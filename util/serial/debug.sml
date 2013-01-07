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

(*
local
   open Serial
   val x = aggregate tuple5 `int8 `word8 `word16 `word16 `word32 $
in
   val { length, writer, parser } = pickleVector `x $
end


val v = writer (fn v => v) (79, 0w13, 0wxaabb, 0wxccdd, 0wxabcdef01)
val (a, b, c, d, e) = parser (v, fn x => x)
val () = print (Int8.toString a ^ Word8.toString b ^ Word16.toString c ^
                Word16.toString d ^ Word32.toString e ^ "\n")
*)

local
   open Serial
   val x = aggregate tuple5 `int8 `word8 `word16l `word16b `word32l $
in
   val { writeSlice, parseSlice, ... } = methods x
end

fun f 0 = 0
  | f i = f (i-1) + 1

val a = Word8Array.array (16, 0w0)
val s = Word8ArraySlice.slice (a, f 4, NONE)
val () = writeSlice (s, (79, 0w13, 0wxaabb, 0wxccdd, 0wxabcdef01))
val (a, b, c, d, e) = parseSlice s

val () = print (Int8.toString a ^ Word8.toString b ^ Word16.toString c ^
                Word16.toString d ^ Word32.toString e ^ "\n")

val i = 0x123456789123456789
local
   open Serial
in
   val { toVector, fromVector, ... } = methods (intinfb 24)
end

val v = toVector i
val j = fromVector v

val () = print (IntInf.toString i ^ "\n")
val () = print (WordToString.fromBytes v ^ "\n")
val () = print (IntInf.toString j ^ "\n")
