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

structure Hessian :> HESSIAN =
   struct
      fun compute { variables, constraints, labels : Labels.t } =
         let
            datatype z = datatype Constraint.t
            
            val { terms, width, index, ... } = labels
            val out = 
               Matrix.tabulate {
                  dimension = (terms, terms),
                  bandwidth = (width, width),
                  symmetric = true,
                  fetch     = fn _ => Element.zero
               }
            
            fun add (x, y, v) =
               let
                  val (xi, yi) = (index x, index y)
(*
                  val () = print ("add(" ^ Int.toString xi ^ ", " ^ Int.toString yi ^ "): " ^ Element.toString v ^ "\n")
*)
                  val old = Matrix.sub out (xi, yi)
                  val new = old + v
               in
                  Matrix.update out (xi, yi, new)
               end
            
            val process = fn
               SUM { x, y, z, a, b, c } =>
               let
                  fun get v = getOpt (Option.map variables v, Element.one)
                  val (x', y', z') = (get x, get y, get z)
                  
                  (* Constriant: a*x + b*y + c*z >= 0
                   * Formulated as -log(a*x + b*y + c*z) 
                   * 
                   * Hessian = 1/(ax + by + cz)^2  [  a*a  a*b  a*c ]
                   *                               [  a*b  b*b  b*c ]
                   *                               [  a*c  b*c  c*c ]
                   *)
                  val divisor = a*x' + b*y' + c*z'
                  val divisor = divisor * divisor
                  
                  val addOpt = fn
                     (SOME x, SOME y, v) => add (x, y, v)
                   | _ => ()
                  
                  val () = addOpt (x, x, a*a/divisor)
                  val () = addOpt (x, y, a*b/divisor)
                  val () = addOpt (x, z, a*c/divisor)
                  val () = addOpt (y, x, a*b/divisor)
                  val () = addOpt (y, y, b*b/divisor)
                  val () = addOpt (y, z, b*c/divisor)
                  val () = addOpt (z, x, a*c/divisor)
                  val () = addOpt (z, y, b*c/divisor)
                  val () = addOpt (z, z, c*c/divisor)
               in
                  ()
               end
             | EXP { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)
                   * Formulated as -log(x - exp(y))
                   * 
                   * Hessian = 1/(x - exp(y))^2  [  1      -exp(y)   ]
                   *                             [ -exp(y)  x*exp(y) ]
                   *)
                  
                  val ey = Element.Math.exp y'
                  val divisor = x' - ey
                  val divisor = divisor * divisor
                  
                  val () = add (x, x, Element.one / divisor)
                  val () = add (x, y, ~ey / divisor)
                  val () = add (y, x, ~ey / divisor)
                  val () = add (y, y, ey * x' / divisor)
               in
                  ()
               end
             | EXP1 { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)-1
                   * Formulated as -log(x - (exp(y)-1))
                   * 
                   * Hessian = 1/(x - (exp(y)-1))^2  [  1      -exp(y)       ]
                   *                                 [ -exp(y)  (x+1)*exp(y) ]
                   *)
                  
                  val ey = Element.Math.exp y'
                  val e1y = Exp1.f y'
                  val divisor = x' - e1y
                  val divisor = divisor * divisor
                  
                  val () = add (x, x, Element.one / divisor)
                  val () = add (x, y, ~ey / divisor)
                  val () = add (y, x, ~ey / divisor)
                  val () = add (y, y, ey * (x' + 1.0) / divisor)
               in
                  ()
               end
            
            val () = Iterator.app process constraints
         in
            out
         end
   end
