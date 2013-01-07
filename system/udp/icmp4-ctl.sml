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

local
   open Serial
   
   val { toVector, fromVector, ... } = Serial.methods word32b
   val message = aggregate tuple6 `word32b `word32b `word16b `word16b `word16b `word16b $
   fun fromAddr addr =
      case INetSock.fromAddr addr of (ip, port) =>
      (fromVector (MLton.Socket.Address.toVector ip), port)
   fun toAddr (ip, port) =
      INetSock.toAddr (MLton.Socket.Address.fromVector (toVector ip), port)
in
   structure ICMP4ctl =
      struct
         fun recvFully (sock, slice) =
            if Word8ArraySlice.isEmpty slice then () else
            let
               val got = Socket.recvArr (sock, slice)
               val tail = Word8ArraySlice.subslice (slice, got, NONE)
            in
               recvFully (sock, tail)
            end
         
         val send = Serial.map {
            store = fn { UDPfrom, UDPto, code, len } =>
                    case (fromAddr UDPfrom, fromAddr UDPto) of
                    ((from, fromport), (to, toport)) =>
                    (from, to, Word16.fromInt fromport, Word16.fromInt toport, 
                     code, Word16.fromInt len),
            load  = fn (from, to, fromport, toport, code, len) =>
                    { UDPfrom = toAddr (from, Word16.toInt fromport),
                      UDPto = toAddr (to, Word16.toInt toport),
                      code = code, len = Word16.toInt len },
            extra = fn () => ()
         } message
         
         val recv = Serial.map {
            store = fn { reporter, UDPto, code, len } =>
                    { UDPfrom=reporter, UDPto=UDPto, code=code, len=len },
            load  = fn { UDPfrom, UDPto, code, len } =>
                    { reporter=UDPfrom, UDPto=UDPto, code=code, len=len },
            extra = fn () => ()
         } send
      end
end
