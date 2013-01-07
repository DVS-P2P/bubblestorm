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

structure BubbleCostMeasurement :> BUBBLE_COST_MEASUREMENT =
   struct
      datatype t = T of {
         decode    : Measurement.result -> Measurement.Real.real,
         localCost : Measurement.Real.real ref,
         costStat  : Statistics.t option ref         
      }
      
      fun new measurement =
         let
            val localCost = ref 0.0
            fun pull () =
               let
                  val out = !localCost
                  val () = localCost := Config.balanceRetention * out
               in
                  out
               end
            val decode = Measurement.addSum (measurement, { pull=pull, stat=NONE })            
         in
            T {
               decode = decode,
               localCost = localCost,
               costStat = ref NONE
            }
         end
      
      val toReal64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge

      fun get (T { decode, ... }, measurement) = (toReal64 o decode) measurement
      
      fun inject (T { localCost, costStat, ... }, cost) =
         let
            val () = case !costStat of
                  SOME stat => Statistics.add stat cost
                | NONE => ()
         in
            localCost := !localCost + cost
         end

      fun injectCostFraction (this, data, fraction) =
         inject (this, fraction * Real32.fromInt (Word8Vector.length data))

      fun injectCost (this, data) = injectCostFraction (this, data, 1.0)
      
      fun setStatistic (T { costStat, ... }, stat) = costStat := stat
   end
