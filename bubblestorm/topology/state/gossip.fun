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

functor Gossip(structure Real : REAL
               val serial : (Real.real, Real.real, unit) Serial.t)
   :> GOSSIP where type Real.real = Real.real =
   struct
      val module = "topology/gossip"
      
      structure Round =
         struct
            type t = Word32.word
            
            local
               open Word32
               val b31 = << (0w1, 0w31)
            in
               val op == : t * t -> bool = op =
               fun a < b = (a-b) >= b31
            end
         end
      structure Round = OrderFromLessEqual(Round)
      
      type packet = {
         round    : Word32.word,
         fishSize : Word64.word,
         fish     : Real.real,
         values   : Word8Vector.vector
      }
      
      type data = {
         round    : Word32.word,
         fishSize : Word64.word,
         fish     : Real.real,
         values   : Real.real vector
      }
      
      datatype t = T of {
         last     : data ref,
         state    : data ref,
         steady   : int ref,
         min      : int, (* How many minimums there are *)
         max      : int, (* How many maximums there are *)
         sum      : int, 
         pull     : unit -> Real.real vector,
         push     : Word32.word * Real.real vector -> unit,
         init     : Word32.word * Real.real vector -> unit,
         freq     : Time.t,
         initd    : bool ref
      }
      
      structure Real = Real
      
      val zero = Real.fromInt 0
      val one = Real.fromInt 1
      val epsilon = Real.fromManExp { man = one, exp = ~Real.precision }
      val minFish = Real.minNormalPos (* Require full precision *)
      
      local
         open Serial
      in
         fun ops len = methods (vector (serial, len))
      end
      
      fun fromPacket (T { min, max, sum, ...}, data) =
         let
            val { round, fishSize, fish, values } = data
            val { fromVector, ... } = ops (min+max+sum)
            val values = fromVector values
         in
            { round=round, fishSize=fishSize, fish=fish, values=values }
         end
      
      fun toPacket (T { min, max, sum, ...}, data) =
         let
            val { round, fishSize, fish, values } = data
            val { toVector, ... } = ops (min+max+sum)
            val values = toVector values
         in
            { round=round, fishSize=fishSize, fish=fish, values=values }
         end
      
      fun push (T { min, max, state, push, last, init, ... }, isInit) =
         let
            val { round, fishSize, fish, values, ... } = !state
            fun fixup (i, v) = if i < min+max then v else Real./ (v, fish)
         in
            if fishSize = 0w0 then
               Log.log (Log.DEBUG, module, fn () => "Skipping fishSize 0")
            else
               (last := !state
                ; if isInit 
                  then init (round, Vector.mapi fixup values)
                  else push (round, Vector.mapi fixup values))
         end
      
      fun skipRound (this as T { state, steady, min, max, sum, ... }, 
                     init, newRound) =
         let
            fun nothing i = if i < min then Real.posInf 
               else if i < min+max then Real.negInf else zero
            val values = Vector.tabulate (min+max+sum, nothing)
            
            val () = push (this, init)
            val () = steady := 0
         in
            state := {
               round    = newRound,
               fish     = one,
               fishSize = 0w0,
               values   = values
            }
         end
      
      fun newRound (this as T { state, steady, pull, ... }, 
                    address, newRound) =
         case address of
            NONE => skipRound (this, false, newRound)
          | SOME addr => 
            let
               fun hash () = CUSP.Address.hash addr o Hash.word32 newRound
               val hash = RoundHash.make hash
               
               val () = push (this, false)
               val () = steady := 0
               
               val fishSize = hash ((), ())
               val fishSize = if fishSize = 0w0 then 0w1 else fishSize
               val () = Log.log (Log.DEBUG, module, fn () => 
                   "Starting new round " ^ Word32.toString newRound ^ 
                   " with fish size " ^ Word64.toString fishSize)
            in
               state := {
                  round    = newRound,
                  fish     = one,
                  fishSize = fishSize,
                  values   = pull ()
               }
            end
      
      fun isChanged (minI, maxI, valsA, fishA, sizeA, valsB, fishB, sizeB) =
         if not (sizeA = sizeB) then false else
            let
               open Real
               val tolerance = fromInt Config.measurementAccuracySlack * epsilon
               fun differ (x, y) =
                  let
                     val size = max (max (abs x, abs y), minPos)
                     val delta = abs (x - y) / size
                  in
                     delta > tolerance
                  end
               fun loop (i, v, a) =
                  a orelse
                  (if Int.< (i, Int.+ (minI, maxI))
                   then differ (v, Vector.sub (valsB, i))
                   else differ (v / fishA, Vector.sub (valsB, i) / fishB))
            in
               Vector.foldli loop false valsA
            end
      
      fun process (this as T { state, min, max, ... }, packet) =
         let
            val data = fromPacket (this, packet)
            
            val { fishSize=myFishSize, fish=myFish, values=myValues, ... } = !state
            val { round, fishSize=inFishSize, fish=inFish, values=inValues } = data
            
            fun my i = Vector.sub (myValues, i)
            fun combine (i, v) =
               if i < min then Real.min (v, my i)
               else if i < min+max then Real.max (v, my i) else Real.+ (v, my i)
            val values = Vector.mapi combine inValues
            
            val (fish, fishSize) =
               case Word64.compare (inFishSize, myFishSize) of
                  LESS => (myFish, myFishSize)
                | EQUAL => (Real.+ (myFish, inFish), myFishSize)
                | GREATER => (inFish, inFishSize)
            
            val () =
               state := {
                  round    = round,
                  fish     = fish,
                  fishSize = fishSize,
                  values   = values
               }
         in
            (fish, values)
         end
      
      fun recv (this as T { initd, state, steady, min, max, ... }, address, degree, packet) =
         if not (!initd) then raise At (module, Fail "recv not initd") else
         let
            val { round=myRound, values=myValues, fish=myFish, fishSize=myFishSize, ... } = !state
            val { round=inRound, fishSize=inFishSize, ... } = packet
         in
            case Round.compare (inRound, myRound) of
               LESS => ()
             | GREATER =>
               let
                  (* Move our round up to match *)
                  (* If we didn't participate in the last round, then don't
                   * contribute now either. This probably means we joined
                   * DURING the round and would now slow the convergence.
                   *)
                  (* TODO: we should get the missed round's result somehow *)
                  val () =
                     if myFishSize = 0w0 orelse Round.!= (inRound, myRound+0w1)
                     then skipRound (this, false, inRound)
                     else newRound (this, address, inRound)
               in
                  ignore (process (this, packet))
               end
             | EQUAL =>
               let
                  val (newFish, newValues) = process (this, packet)
                  
                  val changed = 
                    isChanged (min, max, myValues, myFish, myFishSize, newValues, newFish, inFishSize)
                  val () = steady := (if changed then 0 else !steady + 1)
               in
                  if !steady < degree + Config.gossipExtraAgreement then () else
                  newRound (this, address, myRound + 0w1)
               end
         end
            
      fun recover (this as T { state, ... }, packet) =
         let
            val { round=newRound, ... } = !state
            val { round=oldRound, ... } = packet
         in
            if Round.!= (newRound, oldRound) then () else
            ignore (process (this, packet))
         end
      
      fun sample (this as T { initd, min, max, state, ... }, ratio) =
         if not (!initd) then raise At (module, Fail "sample not initd") else
         let
            val take = ratio
            val keep = Real.- (one, take)
            
            val { round, fish, fishSize, values } = !state
            
            val fishTake = Real.* (fish, take)
            val fishKeep = Real.* (fish, keep)
            
            fun takeFn (i, v) = if i < min+max then v else Real.* (v, take)
            fun keepFn (i, v) = if i < min+max then v else Real.* (v, keep)
            
            val ok = Real.> (fishTake, minFish) andalso 
                     (Real.> (fishKeep, minFish) orelse
                      Real.== (ratio, Real.fromInt 1))
         in
            if not ok then NONE else
            let
               val () = state := {
                  round    = round,
                  fish     = fishKeep,
                  fishSize = fishSize,
                  values   = Vector.mapi keepFn values
               }
            in
               SOME (toPacket (this, {
                  round    = round,
                  fish     = fishTake,
                  fishSize = fishSize,
                  values   = Vector.mapi takeFn values
               }))
            end
         end
      
      fun lastRound (this as T { last, ... }) = toPacket (this, !last)
      fun freq (T { freq, ... }) = freq
      
      fun new { freq, pull, push, init, min, max, sum, stat } =
         let
            val initialValues = {
               round    = 0w0,
               fishSize = 0w0,
               fish     = one,
               values   = Vector.tabulate (min+max+sum, fn _ => zero)
            }
            val this = T { 
               last   = ref initialValues,
               state  = ref initialValues,
               steady = ref 0,
               min    = min,
               max    = max,
               sum    = sum,
               pull   = pull,
               push   = push,
               init   = init,
               freq   = freq,
               initd  = ref false
            }
            (* statistics poll functions *)
            fun statPoll (stat, i) () =
               let
                  val T { state, min, max, ... } = this
                  val { values, fish, fishSize, ... } = !state
                  val value = Vector.sub (values, i)
                  val value = if (i < min+max) then value else Real./ (value, fish)
               in
                  if fishSize <> 0w0 andalso Real.isFinite value
                  then Statistics.add stat (Real32.fromLarge IEEEReal.TO_NEAREST (Real.toLarge value))
                  else ()
               end
            val () =
               Vector.appi
               (fn (i, st) =>
                  Option.app (fn s => Statistics.addPoll (s, statPoll (s, i))) st)
               stat
         in
            this
         end
      
      fun initCreate (this as T { state, initd, pull, ... }, addr) =
         if !initd then () else
         let
            val () = 
              Log.log (Log.DEBUG, module, fn () => 
                "Gossip state initialized by primordial node creation")
            val () = initd := true
            val () = 
              state := {
                round    = 0w41,
                fishSize = 0w1, (* non-zero to get it reported *)
                fish     = one,
                values   = pull ()
              }
         in
            newRound (this, SOME addr, 0w42)
         end

      (* This will report the prior round to the user.
       * Then we participate in the current round w/o changing the values.
       *)
      fun initJoin (this as T { state, initd, ... }, lastRound) =
         if !initd then () else
         let
            val () = 
              Log.log (Log.DEBUG, module, fn () => 
                "Gossip state initialized by bootstrap-ok join message")
            val lastRound = fromPacket (this, lastRound)
            val { round, ... } = lastRound
            val () = initd := true
            val () = state := lastRound
         in
            skipRound (this, true, round + 0w1)
         end
      
      fun deinit (T { initd, state, ... }) = 
         let
            (* Clear the fishSize so we stop reporting our value *)
            val { round, fishSize=_, fish, values } = !state
            val () = state := { round=round, fishSize=0w0, fish=fish, values=values }
         in
            initd := false
         end
   end
