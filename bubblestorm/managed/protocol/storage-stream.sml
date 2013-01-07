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

structure StorageStream :> STORAGE_STREAM =
   struct
      val module = "bubblestorm/bubble/managed/storage-stream"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)
      datatype request = datatype StorageRequest.t
      
      datatype action =
         REQUEST of request
       | POSITION of int
       | SHUTDOWN
       
      datatype t = T of {
         enqueue : action -> unit,
         die : bool -> unit
      }
      
      (* header info to identify request *)
      structure RequestType =
         struct
            datatype typ = INVALID | INS | UPD | DEL | POS
            
            fun store INVALID = 0
              | store INS     = 1
              | store UPD     = 2
              | store DEL     = 3
              | store POS     = 4

            fun load 1 = INS
              | load 2 = UPD
              | load 3 = DEL
              | load 4 = POS
              | load _ = INVALID
              
            open Serial
   
            val typ = map { store = store, load = load, extra = fn () => () } int32l

            (* (request type, length/pos) *)
            (*type t = typ * int*)

            val t = aggregate tuple2 `typ `int32l $
            val { toVector, parseSlice, length, ... } = methods t
         end
      
      (* wait an operation and reset the conversation,
         if it does not complete in time. returns a method to remove the 
         timer when the operation completes. *)
      fun setTimeout conversation =
         let
            val canceled = ref false
            fun kill _ = if !canceled then () else Conversation.reset conversation
            val event = Main.Event.new kill
            val () = Main.Event.scheduleIn (event, Config.RPCTimeout)
         in
            fn () => canceled := true
         end

      fun makeDie (conversation, whenDead) =
         let
            (* die only once *)
            val isDead = ref false
            (* what to do if the other side doesn't answer anymore *)
            fun die shutdown =
               if !isDead then () else
                  let
                     val () = isDead := true
                     (*val mode = if shutdown then "leaving" else "dead"
                     val () = log (fn () => "removing " ^ mode ^ " maintainer " ^
                                          CUSP.Address.toString address)*)
                     val () = if shutdown then () else
                        Conversation.reset conversation
                  in
                     whenDead shutdown
                  end
         in
            die
         end
               
      (* interface used by storage peers to receive from a maintainer *)
      fun newMaintainer { state, conversation, stream, position, onRequest, whenDead } =
         let
            val die = makeDie (conversation, whenDead)

            fun fail () =
               (case CUSP.InStream.state stream of
                  CUSP.InStream.IS_SHUTDOWN => die true
                | CUSP.InStream.IS_RESET => die false
                | CUSP.InStream.IS_ACTIVE => raise At (module,
                     Fail "readFully failed on an active stream"))

            (* use only one receive buffer per stream, which is increased when necessary. *)
            val defaultBufferSize = 2048
            fun createBuffer size = Word8Array.tabulate (size, fn _ => 0w0)
            val buffer = ref (createBuffer defaultBufferSize)
      
            (* do the decoding *)
            fun decodeInsert data = StorageRequest.decodeInsert (state, conversation, data)
            fun decodeUpdate data = StorageRequest.decodeUpdate (state, conversation, data)
            fun decodeDelete data = StorageRequest.decodeDelete (state, conversation, data)

            fun getBuffer length =
               let
                  val () = if length > Word8Array.length (!buffer)
                           then buffer := createBuffer length else ()
               in
                  Word8ArraySlice.slice (!buffer, 0, SOME length)
               end
 
            fun receiveRequest _ false = fail ()
              | receiveRequest (decode, buffer) true =
               let
                  val () = onRequest (decode buffer)
                     handle StorageRequest.InvalidBubbleType => die false
               in
                  readHeader ()
               end
         
            and readRequest (decode, buffer) =
               Conversation.Manual.recv (conversation, stream, {
                  buffer = buffer,
                  complete = receiveRequest (decode, buffer),
                  reliability = Conversation.Reliability.reliable
               })

            (* decode the header (= request type + tail length) *)
            and receiveHeader _ false = fail ()
              | receiveHeader buffer true =
               case RequestType.parseSlice buffer of
                  (RequestType.INS, len) =>
                     readRequest (decodeInsert, getBuffer len)
                | (RequestType.UPD, len) =>
                     readRequest (decodeUpdate, getBuffer len)
                | (RequestType.DEL, len) =>
                     readRequest (decodeDelete, getBuffer len)
                | (RequestType.POS, pos) =>
                     ( position := pos ; readHeader () )
                | (RequestType.INVALID, _) =>
                     die false
            
            (* receive a single request *)
            and readHeader' buffer =
               Conversation.Manual.recv (conversation, stream, {
                  buffer = buffer,
                  complete = receiveHeader buffer,
                  reliability = Conversation.Reliability.reliable
               })
            and readHeader () = readHeader' (getBuffer RequestType.length)
         in
            readHeader ()
         end
      
      (* interface for maintainers for sending to a storage peer *)
      fun newStorage { conversation, stream, whenDead } =
         let
            val die = makeDie (conversation, whenDead)
            val queue = Ring.new ()
            val idle = ref true

            fun setWatch complete =
               let
                  val cancel = setTimeout conversation
               in
                  fn () => ( cancel () ; complete () )
               end
               
            fun sendShutdown () =
                  Conversation.Manual.sendShutdown (conversation, stream, {
                     complete = fn _ => (),
                     reliability = Conversation.Reliability.reliable
                  })

            (* hook into the complete call to cancel timeouts *)
            fun watch (INSERT (bubble, id, data, done)) =
               INSERT (bubble, id, data, setWatch done)
              | watch (UPDATE (bubble, id, data, done)) =
               UPDATE (bubble, id, data, setWatch done)
              | watch (DELETE (bubble, id, done)) =
               DELETE (bubble, id, setWatch done)

            and sendRequest request =
               let
                  fun logRequest host = log (fn () => "sending request to " ^ 
                           host ^ ": " ^ StorageRequest.toString request)
                  val () = case CUSP.Host.remoteAddress (Conversation.host conversation) of
                     SOME address => logRequest (CUSP.Address.toString address)
                   | NONE => logRequest "unknown host"
                  
                  val data = StorageRequest.encode (conversation, watch request)
                  val typ = case request of
                        INSERT _ => RequestType.INS
                      | UPDATE _ => RequestType.UPD
                      | DELETE _ => RequestType.DEL
                  val header = RequestType.toVector (typ, Word8Vector.length data)
               in
                  Conversation.Manual.send (conversation, stream, {
                     buffer = Word8Vector.concat [ header, data ],
                     complete = write,
                     reliability = Conversation.Reliability.reliable
                  })
               end
            
            and sendPos pos =
               Conversation.Manual.send (conversation, stream, {
                  buffer = RequestType.toVector (RequestType.POS, pos),
                  complete = write,
                  reliability = Conversation.Reliability.reliable
               })
            
            (* read from the queue and write to stream *)
            and write false = die false
              | write true =
               case Ring.head queue of
                  NONE => idle := true
                | SOME action =>
                     let
                        val () = Ring.remove action
                     in
                        case Ring.unwrap action of
                           REQUEST request => sendRequest request
                         | POSITION pos => sendPos pos
                           (* TODO: can we modify the timeout of a shutdown? *)
                         | SHUTDOWN => sendShutdown () 
                     end

            (* enqueue a request. if we've been idle, send immediately *)
            fun enqueue action =
               let
                  val () = Ring.addTail (queue, Ring.wrap action)
               in
                  if !idle then
                     ( idle := false ; write true )
                  else ()
               end
         in
            T {
               enqueue = enqueue,
               die = die
            }
         end

      fun send (T { enqueue, ... }, request) = enqueue (REQUEST request)
      fun changePosition (T { enqueue, ... }, pos) = enqueue (POSITION pos)
      fun shutdown (T { enqueue, die }) = ( enqueue SHUTDOWN ; die true )
   end
