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

signature FRONTEND =
   sig
      type t
         
      val new : {
         state   : BasicBubbleType.bubbleState,
         types   : unit -> BasicBubbleType.t list,
         statistics : Stats.managed
      } -> t

      val addStorage : t -> {
         service : StorageService.Description.t,
         capacity : Real64.real,
         d1       : Real64.real,
         filter   : bool -> bool,
         position : int
      } -> unit

      val onRoundSwitch : t * int -> unit
      
      val onLeave : t -> unit
      
      val request : t * StorageRequest.t -> unit
   end
