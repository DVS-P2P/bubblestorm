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

structure ICMP4SetUID : ICMP_PRIMITIVE =
   struct
      type address = INetSock.sock_addr
      
      fun new (udpSock, ready) =
         let
            (* Determine the local UDP port *)
            val self = Socket.Ctl.getSockName udpSock
            val (_, myport) = INetSock.fromAddr self
            
            (* check helper files *)
            fun checkFile name =
               Posix.IO.close (
                  Posix.FileSys.openf (name, Posix.FileSys.O_RDONLY, Posix.FileSys.O.fromWord 0w0))
            val () = checkFile "/usr/bin/cusp-icmp-recv"
            val () = checkFile "/usr/bin/cusp-icmp-send"
            
            fun close () = ()
            
            fun newR () =
               let
                  val (sock, helper) = UnixSock.Strm.socketPair ()
                  val helper = 
                     case Posix.Process.fork () of
                        SOME pid => (Socket.close helper; pid)
                      | NONE =>
                        let
                           val dup2 = _import "bs_dup2" public : (UnixSock.unix, Socket.active Socket.stream) Socket.sock * int -> int;
                           val () = Socket.close sock
                           val _ = dup2 (helper, 1)
                           val () = Socket.close helper
                           val () = Posix.Process.exec ("/usr/bin/cusp-icmp-recv", [ "cusp-icmp-recv", Int.toString myport ])
                        in
                           raise Fail "Could not execute!"
                        end
                  
                  val { length, parseSlice, ... } = Serial.methods ICMP4ctl.recv
                  val buffer = Array.array (length, 0w0)
                  
                  fun recv slice =
                     case Socket.recvArrNB (sock, Word8ArraySlice.full buffer) of
                        NONE => NONE
                      | SOME 0 => raise At ("ICMP4SetUID", Fail "The cusp-icmp-recv program died!")
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
                  val unhook = Main.registerSocketForRead (desc, go)
                  
                  fun closeR () = 
                     if unhook ()
                     then (Socket.close sock
                           ; Posix.Process.kill (Posix.Process.K_PROC helper, 
                                                 Posix.Signal.kill))
                     else ()
               in
                  { closeR=closeR, recv=recv }
               end
            
            fun newS () =
               let
                  fun send { UDPto, UDPfrom, code, data } = 
                     let
                        val UDPto = IPv4.toString UDPto
                        val UDPfrom = IPv4.toString UDPfrom
                        val code = Int.toString (Word16.toInt code)
                        val proc = 
                           Unix.execute ("/usr/bin/cusp-icmp-send", 
                                         [ UDPto, UDPfrom, code ])
                        val os = Unix.binOutstreamOf proc
                        val () = BinIO.output (os, Word8ArraySlice.vector data)
                        val () = BinIO.closeOut os
                        val status = Unix.reap proc
                     in
                        if OS.Process.isSuccess status then () else
                        TextIO.output (TextIO.stdErr, "Execution of cusp-icmp-send failed! Ensure it is setuid root\n")
                     end
                     handle exn as OS.SysErr (_, SOME code) =>
                     if code = Posix.Error.noent
                     then TextIO.output (TextIO.stdErr, "Failed to find cusp-icmp-send! Ensure it is in /usr/bin\n")
                     else raise exn
                  
                  fun closeS () = ()
               in
                  { closeS = closeS, send=send }
               end
         in
            { close=close, newR=newR, newS=newS }
         end
   end
