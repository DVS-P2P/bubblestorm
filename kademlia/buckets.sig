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

signature BUCKETS =
   sig
      structure Id : ID
      structure Address : ADDRESS
      structure Bucket : BUCKET where type Id.t = Id.t and type Address.t = Address.t
      
      type t
      
      (* Creates the buckets for node with specified local ID given max. bucket size *)
      val new : Id.t * int -> t
      
      (* Returns the bucket ID for the given node ID *)
      val bucketId : t * Id.t -> int
      
      (* Updates a node whenever a message has been received,
         returns whether node has been added *)
      val updateNode : t * Id.t * Address.t -> bool
      
      (* Notifier for message timeout *)
      val nodeTimeout : t * Id.t -> unit
      
      (* Returns the closest known nodes for the given ID *)
      val getCloseNodes : t * {
            targetId : Id.t,
            requestorId : Id.t, (* this ID is excluded from the result *)
            count : int
         } -> Bucket.Contact.t list
      
      (* Returns the number of nodes in routing table that are closer to me
         than the given ID (using local information only) *)
      val countCloserNodes : t * Id.t -> int
      
      (* Returns whether there are neighbors closer to given ID than myself
         (using local information only) *)
      val knowNodesCloserTo : t * Id.t -> bool
      
      (* Returns the number of neighbors closer to given ID than myself
         (using local information only) *)
(*       val countNodesCloserTo : t * Id.t -> int *)
      
      (* Returns the number of nodes that are closer to the first ID than the
         second ID (using local information only) *)
      val countCloserNodesFor : t * Id.t * Id.t -> int 
      
      (* Returns whether the bucket with given ID is empty. *)
      val isEmpty : t * int -> bool
      
      val toString : t -> string
      
   end
