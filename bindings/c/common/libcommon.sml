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

(* Common SML glue code for c-bindings *)

(* -------------------- *
 *  Definitions, setup  *
 * -------------------- *)

type ptr = MLton.Pointer.t

structure Event = Main.Event


(* Handle buckets *)
val eventBucket : Event.t IdBucket.t = IdBucket.new()
val abortableBucket : (unit -> unit) IdBucket.t = IdBucket.new()
val statisticsBucket : Statistics.t IdBucket.t = IdBucket.new()
val simultaneousDumpBucket : SimultaneousDump.t IdBucket.t = IdBucket.new()
val exceptionBucket = IdBucket.new ()

fun bucketOps bucket =
   let
      fun dup id =
         case IdBucket.sub (bucket, id) of
            SOME x => IdBucket.alloc (bucket, x)
          | NONE => ~1
      fun free id =
         (IdBucket.free (bucket, id); true) handle
            IdBucket.AlreadyFree => false
   in
      (dup, free)
   end

(* Bucket statistics (optional, for debugging) *)

(*fun makeBucketStat name =
   Statistics.new {
      parents = nil,
      name = "bindings/bucket/" ^ name,
      units = "",
      label = name ^ " bucket id",
      histogram = Statistics.NO_HISTOGRAM,
      persistent = true
   }*)
fun makeBucketStat _ = ()

(*fun bucketStat (id, stat) =
   (if id >= 0 then Statistics.add stat (Real32.fromInt id) else ()
   ; id)*)
fun bucketStat (id, _) = id

val statIdBucketEvent = makeBucketStat "event"
val statIdBucketAbortable = makeBucketStat "abortable"
val statIdBucketStatistics = makeBucketStat "statistics"


(* Internal helper functions *)

val nanReal32 : Real32.real = 0.0/0.0

val nullString = ""
val nullData = Word8Vector.tabulate (0, fn _ => 0w0)

fun returnBool false = 0
 |  returnBool true  = 1

fun returnString (SOME str, strLen) =
   (MLton.Pointer.setInt32 (strLen, 0, Int32.fromInt (String.size str))
   ; str)
 |  returnString (NONE, strLen) =
   (MLton.Pointer.setInt32 (strLen, 0, Int32.fromInt (~1))
   ; nullString)

fun getString (ptr : ptr, len : int) : string =
   CharVector.tabulate
   (len, fn i => Byte.byteToChar (MLton.Pointer.getWord8 (ptr, i)))

fun returnDataVector (SOME data, dataLen) =
   (MLton.Pointer.setInt32 (dataLen, 0, Int32.fromInt (Word8Vector.length data))
   ; data)
 |  returnDataVector (NONE, dataLen) =
   (MLton.Pointer.setInt32 (dataLen, 0, Int32.fromInt (~1))
   ; nullData)

fun getDataVector (data : ptr, len : int) : Word8Vector.vector =
   Word8Vector.tabulate (len, fn i => MLton.Pointer.getWord8 (data, i))

(* Returning stings from C helper *)

local
   val returnedString = ref ""
in
   fun returnStringFromC (strPtr : ptr, strLen: int) : unit =
      returnedString := getString (strPtr, strLen)
   
   fun getReturnedString () =
      let
         val s = !returnedString
         val () = returnedString := ""
      in
         s
      end
end


(* Exception handling helpers *)

(* Common function (error) return values:
 * Int
 *   >=0: success
 *   ~1: invalid input parameters (invalid handle)
 *   ~2: no return value (success)
 *   ~3: exception
 * Real32:
 *   <>NaN: success
 *   NaN: failure or exception (check lastException >= 0)
 * Bool (should be used only for bucket ops):
 *   true: success
 *   false: failure or exception (check lastException >= 0)
 *)

val lastExceptionHandle = ref ~1

fun handleException (function, errReturn) params =
   let
      val () = lastExceptionHandle := ~1
   in
      function params
      handle exn =>
         (lastExceptionHandle := IdBucket.alloc (exceptionBucket, exn)
         ; errReturn)
   end
fun handleExceptionInt function = handleException (function, ~3)
fun handleExceptionInt64 function = handleException (function, ~3)
fun handleExceptionReal32 function = handleException (function, nanReal32)
fun handleExceptionString (function, outLen) params =
   let (* for strings and data, exceptions are indicated by outLen=~3 *)
      val res = handleException (function, nullString) params
      val () =
         if (!lastExceptionHandle >= 0)
         then MLton.Pointer.setInt32 (outLen, 0, Int32.fromInt (~3))
         else ()
   in
      res
   end
