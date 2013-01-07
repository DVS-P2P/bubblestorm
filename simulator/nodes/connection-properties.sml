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

structure ConnectionProperties :> CONNECTION_PROPERTIES =
   struct

      datatype t = T of
         { downstream    : Bandwidth.t,
           upstream      : Bandwidth.t,
           receiveBuffer : int,
           sendBuffer    : int,
           lastHopDelay  : Time.t,
           messageLoss   : real
         }

      fun new (downstream, upstream, receiveBuffer, sendBuffer, lastHopDelay, messageLoss) =
         T { downstream = downstream,
             upstream = upstream,
             receiveBuffer = receiveBuffer,
             sendBuffer = sendBuffer,
             lastHopDelay = lastHopDelay,
             messageLoss = messageLoss
           }

      fun downstream (T fields)    = #downstream fields
      fun upstream (T fields)      = #upstream fields
      fun receiveBuffer (T fields) = #receiveBuffer fields
      fun sendBuffer (T fields)    = #sendBuffer fields
      fun lastHopDelay (T fields)  = #lastHopDelay fields
      fun messageLoss (T fields)   = #messageLoss fields
   end