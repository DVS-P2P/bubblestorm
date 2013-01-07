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

functor Newton(Algebra : ALGEBRA) : NEWTON = 
   struct
      structure Algebra = Algebra
      structure Cholesky = Cholesky(Algebra)
      structure Solve = Solve(Algebra)
      open Algebra
      
      (* val debug = TextIO.print *)
      fun debug _ = ()
      
      local
         open Element
      in
         val zero = zero
         val negOne = zero - one
         val two = one + one
         val four = two + two
         val eight = four + four
      end
      
      fun backtrackingLineSearch { x0, dx, f, descent } =
         let
            open Element
            val alpha = one / eight (* in (0.01, 0.3) *)
            val beta  = one / two   (* in (0.1,  0.8) *)
            
            val fx0 = f x0
(*
            val () = print "fx0:\n"
            val () = print (Element.toString fx0)
            val () = print "\n"
*)
            fun loop t =
               let
                  val () = debug "."
                  val x = Vector.+ (x0, Vector.scale (dx, t))
                  val fx = f x
                  
(*
                  val () = print "t f(x):\n"
                  val () = print (Element.toString t)
                  val () = print " "
                  val () = print (Element.toString fx)
                  val () = print "\n"
*)
               in
                  if fx0 + alpha * t * descent < fx
                  then loop (t * beta)
                  else if not (fx < fx0) then NONE else SOME x
               end
         in
            loop one
         end
      
      fun f { x0, f, hessian, gradient, epsilon, stop } =
         let
            val negEpsilon = Element.- (zero, epsilon)
(*
            val (rows, _) = Matrix.dimension (hessian x0)
            val loop = Iterator.fromInterval { start=0, stop=rows, step=1 }
            fun dumpElement e = (print (Element.toString e); print " ")
            fun dumpVector v = (Iterator.app (dumpElement o Vector.sub v) loop; print "\n")
            fun dumpMatrix A = Iterator.app (dumpVector o Matrix.row A) loop
*)            
            fun loop x =
               let
                  val gradient = gradient x
                  val hessian = hessian x
                  val fx = f x

(*
                  val () = print "x0:\n"
                  val () = dumpVector x
                  val () = print "gradient:\n"
                  val () = dumpVector gradient
                  val () = print "Hessian:\n"
                  val () = dumpMatrix hessian
*)
                  
                  (* Solve dx = -H^-1 g = -(LDL^T)^-1 g = -L^-T*D^-1*L^-1 g *)
                  val {D, L} = Cholesky.f hessian
                  val g' = Solve.forward (L, gradient)
                  val D1 = Cholesky.inverse D
                  val g'' = Matrix.map (D1, g')
                  val LT = Matrix.transpose L (* upper triangular *)
                  val g''' = Solve.backward (LT, g'')
                  val dx = Vector.scale (g''', negOne)
                  val descent = Vector.dot (gradient, dx)

(*
                  val () = print "descent:\n"
                  val () = dumpElement descent
                  val () = print "\ndx:\n"
                  val () = dumpVector dx
*)
                  
                  open Element
                  val error = descent / two
                  val relError = error / fx
                  val () = debug "N: "
               in
                  if (negEpsilon < relError andalso relError < epsilon) orelse stop x
                  then (debug " - good!\n"; x) else
                  (* Find x' = x + t*dx for some t *)
                  case backtrackingLineSearch { x0=x, dx=dx, f=f, descent=descent } of
                     SOME x => (debug "\n"; loop x)
                   | NONE => (debug " - ERR\n"; x) (* not possible to proceed *)
               end
         in
            loop x0
         end
   end
