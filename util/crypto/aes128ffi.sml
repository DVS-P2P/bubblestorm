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

structure AES128FFI :> CIPHER =
   struct
      local
         open MLton.Platform.Arch
      in
         (* val () = expand (longkey, key) 
          * val () = block  (output, input, longkey)
          *)
         val { expand, block } =
            case host of
               X86 => {
                  expand = _import "aes128_x86mmx1_expand" public :
                                   Word8Array.array *
                                   Word8Vector.vector -> unit;,
                  block  = _import "aes128_x86mmx1_block" public :
                                   Word8Array.array *
                                   Word8Array.array *
                                   Word8Array.array -> unit; 
               }
             | AMD64 => {
                  expand = _import "aes128_amd64_2_expand" public :
                                   Word8Array.array *
                                   Word8Vector.vector -> unit;,
                  block  = _import "aes128_amd64_2_block" public :
                                   Word8Array.array *
                                   Word8Array.array *
                                   Word8Array.array -> unit;
               }
             | _ =>
                raise Fail "CPU has no optimized assembler available"
      end
      
      structure Key = 
         struct
            type t = Word8Array.array
            
            fun compare (a, b) =
               let
                  val a = Word8ArraySlice.slice (a, 0, SOME 16)
                  val b = Word8ArraySlice.slice (b, 0, SOME 16)
               in
                  Word8ArraySlice.collate Word8.compare (a, b)
               end
            structure Z = OrderFromCompare(type t = t val compare = compare)
            open Z	
            
            local
               open Serial
            in
               val w32x4l = aggregate tuple4 `word32l `word32l `word32l `word32l $
               val w32x4b = aggregate tuple4 `word32b `word32b `word32b `word32b $
            end
            
            fun toString k =
               let
                  val { parseSlice, ... } = Serial.methods w32x4b
                  val (w0, w1, w2, w3) = parseSlice (Word8ArraySlice.full k)
                  val s = WordToString.from32
               in
                  concat [ s w0, s w1, s w2, s w3 ]
               end
            
            fun hash k =
               let
                  val { parseSlice, ... } = Serial.methods w32x4l
                  val (w0, w1, w2, w3) = parseSlice (Word8ArraySlice.full k)
               in
                  Hash.word32 w0 o Hash.word32 w1 o 
                  Hash.word32 w2 o Hash.word32 w3
               end
            
            val t = Serial.map {
               store = fn a => 
                  Word8ArraySlice.vector
                  (Word8ArraySlice.slice (a, 0, SOME 16)),
               load  = fn v =>
                  let
                     val a = Word8Array.array (56, 0w0)
                     val () = expand (a, v)
                  in
                     a
                  end,
               extra = fn () => ()
            } (Serial.vector (Serial.word8, 16))
         end
      
      val length = 16
      fun f { key, plain, cipher } = 
         let
            (*
            val () = 
               if plainlen <> length orelse cipherlen <> length
               then raise Domain else ()
            *)
         in
            block (cipher, plain, key)
         end
   end
