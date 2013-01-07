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

functor KeyValueApplication (Engine : KV_ENGINE) :> KEY_VALUE_APPLICATION =
   struct
      val module = "kv"
      
      (* helper functions *)
      val now = Main.Event.time
      local
         open Time
      in
         fun addDelayStatistic stat time =
            Statistics.add stat (toSecondsReal32 (now () - time))
      end

      fun logAction (function, action, id) NONE =
         Log.log (Log.INFO, module ^ "/" ^ function, 
         fn () => action ^ " with ID " ^ ID.toString id)
      |   logAction (params as (function, _, _)) (SOME item) =
         let 
            val () = logAction params NONE
         in
            Log.log (Log.DEBUG, module ^ "/" ^ function, fn () => FakeItem.toString item)
         end
      
      (* insert item *)
      fun onInsert insert (item as { id, ... }, confirm) =
         let
            val () = logAction ("insert", "insert item", id) NONE
            val () = insert (id, FakeItem.encode item)
         in
            confirm ()
         end
      
      (* update item *)
      fun onUpdate update (item as { id, ... }, confirm) =
         let
            val () = logAction ("update", "update item", id) NONE
            val () = update (id, FakeItem.encode item)
         in
            confirm ()
         end

      (* delete item *)
      fun onDelete delete (id, confirm) = 
         let
            val () = logAction ("delete", "delete item", id) NONE
            val () = delete id
         in
            confirm ()
         end
      
      (* find item *)
      fun onFind (find, timeout) (item as { id, ... }, step) =
         let
            val () = logAction ("find", "find item", id) (SOME item)
            val tStart = now ()
            val firstHit = ref NONE
            val correctHit = ref NONE
            val matches = ref 0
            val correct = ref 0
            
            fun increment x = x := !x + 1
            fun optSet (x, y, compare) =
               x := SOME (Option.getOpt (Option.map (fn z => compare (y, z)) (!x), y))

            (* receive an individual result *)
            fun receive NONE = ()
              | receive (SOME result) =
               let
                  val () = increment matches
                  val () = optSet (firstHit, now (), Time.min)
                  val result = FakeItem.decode result
               in
                  if FakeItem.== (result, item)
                     then 
                        let
                           val () = increment correct
                           val () = optSet (correctHit, now (), Time.min)
                        in
                           logAction ("result/correct", "found correct item", id) (SOME result)
                        end
                     else logAction ("result/incorrect", "found incorrect item", id) (SOME result)
               end
               
            val cancel = find (id, receive)
            
            (* log the delay for first and first correct result *)
            local
               open Time
               fun addOptDelayStatistic' stat time =
                  TimelineStatistics.add stat step (toSecondsReal32 (time - tStart))
            in
               fun addOptDelayStatistic (stat, delay) =
                  Option.app (addOptDelayStatistic' stat) (!delay)
            end
            
            (* evaluate the results of the query after the timeout *)
            fun evaluateReplication _ =
               let
                  val add = fn stat => TimelineStatistics.add stat step
                  val recall = if !correct > 0 then 1.0 else 0.0
                  val () = add KVStats.recall recall
                  val () = if !matches = 0 then () else
                     add KVStats.precision (if !correct > 0 then 1.0 else 0.0)
                  val () = add KVStats.matchCount (Real32.fromInt (!matches))
                  val () = add KVStats.correctCount (Real32.fromInt (!correct))

                  val () = addOptDelayStatistic (KVStats.firstHit, firstHit)
                  val () = addOptDelayStatistic (KVStats.correctHit, correctHit)
                  val () = logAction ("result/summary", "found " ^ Int.toString (!correct) ^ 
                     " correct and " ^ Int.toString (!matches) ^ " total items", id) NONE
               in
                  cancel ()
               end

            fun evaluateDelete _ =
               let
                  val add = fn stat => TimelineStatistics.add stat step
                  val isDeleted = if !matches = 0 then 1.0 else 0.0
                  val () = add KVStats.isDeleted isDeleted
                  val () = logAction ("result/delete", "found " 
                     ^ Int.toString (!matches) ^ " undeleted items", id) NONE
               in
                  cancel ()
               end
               
            val evaluate = if FakeItem.isNone item 
               then evaluateDelete else evaluateReplication
         in
            Main.Event.scheduleIn (Main.Event.new evaluate, timeout)
         end
      
      datatype onlineStatus = OFFLINE | ONLINE
      
      (* how many nodes are actually part of the overlay? *)
      fun setupOverlayStatistics () =
         let
            val status = ref OFFLINE
            fun toReal ONLINE = 1.0
            |   toReal OFFLINE = 0.0
            fun poll () = ((Statistics.add KVStats.joined) o toReal o !) status
            val () = Statistics.addPoll (KVStats.joined, poll)
         in
            status
         end
         
      (* joining the overlay *)
      fun onJoinComplete (workloadConfig, stopWorkload, status, time) () =
         let
            val () = Log.log (Log.INFO, module, fn () => "Join complete.")
            val () = status := ONLINE
            val () = addDelayStatistic KVStats.joinTime time
            val () = stopWorkload := KVProtocol.register workloadConfig 
         in
            ()
         end

      (* leaving the network *)            
      fun registerLeaveHandler (leave, stopWorkload, status) =
         let
            fun onSigInt () =
               let
                  val () = Log.log (Log.INFO, module, fn () => "Received SIGINT, leaving...")
                  val tLeave = now ()

                  fun onExit ((), ()) =
                     let
                        val () = Log.log (Log.INFO, module, fn () => "Leave complete, stop.")
                        val () = addDelayStatistic KVStats.leaveTime tLeave
                     in
                        Main.stop ()
                     end

                  val (onStopComplete, onLeaveComplete) = combine onExit
                  val () = (!stopWorkload) onStopComplete
                  val () = leave onLeaveComplete
                  val () = status := OFFLINE
               in
                  Main.UNHOOK
               end
         in
            ignore (Main.signal (Posix.Signal.int, onSigInt))
         end
         
      fun main () =
         let
            val config = WorkloadConfig.readArgs ()
            val args = WorkloadConfig.arguments config
            val queryTimeout = WorkloadConfig.queryTimeout config
            
            val (overlay, engine) = Engine.new args
            val { join, leave } = overlay
            val { nodeID, insert, update, delete, find } = engine

            (* TODO setup coordinator connection *)
            val interface = {
               nodeID = nodeID,
               insert = onInsert insert,
               update = onUpdate update,
               delete = onDelete delete,
               find = onFind (find, queryTimeout)
            }
            val workloadConfig = {
               coordinator = WorkloadConfig.coordinator config,
               interface = interface,
               keepAlive = WorkloadConfig.keepAlive config
            }
            val stopWorkload = ref (fn notify => notify ())
            
            val status = setupOverlayStatistics ()
            val () = registerLeaveHandler (leave, stopWorkload, status)
            val () = Log.log (Log.INFO, module, fn () => "Connecting...")
         in
            join (onJoinComplete (workloadConfig, stopWorkload, status, now ()))
         end

      val () = Main.run (Engine.applicationName, main)
   end
