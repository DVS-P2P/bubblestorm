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

structure KVInterface =
   struct
      type data = Word8Vector.vector
      type callback = unit -> unit
      
      type workload = {
         nodeID : ID.t,
         insert : FakeItem.t * callback -> unit,
         update : FakeItem.t * callback  -> unit,
         delete : ID.t * callback  -> unit,
         find   : FakeItem.t * int -> unit
      }
      
      type engine = {
         nodeID : ID.t,
         insert : ID.t * data -> unit,
         update : ID.t * data -> unit,
         delete : ID.t -> unit,
         find   : ID.t * (data option -> unit) -> (unit -> unit)
      }
            
      type overlay = {
         join : callback -> unit,
         leave : callback -> unit
      }
   end
