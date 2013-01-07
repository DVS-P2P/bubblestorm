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

functor NodeRPC (
      structure Id : ID
      structure RPC : RPC
(*       structure Value : VALUE *)
   ) : NODE_RPC
   =
   struct
      structure Id = Id
      structure Address = RPC.Address
      structure RPC = RPC
(*       structure Value = Value *)
      
      open Log
      
      type updateNodeHandler = Id.t * Address.t -> unit
      type nodeTimeoutHandler = Id.t option * Address.t -> unit
      
      type pingRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t
         }-> bool
      type findNodeRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t,
            targetId : Id.t
         } -> (Id.t * Address.t) Iterator.t
      type storeRequestHandler =
         {
            fromAddr   : Address.t,
            fromId     : Id.t,
            id         : Id.t,
            value      : Word8Vector.vector,
            expiryDate : Time.t
         } -> bool
      datatype findValueResult =
         VALUE of (Id.t * Word8Vector.vector * Time.t)
       | NODES of ((Id.t * Address.t) Iterator.t)
      type findValueRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t,
            targetId : Id.t
         } -> findValueResult
      
      type pingCallback = Id.t option -> unit
      type findNodeCallback = (Id.t * (Id.t * Address.t) Iterator.t) option -> unit
      type storeCallback = Id.t option -> unit
      type findValueCallback = (Id.t * findValueResult) option -> unit
      
      datatype fields = T of {
         rpc : RPC.t,
         myId : Id.t,
         updateNode : updateNodeHandler,
         nodeTimeout : nodeTimeoutHandler,
         pingRequestHandler : pingRequestHandler,
         findNodeRequestHandler : findNodeRequestHandler,
         storeRequestHandler : storeRequestHandler,
         findValueRequestHandler : findValueRequestHandler
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      val messageTimeout = 3000
      
      (* message type (service) IDs *)
      val svcPing =      0wx01
      val svcFindNode =  0wx10
      val svcFindValue = 0wx20
      val svcStore =     0wx22
      
      val findValueResultList  = 0w0
      val findValueResultValue = 0w1
      
      (* serialization: Id *)
      local
         open Serial
         val { writeSlice, parseSlice, length, ... } = methods Id.t
      in
         fun writeId (id, slice) = (writeSlice (slice, id); length)
         fun parseId slice = (parseSlice slice, length)
      end
      
      (* serialization: Id * Address *)
      local
         open Serial
         val data = aggregate tuple2 `Id.t `Address.t $
         val { writeSlice, parseSlice, length, ... } = methods data
      in
         fun writeIdAddr (idAddr, slice) = (writeSlice (slice, idAddr); length)
         fun parseIdAddr slice = (parseSlice slice, length)
      end
      
      (* serialization: Id + time (Int64) *)
      local
         open Serial
         val data = aggregate tuple2 `Id.t `Serial.int64l $
         val { writeSlice, parseSlice, length, ... } = methods data
      in
         fun writeIdDate (value, slice) = (writeSlice (slice, value); length)
         fun parseIdDate slice = (parseSlice slice, length)
      end
      
      (* serialization: Word32 *)
      local
         open Serial
         val { writeSlice, parseSlice, length, ... } = methods Serial.word32l
      in
         fun writeWord32 (value, slice) = (writeSlice (slice, value); length)
         fun parseWord32 slice = (parseSlice slice, length)
      end
      
      (* request handler for PING messages *)
      fun requestHandlerPing this (data, fromAddr) =
         let
            (* parse message *)
            val (fromId, _) = parseId data
            val () = log (DEBUG, "kademlia/nodeRPC/ping",
               fn () => ("Request: PING from " ^ Id.toString fromId
                  ^ " (" ^ Address.toString fromAddr ^ ")"))
            (* update node *)
            val updateNode = (get#updateNode this)
            val () = updateNode (fromId, fromAddr)
            (* handle request *)
            val pingRequestHandler = get#pingRequestHandler this
            val respond = pingRequestHandler {fromAddr=fromAddr, fromId=fromId}
            (* response writer *)
            fun responseWriter buf = writeId (get#myId this, buf)
         in
            if respond
            then SOME responseWriter
            else NONE
         end
      
      (* request handler for FIND_NODE messages *)
      fun requestHandlerFindNode this (data, fromAddr) =
         let
            (* parse message *)
            val (fromId, l) = parseId data
            val (targetId, _) = parseId (Word8ArraySlice.subslice (data, l, NONE))
            val () = log (DEBUG, "kademlia/nodeRPC/findNode",
               fn () => ("Request: FIND_NODE from " ^ Id.toString fromId
                  ^ " (" ^ Address.toString fromAddr ^ ")"
                  ^ " for " ^ Id.toString targetId))
            (* update node *)
            val updateNode = (get#updateNode this)
            val () = updateNode (fromId, fromAddr)
            (* handle request *)
            val findNodeRequestHandler = get#findNodeRequestHandler this
            val result = findNodeRequestHandler
               {fromAddr=fromAddr, fromId=fromId, targetId=targetId}
            (* response writer *)
            fun responseWriter buffer =
               let
                  (* write my ID *)
                  val l = writeId (get#myId this, buffer)
                  val buffer = Word8ArraySlice.subslice (buffer, l, NONE)
                  (* write ID-address list *)
                  fun writeEntry (it, slice) =
                     case Iterator.getItem it of
                        SOME (e, nextIt) =>
                           let
                              val l = writeIdAddr (e, slice)
                              val nextSlice = Word8ArraySlice.subslice (slice, l, NONE)
                           in
                              l + writeEntry (nextIt, nextSlice)
                           end 
                        | NONE => 0
                  val l2 = writeEntry (result, buffer)
               in
                  l + l2
               end
         in
            SOME responseWriter
         end
      
      (* request handler for STORE messages *)
      fun requestHandlerStore this (data, fromAddr) =
         let
            (* parse message *)
            val (fromId, l) = parseId data
            val l = l + 4 (* skip padding *)
            val data = Word8ArraySlice.subslice (data, l, NONE)
            val ((id, expiryDate), l) = parseIdDate data
            val value = (Word8ArraySlice.vector o Word8ArraySlice.subslice) (data, l, NONE)
            val expiryDate = Time.fromNanoseconds64 expiryDate
            val () = log (DEBUG, "kademlia/nodeRPC/store",
               fn () => ("Request: STORE from " ^ Id.toString fromId
                  ^ " (" ^ Address.toString fromAddr ^ ")"
                  ^ " with value ID " ^ Id.toString id))
            (* update node *)
            val updateNode = (get#updateNode this)
            val () = updateNode (fromId, fromAddr)
            (* handle request *)
            val storeRequestHandler = get#storeRequestHandler this
            val result = storeRequestHandler
               { fromAddr = fromAddr, fromId = fromId, id = id, value = value, expiryDate = expiryDate }
            (* response writer *)
            fun responseWriter buffer =
               let
                  (* write my ID *)
                  val l = writeId (get#myId this, buffer)
                  val buffer = Word8ArraySlice.subslice (buffer, l, NONE)
                  (* write success code *)
                  val resultWord =
                     if result then 0w1
                     else 0w0
                  val l2 = writeWord32 (resultWord, buffer)
               in
                  l + l2
               end
         in
            SOME responseWriter
         end
      
      (* request handler for FIND_VALUE messages *)
      fun requestHandlerFindValue this (data, fromAddr) =
         let
            (* parse message *)
            val (fromId, l) = parseId data
            val (targetId, _) = parseId (Word8ArraySlice.subslice (data, l, NONE))
            val () = log (DEBUG, "kademlia/nodeRPC/findNode",
               fn () => ("Request: FIND_NODE from " ^ Id.toString fromId
                  ^ " (" ^ Address.toString fromAddr ^ ")"
                  ^ " for " ^ Id.toString targetId))
            (* update node *)
            val updateNode = (get#updateNode this)
            val () = updateNode (fromId, fromAddr)
            (* handle request *)
            val findValueRequestHandler = get#findValueRequestHandler this
            val result = findValueRequestHandler
               { fromAddr = fromAddr, fromId = fromId, targetId = targetId }
            (* response writers *)
            fun baseResponseWriter (tp, buffer) =
               let
                  (* write my ID *)
                  val l = writeId (get#myId this, buffer)
                  (* write type *)
                  val l2 = writeWord32 (tp, Word8ArraySlice.subslice (buffer, l, NONE))
                  (* write padding (for 64-bit alignment...) *)
(*                   val l3 = writeWord32 (0w0, Word8ArraySlice.subslice (buffer, l + l2, NONE)) *)
               in
                  l + l2 (*+ l3*)
               end
            fun nodeListResponseWriter nodeList buffer =
               let
                  val l = baseResponseWriter (findValueResultList, buffer)
                  val buffer = Word8ArraySlice.subslice (buffer, l, NONE)
                  (* write ID-address list *)
                  fun writeEntry (it, slice) =
                     case Iterator.getItem it of
                        SOME (e, nextIt) =>
                           let
                              val l = writeIdAddr (e, slice)
                              val nextSlice = Word8ArraySlice.subslice (slice, l, NONE)
                           in
                              l + writeEntry (nextIt, nextSlice)
                           end 
                        | NONE => 0
                  val l2 = writeEntry (nodeList, buffer)
               in
                  l + l2
               end
            fun valueResponseWriter (id, value, expiryDate) buffer =
               let
                  val l = baseResponseWriter (findValueResultValue, buffer)
                  (* write value *)
                  val l = l + writeIdDate ((id, expiryDate), Word8ArraySlice.subslice (buffer, l, NONE))
                  val remaining = Word8ArraySlice.length buffer - l
                  val valLen = Int.min (remaining, Word8Vector.length value)
                  val valSlice = Word8VectorSlice.slice (value, 0, SOME valLen)
                  val (bufBase, bufBaseI, _) = Word8ArraySlice.base buffer
                  val () = Word8ArraySlice.copyVec { src = valSlice, dst = bufBase, di = bufBaseI + l }
               in
                  l + valLen
               end
         in
            case result of
               NODES n => SOME (nodeListResponseWriter n)
             | VALUE (id, v, t) => SOME (valueResponseWriter (id, v, Time.toNanoseconds64 t))
         end
      
      (* new *)
      fun new {
            port,
            myId,
            updateNode,
            nodeTimeout,
            pingRequestHandler,
            findNodeRequestHandler,
            storeRequestHandler,
            findValueRequestHandler
         } =
         let
            val rpc = RPC.new port
            val this = T {
               rpc = rpc,
               myId = myId,
               updateNode = updateNode,
               nodeTimeout = nodeTimeout,
               pingRequestHandler = pingRequestHandler,
               findNodeRequestHandler = findNodeRequestHandler,
               storeRequestHandler = storeRequestHandler,
               findValueRequestHandler = findValueRequestHandler
            }
            (* register services *)
            val () = RPC.registerService (rpc, svcPing, requestHandlerPing this)
            val () = RPC.registerService (rpc, svcFindNode, requestHandlerFindNode this)
            val () = RPC.registerService (rpc, svcStore, requestHandlerStore this)
            val () = RPC.registerService (rpc, svcFindValue, requestHandlerFindValue this)
         in
            this
         end
      
      fun destroy this =
         RPC.destroy (get#rpc this)
      
      (* PING *)
      fun ping (this, {destAddr, destId, callback}) =
         let
            val () = log (DEBUG, "kademlia/nodeRPC/ping",
               fn () => ("PING to " ^ Address.toString destAddr))
               
               fun writer buf = writeId (get#myId this, buf)
               
               fun validResponse fromId =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/ping",
                     fn () => ("PING response from " ^ Id.toString fromId
                     ^ " (" ^ Address.toString destAddr ^ ")")) 
                  (* update node *)
                  val updateNode = get#updateNode this
                  val () = updateNode (fromId, destAddr)
               in
                  (* callback *)
                  callback (SOME fromId)
               end
            
            fun timeout () =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/ping",
                     fn () => ("PING timeout (" ^ Address.toString destAddr ^ ")")) 
                  (* invoke node timeout handler *)
                  val nodeTimeout = get#nodeTimeout this
                  val () = nodeTimeout (destId, destAddr)
               in
                  (* callback *)
                  callback NONE
               end
            
            fun response data =
               let
                  (* read ID *)
                  val (fromId, _) = parseId data
               in
                  (* check for valid node ID *)
                  case destId of
                     SOME id => if Id.== (fromId, id)
                        then validResponse fromId
                        else timeout ()
                     | NONE => validResponse fromId
               end
            
            val onResponse = fn
               SOME data => response data
               | NONE => timeout ()
            
            val rpc = get#rpc this
         in
            RPC.request (rpc, {
               address = destAddr,
               service = svcPing,
               writer = writer,
               response = onResponse,
               timeout = SOME messageTimeout
            })
         end
      
      (* FIND_NODE *)
      fun findNode (this, {destAddr, destId, targetId, callback}) =
         let
            val () = log (DEBUG, "kademlia/nodeRPC/findNode",
               fn () => ("FIND_NODE to " ^ Address.toString destAddr))
            
            fun writer buf =
               let
                  val l = writeId (get#myId this, buf)
               in
                  l + writeId (targetId, Word8ArraySlice.subslice (buf, l, NONE))
               end
            
            fun validResponse (fromId, data) =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/findNode",
                     fn () => ("FIND_NODE response from " ^ Id.toString fromId
                     ^ " (" ^ Address.toString destAddr ^ ")")) 
                  (* read id-addr-list *)
                  fun readList data =
                     if Word8ArraySlice.length data > 0 then
                        let
                           val (hd, l) = parseIdAddr data
                           val nextData = Word8ArraySlice.subslice (data, l, NONE)
                           val tl = readList nextData
                        in
                           hd::tl
                        end
                     else
                        []
                  val idList = readList data
                  (* update node *)
                  val updateNode = get#updateNode this
                  val () = updateNode (fromId, destAddr)
               in
                  callback (SOME (fromId, Iterator.fromList idList))
               end
            
            fun timeout () =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/findNode",
                     fn () => ("FIND_NODE timeout (" ^ Address.toString destAddr ^ ")")) 
                  (* invoke node timeout handler *)
                  val nodeTimeout = get#nodeTimeout this
                  val () = nodeTimeout (destId, destAddr)
               in
                  (* callback *)
                  callback NONE
               end
            
            fun response data =
               let
                  (* read ID *)
                  val (fromId, l) = parseId data
                  val tailData = Word8ArraySlice.subslice (data, l, NONE)
               in
                  (* check for valid node ID *)
                  case destId of
                     SOME id => if Id.== (fromId, id)
                        then validResponse (fromId, tailData)
                        else timeout ()
                     | NONE => validResponse (fromId, tailData)
               end
            
            val onResponse = fn
               SOME data => response data
               | NONE => timeout ()
            
            val rpc = get#rpc this
         in
            RPC.request (rpc, {
               address = destAddr,
               service = svcFindNode,
               writer = writer,
               response = onResponse,
               timeout = SOME messageTimeout
            })
         end
      
      (* STORE *)
      fun store (this, {destAddr, destId, id, value, expiryDate, callback}) =
         let
            val () = log (DEBUG, "kademlia/nodeRPC/store",
               fn () => ("STORE to " ^ Address.toString destAddr))
            
            fun writer buffer =
               let
                  (* write sender ID *)
                  val l = writeId (get#myId this, buffer)
                  (* write padding (for 64-bit alignment...) *)
                  val l = l + writeWord32 (0w0, Word8ArraySlice.subslice (buffer, l, NONE))
                  (* write value ID and time *)
                  val l = l + writeIdDate ((id, Time.toNanoseconds64 expiryDate), Word8ArraySlice.subslice (buffer, l, NONE))
                  (* write value *)
                  val remaining = Word8ArraySlice.length buffer - l
                  val valLen = Int.min (remaining, Word8Vector.length value)
                  val valSlice = Word8VectorSlice.slice (value, 0, SOME valLen)
                  val (bufBase, bufBaseI, _) = Word8ArraySlice.base buffer
                  val () = Word8ArraySlice.copyVec { src = valSlice, dst = bufBase, di = bufBaseI + l }
               in
                  l + valLen
               end
            
            fun validResponse (fromId, data) =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/store",
                     fn () => ("STORE response from " ^ Id.toString fromId
                     ^ " (" ^ Address.toString destAddr ^ ")")) 
                  (* read result *)
                  val (res, _) = parseWord32 data
                  (* update node *)
                  val updateNode = get#updateNode this
                  val () = updateNode (fromId, destAddr)
               in
                  if (res <> 0w0)
                  then callback (SOME fromId)
                  else callback NONE
               end
            
            fun timeout () =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/findNode",
                     fn () => ("FIND_NODE timeout (" ^ Address.toString destAddr ^ ")")) 
                  (* invoke node timeout handler *)
                  val nodeTimeout = get#nodeTimeout this
                  val () = nodeTimeout (destId, destAddr)
               in
                  (* callback *)
                  callback NONE
               end
            
            fun response data =
               let
                  (* read ID *)
                  val (fromId, l) = parseId data
                  val tailData = Word8ArraySlice.subslice (data, l, NONE)
               in
                  (* check for valid node ID *)
                  case destId of
                     SOME id => if Id.== (fromId, id)
                        then validResponse (fromId, tailData)
                        else timeout ()
                     | NONE => validResponse (fromId, tailData)
               end
            
            val onResponse = fn
               SOME data => response data
               | NONE => timeout ()
            
            val rpc = get#rpc this
         in
            RPC.request (rpc, {
               address = destAddr,
               service = svcStore,
               writer = writer,
               response = onResponse,
               timeout = SOME messageTimeout
            })
         end

      (* FIND_VALUE *)
      fun findValue (this, {destAddr, destId, targetId, callback}) =
         let
            val () = log (DEBUG, "kademlia/nodeRPC/findValue",
               fn () => ("FIND_VALUE to " ^ Address.toString destAddr))
            
            fun writer buf =
               let
                  val l = writeId (get#myId this, buf)
               in
                  l + writeId (targetId, Word8ArraySlice.subslice (buf, l, NONE))
               end
            
            fun validResponse (fromId, data) =
               let
                  (* read id-addr-list *)
                  fun readList data =
                     if Word8ArraySlice.length data > 0 then
                        let
                           val (hd, l) = parseIdAddr data
                           val nextData = Word8ArraySlice.subslice (data, l, NONE)
                           val tl = readList nextData
                        in
                           hd::tl
                        end
                     else
                        []
                  (* read type (node list or value) *)
                  val (tp, l) = parseWord32 data
                  val data  = Word8ArraySlice.subslice (data, l, NONE)
                  (* read padding (for 64-bit alignment) *)
(*                  val (_, l) = parseWord32 data
                  val data  = Word8ArraySlice.subslice (data, l, NONE)*)
                  (* log *)
                  val () = log (DEBUG, "kademlia/nodeRPC/findValue",
                     fn () => ("FIND_VALUE response (" ^ Word32.toString tp 
                        ^ ") from " ^ Id.toString fromId
                        ^ " (" ^ Address.toString destAddr ^ ")")) 
                  (* update node *)
                  val updateNode = get#updateNode this
                  val () = updateNode (fromId, destAddr)
                  (* value publish date conversion *)
                  fun parseVal data =
                     let
                        val ((id, expiryDate), l) = parseIdDate data
                        val value = Word8ArraySlice.vector (Word8ArraySlice.subslice (data, l, NONE))
                     in
                        (id, value, Time.fromNanoseconds64 expiryDate)
                     end
               in
                  if tp = findValueResultList
                  then callback (SOME (fromId, NODES (Iterator.fromList (readList data))))
                  else
                     if tp = findValueResultValue
                     then callback (SOME (fromId, VALUE (parseVal data)))
                     else raise Fail "Invalid FIND_VALUE response."
               end
            
            fun timeout () =
               let
                  val () = log (DEBUG, "kademlia/nodeRPC/findValue",
                     fn () => ("FIND_VALUE timeout (" ^ Address.toString destAddr ^ ")")) 
                  (* invoke node timeout handler *)
                  val nodeTimeout = get#nodeTimeout this
                  val () = nodeTimeout (destId, destAddr)
               in
                  (* callback *)
                  callback NONE
               end
            
            fun response data =
               let
                  (* read ID *)
                  val (fromId, l) = parseId data
                  val tailData = Word8ArraySlice.subslice (data, l, NONE)
               in
                  (* check for valid node ID *)
                  case destId of
                     SOME id => if Id.== (fromId, id)
                        then validResponse (fromId, tailData)
                        else timeout ()
                     | NONE => validResponse (fromId, tailData)
               end
            
            val onResponse = fn
               SOME data => response data
               | NONE => timeout ()
            
            val rpc = get#rpc this
         in
            RPC.request (rpc, {
               address = destAddr,
               service = svcFindValue,
               writer = writer,
               response = onResponse,
               timeout = SOME messageTimeout
            })
         end
      
   end
