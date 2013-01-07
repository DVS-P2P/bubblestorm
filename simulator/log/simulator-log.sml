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
val globalPrintBuffer = ref nil

structure GlobalLog =
   Log(
      structure Event = Experiment.Event
      structure Writer = SimulatorLogWriter
      val node = fn () => NONE
      val address = fn () => "global"
      val printBuffer = fn () => globalPrintBuffer
   )

structure Log =
   Log(
      structure Event = Experiment.Event
      structure Writer = SimulatorLogWriter
      val node = fn () => SOME ((SimulatorNode.id o SimulatorNode.current) ())
      val address = fn () => 
         case (SimulatorNode.currentAddress o SimulatorNode.current) () of
            SOME ip => Address.Ip.toString ip
          | NONE => "---"
      val printBuffer = SimulatorNode.printBuffer o SimulatorNode.current
   )

fun setLogFilters () =      
   let
      fun addFilter (module & level) =
         let
            val level = case LogLevels.fromInt level of
               SOME x => x
             | NONE => raise At ("simulator/log/simulator-log", Fail
                  ("Illegal log level (" ^ module ^ ", " ^ (Int.toString level) ^ ")"))
         in
            (Log.addFilter (module, level); GlobalLog.addFilter (module, level))
         end

      val experimentName = Experiment.name ()
      val database = Experiment.database ()

      open SQL.Query
      
      val filterQuery = prepare database
         "SELECT module, level FROM log_filters WHERE experiment="iS";" oS oI $
   in   
      SQL.app addFilter filterQuery experimentName
   end

   local
      (* log unhandled exception *)
      fun logException exn =
        let
           val history = MLton.Exn.history exn
           val (module, exn) =
              case exn of
                 At (module, exn) => (module, exn)
               | _ => ("simulator/unhandled-exception", exn)
           
           val stdErrMsg = "\nUNHANDLED EXCEPTION in " ^ module ^ ": " 
                           ^ (General.exnMessage exn) ^ "\n"
           val () = TextIO.output (TextIO.stdErr, stdErrMsg)
           val () = List.app (fn x => TextIO.output (TextIO.stdErr, "   " ^ x ^ "\n")) history
           val () = TextIO.flushOut TextIO.stdErr
           
           val msg = "UNHANDLED EXCEPTION: " ^ (General.exnMessage exn)
           fun log (lvl, msg) = Log.logExt (lvl, fn () => module, msg)
           val () = log (Log.ERROR, fn () => msg)
           
           val () = case history of
                       nil => ()
                     | _ => log (Log.ERROR, fn () => "Stack trace:")
           val () = List.app (fn x => log (Log.ERROR, fn () => "   " ^ x)) history
        in
           ()
        end
   in
      val () = SimulatorNode.exceptionLogger := logException
   end