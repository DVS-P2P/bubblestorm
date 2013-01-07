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

structure KVManaged :> KV_ENGINE =
   struct
      val applicationName = "kv-managed"

      fun setExpiration bubble =
         let
            fun expire _ =
               ManagedBubble.delete {
                  bubble = bubble,
                  done = fn () => ()
               }
         in
            Main.Event.scheduleIn (Main.Event.new expire, KVConfig.expiration)
         end
      
      fun insert bubbletype (id, value) =
         setExpiration (ManagedBubble.insert {
               typ = bubbletype,
               id = id,
               data = value,
               done = fn () => ()
            })

      fun exec (id, bubbletype) callback =
         Option.app callback (ManagedBubble.get {
            typ = bubbletype,
            id = id
         })
         
      fun update bubbletype (id, value) =
         exec (id, bubbletype) (fn bubble =>
            ManagedBubble.update {
               bubble = bubble,
               data = value,
               done = fn () => ()
            }
         )

      fun delete bubbletype id =
         exec (id, bubbletype) (fn bubble =>
            ManagedBubble.delete {
               bubble = bubble,
               done = fn () => ()
            }
         )

      fun new args =
         let
            (* init BubbleStorm *)
            val (bs, overlay) = KVBubbleStorm.new args
            (* create store bubble *)
            val master = BubbleStorm.bubbleMaster bs
            val datastore = ManagedHashStore.new ()
            val interface = ManagedHashStore.managed datastore
            val interface = ManagedDataStore.map (interface, FakeItem.decode, FakeItem.encode)

            val dataBubble = BubbleType.newManaged {
               master      = master,
               name        = "data",
               typeId      = KVConfig.dataBubbleID,
               priority    = NONE,
               reliability = NONE,
               datastore   = ManagedDataStore.new interface
            }
            (* create query bubble *)
            val find = KVBubbleStorm.prepareQuery {
               bubblestorm = bs,
               dataBubble = BubbleType.persistentManaged dataBubble,
               lookup = ManagedHashStore.get datastore
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

structure Application = KeyValueApplication(KVManaged)
