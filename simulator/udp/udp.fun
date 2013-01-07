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

functor UdpSim(Base : IP_STACK) :> NATIVE_UDP where type Address.t = Address.t =
   struct
      fun module () = "simulator/udp"
				
      (* A hash table to find the receiver callback of a socket;
         used to demultiplex incoming messages and deliver them to the
         correct receiver. *)
      structure SocketKey =
         struct
            type t = Word16.word
            val op == = op =
            val hash = Hash.word16
         end
      structure SocketTable = HashTable(SocketKey)

      (* A hash table to find the IP stack of a node;
         used to find the corresponding IP stack of a newly created socket. *)
      structure NodeIdKey =
         struct
            type t = int
            val op == = op =
            val hash = Hash.int
         end
      structure HostTable = HashTable(NodeIdKey)

      type callback = Address.t * Routing.message -> unit
      
      (* The IP stack with a table to demultiplex incoming messages;
         there is at most one stack per node. *)
      datatype stack = STACK of {
         base : Base.t,
         sockets : callback SocketTable.t,
         statTrafficUp : Statistics.t,
         statTrafficDown : Statistics.t,
         statRawTrafficUp : Statistics.t,
         statRawTrafficDown : Statistics.t
      }
      type icmpMsg = {
         UDPto    : Address.t,
         reporter : Address.t,
         code     : Word16.word,
         data     : Word8ArraySlice.slice
      }
      
      (* this type describes an UDP socket and refers to the IP stack of the node. *)
      datatype t = T of {
         port      : Word16.word,
         udpQueue  : (Address.t * Word8ArraySlice.slice) option ref,
         icmpQueue : icmpMsg option ref,
         stack     : stack,
         unhook    : (unit -> unit) Ring.element
      }
      
      fun localName (T { port, ... }) = Address.invalidIP port

      exception AddressInUse
      
      (* This is raised if the assembled UDP chain has delays *) 
      exception BadReceiveTime
      
      (* Mapping SimulatorNodes to UDP stacks *)
      val hostTable = HostTable.new ()
      
      val maxMTU = 1472
      fun mtu _ = maxMTU
      
      fun logMessage (msg, mode, host) =
         let
            fun logtext () = 
               case msg of
                  Routing.UDP data =>
                     "UDP packet of length " ^ (Int.toString (Word8ArraySlice.length data)) ^ 
                     "  " ^ mode ^ " " ^ (Address.toString host) ^ " with content = " ^
                     (WordToString.fromBytes (Word8ArraySlice.vector data))
                | Routing.ICMP {UDPto, code, data} =>
                     "ICMP packet of length " ^ (Int.toString (Word8ArraySlice.length data)) ^ 
                     "  " ^ mode ^ " " ^ (Address.toString host) ^ " with code = " ^
                     (Word16.toString code) ^ " UDPto = " ^ (Address.toString UDPto) ^
                     "content = " ^ (WordToString.fromBytes (Word8ArraySlice.vector data))
         in
            Log.logExt (Log.DEBUG, fn () => "packets", logtext)
         end
      
      fun doRecv queue =
         case !queue of
            NONE => NONE
          | SOME x => (queue := NONE; SOME x)

      fun recv (T { udpQueue, ... }, _) = doRecv udpQueue
      fun recvICMP  (T { icmpQueue, ... }, _) = doRecv icmpQueue
      
      fun doSend (stack, port, receiver, msg, size) =
         let
            val () = logMessage (msg, "sent to", receiver)
            val STACK { base, statRawTrafficUp, ... } = stack
            val () = Statistics.add statRawTrafficUp (Real32.fromInt size)
         in
            Base.send {
               stack = base,
               port = port,
               receiver = receiver,
               data = msg,
               size = size,
               when = Experiment.Event.time ()
            }
         end

      fun sendInternal (stack, port, receiver, buffer) =
         let
            (* copy the buffer to avoid future manipulation by the sender *)
            val len = Word8ArraySlice.length buffer
            val copy = 
               Word8Array.tabulate 
               (len, fn i => Word8ArraySlice.sub (buffer, i))
            val copy = Word8ArraySlice.full copy
            val msg = Routing.UDP copy
            (* IP + UDP headers *)
            val size = 20 + 8 + len
         in
            doSend (stack, port, receiver, msg, size)
         end
                  
      fun send (udp, receiver, buffer) =
         let
            val T { stack, port, ... } = udp
            val STACK { statTrafficUp, ... } = stack
            val () = Statistics.add statTrafficUp ((Real32.fromInt o Word8ArraySlice.length) buffer)
            val () = sendInternal (stack, port, receiver, buffer)
         in
            true
         end
         
      fun sendICMPInternal (stack, { UDPto, UDPfrom, code, data }) =
         let
            (* copy the buffer to avoid future manipulation by the sender *)
            val copy = 
               Word8Array.tabulate 
               (Word8ArraySlice.length data, 
                fn i => Word8ArraySlice.sub (data, i))
            val copy = Word8ArraySlice.full copy
            val msg = Routing.ICMP { UDPto=UDPto, code=code, data=copy }
            (* IP + ICMP + inner IP + UDP headers *)
            val size = 20 + 8 + 20 + 8 + (Word8ArraySlice.length copy)
         in
            doSend (stack, 0w0, UDPfrom, msg, size)
         end

      fun sendICMP (T { stack, ... }, icmp) =
         sendICMPInternal (stack, icmp)
               
      (* remove simulator internal data like time *)
      fun discardInternals { sender, port, data, size=_, when } =
         if Time.== (when, Experiment.Event.time ()) then
            let
               val () = logMessage (data, "received from", sender)
            in
               (port, (sender, data))
            end
         else raise BadReceiveTime
      
      (* map the message to the receiver socket *)
      fun demultiplex (sockets, (port, message as (sender, data))) =
         case (SocketTable.get (sockets, port), data) of
            (SOME callback, _) => callback message (* deliver the message *)
          | (NONE, Routing.UDP data) => (* unbound port -> send ICMP port unreachable *)
            let
               val node = SimulatorNode.current ()
               val stack = getStack node
               val ip =
                  case SimulatorNode.currentAddress node of
                     SOME x => x
                   | NONE => raise At (module (), Fail "Receiving node has no address")
            in
               sendICMPInternal (stack, {
                  UDPto = Address.fromIpPort (ip, port),
                  UDPfrom = sender,
                  code = 0wx32, (* destination port unreachable *)
                  data = data
               })
            end
          | (NONE, Routing.ICMP _) => () (* undelivered ICMP messages do not trigger ICMP responses *)
            
      (* build the underlying stack *)
      and buildStack () =
         let
            val sockets = SocketTable.new ()
            val push = Statistics.distill (Statistics.byLogInterval Statistics.sum)
            val statTrafficUp =
               Statistics.new {
                  parents = [ (UdpStatistics.statUDPTrafficUp (), push) ],
                  name = "simulator/UDP message sizes up",
                  units = "bytes",
                  label = "UDP message sizes up",
                  histogram = Statistics.NO_HISTOGRAM,
                  persistent = false
               }
            val statTrafficDown =
               Statistics.new {
                  parents = [ (UdpStatistics.statUDPTrafficDown (), push) ],
                  name = "simulator/UDP message sizes down",
                  units = "bytes",
                  label = "UDP message sizes down",
                  histogram = Statistics.NO_HISTOGRAM,
                  persistent = false
               }
            val statRawTrafficUp =
               Statistics.new {
                  parents = [ (UdpStatistics.statRawTrafficUp (), push) ],
                  name = "simulator/raw message sizes up",
                  units = "bytes",
                  label = "UDP message sizes up",
                  histogram = Statistics.NO_HISTOGRAM,
                  persistent = false
               }
            val statRawTrafficDown =
               Statistics.new {
                  parents = [ (UdpStatistics.statRawTrafficDown (), push) ],
                  name = "simulator/raw message sizes down",
                  units = "bytes",
                  label = "UDP message sizes down",
                  histogram = Statistics.NO_HISTOGRAM,
                  persistent = false
               }
         in
            STACK {
               base = Base.bind (fn x => demultiplex (sockets, discardInternals x)),
               sockets = sockets,
               statTrafficUp = statTrafficUp,
               statTrafficDown = statTrafficDown,
               statRawTrafficUp = statRawTrafficUp,
               statRawTrafficDown = statRawTrafficDown
            }
         end
      
      and getStack node =
         let
            val id = SimulatorNode.id node
         in
            case HostTable.get (hostTable, id) of
               SOME stack => stack
             | NONE => (* first socket of this node, create stack *)
                  let
                     val stack = buildStack ()
                     val () = HostTable.add (hostTable, id, stack)
                  in
                     stack
                  end
         end
         
      fun randomPort (sockets, retries) =
         if retries > 0 then
            let
               (* registered ports: 1024 - 49152 *)
               val min = 0w1024
               val max = 0w49153
               val random = SimulatorNode.random (SimulatorNode.current ())
               val socket = min + Random.word16 (random, SOME (max - min))
            in
               case SocketTable.get (sockets, socket) of
                  (* hash table collision, try again *)
                  SOME _ => randomPort (sockets, retries - 1)
                | NONE => socket
            end
         else raise At ("simulator/udp/random-port",
                 Fail "Could not find an unused port.")
                     
      fun close (T fields) = 
         let
            (* delete cleanup method *)
            val () = Ring.remove (#unhook fields)
            (* remove socket from underlying stack *)
            val stack = case (#stack fields) of STACK x => x
            val sockets = #sockets stack
            val _ = SocketTable.remove (sockets, #port fields)
         in
            if SocketTable.isEmpty sockets then
               let
                  (* no more open sockets -> close IP stack *)
                  val node = SimulatorNode.current ()
                  val _ = HostTable.remove (hostTable, SimulatorNode.id node)
               in
                  Base.close (#base stack)
               end
            else () 
         end
      
      fun new (port, userCb) =
         let
            val node = SimulatorNode.current ()
            (* determine port number *)
            val stack = getStack node
            val sockets = #sockets (case stack of STACK x => x)
            val port = case port of
                          SOME x => Word16.fromInt x
                        | NONE => randomPort (sockets, 50000)
            val udpQueue = ref NONE
            val icmpQueue = ref NONE
            val statTrafficDown = #statTrafficDown (case stack of STACK x => x)
            val statRawTrafficDown = #statRawTrafficDown (case stack of STACK x => x)
            fun callback (sender, Routing.UDP data) =
               let
                  (* receive statistics *)
                  val len = Word8ArraySlice.length data
                  val () = Statistics.add statTrafficDown (Real32.fromInt len)
                  val rawSize = 20 + 8 + len
                  val () = Statistics.add statRawTrafficDown (Real32.fromInt rawSize)

                  val () = udpQueue := SOME (sender, data)
               in
                  userCb ()
               end
              | callback (reporter, Routing.ICMP { UDPto, code, data }) =
               let
                  (* receive statistics *)
                  val len = Word8ArraySlice.length data
                  val rawSize = 20 + 8 + 20 + 8 + len
                  val () = Statistics.add statRawTrafficDown (Real32.fromInt rawSize)
                  
                  val () = icmpQueue := SOME {
                     UDPto = UDPto,
                     reporter = reporter,
                     code = code,
                     data = data
                  }
               in
                  userCb ()
               end
            (* register the socket with the stack *)
            val () = SocketTable.add (sockets, port, callback)
                        handle SocketTable.KeyExists => raise AddressInUse
            (* register the close function in the simulator node *)
            val unhook = Ring.wrap (fn () => ())
            val () = Ring.add (SimulatorNode.cleanupFunctions node, unhook)
            val udp = T {
                         port = port,
                         stack = stack,
                         unhook = unhook,
                         udpQueue = udpQueue,
                         icmpQueue = icmpQueue
                      }
            val () = Ring.update (unhook, fn () => close udp)
         in
            udp 
         end

      structure Address : ADDRESS = Address
   end
