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

functor EndPoint(structure UDP   : PEERED_UDP
                 structure Log   : LOG
                 structure Event : EVENT
                 structure HostDispatch : HOST_DISPATCH
                    where type address = UDP.Address.t) 
   : END_POINT =
   struct
      structure HostTable = 
         HostTable(
            structure Event = Event
            structure Address = UDP.Address
            structure HostDispatch = HostDispatch)
      structure ChannelStack = 
         ChannelStack(
            structure Event = Event
            structure Log = Log
            structure Address = UDP.Address
            structure HostDispatch = HostDispatch)
      
      (* Public types *)
      type host = HostDispatch.t
      type instream = InStreamQueue.t
      type outstream = OutStreamQueue.t
      type service = Word16.word
      type privatekey = Crypto.PrivateKey.t
      type publickey = Crypto.PublicKey.t
      type publickey_set = Suite.PublicKey.set
      type symmetric_set = Suite.Symmetric.set
      type address = UDP.Address.t
      
      type options = { 
         encrypt   : bool, 
         publickey : publickey_set,
         symmetric : symmetric_set
      }
      
      (* Internals *)
      type channel = ChannelStack.t
      type listener = host option -> unit
      datatype record = 
         HOST of channel * listener Ring.t
       | LIFELINE
      type peer = record UDP.peer
      
      datatype natMethod =
         NAT_FAIL
       | NAT_ICMP of { fakeContact : address }
       | NAT_VIA  of { fakeContact : address, helper : unit -> address }
      
      datatype t = T of { 
         hosts         : HostTable.t,
         udp           : record UDP.t,
         zeroIP        : address,
         key           : Crypto.PrivateKey.t,
         bits          : ChannelStack.bits,
         entropy       : int -> Word8Vector.vector,
         seed          : Word64.word,
         bytesSent     : Counter.int ref,
         bytesReceived : Counter.int ref,
         natMethod     : natMethod ref,
         lifeLines     : peer vector ref,
         helperAddress : address ref,
         helperFailed  : int ref,
         helperTimer   : Event.t,
         ping          : Event.t,
         udpOpenRate   : Real32.real ref,
         icmpAckRate   : Real32.real ref,
         safeToDestroy : (unit -> unit) Ring.t,
         statusRing    : (unit -> unit) Ring.t }
      
      val ttl_expired = 0wx0b00
      val { parseSlice=parseAddress, length=addressLength, toVector=addressToVector, ... } = 
         Serial.methods UDP.Address.t
      
      fun safeExec ring a =
         Ring.app (fn r => (ignore (Ring.unwrap r a); Ring.remove r)) ring
      
      fun empty udp = 
         let
            fun host peer =
               case UDP.status (udp, peer) of
                  (_, HOST _, _) => true
                | _ => false
         in
            not (Iterator.exists host (UDP.peers udp))
         end
      
      fun whenSafeToDestroy (T { safeToDestroy, udp, ... }, cb) =
         if empty udp then (cb (); fn () => ()) else
         let
            val r = Ring.wrap cb
            val () = Ring.add (safeToDestroy, r)
         in
            fn () => Ring.remove r
         end
      
      fun channels (T { udp, ... }) =
         let
            fun channels peer =
               case UDP.status (udp, peer) of
                  (a, HOST (c, _), _) => SOME (a, ChannelStack.host c)
                | _ => NONE
         in
            Iterator.mapPartial channels (UDP.peers udp)
         end
      
      fun key           (T x) = #key x
      fun bytesSent     (T x) = Counter.toLarge (! (#bytesSent      x))
      fun bytesReceived (T x) = Counter.toLarge (! (#bytesReceived  x))
      
      fun killRecord (T { udp, safeToDestroy, ... }, peer) =
         case UDP.status (udp, peer) of
            (_, LIFELINE, _) => UDP.depeer (udp, peer)
          | (_, HOST (channel, cbs), _) =>
            let
               val () = UDP.depeer (udp, peer)
               val () = ChannelStack.destroy channel
               
               (* Make certain we only run safeToDestroy from top-level loop.
                * destroy could take away endpoints, hosts, etc on the stack.
                *)
               fun doubleCheck _ =
                  if not (empty udp) then () else
                  safeExec safeToDestroy ()
               val () = 
                  if not (empty udp) then () else
                  Event.scheduleIn (Event.new doubleCheck, Time.zero)
            in
               safeExec cbs NONE
            end
      
      fun create (this as T { udp, seed, ... }, address, busy) =
         let
            val peer = ref NONE
            
            fun channelRTS prio =
               let
                  val peer = valOf (!peer)
                  val (_, _, old) = UDP.status (udp, peer)
               in
                  case old of 
                     NONE => ()
                   | SOME old =>
                     if Real32.== (prio, old) then () else
                     if Real32.isNan prio 
                     then killRecord (this, peer)
                     else UDP.ready (udp, peer, prio)
               end
            
            val chan = ChannelStack.new { rts = Signal.new channelRTS,
                                          seed = seed,
                                          busy = busy }
            val cbs = Ring.new ()
            val out = (chan, cbs)
            val () = peer := SOME (UDP.peer (udp, address, HOST out))
         in
            out
         end
      
      and sendICMP (this as T { udp, zeroIP, natMethod, helperAddress, helperTimer, ... })
                    { to, from, body } =
         let
            fun direct fakeContact =
               let
                  val from = addressToVector (getOpt (from, zeroIP))
                  (* Munge address to confuse NATs *)
                  val from = Word8Vector.map Word8.notb from
                  
                  val len = Word8Vector.length from
                  val data = 
                     Word8Array.tabulate (
                        len + Word8Vector.length body,
                        fn i =>
                           if i < len
                           then Word8Vector.sub (from, i)
                           else Word8Vector.sub (body, i-len))
               in
                  UDP.sendICMP (udp, {
                     UDPfrom = to,
                     UDPto   = fakeContact,
                     code    = ttl_expired,
                     data    = Word8ArraySlice.full data
                  })
               end
               
            fun forward () =
               let
                  val () = 
                     if Event.isScheduled helperTimer then () else
                     Event.scheduleIn (helperTimer, forwarderTimeout)
                  
                  fun arg cbs = args (this, !helperAddress, cbs)
                  fun process (forwarder, cbs) =
                     ChannelStack.forwardRequest (forwarder, arg cbs, {
                        destination = to, 
                        hello       = body
                     })
               in
                  case UDP.getPeer (udp, !helperAddress) of
                     NONE => process (create (this, !helperAddress, false))
                   | SOME z =>
                     case UDP.status (udp, z) of
                        (_, LIFELINE, _) => () (* lifeline cannot proxy! *)
                      | (_, HOST h, _) => process h
               end
         in
            case !natMethod of
               NAT_FAIL => ()
             | NAT_ICMP { fakeContact } => direct fakeContact
             | NAT_VIA { fakeContact, ... } => (direct fakeContact; forward ())
         end
      
      and forwardAckd (T { helperFailed, helperTimer, helperAddress, ... }) sender =
         if !helperFailed < forwarderRetries andalso 
            UDP.Address.!= (!helperAddress, sender) then () else
         let
            (* If we are in probe mode (>3 failures) accept first person to ack *)
            val () = helperAddress := sender
            val () = helperFailed := 0
         in
            Event.cancel helperTimer
         end
      
      and args (this as T { hosts, key, bits, entropy, natMethod, udpOpenRate, icmpAckRate, statusRing, ... }, 
                remoteAddress, cbs) = 
         let
            fun host (key, localAddress) = 
               HostTable.attachHost (hosts, { 
                  key = key, 
                  localAddress = localAddress, 
                  remoteAddress = remoteAddress, 
                  reconnect = reconnect this})
            
            fun exist key = HostTable.existHost (hosts, key)
            fun contact host = safeExec cbs (SOME host)
            
            datatype z = datatype ChannelStack.event
            fun update (x, v, limit) = 
               let
                  val old = !x
                  val new = old * (1.0 - mixRate) + v * mixRate
                  val () = x := new
               in
                  if Real32.signBit (limit-old) <> Real32.signBit (limit-new)
                  then Ring.app (fn r => Ring.unwrap r ()) statusRing
                  else ()
               end
            val record = fn
               UDP_OPEN_OK   => update (udpOpenRate, 1.0, openTolerance)
             | UDP_OPEN_FAIL => update (udpOpenRate, 0.0, openTolerance)
             | ICMP_ACK_OK   => update (icmpAckRate, 1.0, ICMPAckTolerance)
             | ICMP_ACK_FAIL => update (icmpAckRate, 0.0, ICMPAckTolerance)
            
            val haveICMP = 
               case !natMethod of
                  NAT_FAIL => false
                | NAT_ICMP _ => true
                | NAT_VIA _ => false
         in
            {
               key     = key,
               bits    = bits,
               entropy = entropy,
               host    = host,
               exist   = exist,
               contact = contact,
               record  = record,
               forwardAckd = forwardAckd this,
               haveICMP    = haveICMP,
               sendICMP    = sendICMP this
            }
         end
      and reconnect (this as T { udp, ... }) address =
         case UDP.getPeer (udp, address) of
            SOME _ => ()
          | NONE => 
            let
               val (channel, cbs) = create (this, address, false)
            in
               ChannelStack.connect (channel, args (this, address, cbs))
            end
      
      fun contact (this as T { udp, ... }, address, service, cb) =
         let
            fun cbConnect host =
               case host of
                  NONE => cb NONE
                | SOME h => cb (SOME (h, HostDispatch.connect (h, service)))
            
            fun process (channel, cbs) =
               case ChannelStack.host channel of
                  SOME h => (cbConnect (SOME h); fn () => ())
                | NONE =>
                  let
                     val r = Ring.wrap cbConnect
                     val () = Ring.add (cbs, r)
                     val () = ChannelStack.connect (channel, args (this, address, cbs))
                  in
                     fn () => Ring.remove r
                  end
         in
            case UDP.getPeer (udp, address) of
               NONE => process (create (this, address, false))
             | SOME z =>
               case UDP.status (udp, z) of
                  (* bad. no CUSP can live there! *)
                  (_, LIFELINE, _) => (fn () => ())
                | (_, HOST h, _) => process h
         end
      
      fun destroy (this as T { udp, hosts, ping, ... }) =
         let
            val () = Event.cancel ping
            val () = UDP.close udp
            val () = HostTable.destroy hosts
            
            fun killChannels () =
               case Iterator.getItem (UDP.peers udp) of
                  NONE => ()
                | SOME (peer, _) => (killRecord (this, peer); killChannels ())
         in
            killChannels ()
         end
      
      fun send (this as T { udp, bytesSent, ... }, dest, peer, buffer) =
         case UDP.status (udp, peer) of
            (_, HOST (channel, cbs), _) =>
            let
               val (filled, ok) = ChannelStack.pull (channel, dest, args (this, dest, cbs), buffer)
               val () = bytesSent := !bytesSent + Counter.fromInt filled
               val  buffer =  Word8ArraySlice.subslice (buffer, 0, SOME filled)
            in
               (buffer, ok)
            end
         | (_, LIFELINE, _) =>
            let
               (* Send a ping *)
               val () = Word8ArraySlice.update (buffer, 0, 0w0)
               val buffer = Word8ArraySlice.subslice (buffer, 0, SOME 1)
               val () = UDP.ready (udp, peer, Real32.negInf)
            in
               (buffer, fn _ => ())
            end
      
      datatype mode = UDP | ICMP_FORWARD | ICMP_DIRECT
      
      fun recvAll (this as T { udp, bytesReceived, ... }, sender, peer, data, mode) =
         let
            val busy = false (* numHosts + 5 < Map.size table *)
            
            val len = Word8ArraySlice.length data
            val () = bytesReceived := !bytesReceived + Counter.fromInt len
            
            val (icmp, needICMPAck) =
               case mode of
                  UDP => (false, false)
                | ICMP_FORWARD => (true, false)
                | ICMP_DIRECT => (true, true)
            
            fun process (channel, cbs) =
               let
                  val args = args (this, sender, cbs)
                  val () = 
                     if not needICMPAck then () else
                     ChannelStack.acknowledgeICMP (channel, args)
               in
                  ChannelStack.recv (channel, sender, args, data, {icmp=icmp})
               end
         in
            case peer of
               NONE => process (create (this, sender, busy))
             | SOME z => 
               case UDP.status (udp, z) of
                  (_, HOST h, _) => process h
                | (_, LIFELINE, _) => 
                  (* Interpret forged source address as hole-punching
                   * Not as many peers can spoof IP as ICMP, but in case ICMP
                   * gets blocked at some point, this gives us an alternative.
                   *)
                  if Word8ArraySlice.length data < addressLength then () else
                  let
                     (* Demunge the sender address *)
                     val sender = Word8ArraySlice.subslice (data, 0, SOME addressLength)
                     val () = Word8ArraySlice.modify Word8.notb sender
                     val sender = parseAddress sender
                     val peer = UDP.getPeer (udp, sender)
                     
                     (* Unfortunately, addressLength breaks packet alignment *)
                     val data = Word8ArraySlice.subslice (data, addressLength, NONE)
                     val copy = Array.tabulate (Word8ArraySlice.length data,
                                                fn i => Word8ArraySlice.sub (data, i))
                  in
                     (* Can't determine who sent it... :-/ *)
                     recvAll (this, sender, peer, Word8ArraySlice.full copy, ICMP_FORWARD)
                  end
         end
      
      fun recv (this, sender, peer, data) = 
         recvAll (this, sender, peer, data, UDP)
      
      fun icmp (this as T { udp, ... }, { UDPto, reporter, code, data }) =
         case UDP.getPeer (udp, UDPto) of
            NONE => () (* We don't know this destination. ignore it. *)
          | SOME peer =>
            case UDP.status (udp, peer) of 
               (_, HOST (channel, _), _) => 
               let
                  val code = Word16.>> (code, 0w8)
                  val typ = Word16.andb (code, 0wxff)
                  val unreachable =
                     case (code, typ) of
                        (0w3,  0w0)  => true (* Destination network unreachable *)
                      | (0w3,  0w1)  => true (* Destination host unreachable *)
                      | (0w3,  0w2)  => true (* Destination protocol unreachable *)
                      | (0w3,  0w3)  => true (* Destination port unreachable *)
                      | (0w3,  0w4)  => false (* Fragmentation required processed by peered-udp *)
                      | (0w3,  0w5)  => true (* Source route failed *)
                      | (0w3,  0w6)  => true (* Destination network unknown *)
                      | (0w3,  0w7)  => true (* Destination host unknown *)
                      | (0w3,  0w8)  => true (* Source host isolated *)
                      | (0w3,  0w9)  => true (* Network administratively prohibited *)
                      | (0w3,  0w10) => true (* Host administratively prohibited *)
                      | (0w3,  0w11) => true (* Network unreachable for TOS *)
                      | (0w3,  0w12) => true (* Host unreachable for TOS *)
                      | (0w3,  0w13) => true (* Communication administratively prohibited *)
                      | (0w11, 0w0)  => true (* TTL expired in transit *)
                      | _ => false (* If we don't know what it is, ignore it *)
               in
                  if unreachable then ChannelStack.unreachable channel else ()
               end
             | (_, LIFELINE, _) =>
               (* Process the NAT hole punching request *)
               if code <> ttl_expired orelse 
                  Word8ArraySlice.length data <= addressLength then () else
               let
                  (* Demunge the sender address *)
                  val sender = Word8ArraySlice.subslice (data, 0, SOME addressLength)
                  val () = Word8ArraySlice.modify Word8.notb sender
                  val sender = parseAddress sender
                  
                  (* Fill in any zero address bits using the envelope *)
                  val sender = UDP.Address.fix { incomplete = sender, using = reporter }
                  val peer = UDP.getPeer (udp, sender)
                  
                  (* Was the reporter the sender? *)
                  val reporter = UDP.Address.fix { incomplete = reporter, using = sender }
                  val mode =
                     if UDP.Address.== (reporter, sender)
                     then ICMP_DIRECT else ICMP_FORWARD
                  
                  (* Unfortunately, addressLength breaks packet alignment *)
                  val data = Word8ArraySlice.subslice (data, addressLength, NONE)
                  val copy = Array.tabulate (Word8ArraySlice.length data,
                                             fn i => Word8ArraySlice.sub (data, i))
               in
                  recvAll (this, sender, peer, Word8ArraySlice.full copy, mode)
               end
      
      fun new { port, handler, entropy, key, options } = 
         let
            val defaults = {
               encrypt = true,
               publickey = Suite.PublicKey.defaults,
               symmetric = Suite.Symmetric.defaults
            }
            val { encrypt, publickey, symmetric } = getOpt (options, defaults)
            
            (* Pick a random public key to hash for a random seed *)
            val suites = Suite.PublicKey.iterator Suite.PublicKey.all
            val (suite, _) = valOf (Iterator.getItem suites)
            val somekey = Crypto.PrivateKey.pubkey (key, suite)
            val (x, y) = Lookup3.make Crypto.PublicKey.hash (somekey, 0w0)
            val w64 = Word64.fromLarge o Word32.toLarge
            val seed = Word64.orb (Word64.<< (w64 x, 0w32), w64 y)
            
            val bits = { publickey = publickey, symmetric = symmetric, 
                         noEncrypt = not encrypt, resume = false }
            val bytesSent = ref 0
            val bytesReceived = ref 0
            val safeToDestroy = Ring.new ()
            val statusRing = Ring.new ()
            val hosts = HostTable.new ()
            
            val this = ref NONE
            fun out () = valOf (!this)
            
            val udp = UDP.new {
               port = port,
               exceptionHandler = handler,
               receptionHandler = fn (_, addr, tag, data) => recv (out (), addr, tag, data),
               icmpHandler      = fn (_, args) => icmp (out (), args),
               transmissionHandler = fn (_, addr, tag, data) => send (out (), addr, tag, data)
            }
            
            val lifeLines = Vector.tabulate (0, fn _ => raise Domain)
            val lifeLines = ref lifeLines
            
            fun ping event =
               let
                  fun rts peer = UDP.ready (udp, peer, Real32.posInf)
                  val () = Vector.app rts (!lifeLines)
               in
                  Event.scheduleIn (event, lifelineFrequency)
               end
            val ping = Event.new ping
            val () = Event.scheduleIn (ping, lifelineFrequency)
            
            fun helperTimer _ =
               let
                  val this = out ()
                  val T { helperFailed, helperAddress, natMethod, ... } = this
                  val () = helperFailed := !helperFailed + 1
                  val bad = !helperFailed >= forwarderRetries
               in
                  if not bad then () else
                  case !natMethod of
                     NAT_VIA { helper, ... } => helperAddress := helper ()
                   | _ => ()
               end
            val helperTimer = Event.new helperTimer
            
            val () = this := SOME (T {
               hosts         = hosts,
               udp           = udp,
               zeroIP        = UDP.localName udp,
               key           = key,
               bits          = bits,
               entropy       = entropy,
               seed          = seed,
               bytesSent     = bytesSent,
               bytesReceived = bytesReceived,
               safeToDestroy = safeToDestroy,
               natMethod     = ref NAT_FAIL,
               lifeLines     = lifeLines,
               ping          = ping,
               helperAddress = ref UDP.Address.invalid,
               helperFailed  = ref 0,
               helperTimer   = helperTimer,
               udpOpenRate   = ref openTolerance,
               icmpAckRate   = ref ICMPAckTolerance,
               statusRing    = statusRing
            })
         in
            out ()
         end
      
      fun setRate (T { udp, ... }, rate) = UDP.setRate (udp, rate)
      
      (* Re-export host-table methods *)
      fun hosts (T { hosts, ... }) = HostTable.hosts hosts
      fun host (T { hosts, ... }, k) = HostTable.host (hosts, k)
      fun unadvertise (T { hosts, ... }, p) = HostTable.unadvertise (hosts, p)
      fun advertise (T { hosts, ... }, p, cb) = HostTable.advertise (hosts, p, cb)
      fun onAddressChange (T { hosts, ... }, cb) = HostTable.onAddressChange (hosts, cb)
      
      fun canReceiveUDP  (T { udpOpenRate = ref u, ... }) = u >= openTolerance
      fun canSendOwnICMP (T { icmpAckRate = ref a, ... }) = a >= ICMPAckTolerance
      fun watchStatus (T { statusRing, ... }, cb) = 
         let
            val r = Ring.wrap cb
            val () = Ring.add (statusRing, r)
         in
            fn () => Ring.remove r
         end
      
      fun setNATPenetration (T { natMethod, helperAddress, helperFailed, ... }, 
                            method) =
         case method of
            NAT_VIA args =>
            let
               (* Begin in probe-mode *)
               val { helper, ... } = args
               val () = helperAddress := helper ()
               val () = helperFailed := forwarderRetries
            in
               natMethod := NAT_VIA args
            end
          | x => natMethod := x
         
      fun setNATLifeLine (T { udp, lifeLines, ... }, dns) =
         let
            (* Remove any existing LIFELINE peers *)
            fun clear peer = UDP.depeer (udp, peer)
            val () = Vector.app clear (!lifeLines)

            (* don't kill channels with the bogus lifeline addresses *)
            fun peer address =
               case UDP.getPeer (udp, address) of
                  SOME _ => NONE
                | NONE => SOME (UDP.peer (udp, address, LIFELINE))
            
            val dns = 
               case dns of
                  SOME dns => UDP.Address.fromString dns
                | NONE => []
            val peers = List.mapPartial peer dns
         in
            lifeLines := Vector.fromList peers
         end
   end
