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

functor WordCut(Word : WORD) =
   struct
      fun mask x =
         let
            val x = if Word.wordSize >  1 then Word.orb (x, Word.>> (x, 0w01)) else x
            val x = if Word.wordSize >  2 then Word.orb (x, Word.>> (x, 0w02)) else x
            val x = if Word.wordSize >  4 then Word.orb (x, Word.>> (x, 0w04)) else x
            val x = if Word.wordSize >  8 then Word.orb (x, Word.>> (x, 0w08)) else x
            val x = if Word.wordSize > 16 then Word.orb (x, Word.>> (x, 0w16)) else x
            val x = if Word.wordSize > 32 then Word.orb (x, Word.>> (x, 0w32)) else x
            val x = if Word.wordSize > 64 then Word.orb (x, Word.>> (x, 0w64)) else x
         in
            x
         end
      
      fun pick f (t, NONE) = f t
        | pick f (t, SOME x) = 
              let
                 val mask = mask x
                 fun loop () = 
                    let
                       val r = Word.andb (f t, mask)
                    in
                       if Word.< (r, x) then r else loop ()
                    end  
              in
                 loop ()
              end 
   end
   
functor Random(Base : RANDOM_BASE) :> RANDOM =
   struct
      open Base

      val word32 = rand
      val word16 = Word16.fromLarge o Word32.toLarge o rand 
      val word8  = Word8.fromLarge o Word32.toLarge o rand
      
      val word64 = Word64.fromLarge o Word32.toLarge o rand
      val word64 = fn t => Word64.orb (Word64.<< (word64 t, 0w32), word64 t)
      
      val word = 
         case Word.wordSize of
            8 => Word.fromLarge  o Word32.toLarge o rand
          | 16 => Word.fromLarge o Word32.toLarge o rand
          | 32 => Word.fromLarge o Word32.toLarge o rand
          | 64 => Word.fromLarge o Word64.toLarge o word64
          | _ => raise Fail "Unsupported word size"
      
      structure Cut = WordCut(Word)
      val word = Cut.pick word
      structure Cut8 = WordCut(Word8)
      val word8 = Cut8.pick word8
      structure Cut16 = WordCut(Word16)
      val word16 = Cut16.pick word16
      structure Cut32 = WordCut(Word32)
      val word32 = Cut32.pick word32
      structure Cut64 = WordCut(Word64)
      val word64 = Cut64.pick word64
                              
      exception NonPositiveBound
      
      (* I hate the basis library's CRAP(!!) conversions *)
      fun int64 (t, x) = 
         if x <= 0 then raise NonPositiveBound else 
         Int64.fromLarge (Word64.toLargeInt (word64 (t, SOME (Word64.fromLargeInt (Int64.toLarge x)))))
       
      (* Below this point I make use of the non-portable knowledge that Int.precision >= 32 *)
      fun int32 (t, x) = 
         if x <= 0 then raise NonPositiveBound else 
         Int32.fromInt (Word32.toInt (word32 (t, SOME (Word32.fromInt (Int32.toInt x)))))
      fun int16 (t, x) = 
         if x <= 0 then raise NonPositiveBound else 
         Int16.fromInt (Word16.toInt (word16 (t, SOME (Word16.fromInt (Int16.toInt x)))))
      fun int8 (t, x) = 
         if x <= 0 then raise NonPositiveBound else 
         Int8.fromInt (Word8.toInt (word8 (t, SOME (Word8.fromInt (Int8.toInt x)))))
      
      fun int (t, x) = 
         case Int.precision of
            (SOME  8)  => Int8.toInt  (int8  (t, Int8.fromInt x))
          | (SOME 16) => Int16.toInt (int16 (t, Int16.fromInt x))
          | (SOME 32) => Int32.toInt (int32 (t, Int32.fromInt x))
          | (SOME 64) => Int64.toInt (int64 (t, Int64.fromInt x))
          | _ => raise Fail "Unsupported int size"
            
      fun bool t =
         if Word32.andb (rand t, 0w1) <> 0w0 then true else false
      
      fun real32 t =
         let
            val w = Word32.>> (rand t, 0w2)
            val i = Word32.toInt w
         in
            Real32.fromInt i * (1.0/1073741824.0)
         end
         
      fun real64 t = 
         let
            val a = Word32.toInt (Word32.>> (rand t, 0w5))
            val b = Word32.toInt (Word32.>> (rand t, 0w6))
         in
            (Real64.fromInt a * 67108864.0 + Real64.fromInt b) * (1.0/9007199254740992.0)
         end
      
      val real =
         case Real.precision of
            24 => Real.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge o real32
          | 53 => Real.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge o real64
          | _ => raise Fail "Unsupported real size"
      
      fun normal t =
         let
            open Real
            fun box x = x * 2.0 - 1.0
            val (x, y) = (real t, real t)
            val (x, y) = (box x, box y)
            val r = x*x + y*y
         in
            if Real.== (r, 0.0) orelse r > 1.0 then normal t else
            x * Math.sqrt (~2.0 * Math.ln r / r)
            (* y * Real.Math.sqrt ... is also a normal variable indep of this one 
             * We could cache the value for a speed-up if needed.
             *)
         end
      
      fun exponential t = ~ (Real.Math.ln (real t))      
   end
