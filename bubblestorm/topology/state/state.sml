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

datatype gossips = MEASUREMENTS of Measurement.t list | GOSSIP of Gossip.t vector

type bubblecaster = {
   maxSize : unit -> int,
   process  : int * Word8Vector.vector -> unit,
   priority : int -> Real32.real,
   reliability : int -> Real32.real
}

datatype state = STATE of {
   endpoint     : CUSP.EndPoint.t,
   clients      : Clients.t,
   locations    : Locations.t,
   gossip       : gossips ref,
   oracle       : unit -> CUSP.Address.t,
   cache        : CUSP.Address.t option ref,
   hooks        : Main.Event.t vector ref,
   bubblecaster : (int -> bubblecaster) option ref,
   onJoin       : (unit -> unit) Ring.t,
   onLeave      : (unit -> unit) Ring.t,
   onFoundBootstrap : CUSP.Address.t -> unit,
   networkSize  : Real32.real ref
}
