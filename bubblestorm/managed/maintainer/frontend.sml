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

structure Frontend :> FRONTEND =
   struct
      val module = "bubblestorm/bubble/managed/frontend"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)
      fun logStorage (msg, storage) = log (fn () => msg () ^ 
         StorageService.Description.toString (StoragePeer.service storage))

      datatype request = datatype StorageRequest.t
      
      datatype t = T of {
         state   : BasicBubbleType.bubbleState,
         types   : unit -> BasicBubbleType.t list,
         pool    : StoragePool.t,
         bucket  : bool,
         statistics : Stats.managed
      }
                  
      (* callback on completion of store/update/delete request:
         notifies caller when all requests are completed *)
      fun allDone (it, done) =
         let
            val counter = ref (Iterator.length it)
            
            fun doneOne () =
               let
                  val () = counter := !counter - 1
               in
                  if !counter = 0 then done () else ()
               end
         in
            doneOne
         end
         
      (* exec a request on a range of storage peers *)
      fun requestRange (T { pool, ... }, request, range) =
         let
            val it = StoragePool.range (pool, range)
            (* rewrite request to notify completion when the last operation is done *)
            val request = case request of
               INSERT (bubble, id, data, done) =>
                  INSERT (bubble, id, data, allDone (it, done))
             | UPDATE (bubble, id, data, done) =>
                  UPDATE (bubble, id, data, allDone (it, done))
             | DELETE (bubble, id, done) =>
                  DELETE (bubble, id, allDone (it, done))
             (* send the request to a single storage peer *)
             fun exec (_, storage) = StoragePeer.send (storage, request)
         in
            Iterator.app exec it
         end

      (* exec a request on all storage peers responsible for this bubble type *)
      fun request (this, request) =
         let
            val bubble = case request of
               INSERT (bubble, _, _, _) => bubble
             | UPDATE (bubble, _, _, _) => bubble
             | DELETE (bubble, _, _)    => bubble
         in
            requestRange (this, request, Density.bubbleRange bubble)
         end

      (* send/delete bubbles if bubble sizes and/or peer density have changed *)
      fun sendOrDelete { storage, oldDensity, newDensity, bubble, oldSize, newSize } =
         let
            (* retrieve the frontend data cache with our items *)
            fun getCache bubble =                  
               case BasicBubbleType.class bubble of
                  BasicBubbleType.MANAGED { cache, ... } => cache
                | _ => raise At (module, 
                           Fail "impossible: unmanaged bubble type registered")
            (* send requests for all items to the storage peer *)
            fun getItems bubble = ManagedDataCache.iterator (getCache bubble)
            fun mapItems (bubble, map) =
               Iterator.map (fn (id, data) => map (bubble, id, data)) (getItems bubble)
            fun send request = StoragePeer.send (storage, request)
            fun sendAll requests = Iterator.app send requests
            (* insert all items of a bubble time at a peer *)
            fun insertReq (bubble, id, data) = INSERT (bubble, id, data, fn () => ())
            fun insert () = sendAll (mapItems (bubble, insertReq))
            (* delete all items of a bubble time at a peer *)
            fun deleteReq (bubble, id, _) = DELETE (bubble, id, fn () => ())
            fun delete () = sendAll (mapItems (bubble, deleteReq))
            open Density            
         in
            case (oldDensity < oldSize, newDensity < newSize) of
               (false, false) => ()    (* doesn't have it and doesn't need it *)
             | (false, true)  => insert () (* doesn't have it, but needs it *)
             | (true,  false) => delete () (* has it, but doesn't need it *)
             | (true,  true)  => ()        (* has it and needs it *)
         end
         
      (* send all required items to the (new) peer *)
      fun sendItems (T { types, ... }, storage, newDensity, oldDensity) =
         let
            fun sendBubble bubble = sendOrDelete {
               storage    = storage,
               oldDensity = oldDensity,
               newDensity = newDensity,
               bubble     = bubble,
               oldSize    = Density.bubbleSize bubble,
               newSize    = Density.bubbleSize bubble
            }
         in
            List.app sendBubble (types ())
         end

      (* update existing peer *)
      fun updateDensity (this as T { state, pool, ... }, storage, newDensity, oldDensity) =
         let
            val () = logStorage (fn () => "improving storage peer ", storage)
            val () = StoragePool.update (pool, newDensity, storage)
            (* send position update to storage peer *)
            val position = Density.toPosition state newDensity
            val () = StoragePeer.changePosition storage position
            (* send additional items *)
            val () = sendItems (this, storage, newDensity, oldDensity)
         in
            ()
         end
         
      (* update to a smaller position (better for matching and more replicas) *)
      fun onNewStorage (this as T { pool, ... }, newDensity) storage =
         case StoragePool.get (pool, StoragePeer.service storage) of
            NONE => (* add to local pool *)
               let
                  val () = logStorage (fn () => "adding new storage peer ", storage)
                  val () = StoragePool.add (pool, newDensity, storage)
                  val () = sendItems (this, storage, newDensity, Density.maxVal)
               in
                  fn () => StoragePool.remove (pool, storage)
               end
          | SOME (oldDensity, oldStorage) =>
               (* we got two concurrent registrations to the same peer *)
               let
                  val () = logStorage (fn () => "redundant storage peer ", storage)
                  val () = StoragePeer.quit storage (* we don't need the new peer *)
                  val () = if Density.>= (newDensity, oldDensity) then () 
                       else updateDensity (this, oldStorage, newDensity, oldDensity)
               in
                  fn () => () (* we already quit the guy *)
               end

      (* check the storage offer and register or change position *)      
      fun addStorage (this as T { state, pool, bucket, ... })
                      { service, capacity, d1, filter, position } =
         if not (filter bucket) then () (* we're of the wrong kind *) else
            let
               val density = Density.new (state, position, capacity, d1)
            in
               case StoragePool.get (pool, service) of
                  NONE => (* register myself at the (new) storage peer *)
                     let
                        val () = log (fn () => "connecting to storage peer "
                               ^ StorageService.Description.toString service)
                     in
                        StoragePeer.new {
                           state    = state,
                           service  = service,
                           bucket   = bucket,
                           position = Density.toPosition state density,
                           callback = onNewStorage (this, density)
                        }
                     end
                | SOME (oldDensity, storage) =>
                     (* ignore offers to existing peers that don't improve the position *)
                     if Density.>= (density, oldDensity) 
                        then logStorage (fn () => "ignoring storage peer ", storage)
                     else updateDensity (this, storage, density, oldDensity)
            end

      (* remove items and quit a single storage peer *)      
      fun leavePeer (T { types, ... }) (density, storage) =
         let
            (* delete items stored on the storage peer *)
            val service = StoragePeer.service storage
            val () = log (fn () => "truncating " ^ 
                          StorageService.Description.toString service)
            (* remove all items from the peer *)
            fun delete bubble = sendOrDelete {
               storage    = storage,
               oldDensity = density,
               newDensity = Density.maxVal,
               bubble     = bubble,
               oldSize    = Density.bubbleSize bubble,
               newSize    = Density.bubbleSize bubble
            }
            val () = List.app delete (types ())
         in
            StoragePeer.quit storage
         end
         
      (* quit all storage peers *)
      fun onLeave (this as T { pool, ... }) =
         Iterator.app (leavePeer this) (StoragePool.iterator pool)

      (* quit storage peers that have too big positions, they don't have data *)
      fun truncateStorage (T { state, pool, statistics, ... }, pos) =
         let
            fun select (density, storage) =
               if Density.phase density = Density.STABLE
                  then SOME storage
                  else NONE
            val cutoff = Density.fromPosition state pos
            val surplus = StoragePool.range (pool, (cutoff, Density.maxVal))
            val it = Iterator.mapPartial select surplus
            val () = Statistics.add (#truncate statistics) 
                        (Real32.fromInt (Iterator.length it))
         in
            Iterator.app StoragePeer.quit it
         end

      (* adjust storage pool size, peer positions, and items stored on peer,
         when a new measurement result becomes available *)
      fun onRoundSwitch (this as T { state, types, pool, ... }, targetSize) =
         let
            (* get storage peer density change list
               = iterator of (storage, newDensity, oldDensity) *)
            fun getChange (density, storage) =
               (storage, Density.update state density, density)
            val changes = Iterator.map getChange (StoragePool.iterator pool)
            
            (* correct storage pool *)
            fun densityChanged (_, new, old) = Density.!= (new, old)
            fun updatePool (storage, new, _) = StoragePool.update (pool, new, storage)
            val () = Iterator.app updatePool (Iterator.filter densityChanged changes)
            
            (* correct actual positions *)
            val position = Density.toPosition state
            fun updatePos (storage, new, old) =
               if position new = position old then ()
               else StoragePeer.changePosition storage (position new)
            val () = Iterator.app updatePos changes
            
            (* adjust replication of items according to bubble size changes 
               and peer density changes *)
            fun adjustStorage bubble (storage, newDensity, oldDensity) =
               sendOrDelete {
                  storage    = storage,
                  oldDensity = oldDensity,
                  newDensity = newDensity,
                  bubble     = bubble,
                  oldSize    = Density.bubbleSize' bubble,
                  newSize    = Density.bubbleSize bubble
               }
            fun adjustBubble bubble = Iterator.app (adjustStorage bubble) changes
            val () = List.app adjustBubble (types ())
         in
            (* remove unnecessary storage peers. if more peers are required,
               FindStorage will automatically search for us. *)
            truncateStorage (this, targetSize)
         end
         
      fun new { state, types, statistics } =
         let
            val pool = StoragePool.new ()
            fun ifOnline f =
               if SystemStats.status (BasicBubbleType.stats state) = SystemStats.ONLINE 
               then f () else ()
            
            (* storage pool size statistics *)
            val birth = Main.Event.time ()
            fun age () = Stats.getAgeSlot (Time.- (Main.Event.time (), birth))
            fun addCount () = ifOnline (fn () =>
               TimelineStatistics.add (#storage statistics) (age ())
                  (Real32.fromInt (StoragePool.size pool)))
            val () = TimelineStatistics.addPoll (#storage statistics, addCount)
            
            (* storage peer positions histogram *)
            fun pollPositions () =
               let
                  val it = Iterator.map #1 (StoragePool.iterator pool)
                  fun poll density = Statistics.add (#positions statistics)
                     (Real32.fromInt (Density.toPosition state density))
               in
                  Iterator.app poll it
               end
            val () = Statistics.addPoll (#positions statistics, fn () => ifOnline pollPositions)
         in
            T {
               state   = state,
               types   = types,
               pool    = pool,
               (* put this maintainer in the odd or even bucket at random *)
               bucket  = Random.bool (getTopLevelRandom ()),
               statistics = statistics
            }
         end
   end
