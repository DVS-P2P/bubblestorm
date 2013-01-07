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

(* SML glue code for BubbleStorm c-bindings *)

structure Notification = Notification(ID)

(* Handle buckets *)
val bubbleStormBucket : BubbleStorm.t IdBucket.t = IdBucket.new()
val bubbleMasterBucket : BubbleType.master IdBucket.t = IdBucket.new()
val bubbleTypeBasicBucket : BubbleType.t IdBucket.t = IdBucket.new()
val bubbleTypePersistentBucket : BubbleType.persistent IdBucket.t = IdBucket.new()
val bubbleTypeInstantBucket : BubbleType.instant IdBucket.t = IdBucket.new()
val bubbleTypeFadingBucket : BubbleType.fading IdBucket.t = IdBucket.new()
val bubbleTypeManagedBucket : BubbleType.managed IdBucket.t = IdBucket.new()
val bubbleTypeDurableBucket : BubbleType.durable IdBucket.t = IdBucket.new()
val bubbleTypeDurableDatastoreLookupBucket : ((Version.t * Word8Vector.vector option) option -> unit) IdBucket.t = IdBucket.new()
(* val bubbleTypeDurableDatastoreVersionBucket : (Int64.int * Time.t -> unit) IdBucket.t = IdBucket.new() *)
val bubbleTypeDurableDatastoreIteratorBucket : (((ID.t * Version.t * Word8Vector.vector option) Iterator.t -> unit) * ((ID.t * Version.t * Word8Vector.vector option) Ring.t)) IdBucket.t = IdBucket.new()
val bubbleManagedBucket : ManagedBubble.t IdBucket.t = IdBucket.new()
val bubbleDurableBucket : DurableBubble.t IdBucket.t = IdBucket.new()
val idBucket : ID.t IdBucket.t = IdBucket.new()
val notificationBucket : Notification.t IdBucket.t = IdBucket.new()
val notificationResultBucket : Notification.Result.t IdBucket.t = IdBucket.new()
val notificationSendFnBucket : Notification.sendFn IdBucket.t = IdBucket.new()
val queryBucket : Query.t IdBucket.t = IdBucket.new()
val queryRespondBucket : ({ id : ID.t, write : OutStream.t option -> unit } -> unit) IdBucket.t = IdBucket.new()


(* --- BubbleStorm --- *)

fun bubbleStormNew (bandwidth : Real32.real, minBandwidth : Real32.real, port : int, keyHandle : int, encrypt : bool) : int =
   let
      val port = if port > 0 then SOME port else NONE
   in
      case IdBucket.sub (privatekeyBucket, keyHandle) of
         SOME key =>
            IdBucket.alloc (bubbleStormBucket, BubbleStorm.new {
               bandwidth = if bandwidth > 0.0 then SOME bandwidth else NONE,
               minBandwidth = if minBandwidth > 0.0 then SOME minBandwidth else NONE,
               port = port,
               privateKey = key,
               encrypt = encrypt
            })
       | NONE => ~1
   end
val bubbleStormNew = handleExceptionInt bubbleStormNew


fun bubbleStormNewWithEndpoint (bandwidth : Real32.real, minBandwidth : Real32.real, endpointHandle : int) : int =
   case IdBucket.sub (endpointBucket, endpointHandle) of
      SOME ep =>
         IdBucket.alloc (bubbleStormBucket, BubbleStorm.newWithEndpoint {
            bandwidth = if bandwidth > 0.0 then SOME bandwidth else NONE,
            minBandwidth = if minBandwidth > 0.0 then SOME minBandwidth else NONE,
            endpoint = ep
         })
    | NONE => ~1
val bubbleStormNewWithEndpoint = handleExceptionInt bubbleStormNewWithEndpoint


fun bubbleStormCreate (bsHandle : int, addrHandle : int, createCb : ptr, createCbData : ptr) : int =
   let
      val createCbP = _import * : ptr -> ptr -> unit;
      fun createCbFn () = (createCbP createCb) createCbData
   in
      case (IdBucket.sub (bubbleStormBucket, bsHandle), IdBucket.sub (addressBucket, addrHandle)) of
         (SOME bs, SOME addr) => (BubbleStorm.create(bs, addr, createCbFn); 0)
       | _ => ~1
   end
val bubbleStormCreate = handleExceptionInt bubbleStormCreate


fun bubbleStormJoin (bsHandle : int, joinCb : ptr, joinCbData : ptr) : int =
   let
      val joinCbP = _import * : ptr -> ptr -> unit;
      fun joinCbFn () = (joinCbP joinCb) joinCbData
   in
      case IdBucket.sub (bubbleStormBucket, bsHandle) of
         SOME bs => (BubbleStorm.join (bs, joinCbFn); 0)
       | _ => ~1
   end
val bubbleStormJoin = handleExceptionInt bubbleStormJoin


fun bubbleStormLeave (bsHandle : int, leaveCb : ptr, leaveCbData : ptr) : int =
   let
      val leaveCbP = _import * : ptr -> ptr -> unit;
      fun leaveCbFn () = (leaveCbP leaveCb) leaveCbData
   in
      case IdBucket.sub (bubbleStormBucket, bsHandle) of
         SOME bs => (BubbleStorm.leave (bs, leaveCbFn); 0)
       | _ => ~1
   end
val bubbleStormLeave = handleExceptionInt bubbleStormLeave


fun bubbleStormEndpoint (bsHandle : int) : int =
   case IdBucket.sub (bubbleStormBucket, bsHandle) of
      SOME bs => IdBucket.alloc (endpointBucket, BubbleStorm.endpoint bs)
    | _ => ~1
val bubbleStormEndpoint = handleExceptionInt bubbleStormEndpoint


fun bubbleStormBubbleMaster (bsHandle : int) : int =
   case IdBucket.sub (bubbleStormBucket, bsHandle) of
      SOME bs => IdBucket.alloc (bubbleMasterBucket, BubbleStorm.bubbleMaster bs)
    | _ => ~1
val bubbleStormBubbleMaster = handleExceptionInt bubbleStormBubbleMaster


fun bubbleStormAddress (bsHandle : int) : int =
   case IdBucket.sub (bubbleStormBucket, bsHandle) of
      SOME bs =>
         (case BubbleStorm.address bs of
            SOME addr => IdBucket.alloc (addressBucket, addr)
          | NONE => ~2)
    | NONE => ~1
val bubbleStormAddress = handleExceptionInt bubbleStormAddress


fun bubbleStormSaveHostCache' (bsHandle : int, dataLen : ptr) : Word8Vector.vector =
   case IdBucket.sub (bubbleStormBucket, bsHandle) of
      SOME bs => returnDataVector (SOME (BubbleStorm.saveHostCache bs), dataLen)
    | NONE => returnDataVector (NONE, dataLen)
