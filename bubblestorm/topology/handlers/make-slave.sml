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

fun handleMakeSlave
   (HANDLERS { makeSlave, leaveSlave, ... })
   (ACTIONS { makeMethods, ... })
   (STATE { endpoint, clients, ... })
   (location, oldMaster) conversation methods yesMaster leaveMaster instream =
   (* You might not have an oldMaster IF you are the creator of the ring *)
   if not (getOpt (Option.map (fn m => Location.masterIs (location, m)) oldMaster, true)) then () else
   let
      fun method () = "topology/handler/makeSlave"
      val () = Log.logExt (Log.DEBUG, method, fn () => "met " ^ Conversation.toString conversation ^ " at " ^ Location.toString location)

      fun fail () = Location.failedMaster location
      val () = setTopologyLimits (conversation, fail)
      
      (* Kill off the old master immediately and become connecting *)
      val () = 
         case Location.master location of
            NONE => ()
          | SOME m => (Neighbour.initiateTeardown m
                       ; Clients.addSlackerRO (clients, m))
      
      fun myLeaveSlave (master, ()) = leaveSlave (location, master) ()
      val (setupNewMaster1, leaveSlave) = combine myLeaveSlave
      val (leaveSlave, _) =
         Conversation.response (conversation, {
            method   = leaveSlave,
            methodTy = leaveSlaveTy
         })

      fun myMakeSlave (master, (c, m, y, l, i)) = makeSlave (location, SOME master) c m y l i
      val (setupNewMaster2, makeSlave) = combine myMakeSlave
      val (newMakeSlave, unhookMakeSlave) =
         Conversation.advertise (endpoint, {
            service = NONE,
            entryTy = makeSlaveTy,
            entry   = fn c => fn m => fn y => fn l => fn i =>
                      makeSlave (c, m, y, l, i) 
         })
      
      fun gotOutstream outstream =
         let
            (* Setup the new master *)
            val master = Neighbour.new (conversation, instream, outstream, methods)
            (* Bind the makeSlave advertise lifetime to the master *)
            val () = Neighbour.addDeathHandler (master, unhookMakeSlave)
            
            val state = { master=master, upgrade=NONE, leave=SOME leaveMaster }
            val () = Location.installMaster (location, state)
         in
            (setupNewMaster1 master; setupNewMaster2 master)
         end
      
      (* reseting the conversation kills the outstream during call *)
      fun done true = ()
        | done false = (unhookMakeSlave (); Conversation.reset conversation; CUSP.InStream.reset instream)
      
      val () = Location.connectMaster (location, done)
      val (methods, _) = makeMethods conversation
   in
      yesMaster methods newMakeSlave leaveSlave gotOutstream
   end
