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

signature OUT_STREAM_QUEUE =
   sig
      include OUT_STREAM
      eqtype t'
      sharing type t = t'
      
      datatype event = 
         RTS of Real32.real
       | BECAME_RESET
       | BECAME_COMPLETE
       | INFLIGHT_BYTES of int
       | RETRANSMIT_BYTES of int
      
      (* Expect at least 8 bytes available in the buffer *)
      val pull: t * Word16.word * Word8ArraySlice.slice -> PacketFormat.segment * int * (bool -> unit)
      val recv: t * Word8ArraySlice.slice * PacketFormat.writer -> int
      val isReset: t -> bool
      val updateSendStatistics : t -> unit

      val new: (event -> unit) -> t
      val setID: t * Word16.word -> unit
   end
