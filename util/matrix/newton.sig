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

signature NEWTON =
   sig
      structure Algebra : ALGEBRA
      
      (* Find the vector which minimizes function f.
       * gradient = grad(f) = f'
       * hessian  = H(f)    = f''
       * stop when the relative error is less than epsilon
       * x0 is an initial search point
       *)
      val f : {
         x0      : Algebra.Vector.t,
         f       : Algebra.Vector.t -> Algebra.Element.t,
         gradient: Algebra.Vector.t -> Algebra.Vector.t,
         hessian : Algebra.Vector.t -> Algebra.Matrix.t,
         epsilon : Algebra.Element.t,
         stop    : Algebra.Vector.t -> bool
      } -> Algebra.Vector.t
   end