fun handleExceptionData (function, outLen) params =
   let (* for strings and data, exceptions are indicated by outLen=~3 *)
      val res = handleException (function, nullData) params
      val () =
         if (!lastExceptionHandle >= 0)
         then MLton.Pointer.setInt32 (outLen, 0, Int32.fromInt (~3))
         else ()
   in
      res
   end


(* -------------------- *
 *  Exported functions  *
 * -------------------- *)

(* --- Exceptions --- *)

fun lastException () : int = !lastExceptionHandle

fun exceptionName (exnHandle : int, strLen : ptr) : string =
   case IdBucket.sub (exceptionBucket, exnHandle) of
      SOME exn => returnString (SOME (exnName exn), strLen)
    | NONE => returnString (NONE, strLen)

fun exceptionMessage (exnHandle : int, strLen : ptr) : string =
   case IdBucket.sub (exceptionBucket, exnHandle) of
      SOME exn =>
         let
            val history = MLton.Exn.history exn
            val lines = 
               if List.null history
               then [ exnMessage exn ]
               else exnMessage exn :: "\nTrace:" :: List.map (fn x => "\n  " ^ x) history
            val msg = String.concat lines
         in
            returnString (SOME msg, strLen)
         end
    | NONE => returnString (NONE, strLen)

val (exceptionDup, exceptionFree) = bucketOps exceptionBucket


(* --- Time --- *)

fun timeFromString (strPtr : ptr, strLen : int) : Int64.int =
   case Time.fromString (getString (strPtr, strLen)) of
      SOME t => Time.toNanoseconds64 t
    | NONE => ~1
val timeFromString = handleExceptionInt64 timeFromString

fun timeToString' (time : Int64.int, strLen : ptr) : string =
   returnString (SOME (Time.toString (Time.fromNanoseconds64 time)), strLen)
