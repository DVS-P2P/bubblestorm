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

fun handleFindServer
   (HANDLERS { findServer, ... })
   (ACTIONS { contactClient, ... })
   (STATE { locations, ... }) 
   source address makeClient hops =
   let
      fun method () = "topology/handler/findServer"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called from " ^ Conversation.toString source ^ " with (" ^ CUSP.Address.toString address ^ ", " ^ Conversation.Entry.toString makeClient ^ ", " ^ Int16.toString hops ^ ")")
      
      val splits = Iterator.filter Location.hasStableSlave (Locations.activeIterator locations)
      fun splitOk () = not (Iterator.null splits)

      val seed = Random.word64 (getTopLevelRandom (), NONE)
      val forwards = Locations.randomTotalNeighbours (locations, NONE, seed)
      fun forwardOk () = not (Iterator.null forwards)
   in
      if hops < ~Config.maxRandomWalkOvershoot then
         Log.logExt (Log.WARNING, method, fn () => "Random walk overshot limit; dropping")
      else if hops <= 0 andalso splitOk () then
         let
            val overshoot = Int16.toInt (~hops)
            val () = Statistics.add Stats.randomWalkOvershoot (Real32.fromInt overshoot)
         in
            contactClient address makeClient
         end
      else if not (forwardOk ()) then
         Log.logExt (Log.WARNING, method, fn () => "No available neighbour; dropping")
      else if Locations.leaving locations then
         let
            (* We should not use a biased holding probability (below).
             * We are leaving and just want to get rid of it!
             *)
            val (n, _) = valOf (Iterator.getItem forwards)
            val () = Log.logExt (Log.DEBUG, method, fn () => "leaving, so forwarding to " ^ Neighbour.toString n)
          in
            #findServer (Neighbour.methods n) address makeClient (hops-1)
         end
      else
         let
            (* We need to pick a random location and master/slave.
             * If it exists, we forward to it.
             * If not, we decrease the hops by 1 and re-process it.
             * This ensures that a split occures with equal likelihood at 
             * every location, even broken ones. (b/c stationary distribution)
             *)
            val idx = Random.int (getTopLevelRandom (), Locations.activeLocations locations)
            val location = Locations.sub (locations, idx)
            val neighbour = 
              if Random.int (getTopLevelRandom (), 2) = 0 
              then Location.master location 
              else Location.slave location
        in
            case neighbour of
               NONE =>
               let
                  val () = Log.logExt (Log.DEBUG, method, fn () => "keeping findServer for ourselves")
               in
                  findServer source address makeClient (hops-1)
               end
             | SOME n =>
               let
                  val () = Log.logExt (Log.DEBUG, method, fn () => "forwarding to " ^ Neighbour.toString n)
               in
                  #findServer (Neighbour.methods n) address makeClient (hops-1)
               end
         end
   end
