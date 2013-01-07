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

functor Conversation(structure CUSP : CUSP
                     structure Event : EVENT
                     structure Log : LOG
                     structure Statistics : STATISTICS) :> 
   CONVERSATION where type endpoint  = CUSP.EndPoint.t
                where type instream  = CUSP.InStream.t
                where type outstream = CUSP.OutStream.t
                where type host      = CUSP.Host.t
                where type address   = CUSP.Address.t
                where type service   = CUSP.EndPoint.service
                where type Statistics.t = Statistics.t =
   struct
      structure CUSP = CUSP
      structure Statistics = Statistics
      
      open CUSP
      open Log
      
      type endpoint  = CUSP.EndPoint.t
      type instream  = CUSP.InStream.t
      type outstream = CUSP.OutStream.t
      type host      = CUSP.Host.t
      type address   = CUSP.Address.t
      type service   = CUSP.EndPoint.service
      
      fun // (a, b) = let val () = a in b end
      infix 0 //
      
      structure HeapKey =
         struct
            type t = Real32.real
            val op <  = Real32.< (* Smallest first *)
            val op == = Real32.==
         end
      structure Heap = ManagedHeap(OrderFromLessEqual(HeapKey))
      
      datatype fields = T of {
         host       : Host.t,
         plist      : PropertyList.t,
         progress   : Time.t,
         created    : Time.t,
         instreams  : InStream.t Heap.t,
         inbuffer   : int,
         outstreams : OutStream.t Heap.t,
         outbuffer  : int,
         traffic    : Int64.int,
         listeners  : EndPoint.service Ring.t,
         close      : unit -> unit,
         timeout    : timeout option,
         limits     : limits  option
      }
      withtype t = fields ref
      and timeout = { 
         limit : Time.t, 
         dead  : unit -> unit,
         event : Event.t
      }
      and limits = {
         recv  : int,
         send  : int,
         quota : unit -> unit
      }
      type conversation = t

      fun hostToStr host = Option.getOpt (Option.map Address.toString
         (Host.remoteAddress host), "-")
      
      open FunctionalRecordUpdate
      fun get f (ref (T fields)) = f fields
      fun update (this as ref (T fields)) =
         let
            fun from v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 =
               {host=v1,progress=v2,instreams=v3,inbuffer=v4,outstreams=v5,
                outbuffer=v6,listeners=v7,close=v8,timeout=v9,limits=v10,
                plist=v11,created=v12,traffic=v13}
            fun to f
               {host=v1,progress=v2,instreams=v3,inbuffer=v4,outstreams=v5,
                outbuffer=v6,listeners=v7,close=v8,timeout=v9,limits=v10,
                plist=v11,created=v12,traffic=v13} =
               f v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13
         in
            Fold.post (makeUpdate13 (from, from, to) fields,
                       fn z => this := T z)
         end
      
      fun eq (a:t, b) = a = b
      
      fun host this = get#host this
      fun plist this = get#plist this
      fun traffic this = get#traffic this
      fun created this = get#created this
      
      fun toString this =
         getOpt (Option.map Address.toString (Host.remoteAddress (host this)),
                 "<dead-link>")
      
      fun activeInStreams  this = Heap.size (get#instreams  this)
      fun activeOutStreams this = Heap.size (get#outstreams this)
      
      fun checkTimeout this _ =
         let
            val { limit, dead, event } = valOf (get#timeout this)
            open Time
            val idle = Event.time () - (get#progress this)
            val remaining = limit - idle
         in
            if remaining > Time.zero
            then Event.scheduleIn (event, remaining)
            else
               (update this set#timeout NONE $
                ; log (DEBUG, "conversation",
                  fn () => "Conversation timeout exceeded.")
                ; dead ())
         end
      
      fun setTimeout (this, x) =
         let
            val () = 
               case get#timeout this of
                  SOME { event, ... } => Event.cancel event
                | NONE => ()
            val () = update this set#timeout NONE $
         in
            case x of
               NONE => ()
             | SOME { limit, dead } =>
               let
                  open Time
                  val idle = Event.time () - (get#progress this)
                  val remaining = limit - idle
                  val event = Event.new (checkTimeout this)
               in
                  if remaining > Time.zero then
                     let
                        val () = Event.scheduleIn (event, remaining)
                        val timeout = SOME {
                           limit = limit,
                           dead  = dead,
                           event = event
                        }
                     in
                        update this set#timeout timeout $
                     end
                  else
                     let
                        val () = log (DEBUG, "conversation",
                           fn () => "Conversation timeout exceeded when set.")
                     in 
                        dead ()
                     end
               end
         end
      
      fun checkLimitsIn this =
         let
            fun killInStream quota =
               case Heap.peekBounded (get#instreams this, Real32.maxFinite) of
                  NONE =>
                     (update this set#limits NONE $
                      ; log (WARNING, "conversation",
                        fn () => "Reliable instreams exceeded quota.")
                      ; quota ())
                | SOME record =>
                     (InStream.reset (#3 (Heap.sub record))
                      ; log (DEBUG, "conversation",
                        fn () => "Killed an instream (recvLimit exceeded).")
                      ; checkLimitsIn this)
         in
            case get#limits this of
               NONE => ()
             | SOME { recv, quota, ... } =>
                  if get#inbuffer this > recv then killInStream quota else ()
         end
      
      fun checkLimitsOut this =
         let
            fun killOutStream quota =
               case Heap.peekBounded (get#outstreams this, Real32.maxFinite) of
                  NONE =>
                     (update this set#limits NONE $
                      ; log (WARNING, "conversation",
                        fn () => "Reliable outstreams exceeded quota.")
                      ; quota ())
                | SOME record =>
                     (OutStream.reset (#3 (Heap.sub record))
                      ; log (DEBUG, "conversation",
                        fn () => "Killed an outstream (sendLimit exceeded).")
                      ; checkLimitsOut this)
         in
            case get#limits this of
               NONE => ()
             | SOME { send, quota, ... } =>
                  if get#outbuffer this > send then killOutStream quota else ()
         end
      
      fun setLimits (this, x) =
         let
            val () = update this set#limits x $
            val () = checkLimitsIn this
            val () = checkLimitsOut this
         in
            ()
         end
      
      fun reset this = 
         let
            val () = log (DEBUG, "conversation",
               fn () => ("Conversation reset (" ^ hostToStr (get#host this) ^ ")"))
            
            val () = setTimeout (this, NONE)
            
            val () = 
               while not (Heap.isEmpty (get#instreams this)) do
               InStream.reset ((#3 o Heap.sub o valOf o Heap.peek) (get#instreams this))
            val () = 
               while not (Heap.isEmpty (get#outstreams this)) do
               OutStream.reset ((#3 o Heap.sub o valOf o Heap.peek) (get#outstreams this))

            val listeners = Iterator.toList (Ring.iterator (get#listeners this))

            fun unlisten service =
               if service = 0w0 then () else
               Host.unlisten (get#host this, service)
            val () = List.app (unlisten o Ring.unwrap) listeners
         in
            List.app Ring.remove listeners
         end
      
      fun new host = 
         let
            val () = log (DEBUG, "conversation",
               fn () => ("New conversation to " ^ hostToStr host))
            
            val out = ref (T {
               host       = host,
               plist      = PropertyList.new (),
               progress   = Event.time (),
               created    = Event.time (),
               instreams  = Heap.new (),
               inbuffer   = 0,
               outstreams = Heap.new (),
               outbuffer  = 0,
               traffic    = 0,
               listeners  = Ring.new (),
               close      = fn () => (),
               timeout    = NONE,
               limits     = NONE })
         in
            out
         end
      
      fun addInStream (this, instream,
                       { cost, complete, operation, reliability }) =
         let
            val record = Heap.wrap (reliability, instream)
            
            fun done r = 
               let
                  val () = update this upd#inbuffer (fn x => x - cost) $
                  val () = Heap.remove (get#instreams this, record)
               in
                  if not (complete r) then () else
                  update this set#progress (Event.time ()) $
               end
            
            val empty = Heap.isEmpty (get#instreams this)
            val () = 
               if not empty then () else
               update this set#progress (Event.time ()) $ 
            
            val () = update this upd#inbuffer (fn x => x + cost) $
            val () = Heap.push (get#instreams this, record)
            val () = operation done 
                     handle x => 
                     (Heap.remove (get#instreams this, record)
                      ; update this upd#inbuffer (fn x => x - cost) $
                      ; raise x)
         in
            checkLimitsIn this
         end
      
      val ok = fn OutStream.RESET => false | OutStream.READY => true
      fun addOutStream (this, outstream,
                       { cost, complete, operation, reliability }) =
         let
            val record = Heap.wrap (reliability, outstream)
            val queue = 
               OutStream.queuedInflight     outstream +
               OutStream.queuedToRetransmit outstream
            val cost = cost + queue
            
            fun checkClose this =
               let
                  val oldClose = get#close this
               in
                  if not (Heap.isEmpty (get#outstreams this)) then () else
                  (update this set#close (fn () => ()) $; oldClose ())
               end
            
            fun done r = 
               let
                  val () = update this upd#outbuffer (fn x => x - cost) $
                  val () = Heap.remove (get#outstreams this, record)
               in
                  (* success != progress b/c new streams queue up locally.
                   * However, if the queued data is < cost, then there has
                   * been progress in the form of acks.
                   *)
                  if not (complete r) then checkClose this else
                  let
                     val queue = 
                        OutStream.queuedInflight     outstream +
                        OutStream.queuedToRetransmit outstream
                     val () =
                        if queue >= cost then () else
                        update this set#progress (Event.time ()) $
                     
                     val traffic = get#traffic this
                     val change = cost - queue
                     val traffic' = traffic + Int64.fromInt change
                     val () = update this set#traffic traffic' $
                  in
                     checkClose this
                  end
               end
            
            val empty = Heap.isEmpty (get#outstreams this)
            val () = 
               if not empty then () else
               update this set#progress (Event.time ()) $
            
            val () = update this upd#outbuffer (fn x => x + cost) $
            val () = Heap.push (get#outstreams this, record)
            val () = operation done
                     handle x => 
                     (Heap.remove (get#outstreams this, record)
                      ; update this upd#outbuffer (fn x => x - cost) $
                      ; raise x)
         in
            checkLimitsOut this
         end
      
      fun close (this, { complete }) =
         if Heap.isEmpty (get#outstreams this) then
            complete ()
         else
            update this upd#close (fn f => fn () => (complete () // f ())) $
      
      structure Priority =
         struct
            type t = Real32.real
            
            val default : t = 1000.0
            fun fromReal x =
               if Real32.isFinite x then x else raise Domain
         end
      structure Reliability =
         struct
            type t = Real32.real
            
            val reliable = Real32.posInf
            fun fromReal x =
               if Real32.isFinite x then x else raise Domain
         end
      structure QOS =
         struct
            type ('a, 'b) t = 
               (Priority.t * Reliability.t -> 'a) -> 'b
            
            fun static  (p, r) f = f (p, r)
            fun dynamic f (p, r) = f (p, r)
         end
      structure AckInfo =
         struct
            type ('a, 'b) t = 
               ((bool -> unit) -> 'a) -> 'b
            
            fun silent f = f (fn b => 
                  if b then () else
                  log (DEBUG, "conversation", fn () => "Outstream was reset (AckInfo ignored)"))
            fun callback f cb = f cb
         end
      structure Duration =
         struct
            type 'a t = {
               eatReturn : (unit -> unit) -> 'a -> unit,
               limitOnce : unit -> string -> unit
            }
            datatype hook = REHOOK | UNHOOK
            exception OneShotUsedTwice of string
            
            fun fmt (OneShotUsedTwice s) = SOME (concat [ "OneShotUsedTwice \"", s, "\"" ])
               | fmt _ = NONE
            val () = MLton.Exn.addExnMessager fmt
            
            val oneShot = {
               eatReturn = fn unhook => unhook,
               limitOnce = fn () =>
                  let
                     val used = ref false
                  in
                     fn f => 
                        if !used then raise OneShotUsedTwice f else
                        (used := true; ())
                  end
            }
            val permanent = {
               eatReturn = fn _  => ignore,
               limitOnce = fn () => ignore
            }
            val custom = {
               eatReturn = fn unhook => fn 
                  REHOOK => ()
                  | UNHOOK => unhook (),
               limitOnce = fn () => ignore
            }
         end
      structure TailData =
         struct
            type ('a, 'b, 'c) t = {
               sendSuffix : string * ((conversation * OutStream.t * Reliability.t * (bool -> unit) -> unit) -> unit) -> 'a,
               recvSuffix : ('b -> unit) * conversation * InStream.t * Reliability.t * (unit -> 'c) -> unit
            }
            exception StringTooLong of string
            fun fmt (StringTooLong s) = SOME (concat [ "StringTooLong \"", s, "\"" ])
               | fmt _ = NONE
            val () = MLton.Exn.addExnMessager fmt
            
            val none = {
               sendSuffix = fn (_, doit) =>
                  let
                     fun close (conversation, outstream, r, cb) =
                        addOutStream (conversation, outstream, {
                           cost        = 0,
                           complete    = fn ok => (cb ok // ok),
                           operation   = fn cb => 
                              OutStream.shutdown (outstream, cb),
                           reliability = r
                        })
                  in
                     doit close
                  end,
               recvSuffix = fn (finish, conversation, instream, r, parse) =>
                  addInStream (conversation, instream, {
                     cost        = 0,
                     complete    = fn 
                        false => 
                           (log (WARNING, "conversation", fn () => "Unexpected read result for instream with no tail")
                              ; false)
                        | true =>
                           (finish (parse ()) // true),
                     operation   = fn cb => 
                        InStream.readShutdown (instream, cb),
                     reliability = r
                  })
            }
            fun vector {maxLength} = {
               sendSuffix = fn (name, doit) => fn v =>
                  let
                     val len = Word8Vector.length v
                     val () = 
                        if len <= maxLength then () else
                        raise StringTooLong name
                     fun write (conversation, outstream, r, cb) =
                        addOutStream (conversation, outstream, {
                           cost      = len,
                           complete  = fn 
                              false => (cb false // false)
                              | true =>
                                 (close (conversation, outstream, r, cb)
                                    ; true),
                           operation = fn cb =>
                              OutStream.write (outstream, v, cb o ok),
                           reliability = r
                        })
                     and close (conversation, outstream, r, cb) =
                        addOutStream (conversation, outstream, {
                           cost        = 0,
                           complete    = fn ok => (cb ok // ok),
                           operation   = fn cb => 
                              OutStream.shutdown (outstream, cb),
                           reliability = r
                        })
                  in
                     doit write
                  end,
               recvSuffix = fn (finish, conversation, instream, r, parse) =>
                  let
                     val chunks = ref []
                     val have = ref 0
                     
                     fun read () =
                        addInStream (conversation, instream, {
                           cost        = !have,
                           complete    = fn 
                              InStream.SHUTDOWN => 
                                 let
                                    val chunks = List.rev (!chunks)
                                    val v = Vector.concat chunks
                                    val () = finish (parse () v)
                                 in
                                    true
                                 end
                              | InStream.RESET => 
                                 let
                                    val () = log (DEBUG, "conversation", fn () => "Instream tail reset while reading string")
                                 in
                                    false
                                 end
                              | InStream.DATA a =>
                                 let
                                    val v = Word8ArraySlice.vector a
                                    val len = Word8Vector.length v
                                    val () = chunks := v :: !chunks
                                    val () = have := !have + len
                                 in
                                    if !have > maxLength 
                                    then (InStream.reset instream
                                          ; log (WARNING, "conversation", fn () => "Instream tail exceeded string limit")
                                          ; false)
                                    else (read (); true)
                                 end,
                           operation   = fn cb =>
                              InStream.read (instream, maxLength - !have, cb),
                           reliability = r
                        })
                  in
                     read ()
                  end
            }
            fun string args = 
               let
                  val { sendSuffix, recvSuffix } = vector args
               in {
                  sendSuffix = fn (name, doit) => fn s => 
                     sendSuffix (name, doit) (Byte.stringToBytes s),
                  recvSuffix = fn (f, c, i, r, p) =>
                     recvSuffix (f, c, i, r, 
                                 fn () => fn v => 
                                 p () (Byte.bytesToString v))
               } end
            val manual = {
               sendSuffix = fn (_, doit) => fn cb =>
                  let
                     fun pass (_, outstream, _, cb2) =
                        (cb2 true // cb outstream)
                  in
                     doit pass
                  end,
               recvSuffix = fn (finish, _, instream, _, parse) =>
                  finish (parse () instream)
            }
         end
            
      local
         val conversation = ref NONE
      in
         fun getRegistered () =
            case !conversation of
               NONE => raise Fail "Parsing a method with no open conversation"
             | SOME c => c
         
         fun setRegistered (c, f) =
            let
               val () = 
                  if isSome (!conversation)
                  then raise Fail "Setting a conversation while parsing"
                  else ()
               
               val () = conversation := SOME c
               val out = f () handle x => (conversation := NONE; raise x)
               val () = conversation := NONE
            in
               out
            end
         
         fun trySetRegistered (c, f) =
            if isSome (!conversation) then f () else setRegistered (c, f)
      end
      
      (* record to pass method name and statistics to CUSP streams *)
      fun newStreamDescription (name, stats) = {
         localName = name,
         statistics = case stats of
            SOME stats => (fn x => Statistics.add stats (Real32.fromLargeInt x))
          | NONE => (fn _ => ())
      }
         
      (* external description of an entry point or method *)      
      type ('a, 'b, 'c, 'd, 'e, 'f, 'g) description = {
         name     : string,
         datatyp  : 'a,
         ackInfo  : ('f, 'c)     AckInfo.t,
         duration : 'g           Duration.t,
         qos      : ('b, 'f)     QOS.t,
         tailData : ('d, 'g, 'e) TailData.t,
         sendStatistics    : Statistics.t option,
         receiveStatistics : Statistics.t option
      }
      type ('a, 'b, 'c, 'd) internalDesc = {
         name       : string,
         sendPrefix : ((bool -> unit) -> Priority.t * Reliability.t -> 'a) -> 'b,
         sendSuffix : string * ((conversation * OutStream.t * Reliability.t * (bool -> unit) -> unit) -> unit) -> 'c,
         recvSuffix : (unit -> unit) * conversation * InStream.t * Reliability.t * (unit -> 'd) -> unit,
         limitOnce  : unit -> string -> unit,
         outStreamDesc : OutStream.description,
         inStreamDesc : InStream.description
      }

      fun convertDescription { name, datatyp=_, ackInfo, 
         duration={eatReturn,limitOnce}, qos, tailData={sendSuffix,recvSuffix}, 
         sendStatistics, receiveStatistics } : ('a, 'b, 'c, 'd) internalDesc
      = {
         name = name,
         sendPrefix = fn f => ackInfo (fn cb => qos (fn q => f cb q)),
         sendSuffix = sendSuffix,
         recvSuffix = fn (u, c, i, r, p) => recvSuffix (eatReturn u, c, i, r, p),
         limitOnce  = limitOnce,
         outStreamDesc = newStreamDescription (name, sendStatistics),
         inStreamDesc = newStreamDescription (name, receiveStatistics)
      }            
      
      structure Entry =
         struct
            type 'a t = Word16.word
            type ('a, 'b) glue = {
               advertise: 'b * (unit -> unit) -> Host.t * EndPoint.service * InStream.t -> unit,
               associate: conversation * OutStream.t -> 'a,
               name : string
            }
            type ('a, 'b, 'c) ty = 
               ('a t, 'a t, ('b, conversation -> 'c) glue) Serial.t
            
            val newConversation = new
            fun new description =
               case convertDescription description of { name, sendPrefix, 
                  sendSuffix, recvSuffix, limitOnce=_, outStreamDesc, 
                  inStreamDesc } =>
               FoldR.post (Serial.pickle, fn { length, writeVector, parseSlice, ... } =>
               Serial.map {
                  store = fn x => x,
                  load  = fn x => x,
                  extra = fn () => {
                     advertise = fn (f, unhook) => fn (host, _, instream) =>
                        let
                           val a = Word8Array.array (length (), 0w0)
                           val s = Word8ArraySlice.full a
                           val conversation = newConversation host
                           val cb = fn 
                              false =>
                                 (log (DEBUG, "conversation", fn () => "Premature entry end (incomplete headers)")
                                  ; false)
                            | true  =>
                              let
                                 fun parse () =
                                    setRegistered (conversation, fn () =>
                                       parseSlice (s, f conversation))
                                 val () = 
                                    recvSuffix 
                                    (unhook, conversation, instream, 
                                     Reliability.reliable, parse)
                              in
                                 true
                              end
                           val () = InStream.setDescription (instream, inStreamDesc)
                        in
                           addInStream (conversation, instream, {
                              cost        = length (),
                              complete    = cb,
                              operation   = fn cb => 
                                 InStream.readFully (instream, s, cb),
                              reliability = Reliability.reliable
                           })
                        end,
                     associate = fn (conversation, outstream) => 
                        let
                           fun doit cb (p, r) = 
                              writeVector (fn v => sendSuffix (name, fn complete =>
                              let
                                 val () = OutStream.setPriority (outstream, p)
                                 val () = OutStream.setDescription (outstream, outStreamDesc)
                              in
                                 addOutStream (conversation, outstream, {
                                    cost        = length (),
                                    complete    = fn ok => 
                                       if not ok then (cb false // false) else
                                       (complete (conversation, outstream, r, cb)
                                        // ok),
                                    operation   = fn cb => 
                                       OutStream.write (outstream, v, cb o ok),
                                    reliability = r
                                 })
                              end))
                        in
                           sendPrefix doit
                        end,
                     name = name
                  }
               }
               Serial.word16b)

            fun fromWellKnownService x = x
            fun toString x = Word16.toString x
            fun name x = #name (Serial.extra x : ('a, 'b) glue)
         end

      fun advertise (e, { service, entryTy, entry }) =
         let
            val {advertise, associate=_, name=_} = Serial.extra entryTy
            
            val cleared = ref 0w0
            fun unhook () =
               if !cleared = 0w0 then () else
               (EndPoint.unadvertise (e, !cleared)
                ; cleared := 0w0)
            
            val service = EndPoint.advertise (e, service, advertise (entry, unhook))
            val () = cleared := service
         in
            (service, unhook)
         end
      
      fun associate (e, a, { complete, entry, entryTy }) =
         let
            val {advertise=_, associate, name} = Serial.extra entryTy
            val cb = fn
               NONE => complete NONE
             | SOME (host, outstream) =>
               let
                  val c = new host
                  val used = ref false
                  fun doit x =
                     if !used then raise Duration.OneShotUsedTwice name else
                     (used := true; x)
                  val arg = SOME (c, associate (c, outstream) o doit)
                  val () = complete arg
               in
                  if !used then () else OutStream.reset outstream
               end
         in
            EndPoint.contact (e, a, entry, cb)
         end
      
      structure Method =
         struct
            type 'a t = Word16.word
            type 'a glue = {
               response: 'a * (unit -> unit) * conversation -> EndPoint.service * InStream.t -> unit,
               name : string
            }
            type ('a, 'b, 'c) ty = ('a t, 'b, 'c glue) Serial.t
               
            fun new description =
               case convertDescription description of { name, sendPrefix, 
                  sendSuffix, recvSuffix, limitOnce, outStreamDesc, 
                  inStreamDesc } =>
               FoldR.post (Serial.pickle, fn { length, writeVector, parseSlice, ... } =>
               Serial.map {
                  store = fn x => x,
                  load  = fn id => 
                     let
                        val limitOnce = limitOnce ()
                        val conversation = getRegistered ()
                        fun doit cb (p, r) = 
                           writeVector (fn v => sendSuffix (name, fn complete =>
                           let
                              val host = get#host conversation
                              val () = limitOnce name
                              val outstream = Host.connect (host, id)
                              val () = OutStream.setPriority (outstream, p)
                              val () = OutStream.setDescription (outstream, outStreamDesc)
                           in	
                              addOutStream (conversation, outstream, {
                                 cost        = length (),
                                 complete    = fn ok => 
                                    if not ok then (cb false // false) else
                                    (complete (conversation, outstream, r, cb)
                                     // true),
                                 operation   = fn cb => 
                                    OutStream.write (outstream, v, cb o ok),
                                 reliability = r
                              })
                           end))
                     in
                        sendPrefix doit
                     end,
                  extra = fn () => {
                     response = fn (f, unhook, conversation) => fn (_, instream) =>
                        let
                           val a = Word8Array.array (length (), 0w0)
                           val s = Word8ArraySlice.full a
                           val cb = fn 
                              false =>
                                 (log (DEBUG, "conversation", fn () => "Premature response end (incomplete headers)")
                                  ; false)
                            | true  =>
                              let
                                 fun parse () =
                                    setRegistered (conversation, fn () =>
                                       parseSlice (s, f))
                                 val () = (* !!! flexible reliability... *)
                                    recvSuffix 
                                    (unhook, conversation, instream,
                                     Reliability.reliable, parse)
                              in
                                 true
                              end
                           val () = InStream.setDescription (instream, inStreamDesc)
                        in
                           addInStream (conversation, instream, {
                              cost        = length (),
                              complete    = cb,
                              operation   = fn cb => 
                                 InStream.readFully (instream, s, cb),
                              reliability = Reliability.reliable
                           })
                        end,
                     name = name
                  }
               }
               Serial.word16b)
            fun name x = #name (Serial.extra x : 'a glue)
         end
      
      fun response (this, { methodTy, method }) =
         let
            val host = get#host this
            val {response, name=_} = Serial.extra methodTy
            
            val self = Ring.wrap 0w0
            val () = Ring.add (get#listeners this, self)
            fun unhook () =
               if Ring.isSolo self then () else
               (Host.unlisten (host, Ring.unwrap self)
                ; Ring.remove self)
            
            val service = Host.listen (host, response (method, unhook, this))
            val () = Ring.update (self, service)
         in
            (service, unhook)
         end
      
      structure Manual =
         struct
            fun recv (conversation, instream, { buffer, complete, reliability }) =
               addInStream (conversation, instream, {
                  cost        = Word8ArraySlice.length buffer,
                  complete    = fn ok => (trySetRegistered (conversation, 
                                          fn () => complete ok) // ok),
                  operation   = fn cb => InStream.readFully (instream, buffer, cb),
                  reliability = reliability
               })
            
            fun recvShutdown (conversation, instream, { complete }) =
               addInStream (conversation, instream, {
                  cost        = 0,
                  complete    = fn ok => (trySetRegistered (conversation, 
                                          fn () => complete ok) // ok),
                  operation   = fn cb => InStream.readShutdown (instream, cb),
                  reliability = Reliability.reliable
               })
            
            fun send (conversation, outstream, { buffer, complete, reliability }) =
               addOutStream (conversation, outstream, {
                  cost        = Word8Vector.length buffer,
                  complete    = fn ok => (complete ok // ok),
                  operation   = fn cb => OutStream.write (outstream, buffer, cb o ok),
                  reliability = reliability
               })
            
            fun sendShutdown (conversation, outstream, { complete, reliability }) =
               addOutStream (conversation, outstream, {
                  cost        = 0,
                  complete    = fn ok => (complete ok // ok),
                  operation   = fn cb => OutStream.shutdown (outstream, cb),
                  reliability = reliability
               })
         end
   end
