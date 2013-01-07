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

structure WordToString =
   struct
      local
         val hex = "0123456789ABCDEF"
         fun make (f, l) w =
            CharVector.tabulate (l, 
            fn i => CharVector.sub (hex, f (w, Word.fromInt ((l-1-i) * 4))))
         fun c f x y = f (x, y)
      in
         val from8  = make (Word8.toInt o c Word8.andb 0wxf o Word8.>>, 2)
         val from16 = make (Word16.toInt o c Word16.andb 0wxf o Word16.>>, 4)
         val from32 = make (Word32.toInt o c Word32.andb 0wxf o Word32.>>, 8)
         val from64 = make (Word64.toInt o c Word64.andb 0wxf o Word64.>>, 16)
         
         fun fromBytes b =
            let
               val len = Word8Vector.length b
               fun f i = 
                  let
                     val w = Word8Vector.sub (b, i div 2)
                  in
                     if i mod 2 = 1
                     then CharVector.sub (hex, Word8.toInt (Word8.andb (w, 0wxf)))
                     else CharVector.sub (hex, Word8.toInt (Word8.>>   (w, 0w4)))
                  end
            in
               CharVector.tabulate (len*2, f)
            end
         
         fun toBytes s =
            let
               val len = String.size s
               fun cvt (c, b, off) = Char.ord c - Char.ord b + off
               fun fromHex c =
                  if #"0" <= c andalso c <= #"9" then cvt (c, #"0", 0) else
                  if #"A" <= c andalso c <= #"F" then cvt (c, #"A", 10) else
                  if #"a" <= c andalso c <= #"f" then cvt (c, #"a", 10) else
                  raise Domain
               fun f i =
                  let
                     val cvt = Word8.fromInt o fromHex
                     val high = String.sub (s, i*2)
                     val low  = String.sub (s, i*2 + 1)
                  in
                     Word8.orb (Word8.<< (cvt high, 0w4), cvt low)
                  end
            in
               SOME (Word8Vector.tabulate (len div 2, f))
               handle Domain => NONE
            end
      end
   end

(*
val x = Byte.stringToBytes "Hello world!"
val y = WordToString.fromBytes x
val () = print (y ^ "\n")
val z = valOf (WordToString.toBytes y)
val () = print (Byte.bytesToString z ^ "\n")
val f = getOpt (WordToString.toBytes "AG", z)
val () = print (Byte.bytesToString f ^ "\n")
*)
