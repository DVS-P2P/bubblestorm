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

(* This functor watches incoming receives in order to acknowledge them.
 * It will add acknowledgement information to each packet sent. Furthermore,
 * it forces transmission of a packet whenever it sees something new with
 * non-empty payload.  
 *)
functor DelayedAck(structure AckCallbacks : ACK_CALLBACKS
                   structure Event : EVENT) 
   :> ACK_GENERATOR where type host = AckCallbacks.host =
   struct
      type ack = { mask : Word16.word,  (* bitmask of the received packets *) 
                   rasn : Word32.word } (* mask relative to this sender TSN *)
      datatype t = T of { base  : AckCallbacks.t, 
                          new   : ack ref,        (* newest packet seen *)
                          oop   : ack option ref, (* out-of-order packet *)
                          delay : Event.t,
                          drts  : Real32.real ref, (* data ready? *)
                          arts  : bool Signal.t }
      type host = AckCallbacks.host
      
      val delayTime = Time.fromMilliseconds 10
      
      (* Calculate the number of packets in a row to ack.
       * eg: 0010111001010111 has 3 packets seen (low 3 bits set)
       * This works by converting the number first to 0000000000001000.
       * eg: a single bit set at the position of the first missing packet.
       * When all bits are set (none lost), the number becomes 0.
       * So we essentially have the numbers 2^i for i=1..16
       * Thus multiplying this by x shifts x by 'i' positions.
       * We want to know what 'i' is.
       * 
       * Then we use a de Bruijin sequence coded into a constant, which
       * when shifted has a unique value in the high bits. This means
       * that multiplication by the bitmask (= shift) gives a unique
       * offset that we can then decode into the correct value via
       * a lookup table.
       *)
      local
         open Word16
         val deBruijnConstant = 0wx0f2d (* 0000 1111 0010 1101 0000 *)
         val deBruijnTable = Word8Vector.fromList [ 
            0w16 (*  0 *), 0wx1 (*  1 *), 0wx8 (*  2 *), 0wx2 (*  3 *),
            0wxe (*  4 *), 0wx9 (*  5 *), 0wxb (*  6 *), 0wx3 (*  7 *),
            0wxf (*  8 *), 0wx7 (*  9 *), 0wxd (* 10 *), 0wxa (* 11 *),
            0wx6 (* 12 *), 0wxc (* 13 *), 0wx5 (* 14 *), 0wx4 (* 15 *) ]
      in
         fun ackCount mask = 
            Word8Vector.sub (deBruijnTable, 
                             toInt   (>> (deBruijnConstant * 
                                         andb (notb mask, mask + 0w1), 0w12)))
      end
      
      fun recv (T { base, new as ref { mask, rasn }, delay, oop, arts, ... },
                { data, tsn, asn, acklen }) =
         let
            val empty = Word8ArraySlice.length data = 0
            val b31 = Word32.<< (0w1, 0w31)
            
            fun immediateAck () = 
               (Event.cancel delay; Signal.set arts true)
            fun delayedAck () =
               Event.scheduleIn (delay, delayTime)
         in
            if Word32.andb (rasn - tsn, b31) <> 0w0 then (* if rasn < tsn *) 
               (* This is the newest packet yet and is thus not out-of-order.
                * We update the current leading information and raise rts if
                * the message had payload => we need to ack it.
                *) 
               let
                  val shift = Word.fromInt (Word32.toInt (tsn - rasn))
                  val mask = Word16.orb (0w1, Word16.<< (mask, shift))
                  val doAck = 
                     AckCallbacks.recv (base, {
                        data = data,
                        asn = asn,
                        acklen = acklen })
                  val () = 
                     if doAck 
                     then new := { rasn = tsn, mask = mask } 
                     else ()
               in
                  if empty orelse not doAck then () else
                  if Event.isScheduled delay
                  then immediateAck ()
                  else delayedAck ()
               end 
            else if Word32.andb (rasn-tsn-0w16, b31) = 0w0 then (* rasn-16 >= tsn *)
               (* This message is so old that there's little point acking it.
                * The sender is going to retransmit it anyway (fast retransmit).
                * In fact, it greatly simplifies logic if we discard it. This
                * helps the stream layer keep it's counters from wrapping badly.
                *)
               ()
            else(* This packet is out-of-order. There are three cases:
                 *   1. Already seen it
                 *   2. Will be acknowledge by next 'new' ack
                 *   3. Must be handled with an out-of-order ack. 
                 *)
               let
                  val offset = Word.fromInt (Word32.toInt (rasn - tsn))
                  val bit = Word16.<< (0w1, offset)
                  val newmask = Word16.orb (mask, bit)
                  val cutmask = Word16.>> (newmask, offset)
                  val seen = mask = newmask
                  val doAck =
                     if seen
                     then false 
                     else AckCallbacks.recv (base, {
                        data = data,
                        asn = asn,
                        acklen = acklen }) 
                  val count = ackCount newmask
                  val count = Word.fromInt (Word8.toInt count)
                  val covered = Word.> (count, offset)
                  val () = 
                     if doAck 
                     then new := { rasn = rasn, mask = newmask } 
                     else ()
                  val () =
                     if covered orelse empty orelse not doAck
                     then () 
                     else oop := SOME { rasn = tsn, mask = cutmask  }
               in
                  if empty orelse not doAck then () else
                  if not covered orelse Event.isScheduled delay
                  then immediateAck () 
                  else delayedAck ()
               end
         end
      
      (* We create a packet with no content, only an ack, if the upper layer
       * has nothing to say. This is because we sometimes set 'rts' ourselves.
       *) 
      fun pull (T { base, new, oop, delay, drts, arts }, args) =
         let
            val ack = getOpt (!oop, !new)
            val (len, ok) = 
               if Real32.== (!drts, Real32.negInf)
               then (0, fn _ => ())
               else AckCallbacks.pull (base, args)
            val { mask, rasn } = ack
            val acklen = Word8.toInt (ackCount mask) - 1
            val () = oop := NONE
            val () = Signal.set arts false
            val () = Event.cancel delay
         in
            { acklen = acklen, asn = rasn, len = len, ok = ok }
         end
      
      fun host (T { base, ... }) = AckCallbacks.host base
      
      fun new { rts, rtt, host, ack } =
         let
            open Signal
            val (yes, no) = (Real32.posInf, Real32.negInf)
            fun ready (prio, true) = if Real32.isNan prio then prio else yes
              | ready (prio, false) = prio
            
            val (his, mine) = split (rts, ready, (no, true))
            val (tap, drts) = newBox no     (* a signal to catch data RTS *)
            val his = combine (tap, his)    (* hook our data RTS tap in *)
            
            (* Setup a delayed ACK (as required in response to WELCOME) *)
            val delay = Event.new (fn _ => Signal.set mine true)
            val () = 
               if ack then Event.scheduleIn (delay, delayTime) else ()
            
            val base = 
               AckCallbacks.new 
               { rts = his, rtt = rtt, host = host }
         in
            T { base  = base,
                new   = ref { mask = 0w1, rasn = 0w0 },
                oop   = ref NONE,
                delay = delay,
                drts  = drts,
                arts  = mine }
         end
      
      fun destroy (T { base, delay, ... }) =
         (Event.cancel delay; AckCallbacks.destroy base)
   end
