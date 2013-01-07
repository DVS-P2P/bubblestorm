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

functor PeerUDP(Base : BUFFERED_UDP)
   :> PEERED_UDP where type Address.t = Base.Address.t =
   struct
      structure Address = Base.Address
      
      structure PrioKey =
         struct
            type t = Real32.real * Word32.word
            
            fun (ap, al:Word32.word) == (bp, bl) =
               Real32.== (ap, bp) andalso al = bl
            
            (* In a heap, smallest goes first.
             *   We want higher priority to go first.
             *   We want earlier timestamp to go first.
             *)
            fun (ap, al) < (bp, bl) =
               if Real32.< (ap, bp) then false else
               if Real32.< (bp, ap) then true else
               Word32.< (al, bl)
         end
      
      structure Map = HashTable(Address)
      structure Heap = ManagedHeap(OrderFromLessEqual(PrioKey))
      type 'a record = Address.t * int * 'a
      type 'a peer = 'a record Heap.record
      
      datatype 'a t = T of {
         base   : Base.t,
         map    : 'a peer Map.t,
         heap   : 'a record Heap.t,
         serial : Word32.word ref
      }
      
      val idle = (~Real32.minPos, 0w0) (* Anything better will be sent *)
      
      fun receive (this as T { map, ... }, address, buffer, receptionHandler) =
         let
            val peer = Map.get (map, address)
         in
            receptionHandler (this, address, peer, buffer)
         end
      
      fun receiveICMP (this as T { ... }, args, icmpHandler) =
         icmpHandler (this, args)
      
      fun transmit (this as T { base, heap, serial, ... }, buffer, transmissionHandler) =
         let
            val peer = 
               case Heap.popBounded (heap, idle) of
                  SOME x => x
                | NONE => raise Fail "Asked to transmit when not ready."
            
            val (_, (prio, _), (address, mtu, _)) = Heap.sub peer
            
            (* Load balance *)
            val bump = !serial
            val () = serial := bump + 0w1
            val () = Heap.update (heap, peer, (prio, bump))
            
            val buffer = Word8ArraySlice.subslice (buffer, 0, SOME mtu)
            val (buffer, ok) = 
               transmissionHandler (this, address, peer, buffer)
            
            fun ok' status =
               if status then ok status else
               let
                  val (_, _, (address, oldMTU, tag)) = Heap.sub peer
                  val newMTU = Base.mtu (base, address, oldMTU)
                  val () = Heap.updateValue (peer, (address, newMTU, tag))
               in
                  ok status
               end
         in
            (address, buffer, ok')
         end
      
      fun resendRTS (T { base, heap, ...}) =
         case Heap.peekBounded (heap, idle) of
            NONE => Base.ready (base, false)
          | SOME _ => Base.ready (base, true)
      
      fun new { port, exceptionHandler, receptionHandler, icmpHandler, transmissionHandler } =
         let
            val heap = Heap.new ()
            val map = Map.new ()
            val serial = ref 0w0
            fun this base = T {
               base = base,
               heap = heap,
               map = map,
               serial = serial
            }
            val base = Base.new {
               port = port,
               exceptionHandler = exceptionHandler,
               receptionHandler = fn (base, address, buffer) => receive (this base, address, buffer, receptionHandler),
               icmpHandler      = fn (base, args) => receiveICMP (this base, args, icmpHandler),
               transmissionHandler = fn (base, buffer) => transmit (this base, buffer, transmissionHandler)
            }
         in
            this base
         end
      
      fun close (T { base, ... }) = Base.close base
      
      fun peer (T { base, map, heap, ... }, address, data) =
         let
            val mtu = Base.mtu (base, address, Base.maxMTU)
            val peer = Heap.wrap (idle, (address, mtu, data))
            val () = Map.add (map, address, peer)
            val () = Heap.push (heap, peer)
         in
            peer
         end
      
      fun depeer (this as T { map, heap, ... }, peer) =
         let
            val (ok, _, (address, _, _)) = Heap.sub peer
            val () =
               if ok then () else
               raise Fail "Cannot depeer a depeered handle"
            
            val () = Heap.remove (heap, peer)
            val _ = Map.remove (map, address)
         in
            resendRTS this
         end
      
      fun ready (this as T { heap, ... }, peer, prio) =
         let
            val (ok, (_, last), _) = Heap.sub peer
            val () =
               if ok then () else
               raise Fail "Cannot mark a depeered handle as ready"
            val () = Heap.update (heap, peer, (prio, last))
         in
            resendRTS this
         end
      
      fun peers (T { heap, ... }) = Heap.iterator heap
      fun getPeer (T { map, ... }, key) = Map.get (map, key)
      fun status (_, peer) = 
         let
            val (inHeap, (prio, _), (address, _, value)) = Heap.sub peer
         in
            (address, value, if inHeap then SOME prio else NONE)
         end
      
      fun sendICMP (T { base, ... }, args) = Base.sendICMP (base, args)
      fun setRate  (T { base, ... }, args) = Base.setRate  (base, args)
      fun localName (T { base, ... }) = Base.localName base
   end
