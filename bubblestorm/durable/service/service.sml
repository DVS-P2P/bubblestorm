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

structure Service :> SERVICE =
   struct
      (* conversation types *)
      local      
         open Conversation
         open Serial
      in
         datatype accept = ACCEPT
         fun acceptTy x = Method.new {
            name     = "durable.accept",
            datatyp  = ACCEPT,
            ackInfo  = AckInfo.silent,
            duration = Duration.oneShot,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentDurableAccept,
            receiveStatistics = SOME Stats.receivedDurableAccept
         } `bool $ x

         datatype store = STORE
         fun storeTy x = Entry.new {
            name     = "durable.store",
            datatyp  = STORE,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.manual,
            sendStatistics    = SOME Stats.sentDurableStore,
            receiveStatistics = SOME Stats.receivedDurableStore
         } `Record.t `bool `int32l `acceptTy $ x

         datatype lookup = LOOKUP
         fun lookupTy x = Entry.new {
            name     = "durable.lookup",
            datatyp  = LOOKUP,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentDurableLookup,
            receiveStatistics = SOME Stats.receivedDurableLookup
         } `Lookup.t $ x
      end

      datatype t = T of {
         state  : BasicBubbleType.bubbleState,
         store  : store Conversation.Entry.t,
         lookup : lookup Conversation.Entry.t,
         close  : unit -> unit
      }
      
      type stub = CUSP.Address.t * store Conversation.Entry.t *
                  lookup Conversation.Entry.t * Real64.real
      
      local
         open Serial
      in
         val stub = aggregate tuple4 `CUSP.Address.t `storeTy `lookupTy `real64l $

         fun load x = x
         fun store (T this) = (
            BasicBubbleType.address (#state this),
            #store this,
            #lookup this,
            NodeAttributes.capacity (BasicBubbleType.attributes (#state this))
         )
         fun extra () = ()

         val t = map { load=load, store=store, extra=extra } stub
      end

      val r = Conversation.Reliability.reliable

      fun setTimeout onTimeout =
         let            
            val event = Main.Event.new (fn _ => onTimeout ())
            val () = Main.Event.scheduleIn (event, Config.durableTimeout)
         in
            fn () => Main.Event.cancel event
         end

      fun store (T this, (address, store, _, _), record, data, forward, markDead) =
         let
            val cancelTimeout = ref (fn () => ())
            
            fun onConnect NONE = markDead ()
              | onConnect (SOME (conversation, method)) =
               let
                  val () = (!cancelTimeout) ()
                  fun cancel () =
                     ( Conversation.reset conversation ; markDead () )
                  val () = cancelTimeout := setTimeout cancel
                  fun kill () = ( cancel () ; (!cancelTimeout) () )
                  
                  fun completed false = kill ()
                    | completed true = (!cancelTimeout) ()
                    
                  fun done _ false = kill ()
                    | done stream true =
                     Conversation.Manual.sendShutdown (conversation, stream, {
                        complete = completed, reliability = r
                     })

                  fun sendData stream =
                     Conversation.Manual.send (conversation, stream, {
                        buffer = data, complete = done stream, reliability = r
                     })
                     
                  val stream = ref NONE
                  val accepted = ref false
                  
                  fun onAccept false = kill ()
                    | onAccept true = case !stream of
                        NONE => accepted := true
                      | SOME stream => sendData stream
                  
                  fun getStream s = case !accepted of
                        false => stream := SOME s
                      | true => sendData s
                  
                  val (accept, _) = Conversation.response (conversation, {
                     methodTy = acceptTy,
                     method = onAccept
                  })
                  
                  val size = Word8Vector.length data
               in
                  method record forward size accept getStream
               end
            
            val cancel =
               Conversation.associate (BasicBubbleType.endpoint (#state this), 
                  address, {
               entry    = store,
               entryTy  = storeTy,
               complete = onConnect
            })
         in
            cancelTimeout := setTimeout (fn () => ( cancel () ; markDead () ))
         end
      
      fun onStore (state, responsible, route) 
                  conversation record forward size accept stream =
         case CUSP.Host.remoteAddress (Conversation.host conversation) of
            NONE => Conversation.reset conversation
          | SOME remoteAddress =>
               let
                  val request = Record.decode (state, record)
                  
                  fun readShutdown _ false = Conversation.reset conversation
                    | readShutdown (data, pos) true =
                     let
                        fun onSuccess false = ()
                          | onSuccess true =
                           if forward then route (record, data, remoteAddress) 
                           else ()
                     in
                        Backend.store (request, data, pos, onSuccess)
                     end
                  
                  fun readData _ false = Conversation.reset conversation
                    | readData (buffer, pos) true =
                     Conversation.Manual.recvShutdown (conversation, stream, {
                        complete = readShutdown (Word8ArraySlice.vector buffer, pos)
                     })
                     
                  fun startReading pos =
                     let
                        val buffer = Word8ArraySlice.full (Word8Array.tabulate (size, fn _ => 0w0))
                     in
                        Conversation.Manual.recv (conversation, stream, {
                           buffer = buffer, complete = readData (buffer, pos), reliability = r
                        })
                     end
                     
                  fun onAccept _ false =
                     ( CUSP.InStream.reset stream ; accept false )
                    | onAccept pos true =
                     ( startReading pos ; accept true )
               in
                  case responsible request of
                     SOME pos => Backend.isNew (request, onAccept pos)
                   | NONE => ()
               end
      
      fun lookup (T this, (address, _, lookup, _), request, markDead) =
         let
            val cancelTimeout = ref (fn () => ())
            
            fun onConnect connection =
               let
                  val () = (!cancelTimeout) ()
               in
                  case connection of
                     NONE => markDead ()
                   | SOME (_, method) => method request
               end

            val cancel =
               Conversation.associate (BasicBubbleType.endpoint (#state this), 
                  address, {
               entry    = lookup,
               entryTy  = lookupTy,
               complete = onConnect
            })
         in
            cancelTimeout := setTimeout (fn () => ( cancel () ; markDead () ))
         end
      
      fun onLookup state _ lookup =
         Backend.lookup (Lookup.receive (state, lookup))

      fun new { state, responsible, route } =
         let
            (* setup services *)
            val (store, closeStore) = 
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = NONE,
                  entryTy = storeTy,
                  entry   = onStore (state, responsible, route)
               })
            val (lookup, closeLookup) = 
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = NONE,
                  entryTy = lookupTy,
                  entry   = onLookup state
               })
         in
            T {
               state = state,
               store = store,
               lookup = lookup,
               close = fn () => ( closeStore () ; closeLookup () )
            }
         end
      
      fun close (T this) = (#close this) ()
      
      fun capacity (_, _, _, capacity) = capacity

      fun address (address, _, _, _) = address
   end
