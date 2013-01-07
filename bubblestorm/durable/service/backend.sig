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
      
      type itemSet = BasicBubbleType.t * (ID.t * Version.t * Word8Vector.vector) Iterator.t
      
      val new : (unit -> BasicBubbleType.t list) -> t
      
      val isNew : Record.request * (bool -> unit) -> unit
      
      val store : Record.request * Word8Vector.vector * int * (bool -> unit) -> unit

      val lookup : Lookup.request -> unit
      
      val iterator : t * (itemSet -> unit) -> unit
      
      val cleanup : t * (BasicBubbleType.t -> (ID.t -> bool)) -> unit
   end
   
