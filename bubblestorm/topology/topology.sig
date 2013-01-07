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

signature TOPOLOGY =
   sig
      type t
      
      (* Create a network object (that is not connected).
       * hostCache provides addresses to try as entry points.
       *)
      val new : {
         endpoint      : CUSP.EndPoint.t,
         desiredDegree : int,
         hostCache     : unit -> CUSP.Address.t,
         foundBootstrapHandler : CUSP.Address.t -> unit
      } -> t
     
      (* add a new measurement set to the topology, must be called before 
         join/create *)      
      val addMeasurement : t * Measurement.t -> unit
      
      (* add a callback to the topology that is executed after the peer 
         successfully joined the topology. Returns a function to remove
         the callback from the topology. *)
      val addOnJoinHandler : t * (unit -> unit) -> (unit -> unit)
      
      (* add a callback to the topology that is executed when the peer 
         starts leaving the topology. Returns a function to remove
         the callback from the topology. *)
      val addOnLeaveHandler : t * (unit -> unit) -> (unit -> unit)
      
      (* initialize internal structures after setup of bubble types and 
         measurements. Must be called before joining the network the first 
         time. No measurements or bubble types can be created after. *)
      val init : t -> unit
      
      (* Create a new network (using loopback edges), callback invoked when 
         complete. *)
      val create : t * CUSP.Address.t * (unit -> unit) -> unit
      
      (* Join the network, callback invoked once a peer. *)
      val join : t * (unit -> unit) -> unit
      
      (* Leave the network cleanly, callback invoked when done. *)
      val leave : t * (unit -> unit) -> unit
      
      (* What is our best guess at the current IP? *)
      val address : t -> CUSP.Address.t option
           
      (* The CUSP endpoint used by the topology. Useful for higher-level modules
         that need to create their own CUSP connections. *)
      val endpoint : t -> CUSP.EndPoint.t
      
      (* The number of overlay neighbours the topology tries to keep 
         connections to. *)
      val desiredDegree : t -> int
      
      (* process the bubblecast messages of a certain bubble type *)
      type bubblecaster = {
         (* the maximum size a bubble of this type may have *)
         maxSize : unit -> int,
         (* do local processing of a bubble (i.e. storing & matching) *)
         process  : int * Word8Vector.vector -> unit,
         (* compute the priority of a bubble of the given size *)
         priority : int -> Real32.real,
         reliability : int -> Real32.real
      }
      
      (* set a method that returns bubblecaster for a given bubble type id
         to access bubblecast functions of the higher-level modules. *)
      val setBubblecastHandler : t * (int -> bubblecaster) -> unit

      (* start a new bubblecast *)
      val bubblecast : t * {
         typ     : int,
         seed    : Word64.word,
         size    : int,
         start   : int,
         stop    : int,
         payload : Word8Vector.vector
      } -> unit

      (* the network size is set by the bubbles module b/c it's in charge of
         the measurements (do not use this method for anything else) *)
      val setNetworkSize : t * Real32.real -> unit
      
      val minimumDegree : int
   end
