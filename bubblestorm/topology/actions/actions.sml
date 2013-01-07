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

datatype actions = ACTIONS of {
   bubblecast : int -> Word64.word -> int -> int -> int -> Word8Vector.vector -> unit,
   contactClient : CUSP.Address.t -> makeClient -> unit,
   contactSlave : Location.t -> CUSP.Address.t -> makeSlave -> unit,
   create : CUSP.Address.t -> (unit -> unit) -> unit,
   flushClients : unit -> unit,
   join : Location.t -> unit,
   makeMethods : Conversation.t -> methods * (unit -> unit),
   pushFish : unit -> unit,
   startGossip : int -> Main.Event.t,
   startWalk : Location.t -> makeClient * (unit -> unit),
   upgrade : Location.t -> unit
}
