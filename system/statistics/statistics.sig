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

signature STATISTICS =
   sig
      type t
      
      datatype histogram =
         NO_HISTOGRAM
       | FIXED_BUCKET of Real32.real (* parameter: bucket size *)
       | EXPONENTIAL_BUCKET of Real32.real (* parameter: bucket size base *)
      
      type config = {
            parents     : (t * (t -> t -> unit)) list, 
            name        : string,
            units       : string,
            label       : string,
            histogram   : histogram,
            persistent  : bool
         }
      
      (* sets how often statistics are written to disk and reset.
       *)
      val setLogInterval : Time.t -> unit
      
      (* returns the current log interval
       *)
      val logInterval : unit -> Time.t
      
      (* creates a new statistic of the given name.
       * the statistics will be written to disk and 
       * reset periodically.
       *)
      val new : config -> t
      
      (* adds a poll function that is called for each statistics round *)
      val addPoll : t * (unit -> unit) -> unit
      
      (* add a value to the statistic. *)
      val add    : t -> Real32.real -> unit
      (* add all values of the second statistic to the first *)
      val aggregate : t -> t -> unit
      
      (* the number of values added since the last reset. *)
      val count  : t -> int
      (* the smallest value added since the last reset. *)
      val min    : t -> Real32.real
      (* the biggest value added since the last reset. *)
      val max    : t -> Real32.real
      (* the sum of all values added since the last reset. *)
      val sum    : t -> Real32.real
      (* the average of all values added since the last reset. *)
      val avg    : t -> Real32.real
      (* the standard deviation of all values added since the last reset. *)
      val stdDev : t -> Real32.real
      (* deletes all values in the statistic. *)
      val reset : t -> unit
      
      (* divides te output of an aggregator function by the current log interval (in seconds) *)
      val byLogInterval : (t -> Real32.real) -> (t -> Real32.real)
      
      (* takes a basic attribute method (like Statistics.avg) and prepares it 
       * to be used as a push function to the parent.
       *)
      val distill : (t -> Real32.real) -> t -> t -> unit
end
