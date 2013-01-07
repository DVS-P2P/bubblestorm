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

(*
 * The Notification API can be used for 
 *)
signature NOTIFICATION =
   sig
      type t
      
      (* The application-defined identifier that is immediately sent
       * to choose whether to download the payload or not. *)
      structure Identifier : SERIALIZABLE
      
      (* The result object received on a notification.
       * The application may request the result's payload using the payload function
       * based on the identifier (id function).
       * If the payload is not required, cancel MUST be called. *)
      structure Result :
         sig
            type t
            val id : t -> Identifier.t
            val payload : t -> CUSP.InStream.t
            val cancel : t -> unit
         end
      
      (* Creates a new notification object.
       * The resultReceiver will be called for each incoming notification. *)
      val new : 
         {
            endpoint : CUSP.EndPoint.t,
            resultReceiver : Result.t -> unit
         } -> t
      
      (* Closes the notification object, i.e., no more results will be received. *)
      val close : t -> unit
      
      (* Returns the (maximum) size of encoded notification data. *)
      val maxEncodedLength : int
      
      (* Encodes the notification callback data into a byte vector.
       * The second parameter specifies the (current) local address. *)
      val encode : t * CUSP.Address.t -> Word8Vector.vector
      
      (* The send function sendFn takes the object's ID, which is directly transmitted
       * to the receiver, and the sendData. sendData can be
       * - either ON_REQUEST with a function that is called when the receiver requests
       *   the result payload. That function will always be called, either with an
       *   OutStream, if the payload is requested,
       *   or with NONE to notify the responder that the potential response resources can
       *   be deallocated.
       * - Alternatively, sendData can be IMMEDIATE and the data to be sent immediately. *)
      datatype sendData =
         ON_REQUEST of (CUSP.OutStream.t option -> unit)
       | IMMEDIATE of Word8Vector.vector
      type sendFn = Identifier.t * sendData -> unit
      
      (* Decodes a previously encoded notification callback.
       * Returns the notification sender function and the number of bytes read from the data slice. *)
      val decode : (Word8VectorSlice.slice * CUSP.EndPoint.t) -> (sendFn * int)
      
      type callback
      val callback : (callback, callback, unit) Serial.t
      val provideCallback : t * CUSP.Address.t -> callback
      val receiveCallback : callback * CUSP.EndPoint.t -> sendFn
   end
