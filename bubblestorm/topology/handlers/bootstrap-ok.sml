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

fun handleBootstrapOk
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { gossip, cache, ... })
   (source, counter) id round fishSize fish values =
   let
      fun method () = "topology/handler/bootstrapOk"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called from " ^ Conversation.toString source ^ ": " ^ result)

      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")       
   in
      let
         val gossip = Vector.sub (gossip, Int16.toInt id)
         val () =
            Gossip.initJoin (gossip, {
               round    = round,
               fishSize = fishSize,
               fish     = fish,
               values   = values
            })
         
         val () = 
            case CUSP.Host.remoteAddress (Conversation.host source) of
               SOME x => cache := SOME x
             | NONE => ()
         
         val () = log "ok"
      in
         counter ()
      end
      handle Subscript => (log "wrong network"; Conversation.reset source)
   end
