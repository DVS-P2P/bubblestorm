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

signature DYNAMIC_ARRAY =
   sig
      type 'a t

      val new : (int -> 'a) -> 'a t
      val capacity : 'a t -> int
      val truncate : 'a t * int -> unit
      val length : 'a t -> int
      val sub : 'a t * int -> 'a
      val update : 'a t * int * 'a -> unit
      val slice : 'a t * int * int option -> 'a ArraySlice.slice
      val vector : 'a t -> 'a Vector.vector
      val copy    : {
                        src : 'a t,
                        dst : 'a Array.array,
                        di : int
                      } -> unit
      val isEmpty : 'a t -> bool
      val appi : (int * 'a -> unit) -> 'a t -> unit
      val app  : ('a -> unit) -> 'a t -> unit
      val modifyi : (int * 'a -> 'a) -> 'a t -> unit
      val modify  : ('a -> 'a) -> 'a t -> unit
      val foldli : (int * 'a * 'b -> 'b) -> 'b -> 'a t -> 'b
      val foldri : (int * 'a * 'b -> 'b) -> 'b -> 'a t -> 'b
      val foldl  : ('a * 'b -> 'b) -> 'b -> 'a t -> 'b
      val foldr  : ('a * 'b -> 'b) -> 'b -> 'a t -> 'b
      val findi : (int * 'a -> bool)
                    -> 'a t -> (int * 'a) option
      val find  : ('a -> bool) -> 'a t -> 'a option
      val exists : ('a -> bool) -> 'a t -> bool
      val all : ('a -> bool) -> 'a t -> bool
      val collate : ('a * 'a -> order)
                      -> 'a t * 'a t -> order
   end
