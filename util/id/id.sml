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

structure ID :> ID =
   struct
      structure Z = OrderFromCompare(type t = Word8Vector.vector
                                     val compare = Word8Vector.collate Word8.compare)
      
      val numberOfBytes = 20
      val numberOfBits = numberOfBytes * 8
      
      val t = Serial.vector (Serial.word8, numberOfBytes)
      
      local
         open Serial
         val rand = aggregate tuple5 `word32l `word32l `word32l `word32l `word32l $
         val { toVector, ... } = methods rand
      in
         fun fromRandom r =
            let
               val a = Random.word32 (r, NONE)
               val b = Random.word32 (r, NONE)
               val c = Random.word32 (r, NONE)
               val d = Random.word32 (r, NONE)
               val e = Random.word32 (r, NONE)
            in
               toVector (a, b, c, d, e)
            end 
      end
      
      val { fromVector=seed, ... } = Serial.methods Serial.word64l
      val hash = Hash.word8vector
      val toString = WordToString.fromBytes
      val fromHash = RIPEMD160Cooked.hash
      
      fun fromRandomBits (random, bits) =
         let
            val rBytes = (bits + 7) div 8
            val bitMask = (Word8.<< (0w1, Word.fromInt (bits mod 8))) - 0w1
            val rnd = Word8Vector.tabulate (rBytes, fn _ => Random.word8 (random, NONE))
            val zBytes = numberOfBytes - rBytes
            fun tab i =
               if i < zBytes then 0w0
               else
                  if i > zBytes then Word8Vector.sub (rnd, i - zBytes)
                  else Word8.andb (Word8Vector.sub (rnd, 0), bitMask)
         in
            Word8Vector.tabulate (numberOfBytes, tab)
         end
      
      fun xor (a, b) =
         Word8Vector.tabulate (numberOfBytes,
            fn i => Word8.xorb (Word8Vector.sub (a, i), Word8Vector.sub (b, i)))
      
      fun getBit (this, bit) =
         let
            val checkByte = numberOfBytes - (bit div 8) - 1
            val checkBit = bit mod 8
            val checkMask = Word8.<< (0w1, Word.fromInt checkBit)
         in
            Word8.andb (Word8Vector.sub (this, checkByte), checkMask) <> 0w0
         end
      
      fun highestOneBit this =
         case Word8Vector.findi (fn (_, v) => (v <> 0w0)) this of
            SOME (i, v) =>
               let
                  fun bit (w, c) =
                     if (w <> 0w0)
                     then bit (Word8.>> (w, 0w1), c+1)
                     else c
               in
                  numberOfBits - 9 - (i * 8) + bit (v, 0)
               end
            | NONE => ~1
      
      fun setBit (this, bit) =
         let
            val modByte = numberOfBytes - (bit div 8) - 1
            val modBit = bit mod 8
            val andBit = Word8.~ (Word8.<< (0w1, Word.fromInt modBit))
            fun tab i =
               if i = modByte
               then Word8.andb (Word8Vector.sub (this, i), andBit)
               else Word8Vector.sub (this, i)
         in
            Word8Vector.tabulate (numberOfBytes, tab)
         end
      
      fun clearBit (this, bit) =
         let
            val modByte = numberOfBytes - (bit div 8) - 1
            val modBit = bit mod 8
            val orBit = Word8.<< (0w1, Word.fromInt modBit)
            fun tab i =
               if i = modByte
               then Word8.orb (Word8Vector.sub (this, i), orBit)
               else Word8Vector.sub (this, i)
         in
            Word8Vector.tabulate (numberOfBytes, tab)
         end
      
      open Z
   end
