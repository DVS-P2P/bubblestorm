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

signature STORAGE_MAINTAINER =
   sig
      (* the local representation of a remote maintainer *)
      type t
      
      val new : {
         conversation : Conversation.t,
         bucket : bool,
         position : int ref
      } -> t

      (* the bucket the maintainer belongs to *)
      val bucket : t -> bool
      
      (* the bubble position for the maintainer's data. important for 
         intersecting the managed bubbles with other (passive) bubbles. *)
      val position : t -> int
      
      (* tell the maintainer to go away by resetting the stream. 
         will also trigger a whenDead callback on the backend. *)
      val flush : t -> unit
   end
