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

signature NODE_TRIGGER =
   sig
      type t
      
      (* get a handle from the current node, which can be used by a second node
         to make the first node to execute a function. 
         Yes, this breaks isolation. So use it carefully.
       *)
      val get : unit -> t
      
      (* use a node handle to execute a function in this node's context. The
         method will be run in a separate event scheduled for immediate 
         execution in the target node's context. *)
      val exec : t * (unit -> unit) -> unit
   end
