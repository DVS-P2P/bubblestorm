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

fun doUpgrade
   (HANDLERS { makeSlave, leaveSlave, upgradeOk, ... })
   (ACTIONS { ... })
   (STATE { endpoint, ... })
   location =
   let
      fun method () = "topology/action/upgrade"
      val () = Log.logExt (Log.DEBUG, method, fn () => "at " ^ Location.toString location)

      val master = valOf (Location.master location)
      
      (* fetch (and remove) the upgrade function *)
      val upgrade = Location.upgrade (location, fn _ => ())
      val conversation = Neighbour.conversation master
      
      (* remove the old leave method as it cannot be used anymore *)
      val _ = Location.leaveMaster location

      val (makeSlave, unhookMakeSlave) =
         Conversation.advertise (endpoint, {
            service = NONE,
            entryTy = makeSlaveTy,
            entry   = makeSlave (location, SOME master)
         })
      
      val (upgradeOk, unhookUpgradeOk) =
         Conversation.response (conversation, {
            method   = upgradeOk (location, master),
            methodTy = upgradeOkTy
         })

      val (leaveSlave, _) =
         Conversation.response (conversation, {
            method   = leaveSlave (location, master),
            methodTy = leaveSlaveTy
         })
      
      val () = Neighbour.addDeathHandler (master, unhookMakeSlave)
      
      (* This is a big complex interaction. Sit down.
       * When we call upgrade, we are waiting for upgradeOk.
       * Until that happens the slave must be in the CONNECTING state.
       * We cannot allow the CONNECTING state to become wedged; it must be cleared.
       * 
       * These things can happen:
       *   We get tired of waiting for the server to do upgradeOk
       *     ... means we also have a timeout to clean up
       *     => we reset his ass
       *   upgradeOk successfully called
       *     ... runs our handler with either false or true (depending on if we get an address)
       *     => in our handler, cancel timer (CONNECTING state already unwedged)
       *     => set a flag indicating the mess is done
       *   The server is reset
       *     ... to be sure the server hasn't been replaced, check the handler flag
       *     => fail the slave connect (which also cancel timer)
       *   The server gets replaced (he pushed us to a new server)
       *     => the evaluate table fails the connection, calling the handler, which cancels the timer
       *)
      
      fun timeout _ = Neighbour.reset master
      val timeout = Main.Event.new timeout
      val () = Main.Event.scheduleIn (timeout, Config.upgradeWait ())
      
      val alreadyCleanedUp = ref false
      fun handler _ = 
         let
            val () = Main.Event.cancel timeout
            val () = unhookUpgradeOk ()
         in
            alreadyCleanedUp := true
         end
      val () = Location.connectSlave' (location, handler)
      
      fun maybeReset () =
         if !alreadyCleanedUp then () else 
         Location.failedSlave location
      val () = Neighbour.addDeathHandler (master, maybeReset)
   in
      upgrade makeSlave leaveSlave upgradeOk
   end
