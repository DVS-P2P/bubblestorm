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

structure KVStats =
   struct
      (* statistics *)
      fun statConfig (statname, units) = 
         {
            parents = nil,
            name = statname,
            units = units,
            label = statname,
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }
      val basicStatistics = Statistics.new o statConfig
      fun defaultStatistics (statname, units) =
         basicStatistics ("kv/" ^ statname, units)
      fun trafficStatistics name = (
         basicStatistics ("sent/coordinator/" ^ name, "bytes"), 
         basicStatistics ("received/coordinator/" ^ name, "bytes")
      )
      (* FIXME: this is currently unaffected by coordinator cmdline args *)
      val base = LogarithmicMeasurement.getBase (KVConfig.defaultLifetime, KVConfig.defaultSteps)
      val cooldown = Time.- (KVConfig.defaultCooldown, Time.fromSeconds 1) 
      val getTime = Real32.toString o Time.toSecondsReal32 o LogarithmicMeasurement.calc (base, cooldown)
      fun timelineStatistics (statname, units) =
         TimelineStatistics.new (statConfig ("kv/" ^ statname, units), KVConfig.defaultSteps, getTime)
      
      val joined           = defaultStatistics ("joined nodes", "#")
      val joinTime         = defaultStatistics ("join time", "seconds")
      val leaveTime        = defaultStatistics ("leave time", "seconds")

      val recall           = timelineStatistics ("recall", "%")
      val precision        = timelineStatistics ("precision", "%")
      val firstHit         = timelineStatistics ("first hit", "seconds")
      val correctHit       = timelineStatistics ("correct hit", "seconds")
      val matchCount       = timelineStatistics ("result count", "#")
      val correctCount     = timelineStatistics ("correct result count", "#")
      val isDeleted        = timelineStatistics ("delete success", "%")

      val coordClients     = defaultStatistics ("coordinator/clients", "#")
      val coordInserts     = defaultStatistics ("coordinator/inserts", "#")
      val coordUpdates     = defaultStatistics ("coordinator/updates", "#")
      val coordDeletes     = defaultStatistics ("coordinator/deletes", "#")
      val coordFinds       = defaultStatistics ("coordinator/finds", "#")
      
      val dataBubbleSize = defaultStatistics ("data bubble size", "#")
      val dataBubbleCost = defaultStatistics ("data bubble cost", "bytes/measurement")
      val queryBubbleSize = defaultStatistics ("query bubble size", "#")
      val queryBubbleCost = defaultStatistics ("query bubble cost", "bytes/measurement")
      
      val (sentConfirm,  receivedConfirm)  = trafficStatistics "confirm"
      val (sentInsert,   receivedInsert)   = trafficStatistics "insert"
      val (sentUpdate,   receivedUpdate)   = trafficStatistics "update"
      val (sentDelete,   receivedDelete)   = trafficStatistics "delete"
      val (sentFind,     receivedFind)     = trafficStatistics "find"
      val (sentRegister, receivedRegister) = trafficStatistics "register"
   end
