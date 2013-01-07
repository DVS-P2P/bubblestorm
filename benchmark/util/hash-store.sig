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

signature HASH_STORE =
   sig
      type 'a t
      
      val new : unit -> 'a t

      val set : 'a t -> ID.t * 'a -> unit      
      val insert : 'a t -> ID.t * 'a -> bool
      val update : 'a t -> ID.t * 'a -> bool
      val modify : 'a t -> ID.t * ('a -> 'a) -> bool
      val delete : 'a t -> ID.t -> bool
      
      val get : 'a t -> ID.t -> 'a option
      val size : 'a  t -> int
      
      val iterator : 'a t -> (ID.t * 'a) Iterator.t
      val idIterator : 'a t -> ID.t Iterator.t
   end
