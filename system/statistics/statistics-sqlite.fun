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

functor StatisticsSQLite (structure Event : EVENT
                          val database : unit -> SQL.db
                          val experiment : unit -> int)
   :> STATISTICS_WRITER =
   struct
      val module = "system/statistics/StatisticsSQLite"
      
      val createWriter' = ref (fn _ => raise At (module, 
         Fail "cannot create statistic without database connection"))
      
      fun createWriterImpl (create, getID, insert, insertHist) { name, units, label, node, collector, histogram } =
         let
            val experiment = experiment ()
            val typ = "unknown type" (* TODO: make statistic type a meaningful parameter *)
            
            (* create the ID of the statistic *)
            val () = SQL.exec create (experiment & name & units & label & node & typ)

            (* get the ID of the statistic *)
            val results = SQL.table getID (experiment & name & node)
            val id = if Vector.length results <> 1 
               then raise At (module, Fail "corrupt statistics table")
               else Vector.sub (results, 0)

            fun writer () =
               if Collector.count collector = 0 then () else (* don't write empty rows *)
               let
                  val realConvert = Real.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
                  
                  val () = SQL.exec insert (
                                id
                              & (Time.toString (Event.time ()))
                              & (Collector.count collector)
                              & (realConvert (Collector.min collector))
                              & (realConvert (Collector.max collector))
                              & (Collector.sum collector)
                              & (Collector.sum2 collector)
                           )
                  val () = Collector.reset collector
                  
                  (* write histogram *)
                  fun writeHist histogram =
                     let
                        fun insert (bucket, count, width) = SQL.exec insertHist (
                                id
                              & (Time.toString (Event.time ()))
                              & bucket
                              & count
                              & width
                           )
                        val () = Iterator.app insert (Histogram.buckets histogram)
                     in
                        Histogram.reset histogram
                     end
               in
                  Option.app writeHist histogram
               end
         in
            writer
         end

      fun init () =
         let
            open SQL.Query
            val database = database ()
            val experiment = experiment ()
            
            (*val () = print "Removing old data from the statistics tables.\n"*)
            val idSubquery = "(SELECT id FROM statistics WHERE experiment=" ^ 
                              Int.toString experiment ^ ");"
            val () = SQL.simpleExec (database, 
               "DELETE FROM measurements WHERE statistic IN " ^ idSubquery)
(*            val () = SQL.simpleExec (database, 
               "DELETE FROM measurements_single WHERE statistic IN " ^ idSubquery)*)
            val () = SQL.simpleExec (database, 
               "DELETE FROM histograms WHERE statistic IN " ^ idSubquery)
            val () = SQL.simpleExec (database, 
               "DELETE FROM statistics WHERE experiment=" ^ Int.toString experiment ^ ";")

            (* (re-creating a statistic on node re-join requres INSERT OR IGNORE) *)
            val create = prepare database
               "INSERT OR IGNORE INTO statistics (id, experiment, name, units, label, node, type)\
               \ VALUES (NULL, "iI", "iS", "iS", "iS", "iI", "iS");" $
            val getID = prepare database
               "SELECT id FROM statistics\
               \ WHERE experiment="iI" and name="iS" and node="iI";" oI $
            val insert = prepare database
               "INSERT INTO measurements (statistic, time, count, min, max, sum, sum2) \
                \ VALUES ("iI", "iS", "iI", "iR", "iR", "iR", "iR");" $
            val insertHist = prepare database
               "INSERT INTO histograms (statistic, time, bucket, count, width) \
                \ VALUES ("iI", "iS", "iR", "iI", "iR");" $
         in
            createWriter' := createWriterImpl (create, getID, insert, insertHist)
         end

      fun createWriter parameters = (!createWriter') parameters
   end
