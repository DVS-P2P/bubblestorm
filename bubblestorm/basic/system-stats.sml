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

structure SystemStats :> SYSTEM_STATS =
   struct
      fun module () = "bubblestorm/bubble/basic/system-stats"

      datatype status = JOINING | ONLINE | LEAVING | OFFLINE
      
      datatype t = T of {
         status : status ref,
         round : Word32.word ref,
         D0 : Real64.real ref,
         D1 : Real64.real ref,
         D2 : Real64.real ref,
         D0' : Real64.real ref,
         D1' : Real64.real ref,
         D2' : Real64.real ref,
         (*minDegree : Real64.real ref,*)
         maxDegree : Real64.real ref,
         myDegree : unit -> Real32.real
      }
      
      fun statusToString JOINING = "JOINING"
        | statusToString ONLINE = "ONLINE"
        | statusToString LEAVING = "LEAVING"
        | statusToString OFFLINE = "OFFLINE"

      fun setStatus (T { status, ... }, newStatus) = 
         let
            val () = Log.logExt (Log.DEBUG, module, fn () => (statusToString (!status) ^ " => " ^ statusToString newStatus))
         in
            status := newStatus
         end
         
      fun status (T { status, ... }) = !status
      fun round (T { round, ... }) = !round
      fun degree (T { myDegree, ... }) = myDegree ()
      fun d0  (T { D0,  ... }) = !D0
      fun d0' (T { D0', ... }) = !D0'
      fun d1  (T { D1,  ... }) = !D1
      fun d1' (T { D1', ... }) = !D1'
      fun d2  (T { D2,  ... }) = !D2
      (*fun dMin (T { minDegree, ... }) = !minDegree*)
      fun dMax (T { maxDegree, ... }) = !maxDegree
      
      fun new (topology, measurement, attributes) =
         let
            (* helper functions *)
            fun deg () = Real32.fromInt (Topology.desiredDegree topology)
            val toReal64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge

            (* the network size *)            
            val getD0 = Measurement.addSum (measurement, {
               pull = fn () => 1.0,
               stat = SOME Stats.measureD0
            })
         
            (* the sum of degrees *)            
            val getD1 = Measurement.addSum (measurement, {
               pull = fn () => deg (),
               stat = SOME Stats.measureD1
            })
         
            (* the sum of squared degrees *)            
            val getD2 = Measurement.addSum (measurement, {
               pull = fn () => deg () * deg (),
               stat = SOME Stats.measureD2
            })
            
            (* the minimum degree *)
(*            val getDmin = Measurement.addMin (measurement, {
               pull = fn () => deg (),
               stat = SOME Stats.measureDmin
            })
*)                  
            (* the maximum degree *)
            val getDmax = Measurement.addMax (measurement, {
               pull = fn () => deg (),
               stat = SOME Stats.measureDmax
            })
                  
            (* initialize network statistics *)
            val minSize = 1.0
            val capacity = NodeAttributes.capacity attributes
            val myDegree = (Real64.fromInt Config.minDegree) * capacity
            
            val this = T {
               status = ref OFFLINE,
               round = ref 0w0,
               D0 = ref minSize,
               D1 = ref (myDegree * minSize),
               D2 = ref (myDegree * myDegree * minSize),
               D0' = ref minSize,
               D1' = ref (myDegree * minSize),
               D2' = ref (myDegree * myDegree * minSize),
               (*minDegree = ref myDegree,*)
               maxDegree = ref myDegree,
               myDegree = deg
            }

            (* round statistics *)
            fun poll (T { round, ... }) () = if !round = 0w0 then () else
               Statistics.add Stats.measurementRound 
                  (Real32.fromLargeInt (Word32.toLargeInt (!round)))
            val () = Statistics.addPoll (Stats.measurementRound, poll this)
            
            (* receive updates when measurement round changes *)
            fun updateStats (T { round, D0, D1, D2, D0', D1', D2', (*minDegree,*) maxDegree, ... }) 
                            (_, newRound, result) =
               let
                  val () = round := newRound
                  val () = D0' := !D0
                  val () = D1' := !D1
                  val () = D2' := !D2
                  val () = D0 := Real64.max ((toReal64 o getD0) result, 1.0)
                  val () = D1 := (toReal64 o getD1) result
                  val () = D2 := (toReal64 o getD2) result
                  (*val () = minDegree := (toReal64 o getDmin) result*)
                  val () = maxDegree := (toReal64 o getDmax) result
                  
                  val roundInt = Word32.toLargeInt (!round)
                  val () = Log.logExt (Log.DEBUG, module, fn () => 
                  "Completed measurement round " ^ (LargeInt.toString roundInt))
                  val () = Log.logExt (Log.DEBUG, module, fn () => 
                              "Network sizes: d0 = " ^ (Real64.toString (!D0))
                              ^ " d1 = "  ^ (Real64.toString (!D1))
                              ^ " d2 = "  ^ (Real64.toString (!D2))
                              (*^ " dmin = "  ^ (Real64.toString (!minDegree))*)
                              ^ " dmax = "  ^ (Real64.toString (!maxDegree)))

                  (* tell the topology the new network size *)
                  val () = Topology.setNetworkSize (topology, getD0 result)
               in
                  ()
               end
            
            (* register notification on updates *)
            val () = Measurement.addNotification (measurement, updateStats this)
         in
            this
         end

     (*fun relativeDegree (T { D0, D1, myDegree, ... }) =
         let
            val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
            val n = toReal32 (!D0)
            val degreeSum = toReal32 (!D1)
         in
            n * (myDegree ()) / degreeSum
         end
      *)
      fun dependencyCompensator (T {D1 = ref d1, D2 = ref d2, ... }) =
         d2 / (d2 - 2.0 * d1)

      fun dependencyCompensator' (T {D1' = ref d1', D2' = ref d2', ... }) =
         d2' / (d2' - 2.0 * d1')
   end
