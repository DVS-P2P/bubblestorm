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

structure Value = DummyValue(
   structure Id = ID
   val defaultExpiration = Time.fromMinutes 120
)
structure Kademlia = Kademlia(
   structure Event = Main.Event
   structure Value = Value
   structure Id = Value.Id
   structure RPC = RpcUdp(
      structure Event = Main.Event
      structure UDP = UDP4
   )
)
structure ValueStore = SimpleValueStore(
   structure Event = Main.Event
   structure Node = Kademlia.Node
)
open Kademlia
open Log

(* val () = HostCache.addGlobal (hd (Address.fromString "127.0.0.1")) *)

(* statistics *)
fun defaultStatistics name =
   Statistics.new {
      parents = nil,
      name = name,
      units = "", (* TODO value *)
      label = "", (* TODO value *)
      histogram = Statistics.NO_HISTOGRAM,
      persistent = true
   }
val statJoinSuccess = defaultStatistics "join success"
val statJoinTime = defaultStatistics "join time"
val statStoreSuccess = defaultStatistics "store success"
val statStoreReplication = defaultStatistics "store replication"
val statStoreLatency = defaultStatistics "store latency"
val statRetrSuccess = defaultStatistics "retrieve success"
val statRetrLatency = defaultStatistics "retrieve latency"

(* global document table *)
local
   val table : (Value.t * Time.t) Stack.t =
      Stack.new {nill = (Option.valOf (DummyValue.fromString "0"), Time.zero)}
   fun removeValue pos =
      Stack.update (table, pos, Option.valOf (Stack.pop table))
in
   fun storeDocument value =
      ignore (Stack.push (table, (value, Event.time ())))
   fun getRandomExistingDocumentId () =
      let
         val count = Stack.length table
         val now = Event.time ()
         fun get () =
            let
               val pos = Random.int (getTopLevelRandom (), count)
               val (value, store) = Stack.sub (table, pos)
            in
               if Time.<= (now, Time.+ (store, Value.expires value))
               then Value.id value
               else (removeValue pos; get ())
            end
      in
         if count > 0
         then SOME (get ())
         else NONE
      end
end

(* execute activities (store, retrieve) on the node *)
fun nodeActivity node =
   let
      fun retrieve id =
         let
            val tStart = Event.time ()
            val () = log (INFO, "kademlia/test/retrieve",
               fn () => ("Retrieving value with ID " ^ Id.toString id))
            
            fun retrieveCb (SOME value) =
               let (* retrieve successful *)
                  val () = Statistics.add statRetrSuccess 1.0
                  val () = Statistics.add statRetrLatency
                     (Time.toSecondsReal32 (Time.- (Event.time (), tStart)))
                  val () =
                     log (INFO, "kademlia/test/retrieve",
                        fn () => "Retrieval of value with ID " ^ Id.toString id ^ " succeeded: "
                           ^ Value.toString value)
               in
                  ()
               end
            | retrieveCb NONE =
               let (* retrieve failed *)
                  val () = Statistics.add statRetrSuccess 0.0
                  val () =
                     log (WARNING, "kademlia/test/retrieve",
                        fn () => "Retrieval of value with ID " ^ Id.toString id ^ " failed.")
               in
                  ()
               end
         in
            Node.retrieve (node, id, retrieveCb)
         end
      
      fun store () =
         let
            val tStart = Event.time ()
            val value = Value.createRandom ()
            val () = log (INFO, "kademlia/test/store",
               fn () => ("Storing value " ^ Value.toString value))
            
            fun storeCb count =
               if count > 0
               then
                  let (* store successful *)
                     val () = Statistics.add statStoreSuccess 1.0
                     val () = Statistics.add statStoreReplication (Real32.fromInt count)
                     val storeLatency = Time.toSecondsReal32 (Time.- (Event.time (), tStart))
                     val () = Statistics.add statStoreLatency storeLatency
                     val () = log (INFO, "kademlia/test/store",
                        fn () => "Successfully stored value to " ^ Int.toString count ^ " nodes"
                           ^ " in " ^ Real32.toString storeLatency ^ " seconds .")
                  in
                     storeDocument value
                  end
               else
                  let (* store failed *)
                     val () = Statistics.add statStoreSuccess 0.0
                     val () = Statistics.add statStoreReplication 0.0
                     val () = log (WARNING, "kademlia/test/store",
                        fn () => "Storage of value " ^ Value.toString value ^ " failed.")
                  in
                     ()
                  end
         in
            Node.store (node, Value.id value, Word8Vector.tabulate(0, 0w0), Value.expires value, storeCb)
         end
      
      val random = getTopLevelRandom ()
      fun randomInterval () =
         Time.fromSeconds (Random.int (random, 60))
      
      fun randomAction evt =
         let
            val rnd = Random.real random
            val () =
               if rnd < 0.1
               then store ()
               else
                  case getRandomExistingDocumentId () of
                     SOME id => retrieve id
                   | NONE => ()
         in
            Event.scheduleIn (evt, randomInterval ())
         end
      
   in
      (* schedule actions *)
      Event.scheduleIn (Event.new randomAction, Time.+ (randomInterval (), Time.fromMinutes 1))
   end

