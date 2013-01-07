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

signature NODE_DEFINITION =
   sig
      type t

      (* the ID of the group the node is in. *)
      val id : t -> int

      (* the name of the group the node is in. *)
      val name : t -> string

      (* the connection properties of the node. *)
      val connection : t -> ConnectionProperties.t

      (* the pre-parsed command and arguments of the node. *)
      val cmdLine : t -> Arguments.t

      val lifetime : t -> LifetimeDistribution.t

      val crashRatio : t -> Real32.real

      val workload : t -> string

      (* parameters: id, name, connection, command, arguments, onlineTime, offlineTime *)
      val new : {
         id : int,
         name : string,
         connection : ConnectionProperties.t,
         cmdLine : Arguments.t,
         lifetime : LifetimeDistribution.t,
         crashRatio : Real32.real,
         workload : string
      } -> t
   end
