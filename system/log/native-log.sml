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

(* create logger and set filters *)
val module = "system/native-log"

(* enable asynchronous database operation *)
val flushInterval = Time.fromMilliseconds 10000
val unlockDB = case ConfigCommandLine.logDatabase () of
            ConfigCommandLine.STDOUT => (fn () => ())
          | ConfigCommandLine.SQLITE database =>
            let
               open SQL.Query
               val settingsQuery = prepare database
                  "PRAGMA synchronous=OFF; PRAGMA temp_store=MEMORY;" $
               val () = SQL.exec settingsQuery ()
               val startTransaction = prepare database "BEGIN IMMEDIATE TRANSACTION;" $
               val commit = prepare database "COMMIT;" $
         
               fun forceRetry count statement parameters =
                 SQL.exec statement parameters
                 handle (x as SQL.Retry _) =>
                    if count <= 0 then raise x else
                    (OS.Process.sleep (SMLTime.fromMilliseconds 10);
                     forceRetry (count - 1) statement parameters)
         
               fun flushDatabase event =
                  let
                     val () = forceRetry 100 commit ()
                     val () = forceRetry 100 startTransaction ()
                  in
                     Main.Event.scheduleIn (event, flushInterval)
                  end
         
               val flush = Main.Event.new flushDatabase
               val () = Main.Event.scheduleIn (flush, flushInterval)
               val () = SQL.exec startTransaction ()
            in
               (fn () =>
                  let
                     val () = Main.Event.cancel flush
                  in
                     forceRetry 100 commit ()
                  end)
            end
val _ = Main.signal (Posix.Signal.int, fn () => ( unlockDB () ; Main.UNHOOK ))



(* switch between stdout and database depending on command line parameters *)
structure LogWriter :> LOG_WRITER =
   struct
      datatype logMode = datatype ConfigCommandLine.logMode
      
      fun logDB () = 
         case ConfigCommandLine.logDatabase () of
            SQLITE db => db
          | STDOUT => (* unreachable code *) raise At (module, 
           Fail "Trying to initialize log database that has not been configured")
   
      structure SqlWriter =
         SQLiteWriter(
            val experiment = ConfigCommandLine.experimentID
            val database = logDB
         )
      
      fun init () =
         case ConfigCommandLine.logDatabase () of
            SQLITE _ => SqlWriter.init ()
          | STDOUT => StdoutWriter.init ()
      
      fun write parameters =
         case ConfigCommandLine.logDatabase () of
            SQLITE _ => SqlWriter.write parameters
          | STDOUT => StdoutWriter.write parameters
   end   

val localPrintBuffer = ref nil

structure Log = 
   Log(
      structure Event = Main.Event
      structure Writer = LogWriter
      val node = ConfigCommandLine.nodeID
      val address = ConfigCommandLine.nodeAddress
      val printBuffer = fn () => localPrintBuffer
   )

val () = LogWriter.init ()

(* set filters from the command line arguments *)
val () = List.app Log.addFilter (ConfigCommandLine.logFilters ())

(* set filters from the log database *)
val () = case ConfigCommandLine.logDatabase () of
   ConfigCommandLine.STDOUT => ()
 | ConfigCommandLine.SQLITE database =>
      let
         fun addFilter (module & level) =
            let
               val level = case LogLevels.fromInt level of
                  SOME x => x
                  | NONE => raise At (module, Fail
                     ("Illegal log level (" ^ module ^ ", " ^ (Int.toString level) ^ ")"))
            in
               Log.addFilter (module, level)
            end
      
         open SQL.Query
         
         val filterQuery = prepare database
            "SELECT module, level FROM log_filters;" oS oI $
      in   
         SQL.app addFilter filterQuery ()
      end

structure CommandLine = ConfigCommandLine :> COMMAND_LINE

local
   (* log unhandeled events before passing them to the usual system handler *)
   fun handleException defaultHandler exn =
      let
         val (module, exn') =
            case exn of
               At (module, exn') => (module, exn')
             | _                 => ("---", exn)
         fun log msg = Log.logExt (Log.ERROR, fn () => module, fn () => msg)     
         val () = log ("UNHANDLED EXCEPTION: " ^ (General.exnMessage exn'))
         
         val history = MLton.Exn.history exn
         val () = if List.null history then () else log "Stack trace:"
         val () = List.app (fn x => log ("   " ^ x)) history
         val () = unlockDB ()
      in
         defaultHandler exn
      end
   
   val defaultHandler = MLton.Exn.getTopLevelHandler ()
in
   val () = case ConfigCommandLine.logDatabase () of
               ConfigCommandLine.STDOUT => ()
             | ConfigCommandLine.SQLITE database =>
                  MLton.Exn.setTopLevelHandler (handleException defaultHandler)
end
