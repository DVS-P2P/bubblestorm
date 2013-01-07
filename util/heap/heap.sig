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

signature HEAP =
   sig
      structure Key : ORDER
      type 'a t
      
      val new : unit -> 'a t
      
      val push : 'a t * Key.t * 'a -> unit
      val pop  : 'a t -> (Key.t * 'a) option
      val peek : 'a t -> (Key.t * 'a) option
      val size : 'a t -> int
      val isEmpty : 'a t -> bool
      
      (* Only pop the value if the function returns true for it *)
      val popIf : 'a t * (Key.t * 'a -> bool) -> (Key.t * 'a) option
      (* popBounded (x, k) = popIf (x, fn (l, _) => l <= k) *)
      val popBounded : 'a t * Key.t -> (Key.t * 'a) option
   end
