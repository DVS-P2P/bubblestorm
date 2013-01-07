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

structure Exp1 =
   struct
      (* Compute exp(x)-1. 
       * The goal is to avoid cancelation errors for small x.
       *)
      fun f x = 
         let
            open Real64
            open Math
            
            (* Facts for f(x) = exp(x)-1
             * f(2*x) = exp(2*x) - 1 = (exp(x) - 1) * (exp(x) + 1) 
             *        = f(x) * (f(x) + 2)
             * f(x) = x/1 + x*x/1*2 + x*x*x/1*2*3 + ...
             * 
             * Plan:
             *   To evaluate f(x) for x < epsilon, use taylor series
             *   Find a k>=0 such that x/2^k < epsilon 
             *   For general f(x), shrink it to f(x/2^k) and then expand using:
             *     f(2*x) = f(x) * (f(x) + 2)
             *
             * Cut-off series at x^6/6!... relative error at most x^5/(6!*(1-x))
             * This crosses 2**-54 at x ~= 1/470, so epsilon = 1.0/512 works.
             *)
            val epsilon = 1.0/512.0
            
            val (k, powk) =
               if abs x < epsilon then (0, 1.0) else 
               case toManExp ((x/epsilon)*2.0) of { man=_, exp } =>
               (exp, fromManExp { man=1.0, exp=exp })
            
            (* Normalize x to be in (-epsilon, epsilon) *)
            val x = x / powk
            val out = x + x*(x + x*(x + x*(x + x*(x)/5.0)/4.0)/3.0)/2.0
            
            fun loop (0, out) = out
              | loop (i, out) = loop (Int.- (i,1), out * (2.0 + out))
         in
            if Int.<= (k, 19) then loop (k, out) else
            if x > 0.0 then posInf else ~1.0
         end
   end

(*
val e = Exp1.f 1.0
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f 1.0e~10
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f 1.0e~40
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f 310.0
val () = TextIO.print (Real64.toString e ^ "\n")

val e = Exp1.f ~1.0
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f ~1.0e~10
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f ~1.0e~40
val () = TextIO.print (Real64.toString e ^ "\n")
val e = Exp1.f ~310.0
val () = TextIO.print (Real64.toString e ^ "\n")
*)
