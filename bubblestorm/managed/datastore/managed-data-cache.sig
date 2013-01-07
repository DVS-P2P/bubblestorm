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

signature MANAGED_DATA_CACHE =
   sig
      type elem
      type t

      val new : unit -> t
      
      val insert   : t * ID.t * Word8Vector.vector -> (unit -> Word8Vector.vector)
      val update   : t * ID.t * Word8Vector.vector -> unit
      val delete   : t * ID.t -> unit
      val get      : t * ID.t -> (unit -> Word8Vector.vector) option
      val iterator : t -> (ID.t * Word8Vector.vector) Iterator.t
   end
