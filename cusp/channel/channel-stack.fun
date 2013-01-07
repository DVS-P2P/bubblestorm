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

functor ChannelStack(structure Log : LOG
                     structure Event : EVENT
                     structure HostDispatch : HOST_DISPATCH
                     structure Address : ADDRESS)
   :> NEGOTIATION 
      where type host = HostDispatch.t
      where type address = Address.t =
   struct
      structure Event = Event
      
      structure CongestionControl = 
         Reno(structure HostDispatch = HostDispatch)
      structure AckCallbacks = 
         FastRetransmit(structure CongestionControl = CongestionControl
                        structure Event = Event)
      structure AckGenerator = 
         DelayedAck(structure AckCallbacks = AckCallbacks
                    structure Event = Event)
      structure Negotiation =
         Negotiation(structure Log = Log
                     structure Event = Event
                     structure AckGenerator = AckGenerator
                     structure HostDispatch = HostDispatch
                     structure Address = Address)
      
      open Negotiation
   end
