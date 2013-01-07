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
val bufInterval = Time.fromMilliseconds 100
val logInterval = Time.fromMilliseconds 1000

fun log (lvl, msg) = Log.logExt (lvl, fn () => "cusp/flow/writer", msg)

fun handler exn =
   log (Log.WARNING, fn () => General.exnMessage exn)

val zerosLen = 32768
val zeros = Word8Vector.tabulate (zerosLen, fn _ => 0w0)
      
fun main () =
   let  
      val key = Crypto.PrivateKey.new { entropy = Entropy.get }
      
      val endpoint = 
         EndPoint.new { 
            port    = NONE, 
            key     = key,
            handler = handler,
            entropy = Entropy.get,
            options = SOME { 
               encrypt   = false,
               publickey = Suite.PublicKey.defaults,
               symmetric = Suite.Symmetric.defaults
         }  }
      
      fun connected NONE =
         (print "# Failed to connect\n"
         ; Main.stop ())
        | connected (SOME (host, stream)) =
         let
            val () = print "# Connect\n# ----------\n"
            val () = print "# Time\tWrite bytes/s\tHost bytes/s\tBuffered outgoing\n"
            
            val bufSum : int ref = ref 0
            val bufCount : int ref = ref 0
            fun getBuf evt =
               let
                  val () = bufSum := !bufSum + Host.queuedInflight host + Host.queuedToRetransmit host
                  val () = bufCount := !bufCount + 1
               in
                  Main.Event.scheduleIn (evt, bufInterval)
               end
            val _ = Main.Event.scheduleIn (Main.Event.new getBuf, bufInterval)
            
            (* logging *)
            val writtenBytes : int ref = ref 0
            val tStart = Main.Event.time ()
            val lastTimeMs : Int64.int ref = ref ((Time.toNanoseconds64 tStart) div 1000000)
            val lastBytesSent : Int64.int ref = ref (Int64.fromLarge (Host.bytesReceived host))
            fun tick evt =
               let
                  val now = Main.Event.time ()
                  val nowMs = (Time.toNanoseconds64 now) div 1000000
                  val timeDiffMs = nowMs - !lastTimeMs
                  
                  val bytesSent = Int64.fromLarge (Host.bytesSent host)
                  val bytesSentDiff = bytesSent - !lastBytesSent
                  val bytesBuffered = if !bufCount > 0 then !bufSum div !bufCount else 0
(*                   Host.queuedInflight host + Host.queuedToRetransmit host *)
                  
                  val () =
                     print (Time.toAbsoluteString (Time.- (now, tStart))
                        ^ "\t" ^ Int64.toString ((Int64.fromInt (!writtenBytes) * 1000) div timeDiffMs)
                        ^ "\t" ^ Int64.toString ((bytesSentDiff * 1000) div timeDiffMs)
                        ^ "\t" ^ Int.toString bytesBuffered
                        ^ "\n")
                  
                  val () = bufSum := 0
                  val () = bufCount := 0
                  
                  val () = writtenBytes := 0
                  val () = lastTimeMs := nowMs
                  val () = lastBytesSent := bytesSent
               in
                  Main.Event.scheduleIn (evt, logInterval)
               end
            val _ = Main.Event.scheduleIn (Main.Event.new tick, logInterval)
         
            (* send *)
            fun send stream =
            let
               fun writer OutStream.READY =
                  (writtenBytes := !writtenBytes + zerosLen
                  ; OutStream.write (stream, zeros, writer))
                 | writer OutStream.RESET =
                  (print "# Reset??\n"
                  ; Main.stop ())
            in
               writer OutStream.READY
            end
         in
            send stream
         end
      
      val host = 
         case Address.fromString (hd (CommandLine.arguments ())) of
            SOME x => x
          | NONE => (print "# Couldn't resolve target name!\n"; raise Option)
      
      val () = print ("# Contacting " ^ Address.toString host ^ "...\n")
      val _ = EndPoint.contact (endpoint, host, 0w23, connected)
   in
      ()
   end

val () = Main.run ("flow-writer", main)
