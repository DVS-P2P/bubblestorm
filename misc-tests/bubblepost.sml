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

signature PEER =
   sig
      type t
      
      val new : real * Random.t -> t
      
      val id : t -> word
      val capacity : t -> real
      val neighbors : t -> t list
      val setNeighbors : t * t list -> unit
      val responsible : word * word -> t -> bool
      val responsibleNeighbors : word * word -> t -> t Iterator.t
      (*val neighborCount : t -> int*)
   end
   
structure Peer :> PEER =
   struct
      datatype t = T of {
         id : word,
         capacity : real,
         neighbors : t list ref
      }
      
      fun new (capacity, rand) =
         T {
            id = Word.orb (Random.word (rand, NONE), 0w1), (* odd random number *)
            capacity = capacity,
            neighbors = ref []
         }
   
      fun id (T { id, ... }) = id
      fun capacity (T { capacity, ... }) = capacity
      fun neighbors (T { neighbors, ... }) = !neighbors
      fun setNeighbors (T { neighbors, ... }, nuNeighbors) =
         neighbors := nuNeighbors
      fun responsible (item, responsibility) (T { id, ... }) = item * id < responsibility
      fun responsibleNeighbors (item, responsibility) (T { neighbors, ... }) = 
         Iterator.filter (responsible (item, responsibility)) (Iterator.fromList (!neighbors))
   end

structure IntKey =
   struct
      type t = int
      val op == = op =
      val hash = Hash.int
   end
structure IntMap = HashTable(IntKey)

structure WordKey =
   struct
      type t = word
      val op == = op =
      val hash = Hash.word
   end
structure WordMap = HashTable(WordKey)

val rand = Random.new 0w42

(******************************************************************************)
(*                   Parameters & shared data structures                      *)
(******************************************************************************)

val n = 10000
val deg = 16
(*val lambda = Real.Math.e*)
val lambda = 4.0

fun createPeer _ = Peer.new (1.0, rand)
val peers = Vector.tabulate (n, createPeer)

(******************************************************************************)
(*                   Bubble sizes                                             *)
(******************************************************************************)

val D1 = Real.fromInt (deg * n)
val D2 = Real.fromInt (deg * deg * n)

fun responsibilityBubbleSize () =
   let
      open Real
      open Math      
   in
      ceil (sqrt (lambda * D1 * D1 / D2))  
   end
val dataBubbleSize = responsibilityBubbleSize
fun lookupBubbleSize () = 3

val responsibility =
   let
      val maxWord = Real.fromLargeInt (Word.toLargeInt (Word.notb 0w0))
      val p = Real.fromInt (dataBubbleSize ()) / (Real.fromInt n)
   in
      Word.fromLargeInt (Real.toLargeInt IEEEReal.TO_POSINF (maxWord * p))
   end
(******************************************************************************)
(*                   Neighbor initialization                                  *)
(******************************************************************************)

(*
fun permute (vector, size) =
   let
      val arr = Array.tabulate (n, fn i => Vector.sub (vector, i))
      fun flip (x, y, z) =
         let
            val () = Array.update (arr, x, Array.sub (arr, y))
         in
            Array.update (arr, y, z)
         end
      fun permute1 (pos, item) = flip (x, x + Rand.int (rand, n - x), item)
      val slice = ArraySlice.slice (arr, 0, SOME size)
      val () = ArraySlice.appi permute1 slice
   in
      ArraySlice.vector slice
   end
*)

fun selectWithCollisions size =
   let
      val map = IntMap.new ()
      fun select _ = IntMap.set (map, Random.int (rand, n), ())
      val it = Iterator.fromInterval { start=0, stop=size, step=1 }
      val () = Iterator.app select it
      fun getPeers (pos, ()) = Vector.sub (peers, pos)
   in
      Iterator.toList (Iterator.map getPeers (IntMap.iterator map))
   end
   
fun selectNeighbors peer =
   let
      val size = responsibilityBubbleSize ()
   in
      Peer.setNeighbors (peer, selectWithCollisions size)
   end

val () = Vector.app selectNeighbors peers

(******************************************************************************)
(*                   Bubble Lookup                                            *)
(******************************************************************************)

fun selectRandomPeer () = Vector.sub (peers, Random.int (rand, n))

fun protoLookup flag id =
   let
      val map = WordMap.new ()
      
      fun recurse flag peer =
         let
            val () = if flag peer then WordMap.add (map, Peer.id peer, peer) else ()
         in
            Iterator.app (recurse (fn _ => true)) (Peer.responsibleNeighbors (id, responsibility) peer)
         end
         handle WordMap.KeyExists => ()
         
      val entry = selectWithCollisions (lookupBubbleSize ())
      val () = List.app (recurse flag) entry
      fun second (_, b) = b
   in
      Iterator.map second (WordMap.iterator map)
   end

val lookup = protoLookup (fn _ => false)

(******************************************************************************)
(*                   Bubble Post                                              *)
(******************************************************************************)

fun bubblePost id = protoLookup (Peer.responsible (id, responsibility)) id

(******************************************************************************)
(*                   Success Statistics                                       *)
(******************************************************************************)

fun responsible id = Iterator.length (Iterator.filter (Peer.responsible (id, responsibility))
                        (Iterator.fromVector peers))
fun recall id =
   let
      val found = Real.fromInt (Iterator.length (bubblePost id))
      val available =  Real.fromInt (responsible id)
   in
      if available <= 0.0 then 0.0 else found / available
   end
   
val tests = 1000

val it = Iterator.fromInterval { start = 0, stop = tests, step = 1 }
val map = IntMap.new ()
fun exec (pos, sum) =
   let
      val result = recall (Word.fromInt pos)
      val key = Real.round (1000.0 * result)
      val count = Option.getOpt (IntMap.get (map, key), 0)
      val () = IntMap.set (map, key, count + 1)
   in
      sum + result
   end
val sumRecall = Iterator.fold exec 0.0 it
val recall = sumRecall / Real.fromInt tests

(******************************************************************************)
(*                   Output                                                   *)
(******************************************************************************)

val () = print "\n"
val () = print ("n = " ^ (Int.toString n) ^ "\n")
val () = print ("R bubble = " ^ (Int.toString (responsibilityBubbleSize ())) ^ "\n")
val () = print ("Recall = " ^ (Real.toString recall) ^ "\n")

(* sort histogram *)
val arr = Iterator.toArray (IntMap.iterator map)
fun less ((a, _), (b, _)) = Int.< (a, b)
val () = HeapSort.sort less arr
val it = Iterator.fromArray arr

val () = print "\n"
fun printBucket (key, value) = print (Real.toString (Real.fromInt key / 10.0) ^ "\t" ^ Int.toString value ^ "\n")
val () = Iterator.app printBucket it
