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

signature STORAGE_REQUEST =
   sig
      datatype t =
         INSERT of BasicBubbleType.t * ID.t * Word8Vector.vector * (unit -> unit)
       | UPDATE of BasicBubbleType.t * ID.t * Word8Vector.vector * (unit -> unit)
       | DELETE of BasicBubbleType.t * ID.t * (unit -> unit)
       
      exception InvalidBubbleType (* raised by decodeXXX *)

      val decodeInsert : BasicBubbleType.bubbleState * Conversation.t * Word8ArraySlice.slice -> t
      val decodeUpdate : BasicBubbleType.bubbleState * Conversation.t * Word8ArraySlice.slice -> t
      val decodeDelete : BasicBubbleType.bubbleState * Conversation.t * Word8ArraySlice.slice -> t
      
      val encode : Conversation.t * t -> Word8Vector.vector
      
      val toString : t -> string
   end
