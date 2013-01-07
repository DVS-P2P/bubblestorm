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

functor Notification(Identifier : SERIALIZABLE) : NOTIFICATION =
   struct
      open Log
      open CUSP
      open Conversation
      
      structure Identifier = Identifier
      
      (* conversation types *)
      local
         open Serial
      in
         datatype notification = NOTIFICATION
         datatype requestData = QUERY_REQUEST_DATA
         
         (* notification entry point; sends result ID and request/abort function *)
         fun notificationTy x = Entry.new {
            name     = "notification/notification",
            datatyp  = NOTIFICATION,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Priority.fromReal 500.0, Reliability.reliable),
            tailData = TailData.manual,
            sendStatistics    = SOME Stats.sentNotification,
            receiveStatistics = SOME Stats.receivedNotification
         } `Identifier.t `requestDataTy $ x
         
         (* request/abort payload function; true -> request data, false -> abort *)
         and requestDataTy x = Method.new {
            name     = "notification/requestData",
            datatyp  = QUERY_REQUEST_DATA,
            ackInfo  = AckInfo.silent,
            duration = Duration.oneShot,
            qos      = QOS.static (Priority.fromReal 500.0, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentNotificationRequestData,
            receiveStatistics = SOME Stats.receivedNotificationRequestData
         } `bool $ x
      end

      type callback = Address.t * notification Entry.t
      
      (* serialization functions *)
      local
         open Serial
         val callback = aggregate tuple2 `Address.t `notificationTy $
         val { toVector, parseVector, length, ... } = methods callback
      in
         fun notificationToVector (addr, entry) = toVector (addr, entry)
         fun parseNotification slice = (parseVector slice, length)
         val maxEncodedLength = length
         val callback = callback
      end
      
      (* Result structure *)
      structure Result =
         struct
            type t = {
               id : Identifier.t,
               stream : InStream.t,
               requestDataFn : (bool -> unit)
            }
            fun new (id, stream, requestData) =
               { id=id, stream=stream, requestDataFn=requestData }
            fun id { id, stream=_, requestDataFn=_ } =
               id
            fun payload { id=_, stream, requestDataFn } =
               let
                  val () = requestDataFn true
               in
                  stream
               end
            fun cancel { id=_, stream, requestDataFn } =
               let
                  fun readShutdownCb true = ()
                    | readShutdownCb false =
                     log (DEBUG, "notification/result/cancel", fn () => "Unexpected payload data")
                  val () = InStream.readShutdown (stream, readShutdownCb)
               in
                  requestDataFn false
               end
         end
      
      (* Type record *)
      type t = {
         endpoint : EndPoint.t,
         entry : notification Entry.t,
         unhookEntry : unit -> unit
      }
      
      fun new { endpoint, resultReceiver } =
         let
            fun notificationHandler resultReceiver (*conversation*)_ id requestFn inStream =
               let
                  val () =
                     log (DEBUG, "notification/notificationHandler",
                        fn () => "Received notification for " ^ Identifier.toString id)
                  (* TODO conversation limits, timeouts (app-defined!?) *)
                  val result = Result.new (id, inStream, requestFn)
               in
                  resultReceiver result
               end
            (* advertise *)
            val (entry, unhookEntry) = 
               advertise (endpoint, {
                  service = NONE,
                  entryTy = notificationTy,
                  entry   = notificationHandler resultReceiver
               })
               
            val this = {
               endpoint = endpoint,
               entry = entry,
               unhookEntry = unhookEntry
            }
         in
            this
         end
      
      fun close { endpoint=_, entry=_, unhookEntry } =
         unhookEntry ()
      
      fun encode ({ endpoint=_, entry, unhookEntry=_ }, localAddr) =
         notificationToVector (localAddr, entry)

      datatype sendData =
         ON_REQUEST of (CUSP.OutStream.t option -> unit)
       | IMMEDIATE of Word8Vector.vector
      type sendFn = Identifier.t * sendData -> unit
      
      fun provideCallback ({ endpoint=_, entry, unhookEntry=_ }, address) =
         (address, entry)
         
      fun receiveCallback ((address, entry), endpoint) =
         let
            (* mode: ON_REQUEST or IMMEDIATE *)
            fun sender (id, mode) = 
               let
                  val module = "notification/sender"
                  val () =
                     log (DEBUG, module,
                        fn () => "Connecting to " ^ Address.toString address
                           ^ " for notification " ^ Identifier.toString id)
                  
                  (* Either send after data has been requested... *)
                  fun onConnect (ON_REQUEST sendDataFn) (SOME (conversation, queryResponse)) =
                     let
                        val () =
                           log (DEBUG, module,
                              fn () => "Connected to " ^ Address.toString address
                                 ^ " for sending notification")
                        
                        datatype streamState =
                           INIT
                         | REQUESTED
                         | AVAILABLE of CUSP.OutStream.t
                         | DONE
                         | CANCELLED
                        val state = ref INIT
                        
                        val close = ref (fn () => ())
                        
                        fun gotOutstream os =
                           state := (case (!state) of
                              INIT =>
                                 (log (DEBUG, module, fn () => "Got out stream")
                                 ; AVAILABLE os)
                            | REQUESTED =>
                                 (log (DEBUG, module, fn () => "Got out stream, data was already requested")
                                 ; sendDataFn (SOME os)
                                 ; DONE)
                            | AVAILABLE _ =>
                                 raise At (module, Fail "Got OutStream twice")
                            | DONE =>
                                 raise At (module, Fail "Got OutStream twice")
                            | CANCELLED =>
                                 CANCELLED
                           )
                        
                        (* request data function *)
                        fun requestData true =
                           state := (case (!state) of
                              INIT =>
                                 REQUESTED
                            | REQUESTED => (* tolerate any number of requests *)
                                 REQUESTED
                            | AVAILABLE os =>
                                 (log (DEBUG, module, fn () => "Data is requested, out stream already available")
                                 ; sendDataFn (SOME os)
                                 ; (!close) ()
                                 ; DONE)
                            | DONE => (* that's not valid *)
                                 (log (WARNING, module, fn () => "Invalid state, resetting")
                                 ; Conversation.reset conversation
                                 ; CANCELLED)
                            | CANCELLED => (* that's not valid *)
                                 (log (WARNING, module, fn () => "Invalid state, resetting")
                                 ; Conversation.reset conversation
                                 ; CANCELLED)
                           )
                         |  requestData false = (* --> cancel *)
                           state := (case (!state) of
                              INIT =>
                                 (log (DEBUG, module, fn () => "Response data rejected")
                                 ; sendDataFn NONE
                                 ; CANCELLED)
                            | REQUESTED => (* that's not valid *)
                                 (log (WARNING, module, fn () => "Invalid state, resetting")
                                 ; Conversation.reset conversation
                                 ; CANCELLED)
                            | AVAILABLE os =>
                                 (log (DEBUG, module, fn () => "Response data rejected")
                                 ; sendDataFn NONE
                                 ; CUSP.OutStream.shutdown (os, fn _ => ())
                                 ; (!close) ()
                                 ; CANCELLED)
                            | DONE => (* that's not valid *)
                                 (log (WARNING, module, fn () => "Invalid state, resetting")
                                 ; Conversation.reset conversation
                                 ; CANCELLED)
                            | CANCELLED => (* tolerate any number of requests *)
                                 CANCELLED
                           )
                        (* register requestData function *)
                        val (requestDocResp, unhookResp) = 
                           Conversation.response (conversation, {
                              methodTy = requestDataTy,
                              method   = requestData
                           })
                        
                        (* set conversation timout (TODO app-defined?) *)
                        fun timeout () = 
                           let
                              val () = log (DEBUG, module, fn () => "Conversation timeout")
(*                              val () = log (DEBUG, module,
                                 fn () => "  in: " ^ Int.toString (Conversation.activeInStreams conversation)
                                          ^ " out: " ^ Int.toString (Conversation.activeOutStreams conversation))*)
                              val () = case (!state) of (* app-level abort, if necessary *)
                                 INIT => sendDataFn NONE
                               | REQUESTED => sendDataFn NONE
                               | AVAILABLE os => (sendDataFn NONE; CUSP.OutStream.reset os)
                               | DONE => ()
                               | CANCELLED => ()
                           in
                              Conversation.reset conversation
                           end
                        val () =
                           Conversation.setTimeout
                              (conversation, SOME {
                                 limit = Config.notificationResponseTimeout,
                                 dead = timeout
                              })
                        (* TODO set conversation limits? (app-defined!?) *)
                        
                        (* set close function, unhooking and closing conversation *)
                        val () = close := (fn () =>
                           ( unhookResp ()
                           ; Conversation.close (conversation,
                                 { complete = fn () =>
                                    ( Conversation.setTimeout (conversation, NONE)
                                    ; log (DEBUG, module, fn () => "Conversation closed") )
                                 }) ))
                     in
                        (* send response *)
                        queryResponse id requestDocResp gotOutstream
                     end
                  (* (association failed) *)
                   |  onConnect (ON_REQUEST sendDataFn) NONE =
                     let
                        val () =
                           log (DEBUG, module,
                              fn () => "Connect to " ^ Address.toString address ^ " failed")
                     in
                        sendDataFn NONE (* callback failed *)
                     end
                  
                  (* ... or send data immediately *)
                   |  onConnect (IMMEDIATE data) (SOME (conversation, queryResponse)) =
                     let
                        val () =
                           log (DEBUG, module,
                              fn () => "Connected to " ^ Address.toString address
                                 ^ " for sending notification")
                        
                        val close = ref (fn () => ())
                        
                        fun gotOutstream os =
                           let
                              fun done OutStream.READY =
                                 OutStream.shutdown (os, fn _ => ())
                               |  done OutStream.RESET =
                                 ()
                              val () = OutStream.write (os, data, done)
                           in
                              (!close) ()
                           end
                        
                        (* request data function -- ignored *)
                        fun requestData _ = ()
                        val (requestDocResp, unhookResp) = 
                           Conversation.response (conversation, {
                              methodTy = requestDataTy,
                              method   = requestData
                           })
                        
                        (* set conversation timout (TODO app-defined?) *)
                        fun timeout () = 
                           let
                              val () = log (DEBUG, module, fn () => "Conversation timeout")
                           in
                              Conversation.reset conversation
                           end
                        val () =
                           Conversation.setTimeout
                              (conversation, SOME {
                                 limit = Config.notificationResponseTimeout,
                                 dead = timeout
                              })
                        (* TODO set conversation limits? (app-defined!?) *)
                        
                        (* set close function, unhooking and closing conversation *)
                        val () = close := (fn () =>
                           ( unhookResp ()
                           ; Conversation.close (conversation,
                                 { complete = fn () =>
                                    ( Conversation.setTimeout (conversation, NONE)
                                    ; log (DEBUG, module, fn () => "Conversation closed") )
                                 }) ))
                     in
                        (* send response *)
                        queryResponse id requestDocResp gotOutstream
                     end
                  (* (association failed) *)
                   |  onConnect (IMMEDIATE _) NONE =
                     log (DEBUG, module,
                        fn () => "Connect to " ^ Address.toString address ^ " failed")
                  
               in
                  (* associate *)
                  ignore (Conversation.associate (endpoint, address, {
                     entry    = entry,
                     entryTy  = notificationTy,
                     complete = onConnect mode
                  }))
               end (* of fun sender *)
         in
            sender
         end

      fun decode (data, endpoint) =
         let
            val (callback, length) = parseNotification data
         in
            (* return send function and number of bytes consumed from input data *)
            (receiveCallback (callback, endpoint), length)
         end
   end
