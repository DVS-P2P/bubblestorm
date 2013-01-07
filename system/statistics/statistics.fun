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

functor Statistics (structure Helper : STATISTICS_HELPER
                    structure Writer : STATISTICS_WRITER
                    structure Event  : EVENT)
   :> STATISTICS =
   struct
      datatype histogram =
         NO_HISTOGRAM
       | FIXED_BUCKET of Real32.real
       | EXPONENTIAL_BUCKET of Real32.real
      
      datatype t = T of {
         children : (unit -> unit) Ring.t,
         poll : (unit -> unit) Ring.t,
         collector : Collector.t,
         histogram : Histogram.t option
      }
      
      type config = {
            parents     : (t * (t -> t -> unit)) list, 
            name        : string,
            units       : string,
            label       : string,
            histogram   : histogram,
            persistent  : bool
         }

      val topLevelStatistics = Ring.new ()

      fun add (T fields) value =
         let
            val () = Option.app (fn h => Histogram.add h value) (#histogram fields)
         in
            Collector.add (#collector fields) value
         end
      
      fun aggregate (T fields) (T source) =
         let
            val () = case (#histogram fields, #histogram source) of
               (SOME dst, SOME src) => Histogram.aggregate dst src
             | _ => ()
         in
            Collector.aggregate (#collector fields) (#collector source)
         end
      
      fun count (T fields)  = Collector.count (#collector fields)
      fun min (T fields)    = Collector.min (#collector fields)
      fun max (T fields)    = Collector.max (#collector fields)
      fun sum (T fields)    = (Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge) 
                              (Collector.sum (#collector fields))
      fun avg (T fields)    = Collector.avg (#collector fields)
      fun stdDev (T fields) = Collector.stdDev (#collector fields)
      
      fun reset (T fields) =
         let
            val () = Option.app (fn h => Histogram.reset h) (#histogram fields)
         in
            Collector.reset (#collector fields)
         end
      
      (* recursively collect data from attached nodes in the statistics tree *)
      local
         open Iterator
      in
         val collectChildren =
            (app (fn action => action ()) o map Ring.unwrap o 
               fromList o toList o Ring.iterator)
      end
            
      fun addPullFunction (ring, action) =
         let
            val elem = Ring.wrap action
            val () = Helper.setCleanup (fn () => Ring.remove elem)
         in
            Ring.add (ring, elem)
         end
      
      fun addPoll (T parent, collect) = addPullFunction (#poll parent, Helper.setNodeContext collect)
      
      fun addChild (T parent, T this, collect, writer) =
         let
            fun action () =
                let
                    val () = collectChildren (#poll this)
                    val () = collectChildren (#children this) (* recursion *)
                    (* propagate up *)
                    val () = collect (T parent) (T this)
                in
                    writer ()
                end
         in
            addPullFunction (#children parent, action)
         end
      
      fun addGlobal (T this, writer) =
         let
            fun action () =
                let
                    val () = collectChildren (#poll this)
                    val () = collectChildren (#children this) (* recursion *)
                in
                    writer ()
                end
         in
            addPullFunction (topLevelStatistics, action)         
         end
      
      fun new {parents, name, units, label, histogram, persistent}  =
         let
            val realFrom32 = Real.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
            val histogram =
               case histogram of
                  NO_HISTOGRAM => NONE
                | FIXED_BUCKET bucketSize => SOME (Histogram.new (Histogram.CONSTANT_SIZE bucketSize))
                | EXPONENTIAL_BUCKET base => SOME (Histogram.new (Histogram.EXPONENTIAL_SIZE (realFrom32 base)))
            (* create record *)
            val fields = {
               poll = Ring.new (),
               children = Ring.new (),
               collector = Collector.new (),
               histogram = histogram
            }
            val stat = T fields
            (* create a writer function *)
            val writer =
               case persistent of
                  false => (fn () => reset stat)
                | true => Writer.createWriter {
                     name = name,
                     units = units,
                     label = label,
                     node = Helper.nodeID (),
                     collector = #collector fields,
                     histogram = #histogram fields
                  }
 
            (* add to parents *)
            val () = case parents of
               nil => addGlobal (stat, writer)
             | x => List.app (fn (parent, collect) => addChild (parent, stat, collect, writer)) x 
         in
            stat
         end
      
      val interval = ref (Time.fromSeconds 0)
      val intervalSec = ref (Time.toSecondsReal32 (!interval))
      
      (* the periodical poll, propagate, write to disk, and reset event *)
      fun collect event =
         let
            val () = collectChildren topLevelStatistics 
         in
            if Time.> (!interval, Time.zero)
            then Event.scheduleIn (event, !interval)
            else ()
         end

      val collectEvent = Event.new collect
      
      fun setLogInterval newInterval =
         let
            val () = interval := newInterval
            val () = intervalSec := Time.toSecondsReal32 newInterval
         in
            if Time.> (!interval, Time.zero)
            then Event.scheduleIn (collectEvent, newInterval)
            else Event.cancel collectEvent
         end
      
      fun logInterval () = !interval
      
      fun byLogInterval f stat =
         Real32./ (f stat, !intervalSec)
      
      fun distill collect (T parent) (T this) =
         let
            val child = collect (T this)
         in
             (* ignore NANs from children, they are an artifact from 
                averaging an empty statistic *) 
             if Real32.isNan(child) then () else add (T parent) child
         end
   end
