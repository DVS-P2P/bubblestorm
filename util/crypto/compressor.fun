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

functor Compressor(Base : COMPRESSOR_RAW) :> COMPRESSOR_COOKED =
   struct
(*
      structure Base =
         struct
            open Base
            fun compressA (s, a) =
               let
                  val v = Word8ArraySlice.vector a
                  val () = print ("compressA: " ^ WordToString.fromBytes v ^ "\n")
               in
                  Base.compressA (s, a)
               end
            fun compressV (s, vs) =
               let
                  val v = Word8VectorSlice.vector vs
                  val () = print ("compressV: " ^ WordToString.fromBytes v ^ "\n")
               in
                  Base.compressV (s, vs)
               end
         end
*)      
      type state = Base.state * Word8Array.array * Word64.word
      
      val outputLength = Base.outputLength
      val inputLength = Base.inputLength
      val inputLengthW = Word64.fromInt inputLength
      
      fun initial () = 
         (Base.initial, Word8Array.array (inputLength, 0w0), 0w0)
      
      fun compressA ((base, buffer, used), data) =
         let
            val have = Word64.toInt (used mod inputLengthW)
            val (_, offset, new) = Word8ArraySlice.base data
         in
            if have+new < inputLength then
               let
                  (* It will fit into the buffer, but not fill it *)
                  val target = Word8ArraySlice.slice (buffer, have, SOME new)
                  val () = Copy.word8a (target, data)
               in
                  (base, buffer, used + Word64.fromInt new)
               end
            else if have = 0 andalso offset mod 4 = 0 then
               let
                  (* Nothing is buffered and the data is >= an entire block *)
                  val front = Word8ArraySlice.subslice (data, 0, SOME inputLength)
                  val tail  = Word8ArraySlice.subslice (data, inputLength, NONE)
                  val base = Base.compressA (base, front)
               in
                  compressA ((base, buffer, used + Word64.fromInt inputLength), 
                             tail)
               end
            else
               let
                  (* We need to buffer and the new data completely fills it *)
                  val target = Word8ArraySlice.slice (buffer, have, NONE)
                  val space  = Word8ArraySlice.length target
                  val front  = Word8ArraySlice.subslice (data, 0, SOME space)
                  val tail   = Word8ArraySlice.subslice (data, space, NONE)
                  val () = Copy.word8a (target, front)
                  val chunk = Word8ArraySlice.full buffer
                  val base = Base.compressA (base, chunk)
               in
                  compressA ((base, buffer, used + Word64.fromInt space), 
                             tail)
               end
         end
         
      fun compressV ((base, buffer, used), data) =
         let
            val have = Word64.toInt (used mod inputLengthW)
            val (_, offset, new) = Word8VectorSlice.base data
         in
            if have+new < inputLength then
               let
                  (* It will fit into the buffer, but not fill it *)
                  val target = Word8ArraySlice.slice (buffer, have, SOME new)
                  val () = Copy.word8v (target, data)
               in
                  (base, buffer, used + Word64.fromInt new)
               end
            else if have = 0 andalso offset mod 4 = 0 then
               let
                  (* Nothing is buffered and the data is >= an entire block *)
                  val front = Word8VectorSlice.subslice (data, 0, SOME inputLength)
                  val tail  = Word8VectorSlice.subslice (data, inputLength, NONE)
                  val base = Base.compressV (base, front)
               in
                  compressV ((base, buffer, used + Word64.fromInt inputLength), 
                             tail)
               end
            else
               let
                  (* We need to buffer and the new data completely fills it *)
                  val target = Word8ArraySlice.slice (buffer, have, NONE)
                  val space  = Word8ArraySlice.length target
                  val front  = Word8VectorSlice.subslice (data, 0, SOME space)
                  val tail   = Word8VectorSlice.subslice (data, space, NONE)
                  val () = Copy.word8v (target, front)
                  val chunk = Word8ArraySlice.full buffer
                  val base = Base.compressA (base, chunk)
               in
                  compressV ((base, buffer, used + Word64.fromInt space), 
                             tail)
               end
         end
      
      val pad = Word8Vector.tabulate (inputLength, fn _ => 0w0)
      val highBit = Word8Vector.tabulate (1, fn _ => 0wx80)
      val highBit = Word8VectorSlice.full highBit
      val { length, writeSlice, ... } = Serial.methods Base.length
      val lengthW = Word64.fromInt length
      fun finish (this as (_, buffer, used)) =
         let
            val this = compressV (this, highBit)
            
            (* Compute how long it needs to be to fit the length and bit *)
            val totalLen = used + lengthW + 0w1
            (* Round up to a block multiple *)
            val totalLen = totalLen + inputLengthW - 0w1
            val totalLen = (totalLen div inputLengthW) * inputLengthW
            
            (* Pad the state out with 0s *)
            val padLen = Word64.toInt (totalLen - lengthW - used)
            val pad = Word8VectorSlice.slice (pad, 0, SOME padLen)
            val (base, _, _) = compressV (this, pad)
            
            (* Add on the length information *)
            val tail = Word8ArraySlice.slice (buffer, inputLength - length, NONE)
            val () = writeSlice (tail, used)
            
            (* The last compression *)
            val base = Base.compressA (base, Word8ArraySlice.full buffer)
            
            fun done a = Base.finish (base, Word8ArraySlice.full a)
         in
            MakeVector.word8 (outputLength, done)
         end
      
      fun hash v =
         let
            val state = initial ()
            val state = compressV (state, Word8VectorSlice.full v)
         in
            finish state
         end
   end
