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

signature SERVICE =
   sig
      type t
      type stub
      
      val t : (t, stub, unit) Serial.t

      val stub : (stub, stub, unit) Serial.t
      
      val new : {
         state   : BasicBubbleType.bubbleState,
         responsible : Record.request -> int option,
         route   : Record.t * Word8Vector.vector * CUSP.Address.t -> unit
      } -> t
      
      val close : t -> unit
      
      val store : t * stub * Record.t * Word8Vector.vector * bool * (unit -> unit) -> unit
      
      val lookup : t * stub * Lookup.t * (unit -> unit) -> unit
      
      val capacity : stub -> Real64.real
      
      val address : stub -> CUSP.Address.t
   end
