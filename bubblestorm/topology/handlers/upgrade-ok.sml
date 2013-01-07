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

fun handleUpgradeOk
   (HANDLERS { ... })
   (ACTIONS { contactSlave, ... })
   (STATE { ... }) 
   (location, master) address makeSlave leaveMaster =
   let
      fun method () = "topology/handler/upgradeOk"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called with (" ^ CUSP.Address.toString address ^ ", " ^ Conversation.Entry.toString makeSlave ^ ") at " ^ Location.toString location)
      
      val () = 
         if Location.masterIs (location, master)
         then Location.setLeaveMaster (location, leaveMaster)
         else ()
   in
      contactSlave location address makeSlave
   end
