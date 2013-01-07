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

(* This is the interface of a hash algorithm.
 * The input and output depend on the hash algorithm.
 *)
signature HASH_ALGORITHM =
   sig
      type state
      type input
      type output
      
      type 'a t = 'a * input -> output
      val make: ('a, state) Hash.function -> 'a t
   end

(* This is the interface a hash algorithm has to provide.
 * The above interface is automatically created from this.
 *)
signature HASH_PRIMITIVE =
   sig
      (* Whatever one feeds into a hash to create the initial state *)
      type initial
      (* The state which accumulates a hash result *)
      type state
      (* The state which results after completing the hash  *)
      type final
      
      (* Get an initial state for hashing with step+finish *)
      val start: initial -> state Hash.state
      
      (* Finish the hash function *)
      val stop: state -> final
   end
