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

fun doFlushClients
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { clients, locations, ... })
   () =
   let
      fun method () = "topology/action/flushClients"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called")
      
      (* Disperse the remaining clients over our masters *)
      fun neighbours seed = 
        Locations.randomTotalNeighbours (locations, NONE, seed)
   in
      Clients.flushClients (clients, neighbours)
   end
