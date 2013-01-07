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

signature NATIVE_UDP =
   sig
      structure Address : ADDRESS
      
      type t
      
      (* Port to bind and callback to invoke when the socket has data *)
      val new : int option * (unit -> unit) -> t
      val close : t -> unit
      
      (* Path MTU is a tricky business.
      *  
       * If the host system cannot support path MTU, then send should
       * retun 'true' always and mtu always returns 1472.
       *
       * If the host system DOES support path MTU, then:
       *   1) the DF flag must be set on all out-going UDP messages
       *   2) the send method returns false if the message would fragment
       *   3) after a 'false' send, the mtu method reports a shorter length
       *)
      
      (* Get a new estimated MTU for the destination given the last MTU *)
      val mtu : t * Address.t * int -> int
      val maxMTU : int
      
      (* If send returns false, then the buffer was too large to send *)
      val send : t * Address.t * Word8ArraySlice.slice -> bool
      val recv : t * Word8ArraySlice.slice -> (Address.t * Word8ArraySlice.slice) option
      
      (* Deal with ICMP related to the UDP port *)
      val recvICMP : t * Word8ArraySlice.slice -> {
         UDPto    : Address.t,
         reporter : Address.t,
         code     : Word16.word,
         data     : Word8ArraySlice.slice
      } option
      val sendICMP : t * {
         UDPto   : Address.t,
         UDPfrom : Address.t,
         code    : Word16.word,
         data    : Word8ArraySlice.slice
      } -> unit
      
      (* Get the local socket address.
       * Be aware this is probably something like 0.0.0.0!
       *)
      val localName : t -> Address.t
   end
