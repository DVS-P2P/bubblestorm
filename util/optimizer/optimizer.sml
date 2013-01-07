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

structure Optimizer :> OPTIMIZER =
   struct
      exception EmptyInterior
      exception InfeasibleStart
      exception UnusedVariable
      
      type map = Constraint.var -> Element.t
      type solution = map * (unit -> unit)
      
      structure Newton = Newton(Algebra)
      
      val zero = Element.zero
      val one = Element.one
      val two = Element.+ (one, one)
      val negOne = Element.- (zero, one)
      
      fun solve { constraints, costs, interior, bound, stop } =
         let
            (* Add extra constraints to enforce the bound (if any) *)
            local
               open Iterator
               open Constraint
            in
               fun limit s b v =
                  SUM { a = s, x = SOME v, b = 0.0, y = NONE, c = b, z = NONE }
               
               val m = Element.fromInt (length constraints)
               val vars = concat (map vars constraints)
               
               fun extraP bound = map (limit  1.0 bound) vars
               fun extraN bound = map (limit ~1.0 bound) vars
               
               val constraints =
                  case bound of
                     NONE => constraints
                   | SOME b => extraP b @ extraN b @ constraints
               val constraints = fromVector (toVector constraints)
            end
            
            (* Label the variables optimally *)
            val labels = Labels.optimize constraints
            val { terms, width=_, index, clear } = labels
            
            (* Create a costs vector from the costs function *)
            val costsArray = Array.array (terms, Element.zero)
            fun fill var = Array.update (costsArray, index var, costs var)
            val () = Iterator.app fill vars
            val costs = Vector.fromArray (costsArray, terms)

            (* Create an interior from the interior function *)
            val (interior, interiorClear) = interior
            val interiorArray = Array.array (terms, Element.zero)
            fun fill var = Array.update (interiorArray, index var, interior var)
            val () = Iterator.app fill vars
            val interior = Vector.fromArray (interiorArray, terms)
            
            (* Clear the interior values *)
            val () = interiorClear ()
            
            (* Nicely scale the costs vector to keep terms sane *)
            val costsMax = Vector.max costs
            val costs = Vector.scale (costs, Element.one / costsMax)
            
            (* We are using the barrier method.
             * For goal function f_0(x) and constraints f_i(x) >= 0
             * we thus set F_t(x) := f_0(x) - (1/t) sum_i log(f_i(x))
             * We then minimize F_t(x) for a given 't'.
             * Here 't' controls the accuracy of solution.
             * If 'p_t' is the minimum of F_t, then
             *   |f_0(p_t) - min(f_0)| <= m/t
             *   where 'm' is the number of constraints.
             *
             * To simplify calculation, we will be computing:
             *   F_t(x) := t * f_0(x) - sum_i log(f_i(x))
             * ... which has the same minimum p_t as the original F_t.
             * Furthermore, f_0(x) = (costs^T) * x.
             *)
            
            (* Setup easy to-use f, gradient, and Hessian *)
            fun value x var = Vector.sub x (index var)
            fun f t x = (* F_t(x) *)
               let
                  val constraints = 
                     Function.compute {
                        variables   = value x,
                        constraints = constraints,
                        labels      = labels
                     }
                  
                  val cost = Vector.dot (costs, x)
                  val out = constraints + t * cost
(*
                  fun dump i = print (Element.toString (Vector.sub x i) ^ " ")
                  val () = print "f "
                  val () = Iterator.app dump (Iterator.fromInterval { start = 0, stop = terms, step = 1 })
                  val () = print " = "
                  val () = print (Element.toString out ^ " (" ^ Element.toString cost ^ ")\n")
*)
               in
                  out
               end
            fun gradient t x = (* gradient of F_t(x) *)
               let
                  val constraints =
                     Gradient.compute {
                        variables   = value x,
                        constraints = constraints,
                        labels      = labels
                     }
               in
                  Vector.+ (constraints, Vector.scale (costs, t))
               end
            fun hessian x = (* hessian of F_t(x) *)
               let
                  val constraints =
                     Hessian.compute {
                        variables   = value x,
                        constraints = constraints,
                        labels      = labels
                     }
(*
                  val () = print (Matrix.toString Element.toString constraints)
*)
               in
                  constraints
               end
            
            (* Confirm that we are in the interior *)
            val fx = f zero interior
            val () = if Element.isFinite fx then () else raise InfeasibleStart
            
