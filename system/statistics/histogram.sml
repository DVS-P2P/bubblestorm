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

structure Histogram :> HISTOGRAM =
   struct
      val module = "system/statistics/histogram"
      
      structure HistMap = HashTable(
         struct
            type t = int
            val op == = op =
            val hash = Hash.int
         end
      )
      
      datatype bucket_mode =
         CONSTANT_SIZE of Real32.real
       | EXPONENTIAL_SIZE of Real.real
      
      datatype t = T of {
         mode : bucket_mode,
         map : int HistMap.t
      }
      
      val realFrom32 = Real.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
      
      val minInt = valOf Int.minInt
      
      fun put map (key, count') =
         case HistMap.get (map, key) of
            SOME count => HistMap.update (map, key, count + count')
          | NONE => HistMap.add (map, key, count')

      fun equals (CONSTANT_SIZE x, CONSTANT_SIZE y) = Real32.== (x, y)
      |   equals (EXPONENTIAL_SIZE x, EXPONENTIAL_SIZE y) = Real.== (x, y)
      |   equals (_, _) = false
         
      fun aggregate (T { mode=mode1, map=map1, ... }) (T { mode=mode2, map=map2, ... }) =
         if equals (mode1, mode2)
            then Iterator.app (put map1) (HistMap.iterator map2)
            else raise At (module, Fail "cannot aggregate incompatible histograms")

      fun add (T { mode, map, ... }) value =
         if Real32.isNan value then () else
         let
            val key =
               case mode of
                  CONSTANT_SIZE bucketSize =>
                     Real32.toInt IEEEReal.TO_NEGINF (Real32./ (value, bucketSize))
                | EXPONENTIAL_SIZE base =>
                     let
                        val x = Real./ (Math.ln (realFrom32 value), Math.ln base)
                     in
                        if Real.isFinite x
                        then Real.toInt IEEEReal.TO_NEGINF x
                        else minInt
                     end
         in
            put map (key, 1)
         end
      
      fun buckets (T { mode, map, ... }) =
         let
            (* convert internal bucket structure to (left, count, width) *)
            val mapBucket =
               case mode of
                  CONSTANT_SIZE bucketSize =>
                     let
                        val bucketSize = realFrom32 bucketSize
                     in
                        fn (bucket, count) => (
                           Real.* (Real.fromInt bucket, bucketSize),
                           count,
                           bucketSize
                        )
                     end
                | EXPONENTIAL_SIZE base =>
                     fn (bucket, count) =>
                        let
                           val x =
                              if bucket > minInt
                              then Math.pow (base, Real.fromInt bucket)
                              else 0.0
                        in
                           (x, count, x)
                        end
         in
            Iterator.map
            mapBucket
            (HistMap.iterator map)
         end
      
      fun new mode =
         T {
            mode = mode,
            map = HistMap.new ()
         }
      
      fun reset (T { map, ... }) =
         HistMap.clear map
      
   end
