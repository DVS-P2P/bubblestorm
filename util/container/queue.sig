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

(* A double-ended queue.
 * You can use it like a queue with pushBottom and pop.
 * However, you can also use it like a stack with pushTop and pop.
 *)
signature QUEUE =
   sig
      type 'a t
      
      val empty: 'a t
      
      val peek: 'a t -> 'a t * 'a option
      val pop: 'a t  -> 'a t * 'a option
      val isEmpty: 'a t -> bool
      
      val pushFront : 'a t * 'a -> 'a t
      val pushBack  : 'a t * 'a -> 'a t
      
      (* Walk a snapshot of the contents of the queue.
       * Further modification of the queue is not reflected by the iterators.
       *)
      
      (* No specific order, but no memory cost *)
      val unordered: 'a t -> 'a Iterator.t
      
      (* Can use time+space proportional to size *)
      val forward:   'a t -> 'a Iterator.t
      val backward:  'a t -> 'a Iterator.t
   end

signature IMPERATIVE_QUEUE =
   sig
      type 'a t
      
      val new: unit -> 'a t
      
      val peek: 'a t -> 'a option
      val pop: 'a t -> 'a option
      val isEmpty: 'a t -> bool
      
      val pushFront : 'a t * 'a -> unit
      val pushBack  : 'a t * 'a -> unit
      
      val unordered: 'a t -> 'a Iterator.t
      val forward:   'a t -> 'a Iterator.t
      val backward:  'a t -> 'a Iterator.t
   end
