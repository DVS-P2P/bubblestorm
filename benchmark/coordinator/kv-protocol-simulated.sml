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

structure KVProtocol : KV_PROTOCOL =
   struct
      val module = "kv/protocol"

      fun fail _ = raise At (module, Fail "coordinator not available")
      
      val registerFn = ref fail
      val coordinator = ref fail
      
      fun create { endpoint=_, register, keepAlive=_ } =
         let
            fun doRegister node =
               let
                  val () = Log.log (Log.DEBUG, module ^ "/coordinator", fn () => "register")
                  val quit = register node
               in
                  (* safe, because only passive data structures are modified *)
                  fn notify => ( quit () : unit ; notify () )
               end
            val coordinatorHandle = NodeTrigger.get ()
            val () = coordinator := (fn () => coordinatorHandle)
            val () = Log.log (Log.DEBUG, module ^ "/coordinator", fn () => "created")
         in
            registerFn := doRegister
         end

      fun mapClient ({ nodeID, insert, update, delete, find }, client) =
         let
            fun atClient x = NodeTrigger.exec (client, x)
            fun atCoordinator x = NodeTrigger.exec ((!coordinator) (), x)
         in
            {
               nodeID = nodeID,
               insert = fn (item, cb) => atClient (fn () => insert (item, fn () => atCoordinator cb)),
               update = fn (item, cb) => atClient (fn () => update (item, fn () => atCoordinator cb)),
               delete = fn (id, cb) => atClient (fn () => delete (id, fn () => atCoordinator cb)),
               find = fn (item, step) => atClient (fn () => find (item, step))
            }
         end
      
      fun register { coordinator=_, interface, keepAlive=_ } =
         let
            val interface' = mapClient (interface, NodeTrigger.get ())
            val quitCoordinator = (!registerFn) interface'
            val cancelSigHandler = ref (fn () => false)
            fun quit notify =
               let
                  val () = ignore ((!cancelSigHandler) ())
               in
                  quitCoordinator notify
               end
            fun onSigKill () = ( quit (fn () => ()) ; Main.UNHOOK )
            val () = cancelSigHandler := Main.signal (Posix.Signal.kill, onSigKill)
         in
            quit
         end
   end
