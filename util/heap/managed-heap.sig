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

signature MANAGED_HEAP =
   sig
      structure Key : ORDER
      
      type 'a t
      type 'a record
      
      val new : unit -> 'a t
      val pop : 'a t -> 'a record option
      val peek : 'a t -> 'a record option
      val size : 'a t -> int
      val isEmpty : 'a t -> bool
      
      val clear : 'a t -> unit
      
      (* Only pop the value if the function returns true for it *)
      val popIf : 'a t * (Key.t * 'a -> bool) -> 'a record option
      val peekIf : 'a t * (Key.t * 'a -> bool) -> 'a record option
      (* popBounded (x, k) = popIf (x, fn (l, _) => l <= k) *)
      val popBounded : 'a t * Key.t -> 'a record option
      val peekBounded : 'a t * Key.t -> 'a record option
      
      (* If a record is removed/updated while in a different heap: *) 
      exception WrongHeap 
      
      val wrap   : Key.t * 'a -> 'a record
      (* First value is true if the item is scheduled *)
      val sub    : 'a record -> bool * Key.t * 'a
      
      val push   : 'a t * 'a record -> unit
      val remove : 'a t * 'a record -> unit
      val update : 'a t * 'a record * Key.t -> unit (* pushes if needed *)
      val updateValue: 'a record * 'a -> unit
      
      (* Walk records in the heap in no particular order.
       * After the heap is modified, results from the iterator are undefined.
       *)
      val iterator : 'a t -> 'a record Iterator.t
   end
