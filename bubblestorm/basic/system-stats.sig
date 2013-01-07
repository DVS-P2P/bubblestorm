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

signature SYSTEM_STATS =
   sig
      datatype status = JOINING | ONLINE | LEAVING | OFFLINE

      type t
      
      val new : Topology.t * Measurement.t * NodeAttributes.t -> t
      (* sets the connection status of the node *)
      val setStatus : t * status -> unit
      (* the connection status of the node *)
      val status : t -> status
      (* the most recently completed measurement round *)
      val round : t -> Word32.word
      (* the desired number of neighbors *)
      val degree : t -> Real32.real
      (* the number of nodes in the network *)
      val d0 : t -> Real64.real
      (* the number of nodes in the network in the previous measurement round *)
      val d0' : t -> Real64.real
      (* the sum of all degrees in the network (twice the number of links) *)
      val d1 : t -> Real64.real
      (* the sum of all degrees in the previous measurement round *)
      val d1' : t -> Real64.real
      (* the sum of the squared degrees in the network *)
      val d2 : t -> Real64.real
      (* the minimum degree in the network *)
      (*val dMin : t -> Real64.real*)
      (* the maximum degree in the network *)
      val dMax : t -> Real64.real
      (* calculates the relative degree of this node *)
      (*val relativeDegree : t -> Real32.real*)
      (* compensate for the effect of interdependent edges in the topology, 
         if two matching bubble types both use the topology *)
      val dependencyCompensator : t -> Real64.real
      (* dependency compensator from the previous measurement round *)
      val dependencyCompensator' : t -> Real64.real
   end
