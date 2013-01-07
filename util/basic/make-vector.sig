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

signature MAKE_VECTOR =
   sig
      (* WARNING!!! Do not use these functions unless you really must!
       * They allocate an uninitialized array and pass it to your function.
       * After your function returns the array is converted into a vector.
       * NEVER USE THE ARRAY AGAIN AFTER YOU RETURN.
       *)
      val word8  : int * (Word8Array.array  -> unit) -> Word8Vector.vector
      val word16 : int * (Word16Array.array -> unit) -> Word16Vector.vector
      val word32 : int * (Word32Array.array -> unit) -> Word32Vector.vector
      val word64 : int * (Word64Array.array -> unit) -> Word64Vector.vector
      
      val real32 : int * (Real32Array.array -> unit) -> Real32Vector.vector
      val real64 : int * (Real64Array.array -> unit) -> Real64Vector.vector
   end
