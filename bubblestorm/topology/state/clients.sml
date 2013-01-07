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

structure Clients :> CLIENTS =
   struct
      val module = "topology/clients"
      
      type leaving = {
         doAbort    : Main.Event.t,
         neighbours : Word64.word -> Neighbour.t Iterator.t
      }
      
      datatype t = T of {
         clients  : (Neighbour.t * makeClient option ref) Ring.t,
         slackers : {slacker : Neighbour.t, kick : Main.Event.t} Ring.t,
         abort    : (unit -> unit) Ring.t,
         leaving  : leaving option ref,
         evaluate : unit -> unit
      }
      
      fun iterator (T { clients, ... }) =
         let
            val elts = Iterator.toList (Ring.iterator clients)
            val it = Iterator.fromList elts
            val it = Iterator.delay it
            fun trim r =
               if Ring.isSolo r then NONE else SOME (#1 (Ring.unwrap r))
         in
            Iterator.mapPartial trim it
         end
      
      fun empty (T { clients, slackers, abort, ... }) =
         Ring.isEmpty clients andalso 
         Ring.isEmpty slackers andalso
         Ring.isEmpty abort
      
      fun pushClient ((client, makeClient), neighbours) =
         case Iterator.getItem neighbours of
            NONE => raise At (module, Fail "impossible EOF")
          | SOME (neighbour, neighbours) =>
         let
            fun kill _ = Neighbour.reset client
            val kill = Main.Event.new kill
            fun cancel () = Main.Event.cancel kill
            val () = Neighbour.addDeathHandler (client, cancel)
            val () = Main.Event.scheduleIn (kill, Config.leaveWait ())
            
            (* pass it over to a neighbour *)
            val { findServer, ... } = Neighbour.methods neighbour
            val () =
               case Neighbour.address client of
                  NONE => Neighbour.reset client
                | SOME addr => findServer addr makeClient 0
         in
            neighbours
         end
      
      fun pushClients (T { leaving, ... }, clients) =
         case !leaving of NONE => () | SOME { neighbours, ... } =>
         let
            val seed = Random.word64 (getTopLevelRandom (), NONE)
            val neighbours = neighbours seed
            val endlessNeighbours = Iterator.loop neighbours
         in
            if Iterator.null neighbours
            then Iterator.app (Neighbour.reset o #1) clients
            else ignore (Iterator.fold pushClient endlessNeighbours clients)
         end
      
      fun addClient (this as T { clients, evaluate, ... }, client, makeClient) =
         let
            fun method () = module ^ "/addDuplex"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
            
            val needEval = empty this
            val r = Ring.wrap (client, ref (SOME makeClient))

            fun unhook () =
               let
                  fun method () = module ^ "/unhookClient"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
                  val () = Neighbour.setName (client, "unhooked client")
                  val () = Ring.remove r
               in
                  if empty this then evaluate () else ()
               end
            
            fun teardown () = 
               let
                  fun method () = module ^ "/teardownClient"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
                  val () = Neighbour.setName (client, "torn-down client")
               in
                  Neighbour.completeTeardown client
               end
            
            val () = Neighbour.setUnhook (client, unhook)
            val () = Neighbour.setTeardownHandler (client, teardown)
            val () = Neighbour.setName (client, "client")
            val () = Ring.add (clients, r)
            
            val () = 
               pushClients (this, Iterator.fromElement (client, makeClient))
         in
            if needEval then evaluate () else ()
         end
      
      fun addSlackerRO (this as T { slackers, evaluate, leaving, ... }, client) =
         let
            fun method () = module ^ "/addSlackerRO"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
            
            val needEval = empty this
            
            fun kick _ = Neighbour.reset client
            val kick = Main.Event.new kick
            val wait = if isSome (!leaving) then Config.slackerKickWait else Config.slackerNiceWait
            val () = Main.Event.scheduleIn (kick, wait ())
            val r = Ring.wrap { slacker = client, kick = kick }
            
            fun destroy () =
                let
                  fun method () = module ^ "/destroySlacker"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
                  val () = Neighbour.setName (client, "destroyed RO slacker")
                  val () = Ring.remove r
                  val () = Main.Event.cancel kick
               in
                  if empty this then evaluate () else ()
               end
            
            val () = Neighbour.addDeathHandler (client, destroy)
            val () = Neighbour.setName (client, "RO slacker")
            val () = Ring.add (slackers, r)
         in
            if needEval then evaluate () else ()
         end
      
      fun addSlackerRW (this as T { slackers, evaluate, leaving, ... }, client) =
         let
            fun method () = module ^ "/addSlackerRW"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
            
            val needEval = empty this
            
            fun kick _ = 
               let
                  val () = Neighbour.initiateTeardown client
               in
                  addSlackerRO (this, client)
               end
            val kick = Main.Event.new kick
            val wait = if isSome (!leaving) then Config.slackerKickWait else Config.slackerNiceWait
            val () = Main.Event.scheduleIn (kick, wait ())
            val r = Ring.wrap { slacker = client, kick = kick }

            fun unhook () =
               let
                  fun method () = module ^ "/unhookSlacker"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
                  val () = Neighbour.setName (client, "unhooked RW slacker")
                  val () = Ring.remove r
                  val () = Main.Event.cancel kick
               in
                  if empty this then evaluate () else ()
               end
            
            fun teardown () = 
               let
                  fun method () = module ^ "/teardownSlacker"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " ^ Neighbour.toString client)
                  val () = Neighbour.setName (client, "torn-down RW slacker")
               in
                  Neighbour.completeTeardown client
               end
            
            val () = Neighbour.setUnhook (client, unhook)
            val () = Neighbour.setTeardownHandler (client, teardown)
            val () = Neighbour.setName (client, "RW slacker")
            val () = Ring.add (slackers, r)
         in
            if needEval then evaluate () else ()
         end
      
      fun addAbort (this as T { abort, evaluate, ... }, f) =
         let
            val needEval = empty this
            val r = Ring.wrap f
            val () = Ring.add (abort, r)
            val () = if needEval then evaluate () else ()
         in
            fn () => Ring.remove r
         end
      
      fun allowClients (T { leaving, ... }) =
         case !leaving of 
            NONE => () 
          | SOME { doAbort, ... } => (Main.Event.cancel doAbort; leaving := NONE)
      
      (* Reduce the time limit for slackers to leave *)
      fun kickSlackersSoon (T { slackers, ... }) =
         let
            val l = Iterator.toList (Ring.iterator slackers)
            fun map r =
               if Ring.isSolo r then () else
               let
                  val { slacker=_, kick } = Ring.unwrap r
                  val remaining = valOf (Main.Event.timeTillExecution kick)
                  val remaining = Time.min (remaining, Config.slackerKickWait ())
               in
                  Main.Event.scheduleIn (kick, remaining)
               end
         in
            Iterator.app map (Iterator.fromList l)
         end

      (* Stop any wanna-be clients from actually becoming clients *)
      fun abortAll (this as T { abort, evaluate, ... }) = 
         let
            fun run r = (ignore (Ring.unwrap r ()); Ring.remove r)
            val () = Iterator.app run (Ring.iterator abort)
         in
            if empty this then evaluate () else ()
         end
      
      (* The clients who need to be booted *)
      fun clientsWhoNeedAPush (T { clients, ... }) =
         let
            val l = Iterator.toList (Ring.iterator clients)
            fun map r =
               if Ring.isSolo r then NONE else
               let
                  val (n, r) = Ring.unwrap r
                  val old = !r
                  val () = r := NONE
               in
                  Option.map (fn x => (n, x)) old
               end
         in
            Iterator.mapPartial map (Iterator.fromList l)
         end
      
      fun flushClients (this as T { leaving, ... }, neighbours) =
         case !leaving of SOME _ => () | NONE =>
         let
            val doAbort = Main.Event.new (fn _ => abortAll this)
            val () = leaving := SOME { doAbort = doAbort, neighbours = neighbours }
            val () = kickSlackersSoon this
            val () = pushClients (this, clientsWhoNeedAPush this)
         in
            Main.Event.scheduleIn (doAbort, Config.slackerKickWait ())
         end

      fun new evaluate = T {
         clients  = Ring.new (),
         slackers = Ring.new (),
         abort    = Ring.new (),
         leaving  = ref NONE,
         evaluate = evaluate
      }
   end
