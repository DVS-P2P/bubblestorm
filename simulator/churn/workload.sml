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

structure Workload :> WORKLOAD =
   struct
      structure Event = Experiment.Event

      val module = "simulator/churn/workload/"
      
      type churn = {
         nodeGroup : NodeGroup.t,
         percentage : Real32.real
      }

      datatype t =
           EXPONENTIAL_JOIN of churn * Real32.real (* rate *)
         | LINEAR_JOIN of churn * Time.t (* delay between joins *)
         | LINEAR_LEAVE of churn * Time.t (* delay between leaves *)
         | SIMULTANEOUS_JOIN of churn
         | SIMULTANEOUS_LEAVE of churn
         | SIMULTANEOUS_CRASH of churn
         | SIG_USR1 of NodeGroup.t
         | SIG_USR2 of NodeGroup.t

      datatype activeSetChange = datatype NodeGroup.activeSetChange
      
      (* print to log and console *)
      fun myPrint x = (GlobalLog.print x ; print x)

      val leave = ChurnManager.becomeInactive ChurnManager.LEAVE
      val crash = ChurnManager.becomeInactive ChurnManager.CRASH
      
      fun changeMask (nodeGroup, percentage) =
         let
            val active = NodeGroup.activeNodes nodeGroup
            val total = NodeGroup.totalNodes nodeGroup
            val newActive = 
               active + Real32.round (Real32.fromInt total * percentage)
         in
            if newActive < 0 then
               raise At (module ^ "change-mask",
                         Fail "Cannot decrease NodeGroup mask under 0.")
            else if newActive > total then
               raise At (module ^ "change-mask",
                         Fail "Cannot increase NodeGroup mask beyond its size.")
            else NodeGroup.setActiveNodes (nodeGroup, newActive)
         end

      fun linearJoin ({nodeGroup, percentage}, delay) =
         let
            val total = NodeGroup.totalNodes nodeGroup
            val targetGrowth = Real32.round ((Real32.fromInt total) * percentage)
            val growth = ref 0

            fun nextJoin event =
               if !growth = targetGrowth then () else
               let
                  val () = growth := !growth + 1
                  val () = Event.scheduleIn (event, delay)
                  val newActive = (NodeGroup.activeNodes nodeGroup) + 1
               in
                  (case NodeGroup.setActiveNodes (nodeGroup, newActive) of
                     NOCHANGE => ()
                   | ADD nodes => ArraySlice.app ChurnManager.becomeActive nodes
                   | REMOVE _ =>
                        raise At (module ^ "linear-join",
                           Fail "Cannot remove nodes by executing linear join."))
               end
         in
            Event.scheduleIn (Event.new nextJoin, Time.fromSeconds 0)
         end

      fun linearLeave ({nodeGroup, percentage}, delay) =
         let
            val total = NodeGroup.totalNodes nodeGroup
            val change = ref (Real32.round ((Real32.fromInt total) * percentage))

            fun nextLeave event =
               if !change = 0 then () else
               let
                  val () = change := !change - 1
                  val () = Event.scheduleIn (event, delay)
                  val newActive = (NodeGroup.activeNodes nodeGroup) - 1
               in
                  (case NodeGroup.setActiveNodes (nodeGroup, newActive) of
                     NOCHANGE => ()
                   | ADD _ =>
                        raise At (module ^ "linear-leave",
                           Fail "Cannot add nodes by executing linear leave.")
                   | REMOVE nodes => ArraySlice.app leave nodes)
               end
         in
            Event.scheduleIn (Event.new nextLeave, Time.fromSeconds 0)
         end

      fun exponentialJoin ({nodeGroup, percentage}, rate) =
         let
            val total = NodeGroup.totalNodes nodeGroup
            val targetGrowth = Real32.round ((Real32.fromInt total) * percentage)
            val growth = ref 0

            fun nextJoin event =
               if !growth = targetGrowth then () else
               let
                  val () = growth := !growth + 1
                  val currentSize = NodeGroup.activeNodes nodeGroup
                  val delay = (Real32.fromInt (1 + currentSize)) * rate
                  val when = Time.fromSecondsReal32 (1.0 / delay)
                  val () = Event.scheduleIn (event, when)
                  val newActive = currentSize + 1
               in
                  (case NodeGroup.setActiveNodes (nodeGroup, newActive) of
                     NOCHANGE => ()
                   | ADD nodes => ArraySlice.app ChurnManager.becomeActive nodes
                   | REMOVE _ =>
                        raise At (module ^ "exponential-join",
                           Fail "Cannot remove nodes by executing exponential join."))
               end
         in
            Event.scheduleIn (Event.new nextJoin, Time.fromSeconds 0)
         end

      fun sendSignal (name, signal) node =
         if SimulatorNode.isLocal node 
         then 
	         (let
	            fun doIt () =
	               let
	                  val () = Log.logExt (Log.INFO, fn () => module ^ name,
	                     fn () => "received " ^ name ^ " signal")
	               in
	                  signal ()
	               end
	         in
	            SimulatorNode.setCurrent (node, doIt)
	         end      
		      )
      else
      		()
      		
      fun execChurnEvent churn _ =
         case churn of
            EXPONENTIAL_JOIN properties => exponentialJoin properties

          | LINEAR_JOIN properties => linearJoin properties
          | LINEAR_LEAVE properties => linearLeave properties

          | SIMULTANEOUS_JOIN fields =>
               (case changeMask (#nodeGroup fields, #percentage fields) of
                    NOCHANGE => ()
                  | ADD nodes => ArraySlice.app ChurnManager.becomeActive nodes
                  | REMOVE _ => raise At (module ^ "simultaneous-join",
                                 Fail "Cannot remove nodes by executing simultaneous join."))

          | SIMULTANEOUS_LEAVE fields =>
               (case changeMask (#nodeGroup fields, ~(#percentage fields)) of
                    NOCHANGE => ()
                  | REMOVE nodes => ArraySlice.app leave nodes
                  | ADD _ => raise At (module ^ "simultaneous-leave",
                                 Fail "Cannot add nodes by executing simultaneous leave."))

          | SIMULTANEOUS_CRASH fields =>
               (case changeMask (#nodeGroup fields, ~(#percentage fields)) of
                    NOCHANGE => ()
                  | REMOVE nodes => ArraySlice.app crash nodes
                  | ADD _ => raise At (module ^ "simultaneous-crash",
                                 Fail "Cannot add nodes by executing simultaneous crash."))
          | SIG_USR1 group =>
               Iterator.app (sendSignal ("sig-usr1", SimulatorNode.sigUsr1))
                  (NodeGroup.getAliveNodes group)
          | SIG_USR2 group =>
               Iterator.app (sendSignal ("sig-usr2", SimulatorNode.sigUsr2))
                  (NodeGroup.getAliveNodes group)
          
      fun createChurnEvent nodeGroup (churnType & time & percentage & optional) =
         let
            val () = GlobalLog.log (Log.INFO, module ^ "create-churn-event",
                        fn () => "Scheduling \"" ^ churnType ^ "\" for node group \"" ^
                                 (NodeDefinition.name (NodeGroup.definition nodeGroup)) ^
                                 "\" at " ^ time)

            val convert = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
            val fields = {
               nodeGroup = nodeGroup,
               percentage = convert percentage
            }
            val time =
               case Time.fromString time of
                  SOME x => x
                | NONE => raise At (module ^ "create-churn-event",
                                    Fail ("Illegal timestamp: " ^  time))
            val nodeGroupOnlineRatio =
               LifetimeDistribution.onlineRatio o NodeDefinition.lifetime o NodeGroup.definition
            val churn =
               case churnType of
                  "ExponentialJoin" =>
                     let
                        val rate =
                           case Real32.fromString optional of
                              SOME x => x
                            | NONE => raise At (module ^ "create-churn-event",
                                 Fail ("Non-parseable exponential rate parameter: " ^  optional))
                        (* correct join/leave rates according to online ratio *)
                        val rate = Real32./ (rate, nodeGroupOnlineRatio nodeGroup)
                     in
                        EXPONENTIAL_JOIN (fields, rate)
                     end
                | "LinearJoin" =>
                     let
                        val delay =
                           case Time.fromString optional of
                              SOME x => x
                            | NONE => raise At (module ^ "create-churn-event",
                                 Fail ("Non-parseable liner join delay parameter: " ^  optional))
                        (* correct join/leave rates according to online ratio *)
                        val delay = Time.multReal32 (delay, nodeGroupOnlineRatio nodeGroup)
                     in
                        LINEAR_JOIN (fields, delay)
                     end
                | "LinearLeave" =>
                     let
                        val delay =
                           case Time.fromString optional of
                              SOME x => x
                            | NONE => raise At (module ^ "create-churn-event",
                                 Fail ("Non-parseable liner leave delay parameter: " ^  optional))
                        (* correct join/leave rates according to online ratio *)
                        val delay = Time.multReal32 (delay, nodeGroupOnlineRatio nodeGroup)
                     in
                        LINEAR_LEAVE (fields, delay)
                     end
                | "SimultaneousJoin" => SIMULTANEOUS_JOIN fields
                | "SimultaneousLeave" => SIMULTANEOUS_LEAVE fields
                | "SimultaneousCrash" => SIMULTANEOUS_CRASH fields
                | "SigUsr1" => SIG_USR1 nodeGroup
                | "SigUsr2" => SIG_USR2 nodeGroup
                | _ => raise At (module ^ "create-churn-event",
                                 Fail ("Illegal churn type: " ^  churnType))
         in
            Event.scheduleAt (Event.new (execChurnEvent churn), time)
         end

      fun init () = 
         let
     		 	open SQL.Query
     		 	val db = Experiment.database ()
            val churnQuery = prepare db
               "SELECT type, time, percentage, optional_parameter \
               \ FROM workload WHERE name="iS";" oS oS oR oS $
     
   	      fun initChurn nodeGroup =
   	         let
   	            val () = Experiment.addStartFunction
   	               (fn _ => Array.app ChurnManager.initialJoin (NodeGroup.nodes nodeGroup))
   	            val workload = NodeDefinition.workload (NodeGroup.definition nodeGroup)
   	         in
   	            SQL.app (createChurnEvent nodeGroup) churnQuery workload
   	         end
   	
   	      (* node creation *)
   	      val () = myPrint "Creating nodes\n"
   	      val nodeGroups = NodeGroup.getAll ()
   	      val () = Vector.app initChurn nodeGroups
   	      val () = myPrint "Created nodes\n"   	      
         in
            ()
         end
   end
