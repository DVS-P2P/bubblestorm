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

functor Solve(Algebra : ALGEBRA) : SOLVE =
   struct
      structure Algebra = Algebra
      open Algebra
      
      fun make order (A, b) =
         let
            fun build (V, i) =
               let
                  val Ai = Matrix.row A i
                  val AiX = Vector.dot (Ai, V)
                  val b = Vector.sub b i
                  val top = Element.- (b, AiX)
                  val bottom = Matrix.sub A (i, i)
               in
                  Element./ (top, bottom)
               end
         in
            Vector.unfold {
               start  = 0,
               length = #1 (Matrix.dimension A),
               order  = order,
               fetch  = build
            }
         end
      
      (* Solve Ax = b, A lower triangular *)
      fun forward (A, b) =
         if #2 (Matrix.bandwidth A) <> 0 then raise Domain else
         make Vector.TOP_DOWN (A, b)
      
      (* Solve Ax = b, A upper triangular *)
      fun backward (A, b) =
         if #1 (Matrix.bandwidth A) <> 0 then raise Domain else
         make Vector.BOTTOM_UP (A, b)
   end