fun timeToString (time, strLen) = handleExceptionString (timeToString', strLen) (time, strLen)

fun timeToAbsoluteString' (time : Int64.int, strLen : ptr) : string =
   returnString (SOME (Time.toAbsoluteString (Time.fromNanoseconds64 time)), strLen)
fun timeToAbsoluteString (time, strLen) = handleExceptionString (timeToAbsoluteString', strLen) (time, strLen)

fun timeToRelativeString' (time : Int64.int, strLen : ptr) : string =
   returnString (SOME (Time.toRelativeString (Time.fromNanoseconds64 time)), strLen)
fun timeToRelativeString (time, strLen) = handleExceptionString (timeToRelativeString', strLen) (time, strLen)


(* --- Event --- *)

fun eventTime () : Int64.int =
   Time.toNanoseconds64 (Event.time ())
val eventTime = handleExceptionInt64 eventTime


fun eventNew (cb : ptr, cbData : ptr) : int =
   let
      val eventCallbackP = _import * : ptr -> int * ptr -> unit;
      fun eventCallback (evt : Event.t) =
         (eventCallbackP cb) (bucketStat (IdBucket.alloc (eventBucket, evt), statIdBucketEvent), cbData)
   in
      bucketStat (IdBucket.alloc (eventBucket, Event.new (eventCallback)), statIdBucketEvent)
   end
val eventNew = handleExceptionInt eventNew


fun eventScheduleAt (eventHandle : int, time : Int64.int) : int =
   let
      val t = Time.fromNanoseconds64 time;
   in
      case IdBucket.sub (eventBucket, eventHandle) of
         SOME event => (Event.scheduleAt (event, t); 0)
       | NONE => ~1
   end
val eventScheduleAt = handleExceptionInt eventScheduleAt


fun eventScheduleIn (eventHandle : int, time : Int64.int) : int =
   let
      val t = Time.fromNanoseconds64 time;
   in
      case IdBucket.sub (eventBucket, eventHandle) of
         SOME event => (Event.scheduleIn (event, t); 0)
       | NONE => ~1
   end
val eventScheduleIn = handleExceptionInt eventScheduleIn


fun eventCancel (eventHandle : int) : int =
   case IdBucket.sub (eventBucket, eventHandle) of
      SOME event => (Event.cancel (event); 0)
    | NONE => ~1
val eventCancel = handleExceptionInt eventCancel


fun eventTimeOfExecution (eventHandle : int) : Int64.int =
   case IdBucket.sub (eventBucket, eventHandle) of
      SOME event =>
         (case Event.timeOfExecution (event) of
            SOME time => Time.toNanoseconds64 (time)
            | NONE => Int64.fromInt (~2)
         )
    | NONE => Int64.fromInt (~1)
val eventTimeOfExecution = handleExceptionInt64 eventTimeOfExecution


fun eventTimeTillExecution (eventHandle : int) : Int64.int =
   case IdBucket.sub (eventBucket, eventHandle) of
      SOME event =>
         (case Event.timeTillExecution (event) of
            SOME time => Time.toNanoseconds64 (time)
          | NONE => Int64.fromInt (~2)
         )
    | NONE => Int64.fromInt (~1)
val eventTimeTillExecution = handleExceptionInt64 eventTimeTillExecution


fun eventIsScheduled (eventHandle : int) : int =
   case IdBucket.sub (eventBucket, eventHandle) of
      SOME event => if Event.isScheduled event then 1 else 0
    | NONE => ~1
val eventIsScheduled = handleExceptionInt eventIsScheduled


val (eventDup, eventFree) = bucketOps eventBucket


(* --- Abortable --- *)

fun abortableAbort (abortableHandle : int) : int =
   case IdBucket.sub (abortableBucket, abortableHandle) of
      SOME abort => (abort (); 0)
      | NONE => ~1
val abortableAbort = handleExceptionInt abortableAbort

val (abortableDup, abortableFree) = bucketOps abortableBucket


(* --- Log --- *)

fun logLog (severityInt : int, modulePtr : ptr, moduleLen : int,
      msgPtr : ptr, msgLen : int) : int =
   let
      val severity = LogLevels.fromInt severityInt
      val module = getString (modulePtr, moduleLen)
      fun msg () = getString (msgPtr, msgLen)
   in
      case severity of
         SOME s => (Log.log (s, module, msg); 0)
       | NONE => ~1
   end
val logLog = handleExceptionInt logLog

fun logAddFilter (modulePtr : ptr, moduleLen : int, severityInt : int) : int =
   let
      val module = getString (modulePtr, moduleLen)
      val severity = LogLevels.fromInt severityInt
   in
      case severity of
         SOME s => (Log.addFilter (module, s); 0)
       | NONE => ~1
   end
val logAddFilter = handleExceptionInt logAddFilter

fun logRemoveFilter (modulePtr : ptr, moduleLen : int) : int =
   let
      val module = getString (modulePtr, moduleLen)
   in
      (Log.removeFilter module; 0)
   end
val logRemoveFilter = handleExceptionInt logRemoveFilter


(* --- Statistics --- *)

fun statisticsNew (namePtr : ptr, nameLen : int,
      unitPtr : ptr, unitLen : int,
      parentHandle : int, parentMode : int,
      histogramMode : int, histogramParam : Real32.real,
      persistent : bool) : int =
   let
      fun agg 0 = Statistics.min
       |  agg 1 = Statistics.max
       |  agg 2 = Statistics.sum
       |  agg 3 = Statistics.avg
       |  agg 4 = Statistics.stdDev
       |  agg _ = (fn _ => 0.0)
      val parents =
         if parentHandle >= 0
         then
            case IdBucket.sub (statisticsBucket, parentHandle) of
               SOME parent => SOME [(parent, Statistics.distill (agg parentMode))]
             | NONE => NONE 
         else SOME nil
      val hist =
         case histogramMode of
            0 => Statistics.NO_HISTOGRAM
          | 1 => Statistics.FIXED_BUCKET histogramParam
          | 2 => Statistics.EXPONENTIAL_BUCKET histogramParam
          | _ => Statistics.NO_HISTOGRAM
   in
      case parents of
         SOME parents =>
            bucketStat (IdBucket.alloc (statisticsBucket,
               Statistics.new {
                  parents = parents,
                  name = getString (namePtr, nameLen),
                  units = getString (unitPtr, unitLen),
                  label = getString (namePtr, nameLen),
                  histogram = hist,
                  persistent = persistent
               }), statIdBucketStatistics)
       | NONE => ~1
   end
val statisticsNew = handleExceptionInt statisticsNew

fun statisticsAddPoll (statHandle : int, cb : ptr, cbData : ptr) =
   let
      val pollP = _import * : ptr -> ptr -> unit;
      fun poll () = (pollP cb) cbData
   in
      case IdBucket.sub (statisticsBucket, statHandle) of
         SOME stat => (Statistics.addPoll (stat, poll); 0)
       | NONE => ~1
   end
val statisticsAddPoll = handleExceptionInt statisticsAddPoll

fun statisticsAdd (statHandle : int, value : Real32.real) : int =
   case IdBucket.sub (statisticsBucket, statHandle) of
      SOME stat => (Statistics.add stat value; 0)
    | NONE => ~1
val statisticsAdd = handleExceptionInt statisticsAdd

val (statisticsDup, statisticsFree) = bucketOps statisticsBucket


(* --- SimultaneousDump --- *)

fun simultaneousDumpNew (namePtr : ptr, nameLen : int,
      headerPtr : ptr, headerLen : int,
      footerPtr : ptr, footerLen : int,
      interval : Int64.int) : int =
   let
      val name = getString (namePtr, nameLen)
      val header = getString (headerPtr, headerLen)
      val footer = getString (footerPtr, footerLen)
      val interval = Time.fromNanoseconds64 interval
   in
      IdBucket.alloc (simultaneousDumpBucket,
         SimultaneousDump.new (name, header, footer, interval))
   end
val simultaneousDumpNew = handleExceptionInt simultaneousDumpNew

fun simultaneousDumpAddDumper (sdHandle : int, cb : ptr, cbData : ptr) =
   let
      val dumpP = _import * : ptr -> ptr -> unit;
      fun dump () = ((dumpP cb) cbData; getReturnedString ())
   in
      case IdBucket.sub (simultaneousDumpBucket, sdHandle) of
         SOME sd => (SimultaneousDump.addDumper (sd, dump); 0)
       | NONE => ~1
   end
val simultaneousDumpAddDumper = handleExceptionInt simultaneousDumpAddDumper

val (simultaneousDumpDup, simultaneousDumpFree) = bucketOps simultaneousDumpBucket


(* --------- *
 *  Exports  *
 * --------- *)

val () = _export "bs_return_string" : (ptr * int -> unit) -> unit; returnStringFromC

val () = _export "bs_last_exception" : (unit -> int) -> unit; lastException
val () = _export "bs_exception_name" : (int * ptr -> string) -> unit; exceptionName
val () = _export "bs_exception_message" : (int * ptr -> string) -> unit; exceptionMessage
val () = _export "bs_exception_dup" : (int -> int) -> unit; exceptionDup
val () = _export "bs_exception_free" : (int -> bool) -> unit; exceptionFree

(* Time functions *)
val () = _export "evt_time_from_string" : (ptr * int -> Int64.int) -> unit; timeFromString
val () = _export "evt_time_to_string" : (Int64.int * ptr -> string) -> unit; timeToString
val () = _export "evt_time_to_absolute_string" : (Int64.int * ptr -> string) -> unit; timeToAbsoluteString
val () = _export "evt_time_to_relative_string" : (Int64.int * ptr -> string) -> unit; timeToRelativeString

(* Event functions *)
val () = _export "evt_event_time" : (unit -> Int64.int) -> unit; eventTime
val () = _export "evt_event_new" : (ptr * ptr -> int) -> unit; eventNew
val () = _export "evt_event_schedule_at" : (int * Int64.int -> int) -> unit; eventScheduleAt
val () = _export "evt_event_schedule_in" : (int * Int64.int -> int) -> unit; eventScheduleIn
val () = _export "evt_event_cancel" : (int -> int) -> unit; eventCancel
val () = _export "evt_event_time_of_execution" : (int -> Int64.int) -> unit; eventTimeOfExecution
val () = _export "evt_event_time_till_execution" : (int -> Int64.int) -> unit; eventTimeTillExecution
val () = _export "evt_event_is_scheduled" : (int -> int) -> unit; eventIsScheduled
val () = _export "evt_event_dup" : (int -> int) -> unit; eventDup
val () = _export "evt_event_free" : (int -> bool) -> unit; eventFree

(* Stoppable functions *)
val () = _export "evt_abortable_abort" : (int -> int) -> unit; abortableAbort
val () = _export "evt_abortable_dup" : (int -> int) -> unit; abortableDup
val () = _export "evt_abortable_free" : (int -> bool) -> unit; abortableFree

(* Log functions *)
val () = _export "sys_log_log" : (int * ptr * int * ptr * int -> int) -> unit; logLog
val () = _export "sys_log_addfilter" : (ptr * int * int -> int) -> unit; logAddFilter
val () = _export "sys_log_removefilter" : (ptr * int -> int) -> unit; logRemoveFilter

(* Statistics functions *)
val () = _export "sys_statistics_new" : (ptr * int * ptr * int * int * int * int * Real32.real * bool -> int) -> unit; statisticsNew
val () = _export "sys_statistics_addpoll" : (int * ptr * ptr -> int) -> unit; statisticsAddPoll
val () = _export "sys_statistics_add" : (int * Real32.real -> int) -> unit; statisticsAdd
val () = _export "sys_statistics_dup" : (int -> int) -> unit; statisticsDup
val () = _export "sys_statistics_free" : (int -> bool) -> unit; statisticsFree

(* SimultaneousDump functions *)
val () = _export "sys_simultaneousdump_new" : (ptr * int * ptr * int * ptr * int * Int64.int -> int) -> unit; simultaneousDumpNew
val () = _export "sys_simultaneousdump_adddumper" : (int * ptr * ptr -> int) -> unit; simultaneousDumpAddDumper
val () = _export "sys_simultaneousdump_dup" : (int -> int) -> unit; simultaneousDumpDup
val () = _export "sys_simultaneousdump_free" : (int -> bool) -> unit; simultaneousDumpFree
