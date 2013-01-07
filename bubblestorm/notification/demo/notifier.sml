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
structure Notification = Notification(ID)

(* This program sends (fake) notifications to a remote applications which sends
 * its encoded notification data.
 * Expects 1 command line argument specifying the number of notifications to send per request. *)

fun main () =
   let
      fun handler exn =
         print ("CUSP exn: " ^ General.exnMessage exn ^ "\n")
      val ep = 
         EndPoint.new { 
            port    = SOME 8585,
            key     = Crypto.PrivateKey.new { entropy = Entropy.get },
            handler = handler,
            entropy = Entropy.get,
            options = NONE
         }
      
      val notifyCount = valOf (Int.fromString (hd (CommandLine.arguments ())))
      fun notify notData =
         let
            val rnd = Random.new 0w42
            val (sendFn, _) = Notification.decode (Word8VectorSlice.full notData, ep)
            fun send i =
               let
                  val id = ID.fromRandom rnd
                  val size = Random.int (rnd, 1000)
                  val data = Word8Vector.tabulate (size, fn _ => 0w0)
               in
                  sendFn (id, Notification.IMMEDIATE data)
               end
            
            val counter = List.tabulate (notifyCount, fn i => i)
         in
            List.app send counter
         end
      
      fun onConnect (host, service, is) =
         let
            val buf = ref []
            fun read is =
               let
                  fun r (InStream.DATA x) = 
                     (buf := Word8ArraySlice.vector x :: (!buf)
                     ; read is)
                   |  r InStream.SHUTDOWN = notify (Word8Vector.concat (List.rev (!buf)))
                   |  r InStream.RESET = print "connect reset\n"
                in
                  InStream.read (is, ~1, r)
               end
         in
            read is
         end
      val _ = EndPoint.advertise (ep, SOME 0w42, onConnect)
   in
      ()
   end

val () = Main.run ("notifier", main)
