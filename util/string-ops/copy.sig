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

signature COPY =
   sig
      (* Be careful. Bounds are not checked. *)
      
      val word8v  : Word8ArraySlice.slice  * Word8VectorSlice.slice  -> unit
      val word16v : Word16ArraySlice.slice * Word16VectorSlice.slice -> unit
      val word32v : Word32ArraySlice.slice * Word32VectorSlice.slice -> unit
      val word64v : Word64ArraySlice.slice * Word64VectorSlice.slice -> unit

      val real32v : Real32ArraySlice.slice * Real32VectorSlice.slice -> unit
      val real64v : Real64ArraySlice.slice * Real64VectorSlice.slice -> unit
      
      val word8a  : Word8ArraySlice.slice  * Word8ArraySlice.slice  -> unit
      val word16a : Word16ArraySlice.slice * Word16ArraySlice.slice -> unit
      val word32a : Word32ArraySlice.slice * Word32ArraySlice.slice -> unit
      val word64a : Word64ArraySlice.slice * Word64ArraySlice.slice -> unit

      val real32a : Real32ArraySlice.slice * Real32ArraySlice.slice -> unit
      val real64a : Real64ArraySlice.slice * Real64ArraySlice.slice -> unit
   end
