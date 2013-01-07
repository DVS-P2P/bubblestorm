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

structure HostCache : HOST_CACHE =
   struct
      structure Address = Address

      val global = Ring.new ()
      
      fun addGlobal address = Ring.add (global, Ring.wrap address)
               
      type t = unit
      
      fun new (_, _) = ()
      fun close _ = ()
      fun add (_, _) = ()
      
      fun get _ = 
         let
            val entries = (Vector.map Ring.unwrap o Iterator.toVector o Ring.iterator) global
            val pos = Random.int (getTopLevelRandom (), Vector.length entries)
         in
            Vector.sub (entries, pos)
         end
end
