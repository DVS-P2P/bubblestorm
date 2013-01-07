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

structure ICMP4FFI : ICMP_PRIMITIVE =
   struct
      type address = INetSock.sock_addr
      
      fun new (sock, _) = 
         let
            type t = MLton.Pointer.t
            
            val icmp_open =
               _import "cusp_icmp_open" public : INetSock.dgram_sock -> t;
            val icmp_close =
               _import "cusp_icmp_close" public : t -> int;
            
            val state = 
               let
                  val out = icmp_open sock
               in
                  if out = MLton.Pointer.null
                  then raise Fail "couldn't open ICMP FFI"
                  else out
               end
               
            fun close () = 
               let
                  val out = icmp_close state
               in
                  if out = ~1 
                  then raise Fail "couldn't close ICMP FFI"
                  else ()
               end
            
            fun newR () = 
               let
                  val icmp_recv =
                     _import "cusp_icmp_recv" public : t *
                        Word8Array.array * int * int *
                        Word8Array.array * 
                        Word8Array.array * int ref *
                        Word16.word ref -> int;
                  
                  fun recv slice =
                     let
                        val (udp, udpoff, udplen) = Word8ArraySlice.base slice
                        val reporter = Array.array (4, 0w0)
                        val UDPto = Array.array (4, 0w0)
                        val UDPtoport = ref 0
                        val ICMPcode = ref 0w0
                        val udplen =
                           icmp_recv (state, udp, udpoff, udplen, 
                                      reporter, UDPto, UDPtoport, ICMPcode)
                        fun addr (ip, port) =
                           let
                              val ip = Word8Array.vector ip
                              val ip = MLton.Socket.Address.toVector ip
                           in
                              INetSock.toAddr (ip, port)
                           end
                     in
                        if udplen = ~1 orelse udplen = 65535 then NONE else (* 65535 is returned on Android instead of -1 :/ *)
                        SOME {
                           reporter = addr (reporter, 0),
                           UDPto    = addr (UDPto, !UDPtoport),
                           code     = !ICMPcode,
                           data     = Word8ArraySlice.subslice (slice, 0, SOME udplen)
                        }
                     end
                  
                  fun closeR () = ()
               in
                  { recv=recv, closeR=closeR }
               end
            
            fun newS () = 
               let
                  val icmp_send =
                     _import "cusp_icmp_send" public : t *
                        Word8Array.array * int * int *
                        Word8Vector.vector * int *
                        Word8Vector.vector * int *
                        Word16.word -> int;
                  
                  fun send { UDPto, UDPfrom, code, data } =
                     let
                        val (udp, udpoff, udplen) = Word8ArraySlice.base data
                        val (to, toport) = INetSock.fromAddr UDPto
                        val (from, fromport) = INetSock.fromAddr UDPfrom
                        val to = MLton.Socket.Address.fromVector to
                        val from = MLton.Socket.Address.fromVector from
                        val ok =
                           icmp_send (state, udp, udpoff, udplen, 
                                      to, toport, from, fromport, code)
                     in
                        if ok = 0 then () else
                        raise Fail "couldn't send ICMP"
                     end
                  
                  fun closeS () = ()
               in
                  { send=send, closeS=closeS }
               end
         in
            if MLton.Pointer.null = state
            then raise Fail "couldn't open ICMP" 
            else { close=close, newR=newR, newS=newS }
         end
   end
