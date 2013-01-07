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

structure NodeUdp :> NATIVE_UDP where type Address.t = Address.t =
   struct
      structure Address = Address
      
      type ptr = MLton.Pointer.t
      datatype t = T of {
         node : Node.t,
         port : Word16.word,
         udpPtr : ptr
      }
      
      (* function imports *)
      val cUdpNew = _import "c_udp_new" : (ptr * Word16.word * int) -> ptr;
      val cUdpClose = _import "c_udp_close" : (ptr * ptr) -> unit;
      val cUdpSend = _import "c_udp_send" : (ptr * ptr * Word32.word * Word16.word * Word8Array.array * int * int) -> bool;
      val cUdpRecv = _import "c_udp_recv" : (ptr * ptr * Word32Array.array * Word8Array.array * int * int) -> int;
      
      val recvCbBucket : (Node.t * (unit -> unit)) IdBucket.t = IdBucket.new ()
      
      fun recvCallback cbHandle =
         case IdBucket.sub (recvCbBucket, cbHandle) of
            SOME (node, cb) => Node.runInContext (SOME node, cb)
          | NONE => raise Fail "Invalid recv callback handle"
      val () = _export "bs_udp_recv_callback" : (int -> unit) -> unit; recvCallback
      
      fun close (T { udpPtr, ... }) =
         cUdpClose (Node.context (Node.currentNode ()), udpPtr)
      
      fun new (port, userCb) =
         let
            val port = case port of
               SOME x => Word16.fromInt x
             | NONE => 0w0 (* TODO *)
            val node = Node.currentNode ()
            val cbHandle = IdBucket.alloc (recvCbBucket, (node, userCb))
            val udpPtr = cUdpNew (Node.context node, port, cbHandle)
            val this = T { node=node, port=port, udpPtr=udpPtr }
            val _ = Node.addCleanupFunction (node, fn () => close this)
         in
            this
         end
      
      val maxMTU = (*1492*) 1300
      fun mtu _ = maxMTU
      
      fun send (T { udpPtr, ... }, address, data) =
         let
(*             val () = print "send\n" *)
            val ctx = Node.context (Node.currentNode ())
            val ip = Address.Ip.toWord32 (Address.ip address)
            val port = Address.port address
            val (arr, ofs, len) = Word8ArraySlice.base data
         in
            cUdpSend (ctx, udpPtr, ip, port, arr, ofs, len)
         end
      
      fun recv (T { udpPtr, ... }, buffer) =
         let
(*             val () = print "recv\n" *)
            val ctx = Node.context (Node.currentNode ())
            val (arr, ofs, len) = Word8ArraySlice.base buffer
            val addrData = Word32Array.tabulate (2, fn _ => 0w0)
            val read = cUdpRecv(ctx, udpPtr, addrData, arr, ofs, len)
            val addr = Address.fromIpPort(
               Address.Ip.fromWord32 (Word32Array.sub (addrData, 0)),
               (Word16.fromLarge o Word32.toLarge) (Word32Array.sub (addrData, 1)))
(*             val () = print ("recv from " ^ Address.toString addr ^ "\n") *)
         in
            if (read > 0)
            then SOME (addr, Word8ArraySlice.subslice (buffer, 0, SOME read))
            else NONE
         end
      
      fun recvICMP (_, _) = NONE
      fun sendICMP (_, _) = ()
      
      fun localName (T { port, ... }) = Address.invalidIP port
      
   end
