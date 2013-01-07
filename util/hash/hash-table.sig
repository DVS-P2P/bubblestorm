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

signature HASH_KEY =
   sig
      type t
      
      val == : t * t -> bool
      val hash : (t, 'b) Hash.function
   end

signature HASH_TABLE =
   sig
      type 'a t
      structure Key : HASH_KEY
      
      exception KeyExists
      exception KeyDoesNotExist
      
      val new : unit -> 'a t
      val size : 'a t -> int
      val isEmpty : 'a t -> bool
      
      val clear : 'a t -> unit
      
      val get : 'a t * Key.t -> 'a option
      val set : 'a t * Key.t * 'a -> unit
      
      (* Combine get/set of an element; to save a hash operation *)
      (* val getset : 'a t * Key.t * ('a option -> 'a option * 'b) -> 'b *)
      
      val add    : 'a t * Key.t * 'a -> unit (* raises KeyExists *)
      val update : 'a t * Key.t * 'a -> unit (* raises KeyDoesNotExist *)
      val remove : 'a t * Key.t -> 'a        (* raises KeyDoesNotExist *) 

      (* Combine get/update of an element; to save a hash operation *)
      val modify : 'a t * Key.t * ('a -> 'a) -> unit (* raises KeyDoesNotExist *)
      
      (* Walk the table in an arbitrary order *)
      val iterator : 'a t -> (Key.t * 'a) Iterator.t
   end
