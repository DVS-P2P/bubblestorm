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

signature FIELD25519 =
   sig
      type t
      
      val nill : t
      val init : unit -> unit
      
      val add  : t * t -> t
      val sub  : t * t -> t
      val mulC : t * int -> t
      
      (* The result of a sequence of +,-,mulC must be reduced *)
      val reduce : t -> t
      
      (* These operations include a reduce 
       * input must come from no more than 2 terms +/-d together
       *)
      val mul : t * t -> t
      val sqr : t -> t
      
      val toVector : t -> Word8Vector.vector
      val fromVector : Word8Vector.vector -> t
      
      (* Optionally accelerated methods *)
      val powq : (t -> t) option
      val inv  : (t -> t) option
      val loop : (t * Word8Vector.vector * int -> (t * t) * (t * t)) option
   end

functor Curve25519(Field : FIELD25519) :> CYCLIC_GROUP =
   struct
      open Field
      
      val length = 32
      val { toVector=toVectorInt, ... } = 
         Serial.methods (Serial.intinfl length)
      val fromInt = fromVector o toVectorInt
      
      val vZero = toVectorInt 0
      val vHalf = toVectorInt (IntInf.<< (1, 0w254) - 10)
      
      val fZero = ref nill
      val fOne  = ref nill
      val fU    = ref nill
      val fP    = ref nill
      val fA    = ref nill
      val fGen  = ref { x=nill, y=nill }
      val A     = 486662
      
      val op * = mul
      val op + = add
      val op - = sub
      
      (* These are slow, but not in the critical path *)
      fun isEq (x, y) = toVector x = toVector y
      fun isZero x = toVector x = vZero
      
      fun isNegative x =
         let
            val v = toVector x
            
            fun get (_, ~1) = Iterator.EOF
              | get (v, i) = Iterator.VALUE (Word8Vector.sub (v, i),
                                             fn () => get (v, Int.- (i, 1)))
            fun from v = get (v, 31)
         in
            Iterator.collate Word8.compare (from v, from vHalf) = GREATER
         end
      
      local
         fun powtrick z =
            let
               fun sqri 0 z = z
                 | sqri i z = sqri (Int.- (i,1)) (sqr z)
               
               val z2 = sqr z
               val z9 = sqr (sqr z2) * z
               val z11 = z9 * z2
               val z2_5_0 = sqr z11 * z9
               val z2_10_0 = sqri 5 z2_5_0 * z2_5_0
               val z2_20_0 = sqri 10 z2_10_0 * z2_10_0
               val z2_40_0 = sqri 20 z2_20_0 * z2_20_0
               val z2_50_0 = sqri 10 z2_40_0 * z2_10_0
               val z2_100_0 = sqri 50 z2_50_0 * z2_50_0
               val z2_200_0 = sqri 100 z2_100_0 * z2_100_0
               val z2_250_0 = sqri 50 z2_200_0 * z2_50_0
            in
               (z2_250_0, z11)
            end
         
         fun powq z = (* power 2^252 - 3 *)
            let
               val (z2_250_0, _) = powtrick z
            in
               sqr (sqr z2_250_0) * z
            end

         val powq = 
            case Field.powq of
               SOME f => f
             | NONE => powq
      in            
         fun inv z = (* power 2^255 - 21 *)
            let
               val (z2_250_0, z11) = powtrick z
               val z2_255_5 = (sqr o sqr o sqr o sqr o sqr) z2_250_0
            in
               z2_255_5 * z11
            end
         
         val inv = 
            case Field.inv of
               SOME f => f
             | NONE => inv
          
         (* s = pow (2, (p-1) div 4) = pow (2, 2^253-5) *)
         (* U = (s-1)/2 *)
         fun s two = sqr (powq two) * two
         fun U two = (s two - !fOne) * inv two
         
         fun sqrt z = 
            let
               val b = powq z
               val b' = b * z
               (* if isOne (z * sqr b) then b' else s * b' *)
               val test = z * sqr b (* +/- 1 *)
            in
               b' * (!fOne + !fU - test * !fU)
            end
      end
   
      fun store { x, y } =
         let
            val v = toVector x
            fun flip (31, w) = Word8.orb (0wx80, w)
              | flip (_,  w) = w
(*
            val () = print "Stored: { x="
            val () = print (WordToString.fromBytes (Field.toVector x))
            val () = print ", y="
            val () = print (WordToString.fromBytes (Field.toVector y))
            val () = print "}\n"
*)
         in
            if isNegative y then Word8Vector.mapi flip v else v
         end
      
      fun load v =
         let
            val positive = Word8.andb (0wx80, Word8Vector.sub (v, 31)) = 0w0
            val x = fromVector v
            val x2 = sqr x
            val y2 = x2 * x + mulC (x2, A) + x
            val y = sqrt (reduce y2)
            val y = if isNegative y = positive then reduce (!fP - y) else y
