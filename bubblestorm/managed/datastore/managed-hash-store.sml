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

structure ManagedHashStore :> MANAGED_HASH_STORE =
   struct
      structure HashTable = HashTable(ID)

      type 'a t = ('a * bool) HashTable.t
      
      fun new () = HashTable.new ()
      
      fun insert table (id, data, done, bucket) =
         ( HashTable.set (table, id, (data, bucket)) ; done () )
      
      fun update table (id, data, done) =
         ( HashTable.modify (table, id, fn (_, bucket) => (data, bucket)) ; done () )

      fun delete table (id, done) =
         ( ignore (HashTable.remove (table, id)) ; done () )
         
      fun get table id = Option.map (fn (data, _) => data) (HashTable.get (table, id))
      
      fun iterator table =
         Iterator.map (fn (id, (data, _)) => (id, data)) (HashTable.iterator table)
      
      fun flush table filter =
         let
            fun select (_, (_, bucket)) = filter bucket
            fun kill (id, _) = ignore (HashTable.remove (table, id))
         in
            Iterator.app kill (Iterator.filter select (HashTable.iterator table))
         end
      
      fun size table () = HashTable.size table
      
      fun managed table =
         {
            insert = insert table,
            update = update table,
            delete = delete table,
            get    = get table,
            flush  = flush table,
            size   = size table
         }
         
       val size = fn table => size table ()
   end
