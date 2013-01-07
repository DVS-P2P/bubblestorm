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

(**
 * Provides the interface for abstract network addresses.
 * Because of NAT issues, a host can only safely determine
 * its own public address by sending a message to another
 * node and ask the receiver for the sender address. 
 * 
 * Authors: Christof Leng, Wesley Terpstra
 *)
signature ADDRESS =
   sig
      include SERIALIZABLE
      
      (**
       * Reads adress from string representation.
       *)
      val fromString : string -> t list

      (** 
       * An invalid address.
       *)
      val invalid : t
      
      (**
       * Fix an invaild address.
       * If the incomplete address has 0.0.0.0 for an IP, copy using's.
       * If the incomplete address has 0 for a port, copy using's.
       *
       * We need this to derive an ICMP senders address.
       * He fills his socket name (0.0.0.0:8585) into an imcomplete address.
       * The containing ICMP/IP envelope provides the IP and a zero port.
       *)
      val fix : { incomplete : t, using : t } -> t
   end
