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

signature HMQV =
   sig
      structure CyclicGroup : CYCLIC_GROUP
      
      (* Create two keys of the requested length *)
      val compute : {
         length : int, 
         a : LargeInt.int,
         x : LargeInt.int,
         A : CyclicGroup.t,
         B : CyclicGroup.t,
         X : CyclicGroup.t,
         Y : CyclicGroup.t } -> Word8Vector.vector * Word8Vector.vector
   end
