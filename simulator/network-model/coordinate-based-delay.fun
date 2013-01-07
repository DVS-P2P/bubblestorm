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

(* Delay model based on Sebastian Kaune et al "Modelling the Internet Delay
 * Space Based on Geographical Locations" (PDP 2009)
 *)
functor CoordinateBasedDelay(Base : NETWORK_MODEL) :> NETWORK_MODEL =
   struct

      fun route (x, y) =
         let
            val sourceX = Location.virtualX (SimulatorNode.location x)
            val sourceY = Location.virtualY (SimulatorNode.location x)
            val destX = Location.virtualX (SimulatorNode.location y)
            val destY = Location.virtualY (SimulatorNode.location y)

            fun pow2 (x, y) = (* speeds up things compared to Math.pow (x - y, 2.0) *)
                let
                    val a = (x - y)
                in
                    a * a
                end

            val distance = Real32.Math.sqrt (pow2 (sourceX, destX) + pow2 (sourceY, destY))
            val minRTT = Time.fromSecondsReal32 (distance / 1000.0)

            (*val random = SimulatorNode.random x
            val sourceArea = Location.area (SimulatorNode.location x)
            val destArea = Location.area (SimulatorNode.location y)
            val jitter = Location.Area.jitter (random, sourceArea, destArea)*)
            val jitter = Time.zero

            open Time
            val myDelay = divInt (minRTT + jitter, 2)
            fun addDelay (delay, bitErrors) = (delay + myDelay, bitErrors)
         in
            (* add delay to all messages *)
            List.map addDelay (Base.route (x, y))
         end
   end

structure NetworkModel = CoordinateBasedDelay(NetworkModel)
