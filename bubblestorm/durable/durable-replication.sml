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

structure DurableReplication :> DURABLE_REPLICATION =
   struct
      datatype t = T of {
         types : BasicBubbleType.t list ref,
         managed : ManagedReplication.t,
         service : Service.t,
         bidirectional : BidirectionalNeighbor.t,
         responsibilityBubble : ResponsibilityBubble.t,
         lookupBubble : LookupBubble.t,
         storeBubble : StoreBubble.t
      }
      
      fun new state =
         let
            val types = ref []
            fun getTypes () = !types

            val backend = Backend.new getTypes
            
            val responsible = ref (fn _ => NONE)
            val route = ref (fn _ => ())
            val service = Service.new {
               state = state,
               responsible = fn x => (!responsible) x,
               route = fn x => (!route) x
            }

            val replicate = ref (fn _ => ())
            val contact   = ref (fn _ => ())
            val quit      = ref (fn _ => ())
            val table = RoutingTable.new {
               replicate = fn x => (!replicate) x,
               contact   = fn x => (!contact) x,
               quit      = fn x => (!quit) x
            }
            
            val bidirectional = BidirectionalNeighbor.new (state, service, table)
            val () = contact := BidirectionalNeighbor.contact bidirectional
            val () = quit    := BidirectionalNeighbor.quit    bidirectional
            
            val metric = RoutingMetric.new (state, table, backend)
            val () = responsible := RoutingMetric.iAmResponsible metric
            
            val router = Router.new (state, metric, service, table)
            val () = route := Router.route router
            val () = replicate := Router.replicate router
                        
            val managed = ManagedReplication.new {
               state = state,
               name  = "Durable",
               findMaintainerID = ~3,
               findStorageID = ~4,
               statistics = Stats.responsibility
            }

            (* statistics *)
            val status = SystemStats.status o BasicBubbleType.stats
            fun ifOnline f =
               if status state = SystemStats.ONLINE then f () else ()
            fun neighborCount () =
               ifOnline (fn () => Statistics.add Stats.durableNeighbors
                  (Real32.fromInt (RoutingTable.size table)))
            val () = Statistics.addPoll (Stats.durableNeighbors, neighborCount)
            
            (* hook to the measurement protocol *)
            fun onRoundSwitch _ = ifOnline (fn () => Router.onRoundSwitch router)
            val measurement = BasicBubbleType.measurement state
            val () = Measurement.addNotification (measurement, onRoundSwitch)
         in
            T {
               types = types,
               managed = managed,
               service = service,
               bidirectional = bidirectional,
               responsibilityBubble = ResponsibilityBubble.new (state, managed, table),
               lookupBubble = LookupBubble.new (state, router),
               storeBubble  = StoreBubble.new  (state, router)
            }
         end
         
      fun register (T this, bubble) =
         let
            val () = (#types this) := bubble :: !(#types this)
         in
            ResponsibilityBubble.register (#responsibilityBubble this,
               bubble, List.length (!(#types this)) = 1)
         end

      fun lookup (T this, request) =
         LookupBubble.send (#lookupBubble this, request)
      
      (*val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
      val overhead = toReal32 Config.durableDegree*)
         
      fun store  (T this, request as { bubble, id=_, version=_ }, data) =
         let
            val cost = BasicBubbleType.costMeasurement bubble
            val () = BubbleCostMeasurement.injectCost (cost, data)
            (*val () = BubbleCostMeasurement.injectCostFraction
               (cost, data, overhead)*)
         in
            StoreBubble.send (#storeBubble this, request, data)
         end

      fun onJoin (T this) = ManagedReplication.onJoin (#managed this)
      
      fun onJoinComplete (T this) =
         let
            val () = if List.length (!(#types this)) = 0 then () else
               ResponsibilityBubble.publish (#responsibilityBubble this,
                  #service this)
         in
            ManagedReplication.onJoinComplete (#managed this)
         end
         
      fun onLeave (T this) = ManagedReplication.onLeave (#managed this)

      fun onLeaveComplete (T this) =
         let
            val () = Service.close (#service this)
            val () = BidirectionalNeighbor.close (#bidirectional this)
         in
            ManagedReplication.onLeaveComplete (#managed this)
         end
   end
