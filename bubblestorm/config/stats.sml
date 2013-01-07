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

structure Stats =
   struct
      fun cut name = List.last (String.tokens (fn c => c = #"/") name)
      
      fun defaultStatistics (name, units) =
         Statistics.new {
            parents = nil,
            name = name,
            units = units,
            label = cut name,
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }
      
      fun histogramConfig buckets (name, units) =
         {
            parents = nil,
            name = name,
            units = units,
            label = cut name,
            histogram = Statistics.FIXED_BUCKET buckets,
            persistent = true
         }
      (*
      val histogramStatistics10 = Statistics.new o histogramConfig 10.0
      val histogramStatistics1  = Statistics.new o histogramConfig 1.0
      *)
      val histogramStatistics10 = defaultStatistics
      val histogramStatistics1  = defaultStatistics
      
      (* Timeline Statistic setup for maintainer/storage peer counts *)
      
      val sec = Time.fromSeconds
      val ageSlots = Vector.fromList [
         sec 1, sec 2, sec 4, sec 8, sec 15, sec 60,
         sec 120, sec 240, sec 480, sec 900, sec 1800, sec 3600,
         sec (3600*2), sec (3600*3), sec (3600*4), sec (3600*5),
         sec (3600*6), sec (3600*7), sec (3600*8), sec (3600*9), sec (3600*10)
      ]
      
      fun getAgeSlot' (age, pos) =
         if Time.<= (age, Vector.sub (ageSlots, pos)) then pos else getAgeSlot' (age, pos+1)
         handle Subscript => Vector.length ageSlots -1
      fun getAgeSlot age = getAgeSlot' (age, 0)
      
      fun printAge slot = (Real32.toString o Time.toSecondsReal32 o Vector.sub) (ageSlots, slot)
      
      fun timelineStatistic config =
         TimelineStatistics.new (config, Vector.length ageSlots, printAge)
      
      (* ---------------------------------- *)
      (*  Join/leave statistics             *)
      (* ---------------------------------- *)
      
      val joinTime = defaultStatistics ("bubblestorm/join time", "seconds")
      val leaveTime = defaultStatistics ("bubblestorm/leave time", "seconds")

      (* ---------------------------------- *)
      (*  Topology statistics               *)
      (* ---------------------------------- *)
      
      val nodeDegree = defaultStatistics ("topology/node degree", "#")
      val topologyJoinTime = defaultStatistics ("topology/join time", "seconds")
      val topologyLeaveTime = defaultStatistics ("topology/leave time", "seconds")
      val locationJoinTime = defaultStatistics ("topology/location join time", "seconds")
      val randomWalkOvershoot = defaultStatistics ("topology/random walk overshoot", "hops")
      val loadBalance = histogramStatistics10 ("topology/load balance", "bytes/second")

      (*val graphVizDumper =
         SimultaneousDump.new ("topology.dot", "digraph G {\n", "}\n", Time.fromSeconds 5)
         SimultaneousDump.new ("topology.dot", "digraph G {\n", "}\n", Time.fromDays 1000)*)      

      (* -------------------------------- *)
      (*  Bubble statistics               *)
      (* -------------------------------- *)

      (* measurement protocol *)
      val measurementRound = defaultStatistics ("measurement/round", "#")
      val measureD0 = defaultStatistics ("measurement/d0", "#")
      val measureD1 = defaultStatistics ("measurement/d1", "#")
      val measureD2 = defaultStatistics ("measurement/d2", "#")
      val measureDmin = defaultStatistics ("measurement/dmin", "#")
      val measureDmax = defaultStatistics ("measurement/dmax", "#")
      val measureP0 = defaultStatistics ("measurement/expected replicas", "#")
      
      (* query results *)
      val queryLatency = defaultStatistics ("query/latency", "seconds")
      val queryCompletion = defaultStatistics ("query/completion", "seconds")
      val queryResults = histogramStatistics1 ("query/results", "#")
      
      type managed = {
         maintainers : TimelineStatistics.t,
         storage : TimelineStatistics.t,
         target : Statistics.t,
         replicas : Statistics.t,
         density : Statistics.t,
         threshold : Statistics.t,
         flushes : Statistics.t,
         truncate : Statistics.t,
         positions : Statistics.t
      }
      
      (* managed replication *)
      val managed = {
         maintainers = timelineStatistic (histogramConfig 1.0 ("managed/maintainer pool size", "#")),
         storage = timelineStatistic (histogramConfig 1.0 ("managed/storage pool size", "#")),
         target = defaultStatistics ("managed/target size", "#"),
         replicas = defaultStatistics ("managed/replicas", "#"),
         density = defaultStatistics ("managed/target density", "#"),
         threshold = defaultStatistics ("managed/junk threshold", "#"),
         flushes = defaultStatistics ("managed/flushes", "#"),
         truncate = defaultStatistics ("managed/truncates", "#"),
         positions = histogramStatistics1 ("managed/positions", "#")
      }

      (* durable replication *)
      val responsibility = {
         maintainers = timelineStatistic (histogramConfig 1.0 ("responsibility/maintainer pool size", "#")),
         storage = timelineStatistic (histogramConfig 1.0 ("responsibility/storage pool size", "#")),
         target = defaultStatistics ("responsibility/target size", "#"),
         replicas = defaultStatistics ("responsibility/replicas", "#"),
         density = defaultStatistics ("responsibility/target density", "#"),
         threshold = defaultStatistics ("responsibility/junk threshold", "#"),
         flushes = defaultStatistics ("responsibility/flushes", "#"),
         truncate = defaultStatistics ("responsibility/truncates", "#"),
         positions = histogramStatistics1 ("responsibility/positions", "#")
      }
      val responsibilitySize = defaultStatistics ("durable/responsibility size", "#")
      val responsibilityCost = defaultStatistics ("durable/responsibility cost", "#")
      val durableNeighbors = defaultStatistics ("durable/neighbors", "#")
      (*val durableRands = defaultStatistics ("durable/random", "#")
      val durableNodeIDs = defaultStatistics ("durable/node ids", "#")    
      val durableDocIDs = defaultStatistics ("durable/doc ids", "#")*)
      
      (* -------------------------------- *)
      (*  Traffic statistics              *)
      (* -------------------------------- *)

      fun trafficStatistics name = (defaultStatistics ("sent/" ^ name, "bytes"), 
                                    defaultStatistics ("received/" ^ name, "bytes"))

      (* RPC *)
      val (sentConfirm, receivedConfirm) = trafficStatistics "confirm"

      (* Topology *)
      val (sentTopologyBootstrap, receivedTopologyBootstrap) = trafficStatistics "topology/bootstrap"
      val (sentTopologyBootstrapOk, receivedTopologyBootstrapOk) = trafficStatistics "topology/bootstrapOk"
      val (sentTopologyFindServer, receivedTopologyFindServer) = trafficStatistics "topology/findServer"
      val (sentTopologyMakeClient, receivedTopologyMakeClient) = trafficStatistics "topology/makeClient"
      val (sentTopologyYesServer, receivedTopologyYesServer) = trafficStatistics "topology/yesServer"
      val (sentTopologyUpgrade, receivedTopologyUpgrade) = trafficStatistics "topology/upgrade"
      val (sentTopologyUpgradeOk, receivedTopologyUpgradeOk) = trafficStatistics "topology/upgradeOk"
      val (sentTopologyMakeSlave, receivedTopologyMakeSlave) = trafficStatistics "topology/makeSlave"
      val (sentTopologyYesMaster, receivedTopologyYesMaster) = trafficStatistics "topology/yesMaster"
      val (sentTopologyLeaveClient, receivedTopologyLeaveClient) = trafficStatistics "topology/leaveClient"
      val (sentTopologyLeaveSlave, receivedTopologyLeaveSlave) = trafficStatistics "topology/leaveSlave"
      val (sentTopologyLeaveMaster, receivedTopologyLeaveMaster) = trafficStatistics "topology/leaveMaster"
      val (sentTopologyGossip, receivedTopologyGossip) = trafficStatistics "topology/gossip"
      val (sentTopologyKeepAlive, receivedTopologyKeepAlive) = trafficStatistics "topology/keepAlive"

      (* Bubblecast *)
      val (sentBubblecast, receivedBubblecast) = trafficStatistics "bubblecast"

      (* Notification *)
      val (sentNotification, receivedNotification) = trafficStatistics "notification/notification"
      val (sentNotificationRequestData, receivedNotificationRequestData) = trafficStatistics "notification/requestData"

      (* Managed Bubbles *)
      val (sentManagedStore, receivedManagedStore) = trafficStatistics "managed/store"
      val (sentManagedUpdate, receivedManagedUpdate) = trafficStatistics "managed/update"
      val (sentManagedDelete, receivedManagedDelete) = trafficStatistics "managed/delete"
      val (sentManagedQuit, receivedManagedQuit) = trafficStatistics "managed/quit"
      val (sentManagedAddStorage, receivedManagedAddStorage) = trafficStatistics "managed/add storage"
      val (sentManagedAddMaintainer, receivedManagedAddMaintainer) = trafficStatistics "managed/add maintainer"

      val (sentManagedComplete, receivedManagedComplete) = trafficStatistics "managed/complete"
      val (sentManagedStorage, receivedManagedStorage) = trafficStatistics "managed/storage"
      val (sentManagedOffer, receivedManagedOffer) = trafficStatistics "managed/offer"

      (* Bubblepost *)
      val (sentDurableAccept, receivedDurableAccept) = trafficStatistics "durable/accept"
      val (sentDurableStore, receivedDurableStore) = trafficStatistics "durable/store"
      val (sentDurableLookup, receivedDurableLookup) = trafficStatistics "durable/lookup"
      val (sentDurableContact, receivedDurableContact) = trafficStatistics "durable/contact"
      val (sentDurableQuit, receivedDurableQuit) = trafficStatistics "durable/quit"
   end
