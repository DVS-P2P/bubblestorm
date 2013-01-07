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

signature ICMP =
   sig
      type t
      type address
      
      val new : INetSock.dgram_sock * (unit -> unit) -> t
      val close : t -> unit
      
      val recv : t * Word8ArraySlice.slice -> {
         UDPto    : address,
         reporter : address,
         code     : Word16.word,
         data     : Word8ArraySlice.slice
      } option
      val send : t * {
         UDPto   : address,
         UDPfrom : address,
         code    : Word16.word,
         data    : Word8ArraySlice.slice
      } -> unit
   end

signature ICMP_PRIMITIVE =
   sig
      type address
      
      val new : INetSock.dgram_sock * (unit -> unit) -> {
         close : unit -> unit,
         newR  : unit -> {
            closeR : unit -> unit,
            recv : Word8ArraySlice.slice -> {
               UDPto    : address,
               reporter : address,
               code     : Word16.word,
               data     : Word8ArraySlice.slice
            } option
         },
         newS  : unit -> {
            closeS : unit -> unit,
            send : {
               UDPto   : address,
               UDPfrom : address,
               code    : Word16.word,
               data    : Word8ArraySlice.slice
            } -> unit
         }
      }
   end
