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

structure RoutingMetric :> ROUTING_METRIC =
   struct
      datatype t = T of {
         id : Word64.word,
         capacity : Real64.real,
         table : RoutingTable.t,
         backend : Backend.t
      }

      type callback =
         (ID.t * Service.stub * Record.t * Word8Vector.vector) Iterator.t -> unit
         
      (* take the first 64 bit for ID-based computations *)
      local
         val shortID = (#fromVector (Serial.methods Serial.word64l)) o
                       (#toVector (Serial.methods ID.t))
      in      
         fun docID id = shortID id
         (* the short node ID must be odd *)
         fun peerID id = Word64.orb (shortID id, 0w1)
      end
      
      fun new (state, table, backend) =
         T {
            id = peerID (NodeAttributes.id (BasicBubbleType.attributes state)),
            capacity = NodeAttributes.capacity (BasicBubbleType.attributes state),
            table = table,
            backend = backend
         }
      
(*      local
         (* TODO: this code requires that LargeInt = IntInf (arbitrary precision) *)
         val maxWordAsLargeInt = Word64.toLargeInt (Word64.notb 0w0)
         val maxWord = Real64.fromLargeInt maxWordAsLargeInt
         val minDegree = Real64.fromInt Config.minDegree
         (* avoid responsibility overflow (>100% of all items) *)
         fun avoidOverflow x = LargeInt.min (x, maxWordAsLargeInt)
         val realToWord = Word64.fromLargeInt o avoidOverflow o 
                          (Real64.toLargeInt IEEEReal.TO_POSINF)
      in
         fun responsibility (capacity, density) =
            realToWord (capacity * minDegree * density * maxWord)
      end
*)
(* [ML] fix proposed by Christof 2012-10-18 *)
      local
         (* TODO: this code requires that LargeInt = IntInf (arbitrary precision) *)
         val maxWordAsLargeInt = Word64.toLargeInt (Word64.notb 0w0)
         val maxWord = Real64.fromLargeInt maxWordAsLargeInt
         val minDegree = Real64.fromInt Config.minDegree
         (* avoid responsibility overflow (>100% of all items) *)
         fun avoidOverflow x = LargeInt.min (x, maxWordAsLargeInt)
      in
         fun intResponsibility (capacity, density) =
            (Real64.toLargeInt IEEEReal.TO_POSINF)
            (capacity * minDegree * density * maxWord)
         val responsibility = Word64.fromLargeInt o avoidOverflow o intResponsibility
      end
      
      fun isResponsible (nodeID, capacity) density itemID =
         nodeID * itemID < responsibility (capacity, density)

      local
         (* The fraction of nodes in a responsibility set which are within the 
            giant component. The responsibility set has to be target bubble size
            divided by this factor to achieve the correct bubble size. *)
         val giantComponentFraction =
            0.5 * (1.0 + (Real64.Math.sqrt (1.0 - (4.0 / (Config.durableDegree * Real64.Math.e)))))
         
         fun getDensity getBubbleSize btype =
            let
               val size = Real64.realCeil (getBubbleSize btype / giantComponentFraction)
               val state = BasicBubbleType.state btype
               val capacitySum = SystemStats.d1 (BasicBubbleType.stats state)
            in
               size / capacitySum
            end
      in
         val targetDensity = getDensity BasicBubbleType.targetSizeReal
         val previousDensity = getDensity BasicBubbleType.oldSizeReal
      end

      fun findResponsible (T this, bubble, id) =
         let
            val density = targetDensity bubble
            val itemID = docID id
            fun map (nodeID, service) =
               if isResponsible (peerID nodeID, Service.capacity service) density itemID
                  then SOME (nodeID, service)
                  else NONE
         in
            Iterator.mapPartial map (RoutingTable.iterator (#table this))
         end

      fun storeIterator (this, { bubble, id, version=_ }) =
         findResponsible (this, bubble, id)
         
      fun lookupIterator  (this, { bubble, id, receive=_ }) =
         findResponsible (this, bubble, id)
      
(*      fun iAmResponsible (T this) { bubble, id, version=_ } =
         let
            val random = (#id this) * (docID id)
            val limit = responsibility (#capacity this, targetDensity bubble)
            val bubblesize = (Int.toLarge o BasicBubbleType.targetSize) bubble
            val toLarge = Word64.toLargeInt
            val toInt = Int.fromLarge
            fun getPosition () =
               toInt (bubblesize * (toLarge random) div (toLarge limit))
         in
            if random < limit then SOME (getPosition ()) else NONE
         end
*)
(* [ML] fix proposed by Christof 2012-10-18 *)
      fun iAmResponsible (T this) { bubble, id, version=_ } =
         let
            val random = (#id this) * (docID id)
            val cap = (#capacity this, targetDensity bubble)
            val bubblesize = (Int.toLarge o BasicBubbleType.targetSize) bubble
            val toLarge = Word64.toLargeInt
            val toInt = Int.fromLarge
            fun getPosition () =
               toInt (bubblesize * (toLarge random) div (intResponsibility cap))
         in
            if random < responsibility cap then SOME (getPosition ()) else NONE
         end
      
      fun filterItems callback (nodeID, service) (bubble, items) =
         let
            val node = (peerID nodeID, Service.capacity service)
            val density = targetDensity bubble
            fun select (id, _, _) = isResponsible node density (docID id)
            fun combine (id, version, data) = (nodeID, service, 
               Record.encode { bubble=bubble, id=id, version=version }, data)
         in
            callback (Iterator.map combine (Iterator.filter select items))
         end
      
      fun itemIterator (T this, callback) (id, service) =
         Backend.iterator (#backend this, filterItems callback (id, service))

      (* identify items a neighbor has become responsible for because of 
         density increases *)
      fun findNewlyResponsible callback (nodeID, service) (bubble, items) =
         let
            val node = (peerID nodeID, Service.capacity service)
            val oldDensity = previousDensity bubble
            val density = targetDensity bubble
            fun select (id, _, _) = case docID id of doc =>
               (* is responsible now, but not before *)
               (isResponsible node density doc)
               andalso not (isResponsible node oldDensity doc)
            fun combine (id, version, data) = (nodeID, service, 
               Record.encode { bubble=bubble, id=id, version=version }, data)
         in
            callback (Iterator.map combine (Iterator.filter select items))
         end
      
      (* find items to replicate to neighbors and clean up unnecessary items *)
      fun onRoundSwitch (T this, callback : callback) =
         let
            val neighbors = RoutingTable.iterator (#table this)
            val () = Iterator.app (fn x => Backend.iterator (#backend this, findNewlyResponsible callback x)) neighbors
            
            val responsible = isResponsible (#id this, #capacity this)
            fun getFilter bubble = case targetDensity bubble of density =>
               fn id => responsible density (docID id)
         in
            Backend.cleanup (#backend this, getFilter)
         end
   end

