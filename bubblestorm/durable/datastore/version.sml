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

structure Version :> VERSION =
   struct
      structure Order = OrderFromCompare(
         struct
            type t =  Int64.int * Time.t
            
            fun compare ((c1, t1), (c2, t2)) =
               case Int64.compare (c1, c2) of
                  LESS => LESS
                | EQUAL => Time.compare (t1, t2)
                | GREATER => GREATER
         end
      )
      open Order
      
      local
         open Serial
      in
         val t = aggregate tuple2 `int64l `Time.t $
      end
      
      fun new () = (0 : Int64.int, Time.zero)
      
      fun increase (counter, _) = (counter+1 : Int64.int, Main.Event.time ())
      
      fun hash (counter, time) = Hash.int64 counter o Time.hash time
      
      fun toString (counter, time) =
         "(" ^ Int64.toString counter ^ " " ^ Time.toAbsoluteString time ^ ")"
      
      fun toValues (counter, time) = (counter, Time.toNanoseconds64 time)
      fun fromValues (counter, time) = (counter, Time.fromNanoseconds64 time)
   end
