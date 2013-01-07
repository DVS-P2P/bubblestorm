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

functor BufferUDP(structure Base : NATIVE_UDP
                  structure Event : EVENT)
   :> BUFFERED_UDP where type Address.t = Base.Address.t =
   struct
      structure Address = Base.Address
      
      (* In the middle of the 'immediacy gap' (main.sml). *)
      val waitGap = Time.fromNanoseconds 5
      
      datatype t = T of {
         base : Base.t,
         exceptionHandler    : exn -> unit,
         receptionHandler    : t * Address.t * Word8ArraySlice.slice -> unit,
         icmpHandler         : t * { UDPto : Address.t, reporter : Address.t, code : Word16.word, data : Word8ArraySlice.slice } -> unit,
         transmissionHandler : t * Word8ArraySlice.slice -> Address.t * Word8ArraySlice.slice * (bool -> unit),
         send : Event.t,
         ready : bool ref,
         rate : Real32.real ref,
         burst : Time.t ref,
         whenReady : Time.t ref
      }
      
      val buffer =
         OncePerThread.new
         (fn () => Word8ArraySlice.full (Word8Array.array (Base.maxMTU, 0w0)))
      
      fun schedule (T { whenReady, send, ... }) =
         let
            val when = Time.+ (Event.time (), waitGap)
            val when = Time.max (!whenReady, when)
         in
            Event.scheduleAt (send, when)
         end
      
      fun sendLoop (this as T { base, exceptionHandler, transmissionHandler, ready, whenReady, rate, burst, ... }) =
         if not (!ready) then () else
         if Time.> (!whenReady, Event.time ()) then schedule this else
         OncePerThread.get (buffer, fn buffer =>
         let
            val (dest, buffer, ok) = transmissionHandler (this, buffer)
            
            (* We can get temporary failures due to inbound ICMP 
             * We deal with the ICMP messages separately.
             *)
            val attempts = ref 0
            fun retry () =
               Base.send (base, dest, buffer)
               handle x =>
               (exceptionHandler x
                ; attempts := !attempts + 1
                ; if !attempts = 5 then true else retry ())
            val status = retry ()
            
            val len = Word8ArraySlice.length buffer
            val headerLen = 20.0+8.0 (* IP+UDP *)
            val delay = (headerLen + Real32.fromInt len) / !rate
            val delay = Time.fromSecondsReal32 delay
            val now = Event.time ()
            val cutoff = Time.- (now, !burst)
            val nextReady = Time.max (!whenReady, cutoff)
            val nextReady = Time.+ (nextReady, delay)
            val () = if status then whenReady := nextReady else ()
            val () = ok status
         in
            sendLoop this
         end)
      
      fun recvICMPLoop (this as T { base, icmpHandler, (*exceptionHandler,*) ... }) =
         OncePerThread.get (buffer, fn buffer =>
         case Base.recvICMP (base, buffer) 
              (* if icmp helper program breaks it's better to die 
              handle ex => (exceptionHandler ex; NONE)*)
         of
            NONE => ()
          | SOME args => (icmpHandler (this, args); recvICMPLoop this))
      
      fun recvLoop (this as T { base, receptionHandler, exceptionHandler, ... }) =
         OncePerThread.get (buffer, fn buffer =>
         case Base.recv (base, buffer) 
              handle ex => (exceptionHandler ex; NONE)
         of
            NONE => recvICMPLoop this
          | SOME (address, data) 
            => (receptionHandler (this, address, data); recvLoop this))
      
      fun ready (this as T { ready, send, ... }, x) =
         let
            val last = !ready
            val () = ready := x
         in
            if x = last then () else
            case (x, Event.isScheduled send) of
               (false, false) => ()
             | (false, true)  => Event.cancel send
             | (true,  false) => schedule this
             | (true,  true)  => ()
         end
      
      fun setRate (this as T { rate, burst, ready, ... }, newRate) =
         let
            val defaults = { rate = Real32.posInf, burst = Time.zero }
            val { rate=r, burst=b } = getOpt (newRate, defaults)
            val () = rate := r
            val () = burst := b
         in
            if !ready then schedule this else ()
         end
      
      fun new { port, exceptionHandler, receptionHandler, icmpHandler, transmissionHandler } =
         let
            val self = ref NONE
            fun ready () = recvLoop (valOf (!self))
            val send = Event.new (fn _ => sendLoop (valOf (!self)))
            val base = Base.new (port, ready)
            val out = T {
               base = base,
               exceptionHandler = exceptionHandler,
               receptionHandler = receptionHandler,
               icmpHandler      = icmpHandler,
               transmissionHandler = transmissionHandler,
               send = send,
               ready = ref false,
               rate = ref Real32.posInf,
               burst = ref Time.zero,
               whenReady = ref Time.zero
            }
            val () = self := SOME out
         in
            out
         end
      
      fun close (T { base, ... }) = Base.close base
      
      fun sendICMP (T { base, ... }, args) = Base.sendICMP (base, args)
      fun mtu (T { base, ... }, a, m) = Base.mtu (base, a, m)
      fun localName (T { base, ... }) = Base.localName base
      val maxMTU = Base.maxMTU
   end
