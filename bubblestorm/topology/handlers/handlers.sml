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

datatype handlers = HANDLERS of {
   bootstrap     : bootstrapOut,
   bootstrapOk   : Conversation.t * (unit -> unit) -> bootstrapOkOut,
   bubblecast    : Conversation.t option -> bubblecastOut,
   findServer    : Conversation.t -> findServerOut,
   foundBootstrap: Location.t -> Conversation.t * bootstrapIn -> unit,
   foundClient   : Conversation.t * makeClientIn -> unit,
   foundSlave    : Location.t -> Conversation.t * makeSlaveIn -> unit,
   gossip        : Conversation.t -> gossipOut,
   leaveClient   : Neighbour.t * (unit -> unit) -> leaveClientOut,
   leaveMaster   : Location.t * Neighbour.t -> leaveMasterOut,
   leaveSlave    : Location.t * Neighbour.t -> leaveSlaveOut,
   makeClient    : Location.t -> makeClientOut,
   makeSlave     : Location.t * Neighbour.t option -> makeSlaveOut,
   upgrade       : Neighbour.t * (unit -> unit) -> upgradeOut,
   upgradeOk     : Location.t * Neighbour.t -> upgradeOkOut,
   yesServer     : Conversation.t * CUSP.OutStream.t * (Neighbour.t -> unit) -> yesServerOut,
   yesMaster     : Conversation.t * CUSP.OutStream.t * Location.t * (Neighbour.t -> unit) -> yesMasterOut
}
