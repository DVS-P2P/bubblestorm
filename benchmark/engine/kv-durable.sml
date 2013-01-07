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

structure KVDurable :> KV_ENGINE =
   struct
      val applicationName = "kv-durable"
      
      fun insert bubbletype (id, value) =
         ignore (DurableBubble.create {
            typ = bubbletype,
            id = id,
            data = value
         })

      fun lookup (id, bubbletype) callback =
         let
            val cancel = ref (fn () => ())
            val () = cancel := DurableBubble.lookup {
               typ = bubbletype,
               id = id,
               receive = fn item => ( (!cancel) () ; callback item )
            }
            val cancelEvt = Main.Event.new (fn _ => (!cancel) ())
         in
            Main.Event.scheduleIn (cancelEvt, KVConfig.defaultQueryTimeout)
         end
         
      fun update bubbletype (id, value) =
         lookup (id, bubbletype) (fn bubble =>
            DurableBubble.update {
               bubble = bubble,
               data = value
            }
         )

      fun delete bubbletype id = lookup (id, bubbletype) DurableBubble.delete

      fun monitor _ (_, _, SOME _) = ()
        | monitor remove (id, _, NONE) =
         let
            fun expire _ = remove id
         in
            Main.Event.scheduleIn (Main.Event.new expire, KVConfig.expiration)
         end
      
      fun new args =
         let
            (* init BubbleStorm *)
            val (bs, overlay) = KVBubbleStorm.new args
            (* create store bubble *)
            val master = BubbleStorm.bubbleMaster bs
            val datastore = DurableHashStore.new ()
            val interface = DurableHashStore.durable datastore
            val interface = DurableDataStore.monitor (interface, monitor (#remove interface))
            val interface = DurableDataStore.map (interface, FakeItem.decode, FakeItem.encode)
            val dataBubble = BubbleType.newDurable {
               master      = master,
               name        = "data",
               typeId      = KVConfig.dataBubbleID,
               priority    = NONE,
               reliability = NONE,
               datastore   = DurableDataStore.new interface
            }
            (* create query bubble *)
            fun lookup id = case DurableHashStore.get datastore id of
               SOME NONE => NONE
             | SOME (SOME x) => SOME x
             | NONE => NONE
            val find = KVBubbleStorm.prepareQuery {
               bubblestorm = bs,
               dataBubble = BubbleType.persistentDurable dataBubble,
               lookup = lookup
            }
            (* build the interface *)
            val workload = {
               nodeID = BubbleStorm.id bs,
               insert = insert dataBubble,
               update = update dataBubble,
               delete = delete dataBubble,
               find   = find
            }
         in
            (overlay, workload)
         end
   end

structure Application = KeyValueApplication(KVDurable)
