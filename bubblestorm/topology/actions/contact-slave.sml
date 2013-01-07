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

fun doContactSlave
   (HANDLERS { foundSlave, ... })
   (ACTIONS { ... })
   (STATE { endpoint, ... })
   location address makeSlave =
   let
      fun method () = "topology/action/contactSlave"
      fun who () = "(" ^ CUSP.Address.toString address ^ ", " ^ Conversation.Entry.toString makeSlave ^ ")"
      fun log result = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ who () ^ " at " ^ Location.toString location ^ ": " ^ result)
      
      fun status NONE = 
          let
             val () = Log.logExt (Log.WARNING, method, fn () => "contact failed " ^ who ())
          in
             Location.failedSlave location
          end
        | status (SOME x) = foundSlave location x
   in
      if CUSP.Address.== (address, CUSP.Address.invalid) then 
         let
            val () = log "bad address -- stopping"
         in
            Location.failedSlave location
         end
      else
         let
            val () = log "associating"
            val abort = ref (fn () => ())
            val () = Location.connectSlave' (location, fn _ => (!abort) ())
         in
            abort := Conversation.associate (endpoint, address, {
               entry    = makeSlave,
               entryTy  = makeSlaveTy,
               complete = status
            })
         end
   end
