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

structure CRC32 :> CRC32 =
   struct
      val crc32v  = _import "wombat_crc32" public : Word8Vector.vector * Int32.int * Int32.int -> Word32.word;
      fun word8v v =
         let
            val (v, i, l) = Word8VectorSlice.base v
         in
            crc32v (v, Int32.fromInt i, Int32.fromInt l)
         end
         
      val crc32a  = _import "wombat_crc32" public : Word8Array.array * Int32.int * Int32.int -> Word32.word;
      fun word8a a =
         let
            val (a, i, l) = Word8ArraySlice.base a
         in
            crc32a (a, Int32.fromInt i, Int32.fromInt l)
         end
         
      val string = word8v o Word8VectorSlice.full o Byte.stringToBytes
   end
