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

structure SimulatorNode :> SIMULATOR_NODE =
   struct
      val module = "simulator/simulator-node"
      
      datatype rehook = UNHOOK | REHOOK

      datatype t = LOCAL of {
         id : int,
         definition : NodeDefinition.t,
         staticAddress : Address.Ip.t option,
         currentAddress : Address.Ip.t option ref,
         location : Location.t,
         random : Random.t,
         printBuffer : string list ref,
         cleanupFunctions : (unit -> unit) Ring.t,
         sigInt : (unit -> rehook) Ring.t,
         sigKill : (unit -> rehook) Ring.t,
         sigUsr1 : (unit -> rehook) Ring.t,
         sigUsr2 : (unit -> rehook) Ring.t,
         isActive : bool ref,
         isOnline : bool ref,
         isRunning : bool ref,
         msgHandler : Routing.msgHandler ref,
         leaveTimeout : Experiment.Event.t option ref,
         addressTimeout : Experiment.Event.t option ref
         }
     | REMOTE of {
         id : int,
         definition : NodeDefinition.t,
         staticAddress : Address.Ip.t option,
         currentAddress : Address.Ip.t option ref,
         location : Location.t,
         isActive : bool ref,
         isOnline : bool ref,
         addressTimeout : Experiment.Event.t option ref,
         runningOnLP : int
      }
      exception OutsideNodeContext
      exception RecursiveNodeContext
      
      fun raiseException (name) = 
         raise At ("simulatort-node/ " ^ name, 
            Fail ("The function is not available for REMOTE nodes"))

      local
         fun messager OutsideNodeContext = 
            SOME "Asking for current node from outside of SimulatorNode.setCurrent."
           | messager RecursiveNodeContext = 
           SOME "SimulatorNode.setCurrent called inside of setCurrent."
           | messager _ = NONE
      in
         val () = MLton.Exn.addExnMessager messager
      end

      local
         val currentNode = ref NONE
      in
         fun current () =
            case !currentNode of
               NONE => raise At (module ^ "/current", OutsideNodeContext)
             | SOME c => c

          fun localCurrent () = 
            case current () of 
               LOCAL x => (LOCAL x, x)
               | REMOTE _ => raiseException "localCurrent"

         (* sets the current node before event execution and sets it to NONE
            after execution. Is applied to every event being scheduled. *)
         fun setContext (REMOTE _, _) = raiseException "setCurrent"
           | setContext (node as LOCAL _, f) =
            let
               val () = if isSome (!currentNode) 
                  then raise At (module ^ "/set-current", RecursiveNodeContext)
                  else ()
               val () = currentNode := SOME node
               val out = f ()
               val () = currentNode := NONE
            in
               out
            end
      end

      fun id               (LOCAL fields)  = #id fields
        | id               (REMOTE fields) = #id fields
      fun definition       (LOCAL fields)  = #definition fields
        | definition       (REMOTE fields) = #definition fields       
      fun staticAddress    (LOCAL fields)  = #staticAddress fields
        | staticAddress    (REMOTE fields) = #staticAddress fields 
      fun currentAddress   (LOCAL fields)  = ! (#currentAddress fields)
        | currentAddress   (REMOTE fields) = ! (#currentAddress fields)
      fun location         (LOCAL fields)  = #location fields
        | location         (REMOTE fields) = #location fields
      fun random           (LOCAL fields)  = #random fields
        | random           (REMOTE _)      = raiseException "random"
      fun printBuffer      (LOCAL fields)  = #printBuffer fields
        | printBuffer      (REMOTE _)      = raiseException "printBuffer"
      fun cleanupFunctions (LOCAL fields)  = #cleanupFunctions fields
        | cleanupFunctions (REMOTE _)      = raiseException "cleanupFunctions"
      fun isActive         (LOCAL fields)  = ! (#isActive fields)
        | isActive         (REMOTE fields) = ! (#isActive fields)
      fun isOnline         (LOCAL fields)  = ! (#isOnline fields)
        | isOnline         (REMOTE fields) = ! (#isOnline fields)
      fun isRunning        (LOCAL fields)  = ! (#isRunning fields)
        | isRunning        (REMOTE _)      = raiseException "isRunning"
      fun name             (LOCAL fields)  = NodeDefinition.name (#definition fields)
        | name             (REMOTE fields) = NodeDefinition.name (#definition fields)
      fun isLocal          (LOCAL _)  = true
        | isLocal          (REMOTE _) = false
                                                               
      fun toString t =  "\"" ^ name t ^ "\" #" ^ Int.toString (id t)
      
      fun cmdLine () =
         let
            val node = current ()
            val addr = case currentAddress node of
               SOME x => x
             | NONE => raise At (module, Fail ("Current running node " ^ 
                                 toString node ^ " has no address"))
            val port = 0w8585
            val def  = definition node
            val cmd  = NodeDefinition.cmdLine def
         in
            Arguments.toString (addr, port, cmd)
         end
      
      fun equals (x, y) = (id x = id y)
      
      local
         val activeNodes = ref 0
         val onlineNodes = ref 0
         val runningNodes = ref 0

         fun changeState (nodeState, counter, value) =
            let
               val change = 
                  if !nodeState = value
                     then 0 
                  else case value of
                          true => 1
                        | false => ~1
               val () = counter := !counter + change
            in
               nodeState := value
            end
   
      in
         fun setActive value (LOCAL fields)  = changeState (#isActive fields, activeNodes, value)
           | setActive value (REMOTE fields) = changeState (#isActive fields, activeNodes, value)
         fun setOnline value (LOCAL fields)  = changeState (#isOnline fields, onlineNodes, value)
           | setOnline value (REMOTE fields) = changeState (#isOnline fields, onlineNodes, value)
                     
         fun setRunning value (LOCAL fields) = changeState (#isRunning fields, runningNodes, value)
           | setRunning _ (REMOTE _) = raiseException "setRunning"

         val activeNodes = fn () => !activeNodes
         val onlineNodes = fn () => !onlineNodes
         val runningNodes = fn () => !runningNodes
      end
      
      fun setCurrentAddressInner (this, currentAddress, address) =
         case (!currentAddress, address) of
            (SOME _, SOME _) => raise At (module ^ "/set-current-address",
               Fail ("Cannot replace existing IP address at node " ^ 
                     toString this ^ ", release old address first."))
          | (NONE, NONE) => raise At (module ^ "/set-current-address",
               Fail ("Cannot release non-existing IP address as node "^
                     toString this ^ ", assign an address first."))
          | _ => currentAddress := address

      fun setCurrentAddress (this as REMOTE fields, address) =
         setCurrentAddressInner (this, #currentAddress fields, address)
        | setCurrentAddress (this as LOCAL fields, address) =
         setCurrentAddressInner (this, #currentAddress fields, address)

      fun setMessageHandler handler =
         let
            val (current, fields) = localCurrent ()
            val () = if isRunning current then () 
               else raise At (module ^ "/set-message-handler",
                  Fail ("Tried to bind offline node " ^ toString current ))
            val msgHandler = #msgHandler fields
         in
            msgHandler := handler
         end
         
      fun removeMessageHandler () =
         let
            val (_, fields) = localCurrent ()
            val msgHandler = #msgHandler fields
         in
            msgHandler := (fn _ => raise Routing.PortUnreachable)
         end
         
      fun messageHandler (LOCAL fields) = ! (#msgHandler fields)
        | messageHandler (REMOTE _) = 
          raise At (module ^ "/message-handler", Fail "missing inter-LP message routing")

      datatype mode = IS_LOCAL | IS_REMOTE of int

      fun new { mode, id, definition, staticAddress, location, random } =
         case mode of
            IS_LOCAL =>
               LOCAL {
                  id               = id,
                  definition       = definition,
                  staticAddress    = staticAddress,
                  currentAddress   = ref NONE,
                  location         = location,
                  random           = random,
                  printBuffer      = ref nil,
                  cleanupFunctions = Ring.new (),
                  sigInt           = Ring.new (),
                  sigKill          = Ring.new (),
                  sigUsr1          = Ring.new (),
                  sigUsr2          = Ring.new (),
                  isActive         = ref false,
                  isOnline         = ref false,
                  isRunning        = ref false,
                  msgHandler       = ref (fn _ => raise Routing.PortUnreachable),
                  addressTimeout   = ref NONE,
                  leaveTimeout     = ref NONE
               }
          | IS_REMOTE runningOnLP =>
               REMOTE {
                  id             = id,
                  definition     = definition,
                  staticAddress  = staticAddress,
                  currentAddress = ref NONE,
                  location       = location,
                  isActive       = ref false,
                  isOnline       = ref false,
                  addressTimeout = ref NONE,
                  runningOnLP    = runningOnLP
               }

      fun receiveSignal (getter, name) =
         case current () of
            REMOTE _ => raiseException name
          | LOCAL fields =>
               let
                  open Iterator
                  val it = (fromList o toList o Ring.iterator o getter) fields
                  fun runHandler elem =
                     case Ring.unwrap elem () of
                        UNHOOK => Ring.remove elem
                      | REHOOK => ()
               in
                  app runHandler it
               end

      fun sigInt ()  = receiveSignal (#sigInt, "sigInt")
      fun sigKill () = receiveSignal (#sigKill, "sigKill")
      fun sigUsr1 () = receiveSignal (#sigUsr1, "sigUsr1")
      fun sigUsr2 () = receiveSignal (#sigUsr2, "sigUsr2")

      fun signal (LOCAL fields, signal, handler) =
         let
            fun addSignal ring =
               let
                  val elem = Ring.wrap handler
                  val () = Ring.add (ring, elem)
                  fun unhook () =
                     let
                        val unhooked = Ring.isSolo elem
                        val () = Ring.remove elem
                     in
                        unhooked
                     end
               in
                  unhook
               end
            open Posix.Signal
         in
            if signal = int then addSignal (#sigInt  fields)
            else if signal = kill then addSignal (#sigKill fields)
            else if signal = usr1 then addSignal (#sigUsr1 fields)
            else if signal = usr2 then addSignal (#sigUsr2 fields)
            else raise At (module ^ "/signal",
                  Fail "Only the SIG_INT, SIG_USR1, and SIG_USR2 signals are supported in the simulator.")
         end
      | signal (REMOTE _, _, _) = raiseException("signal (Remote Fields, signal, handler)")

      fun destroy () =
         let
            val (current, fields) = localCurrent ()
                
            val () = if isRunning current then () 
               else raise At (module ^ "/destroy",
                  Fail ("Tried to destroy offline node " ^ toString current))
            val () = setRunning false current
            (* send SIG_KILL to application *)
            val () = sigKill () (* FIXME: kill handler might throw an exception *)
            (* unhook all signal handlers *)
            val () = Ring.clear (#sigInt fields)
            val () = Ring.clear (#sigKill fields)
            val () = Ring.clear (#sigUsr1 fields)
            val () = Ring.clear (#sigUsr2 fields)
            (* close all UDP sockets & unhook all events *)
            open Iterator
            val it = (fromList o toList o Ring.iterator) (#cleanupFunctions fields)
            (* kill pending leave timeout *)
            val timeout = #leaveTimeout fields
            val () =
               case !timeout of
                  NONE => ()
                | SOME event => (
                     Experiment.Event.cancel event
                   ; timeout := NONE
                  )
         in
            app (fn elem => (Ring.unwrap elem) ()) it
            (* TODO: assert that the ring is empty after the execution of all cleanup functions. *)
         end

      fun setLeaveTimeout (LOCAL fields, event) =
         let
            val timeout = #leaveTimeout fields

            fun shorterTimeout (evt1, evt2) =
               let
                  val time1 = case Experiment.Event.timeTillExecution evt1 of
                     SOME x => x
                   | NONE => raise At (module ^ "/set-leave-timeout",
                              Fail "Unscheduled leave timeout event set.")
                  val time2 = case Experiment.Event.timeTillExecution evt2 of
                     SOME x => x
                   | NONE => raise At (module ^ "/set-leave-timeout",
                              Fail "Unscheduled leave timeout event set.")
               in
                  if Time.< (time1, time2) then
                     let
                        val () = Experiment.Event.cancel evt2
                     in
                        SOME evt1
                     end
                  else
                     let
                        val () = Experiment.Event.cancel evt1
                     in
                        SOME evt2
                     end
               end
         in
            (* make sure that no leave timeout is set yet *)
            case !timeout of
               NONE => timeout := SOME event
             | SOME event2 => timeout := shorterTimeout (event, event2)
         end
       | setLeaveTimeout (REMOTE _, _) = raiseException("setLeaveTimeout")

      fun join () =
         let
            val (current, fields) = localCurrent ()
            
            val () = if isRunning current
                        then raise At (module ^ "/join",
                           Fail ("Tried to join online node " ^ toString current)) 
                     else ()
            val () = setRunning true current
            val timeout = #leaveTimeout fields
         in
            case !timeout of
               NONE => ()
             | SOME event =>
               (* cancel old leave timeout from last session that would crash
                  the newly joined node. if so, make sure that the node state
                  has been destroyed. *)
               let
                  val () = Experiment.Event.cancel event
                  val () = timeout := NONE
               in
                  if isRunning current andalso isActive current
                     then destroy ()
                  else ()

               end
         end         

      val exceptionLogger = ref (fn _ => ())
      
      (* log unhandled exception and destroy the crashed node *)
      fun handleException exn =
        let
           val () = (!exceptionLogger) exn
        in
           destroy ()
        end

      (* the exception handler needs a couple of function that were 
         not defined yet where setContext was implemented *)
      fun setCurrent (node, f) =
         setContext (node, fn () => f () handle x => handleException x)
   end
