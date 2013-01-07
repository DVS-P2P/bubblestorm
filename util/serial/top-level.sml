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

fun $ (a, f) = f a

local
   (* Tuple.to/from functions *)
   fun tuple1t  a = (a)
   fun tuple1f  t (a) = t a
   fun tuple2t  a b = (a, b)
   fun tuple2f  t (a, b) = t a b
   fun tuple3t  a b c = (a, b, c)
   fun tuple3f  t (a, b, c) = t a b c
   fun tuple4t  a b c d = (a, b, c, d)
   fun tuple4f  t (a, b, c, d) = t a b c d
   fun tuple5t  a b c d e = (a, b, c, d, e)
   fun tuple5f  t (a, b, c, d, e) = t a b c d e
   fun tuple6t  a b c d e f = (a, b, c, d, e, f)
   fun tuple6f  t (a, b, c, d, e, f) = t a b c d e f
   fun tuple7t  a b c d e f g = (a, b, c, d, e, f, g)
   fun tuple7f  t (a, b, c, d, e, f, g) = t a b c d e f g
   fun tuple8t  a b c d e f g h = (a, b, c, d, e, f, g, h)
   fun tuple8f  t (a, b, c, d, e, f, g, h) = t a b c d e f g h
   fun tuple9t  a b c d e f g h i = (a, b, c, d, e, f, g, h, i)
   fun tuple9f  t (a, b, c, d, e, f, g, h, i) = t a b c d e f g h i
   fun tuple10t a b c d e f g h i j = (a, b, c, d, e, f, g, h, i, j)
   fun tuple10f t (a, b, c, d, e, f, g, h, i, j) = t a b c d e f g h i j
   fun tuple11t a b c d e f g h i j k = (a, b, c, d, e, f, g, h, i, j, k)
   fun tuple11f t (a, b, c, d, e, f, g, h, i, j, k) = t a b c d e f g h i j k
   fun tuple12t a b c d e f g h i j k l = (a, b, c, d, e, f, g, h, i, j, k, l)
   fun tuple12f t (a, b, c, d, e, f, g, h, i, j, k, l) = t a b c d e f g h i j k l
   fun tuple13t a b c d e f g h i j k l m = (a, b, c, d, e, f, g, h, i, j, k, l, m)
   fun tuple13f t (a, b, c, d, e, f, g, h, i, j, k, l, m) = t a b c d e f g h i j k l m
   fun tuple14t a b c d e f g h i j k l m n = (a, b, c, d, e, f, g, h, i, j, k, l, m, n)
   fun tuple14f t (a, b, c, d, e, f, g, h, i, j, k, l, m, n) = t a b c d e f g h i j k l m n
   fun tuple15t a b c d e f g h i j k l m n O = (a, b, c, d, e, f, g, h, i, j, k, l, m, n, O)
   fun tuple15f t (a, b, c, d, e, f, g, h, i, j, k, l, m, n, O) = t a b c d e f g h i j k l m n O
   fun tuple16t a b c d e f g h i j k l m n O p = (a, b, c, d, e, f, g, h, i, j, k, l, m, n, O, p)
   fun tuple16f t (a, b, c, d, e, f, g, h, i, j, k, l, m, n, O, p) = t a b c d e f g h i j k l m n O p
in
   val tuple1  = (tuple1t,  tuple1f)
   val tuple2  = (tuple2t,  tuple2f)
   val tuple3  = (tuple3t,  tuple3f)
   val tuple4  = (tuple4t,  tuple4f)
   val tuple5  = (tuple5t,  tuple5f)
   val tuple6  = (tuple6t,  tuple6f)
   val tuple7  = (tuple7t,  tuple7f)
   val tuple8  = (tuple8t,  tuple8f)
   val tuple9  = (tuple9t,  tuple9f)
   val tuple10 = (tuple10t, tuple10f)
   val tuple11 = (tuple11t, tuple11f)
   val tuple12 = (tuple12t, tuple12f)
   val tuple13 = (tuple13t, tuple13f)
   val tuple14 = (tuple14t, tuple14f)
   val tuple15 = (tuple15t, tuple15f)
   val tuple16 = (tuple16t, tuple16f)
end
