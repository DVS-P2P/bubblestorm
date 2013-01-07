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

structure SimulatorStatisticsWriter :> STATISTICS_WRITER =
   struct
      structure StatsWriter =
         StatisticsSQLite(
            structure Event = Experiment.Event
            val experiment = Experiment.id
            val database = Experiment.database
         )

      (* create function for initialized environments *)
      fun createWriterNow parameters =
         if Experiment.mode () = Experiment.SLAVE
            then (fn _ => ()) (* TODO: create forwarding writer *)
            else StatsWriter.createWriter parameters

      type config = {
         name : string,
         units : string,
         label : string,
         node : int,
         collector : Collector.t,
         histogram : Histogram.t option
      }
      datatype writer = INITIALIZED of unit -> unit | UNINITIALIZED of config
      
      (* on-demand delay writer creation for uninitialized environment *)
      fun delayedInitWriter writer parameters =
         case !writer of
            INITIALIZED write => write parameters
          | UNINITIALIZED config =>
               let
                  val write = createWriterNow config
                  val () = writer := INITIALIZED write
               in
                  write parameters
               end

      (* create function to delay writer creation *)      
      fun createWriterLater parameters =
         delayedInitWriter (ref (UNINITIALIZED parameters))

      val initializeWriter = ref createWriterLater
         
      fun createWriter parameters = (!initializeWriter) parameters      

      fun init () =
         if Experiment.mode () = Experiment.SLAVE
            then () (* TODO: set up statistics forwarding *)
            else
               let
                  val () = StatsWriter.init ()
               in
                  initializeWriter := createWriterNow
               end
   end
