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

structure Hash :> HASH =
   struct
      datatype 'b state = S of 'b * ('b * Word32.word -> 'b state)
      type ('a, 'b) function = 'a -> 'b state -> 'b state
      
      fun word32 w (S (state, step)) = step (state, w)
      fun word8  w = word32 (Word32.fromLarge (Word8.toLarge  w))
      fun word16 w = word32 (Word32.fromLarge (Word16.toLarge w))
      fun word64 w = 
         word32 (Word32.fromLarge (Word64.toLarge w)) o
         word32 (Word32.fromLarge (Word64.toLarge (Word64.>> (w, 0w32))))
      
      fun word x = 
         case Word.wordSize of
            8  => (word32 o Word32.fromLarge o Word.toLarge) x
          | 16 => (word32 o Word32.fromLarge o Word.toLarge) x
          | 32 => (word32 o Word32.fromLarge o Word.toLarge) x
          | 64 => (word64 o Word64.fromLarge o Word.toLarge) x
          | _ => raise Fail "Unsupported Word.wordSize"
      
      (* Abuse knowledge that Int.precision >= 32 bit *)
      fun int8  x = (word32 o Word32.fromInt o Int8.toInt)  x
      fun int16 x = (word32 o Word32.fromInt o Int16.toInt) x
      fun int32 x = (word32 o Word32.fromInt o Int32.toInt) x
      fun int64 x = (word64 o Word64.fromLargeInt o Int64.toLarge) x
      (* !!! make int64 faster *)
      
      fun int x = 
         case Int.precision of 
            (SOME 8)  => (word32 o Word32.fromInt) x 
          | (SOME 16) => (word32 o Word32.fromInt) x
          | (SOME 32) => (word32 o Word32.fromInt) x 
          | (SOME 64) => (word64 o Word64.fromInt) x
          | _ => raise Fail "Unsupported Int.precision"
      
      val buffer = 
         OncePerThread.new (fn () => Word8Array.tabulate (8, fn _ => 0w0))
      
      fun real32 r =
         OncePerThread.get 
         (buffer,
          fn buffer =>
            let
               val () = PackReal32Little.update (buffer, 0, r)
            in
               (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 0)
            end)
      
      fun real64 r =
         OncePerThread.get 
         (buffer,
          fn buffer =>
            let
               val () = PackReal64Little.update (buffer, 0, r)
            in
               (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 0) o
               (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 1)
            end)
      
      fun real r =
         OncePerThread.get 
         (buffer,
          fn buffer =>
            let
               val () = PackRealLittle.update (buffer, 0, r)
            in
               case PackRealLittle.bytesPerElem of
                  4 => (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 0)
                | 8 => (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 0) o
                       (word32 o Word32.fromLarge o PackWord32Little.subArr) (buffer, 1)
                | _ => raise Fail "Unsupported Real precision"
            end)
      
      fun bool true  = word32 0w1
        | bool false = word32 0w0
      
      fun word8vector (v,i) state =
         let
            val << = Word32.<<
            val orb = Word32.orb
            infix 6 << 
            infix 5 orb
            val j = i * 4
            fun sub32 (v,k) = 
               (Word32.fromLarge o Word8.toLarge o Word8Vector.sub) (v,k+j)
         in 
            case Word8Vector.length v - j of
               0 => state
             | 1 => word32 (sub32(v,0)) state
             | 2 => word32 (sub32(v,0) orb sub32(v,1)<<0w8) state
             | 3 => word32 (sub32(v,0) orb sub32(v,1)<<0w8 orb sub32(v,2)<<0w16) state
             | _ => word8vector (v, i+1)
                    ((word32 o Word32.fromLarge o PackWord32Little.subVec) 
                     (v, i) state)
      end
      val word8vector = fn v => word8vector (v,0)
            
      fun string s = word8vector (Byte.stringToBytes s)
      fun iterator f i state =
         Iterator.fold (fn (x, s) => f x s) state i
   end
