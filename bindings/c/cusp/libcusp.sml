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

(* SML glue code for CUSP c-bindings *)

(* CUSP structure comes from external configuration, e.g. realnetwork.sml *)
open CUSP

(* Handle buckets *)
val addressBucket : Address.t IdBucket.t = IdBucket.new ()
val endpointBucket : EndPoint.t IdBucket.t = IdBucket.new ()
val hostBucket : Host.t IdBucket.t = IdBucket.new ()
val hostIteratorBucket : Host.t Iterator.t IdBucket.t = IdBucket.new ()
val channelIteratorBucket : (Address.t * Host.t option) Iterator.t IdBucket.t = IdBucket.new ()
val instreamBucket : InStream.t IdBucket.t = IdBucket.new ()
val instreamIteratorBucket : InStream.t Iterator.t IdBucket.t = IdBucket.new ()
val outstreamBucket : OutStream.t IdBucket.t = IdBucket.new ()
val outstreamIteratorBucket : OutStream.t Iterator.t IdBucket.t = IdBucket.new ()
val publickeyBucket : Crypto.PublicKey.t IdBucket.t = IdBucket.new ()
val privatekeyBucket : Crypto.PrivateKey.t IdBucket.t = IdBucket.new ()
val udpBucket : UDP4.t IdBucket.t = IdBucket.new()

(* Bucket statistics *)
val statIdBucketAddress = makeBucketStat "address"
val statIdBucketHost = makeBucketStat "host"
val statIdBucketInstream = makeBucketStat "instream"
val statIdBucketOutstream = makeBucketStat "outstream"
val statIdBucketUDP = makeBucketStat "udp"


(* --- EndPoint --- *)

fun endpointNew (port : int, keyHandle : int, encrypt : bool, publicKeySuites : Word16.word,
      symmetricSuites: Word16.word) : int =
   let
      (* Exception handler -- ignore, since connreset exceptions are common under Windows *)
      fun handler _ = ()
      val options =
         SOME {
            encrypt   = encrypt,
            publickey = Suite.PublicKey.fromMask(publicKeySuites),
            symmetric = Suite.Symmetric.fromMask(symmetricSuites)
         }
      val port = if port > 0 then SOME port else NONE
   in
      case IdBucket.sub (privatekeyBucket, keyHandle) of
         SOME key =>
            let
               val ep =
                  EndPoint.new {
                     port = port,
                     key = key,
                     handler = handler,
                     entropy = Entropy.get,
                     options = options
                  }
               (* add end point statisitcs by default *)
               val () = CUSPStatistics.addEndPoint ep
            in
               IdBucket.alloc (endpointBucket, ep)
            end
         | NONE => ~1
   end
val endpointNew = handleExceptionInt endpointNew


