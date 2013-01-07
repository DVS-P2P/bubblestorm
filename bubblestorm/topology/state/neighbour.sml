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

structure Neighbour :> NEIGHBOUR =
   struct
      open CUSP
      
      datatype fields = T of {
         conversation : Conversation.t,
         outstream : OutStream.t,
         instream  : InStream.t,
         methods : methodsIn,
         unhook : (unit -> unit) ref,
         deathHandler : (unit -> unit) ref,
         teardownHandler : (unit -> unit) ref
      }
      withtype t = fields
      
      val module = "topology/neighbour"
      
      fun conversation (T { conversation, ... }) = conversation
      fun methods (T { methods, ... }) = methods
      fun host this = Conversation.host (conversation this)
      fun address this = CUSP.Host.remoteAddress (host this)
      fun eq (a, b) = Conversation.eq (conversation a, conversation b)
      
      fun setName (T { instream, outstream, ... }, name) =
         let
            val desc = { localName = name, statistics = fn _ => () }
            val () = InStream.setDescription (instream, desc)
         in
            OutStream.setDescription (outstream, desc)
         end
      fun name (T { instream, ... }) = InStream.localName instream

      fun setUnhook (T { unhook, ... }, newFn) =
         let
            val () = (!unhook) ()
            fun noop () = ()
            fun doit () = (unhook := noop; newFn ())
         in
            unhook := doit
         end

      fun addDeathHandler (T { deathHandler, ... }, newFn) =
         let
            val nextHandler = !deathHandler
            fun chained () =
               let
                  val () = newFn ()
               in
                  nextHandler ()
               end
         in
            deathHandler := chained
         end
      
      fun setTeardownHandler (T { teardownHandler, ... }, newFn) =
         teardownHandler := newFn
      
      (*fun localName (n as T { outstream, ... }) =
         let
            val host = host n
            val localAddr = Host.localAddress host
            val localAddrStr = Option.map Address.toString localAddr
            val remoteAddr = Host.remoteAddress host
            val remoteAddrStr = Option.map Address.toString remoteAddr
            val localId = OutStream.globalID outstream
         in
            getOpt (localAddrStr, "?") ^ "/" ^ getOpt (remoteAddrStr, "?")
               ^ "/" ^ Word16.toString localId
         end

      fun remoteName (n as T { instream, ... }) =
         let
            val host = host n
            val localAddr = Host.localAddress host
            val localAddrStr = Option.map Address.toString localAddr
            val remoteAddr = Host.remoteAddress host
            val remoteAddrStr = Option.map Address.toString remoteAddr
            val remoteId = InStream.globalID instream
         in
            getOpt (remoteAddrStr, "?") ^ "/" ^ getOpt (localAddrStr, "?")
               ^ "/" ^ Word16.toString remoteId
         end
      *)
      fun toString (n as T { outstream, ... }) = 
         let
            val host = host n
            val remoteAddr = Host.remoteAddress host
            val remoteAddrStr = Option.map Address.toString remoteAddr
            val localId = OutStream.globalID outstream
         in
            concat [
               name n, " (", getOpt (remoteAddrStr, "?"), 
                        "/", Word16.toString localId, ")" ]
         end
      
      fun reset (n as T { deathHandler, unhook, ... }) =
         let
            val () = Log.log (Log.WARNING, module, fn () => "resetting " ^ toString n)
            val () = (!unhook) ()
            (* Might cause the instream to be reset, running deathHandler twice *)
            val oldHandler = !deathHandler
            val () = deathHandler := (fn () => ())
            (* running deathHandler will reset it to the bug detection *)
         in
            oldHandler ()
         end
      
      fun isZombie (T { instream, ... }) =
        case InStream.state instream of
           InStream.IS_ACTIVE => false
         | InStream.IS_RESET => true
         | InStream.IS_SHUTDOWN => true
      
      fun new (conversation, instream, outstream, methods) =
         let
            val death = ref (fn () => ())
            val this = T {
               conversation = conversation,
               outstream = outstream,
               instream = instream,
               methods = methods,
               unhook = ref (fn () => ()),
               deathHandler = death,
               teardownHandler = ref (fn () => ())
             }
            
             fun bug () = raise At (module, Fail "Neighbour died twice!")
             fun kill () = (OutStream.reset outstream; Conversation.reset conversation; death := bug)
             val () = death := kill
             
             val () = setName (this, "anonymous neighbour")
             
             val deathTimeout = Config.deathTimeout ()
             val keepAliveTime = Config.keepAliveTimeout ()
             
             open Log
             fun timeout () =
                let
                   val () = log (DEBUG, "topology/neighbour/limits",
                      fn () => ("Keep-alive tripped by " ^ name this))
                      
                   val { keepAlive, ... } = methods
                   fun ackd false = () (* already been reset *)
                     | ackd true = (* Works. Setup sending another keep-alive. *)
                      Conversation.setTimeout (conversation, SOME {
                         limit = keepAliveTime,
                         dead  = timeout
                      })
                      
                   val () = keepAlive ackd
                   
                   fun reallyDead () =
                      let
                         val () = log (DEBUG, "topology/neighbour/limits",
                            fn () => ("Keep-alive failed for " ^ name this))
                      in
                         Conversation.reset conversation
                      end
                in
                   (* Setup a reset to trip on failure *)
                   Conversation.setTimeout (conversation, SOME {
                      limit = deathTimeout,
                      dead  = reallyDead
                   })
                end
             fun limitsExceeded () =
                let
                   val () = log (DEBUG, "topology/neighbour/limits",
                      fn () => ("Conversation limits exceeded by " ^ name this))
                in
                   Conversation.reset conversation
                end
             
             val () =
                Conversation.setTimeout (conversation, SOME {
                   limit = keepAliveTime,
                   dead  = timeout
                 })
             val () =
                Conversation.setLimits (conversation, SOME {
                   recv = Config.topologyConversationLimit,
                   send = Config.topologyConversationLimit,
                   quota = limitsExceeded
                 })
             
             val () =
               Conversation.Manual.recvShutdown (conversation, instream, {
                  complete = receiveShutdown this
               })
         in
            this
         end

      and receiveShutdown (T { teardownHandler, ... }) true = (!teardownHandler) ()
        | receiveShutdown this false = reset this
      
      (* Called in to finish connection after the other side stops writing *)
      fun completeTeardown (n as T { conversation, instream, outstream, deathHandler, unhook, ... }) =
        case InStream.state instream of
           InStream.IS_ACTIVE => raise At (module, Fail "Can't complete if not zombie")
         | _ => 
           let
              val () = Log.log (Log.DEBUG, module, fn () => "completing tearing down for " ^ toString n)
              val () = (!unhook) ()
           in
              Conversation.close (conversation, {
                 complete = fn () =>
                    Conversation.Manual.sendShutdown (conversation, outstream, {
                       complete = fn _ => (!deathHandler) (),
                       reliability = Conversation.Reliability.reliable })
              })
           end

      (* Call to initiate a tear-down.
       * The other side gets a grace period to tear-down his side.
       *)
      fun initiateTeardown (n as T { deathHandler, conversation, unhook, instream, outstream, ... }) =
         let
             val () = Log.log (Log.DEBUG, module, fn () => "initiating tear down for " ^ toString n)
             val () = (!unhook) ()
             val () = setTeardownHandler (n, fn () => ())
         in
            Conversation.close (conversation, {
               complete = fn () =>
                  let
                     val theyAreDone = ref (InStream.state instream <> InStream.IS_ACTIVE)
                     val weAreDone = ref false
                     fun maybeBothAreDone () =
                        if !theyAreDone andalso !weAreDone 
                        then (!deathHandler) () else ()
                     
                     fun makeUsDone () = (weAreDone := true; maybeBothAreDone ())
                     fun makeThemDone () = (theyAreDone := true; maybeBothAreDone ())
                     
                     val () = setTeardownHandler (n, makeThemDone)
                     
                     (* theyAreDone := false to prevent sendShutdown running it again *)
                     fun onTimeout _ = (theyAreDone := false; (!deathHandler) ())
                     val timeout = Main.Event.new onTimeout
                     
                     (* Setup the timeout *)
                     val () = addDeathHandler (n, fn () => Main.Event.cancel timeout)
                     val () = Main.Event.scheduleIn (timeout, Config.gracePeriod ())
                  in
                     Conversation.Manual.sendShutdown (conversation, outstream, {
                        reliability = Conversation.Reliability.reliable,
                        complete = fn _ => makeUsDone ()
                     })
                  end
              })
         end
   end
