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

signature END_POINT =
   sig
      type t
      type address
      type host
      type instream
      type outstream
      type publickey
      type privatekey
      type publickey_set
      type symmetric_set
      type service = Word16.word
      
      (* Create a local transport end-point bound to the provided port.
       * Handler receives any exceptions generated by UDP send/recv.
       * Entropy is used to generate ephemeral keys for channels.
       * May raise a transport-specific exception if port is already in use.
       *)
      type options = { 
         encrypt   : bool, 
         publickey : publickey_set,
         symmetric : symmetric_set
      }
      val new : { port    : int option, 
                  handler : exn -> unit,
                  entropy : int -> Word8Vector.vector,
                  key     : privatekey,
                  options : options option } -> t
      
      (* Cap the throughput of an endpoint *)
      val setRate : t * { rate : Real32.real, burst : Time.t } option -> unit
      
      (* Destroy the EndPoint and close the socket.
       * Any further use of EndPoint is undefined.
       *)
      val destroy : t -> unit
      (* Since this is a userland library, TIME_WAIT cannot happen after the
       * program exits. For a clean exit, an application should close all of
       * its streams and then call whenSafeToDestroy. The provided callback
       * will be invoked once all channels have been cleanly closed.
       * The returned callback unhooks the provided callback.
       *)
      val whenSafeToDestroy : t * (unit -> unit) -> (unit -> unit)
      
      (* Recover the end-point's private key *)
      val key : t -> privatekey
      
      (* Total traffic used on this transport (entire packets) *)
      val bytesSent     : t -> LargeInt.int
      val bytesReceived : t -> LargeInt.int
      
      (* Attempt to contact the remote host and Host.connect to it.
       * Returned is a handle that can be used to cancel the callback.
       * If the connection fails, NONE is returned.
       * Please confirm that the host's public key is as expected
       * before using the outstream.
       *)
      val contact : t * address * service * ((host * outstream) option -> unit) -> (unit -> unit)
      
      (* Lookup a host by public key or walk all of them *)
      val host   : t * publickey -> host option
      val hosts  : t -> host Iterator.t
      
      (* List all the addresses associated to a channel *)
      val channels : t -> (address * host option) Iterator.t
      
      (* Watch to see if our local address changes. 
       * This callback is called whenever our reported IP address differs
       * from the last reported IP address. In a multi-homed or NAT scenario
       * a node may have multiple addresses, causing this to flip-flop.
       *)
      val onAddressChange : t * (address -> unit) -> (unit -> unit)
      
      (* Advertise a service that can be connected to by any remote host.
       * If NONE is passed, the service name is dynamically assigned.
       * A well-known service name should have the high two bits cleared.
       * AddressInUse is raised if the named service is in use.
       * Service name 0 is reserved.
       *)
      val advertise : t * service option * (host * service * instream -> unit) -> service
      val unadvertise : t * service -> unit
      
      (* Deal with NAT hole-punching.
       *
       * This scheme requires:
       *   1) Anyone contacting a NAT'd peer duplicates their HELLO messages 
       *      and encapsulates the HELLO inside an ICMP message.
       *      This ICMP message pretends to originate from ONE designated IP 
       *      (fakeContact) that need not exist 'nat-contact.bubblestorm.net'
       *      ... doing this to contact non-NAT'd peers is harmless
       *   2) People behind NATs send UDP keep-alives to ALL IPs designated by
       *      their lifeLine 'nat-listen.bubblestorm.net' (includes fakeContact)
       *      ... it doesn't hurt if non-NAT'd nodes also do this
       *      ... {lifeLine} >= {fakeContact} allows seamless IP transition
       *   3) Those who cannot send an ICMP message themselves (behind a NAT)
       *      must request help from a peer who can
       *)
       datatype natMethod = 
          NAT_FAIL
        | NAT_ICMP of { fakeContact : address }
        | NAT_VIA  of { fakeContact : address, helper : unit -> address }
       val setNATPenetration : t * natMethod -> unit
       val setNATLifeLine    : t * string option -> unit
       
       (* If this peer can:
        *   (1) receive unsolicited UDP messages
        *   (2) send ICMP messages
        * ... then it can act as a 'helper' for peers who need NAT_VIA.
        * ... if (2) the peer can also stop using NAT_VIA itself
        * 
        * Whenever a condition changes, fire the status event.
        *)
       val canReceiveUDP  : t -> bool
       val canSendOwnICMP : t -> bool
       val watchStatus : t * (unit -> unit) -> (unit -> unit)
   end
