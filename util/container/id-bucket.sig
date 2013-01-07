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

signature ID_BUCKET =
   sig
      type 'a t

      (* Creates a new id-bucket *)
      val new: unit -> 'a t
      
      (* Report how many elements are allocated in the bucket *)
      val fill: 'a t -> int

      (* Retrieve item from given index *)
      val sub : 'a t * int -> 'a option

      (* Add item, return its index *)
      val alloc : 'a t * 'a -> int

      (* Replace an item, raise AlreadyFree if the specified cell is free *)
      val replace : 'a t * int * 'a -> unit

      (* Remove item at given index, raise AlreadyFree if the specified cell is already free *)
      val free : 'a t * int -> unit
      exception AlreadyFree

      (* Clears the whole bucket, invalidating all keys *)
      val clear : 'a t -> unit

      (* Walk records in the bucket in no particular order.
       * After the bucket is modified, results from the iterator are undefined.
       *)
      val iterator : 'a t -> (int * 'a) Iterator.t
   end
