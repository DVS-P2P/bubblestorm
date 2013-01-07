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

signature OUT_STREAM =
   sig
      type t
      type priority = Real32.real
      
      (* Control the priority of this stream.
       * Higher priority streams transmit before low priority streams.
       * Raises an exception if the priority is not a finite value.
       *
       * The default priority is 0.
       * Negative priority values will not cause the stream to transmit unless
       * there is otherwise unused space in packet being sent to the peer.
       *)
      val getPriority: t -> priority
      val setPriority: t * priority -> unit
      
      (* Query how much data is buffered. *)
      val queuedInflight     : t -> int (* Inflight awaiting acknowledgment *)
      val queuedToRetransmit : t -> int (* Lost and waiting to be retransmit *)
      val bytesSent          : t -> LargeInt.int

      (* Check if the stream is shutdown/reset *)
      datatype state = IS_ACTIVE | IS_SHUTDOWN | IS_RESET
      val state : t -> state
      
      (* Indicate that the stream will transmit no further data to the peer.
       * If there is an incomplete write, RaceCondition will be raised.
       * If a stream is shutdown twice, RaceCondition will be raised.
       * Any subsequent attempt to queue data for transmission will fail.
       * Once all queued data is finally delivered, the callback is invoked
       * with true and the stream is garbage collected.
       * 
       * If the local out-stream is already reset or reset before final
       * delivery, the callback will be invoked with false. If the remote
       * read stream is reset, the callback is invoked with either true/false.
       *
       * Final delivery of data to the remote in-stream does not guarantee
       * delivery of data to the application. The in-stream might be reset
       * before all the remotely buffered data is delivered.
       *)
      val shutdown: t * (bool -> unit) -> unit
      
      (* Forcibly destroy this stream.
       * Prevents further transmission of data.
       * Immediately frees queueToRetransmit; queuedInFlight drains slowly.
       *  Does not retransmit lost segments.
       *  Cancels with RESET any pending local writes.
       * Attempts to signal RESET to the remote in-stream.
       *  If used before shutdown, remote in-stream is guaranteed to see RESET.
       *  If used after  shutdown, remote in-stream may or may not see RESET.
       * Data unreceived by the remote in-stream before reset may be lost.
       *)
      val reset: t -> unit
      
      (* Queue data for transmission to the remote in-stream.
       * The callback is invoked with READY when more data may be queued.
       * If write is called again before completion, RaceCondition is raised.
       * If write is called after shutdown, RaceCondition is raised.
       * 
       * If the local out-stream is reset, the callback is immediately RESET.
       * 
       * If the remote in-stream resets the stream, the callback might also
       * receive RESET, indicating no further writing should be done.
       *)
      datatype status = RESET | READY
      val write : t * Word8Vector.vector * (status -> unit) -> unit
      
      (* Identify the stream for debugging.
       * The globalID of an instream matches the connected remote outstream.
       * However, this is identifier is re-used and initially ~1.
       * The localName is a user-assigned local name for the stream.
       *)
      val globalID : t -> Word16.word
      val localName  : t -> string

      type description = {
         localName : string,
         statistics : LargeInt.int -> unit
      }
      val setDescription : t * description -> unit
   end
