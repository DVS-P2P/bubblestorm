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

signature MANAGED_DATA_STORE =
   sig
      type t

      type 'a interface = {
         insert : ID.t * 'a * (unit -> unit) * bool -> unit,
         update : ID.t * 'a * (unit -> unit) -> unit,
         delete : ID.t * (unit -> unit) -> unit,
         get    : ID.t -> 'a option, (* TODO consistently asynchronous (or synchronous) *)
         flush  : (bool -> bool) -> unit,
         size   : unit -> int
      }
      
      val new : Word8Vector.vector interface -> t

      val insert : t -> ID.t * Word8Vector.vector * (unit -> unit) * bool -> unit
      val update : t -> ID.t * Word8Vector.vector * (unit -> unit) -> unit
      val delete : t -> ID.t * (unit -> unit) -> unit
      val flush  : t -> (bool -> bool) -> unit
      val size   : t -> unit -> int
      
      val encode : 'a interface * ('a, 'a, unit) Serial.t -> Word8Vector.vector interface
      
      val map : 'a interface * ('b -> 'a) * ('a -> 'b) -> 'b interface

      val monitor : 'a interface * (ID.t * 'a * 'a option -> unit) -> 'a interface
   end
