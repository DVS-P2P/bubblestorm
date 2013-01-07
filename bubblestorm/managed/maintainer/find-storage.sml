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

structure FindStorage :> FIND_STORAGE =
   struct
      val module = "bubblestorm/bubble/managed/find-storage"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)      

      local
         open CUSP
         open Conversation
         open Serial
      in
         datatype offerStorage = OFFER_STORAGE
         fun offerStorageTy x = Entry.new {
            name     = "offerStorage",
            datatyp  = OFFER_STORAGE,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentManagedOffer,
            receiveStatistics = SOME Stats.receivedManagedOffer
         } `StorageService.Description.t `int32l `real64l `real64l $ x
      end
      
      datatype t = T of {
         bubble : BasicBubbleType.t,
         offerStorage : offerStorage Conversation.Entry.t,
         close : unit -> unit,
         justJoined : bool ref
      }
      
      local
         open Serial
         val serial = aggregate tuple3 `CUSP.Address.t `offerStorageTy `real64l $
      in
         val { toVector, parseVector, ... } = methods serial
      end
      
      fun receiveOffer frontend conversation service position capacity d1 =
         case CUSP.Host.remoteAddress (Conversation.host conversation) of
            SOME address =>
               let
                  val () = log (fn () => "receiving storage offer from " ^ 
                                 CUSP.Address.toString address)
               in
                  Frontend.addStorage frontend {
                     service  = service,
                     capacity = capacity,
                     d1       = d1,
                     filter   = fn _ => true, (* any bucket *)
                     position = position
                  }
               end
          | NONE =>
               let
                  val () = log (fn () => "resetting bogus storage offer")
               in
                  Conversation.reset conversation
               end

      (* TODO avoid code duplication *)
      (*fun myCapacity state =
         let
            val toReal64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
            val d = toReal64 (SystemStats.degree (BasicBubbleType.stats state))
            val dMin = Real64.fromInt Config.minDegree
         in
            d / dMin
         end*)
               
      (* offer service to bubblecast initiator *)
      fun respondWithOffer (state, service) (position, data) =
         if not (Option.isSome (StorageService.description service)) then () else
         let
            val (address, entry, d1) = parseVector data
            fun onConnect connection =
               case connection of
                  SOME (_, offer) => (* successfully connected *)
                     (case StorageService.description service of
                        NONE => () (* service is not up anymore *)
                      | SOME description =>
                           let
                              val () = log (fn () => "offering storage to maintainer " ^ 
                                             CUSP.Address.toString address)
                           in
                              offer description position 1.0 d1
                           end)
                | NONE => (* failed to connect *)
                     log (fn () => "could not contact maintainer " ^ 
                                    CUSP.Address.toString address)
                                    
            val () = log (fn () => "contacting maintainer " ^ 
                                    CUSP.Address.toString address)
         in
            (* TODO: do we have to cancel non-responding associate calls? *)
            ignore (Conversation.associate (BasicBubbleType.endpoint state, address, {
               entry    = entry,
               entryTy  = offerStorageTy,
               complete = onConnect
            }))
         end

      fun new { state, types, name, typeID, service, frontend, statistics : Stats.managed } =
         let
            (* create offerStorage receiver service *)
            val (offerStorage, close) = 
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = NONE,
                  entryTy = offerStorageTy,
                  entry   = receiveOffer frontend
               })

            (* create find maintainer bubble type *)
            val bubble = BasicBubbleType.new {
               state    = state,
               name     = name,
               typeId   = typeID,
               class    = BasicBubbleType.MAXIMUM {
                              withBubbles = types,
                              handler = respondWithOffer (state, service)
                           },
               priority = Config.findMaintainerPriority,
               reliability = Config.findMaintainerReliability
            }

            fun ifOnline f =
               if SystemStats.status (BasicBubbleType.stats state) = SystemStats.ONLINE 
               then f () else ()

            (* statistics for desired number of peers per maintainer *)
            fun targetSize () =
               ifOnline (fn () => Statistics.add (#target statistics) 
                  (Real32.fromInt (BasicBubbleType.targetSize bubble)))
            val () = Statistics.addPoll (#target statistics, targetSize)

            (* statistics for maintainer density *)
            val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
            val density = toReal32 o Density.toReal64 o Density.bubbleSize
            fun targetDensity () = ifOnline (fn () => 
               Statistics.add (#density statistics) (density bubble))
            val () = Statistics.addPoll (#density statistics, targetDensity)
         in
            T {
               bubble = bubble,
               offerStorage = offerStorage,
               close = close,
               justJoined = ref false
            }
         end
      
      (* issue a slicecast [x,y) *)
      fun send (T { bubble, offerStorage, ... }, start, stop) =
         let
            val state = BasicBubbleType.state bubble
            val address = BasicBubbleType.address state
            val d1 = SystemStats.d1 (BasicBubbleType.stats state)
            val slicecast = BasicBubbleType.slicecast {
               bubbleType = bubble,
               size = stop
            }
            val () = log (fn () => "sending FindStorage [" ^ 
                           Int.toString start ^ "," ^ Int.toString stop ^ ")")
         in
            (* find storage peers *)
            slicecast {
               data = toVector (address, offerStorage, d1),
               start = start,
               stop = stop
            }
         end

      (* issue a slicecast [old,new) *)
      fun onRoundSwitch (T this) =
         let
            (* the find_maintainer bubbles and leaves preserve the bubble density,
               but we may have joined at the end of the measurement 
               round and missed a lot of find_maintainer messages.
               *)
            val bubble = #bubble this
            val state = BasicBubbleType.state bubble
            fun joinedSize () = Density.toPosition state (Density.bubbleSizeAfterJoin bubble)
            fun stableSize () = Density.toPosition state (Density.bubbleSize' bubble)
            val old = if !(#justJoined this) then joinedSize () else stableSize ()
            val new = Density.toPosition state (Density.bubbleSize bubble)
         in
            if new > old then send (T this, old, new) else ()
         end
      
      (* issue a slicecast [0,targetSize) *)
      fun onJoinComplete (T this) =
         let
            val () = (#justJoined this) := true
         in
            send (T this, 0, BasicBubbleType.targetSize (#bubble this))
         end
      
      (* close the service *)
      fun onLeave (T { close, ... }) = close ()
      
      fun bubbleSize (T { bubble, ... }) = BasicBubbleType.targetSize bubble
   end
