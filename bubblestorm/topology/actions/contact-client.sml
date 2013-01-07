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

fun doContactClient
   (HANDLERS { foundClient, ... })
   (ACTIONS { ... })
   (STATE { endpoint, clients, ... })
   address makeClient =
   let
      fun method () = "topology/action/contactClient"
      fun who () = "(" ^ CUSP.Address.toString address ^ ", " ^ Conversation.Entry.toString makeClient ^ ")"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ who ())
      
      val done = ref (fn () => ())
      
      fun status NONE = ((!done) (); Log.logExt (Log.DEBUG, method, fn () => "contact failed " ^ who ()))
        | status (SOME x) = ((!done) (); foundClient x)
      
      val abort = 
         Conversation.associate (endpoint, address, {
            entry    = makeClient,
            entryTy  = makeClientTy,
            complete = status
         })
   in
      done := Clients.addAbort (clients, abort)
   end
