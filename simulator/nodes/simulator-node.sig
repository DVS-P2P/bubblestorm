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

signature SIMULATOR_NODE =
   sig
      type t

      exception OutsideNodeContext
      exception RecursiveNodeContext

      (* Executes a function in the scope of a node. Returns the
         output of the function. Inside the function the node can
         be retrieved with current (). setCurrent must not be called
         recursively (will raise At (_, RecursiveNodeContext)). *)
      val setCurrent : t * (unit -> unit) -> unit

      (* Returns the node currently in scope. This node can be set
         with setCurrent. Will raise At (_, OutsideNodeContext) if
         called from outside a setCurrent call. *)
      val current : unit -> t

      (* Returns a node's simulator identifier.
         NOTE: the node's simulator ID does *not* equal its
         simulator network address! *)
      val id : t -> int

      val definition : t -> NodeDefinition.t

      (* Returns the command and arguments of the current node 
         (with variable substitution for the arguments) *)
      val cmdLine : unit -> string * string list

      (* Returns a string version of a node's simulator ID. *)
      val toString : t -> string

      (* Returns the static IP address of a node, if available. *)
      val staticAddress : t -> Address.Ip.t option

      (* Returns the current IP address of a node, if available. *)
      val currentAddress : t -> Address.Ip.t option
      val setCurrentAddress : t * Address.Ip.t option -> unit
      
      (* Sets the callback for incoming network messages *)
      val setMessageHandler : Routing.msgHandler -> unit
      (* Replaces an existing callback with a dummy handler that throws 
         PortUnreachable for every incoming message *)
      val removeMessageHandler : unit -> unit 
      (* Returns the current message handler of a node *)
      val messageHandler : t -> Routing.msgHandler

      (* A property list for stuff to associate with the node that is defined 
         after SimulatorNode *)
      (*val properties : t -> PropertyList.t*)
      
      (* Returns the geographical location of a node. *)
      val location : t -> Location.t

      (* Returns the random number generator (RNG) of a node. Each node
         keeps an individual RNG instance that should be used for all
         its random operations. *)
      val random : t -> Random.t

      val equals : t * t -> bool

      val printBuffer : t -> string list ref

      (* is it a node simulated locally or running on a remote LP?
         in the latter case the ID of the remote LP is given. *)
      datatype mode = IS_LOCAL | IS_REMOTE of int
      
      (* Creates a new node. *)
      val new : {
         mode : mode,
         id   : int,
         definition : NodeDefinition.t,
         staticAddress : Address.Ip.t option,
         location : Location.t,
         random : Random.t
      } -> t

      (* Sends a SigInt signal to the current node, which should tell the application
       * running on the node to quit. The node is not necessarily destroyed by
       * this action. To immediately kill a node, use destroy () instead.
       *)
      val sigInt           : unit -> unit
      val sigUsr1          : unit -> unit
      val sigUsr2          : unit -> unit
      (* Kills the application instance running on the current node by closing
       * all UDP sockets, removing all registered signal handlers, and deleting
       * all scheduled events of the node. It sends a SigKill to the application,
       * which can then deal with unfinished business in the simulator environment.
       * In the real world sigKill cannot be caught.
       *)
      val destroy : unit -> unit
      val setLeaveTimeout : t * Experiment.Event.t -> unit
      val join : unit -> unit
      val isOnline : t -> bool
      val isActive : t -> bool
      val isRunning : t -> bool
      val setActive : bool -> t -> unit
      val setOnline : bool -> t -> unit

      (* A collection of methods used to destroy the node. UDP sockets are
       * registered with their close function and events with their cancel
       * call.
       *)
      val cleanupFunctions : t -> (unit -> unit) Ring.t
      (* Registers a signal handler for this node.
       *)
      datatype rehook = UNHOOK | REHOOK
      val signal : t * Posix.Signal.signal * (unit -> rehook) -> (unit -> bool)
      
      (* the total number of nodes in the experiment, no matter what their state is. 
       * a node can be in the following states: 
       * - inactive & offline, inactive & online, active & offline:
       * - active & online: *)
      (*val totalNodes : unit -> int*)
      (* the number of nodes in the experiment that are set active,
       * and thus are able to run an application (if online, too). *)
      val activeNodes : unit -> int
      (* the number of nodes in the experiment that are set online by their 
       * session-intersession churn model. If they are also active, they are 
       * running. *)
      val onlineNodes : unit -> int
      (* the number of nodes in the experiment that are both online and active.
       * These nodes are actually running the application and are connected 
       * to the network. *)
      val runningNodes : unit -> int
      
      val isLocal : t -> bool
      
      (* the logging function for exceptions. must be set later, because 
         the log is not yet available here. *)
      val exceptionLogger : (exn -> unit) ref
   end