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

structure SpaceCoordinate =
   struct
      open Real
      
      type t = real * real * real

      fun fromPosition (longitude, latitude) =
         let
            val long = longitude * Math.pi / 180.0
            val lat  = latitude  * Math.pi / 180.0
            val x = Math.cos (lat) * Math.sin (long)
            val y = Math.sin (lat)
            val z = Math.cos (lat) * Math.cos (long)
         in
            (x, y, z)
         end

      fun * ((x1, y1, z1), (x2, y2, z2)) =
         Real.* (x1, x2) +  Real.* (y1, y2) + Real.* (z1, z2)

      (* Take the dot product of the normal vectors to find cosine of their arc *)
      fun arcLength (a, b) = Math.acos (max (min (a * b, 1.0), ~1.0))
      (* x*y may be >1 (or <-1) caused by rounding errors, thus cut range *)
   end

datatype t = T of {
   ip : Word64.word,
   geo : SpaceCoordinate.t,
   x : real,
   y : real
}

structure WordKey =
   struct
      type t = Word64.word
      val op == = op =
      val hash = Hash.word64
   end
structure WordMap = HashTable(WordKey)

structure IntKey =
   struct
      type t = int
      val op == = op =
      val hash = Hash.int
   end
structure IntMap = HashTable(IntKey)

structure Stat :>
   sig
      type t
      val new : unit -> t
      val add : t * real -> unit
      val toString : t -> string
   end
   =
   struct
      type t = {
         count : Int64.int,
         sum : real,
         min : real,
         max : real
      } ref
      
      fun new () = ref {
         count = 0 : Int64.int,
         sum = 0.0,
         min = Real.posInf,
         max = Real.negInf
      }
      
      fun add (stat as ref { count, sum, min, max }, value) = stat := {
         count = count + 1 : Int64.int,
         sum = sum + value,
         min = Real.min (min, value),
         max = Real.max (max, value)
      }
      
      fun toString (ref { count, sum, min, max }) =
         Real.toString (sum / Real.fromLargeInt (Int64.toLarge count)) ^ "\t"
         ^ Real.toString min ^ "\t" ^ Real.toString max
   end
      
(******************************************************************************)

(* open database *)
val database = SQL.openDB "delay-model.db"

local
   open SQL.Query
in
   val query = prepare database
      "SELECT ip, longitude, latitude, coordinate1, coordinate2 FROM geo_hosts;"
      oZ oR oR oR oR $
end

fun readEntry (ip & long & lat & x & y) =
   T {
      ip = Word64.fromLargeInt (Int64.toLarge ip),
      geo = SpaceCoordinate.fromPosition (long, lat),
      x = x,
      y = y
   }

(* read hosts into vector *)   
val hosts = SQL.map readEntry query ()
val () = SQL.closeDB database

(******************************************************************************)

fun pow2 (x, y) = (* speeds up things compared to Math.pow (x - y, 2.0) *)
      let
         val a = (x - y)
      in
         a * a
      end

fun getVirtDelay (T { x=x1, y=y1, ...}, T { x=x2, y=y2, ... }) =
   Real.Math.sqrt (pow2 (x1, x2) + 4.0 * pow2 (y1, y2)) / 2.0

fun getGeoDelay (T { geo=source, ...}, T { geo=dest, ... }) =
   let
      (* We just average the minor/major axises and call it a sphere: *)
      val earthRadius = 6372797.0 (* in meters *)
      val speedOfLight = 299792458.0; (* in meters/second *)

      val arcLen = (SpaceCoordinate.arcLength (source, dest)) * earthRadius
   in
      1000.0 * arcLen / speedOfLight (* in ms *)
   end

(******************************************************************************)

fun add (hist, delay) =
   let
      val pos = Real.round delay
      val old = DynamicArray.sub (hist, pos)
   in
      DynamicArray.update (hist, pos, old + 1 : Int64.int)
   end

fun virtDelay hist (_, _, _, virtDelay) = add (hist, virtDelay)

fun geoDelay hist (_, _, geoDelay, _) = add (hist, geoDelay)

fun undershoot hist (_, _, geoDelay, virtDelay) =
   if geoDelay > virtDelay then add (hist, geoDelay - virtDelay) else ()
   
fun addIP (hist, pos) =
   WordMap.set (hist, pos, Option.getOpt (WordMap.get (hist, pos), 0 : Int64.int) + 1)

fun tooLow hist (source, dest, geoDelay, virtDelay) =
   let
      val T { ip=src, ... } = source
      val T { ip=dst, ... } = dest
   in
      if geoDelay > virtDelay + 20.0
         then ( addIP (hist, src); addIP (hist, dst) )
         else ()
   end
   
