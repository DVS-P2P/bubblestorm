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

fun setTopologyLimits (conversation, fail) =
   let
      open Log
      fun timeout () =
         let
            val () = log (DEBUG, "topology/limits",
               fn () => ("Timeout exceeded in " ^ Conversation.toString conversation))
            val _ = fail ()
         in
            Conversation.reset conversation
         end
      fun limitsExceeded () =
         let
            val () = log (DEBUG, "topology/limits",
               fn () => ("Conversation limits exceeded in " ^ Conversation.toString conversation))
            val _ = fail ()
         in
            Conversation.reset conversation
         end
      val () =
         Conversation.setTimeout (conversation, SOME {
            limit = Config.deathTimeout (),
            dead  = timeout
          })
      val () =
         Conversation.setLimits (conversation, SOME {
            recv = Config.topologyConversationLimit,
            send = Config.topologyConversationLimit,
            quota = limitsExceeded
          })
   in
      ()
   end
