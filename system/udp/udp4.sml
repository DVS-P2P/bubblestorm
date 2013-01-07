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

structure UDP4 :> NATIVE_UDP =
   struct
      structure Address = IPv4

      datatype t = T of {
         socket   : INetSock.dgram_sock,
         icmp     : ICMP4.t,
         unhook   : unit -> bool }

      exception AddressInUse

      fun send (T { socket, ... }, destination, buffer) =
         (Socket.sendArrTo (socket, destination, buffer); true)
         (* Trap an MTU exceeded exception *)
         handle exn as OS.SysErr (_, SOME code) =>
         if code = Posix.Error.msgsize then false else raise exn
      
      fun recv (T { socket, ... }, buffer) =
         case Socket.recvArrFromNB (socket, buffer) of
            NONE => NONE
          | SOME (len, sender) =>
            let
               val data = Word8ArraySlice.subslice (buffer, 0, SOME len)
            in
               SOME (sender, data)
            end

      fun new (port, cb) =
         let
            val sock = INetSock.UDP.socket ()
            val desc = Socket.sockDesc sock
            
            fun ready () = (ignore (cb ()); Main.REHOOK)

            val addr = INetSock.any (getOpt (port, 0))
            val () = Socket.bind (sock, addr)
                     handle OS.SysErr _ => (Socket.close sock; raise AddressInUse)
         in
            T {
               socket   = sock,
               icmp     = ICMP4.new (sock, cb),
               unhook   = Main.registerSocketForRead (desc, ready)
            }
         end

      fun close (T { socket, icmp, unhook, ... }) =
         if unhook () 
         then (ICMP4.close icmp; Socket.close socket) 
         else ()

      val maxMTU = 1468 (* ethernet - ip - udp - PPPoE *)
      fun mtu _ = maxMTU
      
      fun recvICMP (T { icmp, ... }, slice) = ICMP4.recv (icmp, slice)
      fun sendICMP (T { icmp, ... }, args) = ICMP4.send (icmp, args)
      
      fun localName (T { socket, ... }) = Socket.Ctl.getSockName socket
   end
