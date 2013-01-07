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

signature BUFFERED_UDP =
   sig
      structure Address : ADDRESS
      
      type t
      
      val new : {
         port                : int option,
         exceptionHandler    : exn -> unit,
         receptionHandler    : t * Address.t * Word8ArraySlice.slice -> unit,
         icmpHandler         : t * { UDPto : Address.t, reporter : Address.t, code : Word16.word, data : Word8ArraySlice.slice } -> unit,
         transmissionHandler : t * Word8ArraySlice.slice -> Address.t * Word8ArraySlice.slice * (bool -> unit)
      } -> t
      val close : t -> unit
      
      val ready : t * bool -> unit
      val mtu : t * Address.t * int -> int
      val maxMTU : int
      
      (* Limit the rate at which UDP can send.
       * The rate is in bytes / second.
       * Burst is how much delay can be tolerated by an initial burst of
       * traffic after a quiet period.
       *)
      val setRate : t * { rate : Real32.real, burst : Time.t } option -> unit
      
      val sendICMP : t * {
         UDPto   : Address.t,
         UDPfrom : Address.t,
         code    : Word16.word,
         data    : Word8ArraySlice.slice
      } -> unit
      
      val localName : t -> Address.t
   end
