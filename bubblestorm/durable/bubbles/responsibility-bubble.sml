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

structure ResponsibilityBubble :> RESPONSIBILITY_BUBBLE =
   struct
      type t = ManagedReplication.t * BasicBubbleType.t
      
      fun new (state, managed, table) =
         let
            val interface = RoutingTable.managed table
            val interface = ManagedDataStore.encode (interface, Service.stub)
            val bubble = BasicBubbleType.new {
               state       = state,
               name        = "Durable.Responsibility",
               typeId      = ~7,
               class       = BasicBubbleType.MANAGED {
                                cache = ManagedDataCache.new (),
                                datastore = ManagedDataStore.new interface
                             },
               priority    = Config.defaultQueryPriority,
               reliability = Config.defaultBubblepostReliability
            }
            val () = BasicBubbleType.setSizeStat (bubble, SOME Stats.responsibilitySize)
            val () = BasicBubbleType.setSizeStat (bubble, SOME Stats.responsibilitySize)
         in
            (managed, bubble)
         end

      val getMyID =
         NodeAttributes.id o BasicBubbleType.attributes o BasicBubbleType.state

      fun publish ((managed, bubble), service) =
         ignore (ManagedReplication.insert (managed, {
            bubble = bubble,
            id     = getMyID bubble,
            data   = (#toVector (Serial.methods Service.t)) service,
            done   = fn () => ()
         }))

      (* match constraint for data bubble assures correct size of responsibility bubble.
         setMinimum stops the balancer from making durable bubbles too small and
         thus too unreliable in case of a failure. *)
      fun register ((managed, bubble), typ, activate) =
         let
            val () = BasicBubbleType.setMinimum (typ, fn _ => Config.durableReliability)
            val () = BasicBubbleType.match {
               subject = bubble,
               object  = typ,
               lambda  = Config.durableDegree/2.0,
               handler = fn (_, _) => () (* the rendezvous is irrelevant *)
            }
         in
            if activate 
               then ManagedReplication.register (managed, bubble)
               else ()
         end
   end
