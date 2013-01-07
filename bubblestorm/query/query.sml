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

structure Query : QUERY =
   struct
      open Log
      open CUSP
      open Conversation
      open Stats
      
      val module = "bubblestorm/query"
      
      structure Notification = Notification (ID)
      structure IdMap = HashTable (ID)
      
      (* type recoed *)
      datatype fields = T of {
         queryBubble : BubbleType.instant,
         responder : {
            query : Word8VectorSlice.slice,
            respond : {id : ID.t, write : CUSP.OutStream.t option -> unit} -> unit
         } -> unit
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      (* handle incoming queries *)
      fun queryHandler (T { queryBubble, responder }) data =
         let
            val () = logExt (DEBUG, fn () => module ^ "/queryHandler",
                             fn () => "Received query")
            val basic = BubbleType.basicInstant queryBubble
            val endpoint = BubbleType.endpoint basic
            val (sender, headerLen) = Notification.decode (data, endpoint)
            val queryPayload = Word8VectorSlice.subslice (data, headerLen, NONE)
            
            (* handle application-level response *)
            fun respond { id, write } =
               let
                  val () =
                     logExt (DEBUG, fn () => module ^ "/queryHandler/respond",
                        fn () => "I have a response (" ^ ID.toString id ^ ")")
               in
                  sender (id, Notification.ON_REQUEST write)
               end
         in
            (* pass the query to the application layer *)
            responder { query = queryPayload, respond = respond }
         end
      
      (* - - - Public API - - - *)
      
      fun new { master, dataBubble, queryBubbleId, queryBubbleName, lambda, priority, reliability, responder } =
         let
            val queryBubble = BubbleType.newInstant {
               master = master,
               typeId = queryBubbleId,
               name = queryBubbleName,
               priority = priority,
               reliability = reliability
            }
            val this = T {
               queryBubble = queryBubble,
               responder = responder
            }
            val () = BubbleType.match {
               subject = BubbleType.basicInstant queryBubble,
               object  = dataBubble,
               lambda  = lambda,
               handler = queryHandler this
            }
         in
            this
         end

      fun query (this, { query, responseCallback }) =
         let
            val created = Main.Event.time ()
            val queryBubble = get#queryBubble this
            val basic = BubbleType.basicInstant queryBubble
            val endpoint = BubbleType.endpoint basic
            val localAddress = BubbleType.address basic
            val results = IdMap.new ()
            fun resultReceiver result =
               let
                  val id = Notification.Result.id result
               in
                  case IdMap.get (results, id) of
                     SOME (first, _, count) => 
                        let
                           val count = count + 1
                           val last = Main.Event.time ()
                           val record = (first, last, count)
                           val () = IdMap.update (results, id, record)
                        in
                           (* discard duplicate result *)
                           Notification.Result.cancel result
                        end
                   | NONE => (* new result *)
                        let
                           val first = Main.Event.time ()
                           val last = first
                           val count = 1
                           val record = (first, last, count)
                           val () = IdMap.add (results, id, record)
                           
                           val stream = Notification.Result.payload result
                        in
                           responseCallback { id = id, stream = stream }
                        end
               end
            val notification = Notification.new
               { endpoint=endpoint, resultReceiver=resultReceiver }
            val notificationData = Notification.encode (notification, localAddress)
            
            (* bubblecast *)
            val payload = Vector.concat [notificationData, query]
            (* TODO slicecast, incremental, ... *)
            val () = InstantBubble.create {
               typ = queryBubble,
               data = payload
            }
            
            (* abort function *)
            fun abort () = 
               let
                  fun bucket (_, (first, last, count)) =
                     let
                        val latency = Time.- (first, created)
                        val complete = Time.- (last, created)
                        val () = Statistics.add queryLatency    (Time.toSecondsReal32 latency)
                        val () = Statistics.add queryCompletion (Time.toSecondsReal32 complete)
                     in
                        Statistics.add queryResults (Real32.fromInt count)
                     end
                  
                  val () = Iterator.app bucket (IdMap.iterator results)
                  val () = 
                     if IdMap.isEmpty results 
                     then Statistics.add queryResults 0.0
                     else ()
               in
                  Notification.close notification
               end
         in
            abort
         end
      
      fun queryBubble this =
         get#queryBubble this
      
   end
