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

(* A CongestionControl functor is constructed with a higher level layer (Host)
 * A CongestionControl object (new) is constructed with a lower level rts (AckCallbacks)
 *)
signature CONGESTION_CONTROL =
   sig
      type t
      type host
      
      datatype status = TIMEOUT | MISSING | MTU | ACK
      
      val recv: t * Word8ArraySlice.slice -> bool
      val pull: t * Word8ArraySlice.slice ->
                { filled   : int,
                  ack      : status -> unit } (* callback to report (n)ack *)
      
      val host: t -> host
      
      (* Create a congestioncontrol stack giving the rts method *)       
      val new: { rts      : Real32.real Signal.t,
                 host     : host } -> t
      val destroy: t -> unit
   end
