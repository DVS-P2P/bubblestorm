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

structure Backend :> BACKEND =
   struct
      fun module () = "bubblestorm/bubble/managed/backend"

      datatype t = T of {
         types : unit -> BasicBubbleType.t list,
         (* a list of all currently registered maintainers *)
         maintainers : StorageMaintainer.t Ring.t,
         (* the number of registered maintainers *)
         size : int ref,
         (* JunkManager function to adjust junk counters *)
         adjustJunk : bool * int -> unit
      }
      
      fun onDeadMaintainer (T { size, adjustJunk, ... }, elem) cleanLeave =
         let
            val maintainer = Ring.unwrap elem
            val bucket = StorageMaintainer.bucket maintainer
            val () = if cleanLeave then adjustJunk (bucket, ~1) else ()
            val () = size := !size - 1
         in
            Ring.remove elem
         end
         
      fun addMaintainer (this as T { maintainers, size, adjustJunk, ... }, maintainer) =
         let
            (* keep a reference to the maintainer *)
            (* TODO: can we deal with duplicate registrations? *)
            val elem = Ring.wrap maintainer
            val () = Ring.add (maintainers, elem)
            val () = adjustJunk (StorageMaintainer.bucket maintainer, 1)
            val () = size := !size + 1
         in
            onDeadMaintainer (this, elem)
         end
      
      (* retrieve managed data store of a bubbletype *)
      (* FIXME: code duplication! should be in BasicBubbleType *)
      fun getDataStore bubble =
         case BasicBubbleType.class bubble of
            BasicBubbleType.MANAGED { datastore, ... } => datastore
          | _ => raise At (module (), Fail "processing request for non-maintained bubble type")

      fun flush (T { types, maintainers, ... }) filter =
         let
            (* flush the maintainers *)
            fun quit maintainer =
               (* select the affected maintainers *)
               if filter (StorageMaintainer.bucket maintainer)
                  then StorageMaintainer.flush maintainer else ()
            val () = Iterator.app (quit o Ring.unwrap) (Ring.iterator maintainers)

            (* flush the data *)
            fun flushStore datastore = ManagedDataStore.flush datastore filter
         in
            List.app (flushStore o getDataStore) (types ())
         end
                  
      fun new { state, types, adjustJunk, statistics : Stats.managed } =
         let
            (* for timeline statistics based on the age of the peer *)
            val birth = Main.Event.time ()
            fun age () = Stats.getAgeSlot (Time.- (Main.Event.time (), birth))
            fun ifOnline f =
               if SystemStats.status (BasicBubbleType.stats state) = SystemStats.ONLINE 
               then f () else ()
 
             (* maintainers per storage peer statistics *)
            val size = ref 0
            fun pullSize () = ifOnline (fn () =>
               TimelineStatistics.add (#maintainers statistics) 
                  (age ()) (Real32.fromInt (!size))
               )
            val () = TimelineStatistics.addPoll (#maintainers statistics, pullSize)

            (* replica count statistics *)
            fun count (bubble, counter) =
               ManagedDataStore.size (getDataStore bubble) () + counter
            fun pullSize () = ifOnline (fn () => Statistics.add (#replicas statistics)
                                 (Real32.fromInt (List.foldl count 0 (types ()))))
            val () = Statistics.addPoll (#replicas statistics, pullSize)
         in
            T {
               types       = types,
               maintainers = Ring.new (),
               size        = size,
               adjustJunk  = adjustJunk
            }
         end
   end
