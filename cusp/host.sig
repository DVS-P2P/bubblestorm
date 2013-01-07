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

(* A Host is a hook to the local information about a remote peer.
 * Hosts are automatically destroyed when there are no open streams or listeners.
 * Any attempt to listen or connect on a destroyed Host will trigger the
 * HostIsDestroyed exception. If you intend to use a host again later, then
 * make sure you have at least one stream or listener used.
 *)
signature HOST =
   sig
      type t
      type address
      type instream
      type outstream
      type publickey
      type service = Word16.word
      
      (* Iterate over non-reset streams attached to this host *)
      val inStreams  : t -> instream  Iterator.t
      val outStreams : t -> outstream Iterator.t
      
      (* Query how much data is buffered. 
       * Be advised that queuedOutOfOrder and queuedInflight may exceed the
       * sum of these buffers from read/outStreams due to reset streams that
       * still consume buffers.
       *)
      val queuedOutOfOrder   : t -> int (* Received, but unreadable *)
      val queuedUnread       : t -> int (* Received, waiting to be read *)
      val queuedInflight     : t -> int (* Inflight awaiting acknowledgment *)
      val queuedToRetransmit : t -> int (* Lost and waiting to be retransmit *)
      
      (* Total traffic sent through this host (including stream headers) *)
      val bytesSent     : t -> LargeInt.int
      val bytesReceived : t -> LargeInt.int
      val lastSend      : t -> Time.t
      val lastReceive   : t -> Time.t
      
      (* The public key of the connected host. *)
      val key : t -> publickey
      (* The remote address, if the host is contacted. *)
      val remoteAddress : t -> address option
      val localAddress : t -> address option
      (* Watch for renegotiation, aka. changed {remote,local}Addresses.
       * If there is a change the passed callback is run.
       * Returned is a handle to unhook the callback.
       *)
      val onAddressChange : t * (unit -> unit) -> (unit -> unit)
      
      (* Connect to this host *)
      val connect : t * service -> outstream
      
      (* Listen for connections from (only) this host.
       * The returned service name is dynamically assigned.
       * If there are too many listeners bound, then AddressInUse is raised.
       *)
      val listen : t * (service * instream -> unit) -> service
      val unlisten: t * service -> unit
   end
