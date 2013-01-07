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

structure FadingBubble :> FADING_BUBBLE =
   struct
      open PersistentBubble
      
      fun encode (id, data) =
         let
            (* include ID in payload *)
            val { toVector, ... } = Serial.methods ID.t
         in
            Word8Vector.concat [ toVector id,  data ]
         end
      
      fun create { typ, id, data } =
         let
            val basic = BubbleType.basicFading typ
            val () = BasicBubbleType.bubblecast {
               bubbleType = basic,
               size = BasicBubbleType.defaultSize basic,
               data = encode (id, data)
            }
         in
            new (id, data)
         end
      
      fun createPartially { typ, id } =
         let
            val basic = BubbleType.basicFading typ
            val slicecast = BasicBubbleType.slicecast {
               bubbleType = basic,
               size = BasicBubbleType.defaultSize basic
            }
            
            fun createPart { data, start, stop } =
               slicecast { data = encode (id, data), start = start, stop = stop }
         in
            createPart
         end
   end
