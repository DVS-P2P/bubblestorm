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

structure HostCache :> HOST_CACHE =
   struct
      (* TODO move to global config *)
      (* max. number of host cache entries *)
      val hostCacheLimit = 1000
      (* decay factor of bootstrap node availability *)
      val hostCacheAvailabilityDecay : Real32.real = 0.1
      (* availability value of new host cache entries *)
      val hostCacheInitialAvailability : Real32.real = 0.5
      
      val module = "bubblestorm/hostCache"
      
      (* Host heap key: availability
       * Host heap value: address
       * Host map key: address
       * Host map value: host heap record
       *)
      type hostEntry = CUSP.Address.t
      structure HostHeapKey =
         struct
            type t = Real32.real
            val op < = Real32.<
            val op == = Real32.==
         end
      structure HostHeap = ManagedHeap (OrderFromLessEqual (HostHeapKey))
      structure HostMap = HashTable (CUSP.Address)
      
      datatype t = T of {
         hostHeap : hostEntry HostHeap.t,
         hostMap : hostEntry HostHeap.record HostMap.t,
         explicitBootstrapAddr : CUSP.Address.t option ref
      }
      
      (* serialization functions *)
      local
         open Serial
         val s = aggregate tuple2 `CUSP.Address.t `real32l $
         val { toVector, parseVector, length, ... } = methods s
      in
         val hostEntryToVector = toVector
         val hostEntryFromVectorSlice = parseVector
         val hostEntryDataLength = length
      end
      
      (* --- public API --- *)
      
      fun new () =
         let
            (* prepare the host cache *)
            val hostHeap = HostHeap.new ()
            val hostMap = HostMap.new ()
         in
            T {
               hostHeap = hostHeap,
               hostMap = hostMap,
               explicitBootstrapAddr = ref NONE
            }
         end
      
      (* returns a randomly selected address from the host cache *)
      fun getAddressInternal (T { hostHeap, ... }) =
         if HostHeap.isEmpty hostHeap
         then raise At (module, Fail "No host in cache")
         else
            let
               val hostIt = HostHeap.iterator hostHeap
               val availabilities =
                  Iterator.map
                  (fn record => (#2 o HostHeap.sub) record)
                  hostIt
               val avSum = Iterator.fold Real32.+ 0.0 availabilities
               val rnd = getTopLevelRandom ()
               val p = avSum * Random.real32 rnd
               fun walk (it, sum) =
                  case Iterator.getItem it of
                     SOME (record, nextIt) =>
                        let
                           val (_, v, addr) = HostHeap.sub record
                           val sum = sum + v
                        in
                           if p <= sum
                           then addr
                           else walk (nextIt, sum)
                        end
                   | NONE => raise At (module, Fail "Inconsistent host selection")
            in
               walk (hostIt, 0.0)
               (*case HostHeap.peek hostHeap of
                  SOME el => #3 (HostHeap.sub el)
               | NONE => raise At (module, Fail "No host in cache")*)
            end
      
      (* returns the address to a bootrap node from the host cache *)
      fun getAddress (this as T { explicitBootstrapAddr, ... }) =
         case !explicitBootstrapAddr of
            SOME addr => ( (*explicitBootstrapAddr := NONE ; *) addr )
            (* FIXME resetting explicitBootstrapAddr this breaks things, need to work around this... *)
          | NONE => getAddressInternal this
      
      (* indicates that a bootstrap node address has been found, updates the cache accordingly *)
      fun addAddress (T { hostHeap, hostMap, ... }, addr) =
         let
            fun addEntry () =
               let
                  val v = hostCacheInitialAvailability
                  val () =
                     Log.logExt (Log.DEBUG, fn () => module ^ "/addAddress",
                        fn () => "Adding " ^ CUSP.Address.toString addr ^ " ("
                           ^ Real32.toString v ^ ") to local cache")
                  val record = HostHeap.wrap (v, addr)
                  val () = HostHeap.push (hostHeap, record)
               in
                  HostMap.add (hostMap, addr, record)
               end
            fun updateEntry record =
               let
                  val (_, v, _) = HostHeap.sub record
                  val new = Real32.+ (v, hostCacheAvailabilityDecay)
                  val () =
                     Log.logExt (Log.DEBUG, fn () => module ^ "/addAddress",
                        fn () => "Updating " ^ CUSP.Address.toString addr ^ " ("
                           ^ Real32.toString new ^ ") in local cache")
               in
                  HostHeap.update (hostHeap, record, new)
               end
         in
            case HostMap.get (hostMap, addr) of
               SOME record => updateEntry record
             | NONE => addEntry ()
         end
      
      (* trims the cache to a maximum size of hostCacheLimit *)
      fun trimCache (T { hostHeap, ... }) =
         let
            val reduce = HostHeap.size hostHeap - hostCacheLimit
         in
            if reduce <= 0 then ()
            else
               Iterator.app
               (fn _ => ignore (HostHeap.pop hostHeap))
               (Iterator.fromInterval { start = 1, stop = reduce, step = 1 })
         end
      
      (* decays all availability values by the hostCacheAvailabilityDecay factor *)
      fun decayAvailabilities (T { hostHeap, hostMap, ... }) =
         let
            val factor = 1.0 - hostCacheAvailabilityDecay
            fun decay (_, record) =
               let
                  val (_, v, _) = HostHeap.sub record
                  val new = Real32.* (factor, v)
               in
                  HostHeap.update (hostHeap, record, new)
               end
         in
            Iterator.app decay (HostMap.iterator hostMap)
         end
      
      fun getHostCacheData (T { hostHeap, ... }) =
         let
            fun serializeEntry record =
               let
                  val (_, v, addr) = HostHeap.sub record
               in
                  hostEntryToVector (addr, v)
               end
         in
            Word8Vector.concat (Iterator.toList
               (Iterator.map serializeEntry (HostHeap.iterator hostHeap)))
         end
      
      exception InvalidHostCacheData
      
      fun setHostCacheData (T { hostHeap, hostMap, explicitBootstrapAddr, ... }, 
                            data, wellKnownEntries, bootstrap) =
         let
            (* clear cache *)
            val () = HostMap.clear hostMap
            val () = HostHeap.clear hostHeap
            (* add well-known entries *)
            val () = explicitBootstrapAddr := bootstrap
            fun addWellKnownEntry addr =
               let
                  val v = 1.0 (* FIXME inf? *)
                  val () =
                     Log.logExt (Log.DEBUG, fn () => module ^ "/setHostCacheData",
                        fn () => "Adding well-known address " ^ CUSP.Address.toString addr)
                  val record = HostHeap.wrap (v, addr)
                  val () = HostHeap.push (hostHeap, record)
               in
                  HostMap.add (hostMap, addr, record)
               end
            val () = List.app addWellKnownEntry wellKnownEntries
            (* add entries from data *)
            fun addEl slice =
               if Word8VectorSlice.isEmpty slice then ()
               else
                  let
                     val (addr, v) = hostEntryFromVectorSlice slice
                     val record = HostHeap.wrap (v, addr)
                     val () = HostHeap.push (hostHeap, record)
                     val () = HostMap.add (hostMap, addr, record)
                  in
                     addEl (Word8VectorSlice.subslice (slice, hostEntryDataLength, NONE))
                  end
         in
            addEl (Word8VectorSlice.full data)
         end
      
   end
