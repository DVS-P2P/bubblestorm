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

structure StorageService :> STORAGE_SERVICE =
   struct
      val module = "bubblestorm/bubble/managed/storage-service"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)
      datatype request = datatype StorageRequest.t

      (* conversation type *)
      local
         open CUSP
         open Conversation
         open Serial
      in
         datatype storageService = STORAGE_SERVICE
         fun storageServiceTy x = Entry.new {
            name     = "managed/storage",
            datatyp  = STORAGE_SERVICE,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.manual,
            sendStatistics    = SOME Stats.sentManagedStorage,
            receiveStatistics = SOME Stats.receivedManagedStorage
         } `bool `int32l $ x
      end

      (* the contact information needed to register at a storage peer *)
      structure Description =
         struct
            structure Order = OrderFromCompare (
               struct
                  type t = CUSP.Address.t * storageService Conversation.Entry.t
                  
                  (* FIXME: we should also compare entries in case the address is
                     re-used by a new peer. Unfortunately, conversation entries have
                     no order defined yet. *)
                  fun compare ((a1, _), (a2, _)) = CUSP.Address.compare (a1, a2)
               end)
            
            open Order
            
            (* FIXME: hash should also include entry *)
            fun hash (address, _) = CUSP.Address.hash address
            
            fun toString (address, _) = CUSP.Address.toString address
            
            (* serializable storage service description *)
            local
               open Serial
            in
               val t = aggregate tuple2 `CUSP.Address.t `storageServiceTy $
            end
            
         end

      datatype t' = T of {
         state   : BasicBubbleType.bubbleState,
         backend : Backend.t,
         service : (storageService Conversation.Entry.t * (unit -> unit)) option
      }
      type t = t' ref
      
      
      fun new { state, backend } =
         ref (T {
            state   = state,
            backend = backend,
            service = NONE
         })

      (* has been started and not stopped again. *)
      fun isRunning (ref (T { service, ... })) = Option.isSome service
      
      (* stop accepting reqistrations. *)
      fun stop (this as ref (T { state, backend, service })) =
         case service of
            NONE => raise At (module, Fail "cannot stop non-running service")
          | SOME (_, close) =>
               let
                  val () = close ()
               in
                  this := T {
                     state = state,
                     backend = backend,
                     service = NONE
                  }
               end

      (* the information needed to contact the service *)
      fun description (ref (T { state, service, ... })) =
         Option.map (fn (entry, _) => (BasicBubbleType.address state, entry)) 
            service
      
      (* retrieve managed data store of a bubbletype *)
      (* FIXME: code duplication! should be in BasicBubbleType *)
      fun getDataStore bubble =
         case BasicBubbleType.class bubble of
            BasicBubbleType.MANAGED { datastore, ... } => datastore
          | _ => raise At (module, Fail "processing request for non-maintained bubble type")

      (* match insert requests against other bubble types *)      
      fun match (maintainer, bubble, id, data, done) () =
         let
            val pos = StorageMaintainer.position maintainer
            val data = Word8VectorSlice.full data
            val () = BasicBubbleType.doMatching (bubble, pos) (id, data)
         in
            done ()
         end

      (* process incoming requests *)
      fun onRequest maintainer (INSERT (bubble, id, data, done)) =
         ManagedDataStore.insert (getDataStore bubble) (id, data, 
                                  match (maintainer, bubble, id, data, done),
                                  StorageMaintainer.bucket maintainer)
        | onRequest _ (UPDATE (bubble, id, data, done)) =
         ManagedDataStore.update (getDataStore bubble) (id, data, done)
        | onRequest maintainer (DELETE (bubble, id, done)) =
         ManagedDataStore.delete (getDataStore bubble) (id, done)
      handle _ => StorageMaintainer.flush maintainer

      (* start accepting reqistrations. *)
      fun start (this as ref (T { state, backend, ... })) =
         if isRunning this then raise At (module, Fail "cannot start running service") else
         let
            (* handle incoming registrations *)
            fun onRegistration conversation bucket position stream =
               case CUSP.Host.remoteAddress (Conversation.host conversation) of
                  SOME remoteAddress =>
                     let
                        val () = log (fn () => "newly registered maintainer " ^ 
                                       CUSP.Address.toString remoteAddress)
                        (* make maintainer representation *)
                        val position = ref position
                        val maintainer = StorageMaintainer.new {
                           bucket = bucket,
                           position = position,
                           conversation = conversation
                        }
                     in
                        (* start receiving *)
                        StorageStream.newMaintainer {
                           state = state,
                           conversation = conversation,
                           stream = stream,
                           position = position,
                           onRequest = onRequest maintainer,
                           whenDead = Backend.addMaintainer (backend, maintainer)
                        }
                     end
                | NONE =>
                     let
                        val () = log (fn () => "resetting bogus storage request")
                     in
                        Conversation.reset conversation
                     end
                  
            (* set up storage service *)
            val service =
               Conversation.advertise (BasicBubbleType.endpoint state, {
                  service = NONE,
                  entryTy = storageServiceTy,
                  entry   = onRegistration
               })
         in
            this := T {
               state = state,
               backend = backend,
               service = SOME service
            }
         end         

      type register = bool -> int -> (CUSP.OutStream.t -> unit) -> unit

      fun register { endpoint, service=(address, entry), complete } =
         (* TODO: do we have to cancel non-responding associate calls? *)
         ignore (Conversation.associate (endpoint, address, {
            entry    = entry,
            entryTy  = storageServiceTy,
            complete = complete : (Conversation.t * register) option -> unit
         }))
   end
