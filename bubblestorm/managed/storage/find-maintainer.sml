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

structure FindMaintainer :> FIND_MAINTAINER =
   struct      
      val module = "bubblestorm/bubble/managed/find-maintainer"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)      

      type t = BasicBubbleType.t * StorageService.t

      local
         open Serial
         
         (* serialization of the bucket selection filter *)
         val filter = aggregate tuple2 `bool `bool $
         fun store (f : bool -> bool) = (f false, f true)
         (* are we in the right kind of bucket? *)
         fun load (even, odd) =
            fn bucket => (even andalso not bucket) orelse (odd andalso bucket)
         val filter = map { store=store, load=load, extra=fn()=>() } filter
         
         (* serialization of FindMaintainer payload *)
         val serial = aggregate tuple4 `StorageService.Description.t `real64l `real64l `filter $
      in
         val { toVector, parseVector, ... } = methods serial
      end
      
      (* FindMaintainers bubbles are answered with probability inversely 
         proportional to the maintainer's node capacity *)
      fun probabilisticAnswer (state, counter) =
         let
            val stats = BasicBubbleType.stats state
            val toReal64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
            val d = toReal64 (SystemStats.degree stats)
            val dMin = Real64.fromInt Config.minDegree
            val () = counter := !counter + dMin / d
         in
            if !counter < 1.0 then false else
               ( counter := !counter - 1.0 ; true )
         end

      fun receive (state, frontend, counter) (pos, data) =
         if not (probabilisticAnswer (state, counter)) then () else
            let
               val (service, capacity, d1, filter) = parseVector data
            in
               Frontend.addStorage frontend {
                  service  = service,
                  capacity = capacity,
                  d1       = d1,
                  filter   = filter,
                  position = pos
               }
            end

      fun new { state, types, name, typeID, service, frontend } =
         let
            (* create find maintainer bubble type *)
            val bubble = BasicBubbleType.new {
               state    = state,
               name     = name,
               typeId   = typeID,
               class    = BasicBubbleType.MAXIMUM {
                              withBubbles = types,
                              handler = receive (state, frontend, ref 0.0)
                           },
               priority = Config.findMaintainerPriority,
               reliability = Config.findMaintainerReliability
            }
         in
            (bubble, service)
         end
      
      fun bubbleSize (bubble, _) = BasicBubbleType.targetSize bubble
      
      (* TODO avoid code duplication *)
      fun myCapacity state =
         let
            val toReal64 = Real64.fromLarge IEEEReal.TO_NEAREST o Real32.toLarge
            val d = toReal64 (SystemStats.degree (BasicBubbleType.stats state))
            val dMin = Real64.fromInt Config.minDegree
         in
            d / dMin
         end
               
      (* send a FindMaintainers bubblecast *)
      fun send (bubble, service) filter =
         let
            val description = 
               case StorageService.description service of
                  SOME x => x
                | NONE => raise At (module, 
                            Fail "cannot send FindMaintainer without service")
            val state = BasicBubbleType.state bubble
            val baseSize = BasicBubbleType.targetSizeReal bubble
            
            (* findMaintainers bubble size must be proportional to node capacity *)
            val relCapacity = myCapacity state
            val size = Real64.ceil (baseSize * relCapacity)
            val d1 = SystemStats.d1 (BasicBubbleType.stats state)
            
            val () = log (fn () => "sending FindMaintainer of size " ^ 
                                    Int.toString size)
         in
            (* pull data from maintainers *)
            BasicBubbleType.bubblecast {
               bubbleType = bubble,
               size = size,
               data = toVector (description, relCapacity, d1, filter)       
            }
         end

      (* find maintainers for both buckets *)
      fun onJoinComplete this = send this (fn _ => true)
  end
