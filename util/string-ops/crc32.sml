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
      val Q = 0wx04c11db7
      
      fun crctab i =
         let
            fun push crc = 
               if Word32.andb (crc, 0wx80000000) <> 0w0
               then Word32.xorb (Word32.<< (crc, 0w1), Q)
               else Word32.<< (crc, 0w1)
            val push8 = push o push o push o push o
                        push o push o push o push
         in
            push8 (Word32.<< (Word32.fromInt i, 0w24))
         end
      val crctab = Word32Vector.tabulate (256, crctab)
      
      fun step (b, crc) =
         let
            val w = Word32Vector.sub (crctab, Word8.toInt b)
         in
            w (* !!! fix me later *)
         end
      
      val crc32v = Word8VectorSlice.foldl step 0w0
      val crc32a = Word8ArraySlice.foldl step 0w0
      val string = word8v o Word8VectorSlice.full o Byte.stringToBytes
   end
