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

fun log (lvl, msg) = Log.logExt (lvl, fn () => "cusp/demo/cusp-test", msg)

fun remoteName host =
   let
      val toString = Option.map Address.toString
   in
      concat [ Crypto.PublicKey.toString (Host.key host),
               " <", getOpt (toString (Host.remoteAddress host), "*"), ":",
                     getOpt (toString (Host.localAddress host), "*"), ">" ]
   end

fun accept (host, _, stream) =
    let
       val () = log (Log.DEBUG, fn () => "Accept from channel " ^ remoteName host ^ "\n")
       
       fun echo x = print (Byte.bytesToString (Word8ArraySlice.vector x) ^ "\n")
       val rec get = fn
          InStream.DATA x   => (echo x; InStream.read (stream, ~1, get))
        | InStream.SHUTDOWN => log (Log.DEBUG, fn () => "InStream ends.\n")
        | InStream.RESET    => log (Log.INFO, fn () => "InStream reset.\n")
    in
       InStream.read (stream, ~1, get)
    end

fun host NONE = log (Log.INFO, fn () => "Failed to contact\n")
  | host (SOME (host, stream)) =
     let
        val () = log (Log.INFO, fn () => "Connect to " ^ remoteName host ^ "\n")
        val payload = Byte.stringToBytes "Hello world."
        val rec write = fn
           () => OutStream.write (stream, payload, shutdown)
        and shutdown = fn
           OutStream.RESET => log (Log.DEBUG, fn () => "OutStream reset.\n")
         | OutStream.READY => OutStream.shutdown (stream, done)
        and done = fn
           true => print "Sent\n"
         | false => log (Log.DEBUG, fn () => "Unack'd\n")
     in
        write ()
     end

fun handler exn =
   log (Log.WARNING, fn () => General.exnMessage exn)

fun main () =
   let 
      val () = log (Log.DEBUG, fn () => "Starting CUSP-test\n")
      val t = 
         EndPoint.new { 
            port    = SOME 8585, 
            key     = Crypto.PrivateKey.new { entropy = Entropy.get },
            handler = handler,
            entropy = Entropy.get,
            options = NONE }
      
(*      val contact = List.hd (Address.fromString "nat-contact.bubblestorm.net:8586")
      val () = EndPoint.setNATLifeLine (t, SOME "nat-listen.bubblestorm.net:8586")
      val () = EndPoint.setNATPenetration (t, EndPoint.NAT_ICMP { fakeContact = contact })*)
      
      val _ = EndPoint.advertise (t, SOME 0w23, accept)
      val _ = 
         case CommandLine.arguments () of
            [peer] => EndPoint.contact (t, List.hd (Address.fromString peer), 0w23, host)
          | _ => raise Domain
      
      val attempt = ref 0
      fun sigIntHandler () = 
         if !attempt = 0 then
            let
               fun done () = (print "Terminating...\n" 
                              ; EndPoint.destroy t; Main.stop ())
               val _ = EndPoint.whenSafeToDestroy (t, done)
               val () = attempt := !attempt + 1
               val () = log (Log.DEBUG, fn () => "User interrupt! -- attempting to quit.\n")
            in
               Main.REHOOK
            end
         else
            let
               val () = EndPoint.destroy t
               val () = Main.stop ()
               val () = log (Log.WARNING, fn () => "FORCED TO QUIT UNCLEANLY.\n")
            in
               Main.REHOOK
            end
      
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
      val () = log (Log.DEBUG, fn () => "Started CUSP-test\n")
   in
      ()
   end

val () = Main.run ("cusp-test", main)
