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

structure DurableHashStore :> DURABLE_HASH_STORE =
   struct
      structure HashTable = HashTable(ID)

      type 'a t = (Version.t * 'a option) HashTable.t
      
      fun new () = HashTable.new ()
      
      fun store table (id, version, data, success) =
         case HashTable.get (table, id) of
            NONE => ( HashTable.set (table, id, (version, data)) ; success true )
          | SOME (oldVersion, _) =>
               if Version.<= (version, oldVersion) then success false
               else ( HashTable.set (table, id, (version, data)) ; success true )
      
      fun lookup table (id, return) = return (HashTable.get (table, id))
      
      fun get table id = Option.map (fn (_, data) => data) (HashTable.get (table, id))

      fun remove table id = ignore (HashTable.remove (table, id))
         handle HashTable.KeyDoesNotExist => ()
      
      fun iterator table callback =
         callback (Iterator.map (fn (id, (version, data)) => (id, version, data))
            (HashTable.iterator table))
      
      fun size table () = HashTable.size table
      
      fun durable table =
         {
            store    = store table,
            lookup   = lookup table,
            remove   = remove table,
            iterator = iterator table,
            size     = size table
         }
   end
