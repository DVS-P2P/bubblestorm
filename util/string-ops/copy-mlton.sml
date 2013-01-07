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
      fun make (baseA, baseV, copy) (a, v) =
         let
            val (a, ao, _)  = baseA a
            val (v, vo, vl) = baseV v
            val i = Int32.fromInt
         in
            copy (a, i ao, v, i vo, i vl)
         end
      
      val copy8  = _import "bs_copy" public : Word8Array.array  * Int32.int * Word8Vector.vector  * Int32.int * Int32.int -> unit;
      val copy16 = _import "bs_copy" public : Word16Array.array * Int32.int * Word16Vector.vector * Int32.int * Int32.int -> unit;
      val copy32 = _import "bs_copy" public : Word32Array.array * Int32.int * Word32Vector.vector * Int32.int * Int32.int -> unit;
      val copy64 = _import "bs_copy" public : Word64Array.array * Int32.int * Word64Vector.vector * Int32.int * Int32.int -> unit;
      
      val word8v  = make (Word8ArraySlice.base,  Word8VectorSlice.base,  copy8)
      val word16v = make (Word16ArraySlice.base, Word16VectorSlice.base, copy16)
      val word32v = make (Word32ArraySlice.base, Word32VectorSlice.base, copy32)
      val word64v = make (Word64ArraySlice.base, Word64VectorSlice.base, copy64)
      
      val copy32 = _import "bs_copy" public : Real32Array.array * Int32.int * Real32Vector.vector * Int32.int * Int32.int -> unit;
      val copy64 = _import "bs_copy" public : Real64Array.array * Int32.int * Real64Vector.vector * Int32.int * Int32.int -> unit;

      val real32v = make (Real32ArraySlice.base, Real32VectorSlice.base, copy32)
      val real64v = make (Real64ArraySlice.base, Real64VectorSlice.base, copy64)
      
      val copy8  = _import "bs_copy" public : Word8Array.array  * Int32.int * Word8Array.array  * Int32.int * Int32.int -> unit;
      val copy16 = _import "bs_copy" public : Word16Array.array * Int32.int * Word16Array.array * Int32.int * Int32.int -> unit;
      val copy32 = _import "bs_copy" public : Word32Array.array * Int32.int * Word32Array.array * Int32.int * Int32.int -> unit;
      val copy64 = _import "bs_copy" public : Word64Array.array * Int32.int * Word64Array.array * Int32.int * Int32.int -> unit;
      
      val word8a  = make (Word8ArraySlice.base,  Word8ArraySlice.base,  copy8)
      val word16a = make (Word16ArraySlice.base, Word16ArraySlice.base, copy16)
      val word32a = make (Word32ArraySlice.base, Word32ArraySlice.base, copy32)
      val word64a = make (Word64ArraySlice.base, Word64ArraySlice.base, copy64)
      
      val copy32 = _import "bs_copy" public : Real32Array.array * Int32.int * Real32Array.array * Int32.int * Int32.int -> unit;
      val copy64 = _import "bs_copy" public : Real64Array.array * Int32.int * Real64Array.array * Int32.int * Int32.int -> unit;

      val real32a = make (Real32ArraySlice.base, Real32ArraySlice.base, copy32)
      val real64a = make (Real64ArraySlice.base, Real64ArraySlice.base, copy64)
   end
