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

signature ID =
   sig
      include SERIALIZABLE
      
      val numberOfBits : int
      val numberOfBytes : int
      
      (* Creates a new random Id. *)
      val fromRandom : Random.t -> t
      
      (* Creates an Id from the hashed input data *)
      val fromHash : Word8Vector.vector -> t
      
      (* Creates an Id with the lower n bits random and the high bits zero *)
      val fromRandomBits : Random.t * int -> t

      (* Used in Bubblecast; the first 8 bytes *)
      val seed : t -> Word64.word
      
      val xor : t * t -> t
      
      val getBit : t * int -> bool
      
      val highestOneBit : t -> int
      
      val setBit : t * int -> t
      
      val clearBit : t * int -> t
      
   end
