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

fun doCreate 
   (HANDLERS { makeSlave, ... })
   (ACTIONS { contactSlave, startGossip, ... })
   (STATE { endpoint, locations, gossip, hooks, ... })
   myAddress cb =
   let
      fun method () = "topology/action/create"
      val () = Log.logExt (Log.DEBUG, method, fn () => "Building ring with myself")
      
      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
       
      (* Mark default locations as joining *)
      val numLocations = Locations.desiredDegree locations div 2
      val () = Locations.setActiveLocations (locations, numLocations)
      val () = Locations.setGoal (locations, Locations.JOIN (Locations.IN_PROGRESS cb))
            
      (* Prepare makeSlave methods for self-looping *)
      fun advertiseMakeSlave idx =
         #1 (Conversation.advertise (endpoint, {
            service = NONE,
            entryTy = makeSlaveTy,
            entry   = makeSlave (Locations.sub (locations, idx), NONE)
         }))
      val makeSlaveTable =
         Vector.tabulate (numLocations, advertiseMakeSlave)
      
      (* Connect to each location to the next *)
      fun setup masterLocation =
         let
            val slaveLocation = (masterLocation + 1) mod numLocations
            val location = Locations.sub (locations, masterLocation)
            val makeSlave = Vector.sub (makeSlaveTable, slaveLocation)
            val () = Location.connectSlave (location, fn _ => ())
         in
            contactSlave location myAddress makeSlave
         end
      val () = Iterator.app setup (Locations.activeIndexes locations)
      
      (* Feed the first results of the measurement protocol out to the readers.
       * We are the only node, so complete the round and start a real new one.
       *)
      fun init g = Gossip.initCreate (g, myAddress)
      val () = Vector.app init gossip
      fun start (i, _) = startGossip i
      val () = hooks := Vector.mapi start gossip
   in
      ()
   end
