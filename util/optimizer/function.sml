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

structure Function :> FUNCTION =
   struct
      fun compute { variables, constraints, labels = _ } =
         let
            datatype z = datatype Constraint.t
            
            val out = ref Element.zero
            
            fun add v =
               let
                  val old = !out
                  val new = old + v
               in
                  out := new
               end
            
            fun barrier x =
               if x > Element.zero
               then ~(Element.Math.ln x)
               else Element.posInf
            
            val process = fn
               SUM { x, y, z, a, b, c } =>
               let
                  fun get v = getOpt (Option.map variables v, Element.one)
                  val (x', y', z') = (get x, get y, get z)
                  
                  (* Constriant: a*x + b*y + c*z >= 0
                   * Formulated as -log(a*x + b*y + c*z) 
                   *)
                  val term = a*x' + b*y' + c*z'
               in
                  add (barrier term)
               end
             | EXP { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)
                   * Formulated as -log(x - exp(y)) 
                   *)
                  val ey = Element.Math.exp y'
                  val term = x' - ey
               in
                  add (barrier term)
               end
             | EXP1 { x, y } =>
               let
                  val (x', y') = (variables x, variables y)
                  
                  (* Constriant: x >= exp(y)-1
                   * Formulated as -log(x - (exp(y)-1)) 
                   *)
                  val e1y = Exp1.f y'
                  val term = x' - e1y
               in
                  add (barrier term)
               end
            
            val () = Iterator.app process constraints
         in
            !out
         end
   end
