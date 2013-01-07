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

(* An AckGenerator functor is constructed with a higher level layer (AckCallbacks)
 * An AckGenerator object (new) is constructed with a lower level rts (Integrity)
 *)
signature ACK_GENERATOR =
   sig
      type t
      type host
      
      val recv: t  * {
         data   : Word8ArraySlice.slice,
         tsn    : Word32.word,
         asn    : Word32.word,
         acklen : int
      } -> unit
      
      val pull: t * {
         data : Word8ArraySlice.slice,
         tsn  : Word32.word
      } -> {
         len    : int,
         asn    : Word32.word,
         acklen : int,
         ok     : bool -> unit
      }
      
      val host: t -> host
      
      (* Create an nackcallback stack giving the rts method *)       
      val new: { rts      : Real32.real Signal.t, 
                 rtt      : Time.t,
                 host     : host,
                 ack      : bool } -> t
      val destroy: t -> unit
   end
