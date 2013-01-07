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

fun doJoin
   (HANDLERS { foundBootstrap, ... })
   (ACTIONS { startWalk, ... })
   (STATE { locations, endpoint, oracle, cache, networkSize, ... })
   location =
   let
      fun method () = "topology/action/join"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called on " ^ Location.toString location)
      
      val seed = Random.word64 (getTopLevelRandom(), NONE)
      val joinVia = Locations.randomTotalNeighbours (locations, NONE, seed)
   in
      case Iterator.getItem joinVia of
         SOME (neighbour, _) =>
         let
            val () = Location.connectMaster (location, fn _ => ())
            (* must succeed if we have neighbours (ala joinVia) *)
            val addr = valOf (Locations.localAddress locations)
            val {findServer, ...} = Neighbour.methods neighbour
            val (makeClient, allowMakeClient) = startWalk location
            val () = allowMakeClient ()
            
            (* How far ? *)
            val hops = Config.walkLength (!networkSize)
            val hops = (Int16.fromInt o Real32.toInt IEEEReal.TO_POSINF) hops
         in
            findServer addr makeClient hops
         end
       | NONE =>
         let
            val bootstrapHost =
               case !cache of
                  NONE => oracle ()
                | SOME x => x
            
            (* we need to find a bootstrap *)
            fun state (SOME x) = foundBootstrap location x
              | state NONE = 
               let
                  fun method () = "topology/action/join/callback"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "contact failed")
                  val () = 
                     case !cache of
                        NONE => ()
                      | SOME x => 
                        if CUSP.Address.== (x, bootstrapHost)
                        then cache := NONE else ()
               in
                  Location.failedMaster location
               end
            
            (* Be more aggressive at determining timeout *)
            val stop = ref (fn () => ())
            fun cancel _ =
               let
                  fun method () = "topology/action/join/timeout"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "contact bootstrap timeout")
                  val () = (!stop) ()
               in
                  Location.failedMaster location
               end
            val timeout = Main.Event.new cancel
            val () = Main.Event.scheduleIn (timeout, Config.bootstrapTimeout ())
            
            fun stop' _ = (Main.Event.cancel timeout; (!stop) ())
            val () = Location.connectMaster (location, stop')
         in
            stop := 
               Conversation.associate (endpoint, bootstrapHost, {
                  entry    = Conversation.Entry.fromWellKnownService Config.BOOTSTRAP_SERVICE,
                  entryTy  = bootstrapTy,
                  complete = state
               })
         end
   end
