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

signature RPC =
   sig
      type t
      
      structure Address : ADDRESS
      
      (* invoked when a request message is received.
         returns the write function that fills the passed buffer or NONE if there should be no response
         *)
      type requestCallback = Word8ArraySlice.slice * Address.t ->
         (Word8ArraySlice.slice -> int) option
      
      type responseCallback = Word8ArraySlice.slice option -> unit
      
      val new : int option -> t
      
      val destroy : t -> unit
      
      val registerService : t * Word16.word * requestCallback -> unit
      
      val unregisterService : t * Word16.word -> unit
      
      (* start a request. the 3rd parameter is the message payload pull funtion.
         use the returned function to abort the request; int option: timeout (ms) *)
      val request : t * {
         address : Address.t,
         service : Word16.word,
         writer : (Word8ArraySlice.slice -> int),
         response : responseCallback,
         timeout : int option
      } -> (unit -> unit)
      
   end