fun startup () =
   let
      (* TODO re-join with persistent ID *)
      
      (* bootstrap nodes *)
      local
         val wellKnownAddrs = Address.fromString "join.bubblestorm.net:8585"
         val addrCount = List.length wellKnownAddrs
         val () = if addrCount > 0 then () else raise At("kademlia/test", Fail "No bootstrap address")
         val random = getTopLevelRandom ()
      in
         fun bootstrapAddress () =
            List.nth (wellKnownAddrs, Random.int (random, addrCount))
   (*          HostCache.get (HostCache.new (0, 0)) *)
      end

      fun usage () =
         let
            val () = print "Usage:\n\
               \kademlia-test bootstrap    <my-port>     creates a new overlay network\n\
               \kademlia-test join <addr> [<my-port>]    joins a network\n\
               \kademlia-test             [<my-port>]    joins using the host cache\n"
         in
            OS.Process.exit OS.Process.failure
         end
      
      (* process command line *)
      val (bootstrapAddr, bindPort) = 
         case CommandLine.arguments () of
            ["bootstrap", port] => (NONE, Int.fromString port)
          | ["join", addr, port] => (SOME (hd (Address.fromString addr)), Int.fromString port)
          | ["join", addr] => (SOME (hd (Address.fromString addr)), NONE)
          | [port] => (SOME (bootstrapAddress ()), Int.fromString port)
          | [] => (SOME (bootstrapAddress ()), NONE)
          | _ => usage ()
      
      (* create store & node *)
      val store = ValueStore.new ()
      val node =
         Node.new (bindPort,
            ValueStore.storeHandler store,
            ValueStore.retrieveHandler store,
            ValueStore.valuesIterator store)
      val () = ValueStore.setNode (store, node)
      fun destroy () =
         (Node.destroy node
         ; ValueStore.destroy store)
      
      (* SIGINT handler *)
      fun sigIntHandler () =
         let
            val () = log (INFO, "kademlia/test/shutdown", fn () => "Shutting down.")
            val () = destroy ()
            val () = Main.stop ()
         in
            Main.UNHOOK
         end
      val _ = Main.signal (Posix.Signal.int, sigIntHandler)
      
      (* join *)
      val joinStart = Event.time ()
      fun joinCb false =
         let
            val () = log (ERROR, "kademlia/test/startup", fn () => "Join failed.")
            val () = Statistics.add statJoinSuccess 0.0
            val () = destroy ()
         in
            Main.stop ()
         end
       | joinCb true =
         let
            val () = log (INFO, "kademlia/test/startup", fn () => "Joined successfully.")
            val () = Statistics.add statJoinSuccess 1.0
            val () = Statistics.add statJoinTime
               (Time.toSecondsReal32 (Time.- (Event.time (), joinStart)))
         in
            nodeActivity node
         end
      val () = case bootstrapAddr of
         SOME addr =>
            (log (INFO, "kademlia/test/startup", fn () => "Joining.")
            ; Node.join (node, addr, joinCb))
       | NONE =>
            log (INFO, "kademlia/test/startup", fn () => "I am the initial Node.")
   in
      log (INFO, "kademlia/test/startup",
         fn () => "Node " ^ Id.toString (Node.myId node) ^ " starting up.")
   end

val () = Main.run ("kademlia-test", startup)
