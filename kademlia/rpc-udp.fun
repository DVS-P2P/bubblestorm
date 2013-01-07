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

functor RpcUdp(
      structure Event : EVENT
      structure UDP : NATIVE_UDP
   ) : RPC
   where type Address.t = UDP.Address.t
   =
   struct
      structure Address = UDP.Address
      
      type requestCallback = Word8ArraySlice.slice * Address.t ->
         (Word8ArraySlice.slice -> int) option
      type responseCallback = Word8ArraySlice.slice option -> unit
      
      (* Service map *)
      structure ServiceKey =
         struct
            type t = Word16.word
            val op == = op =
            val hash = Hash.word16
         end
      structure ServiceMap = HashTable(ServiceKey)
      
      (* Request map *)
      structure RequestId =
         struct
            type t = Word8Vector.vector
            val numberOfBytes = 20
            val t = Serial.vector (Serial.word8, numberOfBytes)
            val hash = Hash.word8vector
            val compare = Word8Vector.collate Word8.compare
            fun op == (x, y) = compare (x, y) = EQUAL
            fun random () = Entropy.get numberOfBytes
         end
      structure RequestMap = HashTable(RequestId)
      
      datatype fields = T of {
         udp : UDP.t,
         recvBuf : Word8ArraySlice.slice,
         sendBuf : Word8ArraySlice.slice,
         serviceMap : requestCallback ServiceMap.t,
         requestMap : (responseCallback * Word16.word) RequestMap.t
      }
      withtype t = fields ref
      
      open FunctionalRecordUpdate
      fun get f (ref (T fields)) = f fields
      
      (* message header definition *)
      datatype header =
         REQUEST of (Word16.word * RequestId.t)
       | RESPONSE of (Word16.word * RequestId.t)
       | INVALID
      local
         open Serial
         val h = aggregate tuple3 `word16b `word16b `RequestId.t $
         val { parseSlice, writeSlice, length, ... } = methods h
      in
         val headerSize = length
         
         fun parseHeader buffer =
            let
               val (msgType, svcId, reqId) = parseSlice buffer
            in
               case msgType of
                  0wx0101 => REQUEST (svcId, reqId)
                | 0wx0103 => RESPONSE (svcId, reqId)
                | _ => INVALID
            end
         
         fun writeHeader (head, buffer) =
            case head of
               REQUEST (svcId, reqId) => writeSlice (buffer, (0wx0101, svcId, reqId))
               | RESPONSE (svcId, reqId) => writeSlice (buffer, (0wx0103, svcId, reqId))
               | INVALID => raise Fail "Cannot write invalid header to packet"
      end
      
      (* message receive handler *)
      fun receiveHandler this () =
         case UDP.recv (get#udp this, get#recvBuf this) of
            SOME (sender, data) =>
               let
                  (* get request Id *)
                  val header = parseHeader data
                  val payload = Word8ArraySlice.subslice (data, headerSize, NONE)
                  
                  (* send response from app *)
                  fun handleRequest (svcId, reqId) =
                     case ServiceMap.get (get#serviceMap this, svcId) of
                        SOME cb => (
                           case cb (payload, sender) of
                              SOME writeCb =>
                                 let
                                    val buffer = get#sendBuf this
                                    val () = writeHeader (RESPONSE (svcId, reqId), buffer)
                                    val bodyLen = writeCb (Word8ArraySlice.subslice (buffer, headerSize, NONE))
                                    val data = Word8ArraySlice.subslice (buffer, 0, SOME (headerSize+bodyLen))
                                 in
                                    ignore (UDP.send (get#udp this, sender, data))
                                 end
                              | NONE => () (* no reponse to send *)
                           )
                        | NONE => () (* ignore invalid request *)
                  
                  (* response handler *)
                  fun handleResponse (reqId, svcId) =
                     let
                        val requestMap = get#requestMap this
                     in
                        case RequestMap.get (requestMap, reqId) of
                           SOME (cb, service) =>
                              (ignore (RequestMap.remove (requestMap, reqId))
                              ; if (svcId = service)
                                 then cb (SOME payload)
                                 else () (* invalid service ID in response -> ignore *)
                              )
                           | NONE => () (* request timed out or aborted *)
                     end
               in
                  (* read header: request or reponse? *)
                  case header of
                     REQUEST (svcId, reqId) => handleRequest (svcId, reqId)
                     | RESPONSE (svcId, reqId) => handleResponse (reqId, svcId)
                     | INVALID => () (* ignore *)
               end
          | NONE => () (* probably ICMP... *)
      
      fun new port =
         let
            val proxyVal = ref NONE
            fun proxy f x = f (valOf (!proxyVal)) x
            val this = ref (T {
               udp = UDP.new (port, proxy receiveHandler),
               recvBuf = Word8ArraySlice.full (Word8Array.tabulate (UDP.maxMTU, fn _ => 0w0)),
               sendBuf = Word8ArraySlice.full (Word8Array.tabulate (UDP.maxMTU, fn _ => 0w0)),
               serviceMap = ServiceMap.new (),
               requestMap = RequestMap.new ()
            })
            val () = proxyVal := SOME this
         in
            this
         end
      
      fun destroy this =
         UDP.close (get#udp this)
      
      fun registerService (this, svcId, requestCb) =
         ServiceMap.add (get#serviceMap this, svcId, requestCb)
      
      fun unregisterService (this, svcId) =
         ignore (ServiceMap.remove (get#serviceMap this, svcId))
      
      fun request (this, {address, service, writer, response, timeout}) =
         let
            val requestMap = get#requestMap this
            (* create request id *)
            val reqId = RequestId.random ()
            (* remove request from map function *)
            fun removeRequest () = ignore (RequestMap.remove (requestMap, reqId))
            (* set timeout *)
            val removeTimeout =
               case timeout of
                  NONE => (fn () => ())
                  | SOME timeout =>
                     let
                        fun onTimeout _ = (removeRequest (); response NONE)
                        val timeoutEvent = Event.new onTimeout
                        val () = Event.scheduleIn (timeoutEvent, Time.fromMilliseconds timeout)
                     in
                        fn () => Event.cancel timeoutEvent
                     end
            (* abort funtion *)
            fun abort () = (removeRequest (); removeTimeout ())
            (* response callback wrapper *)
            fun onResponse data = (removeTimeout (); response data)
            (* put to request map *)
            val () = RequestMap.add (requestMap, reqId, (onResponse, service))
            (* send message *)
            val buffer = get#sendBuf this
            (* Insert header (request id) *)
            val () = writeHeader (REQUEST (service, reqId), buffer)
            (* Insert body *)
            val bodyLen = writer (Word8ArraySlice.subslice (buffer, headerSize, NONE))
            val data = Word8ArraySlice.subslice (buffer, 0, SOME (headerSize+bodyLen))
            (* send *)
            val _ = UDP.send (get#udp this, address, data)
         in
            (* return abort funtion *)
            abort
         end
      
   end
