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

structure Simulator :> SIMULATOR =
   struct
      datatype mode = datatype Experiment.mode
      
      fun init mode { database, experiment, realtime, id, idCount } = 
         let
            val () = Experiment.init { (* read base config *)
               mode = mode,
               database = database,
               experiment = experiment,
               realtime = realtime
            }
            (* speed up writing experiment setup to database *)
            val unlock = if mode = SLAVE then (fn () => ()) else Experiment.lockDB ()
            val () = Location.init () (* read node locations *)
            val () = Address.init () (* read DNS *)
            val () = SimulatorLogWriter.init () (* connect to database *)
            val () = SimultaneousDump.init () (* connect to database *)
            val () = setLogFilters () (* read filter settings *)
            val create = (mode = SINGLE) orelse (mode = SLAVE)
            val writeDB = (mode = SINGLE) orelse (mode = MASTER)
            val () = NodeGroup.init (idCount, id, create, writeDB) (* create nodes *)
            val () = Workload.init () (* read workload events *)
            val () = UdpStatistics.initUDP () (* set up statistics *)            
            val () = initStatistics () (* connect to database *)
            val () = initSimStatistics () (* set up statistics *)
            (* master has to temporarily release datbase so slaves can read config *)
            val () = if mode = MASTER then unlock () else ()
         in
            print "Simulator initialization complete\n"
         end
         
      fun startSingle (database, experiment, realtime) =
         let
            val () = print "Initializing single-threaded simulator\n"
            val () = init SINGLE {
               database = database,
               experiment = experiment,
               realtime = realtime,
               id = NONE,
               idCount = 1
            }
            val () = print "Starting single-threaded mode\n"
         in
            SimulatorMain.start ()
         end

      fun startMaster (parameters as { database, experiment, realtime, port=_, slaveCount }) =
         let
            val () = print "Initializing master\n"
            val () = init MASTER {
               database = database,
               experiment = experiment,
               realtime = realtime,
               id = NONE,
               idCount = slaveCount
            }
            val () = print "Starting master mode\n"
         in
            (* TODO: re-enable database lock after slave initialization *)
            Main.run ("simulator", fn () => PDES.startMaster parameters)
         end
      
      fun startSlave master =
         let
            fun initSlave parameters =
               let
                  val () = print "Initializing slave\n"
                  val () = init SLAVE parameters
                  val () = print "Starting slave mode\n"
               in
                  (* TODO: replace with call to slave main loop *)
                  SimulatorMain.start ()
               end
         in
            Main.run ("simulator", fn () => PDES.startSlave (master, initSlave))
         end
         
      fun main () =
         let
            val { mode, database, experiment, realtime, port, master, 
                  slaveCount } = Arguments.parse ()
         in
            case mode of
               SINGLE => startSingle (database, experiment, realtime)
             | SLAVE  => startSlave master
             | MASTER => startMaster {
                  database = database,
                  experiment = experiment,
                  realtime = realtime,
                  slaveCount = slaveCount,
                  port = port
               }
         end

      (* shutting down the simulator on ctrl-c *)
      val attempt = ref 0
      fun sigIntHandler () =
         if !attempt = 0 then
            let
               fun done () = 
                  let
                     val () = print "\nTerminating...\n"
                     (*val () = CUSP.EndPoint.destroy cusp*)
                     val () = Experiment.closeDB ()
                     (*val () = Main.stop ()*)
                  in
                     ()
                  end
               val () = attempt := !attempt + 1
               val () = GlobalLog.print "User interrupt! -- attempting to quit.\n"
               (*val _ = CUSP.EndPoint.whenSafeToDestroy (cusp, done)*)
               val () = done ()
            in
               Main.REHOOK
            end
         else
            let
               val () = Main.stop ()
               val () = GlobalLog.print "FORCED TO QUIT UNCLEANLY.\n"
            in
               Main.REHOOK
            end
   
      val () = ignore (Main.signal (Posix.Signal.int, sigIntHandler))
   end