fun endpointDestroy (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => (EndPoint.destroy ep; 0)
    | NONE => ~1
val endpointDestroy = handleExceptionInt endpointDestroy


fun endpointWhenSafeToDestroy (epHandle : int, cb : ptr, cbData : ptr) : int =
   let
      fun safeToDestroyCallback () =
         let
            val safeToDestroyCallbackP = _import * : ptr -> ptr -> unit;
         in
            (safeToDestroyCallbackP cb) (cbData)
         end
   in
      case IdBucket.sub (endpointBucket, epHandle) of
         SOME ep =>
            bucketStat (IdBucket.alloc (abortableBucket,
               EndPoint.whenSafeToDestroy (ep, safeToDestroyCallback)), statIdBucketAbortable)
       | NONE => ~1
   end
val endpointWhenSafeToDestroy = handleExceptionInt endpointWhenSafeToDestroy


fun endpointKey (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => IdBucket.alloc (privatekeyBucket, EndPoint.key ep)
    | NONE => ~1
val endpointKey = handleExceptionInt endpointKey


fun endpointPublickeyStr' (epHandle : int, suite : Word16.word, strLen : ptr) : string =
   let
      val pkSuite = Suite.PublicKey.fromValue(suite)
      val str = case IdBucket.sub (endpointBucket, epHandle) of
         SOME ep => SOME (Crypto.PublicKey.toString (Crypto.PrivateKey.pubkey (EndPoint.key ep, pkSuite )))
       | NONE => NONE
   in
      returnString (str, strLen)
   end
fun endpointPublickeyStr (epHandle, suite, strLen) =
   handleExceptionString (endpointPublickeyStr', strLen) (epHandle, suite, strLen)


fun endpointBytesSent (epHandle : int) : Int64.int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => Int64.fromLarge (EndPoint.bytesSent(ep))
      | NONE => ~1
val endpointBytesSent = handleExceptionInt64 endpointBytesSent


fun endpointBytesReceived (epHandle : int) : Int64.int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => Int64.fromLarge(EndPoint.bytesReceived ep)
      | NONE => ~1
val endpointBytesReceived = handleExceptionInt64 endpointBytesReceived


fun endpointContact (epHandle : int, addrHandle : int, service : Word16.word, cb : ptr, cbData : ptr) : int =
   let
      fun contactCallback (hs : (Host.t * OutStream.t) option) =
         let
            val contactCallbackP = _import * : ptr -> int * int * ptr -> unit;
            val (hostHandle, osHandle) = case hs of
               SOME (h, os) => (
                  bucketStat (IdBucket.alloc (hostBucket, h), statIdBucketHost),
                  bucketStat (IdBucket.alloc (outstreamBucket, os), statIdBucketOutstream)
               )
             | NONE => (~1, ~1)
         in
            (contactCallbackP cb) (hostHandle, osHandle, cbData)
         end
   in
      case IdBucket.sub (endpointBucket, epHandle) of
         SOME ep =>
            (case IdBucket.sub (addressBucket, addrHandle) of
               SOME addr => bucketStat (IdBucket.alloc (abortableBucket,
                  EndPoint.contact (ep, addr, service, contactCallback)), statIdBucketAbortable)
             | NONE => ~1
            )
       | NONE => ~1
   end
val endpointContact = handleExceptionInt endpointContact


fun endpointHosts (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => IdBucket.alloc (hostIteratorBucket, EndPoint.hosts ep)
    | NONE => ~1
val endpointHosts = handleExceptionInt endpointHosts


fun endpointChannels (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => IdBucket.alloc (channelIteratorBucket, EndPoint.channels ep)
    | NONE => ~1
val endpointChannels = handleExceptionInt endpointChannels


fun endpointAdvertise (epHandle : int, service : Word16.word, cb : ptr, cbData : ptr) : int =
   (* TODO support dynamic service ID assignment *)
   let
      val advertiseCallbackP = _import * : ptr -> int * int * ptr -> unit;
      fun advertiseCallback (host : Host.t, _ : Word16.word, stream : InStream.t) =
         let
            val hostHandle = bucketStat (IdBucket.alloc (hostBucket, host), statIdBucketHost)
            val streamHandle = bucketStat (IdBucket.alloc (instreamBucket, stream), statIdBucketInstream)
         in
            (advertiseCallbackP cb) (hostHandle, streamHandle, cbData)
         end
   in
      case IdBucket.sub (endpointBucket, epHandle) of
         SOME ep => (ignore (EndPoint.advertise (ep, SOME service, advertiseCallback)); 0)
       | NONE => ~1
   end
val endpointAdvertise = handleExceptionInt endpointAdvertise


fun endpointUnadvertise (epHandle : int, service : Word16.word) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => (EndPoint.unadvertise (ep, service); 0)
    | NONE => ~1
val endpointUnadvertise = handleExceptionInt endpointUnadvertise


fun endpointCanReceiveUDP (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => returnBool (EndPoint.canReceiveUDP ep)
    | NONE => ~1
val endpointCanReceiveUDP = handleExceptionInt endpointCanReceiveUDP


fun endpointCanSendOwnICMP (epHandle : int) : int =
   case IdBucket.sub (endpointBucket, epHandle) of
      SOME ep => returnBool (EndPoint.canSendOwnICMP ep)
    | NONE => ~1
val endpointCanSendOwnICMP = handleExceptionInt endpointCanSendOwnICMP


val (endpointDup, endpointFree) = bucketOps endpointBucket


(* --- Address --- *)

fun addressFromString (strPtr : ptr, strLen : int) : int =
   case Address.fromString(getString (strPtr, strLen)) of
      addr :: _ => bucketStat (IdBucket.alloc (addressBucket, addr), statIdBucketAddress)
    | nil => ~2
val addressFromString = handleExceptionInt addressFromString


fun addressToString' (addrHandle : int, strLen : ptr) : string =
   let
      val str = case IdBucket.sub (addressBucket, addrHandle) of
         SOME addr => SOME (Address.toString addr)
       | NONE => NONE
   in
      returnString (str, strLen)
   end
fun addressToString (addrHandle, strLen) =
   handleExceptionString (addressToString', strLen) (addrHandle, strLen)


val (addressDup, addressFree) = bucketOps addressBucket


(* --- Host --- *)

fun hostConnect (hostHandle : int, service : Word16.word) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => bucketStat (IdBucket.alloc (outstreamBucket, Host.connect (host, service)), statIdBucketOutstream)
    | NONE => ~1
val hostConnect = handleExceptionInt hostConnect


fun hostListen (hostHandle : int, cb : ptr, cbData : ptr) : int =
   let
      val listenCallbackP = _import * : ptr -> Word16.word * int * ptr -> unit;
      fun listenCallback (service : Word16.word, instream : InStream.t) =
         let
            val isHandle = bucketStat (IdBucket.alloc (instreamBucket, instream), statIdBucketInstream)
         in
            (listenCallbackP cb) (service, isHandle, cbData)
         end
   in
      case IdBucket.sub (hostBucket, hostHandle) of
         SOME host => Word16.toInt (Host.listen (host, listenCallback))
       | NONE => ~1
   end
val hostListen = handleExceptionInt hostListen


fun hostUnlisten (hostHandle : int, service : Word16.word) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => (Host.unlisten (host, service); 0)
    | NONE => ~1
val hostUnlisten = handleExceptionInt hostUnlisten


fun hostKey (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => IdBucket.alloc (publickeyBucket, Host.key (host))
    | NONE => ~1
val hostKey = handleExceptionInt hostKey


fun hostKeyStr' (hostHandle : int, strLen : ptr) : string =
   let
      val str = case IdBucket.sub (hostBucket, hostHandle) of
         SOME host => SOME (Crypto.PublicKey.toString (Host.key (host)))
       | NONE => NONE
   in
      returnString (str, strLen)
   end
fun hostKeyStr (hostHandle, strLen) =
   handleExceptionString (hostKeyStr', strLen) (hostHandle, strLen)


fun hostAddress (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host =>
         (case Host.remoteAddress (host) of
            SOME addr => bucketStat (IdBucket.alloc (addressBucket, addr), statIdBucketAddress)
          | NONE => ~2)
    | NONE => ~1
val hostAddress = handleExceptionInt hostAddress


fun hostToString' (hostHandle : int, strLen : ptr) : string =
   let
      val host = IdBucket.sub (hostBucket, hostHandle)
      val addr = case host of
         SOME h => Host.remoteAddress h
       | NONE => NONE
      val str = case host of
         SOME h => SOME (concat [ Crypto.PublicKey.toString (Host.key h),
            " <", getOpt (Option.map Address.toString addr, "*"), ">" ])
       | NONE => NONE
   in
      returnString (str, strLen)
   end
fun hostToString (hostHandle, strLen) =
   handleExceptionString (hostToString', strLen) (hostHandle, strLen)


fun hostInstreams (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => IdBucket.alloc (instreamIteratorBucket, Host.inStreams host)
    | NONE => ~1
val hostInstreams = handleExceptionInt hostInstreams


fun hostOutstreams (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => IdBucket.alloc (outstreamIteratorBucket, Host.outStreams host)
    | NONE => ~1
val hostOutstreams = handleExceptionInt hostOutstreams


fun hostQueuedOutOfOrder (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Host.queuedOutOfOrder host
    | NONE => ~1
val hostQueuedOutOfOrder = handleExceptionInt hostQueuedOutOfOrder


fun hostQueuedUnread (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Host.queuedUnread host
    | NONE => ~1
val hostQueuedUnread = handleExceptionInt hostQueuedUnread


fun hostQueuedInflight (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Host.queuedInflight host
    | NONE => ~1
val hostQueuedInflight = handleExceptionInt hostQueuedInflight


fun hostQueuedToRetransmit (hostHandle : int) : int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Host.queuedToRetransmit host
    | NONE => ~1
val hostQueuedToRetransmit = handleExceptionInt hostQueuedToRetransmit


fun hostBytesReceived (hostHandle : int) : Int64.int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Int64.fromLarge (Host.bytesReceived host)
    | NONE => ~1
val hostBytesReceived = handleExceptionInt64 hostBytesReceived


fun hostBytesSent (hostHandle : int) : Int64.int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Int64.fromLarge (Host.bytesSent host)
    | NONE => ~1
val hostBytesSent = handleExceptionInt64 hostBytesSent


fun hostLastReceive (hostHandle : int) : Int64.int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Time.toNanoseconds64 (Host.lastReceive host)
    | NONE => ~1
val hostLastReceive = handleExceptionInt64 hostLastReceive


fun hostLastSend (hostHandle : int) : Int64.int =
   case IdBucket.sub (hostBucket, hostHandle) of
      SOME host => Time.toNanoseconds64 (Host.lastSend host)
    | NONE => ~1
val hostLastSend = handleExceptionInt64 hostLastSend


val (hostDup, hostFree) = bucketOps hostBucket


(* --- Host::Iterator --- *)

fun hostIteratorHasNext (hostIteratorHandle : int) : int =
   case IdBucket.sub (hostIteratorBucket, hostIteratorHandle) of
      SOME it => if Iterator.null it then 0 else 1
    | NONE => ~1
val hostIteratorHasNext = handleExceptionInt hostIteratorHasNext


fun hostIteratorNext (hostIteratorHandle : int) : int =
   case IdBucket.sub (hostIteratorBucket, hostIteratorHandle) of
      SOME hi => 
         (case Iterator.getItem hi of
            SOME (h, it) =>
               (IdBucket.replace (hostIteratorBucket, hostIteratorHandle, it);
               bucketStat (IdBucket.alloc (hostBucket, h), statIdBucketHost))
          | NONE => ~2)
    | NONE => ~1
val hostIteratorNext = handleExceptionInt hostIteratorNext


val (hostIteratorDup, hostIteratorFree) = bucketOps hostIteratorBucket


(* --- Channel::Iterator --- *)

fun channelIteratorHasNext (channelIteratorHandle : int) : int =
   case IdBucket.sub (channelIteratorBucket, channelIteratorHandle) of
      SOME it => if Iterator.null it then 0 else 1
    | NONE => ~1
val channelIteratorHasNext = handleExceptionInt channelIteratorHasNext


fun channelIteratorNext (channelIteratorHandle : int, hostHandle : ptr) : int =
   case IdBucket.sub (channelIteratorBucket, channelIteratorHandle) of
      SOME ci =>
         (case Iterator.getItem ci of
            SOME ((addr, SOME h), it) =>
               (IdBucket.replace (channelIteratorBucket, channelIteratorHandle, it)
               ; MLton.Pointer.setInt32 (hostHandle, 0, Int32.fromInt (bucketStat (IdBucket.alloc (hostBucket, h), statIdBucketHost)))
               ; bucketStat (IdBucket.alloc (addressBucket, addr), statIdBucketAddress))
          | SOME ((addr, NONE), it) =>
               (IdBucket.replace (channelIteratorBucket, channelIteratorHandle, it)
               ; MLton.Pointer.setInt32 (hostHandle, 0, Int32.fromInt ~1)
               ; bucketStat (IdBucket.alloc (addressBucket, addr), statIdBucketAddress))
          | NONE => ~2)
    | NONE => ~1
val channelIteratorNext = handleExceptionInt channelIteratorNext


val (channelIteratorDup, channelIteratorFree) = bucketOps channelIteratorBucket


(* --- InStream --- *)

fun instreamState (streamHandle : int) : int =
   case IdBucket.sub (instreamBucket, streamHandle) of
      SOME stream => (case InStream.state stream of
         InStream.IS_ACTIVE => 0
       | InStream.IS_SHUTDOWN => 1
       | InStream.IS_RESET => 2)
    | NONE => ~1
val instreamState = handleExceptionInt instreamState


fun instreamRead (streamHandle : int, maxCount : int, cb : ptr, cbData : ptr) : int =
   let
      val nullData = Array.tabulate (0, fn _ => 0w0)
      val readCallbackP = _import * : ptr -> int * int * Word8.word array * ptr -> unit;
      fun readCallback (status : InStream.status) =
         let
            val (arr, ofs, len) =
               case status of
                  InStream.DATA data => Word8ArraySlice.base (data)
                | InStream.SHUTDOWN => (nullData, 0, ~2)
                | InStream.RESET => (nullData, 0, ~1)
         in
            (readCallbackP cb) (len, ofs, arr, cbData)
         end
   in
      case IdBucket.sub (instreamBucket, streamHandle) of
         SOME stream => (InStream.read (stream, maxCount, readCallback); 0)
       | NONE => ~1
   end
val instreamRead = handleExceptionInt instreamRead


fun instreamReadShutdown (streamHandle : int, cb : ptr, cbData : ptr) : int =
   let
      val callbackP = _import * : ptr -> bool * ptr -> unit;
      fun callback success =
         (callbackP cb) (success, cbData)
   in
      case IdBucket.sub (instreamBucket, streamHandle) of
         SOME stream => (InStream.readShutdown (stream, callback); 0)
       | NONE => ~1
   end
val instreamReadShutdown = handleExceptionInt instreamReadShutdown


fun instreamReset (streamHandle : int) : int =
   case IdBucket.sub (instreamBucket, streamHandle) of
      SOME stream => (InStream.reset stream; 0)
    | NONE => ~1
val instreamReset = handleExceptionInt instreamReset


fun instreamQueuedOutOfOrder (streamHandle : int) : int =
   case IdBucket.sub (instreamBucket, streamHandle) of
      SOME stream => InStream.queuedOutOfOrder stream
    | NONE => ~1
val instreamQueuedOutOfOrder = handleExceptionInt instreamQueuedOutOfOrder


fun instreamQueuedUnread (streamHandle : int) : int =
   case IdBucket.sub (instreamBucket, streamHandle) of
      SOME stream => InStream.queuedUnread stream
    | NONE => ~1
val instreamQueuedUnread = handleExceptionInt instreamQueuedUnread


fun instreamBytesReceived (streamHandle : int) : Int64.int =
   case IdBucket.sub (instreamBucket, streamHandle) of
      SOME stream => Int64.fromLarge (InStream.bytesReceived stream)
    | NONE => ~1
val instreamBytesReceived = handleExceptionInt64 instreamBytesReceived


val (instreamDup, instreamFree) = bucketOps instreamBucket


(* --- InStream::Iterator --- *)

fun instreamIteratorHasNext (instreamIteratorHandle : int) : int =
   case IdBucket.sub (instreamIteratorBucket, instreamIteratorHandle) of
      SOME it => if Iterator.null it then 0 else 1
    | NONE => ~1
val instreamIteratorHasNext = handleExceptionInt instreamIteratorHasNext


fun instreamIteratorNext (instreamIteratorHandle : int) : int =
   case Option.mapPartial Iterator.getItem 
         (IdBucket.sub (instreamIteratorBucket, instreamIteratorHandle)) of
      SOME (is, it) =>
         (IdBucket.replace (instreamIteratorBucket, instreamIteratorHandle, it);
         bucketStat (IdBucket.alloc (instreamBucket, is), statIdBucketInstream))
    | NONE => ~1
val instreamIteratorNext = handleExceptionInt instreamIteratorNext


val (instreamIteratorDup, instreamIteratorFree) = bucketOps instreamIteratorBucket


(* --- OutStream --- *)

fun outstreamGetPriority (streamHandle : int) : Real32.real =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => OutStream.getPriority (stream)
    | NONE => nanReal32
val outstreamGetPriority = handleExceptionReal32 outstreamGetPriority


fun outstreamSetPriority (streamHandle : int, prio : Real32.real) : int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => (OutStream.setPriority (stream, prio); 0)
    | NONE => ~1
val outstreamSetPriority = handleExceptionInt outstreamSetPriority


fun outstreamState (streamHandle : int) : int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => (case OutStream.state stream of
         OutStream.IS_ACTIVE => 0
       | OutStream.IS_SHUTDOWN => 1
       | OutStream.IS_RESET => 2)
    | NONE => ~1
val outstreamState = handleExceptionInt outstreamState


fun outstreamWrite (streamHandle : int, data : ptr, dataLen : int, cb : ptr, cbData : ptr) : int =
   let
      val dataVector = getDataVector (data, dataLen)
      val readCallbackP = _import * : ptr -> int * ptr -> unit;
      fun writeCallback (status : OutStream.status) =
         let
            val statusInt = case status of
               OutStream.READY => 0
             | OutStream.RESET => ~1
         in
            (readCallbackP cb) (statusInt, cbData)
         end
   in
      case IdBucket.sub (outstreamBucket, streamHandle) of
         SOME stream => (OutStream.write (stream, dataVector, writeCallback); 0)
       | NONE => ~1
   end
val outstreamWrite = handleExceptionInt outstreamWrite


fun outstreamShutdown (streamHandle : int, cb : ptr, cbData : ptr) : int =
   let
      val shutdownCallbackP = _import * : ptr -> bool * ptr -> unit;
      fun shutdownCallback (success : bool) =
         (shutdownCallbackP cb) (success, cbData)
   in
      case IdBucket.sub (outstreamBucket, streamHandle) of
         SOME stream => (OutStream.shutdown (stream, shutdownCallback); 0)
       | NONE => ~1
   end
val outstreamShutdown = handleExceptionInt outstreamShutdown


fun outstreamReset (streamHandle : int) : int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => (OutStream.reset stream; 0)
    | NONE => ~1
val outstreamReset = handleExceptionInt outstreamReset


fun outstreamQueuedInflight (streamHandle : int) : int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => OutStream.queuedInflight stream
    | NONE => ~1
val outstreamQueuedInflight = handleExceptionInt outstreamQueuedInflight


fun outstreamQueuedToRetransmit (streamHandle : int) : int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => OutStream.queuedToRetransmit stream
    | NONE => ~1
val outstreamQueuedToRetransmit = handleExceptionInt outstreamQueuedToRetransmit


fun outstreamBytesSent (streamHandle : int) : Int64.int =
   case IdBucket.sub (outstreamBucket, streamHandle) of
      SOME stream => Int64.fromLarge (OutStream.bytesSent stream)
    | NONE => ~1
val outstreamBytesSent = handleExceptionInt64 outstreamBytesSent


val (outstreamDup, outstreamFree) = bucketOps outstreamBucket


(* --- OutStream::Iterator --- *)

fun outstreamIteratorHasNext (outstreamIteratorHandle : int) : int =
   case IdBucket.sub (outstreamIteratorBucket, outstreamIteratorHandle) of
      SOME it => if Iterator.null it then 0 else 1
    | NONE => ~1
val outstreamIteratorHasNext = handleExceptionInt outstreamIteratorHasNext


fun outstreamIteratorNext (outstreamIteratorHandle : int) : int =
   case Option.mapPartial Iterator.getItem
         (IdBucket.sub (outstreamIteratorBucket, outstreamIteratorHandle)) of
      SOME (os, it) =>
         (IdBucket.replace (outstreamIteratorBucket, outstreamIteratorHandle, it)
         ; bucketStat (IdBucket.alloc (outstreamBucket, os), statIdBucketOutstream))
    | NONE => ~1
val outstreamIteratorNext = handleExceptionInt outstreamIteratorNext


val (outstreamIteratorDup, outstreamIteratorFree) = bucketOps outstreamIteratorBucket


(* --- SuiteSet --- *)

fun suitesetPublickeyAll () : Word16.word =
   Suite.PublicKey.toMask Suite.PublicKey.all


fun suitesetPublickeyDefaults () : Word16.word =
   Suite.PublicKey.toMask Suite.PublicKey.defaults


fun suitesetPublickeyCheapest (set : Word16.word) : Word16.word =
   case Suite.PublicKey.cheapest (Suite.PublicKey.fromMask set) of
      SOME suite => Suite.PublicKey.toValue suite
    | NONE => 0w0


fun suitesetSymmetricAll () : Word16.word =
   Suite.Symmetric.toMask Suite.Symmetric.all


fun suitesetSymmetricDefaults () : Word16.word =
   Suite.Symmetric.toMask Suite.Symmetric.defaults


fun suitesetSymmetricCheapest (set : Word16.word) : Word16.word =
   case Suite.Symmetric.cheapest (Suite.Symmetric.fromMask set) of
      SOME suite => Suite.Symmetric.toValue suite
    | NONE => 0w0


(* --- Suite --- *)

fun suitePublickeyName' (value : Word16.word, strLen : ptr) : string =
   returnString (SOME (Suite.PublicKey.name (Suite.PublicKey.fromValue value)), strLen)
fun suitePublickeyName (value, strLen) =
   handleExceptionString (suitePublickeyName', strLen) (value, strLen)


fun suitePublickeyCost (value : Word16.word) : Real32.real =
   Suite.PublicKey.cost (Suite.PublicKey.fromValue value)
val suitePublickeyCost = handleExceptionReal32 suitePublickeyCost


fun suiteSymmetricName' (value : Word16.word, strLen : ptr) : string =
   returnString (SOME (Suite.Symmetric.name (Suite.Symmetric.fromValue value)), strLen)
fun suiteSymmetricName (value, strLen) =
   handleExceptionString (suiteSymmetricName', strLen) (value, strLen)


fun suiteSymmetricCost (value : Word16.word) : Real32.real =
   Suite.Symmetric.cost (Suite.Symmetric.fromValue value)
val suiteSymmetricCost = handleExceptionReal32 suiteSymmetricCost


(* --- PublicKey --- *)

fun publickeyToString' (pkHandle : int, strLen : ptr) : string =
   let
      val str = case IdBucket.sub (publickeyBucket, pkHandle) of
         SOME pk => SOME (Crypto.PublicKey.toString pk)
       | NONE => NONE
   in
      returnString (str, strLen)
   end
fun publickeyToString (pkHandle, strLen) =
   handleExceptionString (publickeyToString', strLen) (pkHandle, strLen)


fun publickeySuite (pkHandle : int) : int =
   case IdBucket.sub (publickeyBucket, pkHandle) of
      SOME pk => Word16.toInt (Suite.PublicKey.toValue (Crypto.PublicKey.suite pk))
    | NONE => ~1
val publickeySuite = handleExceptionInt publickeySuite


val (publickeyDup, publickeyFree) = bucketOps publickeyBucket


(* --- PrivateKey --- *)

fun privatekeyNew () : int =
   IdBucket.alloc (privatekeyBucket, Crypto.PrivateKey.new { entropy = Entropy.get })
val privatekeyNew = handleExceptionInt privatekeyNew


fun privatekeySave' (pkHandle : int, pwdPtr : ptr, pwdLen : int, strLenOut : ptr) : string =
   let
      val password = getString (pwdPtr, pwdLen)
      val str = case IdBucket.sub (privatekeyBucket, pkHandle) of
         SOME pk => SOME (Crypto.PrivateKey.save (pk, { password = password }))
       | NONE => NONE
   in
      returnString (str, strLenOut)
   end
fun privatekeySave (pkHandle, pwdPtr, pwdLen, strLenOut) =
   handleExceptionString (privatekeySave', strLenOut) (pkHandle, pwdPtr, pwdLen, strLenOut)


fun privatekeyLoad (keyPtr : ptr, keyLen : int, pwdPtr : ptr, pwdLen : int) : int =
   let
      val key = getString (keyPtr, keyLen)
      val password = getString (pwdPtr, pwdLen)
   in
      case Crypto.PrivateKey.load {password = password, key = key} of
         SOME pk => IdBucket.alloc (privatekeyBucket, pk)
       | NONE => ~1
   end
val privatekeyLoad = handleExceptionInt privatekeyLoad


fun privatekeyPubkey (pkHandle : int, sVal : Word16.word) : int =
   let
      val suite = Suite.PublicKey.fromValue sVal
   in
      case IdBucket.sub (privatekeyBucket, pkHandle) of
         SOME pk => IdBucket.alloc (publickeyBucket, Crypto.PrivateKey.pubkey (pk, suite))
       | NONE => ~1
   end
val privatekeyPubkey = handleExceptionInt privatekeyPubkey


val (privatekeyDup, privatekeyFree) = bucketOps privatekeyBucket


(* --- UDP --- *)

fun udpNew (port : int, cb : ptr, cbData : ptr) : int =
   let
      val portOpt = if port >= 0 then SOME port else NONE
      val dataReadyP = _import * : ptr -> ptr -> unit;
      fun dataReady () = (dataReadyP cb) cbData
   in
      bucketStat (
         IdBucket.alloc (
            udpBucket,
            UDP4.new (portOpt, dataReady)),
         statIdBucketUDP)
   end
val udpNew = handleExceptionInt udpNew

fun udpClose (udpHandle : int) : int =
   case IdBucket.sub (udpBucket, udpHandle) of
      SOME udp => (UDP4.close udp; 0)
    | NONE => ~1

fun udpSend (udpHandle : int, addrHandle : int, data : ptr, dataLen : int) : int =
   let
      val dataArray = Word8ArraySlice.full (getDataArray (data, dataLen))
   in
      case IdBucket.sub (udpBucket, udpHandle) of
         SOME udp =>
            (case IdBucket.sub (addressBucket, addrHandle) of
               SOME addr => if UDP4.send (udp, addr, dataArray) then 0 else ~2
             | NONE => ~1
            )
       | NONE => ~1
   end
val udpSend = handleExceptionInt udpSend

fun udpRecv (udpHandle : int, dataOfs : ptr, dataLen : ptr, addrHandleP : ptr) : Word8Array.array =
   let
      val out =
         case IdBucket.sub (udpBucket, udpHandle) of
            SOME udp => UDP4.recv (udp,
               Word8ArraySlice.full (Word8Array.tabulate (UDP4.maxMTU, fn _ => 0w0)))
          | NONE => NONE
      val (addrHandle, rcvd) =
         case out of
            SOME (a, r) =>
               (bucketStat (IdBucket.alloc (addressBucket, a), statIdBucketAddress),
                SOME r)
          | NONE => (~1, SOME (Word8ArraySlice.full nullArray))
      val () = MLton.Pointer.setInt32 (addrHandleP, 0, Int32.fromInt addrHandle)
   in
      returnDataArraySlice (rcvd, dataOfs, dataLen)
   end
(* TODO val udpRecv = handleExceptionInt udpRecv *)


val (udpDup, udpFree) = bucketOps udpBucket


(* --------- *
 *  Exports  *
 * --------- *)

(* EndPoint functions *)
val () = _export "cusp_endpoint_new" : (int * int * bool * Word16.word * Word16.word -> int) -> unit; endpointNew
val () = _export "cusp_endpoint_destroy" : (int -> int) -> unit; endpointDestroy
val () = _export "cusp_endpoint_when_safe_to_destroy" : (int * ptr * ptr -> int) -> unit; endpointWhenSafeToDestroy
(* val () = _export "cusp_endpoint_set_rate" : (int * int -> bool) -> unit; endpointSetRate *)
val () = _export "cusp_endpoint_key" : (int -> int) -> unit; endpointKey
val () = _export "cusp_endpoint_publickey_str" : (int * Word16.word * ptr -> string) -> unit; endpointPublickeyStr
val () = _export "cusp_endpoint_bytes_sent" : (int -> Int64.int) -> unit; endpointBytesSent
val () = _export "cusp_endpoint_bytes_received" : (int -> Int64.int) -> unit; endpointBytesReceived
val () = _export "cusp_endpoint_contact" : (int * int * Word16.word * ptr * ptr -> int) -> unit; endpointContact
val () = _export "cusp_endpoint_hosts" : (int -> int) -> unit; endpointHosts
val () = _export "cusp_endpoint_channels" : (int -> int) -> unit; endpointChannels
val () = _export "cusp_endpoint_advertise" : (int * Word16.word * ptr * ptr -> int) -> unit; endpointAdvertise
val () = _export "cusp_endpoint_unadvertise" : (int * Word16.word -> int) -> unit; endpointUnadvertise
val () = _export "cusp_endpoint_can_receive_udp" : (int -> int) -> unit; endpointCanReceiveUDP
val () = _export "cusp_endpoint_can_send_own_icmp" : (int -> int) -> unit; endpointCanSendOwnICMP
val () = _export "cusp_endpoint_dup" : (int -> int) -> unit; endpointDup
val () = _export "cusp_endpoint_free" : (int -> bool) -> unit; endpointFree

(* Address functions *)
val () = _export "cusp_address_from_string" : (ptr * int -> int) -> unit; addressFromString
val () = _export "cusp_address_to_string" : (int * ptr -> string) -> unit; addressToString
val () = _export "cusp_address_dup" : (int -> int) -> unit; addressDup
val () = _export "cusp_address_free" : (int -> bool) -> unit; addressFree

(* Host functions *)
val () = _export "cusp_host_connect" : (int * Word16.word -> int) -> unit; hostConnect
val () = _export "cusp_host_listen" : (int * ptr * ptr -> int) -> unit; hostListen
val () = _export "cusp_host_unlisten" : (int * Word16.word -> int) -> unit; hostUnlisten
val () = _export "cusp_host_key" : (int -> int) -> unit; hostKey
val () = _export "cusp_host_key_str" : (int * ptr -> string) -> unit; hostKeyStr
val () = _export "cusp_host_address" : (int -> int) -> unit; hostAddress
val () = _export "cusp_host_to_string" : (int * ptr -> string) -> unit; hostToString
val () = _export "cusp_host_instreams" : (int -> int) -> unit; hostInstreams
val () = _export "cusp_host_outstreams" : (int -> int) -> unit; hostOutstreams
val () = _export "cusp_host_queued_out_of_order" : (int -> int) -> unit; hostQueuedOutOfOrder
val () = _export "cusp_host_queued_unread" : (int -> int) -> unit; hostQueuedUnread
val () = _export "cusp_host_queued_inflight" : (int -> int) -> unit; hostQueuedInflight
val () = _export "cusp_host_queued_to_retransmit" : (int -> int) -> unit; hostQueuedToRetransmit
val () = _export "cusp_host_bytes_received" : (int -> Int64.int) -> unit; hostBytesReceived
val () = _export "cusp_host_bytes_sent" : (int -> Int64.int) -> unit; hostBytesSent
val () = _export "cusp_host_last_receive" : (int -> Int64.int) -> unit; hostLastReceive
val () = _export "cusp_host_last_send" : (int -> Int64.int) -> unit; hostLastSend
val () = _export "cusp_host_dup" : (int -> int) -> unit; hostDup
val () = _export "cusp_host_free" : (int -> bool) -> unit; hostFree

(* Host::Iterator functions *)
val () = _export "cusp_host_iterator_has_next" : (int -> int) -> unit; hostIteratorHasNext
val () = _export "cusp_host_iterator_next" : (int -> int) -> unit; hostIteratorNext
val () = _export "cusp_host_iterator_dup" : (int -> int) -> unit; hostIteratorDup
val () = _export "cusp_host_iterator_free" : (int -> bool) -> unit; hostIteratorFree

(* Channel::Iterator functions *)
val () = _export "cusp_channel_iterator_has_next" : (int -> int) -> unit; channelIteratorHasNext
val () = _export "cusp_channel_iterator_next" : (int * ptr -> int) -> unit; channelIteratorNext
val () = _export "cusp_channel_iterator_dup" : (int -> int) -> unit; channelIteratorDup
val () = _export "cusp_channel_iterator_free" : (int -> bool) -> unit; channelIteratorFree

(* InStream functions *)
val () = _export "cusp_instream_state" : (int -> int) -> unit; instreamState
val () = _export "cusp_instream_read" : (int * int * ptr * ptr -> int) -> unit; instreamRead
val () = _export "cusp_instream_read_shutdown" : (int * ptr * ptr -> int) -> unit; instreamReadShutdown
val () = _export "cusp_instream_reset" : (int -> int) -> unit; instreamReset
val () = _export "cusp_instream_queued_out_of_order" : (int -> int) -> unit; instreamQueuedOutOfOrder
val () = _export "cusp_instream_queued_unread" : (int -> int) -> unit; instreamQueuedUnread
val () = _export "cusp_instream_bytes_received" : (int -> Int64.int) -> unit; instreamBytesReceived
val () = _export "cusp_instream_dup" : (int -> int) -> unit; instreamDup
val () = _export "cusp_instream_free" : (int -> bool) -> unit; instreamFree

(* InStream::Iterator functions *)
val () = _export "cusp_instream_iterator_has_next" : (int -> int) -> unit; instreamIteratorHasNext
val () = _export "cusp_instream_iterator_next" : (int -> int) -> unit; instreamIteratorNext
val () = _export "cusp_instream_iterator_dup" : (int -> int) -> unit; instreamIteratorDup
val () = _export "cusp_instream_iterator_free" : (int -> bool) -> unit; instreamIteratorFree

(* OutStream functions *)
val () = _export "cusp_outstream_get_priority" : (int -> Real32.real) -> unit; outstreamGetPriority
val () = _export "cusp_outstream_set_priority" : (int * Real32.real -> int) -> unit; outstreamSetPriority
val () = _export "cusp_outstream_state" : (int -> int) -> unit; outstreamState
val () = _export "cusp_outstream_write" : (int * ptr * int * ptr * ptr -> int) -> unit; outstreamWrite
val () = _export "cusp_outstream_shutdown" : (int * ptr * ptr -> int) -> unit; outstreamShutdown
val () = _export "cusp_outstream_reset" : (int -> int) -> unit; outstreamReset
val () = _export "cusp_outstream_queued_inflight" : (int -> int) -> unit; outstreamQueuedInflight
val () = _export "cusp_outstream_queued_to_retransmit" : (int -> int) -> unit; outstreamQueuedToRetransmit
val () = _export "cusp_outstream_bytes_sent" : (int -> Int64.int) -> unit; outstreamBytesSent
val () = _export "cusp_outstream_dup" : (int -> int) -> unit; outstreamDup
val () = _export "cusp_outstream_free" : (int -> bool) -> unit; outstreamFree

(* OutStream::Iterator functions *)
val () = _export "cusp_outstream_iterator_has_next" : (int -> int) -> unit; outstreamIteratorHasNext
val () = _export "cusp_outstream_iterator_next" : (int -> int) -> unit; outstreamIteratorNext
val () = _export "cusp_outstream_iterator_dup" : (int -> int) -> unit; outstreamIteratorDup
val () = _export "cusp_outstream_iterator_free" : (int -> bool) -> unit; outstreamIteratorFree

(* SuiteSet functions *)
val () = _export "cusp_suiteset_publickey_all" : (unit -> Word16.word) -> unit; suitesetPublickeyAll
val () = _export "cusp_suiteset_publickey_defaults" : (unit -> Word16.word) -> unit; suitesetPublickeyDefaults
val () = _export "cusp_suiteset_publickey_cheapest" : (Word16.word -> Word16.word) -> unit; suitesetPublickeyCheapest
val () = _export "cusp_suiteset_symmetric_all" : (unit -> Word16.word) -> unit; suitesetSymmetricAll
val () = _export "cusp_suiteset_symmetric_defaults" : (unit -> Word16.word) -> unit; suitesetSymmetricDefaults
val () = _export "cusp_suiteset_symmetric_cheapest" : (Word16.word -> Word16.word) -> unit; suitesetSymmetricCheapest

(* Suite functions *)
val () = _export "cusp_suite_publickey_name" : (Word16.word * ptr -> string) -> unit; suitePublickeyName
val () = _export "cusp_suite_publickey_cost" : (Word16.word -> Real32.real) -> unit; suitePublickeyCost
val () = _export "cusp_suite_symmetric_name" : (Word16.word * ptr -> string) -> unit; suiteSymmetricName
val () = _export "cusp_suite_symmetric_cost" : (Word16.word -> Real32.real) -> unit; suiteSymmetricCost

(* PublicKey functions *)
val () = _export "cusp_publickey_to_string" : (int * ptr -> string) -> unit; publickeyToString
val () = _export "cusp_publickey_suite" : (int -> int) -> unit; publickeySuite
val () = _export "cusp_publickey_dup" : (int -> int) -> unit; publickeyDup
val () = _export "cusp_publickey_free" : (int -> bool) -> unit; publickeyFree

(* PrivateKey functions *)
val () = _export "cusp_privatekey_new" : (unit -> int) -> unit; privatekeyNew
val () = _export "cusp_privatekey_save" : (int * ptr * int * ptr -> string) -> unit; privatekeySave
val () = _export "cusp_privatekey_load" : (ptr * int * ptr * int -> int) -> unit; privatekeyLoad
val () = _export "cusp_privatekey_pubkey" : (int * Word16.word -> int) -> unit; privatekeyPubkey
val () = _export "cusp_privatekey_dup" : (int -> int) -> unit; privatekeyDup
val () = _export "cusp_privatekey_free" : (int -> bool) -> unit; privatekeyFree

(* UDP functions *)
val () = _export "cusp_udp_new" : (int * ptr * ptr -> int) -> unit; udpNew
val () = _export "cusp_udp_close" : (int -> int) -> unit; udpClose
val () = _export "cusp_udp_send" : (int * int * ptr * int -> int) -> unit; udpSend
val () = _export "cusp_udp_recv" : (int * ptr * ptr * ptr -> Word8Array.array) -> unit; udpRecv
val () = _export "cusp_udp_dup" : (int -> int) -> unit; udpDup
val () = _export "cusp_udp_free" : (int -> bool) -> unit; udpFree

