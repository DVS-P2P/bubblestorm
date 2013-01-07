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

structure Measurement =
   struct
      structure Real = Gossip.Real

      exception MeasurementInitialized
            
      datatype result = R of {
         data : Real.real vector,
         mins : int,
         maxs : int
      }
      
      fun getMinResult pos (R {data, ...})  = Vector.sub (data, pos)
      fun getMaxResult pos (R {data, mins, ...})  = Vector.sub (data, mins+pos)
      fun getSumResult pos (R {data, mins, maxs}) = Vector.sub (data, mins+maxs+pos)
      
      type measurement = {
         pull : unit -> Real.real, 
         stat : Statistics.t option
      }

      datatype innerT = T of { 
         freq : Time.t,
         notifications : (bool * Word32.word * result -> unit) list ref,
         min  : measurement list ref, 
         max  : measurement list ref, 
         sum  : measurement list ref 
      } | DONE

      type t = innerT ref 
      
      fun new freq = ref (T {
         freq = freq,
         notifications = ref [],
         min  = ref [],
         max  = ref [],
         sum  = ref []
      })
      
      fun addNotification (ref DONE, _) = raise MeasurementInitialized
        | addNotification (ref (T { notifications, ... }), callback) =
         notifications := callback :: !notifications
         
      fun addSum (ref DONE, _) = raise MeasurementInitialized
        | addSum (ref (T { sum, ... }), r) =
         let
            val pos = List.length (!sum)
            val () = sum := r :: !sum
          in
            getSumResult pos
          end
          
      fun addMin (ref DONE, _) = raise MeasurementInitialized
        | addMin (ref (T { min, ... }), r) = 
         let
            val pos = List.length (!min)
            val () = min := r :: !min
          in
            getMinResult pos
          end
      
      fun addMax (ref DONE, _) = raise MeasurementInitialized
        | addMax (ref (T { max, ... }), r) = 
         let
            val pos = List.length (!max)
            val () = max := r :: !max
          in
            getMaxResult pos
          end
      
      fun make (ref DONE) = raise MeasurementInitialized
        | make (this as ref (T { freq, notifications, min, max, sum })) =
         let
            (* pull functions & measurement statistics *)
            val mins = List.length (!min)
            val maxs = List.length (!max)
            val sums = List.length (!sum)
            val both = List.rev (!min) @ List.rev (!max) @ List.rev (!sum)
            val pull = Vector.fromList (List.map #pull both)
            fun pullFn () = Vector.map (fn f => f ()) pull           
            val stat = Vector.fromList (List.map #stat both)

            (* notifications *)
            val callbacks = Vector.fromList (List.rev (!notifications))
            fun notify init (round, data) =
               Vector.app (fn f => f (init, round, R {data=data, mins=mins, maxs=maxs})) callbacks
            val () = this := DONE (* no more fooling around after initialization *)
         in
            {
               freq = freq,
               min = mins,
               max = maxs,
               sum = sums,
               pull = pullFn,
               push = notify false,
               init = notify true,
               stat = stat
            }
         end
   end
