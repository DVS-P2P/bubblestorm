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

(* Make the simulator structures (e.g. Main, UDP) top-level and thus replace
   * the "real" implementations. *)

(* Main *)
structure Main :> MAIN = SimulatorMain
structure CommandLine = SimulatorCommandLine
structure Entropy = SimulatorEntropy
structure Time : TIME = Time (* remove realTime *)
structure Log = Log
structure SimultaneousDump = SimultaneousDump
structure Statistics = Statistics
structure TimelineStatistics = TimelineStatistics
structure Simulator = Simulator (* we've to expose this to call main () *)
structure NodeTrigger = NodeTrigger

(* UDP stack *)
structure UDP4 =
   UdpSim(
      InQueue(
         OutQueue(
            MessageRouter(
               NetworkModel
            )
         )
      )
   )

(* Globally used random number generator, retrieved from current node's context *)
fun getTopLevelRandom () = SimulatorNode.random (SimulatorNode.current ())

(* make log function globally available and override print function *)
open Log

(* global eventing, to be used for global knowledge processing *)
structure GlobalEvent = Experiment.Event
(* export experiment for simulator-specific operations (e.g., in PlanetPI4) *)
structure Experiment = Experiment
(* export simulator node to obtain current node ID (PlanetPI4) *)
structure SimulatorNode = SimulatorNode
