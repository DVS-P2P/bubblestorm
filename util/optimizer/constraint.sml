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

structure Constraint :> CONSTRAINT =
   struct
      type var = PropertyList.t
      type constant = Element.t
      
      datatype t = 
         SUM of { x : var option, y : var option, z : var option,
                  a : constant,   b : constant,   c : constant }
       | EXP of { x : var, y : var }
       | EXP1 of { x : var, y : var }
      
      fun newVariable () = PropertyList.new ()
      fun plist x = x
      
      fun var (NONE,   f) = Iterator.SKIP f
        | var (SOME x, f) = Iterator.VALUE (x, f)
      val vars = fn
         SUM { x, y, z, ... } => 
            var (x, fn () => 
            var (y, fn () => 
            var (z, fn () =>
            Iterator.EOF)))
       | EXP { x, y } =>
            Iterator.VALUE (x, fn () => 
            Iterator.VALUE (y, fn () =>
            Iterator.EOF))
       | EXP1 { x, y } =>
            Iterator.VALUE (x, fn () => 
            Iterator.VALUE (y, fn () =>
            Iterator.EOF))
   end
