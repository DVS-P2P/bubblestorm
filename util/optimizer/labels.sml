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

structure Labels :> LABELS =
   struct
      exception UnLabeled

      type t = {
         terms : int,
         width : int,
         index : Constraint.var -> int,
         clear : unit -> unit
      }
      
      fun optimize constraints =
         let
            val { get=get1, set=set1, remove=remove1 } = 
               Property.getSetOnce (Constraint.plist, Property.initConst ~1)
            
            (* Step 1. Pass through all the constraints, labeling variables *)
            val n = ref 0
            val distinctVars = ref []
            fun setIndex var =
               if get1 var <> ~1 then () else
               (set1 (var, !n); n := !n + 1; distinctVars := var :: !distinctVars)
            local
               open Iterator
            in
               val () = app setIndex (concat (map Constraint.vars constraints))
            end
            
            (* Step 2. Construct a graph from constraints *)
            val n = !n
            val graph = Array.array (n, [])
            fun edge (x, y) = 
               let
                  val (x, y) = (get1 x, get1 y)
                  val tail = Array.sub (graph, x)
               in
                  Array.update (graph, x, y :: tail)
               end
            local
               open Iterator
               fun pairs v = cross (Constraint.vars v, Constraint.vars v)
            in
               val () = app edge (concat (map pairs constraints))
            end
            val graph = Array.vector graph
            
            (* Step 3. Find the improved numbering to reduce bandwidth *)
            val graph = CuthillMcKee.simplify graph
            val permute = CuthillMcKee.optimize graph
            val graph = CuthillMcKee.relabel (graph, permute)
            val width = CuthillMcKee.bandwidth graph
            
(*
            fun out l = (List.app (print o Int.toString) l; print "\n")
            val () = PolyVector.app out graph
*)            
            (* Step 4. Relabel all of the variables *)
            val { get=get2, set=set2, remove=remove2 } = 
               Property.getSetOnce (Constraint.plist, Property.initConst ~1)
            fun relabel v = 
               (set2 (v, PolyVector.sub (permute, get1 v)); remove1 v)
            val () = List.app relabel (!distinctVars)
            
            (* Step 4. Wrap up the accessor *)
            fun index v =
               let
                  val i = get2 v
               in
                  if i = ~1 then raise UnLabeled else i
               end
            fun clear () = List.app remove2 (!distinctVars)
         in
            {
               terms = n,
               width = width,
               index = index,
               clear = clear
            }
         end
   end
