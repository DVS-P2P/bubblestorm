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

structure JunkManager :> JUNK_MANAGER =
   struct
      val module = "bubblestorm/bubble/managed/junk-manager"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)

      datatype t = T of {
         state : BasicBubbleType.bubbleState,
         backend : Backend.t,
         findMaintainer : FindMaintainer.t,
         (* the number of entries a bucket may receive before being flushed *)
         threshold : int ref,
         (* flush threshold counters for odd and even bucket *)
         current  : { even : int, odd : int } ref,
         previous : { even : int, odd : int } ref,
         stable   : { even : int, odd : int } ref,
         statistics : Stats.managed
      }
      
      (* TODO: make goodness configurable *)
      val goodness = 0.8
      val minThreshold = 5
      
      fun flush (T { backend, findMaintainer, ... }, filter) =
         let
            val () = log (fn () =>
               case (filter true, filter false) of
                  (false, false) => raise At (module, Fail "flushing, but no bucket selected")
                | (false, true)  => "flushing even bucket"
                | (true,  false) => "flushing odd bucket"
                | (true,  true)  => "flushing both buckets")
            val () = Backend.flush backend filter
         in
            FindMaintainer.send findMaintainer filter
         end

      fun onRoundSwitch (this as T { state, findMaintainer, threshold, current, 
                                     previous, stable, statistics, ... }) =
         let
            (* compute new junk threshold *)
            val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
            val stats = BasicBubbleType.stats state
            val d = SystemStats.degree stats
            val D0 = toReal32 (SystemStats.d0 stats)
            val D1 = toReal32 (SystemStats.d1 stats)
            val avgShare = Real32.fromInt (FindMaintainer.bubbleSize findMaintainer)
            val myShare = avgShare * d * D0 / D1
            val threshold' = myShare/goodness - myShare/2.0
            val () = threshold := Int.max (Real32.ceil threshold', minThreshold)
            val () = log (fn () => "junk threshold = " ^ Int.toString (!threshold))

            (* check both buckets *)
            (* don't use the junk count this round, because junk level is based
               on current state, whereas threshold parameters from the measurement
               are one round old. *)
            val evenOverflow = #even (!stable) > !threshold
            val oddOverflow  = #odd  (!stable) > !threshold
            (* reset counter and copy current values to the stable counters *)
            val () = stable := {
               even = if evenOverflow then 0 else #even (!previous),
               odd  = if oddOverflow  then 0 else #odd  (!previous)
            }
            val () = previous := {
               even = if evenOverflow then 0 else #even (!current),
               odd  = if oddOverflow  then 0 else #odd  (!current)
            }
            val () = current := {
               even = if evenOverflow then 0 else #even (!current),
               odd  = if oddOverflow  then 0 else #odd  (!current)
            }
            (* log flush events *)
            fun flushes bucket = if bucket then 0.5 else 0.0
            val () = Statistics.add (#flushes statistics)
                        (flushes evenOverflow + flushes oddOverflow)
            (* if junk threshold is reached flush the *other* bucket *)
            fun filter bucket = (oddOverflow andalso not bucket) orelse 
                                (evenOverflow andalso bucket)
         in
            if evenOverflow orelse oddOverflow then flush (this, filter) else ()
         end

      (* only flush on round switches to avoid being pushed into flushing and 
         reloading with old bubble sizes shortly before a round switch. 
         this would be caused by the nodes that switch before us and flood us 
         with findStorage and store requests based on the new bubble sizes. *)      
      fun adjust (T { current as ref { even, odd }, ... }) (oddFlag, delta) =
         current := {
            even = if oddFlag then even else even + delta,
            odd  = if oddFlag then odd + delta else odd
         }
         
      fun new { state, backend, findMaintainer, statistics } =
         let
            val junkThreshold = ref minThreshold
            (* junk threshold statistics *)
            fun ifOnline f =
               if SystemStats.status (BasicBubbleType.stats state) = SystemStats.ONLINE 
               then f () else ()
            fun pullJunk () =
               ifOnline (fn () => Statistics.add (#threshold statistics)
                  (Real32.fromInt (!junkThreshold)))
            val () = Statistics.addPoll (#threshold statistics, pullJunk)
(*
            val this = T {
               state     = state,
               backend   = backend,
               findMaintainer = findMaintainer,
               threshold = junkThreshold,
               current   = ref { even = 0, odd = 0 },
               previous  = ref { even = 0, odd = 0 },
               stable    = ref { even = 0, odd = 0 }
            }
            fun onSigUsr () = ( flush (this, fn _ => true) ; Main.REHOOK )
            val _ = Main.signal (Posix.Signal.usr1, onSigUsr)
         in
            this
         end
*)
         in
            T {
               state     = state,
               backend   = backend,
               findMaintainer = findMaintainer,
               threshold = junkThreshold,
               current   = ref { even = 0, odd = 0 },
               previous  = ref { even = 0, odd = 0 },
               stable    = ref { even = 0, odd = 0 },
               statistics = statistics
            }
         end
   end
