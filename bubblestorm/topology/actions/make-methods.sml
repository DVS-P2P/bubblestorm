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

fun doMakeMethods
   (HANDLERS { bubblecast, gossip, findServer, ... })
   (ACTIONS { ... })
   (STATE { locations, ... })
   conversation =
   let
      fun method () = "topology/action/makeMethods"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called for " ^ Conversation.toString conversation)
      
      val (b, bhook) =
         Conversation.response (conversation, {
            method   = bubblecast (SOME conversation),
            methodTy = bubblecastTy
         })
      val (g, ghook) =
         Conversation.response (conversation, {
            method   = gossip conversation,
            methodTy = gossipTy
         })
      val (k, khook) =
         Conversation.response (conversation, {
            method   = (),
            methodTy = keepAliveTy
         })
      val (f, fhook) =
         Conversation.response (conversation, {
            method   = findServer conversation,
            methodTy = findServerTy
         })
      fun hook () = (bhook (); ghook (); khook (); fhook ())
      val record = { 
         bubblecast = b,
         gossip     = g,
         keepAlive  = k,
         findServer = f,
         degree     = Word16.fromInt (Locations.desiredDegree locations)
      }
   in
      (record, hook)
   end
