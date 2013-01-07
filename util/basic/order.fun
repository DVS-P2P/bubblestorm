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

infix 4 == !=

functor OrderFromCompare(Base : ORDER_FROM_COMPARE) : ORDER =
   struct
      open Base
       
      fun op <  (x, y) = compare (x, y) = LESS
      fun op == (x, y) = compare (x, y) = EQUAL
      fun op >  (x, y) = y < x
      fun op >= (x, y) = not (x < y)
      fun op <= (x, y) = not (y < x)
      fun op != (x, y) = not (x == y)
      
      fun min (x, y) = if x < y then x else y
      fun max (x, y) = if x < y then y else x
   end

functor OrderFromLessEqual(Base : ORDER_FROM_LESS_EQUAL) : ORDER =
   struct
      open Base
      
      fun compare (x, y) =
         if x < y then LESS else
         if y < x then GREATER else
         EQUAL
       
      fun op >  (x, y) = y < x
      fun op >= (x, y) = not (x < y)
      fun op <= (x, y) = not (y < x)
      fun op != (x, y) = not (x == y)
      
      fun min (x, y) = if x < y then x else y
      fun max (x, y) = if x < y then y else x
   end
