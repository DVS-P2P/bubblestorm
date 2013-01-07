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

signature STORAGE_SERVICE =
   sig
      structure Description : SERIALIZABLE
      
      type t
         
      (* create a storage peer service *)
      val new : {
         state : BasicBubbleType.bubbleState,
         backend : Backend.t
      } -> t

      (* start accepting reqistrations. *)
      val start : t -> unit

      (* stop accepting reqistrations. *)
      val stop : t -> unit
      
      (* has been started and not stopped again. *)
      val isRunning : t -> bool

      (* the information needed to contact the service *)
      val description : t -> Description.t option
      
      type register = bool -> int -> (CUSP.OutStream.t -> unit) -> unit
      
      (* connect to the storage service *)
      val register : {
         endpoint : CUSP.EndPoint.t,
         service  : Description.t,
         complete : (Conversation.t * register) option -> unit
      } -> unit
   end
