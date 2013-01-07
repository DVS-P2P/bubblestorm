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

structure Field25519FFI : FIELD25519 =
   struct
      type t = Word64Vector.vector
      
      val cadd =
         _import "field25519_wes_add" public :
            Word64Array.array * Word64Vector.vector * Word64Vector.vector -> unit;
      val csub =
         _import "field25519_wes_sub" public :
            Word64Array.array * Word64Vector.vector * Word64Vector.vector -> unit;
      val cmul =
         _import "field25519_wes_mul" public :
            Word64Array.array * Word64Vector.vector * Word64Vector.vector -> unit;
      val csqr =
         _import "field25519_wes_sqr" public :
            Word64Array.array * Word64Vector.vector -> unit;
      val cinv =
         _import "field25519_wes_inv" public :
            Word64Array.array * Word64Vector.vector -> unit;
      val cpowq =
         _import "field25519_wes_powq" public :
            Word64Array.array * Word64Vector.vector -> unit;
      val cmulC =
         _import "field25519_wes_mulC" public :
            Word64Array.array * Word64Vector.vector * Word64.word -> unit;
      val cexpand = 
         _import "field25519_wes_expand" public : 
            Word64Array.array * Word8Vector.vector -> unit;
      val ccontract =
         _import "field25519_wes_contract" public :
            Word8Array.array * Word64Vector.vector -> unit;
      val cloop =
         _import "curve25519_wes_loop" public :
            Word64Array.array * Word8Vector.vector * int -> unit;
      
      fun wrap f = MakeVector.word64 (5, f)
      
      fun add  (a, b) = wrap (fn x => cadd  (x, a, b))
      fun sub  (a, b) = wrap (fn x => csub  (x, a, b))
      fun mul  (a, b) = wrap (fn x => cmul  (x, a, b))
      fun mulC (a, w) = wrap (fn x => cmulC (x, a, Word64.fromInt w))
      fun inv  a = wrap (fn x => cinv  (x, a))
      fun powq a = wrap (fn x => cpowq (x, a))
      fun sqr  a = wrap (fn x => csqr  (x, a))
      fun reduce x = x
      
(*
      fun dump l v =
         let
            fun w i = WordToString.from64 (Word64Vector.sub (v, i))
         in
            print (concat [ l, ": ", w 0, " ", w 1, " ", w 2, " ", w 3, " ", w 4, "\n" ])
         end
*)
      
      fun fromVector v = wrap (fn x => cexpand (x, v))
      fun toVector x = MakeVector.word8 (32, fn a => ccontract (a, x))
      
      val nill = Word64Vector.tabulate (0, fn _ => 0w0)
      fun init () = ()
      
      fun loop (x, e, l) =
         let
            val a = Word64Array.array (40, 0w0)
            fun upd (i, x) = Word64Array.update (a, i, x)
            val () = Word64Vector.appi upd x
            val () = cloop (a, e, (l + 7) div 8)
            
            open Word64ArraySlice
            val Rx  = slice (a,  0, SOME 5)
            val Rz  = slice (a,  5, SOME 5)
            val RBx = slice (a, 10, SOME 5)
            val RBz = slice (a, 15, SOME 5)
         in
            ((vector Rx, vector Rz), (vector RBx, vector RBz))
         end
      
      val powq = SOME powq
      val inv  = SOME inv
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
