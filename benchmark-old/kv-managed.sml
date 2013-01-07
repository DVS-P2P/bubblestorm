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

val module = "kv/managed"

(* statistics *)
fun defaultStatistics (name, units) =
   Statistics.new {
      parents = nil,
      name = name,
      units = units,
      label = List.last (String.tokens (fn c => c = #"/") name),
      histogram = Statistics.NO_HISTOGRAM,
      persistent = true
   }
val statStoreBubbleSize = defaultStatistics ("kv/managed/store bubble size", "#")
val statStoreBubbleCost = defaultStatistics ("kv/managed/store bubble cost", "bytes/measurement")
val statQueryBubbleSize = defaultStatistics ("kv/managed/query bubble size", "#")
val statQueryBubbleCost = defaultStatistics ("kv/managed/query bubble cost", "bytes/measurement")

open Log
open CUSP

structure KeyValueStore :> KEY_VALUE_STORE =
   struct
      structure Address = Address
      structure ID = ID
      datatype t = T of {
         bubblestorm : BubbleStorm.t,
         storeBubble : BubbleType.managed,
         query : Query.t
      }
      
      local
         val { parseVector, toVector, length, ... } = Serial.methods ID.t
      in
         val idToVector = toVector
         fun parseId slice = (parseVector slice, length)
      end
      
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
            val dataStore = FakeHashStore.new ()
            val storeBubble = BubbleType.newManaged {
               master      = master,
               name        = "data",
               typeId      = 1,
               priority    = NONE,
               reliability = NONE,
               frontend    = FakeHashStore.frontend (FakeHashStore.new ()),
               backend     = FakeHashStore.backend dataStore
            }
            val () = BubbleType.setSizeStat (BubbleType.basicManaged storeBubble, SOME statStoreBubbleSize)
            val () = BubbleType.setCostStat (BubbleType.basicManaged storeBubble, SOME statStoreBubbleCost)

            (* Create Query *)
            fun queryResponder { query, respond } =
               let
                  val (queryId, _) = parseId query
                  val () =
                     log (DEBUG, module ^ "/queryResponder",
                        fn () => "Received query for " ^ ID.toString queryId)
                  
                  fun writeDoc data (SOME stream) =
                     let
                        val () =
                           log (DEBUG, module ^ "/queryResponder/writeDoc",
                              fn () => "Writing document " ^ ID.toString queryId)
                        fun done OutStream.READY =
                           OutStream.shutdown (stream, fn _ => ())
                        |  done OutStream.RESET =
                           (print "Sending result document failed"
                           ; OutStream.reset stream)
                     in
                        OutStream.write (stream, data, done)
                     end
                   |  writeDoc _ NONE =
                     log (DEBUG, module ^ "/queryResponder/writeDoc",
                        fn () => "Not writing document " ^ ID.toString queryId)
               in
                  case FakeHashStore.get dataStore queryId of
                     SOME data => respond { id = queryId, write = writeDoc data } 
                   | NONE => ()
               end
            val query =
               Query.new {
                  master = master,
                  dataBubble = BubbleType.persistentManaged storeBubble,
                  queryBubbleId = 2,
                  queryBubbleName = "query",
                  lambda = 4.0,
                  priority = NONE,
                  reliability = NONE,
                  responder = queryResponder
               }
            val queryBubble = Query.queryBubble query
            val () = BubbleType.setSizeStat (BubbleType.basicInstant queryBubble, SOME statQueryBubbleSize)
            val () = BubbleType.setCostStat (BubbleType.basicInstant queryBubble, SOME statQueryBubbleCost)
         in
            T {
               bubblestorm = bs,
               storeBubble = storeBubble,
               query = query
            }
         end
      
      fun create (T { bubblestorm, ... }, localAddr, done) =
         let
(*            val () = log (INFO, module,
               fn () => ("Creating self loop with local address " ^ CUSP.Address.toString localAddr))*)
         in
            BubbleStorm.create (bubblestorm, localAddr, done)
         end

      fun join (T { bubblestorm, ... }, done) =
         let
(*             val () = log (INFO, module, fn () => "Joining...") *)
         in
            BubbleStorm.join (bubblestorm, done)
         end
      
      fun leave (T { bubblestorm, ... }, done) =
         BubbleStorm.leave (bubblestorm, done)
      
      fun store (T { storeBubble, ... }, id, value) =
         let
            val () =
               log (INFO, module ^ "/store", 
                  fn () => "Storing document " ^ ID.toString id)
         in
            ignore (ManagedBubble.create {
               typ = storeBubble,
               id = id,
               data = value,
               done = fn () => ()
            })
         end

      fun retrieve (T { query, ... }, id, callback) =
         let
            val () =
               log (INFO, module ^ "/retrieve", 
                  fn () => "Querying for " ^ ID.toString id)
            (* response handler *)
            fun responseCallback { id, stream } =
               let
                  val () =
                     log (DEBUG, module ^ "/retrieve", 
                        fn () => "Received a response: " ^ ID.toString id)
                  fun readStream (is, callback) =
                     let
                        fun read data =
                           InStream.read (is, ~1, readDone data)
                        and readDone data (InStream.DATA slice) =
                           read ((Word8ArraySlice.vector slice)::data)
                        |  readDone data InStream.SHUTDOWN =
                           (InStream.reset is
                           ; callback (SOME (Word8Vector.concat (List.rev data))))
                        |  readDone _ InStream.RESET =
                           (InStream.reset is; callback NONE)
                     in
                        read []
                     end
               in
                  readStream (stream, callback)
               end
            (* start query *)
            val queryData = idToVector id
            val stop =
               Query.query (query, {
                  query = queryData,
                  responseCallback = responseCallback
               })
         in
            stop
         end
      
      fun delete (T { storeBubble, ... }, id) =
         let
            fun doDelete NONE =
               log (ERROR, module ^ "/delete", fn () => "could not find item " ^ ID.toString id ^ " locally")
              | doDelete (SOME item) =
               ManagedBubble.delete { bubble = item, done = fn () => () }
         in
            ManagedBubble.get { typ = storeBubble, id = id, callback = doDelete }
         end
   end

structure Workload = KeyValueWorkload (
   structure KeyValueStore = KeyValueStore
   val name = "managed"
)
