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

signature DENSITY =
   sig
      include ORDER
      
      datatype phase = NEW | UPDATED | STABLE
      
      type range = t * t

      (* make a new density position with a network capacity D1, a node capacity,
         and a bubble position pos *)
      val new : BasicBubbleType.bubbleState * int * Real64.real * Real64.real -> t

      (* density of 0.0 *)
      val minVal : t
      
      (* density of 1.0 *)
      val maxVal : t
      
      (* get the density position of a bubble size using the *current*
         measurement round *)
      val bubbleSize : BasicBubbleType.t -> t
      
      (* get the density position of a bubble size using the *previous*
         measurement round *)
      val bubbleSize' : BasicBubbleType.t -> t

      (* get the density position of a bubble size using the old size and the
         current D1 *)
      val bubbleSizeAfterJoin : BasicBubbleType.t -> t

      (* returns (minDensity, bubbleSize) *)
      val bubbleRange : BasicBubbleType.t -> range
      
      (* gives the fixed density position = pos/D1 *)
      val toReal64 : t -> Real64.real
      
      val fromPosition : BasicBubbleType.bubbleState -> int -> t
      
      (* returns the actual bubble position = pos * D1_now / D1_orig
         needs the bubble state to retrieve the current network capacity D1_now. *)
      val toPosition : BasicBubbleType.bubbleState -> t -> int

      (* update a density with bigger D1 on a round switch. will update phases:
         NEW -> UPDATED, UPDATED -> STABLE, STABLE remains unchanged *)
      val update : BasicBubbleType.bubbleState -> t -> t
      
      val phase : t -> phase
   end
