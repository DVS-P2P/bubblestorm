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

fun handleMakeClient
   (HANDLERS { makeClient, ... })
   (ACTIONS { makeMethods, ... })
   (STATE { endpoint, clients, ... })
   location conversation methods yesServer upgrade leaveClient instream =
   let
      fun method () = "topology/handler/makeClient"
      val () = Log.logExt (Log.DEBUG, method, fn () => "met " ^ Conversation.toString conversation)
      
      fun fail () = Location.failedMaster location
      val () = setTopologyLimits (conversation, fail)
      
      (* Kill off any old master we have *)
      val () = 
         case Location.master location of
            NONE => ()
          | SOME m => (Neighbour.initiateTeardown m
                       ; Clients.addSlackerRO (clients, m)
                       ; Location.connectMaster (location, fn _ => ()))
      
      val (newMakeClient, unhookMakeClient) =
         Conversation.advertise (endpoint, {
            service = NONE,
            entryTy = makeClientTy,
            entry   = makeClient location
         })
      
      fun gotOutstream outstream =
         let
            val master = Neighbour.new (conversation, instream, outstream, methods)
            val () = Neighbour.addDeathHandler (master, unhookMakeClient)
            fun leave _ _ = leaveClient ()
            val state = { master=master, upgrade=SOME upgrade, leave=SOME leave }
         in
            Location.installMaster (location, state)
         end
      
      (* killing the conversation kills the outstream up until saveOutstream *)
      fun done true = ()
        | done false = (unhookMakeClient (); Conversation.reset conversation; CUSP.InStream.reset instream)
      
      val () = Location.connectMaster' (location, done)
      val (methods, _) = makeMethods conversation
   in
      yesServer methods newMakeClient gotOutstream
   end
