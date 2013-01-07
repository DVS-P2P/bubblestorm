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

val module = "system/native-log"

structure StatsWriter :> STATISTICS_WRITER =
   struct
      datatype logMode = datatype ConfigCommandLine.logMode

      structure StdoutWriter = StatisticsStdout(Main.Event)
      
      fun logDB () = 
         case ConfigCommandLine.logDatabase () of
            SQLITE db => db
          | STDOUT => (* unreachable code *) raise At (module, 
           Fail "Trying to initialize log database that has not been configured")

      structure SqlWriter =
         StatisticsSQLite(
            structure Event = Main.Event
            val experiment = ConfigCommandLine.experimentID
            val database = logDB
         )

      fun init () =
         case ConfigCommandLine.logDatabase () of
            SQLITE _ => SqlWriter.init ()
          | STDOUT => StdoutWriter.init ()
      
      fun createWriter parameters =
         case ConfigCommandLine.logDatabase () of
            SQLITE _ => SqlWriter.createWriter parameters
          | STDOUT => StdoutWriter.createWriter parameters
   end

structure Statistics =
    Statistics(
       structure Helper = NativeStatisticsHelper
       structure Writer = StatsWriter
       structure Event  = Main.Event
    )

structure TimelineStatistics = TimelineStatistics(Statistics)

val () = StatsWriter.init ()

val defaultInterval = Time.fromSeconds 0
val logInterval = Option.getOpt (ConfigCommandLine.logInterval (), defaultInterval)
val () = Statistics.setLogInterval logInterval
