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

signature STACK =
   sig
      type 'a t
      
      val new: { nill : 'a } -> 'a t
      (* returns index of pushed element (equals length () - 1) *)
      val push: 'a t * 'a -> int
      val pop: 'a t -> 'a option
      val length : 'a t -> int
      val isEmpty : 'a t -> bool
      
      val clear : 'a t -> unit
      
      (* Walk the stack records from the bottom to the top (ie: backwards) 
       * After the stack is modified, results from the iterator are undefined.
       *)
      val iterator : 'a t -> 'a Iterator.t
   end

signature RAM_STACK =
   sig
      include STACK
      
      val sub : 'a t * int -> 'a
      val update : 'a t * int * 'a -> unit
   end
