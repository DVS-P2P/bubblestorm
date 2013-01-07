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

signature BUBBLESTORM =
   sig
      type t

      val new : {
         bandwidth    : Real32.real option,
         minBandwidth : Real32.real option,
         port         : int option,
         privateKey   : CUSP.Crypto.PrivateKey.t,
         encrypt      : bool
      } -> t

      val newWithEndpoint : {
         bandwidth    : Real32.real option,
         minBandwidth : Real32.real option,
         endpoint     : CUSP.EndPoint.t
      } -> t

      val id : t -> ID.t
      
      val create : t * CUSP.Address.t * (unit -> unit) -> unit

      val join : t * (unit -> unit) -> unit

      val leave : t * (unit -> unit) -> unit

      val endpoint : t -> CUSP.EndPoint.t

      val networkSize : t -> int                 

      val bubbleMaster : t -> BubbleType.master

      (* What is our best guess at the current IP? *)
      val address : t -> CUSP.Address.t option
      
      (* Functions for application-level host cache persistence *)
      val saveHostCache : t -> Word8Vector.vector
      val loadHostCache : t * {
         data      : Word8Vector.vector,
         wellKnown : CUSP.Address.t list,
         bootstrap : CUSP.Address.t option
      } -> unit (* raises InvalidHostCacheData *)
      exception InvalidHostCacheData
      
      (* A global flag controlling timeouts for all instances of BubbleStorm.
         When enabled all timeouts are reduced by a factor 10 (for LAN debugging 
         testbeds). *)
      val setLanMode : bool -> unit

      (* add a new measurement set to the topology, must be called before 
         join/create *)      
      val addMeasurement : t * Measurement.t -> unit
      
      (* add a callback to the topology that is executed after the peer 
         successfully joined the topology. Returns a function to remove
         the callback from the topology. *)
      (* TODO: implement if needed
         val addOnJoinHandler : t * (unit -> unit) -> (unit -> unit) *)
      
      (* add a callback to the topology that is executed when the peer 
         starts leaving the topology. Returns a function to remove
         the callback from the topology. *)
      (* TODO: implement if needed
         val addOnLeaveHandler : t * (unit -> unit) -> (unit -> unit) *)
   end
