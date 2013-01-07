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

val module = "kv/kademlia"

(* statistics *)
(*fun defaultStatistics name =
   Statistics.new {
      parents = nil,
      name = name,
      units = units,
      histogram = Statistics.NO_HISTOGRAM,
      label = List.last (String.tokens (fn c => c = #"/") name),
      units = units,
      persistent = true
   }
val statStoreBubbleSize = defaultStatistics "store bubble size"*)

structure Kademlia = Kademlia (
   structure Event = Main.Event
   structure Id = ID
   structure RPC = RpcUdp (
      structure Event = Main.Event
      structure UDP = UDP4
   )
)
structure ValueStore = SimpleValueStore (
   structure Event = Main.Event
   structure Node = Kademlia.Node
)

open Log
open Kademlia

structure KeyValueStore :> KEY_VALUE_STORE =
   struct
      structure Address = Address
      structure ID = ID
      datatype t = T of {
         node : Node.t,
         bootstrap : Address.t option
      }
      
      fun new {port, bootstrap, login=_, bandwidth=_, minBandwidth=_} =
         let
            val store = ValueStore.new ()
            val node =
               Node.new (port,
                  ValueStore.storeHandler store,
                  ValueStore.retrieveHandler store,
                  ValueStore.valuesIterator store)
            val () = ValueStore.setNode (store, node)
         in
            T {
               node = node,
               bootstrap = bootstrap
            }
         end
      
      fun create (T { ... }, _, done) =
         let
(*             val () = log (INFO, module, fn () => "Creating unconnected node") *)
         in
            done () (* TODO anything? *)
         end

      fun join (T { node, bootstrap, ... }, done) =
         let
(*             val () = log (INFO, module, fn () => "Joining...") *)
            val bootstrapAddr =
               case bootstrap of
                  SOME bs => bs
                | NONE =>
                     let
                        val wellKnownAddrs = nil (* HACK, was: Address.fromString wellKnownAddr *)
                        val count = List.length wellKnownAddrs
                        val rnd = getTopLevelRandom ()
                     in
                        if count > 0
                        then List.nth (wellKnownAddrs, Random.int (rnd, count))
                        else raise At (module, Fail "No bootstrap address")
                     end
            fun joinCb true = done ()
             |  joinCb false = () (* TODO retry/...? *)
         in
            Node.join (node, bootstrapAddr, joinCb)
         end
      
      fun leave (T { node, ... }, done) =
         (Node.destroy node; done ())
      
      fun store (T { node, ... }, id, value) =
         let
            val () =
               log (INFO, module ^ "/store", 
                  fn () => "Storing document " ^ ID.toString id)
            fun storeCb count =
               log (INFO, module ^ "/store", 
                  fn () => "Stored document " ^ ID.toString id ^ " to "
                     ^ Int.toString count ^ " nodes.")
         in
            Node.store (node, id, value, NONE, storeCb)
         end

      fun retrieve (T { node, ... }, id, callback) =
         let
            val () =
               log (INFO, module ^ "/retrieve", 
                  fn () => "Querying for " ^ ID.toString id)
            val aborted = ref false
            fun retrieveCb (SOME (_, value)) =
               if (!aborted) then ()
               else callback (SOME value)
             |  retrieveCb NONE =
               if (!aborted) then ()
               else callback NONE
            (* TODO Kademlia: native stop!? *)
            val () = Node.retrieve (node, id, retrieveCb)
            fun stop () =
               aborted := true
         in
            stop
         end
      
      (* TODO FIXME *)
      fun delete _ = raise At (module, Fail "delete not yet implemented")
   end

structure Workload = KeyValueWorkload (
   structure KeyValueStore = KeyValueStore
   val name = "kademlia"
)
