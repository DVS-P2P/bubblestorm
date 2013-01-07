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

signature EXPERIMENT =
   sig
      structure Event : EVENT_EXTRA

      exception ExperimentNotFound

      datatype mode = SINGLE | MASTER | SLAVE

      (* the execution mode of this simulator process *)
      val mode : unit -> mode
      (* the ID of the selected experiment *)
      val id : unit -> int
      (* the name of the selected experiment *)
      val name : unit -> string
      (* the experiment database used for logging simulation results *)
      val database : unit -> SQL.db
      (* the interval in which statistics are written to the experiment database *)
      val logInterval : unit -> Time.t
      (* the global random number generator of the experiment.
         has to be used synchroneously on all simulator instances,
         because otherwise the simulation would not be reproducible. *)
      val random : unit -> Random.t
      (* the total number of nodes in the experiment *)
      val size : unit -> int
      (* whether the simulation should be slowed down to real-time *)
      val runRealTime : unit -> bool
      (* add a function to be executed at the beginning of the simulation run *)
      val addStartFunction : (Event.t -> unit) -> unit
      (* set a function to be executed at the end of the simulation run *)
      val setStopFunction : (Event.t -> unit) -> unit
      (* switches the database from auto-commit to periodic commits to increase
       * throughput. This put a write lock on the database that prevents
       * other processes to access the database. returns a function to unlock 
       * the database. *)
      val lockDB : unit -> (unit -> unit)
      (* closes the experiment and log database at the end of the simulation run *)
      val closeDB : unit -> unit
      val init : {
         mode : mode,
         database : string,
         experiment : string,
         realtime : bool
      } -> unit 
   end
