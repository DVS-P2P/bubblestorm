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

fun log (lvl, msg) = Log.logExt (lvl, fn () => "cusp/demo/reader", msg)

fun handler exn =
   log (Log.WARNING, fn () => General.exnMessage exn)

fun main () =
   let  
      val () = log (Log.DEBUG, fn () => "Starting reader\n")
      val t = 
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
      
      val ticks = 1000 (* ms *)
      
      val last : LargeInt.int ref = ref 0
      val count : LargeInt.int ref = ref 0
      fun tick e =
         let
            val ns = Time.toNanoseconds (Main.Event.time ())
            val ms = ns div 1000000
            val ms = (ms div ticks) * ticks
            val amount = !count - !last
            val hosts = Iterator.length (EndPoint.hosts t)
            val chans = Iterator.length (EndPoint.channels t)
            val () = print (LargeInt.toString ms ^ " " ^ Int.toString chans ^ " " ^ Int.toString hosts ^ " " ^ LargeInt.toString amount ^ "\n")
            val () = last := !count
         in
            Main.Event.scheduleIn (e, Time.fromMilliseconds (Int.fromLarge ticks))
         end
      
      fun connect (host, _, stream) =
          let
             val () = log (Log.INFO, fn () => "# ***************** Connect\n")
             fun echo x = print (Byte.bytesToString (Word8ArraySlice.vector x) ^ "\n")
             val rec get = fn
                InStream.DATA x   => 
                   (count := !count + Int.toLarge (Word8ArraySlice.length x)
                    ; InStream.read (stream, ~1, get))
              | InStream.SHUTDOWN => log (Log.DEBUG, fn () => "Stream ends\n")
              | InStream.RESET    => log (Log.DEBUG, fn () => "Reset??\n")
          in
             InStream.read (stream, ~1, get)
          end
      
      val _ = EndPoint.advertise (t, SOME 0w23, connect)
      val _ = Main.Event.scheduleIn (Main.Event.new tick, Time.zero)
      
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
               val () = print "FORCED TO QUIT UNCLEANLY.\n"
            in
               Main.REHOOK
            end
      
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
      val () = print "Started reader\n"
   in
      ()
   end

val () = Main.run ("reader", main)
