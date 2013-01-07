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

signature ITERATOR =
   sig
      datatype 'a t = EOF | SKIP of (unit -> 'a t) | VALUE of 'a * (unit -> 'a t)
      
      (* Fetch one item *)
      val getItem: 'a t -> ('a * 'a t) option
      val null: 'a t -> bool
      
      (* Constant time iterator operations *)
      val map: ('a -> 'b) -> 'a t -> 'b t
      val mapPartial: ('a -> 'b option) -> 'a t -> 'b t
      val mapPartialWith: ('a * 'w -> 'b option * 'w) -> 'a t * 'w -> 'b t
      val filter: ('a -> bool) -> 'a t -> 'a t
      val partition: ('a -> bool) -> 'a t -> { true : 'a t, false : 'a t }
      
      val @ : 'a t * 'a t -> 'a t
      val cross : 'a t * 'b t -> ('a * 'b) t
      val concat: 'a t t -> 'a t
      val loop : 'a t -> 'a t
      val push: 'a * 'a t -> 'a t
      val truncate: ('a -> bool) -> 'a t -> 'a t
      
      (* Makes the iterator fully lazy.
       * It will never cache the next value and is thus safe to use across
       * state changing operations.
       *)
      val delay : 'a t -> 'a t
      
      (* Amortized linear time *)
      val app: ('a -> unit) -> 'a t -> unit
      val appi: (int * 'a -> unit) -> 'a t -> unit
      val fold: ('a * 'b -> 'b) -> 'b -> 'a t -> 'b
      val exists: ('a -> bool) -> 'a t -> bool
      val find: ('a -> bool) -> 'a t -> 'a option
      val collate: ('a * 'b -> order) -> 'a t * 'b t -> order 
      
      (* These take linear time (even if the underlying representation is faster) *)
      val length: 'a t -> int
      val nth: 'a t * int -> 'a
      
      (* Cost proportional to second parameter *)
      val take: 'a t * int -> 'a list
      val drop: 'a t * int -> 'a t
      
      (* Conversions between some common data types *)
      val fromElement : 'a -> 'a t
      val fromList: 'a list -> 'a t
      val fromString: string -> char t
      val fromVector: 'a vector -> 'a t
      val fromArray:  'a array  -> 'a t
      
      val fromSubstring: Substring.substring -> char t
      val fromVectorSlice: 'a VectorSlice.slice -> 'a t
      val fromVectorSlicei: 'a VectorSlice.slice -> (int * 'a) t
      val fromArraySlice: 'a ArraySlice.slice -> 'a t
      val fromArraySlicei: 'a ArraySlice.slice -> (int * 'a) t
      
      val toList: 'a t -> 'a list      
      val toString: char t -> string
      val toVector: 'a t -> 'a vector
      val toArray: 'a t -> 'a array
      
      (* Surprisingly useful as a means to make a loop *)
      val fromInterval: { start : int, stop : int, step : int } 
                        -> int t
   end
