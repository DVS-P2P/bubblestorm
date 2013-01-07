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

functor MessageRouter(NetworkModel : NETWORK_MODEL) :> IP_STACK =
   struct
      val module = "simulator/udp/message-router"
   
      structure NetworkModel = NetworkModel

      type t = unit

      fun sendICMPunreachable { sender, receiver, code, target, port, data, when } =
         case data of
            (* undelivered ICMP messages do not trigger ICMP responses *)
            Routing.ICMP _ => () 
          | Routing.UDP data =>
               let
                  val msgHandler = SimulatorNode.messageHandler receiver
               in
                  msgHandler {
                     sender = sender,
                     port = port,
                     data = Routing.ICMP { UDPto = target, code = code, data = data },
                     size = 20 + 8 + 20 + 8 + (Word8ArraySlice.length data),
                     when = Time.+ (when, Time.fromSeconds 3) (* ~3 seconds for the ARP timeout *)
                  }
               end

      (* receiver is gone, reply with a destination unreachable ICMP *)
      fun triggerICMPdestUnreachable (sender, receiver, port, data, when) =
         sendICMPunreachable {
            sender = Address.invalid, (* is sent by "the network" *)
            receiver = sender,
            code = 0wx31,
            target = receiver,
            port = port,
            data = data,
            when = when
         }

      (* receiver has not bound the given port *)
      fun triggerICMPportUnreachable (sender, receiver, data, when) =
         sendICMPunreachable {
            sender = Address.invalidPort (Address.ip receiver), (* is sent by the receiver *)
            receiver = AddressTable.get (Address.ip sender),
            code = 0wx32,
            target = receiver,
            port = Address.port sender,
            data = data,
            when = when
         }
         handle Routing.HostUnreachable => () (* sender went offline in the meantime *)

      (* flip a single bit in a byte *)
      (*fun flipBit (word8 : Word8.word, bit) =
         Word8.xorb (word8, Word8.<< (0w1, bit))*)

      (* flip a number of bits in the given data (to simulate packet corruption) *)
      (*fun corrupt (data, 0) = data
      |   corrupt (data, bitErrors) =
         let
            val random = SimulatorNode.random (SimulatorNode.current ())
            val pos = Random.int (random, Word8ArraySlice.length data)
            val bit = Random.word (random, SOME 0w8)
            val original = Word8ArraySlice.sub (data, pos)
            val corrupted = flipBit (original, bit)
            val () = Word8ArraySlice.update (data, pos, corrupted)
         in
            corrupt (data, bitErrors - 1)
         end*)

      (* connects the bottom of the sender UDP stack with the bottom of receiver IP stack *)
      fun route (receiver, receiverCallback, sender, data, size, when) (delay, _) =
         if Time.>= (delay, Time.zero) then
            receiverCallback {
               sender = sender,
               port = Address.port receiver,
               data = data (*corrupt (data, bitErrors)*),
               size = size,
               when = Time.+ (when, delay)
            }         
            handle Routing.PortUnreachable =>
               triggerICMPportUnreachable (sender, receiver, data, when)
         else 
            raise At (module ^ "/route", Fail ("NetworkModel gave a negative delay of " 
                  ^ (Time.toString delay) ^ "."))

      (* before finally dispatching the message to the receiver, the network model is applied *)
      fun send { stack=(), port, receiver, data, size, when } =
         let
            (* determine sender address *)
            val source = SimulatorNode.current ()
            val sender = case SimulatorNode.currentAddress source of
               SOME x => x
             | NONE => raise At (module ^ "/send", 
                  Fail ("Offline node " ^ (SimulatorNode.toString source) ^
                     " at port " ^ (Word16.fmt StringCvt.DEC port) ^ 
                     " tries to send a message to address " ^ 
                     (Address.toString receiver) ^ ".\n"))
           (* get receiver *)
           val dest = AddressTable.get (Address.ip receiver)
           val msgHandler = SimulatorNode.messageHandler dest
           (* let the network model stack do every imageinable mean
              thing to the message (loss, duplication, delay, corruption)
              and deliver the resulting list of delays and bit errors. *)
            val delay = NetworkModel.route (source, dest)
            val sourceAddr = Address.fromIpPort (sender, port)
         in
            List.app (route (receiver, msgHandler, sourceAddr, data, size, when)) delay
         end
         handle Routing.HostUnreachable => 
            triggerICMPdestUnreachable (SimulatorNode.current (), receiver, port, data, when)

      val bind = SimulatorNode.setMessageHandler
      val close = SimulatorNode.removeMessageHandler
   end