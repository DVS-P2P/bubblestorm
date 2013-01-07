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

structure Poly1305FFI :> MAC =
   struct
      val length = 16
      
      structure Nonce = Key(val length = length)
      structure Key =
         struct
            open Nonce
            
            val clamp =
               Word8Vector.fromList [
                  0wxff, 0wxff, 0wxff, 0wx0f, 
                  0wxfc, 0wxff, 0wxff, 0wx0f,
                  0wxfc, 0wxff, 0wxff, 0wx0f,
                  0wxfc, 0wxff, 0wxff, 0wx0f ]
            fun andb (i, x) = Word8.andb (Word8Vector.sub (clamp, i), x)
            
            val t = Serial.map {
               load  = Word8Vector.mapi andb,
               store = fn x => x,
               extra = fn () => ()
            } t
         end
      
      val raw =
         _import "poly1305_offs" public : 
            Word8Array.array * 
            Word8Vector.vector * 
            Word8Vector.vector *
            Word8Array.array * int * int -> unit;

      fun f { key, nonce, text } =
         let
            val output = Word8Array.array (length, 0w0)
            val (text, textoff, textlen) = Word8ArraySlice.base text
            val () = raw (output, key, nonce, text, textoff, textlen)
         in
            Word8Array.vector output
         end
   end
