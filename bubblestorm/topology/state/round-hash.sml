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

(* Our goal is to ensure that if the first two values are distinct 
 * and the rest is identical, then the output is distinct.
 * Thus, if you hash (IP, port, round) you are guaranteed that there is
 * exactly ONE winner for fish size.
 *)
structure RoundHash : HASH_PRIMITIVE =
   struct
      open Word64
      
      type initial = unit
      type state = Word64.word
      type final = Word64.word
      
      (* Must be an invertible function *)
      fun mix w =
         let
            val w = w * 0w2454158371928412325
            val w = orb (<< (w, 0w32), >> (w, 0w32))
            val w = w * 0w7189172858971738597
         in
            w
         end
      
      val big = Word64.fromLarge o Word32.toLarge
      
      fun start () = Hash.S (0w0, step1)
      and step0 (w, a) = step1 (mix w, a)
      and step1 (w, a) = Hash.S (xorb (w, big a), step2)
      and step2 (w, b) = Hash.S (xorb (w, << (big b, 0w32)), step0)
      
      val stop = mix
   end
structure RoundHash = HashAlgorithm(RoundHash)
