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

signature CONSTRAINT =
   sig
      eqtype var
      type constant = Real64.real
      
      (* a*x + b*y + c*z >= 0   (x=NONE means x=1) *)
      (* x >= exp(y)    good for |y| > 1 *)
      (* x >= exp(y)-1  good for y > -1 *)
      datatype t = 
         SUM of { x : var option, y : var option, z : var option,
                  a : constant,   b : constant,   c : constant }
       | EXP of { x : var, y : var }
       | EXP1 of { x : var, y : var }
      
      val newVariable : unit -> var
      val plist : var -> PropertyList.t
      
      val vars : t -> var Iterator.t
    end
