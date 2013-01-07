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

structure KVBubbleStorm :
   sig
      val new : string list -> BubbleStorm.t * KVInterface.overlay
      val prepareQuery : {
         bubblestorm : BubbleStorm.t,
         dataBubble  : BubbleType.persistent,
         lookup      : ID.t -> FakeItem.t option
      } -> ID.t * (Word8Vector.vector option -> unit) -> (unit -> unit)
   end
=
   struct
      val module = "kv/bubblestorm"
      
      fun join (bubblestorm, myAddress) done =
            case myAddress of
               SOME addr => BubbleStorm.create (bubblestorm, addr, done)
             | NONE => BubbleStorm.join (bubblestorm, done)
      
      fun leave bubblestorm done = BubbleStorm.leave (bubblestorm, done)
      
      fun usage () =
         print ("Supported arguments are:\n\
         \ \n\
         \--port x                  UDP port to use locally\n\
         \--login x                 addresses of well-known login hosts\n\
         \--bootstrap x             address of bootstrap host to contact initially\n\
         \--create x                create a new overlay (x is the local IP address)\n\
         \--bandwidth x             (upstream) bandwidth (in MBit/s)\n\
         \--min-bandwidth x         minimum bandwidth to become a peer (default: 1MBit/s)\n")

      fun readArgs args =
         let
            val (args, _) = ArgumentParser.new (args, NONE)
            fun optional x = ArgumentParser.optional args x
            fun parseAddress x = case CUSP.Address.fromString x of
                  nil => NONE
                | x => SOME x

            val port = optional ("port", #"p", Int.fromString)
            val login = Option.getOpt (optional ("login", #"l", parseAddress), [])
            val bootstrap = Option.map hd (optional ("bootstrap", #"b", parseAddress))
            val myAddress = Option.map hd (optional ("create", #"c", parseAddress))
            val bandwidth =
               case optional ("bandwidth", #"x", Real32.fromString) of
                  SOME x => SOME (x * 128000.0) (* convert to bytes/sec *)
                | NONE => NONE
            val minBandwidth =
               case optional ("min-bandwidth", #"m", Real32.fromString) of
                  SOME x => SOME (x * 128000.0) (* convert to bytes/sec *)
                | NONE => NONE

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
         handle exn => ( usage () ; raise At (module ^ "/read-args", exn) )

      fun new args =
         let
            val (myAddress, {port, bootstrap, login, bandwidth, minBandwidth}) 
               = readArgs args

            val privateKey = CUSP.Crypto.PrivateKey.new { entropy = Entropy.get }

            (* BubbleStorm *)
            val this = BubbleStorm.new {
               bandwidth = bandwidth,
               minBandwidth = minBandwidth,
               port = port,
               privateKey = privateKey,
               encrypt = false
            }
            (* load host cache *)
            val () = BubbleStorm.loadHostCache (this, {
               data = Word8Vector.tabulate (0, fn _ => 0w0),
               wellKnown = login,
               bootstrap = bootstrap
            })
            
            (* interface *)
            val interface = {
               join = join (this, myAddress),
               leave = leave this
            }
         in
            (this, interface)
         end

      (* send an item *)
      fun writeItem _ NONE = () (* request canceled by receiver *)
      |   writeItem data (SOME stream) =
         let
            open CUSP.OutStream
            fun done READY = shutdown (stream, fn _ => ())
            |   done RESET = reset stream
         in
            write (stream, data, done)
         end

      (* receive an item *)
      fun readItem (stream, callback) =
         let
            fun append (data, slice) = (Word8ArraySlice.vector slice)::data
            fun deliver data = callback (SOME (Word8Vector.concat (List.rev data)))

            open CUSP.InStream
            fun readStream data = read (stream, ~1, receive data)
            and receive data (DATA slice) = readStream (append (data, slice))
              | receive data  SHUTDOWN    = ( reset stream ; deliver data )
              | receive _     RESET       = ( reset stream ; callback NONE )
         in
            readStream []
         end
   
      (* process incoming queries *)
      fun match lookup { query, respond } =
         match' (lookup, FakeItem.decodeQuery query, respond)
      and match' (lookup, queryId, respond) =
         case lookup queryId of 
            SOME data => respond {
               id = FakeItem.toHashID data,
               write = (writeItem o FakeItem.encode) data
            } 
          | NONE => ()

      (* start query *)
      fun find query (id, callback) =
         Query.query (query, {
            query = FakeItem.encodeQuery id,
            responseCallback = fn { id=_, stream } => readItem (stream, callback)
         })
   
      (* create query bubble *)
      fun prepareQuery { bubblestorm, dataBubble, lookup } =
         let
            val query = (Query.new {
               master = BubbleStorm.bubbleMaster bubblestorm,
               dataBubble = dataBubble,
               queryBubbleId = KVConfig.queryBubbleID,
               queryBubbleName = "query",
               lambda = KVConfig.lambda,
               priority = NONE,
               reliability = NONE,
               responder = match lookup
            })
            val queryBubble = BubbleType.basicInstant (Query.queryBubble query)
            val dataBubble = BubbleType.basicPersistent dataBubble
            val () = BubbleType.setSizeStat (dataBubble,  SOME KVStats.dataBubbleSize)
            val () = BubbleType.setCostStat (dataBubble,  SOME KVStats.dataBubbleCost)
            val () = BubbleType.setSizeStat (queryBubble, SOME KVStats.queryBubbleSize)
            val () = BubbleType.setCostStat (queryBubble, SOME KVStats.queryBubbleCost)
         in
            find query
         end
   end
