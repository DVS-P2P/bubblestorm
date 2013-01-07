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

functor Negotiation(structure Log          : LOG
                    structure Event        : EVENT
                    structure HostDispatch : HOST_DISPATCH
                    structure AckGenerator : ACK_GENERATOR where type host = HostDispatch.t
                    structure Address      : ADDRESS)
   :> NEGOTIATION where type host = HostDispatch.t 
                  where type address = Address.t =
   struct	
      structure Base = AckGenerator
      
      structure PacketFormat = PacketFormat(Address)
      open PacketFormat
      structure P = Suite.PublicKey
      structure S = Suite.Symmetric
      
      type host = HostDispatch.t
      type address = Address.t
      datatype state = 
         CLOSED         of { noState      : Word8Vector.vector option }
       | SENT           of { agreed       : bits, 
                             half         : Crypto.half_negotiation,
                             noState      : Word8Vector.vector option }
       | RECEIVED       of { agreed       : bits, 
                             key          : Crypto.PublicKey.t,
                             half         : Crypto.half_negotiation,
                             full         : Crypto.full_negotiation,
                             localAddress : address,
                             tail         : Word8Vector.vector }
       | ESTABLISHED    of { base         : Base.t,
                             full         : Crypto.full_negotiation,
                             tail         : Word8Vector.vector, 
                             tsn          : LargeInt.int,
                             asn          : LargeInt.int }
      
      datatype forwardState = 
         FORWARD_STATE of {
            requestQueue   : { destination : address, hello : Word8Vector.vector } list,
            needForwardAck : bool,
            needICMPAck    : bool
         }
      
      type t = { rts        : Real32.real Signal.t,
                 counter    : int ref,
                 seed       : Word64.word,
                 created    : Time.t,
                 timeout    : Event.t,
                 state      : state ref,
                 forward    : forwardState ref,
                 forwardRTS : bool Signal.t
                 }
      
      datatype event = UDP_OPEN_OK | UDP_OPEN_FAIL | ICMP_ACK_OK | ICMP_ACK_FAIL
      type args = { key     : Crypto.PrivateKey.t,
                    bits    : bits,
                    entropy : int -> Word8Vector.vector,
                    host    : Crypto.PublicKey.t * address -> host,
                    exist   : Crypto.PublicKey.t -> bool,
                    contact : host -> unit,
                    record  : event -> unit,
                    haveICMP    : bool,
                    forwardAckd : address -> unit,
                    sendICMP    : { to : address, from : address option,
                                    body : Word8Vector.vector } -> unit
                    }
      
      val ready = Real32.posInf
      val idle  = Real32.negInf
      val destroyMe = ready * 0.0 (* NaN *)
      
      val host = fn
         ({ state = ref (ESTABLISHED { base, ... }), ... } : t) => 
            SOME (Base.host base)
       | _ => 
            NONE
      
      (* We retransmit connection attempts with exponentially
       * increasing delays, and randomized inter-transmission times.
       * We send 8 packets with these timeouts:
       *   packet 0 -> 0.5-1s
       *   packet 1 -> 1-2s
       *   packet 2 -> 2-4s
       *   packet 3 -> 4-8s
       *   packet 4 -> 8-16s
       *   packet 5 -> 16-32s
       *   packet 6 -> 32-64s
       *   packet 7 -> 64-128s
       *)
      val xmitGap = Time.fromMilliseconds 500
      
      fun pow2Int x = Word32.toInt (Word32.<< (0w1, Word32.fromInt x))
      
      fun delay (seed, count) = 
         let
            val base = Time.* (xmitGap, pow2Int count)
            val limit = Time.toNanoseconds64 base
            (* "random" *)
            val jitter = seed * Word64.fromInt count
            val jitter = Word64.>> (jitter, 0w1)
            val jitter = Int64.fromLarge (Word64.toLargeInt jitter)
            val jitter = jitter mod limit
            val jitter = Time.fromNanoseconds64 jitter
         in
            Time.+ (base, jitter)
         end
            
      (* You have 127.5-255 seconds to comply! *)
      fun newDeathCounter (rts, seed, count) =
         let
            fun handler event =
               if !count = 8 then Signal.set rts destroyMe else
               (Signal.set rts ready (* retransmit *)
                ; Event.scheduleIn (event, delay (seed, !count))
                ; count := !count + 1)
            val out = Event.new handler
            val () = Event.scheduleIn (out, delay (seed, !count))
         in
            out
         end
      
      fun new { rts, seed, busy=_ } =
         let
            val counter = ref 0
            val () = Log.log (Log.DEBUG, "cusp/channel", fn () => "new")
            
            fun both (prio, true) = if Real32.isNan prio then prio else ready
              | both (prio, false) = prio
            val (rts, forwardRTS) = Signal.splitNoInit (rts, both, (idle, false))
         in
            { rts        = rts,
              counter    = counter,
              created    = Event.time (),
              seed       = seed,
              timeout    = newDeathCounter (rts, seed, counter),
              state      = ref (CLOSED { noState = NONE }),
              forwardRTS = forwardRTS,
              forward    = ref (FORWARD_STATE { requestQueue = [], needForwardAck = false, needICMPAck = false }) }
         end
      
      fun destroy ({ state, timeout, ... } : t) =
         (Event.cancel timeout
          ; case !state of
               ESTABLISHED { base, ... } => Base.destroy base
             | _ => ()
          ; state := CLOSED { noState = NONE })
      
      fun badMAC (full, data, sn) =
         let
            val { macLen, decipher, ... } = full
            val { f=_, mac } = decipher sn
            val off = Word8ArraySlice.length data - macLen
            val body = Word8ArraySlice.subslice (data, 0, SOME off)
            val tail = Word8ArraySlice.subslice (data, off, NONE)
            val tail = Word8ArraySlice.vector tail
            val mac = mac body
         in
            tail <> mac
         end
         handle exn =>
            let
               val () = Log.log (Log.WARNING, "cusp/channel/negotiation", 
                        fn () => "badMAC exception " ^ General.exnMessage exn)
            in
               true
            end
      
      fun makeProgress ({ counter, timeout, seed, rts, ... } : t) =
         let
            val () = Signal.set rts ready
         in
            Event.scheduleIn (timeout, delay (seed, !counter))
         end
      
      fun goFAIL (self as { state, ... } : t) =
         let
            val () = state := CLOSED { noState = NONE }
         in
            makeProgress self
         end
      
      fun goNOSTATE (self as { state, ... } : t, data) =
         let
            val () = state := CLOSED { noState = SOME (extractTail data) }
         in
            makeProgress self
         end
      
      fun goOOBNOSTATE (self as { state, ... } : t, agreed, half, data) =
         let
            val () = state := 
               SENT { agreed = agreed, half = half, 
                      noState = SOME (extractTail data) }
         in
            makeProgress self
         end
      
      fun goSENT (self as { state, ... } : t, 
                  { entropy, key, ... } : args,
                  bits as { publickey, ... } : bits,
                  half) =
         let
            val half =
               case half of
                  SOME half => half
                | NONE =>
                     Crypto.publickey {
                        suite   = valOf (P.cheapest publickey),
                        key     = key,
                        entropy = entropy }
            val () = state := SENT { agreed = bits, half = half, noState = NONE }
         in
            makeProgress self
         end
      
      fun goRECEIVED (self as { state, ... } : t, address, bits, half, full, key) =
         let
            (* empty mac is impossible to match against *)
            val mac = Word8Vector.tabulate (0, fn _ => 0w0)
            val () = state :=
               RECEIVED { agreed = bits, half = half, full = full, 
                          key = key, tail = mac, localAddress = address }
         in
            makeProgress self
         end
      
      fun goESTABLISHED (log, 
                         { state, timeout, rts, created, ... } : t, 
                         { host, contact, ... } : args,
                         full, key, noEncrypt, resume, localAddress, ack) =
         let
            val { macLen, loopback, encipher, decipher } = full
            val full = 
               if noEncrypt then {
                  macLen = macLen,
                  loopback = loopback,
                  encipher = fn x => { f = fn _ => (), mac = #mac (encipher x) },
                  decipher = fn x => { f = fn _ => (), mac = #mac (decipher x) }
               } else full
            
            val host = host (key, localAddress)
            val () = 
               if resume 
               then log "RESUME ESTABLISH"
               else (log "NEW ESTABLISH"; HostDispatch.wipeState host)
            
            val base = Base.new {
               rts  = rts,
               rtt  = Time.- (Event.time (), created),
               host = host,
               ack  = ack (* setup delayed ACK *)
               }
            val tail = Word8Vector.tabulate (0, fn _ => 0w0)
            val e = { base=base, full=full, tail=tail, asn=0, tsn=0 }
            val () = state := ESTABLISHED e
            val () = Event.cancel timeout
            val () = contact host
         in
            e
         end
      
      fun processHELLO (log,
                        self, args as { exist, key, entropy, ... } : args, 
                        agreed, half, { remote, B, Y, address }) =
         let
            val { publickey=sp, symmetric=ss, noEncrypt=se, ... } = agreed
            val { publickey=rp, symmetric=rs, noEncrypt=re, resume } = remote
            val ip = P.intersect (sp, rp)
            val is = S.intersect (ss, rs)
            val ie = se andalso re
            
            (* Can they use our key? no -> rekey *)
            val half =
               case half of
                  NONE => NONE
                | z =>
                  if P.contains (rp, valOf (P.cheapest sp)) then z else NONE
               
            (* Can we use their key? no -> stay HELLO *)
            val suite =
               Option.mapPartial
               (fn x => if P.contains (sp, x) then SOME x else NONE)
               (P.cheapest rp)
            
            (* Do we recognize this host? yes -> stay HELLO *)
            val pkey = 
               Option.map (fn s => #parse (Crypto.publickeyInfo s) {B=B}) suite
            val known = getOpt (Option.map exist pkey, false)
            
            (* Intersected options of local and remote *)
            val isect = { publickey=ip, symmetric=is, noEncrypt=ie, 
                          resume=known }
         in
            if P.isEmpty ip orelse S.isEmpty is then goFAIL self else
            case suite of 
               NONE => (log "can't use their public-key, HELLO"
                        ; goSENT (self, args, isect, half))
             | SOME suite =>
            if known andalso not resume 
            then (log "want resume, HELLO"
                  ; goSENT (self, args, isect, half))
            else
            let
               fun new () =
                  Crypto.publickey { suite=suite, key=key, entropy=entropy }
               val half as { symmetric, ... } = 
                  case half of
                     NONE => new ()
                   | SOME half => half
               val full = symmetric { suite = valOf (S.cheapest is), B = B, Y = Y }
               val () = log "RECEIVED"
            in
               goRECEIVED (self, address, isect, half, full, valOf pkey)
            end
         end
      
      fun confirmWELCOME (agreed, remote) =
         let
            val { publickey=sp, symmetric=ss, noEncrypt=se, resume=sr } = agreed
            val { publickey=rp, symmetric=rs, noEncrypt=re, resume=rr } = remote
         in
            not (P.isEmpty rp) andalso
            not (S.isEmpty rs) andalso
            P.isEmpty (P.subtract (rp, sp)) andalso
            S.isEmpty (S.subtract (rs, ss)) andalso
            P.cheapest rp = P.cheapest sp andalso
            (se orelse not re) andalso
            (sr orelse not rr)
         end
      
      fun processWELCOME (log, self, args, half, agreed, data, { remote, B, Y, address }) =
         let
            exception NoGood
            val () = 
               if confirmWELCOME (agreed, remote) then () else raise NoGood
               
            (* These must be non-empty since confirmWELCOME is ok *)
            val { publickey=rp, symmetric=rs, noEncrypt=re, resume=rr } = remote
            val rp = valOf (P.cheapest rp)
            val rs = valOf (S.cheapest rs)
            
            val { parse, ... } = Crypto.publickeyInfo rp
            val key = parse { B = B }
            
            (* If there are problems with the keys, exception -> OOB NOSTATE *)
            val { symmetric, ... } = half
            val full = symmetric { suite = rs, B = B, Y = Y }
            val () = if badMAC (full, data, 0) then raise NoGood else ()
            
         in
            ignore (goESTABLISHED (log, self, args, full, key, re, rr, address, true))
         end
         handle _ => 
         ( log "oob NOSTATE"; goOOBNOSTATE (self, agreed, half, data))
   
      fun processDATA (sender, self as { state, rts, ... }, 
                       { base, full, tail, asn=_, tsn }, data, d) =
         let
            val { tsn=rtsn, asn=rasn, acklen, finish } = d
            val rtsn32 = Word32.fromLargeInt rtsn
            val rasn32 = Word32.fromLargeInt rasn
            val { macLen, decipher, loopback, ... } = full
            val (body, len) =
               let
                  val { f, mac } = decipher rtsn
                  val off = Word8ArraySlice.length data - macLen
                  val text = Word8ArraySlice.subslice (data, 0, SOME off)
                  val tail = Word8ArraySlice.subslice (data, off, NONE)
                  val body = Word8ArraySlice.subslice (text, 8, NONE)
                  val tail = Word8ArraySlice.vector tail
                  val mac = mac text
                  val len = Word8ArraySlice.length body
               in
                  if tail <> mac then (NONE, ~1) else (SOME (f body; body), len)
               end
               handle _ => (NONE, ~2)
            fun wrap (f, g) =
               (ignore (f ()) handle x => (ignore (g ()); raise x)
                ; g ()) 
                
            fun log result = 
               Log.log (Log.DEBUG, "cusp/channel/recv",
                        fn () => Address.toString sender ^ " --> DATA(" ^ 
                                 Int.toString len ^ (if finish then ",finish" else "") ^ 
                                 "): ESTABLISHED => " ^ result)
         in
            case body of NONE => log "ignored corrupt" | SOME body =>
            wrap (fn () => Base.recv (base, { data = body, acklen = acklen,
                                              tsn = rtsn32, asn = rasn32 }),
                  fn () => 
                  let
                     fun zombie () = HostDispatch.isZombie (Base.host base)
                     val zombie = Lazy.make zombie
                     val empty = Word8ArraySlice.length body = 0
                  in
                     if (finish orelse loopback) andalso zombie ()
                     then (log "CLOSED (NOSTATE)"
                           ; Base.destroy base
                           ; goNOSTATE (self, data))
                     else (log "processed"
                           ; state := ESTABLISHED 
                            { base=base, full=full, tail=tail, tsn=tsn, asn=rtsn }
                            (* Push us out of simultaneous close *)
                           ; if empty andalso zombie ()
                             then Signal.set rts ready
                             else ())
                  end)
         end
      
      val seqs = fn
          ESTABLISHED { tsn, asn, ... } => (tsn, asn)
        | _ => (0, 0)
      
      fun logRecv sender state msg result =
         Log.log (Log.DEBUG, "cusp/channel/recv", 
                  fn () => Address.toString sender ^ " --> " ^ msg ^ ": " ^ 
                           state ^ " => " ^ result)
       
      (* The ultimate bad news would be if both sides got into AM_ESTABLISHED
       * with different keys. As long as one party never makes it, he can
       * timeout and reset the other party. The only transitions that take
       * a node to ESTABLISHED are receipt of a WELCOME message or a
       * valid data packet while in the RECEIVED state.
       *
       * Both transitions are completely safe. The MAC is nearly 100% proof 
       * that the connection establishment succeeded. 
       *)
      fun recv (self as { state, forward, forwardRTS, rts, counter, ... }, 
                sender,
                args as { bits, forwardAckd, sendICMP, haveICMP, record, ...}, 
                data, { icmp }) =
         case logRecv sender of log =>
         case (!state, PacketFormat.parse (data, seqs (!state))) of
         (*--------------------Handle corrupt packets--------------------*)

            (CLOSED _, CORRUPT) => 
            (log "CLOSED" "CORRUPT" "death"
             ; Signal.set rts destroyMe)
          | (_, CORRUPT) => log "?" "CORRUPT" "ignored"

         (*----------------------Handle forwarding-----------------------*)

          | (_, FORWARD_REQ { destination, hello }) =>
            if haveICMP then 
            (log "?" "FORWARD_REQ" "?/FORWARD_NEED_ACK"
             ; case !forward of FORWARD_STATE { requestQueue, needICMPAck, ... } =>
               forward := FORWARD_STATE { 
                  requestQueue   = requestQueue, 
                  needICMPAck    = needICMPAck, 
                  needForwardAck = true 
               }
             ; sendICMP {
                 to   = destination,
                 from = SOME sender,
                 body = hello
               }
             ; Signal.set forwardRTS true)
            else
            (log "?" "FORWARD_REQ" "ignored" (* !!! FUCK - bug waiting to happen *)
             ; Signal.set rts destroyMe)
          | (CLOSED _, FORWARD_ACK) =>
            if haveICMP then
            (log "CLOSED" "FORWARD_ACK" "death"
             ; Signal.set rts destroyMe)
            else
            (log "CLOSED" "FORWARD_ACK" "processed + death"
             ; forwardAckd sender
             ; Signal.set rts destroyMe)
          | (_, FORWARD_ACK) =>
            if haveICMP then
            (log "?" "FORWARD_ACK" "ignored")
            else
            (log "?" "FORWARD_ACK" "processed"
             ; forwardAckd sender)
          | (CLOSED _, ICMP_ACK) => 
            (log "CLOSED" "ICMP_ACK" "death"
             ; Signal.set rts destroyMe)
          | (_, ICMP_ACK) =>
            (log "?" "ICMP_ACK" "?"
             ; record ICMP_ACK_OK)

         (*------------------------------CLOSED--------------------------*)

          | (CLOSED _, NOSTATE _) => 
            (log "CLOSED" "NOSTATE" "death"
             ; Signal.set rts destroyMe)
          | (CLOSED _, FAIL _)  =>
            (log "CLOSED" "FAIL" "death"
             ; Signal.set rts destroyMe)
          | (CLOSED _, HELLO h) => 
               (* !!! if busy then goCHALLENGE else *)
            (record (if icmp then UDP_OPEN_FAIL else UDP_OPEN_OK)
             ; processHELLO (log "CLOSED" "HELLO", self, args, bits, NONE, h))
          | (CLOSED _, WELCOME _) =>
            (log "CLOSED" "WELCOME" "NOSTATE"
             ; goNOSTATE (self, data))
          | (CLOSED _, DATA _)  => 
            (log "CLOSED" "DATA" "NOSTATE"
             ; goNOSTATE (self, data))
          
         (*------------------SENT goes rts when change-------------------*)
         
          | (SENT _, NOSTATE _) => 
            log "SENT" "NOSTATE" "ignored"
          | (SENT _, FAIL _) => 
             (* !!! maybe authenticate somehow? *)
            (log "SENT" "FAIL" "death"
             ; Signal.set rts destroyMe)
          | (SENT { half, agreed, ... }, HELLO h) =>
            processHELLO (log "SENT" "HELLO", self, args, agreed, SOME half, h)
          | (SENT { half, agreed, ... }, WELCOME w) =>
            (record ICMP_ACK_FAIL
             ; processWELCOME (log "SENT" "WELCOME", self, args, half, agreed, data, w))
          | (SENT { agreed, half, ... }, DATA _) =>
            (log "SENT" "DATA" "oob NOSTATE"
             ; goOOBNOSTATE (self, agreed, half, data))

         (*------------------SEND_ESTAB goes rts when change-----------------*)
         
          | (RECEIVED { tail=my, ... }, NOSTATE { tail }) =>
             if my <> tail then log "RECEIVED" "bad NOSTATE" "ignored" else
             (log "RECEIVED" "NOSTATE" "SENT"
              ; goSENT (self, args, bits, NONE))
          | (RECEIVED _, FAIL _) => 
             log "RECEIVED" "FAIL" "ignored (re-xmit will trigger NOSTATE)"
          | (RECEIVED _, HELLO _) =>
             log "RECEIVED" "HELLO" "ignored (re-xmit will trigger NOSTATE)"
          | (RECEIVED { full, key, agreed, localAddress, ... }, 
             WELCOME { remote as { noEncrypt, resume, ...}, ... }) =>
             (record ICMP_ACK_FAIL
              ; if not (confirmWELCOME (agreed, remote)) then log "RECEIVED" "mismatched WELCOME" "ignored" else
                if badMAC (full, data, 0) then log "RECEIVED" "bad WELCOME mac" "ignored" else
                ignore (goESTABLISHED (log "RECEIVED" "WELCOME", self, args, full, key, noEncrypt, resume, localAddress, true)))
          | (RECEIVED { full, key, agreed, localAddress, ... }, DATA (d as { tsn, ...})) =>
             if badMAC (full, data, tsn) then log "RECEIVED" "bad DATA" "ignored" else
             let
                val { noEncrypt, resume, ... } = agreed
                val e = goESTABLISHED (log "RECEIVED" "DATA", self, args, full, key, noEncrypt, resume, localAddress, false)
             in
                processDATA (sender, self, e, data, d)
             end
          
         (*------------------ESTABLISHED connections are sticky--------------*)

          | (ESTABLISHED { tail=my, base, ... }, NOSTATE { tail }) =>
             if my <> tail then log "ESTABLISHED" "bad NOSTATE" "ignored" else
             if HostDispatch.isZombie (Base.host base)
             then (log "ESTABLISHED zombie" "NOSTATE" "death"
                   ; Signal.set rts destroyMe)
             else (log "ESTABLISHED" "NOSTATE" "SENT"
                   ; Base.destroy base
                   ; counter := 0
                   ; goSENT (self, args, bits, NONE))
          | (ESTABLISHED _, FAIL _) => 
             log "ESTABLISHED" "FAIL" "ignored"
          | (ESTABLISHED _, HELLO _) =>
             (log "ESTABLISHED" "HELLO" "ack (to ellicit NOSTATE)"
              ; Signal.set rts ready)
          | (ESTABLISHED _, WELCOME _) =>
             (log "ESTABLISHED" "WELCOME" "ack (prior ack lost?)"
              ; record ICMP_ACK_FAIL
              ; Signal.set rts ready)
          | (ESTABLISHED e, DATA d) =>
              processDATA (sender, self, e, data, d)
      
      fun connect (self as { state, ... } : t, 
                   args as { bits, ... } : args) =
         case !state of
            CLOSED _ => goSENT (self, args, bits, NONE)
          | _ => () (* Already in-progress *)
      
      fun forwardRequest ({ forward, forwardRTS, ... } : t, _, req) =
         let
            val () = Signal.set forwardRTS true
            val FORWARD_STATE { requestQueue, needForwardAck, needICMPAck } = 
               !forward
         in
            forward := FORWARD_STATE {
               requestQueue   = req :: requestQueue,
               needForwardAck = needForwardAck,
               needICMPAck    = needICMPAck
            }
         end
      fun acknowledgeICMP ({ forward, forwardRTS, ... } : t, _) =
         let
            val () = Signal.set forwardRTS true
            val FORWARD_STATE { requestQueue, needForwardAck, ... } = 
               !forward
         in
            forward := FORWARD_STATE {
               requestQueue   = requestQueue,
               needForwardAck = needForwardAck,
               needICMPAck    = true
            }
         end
      
      fun unreachable ({ rts, state, ... } : t) =
         let
            fun ignore () = ()
            fun die () = Signal.set rts destroyMe
         in
            case !state of
               CLOSED _ => die ()
             | SENT _ => die ()
             | RECEIVED _ => ignore ()
             | ESTABLISHED _ => ignore ()
         end
      
      fun logSend sender state msg result =
         Log.log (Log.DEBUG, "cusp/channel/send", 
                  fn () => Address.toString sender ^ " <-- " ^ msg ^ ": " ^ 
                           state ^ " => " ^ result)
      
      (* Negotiation packets always fit inside MTU *)
      fun writeAck z = (write z, fn _ => ())
      fun setForward ({ forwardRTS, forward, rts, state, ... } : t, x) =
         let
            val frts =
               case x of
                  FORWARD_STATE { requestQueue=_::_, ... } => true
                | FORWARD_STATE { requestQueue=[], needForwardAck, needICMPAck } =>
                     needForwardAck orelse needICMPAck
            val closed =
               case !state of
                  CLOSED _ => true
                | _ => false
            
            val () = forward := x
            val () = Signal.set forwardRTS frts
         in
            if not closed orelse frts then () else
            Signal.set rts destroyMe
         end
      
      fun pull (this as { rts, state, forward, ... } : t, 
                address, { bits, sendICMP, ... } : args, data) =
         case logSend address of log =>
         case !forward of
         (*----------------------Handle forwarding-----------------------*)
            FORWARD_STATE { requestQueue=x::r, needForwardAck, needICMPAck } =>
               (log "requestQueue" "FORWARD_REQ" "?"
                ; setForward (this, FORWARD_STATE { 
                     requestQueue   = r,
                     needForwardAck = needForwardAck,
                     needICMPAck    = needICMPAck
                  })
                ; writeAck (data, FORWARD_REQ x))
          | FORWARD_STATE { requestQueue=[], needForwardAck=true, needICMPAck } =>
               (log "needForwardAck" "FORWARD_ACK" "?"
                ; setForward (this, FORWARD_STATE {
                     requestQueue   = [],
                     needForwardAck = false,
                     needICMPAck    = needICMPAck
                  })
                ; writeAck (data, FORWARD_ACK))
          | FORWARD_STATE { requestQueue=[], needForwardAck=false, needICMPAck=true } =>
               (log "needICMPAck" "ICMP_ACK" "?"
                ; setForward (this, FORWARD_STATE {
                     requestQueue   = [],
                     needForwardAck = false,
                     needICMPAck    = false
                  })
                ; writeAck (data, ICMP_ACK))
          | FORWARD_STATE { requestQueue=[], needForwardAck=false, needICMPAck=false } =>
         case !state of
         (*----------------------Handle negotiation----------------------*)
            CLOSED { noState = NONE } => 
               (log "CLOSED" "FAIL" "death"
                ; Signal.set rts destroyMe
                ; writeAck (data, FAIL { remote = bits }))
          | CLOSED { noState = SOME tail } => 
               (log "CLOSED" "NOSTATE" "death"
                ; Signal.set rts destroyMe
                ; writeAck (data, NOSTATE { tail = tail }))
          | SENT { noState = SOME tail, half, agreed } => 
               (log "SENT" "oob NOSTATE" "SENT"
                ; Signal.set rts idle
                ; state := SENT { noState = NONE, half = half, agreed = agreed }
                ; writeAck (data, NOSTATE { tail = tail }))
          | SENT { agreed, half = { A, X, ... }, ... } =>
            let
               val () = log "SENT" "HELLO" "SENT"
               val () = Signal.set rts idle
               val out = write (data, HELLO { remote = agreed, B = A, Y = X, address = address })
               
               (* Duplicate the HELLO to an ICMP message for NAT-punching *)
               val hello = Word8ArraySlice.subslice (data, 0, SOME out)
               fun send _ =
                  sendICMP {
                     to   = address,
                     from = NONE, (* let end-point assign our sender address *)
                     body = Word8ArraySlice.vector hello
                  }
            in
               (out, send)
            end
          | RECEIVED { agreed, key, half as { A, X, ... }, full, localAddress, ... } =>
            let
               val () = log "RECEIVED" "WELCOME" "RECEIVED"
               val () = Signal.set rts idle
               val len = write (data, WELCOME { remote = agreed, B = A, Y = X, address = address })
               
               val { encipher, macLen, ... } = full
               val { f=_, mac } = encipher 0
               val mac = mac (Word8ArraySlice.subslice (data, 0, SOME len))
               val (a, i, _) = Word8ArraySlice.base data
               val () = Word8Array.copyVec { src = mac, dst = a, di = i+len }
               
               val fullLen = len+macLen
               val tail = extractTail (Word8ArraySlice.subslice (data, 0, SOME fullLen))
               
               val () = state :=
                 RECEIVED { agreed=agreed, key=key, half=half, full=full, tail=tail, localAddress=localAddress }
            in
               (fullLen, fn _ => ())
            end
          | ESTABLISHED { base, full, tail=_, tsn, asn } =>
            let
               val tsn = tsn + 1
               val tsn32 = Word32.fromLargeInt tsn
               val { macLen, encipher, ... } = full
               
               val len = Word8ArraySlice.length data - 8 - macLen
               val subdata = Word8ArraySlice.subslice (data, 8, SOME len)
               val { len, acklen, asn=asn32, ok } = 
                  Base.pull (base, {
                     data = subdata, 
                     tsn  = tsn32 })
               
               val finish = HostDispatch.isZombie (Base.host base)
               val off = write (data, DATA { acklen=acklen, finish=finish, asn=asn32, tsn=tsn32 })
               val textLen = len+off
               
               val () =
                  Log.log (Log.DEBUG, "cusp/channel/send", 
                           fn () => Address.toString address ^ " <-- DATA(" ^ 
                                    Int.toString len ^ (if finish then ",finish" else "") ^
                                    "): ESTABLISHED => ESTABLISHED")
               
               val { f, mac } = encipher tsn
               val (a, i, _) = Word8ArraySlice.base data
               
               val () = f (Word8ArraySlice.subslice (subdata, 0, SOME len))
               val mac = mac (Word8ArraySlice.subslice (data, 0, SOME textLen))
               val () = Word8Array.copyVec { src = mac, dst = a, di = i+textLen }
               
               val fullLen = textLen + macLen
               val tail = extractTail (Word8ArraySlice.subslice (data, 0, SOME fullLen))
               
               val () = 
                  state := ESTABLISHED { base=base, full=full, tail=tail, tsn=tsn, asn=asn }
            in
               (fullLen, ok)
            end
   end