(*
            val epsilon = 5.96046447753906E~08 (* float  = 2^-24 *)
            val epsilon = 3.5527136788005E~15  (* double = 2^-48 *)
*)
            val epsilon = 3.5527136788005E~15  (* double = 2^-48 *)
            
            fun sqr x = x*x
            val t0 = one / Vector.dot (costs, interior)
            val u  = (sqr o sqr) two (* 16.0 *)
            
            fun out x var =
               let
                  val i = index var
               in
                  Vector.sub x i
               end
               handle Labels.UnLabeled => raise UnusedVariable
            
            fun loop (t, x) =
               let
(*
                  fun dump i = print (Element.toString (Vector.sub x i) ^ " ")
                  val () = Iterator.app dump (Iterator.fromInterval { start = 0, stop = terms, step = 1 })
                  val () = print "\n"
*)                  
                  (* Find p_t, the minimum of F_t *)
(*
                  val () = TextIO.print "-----------------------------------------------------------------------------\n"
*)
                  val x' = 
                     Newton.f {
                        x0       = x,
                        f        = f t,
                        gradient = gradient t,
                        hessian  = hessian,
                        epsilon  = epsilon,
                        stop     = fn x => stop (out x)
                     }
                  
                  (* Compute the relative accuracy of the solution.
                   *  |(f_0(p_t) - min(f_0))/f_0(p_t)|
                   *     <= |m / (t f_0(p_t))|
                   *)
                  val accuracy = Element.abs ((m / t) / Vector.dot (costs, x'))
               in
                  if not (Element.< (epsilon, accuracy)) orelse stop (out x')
                  then x' 
                  else loop (t*u, x')
               end
            
            val result = loop (t0, interior)
         in
            (out result, clear)
         end

      fun interior { constraints, bound } = 
         let
            datatype z = datatype Constraint.t
            
            val { get, set, remove } = 
               Property.getSetOnce (Constraint.plist, Property.initConst Element.zero)
            
            local
               open Element
            in
               val term = fn (NONE, a) => a | (SOME _, _) => zero
               val LHS = fn
                  SUM { x, y, z, a, b, c } => 
                     term (x, a) + term (y, b) + term (z, c)
                | EXP _ => negOne
                | EXP1 _ => zero
               fun min (x, y) = if x < y then x else y
               val s0 = Iterator.fold min zero (Iterator.map LHS constraints)
               val s0 = (zero - s0) + two
            end
            
            val s = Constraint.newVariable ()
            val () = set (s, s0)
            
            fun map c =
               let
                  val q = Constraint.newVariable ()
               in
                  case c of
                     (* ax + by >= q      (ax + by >= ax + by - 1 = q)
                      * q + s + cz >= 0   (ax + by + cz + s >= 1+1)
                      *  --->    ax + by + cz + s >= 0
                      *          with q = ax + by
                      *)
                     SUM { x, y, z, a, b, c } =>
                        (set (q, term (x, a) + term (y, b) - one)
                        ;  [ SUM { x=x, y=y, z=SOME q, a=a, b=b, c=negOne }, 
                             SUM { x=SOME q, y=SOME s, z=z, a=one, b=one, c=c } ])
                     (* x + s >= q    (0 + s >= 3 >= 2 = q)
                      * q >= exp(y)   (2 >= exp(0) = 1)
                      *  --->    x + s >= exp(y)
                      *          with q = x + s
                      *)
                   | EXP { x, y } =>
                        (set (q, two)
                        ;  [ EXP { x=q, y=y },
                             SUM { x=SOME x, y=SOME s, z=SOME q, 
                                   a=one, b=one, c=negOne } ])
                     (* x + s >= q    (0 + s >= 2 >= 1 = q)
                      * q >= exp(y)-1 (1 >= exp(0)-1 = 0)
                      *  --->    x + s >= exp(y)-1
                      *          with q = x + s
                      *)
                   | EXP1 { x, y } =>
                        (set (q, one)
                        ;  [ EXP1 { x=q, y=y },
                             SUM { x=SOME x, y=SOME s, z=SOME q, 
                                   a=one, b=one, c=negOne } ])
               end
            
            val cvt = List.concat o Iterator.toList o Iterator.map map
            val constraints = Iterator.fromList (cvt constraints)
            
            (* Clear the interior variable markers *)
            local
               open Iterator
            in
               fun interiorClear () = 
                  app remove (concat (map Constraint.vars constraints))
            end
            
            val (out, clear) = 
               solve {
                  constraints = constraints,
                  costs       = fn v => if v = s then one else zero,
                  interior    = (get, interiorClear),
                  bound       = SOME bound,
                  stop        = fn v => v s < zero
               }
         in
            if Element.< (out s, zero)
            then (out, clear)
            else (clear (); raise EmptyInterior)
         end
      
      val solve = fn { constraints, costs, interior, bound } =>
         solve { 
            constraints = constraints,
            costs       = costs,
            interior    = interior,
            bound       = bound,
            stop        = fn _ => false
         }
   end
