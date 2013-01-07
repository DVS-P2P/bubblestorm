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

functor KeyValueWorkload (structure KeyValueStore : KEY_VALUE_STORE
                          val name : string)
   :> KEY_VALUE_WORKLOAD where type KeyValueStore.t = KeyValueStore.t
   =
   struct
      val docLifetime = Time.fromMinutes 5
      val docPlacement = Time.fromMinutes 1
      val baseActivityInterval = ref 60
      val storeRatio = 0.01
      val queryTimeout = Time.fromSeconds 60
      fun docSize () = 20000
      
      val growthTriggered = ref NONE
      
      val module = "kv/workload"
      
      structure Event = Main.Event
      structure KeyValueStore = KeyValueStore
      structure Address = KeyValueStore.Address
      structure ID = KeyValueStore.ID
      structure GlobalDocTable = GlobalDocTable(ID)
      
      open Log
      
      (* statistics *)
      fun defaultStatistics (statname, units) =
         Statistics.new {
            parents = nil,
            name = "kv/" ^ name ^ "/" ^ statname,
            units = units,
            label = statname,
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }
      val statJoined           = defaultStatistics ("joined nodes", "#")
      val statJoinTime         = defaultStatistics ("join time", "seconds")
      val statLeaveTime        = defaultStatistics ("leave time", "seconds")
      val statRetrSuccess      = defaultStatistics ("retrieve success", "%")
      val statRetrLatency      = defaultStatistics ("retrieve latency", "%")
      val statDocsPublished    = defaultStatistics ("published docs", "#")
      
      val docTable = GlobalDocTable.new ()
      
      datatype t = T of {
         store : KeyValueStore.t,
         stop  : (unit -> unit) ref,
         cleanup : (Event.t ref * GlobalDocTable.doc) Ring.t,
         docCount : int ref
      }
      
      fun new store =
         T {
            store = store,
            stop = ref (fn () => ()),
            cleanup = Ring.new (),
            docCount = ref 0
         }

      (* TODO: move to encoding/decoding of fake documents a better place *)            
      local
         val { toVector, parseVector, length=intSize, ... } = 
            Serial.methods Serial.int32l
      in
         fun encode { version, size } = 
            let
               val head = toVector version
               val tailSize = Int.max (size - intSize, 0)
               val tail = Word8Vector.tabulate (tailSize, fn _ => 0w0)
            in
               Word8Vector.concat [ head, tail ]
            end
            
         fun decode data =
            if Word8Vector.length data < intSize then NONE else
               let
                  val head = Word8VectorSlice.slice (data, 0, SOME intSize)
                  val version = parseVector head
                  val size = Word8Vector.length data
               in
                  SOME {
                     version = version,
                     size = size
                  }
               end
      end

      fun startWorkload (T { store, stop, cleanup, docCount, ... }) =
         let
            (* stop old workload if started twice *)
            val () = (!stop ())

            val random = getTopLevelRandom ()           
            
            fun doStore () =
               let
                  val id = ID.fromRandom random
                  (*val data = Byte.stringToBytes "Some Data."*)
                  val data = encode { version = 0, size = docSize () }
                  val () =
                     log (INFO, module ^ "/store", 
                        fn () => "Storing document " ^ ID.toString id)
                  
                  fun addDoc _ =
                     let
                        val doc = GlobalDocTable.add (docTable, id)
                        val () = docCount := !docCount + 1
                        
                        (* clean up document after expiration and upon leave *)
                        val dummyEvent = Event.new (fn _ => ())
                        val evt = ref dummyEvent
                        val elem = Ring.wrap (evt, doc)
                        val () = Ring.add (cleanup, elem)
                        fun expire _ =
                           let
                              val (_, doc) = Ring.unwrap elem
                              val () = GlobalDocTable.delete (docTable, doc)
                              val () = docCount := !docCount - 1
                              val () = Ring.remove elem
                           in
                              KeyValueStore.delete (store, GlobalDocTable.getID doc)
                           end
                        val () = evt := Event.new expire
                        
                        val uptime = docLifetime
                        val uptime = Time.- (uptime, docPlacement)
                        val uptime = Time.- (uptime, queryTimeout)
                     in
                        Event.scheduleIn (!evt, uptime)
                     end
                  
                  val () = Event.scheduleIn (Event.new addDoc, docPlacement)
               in
                  KeyValueStore.store (store, id, data)
               end

            fun doRetrieve id =
               let
                  val () =
                     log (INFO, module ^ "/retrieve", 
                        fn () => "Querying for " ^ ID.toString id)
                  val done = ref false
                  val tStart = Event.time ()
                  
                  (* response handler *)
                  fun responseCallback (SOME data) =
                     (case decode data of
                        NONE => done := true
                      | SOME { version, size=_ } =>
                         let
                           val () =
                              log (INFO, module ^ "/retrieve", 
                                 fn () => "Retrieved document version: " ^ Int.toString version)
                           val () = Statistics.add statRetrSuccess 1.0
                           val () = Statistics.add statRetrLatency (Time.toSecondsReal32 (Time.- (Event.time (), tStart)))
                        in
                           done := true
                        end)
                   |  responseCallback NONE =
                     let
                        val () =
                           log (INFO, module ^ "/retrieve/fail", 
                              fn () => "No result found for " ^ ID.toString id)
                        val () = Statistics.add statRetrSuccess 0.0
                     in
                        done := true
                     end
                  
                  (* start query *)
                  val stop = KeyValueStore.retrieve (store, id, responseCallback)
                  fun timeout _ =
                     if (!done) then stop () else
                     let
                        val () =
                           log (INFO, module ^ "/retrieve/timeout", 
                              fn () => "Query for " ^ ID.toString id ^ " timed out.")
                        val () = Statistics.add statRetrSuccess 0.0
                     in
                        stop ()
                     end
                  val _ = Event.scheduleIn (Event.new timeout, queryTimeout)
               in
                  ()
               end
            
            fun randomInterval () =
               let
                  val factor =
                     case !growthTriggered of
                        NONE => 1
                      | SOME when => 
                        let
                           val gap = Time.- (Main.Event.time (), when)
                           val minutes = Time.toSecondsReal32 gap / 60.0
                        in
                           Real32.ceil minutes
                        end
                  
                  val interval = Time.fromSeconds (Random.int (random, 2 * !baseActivityInterval))
               in
                  Time.divInt (interval, factor)
               end
            
            fun randomAction evt =
               let
                  val rnd = Random.real random
                  val () =
                     if rnd < storeRatio
                     then doStore ()
                     else
                        case GlobalDocTable.getRandom docTable of
                           SOME id => doRetrieve id
                         | NONE => ()
               in
                  Event.scheduleIn (evt, randomInterval ())
               end
            
            val evt = Event.new randomAction
            val () = Event.scheduleIn (evt, randomInterval ())
            fun stopIt () =
               let
                  fun expireNow elem =
                     let
                        val (ref evt, doc) = Ring.unwrap elem
                        val () = GlobalDocTable.delete (docTable, doc)
                        val () = docCount := !docCount - 1
                     in
                        Event.cancel evt
                     end
                  val () = Ring.app expireNow cleanup
                  val () = Ring.clear cleanup
                  val () = Event.cancel evt
               in
                  stop := (fn () => ())
               end
         in
            stop := stopIt
         end
      
      fun stopWorkload (T { stop, ... }) = (!stop) ()

      val appname = "kv-" ^ name
      
      fun usage () =
         print ("Supported arguments are:\n\
         \ \n\
         \--port x                  UDP port to use locally\n\
         \--login x                 addresses of well-known login host\n\
         \--bootstrap x             address of bootstrap host to contact initially\n\
         \--create x                create a new overlay (x is the local IP address)\n\
         \--bandwidth x             (upstream) bandwidth (in MBit/s)\n\
         \--min-bandwidth x         minimum bandwidth to become a peer (default: 1MBit/s)\n\
         \--baseActivityInterval x  time between query/post operations (before sigusr1)\n")

      fun readArgs () =
         let
            val (args, _) = ArgumentParser.new (CommandLine.arguments (), NONE)
            fun optional x = ArgumentParser.optional args x
            fun parseAddress x = case Address.fromString x of
                  nil => NONE
                | x => SOME x

            val port = optional ("port", #"p", Int.fromString)
            val login = Option.getOpt (optional ("login", #"l", parseAddress), [])
            val bootstrap = Option.map hd (optional ("bootstrap", #"b", parseAddress))
            val myAddress = optional ("create", #"c", parseAddress)
            val bandwidth =
               case optional ("bandwidth", #"x", Real32.fromString) of
                  SOME x => SOME (x * 128000.0) (* convert to bytes/sec *)
                | NONE => NONE
            val minBandwidth =
               case optional ("min-bandwidth", #"m", Real32.fromString) of
                  SOME x => SOME (x * 128000.0) (* convert to bytes/sec *)
                | NONE => NONE
            val () = Option.app (fn x => baseActivityInterval := x)
                        (optional ("baseActivityInterval", #"a", Int.fromString))

            val fold = List.foldl (fn (a,b) => b ^ " " ^ a) ""

            val () = case ArgumentParser.complainUnused args of
                  nil => ()
                | x => raise Fail ("Illegal parameters: " ^ fold x)
         in
            (myAddress, {
               port = port,
               bootstrap = bootstrap,
               login = login,
               bandwidth = bandwidth,
               minBandwidth = minBandwidth
            })
         end
         handle exn => ( usage () ; raise At (module ^ "/main", exn) )
          
      fun main () =
         let
            val (myAddress, config) = readArgs ()
            val store = KeyValueStore.new config
            val workload = new store

            (* document count statistics *)
            fun addCount (T { docCount, ... }) () =
               Statistics.add statDocsPublished (Real32.fromInt (!docCount))
            val () = Statistics.addPoll (statDocsPublished, addCount workload)

            (* how many nodes are actually part of the overlay? *)
            val joined = ref false
            fun boolToReal true = 1.0
             |  boolToReal false = 0.0
            val () = Statistics.addPoll
                  (statJoined, fn () => Statistics.add statJoined (boolToReal (!joined)))
            val tJoin = Event.time ()
            
            (* leaving the network *)            
            fun onSigInt () =
               let
                  val () = log (DEBUG, module, fn () => "Received SIGINT, leaving...")
                  val tLeave = Event.time ()
                  fun doneLeave () =
                     let
                        val () = log (DEBUG, module, fn () => "Leave complete, stop.")
                        val () = Statistics.add statLeaveTime (Time.toSecondsReal32 (Time.- (Event.time(), tLeave)))
                     in
                        Main.stop ()
                     end
                  val () = stopWorkload workload
                  val () = KeyValueStore.leave (store, doneLeave)
                  val () = joined := false
               in
                  Main.UNHOOK
               end
            val _ = Main.signal (Posix.Signal.int, onSigInt)

            (* delete docs for crashed nodes *)
            fun onSigKill () = ( stopWorkload workload ; Main.UNHOOK )
            val _ = Main.signal (Posix.Signal.kill, onSigKill)
            
            fun onSigUsr () = (growthTriggered := SOME (Main.Event.time ()) ; Main.UNHOOK 	)
            val _ = Main.signal (Posix.Signal.usr1, onSigUsr)

            fun start () =
               let
                  val () = log (DEBUG, module, fn () => "Connected.")
                  val () = joined := true
                  val () = Statistics.add statJoinTime (Time.toSecondsReal32 (Time.- (Event.time(), tJoin)))
                  val () = startWorkload workload
               in
                  ()
               end
            val () = log (DEBUG, module, fn () => "Connecting...")
         in
            case myAddress of
               SOME addr => KeyValueStore.create (store, hd addr, start)
             | NONE => KeyValueStore.join (store, start)
         end

      val () = Main.run (appname, main)
   end
