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
   end
   =
   struct
      val cEventTime = _import "c_event_time" : unit -> Int64.int;
(*       val cEventScheduleAt = _import "c_event_schedule_at" : (Int64.int * int) -> unit; *)
      val cEventScheduleIn = _import "c_event_schedule_in" : (Int64.int * int) -> unit;
      
      datatype t = T of {
         node : Node.t option,
         cb : t -> unit,
         ts : Time.t option ref,
         cleanupRef : Node.cleanupFnRef option ref
      }
      type callback = t -> unit
      
      val eventBucket : t IdBucket.t = IdBucket.new()
      
      fun time () =
         Time.fromNanoseconds64 (cEventTime ())
      
      fun new cb =
         let
            val node = Node.currentNodeOpt () (* store owning node *)
            val this = T { node = node, cb = cb, ts = ref NONE, cleanupRef = ref NONE }
         in
            this
         end
      
      fun timeOfExecution (T { ts, ... }) =
         !ts

      fun timeTillExecution (T { ts, ... }) =
         case !ts of
            SOME t => SOME (Time.- (t, time()))
          | NONE => NONE
      
      fun isScheduled (T { ts, ... }) =
         isSome (!ts)
      
      fun clearEvent (T { ts, cleanupRef, ... }) =
         let
            val() =
               case !cleanupRef of
                  SOME cr => (Node.removeCleanupFunction cr; cleanupRef := NONE)
                | NONE => ()
         in
            ts := NONE
         end
      
      fun cancel this =
(*          (print ("cancel: " ^ Int.toString (!id) ^ "\n"); *)
         clearEvent this
      
      exception PastEventScheduled (* TODO check and throw this *)
      
      fun scheduleAlloc (this as T { node, ts, cleanupRef, ... }) =
         let
            val () = if isScheduled this then cancel this else ()
            val cleanupFn = fn () => ts := NONE
            val () =
               case node of
                  SOME n => cleanupRef := SOME (Node.addCleanupFunction (n, cleanupFn))
                | NONE => cleanupRef := NONE
         in
            IdBucket.alloc (eventBucket, this)
         end
      
      fun scheduleAt (this as T { ts, ... }, tm) =
         let
            val id = scheduleAlloc this
            val () = ts := SOME tm
(*             val () = print ("scheduleAt ID: " ^ Int.toString (id) ^ "\n") *)
         in
            cEventScheduleIn (Time.toNanoseconds64 (Time.- (tm, time ())), id)
         end
      
      fun scheduleIn (this as T { ts, ... }, tm) =
         let
            val id = scheduleAlloc this
            val () = ts := SOME (Time.+ (tm, time ()))
(*             val () = print ("scheduleIn ID: " ^ Int.toString id ^ "\n") *)
         in
            cEventScheduleIn (Time.toNanoseconds64 tm, id)
         end

      fun handleEvent (this as T { node, cb, ts, ... }) =
         if (isSome (!ts)) andalso Time.== (valOf (!ts), time ())
         then (clearEvent this; Node.runInContext (node, fn () => cb this))
         else () (* event was cancelled *)
      
      fun fire id =
         case IdBucket.sub (eventBucket, id) of
            SOME event => ((*print ("fire ID: " ^ Int.toString id ^ "\n");*)
               IdBucket.free (eventBucket, id)
               ; handleEvent event)
          | NONE => (raise Fail ("Invalid event ID fired: " ^ Int.toString id))
      val () = _export "bs_event_fire" : (int -> unit) -> unit; fire
      
   end
