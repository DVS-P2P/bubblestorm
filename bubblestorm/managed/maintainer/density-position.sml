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

structure Density :> DENSITY =
   struct
      datatype phase = NEW | UPDATED | STABLE

      structure Order = OrderFromCompare (
         struct
            type t = Real64.real * Real64.real * phase
            fun compare ((pos, D1, _), (pos', D1', _)) =
               Real64.compare (pos/D1, pos'/D1')
         end)
      
      open Order

      type range = t * t
      
      val getD1  = SystemStats.d1  o BasicBubbleType.stats
      val getD1' = SystemStats.d1' o BasicBubbleType.stats

      fun new (state, pos, capacity, theirD1) =
         (Real64.fromInt pos / capacity, Real64.max (theirD1, getD1 state), NEW)
            
      val minVal = (0.0, 1.0, STABLE)

      val maxVal = (1.0, 1.0, STABLE)
      
      fun bubbleSize bubble =
         let
            val state = BasicBubbleType.state bubble
            val size = Real64.fromInt (BasicBubbleType.targetSize bubble)
         in
            (size, getD1 state, NEW)
         end
                  
      fun bubbleSize' bubble =
         let
            val state = BasicBubbleType.state bubble
            val oldSize = Real64.fromInt (BasicBubbleType.oldSize bubble)
         in
            (oldSize, getD1' state, NEW)
         end

      fun bubbleSizeAfterJoin bubble =
         let
            val state = BasicBubbleType.state bubble
            val oldSize = Real64.fromInt (BasicBubbleType.oldSize bubble)
         in
            (oldSize, Real64.max (getD1 state, getD1' state), NEW)
         end
         
      fun bubbleRange bubble = (minVal, bubbleSize bubble)
                  
      fun toReal64 (pos, D1, _) = pos / D1
      
      fun fromPosition state pos = new (state, pos, 1.0, 0.0)
      
      fun toPosition state (pos, D1, _) = Real64.floor (pos * (getD1 state) / D1)
      
      fun update state (pos, D1, NEW)       = (pos, Real64.max (D1, getD1 state), UPDATED)
        | update state (pos, D1, UPDATED)   = (pos, Real64.max (D1, getD1 state), STABLE)
        | update _ (this as (_, _, STABLE)) = this

      fun phase (_, _, phase) = phase
   end
