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

(* Minimize the bandwidth of a sparse graph *)
signature CUTHILL_MCKEE =
   sig
      (* Remove double-edges and self-loops. Also sorts adjacency. *)
      val simplify : int list vector -> int list vector
      (* Input is an >>>undirected<<< graph in adjacency list format.
       * Output is a permutation with (hopefully) improved bandwidth.
       *)
      val optimize : int list vector -> int vector
      (* Relabel a graph using a permutation *)
      val relabel : int list vector * int vector -> int list vector
      (* Calculate the bandwidth of a graph *)
      val bandwidth : int list vector -> int
      (* Invert a permutation *)
      val inverse : int vector -> int vector
   end
