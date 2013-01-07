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

val module = "kv/durable"

(* statistics *)
fun defaultStatistics (name, units) =
   Statistics.new {
      parents = nil,
      name = name,
      units = units,
      histogram = Statistics.NO_HISTOGRAM,
      label = List.last (String.tokens (fn c => c = #"/") name),
      persistent = true
   }
val statStoreBubbleSize = defaultStatistics ("kv/durable/store bubble size", "#")
val statStoreBubbleCost = defaultStatistics ("kv/durable/store bubble cost", "bytes")
val statStoredItems     = defaultStatistics ("kv/durable/stored docs", "#")

open Log
open CUSP

structure KeyValueStore :> KEY_VALUE_STORE =
   struct
      structure Address = Address
      structure ID = ID
      structure IDHashTable = HashTable(ID)

      datatype t = T of {
         bubblestorm : BubbleStorm.t,
         storeBubble : BubbleType.durable,
         myItems : DurableBubble.t IDHashTable.t
      }
      
      fun new {port, bootstrap, login, bandwidth, minBandwidth} =
         let
            val privateKey = CUSP.Crypto.PrivateKey.new { entropy = Entropy.get }

            (* BubbleStorm *)
            val bs = BubbleStorm.new {
               bandwidth = bandwidth,
               minBandwidth = minBandwidth,
               port = port,
               privateKey = privateKey,
               encrypt = false
            }
            val master = BubbleStorm.bubbleMaster bs
            
            (* load host cache *)
            val () = BubbleStorm.loadHostCache (bs, {
               data = Word8Vector.tabulate (0, fn _ => 0w0),
               wellKnown = login,
               bootstrap = bootstrap
            })
            
            (* Create store bubble *)
            val backend = FakeDurableStore.new ()
            val storeBubble = BubbleType.newDurable {
               master      = master,
               name        = "data",
               typeId      = 1,
               priority    = NONE,
               reliability = NONE,
               datastore   = FakeDurableStore.datastore backend
            }
            val () = BubbleType.setSizeStat (BubbleType.basicDurable storeBubble, SOME statStoreBubbleSize)
            val () = BubbleType.setCostStat (BubbleType.basicDurable storeBubble, SOME statStoreBubbleCost)

            val () = Statistics.addPoll (statStoredItems, fn () =>
               Statistics.add statStoredItems (
                  Real32.fromInt (FakeDurableStore.size backend)
                )
            )
         in
            T {
               bubblestorm = bs,
               storeBubble = storeBubble,
               myItems = IDHashTable.new ()
            }
         end
      
      fun create (T { bubblestorm, ... }, localAddr, done) =
         BubbleStorm.create (bubblestorm, localAddr, done)

      fun join (T { bubblestorm, ... }, done) =
         BubbleStorm.join (bubblestorm, done)
      
      fun leave (T { bubblestorm, ... }, done) =
         BubbleStorm.leave (bubblestorm, done)
      
      fun store (T { storeBubble, myItems, ... }, id, value) =
         let
            val () = log (INFO, module ^ "/store", 
                  fn () => "Storing document " ^ ID.toString id)
            val item = DurableBubble.create {
               typ = storeBubble,
               id = id,
               data = value
            }
         in
            IDHashTable.add (myItems, id, item)
         end

      fun retrieve (T { storeBubble, ... }, id, callback) =
         let
            val () = log (INFO, module ^ "/retrieve", 
                  fn () => "Querying for " ^ ID.toString id)
            fun returnResult bubble = callback (SOME (DurableBubble.data bubble))
         in
            DurableBubble.lookup {
               typ = storeBubble,
               id = id,
               receive = returnResult
            }
         end
      
      fun delete (T { myItems, ... }, id) =
         let
            val () = log (INFO, module ^ "/delete", 
                  fn () => "Deleting document " ^ ID.toString id)
            val item = IDHashTable.remove (myItems, id)
         in
            DurableBubble.delete item
         end
   end

structure Workload = KeyValueWorkload (
   structure KeyValueStore = KeyValueStore
   val name = "durable"
)
