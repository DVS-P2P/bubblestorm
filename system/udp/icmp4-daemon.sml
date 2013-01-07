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

structure ICMP4Daemon : ICMP_PRIMITIVE =
   struct
      type address = INetSock.sock_addr
      
      fun new (udpSock, ready) =
         let
            (* Determine the local UDP port *)
            val self = Socket.Ctl.getSockName udpSock
            val (_, myport) = INetSock.fromAddr self
            
            (* Setup a TCP socket to connect to the daemon *)
            val sock = INetSock.TCP.socket ()
            fun close () = Socket.close sock
            
            (* Connect to the daemon *)
            val host = valOf (NetHostDB.fromString "127.0.0.1")
            val service = INetSock.toAddr (host, 8585)
            val () = Socket.connect (sock, service)
                     handle x => (close (); raise x)
            
            fun newR () =
               let
                  val { length, parseSlice, ... } = Serial.methods ICMP4ctl.recv
                  
                  val buffer = Array.array (length, 0w0)
                  val { writeSlice=write16b, ... } = Serial.methods Serial.word16b
				  
                  (* Enable listening on our port *)
                  val toport = Word8ArraySlice.slice (buffer, 8, SOME 2)
                  val () = write16b (toport, Word16.fromInt myport)
                  val _ = Socket.sendArr (sock, Word8ArraySlice.full buffer)
                  
                  fun recv slice =
                     case Socket.recvArrNB (sock, Word8ArraySlice.full buffer) of
                        NONE => NONE
                      | SOME x =>
                        (* Now blocking receive the rest of the ICMP message *)
                        let
                           val tail = Word8ArraySlice.slice (buffer, x, NONE)
                           val () = ICMP4ctl.recvFully (sock, tail)
                           
                           val { reporter, UDPto, code, len } = 
                              parseSlice (Word8ArraySlice.full buffer)
                           
                           val data = Word8ArraySlice.subslice (slice, 0, SOME len)
                           val () = ICMP4ctl.recvFully (sock, data)
                        in
                           SOME {
                              reporter = reporter,
                              UDPto    = UDPto,
                              code     = code,
                              data     = data
                           }
                        end
                  
                  val desc = Socket.sockDesc sock
                  fun go () = (ignore (ready ()); Main.REHOOK)
                  val closeR = ignore o (Main.registerSocketForRead (desc, go))
               in
                  { recv=recv, closeR=closeR }
               end
            
            fun newS () =
               let
                  val { toVector, ... } = Serial.methods ICMP4ctl.send
                  fun send { UDPto, UDPfrom, code, data } =
                     let
                        val msg = toVector {
                           UDPto   = UDPto,
                           UDPfrom = UDPfrom,
                           code    = code,
                           len     = Word8ArraySlice.length data
                        }
                        
                        val _ = Socket.sendVec (sock, Word8VectorSlice.full msg)
                        val _ = Socket.sendArr (sock, data)
                     in
                        ()
                     end
                  
                  fun closeS () = ()
               in
                  { send=send, closeS=closeS }
               end
         in
            { close=close, newR=newR, newS=newS }
         end
   end
