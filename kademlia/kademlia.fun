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

functor Kademlia(
      structure Event : EVENT
      structure Id : ID
      structure RPC : RPC
(*       structure Value : VALUE *)
(*       structure ValueStore : VALUE_STORE *)
   ) : KADEMLIA
   where type Address.t = RPC.Address.t
   =
   struct
      structure Event = Event
      structure Address = RPC.Address
      structure Id = Id
      structure Node = Node(
         structure Event = Event
         structure RPC = RPC
         structure Id = Id
(*          structure Value = Value *)
(*          structure ValueStore = ValueStore *)
      )
(*       structure Value = Value *)
   end
