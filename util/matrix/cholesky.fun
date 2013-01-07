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

functor Cholesky(Algebra : ALGEBRA) : CHOLESKY =
   struct
      structure Algebra = Algebra
      open Algebra
      
      fun f A =
         let
            val (rows, cols) = Matrix.dimension A
            val (lower, _) = Matrix.bandwidth A
            val symmetric = Matrix.symmetric A
         in
            if not symmetric orelse rows <> cols then raise Domain else
            let
               val D = Array.array (rows, Element.zero)
               val DLr = Array.array (rows, Element.zero)
               fun work (L, r, c) =
                  if r = c then
                     let
                        val a = Matrix.sub A (r, c)
                        val Lc = Matrix.row L c
(*
                        val Lr = Matrix.row L r
                        val D' = Vector.fromArray (D, c)
                        val DLr' = Vector.* (D', Lr)
*)
                        val DLr' = Vector.fromArray (DLr, c)
                        val Dc = Element.- (a, Vector.dot (Lc, DLr'))
                        val () = Array.update (D, c, Dc)
                        
                        (* In banded operation, we won't overwrite old values
                         * in the earlier cached values of DLr. Zero the band.
                         *)
                        val () = 
                           if c < lower then () else
                           Array.update (DLr, c-lower, Element.zero)
                     in
                        Element.one
                     end
                  else
                     let
                        val a = Matrix.sub A (r, c)
                        val Lc = Matrix.row L c
(*
                        val Lr = Matrix.row L r
                        val D' = Vector.fromArray (D, c)
                        val DLr' = Vector.* (D', Lr)
*)
                        val DLr' = Vector.fromArray (DLr, c)
                        val DcLrc = Element.- (a, Vector.dot (Lc, DLr'))
                        val () = Array.update (DLr, c, DcLrc)
                        val Dc = Array.sub (D, c)
                        val Lrc = Element./ (DcLrc, Dc)
                     in
                        Lrc
                     end
               val L = Matrix.unfold {
                  dimension = (rows, cols),
                  bandwidth = (lower, 0),
                  symmetric = false,
                  fetch = work
                  }
               val D = Matrix.tabulate {
                  dimension = (rows, cols),
                  bandwidth = (0, 0),
                  symmetric = true,
                  fetch = fn (r, _) => Array.sub (D, r)
                  }
            in
               { D=D, L=L }
            end
         end
      
      fun inverse D = 
         if Matrix.bandwidth D <> (0, 0) then raise Domain else
         Matrix.tabulate {
            dimension = Matrix.dimension D,
            bandwidth = (0, 0),
            symmetric = true,
            fetch = fn (r, _) => Element./ (Element.one, Matrix.sub D (r, r))
         }
   end
