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

fun handleFoundClient
   (HANDLERS { leaveClient, upgrade, yesServer, ... })
   (ACTIONS { makeMethods, ... })
   (STATE { clients, ... }) 
   (conversation, makeClient) =
   let
      fun method () = "topology/handler/foundClient"
      val () = Log.logExt (Log.DEBUG, method, fn () => ("contacted client " ^ Conversation.toString conversation))

      (* This operation is cancelled either by leaving or limits timeout *)
      fun abort () = Conversation.reset conversation
      val done = ref (Clients.addAbort (clients, abort))
      
      fun fail () = (!done) ()
      val () = setTopologyLimits (conversation, fail)

      fun myLeaveClient ((client, unhookUpgrade), ()) = 
        leaveClient (client, unhookUpgrade) ()
      val (setLeaveClient, leaveClient) = combine myLeaveClient
      val (leaveClient, unhookLeave) =
         Conversation.response (conversation, {
            method   = leaveClient,
            methodTy = leaveClientTy
         })
      
      fun myUpgrade (client, (x, y, z)) = 
        upgrade (client, unhookLeave) x y z
      val (setUpgradeClient, upgrade) = combine myUpgrade
      val (upgrade, unhookUpgrade) =
         Conversation.response (conversation, {
            method   = fn x => fn y => fn z => upgrade (x, y, z),
            methodTy = upgradeTy
         })
      
      fun setupClient client = 
        (setUpgradeClient client; setLeaveClient (client, unhookUpgrade))
      
      fun myYesServer ((x, y, z), outstream) =
         ((!done) ()
          ; yesServer (conversation, outstream, setupClient) x y z)
      val (yesServer, gotOutstream) = combine myYesServer
      fun saveOutstream outstream =
         let
            val () = (!done) ()
            
            fun abort () = (CUSP.OutStream.reset outstream; Conversation.reset conversation)
            val () = done := Clients.addAbort (clients, abort)
            
            fun fail () = (CUSP.OutStream.reset outstream; (!done) ())
            val () = setTopologyLimits (conversation, fail)
         in
            gotOutstream outstream
         end
      
      val (yesServer, _) =
         Conversation.response (conversation, {
            method   = fn x => fn y => fn z => yesServer (x, y, z),
            methodTy = yesServerTy
         })

      val (methods, _) = makeMethods conversation
   in
      makeClient methods yesServer upgrade leaveClient saveOutstream
   end
