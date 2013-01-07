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

fun doEvaluateN
   (HANDLERS { bootstrap, ... })
   (ACTIONS { pushFish, ... })
   (STATE { locations, clients, endpoint, gossip, hooks, onJoin, ... })
   () =
   let
      fun method () = "topology/action/evaluateN"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called")
      
      val gossip = case !gossip of
         GOSSIP x => x
       | MEASUREMENTS _ => raise At (method (), Fail "topology not initialized")
       
      val l = locations
      open Locations
      
      fun joinComplete () =
         let
            (* execute join handlers *)
            val () = Ring.app (fn x => (Ring.unwrap x) ()) onJoin
            
            fun makeBootstrap () =
               #2 (Conversation.advertise (endpoint, {
                     service = SOME Config.BOOTSTRAP_SERVICE,
                     entryTy = bootstrapTy,
                     entry   = bootstrap
                  }))
         in
            setGoal (l, JOIN (COMPLETE (makeBootstrap ())))
         end
         
      fun leaveComplete () =
         let
            val () = pushFish ()
            val () = Vector.app Gossip.deinit gossip
            val () = Vector.app Main.Event.cancel (!hooks)
            val () = hooks := Vector.tabulate (0, fn _ => raise Domain)
         in
            setGoal (l, LEAVE (COMPLETE (fn () => ())))
         end

      val (minDegree, maxDegree) = state l 
   in
      case (maxDegree, minDegree, goal l, Clients.empty clients) of
         (_, ENOUGH, LEAVE _, _) => 
            raise At (method (), Fail "cannot be ENOUGH if leaving")
       | (_, TOO_MUCH, LEAVE _, _) => 
            raise At (method (), Fail "cannot be TOO_MUCH if leaving")
       | (ZERO, LOW, LEAVE (IN_PROGRESS _), true) =>
            leaveComplete ()
       | (ZERO, LOW, LEAVE (IN_PROGRESS _), false) =>
            () (* waiting for clients to leave *)
       | (ZERO, LOW, LEAVE (COMPLETE _), _) =>
            () (* we're not online *)
       | (ZERO, LOW, JOIN _, _) =>
            raise At (method (), Fail "no active locations in join state")
       | (ZERO, _, _, _) =>
            raise At (method (), Fail "min degree bigger than max degree (ZERO)")
            
       | (NEED_MORE, TOO_MUCH, _, _) => 
            raise At (method (), Fail "min degree bigger than max degree (NEED_MORE)")
       | (NEED_MORE, LOW, JOIN (IN_PROGRESS _), _) =>
            () (* waiting for more neighbours to become a peer *)
       | (NEED_MORE, ENOUGH, JOIN (IN_PROGRESS _), _) =>
            joinComplete ()
       | (NEED_MORE, _, JOIN (COMPLETE _), _) =>
            increaseDegree l
       | (NEED_MORE, _, LEAVE _, _) =>
            () (* no need for more links, we're leaving *)
            
       | (SATISFIED, LOW, _, _) =>
            () (* we will recover or leave (respectively) sooner or later *)
       | (SATISFIED, ENOUGH, JOIN (IN_PROGRESS _), _) =>
            joinComplete ()
       | (SATISFIED, ENOUGH, _, _) =>
            () (* we're in the ideal range (yeah!) *)
       | (SATISFIED, TOO_MUCH, _, _) =>
            decreaseDegree l
   end