fun outliers hist (source, dest, geoDelay, virtDelay) =
   let
      val T { ip=src, ... } = source
      val T { ip=dst, ... } = dest
   in
      if virtDelay > 1000.0 orelse geoDelay - virtDelay > 0.0
         then ( addIP (hist, src); addIP (hist, dst) )
         else ()
   end
   
fun compared hist (_, _, geoDelay, virtDelay) =
   let
      val pos = Real.round geoDelay
      val stat = case IntMap.get (hist, pos) of
         SOME x => x
       | NONE =>
         let
            val stat = Stat.new ()
            val () = IntMap.set (hist, pos, stat)
         in
            stat
         end
   in
      Stat.add (stat, virtDelay)
   end

(******************************************************************************)

val progress = ref ~1
val filters = ref []
val writers = ref []

fun printStatus (filename, size) pos =
   let
      val rem = Real.fromInt (size - pos)
      val size = Real.fromInt size
      val elems = size * size / 2.0
      val togo = rem * rem / 2.0
      val newPos = Real.round (1000.0 * (elems - togo) / elems)
   in
      if newPos = !progress then () else
         let
            val () = progress := newPos
            val () = print ("\r" ^ filename ^ ": " ^ 
                        (Real.fmt (StringCvt.FIX (SOME 1)) 
                         (Real.fromInt (!progress) / 10.0)) ^ "%")
         in
            TextIO.flushOut TextIO.stdOut
         end
   end
   
fun innerLoop filters source dest =
   let
      val geoDelay = getGeoDelay (source, dest)
      val virtDelay = getVirtDelay (source, dest)
   in
      List.app (fn f => f (source, dest, geoDelay, virtDelay)) filters
   end

fun outerLoop (status, filters) (pos, node) =
   let
      val () = status pos
      val slice = VectorSlice.slice (hosts, pos + 1, NONE)
   in
      VectorSlice.app (innerLoop filters node) slice
   end

fun main () =
   let
      (* do the computation *)
      val status = printStatus ("computing", Vector.length hosts)   
      val () = Vector.appi (outerLoop (status, !filters)) hosts

      val () = print "\rDone.                         \n"
   in
      (* write results to disk *)
      List.app (fn f => f ()) (!writers)
   end

(******************************************************************************)

fun writeCDF filename hist () =
   let
      val stream = TextIO.openOut filename
      fun printLine (pos, value, acc) =
         if value = 0 then acc else 
         let
            val acc = acc + value
            val () = TextIO.output (stream, Int.toString pos ^ "\t" ^ Int64.toString acc ^ "\n")
         in
            acc
         end
      val () = ignore (DynamicArray.foldli printLine 0 hist)
   in
      TextIO.closeOut stream
   end

fun sort (less, it) =
   let
      val arr = Iterator.toArray it
      val () = HeapSort.sort less arr
   in
      Iterator.fromArray arr
   end
   
fun writeIPHistogram filename hist () =
   let
      val stream = TextIO.openOut filename
      fun IPtoString ip = LargeInt.toString (Word64.toLargeInt ip)
      fun printLine (pos, value) =
         if value = 0 then () else 
            TextIO.output (stream, IPtoString pos ^ "\t" ^ Int64.toString value ^ "\n")
      fun less ((_, valA), (_, valB)) = Int64.< (valA, valB)
      val () = Iterator.app printLine (sort (less, WordMap.iterator hist))
   in
      TextIO.closeOut stream
   end

fun writeCorrelation filename hist () =
   let
      val stream = TextIO.openOut filename
      fun printLine (pos, value) =
         TextIO.output (stream, Int.toString pos ^ "\t" ^ Stat.toString value ^ "\n")
      fun less ((posA, _), (posB, _)) = Int.< (posA, posB)
      val () = Iterator.app printLine (sort (less, IntMap.iterator hist))
   in
      TextIO.closeOut stream
   end

(******************************************************************************)

(* create histogram data structures *)
fun add map (filter, writer) = (
        filters := (filter map) :: (!filters)
      ; writers := (writer map) :: (!writers)
   )
   
fun addCDF (filter, filename) =
   add (DynamicArray.new (fn _ => 0 : Int64.int)) (filter, writeCDF filename)
fun addIPHistogram (filter, filename) =
   add (WordMap.new ()) (filter, writeIPHistogram filename)
fun addCorrelation (filter, filename) =
   add (IntMap.new ()) (filter, writeCorrelation filename)

(******************************************************************************)

val () = addCDF (virtDelay, "virtDelay.txt")
val () = addCDF (geoDelay, "geoDelay.txt")
val () = addCDF (undershoot, "undershoot.txt")
val () = addIPHistogram (outliers, "outliers.txt")
val () = addIPHistogram (tooLow, "too-low.txt")
val () = addCorrelation (compared, "compared.txt")

val () = main ()
