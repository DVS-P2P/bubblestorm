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

fun shr (i, j, x) = 
   Word.toIntX (Word.>> (Word.fromInt i, x) + Word.>> (Word.fromInt j, x))

val unit = fn () =>
   { align  = 0w0, 
     length = 0,
     write  = fn _ => (),
     readA  = fn _ => (),
     readV  = fn _ => (),
     extra  = () } 

val word8 = fn () =>
   { align  = 0w0, 
     length = 1, 
     write  = fn (a, i, j, w) => PackWord8.update (a, shr (i, j, 0w0), w),
     readA  = fn (a, i, j)    => PackWord8.subArr (a, shr (i, j, 0w0)),
     readV  = fn (v, i, j)    => PackWord8.subVec (v, shr (i, j, 0w0)),
     extra  = () } 

val word16l = fn () =>
   { align  = 0w1,
     length = 2, 
     write  = fn (a, i, j, w) => PackWord16L.update (a, shr (i, j, 0w1), w),
     readA  = fn (a, i, j)    => PackWord16L.subArr (a, shr (i, j, 0w1)),
     readV  = fn (v, i, j)    => PackWord16L.subVec (v, shr (i, j, 0w1)),
     extra  = () } 

val word32l = fn () =>
   { align  = 0w3, 
     length = 4,
     write  = fn (a, i, j, w) => PackWord32L.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackWord32L.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackWord32L.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val word64l = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackWord64L.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackWord64L.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackWord64L.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

val word16b = fn () =>
   { align  = 0w1,
     length = 2, 
     write  = fn (a, i, j, w) => PackWord16B.update (a, shr (i, j, 0w1), w),
     readA  = fn (a, i, j)    => PackWord16B.subArr (a, shr (i, j, 0w1)),
     readV  = fn (v, i, j)    => PackWord16B.subVec (v, shr (i, j, 0w1)),
     extra  = () } 

val word32b = fn () =>
   { align  = 0w3, 
     length = 4,
     write  = fn (a, i, j, w) => PackWord32B.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackWord32B.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackWord32B.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val word64b = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackWord64B.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackWord64B.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackWord64B.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

val int8 = fn () =>
   { align  = 0w0,
     length = 1, 
     write  = fn (a, i, j, w) => PackInt8.update (a, shr (i, j, 0w0), w),
     readA  = fn (a, i, j)    => PackInt8.subArr (a, shr (i, j, 0w0)),
     readV  = fn (v, i, j)    => PackInt8.subVec (v, shr (i, j, 0w0)),
     extra  = () } 

val int16l = fn () =>
   { align  = 0w1, 
     length = 2, 
     write  = fn (a, i, j, w) => PackInt16L.update (a, shr (i, j, 0w1), w),
     readA  = fn (a, i, j)    => PackInt16L.subArr (a, shr (i, j, 0w1)),
     readV  = fn (v, i, j)    => PackInt16L.subVec (v, shr (i, j, 0w1)),
     extra  = () } 

val int32l = fn () =>
   { align  = 0w3, 
     length = 4, 
     write  = fn (a, i, j, w) => PackInt32L.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackInt32L.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackInt32L.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val int64l = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackInt64L.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackInt64L.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackInt64L.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

val int16b = fn () =>
   { align  = 0w1, 
     length = 2, 
     write  = fn (a, i, j, w) => PackInt16B.update (a, shr (i, j, 0w1), w),
     readA  = fn (a, i, j)    => PackInt16B.subArr (a, shr (i, j, 0w1)),
     readV  = fn (v, i, j)    => PackInt16B.subVec (v, shr (i, j, 0w1)),
     extra  = () } 

val int32b = fn () =>
   { align  = 0w3, 
     length = 4, 
     write  = fn (a, i, j, w) => PackInt32B.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackInt32B.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackInt32B.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val int64b = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackInt64B.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackInt64B.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackInt64B.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

val real32l = fn () =>
   { align  = 0w3, 
     length = 4, 
     write  = fn (a, i, j, w) => PackReal32L.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackReal32L.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackReal32L.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val real64l = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackReal64L.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackReal64L.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackReal64L.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

val real32b = fn () =>
   { align  = 0w3, 
     length = 4, 
     write  = fn (a, i, j, w) => PackReal32B.update (a, shr (i, j, 0w2), w),
     readA  = fn (a, i, j)    => PackReal32B.subArr (a, shr (i, j, 0w2)),
     readV  = fn (v, i, j)    => PackReal32B.subVec (v, shr (i, j, 0w2)),
     extra  = () } 

val real64b = fn () =>
   { align  = 0w7, 
     length = 8, 
     write  = fn (a, i, j, w) => PackReal64B.update (a, shr (i, j, 0w3), w),
     readA  = fn (a, i, j)    => PackReal64B.subArr (a, shr (i, j, 0w3)),
     readV  = fn (v, i, j)    => PackReal64B.subVec (v, shr (i, j, 0w3)),
     extra  = () } 

local
   (* helper functions to serialize bools as bytes *)
   fun boolToWord8 x = if x then 0w1 else 0w0
   fun word8ToBool x = x > 0w0
in
   
   val bool = fn () =>
      { align  = 0w0, 
        length = 1, 
        write  = fn (a, i, j, w) => PackWord8.update (a, shr (i, j, 0w0), boolToWord8 w),
        readA  = fn (a, i, j)    => word8ToBool (PackWord8.subArr (a, shr (i, j, 0w0))),
        readV  = fn (v, i, j)    => word8ToBool (PackWord8.subVec (v, shr (i, j, 0w0))),
        extra  = () } 
end
