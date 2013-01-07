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

signature NODE_GROUP =
   sig
      type t

      (* all node groups defined in the current experiment. *)
      val getAll : unit -> t vector

      (* *)
      val definition : t -> NodeDefinition.t

      (* the total number of nodes in the group, no matter what there state is. 
       * a node can be in the following states: 
       * - inactive & offline, inactive & online, active & offline:
       * - active & online: *)
      val totalNodes : t -> int
      (* the number of nodes in the group that are set active,
       * and thus are able to run an application (if online, too). *)
      val activeNodes : t -> int
      (* the number of nodes in the group that are set online by their 
       * session-intersession churn model. If they are also active, they are 
       * running. *)
      (*val onlineNodes : t -> int*)
      (* the number of nodes in the group that are both online and active.
       * These nodes are actually running the application and are connected 
       * to the network. *)
      (*val runningNodes : t -> int*)
      
      (* the nodes in a group. *)
      val nodes : t -> SimulatorNode.t array

      datatype activeSetChange = 
         ADD of SimulatorNode.t ArraySlice.slice
       | REMOVE of SimulatorNode.t ArraySlice.slice
       | NOCHANGE
       
      val setActiveNodes : t * int -> activeSetChange

      (* returns an iterator over all nodes in this group that are currently
         alive (i.e. active and online). Alive nodes are all nodes that have 
         not yet received a SIG_INT signal. *)
      val getAliveNodes : t -> SimulatorNode.t Iterator.t      
(*       val wellKnownHosts : unit -> Address.t list *)
      
      (* returns whether the given address belongs to a node with a static address *)
      val isStaticAddress : Address.Ip.t -> bool
      
      val init : (int * int option * bool * bool) -> unit
   end
