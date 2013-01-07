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

(* Latency depending on the arc-length from one point on the earth to the
 * other point *)
functor ArcLengthDelay(Base : NETWORK_MODEL) :> NETWORK_MODEL =
   struct
      structure SpaceCoordinate =
         struct
            open Real32

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
               Real32.* (x1, x2) +  Real32.* (y1, y2) + Real32.* (z1, z2)

            (* Take the dot product of the normal vectors to find cosine of their arc *)
            fun arcLength (x, y) = Math.acos (max (min (x * y, 1.0), ~1.0))
               (* x*y may be >1 (or <-1) caused by rounding errors, thus cut range *)

         end

      fun computeDelay (x, y) =
         let
            (* We just average the minor/major axises and call it a sphere: *)
            val earthRadius = 6372797.0 (* in meters *)
            val speedOfLight = 299792458.0; (* in meters/second *)

            val spaceCoord = SpaceCoordinate.fromPosition o Location.geoPosition o SimulatorNode.location
            val source =  spaceCoord x
            val dest = spaceCoord y
            val arcLen = (SpaceCoordinate.arcLength (source, dest)) * earthRadius
            val physicalLimit = Time.fromSecondsReal32 (arcLen / speedOfLight)
         in
            (* Real Internet is not a direct path and fiber + switching
             * is slower than light in vaacum *)
            Time.* (physicalLimit, 2)
         end

      fun addDelay myDelay (delay, bitErrors) = (Time.+ (delay, myDelay), bitErrors)

      fun route (x, y) =
         List.map (addDelay (computeDelay (x, y))) (Base.route (x, y))
   end

structure NetworkModel = ArcLengthDelay(NetworkModel)
