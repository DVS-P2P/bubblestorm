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

structure Config =
   struct
      (* ------------------------------------- *)
      (*  LAN mode shortens all the timeouts   *)
      (* ------------------------------------- *)
      local
         val lanMode = ref false
         val lanModeFactor = 10 (* 10* faster *)         
      in
         fun setLanMode x = lanMode := x
         
         fun applyLanMode seconds = 
            let
               val delay = Time.fromSeconds seconds
            in
               if !lanMode
               then Time.divInt (delay, lanModeFactor)
               else delay
            end
      end
      
      (* ---------------------------------- *)
      (*  Topology configuration constants  *)
      (* ---------------------------------- *)

      (* bandwidth for a min capacity peer *)
      val minBandwidth = 128000.0 : Real32.real
      (* burst window for bandwidth cap *)
      val bandwidthBurstWindow = Time.fromMilliseconds 20
      (* the minimum number of desired neighbours allowed *)
      val minDegree = 16
      (* max conversation send&recv buffer sizes *)
      val topologyConversationLimit = 131072
      (* the default topology conversation timout *)
      fun deathTimeout () = applyLanMode 45
      (* require packets sent this often -- MUST be less than half of deathTimeout *)
      fun keepAliveTimeout () = applyLanMode 15
      (* how long do we wait for shutdown completion after intiation *)
      fun gracePeriod () = applyLanMode 240
      (* how long do we wait for something to happen after calling leave *)
      fun leaveWait () = applyLanMode 20
      (* how long do we allow a RW/RO slacker to stay when not leaving *)
      val slackerNiceWait = gracePeriod
      (* how long do we allow a RW/RO slacker to stay when leaving *)
      val slackerKickWait = leaveWait
      (* how long to wait for an upgradeOk after upgrade *)
      fun upgradeWait () = applyLanMode 45
      (* timeout for join random walk *)
      fun joinTimeout () = applyLanMode 240
      (* timeout for makeSlave when node is leaving itself *)
      fun slaveLeaveTimeout () = applyLanMode 30
      (* timeout for a bootstrap to respond *)
      fun bootstrapTimeout () = applyLanMode 20
      (* well-known service ID for bootstrap service *)
      val BOOTSTRAP_SERVICE = 0w89 : CUSP.EndPoint.service
      (* maximum number of extra random walk hops before discarding *)
      val maxRandomWalkOvershoot : Int16.int = 10
      (* Maximum sizes of topology messages *)
      val maxBubblecast = 65536
      val maxGossip = 1024
      (* Number of neighbors beyond desiredDegree that have to agree before
         a round switch is initiated *)
      val gossipExtraAgreement = minDegree
      
      (* Reliability for topology messages *)
      local
         open Conversation.Reliability
      in
         val topologyReliability   = reliable
         val gossipReliability     = fromReal 10000.0
         val bootstrapRealiability = fromReal  9000.0
         val walkReliability       = fromReal  8000.0
      end
      (* Priority of topology messages *)
      local
         open Conversation.Priority
      in
         val topologyPriority  = fromReal 11000.0
         val gossipPriority    = fromReal  8000.0
         val bootstrapPriority = fromReal 10000.0
         val walkPriority      = fromReal  9000.0
      end
      
      (* How far from floating point precision is considered a match?
       * For an IEEE float with precision 3e-8, this means we allow
       * relative error 64 times larger (2e-6). You can't set this too
       * low or rounding error prevents round switch. Too high and your
       * results might not reach floating point precision.
       * For a heterogeneous network, 4 is too low.
       * For the heterogeneous mix in Wes' thesis 64 was large enough.
       * Intermediate values have not been tested.
       *)
      val measurementAccuracySlack = 64
      
      (* How many random walk hops? 
         * => Suffices to get within 1% relative error of true uniform sampling
         * see Wesley's thesis for details
         *)
      local
         open Real32.Math
         val degree = Real32.fromInt minDegree
         val delta = 0.01
         val coefficient = 4.0 / (ln degree - 2.0 * ln 2.0)
         val constant = coefficient * (ln 2.0 - ln delta)
      in
         fun walkLength size = constant + coefficient * ln size
      end

      (* -------------------------------- *)
      (*  Bubble configuration constants  *)
      (* -------------------------------- *)
      
      (* Balancer frequency, must be at least twice the topology deathTimeout *)
      fun balanceFrequency () = applyLanMode 90
      (* How much of the last round's cost do we smooth over *)
      val balanceRetention = 0.8 : Real32.real
      
      (* default bubblecast message priority *)
      val defaultQueryPriority   =  5000.0 : Real32.real
      val defaultStoragePriority =  4000.0 : Real32.real
      val findMaintainerPriority =  3000.0 : Real32.real
      val findStoragePriority    =  3000.0 : Real32.real
      val responsibilityPriority =  2000.0 : Real32.real
      val hostcachePriority      =  1000.0 : Real32.real
      (* Every bubble has the same reliability, because we want
       * loss to affect bubbles equally. Imagine AxB intersecting.
       * Dropping 50% of only A is worse that 25% of A and B.
       *)
      val defaultBubblecastReliability = 4000.0 : Real32.real
      val defaultBubblepostReliability = 5000.0 : Real32.real
      val findMaintainerReliability    = 3000.0 : Real32.real
      val findStorageReliability       = 3000.0 : Real32.real
      val responsibilityReliability    = 2000.0 : Real32.real
      val hostcacheReliability         = 1000.0 : Real32.real
      (* the maximum factor a bubble may be bigger than its default size. Incoming
         slices that are bigger are truncated *)
      val maxBubbleOvershoot = 1.2
      
      (**)
      val RPCTimeout = Time.fromSeconds 60
      (**)
      val RPCLeaveTimeout = Time.fromSeconds 30

      (* priority of point-to-point messages used for managed bubbles *)
      val maintainerPriority = Conversation.Priority.fromReal 500.0
      (* maxumum size of managed bubble payload *)
      val maxMaintainedData = 65536
      
      (* service port number for durable replication *)
      val durableContact = 0w8587 : CUSP.EndPoint.service
      val durableQuit    = 0w8588 : CUSP.EndPoint.service
      (* expected number of neighbors in a responsibility set *)
      val durableDegree = 2.0
      (* the minimum number of replicas in a durable bubble *)
      val durableReliability = 20.0
      (* probability to not find the giant component is O(e^-x) *)
      val locateBubbleSize = 3.0
      (* when do we consider a neighbor dead? *)
      val durableTimeout = Time.fromSeconds 30
      
      (* ------------------------ *)
      (*  Notification constants  *)
      (* ------------------------ *)
      
      val notificationResponseTimeout = Time.fromSeconds 60
      
   end
