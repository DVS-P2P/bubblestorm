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

fun doStartGossip 
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { locations, clients, gossip, ... })
   id =
   let
      fun method () = "topology/action/startGossip"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called with ID " ^ (Int.toString id))

      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")       
      val gossip = Vector.sub (gossip, id)
      
      val toPing = ref Iterator.EOF
      val clientBound = ref 0
      
      fun nextPass () =
         let
            val () = Log.logExt (Log.DEBUG, method, fn () => "starting new pass for ID " ^ (Int.toString id))
            
            val clients = Clients.iterator clients
            val neighbours = Locations.totalNeighbours locations
            val iter = Iterator.@ (clients, neighbours)
            
            val () = toPing := iter
            val () = clientBound := Iterator.length clients
         in
            !clientBound + Locations.actualDegree locations > 0
         end
      
      fun gap () =
         let
            val neighbours = Locations.actualDegree locations
            val clients = !clientBound
            val total = neighbours + clients
            val dontGetStuck = Int.max (total, Config.minDegree)
         in
            Time.divInt (Gossip.freq gossip, dontGetStuck)
         end

      fun loop evt =
         case Iterator.getItem (!toPing) of
            NONE => 
               if nextPass () then loop evt else
               Main.Event.scheduleIn (evt, gap ())
          | SOME (neighbour, rest) =>
            let
               val gap = gap ()
               val () = Log.logExt (Log.DEBUG, method, fn () => "sending ID " ^ Int.toString id ^ " to " ^ Neighbour.toString neighbour ^ " gap=" ^ Time.toString gap)
               val { degree=hisDegree, gossip=hisGossip, ... } = 
                  Neighbour.methods neighbour
               val () = toPing := rest
               
               val myDegree = Locations.desiredDegree locations
               val hisDegree = Real32.fromInt (Word16.toInt hisDegree)
               val myDegree = Real32.fromInt myDegree
               
               (* val ratio = 0.5 *)
               (* val ratio = 1.0 / myDegree *)
               val ratio = hisDegree / (myDegree + hisDegree)
               
               (* Send the message, but recover it if lost. *)
               val () = 
                  case Gossip.sample (gossip, ratio) of 
                     NONE => ()
                   | SOME (packet as { round, fishSize, fish, values }) =>
                     let
                        val id = Int16.fromInt id
                        fun ackd true = ()
                          | ackd false = Gossip.recover (gossip, packet)
                     in
                        hisGossip ackd id round fishSize fish values
                     end
            in
               Main.Event.scheduleIn (evt, gap)
            end
      
      val out = Main.Event.new loop
      val () = Main.Event.scheduleIn (out, Time.zero)
   in
      out
   end
