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

fun handleUpgrade
   (HANDLERS { leaveMaster, ... })
   (ACTIONS { ... })
   (STATE { locations, clients, ... }) 
   (client, unhookLeaveClient) makeSlave leaveSlave upgradeOk =
   let
      fun method () = "topology/handler/upgrade"

      val seed = Random.word64 (getTopLevelRandom (), NONE)
      val iter = Locations.randomActiveIterator (locations, seed)
      val iter = Iterator.filter Location.hasStableSlave iter
   in
      if Locations.leaving locations then
         Log.logExt (Log.DEBUG, method, fn () => "ignoring upgrade; client is already dispatched to a neighbour")
      else
      case Iterator.getItem iter of
         NONE =>
           (* If leaving, we already pushed the client away. He will be able to upgrade elsewhere; ignore him. *)
           if Locations.leaving locations then () else
           let
              (* Can't push him away b/c, what if I want to leave later? Pushing twice would be bad! *)
              (* If I ever really see this happen, I will consider a sleep and try again policy *)
              val () = Log.logExt (Log.WARNING, method, fn () => "Could not honour upgrade (no peers) for " ^ Neighbour.toString client)
           in
              Neighbour.reset client
           end
       | SOME (location, _) =>
            let
               val () = Log.logExt (Log.DEBUG, method, fn () => "Upgrade " ^ Neighbour.toString client ^ " at " ^ Location.toString location)
               val state = { 
                  slave     = client,
                  makeSlave = makeSlave,
                  leave     = SOME leaveSlave
               }
               
               (* First, downgrade the existing slave to slacker *)
               fun demote (complete, oldSlave, makeSlave) =
                  let
                     val () = 
                        if complete 
                        then Neighbour.completeTeardown oldSlave 
                        else Clients.addSlackerRW (clients, oldSlave)
                  in
                     case Neighbour.address oldSlave of
                        NONE => (badSlave, badMakeSlave)
                      | SOME address => (address, makeSlave)
                  end
               val (oldSlaveAddress, oldMakeSlave) = 
                  case Location.state location of
                     Location.STATE { slave=Location.CONNECTED { slave, makeSlave, ... }, ... } =>
                        demote (false, slave, makeSlave)
                   | Location.STATE { slave=Location.ZOMBIE { slave, makeSlave, ... }, ... } =>
                        demote (true, slave, makeSlave)
                   | _ => (badSlave, badMakeSlave)
               
               val () = unhookLeaveClient ()
               val (leaveMaster, _) =
                  Conversation.response (Neighbour.conversation client, {
                     method   = leaveMaster (location, client),
                     methodTy = leaveMasterTy
                  })
               
               (* Now skip the CONNECTING state *)
               val () = Location.connectSlave (location, fn _ => ())
               val () = Location.installSlave (location, state)
            in
               upgradeOk oldSlaveAddress oldMakeSlave leaveMaster
            end
   end