fun bubbleStormSaveHostCache (bsHandle, dataLen) =
   handleExceptionData (bubbleStormSaveHostCache', dataLen) (bsHandle, dataLen)


fun bubbleStormLoadHostCache (bsHandle : int, data : ptr, dataLen : int, bootstrapHandle : int) : int =
   let
      val bootstrap =
         if (bootstrapHandle >= 0)
         then
            case IdBucket.sub (addressBucket, bootstrapHandle) of
               SOME boot => SOME (SOME boot)
             | NONE => NONE
         else SOME NONE
   in
      case (IdBucket.sub (bubbleStormBucket, bsHandle), bootstrap) of
         (SOME bs, SOME boot) =>
            (BubbleStorm.loadHostCache (bs, {
               data = getDataVector (data, dataLen),
               wellKnown = [],
               bootstrap = boot
            }); 0)
      | _ => ~1
   end
val bubbleStormLoadHostCache = handleExceptionInt bubbleStormLoadHostCache


fun bubbleStormSetLanMode (enable : bool) : int =
   (BubbleStorm.setLanMode enable; 0)
val bubbleStormSetLanMode = handleExceptionInt bubbleStormSetLanMode


val (bubbleStormDup, bubbleStormFree) = bucketOps bubbleStormBucket


(* --- BubbleMaster --- *)

fun bubbleMasterNewInstant (bmHandle : int, id : int, priority : Real32.real) : int =
   let
      val prio = if (Real32.isFinite priority) then SOME priority else NONE
   in
      case IdBucket.sub (bubbleMasterBucket, bmHandle) of
         SOME bm =>
            IdBucket.alloc (bubbleTypeInstantBucket, BubbleType.newInstant {
               master = bm,
               name = "", (* TODO *)
               typeId = id,
               priority = prio,
               reliability = NONE (* TODO port to bindings *)
            })
       | NONE => ~1
   end
val bubbleMasterNewInstant = handleExceptionInt bubbleMasterNewInstant


fun bubbleMasterNewFading (bmHandle : int, id : int, priority : Real32.real, handler : ptr, handlerData : ptr) : int =
   let
      val prio = if (Real32.isFinite priority) then SOME priority else NONE
      val handlerP = _import * : ptr -> int * Word8.word vector * int * int * ptr -> unit;
      fun handlerFn (id, data) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
            val (base, ofs, len) = Word8VectorSlice.base data
         in
            (handlerP handler) (idHandle, base, ofs, len, handlerData)
         end
   in
      case IdBucket.sub (bubbleMasterBucket, bmHandle) of
         SOME bm =>
            IdBucket.alloc (bubbleTypeFadingBucket, BubbleType.newFading {
               master = bm,
               name = "", (* TODO *)
               typeId = id,
               priority = prio,
               reliability = NONE, (* TODO port to bindings *)
               store = handlerFn
            })
       | NONE => ~1
   end
val bubbleMasterNewFading = handleExceptionInt bubbleMasterNewFading


fun bubbleMasterNewManaged (bmHandle : int, id : int, priority : Real32.real,
      insertHandler : ptr, updateHandler : ptr, deleteHandler : ptr, (*getHandler : ptr,*)
      flushHandler : ptr, sizeHandler : ptr, handlerData : ptr) : int =
   let
      val prio = if (Real32.isFinite priority) then SOME priority else NONE
      val insertHandlerP = _import * : ptr -> int * Word8.word vector * int * int * bool * ptr -> unit;
      fun insertHandlerFn ( id, data, done, bucket ) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
(*             val (base, ofs, len) = Word8VectorSlice.base data *)
            val (base, ofs, len) = (data, 0, Word8Vector.length data)
         in
            done ((insertHandlerP insertHandler) (idHandle, base, ofs, len, bucket, handlerData))
            (* TODO asynchronous response from Java/C++ *)
         end
      val updateHandlerP = _import * : ptr -> int * Word8.word vector * int * int * ptr -> unit;
      fun updateHandlerFn ( id, data, done ) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
(*             val (base, ofs, len) = Word8VectorSlice.base data *)
            val (base, ofs, len) = (data, 0, Word8Vector.length data)
         in
            done ((updateHandlerP updateHandler) (idHandle, base, ofs, len, handlerData))
            (* TODO asynchronous response from Java/C++ *)
         end
      val deleteHandlerP = _import * : ptr -> int * ptr -> unit;
      fun deleteHandlerFn ( id, done ) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
         in
            done ((deleteHandlerP deleteHandler) (idHandle, handlerData))
            (* TODO asynchronous response from Java/C++ *)
         end
(*       val getHandlerP = _import * : ptr -> int * ptr -> unit; *)
      fun getHandlerFn ( (*id*) _ ) =
         let
(*             val idHandle = IdBucket.alloc (idBucket, id) *)
         in
            NONE (* TODO -- (this is not needed right now) *)
            (* TODO asynchronous response from Java/C++ *)
         end
      val flushHandlerP = _import * : ptr -> bool * ptr -> unit;
      fun flushHandlerFn ( filter ) =
         (if (filter false) then (flushHandlerP flushHandler) (false, handlerData) else ()
         ; if (filter true) then (flushHandlerP flushHandler) (true, handlerData) else ())
      val sizeHandlerP = _import * : ptr -> ptr -> int;
      fun sizeHandlerFn () =
         (sizeHandlerP sizeHandler) handlerData
      val datastore =
         ManagedDataStore.new {
            insert = insertHandlerFn,
            update = updateHandlerFn,
            delete = deleteHandlerFn,
            get    = getHandlerFn,
            flush  = flushHandlerFn,
            size   = sizeHandlerFn
         }
   in
      case IdBucket.sub (bubbleMasterBucket, bmHandle) of
         SOME bm =>
            IdBucket.alloc (bubbleTypeManagedBucket, BubbleType.newManaged {
               master = bm,
               name = "", (* TODO *)
               typeId = id,
               priority = prio,
               reliability = NONE, (* TODO port to bindings *)
               datastore = datastore
            })
       | NONE => ~1
   end
val bubbleMasterNewManaged = handleExceptionInt bubbleMasterNewManaged


fun bubbleMasterNewDurable (bmHandle : int, id : int, priority : Real32.real,
      storeHandler : ptr, lookupHandler : ptr, removeHandler : ptr, (*versionHandler : ptr,*)
      iteratorHandler : ptr, sizeHandler : ptr, handlerData : ptr) : int =
   let
      val prio = if (Real32.isFinite priority) then SOME priority else NONE
      
      val storeHandlerP = _import * : ptr -> int * Int64.int * Int64.int * Word8.word vector * int * int * ptr -> unit;
      fun storeHandlerFn ( id, version, data, done ) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
            val (base, ofs, len) = case data of
               SOME data => (data, 0, Word8Vector.length data)
             | NONE => (Word8Vector.tabulate (0, fn _ => 0w0), 0, ~1)
            val (counter, time) = Version.toValues version
         in
            ((storeHandlerP storeHandler) (idHandle, counter, time, base, ofs, len, handlerData)
            ; done true) (* store cannot fail with current interface (FIXME?) *)
         end
      val lookupHandlerP = _import * : ptr -> int * int * ptr -> unit;
      fun lookupHandlerFn ( id, resultCb ) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
            val lookupCbId = IdBucket.alloc (bubbleTypeDurableDatastoreLookupBucket, resultCb)
         in
            (lookupHandlerP lookupHandler) (idHandle, lookupCbId, handlerData)
            (* (invokes asynchronous response from Java/C++) *)
         end
      val removeHandlerP = _import * : ptr -> int * ptr -> unit;
      fun removeHandlerFn id =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
         in
            (removeHandlerP removeHandler) (idHandle, handlerData)
         end
      val iteratorHandlerP = _import * : ptr -> int * ptr -> unit;
      fun iteratorHandlerFn iteratorCb =
         let
            val iteratorCbId = IdBucket.alloc (bubbleTypeDurableDatastoreIteratorBucket, (iteratorCb, Ring.new ()))
         in
            (iteratorHandlerP iteratorHandler) (iteratorCbId, handlerData)
            (* (invokes asynchronous response from Java/C++) *)
         end
      val sizeHandlerP = _import * : ptr -> ptr -> int;
      fun sizeHandlerFn () =
         (sizeHandlerP sizeHandler) handlerData
      
      val datastore =
         DurableDataStore.new {
            store    = storeHandlerFn,
            lookup   = lookupHandlerFn,
            remove   = removeHandlerFn,
            iterator = iteratorHandlerFn,
            size     = sizeHandlerFn
         }
   in
      case IdBucket.sub (bubbleMasterBucket, bmHandle) of
         SOME bm =>
            IdBucket.alloc (bubbleTypeDurableBucket, BubbleType.newDurable {
               master = bm,
               name = "", (* TODO *)
               typeId = id,
               priority = prio,
               reliability = NONE, (* TODO port to bindings *)
               datastore = datastore
            })
       | NONE => ~1
   end
val bubbleMasterNewManaged = handleExceptionInt bubbleMasterNewManaged


val (bubbleMasterDup, bubbleMasterFree) = bucketOps bubbleMasterBucket


(* --- BubbleType Basic --- *)

fun bubbleTypeBasicMatch (subjectHandle : int, objectHandle : int, lambda : Real64.real, handler : ptr, handlerData : ptr) : int =
   let
      val handlerP = _import * : ptr -> Word8.word vector * int * int * ptr -> unit;
      fun handlerFn data =
         let
            val (base, ofs, len) = Word8VectorSlice.base data
         in
            (handlerP handler) (base, ofs, len, handlerData)
         end
   in
      case (IdBucket.sub (bubbleTypeBasicBucket, subjectHandle), IdBucket.sub (bubbleTypePersistentBucket, objectHandle)) of
         (SOME subject, SOME object) => 
            (BubbleType.match {
               subject = subject,
               object = object,
               lambda = lambda,
               handler = handlerFn
            }; 0)
       | _ => ~1
   end
val bubbleTypeBasicMatch = handleExceptionInt bubbleTypeBasicMatch


fun bubbleTypeBasicTypeId (btHandle : int) : int =
   case IdBucket.sub (bubbleTypeBasicBucket, btHandle) of
      SOME bt => BubbleType.typeId bt
    | _ => ~1   
val bubbleTypeBasicTypeId = handleExceptionInt bubbleTypeBasicTypeId

(* TODO: name, priority, ... *)

fun bubbleTypeBasicDefaultSize (btHandle : int) : int =
   case IdBucket.sub (bubbleTypeBasicBucket, btHandle) of
      SOME bt => BubbleType.defaultSize bt
    | _ => ~1   
val bubbleTypeBasicDefaultSize = handleExceptionInt bubbleTypeBasicDefaultSize


val (bubbleTypeBasicDup, bubbleTypeBasicFree) = bucketOps bubbleTypeBasicBucket


(* --- BubbleType Persistent --- *)

fun bubbleTypePersistentMatchWithID (subjectHandle : int, objectHandle : int, lambda : Real64.real, handler : ptr, handlerData : ptr) : int =
   let
      val handlerP = _import * : ptr -> int * Word8.word vector * int * int * ptr -> unit;
      fun handlerFn (id, data) =
         let
            val idHandle = IdBucket.alloc (idBucket, id)
            val (base, ofs, len) = Word8VectorSlice.base data
         in
            (handlerP handler) (idHandle, base, ofs, len, handlerData)
         end
   in
      case (IdBucket.sub (bubbleTypePersistentBucket, subjectHandle), IdBucket.sub (bubbleTypePersistentBucket, objectHandle)) of
         (SOME subject, SOME object) => 
            (BubbleType.matchWithID {
               subject = subject,
               object = object,
               lambda = lambda,
               handler = handlerFn
            }; 0)
       | _ => ~1
   end
val bubbleTypePersistentMatchWithID = handleExceptionInt bubbleTypePersistentMatchWithID


val (bubbleTypePersistentDup, bubbleTypePersistentFree) = bucketOps bubbleTypePersistentBucket


(* --- BubbleType Instant --- *)

fun bubbleTypeInstantBasic (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeInstantBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypeBasicBucket, BubbleType.basicInstant bt)
    | _ => ~1
val bubbleTypeInstantBasic = handleExceptionInt bubbleTypeInstantBasic


val (bubbleTypeInstantDup, bubbleTypeInstantFree) = bucketOps bubbleTypeInstantBucket


(* --- BubbleType Fading --- *)

fun bubbleTypeFadingBasic (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeFadingBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypeBasicBucket, BubbleType.basicFading bt)
    | _ => ~1
val bubbleTypeFadingBasic = handleExceptionInt bubbleTypeFadingBasic


fun bubbleTypeFadingPersistent (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeFadingBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypePersistentBucket, BubbleType.persistentFading bt)
    | _ => ~1
val bubbleTypeFadingPersistent = handleExceptionInt bubbleTypeFadingPersistent


val (bubbleTypeFadingDup, bubbleTypeFadingFree) = bucketOps bubbleTypeFadingBucket


(* --- BubbleType Managed --- *)

fun bubbleTypeManagedBasic (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeManagedBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypeBasicBucket, BubbleType.basicManaged bt)
    | _ => ~1
val bubbleTypeManagedBasic = handleExceptionInt bubbleTypeManagedBasic


fun bubbleTypeManagedPersistent (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeManagedBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypePersistentBucket, BubbleType.persistentManaged bt)
    | _ => ~1
val bubbleTypeManagedPersistent = handleExceptionInt bubbleTypeManagedPersistent


val (bubbleTypeManagedDup, bubbleTypeManagedFree) = bucketOps bubbleTypeManagedBucket


(* --- BubbleType Durable --- *)

fun bubbleTypeDurableBasic (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeDurableBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypeBasicBucket, BubbleType.basicDurable bt)
    | _ => ~1
val bubbleTypeDurableBasic = handleExceptionInt bubbleTypeDurableBasic


fun bubbleTypeDurablePersistent (btHandle : int) : int =
   case (IdBucket.sub (bubbleTypeDurableBucket, btHandle)) of
      SOME bt => IdBucket.alloc(bubbleTypePersistentBucket, BubbleType.persistentDurable bt)
    | _ => ~1
val bubbleTypeDurablePersistent = handleExceptionInt bubbleTypeDurablePersistent


val (bubbleTypeDurableDup, bubbleTypeDurableFree) = bucketOps bubbleTypeDurableBucket


(* --- BubbleType Durable Datastore --- *)

fun bubbleTypeDurableDatastoreLookupCb (cbHandle : int, version : Int64.int, time : Int64.int,
      data : ptr, dataLen : int) : int =
   case (IdBucket.sub (bubbleTypeDurableDatastoreLookupBucket, cbHandle)) of
      SOME cb =>
         ( if version >= 0 (* -> have valid version *)
           then
              if dataLen >= 0 (* -> have data *)
              then cb (SOME (Version.fromValues (version, time), SOME (getDataVector (data, dataLen))))
              else cb (SOME (Version.fromValues (version, time), NONE))
           else cb NONE (* -> have nothing *)
         ; IdBucket.free (bubbleTypeDurableDatastoreLookupBucket, cbHandle)
         ; 0)
       | _ => ~1
val bubbleTypeDurableDatastoreLookupCb = handleExceptionInt bubbleTypeDurableDatastoreLookupCb

(* val (bubbleTypeDurableDatastoreGetDup, bubbleTypeDurableDatastoreGetFree) = bucketOps bubbleTypeDurableDatastoreGetBucket *)


(*fun bubbleTypeDurableDatastoreVersionCb (cbHandle : int, version : Int64.int, time : Int64.int) : int =
   case (IdBucket.sub (bubbleTypeDurableDatastoreVersionBucket, cbHandle)) of
      SOME cb =>
         ( cb (version, Time.fromNanoseconds64 time)
         ; IdBucket.free (bubbleTypeDurableDatastoreVersionBucket, cbHandle)
         ; 0)
       | _ => ~1
val bubbleTypeDurableDatastoreVersionCb = handleExceptionInt bubbleTypeDurableDatastoreVersionCb*)

(* val (bubbleTypeDurableDatastoreVersionDup, bubbleTypeDurableDatastoreVersionFree) = bucketOps bubbleTypeDurableDatastoreVersionBucket *)


fun bubbleTypeDurableDatastoreIteratorCb (cbHandle : int, idHandle: int, version : Int64.int, time : Int64.int, data : ptr, dataLen : int) : int =
   let
(*      ( * signature: (cbData, idHandle out, version out, time out, data len out) -> data ptr * )
      val nextCbP = _import * : ptr -> ptr * int ref * Int64.int ref * Int64.int ref * int ref -> ptr;
      fun iteratorNext () =
         let
            val () = TextIO.print ("TODO: Durable datastore list iterator!!!\n")
( *             (cbData, idHandle out, version out, time out, data len out) * )
( *             val dataPtr = (nextCbP nextCb) () * )
         in
            Iterator.EOF ( * TODO * )
         end
      (* TODO callback for release when iterator is not used anymore *)*)
   in
(*      case (IdBucket.sub (bubbleTypeDurableDatastoreListBucket, cbHandle)) of
         SOME cb =>
            ( cb (Iterator.SKIP iteratorNext)
            ; IdBucket.free (bubbleTypeDurableDatastoreListBucket, cbHandle)
            ; 0)
          | _ => ~1*)
      if idHandle >= 0
      then (* push next element *)
         case (IdBucket.sub (bubbleTypeDurableDatastoreIteratorBucket, cbHandle),
               IdBucket.sub (idBucket, idHandle)) of
            (SOME (_, ring), SOME id) =>
               (Ring.addTail (ring, Ring.wrap (
                  id,
                  Version.fromValues (version, time),
                  if dataLen >= 0 then SOME (getDataVector (data, dataLen)) else NONE)
               )
               ; 0)
          | _ => ~1
      else (* done, invoke callback with data iterator *)
         case IdBucket.sub (bubbleTypeDurableDatastoreIteratorBucket, cbHandle) of
            SOME (cb, ring) =>
               (cb (Iterator.map Ring.unwrap (Ring.iterator ring))
               ; IdBucket.free (bubbleTypeDurableDatastoreIteratorBucket, cbHandle)
               ; 0)
          | NONE => ~1
   end
val bubbleTypeDurableDatastoreIteratorCb = handleExceptionInt bubbleTypeDurableDatastoreIteratorCb


(* --- Bubble Instant --- *)

fun bubbleInstantCreate (typeHandle : int, data : ptr, dataLen : int) : int =
   case IdBucket.sub (bubbleTypeInstantBucket, typeHandle) of
      SOME bt =>
         (InstantBubble.create {
            typ = bt,
            data = getDataVector (data, dataLen)
         }; 0)
      | _ => ~1
val bubbleInstantCreate = handleExceptionInt bubbleInstantCreate

(* TODO: createPartially *)


(* --- Bubble Fading --- *)

fun bubbleFadingCreate (btHandle : int, idHandle : int, data : ptr, dataLen : int) : int =
   case (IdBucket.sub (bubbleTypeFadingBucket, btHandle), IdBucket.sub (idBucket, idHandle)) of
      (SOME bt, SOME id) =>
         (ignore (FadingBubble.create { (* TODO export PersistentBubble type *)
            typ = bt,
            id = id,
            data = getDataVector (data, dataLen)
         }); 0)
      | _ => ~1
val bubbleFadingCreate = handleExceptionInt bubbleFadingCreate

(* TODO: createPartially *)


(* --- Bubble Managed --- *)

fun bubbleManagedInsert (btHandle : int, idHandle : int, data : ptr, dataLen : int,
      doneHandler : ptr, doneHandlerData : ptr) : int =
   let
      val doneHandlerP = _import * : ptr -> ptr -> unit;
      fun doneHandlerFn () =
         (doneHandlerP doneHandler) (doneHandlerData)
   in
      case (IdBucket.sub (bubbleTypeManagedBucket, btHandle), IdBucket.sub (idBucket, idHandle)) of
         (SOME bt, SOME id) =>
            IdBucket.alloc (bubbleManagedBucket, ManagedBubble.insert {
               typ = bt,
               id = id,
               data = getDataVector (data, dataLen),
               done = doneHandlerFn
            })
       | _ => ~1
   end
val bubbleManagedInsert = handleExceptionInt bubbleManagedInsert


fun bubbleManagedId (bubbleHandle : int) : int =
   case IdBucket.sub (bubbleManagedBucket, bubbleHandle) of
      SOME bubble =>
         IdBucket.alloc (idBucket, ManagedBubble.id bubble)
    | NONE => ~1
val bubbleManagedId = handleExceptionInt bubbleManagedId


fun bubbleManagedData' (bubbleHandle : int, dataLen : ptr) : Word8Vector.vector =
   case IdBucket.sub (bubbleManagedBucket, bubbleHandle) of
      SOME bubble =>
         returnDataVector (SOME (ManagedBubble.data bubble), dataLen)
    | NONE => returnDataVector (NONE, dataLen)
fun bubbleManagedData (bsHandle, dataLen) =
   handleExceptionData (bubbleManagedData', dataLen) (bsHandle, dataLen)


fun bubbleManagedUpdate (bubbleHandle : int, data : ptr, dataLen : int,
      doneHandler : ptr, doneHandlerData : ptr) : int =
   let
      val doneHandlerP = _import * : ptr -> ptr -> unit;
      fun doneHandlerFn () =
         (doneHandlerP doneHandler) (doneHandlerData)
   in
      case IdBucket.sub (bubbleManagedBucket, bubbleHandle) of
         SOME bubble =>
            (ManagedBubble.update {
               bubble = bubble,
               data = getDataVector (data, dataLen),
               done = doneHandlerFn
            }; 0)
       | _ => ~1
   end
val bubbleManagedUpdate = handleExceptionInt bubbleManagedUpdate


fun bubbleManagedDelete (bubbleHandle : int, doneHandler : ptr, doneHandlerData : ptr) : int =
   let
      val doneHandlerP = _import * : ptr -> ptr -> unit;
      fun doneHandlerFn () =
         (doneHandlerP doneHandler) (doneHandlerData)
   in
      case IdBucket.sub (bubbleManagedBucket, bubbleHandle) of
         SOME bubble =>
            (ManagedBubble.delete {
               bubble = bubble,
               done = doneHandlerFn
            }; 0)
       | _ => ~1
   end
val bubbleManagedDelete = handleExceptionInt bubbleManagedDelete


val (bubbleManagedDup, bubbleManagedFree) = bucketOps bubbleManagedBucket


(* --- Bubble Durable --- *)

fun bubbleDurableLookup (btHandle : int, idHandle : int, receiveHandler : ptr, receiveHandlerData : ptr) : int =
   let
      val receiveHandlerP = _import * : ptr -> int * ptr -> unit;
      fun receiveHandlerFn bubble =
         let
            val bubbleHandle = IdBucket.alloc (bubbleDurableBucket, bubble)
         in
            (receiveHandlerP receiveHandler) (bubbleHandle, receiveHandlerData)
         end
   in
      case (IdBucket.sub (bubbleTypeDurableBucket, btHandle), IdBucket.sub (idBucket, idHandle)) of
         (SOME bt, SOME id) =>
            IdBucket.alloc (abortableBucket, DurableBubble.lookup {
               typ = bt,
               id = id,
               receive = receiveHandlerFn
            })
       | _ => ~1
   end
val bubbleDurableLookup = handleExceptionInt bubbleDurableLookup


fun bubbleDurableCreate (btHandle : int, idHandle : int, data : ptr, dataLen : int) : int =
	case (IdBucket.sub (bubbleTypeDurableBucket, btHandle), IdBucket.sub (idBucket, idHandle)) of
		(SOME bt, SOME id) =>
			IdBucket.alloc (bubbleDurableBucket, DurableBubble.create {
				typ = bt,
				id = id,
				data = getDataVector (data, dataLen)
			})
		| _ => ~1
val bubbleDurableCreate = handleExceptionInt bubbleDurableCreate


fun bubbleDurableId (bubbleHandle : int) : int =
   case IdBucket.sub (bubbleDurableBucket, bubbleHandle) of
      SOME bubble =>
         IdBucket.alloc (idBucket, DurableBubble.id bubble)
    | NONE => ~1
val bubbleDurableId = handleExceptionInt bubbleDurableId


fun bubbleDurableData' (bubbleHandle : int, dataLen : ptr) : Word8Vector.vector =
   case IdBucket.sub (bubbleDurableBucket, bubbleHandle) of
      SOME bubble =>
         returnDataVector (SOME (DurableBubble.data bubble), dataLen)
    | NONE => returnDataVector (NONE, dataLen)
fun bubbleDurableData (bsHandle, dataLen) =
   handleExceptionData (bubbleDurableData', dataLen) (bsHandle, dataLen)


fun bubbleDurableUpdate (bubbleHandle : int, data : ptr, dataLen : int) : int =
   case IdBucket.sub (bubbleDurableBucket, bubbleHandle) of
      SOME bubble =>
         (DurableBubble.update {
            bubble = bubble,
            data = getDataVector (data, dataLen)
         }; 0)
      | _ => ~1
val bubbleDurableUpdate = handleExceptionInt bubbleDurableUpdate


fun bubbleDurableDelete (bubbleHandle : int) : int =
   case IdBucket.sub (bubbleDurableBucket, bubbleHandle) of
      SOME bubble =>
         (DurableBubble.delete bubble
         ; 0)
      | _ => ~1
val bubbleDurableDelete = handleExceptionInt bubbleDurableDelete


val (bubbleDurableDup, bubbleDurableFree) = bucketOps bubbleDurableBucket


(* --- ID --- *)

fun idFromHash (data : ptr, dataLen : int) : int =
   let
      val dataVector = getDataVector (data, dataLen)
      val id = ID.fromHash dataVector
   in
      IdBucket.alloc (idBucket, id)
   end
val idFromHash = handleExceptionInt idFromHash


fun idFromRandom () : int =
   let
      val id = ID.fromRandom (getTopLevelRandom ())
   in
      IdBucket.alloc (idBucket, id)
   end
val idFromRandom = handleExceptionInt idFromRandom


fun idFromBytes (data : ptr) : int =
   let
      val {length, fromVector, ...} = Serial.methods ID.t
      val dataVector = getDataVector (data, length)
      val id = fromVector dataVector
   in
      IdBucket.alloc (idBucket, id)
   end
val idFromBytes = handleExceptionInt idFromBytes


fun idToBytes' (idHandle : int, dataLen : ptr) : Word8Vector.vector =
   let
      val {length, toVector, ...} = Serial.methods ID.t
   in
      case IdBucket.sub (idBucket, idHandle) of
         SOME id =>
            (MLton.Pointer.setInt32 (dataLen, 0, Int32.fromInt length)
            ; toVector id)
       | NONE =>
            (MLton.Pointer.setInt32 (dataLen, 0, Int32.fromInt ~1)
            ; Word8Vector.tabulate (0, fn _ => 0w0))
   end
fun idToBytes (idHandle, dataLen) =
   handleExceptionData (idToBytes', dataLen) (idHandle, dataLen)


fun idToString' (idHandle : int, strLen : ptr) : string =
   let
      val str = case IdBucket.sub (idBucket, idHandle) of
         SOME id => SOME (ID.toString id)
       | NONE    => NONE
   in
      returnString (str, strLen)
   end
fun idToString (idHandle, strLen) =
   handleExceptionString (idToString', strLen) (idHandle, strLen)


fun idEquals (aHandle : int, bHandle : int) : int =
   case (IdBucket.sub (idBucket, aHandle), IdBucket.sub (idBucket, bHandle)) of
      (SOME a, SOME b) => if ID.== (a, b) then 1 else 0
    | _ => ~1
val idEquals = handleExceptionInt idEquals


fun idHash (idHandle : int) : Int64.int =
   case IdBucket.sub (idBucket, idHandle) of
      SOME id =>
         (Int64.fromLarge o Word32.toLargeInt)
            (#1 (Lookup3.make ID.hash (id, 0wx1234abcd)))
    | NONE => ~1
val idHash = handleExceptionInt64 idHash


val (idDup, idFree) = bucketOps idBucket


(* --- Notification --- *)

fun notificationNew (epHandle : int, resultReceiverFn : ptr, resultReceiverData : ptr) : int =
   let
      val resultReceiverP = _import * : ptr -> int * ptr -> unit;
      fun resultReceiver result =
         (resultReceiverP resultReceiverFn) (IdBucket.alloc (notificationResultBucket, result), resultReceiverData)
   in
      case IdBucket.sub (endpointBucket, epHandle) of
         SOME ep =>
            IdBucket.alloc (notificationBucket, Notification.new {
               endpoint = ep,
               resultReceiver = resultReceiver
            })
       | NONE => ~1
   end
val notificationNew = handleExceptionInt notificationNew


fun notificationClose (notHandle : int) : int =
   case IdBucket.sub (notificationBucket, notHandle) of
      SOME not => (Notification.close not; 0)
    | NONE => ~1
val notificationClose = handleExceptionInt notificationClose


fun notificationMaxEncodedLength () : int =
   Notification.maxEncodedLength
val notificationMaxEncodedLength = handleExceptionInt notificationMaxEncodedLength


fun notificationEncode' (notHandle : int, localAddrHandle : int, dataLen : ptr) : Word8Vector.vector =
   case (IdBucket.sub (notificationBucket, notHandle), IdBucket.sub (addressBucket, localAddrHandle)) of
      (SOME not, SOME localAddr) => returnDataVector (SOME (Notification.encode (not, localAddr)), dataLen)
    | _ => returnDataVector (NONE, dataLen)
fun notificationEncode (notHandle, localAddrHandle, dataLen) =
   handleExceptionData (notificationEncode', dataLen) (notHandle, localAddrHandle, dataLen)


fun notificationDecode (data : ptr, dataLen : ptr, epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep =>
         let
            val maxLen = Int.min (MLton.Pointer.getInt32 (dataLen, 0), Notification.maxEncodedLength)
            val dataSlice = Word8VectorSlice.full (getDataVector (data, maxLen))
            val (sendFn, len) = Notification.decode (dataSlice, ep)
            val () = MLton.Pointer.setInt32 (dataLen, 0, len)
         in
            IdBucket.alloc (notificationSendFnBucket, sendFn)
         end
    | NONE => ~1
val notificationDecode = handleExceptionInt notificationDecode


val (notificationDup, notificationFree) = bucketOps notificationBucket


fun notificationResultId (resultHandle : int) : int =
   case IdBucket.sub (notificationResultBucket, resultHandle) of
      SOME result => IdBucket.alloc (idBucket, Notification.Result.id result)
    | NONE => ~1
val notificationResultId = handleExceptionInt notificationResultId


fun notificationResultPayload (resultHandle : int) : int =
   case IdBucket.sub (notificationResultBucket, resultHandle) of
      SOME result => IdBucket.alloc (instreamBucket, Notification.Result.payload result)
    | NONE => ~1
val notificationResultPayload = handleExceptionInt notificationResultPayload


fun notificationResultCancel (resultHandle : int) : int =
   case IdBucket.sub (notificationResultBucket, resultHandle) of
      SOME result => (Notification.Result.cancel result; 0)
    | NONE => ~1
val notificationResultCancel = handleExceptionInt notificationResultCancel


val (notificationResultDup, notificationResultFree) = bucketOps notificationResultBucket


fun notificationSendFn (sendFnHandle : int, idHandle : int, getDataFn : ptr, getDataData : ptr) : int =
   let
      val getDataP = _import * : ptr -> int * ptr -> unit;
      fun getData (SOME os) =
         (getDataP getDataFn) (IdBucket.alloc (outstreamBucket, os), getDataData)
        | getData NONE =
         (getDataP getDataFn) (~1, getDataData)
   in
      case (IdBucket.sub (notificationSendFnBucket, sendFnHandle), IdBucket.sub (idBucket, idHandle)) of
         (SOME sendFn, SOME id) => (sendFn (id, Notification.ON_REQUEST getData); 0)
       | _ => ~1
   end
val notificationSendFn = handleExceptionInt notificationSendFn


fun notificationSendFnImmediate (sendFnHandle : int, idHandle : int, data : ptr, dataLen : int) : int =
   let
      val dataVector = getDataVector (data, dataLen)
   in
      case (IdBucket.sub (notificationSendFnBucket, sendFnHandle), IdBucket.sub (idBucket, idHandle)) of
         (SOME sendFn, SOME id) => (sendFn (id, Notification.IMMEDIATE dataVector); 0)
       | _ => ~1
   end
val notificationSendFnImmediate = handleExceptionInt notificationSendFnImmediate


val (notificationSendFnDup, notificationSendFnFree) = bucketOps notificationSendFnBucket


(* --- Query --- *)

fun queryNew (masterHandle : int, dataBubbleHandle : int, queryBubbleId : int, lambda : Real64.real, responderFn : ptr, responderData : ptr) : int =
   let
      fun responder {query, respond} =
         let
            val responderP = _import * : ptr -> Word8Vector.vector * int * int * int * ptr -> unit;
            val (vec, ofs, len) = Word8VectorSlice.base query
            val respondHandle = IdBucket.alloc (queryRespondBucket, respond)
         in
            (responderP responderFn) (vec, ofs, len, respondHandle, responderData)
         end
      val master = IdBucket.sub (bubbleMasterBucket, masterHandle)
      val dataBubble = IdBucket.sub (bubbleTypePersistentBucket, dataBubbleHandle)
   in
      case (master, dataBubble) of
         (SOME master, SOME dataBubble) =>
            IdBucket.alloc (queryBucket,
               Query.new {
                  master = master,
                  dataBubble = dataBubble,
                  queryBubbleId = queryBubbleId,
                  queryBubbleName = "", (* TODO *)
                  lambda = lambda,
                  priority = NONE, (* TODO port priority & reliability *)
                  reliability = NONE,
                  responder = responder
               })
       | _ => ~1
   end
val queryNew = handleExceptionInt queryNew


fun queryQuery (queryHandle : int, queryData : ptr, queryDataLen : int, responseCb : ptr, responseCbData : ptr) : int =
   let
      fun responseCallback {id, stream} =
         let
            val responseP = _import * : ptr -> int * int * ptr -> unit;
            val idHandle = IdBucket.alloc (idBucket, id)
            val streamHandle = IdBucket.alloc (instreamBucket, stream)
         in
            (responseP responseCb) (idHandle, streamHandle, responseCbData)
         end
      val query = IdBucket.sub (queryBucket, queryHandle)
   in
      case query of
         SOME query =>
            (IdBucket.alloc (abortableBucket,
               Query.query (query, {
                  query = getDataVector (queryData, queryDataLen),
                  responseCallback = responseCallback
               })
            ) (* TODO exception still there? handle (Query.QueryException _) => ~2*) ) (* catch failure if local address is unknown *)
       | _ => ~1
   end
val queryQuery = handleExceptionInt queryQuery


val (queryDup, queryFree) = bucketOps queryBucket


(* --- QueryRespond --- *)

fun queryRespond (respondHandle : int, idHandle : int, writeFn : ptr, writeFnData : ptr) : int =
   let
      fun write stream =
         let
            val writeP = _import * : ptr -> int * ptr -> unit;
            val osHandle =
               case stream of
                  SOME os => IdBucket.alloc (outstreamBucket, os)
                | NONE => ~1
         in
            (writeP writeFn) (osHandle, writeFnData)
         end
      val respond = IdBucket.sub (queryRespondBucket, respondHandle)
      val id = IdBucket.sub (idBucket, idHandle)
   in
      case (respond, id) of
         (SOME respond, SOME id) => (respond {id = id, write = write}; 0)
       | _ => ~1
   end
val v = handleExceptionInt queryRespond


val (queryRespondDup, queryRespondFree) = bucketOps queryRespondBucket


(* --------- *
 *  Exports  *
 * --------- *)

(* BubbleStorm functions *)
val () = _export "bs_bubblestorm_new" : (Real32.real * Real32.real * int * int * bool -> int) -> unit; bubbleStormNew
val () = _export "bs_bubblestorm_new_with_endpoint" : (Real32.real * Real32.real * int -> int) -> unit; bubbleStormNewWithEndpoint
val () = _export "bs_bubblestorm_create" : (int * int * ptr * ptr -> int) -> unit; bubbleStormCreate
val () = _export "bs_bubblestorm_join" : (int * ptr * ptr -> int) -> unit; bubbleStormJoin
val () = _export "bs_bubblestorm_leave" : (int * ptr * ptr -> int) -> unit; bubbleStormLeave
val () = _export "bs_bubblestorm_endpoint" : (int -> int) -> unit; bubbleStormEndpoint
val () = _export "bs_bubblestorm_bubblemaster" : (int -> int) -> unit; bubbleStormBubbleMaster
val () = _export "bs_bubblestorm_address" : (int -> int) -> unit; bubbleStormAddress
val () = _export "bs_bubblestorm_save_hostcache" : (int * ptr -> Word8Vector.vector) -> unit; bubbleStormSaveHostCache
val () = _export "bs_bubblestorm_load_hostcache" : (int * ptr * int * int -> int) -> unit; bubbleStormLoadHostCache
val () = _export "bs_bubblestorm_set_lan_mode" : (bool -> int) -> unit; bubbleStormSetLanMode
val () = _export "bs_bubblestorm_dup" : (int -> int) -> unit; bubbleStormDup
val () = _export "bs_bubblestorm_free" : (int -> bool) -> unit; bubbleStormFree

(* BubbleMaster functions *)
val () = _export "bs_bubblemaster_new_instant" : (int * int * Real32.real -> int) -> unit; bubbleMasterNewInstant
val () = _export "bs_bubblemaster_new_fading" : (int * int * Real32.real * ptr * ptr -> int) -> unit; bubbleMasterNewFading
val () = _export "bs_bubblemaster_new_managed" : (int * int * Real32.real * ptr * ptr * ptr * ptr * ptr * ptr -> int) -> unit; bubbleMasterNewManaged
val () = _export "bs_bubblemaster_new_durable" : (int * int * Real32.real * ptr * ptr * ptr * ptr * ptr * ptr -> int) -> unit; bubbleMasterNewDurable
val () = _export "bs_bubblemaster_dup" : (int -> int) -> unit; bubbleMasterDup
val () = _export "bs_bubblemaster_free" : (int -> bool) -> unit; bubbleMasterFree

(* BubbleType functions *)
val () = _export "bs_bubbletype_basic_match" : (int * int * Real64.real * ptr * ptr -> int) -> unit; bubbleTypeBasicMatch
val () = _export "bs_bubbletype_basic_typeid" : (int -> int) -> unit; bubbleTypeBasicTypeId
val () = _export "bs_bubbletype_basic_default_size" : (int -> int) -> unit; bubbleTypeBasicDefaultSize
val () = _export "bs_bubbletype_basic_dup" : (int -> int) -> unit; bubbleTypeBasicDup
val () = _export "bs_bubbletype_basic_free" : (int -> bool) -> unit; bubbleTypeBasicFree
val () = _export "bs_bubbletype_persistent_match_with_id" : (int * int * Real64.real * ptr * ptr -> int) -> unit; bubbleTypePersistentMatchWithID
val () = _export "bs_bubbletype_persistent_dup" : (int -> int) -> unit; bubbleTypePersistentDup
val () = _export "bs_bubbletype_persistent_free" : (int -> bool) -> unit; bubbleTypePersistentFree
val () = _export "bs_bubbletype_instant_basic" : (int -> int) -> unit; bubbleTypeInstantBasic
val () = _export "bs_bubbletype_instant_dup" : (int -> int) -> unit; bubbleTypeInstantDup
val () = _export "bs_bubbletype_instant_free" : (int -> bool) -> unit; bubbleTypeInstantFree
val () = _export "bs_bubbletype_fading_basic" : (int -> int) -> unit; bubbleTypeFadingBasic
val () = _export "bs_bubbletype_fading_persistent" : (int -> int) -> unit; bubbleTypeFadingPersistent
val () = _export "bs_bubbletype_fading_dup" : (int -> int) -> unit; bubbleTypeFadingDup
val () = _export "bs_bubbletype_fading_free" : (int -> bool) -> unit; bubbleTypeFadingFree
val () = _export "bs_bubbletype_managed_basic" : (int -> int) -> unit; bubbleTypeManagedBasic
val () = _export "bs_bubbletype_managed_persistent" : (int -> int) -> unit; bubbleTypeManagedPersistent
val () = _export "bs_bubbletype_managed_dup" : (int -> int) -> unit; bubbleTypeManagedDup
val () = _export "bs_bubbletype_managed_free" : (int -> bool) -> unit; bubbleTypeManagedFree
val () = _export "bs_bubbletype_durable_basic" : (int -> int) -> unit; bubbleTypeDurableBasic
val () = _export "bs_bubbletype_durable_persistent" : (int -> int) -> unit; bubbleTypeDurablePersistent
val () = _export "bs_bubbletype_durable_dup" : (int -> int) -> unit; bubbleTypeDurableDup
val () = _export "bs_bubbletype_durable_free" : (int -> bool) -> unit; bubbleTypeDurableFree
val () = _export "bs_bubbletype_durable_datastore_lookup_cb" : (int * Int64.int * Int64.int * ptr * int -> int) -> unit; bubbleTypeDurableDatastoreLookupCb
(* val () = _export "bs_bubbletype_durable_datastore_version_cb" : (int * Int64.int * Int64.int -> int) -> unit; bubbleTypeDurableDatastoreVersionCb *)
val () = _export "bs_bubbletype_durable_datastore_iterator_cb" : (int * int * Int64.int * Int64.int * ptr * int -> int) -> unit; bubbleTypeDurableDatastoreIteratorCb

(* Bubble functions *)
val () = _export "bs_bubble_instant_create" : (int * ptr * int -> int) -> unit; bubbleInstantCreate
val () = _export "bs_bubble_fading_create" : (int * int * ptr * int -> int) -> unit; bubbleFadingCreate
val () = _export "bs_bubble_managed_insert" : (int * int * ptr * int * ptr * ptr -> int) -> unit; bubbleManagedInsert
val () = _export "bs_bubble_managed_id" : (int -> int) -> unit; bubbleManagedId
val () = _export "bs_bubble_managed_data" : (int * ptr -> Word8Vector.vector) -> unit; bubbleManagedData
val () = _export "bs_bubble_managed_update" : (int * ptr * int * ptr * ptr -> int) -> unit; bubbleManagedUpdate
val () = _export "bs_bubble_managed_delete" : (int * ptr * ptr -> int) -> unit; bubbleManagedDelete
val () = _export "bs_bubble_managed_dup" : (int -> int) -> unit; bubbleManagedDup
val () = _export "bs_bubble_managed_free" : (int -> bool) -> unit; bubbleManagedFree
val () = _export "bs_bubble_durable_lookup" : (int * int * ptr * ptr -> int) -> unit; bubbleDurableLookup
val () = _export "bs_bubble_durable_create" : (int * int * ptr * int -> int) -> unit; bubbleDurableCreate
val () = _export "bs_bubble_durable_data" : (int * ptr -> Word8Vector.vector) -> unit; bubbleDurableData
val () = _export "bs_bubble_durable_id" : (int -> int) -> unit; bubbleDurableId
val () = _export "bs_bubble_durable_update" : (int * ptr * int -> int) -> unit; bubbleDurableUpdate
val () = _export "bs_bubble_durable_delete" : (int -> int) -> unit; bubbleDurableDelete
val () = _export "bs_bubble_durable_dup" : (int -> int) -> unit; bubbleDurableDup
val () = _export "bs_bubble_durable_free" : (int -> bool) -> unit; bubbleDurableFree

(* ID functions *)
val () = _export "bs_id_from_hash" : (ptr * int -> int) -> unit; idFromHash
val () = _export "bs_id_from_random" : (unit -> int) -> unit; idFromRandom
val () = _export "bs_id_from_bytes" : (ptr -> int) -> unit; idFromBytes
val () = _export "bs_id_to_bytes" : (int * ptr -> Word8Vector.vector) -> unit; idToBytes
val () = _export "bs_id_to_string" : (int * ptr -> string) -> unit; idToString
val () = _export "bs_id_equals" : (int * int -> int) -> unit; idEquals
val () = _export "bs_id_hash" : (int -> Int64.int) -> unit; idHash
val () = _export "bs_id_dup" : (int -> int) -> unit; idDup
val () = _export "bs_id_free" : (int -> bool) -> unit; idFree

(* Notification functions *)
val () = _export "bs_notification_new" : (int (** ptr * ptr*) * ptr * ptr -> int) -> unit; notificationNew
val () = _export "bs_notification_close" : (int -> int) -> unit; notificationClose
val () = _export "bs_notification_max_encoded_length" : (unit -> int) -> unit; notificationMaxEncodedLength
val () = _export "bs_notification_encode" : (int * int * ptr -> Word8Vector.vector) -> unit; notificationEncode
val () = _export "bs_notification_decode" : (ptr * ptr * int -> int) -> unit; notificationDecode
val () = _export "bs_notification_dup" : (int -> int) -> unit; notificationDup
val () = _export "bs_notification_free" : (int -> bool) -> unit; notificationFree

val () = _export "bs_notification_result_id" : (int -> int) -> unit; notificationResultId
val () = _export "bs_notification_result_payload" : (int -> int) -> unit; notificationResultPayload
val () = _export "bs_notification_result_cancel" : (int -> int) -> unit; notificationResultCancel
val () = _export "bs_notification_result_dup" : (int -> int) -> unit; notificationResultDup
val () = _export "bs_notification_result_free" : (int -> bool) -> unit; notificationResultFree

val () = _export "bs_notification_sendfn" : (int * int * ptr * ptr -> int) -> unit; notificationSendFn
val () = _export "bs_notification_sendfn_immediate" : (int * int * ptr * int -> int) -> unit; notificationSendFnImmediate
val () = _export "bs_notification_sendfn_dup" : (int -> int) -> unit; notificationSendFnDup
val () = _export "bs_notification_sendfn_free" : (int -> bool) -> unit; notificationSendFnFree

(* Query functions *)
val () = _export "bs_query_new" : (int * int * int * Real64.real * ptr * ptr -> int) -> unit; queryNew
val () = _export "bs_query_query" : (int * ptr * int * ptr * ptr -> int) -> unit; queryQuery
val () = _export "bs_query_dup" : (int -> int) -> unit; queryDup
val () = _export "bs_query_free" : (int -> bool) -> unit; queryFree

val () = _export "bs_query_respond" : (int * int * ptr * ptr -> int) -> unit; queryRespond
val () = _export "bs_query_respond_dup" : (int -> int) -> unit; queryRespondDup
val () = _export "bs_query_respond_free" : (int -> bool) -> unit; queryRespondFree
