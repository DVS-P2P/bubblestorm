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

structure Experiment :> EXPERIMENT =
   struct
      structure Event = Event ()

      val module = "simulator/experiment"
      
      exception ExperimentNotFound

      datatype mode = SINGLE | MASTER | SLAVE

      val mode'        = ref NONE
      val id'          = ref NONE
      val name'        = ref NONE
      val database'    = ref NONE
      val logInterval' = ref NONE
      val size'        = ref NONE
      val random'      = ref NONE
      val realTime'    = ref NONE
      val startDate'   = ref NONE          
      val runTime'     = ref NONE
      
      val unlockDB' = ref (fn () => raise At (module, Fail "unlockDB not initialized"))
      
      (* stores the start functions *)
      val startFunctionList = Ring.new ()
      
      fun execStartFunctions evt =
         Ring.app (fn s => (Ring.unwrap s) evt) startFunctionList
      
      fun getRefOption (variable, name) = case !variable of
         SOME x => x
       | NONE => raise At (module, Fail (name ^ " not initialized"))
         
      fun init { mode, database, experiment, realtime } = 
         let
           (* open database *)
            val () = print ("Opening database.\n")
            val database = SQL.openDB database
            (* tune DB *)
            local
               open SQL.Query
               val settingsQuery1 = prepare database
                  "PRAGMA synchronous=OFF;" $
               val settingsQuery2 = prepare database
                  "PRAGMA journal_mode=MEMORY;" $
               val settingsQuery3 = prepare database
                  "PRAGMA temp_store=MEMORY;" $
            in
               val () = SQL.exec settingsQuery1 ()
               val () = SQL.exec settingsQuery2 ()
               val () = SQL.exec settingsQuery3 ()
            end
      
            (* load experiment *)
            val () = print ("Reading experiment \"" ^ experiment ^ "\" from database.\n")
            local
               open SQL.Query
               val experimentQuery = prepare database
                  "SELECT id, start_date, runtime, log_interval, size, seed\
                  \ FROM experiments WHERE name="iS";"
                  oI oS oS oS oI oI $
               val results = SQL.table experimentQuery experiment
            in
               val ( id & startDate & runtime & logInterval & size & seed) =
                  if Vector.length results <> 1
                     then raise ExperimentNotFound
                  else Vector.sub (results, 0)
            end

            (* set experiment properties *)
            val () = mode' := SOME mode
            val () = database' := SOME database                
            val () = name' := SOME experiment
            val () = realTime' := SOME realtime
            val () = id':= SOME id
            val () = size':= SOME size

            (* parse times *)
            val () = startDate' :=
               (case Time.fromString startDate of
                  SOME x => SOME x
                | NONE => raise Fail ("Simulation start date (" ^ startDate ^
                                      ") is not a parseable timestamp."))
            val () = runTime' :=
               (case Time.fromString runtime of
                  SOME x => SOME x
                | NONE => raise Fail ("Simulation runtime (" ^ runtime ^
                                      ") is not a parseable timestamp."))
            val () = logInterval' := 
               (case Time.fromString logInterval of
                  SOME x => SOME x
                | NONE => raise Fail ("Simulation log interval (" ^ logInterval ^
                                      ") is not a parseable timestamp."))
      
            (* create random number generator *)
            val () = random' := SOME (Random.new (Word32.fromInt seed))
      
            val () = unlockDB' := (fn () => ())
         in
            (* schedule start functions *)
            Event.scheduleAt (Event.new execStartFunctions,
               Time.-(getRefOption (startDate', "startDate"), Time.fromNanoseconds64 1))
         end   

      (* enable locking of database after slaves have read their config *)
      fun lockDB () =
         let
            val database = getRefOption (database', "database")
            (* database locking & flushing*)
            val flushInterval = Time.fromMilliseconds 1000
            open SQL.Query
            val startTransaction = prepare database "BEGIN IMMEDIATE TRANSACTION;" $
            val commit = prepare database "COMMIT;" $
      
            fun forceRetry count statement parameters =
              SQL.exec statement parameters
              handle (x as SQL.Retry _) =>
                 if count <= 0 then raise x else
                 (OS.Process.sleep (SMLTime.fromMilliseconds 100);
                  forceRetry (count - 1) statement parameters)
      
            (* retry 10 times per second for one minute *)
            fun flushDatabase event =
               let
                  val () = forceRetry 600 commit ()
                  val () = forceRetry 600 startTransaction ()
               in
                  Main.Event.scheduleIn (event, flushInterval)
               end
      
            val flush = Main.Event.new flushDatabase
            val () = Main.Event.scheduleIn (flush, flushInterval)
            val () = SQL.exec startTransaction ()

            val () = unlockDB' := (fn () =>
               let
                  val () = Main.Event.cancel flush
               in
                  forceRetry 100 commit ()
               end)
         in
            fn () => (!unlockDB') ()
         end
                    
      (* function to close the database *)
      fun closeDB () =
         let
            val () = (!unlockDB') ()
         in
            SQL.closeDB (getRefOption (database', "database"))
         end

      (* getter functions *)
      fun mode ()        = getRefOption (mode' ,"mode")
      fun id ()          = getRefOption (id' ,"id")
      fun name ()        = getRefOption (name', "name'")
      fun database ()    = getRefOption (database', "database")
      fun logInterval () = getRefOption (logInterval', "logInterval'")
      fun size ()        = getRefOption (size', "size'")
      fun random ()      = getRefOption (random', "random")
      fun runRealTime () = getRefOption (realTime', "realTime")
      fun startDate ()   = getRefOption (startDate', "startDate") (* not public *)
      fun runTime ()     = getRefOption (runTime', "runTime") (* not public *)

       (* start & stop functions *)
      fun addStartFunction startFn =
         Ring.add (startFunctionList, Ring.wrap startFn)
(*          Event.scheduleAt (Event.new startFn, startDate ()) *)
      
      fun setStopFunction stopfn =
         Event.scheduleIn (Event.new stopfn, Time.+ (startDate (), runTime ()))
   end
