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

signature GOSSIP =
   sig
      type t
      
      structure Real : REAL
      
      type packet = {
         round    : Word32.word,
         fishSize : Word64.word,
         fish     : Real.real,
         values   : Word8Vector.vector
      }
      
      val new : {
         freq : Time.t,
         pull : unit -> Real.real vector,
         push : Word32.word * Real.real vector -> unit,
         init : Word32.word * Real.real vector -> unit,
         stat : (Statistics.t option) vector,
         min  : int,
         max  : int,
         sum  : int
      } -> t
      
      (* The address is our OWN address and degree *)
      val recv : t * CUSP.Address.t option * int * packet -> unit
      val recover : t * packet -> unit
      val sample : t * Real.real -> packet option
      val freq : t -> Time.t
      
      val initCreate : t * CUSP.Address.t -> unit
      val initJoin : t * packet -> unit
      val deinit : t -> unit
      
      val lastRound : t -> packet
   end
