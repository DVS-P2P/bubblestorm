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

structure SimulatorStatisticsHelper :> STATISTICS_HELPER =
   struct
      fun currentNode () =
         (SOME (SimulatorNode.current ()))
         handle At (_, SimulatorNode.OutsideNodeContext) => NONE
         
      fun nodeID () =
         case currentNode () of
            SOME node => SimulatorNode.id node
          | NONE => ~1
   
      fun setNodeContext collect =
         case currentNode () of
            SOME node => (fn () => SimulatorNode.setCurrent (node, collect))
          | NONE => collect
      
      fun setCleanup action =
         case currentNode () of         
            NONE => ()
          | SOME node =>
               let
                  val ring = SimulatorNode.cleanupFunctions node
                  val elem = Ring.wrap action    
               in
                  Ring.add (ring, elem)
               end
   end