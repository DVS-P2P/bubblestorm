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

 structure UdpStatistics = 
   struct
      val statUDPTrafficUp'   = ref NONE
      val statUDPTrafficDown' = ref NONE
      val statRawTrafficUp'   = ref NONE
      val statRawTrafficDown' = ref NONE
      
      fun getRefOption (variable, name) = case !variable of
            SOME x => x
          | NONE => raise At ("udp-statistics", Fail (name ^ " not initialized"))
      
      fun defaultStatistic name =
         Statistics.new {
               parents = nil,
               name = "simulator/" ^ name,
               units = "bytes/second",
               label = name,
               histogram = Statistics.NO_HISTOGRAM,
               persistent = true
            }
      
      fun initUDP () = 
         let
            val () = statUDPTrafficUp' := SOME (defaultStatistic "UDP traffic up")
            val () = statUDPTrafficDown' := SOME (defaultStatistic "UDP traffic down")
            val () = statRawTrafficUp' := SOME (defaultStatistic "raw traffic up")
            val () = statRawTrafficDown' := SOME (defaultStatistic "raw traffic down")
         in
            ()
         end
      
      val statUDPTrafficUp   = fn () => getRefOption (statUDPTrafficUp', "statUDPTrafficUp'")
      val statUDPTrafficDown = fn () => getRefOption (statUDPTrafficDown', "statUDPTrafficDown'")
      val statRawTrafficUp   = fn () => getRefOption (statRawTrafficUp', "statRawTrafficUp'")
      val statRawTrafficDown = fn () => getRefOption (statRawTrafficDown', "statRawTrafficDown'")
   end
