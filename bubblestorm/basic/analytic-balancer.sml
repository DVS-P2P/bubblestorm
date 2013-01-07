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

(* A quick hack to use when verifying the balancer *)
val [ d, a, q, b ] = CommandLine.arguments ()

open Real32

val d = valOf (fromString d)
val a = valOf (fromString a)
val q = valOf (fromString q)
val b = valOf (fromString b)

val top = max (d, a) + max (d, b)
val bottom = max (d, q)
val ratio = top / bottom
val Q = Math.sqrt ratio
val AB = 1.0 / Q

val () = print ("A: " ^ toString AB ^ "\n")
val () = print ("Q: " ^ toString Q ^ "\n")
val () = print ("B: " ^ toString AB ^ "\n")
