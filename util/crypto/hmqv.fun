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

functor HMQV(structure CyclicGroup : CYCLIC_GROUP
             structure Compressor  : COMPRESSOR_RAW)
   :> HMQV where type CyclicGroup.t = CyclicGroup.t =
   struct
      structure CyclicGroup = CyclicGroup
      
      val groupLength = #length (Serial.methods CyclicGroup.t)
      val groupLength2 = groupLength + groupLength
      val halfGroupLength = groupLength div 2
      

      local
         open Serial
         val pair = aggregate tuple2 `CyclicGroup.t `CyclicGroup.t $
      in
         val { writeSlice=writePair, ... } = methods pair
         val { fromVector, ... } = methods (intinfl halfGroupLength)
      end
      
      val iclen = Compressor.inputLength
      val oclen = Compressor.outputLength
      (* round length up to a multiple of the compressor input size *)
      val ilen  = ((groupLength2 + iclen - 1) div iclen) * iclen
      
      fun hash olen (A, B) =
         let
            (* Round up to a multiple of the compressor output size *)
            val olen' = (olen + oclen - 1) div oclen
            
            val buffer = Word8Array.array (ilen, 0w0)
            val () = writePair (Word8ArraySlice.full buffer, (A, B))
            
            fun loop (state, i) =
               if i = ilen then state else
               let
                  val slice = Word8ArraySlice.slice (buffer, i, SOME iclen)
               in
                  loop (Compressor.compressA (state, slice), i+iclen)
               end
            
            val prefix = Word8Array.array (iclen, 0w0)
            val prefixs = Word8ArraySlice.full prefix
            fun tweak (i, v) =
               (PackWord64Little.update (prefix, 0, LargeWord.fromInt i)
                ; Compressor.compressA (v, prefixs))
            
            val states = Vector.tabulate (olen', fn _ => Compressor.initial)
            val states = (* prefix the hashes if we need more bits *)
               if olen <= oclen then states else
               Vector.mapi tweak states
            val states = Vector.map (fn state => loop (state, 0)) states
            
            val output = Word8Array.array (oclen * olen', 0w0)
            fun store (i, v) = 
               let
                  val part = Word8ArraySlice.slice (output, i*oclen, SOME oclen)
               in
                  Compressor.finish (v, part)
               end
            val () = Vector.appi store states
         in
            Word8ArraySlice.vector 
            (Word8ArraySlice.slice (output, 0, SOME olen))
         end
      
      fun compute { length, a, x, A, B, X, Y } =
         let
            val H' = hash halfGroupLength
            val H = hash length
            
            val d = fromVector (H' (X, B))
            val e = fromVector (H' (Y, A))
            
            (*
            val () = print ("d = " ^ IntInf.toString d ^ "\n")
            val () = print ("e = " ^ IntInf.toString e ^ "\n")
            *)
            
            open CyclicGroup
            val Be = fixedPower (B, e, halfGroupLength * 8)
            val YBe = multiply (Y, Be)
            val sigma = fixedPower (YBe, x + d*a, halfGroupLength * 24)
         in
            (H (sigma, A), H (sigma, B))
         end
   end

(*
local
   open Curve25519ML
   structure HMQV = HMQV(structure CyclicGroup = Curve25519ML
                         structure Compressor = Whirlpool)
in
fun attempt x =
   let
      val a = clamp (10948129048109281980849012813111775452266+x)
      val b = clamp (8902375289037823089012740918240931513124424134+x+x)
      val x = clamp (9239048239085290385902385019231527413585123544+x+x+x)
      val y = clamp (2938459012384589016510118975189237553492733433+x+x+x+x)
      
      val A = power (generator (), a)
      val B = power (generator (), b)
      val X = power (generator (), x)
      val Y = power (generator (), y)
      
      val (S1, S2) = HMQV.compute { length = 16, a=a, x=x, A=A, B=B, X=X, Y=Y }
      val (S3, S4) = HMQV.compute { length = 16, a=b, x=y, A=B, B=A, X=Y, Y=X }
      
      val () = print (WordToString.fromBytes S1 ^ "\n")
      val () = print (WordToString.fromBytes S2 ^ "\n")
      val () = print (WordToString.fromBytes S3 ^ "\n")
      val () = print (WordToString.fromBytes S4 ^ "\n")
   in
      print "\n"
   end
end

val () = attempt 28903752
val () = attempt 239857128901
val () = attempt 234892378
val () = attempt 2983578923476
val () = attempt 456874
val () = attempt 234589711
val () = attempt 235232211
val () = attempt 394875121
*)
(*
open Curve25519ML
structure HMQV = HMQV(structure CyclicGroup = Curve25519ML
                      structure Compressor = Whirlpool)

val a = clamp (10948129048109281980849012813111775452266)
val b = clamp (8902375289037823089012740918240931513124424134)
val x = clamp (9239048239085290385902385019231527413585123544)
val y = clamp (2938459012384589016510118975189237553492733433)

val A = power (generator (), a)
val B = power (generator (), b)
val Y = power (generator (), y)

fun loop 0 = ()
  | loop i = 
   let
      val x = x+i
      val X = power (generator (), x)
      val (S1, S2) = HMQV.compute { length = 16, a=a, x=x, A=A, B=B, X=X, Y=Y }
      val () = print (WordToString.fromBytes S1 ^ "\n")
      val () = print (WordToString.fromBytes S2 ^ "\n")
   in
      loop (i-1)
   end

val () = loop 1000
*)
