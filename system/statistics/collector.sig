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

signature COLLECTOR =
   sig
      type t
      
      val new : unit -> t
      val reset : t -> unit
      
      val add : t -> Real32.real -> unit
      val aggregate : t -> t -> unit
      
      val count : t -> int
      val sum : t -> Real64.real
      val sum2 : t -> Real64.real
      val min : t -> Real32.real
      val max : t -> Real32.real
      
      val avg : t -> Real32.real
      val stdDev : t -> Real32.real
   end
