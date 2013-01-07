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

signature ROUTING_METRIC =
   sig
      type t
      
      type callback =
         (ID.t * Service.stub * Record.t * Word8Vector.vector) Iterator.t -> unit
      
      val new : BasicBubbleType.bubbleState * RoutingTable.t * Backend.t -> t

      val iAmResponsible : t -> Record.request -> int option
      
      val storeIterator  : t * Record.request -> (ID.t * Service.stub) Iterator.t
      val lookupIterator : t * Lookup.request -> (ID.t * Service.stub) Iterator.t
      val itemIterator   : t * callback -> ID.t * Service.stub -> unit
      val onRoundSwitch  : t * callback -> unit
   end
