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

structure KVKademlia :> KV_ENGINE =
   struct
      val applicationName = "kv-kademlia"
      val module = "kv/kademlia"

      structure Kademlia = Kademlia (
         structure Event = Main.Event
         structure Id = ID
         structure RPC = RpcUdp (
            structure Event = Main.Event
            structure UDP = UDP4
         )
      )
      open Kademlia
      structure ValueStore = SimpleValueStore (
         structure Event = Main.Event
         structure Node = Kademlia.Node
      )

      fun expiration () =
         SOME (Time.+ (Main.Event.time (), KVConfig.kademliaLifetime))
         
      fun insert node (id, data) =
         Node.store (node, id, data, expiration (), fn _ => ())
      
      fun find node (id, callback) =
         let
            val receive = ref (fn result => callback (Option.map #2 result))
            val () = Node.retrieve (node, id, fn result => (!receive) result)
         in
            fn () => receive := (fn _ => ())
         end

      fun onJoin callback success = if success then callback () else ()
      
      fun join (_, NONE) callback = callback ()
      |   join (node, SOME bootstrap) callback = 
         Node.join (node, bootstrap, onJoin callback)
      
      fun leave (node, store) callback =
         let
            val () = Node.destroy node
            val () = ValueStore.destroy store
         in
            callback ()
         end
      
      fun usage () =
         print ("Supported arguments are:\n\
         \ \n\
         \--port x                  UDP port to use locally\n\
         \--login x                 addresses of well-known login hosts\n")

      fun selectBootstrap nodes =
         case List.length nodes of
            0 => NONE
          | 1 => SOME (hd nodes)
          | n => SOME (List.nth (nodes, Random.int (getTopLevelRandom (), n)))
         
      fun readArgs args =
         let
            val (args, _) = ArgumentParser.new (args, NONE)
            fun optional x = ArgumentParser.optional args x
            fun parseAddress x = case Address.fromString x of
                  nil => NONE
                | x => SOME x

            val port = optional ("port", #"p", Int.fromString)
            val login = Option.getOpt (optional ("login", #"l", parseAddress), [])

            val fold = List.foldl (fn (a,b) => b ^ " " ^ a) ""
            val () = case ArgumentParser.complainUnused args of
                  nil => ()
                | x => raise Fail ("Illegal parameters: " ^ fold x)
         in
            (port, selectBootstrap login)
         end
         handle exn => ( usage () ; raise At (module ^ "/read-args", exn) )

      fun new args =
         let
            val (port, bootstrap) = readArgs args
            val store = ValueStore.new ()
            val node =
               Node.new (port,
                  ValueStore.storeHandler store,
                  ValueStore.retrieveHandler store,
                  ValueStore.valuesIterator store)
            val () = ValueStore.setNode (store, node)
         in
            ({
               join  = join (node, bootstrap),
               leave = leave (node, store)
            }, {
               nodeID = Node.myId node,
               insert = insert node,
               update = insert node,
               delete = fn _ => (), (* impossible with Kademlia *)
               find   = find node
            })
         end
   end

structure Application = KeyValueApplication(KVKademlia)
