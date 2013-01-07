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

structure CuthillMcKee :> CUTHILL_MCKEE =
   struct
      fun simplify graph =
         let
            fun reduce (i, edges) =
               let
                  val edges = List.filter (fn x => x <> i) edges
                  val edges = Array.fromList edges
                  val () = HeapSort.sort Int.< edges
                  val out = ref [~1]
                  fun push e =
                     if List.hd (!out) = e then () else
                     out := e :: !out
                  val () = Array.app push edges
               in
                  List.tl (List.rev (!out))
               end
         in
            Vector.mapi reduce  graph
         end
            
      fun optimize graph =
         let
            val length = Vector.length graph
            
            (* count degrees for each vertex *)
            val degree = Vector.map List.length graph
            (* sort the nodes by ascending degree *)
            fun less (x, y) = Vector.sub (degree, x) < Vector.sub (degree, y)
            val degreeOrder = Array.tabulate (length, fn i => i)
            val () = HeapSort.sort less degreeOrder
            (* re-order neighbour lists to be ascending degree *)
            val sortedGraph = Array.array (length, [])
            fun push a b = Array.update (sortedGraph, b, a :: Array.sub (sortedGraph, b))
            fun add (node, ()) = List.app (push node) (Vector.sub (graph, node))
            val () = Array.foldr add () degreeOrder
            (* breadth-first search, adding children lowest degree first *)
            val permutation = Array.array (Vector.length graph, ~1)
            val i = ref 0
            fun bfs Q =
               case Queue.pop Q of
                  (_, NONE) => ()
                | (Q, SOME node) => 
                  if Array.sub (permutation, node) <> ~1 then bfs Q else
                  let
                     val () = Array.update (permutation, node, !i)
                     val () = i := !i + 1
                     (* Explore children in ascending degree permutation *)
                     val children = Array.sub (sortedGraph, node)
                     fun push (child, Q) = Queue.pushBack (Q, child)
                     val Q = List.foldl push Q children
                  in
                     bfs Q
                  end
            (* Pick bfs roots by lowest degree first *)
            fun pick (node, ()) = bfs (Queue.pushBack (Queue.empty, node))
            val () = Array.foldl pick () degreeOrder
         in
            Array.vector permutation
         end
      fun inverse permutation =
         let
            val a = Array.array (Vector.length permutation, ~1)
            fun update (i, j) = Array.update (a, j, i)
            val () = Vector.appi update permutation
         in
            Array.vector a
         end
      fun relabel (graph, permutation) =
         let
            val ipermutation = inverse permutation
            fun map i = Vector.sub (permutation, i)
            fun imap i = Vector.sub (ipermutation, i)
            fun node i = List.map map (Vector.sub (graph, imap i))
         in
            Vector.tabulate (Vector.length graph, node)
         end
      fun bandwidth graph = 
         let
            fun biggest i (j, acc) = Int.max (Int.abs (i - j), acc)
            fun node (i, l, acc) = List.foldl (biggest i) acc l
         in
            Vector.foldli node 0 graph
         end
   end

(*
(* A 3x3 grid. *)
val grid = Vector.fromList
  [ [ 1, 3],    [0, 2, 4],    [1, 5],
    [ 0, 4, 6], [1, 3, 5, 7], [2, 4, 8],
    [ 3, 7],    [4, 6, 8],    [5, 7]
  ]
val mess = Vector.fromList [ 7, 0, 2, 6, 5, 1, 8, 3, 4 ]
val grid = CuthillMcKee.relabel (grid, mess)

val bw = CuthillMcKee.bandwidth grid
val () = print ("Old Bandwidth: " ^ Int.toString bw ^ "\n")

val permutation = CuthillMcKee.optimize grid
val newgrid = CuthillMcKee.relabel (grid, permutation)
val bw = CuthillMcKee.bandwidth newgrid
val () = print ("New Bandwidth: " ^ Int.toString bw ^ "\n")

fun vtx l = (List.app (fn i => print (Int.toString i ^ " ")) l; print "\n")
val () = Vector.appi (fn (i, l) => (print (Int.toString i ^ ": "); vtx l)) newgrid
*)
