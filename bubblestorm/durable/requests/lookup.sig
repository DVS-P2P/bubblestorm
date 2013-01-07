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

signature LOOKUP =
   sig
      type t
      
      val t : (t, t, unit) Serial.t
      
      type request = {
         bubble  : BasicBubbleType.t,
         id      : ID.t,
         receive : Version.t * Word8Vector.vector -> unit
      }
      
      exception IllegalBubbleType

      val start   : request -> t * (unit -> unit)
      val receive : BasicBubbleType.bubbleState * t -> request
      
      val toVector : t -> Word8Vector.vector
      val fromVectorSlice : Word8VectorSlice.slice -> t
   end
