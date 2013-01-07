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

structure ManagedReplication :> MANAGED_REPLICATION =
   struct
      fun module () = "bubblestorm/bubble/managed/maintainer"

      datatype t = T of {
         types    : BasicBubbleType.t list ref,
         frontend : Frontend.t,
         backend  : Backend.t,
         service  : StorageService.t,
         findStorage    : FindStorage.t,
         findMaintainer : FindMaintainer.t
      }
      
      datatype request = datatype StorageRequest.t

      (* when a new managed bubble type is created *)
      fun register (T { types, ... }, bubble ) =
         case BasicBubbleType.class bubble of
            BasicBubbleType.MANAGED _ => types := bubble :: (!types)
          | _ => raise At (module (), 
                     Fail "tried to register non-maintained bubble type")

      (* get the frontend datas cache *)
      fun getCache bubble =
         case BasicBubbleType.class bubble of
            BasicBubbleType.MANAGED { cache, ... } => cache
          | _ => raise At (module (),
                     Fail "cannot get data cache from non-maintained type")
      
      (* add traffic costs to the bubble type (for the balancer) *)
      fun addCost (bubble, data) = BubbleCostMeasurement.injectCost
         (BasicBubbleType.costMeasurement bubble, data)

      (* insert *)
      fun insert (T { frontend, ... }, { bubble, id, data, done }) =
         let
            val elem = ManagedDataCache.insert (getCache bubble, id, data)
            val () = addCost (bubble, data)
            val () = Frontend.request (frontend, INSERT (bubble, id, data, done))
         in
            elem
         end
      
      (* update *)
      fun update (T { frontend, ... }, { bubble, id, data, done }) =
         let
            val () = ManagedDataCache.update (getCache bubble, id, data)
            val () = addCost (bubble, data)
         in
            Frontend.request (frontend, UPDATE (bubble, id, data, done))
         end

      (* delete *)
      fun delete (T { frontend, ... }, { bubble, id, done }) =
         let
            val () = ManagedDataCache.delete (getCache bubble, id)
         in
            Frontend.request (frontend, DELETE (bubble, id, done))
         end

      (* get *)
      fun get (_, { bubble, id }) = ManagedDataCache.get (getCache bubble, id)

      (* onJoin: offer our storage to the world *)
      fun onJoin (T { types, service, ... }) =
         if List.null (!types) then () else StorageService.start service
      
      (* onJoinComplete: find friends *)
      fun onJoinComplete (T { types, findStorage, findMaintainer, ... }) =
         if List.null (!types) then () else
         let
            (* find an initial set of storage peers *)
            val () = FindStorage.onJoinComplete findStorage
         in
            (* find an initial set of maintainers *)
            FindMaintainer.onJoinComplete findMaintainer
         end

      (* onLeave: remove data and stop getting new friends *)
      fun onLeave (T { types, frontend, findStorage, service, ... }) =
         if List.null (!types) then () else
         let
            (* stop accepting new storage peer offers *)
            val () = FindStorage.onLeave findStorage
            (* stop accepting new maintainers *)
            val () = StorageService.stop service
         in
            (* delete our data from the storage peers and quit them *)
            Frontend.onLeave frontend
         end

      (* onLeaveComplete: reset all maintainers *)
      fun onLeaveComplete (T { types, backend, ... }) =
         if List.null (!types) then () else Backend.flush backend (fn _ => true)

      fun new { state, name, findStorageID, findMaintainerID, statistics } =
         let
            (* the managed bubble types *)
            val types = ref []
            fun getTypes () = !types
            
            (* solve mutual dependency between Backend and JunkManager *)
            val junkAdjuster = ref (fn _ => ())
            fun adjustJunk x = (!junkAdjuster) x
            
            (* create storage peer backend *)
            val backend = Backend.new {
               state   = state,
               types   = getTypes,
               adjustJunk = adjustJunk,
               statistics = statistics
            }

            (* create the storage service *)
            val service = StorageService.new {
               state   = state,
               backend = backend
            }
            
            (* create storage pool manager *)
            val frontend = Frontend.new {
               state   = state,
               types   = getTypes,
               statistics = statistics
            }
            
            (* the find storage bubble *)
            val findStorage = FindStorage.new {
               state   = state,
               types   = types,
               name    = name ^ ".Find_Storage",
               typeID  = findStorageID,
               service = service,
               frontend = frontend,
               statistics = statistics
            }
            
            (* the find maintainer bubble *)
            val findMaintainer = FindMaintainer.new {
               state   = state,
               types   = types,
               name    = name ^ ".Find_Maintainer",
               typeID  = findMaintainerID,
               service = service,
               frontend = frontend
            }

            (* create junk manager *)
            val junkManager = JunkManager.new {
               state = state,
               backend = backend,
               findMaintainer = findMaintainer,
               statistics = statistics
            }
            val () = junkAdjuster := JunkManager.adjust junkManager

            (* hook to the measurement protocol *)
            val status = SystemStats.status o BasicBubbleType.stats
            fun onRoundSwitch _ =
               (* don't waste traffic if there are no bubble types *)
               (* don't try to bubblecast if we're not fully connected *)
               if List.null (getTypes ()) orelse 
                  not (status state = SystemStats.ONLINE) then () else
                  let
                     val targetSize = FindStorage.bubbleSize findStorage
                     val () = Frontend.onRoundSwitch (frontend, targetSize)
                     val () = FindStorage.onRoundSwitch findStorage
                  in
                     JunkManager.onRoundSwitch junkManager
                  end
            val measurement = BasicBubbleType.measurement state
            val () = Measurement.addNotification (measurement, onRoundSwitch)
         in
            T {
               types    = types,
               frontend = frontend,
               backend  = backend,
               service  = service,
               findStorage    = findStorage,
               findMaintainer = findMaintainer
            }
         end
end
