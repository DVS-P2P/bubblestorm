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

fun handleBubblecast
   (HANDLERS { ... })
   (ACTIONS { ... })
   (STATE { locations, bubblecaster, ... }) 
   source typ seed bubbleStart bubbleStop sliceStart sliceStop payload =
   let
      fun method () = "topology/handler/bubblecast"
      fun who () = getOpt (Option.map Conversation.toString source, "myself")
      val () = Log.logExt (Log.DEBUG, method, fn () =>
         "called from " ^ who ()
         ^ ": typ=" ^ (Int.toString typ)
         ^ ", bubbleStart=" ^ (Int.toString bubbleStart) ^ ", bubbleStop=" ^ (Int.toString bubbleStop)
         ^ ", sliceStart=" ^ (Int.toString sliceStart) ^ ", sliceStop=" ^ (Int.toString sliceStop))
      
      val {maxSize, process, priority, reliability} = case !bubblecaster of
         SOME getType => getType typ
       | NONE => raise At (method (), Fail "bubblecast handler not initialized")
      
      (* sanitize input values; stop must be bigger than start *)
      val bubbleStop = Int.max (bubbleStart, bubbleStop)
      val sliceStop = Int.max (sliceStart, sliceStop)
      
      (* do local processing and reduce bubble size by one *)
      val () = if sliceStart <= bubbleStart 
               then process (bubbleStart, payload)
               else ()
      val bubbleStart = bubbleStart + 1
      val midpoint = (bubbleStart + bubbleStop) div 2
      
      (* shrink incoming bubbles if they are bigger than our estimate of the
         initial size. only change slice size, because the bubble might be much
         bigger than it should but only used for small slices (e.g. in the 
         maintained replication). *)
      val sliceStop = Int.min (sliceStop, sliceStart + maxSize ())

      (* pick two random neighbours. we have to include the current position in 
         the bubble. Otherwise, collisions would always follow the same paths. *)
      val seed = Word64.xorb (seed, Word64.fromInt bubbleStart)
      val (left, right) = Locations.randomSplitTotalNeighbours (locations, source, seed)
      val (left, right) = (Iterator.getItem left, Iterator.getItem right)
      
      (* Do the splitting of the remaining bubble:
      
         [bubbleStart,                  bubbleStop) 
               [sliceStart,      sliceStop) 
                             ^ 
                             \------- cut at midpoint
      *)
      fun cannotForward () =
         Log.logExt (Log.WARNING, method, fn () => "no appropriate neighbour. dropping.")

      fun forward (NONE, _) = cannotForward ()         
        | forward (_, NONE) = cannotForward ()
        | forward (SOME (left, _), SOME (right, _)) =
         let      
            val subBubble1Start = bubbleStart
            val subBubble1Stop  = midpoint
            val subBubble2Start = midpoint
            val subBubble2Stop  = bubbleStop
            
            val subSlice1Start = Int.max (sliceStart, subBubble1Start)
            val subSlice1Stop  = Int.min (sliceStop,  subBubble1Stop)
            val subSlice2Start = Int.max (sliceStart, subBubble2Start)
            val subSlice2Stop  = Int.min (sliceStop,  subBubble2Stop)
            
            val () = Log.logExt (Log.DEBUG, method, fn () =>
               ("forward: midpoint=" ^ (Int.toString midpoint)
               ^ ", subBubble1Start=" ^ (Int.toString subBubble1Start) ^ ", subBubble1Stop=" ^ (Int.toString subBubble1Stop)
               ^ ", subBubble2Start=" ^ (Int.toString subBubble2Start) ^ ", subBubble2Stop=" ^ (Int.toString subBubble2Stop)
               ^ ", subSlice1Start=" ^ (Int.toString subSlice1Start) ^ ", subSlice1Stop=" ^ (Int.toString subSlice1Stop)
               ^ ", subSlice2Start=" ^ (Int.toString subSlice2Start) ^ ", subSlice2Stop=" ^ (Int.toString subSlice2Stop)))
            
            (* helper function for forwarding bubbles *)
            fun cast neighbour bubbleStart bubbleStop sliceStart sliceStop = 
               if sliceStop <= sliceStart then () else
               let
                  val { bubblecast, ... } = Neighbour.methods neighbour
                  val priority = priority (sliceStop - sliceStart)
                  val priority = Conversation.Priority.fromReal priority
                  val reliability = reliability (sliceStop - sliceStart)
                  val reliability = Conversation.Reliability.fromReal reliability
               in
                  bubblecast (priority, reliability) typ seed bubbleStart bubbleStop sliceStart sliceStop payload
               end      
            
            (* do the forwarding *)
            val () = cast left  subBubble1Start subBubble1Stop subSlice1Start subSlice1Stop
            val () = cast right subBubble2Start subBubble2Stop subSlice2Start subSlice2Stop
         in
            ()
         end
   in
      if (sliceStop <= sliceStart) then () else (* don't forward if there is no slice left *)
      forward (left, right)
   end
