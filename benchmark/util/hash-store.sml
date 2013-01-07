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

structure HashStore :> HASH_STORE =
   struct
      structure IDTable = HashTable(ID)
      
      type 'a t = 'a IDTable.t

      (* retrieve an item *)
      fun get table id = IDTable.get (table, id)

      (* write an item (and overwrite any previous value) *)
      fun set table (id, data) = IDTable.set (table, id, data)
      
      (* store an item *)
      fun insert table (id, data) =
         ( IDTable.add (table, id, data) ; true )
         handle IDTable.KeyExists => false

      (* modify an item *)
      fun modify table (id, map) =
         case IDTable.get (table, id) of
            NONE => false
          | SOME data => ( IDTable.update (table, id, map data) ; true )
         
      (* update an item *)
      fun update table (id, data) =
         ( IDTable.update (table, id, data) ; true )
         handle IDTable.KeyDoesNotExist => false
         
      (* delete an item *)
      fun delete table id =
         ( ignore (IDTable.remove (table, id)) ; true )
         handle IDTable.KeyDoesNotExist => false
         
      (* the number of items stored *)
      val size = IDTable.size

      val iterator = IDTable.iterator
      
      fun idIterator table = Iterator.map #1 (iterator table)
      
      (* create a new store *)
      val new = IDTable.new
   end
