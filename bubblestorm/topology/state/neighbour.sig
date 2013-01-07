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

signature NEIGHBOUR =
   sig
      type t
      
      (* Setup a neighbour relationship using the two persistent streams *)
      val new : Conversation.t * CUSP.InStream.t * CUSP.OutStream.t * methodsIn -> t
      
      val conversation : t -> Conversation.t
      val host : t -> CUSP.Host.t
      val address : t -> CUSP.Address.t option
      val methods : t -> methodsIn
      val eq : t * t -> bool
      
      (* Neighbours have several hooks:
       *   death handlers -> run when neighbour crashes OR duplex shutdown
       *   unhook         -> run on death and change of unhook
       *   teardown       -> run on CLEAN shutdown by peer
       *)
      
      (* Set the unhook method to remove it from topology (stop messages) 
       * Runs the old unhook method first.
       * The old unhook method is guaranteed to run exactly once.
       *)
      val setUnhook : t * (unit -> unit) -> unit
      (* Add method to be called on neighbour death (free resources) *)
      val addDeathHandler : t * (unit -> unit) -> unit
      
      (* The other side gets a grace period to completeTeatdown on his side.
       * Your teardownHandler will NOT be run (death handlers will).
       * Your unhook is run immediately.
       *)
      val initiateTeardown : t -> unit
      (* Watch for tear-down initiation (ie: transition to zombie state) *)
      val setTeardownHandler : t * (unit -> unit) -> unit
      (* Should be called in response to an initiated teardown *)
      val completeTeardown : t -> unit
      
      (* Destroy the neighbour forcibly (needed by some error conditions) *)
      val reset : t -> unit
      (* Check if something is a zombie *)
      val isZombie : t -> bool
      
      (* Pretty printing *)
      (*val localName : t -> string
      val remoteName : t -> string*)
      val toString : t -> string
      
      (* Set the name for tracking down lost stream *)
      val setName : t * string -> unit
      val name : t -> string
   end
