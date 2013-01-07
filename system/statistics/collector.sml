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

structure Collector :> COLLECTOR =
   struct      
      datatype fields = T of {
         count : int,
         sum : Real64.real,
         squareSum : Real64.real,
         min : Real32.real,
         max : Real32.real
      }
      withtype t = fields ref
      
      val from32to64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
      val from64to32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
      
      fun changeRoundingMode operation =
(*         let
            val oldRounding = IEEEReal.getRoundingMode ()
            val () = IEEEReal.setRoundingMode IEEEReal.TO_POSINF
            fun restoreRoundingMode (mode, value) =
               ( IEEEReal.setRoundingMode mode ; value )
         in
            restoreRoundingMode (oldRounding, operation ())
         end*)
      (* [ML] ARM does not support TO_POSINF, so just ignoreing for now *)
         operation ()
         
      fun addInner (this as ref (T fields)) (value, val64) =
         this := T {
               count = #count fields + 1,
               sum = #sum fields + val64,
               squareSum = changeRoundingMode (fn () => #squareSum fields + val64 * val64),
               min = Real32.min (#min fields, value),
               max = Real32.max (#max fields, value)
         }
      fun add this value = addInner this (value, from32to64 value)
      
      fun aggregate (this as ref (T fields)) (ref (T source)) =
         this := T {
               count = #count fields + #count source,
               sum = #sum fields + #sum source,
               squareSum = changeRoundingMode (fn () => #squareSum fields + #squareSum source),
               min = Real32.min (#min fields, #min source),
               max = Real32.max (#max fields, #max source)
         }
               
      fun create () = T {
         count = 0,
         sum = 0.0,
         squareSum = 0.0,
         min = Real32.posInf,
         max = Real32.negInf
      }
      
      fun new () = ref (create ())
      fun reset this = this := create ()
         
      fun count (ref (T fields)) = #count     fields
      fun sum   (ref (T fields)) = #sum       fields
      fun sum2  (ref (T fields)) = #squareSum fields
      fun min   (ref (T fields)) = #min       fields
      fun max   (ref (T fields)) = #max       fields

      fun avg (ref (T fields)) =
         let
            val count = Real32.fromInt (#count fields)
            val sum = from64to32 (#sum fields)
         in
            case Real32.compareReal (count, 0.0) of
               IEEEReal.EQUAL => valOf (Real32.fromString "nan")
            | IEEEReal.GREATER => sum / count
            | _ => raise Fail("Could not calculate mean with negative count = " ^ (Real32.toString count))
         end 
         
      fun stdDev (ref (T fields)) =
         let
            val count = Real64.fromInt (#count fields)
            val sum = #sum fields
            val squareSum = #squareSum fields
            val sumSquared = sum * sum
            val squaresCount = squareSum * count
            val countSquared = count * (count - 1.0)
            val () =
                case Real64.compareReal (squaresCount, sumSquared) of
                   IEEEReal.LESS => raise Fail "StdDev calculation violates mathematical law!"
                 | IEEEReal.EQUAL => ()
                 | IEEEReal.GREATER => ()
                 | IEEEReal.UNORDERED => ()
         in
            (* count <= 1 =>  stddev = infinity *)
            case Real64.compareReal (count, 1.0) of
	            IEEEReal.GREATER => (from64to32 o Real64.Math.sqrt) ((squaresCount - sumSquared) / countSquared)
	          | IEEEReal.UNORDERED => valOf (Real32.fromString "nan")
             | _ => Real32.posInf
         end
    
   end
