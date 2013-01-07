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

structure WorkloadGenerator :> WORKLOAD_GENERATOR =
   struct
      val module = "kv/coordinator/workload-generator"
      
      datatype node = NODE of {
         pos : int ref,
         interface : KVInterface.workload
      }

      datatype t = T of {
         nodes : node Stack.t,
         itemSize : int,
         cooldown : Time.t,
         phaseDelay : Time.t,
         rate : Real32.real,
         base : Real32.real,
         maxPhases : int,
         delPhases : int,
         maxSteps : int,
         managed : bool,
         updates : int ref
      }
      
      fun unreachable () =
         raise At (module, Fail "accessed empty node stack entry")
      val nillNode = NODE {
         pos = ref ~1,
         interface = {
            nodeID = ID.fromHash (Word8Vector.tabulate (0, fn _ => 0w0)),
            insert = fn _ => unreachable (),
            update = fn _ => unreachable (),
            delete = fn _ => unreachable (),
            find   = fn _ => unreachable ()
         }
      }
            
      fun randomNode (T { nodes, ... }) =
         if Stack.length nodes = 0 then NONE else
            let
               val pos = Random.int (getTopLevelRandom (), Stack.length nodes)
            in
               SOME (Stack.sub (nodes, pos))
            end
         
      fun register (T { nodes, ... }) interface =
         let
            val pos = ref ~1
            val node = NODE {
               pos = pos,
               interface = interface
            }
            val () = pos := Stack.push (nodes, node)
            
            fun quit () =
               let
                  val replacement = case Stack.pop nodes of
                     SOME x => x
                   | NONE => raise At (module, Fail "cannot quit, node stack inconsistent")
                  val NODE { pos=replPos, ... } = replacement
                  val () = replPos := !pos
                  val () = pos := ~1
               in
                  if !replPos = ~1 then () else
                     Stack.update (nodes, !replPos, replacement)
               end
         in
            quit
         end
         
      fun hasLeft (NODE { pos, ... }) = !pos = ~1

      fun findItem (this as T { maxSteps, managed, base, cooldown, phaseDelay, ...}, 
                    publisher, item, step, updateDeleteEvt) findEvt =
         if managed andalso hasLeft publisher then () else
            let
               val () = Statistics.add KVStats.coordFinds 1.0
               val current = !step
               val next = current + 1
               val () = step := next

               val now = LogarithmicMeasurement.calc (base, cooldown) current
               val future = LogarithmicMeasurement.calc (base, cooldown) next
               val wait = Time.- (future, now)
               
               val () = if next < maxSteps
                           then Main.Event.scheduleIn (findEvt, wait)
                           else Main.Event.scheduleIn (updateDeleteEvt, phaseDelay)
            in
               case randomNode this of
                  SOME (NODE { interface = { find, ... }, ... } ) =>
                     find (item, current)
                | NONE => ()
            end
      
      fun deleteItem (this, id, publisher, phase) deleteEvt =
         let
            val T { cooldown, delPhases, managed, ... } = this
            
            fun doDelete node =
               let
                  val NODE { interface = { nodeID, delete, ... }, ... } = node
                  val item = FakeItem.none {
                     id = id,
                     publisher = nodeID
                  }
                  (* timeout => try again with new item & publisher *)
                  val () = Main.Event.scheduleIn (deleteEvt, Time.fromMinutes 1)
                  
                  (* success => schedule retrieve event *)
                  fun onSuccess () =
                     let
                        val () = Statistics.add KVStats.coordDeletes 1.0
                        val () = Main.Event.cancel deleteEvt
                        val () = phase := !phase + 1
                        val action = findItem (this, publisher, item, ref 0, deleteEvt)
                        val findEvt = Main.Event.new action
                     in
                        Main.Event.scheduleIn (findEvt, cooldown)
                     end
               in
                  delete (id, onSuccess)
               end
            in
               if !phase = delPhases then () else
                  if managed
                     then if hasLeft publisher then () else doDelete publisher
                     else case randomNode this of
                              NONE => ()
                            | SOME node => doDelete node
            end

      fun updateItem (this, id, oldPublisher, phase) updateEvt =
         let
            val T { itemSize, cooldown, maxPhases, delPhases, managed, 
                    updates, ... } = this
            
            fun doUpdate publisher =
               let
                  val NODE { interface = { nodeID, update, ... }, ... } = publisher
                  val item = {
                     id = id,
                     publisher = nodeID,
                     version = !phase+1,
                     size = itemSize
                  }
                  (* timeout => try again with new item & publisher *)
                  val () = Main.Event.scheduleIn (updateEvt, Time.fromMinutes 1)
                  
                  (* success => schedule retrieve event *)
                  fun onSuccess () =
                     let
                        val () = updates := !updates + 1
                        val () = Statistics.add KVStats.coordUpdates 1.0
                        val () = Main.Event.cancel updateEvt
                        val () = phase := !phase + 1
                        val action = findItem (this, publisher, item, ref 0, updateEvt)
                        val findEvt = Main.Event.new action
                     in
                        Main.Event.scheduleIn (findEvt, cooldown)
                     end
               in
                  update (item, onSuccess)
               end
            in
               if !phase = maxPhases then
                  if delPhases = 0 then () else
                     let
                        (* start deleting *)
                        val deleteAction = deleteItem (this, id, oldPublisher, ref 0)
                        val deleteEvent = Main.Event.new deleteAction
                     in
                        deleteAction deleteEvent
                     end
               (* execute update *)
               else if managed
                     then if hasLeft oldPublisher then () else doUpdate oldPublisher
                     else case randomNode this of
                              NONE => ()
                            | SOME newPublisher => doUpdate newPublisher
            end
      
      fun createItem (this as T { itemSize, cooldown, ... }) =
         (* select publisher *)
         case randomNode this of
            NONE => ()
          | SOME publisher =>
         let
            val NODE { interface = { nodeID, insert, ... }, ... } = publisher
            (* define item *)
            val id = ID.fromRandom (getTopLevelRandom ())
            val item = {
               id = id,
               publisher = nodeID,
               version = 0,
               size = itemSize
            }
            
            (* timeout => try again with new item & publisher *)
            fun timeout _ = createItem this 
            val timeoutEvt = Main.Event.new timeout
            val () = Main.Event.scheduleIn (timeoutEvt, Time.fromMinutes 1)
            
            (* success => schedule retrieve event *)
            fun onSuccess () =
               let
                  val () = Statistics.add KVStats.coordInserts 1.0
                  val () = Main.Event.cancel timeoutEvt
                  val updateAction = updateItem (this, id, publisher, ref 0)
                  val updateEvent = Main.Event.new updateAction
                  val findAction = findItem (this, publisher, item, ref 0, updateEvent)
                  val findEvent = Main.Event.new findAction
               in
                  Main.Event.scheduleIn (findEvent, cooldown)
               end
         in
            insert (item, onSuccess)
         end
      
      fun scheduleNextInsert (T { rate, nodes, ... }) event =
         let
            val n = Real32.fromInt (Int.max (Stack.length nodes, 1))
            val baseDelay = 60.0 / (rate * n)
            (* Poisson arrival rate = exponential inter-arrival times *)
            val real64to32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
            val rand = (real64to32 o Random.exponential o getTopLevelRandom) ()
            val delay = Time.fromSecondsReal32 (baseDelay * rand)
         in
            Main.Event.scheduleIn (event, delay)
         end
         
      fun startAction (this as T { updates, ... }) event =
         (* skip an insert for every update that has happened to keep the 
            network load steady *)
         let
            val () = if !updates = 0 then createItem this
                     else updates := !updates-1
         in
            scheduleNextInsert this event
         end
      
      fun scheduleAction this =
         let
            val event = Main.Event.new (startAction this)
         in
            Main.Event.scheduleIn (event, Time.zero)
         end
         
      fun new { rate, itemSize, cooldown, steps, base, phases, delPhases, phaseDelay, managed } =
         let
            val nodes = Stack.new { nill = nillNode }
            fun countClients () = Statistics.add KVStats.coordClients 
               (Real32.fromInt (Stack.length nodes))
            val () = Statistics.addPoll (KVStats.coordClients, countClients)
            
            val this = T {
               nodes = nodes,
               rate = rate,
               itemSize = itemSize,
               cooldown = cooldown,
               phaseDelay = phaseDelay,
               base = base,
               maxPhases = phases,
               delPhases = delPhases,
               maxSteps = steps,
               managed = managed,
               updates = ref 0
            }
            val () = scheduleAction this
         in
            this
         end
   end
