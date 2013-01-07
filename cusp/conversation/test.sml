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

open Conversation
open CUSP
open Log

local
   open Serial
   open Policy
   
   fun service x = make {
      ackInfo  = AckInfo.silent,
      duration = Duration.permanent,
      qos      = QOS.static (Priority.default, Reliability.reliable),
      tailData = TailData.string { maxLength = 256*1024 }
   } x
   fun manual x = make {
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (Priority.default, Reliability.reliable),
      tailData = TailData.manual
   } x
   
   datatype request   = REQUEST
   datatype response  = RESPONSE
in
   fun requestTy  x = Entry.new  service REQUEST  "request" `int32l `responseTy $ x
   and responseTy x = Method.new manual  RESPONSE "response" $ x
end

val REQUEST = 0w69

fun server () =
   let
      val len = 8192
      val endpoint = endpoint (SOME 8585)
      val packet = Word8Vector.tabulate (len, fn _ => 0w0)
      
      fun request conv length response s =
         let
            fun tail length os =
               if length >= len then
                  Manual.send (conv, os, {
                     buffer      = packet,
                     reliability = Policy.Reliability.reliable,
                     complete    = fn _ => tail (length - len) os
                  })
               else if length > 0 then
                  Manual.send (conv, os, {
                     buffer      = Word8Vector.tabulate (length, fn _ => 0w0),
                     reliability = Policy.Reliability.reliable,
                     complete    = fn _ => tail 0 os
                  })
               else
                  Manual.sendShutdown (conv, os, {
                     reliability = Policy.Reliability.reliable,
                     complete    = fn _ => ()
                     (*ignore (EndPoint.whenSafeToDestroy (endpoint, MLton.GC.collect)) *)
                  })
         in
            response (tail length)
         end
      
      val _ =
         advertise (endpoint, {
            service = SOME REQUEST,
            entryTy = requestTy,
            entry   = request
         })
   in
      ()
   end

fun client hot server runs wsize rsize =
   let
      val server = 
         case Address.fromString server of
            [] => (print ("Bad address " ^ server ^ ", using localhost:8585\n")
                     ; List.hd (Address.fromString "localhost:8585"))
          | x::_ => x
      
      (* We need multiple end-points so they shutdown before next use.
       * Otherwise we will inadvertantly start measuring hot.
       * The number 40 might need to be larger for faster CPUs.
       *)
      val endpoints = if hot then 1 else 40
      val endpoints = Vector.tabulate (endpoints, fn _ => endpoint NONE)
      
      val runs = ref (valOf (Int.fromString runs))
      val wsize = valOf (Int.fromString wsize)
      val rsize = valOf (Int.fromString rsize)
      val buffer = CharVector.tabulate (wsize, fn _ => #"0")
      val len = 32768
      val packet = Word8Array.tabulate (len, fn _ => 0w0)
      
      val toTidy = ref (Vector.length endpoints)
      fun tidy () = Vector.app clean endpoints
      and clean e = ignore (EndPoint.whenSafeToDestroy (e, amDone))
      and amDone () = if !toTidy = 1 then Main.stop () else
                      toTidy := !toTidy - 1
      
      fun responseCb conv is = 
         let
            fun tail length =
               if length >= len then
                  Manual.recv (conv, is, {
                     buffer      = Word8ArraySlice.full packet,
                     reliability = Policy.Reliability.reliable,
                     complete    = fn _ => tail (length - len)
                  })
               else if length > 0 then 
                  Manual.recv (conv, is, {
                     buffer      = Word8ArraySlice.slice (packet, 0, SOME len),
                     reliability = Policy.Reliability.reliable,
                     complete    = fn _ => tail 0
                  })
               else
                  Manual.recvShutdown (conv, is, {
                     complete    = fn _ => 
                       if !runs = 1 then tidy () else
                       (runs := !runs - 1; ignore (go ()))
                  })
         in
            tail rsize
         end
      and cb NONE =
            (print ("Failed to contact server " ^ Address.toString server ^ "!\n")
             ; Main.stop ())
        | cb (SOME (conversation, request)) =
         let
            val (response, _) =
               response (conversation, {
                  methodTy = responseTy,
                  method   = responseCb conversation
               })
               
            val () = setLimits (conversation, NONE)
         in
            request rsize response buffer
         end
      and go () =
         associate (Vector.sub (endpoints, !runs mod Vector.length endpoints), 
                    server, {
            entry    = Entry.fromWellKnownService REQUEST,
            entryTy  = requestTy,
            complete = cb
         })
   in
      ignore (go ())
   end

fun main () =
   case CommandLine.arguments () of 
      ["server"] => server ()
    | ["hot",  server, runs, wsize, rsize] => client true  server runs wsize rsize
    | ["cold", server, runs, wsize, rsize] => client false server runs wsize rsize
    | _ => print "Bad command-line.\n"

val () = Main.run ("conversation/test", main)
val () = print "Clean exit.\n"
