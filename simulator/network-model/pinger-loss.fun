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

(* Message loss model based on Sebastian Kaune et al "Modelling the Internet Delay
 * Space Based on Geographical Locations" (PDP 2009)
 *)
functor PingERLoss(Base : NETWORK_MODEL) :> NETWORK_MODEL =
   struct
      fun route (x, y) =
         let
            val random = SimulatorNode.random x
            val sourceArea = Location.area (SimulatorNode.location x)
            val destArea = Location.area (SimulatorNode.location y)
            fun keepMsg _ = Bool.not (Location.Area.loss (random, sourceArea, destArea))
         in
            List.filter keepMsg (Base.route (x, y))
         end
   end

structure NetworkModel = PingERLoss(NetworkModel)
