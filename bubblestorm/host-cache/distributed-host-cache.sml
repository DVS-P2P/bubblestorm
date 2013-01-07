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

structure DistributedHostCache =
   struct
      (* TODO move to global config *)
      (* disable publishing and querying for bootstrap nodes *)
      val disableDistributedHostCache = true
      (* bubble type IDs for bootstrap publication and query *)
      val bootstrapPublishBubbleId = 98; (* FIXME should only use negative IDs internally *)
      val bootstrapQueryBubbleId = 99;
      val bootstrapBubbleLabmda = 4.0;
      (* time between join and first host cache query *)
      val hostCacheQueryInitialDelay = Time.fromMinutes 1
      (* interval of regular host cache query *)
      val hostCacheQueryInterval = Time.fromMinutes 60
      (* time before terminating the host cache query *)
      val hostCacheQueryTimeout = Time.fromSeconds 30
      
      val module = "bubblestorm/distributedHostCache"
      
      datatype t = T of {
         hostCache : HostCache.t,
         bootstrapPublishBubble : BubbleType.managed,
         bootstrapPublishItem : ManagedBubble.t option ref,
         hostCacheQueryEvent : Main.Event.t
      }
      
      (* serialization functions *)
      local
         val { toVector, parseSlice, length, ... } = Serial.methods CUSP.Address.t
      in
         val addressToVector = toVector
         val addressFromArraySlice = parseSlice
         val addressDataLength = length
      end
      
      val nullData = Word8Vector.tabulate (0, fn _ => 0w0)
      
      (* --- public API --- *)
      
      fun new (hostCache, master) =
         let
            (* bootstrap publish bubble *)
            val bootstrapDataStore = HashStore.new ()
            val bootstrapPublishBubble =
               BubbleType.newManaged {
                  master      = master,
                  typeId      = bootstrapPublishBubbleId,
                  name        = "distributed-host-cache/announce",
                  priority    = SOME Config.hostcachePriority,
                  reliability = SOME Config.hostcacheReliability,
                  backend     = HashStore.backend (bootstrapDataStore),
                  frontend    = HashStore.frontend (HashStore.new ())
               }
            
            (* bootstrap query *)
            fun bootstrapQueryResponder { query=_, respond } =
               let
                  val () =
                     Log.logExt (Log.DEBUG, fn () => module ^ "/queryResponder",
                        fn () => "Received query for bootstrap nodes")
                  
                  fun writeResult data (SOME stream) =
                     let
                        val () =
                           Log.logExt (Log.DEBUG, fn () => module ^ "/writeResult",
                              fn () => "Writing payload")
                        fun done CUSP.OutStream.READY =
                           CUSP.OutStream.shutdown (stream, fn _ => ())
                         |  done CUSP.OutStream.RESET =
                           (Log.logExt (Log.DEBUG, fn () => module ^ "/writeResult",
                              fn () => "Writing payload aborted")
                           ; CUSP.OutStream.reset stream)
                     in
                        CUSP.OutStream.write (stream, data, done)
                     end
                   | writeResult _ NONE =
                     Log.logExt (Log.DEBUG, fn () => module ^ "/writeResults",
                        fn () => "Not writing payload")
                  
                  fun respondResult (id, data) =
                     (Log.logExt (Log.DEBUG, fn () => module ^ "/respondResult",
                        fn () => "Writing result " ^ ID.toString id)
                     ; respond { id = id, write = writeResult data })
               in
                  Iterator.app respondResult (HashStore.iterator bootstrapDataStore)
               end
            val bootstrapQuery =
               Query.new {
                  master = master,
                  dataBubble = BubbleType.persistentManaged bootstrapPublishBubble,
                  queryBubbleId = bootstrapQueryBubbleId,
                  queryBubbleName = "distributed-host-cache/query",
                  lambda = bootstrapBubbleLabmda,
                  priority = SOME Config.hostcachePriority,
                  reliability = SOME Config.hostcacheReliability,
                  responder = bootstrapQueryResponder
               }
            
            (* host cache query event *)
            fun queryHostCache evt =
               if disableDistributedHostCache then () else
               let
                  (* prepare local cache for update *)
                  val () = HostCache.trimCache hostCache
                  val () = HostCache.decayAvailabilities hostCache
                  
                  fun responseCallback { id=_, stream } =
                     let
                        val data = Word8ArraySlice.full (Word8Array.tabulate (addressDataLength, fn _ => 0w0))
                        fun onRead true =
                           let
                              val addr = addressFromArraySlice data
                              fun onShutdown true =
                                 HostCache.addAddress (hostCache, addr)
                               |  onShutdown false =
                                 Log.logExt (Log.WARNING, fn () => module ^ "/responseCallback",
                                    fn () => "Error reading response")
                           in
                              CUSP.InStream.readShutdown (stream, onShutdown)
                           end
                         |  onRead false =
                           Log.logExt (Log.WARNING, fn () => module ^ "/responseCallback",
                              fn () => "Error reading response")
                     in
                        CUSP.InStream.readFully (stream, data, onRead)
                     end
                  
                  val stop =
                     Query.query (bootstrapQuery, {
                        query = nullData,
                        responseCallback = responseCallback
                     })
                  (* schedule query termination *)
                  val () = Main.Event.scheduleIn (Main.Event.new (fn _ => stop ()), hostCacheQueryTimeout)
               in
                  Main.Event.scheduleIn (evt, hostCacheQueryInterval)
               end
            val hostCacheQueryEvent = Main.Event.new queryHostCache
         in
            T {
               hostCache = hostCache,
               bootstrapPublishBubble = bootstrapPublishBubble,
               bootstrapPublishItem = ref NONE,
               hostCacheQueryEvent = hostCacheQueryEvent
            }
         end
      
      (* publish myself as bootstap node *)
      fun publishBootstrap (T { bootstrapPublishBubble, bootstrapPublishItem, ... }, myAddr) =
         if disableDistributedHostCache then () else
         let
            (* TODO check isSome !bootstrapPublishBubble *)
            val addr = valOf myAddr
            val () =
               Log.logExt (Log.DEBUG, fn () => module,
                  fn () => "Publishing myself (" ^ CUSP.Address.toString addr
                     ^ ") as bootstrap node")
            fun logIt () = Log.logExt (Log.DEBUG, fn () => module,
                  fn () => "Finished publishing myself as bootstrap node")
            val data = addressToVector addr
         in
            case !bootstrapPublishItem of
               SOME bubble => ManagedBubble.update { 
                     bubble = bubble,
                     data = data,
                     done = logIt
                  }
             | NONE => bootstrapPublishItem := 
                  SOME (ManagedBubble.create {
                     typ = bootstrapPublishBubble,
                     id = ID.fromHash data,
                     data = data,
                     done = logIt
                  })
         end
      
      (* unpublish myself as bootstap node *)
      fun unpublishBootstrap (T { bootstrapPublishItem, ... }) =
         let
            val () =
               Log.logExt (Log.DEBUG, fn () => module,
                  fn () => "Unpublishing myself as bootstrap node")
            fun done () = Log.logExt (Log.DEBUG, fn () => module,
                           fn () => "Finished unpublishing myself as bootstrap node")
            val () =
               case !bootstrapPublishItem of
                  SOME item =>
                     ManagedBubble.delete {
                        bubble = item,
                        done = done
                     }
                | NONE => ()
         in
            bootstrapPublishItem := NONE
         end
      
      (* start regularly querying for bootstrap nodes *)
      fun startHostCacheQueries (T { hostCacheQueryEvent, ... }) =
         Main.Event.scheduleIn (hostCacheQueryEvent, hostCacheQueryInitialDelay)
      
      (* stop querying for bootstrap nodes *)
      fun stopHostCacheQueries (T { hostCacheQueryEvent, ... }) =
          Main.Event.cancel hostCacheQueryEvent 
      
   end
