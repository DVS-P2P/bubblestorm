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

(* This program connects to a remote host to send the enocded notifications data.
 * The remote application is supposed to send notifications.
 * Expects 1 command line argument specifying the remote address. *)

fun main () =
   let
      fun handler exn =
         print ("CUSP exn: " ^ General.exnMessage exn ^ "\n")
      val ep = 
         EndPoint.new { 
            port    = SOME 8586,
            key     = Crypto.PrivateKey.new { entropy = Entropy.get },
            handler = handler,
            entropy = Entropy.get,
            options = NONE
         }
      val localAddr = List.hd (Address.fromString "localhost:8586")
      
      val resultId = ref 0
      fun resultReceiver result =
         let
            val resId = !resultId
            val () = resultId := resId + 1
            val () = print (Int.toString resId ^ " notified\n")
            fun read is =
               let
                  fun r (InStream.DATA x) = 
                     (print (Int.toString resId ^ "   data: " ^ Int.toString (Word8ArraySlice.length x) ^ "\n")
                     ; read is)
                   |  r InStream.SHUTDOWN = ()
                   |  r InStream.RESET = print "result reset\n"
               in
                  InStream.read (is, ~1, r)
               end
            val payload = Notification.Result.payload result
         in
            read payload
         end
      
      val notification =
         Notification.new {
            endpoint = ep,
            resultReceiver = resultReceiver
         }
      val notData = Notification.encode (notification, localAddr)
      
      fun onContact (SOME (_, os)) =
         let
            fun done OutStream.READY = OutStream.shutdown (os, fn _ => ())
             |  done OutStream.RESET = print "write reset\n"
         in
            OutStream.write (os, notData, done)
         end
       |  onContact NONE = print "contact fail\n"
      
      val destAddr = hd (Address.fromString (hd (CommandLine.arguments ())))
      val _ = EndPoint.contact (ep, destAddr, 0w42, onContact)
   in
      ()
   end

val () = Main.run ("notified", main)
