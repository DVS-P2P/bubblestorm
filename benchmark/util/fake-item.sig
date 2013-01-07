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

signature FAKE_ITEM =
   sig
      include SERIALIZABLE

      val new : {
         id : ID.t,
         publisher : ID.t,
         version : int,
         size : int
      } -> t
      val none : {
         id : ID.t,
         publisher : ID.t
      } -> t
      val isNone : t -> bool
      
      val encode : t -> Word8Vector.vector
      val decode : Word8Vector.vector -> t
      val decodeSlice : Word8VectorSlice.slice -> t
      val toHashID : t -> ID.t
      
      val encodeQuery : ID.t -> Word8Vector.vector
      val decodeQuery : Word8VectorSlice.slice -> ID.t
   end
