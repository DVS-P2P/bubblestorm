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

signature STORAGE_STREAM =
   sig
      type t
      
      (* interface used by storage peers to receive from a maintainer *)
      val newMaintainer : {
         state : BasicBubbleType.bubbleState,
         conversation : Conversation.t,
         stream : CUSP.InStream.t,
         position : int ref, (* gets updated by the maintainer *)
         onRequest : StorageRequest.t -> unit,
         (* true = shutdown, false = reset/timeout *)
         whenDead : bool -> unit
      } -> unit
      
      (* interface for maintainers for sending to a storage peer *)
      val newStorage : {
         conversation : Conversation.t,
         stream : CUSP.OutStream.t,
         whenDead : bool -> unit
      } -> t
      
      val send : t * StorageRequest.t -> unit
      val changePosition : t * int -> unit
      val shutdown : t -> unit
   end
