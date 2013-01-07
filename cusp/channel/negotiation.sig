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

(* A Negotiation functor is constructed with a higher level layer (Integrity)
 * A Negotiation object (new) is constructed with a lower level rts (Transport)
 *)
signature NEGOTIATION =
   sig
      type t
      type host
      type address
      
      type bits = {
         publickey : Suite.PublicKey.set,
         symmetric : Suite.Symmetric.set,
         noEncrypt : bool,
         resume    : bool
      }
      
      datatype event = UDP_OPEN_OK | UDP_OPEN_FAIL | ICMP_ACK_OK | ICMP_ACK_FAIL
      type args = { key     : Crypto.PrivateKey.t,
                    bits    : bits,
                    entropy : int -> Word8Vector.vector,
                    host    : Crypto.PublicKey.t * address -> host,
                    exist   : Crypto.PublicKey.t -> bool,
                    contact : host -> unit,
                    record  : event -> unit,
                    haveICMP    : bool,
                    forwardAckd : address -> unit,
                    sendICMP    : { to : address, from : address option,
                                    body : Word8Vector.vector } -> unit
                  }
      
      (* NaN -> destroy this channel *)
      val new : { rts       : Real32.real Signal.t, 
                  seed      : Word64.word,
                  busy      : bool } -> t
      
      (* Clear all events associated to the channel.
       * Unbind any attached host.
       *)
      val destroy: t -> unit
      
      (* Become actively interested in connection establishment 
       * The arguments host, exist, and contact are not needed.
       *)
      val connect : t * args -> unit
      
      (* Become ready to transmit a forward request. *)
      val forwardRequest : t * args * { destination : address, hello : Word8Vector.vector } -> unit
      (* Acknowledge the ICMP we received. *)
      val acknowledgeICMP : t * args -> unit
      
      (* Link layer reports the destination is unreachable *)
      val unreachable : t -> unit
      
      (* Returns the connected host (if any) *)
      val host : t -> host option
      
      val recv : t * address * args * Word8ArraySlice.slice * { icmp : bool } -> unit
      val pull : t * address * args * Word8ArraySlice.slice -> int * (bool -> unit)
   end
