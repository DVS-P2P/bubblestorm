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

fun log (lvl, msg) = Log.logExt (lvl, fn () => "cusp/demo/sendzeros", msg)

fun handler exn =
   log (Log.WARNING, fn () => General.exnMessage exn)

val zeros = Word8Vector.tabulate (32768, fn _ => 0w0)
      
fun main () =
   let  
      val key = Crypto.PrivateKey.new { entropy = Entropy.get }
      (*val key = valOf (Crypto.PrivateKey.load { password="", key="AB83A01487F6BD8048F500D1AA3F08B36EF2AD4788EDA42D2C784032289CACA1CA1D6049BC901F5C8209FEE8DBAAB7D85222239034F765CC3BB824950365743356864C61658FE6B2" })*)
      
      val t = 
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
      
      fun quit _ =
         let
            val () = print ">>>>> Done sending, shutting down <<<<<\n"
            fun safe () = (print "All channels closed; terminating.\n"
                           ; EndPoint.destroy t; Main.stop ())
            val _ = EndPoint.whenSafeToDestroy (t, safe)
         in
            ()
         end
      
      fun send stream =
          let
             fun next 100000 _ = OutStream.shutdown (stream, quit)
               | next i OutStream.READY = 
                  OutStream.write (stream, zeros, next (i+1))
                  (*let
                     val twoYears = Time.fromDays 730
                     val evt = Event.new (fn _ => OutStream.write (stream, zeros, next (i+1)))
                  in
                     Main.Event.scheduleIn (evt, twoYears)
                  end*)
               | next _ OutStream.RESET = print "Reset??\n"
          in
             OutStream.write (stream, zeros, next 1)
          end
      
      val ok = fn
         NONE => print "Failed to connect\n"
       | SOME (h, stream) =>
          let
             val () = print "Connected!\n"
             val () = send stream
          in
             ()
          end
      
      val host = 
         case Address.fromString (hd (CommandLine.arguments ())) of
            [x] => x
          | _ => (print "Couldn't resolve target name!\n"; raise Option)
      
      val () = print ("Contacting " ^ Address.toString host ^ "...\n")
      val _ = EndPoint.contact (t, host, 0w23, ok)
      
      fun stats event =
         let
            fun wstream w = 
               log (Log.DEBUG, fn () =>
                      "Write-Stream\n" ^
                      " Sent: " ^ LargeInt.toString (OutStream.bytesSent w) ^ "\n" ^
                      " InF:  " ^ Int.toString (OutStream.queuedInflight w) ^ "\n" ^
                      " ToX:  " ^ Int.toString (OutStream.queuedToRetransmit w) ^ "\n")
            fun rstream r =
               log (Log.DEBUG, fn () =>
                      "Read-Stream\n" ^
                      " Recv: " ^ LargeInt.toString (InStream.bytesReceived r) ^ "\n" ^
                      " OoO:  " ^ Int.toString (InStream.queuedOutOfOrder r) ^ "\n" ^
                      " UnR:  " ^ Int.toString (InStream.queuedUnread r) ^ "\n")
            fun host h =
               log (Log.DEBUG, fn () =>
                      "Host " ^ Crypto.PublicKey.toString (Host.key h) ^ "\n" ^
                      " Sent: " ^ LargeInt.toString (Host.bytesSent h) ^ "\n" ^
                      " Recv: " ^ LargeInt.toString (Host.bytesReceived h) ^ "\n" ^
                      " OoO:  " ^ Int.toString (Host.queuedOutOfOrder h) ^ "\n" ^
                      " UnR:  " ^ Int.toString (Host.queuedUnread h) ^ "\n" ^
                      " InF:  " ^ Int.toString (Host.queuedInflight h) ^ "\n" ^
                      " ToX:  " ^ Int.toString (Host.queuedToRetransmit h) ^ "\n")
            fun chan (a, h) =
               log (Log.DEBUG, fn () =>
                      "Channel " ^ Address.toString a ^ " => " ^
                      getOpt (Option.map (Crypto.PublicKey.toString o Host.key) h, "---") ^ "\n")
            fun endpoint e =
               log (Log.DEBUG, fn () =>
                      "EndPoint\n" ^
                      " Sent: " ^ LargeInt.toString (EndPoint.bytesSent e) ^ "\n" ^
                      " Recv: " ^ LargeInt.toString (EndPoint.bytesReceived e) ^ "\n")
            
            fun happ h = (host h
                          ; Iterator.app rstream (Host.inStreams h)
                          ; Iterator.app wstream (Host.outStreams h))
            val () = endpoint t
            val () = Iterator.app chan (EndPoint.channels t)
            val () = Iterator.app happ (EndPoint.hosts t)
         in
            Main.Event.scheduleIn (event, Time.fromSeconds 1)
         end
        
      val () = Main.Event.scheduleIn (Main.Event.new stats, Time.fromSeconds 1)
   in
      ()
   end

val () = Main.run ("sendzeros", main)
