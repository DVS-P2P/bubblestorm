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

structure IPv4 : ADDRESS =
   struct
      type t = INetSock.sock_addr

      local
         (* We pull some scary shit here to make addresses 16-bit
          * aligned only (so 2* an address fit nicely) and to make
          * certain we can parse relatively quickly.
          *)
         open Serial
         (* An address is fundamentally an (ip, port) *)
         val t = aggregate tuple2 `(vector (word8, 4)) `word16b $
         (* ... however, we need to convert in/out of a MLton address *)
      in
         val t = map {
            store = fn addr =>
               let
                  val (netdb, port) = INetSock.fromAddr addr
                  val v = (*MLton.Socket.Address.toVector*) netdb
               in
                  (v, Word16.fromInt port)
               end,
            load  = fn (ip, port) =>
               let
                  val netdb = (*MLton.Socket.Address.fromVector*) ip
               in
                  INetSock.toAddr (netdb, Word16.toInt port)
               end,
            extra = fn _ => ()
         } t
      end

      fun toString addr = case INetSock.fromAddr addr of (ip, port) =>
         NetHostDB.toString ip ^ ":" ^ Int.toString port

      fun compare (a, b) =
         let
            val (aip, aport) = INetSock.fromAddr a
            val (bip, bport) = INetSock.fromAddr b
         in
            case Word8Vector.collate Word8.compare (aip, bip) of
               LESS => LESS
             | GREATER => GREATER
             | EQUAL => Int.compare (aport, bport)
         end
      structure Z = OrderFromCompare(type t = t val compare=compare)
      open Z

      fun hash x =
         let
            val (ip, port) = INetSock.fromAddr x
         in
            Hash.int port o
            Hash.word8vector ((*MLton.Socket.Address.toVector*) ip)
         end

      fun addrFromString str =
         case NetHostDB.fromString str of
            SOME addr => [addr]
          | NONE =>
                case NetHostDB.getByName str of
                  NONE => []
                | SOME entry => NetHostDB.addrs entry
      
      fun portFromString str =
         case Int.fromString str of
            SOME i => SOME i
          | NONE =>
            case NetServDB.getByName (str, SOME "udp") of
               NONE => NONE
             | SOME e => SOME (NetServDB.port e)
      
      fun addPort (ips, port) = 
         List.map (fn ip => INetSock.toAddr (ip, port)) ips
      
      fun fromStringSingle str =
         case String.fields (fn c => c = #":") str of
            [host, port] =>
               (case (addrFromString host, portFromString port) of
                   (ips, SOME port) => addPort (ips, port)
                 | _ => [])
          | [host] => addPort (addrFromString host, 8585)
          | _ => []
      
      fun fromString str = 
         List.concat (
            List.map fromStringSingle (String.fields (fn c => c = #",") str)
         )
         
      val zeroIP = valOf (NetHostDB.fromString "0.0.0.0")
      val invalid = INetSock.toAddr (zeroIP, 0)
      
      fun fix { incomplete, using } =
         let
            val (ipi, porti) = INetSock.fromAddr incomplete
            val (ipu, portu) = INetSock.fromAddr using
            val isZeroIP = Word8Vector.collate Word8.compare (ipi, zeroIP)
            val ip = case isZeroIP of EQUAL => ipu | _ => ipi
            val port = if porti = 0 then portu else porti
         in
            INetSock.toAddr (ip, port)
         end
   end
