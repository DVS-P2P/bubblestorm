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

fun handleFoundBootstrap
   (HANDLERS { bootstrapOk, ... })
   (ACTIONS { startWalk, startGossip, ... })
   (STATE { gossip, hooks, onFoundBootstrap, ... }) 
   location (conversation, bootstrap) =
   let
      fun method () = "topology/handler/foundBootstrap"
      val () = Log.logExt (Log.DEBUG, method, fn () => ("contacted bootstrap " ^ Conversation.toString conversation))
      
      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
       
      val (makeClient, allowMakeClient) = startWalk location
      
      fun measurementReady () =
         let
            fun doit (i, _) = startGossip i
            val () =
               if Vector.length (!hooks) <> 0 then () else
               (Log.logExt (Log.DEBUG, method, fn () => "enabling make client")
                ; hooks := Vector.mapi doit gossip)
         in
            allowMakeClient ()
         end
      
      val remaining = ref (Vector.length gossip)
      fun tick () = 
         let
            val () = remaining := !remaining - 1
         in
            if !remaining = 0 then measurementReady () else ()
         end
      
      val (bootstrapOk, _) = 
         Conversation.response (conversation, {
            methodTy = bootstrapOkTy,
            method   = bootstrapOk (conversation, tick)
         })
      
      (* found-bootstrap callback for host cache / NAT penetration *)
      val () = (onFoundBootstrap o valOf o CUSP.Host.remoteAddress o Conversation.host) conversation
   in
      bootstrap makeClient bootstrapOk
   end
