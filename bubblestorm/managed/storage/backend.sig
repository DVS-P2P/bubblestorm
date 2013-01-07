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

signature BACKEND =
   sig
      type t

      val new : {
         state : BasicBubbleType.bubbleState,
         types : unit -> BasicBubbleType.t list,
         (* JunkManager function to adjust junk counters *)
         adjustJunk : bool * int -> unit,
         statistics : Stats.managed
      } -> t

      (* returns a function to remove the maintainer again,
         true = clean shutdown, false = reset, timeout, corrupted stream *)
      val addMaintainer : t * StorageMaintainer.t -> (bool -> unit)
      
      val flush : t -> (bool -> bool) -> unit
   end
