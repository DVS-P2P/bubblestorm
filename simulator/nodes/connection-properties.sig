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

signature CONNECTION_PROPERTIES =
   sig
      type t
      (* parameters: downstream bandwidth, upstream bandwidth, 
        receiveBuffer, sendBuffer, lastHopDelay, messageLoss *)
      val new : Bandwidth.t * Bandwidth.t * int * int * Time.t * real -> t

      val downstream    : t -> Bandwidth.t (* downstream bandwidth *)
      val upstream      : t -> Bandwidth.t (* upstream bandwidth *)
      val receiveBuffer : t -> int (* buffer size of the InQueue in bytes *)
      val sendBuffer    : t -> int (* buffer size of the OutQueue in bytes *)
      val lastHopDelay  : t -> Time.t (* delay added by the node's link to the Internet *)
      val messageLoss   : t -> real (* percentage of lost packets on this connection *)
   end
