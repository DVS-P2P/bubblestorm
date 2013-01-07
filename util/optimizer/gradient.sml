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

structure Gradient :> GRADIENT =
   struct
      fun compute { variables, constraints, labels : Labels.t } =
         let
            datatype z = datatype Constraint.t
            
            val { index, terms, ... } = labels
            val out = Array.array (terms, Element.zero)
            
            fun add (x, v) =
               let
                  val xi = index x
                  val old = Array.sub (out, xi)
                  val new = old + v
               in
                  Array.update (out, xi, new)
               end
            
            val process = fn
               SUM { x, y, z, a, b, c } =>
               let
                  fun get v = getOpt (Option.map variables v, Element.one)
                  val (x', y', z') = (get x, get y, get z)
                  
                  (* Constriant: a*x + b*y + c*z >= 0
                   * Formulated as -log(a*x + b*y + c*z) 
                   * 
                   * Gradient = 1 / (a*x + b*y + c*z) [ -a ]
                   *                                  [ -b ]
                   *                                  [ -c ]
                   *)
                  val divisor = a*x' + b*y' + c*z'
                  
                  val addOpt = fn
                     (SOME x, v) => add (x, v)
                   | _ => ()
                  
                  val () = addOpt (x, ~a / divisor)
                  val () = addOpt (y, ~b / divisor)
                  val () = addOpt (z, ~c / divisor)
               in
                  ()
               end
             | EXP { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)
                   * Formulated as -log(x - exp(y)) 
                   * 
                   * Gradient = 1/(x - exp(y)) [ -1     ]
                   *                           [ exp(y) ]
                   *)
                  val ey = Element.Math.exp y'
                  val divisor = x' - ey
                  
                  val () = add (x, (Element.zero - Element.one) / divisor)
                  val () = add (y, ey / divisor)
               in
                  ()
               end
             | EXP1 { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)-1
                   * Formulated as -log(x - (exp(y)-1))
                   * 
                   * Gradient = 1/(x - (exp(y)-1)) [ -1     ]
                   *                               [ exp(y) ]
                   *)
                  val ey = Element.Math.exp y'
                  val e1y = Exp1.f y'
                  val divisor = x' - e1y
                  
                  val () = add (x, (Element.zero - Element.one) / divisor)
                  val () = add (y, ey / divisor)
               in
                  ()
               end
            
            val () = Iterator.app process constraints
         in
            Vector.fromArray (out, terms)
         end
   end
