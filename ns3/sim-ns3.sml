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

local
   (* C exports utils *)
   type ptr = MLton.Pointer.t
   fun getString (ptr : ptr, len : int) : string =
      CharVector.tabulate
      (len, fn i => Byte.byteToChar (MLton.Pointer.getWord8 (ptr, i)))
   fun getStrings (ptr : ptr, lens : ptr, len : int) : string list =
      let
         fun mk i =
            getString (MLton.Pointer.getPointer (ptr, i), MLton.Pointer.getInt32 (lens, i))
      in
         List.tabulate (len, mk)
      end
in
   (* log support *)
   structure Log = 
      NodeLog(
         structure Event = SimulatorMain.Event
         structure Writer = StdoutNodeWriter
      )
   (* GlobalLog *)
   val globalPrintBuffer = ref nil (* TODO? *)
   structure GlobalLog =
      Log(
         structure Event = SimulatorMain.Event
         structure Writer = StdoutWriter
         val node = fn () => NONE
         val address = fn () => "global"
         val printBuffer = fn () => globalPrintBuffer
      )
   (* add log filter command line support *)
(*    structure CommandLine = LogCommandLine(Log) *)
   (* export log filter function *)
   local
      fun logAddFilter (modulePtr, moduleLen, level) =
         let
            val module = getString (modulePtr, moduleLen)
            val level = valOf (LogLevels.fromInt level)
         in
            Log.addFilter (module, level)
         end
   in
      val () = _export "bs_log_add_filter" : (ptr * int * int -> unit) -> unit; logAddFilter
   end
   (* make log function globally available and override print function *)
   open Log

   structure Main :> MAIN = SimulatorMain
   structure SimulatorMain = SimulatorMain
   structure CommandLine = SimulatorCommandLine
   (* structure Entropy = SimulatorEntropy *)
   structure Time : TIME = Time (* remove realTime *)
   structure UDP4 = NodeUdp

   (* random -- FIXME proper per-node random *)
   val random = Random.new ((*Random.word32 (random, NONE)*)0w42)
   fun getTopLevelRandom () = (*SimulatorNode.random (SimulatorNode.current ())*) random

   (* statistics *)
   local
      structure StatisticsHelper :> STATISTICS_HELPER =
         struct
            fun nodeID () =
               case Node.currentNodeOpt () of
                  SOME node => Node.id node
               | NONE => ~1
            fun setNodeContext collect = collect
            fun setCleanup action =
               case Node.currentNodeOpt () of
                  SOME node => ignore (Node.addCleanupFunction (node, action))
               | NONE => ()
         end
      structure StatsWriter = StatisticsStdout(Main.Event)
   in
      structure Statistics =
         Statistics(
            structure Helper = StatisticsHelper
            structure Writer = StatsWriter
            structure Event = SimulatorMain.Event
         )
   end
   local
      fun statisticsLogInterval intervalNs =
         Statistics.setLogInterval (Time.fromNanoseconds64 intervalNs)
   in
      val () = _export "bs_statistics_log_interval" : (Int64.int -> unit) -> unit; statisticsLogInterval
   end

   (* start/stop C function exports *)
   local
      fun startApp (appContext, id, namePtr, nameLen, argPtr, argLens, argLen) =
         let
            val name = getString (namePtr, nameLen)
            val appMain = SimulatorMain.getApp name
            val args = getStrings (argPtr, argLens, argLen)
         in
            case appMain of
               SOME appMain => Node.start (appContext, id, appMain, name, args)
               | NONE => raise Fail ("App does not exist: " ^ name)
         end
      
      fun stopApp appHandle =
         Node.stop appHandle
   in
      val () = _export "bs_app_start" : (ptr * int * ptr * int * ptr * ptr * int -> int) -> unit; startApp
      val () = _export "bs_app_stop" : (int -> bool) -> unit; stopApp
   end
end
