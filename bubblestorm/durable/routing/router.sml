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

structure Router :> ROUTER =
   struct
      datatype t = T of {
         state   : BasicBubbleType.bubbleState,
         metric  : RoutingMetric.t,
         service : Service.t,
         table   : RoutingTable.t
      }
      
      fun new (state, metric, service, table) = T {
         state   = state,
         metric  = metric,
         service = service,
         table   = table
      }
      
      fun markDead (T this, id) () = RoutingTable.markDead (#table this, id)
         
      fun route (T this) (record, data, sender) =
         let
            fun send (id, neighbor) = Service.store (
               #service this, neighbor, record, data, true, markDead (T this, id)
            )
            val request = Record.decode (#state this, record)
            val neighbors = RoutingMetric.storeIterator (#metric this, request)
            fun filter (_, neighbor) =
               CUSP.Address.!= (sender, Service.address neighbor) 
         in
            Iterator.app send (Iterator.filter filter neighbors)
         end
      
      fun store (this, record, data) =
         route this (record, data, CUSP.Address.invalid)
      
      fun lookup (T this, lookup) =
         let
            fun send (id, neighbor) = Service.lookup (
               #service this, neighbor, lookup, markDead (T this, id)
            )
            val request = Lookup.receive (#state this, lookup)
            val neighbors = RoutingMetric.lookupIterator (#metric this, request)
         in
            Iterator.app send neighbors
         end

      fun send (T this) (id, neighbor, record, data) = Service.store (
         #service this, neighbor, record, data, false, markDead (T this, id)
      )

      fun replicate (T this) change =
         RoutingMetric.itemIterator (#metric this, Iterator.app (send (T this))) 
            change
      
      fun onRoundSwitch (T this) =
         RoutingMetric.onRoundSwitch (#metric this, Iterator.app (send (T this)))
   end
