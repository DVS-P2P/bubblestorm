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

(* Main loop glue code for c-bindings *)

(* Handle buckets *)
val asyncHandlerBucket : (Socket.active INetSock.stream_sock * (unit -> bool)) IdBucket.t = IdBucket.new()

(* Internal helper functions *)

fun socketPair () =
   let
      val listener = INetSock.TCP.socket ()
      val localAddr = NetHostDB.addr (Option.valOf (NetHostDB.getByName "localhost"))
      val () = Socket.bind (listener, INetSock.toAddr (localAddr, 0))
      val () = Socket.listen (listener, 1)
      val addr = Socket.Ctl.getSockName listener
      val client = INetSock.TCP.socket ()
      val () = Socket.connect (client, addr)
      val (server, _) = Socket.accept listener
      val () = Socket.close listener
   in
      (client, server)
   end

(* -------------------- *
 *  Exported functions  *
 * -------------------- *)

(* Main event loop functions *)

fun main () =
   Main.run ("c-app", fn () => ())

(* Main loop with SIGINT handler *)
fun mainSigInt () =
   let
      fun sigIntHandler () = Main.stop ()
      val oldHandler = MLton.Signal.getHandler (Posix.Signal.int)
   in
      MLton.Signal.setHandler (Posix.Signal.int, MLton.Signal.Handler.simple (sigIntHandler))
      ; main ()
      ; MLton.Signal.setHandler (Posix.Signal.int, oldHandler)
   end

fun mainIsRunning () =
   Main.isRunning ()

fun mainStop () =
   Main.stop ()

fun processEvents () =
   Main.poll ()

(* Async handler functions (for multithread application support) *)

fun asyncHandlerCreate (handlerCb : ptr, cbData : ptr) : int =
   let
      val (sockIn, sockOut) = socketPair ()
      fun handler () =
         let
            val _ = Socket.recvVecNB (sockOut, 1)
            val handlerCallbackP = _import * : ptr -> ptr -> unit;
            val () = (handlerCallbackP handlerCb) cbData
         in
            Main.REHOOK
         end
      val unhook = Main.registerSocketForRead (Socket.sockDesc sockOut, handler)
   in
      IdBucket.alloc (asyncHandlerBucket, (sockIn, unhook))
   end

(* HACK: need a ~1 as Socket.sock_desc, conversion is gone since MLton.Socket has been removed *)
(* val () = _export "fakeInvalidSd" private: (unit -> int) -> unit; (fn () => ~1) -> now in libmain.c *)
val invalidSd = _import "fakeInvalidSd" : unit -> Socket.sock_desc;

fun asyncHandlerGetSocket (aHandle : int) : Socket.sock_desc =
   case IdBucket.sub (asyncHandlerBucket, aHandle) of
      SOME (sock, _) => Socket.sockDesc sock
    | NONE => invalidSd ()

fun asyncHandlerDelete (aHandle : int) : bool =
   case IdBucket.sub (asyncHandlerBucket, aHandle) of
      SOME (_, unhook) => unhook ()
    | NONE => false

val (asyncHandlerDup, asyncHandlerFree) = bucketOps asyncHandlerBucket


(* --------- *
 *  Exports  *
 * --------- *)

(* Main loop functions *)
val () = _export "evt_main" : (unit -> unit) -> unit; main
val () = _export "evt_main_sigint" : (unit -> unit) -> unit; mainSigInt
val () = _export "evt_main_running" : (unit -> bool) -> unit; mainIsRunning
val () = _export "evt_stop_main" : (unit -> unit) -> unit; mainStop
val () = _export "evt_process_events" : (unit -> unit) -> unit; processEvents

(* Async handler functions *)
val () = _export "evt_asynchandler_create" : (ptr * ptr -> int) -> unit; asyncHandlerCreate
val () = _export "evt_asynchandler_get_socket" : (int -> Socket.sock_desc) -> unit; asyncHandlerGetSocket
val () = _export "evt_asynchandler_delete" : (int -> bool) -> unit; asyncHandlerDelete
val () = _export "evt_asynchandler_dup" : (int -> int) -> unit; asyncHandlerDup
val () = _export "evt_asynchandler_free" : (int -> bool) -> unit; asyncHandlerFree
