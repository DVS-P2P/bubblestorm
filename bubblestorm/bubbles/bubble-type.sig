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

signature BUBBLE_TYPE =
   sig
      (* there are four different bubble type classes: instant, fading, managed,
         and durable. The classes fading, managed, and durable are of the 
         meta-class persistent, which means that they are stored in the overlay
         network. Instant bubble types are not persistent. *)
         
      (* the basic type all bubble types share *)
      type t
      
      (* the meta-class for bubble types that are stored in the network *)
      type persistent
      
      (* Instant bubble types are used for non-persistent information, that 
         usually triggers some action on a persistent bubble type. Typical 
         examples for instant bubble types are queries in an information 
         retrieval scenario and publications in a basic pub/sub scenario. *)
      type instant
      
      (* Fading bubble types are the most basic form of persistent bubble types.
         Bubbles of a fading type are sent into the network and not maintained 
         after that ("fire & forget"). They can not be updated or deleted and 
         will slowly decay under network churn. Therefore they should only be 
         used for short-living data that deletes itself after a timeout
         (this has to be implemented on application level). Fading bubbles are
         cheaper and quicker than other persistent types.  *)
      type fading
      
      (* Managed bubble types are maintained by their publisher (the node that 
         creates them). This node can update and delete them. If the publisher 
         leaves the network, it will delete its managed bubbles automatically. 
         If it crashes, the orphaned bubbles ("junk") will be purged from the 
         network after some time. This class should be used for data that is 
         naturally bound to its publisher. Typical examples would be a list of 
         shared data in a filesharing scenario or precense information in a 
         chat system. *)
      type managed
      
      (* Durable bubble types are collectively maintained by the nodes in the 
         network (opposed to the publisher for managed bubbles). They can be 
         updated or deleted by any node in the system, but conflicts may occur 
         under concurrent updates (some updates might not take effect). Durable 
         bubbles will persist indefinetely even under churn. A typical use case
         for such bubble types would articles in a distributed wiki. *)
      type durable
      
      (* convert a bubble type of a certain class to the basic type *)
      val basicInstant : instant -> t
      val basicFading  : fading  -> t
      val basicManaged : managed -> t
      val basicDurable : durable -> t
      val basicPersistent : persistent -> t
      (* convert a bubble type of a certain class to the persistent type *)
      val persistentFading  : fading  -> persistent
      val persistentManaged : managed -> persistent
      val persistentDurable : durable -> persistent
      
      (* If a bubble type should interact with data of another bubble type, 
         this has to be specified via match. The subject is the bubble type that 
         should trigger the action (e.g. the query) and the object is the bubble 
         type it operates on (e.g. the data). lambda specifies the certainty of 
         a successful rendezvous (i.e. the query finds the data). The failure 
         probability for a given query-data pair is exp(-lambda). Higher lambda
         results in higher network traffic because the bubble sizes need to be 
         increased. The handler function on the receiving peers is passed the 
         payload of the subject bubble. How it uses this payload or the locally 
         stored object bubble type data is the application's concern.
         Application developers should have a look on the convencience APIs for 
         standard scenarios like query/data or pub/sub which already implement 
         result notification. *)
      val match : {
         subject : t,
         object  : persistent,
         lambda  : Real64.real,
         handler : Word8VectorSlice.slice -> unit
      } -> unit
      
      (* Similar to match, only that it passes the ID of the subject bubble to 
         the match function. This can only be used if the subject bubble type is 
         persistent (instant bubbles have no ID). *)
      val matchWithID : {
         subject : persistent,
         object  : persistent,
         lambda  : Real64.real,
         handler : ID.t * Word8VectorSlice.slice -> unit
      } -> unit

      (* the ID given to a bubble type *)
      val typeId : t -> int
      
      (* the name of a bubble type *)
      val name : t -> string
      
      (* the priority of messages of this bubble type *)
      val priority    : t -> Real32.real
      val reliability : t -> Real32.real
      
      (* the number of nodes a bubble of this type is replicated to *)
      val defaultSize : t -> int

      val setSizeStat : t * Statistics.t option -> unit
      val setCostStat : t * Statistics.t option -> unit

      val topology : t -> Topology.t
      val endpoint : t -> CUSP.EndPoint.t
      val address  : t -> CUSP.Address.t
      
      (* information shared between all bubble types of an overlay network.
         needed to create new bubble types. *)
      type master
      
      val newMaster : Topology.t * NodeAttributes.t -> master
      val join : master -> unit    
      val leave : master -> unit
      val onJoinComplete : master -> unit    
      val onLeaveComplete : master -> unit
      val networkSize : master -> int
      
      val newInstant : {
         master      : master,
         name        : string,
         typeId      : int,
         priority    : Real32.real option,
         reliability : Real32.real option
      } -> instant
      
      val newFading : {
         master      : master,
         name        : string,
         typeId      : int,
         priority    : Real32.real option,
         reliability : Real32.real option,
         store       : ID.t * Word8VectorSlice.slice -> unit
      } -> fading

      val newManaged : {
         master      : master,
         name        : string,
         typeId      : int,
         priority    : Real32.real option,
         reliability : Real32.real option,
         datastore   : ManagedDataStore.t
      } -> managed

      val newDurable : {
         master      : master,
         name        : string,
         typeId      : int,
         priority    : Real32.real option,
         reliability : Real32.real option,
         datastore   : DurableDataStore.t
      } -> durable
   end

signature BUBBLE_TYPE_EXTRA =
   sig
      include BUBBLE_TYPE
      
      val managedReplication : managed -> ManagedReplication.t
      val durableReplication : durable -> DurableReplication.t
   end
