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

signature MANAGED_BUBBLE =
   sig
      include PERSISTENT_BUBBLE
      
      val insert : {
         typ   : BubbleType.managed,
         id    : ID.t,
         data  : Word8Vector.vector,
         done  : unit -> unit
      } -> t
      
      val update : {
         bubble : t,
         data   : Word8Vector.vector,
         done   : unit -> unit
      } -> unit
      
      val delete : {
         bubble : t,
         done   : unit -> unit
      } -> unit
      
      (* retrieves a bubble from the set of bubbles published by us *)
      val get : {
         typ      : BubbleType.managed,
         id       : ID.t
      } -> t option
   end
