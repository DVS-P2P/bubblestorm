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

structure SimulatorMain :>
   sig
      include MAIN
      val start : unit -> unit
      val events : unit -> Int64.int
   end
=
   struct
      structure Main = Main (* the actual (not simulated) main of the runtime *)
      structure Event :> EVENT = NodeEvent (* makes events node-specific *)

      (* helper structure to keep track of the average time a simulator
       * event takes to execute. Used to adjust the number of events that
       * are executed per batch.
       *)
      structure EventStats =
         struct
            val totalEvents : Int64.int ref = ref 1
            val totalTime = ref (Time.fromMicroseconds 50)

            fun timePerEvent () = Time.divInt64 (!totalTime, !totalEvents)

            fun update (events, time) =
               (  totalEvents := !totalEvents + events
                  ; totalTime := Time.+ (!totalTime, time)
               )
         end

      fun events () = !EventStats.totalEvents

      datatype rehook = datatype SimulatorNode.rehook

      fun signal (signal, handler) = SimulatorNode.signal (SimulatorNode.current (), signal, handler)

      (* the time one batch of events should take. Between each batch the
       * realtime main loop is polled. The time an individual batch
       * actually takes to execute cannot be guaranteed.
       *)
      val executionTime = Time.fromMilliseconds 1

      fun executeEvents (count, executed) =
         if (count > 0 andalso NodeEvent.runNext ()) then
            executeEvents (count - 1, executed + 1)
         else executed
      val executeEvents = fn x => executeEvents (x, 0)

      fun simulateForAWhile () =
         let
            open Time
            val eventsToExecute = Int64.max (1, Time.div64 (executionTime, EventStats.timePerEvent ()))
            val now = Time.realTime ()
            val executedEvents = executeEvents eventsToExecute
         in
            EventStats.update (executedEvents, Time.realTime () - now)
         end

      val stopFlagRef = ref false

      fun simulate () =
         if !stopFlagRef
            then ()
         else
            case NodeEvent.nextEvent () of
               NONE => () (* no events to be processed *)
             | SOME _ =>
                  (  simulateForAWhile ()
                     ; Main.poll () (* check for real-world I/O events *)
                     ; simulate ()
                  )

      fun mainloop () =
         let
            val () = simulate () (* simulate until no more events available *)
            val () = if !stopFlagRef then () else Main.run ("simulator", fn _ => ()) (* will stop on horizon update *)
         in
            if !stopFlagRef
               then Experiment.closeDB () (* simulator is done *)
               (*then ()*)
            else mainloop () (* recursion *)
         end

      fun executeEventsRT' (until, executed) =
         let
            val nextEvent = NodeEvent.nextEvent ()
         in
            if isSome nextEvent
               andalso Time.< (valOf nextEvent, until)
               andalso NodeEvent.runNext ()
            then executeEventsRT' (until, executed + 1)
            else executed
         end
      fun executeEventsRT until = executeEventsRT' (until, 0)

      (* real-time simulation loop *)
      fun mainloopRT' () =
         let
            (* calculate initial simulation-to-real-time offset *)
            val timeOffset = Time.-(Main.Event.time (), valOf (NodeEvent.nextEvent ()))
(*            val () = TextIO.print ("mainloopRT Main.Event.time: " ^ Time.toString (Main.Event.time ())
               ^ " NodeEvent.nextEvent: " ^ Time.toString (valOf (NodeEvent.nextEvent ()))
               ^ " timeOffset: " ^ Time.toString timeOffset ^ "\n")*)
            (* maximum time interval to simulate 'into the future' *)
            val rtWindow = Time.fromMilliseconds 100
            fun simulate evt =
               let
                  val until = Time.+ (Time.- (Main.Event.time (), timeOffset), rtWindow)
(*                   val () = TextIO.print ("until: " ^ Time.toString until ^ "\n") *)
                  val executedEvents = executeEventsRT until
                  val () = EventStats.update (executedEvents, Time.zero)
(*                   val () = TextIO.print ("NodeEvent.nextEvent: " ^ Time.toString (valOf (NodeEvent.nextEvent ())) ^ "\n") *)
               in
                  Option.app
                  (fn t => Main.Event.scheduleAt (evt, Time.+ (t, timeOffset)))
                  (NodeEvent.nextEvent ())
               end
         in
            simulate (Main.Event.new simulate)
         end
      fun mainloopRT () =
         Main.run ("simulator", mainloopRT')

      fun start () =
         let
            (* print to log and console *)
            fun myPrint x = (GlobalLog.print x ; print x)
            val () = myPrint ("Simulation started at " ^ (Time.toString (Main.Event.time ())) ^ ".\n")

            val spinner = ref 0
            fun spin 0 = "|"
              | spin 1 = "/"
              | spin 2 = "-"
              | spin 3 = "\\"
              | spin _ = "?"
            val pad = ".000000000"
            fun status event =
               let
                  val time = Time.toString (Event.time ())
                  val pad = String.extract (pad, String.size time - 19, NONE)
                  fun print s = TextIO.output (TextIO.stdOut, s)
                  val () = print "\r"
                  val () = print time
                  val () = print pad
                  val () = print "  ...  "
                  val () = print (spin (!spinner mod 4))
                  val () = TextIO.flushOut TextIO.stdOut
                  val () = spinner := !spinner + 1
               in
                  Main.Event.scheduleIn (event, Time.fromMilliseconds 100)
               end

            val statusEvent = Main.Event.new status

            val () = Experiment.addStartFunction (fn _ =>
               Main.Event.scheduleIn (statusEvent, Time.fromSeconds 0)
            )

            (* Event to stop the simulator *)
            val () = Experiment.setStopFunction (fn _ =>
               let
                  val () = Main.Event.cancel statusEvent
                  val () = print "\r"
                  val () = myPrint ("Simulation stopped at " ^ (Time.toString (Main.Event.time ())) ^ ".\n")
                  val pad = CharVector.tabulate (19, fn _ => #" ")
                  val () = print pad
                  val () = myPrint "\n"
               in
                  stopFlagRef := true
               end
            )
         in
            (* start the simulator main loop *)
            if Experiment.runRealTime ()
            then mainloopRT ()
            else mainloop ()
         end

      (* pass the main function to the churn manager *)
      val run = ApplicationTable.add

      (* kill the current node *)
      val stop = SimulatorNode.destroy

   end
