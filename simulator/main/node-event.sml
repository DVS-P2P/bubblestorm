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

structure NodeEvent :
   sig
      include EVENT
      val nextEvent : unit -> Time.t option
      val runNext : unit -> bool
      
      val new' : SimulatorNode.t -> callback -> t
      val scheduleAt' : SimulatorNode.t -> t * Time.t -> unit
      val scheduleIn' : SimulatorNode.t -> t * Time.t -> unit     
   end
   =
   struct
      structure Event = Experiment.Event

      type t = {
         base : Event.t,
         unhook : (unit -> unit) Ring.element
      }

      type callback = t -> unit

      val time = Event.time
      val nextEvent = Event.nextEvent
      val runNext = Event.runNext

      exception PastEventScheduled

      fun timeOfExecution {base, unhook=_} = Event.timeOfExecution base
      fun timeTillExecution {base, unhook=_} = Event.timeTillExecution base
      fun isScheduled {base, unhook=_} = Event.isScheduled base

      fun cancel {base, unhook} =
         let
            (* canceled events don't need to be cleaned up. *)
            val () = Ring.remove unhook
         in
            Event.cancel base
         end

      local
         fun wrapNew factory node callback =
            let
               (* register an unhook function with the node's cleanup methods.
                * wrap the event handler to remove the unhook from the cleanup
                * on event execution (it's no longer being scheduled then) and
                * set the correct node context. *)
               val unhook = Ring.wrap (fn () => ())
               val () = Ring.add (SimulatorNode.cleanupFunctions node, unhook)
               fun wrappedFn base =
                  let
                     val () = Ring.remove unhook
                     fun handler () = callback { base=base, unhook=unhook }
                  in
                     SimulatorNode.setCurrent (node, handler)
                  end
               val base = factory wrappedFn
               val result = { base=base, unhook=unhook }
               val () = Ring.update (unhook, fn () => cancel result)
            in
               result
            end
      in
         val new' = wrapNew Event.new
         fun new callback = new' (SimulatorNode.current ()) callback
      end

      local
         fun wrap factory node ({base, unhook}, time) =
            if SimulatorNode.isRunning node then
               (
                  (* make sure that the unhook method is in the set of
                     * cleanup methods of the node. *)
                  Ring.add (SimulatorNode.cleanupFunctions node, unhook)
                  ; factory (base, time)
               )
            else () (* do NOT schedule events for offline nodes! *)
      in
         val scheduleAt' = wrap Event.scheduleAt
         val scheduleIn' = wrap Event.scheduleIn
         fun scheduleAt params = scheduleAt' (SimulatorNode.current ()) params
         fun scheduleIn params = scheduleIn' (SimulatorNode.current ()) params
      end
   end
