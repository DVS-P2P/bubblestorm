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

local
   open Constraint
   open Optimizer
in
   val x = newVariable ()
   val y = newVariable ()
   val toR = valOf o Real64.fromString
   val [ D0, D1, D2, Dm ] = List.map toR (CommandLine.arguments ())
   val l = 4.0
   
   val wm = Dm / D1
   val Sw2 = D2 / (D1*D1)
   
   (* Want to minimize:
    *  a*x + b*y
    * with the constraint:
    *  (1 - exp(-x/D2)) * (1 - exp(-y/D2)) >= 1 - exp(-l/D2)
    *)
   val RHS = ~ (Exp1.f (~l * wm * wm / Sw2))
   
   (* First step, pull the coefficients -1/D2 out of the constraints and
    * into the goal function.
    *)
   
   val a = newVariable ()
   val b = newVariable ()
   val p = newVariable ()
   val q = newVariable ()
   val n = newVariable ()
   val m = newVariable ()
   val j = newVariable ()
   val k = newVariable ()
   
   (* (1 - exp(-x/D2)) * (1 - exp(-y/D2))
    * >= (1 - exp(j)) * (1 - exp(k))          j >= -x/D2
    * >= (-n) * (-m)                          exp(j)-1 <= n
    * >= p * q                                -n >= p
    * >= exp(a) * exp(b)                      p >= exp(a)
    * >= exp(log(RHS))                        a+b >= lRHS
    * = RHS
    * = 1 - exp(-l/D2)
    *)
   val lRHS = Real64.Math.ln RHS
   val constraints = Iterator.fromList [
      (* x/D2 >= -j    *) SUM  { a = wm, x = SOME x, b = 0.0, y = NONE, c = 1.0, z = SOME j },
      (* y/D2 >= -k    *) SUM  { a = wm, x = SOME y, b = 0.0, y = NONE, c = 1.0, z = SOME k },
      (* n >= exp(j)-1 *) EXP1 { x = n, y = j },
      (* m >= exp(k)-1 *) EXP1 { x = m, y = k },
      (* -n >= p       *) SUM  { a = 0.0, x = NONE, b = ~1.0, y = SOME n, c = ~1.0, z = SOME p },
      (* -m >= q       *) SUM  { a = 0.0, x = NONE, b = ~1.0, y = SOME m, c = ~1.0, z = SOME q },
      (* p >= exp(a)   *) EXP  { x = p, y = a },
      (* q >= exp(b)   *) EXP  { x = q, y = b },
      (* a + b >= l    *) SUM  { a = 1.0, x = SOME a, b = 1.0, y = SOME b, c= ~lRHS, z=NONE }
   ]
   
   (* Initial values *)
   val { get, set, remove } = Property.getSet (plist, Property.initRaise Domain)
   
   (* a<0    a >= lRHS/2   *) val () = set (a, lRHS/4.0)
   (* 0<p<1  p >= exp(a)   *) val () = set (p, (1.0 + Real64.Math.exp (get a)) / 2.0)
   (* -1<n<0 -n >= p       *) val () = set (n, ~ (get p + 1.0) / 2.0)
   (* j<0    n >= exp(j)-1 *) val () = set (j, 2.0 * Real64.Math.ln (get n + 1.0))
   (* x>0    x >= -jD2     *) val () = set (x, 2.0 * ~(get j) / wm)

   (* a<0    a >= lRHS/2   *) val () = set (b, lRHS/4.0)
   (* 0<p<1  p >= exp(a)   *) val () = set (q, (1.0 + Real64.Math.exp (get b)) / 2.0)
   (* -1<n<0 -n >= p       *) val () = set (m, ~ (get q + 1.0) / 2.0)
   (* j<0    n >= exp(j)-1 *) val () = set (k, 2.0 * Real64.Math.ln (get m + 1.0))
   (* x>0    x >= -jD2     *) val () = set (y, 2.0 * ~(get k) / wm)
   
   val () = print ("Start:\n")
   val () = print ("  lRHS = " ^ Real64.toString lRHS ^ "\n")
   val () = print ("  a = " ^ Real64.toString (get a) ^ "\n")
   val () = print ("  b = " ^ Real64.toString (get b) ^ "\n")
   val () = print ("  p = " ^ Real64.toString (get p) ^ "\n")
   val () = print ("  q = " ^ Real64.toString (get q) ^ "\n")
   val () = print ("  n = " ^ Real64.toString (get n) ^ "\n")
   val () = print ("  m = " ^ Real64.toString (get m) ^ "\n")
   val () = print ("  j = " ^ Real64.toString (get j) ^ "\n")
   val () = print ("  k = " ^ Real64.toString (get k) ^ "\n")
   val () = print ("  x = " ^ Real64.toString (get x) ^ "\n")
   val () = print ("  y = " ^ Real64.toString (get y) ^ "\n")
   
   val (solution, clear) =
      solve {
         constraints = constraints,
         costs       = fn v => if v=x then 1.0 else if v=y then 1.0 else 0.0,
         interior    = (get, fn () => ()),
         bound       = NONE
      }
   
   val () = print ("Solution:\n")
   val () = print ("  lRHS = " ^ Real64.toString lRHS ^ "\n")
   val () = print ("  a = " ^ Real64.toString (solution a) ^ "\n")
   val () = print ("  b = " ^ Real64.toString (solution b) ^ "\n")
   val () = print ("  p = " ^ Real64.toString (solution p) ^ "\n")
   val () = print ("  q = " ^ Real64.toString (solution q) ^ "\n")
   val () = print ("  n = " ^ Real64.toString (solution n) ^ "\n")
   val () = print ("  m = " ^ Real64.toString (solution m) ^ "\n")
   val () = print ("  j = " ^ Real64.toString (solution j) ^ "\n")
   val () = print ("  k = " ^ Real64.toString (solution k) ^ "\n")
   val () = print ("  x = " ^ Real64.toString (solution x) ^ "\n")
   val () = print ("  y = " ^ Real64.toString (solution y) ^ "\n")
   val () = clear ()
end
