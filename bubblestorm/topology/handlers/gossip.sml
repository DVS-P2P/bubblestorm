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

fun handleGossip
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { gossip, locations, ... }) 
   source id round fishSize fish values =
   let
      fun method () = "topology/handler/gossip"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called from " ^ 
         Conversation.toString source ^ " ID = " ^ Int16.toString id ^ 
         " round = " ^ Word32.toString round ^ 
         " fishSize = " ^ Word64.toString fishSize)
      
      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
       
      val gossip = Vector.sub (gossip, Int16.toInt id)
      val address = Locations.localAddress locations
      val degree = Locations.desiredDegree locations
   in
      Gossip.recv (gossip, address, degree, {
         round    = round,
         fishSize = fishSize,
         fish     = fish,
         values   = values
      })
      handle Subscript => () (* ignore too short packets *)
   end
