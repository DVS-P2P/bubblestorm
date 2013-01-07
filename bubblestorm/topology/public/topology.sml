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

structure Topology :> TOPOLOGY =
   struct
      type t = state
      
      fun new { endpoint, desiredDegree, hostCache, foundBootstrapHandler } =
         let
            val this = ref NONE
            val hooks = Vector.tabulate (0, fn _ => raise Domain)
            val evaluate  = fn l  => evaluate  (valOf (!this)) l
            (* evaluateN should always be called as a separate event 1ns later.
             * This ensures that all state transitions haven taken place.
             * Evaluating intermediate states could lead to wrong actions.
             * Also, this guarantees that evaluateN is only executed once for
             * all related transitions (there's only one event).
             *)
            val evalNEvent = Main.Event.new (fn _ => evaluateN (valOf (!this)) ())
            fun evaluateN () = Main.Event.scheduleIn (evalNEvent, Time.fromNanoseconds 1)

            val out =
               STATE {
                  endpoint = endpoint,
                  locations = 
                     Locations.new {
                        desiredDegree = desiredDegree,
                        eval1 = evaluate,
                        evalN = evaluateN
                     },
                  oracle = hostCache,
                  cache = ref NONE,
                  gossip = ref (MEASUREMENTS nil),
                  clients = Clients.new evaluateN,
                  hooks = ref hooks,
                  bubblecaster = ref NONE,
                  onJoin = Ring.new (),
                  onLeave = Ring.new (),
                  onFoundBootstrap = foundBootstrapHandler,
                  networkSize = ref 1000000.0
               }
            val () = this := SOME out
         in
            out
         end
         
      fun addMeasurement (state, measurement) =
         let
            val STATE { gossip, ... } = state
            val measurements = case !gossip of
               MEASUREMENTS x => x
             | GOSSIP _ => raise Fail "topology already initialized" 
         in
            gossip := MEASUREMENTS (measurement :: measurements)
         end
      
      fun addOnJoinHandler (state, handler) =
         let
            val STATE { onJoin, ... } = state
            val elem = Ring.wrap handler
            val () = Ring.add (onJoin, elem)
         in
            fn () => Ring.remove elem
         end
         
      fun addOnLeaveHandler (state, handler) =
         let
            val STATE { onLeave, ... } = state
            val elem = Ring.wrap handler
            val () = Ring.add (onLeave, elem)
         in
            fn () => Ring.remove elem
         end
         
      fun init (STATE { gossip, ... }) =
         case !gossip of
            MEASUREMENTS measurements =>
               let
                  val gossips = map (Gossip.new o Measurement.make) measurements
                  val allGossips = Vector.fromList gossips
               in
                  gossip := GOSSIP allGossips
               end
          | GOSSIP _ => () (* already initialized *)
            
      val create = fn (state, addr, cb) => 
         let
            val () = init state
            val STATE { locations, ... } = state
            datatype y = datatype Locations.progress
            datatype z = datatype Locations.goal
         in
            case Locations.goal locations of
               LEAVE (COMPLETE _) => create state addr cb
             | _ => raise Fail "create called on running topology"
         end
      
      fun join (state, cb) = 
         let
            val () = init state
            val STATE { locations, clients, ... } = state
            datatype y = datatype Locations.progress
            datatype z = datatype Locations.goal
            
            val now = Main.Event.time ()
            fun cb' () =
               let
                  val delay = Time.- (Main.Event.time (), now)
                  val () = Statistics.add Stats.topologyJoinTime (Time.toSecondsReal32 delay)
               in
                  cb ()
               end
            
            val () = Clients.allowClients clients
            fun noop () = ()
         in
            case Locations.goal locations of
               JOIN _   => raise Fail "join while not leaving"
             | LEAVE (IN_PROGRESS _)  => (Locations.setGoal (locations, JOIN (IN_PROGRESS noop)); cb' ())
             | LEAVE (COMPLETE _)  => (Locations.setGoal (locations, JOIN (IN_PROGRESS cb')))
         end
      
      fun leave (state, cb) =
         let
            val STATE { locations, onLeave, ... } = state
            datatype y = datatype Locations.progress
            datatype z = datatype Locations.goal
            val now = Main.Event.time ()
            fun cb' () =
               let
                  val delay = Time.- (Main.Event.time (), now)
                  val () = Statistics.add Stats.topologyLeaveTime (Time.toSecondsReal32 delay)
               in
                  cb ()
               end
         in
            case Locations.goal locations of
               LEAVE _ => raise Fail "leave while not joining"
             | JOIN _  =>
               let
                  val () = flushClients state ()
                  val () = Locations.setGoal (locations, LEAVE (IN_PROGRESS cb'))
                  (* execute leave handlers *)
                  val () = Ring.app (fn x => (Ring.unwrap x) ()) onLeave
               in
                  ()
               end
         end
      
      fun address (STATE { locations, ... }) = Locations.localAddress locations

      fun endpoint (STATE { endpoint, ... }) = endpoint
      
      fun desiredDegree (STATE { locations, ... }) = Locations.desiredDegree locations

      type bubblecaster = bubblecaster
      
      fun setBubblecastHandler (STATE {bubblecaster, ...}, handler) =
         bubblecaster := SOME handler

      val bubblecast = fn (topology, {typ, seed, size, start, stop, payload}) =>
         bubblecast topology typ seed size start stop payload      
      
      fun setNetworkSize (STATE {networkSize, ...}, size) =
         networkSize := size
      
      (* TODO: get mindegree from config everywhere *)
      val minimumDegree = Config.minDegree
   end

structure Measurement 
   :> MEASUREMENT where type Real.real = Measurement.Real.real
                  where type t = Measurement.t
   = Measurement
