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

fun doStartWalk
   (HANDLERS { makeClient, ... })
   (ACTIONS { ... })
   (STATE { endpoint, ... })
   location =
   let
      fun method () = "topology/action/startWalk"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called on " ^ Location.toString location)
      
      fun myMakeClient ((), (c, m, y, u, l, i)) =
         makeClient location c m y u l i
      val (allowMakeClient, makeClient) = combine myMakeClient
      
      val (makeClient, unhook) =
         Conversation.advertise (endpoint, {
            service = NONE,
            entryTy = makeClientTy,
            entry   = fn c => fn m => fn y => fn u => fn l => fn i =>
                      makeClient (c, m, y, u, l, i)
         })
      
      val start = Main.Event.time ()
      fun timeout _ =
         let
            val () = Log.logExt (Log.DEBUG, method, fn () => "timeout on " ^ Location.toString location)
         in
            Location.failedMaster location
         end
      val timeout = Main.Event.new timeout
      val () = Main.Event.scheduleIn (timeout, Config.joinTimeout ())
      
      fun done _ =
         let
            val joinSeconds = Time.toSecondsReal32 (Time.- (Main.Event.time(), start))
            val () = Statistics.add Stats.locationJoinTime joinSeconds
            val () = unhook ()
         in
            Main.Event.cancel timeout
         end
      val () = Location.connectMaster' (location, done)
   in
      (makeClient, allowMakeClient)
   end
