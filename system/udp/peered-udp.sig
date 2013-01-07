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

signature PEERED_UDP =
   sig
      structure Address : ADDRESS
      
      type 'a t
      type 'a peer
      
      val new : {
         port                : int option,
         exceptionHandler    : exn -> unit,
         receptionHandler    : 'a t * Address.t * 'a peer option * Word8ArraySlice.slice -> unit,
         icmpHandler         : 'a t * { UDPto : Address.t, reporter : Address.t, code : Word16.word, data : Word8ArraySlice.slice } -> unit,
         transmissionHandler : 'a t * Address.t * 'a peer * Word8ArraySlice.slice -> Word8ArraySlice.slice * (bool -> unit)
      } -> 'a t
      val close : 'a t -> unit
      
      val peer : 'a t * Address.t * 'a -> 'a peer
      val depeer : 'a t * 'a peer -> unit
      
      val peers : 'a t -> 'a peer Iterator.t
      val getPeer : 'a t * Address.t -> 'a peer option
      
      val ready : 'a t * 'a peer * Real32.real -> unit
      val status : 'a t * 'a peer -> Address.t * 'a * Real32.real option
      
      val setRate : 'a t * { rate : Real32.real, burst : Time.t } option -> unit
      val sendICMP : 'a t * {
         UDPto   : Address.t,
         UDPfrom : Address.t,
         code    : Word16.word,
         data    : Word8ArraySlice.slice
      } -> unit

      val localName : 'a t -> Address.t
   end
