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

fun handleLeaveMaster
   (HANDLERS { ... })
   (ACTIONS { contactSlave, ... })
   (STATE { clients, ... }) 
   (location, neighbour) address makeSlave =
   let
      fun method () = "topology/handler/leaveMaster"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called with (" ^ CUSP.Address.toString address ^ ", " ^ Conversation.Entry.toString makeSlave ^ "): " ^ result)
   in
      if Location.leaving location then 
         log "ignored -- leaving"
      else if not (Location.slaveIs (location, neighbour)) then
         log "ignored -- slave has been replaced"
      else
      let
         val () = log "honouring"
         val () = Neighbour.initiateTeardown neighbour
         val () = Clients.addSlackerRO (clients, neighbour)
         val () = Location.connectSlave (location, fn _ => ())
      in
         contactSlave location address makeSlave
      end
   end
