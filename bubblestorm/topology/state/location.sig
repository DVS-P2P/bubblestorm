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

signature LOCATION =
   sig
      type t
      
      datatype subjoin = CLIENT | PEER
      datatype subleave = LINGER | QUIT
      datatype goal = JOIN of subjoin | LEAVE of subleave

      type slaveInfo = {
         slave     : Neighbour.t, 
         makeSlave : makeSlave, 
         leave     : leaveSlaveIn option 
      }
      type masterInfo = { 
         master  : Neighbour.t, 
         upgrade : upgradeIn option,
         leave   : leaveMasterIn option 
      }
      datatype state =
         STATE of { master : masterInfo peer, slave  : slaveInfo peer }
      and 'a peer =
         NOTHING
       | CONNECTING of bool -> unit (* free resources used during connect *)
       | CONNECTED of 'a
       | ZOMBIE of 'a
      
      val toString : t -> string (* for logging *)
      
      val slave  : t -> Neighbour.t option
      val master : t -> Neighbour.t option
      
      val slaveIs  : t * Neighbour.t -> bool
      val masterIs : t * Neighbour.t -> bool
      
      val hasStableSlave : t -> bool
      
      val goal : t -> goal
      val leaving : t -> bool
      val setGoal : t * goal -> unit
      
      val state : t -> state
      
      (* Transition NOTHING -> CONNECTING *)
      val connectSlave  : t * (bool -> unit) -> unit
      val connectMaster : t * (bool -> unit) -> unit
      (* Transition CONNECTING -> CONNECTING, finishing as OK the handler fn *)
      val connectMaster' : t * (bool -> unit) -> unit
      val connectSlave'  : t * (bool -> unit) -> unit
      (* Transition CONNECTING -> CONNECTED, finishing as OK the handler fn *)
      val installSlave  : t * slaveInfo  -> unit
      val installMaster : t * masterInfo -> unit
      (* Cancel the CONNECTING state to NOTHING *)
      val failedSlave  : t -> unit
      val failedMaster : t -> unit
      
      (* Remove and return the upgrade function, set slave CONNECTING *)
      val upgrade : t * (bool -> unit) -> upgradeIn
      (* Remove and return the master leave function *)
      val leaveMaster : t -> leaveMasterIn option
      (* Remove and return the slave leave function *)
      val leaveSlave : t -> leaveSlaveIn option
      (* Put in a new leaveMaster *)
      val setLeaveMaster : t * leaveMasterIn -> unit
      (* Put in a new leaveSlave *)
      val setLeaveSlave : t * leaveSlaveIn -> unit
      
      val new : { id          : int, 
                  updateLinks : { min : int, actual : int, max : int } -> unit,
                  evaluate    : t -> unit } -> t
   end
