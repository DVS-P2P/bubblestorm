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

signature KEY_VALUE_STORE =
   sig
      type t
      structure Address : ADDRESS
      structure ID : ID
      
      (* params: port, explicit bootstrap addr, list of login nodes, relative capacity *)
      val new : {
         port : int option,
         bootstrap : Address.t option,
         login : Address.t list,
         bandwidth : Real32.real option,
         minBandwidth : Real32.real option
      } -> t
      val create : t * Address.t * (unit -> unit) -> unit
      val join : t * (unit -> unit) -> unit
      val leave : t * (unit -> unit) -> unit
      
      val store : t * ID.t * Word8Vector.vector -> unit
      val delete : t * ID.t -> unit
      (* input: search ID, callback is invoked at most once, passing NONE means no result found
         returns a function to abort the query. once the callback has been called, the query is assumed to be finished *)
      val retrieve : t * ID.t * (Word8Vector.vector option -> unit) -> (unit -> unit)
   end