(*
            val () = print "Loaded: { x="
            val () = print (WordToString.fromBytes (Field.toVector x))
            val () = print ", y="
            val () = print (WordToString.fromBytes (Field.toVector y))
            val () = print "}\n"
*)
         in
            { x = x, y = y }
         end
         
      val initd = ref false
      fun initSelf () =
         if !initd then () else
         let
            val two = fromInt 2
            val () = fZero := fromInt 0
            val () = fOne  := fromInt 1
            val () = fU    := U two
            val () = fP    := fromInt (IntInf.- (IntInf.<< (1, 0w255), 19))
            val () = fA    := fromInt 486662
            val () = fGen  := load (toVectorInt 9)
         in
            initd := true
         end
	  
	  (* Field.init must be run before any FFI calls. It sets CPU state up (rounding mode). *)
	  fun init () = (Field.init (); initSelf ())
      
      type t = { x : t, y : t }
      val t = Serial.map {
         store = store,
         load = fn v => (init (); load v),
         extra = fn () => ()
      } (Serial.vector (Serial.word8, length))
      
      val { toVector, ... } = Serial.methods t
      fun hash x = Hash.word8vector (toVector x)
      val toString = WordToString.fromBytes o toVector
      fun compare (x, y) =
         Word8Vector.collate Word8.compare (toVector x, toVector y)
      
      exception BadElement
      fun generator () = (init (); !fGen)
      
      fun multiply ({ x=Mx, y=My }, { x=Nx, y=Ny }) =
         (init ();
         if isEq (Mx, Nx) orelse isZero Mx orelse isZero Nx then
            (* The odds of this are so low that if it does happen, 
             * it's almost surely some sort of attack. Reject the input.
             *)
            raise BadElement 
         else
            let
               val l = (My - Ny) * inv (Mx - Nx)
               val Rx = reduce (sqr l - !fA - Mx - Nx)
               val Ry = reduce (l * (Mx - Rx) - My)
(*
               val () = print "Product: { x="
               val () = print (WordToString.fromBytes (Field.toVector Rx))
               val () = print ", y="
               val () = print (WordToString.fromBytes (Field.toVector Ry))
               val () = print "}\n"
*)
            in
               { x = Rx, y = Ry }
            end)
      
      local
         val A4 = Int.- (A, 2) div 4
        
         fun dbl (x, z) =
            let
               val m = sqr (x + z)
               val n = sqr (x - z)
               val k = m - n
            in
               (n * m, reduce (mulC (k, A4) + m) * k)
            end
        
         fun sum ((Rx, Rz), (RBx, RBz), Bx) =
            let
               val p = (Rx - Rz) * (RBx + RBz)
               val q = (Rx + Rz) * (RBx - RBz)
            in
               (sqr (p + q), sqr (p - q) * Bx)
            end
        
         fun findRy (Rx, RBx, Bx, By) =
            let
               (* (Ry - By)^2 = (Rx - Bx)^2 * (RBx + a + Rx + Bx) = c
                   Ry^2 = Rx^3 + a*Rx^2 + Rx
                   Ry = (2*By)^-1 * (Ry^2 + By^2 - c)
                *)
               val c = sqr (Rx - Bx) * reduce (RBx + !fA + Rx + Bx)
               val Rx2 = sqr Rx
               val Ry2 = Rx2 * Rx + mulC (Rx2, A) + Rx
               val By2 = sqr By
               val By1 = inv (By+By)
            in
               By1 * reduce (Ry2 + By2 - c)
            end
        
         fun isBitSet (v, i) =
            let
               val i = Word.fromInt i
               val iv = Word.>> (i, 0w3)
               val is = Word.andb (i, 0w7)
               val w = Word8Vector.sub (v, Word.toInt iv)
               open Word8
            in
               andb (0w1, >> (w, is)) <> 0w0
            end
            handle Subscript => false
        
         fun rawPower (Bx, By, v, i) =
           let
              val () = init ()
			  
              fun loop (R, RB, 0) = (R, RB)
                | loop (R, RB, i) = 
                 let
                    val i = Int.- (i, 1)
                    val S = sum (R, RB, Bx)
                 in
                    if isBitSet (v, i)
                    then loop (S, dbl RB, i)
                    else loop (dbl R, S,  i)
                 end
              
              val ((Rx, Rz), (RBx, RBz)) =
                 case Field.loop of
                    NONE =>
                       loop ((!fOne, !fZero), (Bx, !fOne), i)
                  | SOME f =>
                       f (Bx, v, i)
            
              val (Rx, RBx) = (Rx * inv Rz, RBx * inv RBz)
              val Ry = findRy (Rx, RBx, Bx, By)

(*
            val () = print "Power:  { x="
            val () = print (WordToString.fromBytes (Field.toVector Bx))
            val () = print ", y="
            val () = print (WordToString.fromBytes (Field.toVector By))
            val () = print "} = { x="
            val () = print (WordToString.fromBytes (Field.toVector Rx))
            val () = print ", y="
            val () = print (WordToString.fromBytes (Field.toVector Ry))
            val () = print "}\n"
*)
           in
              { x = Rx, y = Ry }
           end
        
         val { toVector, ... } = Serial.methods (Serial.intinfl 32)
         val order = 57896044618658097711785492504343953926856930875039260848015607506283634007912
      in
         fun power ({ x=Bx, y=By }, e) =
            let
               val e = if e > order then e mod order else e
               (* log2 gives the index of the first bit set.
                * That means we need to process log2 + 1 total bits.
                *)
               val bits = Int.+ (1, IntInf.log2 e)
            in
               rawPower (Bx, By, toVector e, bits)
            end
         
         fun fixedPower ({ x=Bx, y=By }, e, bits) =
            let
               val (bits, e) = 
                  if bits > 256
                  then (255, e mod order)
                  else (256, e)
            in
               rawPower (Bx, By, toVector e, bits)
            end
      end
      
      local
         open IntInf
         val mask = xorb (<< (1, 0w255) - 1, 7) (* 252 ones, 3 zeros *)
      in
         fun clamp x = orb (andb (mask, x), << (1, 0w254))
      end

      structure Z = OrderFromCompare(type t = t val compare = compare)
      open Z
   end
