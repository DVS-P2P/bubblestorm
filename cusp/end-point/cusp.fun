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

functor CUSP(structure Log    : LOG
             structure UDP    : PEERED_UDP
             structure Event  : EVENT)
   :> CUSP where type Address.t = UDP.Address.t
   =
   struct
      structure Address = UDP.Address
      
      structure Suite = Suite
      structure Crypto = Crypto
      structure InStream = InStreamQueue
      structure OutStream = OutStreamQueue
      structure BufferedOutStream = BufferedOutStream(OutStream)
      
      structure Host = HostDispatch(structure Log = Log
                                    structure Address = Address
                                    structure Event = Event)
      structure EndPoint = EndPoint(structure Log = Log
                                    structure UDP = UDP
                                    structure Event = Event
                                    structure HostDispatch = Host)
      
      exception RaceCondition = RaceCondition
      exception AddressInUse = AddressInUse
   end
