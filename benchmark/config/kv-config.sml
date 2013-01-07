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

structure KVConfig =
   struct
      (* Workload  & Experiement *)
      val defaultPort = 8585
      val defaultItemSize = 2000
      val defaultRate = 0.1 : Real32.real
      val defaultCooldown = Time.fromMilliseconds 100
      val defaultPhases = 0
      val defaultSteps = 20
      val defaultLifetime = Time.fromHours 1
      val defaultQueryTimeout = Time.fromSeconds 60
      (* for search experiments *)
      (*val expiration = Time.+ (defaultLifetime, Time.fromMinutes 10)*)
      (* for update/delete experiments *)
      val expiration = Time.fromHours 4
      
      (* Experiment Coordination *)
      val defaultCoordinator  = hd (CUSP.Address.fromString "127.0.0.1:8586")
      val defaultKeepAlive    = Time.fromSeconds 10
      val minPort = 500000
      val maxPort = 600000
      val bandwidth = 128000.0 : Real32.real
      val bandwidthBurstWindow = Time.fromMilliseconds 20
      val workloadPriority = Conversation.Priority.fromReal 2000.0
      val maxItemSize = 1000000
      val registerService = 0w8586 : Conversation.service (* TODO make cmdline arg *)
      
      (* BubbleStorm *)
      val dataBubbleID = 1
      val queryBubbleID = 2
      val lambda = 4.0
      
      (* Kademlia *)
      val kademliaLifetime = Time.fromDays 1
end
