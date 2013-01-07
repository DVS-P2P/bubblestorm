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

structure SimulatorLogWriter :> LOG_WRITER =
   struct
      structure LogWriter =
         SQLiteWriter(
            val experiment = Experiment.id
            val database = Experiment.database
         )
      
      fun init () =
         if Experiment.mode () = Experiment.SLAVE
              then () (* TODO: set up log forwarding *)
              else LogWriter.init ()
      
      fun write parameters =
         if Experiment.mode () = Experiment.SLAVE
            then () (* TODO: forward log entry *)
            else LogWriter.write parameters
   end   
