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

signature NODE_RPC =
   sig
      
      structure Id : ID
      structure Address : ADDRESS
      structure RPC : RPC
(*       structure Value : VALUE *)
      
      type t
      
      type updateNodeHandler = Id.t * Address.t -> unit
      type nodeTimeoutHandler = Id.t option * Address.t -> unit
      
      type pingRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t
         } -> bool
      type findNodeRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t,
            targetId : Id.t
         } -> (Id.t * Address.t) Iterator.t
      type storeRequestHandler =
         {
            fromAddr   : Address.t,
            fromId     : Id.t,
            id         : Id.t,
            value      : Word8Vector.vector,
            expiryDate : Time.t
         } -> bool
      datatype findValueResult =
         VALUE of (Id.t * Word8Vector.vector * Time.t) (* id, value, and expiration date *)
       | NODES of ((Id.t * Address.t) Iterator.t)
      type findValueRequestHandler =
         {
            fromAddr : Address.t,
            fromId   : Id.t,
            targetId : Id.t
         } -> findValueResult
      
      type pingCallback = Id.t option -> unit
      type findNodeCallback = (Id.t * (Id.t * Address.t) Iterator.t) option -> unit
      type storeCallback = Id.t option -> unit
      type findValueCallback = (Id.t * findValueResult) option -> unit
      
      (* Creates an instance using the specified RPC instance and local ID. *)
      val new : {
            port : int option,
            myId : Id.t,
            updateNode : updateNodeHandler,
            nodeTimeout : nodeTimeoutHandler,
            pingRequestHandler : pingRequestHandler,
            findNodeRequestHandler : findNodeRequestHandler,
            storeRequestHandler : storeRequestHandler,
            findValueRequestHandler : findValueRequestHandler
         } -> t
      
      val destroy : t -> unit
      
      (* Sends a PING message to given address.
         The optional ID parameter specifies the expected node ID. If the response
         is not from the same node, it is treated as a timeout.
      *)
      val ping : t * {
            destAddr : Address.t,
            destId   : Id.t option,
            callback : pingCallback
         } -> (unit -> unit)
      
      (* Sends a FIND_NODE message. *)
      val findNode : t * {
            destAddr : Address.t,
            destId   : Id.t option,
            targetId : Id.t,
            callback : findNodeCallback
         } -> (unit -> unit)
      
      (* Sends a STORE message *)
      val store : t * {
            destAddr    : Address.t,
            destId      : Id.t option,
            id          : Id.t,
            value       : Word8Vector.vector,
            expiryDate  : Time.t,
            callback    : storeCallback
         } -> (unit -> unit)
      
      (* Sends a FIND_VALUE message. *)
      val findValue : t * {
            destAddr : Address.t,
            destId   : Id.t option,
            targetId : Id.t,
            callback : findValueCallback
         } -> (unit -> unit)
      
   end
