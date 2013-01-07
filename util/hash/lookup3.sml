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

structure Lookup3 : HASH_PRIMITIVE =
   struct
      local
         open Word32
         val rol = MLton.Word32.rol
         infix 7 xorb rol
      in
         (* mix -- mix 3 32-bit values reversibly.

           This is reversible, so any information in (a,b,c) before mix() is
           still in (a,b,c) after mix().
         
           If four pairs of (a,b,c) inputs are run through mix(), or through
           mix() in reverse, there are at least 32 bits of the output that
           are sometimes the same for one pair and different for another pair.
           This was tested for:
           * pairs that differed by one bit, by two bits, in any combination
             of top bits of (a,b,c), or in any combination of bottom bits of
             (a,b,c).
           * "differ" is defined as +, -, ^, or ~^.  For + and -, I transformed
             the output delta to a Gray code (a^(a>>1)) so a string of 1's (as
             is commonly produced by subtraction) look like a single 1-bit
             difference.
           * the base values were pseudorandom, all zero but one bit set, or
             all zero plus a counter that starts at zero.
         
           Some k values for my "a-=c; a^=rot(c,k); c+=b;" arrangement that
           satisfy this are
               4  6  8 16 19  4
               9 15  3 18 27 15
              14  9  3  7 17  3
           Well, "9 15 3 18 27 15" didn't quite get 32 bits diffing
           for "differ" defined as + with a one-bit base and a two-bit delta.  I
           used http://burtleburtle.net/bob/hash/avalanche.html to choose
           the operations, constants, and arrangements of the variables.
         
           This does not achieve avalanche.  There are input bits of (a,b,c)
           that fail to affect some output bits of (a,b,c), especially of a.  The
           most thoroughly mixed value is c, but it doesn't really even achieve
           avalanche in c.
         
           This allows some parallelism.  Read-after-writes are good at doubling
           the number of bits affected, so the goal of mixing pulls in the opposite
           direction as the goal of parallelism.  I did what I could.  Rotates
           seem to cost as much as shifts on every machine I could lay my hands
           on, and rotates are much kinder to the top and bottom bits, so I used
           rotates.
         *)
            
         fun mix (a, b, c) =
            let
               val (a, c) = ((a - c) xorb (c rol 0w4),  c + b)
               val (b, a) = ((b - a) xorb (a rol 0w6),  a + c)
               val (c, b) = ((c - b) xorb (b rol 0w8),  b + a)
               val (a, c) = ((a - c) xorb (c rol 0w16), c + b)
               val (b, a) = ((b - a) xorb (a rol 0w19), a + c)
               val (c, b) = ((c - b) xorb (b rol 0w4),  b + a)
            in
               (a, b, c)
            end
            
            (* final -- final mixing of 3 32-bit values (a,b,c) into c

              Pairs of (a,b,c) values differing in only a few bits will usually
              produce values of c that look totally different.  This was tested for
              * pairs that differed by one bit, by two bits, in any combination
                of top bits of (a,b,c), or in any combination of bottom bits of
                (a,b,c).
              * "differ" is defined as +, -, ^, or ~^.  For + and -, I transformed
                the output delta to a Gray code (a^(a>>1)) so a string of 1's (as
                is commonly produced by subtraction) look like a single 1-bit
                difference.
              * the base values were pseudorandom, all zero but one bit set, or
                all zero plus a counter that starts at zero.
            
              These constants passed:
               14 11 25 16 4 14 24
               12 14 25 16 4 14 24
              and these came close:
                4  8 15 26 3 22 24
               10  8 15 26 3 22 24
               11  8 15 26 3 22 24
            *)
         fun final (a, b, c) =
            let
               val c = (c xorb b) - (b rol 0w14)
               val a = (a xorb c) - (c rol 0w11)
               val b = (b xorb a) - (a rol 0w25)
               val c = (c xorb b) - (b rol 0w16)
               val a = (a xorb c) - (c rol 0w4)
               val b = (b xorb a) - (a rol 0w14)
               val c = (c xorb b) - (b rol 0w24)
            in
               (b, c)
            end
      end
      
      type state = Word32.word * Word32.word * Word32.word
      type initial = Word32.word
      type final = Word32.word * Word32.word
      
      fun start x = Hash.S ((x, x, x), step1)
      and step1 ((a, b, c), w) = Hash.S ((a + w, b, c), step2)
      and step2 ((a, b, c), w) = Hash.S ((a, b + w, c), step3)
      and step3 ((a, b, c), w) = Hash.S (mix (a, b, c + w), step1)
      
      val stop = final
   end

structure Lookup3 = HashAlgorithm(Lookup3)
