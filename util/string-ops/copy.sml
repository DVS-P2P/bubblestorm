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

structure Copy :> COPY =
   struct
      fun make (base, copy) (dst, src) =
         let
            val (dst, dstOff, _) = base dst
         in
            copy { src = src, dst = dst, di = dstOff }
         end
      
      val word8v  = make (Word8ArraySlice.base,  Word8ArraySlice.copyVec)
      val word16v = make (Word16ArraySlice.base, Word16ArraySlice.copyVec)
      val word32v = make (Word32ArraySlice.base, Word32ArraySlice.copyVec)
      val word64v = make (Word64ArraySlice.base, Word64ArraySlice.copyVec)
      
      val real32v = make (Real32ArraySlice.base, Real32ArraySlice.copyVec)
      val real64v = make (Real64ArraySlice.base, Real64ArraySlice.copyVec)
      
      val word8a  = make (Word8ArraySlice.base,  Word8ArraySlice.copy)
      val word16a = make (Word16ArraySlice.base, Word16ArraySlice.copy)
      val word32a = make (Word32ArraySlice.base, Word32ArraySlice.copy)
      val word64a = make (Word64ArraySlice.base, Word64ArraySlice.copy)
      
      val real32a = make (Real32ArraySlice.base, Real32ArraySlice.copy)
      val real64a = make (Real64ArraySlice.base, Real64ArraySlice.copy)
   end
