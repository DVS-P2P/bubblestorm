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

structure Field25519FFI :> FIELD25519 =
   struct
      type t = Real64Vector.vector
      
      val cinit = _import "curve25519_athlon_init" public : unit -> unit;
      val cmul =
         _import "curve25519_athlon_mult" public :
            Real64Array.array * Real64Vector.vector * Real64Vector.vector -> unit;
      val csqr =
         _import "curve25519_athlon_square" public :
            Real64Array.array * Real64Vector.vector -> unit;
      val cto = 
         _import "curve25519_athlon_todouble" public : 
            Real64Array.array * Word8Vector.vector -> unit;
      val cfrom =
         _import "curve25519_athlon_fromdouble" public :
            Word8Array.array * Real64Vector.vector -> unit;
      val cloop =
         _import "curve25519_athlon_mainloop_wes" public :
            Real64Array.array * Word8Array.array -> unit;
      
      fun sadd (x, a, b) =
         let
            val sub = Unsafe.Real64Vector.sub
            val upd = Unsafe.Real64Array.update
            val () = upd (x, 0, sub (a, 0) + sub (b, 0))
            val () = upd (x, 1, sub (a, 1) + sub (b, 1))
            val () = upd (x, 2, sub (a, 2) + sub (b, 2))
            val () = upd (x, 3, sub (a, 3) + sub (b, 3))
            val () = upd (x, 4, sub (a, 4) + sub (b, 4))
            val () = upd (x, 5, sub (a, 5) + sub (b, 5))
            val () = upd (x, 6, sub (a, 6) + sub (b, 6))
            val () = upd (x, 7, sub (a, 7) + sub (b, 7))
            val () = upd (x, 8, sub (a, 8) + sub (b, 8))
            val () = upd (x, 9, sub (a, 9) + sub (b, 9))
         in
            ()
         end
      
      fun ssub (x, a, b) =
         let
            val sub = Unsafe.Real64Vector.sub
            val upd = Unsafe.Real64Array.update
            val () = upd (x, 0, sub (a, 0) - sub (b, 0))
            val () = upd (x, 1, sub (a, 1) - sub (b, 1))
            val () = upd (x, 2, sub (a, 2) - sub (b, 2))
            val () = upd (x, 3, sub (a, 3) - sub (b, 3))
            val () = upd (x, 4, sub (a, 4) - sub (b, 4))
            val () = upd (x, 5, sub (a, 5) - sub (b, 5))
            val () = upd (x, 6, sub (a, 6) - sub (b, 6))
            val () = upd (x, 7, sub (a, 7) - sub (b, 7))
            val () = upd (x, 8, sub (a, 8) - sub (b, 8))
            val () = upd (x, 9, sub (a, 9) - sub (b, 9))
         in
            ()
         end
      
      fun smulC (x, a, z) =
         let
            val sub = Unsafe.Real64Vector.sub
            val upd = Unsafe.Real64Array.update
            val () = upd (x, 0, sub (a, 0) * z)
            val () = upd (x, 1, sub (a, 1) * z)
            val () = upd (x, 2, sub (a, 2) * z)
            val () = upd (x, 3, sub (a, 3) * z)
            val () = upd (x, 4, sub (a, 4) * z)
            val () = upd (x, 5, sub (a, 5) * z)
            val () = upd (x, 6, sub (a, 6) * z)
            val () = upd (x, 7, sub (a, 7) * z)
            val () = upd (x, 8, sub (a, 8) * z)
            val () = upd (x, 9, sub (a, 9) * z)
         in
            ()
         end
      
      fun sred (r, a) =
         let
            val alpha26  = 9.28455029464035206e26
            val alpha51  = 3.11537811512089658e34
            val alpha77  = 2.09069486236224592e42
            val alpha102 = 7.01520785918833401e49
            val alpha128 = 4.70782630154001057e57
            val alpha153 = 1.57968437502835780e65
            val alpha179 = 1.06010823886703060e73
            val alpha204 = 3.55713298137035352e80
            val alpha230 = 2.38715153476697588e88
            val alpha255 = 8.00995138470341281e95
            val scale    = 3.28174405093588896e~76
            
            val sub  = Unsafe.Real64Vector.sub
            val sub' = Unsafe.Real64Array.sub
            val upd  = Unsafe.Real64Array.update
            val x = sub (a, 0)
            val y = (x + alpha26) - alpha26
            val () = upd (r, 0, x - y)
            val x = sub (a, 1) + y
            val y = (x + alpha51) - alpha51
            val () = upd (r, 1, x - y)
            val x = sub (a, 2) + y
            val y = (x + alpha77) - alpha77
            val () = upd (r, 2, x - y)
            val x = sub (a, 3) + y
            val y = (x + alpha102) - alpha102
            val () = upd (r, 3, x - y)
            val x = sub (a, 4) + y
            val y = (x + alpha128) - alpha128
            val () = upd (r, 4, x - y)
            val x = sub (a, 5) + y
            val y = (x + alpha153) - alpha153
            val () = upd (r, 5, x - y)
            val x = sub (a, 6) + y
            val y = (x + alpha179) - alpha179
            val () = upd (r, 6, x - y)
            val x = sub (a, 7) + y
            val y = (x + alpha204) - alpha204
            val () = upd (r, 7, x - y)
            val x = sub (a, 8) + y
            val y = (x + alpha230) - alpha230
            val () = upd (r, 8, x - y)
            val x = sub (a, 9) + y
            val y = (x + alpha255) - alpha255
            val () = upd (r, 9, x - y)
            val y = y * scale
            val x = sub' (r, 0) + y
            val y = (x + alpha26) - alpha26
            val () = upd (r, 0, x - y)
            val () = upd (r, 1, sub' (r, 1) + y)
         in
            ()
         end
      
      fun wrap f = MakeVector.real64 (10, f)
      
      fun add  (a, b) = wrap (fn x => sadd  (x, a, b))
      fun sub  (a, b) = wrap (fn x => ssub  (x, a, b))
      fun mul  (a, b) = wrap (fn x => cmul  (x, a, b))
      fun mulC (a, z) = wrap (fn x => smulC (x, a, Real64.fromInt z))
      fun sqr    a = wrap (fn x => csqr (x, a))
      fun reduce a = wrap (fn x => sred (x, a))
      fun fromVector v = wrap (fn x => cto (x, v))
      fun toVector x = MakeVector.word8 (32, fn a => cfrom (a, x))
      
      val nill = Real64Vector.tabulate (0, fn _ => 0.0)
      fun init () = cinit ()
      
      fun loop (x, v, _) =
         let
            val a = Real64Array.array (40, 0.0)
            fun upd (i, x) = Real64Array.update (a, i, x)
            val () = Real64Vector.appi upd x
            
            val b = Word8Array.array (32, 0w0)
            fun upd (i, x) = Word8Array.update (b, i, x)
            val () = Word8Vector.appi upd v
            
            val () = cloop (a, b)
            
            open Real64ArraySlice
            val Rx  = slice (a,  0, SOME 10)
            val Rz  = slice (a, 10, SOME 10)
            val RBx = slice (a, 20, SOME 10)
            val RBz = slice (a, 30, SOME 10)
         in
            ((vector Rx, vector Rz), (vector RBx, vector RBz))
         end
      
      val powq = NONE
      val inv  = NONE
      val loop = SOME loop
   end
structure Curve25519FFI = Curve25519(Field25519FFI)

(*
open Curve25519FFI
val a = 302938523905801293845209840293850928350928354129084190285019238759081275912781297865
fun loop 1000 = ()
  | loop i = (print (toString (power (generator (), i+a)) ^ " (" ^ LargeInt.toString i ^ ")\n"); loop (i+1))
  val () = loop 0
*)
(*
local
   open Curve25519FFI
in
   val a = 302938523905801293845209840293850928350928354129084190285019238759081275912781297865
   val b = clamp 8902375289037823089012740918240914
   val A = power (generator (), a)
   val B = power (generator (), b)
   val AB1 = power (A, b)
   val AB2 = power (B, a)
   val AB = multiply (A, B)
   val () = print (toString A ^ "\n")
   val () = print (toString B ^ "\n")
   val () = print (toString AB1 ^ "\n")
   val () = print (toString AB2 ^ "\n")
   val () = print (toString AB ^ "\n")
   val () = print "\n"
   
   val () = print (toString (power (B, 1)) ^ "\n")
   val () = print (toString (power (B, 2)) ^ "\n")
   val () = print (toString (power (B, 3)) ^ "\n")
   val () = print (toString (power (B, 4)) ^ "\n")
   val () = print (toString (power (B, 5)) ^ "\n")
   val () = print (toString (power (B, 6)) ^ "\n")
   val () = print (toString (power (B, 7)) ^ "\n")
   val () = print (toString (power (B, 8)) ^ "\n")
   val () = print "\n"
end
*)
(*
local
   open Curve25519FFI
in
   val b = clamp 8902375289037823089012740918240914
   fun loop (0, x) = x
     | loop (i, x) = loop (i-1, power (x, b))
   val r = loop (10000, generator ())
   val () = print (toString r ^ "\n")
end
*)
(*
local
   open Curve25519FFI
in
   val A = power (generator (), clamp 8902375289037823089012740918240914)
   val B = power (generator (), clamp 190381231)
   fun loop (0, x) = x
     | loop (i, x) = loop (i-1, multiply (x, B))
   val r = loop (100000, A)
   val () = print (toString r ^ "\n")
end
*)
