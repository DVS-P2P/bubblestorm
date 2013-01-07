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

structure Main :> MAIN_EXTRA =
   struct
      structure Event = Event()
      
      (* Process any events scheduled within this time window *)
      val immediacy = Time.fromNanoseconds 50
      
      (* Catch the clock up to the time the program is loaded *)
      val () = Event.runTill (Time.realTime ())
      
      datatype rehook = UNHOOK | REHOOK

      structure Signal =
         struct
            type t = Posix.Signal.signal
            val op == : t * t -> bool = op =
            fun hash w = (Hash.word32 o Word32.fromLarge o SysWord.toLarge o Posix.Signal.toWord) w
         end
      structure SigMap = HashTable(Signal)
      val sigmap = SigMap.new ()
      
      fun unhook (signal, r) =
         let
            val out = not (Ring.isSolo r)
            val () = Ring.remove r
            val ring = valOf (SigMap.get (sigmap, signal))
            val () = 
               if not (Ring.isEmpty ring) then () else
               (SigPoll.poll (signal, false)
                ; ignore (SigMap.remove (sigmap, signal)))
         in
            out
         end
      
      fun runHandler signal =
         case SigMap.get (sigmap, signal) of
            NONE => ()
          | SOME r =>
            let
               fun exec r =
                  case Ring.unwrap r () of
                     REHOOK => ()
                   | UNHOOK => ignore (unhook (signal, r))
            in
               Ring.app exec r
            end
      
      fun signal (signal, handler) =
         let
            val ring =
               case SigMap.get (sigmap, signal) of
                  SOME r => r
                | NONE => 
                  let
                     val ring = Ring.new ()
                     val () = SigPoll.poll (signal, true)
                     val () = SigMap.add (sigmap, signal, ring)
                  in
                     ring
                  end
            
            val r = Ring.wrap handler
            val () = Ring.add (ring, r)
         in
            fn () => unhook (signal, r)
         end
      
      val readSockets  = Ring.new ()
      val writeSockets = Ring.new ()
      
      fun registerSocketForRead (sock, cb) =
         let
            val r = Ring.wrap (sock, cb)
            val () = Ring.add (readSockets, r)
         in
            fn () => not (Ring.isSolo r) before Ring.remove r
         end
      
      fun registerSocketForWrite (sock, cb) =
         let
            val r = Ring.wrap (sock, cb)
            val () = Ring.add (writeSockets, r)
         in
            fn () => not (Ring.isSolo r) before Ring.remove r
         end
      
      fun wait timeout =
         if Ring.isEmpty readSockets andalso
            Ring.isEmpty writeSockets andalso
            isSome timeout andalso
            Time.== (valOf timeout, Time.zero)
         (* avoid empty select calls because Windows does not like them *)
         then Iterator.fromList nil
         else
         let
            open Iterator
            
            val smlTime = SMLTime.fromNanoseconds o Time.toNanoseconds
            val timeout = Option.map smlTime timeout

            val snapshot = toList o Ring.iterator
            val readSnapshot = snapshot readSockets
            val writeSnapshot = snapshot writeSockets
            
            val { rds=readReady, wrs=writeReady, exs=_ } =
               Socket.select { rds = List.map (#1 o Ring.unwrap) readSnapshot,
                               wrs = List.map (#1 o Ring.unwrap) writeSnapshot,
                               exs = [],
                               timeout = timeout }
               handle exn as OS.SysErr (_, SOME code) =>
               if code = Posix.Error.intr
               then { rds = [], wrs = [], exs = [] }
               else raise exn
            
            fun notSame (r, h) =
               not (Socket.sameDesc (#1 (Ring.unwrap r), h))
               
            fun pickReady (_, []) = (NONE, [])
              | pickReady (r, ready as head :: tail) =
                  if notSame (r, head) then (NONE, ready) else
                  if Ring.isSolo r then (NONE, tail) else
                  (SOME r, tail)
            
            fun ready (s, x) = mapPartialWith pickReady (fromList s, x)
         in
            ready (readSnapshot,  readReady) @ 
            ready (writeSnapshot, writeReady)
         end
      
      fun process timeout =
         let
            val active = wait timeout
            
            (* Current wall clock time *)
            val now = Time.realTime ()
            
            (* Catch the clock up to real-time so the packets are processed
             * at the time they were received.
             *)
            val () = Event.runTill now
            fun exec r = 
               case #2 (Ring.unwrap r) () of
                  REHOOK => ()
                | UNHOOK => Ring.remove r
            val () = Iterator.app exec active
            
            (* Process the delivered signals *)
            val signals = SigMap.iterator sigmap
            val signals = Iterator.map #1 signals
            val signals = Iterator.filter SigPoll.ready signals
            val signals = Iterator.toList signals
            val () = List.app runHandler signals
            
            (* Run any events that were queued by the processing of packets.
             * eg. sending out replies.
             *)
            val followup = Time.+ (now, immediacy)
            val () = Event.runTill followup
         in
            ()
         end
      
      fun poll () = process (SOME Time.zero)
      
      val stopFlagRef = ref false
      val depthRef = ref 0
      
      fun loop () =
         let
            val now = Time.realTime ()
            val next = Event.nextEvent ()
            val sleepTill = Option.map (fn next => Time.max (next, now)) next
            val sleep = Option.map (fn next => Time.- (next, now)) sleepTill
            val () = process sleep
         in
            if !stopFlagRef
            then stopFlagRef := false
            else loop ()
         end
      
      fun run (_, mainFun) = 
         let
            val () = depthRef := !depthRef + 1
            val () = mainFun ()
            val () = loop ()
            val () = depthRef := !depthRef - 1
         in
            ()
         end
      
      fun isRunning () = !depthRef > 0
      
      fun stop () = 
         if isRunning ()
         then stopFlagRef := true
         else raise Fail "Can not stop without a matching run" 
   end

structure GlobalEvent = Main.Event (* there is no 'global' event in native mode *)
