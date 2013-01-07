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

structure Poly1305ML :> MAC =
   struct
      structure Nonce = 
         struct
            structure Z = OrderFromCompare(type t = IntInf.int 
                                           val compare = IntInf.compare)
            open Z
            
            val t = Serial.intinfl 16
            
            val { toVector, ... } = Serial.methods t
            fun hash x = Hash.word8vector (toVector x)
            val toString = WordToString.fromBytes o toVector
         end
      
      structure Key =
         struct
            open Nonce
            
            val mask = 0x0ffffffc0ffffffc0ffffffc0fffffff
            
            val t = Serial.map {
               load  = fn i => IntInf.andb (mask, i),
               store = fn i => i,
               extra = fn () => () 
            } t
         end
      
      val length = 16
      val p = IntInf.<< (1, 0w130) - 5
      
      fun f { key, nonce, text } =
         let
            val sub = Word8ArraySlice.subslice
            val len = Word8ArraySlice.length text
            fun fromSlice s =
               let
                  val len = Word8ArraySlice.length s
                  val len2 = len div 2
               in
                  if len = 1 
                  then Word8.toLargeInt (Word8ArraySlice.sub (s, 0))
                  else
                     fromSlice (sub (s, 0, SOME len2)) +
                     IntInf.<< (fromSlice (sub (s, len2, NONE)),
                                Word.fromInt len2 * 0w8)
               end
            fun loop (i, h) =
               if i >= len then h else
               let
                  val len = Int.min (16, len-i)
                  val tail = sub (text, i, SOME len)
                  val t = fromSlice tail
                  val t' = IntInf.<< (1, Word.fromInt len * 0w8)
               in
                  loop (i+16, (h+t+t')*key mod p)
               end
            val h = loop (0, 0) + nonce
         in
            Nonce.toVector h
         end
   end
