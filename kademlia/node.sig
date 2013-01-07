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

signature NODE =
   sig
      
      structure Id : ID
      structure Address : ADDRESS
(*       structure Value : VALUE where type Id.t = Id.t *)
      
      type t
      
      (* Contains a value and its expiration date. *)
      type valueEntry = Id.t * Word8Vector.vector * Time.t
      (* Store handler to be provided by the value store. *)
      type storeHandler = valueEntry -> bool
      (* Retrieve handler to be provided by the value store. *)
      type retrieveHandler = Id.t -> valueEntry option
      (* Returns an iterator over all stored values. *)
      type valuesIterator = unit -> valueEntry Iterator.t
      
      (* Callback for join success (true) or failure (false) *)
      type joinCallback = bool -> unit
      (* Callback for store. Passes the number of nodes on which
         the value has been stored successfully. *)
      type storeCallback = int -> unit
      (* Callback for retrieve. Passes SOME value if succesful,
         NONE otherwise. *)
      type retrieveCallback = (Id.t * Word8Vector.vector) option -> unit
      
      (* Creates a node an empty routing table. Listening at given port. *)
      val new : int option * storeHandler * retrieveHandler * valuesIterator -> t
      
      val destroy : t -> unit
      
      val myId : t -> Id.t
      
      (* Joins the network using given bootstrap address. *)
      val join : t * Address.t * joinCallback -> unit
      
      (* Stores a value (iterative FIND_NODE and STORE). *)
(*       val store : t * Value.t * storeCallback -> unit *)
(*       val storeWithPublishDate : t * Value.t * Time.t * storeCallback -> unit *)
      val store : t * Id.t * Word8Vector.vector * Time.t option * storeCallback -> unit
      
      (* Retrieves a value (iterative FIND_VALUE). *)
      val retrieve : t * Id.t * retrieveCallback -> unit
      
      (* Calculates the expiration factor depending on the number of
         nodes in the routing table between my ID and the given ID. *)
      val getExpirationFactor : t * Id.t -> Real32.real
      
   end
