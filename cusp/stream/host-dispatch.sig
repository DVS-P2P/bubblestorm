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

signature HOST_DISPATCH =
   sig
      include HOST 
      where type instream = InStreamQueue.t
      where type outstream = OutStreamQueue.t
      where type publickey = Crypto.PublicKey.t
      
      val recv: t * Word8ArraySlice.slice -> bool (* true -> packet ok *)
      val pull: t * Word8ArraySlice.slice -> int * (bool -> unit)
      
      val new: {
         key           : publickey,
         localAddress  : address,
         remoteAddress : address,
         global        : Word16.word -> (t * InStreamQueue.t -> unit) option,
         reconnect     : address -> unit
      }-> t
      val updateAddress : t * { localAddress : address, remoteAddress : address }-> unit
      
      (* (Un)bind a Host to a channel *)
      val bind: t * (Real32.real -> unit) -> unit
      val unbind: t -> unit
      val isBound: t -> bool
      
      (* If a channel is negotiated with no prior state, then all instreams
       * must be reset and all outstreams older than the last unbind.
       *)
      val wipeState : t -> unit
      val isZombie  : t -> bool
      
      (* Only kept alive by a weak pointer *)
      val effectivelyDead : t -> bool
      (* Force a node (even one effectively dead) to stay alive *)
      val poke : t -> unit
      
      (* Kill off as much state as possible.
       * Cancel all events. Reset all streams.
       *)
      val destroy : t -> unit
   end
