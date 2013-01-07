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

fun handleLeaveClient
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { locations, clients, ... }) 
   (neighbour, unhookUpgrade) () =
   let
      fun method () = "topology/handler/leaveClient"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called by " ^ Neighbour.toString neighbour ^ ": " ^ result)
   in
      if Locations.leaving locations then
         log "ignored -- leaving"
      else
      let
         val () = log "honouring"
         val () = unhookUpgrade ()
         val () = Neighbour.initiateTeardown neighbour
      in
         Clients.addSlackerRO (clients, neighbour)
      end
   end
