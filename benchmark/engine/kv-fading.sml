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

structure KVFading :> KV_ENGINE =
   struct
      val applicationName = "kv-fading"
      
      fun insert bubbletype (id, value) =
         ignore (FadingBubble.create {
            typ = bubbletype,
            id = id,
            data = value
         })

      fun new args =
         let
            (* init BubbleStorm *)
            val (bs, overlay) = KVBubbleStorm.new args
            (* create store bubble *)
            val master = BubbleStorm.bubbleMaster bs
            val dataStore = KVFadingStore.new ()
            val dataBubble = BubbleType.newFading {
               master      = master,
               name        = "data",
               typeId      = KVConfig.dataBubbleID,
               priority    = NONE,
               reliability = NONE,
               store       = KVFadingStore.store dataStore
            }
            (* create query bubble *)
            val find = KVBubbleStorm.prepareQuery {
               bubblestorm = bs,
               dataBubble = BubbleType.persistentFading dataBubble,
               lookup = KVFadingStore.get dataStore
            }
            (* build the interface *)
            val workload = {
               nodeID = BubbleStorm.id bs,
               insert = insert dataBubble,
               update = fn _ => (), (* impossible for fading *)
               delete = fn _ => (), (* impossible for fading *)
               find   = find
            }
         in
            (overlay, workload)
         end
   end

structure Application = KeyValueApplication(KVFading)
