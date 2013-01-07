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

structure Arguments :> ARGUMENTS =
   struct
      fun usage () =
         print "BubbleStorm simulator. Usage: simulator [options]\n\
         \ Available options are:\n\
         \   -m [--mode] ARG        available modes are single, master, and slave\n\
         \   -d [--database] ARG    the filename of the database for the experiment\n\
         \   -e [--experiment] ARG  the name of the experiment to execute\n\
         \   -r [--realtime]        enables real-time simulation slow-down\n\
         \   -p [--port] ARG        the listen port (only for master mode)\n\
         \   -# [--slaves] ARG      the number of slave processes (only for master)\n\
         \   -@ [--connect] ARG     address/port of master (only for slave mode)\n\
         \   -h [-?] [--help]       print this message\n\
         \\n\
         \default values are: -m single -d simulator.db -p 8585 -# 1 -@ localhost:8585\n"

      fun help () = ( usage () ; ignore (OS.Process.exit OS.Process.success) )

      fun die () = ( usage () ; OS.Process.exit OS.Process.failure )
                
      fun complain msg =
         let
            val () = print (msg ^ ". Try -h for help.\n")
         in
            OS.Process.exit OS.Process.failure
         end
      
      fun parse () =
         let
            val mode = ref Experiment.SINGLE
            val database = ref "simulator.db"
            val experiment = ref ""
            val realtime = ref false
            val port = ref 8585
            val master = ref "localhost:8585"
            val slaveCount = ref 1
            
            fun setMode "single" = mode := Experiment.SINGLE
              | setMode "master" = mode := Experiment.MASTER
              | setMode "slave" = mode  := Experiment.SLAVE
              | setMode x = complain ("\"" ^ x  ^ "\" is not a valid mode")
            fun setDatabase x = database := x
            fun setExperiment x = experiment := x
            fun setRealtime () = realtime := true
            fun setPort x =
               case Int.fromString x of
                  SOME y => port := y
                | NONE => complain ("\"" ^ x ^ "\" is not a valid port number")
            fun setMaster x = master := x
            fun setSlaveCount x =
               case Int.fromString x of
                  SOME y => if y > 0 then slaveCount := y
                     else complain "try a positive number of slave processes"
                | NONE => complain ("\"" ^ x ^ "\" is not a valid number of slave processes")

            fun parseRecursively (optionName, arguments) =
               let
                  fun fetchParameter (setter : string -> unit, args) =
                     ( setter (hd args) ; tl args )
                     handle Empty => complain ("Parameter missing for option \"" ^ optionName ^ "\"")
                  
                  val arguments = case optionName of
                     "--mode" => fetchParameter (setMode, arguments)
                   | "-m" => fetchParameter (setMode, arguments)
                   | "--database" => fetchParameter (setDatabase, arguments)
                   | "-d" => fetchParameter (setDatabase, arguments)
                   | "--experiment" => fetchParameter (setExperiment, arguments)
                   | "-e" => fetchParameter (setExperiment, arguments)
                   | "--realtime" => ( setRealtime () ; arguments )
                   | "-r" => ( setRealtime () ; arguments )
                   | "--port" => fetchParameter (setPort, arguments)
                   | "-p" => fetchParameter (setPort, arguments)
                   | "--connect" => fetchParameter (setMaster, arguments)
                   | "-@" => fetchParameter (setMaster, arguments)
                   | "--slaves" => fetchParameter (setSlaveCount, arguments)
                   | "-#" => fetchParameter (setSlaveCount, arguments)
                   | "--help" => ( help () ; arguments )
                   | "-h" => ( help () ; arguments )
                   | "-?" => ( help () ; arguments )
                   | _ => complain ("Unknown parameter \"" ^ optionName ^ "\"")
               in
                  case arguments of
                     head :: tail => parseRecursively (head, tail)
                   | nil => {
                        mode = !mode,
                        database = !database,
                        experiment = !experiment,
                        realtime = !realtime,
                        port = !port,
                        master = !master,
                        slaveCount = !slaveCount
                     }
               end
         in
            case CommandLine.arguments () of
               head :: tail => parseRecursively (head, tail)
               | nil => die ()
         end
   end
