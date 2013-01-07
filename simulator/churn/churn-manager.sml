(*
   This file is part of BubbleStorm.
   Copyright © 2008-2013 the BubbleStorm authors

   BubbleStorm is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   BubbleStorm is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*)

structure ChurnManager :> CHURN_MANAGER =
   struct
      (* TODO: move into a central config file *)
      val sigkillTimeout = Time.fromMinutes 5
      val removeAddressTimeout = Time.+ (sigkillTimeout, Time.fromSeconds 1)

      val module = "simulator/churn-manager"
      
      fun log (method, message) =
         Log.logExt (Log.INFO, fn () => module ^ "/" ^ method (), message)
      
      datatype mode = LEAVE | CRASH

      (* churn statistics *)
      fun newStatistics name = Statistics.new {
         parents = nil,
         name = "simulator/" ^ name,
         units =" #",
         label = name,
         histogram = Statistics.NO_HISTOGRAM,
         persistent = true
      }
      
      val randStat    = newStatistics "random calls"
      val joinStat    = newStatistics "joins"
      val leaveStat   = newStatistics "leaves"
      val crashStat   = newStatistics "crashes"
      val timeoutStat = newStatistics "leave timeouts"

      fun isReady node =
         SimulatorNode.isOnline node andalso SimulatorNode.isActive node
         
      fun isRunning node = 
         SimulatorNode.isLocal node andalso SimulatorNode.isRunning node

      fun execAsNode (node, method) = SimulatorNode.setCurrent (node, method)

      fun schedule (method, time) =
         Experiment.Event.scheduleIn 
            (Experiment.Event.new (fn _ => method ()), time)

      fun scheduleEvent (method, time) =
         let
            val event = Experiment.Event.new (fn _ => method ())
            val () = Experiment.Event.scheduleIn (event, time)
         in
            event
         end

      fun join node =
         let
            (* kill lingering last session *)
            val () = if isRunning node
               then execAsNode (node, SimulatorNode.destroy) else ()
            
            (* release lingering address of last session. this might be 
               necessary for short intersession times (<5min). *)
            val () = case SimulatorNode.currentAddress node of
               SOME _ => AddressTable.releaseAddress node
             | NONE => ()
             
            val () = AddressTable.assignAddress node
            
            fun startup () =
               let
                  val (command, args) = SimulatorNode.cmdLine ()
                  val run = ApplicationTable.get command
                  val () = log (fn () => "join", fn () => "Starting node " ^
                      SimulatorNode.toString node ^ " with command \"" ^ 
                      command ^ " " ^ (String.concatWith " " args) ^ "\"")
                  val () = Statistics.add joinStat 1.0
                  fun poll () =
                     Statistics.add randStat 
                     (Real32.fromInt (Random.callCount (SimulatorNode.random node)))
                  val () = Statistics.addPoll (randStat, poll)
                  val () = SimulatorNode.join ()
               in
                  run ()
               end
         in
            if SimulatorNode.isLocal node then execAsNode (node, startup)
            else ()
         end
      
      fun terminate node =
         if isRunning node then
            let
               val () = Statistics.add timeoutStat 1.0

               fun killNode () =
                  (  log (fn () => "timeout", fn () => "Node " ^ 
                        SimulatorNode.toString node ^ " is destroyed due to timeout.")
                   ;  SimulatorNode.destroy ()
                  )
            in
               execAsNode (node, killNode)
            end
         else ()
         
      fun leave node =
         let
            val () = AddressTable.scheduleRelease (node, removeAddressTimeout)
            
            fun sigInt () =
               (  log (fn () => "leave", fn () =>
		               "Node " ^ SimulatorNode.toString node ^ " is leaving.")
		          ; SimulatorNode.sigInt ()
		         )
		         
            fun doLeave () =
               let
                  val () = Statistics.add leaveStat 1.0               
                  val timeoutEvent = scheduleEvent (fn () => terminate node, sigkillTimeout)
	               val () = SimulatorNode.setLeaveTimeout (node, timeoutEvent)
               in
                  execAsNode (node, sigInt)
               end
         in
            if isRunning node then doLeave () else ()
         end
      
      fun crash node =
         let
            fun doCrash () =
               (  log (fn () => "crash", fn () =>
                     "Node " ^ (SimulatorNode.toString node) ^ " crashes.")
                ; SimulatorNode.destroy ()
               )
            
            val () = if isRunning node then
                  ( Statistics.add crashStat 1.0 ; execAsNode (node, doCrash) )
               else ()
         in
            AddressTable.releaseAddress node
         end

      fun leaveOrCrash node =
         let
      		val random = Experiment.random ()
            val crashRatio = NodeDefinition.crashRatio (SimulatorNode.definition node)
         in
            if Random.real32 random < crashRatio
               then crash node
            else leave node
         end 

      fun goOnline (node, time) () =
         let
            val time = case time of
               SOME x => x (* pre-defined session time for first session *)
             | NONE => (* default random session time *)
                       (LifetimeDistribution.sessionDuration o
                        NodeDefinition.lifetime o
                        SimulatorNode.definition) node
            (* schedule goOffline *)
            val () = schedule (goOffline node, time)
            val () = SimulatorNode.setOnline true node
         in
            if isReady node then join node else ()
         end
         
      and goOffline node () =
         let
            val time = (LifetimeDistribution.intersessionDuration o
                        NodeDefinition.lifetime o
                        SimulatorNode.definition) node
            val time = Time.max (Time.fromSeconds 1, time)
            val () = schedule (goOnline (node, NONE), time)
            val wasReady = isReady node
            val () = SimulatorNode.setOnline false node
         in
            if wasReady then leaveOrCrash node else ()
         end
         
      fun becomeActive node = if isReady node then join node else ()
      
      fun becomeInactive mode node =
         if SimulatorNode.isOnline node
            then case mode of
                 LEAVE => leave node
               | CRASH => crash node
            else ()
      
      val initialChurnState = LifetimeDistribution.initialState o
          NodeDefinition.lifetime o SimulatorNode.definition

      fun initialJoin node =
         case initialChurnState node of
            LifetimeDistribution.ONLINE time => goOnline (node, SOME time) ()
          | LifetimeDistribution.OFFLINE time => 
               schedule (goOnline (node, NONE), time)
	end
