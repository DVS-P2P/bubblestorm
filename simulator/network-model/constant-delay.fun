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

functor ConstantDelay(Base : NETWORK_MODEL) :> NETWORK_MODEL =
   struct
      open Time

      val delay = ConnectionProperties.lastHopDelay o
                  NodeDefinition.connection o
                  SimulatorNode.definition

      fun route (x, y) =
         let
            val sourceDelay = delay x
            val destDelay   = delay y
            val myDelay = Time.+ (sourceDelay, destDelay)
            fun addDelay (delay, bitErrors) = (delay + myDelay, bitErrors)
         in
            (* add last hop delay from source and destination to all messages *)
            List.map addDelay (Base.route (x, y))
         end
   end

structure NetworkModel = ConstantDelay(NetworkModel)
