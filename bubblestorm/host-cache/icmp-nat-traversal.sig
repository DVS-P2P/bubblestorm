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

signature ICMP_NAT_TRAVERSAL =
   sig
      val init : CUSP.EndPoint.t -> unit
      val onFoundBootstrap : CUSP.EndPoint.t -> CUSP.Address.t -> unit
      val onJoinComplete : {
         endpoint : CUSP.EndPoint.t,
         address : unit -> CUSP.Address.t option,
         hostCache : HostCache.t,
         registerUnhook : (unit -> unit) -> unit
      } -> unit
   end
