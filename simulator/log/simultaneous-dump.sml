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

structure SimultaneousDump :> SIMULTANEOUS_DUMP =
   struct
      datatype t = T of {
         dumpers : (int * (unit -> string)) Ring.t, (* contains node ID and dump function *)
         writer : (int * (unit -> string)) Ring.t -> unit,
         event : Experiment.Event.t
      }

      val module = "sumulator/log/simultaneous-dump"
      
      val createWriter' = ref (fn _ => raise At (module, 
         Fail "cannot create dump without database connection"))
      
      fun createWriterImpl (create, getID, insert) (name, prefix, suffix) =
         let
            val experiment = Experiment.id ()
            
            (* create the ID of the dump *)
            val () = SQL.exec create (experiment & name & prefix & suffix)

            (* get the ID of the dump *)
            val results = SQL.table getID (experiment & name)
            val id = if Vector.length results <> 1 
               then raise At (module, Fail "corrupt dumps table")
               else Vector.sub (results, 0)
            
            fun writer ring =
               let
                  val time = Time.toString (Experiment.Event.time ())
                  fun dumpNode el =
                     let
                        val (node, dumper) = Ring.unwrap el
                        val text = dumper ()
                     in
                        SQL.exec insert (id & time & node & text)
                     end
               in
                  Ring.app dumpNode ring
               end
         in
            writer
         end
      
      fun init () =
         let
            open SQL.Query
            val experiment = Experiment.id ()
            val database = Experiment.database ()

            val () = print "Removing old data from the dumps tables.\n"
            val idSubquery = "(SELECT id FROM dumps WHERE experiment=" ^ 
                              Int.toString experiment ^ ");"
            val () = SQL.simpleExec (database, 
               "DELETE FROM dump_data WHERE dump IN " ^ idSubquery)
            val () = SQL.simpleExec (database, "DELETE FROM dumps WHERE experiment=" ^ (Int.toString experiment) ^ ";")

            val create = prepare database
               "INSERT INTO dumps (id, experiment, name, prefix, suffix)\
               \ VALUES (NULL, "iI", "iS", "iS", "iS");" $
            val getID = prepare database
               "SELECT id FROM dumps\
               \ WHERE experiment="iI" and name="iS";" oI $
            val insert = prepare database
               "INSERT INTO dump_data (dump, time, node, text)\
               \ VALUES ("iI", "iS", "iI", "iS");" $
         in
             createWriter' := createWriterImpl (create, getID, insert) 
         end
      
      fun new (name, prefix, suffix, interval) =
         let
            val dumpers = Ring.new ()
            val writer = (!createWriter') (name, prefix, suffix)

            fun dump event =
               (* stop if there are no more dumpers *)
               if Ring.isEmpty dumpers then () else
               let
                  (* dump *)
                  val () = writer dumpers
               in
                  Experiment.Event.scheduleIn (event, interval)
               end

            val event = Experiment.Event.new dump
         in
            T {
               dumpers = dumpers,
               writer = writer,
               event = event
            }
         end

      fun addDumper (T fields, dumper) =
         let
            val elem = Ring.wrap (SimulatorNode.id (SimulatorNode.current ()), dumper)
            val unhook = Ring.wrap (fn () => Ring.remove elem)
            val cleanup = SimulatorNode.cleanupFunctions (SimulatorNode.current ())
            val () = Ring.add (cleanup, unhook)
            val () = Ring.add (#dumpers fields, elem)
            val event = #event fields
         in
            if Experiment.Event.isScheduled event then ()
            else Experiment.Event.scheduleIn (event, Time.zero)
         end
   end
