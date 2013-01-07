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

functor CUSPStatistics (
      structure CUSP : CUSP
      structure Event : EVENT
      structure Statistics : STATISTICS
   ) : CUSP_STATISTICS =
struct
   structure CUSP = CUSP
   open CUSP
   
   val statTrafficUp =
      Statistics.new {
         parents = nil,
         name = "cusp/traffic up",
         units = "bytes/second",
         label = "uplink",
         histogram = (*Statistics.EXPONENTIAL_BUCKET 2.0*) Statistics.NO_HISTOGRAM,
         persistent = true
      }
   val statTrafficDown =
      Statistics.new {
         parents = nil,
         name = "cusp/traffic down",
         units = "bytes/second",
         label = "downlink",
         histogram = (*Statistics.EXPONENTIAL_BUCKET 2.0*) Statistics.NO_HISTOGRAM,
         persistent = true
      }
   val statChannels =
      Statistics.new {
         parents = nil,
         name = "cusp/active channels",
         units = "#",
         label = "channels",
         histogram = Statistics.NO_HISTOGRAM,
         persistent = true
      }
   val statInStreams =
      Statistics.new {
         parents = nil,
         name = "cusp/in streams",
         units = "#",
         label = "input streams",
         histogram = Statistics.NO_HISTOGRAM,
         persistent = true
      }
   val statOutStreams =
      Statistics.new {
         parents = nil,
         name = "cusp/out streams",
         units = "#",
         label = "output streams",
         histogram = Statistics.NO_HISTOGRAM,
         persistent = true
      }
   
   fun addEndPoint ep =
      let
         (* traffic up *)
         val lastBytesUp = ref (EndPoint.bytesSent ep)
         val lastBytesUpT = ref (Event.time ())
         fun pollTrafficUp () =
            let
               val bytesUp = EndPoint.bytesSent ep
               val trafficUp = Real32.fromLargeInt (bytesUp - !lastBytesUp)
               val () = lastBytesUp := bytesUp
               val now = Event.time ()
               val tDiff = Time.toSecondsReal32 (Time.- (now, !lastBytesUpT))
               val () = lastBytesUpT := now
            in
               Statistics.add statTrafficUp (trafficUp / tDiff)
            end
         val () = Statistics.addPoll (statTrafficUp, pollTrafficUp)
         
         (* traffic down *)
         val lastBytesDown = ref (EndPoint.bytesReceived ep)
         val lastBytesDownT = ref (Event.time ())
         fun pollTrafficDown () =
            let
               val bytesDown = EndPoint.bytesReceived ep
               val trafficDown = Real32.fromLargeInt (bytesDown - !lastBytesDown)
               val () = lastBytesDown := bytesDown
               val now = Event.time ()
               val tDiff = Time.toSecondsReal32 (Time.- (now, !lastBytesDownT))
               val () = lastBytesDownT := now
            in
               Statistics.add statTrafficDown (trafficDown / tDiff)
            end
         val () = Statistics.addPoll (statTrafficDown, pollTrafficDown)
         
         (* channels *)
         fun countChannels () =
               ((Iterator.length o EndPoint.channels) ep)
         val () =
            Statistics.addPoll (statChannels,
               fn () => Statistics.add statChannels ((Real32.fromInt o countChannels) ()))
         
         (* in streams *)
         fun countInStreams () =
            let
               fun agg ((_, SOME host), count) = count + (Iterator.length o Host.inStreams) host
                 | agg ((_, NONE), count) = count
            in
               Iterator.fold agg 0 (EndPoint.channels ep)
            end
         val () =
            Statistics.addPoll (statInStreams,
               fn () => Statistics.add statInStreams ((Real32.fromInt o countInStreams) ()))
         
         (* out streams *)
         fun countOutStreams () =
            let
               fun agg ((_, SOME host), count) = count + (Iterator.length o Host.outStreams) host
                 | agg ((_, NONE), count) = count
            in
               Iterator.fold agg 0 (EndPoint.channels ep)
            end
         val () =
            Statistics.addPoll (statOutStreams,
               fn () => Statistics.add statOutStreams ((Real32.fromInt o countOutStreams) ()))
      in
         ()
      end
   
end
