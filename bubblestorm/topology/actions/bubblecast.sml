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

fun doBubblecast
   (HANDLERS { bubblecast, ... })
   (ACTIONS { ... })
   _
   typ seed size start stop payload =
   let
      fun method () = "topology/action/bubblecast"
      val () = Log.logExt (Log.DEBUG, method, fn () => 
         "called with typ=" ^ (Int.toString typ) ^ ", size=" ^ (Int.toString size)
          ^ ", start=" ^ (Int.toString start) ^ ", stop=" ^ (Int.toString stop))
   in
      (* call the local bubblecast handler to process and forward the message *)
      bubblecast NONE typ seed 0 size start stop payload
   end
