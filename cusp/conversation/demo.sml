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

structure Event = Main.Event

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
      tailData = TailData.manual
   } x
   fun string x = make {
      ackInfo  = AckInfo.silent,
      duration = Duration.permanent,
      qos      = QOS.static (Priority.default, Reliability.reliable),
      tailData = TailData.string { maxLength = 80 }
   } x
   fun ackd x = make {
      ackInfo  = AckInfo.callback,
      duration = Duration.permanent,
      qos      = QOS.static (Priority.default, Reliability.reliable),
      tailData = TailData.string { maxLength = 80 }
   } x
   fun simple x = make {
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (Priority.default, Reliability.reliable),
      tailData = TailData.none
   } x
   
   datatype register   = REGISTER
   datatype send       = SEND
   datatype event      = EVENT
   datatype ok         = OK
in
   fun registerTy   x = Entry.new  service REGISTER   "register" `eventTy `okTy $ x
   and sendTy       x = Entry.new  string  SEND       "send"     `okTy          $ x
   and eventTy      x = Method.new ackd    EVENT      "event"                   $ x
   and okTy         x = Method.new simple  OK         "ok"       `unit          $ x
end

val REGISTER = 0w69
val SEND     = 0w70

fun handler exn =
   log (WARNING, "conversation/demo/endpoint", fn () => General.exnMessage exn)
  
fun endpoint port = 
   EndPoint.new { 
      port    = port,
      handler = handler,
      entropy = Entropy.get,
      key     = Crypto.PrivateKey.new { entropy = Entropy.get },
      options = NONE }

fun hostname conversation =
   let
      val host = host conversation
      val address = Option.map Address.toString (Host.remoteAddress host)
   in
      Crypto.PublicKey.toString (Host.key host) ^ " <" ^ getOpt (address, "???") ^ ">"
   end

fun server () =
   let
      val endpoint = endpoint (SOME 8080)
      val clients = Ring.new ()
      
      fun status evt =
         let
            val channels = Iterator.length (EndPoint.channels endpoint)
            val hosts = Iterator.length (EndPoint.hosts endpoint)
            val () = print ("Connected to " ^ Int.toString channels ^ "/" ^ 
                            Int.toString hosts ^ " channels/hosts: " ^
                            Int.toString (MLton.size endpoint) ^ " bytes\n")
         in
            Event.scheduleIn (evt, Time.fromSeconds 10)
         end
      val _ = Event.scheduleIn (Event.new status, Time.fromSeconds 0)
      
      fun register conversation event ok instream =
         let
            val () = print ("Subscriber joined: " ^ hostname conversation ^ "\n")
            val who = hostname conversation
            
            fun send msg =
               let
                  fun timeout () =
                     setTimeout (conversation, 
                        if activeOutStreams conversation = 0
                        then NONE
                        else SOME { limit = Time.fromSeconds 20,
                                    dead  = fn () => (print ("Subscriber " ^ who ^ " timeout!\n")
                                                      ; reset conversation) })
                  fun done ok =
                     if ok then timeout () else 
                     (print ("Delivery to subscriber " ^ who ^ " failed!\n")
                      ; reset conversation)
                  val () = event done msg
               in
                  timeout ()
               end
            
            val node = Ring.wrap send
            val () = Ring.add (clients, node)
            
            fun done ok = 
               let
                  val () = 
                     if ok
                     then print ("Subscriber " ^ who ^ " left.\n")
                     else print ("Subscriber " ^ who ^ " reset subscription!\n")
               in
                  Ring.remove node
               end
            
            val () = ok ()
         in
            Manual.recvShutdown (conversation, instream, {
               complete = done 
            })
         end
      
      fun send conversation ok msg =
         let
            val () = print ("Message from: " ^ hostname conversation ^ "\n")
            val () = Iterator.app (fn f => Ring.unwrap f msg) (Ring.iterator clients)
         in
            ok ()
         end
         
      val _ = 
         advertise (endpoint, {
            service = SOME REGISTER,
            entryTy = registerTy,
            entry   = register
         })
      val _ =
         advertise (endpoint, {
            service = SOME SEND,
            entryTy = sendTy,
            entry   = send
         })
   in
      ()
   end

fun handleFail f  x =
   case x of
      NONE => (print ("Failed to contact server!\n"); Main.stop ())
    | SOME x => f x

fun subscriber server = 
   let
      val endpoint = endpoint NONE
      
      fun subscribe (conversation, register) =
         let
            val () = print ("Associated to " ^ hostname conversation ^ "...\n")
            
            val (ok, _) =
               response (conversation, {
                  methodTy = okTy,
                  method   = fn () => print "Registration successful!\n"
               })
            val (event, _) =
               response (conversation, {
                  methodTy = eventTy,
                  method   = fn msg => print ("New message: " ^ msg ^ "\n")
               })
            
            fun stop outstream () =
               let
                  val () = print "Control-C! Unregistering\n"
                  val _ = EndPoint.whenSafeToDestroy (endpoint, Main.stop)
                  val () =
                     Manual.sendShutdown (conversation, outstream, {
                        reliability = Policy.Reliability.reliable,
                        complete = fn ok => print ("Status: " ^ Bool.toString ok ^ "\n") })
               in
                  Main.REHOOK
               end
            
            fun doneSend outstream =
               ignore (Main.signal (Posix.Signal.int, stop outstream))
            
         in
            register event ok doneSend
         end
   in
      associate (endpoint, server, {
         entry    = Entry.fromWellKnownService REGISTER,
         entryTy  = registerTy,
         complete = handleFail subscribe
      })
   end

fun publisher server msg =
   let
      val endpoint = endpoint NONE
      
      fun publish (conversation, send) = 
         let
            val () = print ("Associated to " ^ hostname conversation ^ "...\n")
            
            fun ok () =
               let
                  val () = print "Received ok!\n"
               in
                  ignore (EndPoint.whenSafeToDestroy (endpoint, Main.stop))
               end
            
            val (ok, _) =
               response (conversation, {
                  methodTy = okTy,
                  method   = ok
               })
         in
            send ok msg
         end
   in
      associate (endpoint, server, {
         entry    = Entry.fromWellKnownService SEND,
         entryTy  = sendTy,
         complete = handleFail publish
      })
   end
   
fun addr server =
   case Address.fromString server of
      [] => (print ("Bad address " ^ server ^ ", using localhost:8080\n")
               ; List.hd (Address.fromString "localhost:8080"))
    | x::_ => x

fun main () =
   case CommandLine.arguments () of 
      ["server"] => server ()
    | ["subscribe", server] => ignore (subscriber (addr server))
    | ["publish", server, msg] => ignore (publisher (addr server) msg)
    | _ => print "Bad command-line.\n"

val () = Main.run ("conversation-demo", main)
