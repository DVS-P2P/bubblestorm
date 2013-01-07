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

structure BubbleType :> BUBBLE_TYPE_EXTRA where type t = BasicBubbleType.t =
   struct
      type t = BasicBubbleType.t
      type persistent = t
      
      type instant = t
      type fading  = t
      datatype managed = M of { basic : t, replication : ManagedReplication.t }
      datatype durable = D of { basic : t, replication : DurableReplication.t }
      
      fun basicInstant this = this
      fun basicFading  this = this
      fun basicManaged (M this) = #basic this
      fun basicDurable (D this) = #basic this
      fun basicPersistent this = this

      fun persistentFading  this = this
      fun persistentManaged (M this) = #basic this
      fun persistentDurable (D this) = #basic this

      fun managedReplication (M this) = #replication this      
      fun durableReplication (D this) = #replication this

      datatype master = MASTER of {
         state   : BasicBubbleType.bubbleState,
         managed : ManagedReplication.t,
         durable : DurableReplication.t
      }
      
      fun newMaster (topology, attributes) =
         let
            val state = BasicBubbleType.newBubbleState (topology, attributes)
            val () = Balancer.init state
            val managed = ManagedReplication.new {
               state = state,
               name  = "Managed",
               findMaintainerID = ~1,
               findStorageID = ~2,
               statistics = Stats.managed
            }
         in
            MASTER {
               state = state,
               managed = managed,
               durable = DurableReplication.new state
            }
         end
         
      fun join (MASTER this) =
         let
            val stats = BasicBubbleType.stats (#state this)
            val () = SystemStats.setStatus (stats, SystemStats.JOINING)
            val () = ManagedReplication.onJoin (#managed this)
            val () = DurableReplication.onJoin (#durable this)
         in
            ()
         end
         
      fun leave (MASTER this) =
         let
            val stats = BasicBubbleType.stats (#state this)
            val () = SystemStats.setStatus (stats, SystemStats.LEAVING)
            val () = ManagedReplication.onLeave (#managed this)
            val () = DurableReplication.onLeave (#durable this)
         in
            ()
         end
         
      fun onJoinComplete (MASTER this) =
         let
            val stats = BasicBubbleType.stats (#state this)
            val () = SystemStats.setStatus (stats, SystemStats.ONLINE)
            val () = ManagedReplication.onJoinComplete (#managed this)
            val () = DurableReplication.onJoinComplete (#durable this)
         in
            ()
         end
         
      fun onLeaveComplete (MASTER this) =
         let
            val stats = BasicBubbleType.stats (#state this)
            val () = SystemStats.setStatus (stats, SystemStats.OFFLINE)
            val () = ManagedReplication.onLeaveComplete (#managed this)
            val () = DurableReplication.onLeaveComplete (#durable this)
         in
            ()
         end
      
      fun newInstant { master=MASTER this, name, typeId, priority, reliability } =
         BasicBubbleType.new {
            state       = #state this,
            name        = name,
            typeId      = typeId,
            class       = BasicBubbleType.INSTANT,
            priority    = Option.getOpt (priority, Config.defaultQueryPriority),
            reliability = Option.getOpt (reliability, Config.defaultBubblecastReliability)
         }            
      
      fun newFading { master=MASTER this, name, typeId, priority, reliability, store } =
         BasicBubbleType.new {
            state       = #state this,
            name        = name,
            typeId      = typeId,
            class       = BasicBubbleType.FADING { store = store },
            priority    = Option.getOpt (priority, Config.defaultStoragePriority),
            reliability = Option.getOpt (reliability, Config.defaultBubblecastReliability)
         }            

      fun newManaged { master=MASTER this, name, typeId, priority, reliability, datastore } =
         let
            val bubbletype = BasicBubbleType.new {
                     state    = #state this,
                     name     = name,
                     typeId   = typeId,
                     class    = BasicBubbleType.MANAGED {
                                   cache = ManagedDataCache.new (),
                                   datastore = datastore
                                },
                     priority = Option.getOpt (priority, Config.defaultStoragePriority),
                     reliability = Option.getOpt (reliability, Config.defaultBubblecastReliability)
                  }
            val () = ManagedReplication.register (#managed this, bubbletype)
         in
            M {
               basic = bubbletype,
               replication = #managed this
            }
         end

      fun newDurable { master=MASTER this, name, typeId, priority, reliability, datastore } =
         let
            val bubbletype = BasicBubbleType.new {
                     state    = #state this,
                     name     = name,
                     typeId   = typeId,
                     class    = BasicBubbleType.DURABLE {
                                   datastore = datastore
                                },
                     priority = Option.getOpt (priority, Config.defaultStoragePriority),
                     reliability = Option.getOpt (reliability, Config.defaultBubblecastReliability)
                  }
            val () = DurableReplication.register (#durable this, bubbletype)
         in
            D {
               basic = bubbletype,
               replication = #durable this
            }
         end
      
      fun match { subject, object, lambda, handler } =
         BasicBubbleType.match {
            subject = subject,
            object = object,
            lambda = lambda,
            handler = fn (_, data) => handler data
         }
         
      fun matchWithID { subject, object, lambda, handler } =
         BasicBubbleType.match {
            subject = subject,
            object = object,
            lambda = lambda,
            handler = handler
         }

      val typeId = BasicBubbleType.typeId
      val name = BasicBubbleType.name
      val priority = BasicBubbleType.priority
      val reliability = BasicBubbleType.reliability
      val defaultSize = BasicBubbleType.defaultSize
      val setSizeStat = BasicBubbleType.setSizeStat
      val setCostStat = BasicBubbleType.setCostStat

      local
         open BasicBubbleType
      in
         val topology = fn bubble => (topology o state) bubble
         val endpoint = fn bubble => (endpoint o state) bubble
         val address  = fn bubble => (address o state) bubble
      end
      
      fun networkSize (MASTER this) =
         Real64.round (SystemStats.d0 (BasicBubbleType.stats (#state this)))
   end
