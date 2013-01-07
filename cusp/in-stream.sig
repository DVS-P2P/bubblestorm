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

signature IN_STREAM =
   sig
      type t
      
      (* Query how much data is buffered. *)
      val queuedOutOfOrder   : t -> int (* Received, but unreadable *)
      val queuedUnread       : t -> int (* Received, waiting to be read *)
      val bytesReceived      : t -> LargeInt.int
      
      (* Check if the stream is shutdown/reset *)
      datatype state = IS_ACTIVE | IS_SHUTDOWN | IS_RESET
      val state : t -> state
      
      (* Forcibly destroy this stream.
       * Prevents receipt of any further data.
       * Immediately frees queuedUnread; queuedOutOfOrder drains slowly.
       *  Drops received segments.
       *  Cancels with RESET any pending local reads.
       * Attempts to stop the remote out-stream from sending.
       *  The remote out-stream may (or may not) see the RESET.
       *)
      val reset: t -> unit
      
      (* Read data from the remote out-stream up to the specified amount.
       * The special value ~1 indicates any amount of data may be returnd.
       * The callback will be invoked when the operation completes.
       * The DATA slice provided to the callback is overwritten on return.
       * If read is called again before completion, RaceCondition is raised.
       *
       * The reader callback is never run with zero length DATA unless you
       * called read with length=0, in which case it means data is ready.
       * 
       * Normally, the callback is invoked with (DATA slice), where slice
       * contains read data. The slice will never exceed the requested size,
       * but can be less.
       * 
       * If the remote out-stream has shutdown this stream and all data has
       * been read, the callback is invoked with SHUTDOWN indicating EOF.
       * After delivering SHUTDOWN, the stream will be garbage collected.
       * 
       * If you have reset this stream, the callback is called with RESET.
       * If the remote out-stream calls reset, the callback may be invoked
       * with RESET (this is guaranteed if reset is called before shutdown).
       *)
      datatype status = SHUTDOWN | RESET | DATA of Word8ArraySlice.slice
      val read: t * int * (status -> unit) -> unit
      
      (* A convenience function which reads fully into the provided slice.
       * If the stream is terminated (via shutdown or reset) before the read
       * completes, the callback is invoked with 'false'.
       *)
      val readFully: t * Word8ArraySlice.slice * (bool -> unit) -> unit
      
      (* A convenience function which expects the next read to be SHUTDOWN.
       * If the next read returns SHUTDOWN, the callback is invoked with 'true'.
       * If there is any excess data, the stream is reset and 'false' is returned.
       *)
      val readShutdown: t * (bool -> unit) -> unit
      
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
