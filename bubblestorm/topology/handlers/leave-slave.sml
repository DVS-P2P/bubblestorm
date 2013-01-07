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

fun handleLeaveSlave
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { clients, ... }) 
   (location, neighbour) () =
   let
      fun method () = "topology/handler/leaveSlave"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called with at " ^ Location.toString location ^ ": " ^ result)
   in
      if not (Location.masterIs (location, neighbour)) then
         log "ignored -- master has been replaced"
      else
      let
         val () = log "honouring"
         val () = Neighbour.initiateTeardown neighbour
      in
         Clients.addSlackerRO (clients, neighbour)
      end
   end
