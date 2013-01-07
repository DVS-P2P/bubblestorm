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

signature MEASUREMENT =
   sig
      (* a measurment set. to be used with Topology.addMeasurement. *)
      type t

      (* the result of a measurement round *)
      type result
      
      (* the real type used for measurements *)
      structure Real : REAL     

      (* when a node joins the network the measurements get initialized.
       * after initialization a measurement set cannot be modified
       * anymore (by calling addNotification, addSum, or addMax).
       *)
      exception MeasurementInitialized

      (* create a new measurement set which can be measured with the topology.
       * the parameter sets the frequency at which new results should arrive.
       *)  
      val new : Time.t -> t
      
      (* add a notification callback to the measurement set that receives
       * newly computed global measurements. The boolean value is true if it
       * is the first measurement (received upon join) or false for any 
       * subsequent measurement. The word value is the round number. *)
      val addNotification : t * (bool * Word32.word * result -> unit) -> unit
      
      (* add a new global sum to a measurement set.
       * pull : a callback to retrieve the local summand for the global sum
       * stat : an optional statistic to keep track of the conversion of the
       *        global sum
       *)
      val addSum : t * {
         pull : unit -> Real.real,
         stat : Statistics.t option
      } -> (result -> Real.real)

      (* add a new global minimum to a measurement set.
       * pull : a callback to retrieve the local value for the global minimum
       * stat : an optional statistic to keep track of the conversion of the
       *        global minimum
       *)
      val addMin : t * {
         pull : unit -> Real.real,
         stat : Statistics.t option
      } -> (result -> Real.real)
      
      (* add a new global maximum to a measurement set.
       * pull : a callback to retrieve the local value for the global maximum
       * stat : an optional statistic to keep track of the conversion of the
       *        global maximum
       *)
      val addMax : t * {
         pull : unit -> Real.real,
         stat : Statistics.t option
      } -> (result -> Real.real)
   end
