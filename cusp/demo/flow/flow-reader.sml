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

open CUSP

(* parameters *)
val phaseInterval = Time.fromSeconds 10
val rates : Int64.int list = [ (* per-seconds rate (byte/s) limits for each phase *)
   1000000,
   1000,
   100000,
   0,
   50000,
   1000000000
]
val quotaIntervalMs = 50
val quotaInterval = Time.fromMilliseconds quotaIntervalMs
val bufInterval = Time.fromMilliseconds 100
val logInterval = Time.fromMilliseconds 1000

fun log (lvl, msg) = Log.logExt (lvl, fn () => "cusp/flow/reader", msg)

fun handler exn =
   log (Log.WARNING, fn () => General.exnMessage exn)

fun main () =
   let  
      val () = print "# Starting reader\n"
      val endpoint = 
         EndPoint.new { 
            port    = SOME 8585, 
            key     = Crypto.PrivateKey.new { entropy = Entropy.get },
            handler = handler,
            entropy = Entropy.get,
            options = SOME { 
               encrypt   = false,
               publickey = Suite.PublicKey.defaults,
               symmetric = Suite.Symmetric.defaults
         }  }
      
      fun connect (host, _, stream) =
         let
            val () = print "# Connect\n# ----------\n"
            val () = print "# Time\tRate\tRead bytes/s\tHost bytes/s\tBuffered incoming\n"
            
            (* current receive rate limit (byte/s) *)
            val rate : Int64.int ref = ref 0
            val quota : Int64.int ref = ref 0
            val ready : bool ref = ref true
            
            val bufSum : int ref = ref 0
            val bufCount : int ref = ref 0
            fun getBuf evt =
               let
                  val () = bufSum := !bufSum + Host.queuedOutOfOrder host + Host.queuedUnread host
                  val () = bufCount := !bufCount + 1
               in
                  Main.Event.scheduleIn (evt, bufInterval)
               end
            val _ = Main.Event.scheduleIn (Main.Event.new getBuf, bufInterval)
            
            (* logging *)
            val readBytes : int ref = ref 0
            val tStart = Main.Event.time ()
            val lastTimeMs : Int64.int ref = ref ((Time.toNanoseconds64 tStart) div 1000000)
            val lastBytesRcvd : Int64.int ref = ref (Int64.fromLarge (Host.bytesReceived host))
            fun log evt =
               let
                  val now = Main.Event.time ()
                  val nowMs = (Time.toNanoseconds64 now) div 1000000
                  val timeDiffMs = nowMs - !lastTimeMs
                  
                  val bytesRcvd = Int64.fromLarge (Host.bytesReceived host)
                  val bytesRcvdDiff = bytesRcvd - !lastBytesRcvd
                  val bytesBuffered = if !bufCount > 0 then !bufSum div !bufCount else 0
(*                   Host.queuedOutOfOrder host + Host.queuedUnread host *)
                  
                  val () =
                     print (Time.toAbsoluteString (Time.- (now, tStart))
                        ^ "\t" ^ Int64.toString (!rate)
                        ^ "\t" ^ Int64.toString ((Int64.fromInt (!readBytes) * 1000) div timeDiffMs)
                        ^ "\t" ^ Int64.toString ((bytesRcvdDiff * 1000) div timeDiffMs)
                        ^ "\t" ^ Int.toString bytesBuffered
                        ^ "\n")
                  
                  val () = bufSum := 0
                  val () = bufCount := 0
                  
                  val () = readBytes := 0
                  val () = lastTimeMs := nowMs
                  val () = lastBytesRcvd := bytesRcvd
               in
                  Main.Event.scheduleIn (evt, logInterval)
               end
            val _ = Main.Event.scheduleIn (Main.Event.new log, logInterval)
            
            (* read *)
(*            fun readEvt evt =
               let
                  fun get (InStream.DATA x) =
                        let
                           val len = Int64.fromInt (Word8ArraySlice.length x)
                           val delayNs = len * 1000000000 div !rate
                           val delay = Time.fromNanoseconds64 delayNs
                        in
                           ignore (Main.Event.scheduleIn (Main.Event.new readEvt, delay))
                        end
                    | get InStream.SHUTDOWN = (print "# Stream ends\n"; Main.stop ())
                    | get InStream.RESET = (print "# Reset\n"; Main.stop ())
               in
                  InStream.read (stream, Int64.toInt (!rate div 10), get)
               end
            val () = Main.Event.scheduleIn (Main.Event.new readEvt, Time.zero)*)

            fun get (InStream.DATA x) =
                  let
                     val () = ready := true
                     val len = Word8ArraySlice.length x
                     val () = readBytes := !readBytes + len
                     val () = quota := !quota - Int64.fromInt len
                  in
                     if !quota > 0
                     then read ()
                     else ()
                  end
               | get InStream.SHUTDOWN = (print "# Stream ends\n"; Main.stop ())
               | get InStream.RESET = (print "# Reset\n"; Main.stop ())
            and read () =
               (ready := false
               ; InStream.read (stream, Int64.toInt (!quota), get))

            fun updateQuota evt =
               let
                  val rate = !rate
                  val () =
                     quota := Int64.min (!quota
                        + ((rate * (Int64.fromInt quotaIntervalMs)) div 1000), rate)
                  val () =
                     if (!quota > 0) andalso (!ready)
                     then read ()
                     else ()
               in
                  Main.Event.scheduleIn (evt, quotaInterval)
               end
            val () = Main.Event.scheduleIn (Main.Event.new updateQuota, quotaInterval)
            
            (* rate limiting phases *)
            val rates = ref rates
            fun nextPhase evt =
               case !rates of
                  newRate::nextRates =>
                     let
                        val () = rates := nextRates
                        val () = rate := newRate
                        val () =
                           print ("# Set rate to "
                              ^ Int64.toString newRate ^ "\n")
                     in
                        Main.Event.scheduleIn (evt, phaseInterval)
                     end
                | nil => ()
         in
            ignore (Main.Event.scheduleIn (Main.Event.new nextPhase, Time.zero))
         end
      
      val _ = EndPoint.advertise (endpoint, SOME 0w23, connect)
      
      val attempt = ref 0
      fun sigIntHandler () = 
         if !attempt = 0 then
            let
               fun done () = (print "# Terminating...\n" 
                              ; EndPoint.destroy endpoint; Main.stop ())
               val _ = EndPoint.whenSafeToDestroy (endpoint, done)
               val () = attempt := !attempt + 1
               val () = print "# User interrupt! -- attempting to quit.\n"
            in
               Main.REHOOK
            end
         else
            let
               val () = Main.stop ()
               val () = print "# FORCED TO QUIT UNCLEANLY.\n"
            in
               Main.REHOOK
            end
      
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
      val () = print "# Started reader\n"
   in
      ()
   end

val () = Main.run ("flow-reader", main)
