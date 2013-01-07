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

structure Record :> RECORD =
   struct
      type t = Version.t * ID.t * int
      
      type request = {
         bubble  : BasicBubbleType.t,
         id      : ID.t,
         version : Version.t
      }

      exception IllegalBubbleType

      fun encode { bubble, id, version } =
         (version, id, BasicBubbleType.typeId bubble)
         
      (* TODO: avoid code duplication, code is also used in Lookup *)      
      fun getBubble state bubble =
         case IDHashTable.get (BasicBubbleType.bubbletypes state, bubble) of
            NONE => raise IllegalBubbleType
          | SOME bubble =>
               case BasicBubbleType.class bubble of
                  BasicBubbleType.DURABLE _ => bubble
                | _ => raise IllegalBubbleType

      fun decode (state, (version, id, bubble)) =
         {
            bubble  = getBubble state bubble,
            id      = id,
            version = version
         }

      local
         open Serial
      in
         val t = aggregate tuple3 `Version.t `ID.t `int32l $
         val { toVector=write, fromVector, length, ... } = methods t
      end
      
      fun fromVectorSlice data =
         (fromVector (Word8VectorSlice.vector (Word8VectorSlice.subslice (data, 0, SOME length))),
          Word8VectorSlice.vector (Word8VectorSlice.subslice (data, length, NONE)))


      fun toVector (request, data) = Word8Vector.concat [ write request, data ]
   end
