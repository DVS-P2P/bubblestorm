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

fun doPushFish
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { locations, gossip, ... })
   () =
   let
      fun method () = "topology/action/pushFish"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called: " ^ result)

      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
   in
      case Iterator.getItem (Locations.totalNeighbours locations) of
         NONE => log "failed -- no uplink"
       | SOME (neighbour, _) =>
         let
            val () = log ("sent to " ^ Neighbour.toString neighbour)
            val { gossip=hisGossip, ... } = Neighbour.methods neighbour
            fun doit (id, g) =
               (* Take everything and pass it on *)
               case Gossip.sample (g, 1.0) of
                  NONE => ()
                | SOME { round, fishSize, fish, values } =>
                     hisGossip (fn _ => ()) (Int16.fromInt id) round fishSize fish values
         in
            Vector.appi doit gossip
         end
   end
