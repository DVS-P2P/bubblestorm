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

structure MakeVector :> MAKE_VECTOR =
   struct
      fun make (array, vector, z) (len, f) =
         let
            val a = array (len, z)
            val () = f a
         in
            vector a
         end
      
      val word8  = make (Word8Array.array,  Word8Array.vector,  0w0)
      val word16 = make (Word16Array.array, Word16Array.vector, 0w0)
      val word32 = make (Word32Array.array, Word32Array.vector, 0w0)
      val word64 = make (Word64Array.array, Word64Array.vector, 0w0)
      
      val real32 = make (Real32Array.array, Real32Array.vector, 0.0)
      val real64 = make (Real64Array.array, Real64Array.vector, 0.0)
   end
