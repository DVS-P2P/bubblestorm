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

(* Want to minimize:
 *  a*x + b*y
 * with the constraint:
 *  (1 - exp(-x*wm)) * (1 - exp(-y*wm)) >= 1 - exp(-l*wm*wm/Sw2)
 *
 * First step, pull the coefficients -1/D2 out of 
 * the constraints and into the goal function.
 *              
 * (1 - exp(-x*wm)) * (1 - exp(-y*wm))
 * >= (1 - exp(j)) * (1 - exp(k))          j >= -x*wm
 * >= (-n) * (-m)                          exp(j)-1 <= n
 * >= p * q                                -n >= p
 * >= exp(a) * exp(b)                      p >= exp(a)
 * >= exp(log(RHS))                        a+b >= lRHS
 * = RHS
 * = 1 - exp(-l*wm*wm*T)
 *)

            (* the network stats *)
            val cvt = valOf o Real64.fromString
            val [d1, d2, dm] = CommandLine.arguments ()
            val (d1, d2, dm) = (cvt d1, cvt d2, cvt dm)
            
            val lambda = 1.0
            
            (* some derived stats *)
            val wm = dm / d1
            val Sw2 = d2/(d1*d1) (* sum_u w_u^2 *)
            val maxLambda = lambda
            val maxRHS    = ~ (Exp1.f (~maxLambda * wm * wm / Sw2))
            val maxLogRHS = Real64.Math.ln maxRHS
            val minSize = 1.0
            
            val Bx = Constraint.newVariable ()
            val By = Constraint.newVariable ()

(* limits
 * cost >= 1
 * bubble size >= 1
 *)
      val { get=getInitial, set=setInitial, remove=_ } =
         Property.getSet (Constraint.plist, Property.initRaise (Fail "oops"))
      
      val {get=getCost, set=setCost, remove=_} =
         Property.getSet (Constraint.plist, Property.initConst 0.0)

      (* we use temporary variables to represent the match constraints in a form
       * the optimizer can handle them. The temporary variables form a 
       * chain of constraints and the last temporary variable is stored 
       * in a property of the bubble. That way, the temporary variables 
       * are created only once and only for bubble types that actually 
       * intersect other types.
       *)
      fun setupTempVar balancerVar =
         let
            open Constraint
            val j = newVariable ()
            val n = newVariable ()
            val p = newVariable ()
            val a = newVariable ()                  

            val out =
               (* x*wm >= -j    *) SUM  { a = wm, x = SOME balancerVar, b = 0.0, 
                                          y = NONE, c = 1.0, z = SOME j } ::
               (* n >= exp(j)-1 *) EXP1 { x = n, y = j } ::
               (* -n >= p       *) SUM  { a = 0.0, x = NONE, b = ~1.0,
                                          y = SOME n, c = ~1.0, z = SOME p } ::
               (* p >= exp(a)   *) EXP  { x = p, y = a } ::
               (* x >= 1        *) SUM { a =  1.0, x = SOME balancerVar, 
                                         b = ~minSize, y = NONE,
                                         c = 0.0, z = NONE } :: []
            
            (* set initial values *)
            val set = setInitial
            val get = getInitial
            (* a<0    a >= lRHS/2   *) val () = set (a, maxLogRHS/4.0)
            (* 0<p<1  p >= exp(a)   *) val () = set (p, (1.0 + Real64.Math.exp (get a)) / 2.0)
            (* -1<n<0 -n >= p       *) val () = set (n, ~ (1.0 + get p) / 2.0)
            (* j<0    n >= exp(j)-1 *) val () = set (j, 2.0 * Real64.Math.ln (get n + 1.0))
            (* x>0    x >= -j/wm    *) val initial = 2.0 * ~(get j) / wm
            (* balancerVar already has an initial value from min constraint *)
            val () = set (balancerVar, Real64.max (2.0 * minSize, initial))
         in
            (a, out)
         end
      
      (* convert all match constraints from the bubble types to optimizer 
         constraints *)
            fun match (Bx', By') =
               let
                  val RHS    = ~ (Exp1.f (~lambda * wm * wm / Sw2))
                  val logRHS = Real64.Math.ln RHS
                  open Constraint
               in
                  (* a + b >= lambda  *) 
                  SUM { a = 1.0, x = SOME Bx', b = 1.0, 
                        y = SOME By', c = ~logRHS, z = NONE }
               end            
      
      val (Bx', Bxc) = setupTempVar Bx
      val (By', Byc) = setupTempVar By
      val m = match (Bx', By')
      
      val constraints = Bxc @ Byc @ [m]

      fun doit () =
        let
            (* solve the problem *)
            val (solution, free) =
               Optimizer.solve {
                  constraints = Iterator.fromList constraints,
                  costs       = getCost,
                  interior    = (getInitial, fn () => ()),
                  bound       = NONE
               }
            val out = (solution Bx, solution By)
            val () = free ()
         in
            out
         end
      
      val rate = 1.25892541179417
      val start = 1e~6
      val stop  = 1e6
      
      fun CS #"~" = #"-"
        | CS x = x
      val fmt = String.map CS o Real64.toString
      
      val () = print ("# hand-balance " ^ fmt d1 ^ " " ^ fmt d2 ^ " " ^ fmt dm ^ "\n")
      val () = print "# SQ/SD xQ xD Traffic Error\n"
      
      val () = setCost (By, 1.0)
      fun loop x =
         let
            val () = setCost (Bx, x)
            val x' = x * rate
            val (Sx, Sy) = doit ()
            val () = print (fmt x ^ " ")
            val () = print (fmt Sx ^ " ")
            val () = print (fmt Sy ^ " ")
            val () = print (fmt ((Sx*x + Sy) / (x + 1.0)) ^ " ")
            val RHS = ~ (Exp1.f (~lambda * wm * wm / Sw2))
            val LHS = (Exp1.f (~ wm * Sx)) * (Exp1.f (~wm * Sy))
            val error = Real64.abs (LHS-RHS)
            val () = print (fmt (error/RHS) ^ "\n")
         in
            if x' > (stop*(1.0+(rate-1.0)/2.0)) then () else loop x'
         end
      
      val () = loop start
