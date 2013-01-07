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

structure Backend :> BACKEND =
   struct
      val module = "bubblestorm/durable/backend"
      
      type t = unit -> BasicBubbleType.t list
      
      type itemSet = BasicBubbleType.t * (ID.t * Version.t * Word8Vector.vector) Iterator.t
      
      fun new x = x
      
      fun getDataStore bubble =
         case BasicBubbleType.class bubble of
            BasicBubbleType.DURABLE { datastore } => datastore
          | _ => raise At (module, Fail "non-durable bubbletype in list")
      
      fun isNew ({ bubble, id, version }, success) =
         let
            fun compare NONE = success true
              | compare (SOME (currentVersion, _)) =
               success (Version.> (version, currentVersion))
         in
            DurableDataStore.lookup (getDataStore bubble) (id, compare)
         end
         
      fun store ({ bubble, id, version }, data, position, success) =
         let
            (* filter out delete requests *)
            val actualData = case Word8Vector.length data of
                  0 => NONE
                | _ => SOME data
            (* match successful store requests against other bubble types *)      
            fun match false = ()
              | match true = if actualData = NONE then () else
               BasicBubbleType.doMatching (bubble, position) 
                                (id, Word8VectorSlice.full data)
         in
            DurableDataStore.store (getDataStore bubble) 
               (id, version, actualData, fn x => ( match x ; success x ))
         end
         
      fun lookup { bubble, id, receive } =
         let
            fun evaluate result =
               case result of
                  SOME (version, SOME data) => receive (version, data)
                | SOME (version, NONE) => receive (version, Word8Vector.fromList [])
                | NONE => ()
         in
            DurableDataStore.lookup (getDataStore bubble) (id, evaluate)
         end
      
      fun iterator (this, callback) =
         let
            fun map (id, version, SOME data) = (id, version, data)
              | map (id, version, NONE) = (id, version, Word8Vector.fromList [])
            fun getItems bubble = DurableDataStore.iterator (getDataStore bubble)
                  (fn items => callback ((bubble, Iterator.map map items) : itemSet))
         in
            List.app getItems (this ())
         end
      
      fun cleanup (this, getFilter) =
         let
            fun select filter (id, _, _) = if (filter id) then NONE else SOME id

            fun clean (datastore, filter) items =
               Iterator.app (DurableDataStore.remove datastore) 
                  (Iterator.mapPartial (select filter) items)
               
            fun cleanBubble bubble =
               let
                  val datastore = getDataStore bubble
                  val filter = getFilter bubble
               in
                  DurableDataStore.iterator datastore (clean (datastore, filter))
               end
         in
            List.app cleanBubble (this ())
         end
   end
   
