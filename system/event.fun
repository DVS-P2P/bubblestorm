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

functor Event() :> EVENT_EXTRA =
   struct
      structure Heap = ManagedHeap(Time)
      datatype t = T of callback Heap.record
      withtype callback = t -> unit
      
      val heap = Heap.new ()
      val now = ref Time.zero
      
      fun time () = !now

      fun new callback = T (Heap.wrap (Time.zero, callback)) 
      
      fun timeOfExecution (T event) =
         case Heap.sub event of
            (false, _, _) => NONE
          | (true, time, _) => SOME time
          
      fun timeTillExecution (T event) =
         case Heap.sub event of
            (false, _, _) => NONE
          | (true, time, _) => SOME (Time.- (time, !now))
      
      fun isScheduled (T event) = #1 (Heap.sub event)
      
      exception PastEventScheduled
      fun scheduleAt (T event, time) =
         let
            val () = if Time.< (time, !now) then raise PastEventScheduled else ()
         in
            Heap.update (heap, event, time)
         end
      
      fun scheduleIn (event, time) = 
         scheduleAt (event, Time.+ (time, !now))
         
      fun cancel (T event) =
         Heap.remove (heap, event)
       
      fun nextEvent () =
         case Heap.peek heap of
            NONE => NONE
          | (SOME e) => case Heap.sub e of (_, time, _) => SOME time

      fun runTill stop =
         case Heap.popBounded (heap, stop) of
            NONE => now := Time.max (stop, !now)
          | (SOME e) => 
               case Heap.sub e of (_, time, callback) =>
               (now := time; callback (T e); runTill stop)

      fun runNext () =
         case Heap.pop heap of
            NONE => false
          | SOME e =>
               case Heap.sub e of (_, time, callback) =>
               (now := time; callback (T e); true)
   end
