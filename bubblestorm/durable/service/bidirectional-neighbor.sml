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

structure BidirectionalNeighbor :> BIDIRECTIONAL_NEIGHBOR =
   struct
      (* conversation types *)
      local      
         open Conversation
         open Serial
      in
         datatype contact = CONTACT
         fun contactTy x = Entry.new {
            name     = "durable.contact",
            datatyp  = CONTACT,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentDurableContact,
            receiveStatistics = SOME Stats.receivedDurableContact
         } `ID.t `Service.t $ x

         datatype quit = QUIT
         fun quitTy x = Entry.new {
            name     = "durable.quit",
            datatyp  = CONTACT,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentDurableQuit,
            receiveStatistics = SOME Stats.receivedDurableQuit
         } `ID.t $ x
      end
      
      datatype t = T of {
         state   : BasicBubbleType.bubbleState,
         service : Service.t,
         table   : RoutingTable.t,
         close   : unit -> unit
      }
      
      fun setTimeout onTimeout =
         let            
            val event = Main.Event.new (fn _ => onTimeout ())
            val () = Main.Event.scheduleIn (event, Config.durableTimeout)
         in
            fn () => Main.Event.cancel event
         end

      fun myid (T this) =
         NodeAttributes.id (BasicBubbleType.attributes (#state this))

      fun contact (T this) (id, service) =
         let
            val cancelTimeout = ref (fn () => ())
            
            fun onConnect connection =
               let
                  val () = (!cancelTimeout) ()
               in
                  case connection of
                     NONE => RoutingTable.markDead (#table this, id)
                   | SOME (_, method) => method (myid (T this)) (#service this)
               end

            val cancel =
               Conversation.associate (BasicBubbleType.endpoint (#state this), 
                  Service.address service, {
               entry    = Conversation.Entry.fromWellKnownService Config.durableContact,
               entryTy  = contactTy,
               complete = onConnect
            })
         in
            cancelTimeout := setTimeout (
               fn () => ( cancel () ; RoutingTable.markDead (#table this, id) )
            )
         end
      
      
      fun quit (T this) (id, service) =
         let
            val cancelTimeout = ref (fn () => ())
            
            fun onConnect connection =
               let
                  val () = (!cancelTimeout) ()
               in
                  case connection of
                     NONE => RoutingTable.markDead (#table this, id)
                   | SOME (_, method) => method (myid (T this))
               end

            val cancel =
               Conversation.associate (BasicBubbleType.endpoint (#state this), 
                  Service.address service, {
               entry    = Conversation.Entry.fromWellKnownService Config.durableQuit,
               entryTy  = quitTy,
               complete = onConnect
            })
         in
            cancelTimeout := setTimeout (
               fn () => ( cancel () ; RoutingTable.markDead (#table this, id) )
            )
         end
      
      fun onContact table _ id service =
         RoutingTable.contact (table, id, service)

      fun onQuit table _ id = RoutingTable.quit (table, id)

      fun new (state, service, table) =
         let
            (* setup services *)
            val (_, closeContact) = 
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = SOME Config.durableContact,
                  entryTy = contactTy,
                  entry   = onContact table
               })
            val (_, closeQuit) =
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = SOME Config.durableQuit,
                  entryTy = quitTy,
                  entry   = onQuit table
               })
         in
            T {
               state   = state,
               service = service,
               table   = table,
               close   = fn () => ( closeContact () ; closeQuit () )
            }
         end
      
      fun close (T this) = (#close this) ()
   end
