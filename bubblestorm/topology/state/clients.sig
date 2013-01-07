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

signature CLIENTS =
   sig
      type t
      
      (* Register a resource to release on leave.
       * This is used to abort contactClient/makeClient.
       *)
      val addAbort : t * (unit -> unit) -> (unit -> unit)
      
      (* Clients are neighbours who have never been peers (slave/master)
       *    they come from findServer->contactClient->makeClient
       *
       * When we are leaving we pass them off to someone with findServer.
       * 
       * Notice: once leaving no more are created:
       *   we don't process findServer any more
       *   all in-progress contactClient/makeClient are aborted
       *)
      val addClient : t * Neighbour.t * makeClient -> unit
      
      (* Slackers are former peers who are disconnecting from us.
       *   slaves replaced after request via leaveSlave
       *   slaves repalced via an upgrade
       *
       * We still need to look after them if we quit ourselves.
       * We'll just hold off leaving until they are gone.
       *
       * Notice: once leaving no more are created:
       *   we don't process leaveMaster or upgrade any more
       *)
      val addSlackerRW : t * Neighbour.t -> unit
      val addSlackerRO : t * Neighbour.t -> unit
      
      (* Walk the clients *)
      val iterator : t -> Neighbour.t Iterator.t
      
      (* Upon leaving, we want to push all clients away
       *   abort all in-progress operations
       *   push clients away with a findMaster
       *   slackers are already going, so just add a timeout
       *)
      val flushClients : t * (Word64.word -> Neighbour.t Iterator.t) -> unit
      val allowClients : t -> unit
       
      (* Are all the clients gone? *)
      val empty : t -> bool
      
      val new : (unit -> unit) -> t
   end
