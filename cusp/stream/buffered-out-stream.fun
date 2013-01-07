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

functor BufferedOutStream (OutStream : OUT_STREAM) : BUFFERED_OUT_STREAM =
   struct
      structure OutStream = OutStream
      
      datatype internalState =
         BUF_ACTIVE | BUF_RESET | BUF_SHUTDOWN | BUF_CLOSING of (bool -> unit)
         
      datatype status = datatype OutStream.status

      datatype t = T of {
         stream : OutStream.t,
         buffer : (Word8Vector.vector * (status -> unit)) Ring.t,
         ready  : bool ref,
         state  : internalState ref
      }

      fun outStream (T { stream, ... }) = stream
      
      (* map most functions directly to outstream *)
      type priority = OutStream.priority
      val getPriority = OutStream.getPriority o outStream
      val setPriority = OutStream.setPriority o (fn (this, prio) => (outStream this, prio))
      val queuedToRetransmit = OutStream.queuedToRetransmit o outStream
      val bytesSent = OutStream.bytesSent o outStream
      datatype state = datatype OutStream.state
      val globalID = OutStream.globalID o outStream
      val localName = OutStream.localName o outStream
      type description = OutStream.description
      val setDescription =
         OutStream.setDescription o (fn (this, desc) => (outStream this, desc))

      fun queuedInflight (T { stream, buffer, ... }) =
         let
            fun count ((data, _), sum) = sum + Word8Vector.length data
            val queue = Iterator.map Ring.unwrap (Ring.iterator buffer)
         in
            OutStream.queuedInflight stream + (Iterator.fold count 0 queue)
         end

      fun state (T { state = ref status, ... }) =
         case status of
            BUF_ACTIVE => IS_ACTIVE
          | BUF_RESET => IS_RESET
          | BUF_SHUTDOWN => IS_SHUTDOWN
          | BUF_CLOSING _ => IS_SHUTDOWN
      
      (* clear the buffer on reset *)
      fun resetQueued (T { buffer, ready, ... }) =
         let
            fun resetBuffer (_, cb) = cb RESET
            val () = Iterator.app (resetBuffer o Ring.unwrap) (Ring.iterator buffer)
            val () = Ring.clear buffer
         in
            ready := true
         end
      
      fun reset (this as T { state, ... }) =
         let
            val () = resetQueued this
            val () = state := BUF_RESET
         in
            (OutStream.reset o outStream) this
         end

      fun execShutdown (T { state, stream, ... }, cb) =
         let
            val () = state := BUF_SHUTDOWN
         in
            OutStream.shutdown (stream, cb)
         end

      (* delay shutdown to flush buffer *)
      fun shutdown (this as T { state, ready, ... }, cb) =
         case !state of
            BUF_RESET => cb false
          | BUF_SHUTDOWN => raise RaceCondition
          | BUF_CLOSING _ => raise RaceCondition
          | BUF_ACTIVE => if !ready
               then execShutdown (this, cb)
               else state := BUF_CLOSING cb
      
      (* write to the outstream *)
      fun writer (this as T { stream, buffer, ready, state }) =
         case Ring.head buffer of
            SOME elem =>
               let
                  val (data, cb) = Ring.unwrap elem
                  val () = Ring.remove elem
                  val () = ready := false
                  fun continue cb RESET = ( resetQueued this ; cb RESET )
                    | continue cb READY = ( cb READY ; writer this )
               in
                  OutStream.write (stream, data, continue cb)
               end
          | NONE =>
               let
                  val () = case !state of
                     BUF_CLOSING cb => execShutdown (this, cb)
                   | _ => ()
               in
                  ready := true
               end
       
      (* put incoming data into the buffer *)
      fun write (this as T { buffer, ready, ... }, data, cb) =
         case state this of
            IS_RESET => cb RESET
          | IS_SHUTDOWN => raise RaceCondition
          | IS_ACTIVE =>
               let
                  val () = Ring.addTail (buffer, Ring.wrap (data, cb))
               in
                  if !ready then writer this else ()
               end
            
      fun new stream =
         T {
            stream = stream,
            buffer = Ring.new (),
            ready = ref true,
            state = ref BUF_ACTIVE
         }
   end
