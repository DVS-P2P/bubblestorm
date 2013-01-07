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

signature DURABLE_DATA_STORE =
   sig
      type t

      type 'a interface = {
         store    : ID.t * Version.t * 'a option * (bool -> unit) -> unit,
         lookup   : ID.t * ((Version.t * 'a option) option -> unit) -> unit,
         remove   : ID.t -> unit,
         iterator : ((ID.t * Version.t * 'a option) Iterator.t -> unit) -> unit,
         size     : unit -> int
      }
      
      val new : Word8Vector.vector interface -> t

      val store    : t -> ID.t * Version.t * Word8Vector.vector option * (bool -> unit) -> unit
      val lookup   : t -> ID.t * ((Version.t * Word8Vector.vector option) option -> unit) -> unit
      val remove   : t -> ID.t -> unit
      val iterator : t -> ((ID.t * Version.t * Word8Vector.vector option) Iterator.t -> unit) -> unit
      val size     : t -> unit -> int
      
      val encode : 'a interface * ('a, 'a, unit) Serial.t -> Word8Vector.vector interface
      
      val map : 'a interface * ('b -> 'a) * ('a -> 'b) -> 'b interface

      val monitor : 'a interface * (ID.t * 'a option * 'a option option -> unit) -> 'a interface
   end
