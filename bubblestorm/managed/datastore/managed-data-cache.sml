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

structure ManagedDataCache :> MANAGED_DATA_CACHE =
   struct
      type elem = Word8Vector.vector ref
      
      structure Table = HashTable(ID)
      
      type t = elem Table.t
      
      val new = Table.new
      
      fun insert (this, id, data) =
         let
            val elem = ref data
            val () = Table.add (this, id, elem)
         in
            fn () => !elem
         end
      
      fun update (this, id, data) =
         case Table.get (this, id) of
            NONE => raise Table.KeyDoesNotExist
          | SOME elem => elem := data
      
      val delete = ignore o Table.remove
      
      fun get (this, id) =
         Option.map (fn x => (fn () => !x)) (Table.get (this, id))
      
      fun iterator this =
         Iterator.map (fn (x, y) => (x, !y)) (Table.iterator this)
   end
