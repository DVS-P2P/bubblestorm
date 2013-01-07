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

structure Field25519ML :> FIELD25519 =
   struct
      open IntInf
      infix 7 << ~>>
      
      type t = int
      val p = 1 << 0w255 - 19
      val mask = 1 << 0w255 - 1
      
      fun init () = ()
      val nill = 0:t
      
      fun reduce x = x
      
      fun add (x, y) = 
         let
            val z = x + y
         in
            if z >= p then z - p else z
         end
      
      fun sub (x, y) =
         if x > y then x - y else p + x - y
      
      fun mul (x, y) =
         let
            val z = x * y
            (* Now compute mod p *)
            val (high, low) = (z ~>> 0w255, andb (z, mask))
            val step1 = high * 19 + low
            (* May have had a carry *)
            val (high, low) = (step1 ~>> 0w255, andb (step1, mask))
            val step2 = high * 19 + low
         in
            (* Any remaining carry can only be one bit *)
            if step2 >= p then step2 - p else step2
         end
      
      fun sqr x = mul (x, x)
      
      fun mulC (x, c) =
         let
            val z = x * Int.toLarge c
            (* mod p *)
            val (high, low) = (z ~>> 0w255, andb (z, mask))
            val z = high * 19 + low
         in
            (* Any remaining carry can only be one bit *)
            if z >= p then z - p else z
         end

      val { toVector, fromVector, ... } =
         Serial.methods (Serial.intinfl 32)
      
      val fromVector = fn x => andb (fromVector x, mask)
      
      val powq = NONE
      val inv  = NONE
      val loop = NONE
   end
structure Curve25519ML = Curve25519(Field25519ML)

(*
open Curve25519ML
val a = 302938523905801293845209840293850928350928354129084190285019238759081275912781297865
fun loop 1000 = ()
  | loop i = (print (toString (power (generator (), i+a)) ^ " (" ^ LargeInt.toString i ^ ")\n"); loop (i+1))
  val () = loop 0
*)  
(*
local
   open Curve25519ML
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
   open Curve25519ML
in
   val b = clamp 8902375289037823089012740918240914
   fun loop (0, x) = x
     | loop (i, x) = loop (i-1, power (x, b))
   val r = loop (1000, generator ())
   val () = print (toString r ^ "\n")
end
*)
(*
local
   open Curve25519ML
in
   val A = power (generator (), clamp 8902375289037823089012740918240914)
   val B = power (generator (), clamp 190381231)
   fun loop (0, x) = x
     | loop (i, x) = loop (i-1, multiply (x, B))
   val r = loop (1000, A)
   val () = print (toString r ^ "\n")
end
*)
