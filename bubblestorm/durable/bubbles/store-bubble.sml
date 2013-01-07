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

structure StoreBubble :> STORE_BUBBLE =
   struct
      type t = BasicBubbleType.t

      (* an all-zero ID for bubblecast to eat *)
      val { length, toVector, fromVector, ... } = Serial.methods ID.t
      val fakeID = fromVector (Word8Vector.tabulate (length, fn _ => 0w0))
      
      fun send (this, request, data) =
         BasicBubbleType.bubblecast {
            bubbleType = this,
            size       = BasicBubbleType.defaultSize this,
            data       = Word8Vector.concat [
               toVector fakeID,
               Record.toVector (Record.encode request, data)
            ]
         }
      
      fun receive router (_, data) =
         case Record.fromVectorSlice data of (record, data) =>
            Router.store (router, record, data)
            
      fun new (state, router) =
         let
            val this = BasicBubbleType.new {
                  state       = state,
                  name        = "Durable.Store",
                  typeId      = ~6,
                  class       = BasicBubbleType.FADING {
                                   store = receive router
                                },
                  priority    = Config.defaultQueryPriority,
                  reliability = Config.defaultBubblepostReliability
               }
            val () = BasicBubbleType.setMinimum (this, fn _ => Config.locateBubbleSize)
         in
            this
         end
   end
