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
      fun make (cast, create) (len, f) =
         let
            val a = create len
            val () = f a
         in
            cast a
         end
      
      val cast8  = _prim "Array_toVector" : Word8Array.array  -> Word8Vector.vector;
      val cast16 = _prim "Array_toVector" : Word16Array.array -> Word16Vector.vector;
      val cast32 = _prim "Array_toVector" : Word32Array.array -> Word32Vector.vector;
      val cast64 = _prim "Array_toVector" : Word64Array.array -> Word64Vector.vector;
      
      val word8  = make (cast8,  Unsafe.Word8Array.create)
      val word16 = make (cast16, Unsafe.Word16Array.create)
      val word32 = make (cast32, Unsafe.Word32Array.create)
      val word64 = make (cast64, Unsafe.Word64Array.create)

      val cast32 = _prim "Array_toVector" : Real32Array.array -> Real32Vector.vector;
      val cast64 = _prim "Array_toVector" : Real64Array.array -> Real64Vector.vector;
      
      val real32 = make (cast32, Unsafe.Real32Array.create)
      val real64 = make (cast64, Unsafe.Real64Array.create)
   end
