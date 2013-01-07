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

signature STORAGE_PEER =
   sig
      (* the local representation of a remote storage peer *)
      type t

      (* register at a storage peer *)
      val new : {
         state : BasicBubbleType.bubbleState,
         (* the storage peer to connect to *)
         service  : StorageService.Description.t,
         (* to which bucket do we belong? *)
         bucket   : bool,
         (* the storage peer's position in our virtual "bubblecast". important 
            for intersecting the managed bubbles with other (passive) bubbles. *)
         position : int,
         (* if registration is successful, the callback will receive a local
            representation of the storage peer that can be used to send requests. *)
         (* the callback must return a function used by the storage protocol 
            to tell the frontend when the storage has died (i.e., timed out,
            sent a reset, or was quit by the frontend) *)
         callback : t -> (unit -> unit)
      } -> unit

      val service : t -> StorageService.Description.t
      
      (* quit a storage peer. will trigger the callback that tells the frontend
         that the peer is dead *)
      val quit : t -> unit

      (* send a (store|update|delete) request to a storage peer. 
         might trigger the dead callback, if a timeout is encountered. *)
      val send : t * StorageRequest.t -> unit

      (* update the bubble position of the peer.
         might trigger the dead callback, if a timeout is encountered. *)
      val changePosition : t -> int -> unit
   end
