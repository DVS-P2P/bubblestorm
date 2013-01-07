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
open Log

fun handler exn = raise exn

fun sendOneByte stream =
   let
      val () = print "Sending 1 byte\n"
      fun cb OutStream.READY = ()
        | cb OutStream.RESET = print "Stream was reset while writing!\n"
      val data = Word8Vector.tabulate (1, fn _ => 0w0)
   in
      OutStream.write (stream, data, cb)
   end

fun main1 () =
   let  
      val () = print "Starting main1\n"
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
      
      fun onConnect (host, _, is) =
         let
            val () =
               print ("Connect from "
                  ^ Address.toString (Option.valOf (Host.remoteAddress host))
                  ^ "\n")
            fun read (InStream.DATA _) = InStream.read (is, ~1, read)
              | read _ = ()
         in
            InStream.read (is, ~1, read)
         end
      val _ = EndPoint.advertise (endpoint, SOME 0w23, onConnect)

      val connectTo = 
         case Address.fromString (hd (CommandLine.arguments ())) of
            SOME x => x
          | NONE => (print ("Couldn't resolve target name " ^ hd (CommandLine.arguments ()) ^ "\n")
                     ; raise Option)
      
      fun connect _ =
         let
            val () = print ("Contacting " ^ Address.toString connectTo ^ "...\n")
            fun connected NONE = print "Contact FAILED\n"
              | connected (SOME (_, stream)) =
               let
                  val () = print "Contact successful\n"
                  fun send _ = sendOneByte stream
               in
                  Main.Event.scheduleIn (Main.Event.new send, Time.fromSeconds 30)
               end
         in
            ignore (EndPoint.contact (endpoint, connectTo, 0w23, connected))
         end

      fun sigIntHandler () = 
         (EndPoint.destroy endpoint
         ; Main.stop ()
         ; Main.UNHOOK)
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
   in
      Main.Event.scheduleIn (Main.Event.new connect, Time.fromSeconds 10)
   end

fun main2 () =
   let  
      val () = print "Starting main2\n"
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
      
      val connectTo = 
         case Address.fromString (hd (CommandLine.arguments ())) of
            SOME x => x
          | NONE => (print "Couldn't resolve target name!\n"; raise Option)
      
      fun connect _ =
         let
            val () = print ("Contacting " ^ Address.toString connectTo ^ "...\n")
            fun connected NONE = print "Contact FAILED\n"
              | connected (SOME (host, stream)) =
               let
                  val () = print "Contact successful\n"
                  
                  fun send os _ = sendOneByte os
                  
                  fun connect () =
                     let
                        val () = print "Connect more\n"
                        val os = Host.connect (host, 0w23)
                     in
                        Main.Event.scheduleIn (Main.Event.new (send os), Time.fromSeconds 10)
                     end
                  fun connectMore _ =
                     Iterator.app
                     (fn _ => connect ())
                     (Iterator.fromInterval {start=0, stop=10, step=1})
                  val () = Main.Event.scheduleIn (Main.Event.new connectMore, Time.fromSeconds 10)
                  
               in
                  Main.Event.scheduleIn (Main.Event.new (send stream), Time.fromSeconds 20)
               end
         in
            ignore (EndPoint.contact (endpoint, connectTo, 0w23, connected))
         end

      fun sigIntHandler () = 
         (EndPoint.destroy endpoint
         ; Main.stop ()
         ; Main.UNHOOK)
      
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
   in
      Main.Event.scheduleIn (Main.Event.new connect, Time.fromSeconds 20)
   end

val () = Main.run ("cusp-mem-usage-1", main1)
val () = Main.run ("cusp-mem-usage-2", main2)
