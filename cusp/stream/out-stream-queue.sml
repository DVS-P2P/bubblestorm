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

structure OutStreamQueue :> OUT_STREAM_QUEUE =
   struct
      datatype status = RESET | READY
      
      structure Key =
         struct
            type t = Word32.word
   
            local
               open Word32
               val b31 = << (0w1, 0w31)
            in
               val op == : t * t -> bool = op =
               fun a < b = (a-b) >= b31
            end
         end
      structure Key = OrderFromLessEqual(Key)
      structure Heap = ManagedHeap(Key)
      
      (* Invariants:
       *   buffer holds data which is past the sendOffset
       *   the offsets in inflight&retransmit are all <= barrier
       *   WARNING: sendOffset might wrap past the barrier (a large write)
       *   inflightBytes = sum of lengths in inflight
       *   retransmitBytes = sum of lengths in retransmit
       *)
       
      datatype event = 
         RTS of Real32.real
       | BECAME_RESET
       | BECAME_COMPLETE
       | INFLIGHT_BYTES of int
       | RETRANSMIT_BYTES of int
      
      datatype progress = RETRANSMIT | INFLIGHT | ACKD

      datatype state = AM_CONNECTED | AM_RESET | AM_SHUTDOWN of progress

      type description = {
         localName : string,
         statistics : LargeInt.int -> unit
      }

      datatype fields = T of {
         description     : description,
         callback        : event -> unit,
         state           : state,
         priority        : Real32.real,
         inflight        : Word8VectorSlice.slice Heap.t,
         inflightBytes   : int,
         retransmit      : Word8VectorSlice.slice Heap.t,
         retransmitBytes : int,
         bytesSent       : Counter.int,
         sendOffset      : Word32.word,
         barrier         : Word32.word,
         buffer          : Word8VectorSlice.slice option,
         writer          : status -> unit,
         shutdowner      : bool -> unit,
         id              : Word16.word
      } withtype t' = fields ref
      
      type t = t'
      
      type priority = Real32.real
      
      val minimumWindow = 0w21568 (* (1380-32)*16 --> ie: every 8th packet *)
      
      open FunctionalRecordUpdate
      fun get f (ref (T fields)) = f fields
      fun update (this as ref (T fields)) =
         let
            fun from
               v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v13 v14 v15 v16 =
               {callback=v1,state=v2,priority=v3,inflight=v4,inflightBytes=v5,
                retransmit=v6,retransmitBytes=v7,bytesSent=v8,sendOffset=v9,
                buffer=v10,writer=v11,shutdowner=v13,barrier=v14,id=v15,description=v16}
            fun to f
              {callback=v1,state=v2,priority=v3,inflight=v4,inflightBytes=v5,
                retransmit=v6,retransmitBytes=v7,bytesSent=v8,sendOffset=v9,
                buffer=v10,writer=v11,shutdowner=v13,barrier=v14,id=v15,description=v16} =
              f v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v13 v14 v15 v16
         in
            Fold.post (makeUpdate15 (from, from, to) fields,
                       fn z => this := T z)
         end
      
      val queuedInflight     = get#inflightBytes
      val queuedToRetransmit = get#retransmitBytes
      val bytesSent          = Counter.toLarge o get#bytesSent
      val getPriority        = get#priority
      
      (* We are RTS if should indicate shutdown, reset, or send something *)
      fun amRTS this =
         case get#state this of
            AM_RESET => true
          | AM_SHUTDOWN RETRANSMIT => true
          | _ => 
            case Heap.peek (get#retransmit this) of
               NONE => false
             | SOME r => (* prevent silly window *)
                 Key.< (#2 (Heap.sub r), get#barrier this - 0w2048)
      
      fun updateRTS this =
         (get#callback this o RTS) 
         (if amRTS this then get#priority this else Real32.negInf)
      
      fun setPriority (this, prio) =
         if Real32.isFinite prio
            then
               (update this set#priority prio $
                ; updateRTS this)
            else
               raise Domain
      
      datatype state = IS_ACTIVE | IS_SHUTDOWN | IS_RESET
      fun state this =
         case get#state this of
            AM_RESET => IS_RESET
          | AM_SHUTDOWN ACKD => IS_SHUTDOWN
          | _ => IS_ACTIVE
      
      (* Make progress towards sending data.
       * Move data from buffer into the retransmit queue (if it's empty).
       *)
      fun makeProgress this =
         if not (Heap.isEmpty (get#retransmit this)) then updateRTS this else
         case get#buffer this of NONE => () | SOME buffer =>
         let
            val len = Word8VectorSlice.length buffer
            
            (* Now move the buffer into the retransmit heap *)
            val item = Heap.wrap (get#sendOffset this, buffer)
            val () = Heap.push (get#retransmit this, item)
            val () = (get#callback this) (RETRANSMIT_BYTES len)
            val writer = get#writer this
            val () =
               update this
                  set#buffer          NONE
                  set#writer          (fn _ => ())
                  upd#retransmitBytes (fn x => x + len)
                  upd#sendOffset      (fn x => x + Word32.fromInt len) $
            val () = updateRTS this
         in
            writer READY
         end
      
      fun write (this, buffer, writer) =
         if isSome (get#buffer this) then raise RaceCondition else
         case get#state this of
            AM_SHUTDOWN _ => raise RaceCondition
          | AM_RESET => writer RESET
          | _ =>
            (update this
                set#buffer (SOME (Word8VectorSlice.full buffer))
                set#writer writer $
             ; makeProgress this)
      
      fun shutdown (this, cb) =
         if isSome (get#buffer this) then raise RaceCondition else
         case get#state this of
            AM_SHUTDOWN _ => raise RaceCondition
          | AM_RESET => cb false
          | _ =>
            (update this
                set#state (AM_SHUTDOWN RETRANSMIT)
                set#shutdowner cb $
             ; updateRTS this)
      
      fun doReset this = 
         let
            val () = (get#callback this) (RETRANSMIT_BYTES (~ (get#retransmitBytes this)))
            val shutdowner = get#shutdowner this
            val writer = get#writer this
            val () =
               update this
                  set#state           AM_RESET
                  set#retransmit      (Heap.new ())
                  set#retransmitBytes 0
                  set#writer          (fn _ => ())
                  set#shutdowner      (fn _ => ())
                  set#buffer          NONE $
            val () = (get#callback this) BECAME_RESET
            val () = shutdowner false
            val () = writer RESET
         in
            ()
         end
      
      fun reset this = (doReset this; updateRTS this)
      
      fun amDone this =
         (get#state this = AM_SHUTDOWN ACKD) andalso
         Heap.isEmpty (get#inflight this) andalso
         Heap.isEmpty (get#retransmit this)
         
      fun checkDone this =
         if not (amDone this) then () else
         let
            val shutdowner = get#shutdowner this
            val () = (get#callback this) BECAME_COMPLETE
            val () = update this set#shutdowner (fn _ => ()) $
         in
            shutdowner true
         end
         
      (* Pull segments needing retransmission into the buffer *)
      fun pullContiguousSegments (this, data, offset) =
         case Heap.popBounded (get#retransmit this, offset) of
            NONE => []
          | SOME segment =>
               let
                  val segmentSlice = #3 (Heap.sub segment)
                  
                  val segmentLen = Word8VectorSlice.length segmentSlice
                  val dataLen = Word8ArraySlice.length data
                  val len = Int.min (segmentLen, dataLen)
                  
                  val segmentHead = Word8VectorSlice.subslice (segmentSlice, 0, SOME len)
                  val () = Copy.word8v (data, segmentHead)
                  
                  val newOffset = offset + Word32.fromInt len
                  val dataTail = Word8ArraySlice.subslice (data, len, NONE)
                  val segmentTail = Word8VectorSlice.subslice (segmentSlice, len, NONE)
               in
                  if segmentLen = len
                  then (* We consumed the entire segment *)
                     (makeProgress this
                      ; segment :: 
                        (if dataLen = len then [] else
                         pullContiguousSegments (this, dataTail, newOffset)))
                  else (* We filled the entire data buffer *)
                     (Heap.push (get#retransmit this,
                                 Heap.wrap (newOffset, segmentTail))
                      ; [Heap.wrap (offset, segmentHead)])
               end
      
      (* Pull segments needing retransmission *)
      fun pullSegments (this, data) =
         case Heap.peek (get#retransmit this) of
            NONE => []
          | SOME segment =>
               pullContiguousSegments (this, data, #2 (Heap.sub segment))
      
      local
         open PacketFormat
         val { parseSlice, writeSlice, ... } = Serial.methods Serial.word32b
         val parser = fn d => 
            parseSlice (Word8ArraySlice.subslice (d, 4, SOME 4))
         val writer = fn (d, x) =>
            writeSlice (Word8ArraySlice.subslice (d, 4, SOME 4), x)
      in
      fun pull (this, id, data) =
         if get#state this = AM_RESET then
            let
               fun ackd true = (get#callback this) BECAME_COMPLETE (* remove us from table *)
                 | ackd false = (get#callback this) (RTS Real32.posInf)
               val () = (get#callback this) (RTS Real32.negInf)
               val msg = READER (READER_CTL WRITER_RESETS, { id = id })
            in
               (msg, 4, ackd)
            end
         else
            let
               val offset =
                  case Heap.peek (get#retransmit this) of
                     NONE => get#sendOffset this (* shutdown *)
                   | SOME segment => #2 (Heap.sub segment)
               
               val headerLen = 
                  if offset = 0w0 then 4 else
                  (writer (data, offset); 8)
               
               (* Don't pull more than 4k-4 bytes at once.
                * The length header only supports this much.
                *)
               val len = Int.min (Word8ArraySlice.length data - headerLen, 4092)
               val subdata = Word8ArraySlice.subslice (data, headerLen, SOME len)
               val segments = pullSegments (this, subdata)
               
               val () = app (fn x => Heap.push (get#inflight this, x)) segments
               
               val lenOfSegment = Word8VectorSlice.length o #3 o Heap.sub
               val len = foldl (fn (x, a) => lenOfSegment x + a) 0 segments
               val alignedLen = align len
               
               (* Zero the tail for privacy (buffer is reused) *)
               val () = 
                  Word8ArraySlice.modify (fn _ => 0w0)
                  (Word8ArraySlice.subslice 
                   (subdata, len, SOME (alignedLen-len)))
               
               val (attachEOF, state) = 
                  case (get#state this) of
                     AM_SHUTDOWN ACKD => (false, AM_SHUTDOWN ACKD)
                   | AM_SHUTDOWN a =>
                        if offset + Word32.fromInt len <> get#sendOffset this
                        then (false, AM_SHUTDOWN a) 
                        else (true,  AM_SHUTDOWN INFLIGHT)
                   | x => (false, x)
               
               val () =
                  update this
                     set#state           state
                     upd#inflightBytes   (fn x => x + len)
                     upd#retransmitBytes (fn x => x - len) $
               
               val () = updateRTS this
               
               val () = (get#callback this) (INFLIGHT_BYTES len)
               val () = (get#callback this) (RETRANSMIT_BYTES (~len))
               
               fun ack this ok =
                  let
                     fun deflight x = Heap.remove (get#inflight this, x)
                     fun requeue x = Heap.push (get#retransmit this, x)
                     val len = foldl (fn (x, a) => lenOfSegment x + a) 0 segments
                     
                     val () = List.app deflight segments
                     val () = (get#callback this) (INFLIGHT_BYTES (~len))
                     
                     val state =
                        case (attachEOF, get#state this) of
                           (_, AM_SHUTDOWN ACKD) => AM_SHUTDOWN ACKD
                         | (true, AM_SHUTDOWN _) =>
                              AM_SHUTDOWN (if ok then ACKD else RETRANSMIT)
                         | (_, state) => state
                     
                     val shouldRequeue = not ok andalso state <> AM_RESET
                     val requeueLen  = if shouldRequeue then len else 0
                     val progressLen = if ok then len else 0
                     
                     val () =
                        update this
                           set#state           state
                           upd#bytesSent       (fn x => x + Counter.fromInt progressLen)
                           upd#inflightBytes   (fn x => x - len)
                           upd#retransmitBytes (fn x => x + requeueLen) $
                  in
                     if not shouldRequeue
                     then (makeProgress this; checkDone this)
                     else 
                        (List.app requeue segments
                         ; (get#callback this) (RETRANSMIT_BYTES len)
                         ; updateRTS this)
                  end
                  
               val msg = READER (DATA { eof = attachEOF,
                                        offset = offset <> 0w0,
                                        length = len },
                                 { id = id })
            in
               (msg, headerLen + alignedLen, ack this)
            end
      
      fun recv (this, data, WRITER_CTL msg) =
         case msg of
            READER_BARRIER =>
               (update this set#barrier (parser data) $
                ; makeProgress this
                ; 8)
          | READER_RESETS =>
               (doReset this
                ; (get#callback this) BECAME_COMPLETE
                ; 4)
      end
      
      fun isReset this = get#state this = AM_RESET
      
      fun updateSendStatistics this =
         (#statistics (get#description this)) (bytesSent this)
         
      fun setID (this, id) = update this set#id id $
      fun globalID this = get#id this
      
(*      fun localName this = case get#description this of { name, statistics=_ } => name *)
      fun localName this = #localName (get#description this)
      fun setDescription (this, desc) = update this set#description desc $
      
      val defaultDescription = { localName = "", statistics = fn _ => () }

      fun new cb =
         ref (T { description     = defaultDescription,
                  callback        = cb,
                  state           = AM_CONNECTED,
                  priority        = 0.0,
                  inflight        = Heap.new (),
                  inflightBytes   = 0,
                  retransmit      = Heap.new (),
                  retransmitBytes = 0,
                  bytesSent       = 0,
                  sendOffset      = 0w0,
                  barrier         = minimumWindow,
                  buffer          = NONE,
                  writer          = fn _ => (),
                  shutdowner      = fn _ => (),
                  id              = 0wxffff })
   end
