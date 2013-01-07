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

fun initSimStatistics () =
	let
      fun pollStatistics (name, units, poll) =
         let
            val stat = Statistics.new {
               parents = nil,
               name = "simulator/" ^ name,
               units = units,
               label = name,
               histogram = Statistics.NO_HISTOGRAM,
               persistent = true
            }
         in
            Statistics.addPoll (stat, poll stat)
         end

      (* number of simulator events executed per log interval *)
      val oldEvents = ref 0
      fun poll stat () =
         let
            val curEvents = SimulatorMain.events ()
            val events = curEvents - !oldEvents
            val realEvents = Real32.fromLargeInt (Int64.toLarge events)
            val () = Statistics.add stat realEvents
         in
            oldEvents := curEvents
         end  
      val () = pollStatistics ("events executed", "#", poll)

      (* memory usage in bytes *)
      val () = pollStatistics ("memory usage", "bytes", fn stat => fn () =>
         Statistics.add stat (Real32.fromLargeInt (MLton.GC.Statistics.lastBytesLive ()))
      )

      (* speed of the simulator compared to real-time *)
      val oldRealtime = ref (Time.realTime ())
      val oldSimtime = ref (Experiment.Event.time ())
      fun computeSpeed () =
         let
            open Time
            val newRealtime = realTime ()
            val newSimtime = Experiment.Event.time ()
            val speed = 
                  (toSecondsReal32 (newSimtime - (!oldSimtime))) /
                  (toSecondsReal32 (newRealtime - (!oldRealtime)))
            val () = oldRealtime := newRealtime
            val () = oldSimtime := newSimtime
         in
            speed
         end
      val () = pollStatistics ("speed", "simulated/real time", fn stat => fn () =>
         Statistics.add stat (computeSpeed ())
      )
      (* initialize timers correctly to avoid initial peak *)
      val () = Experiment.addStartFunction (fn _ => ignore (computeSpeed ()))

      (* number of total nodes in the experiment *)
      (*val () = pollStatistics ("total nodes", "#", fn stat => fn () =>
         Statistics.add stat (Real32.fromInt (SimulatorNode.totalNodes ()))
      )*)

      (* number of active nodes in the experiment *)
      val () = pollStatistics ("active nodes", "#", fn stat => fn () =>
         Statistics.add stat (Real32.fromInt (SimulatorNode.activeNodes ()))
      )

      (* number of online nodes in the experiment *)
      val () = pollStatistics ("online nodes", "#", fn stat => fn () =>
         Statistics.add stat (Real32.fromInt (SimulatorNode.onlineNodes ()))
      )
   
      (* number of running nodes in the experiment *)
      val () = pollStatistics ("running nodes", "#", fn stat => fn () =>
         Statistics.add stat (Real32.fromInt (SimulatorNode.runningNodes ()))
      )

      (* calls to the experiment's global random number generator *)
      val () = pollStatistics ("global random calls", "#", fn stat => fn () =>
         Statistics.add stat (Real32.fromInt (Random.callCount (Experiment.random ())))
      )
   in
   	()
   end
