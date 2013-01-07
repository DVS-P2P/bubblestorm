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

(* NAT forwarder settings *)
val forwarderTimeout = Time.fromSeconds 2
val forwarderRetries = 3
val lifelineFrequency = Time.fromSeconds 15

(* A NAT might allow unsoliticed UDP in due to an old session.
 * Require that 80% of all opens are UDP triggered to mitigate.
 *)
val openTolerance = 0.80 : Real32.real

(* The ratio of ICMP_ACKs to WELCOMEs.
 * Both endpoints are retransmitting, so the ratio should be 50%.
 * [I send one ICMP (triggering ACK) for each WELCOME he sends]
 * Add a bit of tolerance for ICMP packet drops to get 40%.
 *)
val ICMPAckTolerance = 0.40 : Real32.real

(* How quickly do we mix in new values for UDP/ICMP detection *)
val mixRate = 0.03 : Real32.real
