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

functor RingMap(Key : HASH_KEY) =
   struct
      structure Map = HashTable(Key)
      
      type 'a element = 'a Ring.element
      type 'a t = 'a Ring.t * 'a element Map.t
      
      fun new () =
         (Ring.new (), Map.new ())
      
      fun addHead ((ring, map), key, item) =
         let
            val el = Ring.wrap item
            val () = Map.add (map, key, el)
         in
            Ring.add (ring, el)
         end
      
      fun addTail ((ring, map), key, item) =
         let
            val el = Ring.wrap item
            val () = Map.add (map, key, el)
         in
            Ring.addTail (ring, el)
         end
      
      fun moveHead ((ring, _), el) =
         Ring.add (ring, el)
      
      fun moveTail ((ring, _), el) =
         Ring.addTail (ring, el)
      
      fun remove ((_, map), key) =
         Ring.remove (Map.remove (map, key))
      
      fun size (_, map) =
         Map.size map
      
      fun isEmpty (_, map) =
         Map.isEmpty map
      
      fun get ((_, map), key) =
         Map.get (map, key)
      
      fun head (ring, _) =
         Ring.head ring
      
      fun tail (ring, _) =
         Ring.tail ring
      
      fun contains ((_, map), key) =
         Option.isSome (Map.get (map, key))
      
      fun iterator (ring, _) =
         Ring.iterator ring
      
      fun unwrap el =
         Ring.unwrap el
      
   end
