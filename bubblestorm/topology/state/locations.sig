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

signature LOCATIONS =
   sig
      type t
      
      datatype minDegree    = LOW | ENOUGH | TOO_MUCH
      datatype maxDegree    = ZERO | NEED_MORE | SATISFIED

      val state : t -> minDegree * maxDegree
      val desiredDegree : t -> int
      val actualDegree : t -> int
      val activeLocations : t -> int
      (* ONLY EVER to be used by create! *)
      val setActiveLocations : t * int -> unit
      val totalLocations : t -> int
      
      val sub : t * int -> Location.t
      
      val activeIterator : t -> Location.t Iterator.t
      val randomActiveIterator : t * Word64.word -> Location.t Iterator.t
      val activeIndexes : t -> int Iterator.t
      
      val totalNeighbours : t -> Neighbour.t Iterator.t
      val randomTotalNeighbours : t * Conversation.t option * Word64.word -> Neighbour.t Iterator.t
      val randomSplitTotalNeighbours : t * Conversation.t option * Word64.word -> Neighbour.t Iterator.t * Neighbour.t Iterator.t
      
      (* NONE only if no neighbours *)
      val localAddress : t -> CUSP.Address.t option
      
      datatype progress =
           IN_PROGRESS of unit -> unit
         | COMPLETE of unit -> unit 
      datatype goal = JOIN of progress | LEAVE of progress
      (* associated callbacks are 
         JOIN  (IN_PROGRESS x) callback for join completion
         JOIN  (COMPLETE x)    unhook bootstrap service
         LEAVE (IN_PROGRESS x) callback for leave completion
         LEAVE (COMPLETE x)    not used yet
       *)
      val goal : t -> goal
      val setGoal : t * goal -> unit
      val leaving : t -> bool
       
      val increaseDegree : t -> unit
      val decreaseDegree : t -> unit

      val new : { desiredDegree : int,
                  eval1 : Location.t -> unit,
                  evalN : unit -> unit } -> t
   end
