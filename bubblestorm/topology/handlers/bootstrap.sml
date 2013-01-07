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

fun handleBootstrap
   (HANDLERS { findServer, ... })
   (ACTIONS { ... })
   (STATE { gossip, networkSize, ... })
   source makeClient bootstrapOk =
   let
      fun method () = "topology/handler/bootstrap"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called from " ^ Conversation.toString source)
      
      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
       
      val () = setTopologyLimits (source, fn () => ())
      
      fun send (i, g) =
         let
            val { round, fishSize, fish, values } =
               Gossip.lastRound g
         in
            bootstrapOk (fn _ => ()) (Int16.fromInt i) round fishSize fish values
         end
      val () = Vector.appi send gossip
      
      val host = Conversation.host source
      val address = CUSP.Host.remoteAddress host
      
      (* How far ? *)
      val hops = Config.walkLength (!networkSize)
      val hops = (Int16.fromInt o Real32.toInt IEEEReal.TO_POSINF) hops
   in
      case address of
         SOME addr => findServer source addr makeClient hops
       | NONE => ()
   end
