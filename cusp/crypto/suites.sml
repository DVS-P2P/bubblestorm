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

signature SYMMETRIC_SUITE_SET =
   sig
      include SUITE_SET
      
      val crc32 : suite
      val poly1305aes : suite
   end
   
signature PUBLICKEY_SUITE_SET =
   sig
      include SUITE_SET
      
      val xor : suite
      val curve25519 : suite
   end
   
local
   structure SuiteSet =
      struct
         type set = Word16.word
         type suite = Word16.word
         
         val intersect = Word16.andb
         val union     = Word16.orb
         
         fun subtract (a, b) = Word16.andb (a, Word16.notb b)
         fun isEmpty a = a = (0w0:Word16.word)
         
         fun contains (a, b) = Word16.andb (a, b) <> 0w0
         fun element x = x
         
         fun iterator 16 _ = Iterator.EOF
           | iterator i  x =
            let
               val bit = Word16.<< (0w1, Word.fromInt i)
               fun next () = iterator (i+1) x
            in
               if contains (x, bit)
               then Iterator.VALUE (bit, next)
               else Iterator.SKIP next
            end
         val iterator = iterator 0
         
         fun fromMask x = x
         fun toMask x = x
         
         fun fromValue x = x
         fun toValue x = x
         
         fun cheapest cost mask = 
            let
               fun best (x, (y, yscore)) =
                  let
                     val xscore = cost x
                  in
                     if Real32.< (xscore, yscore)
                     then (x, xscore)
                     else (y, yscore)
                  end
               
               val result = 
                  #1 (Iterator.fold best (0w0, 10e6) (iterator mask))
            in
               if result = 0w0 then NONE else SOME result
            end
      end
in
   structure Suite =
      struct
         structure Symmetric :> SYMMETRIC_SUITE_SET =
            struct
               open SuiteSet
               
               fun name 0w1 = "crc32"
                 | name 0w2 = "poly1305+aes"
                 | name (_:suite) = raise Fail "bad symmetric suite"
               
               fun cost 0w1 = 0.5
                 | cost 0w2 = 1.0
                 | cost (_:suite) = raise Fail "bad symmetric suite"
               
               val cheapest = cheapest cost
               
               val all : set = 0w3
               val defaults : set = 0w2
               
               val crc32 : suite = 0w1
               val poly1305aes : suite = 0w2
            end

         structure PublicKey :> PUBLICKEY_SUITE_SET =
            struct
               open SuiteSet
               
               fun name 0w1 = "xor"
                 | name 0w2 = "curve25519+whirlpool"
                 | name (_:suite) = raise Fail "bad public-key suite"
               
               fun cost 0w1 = 0.1
                 | cost 0w2 = 1.0
                 | cost (_:suite) = raise Fail "bad public-key suite"
                
               val cheapest = cheapest cost
               
               val all : set = 0w3
               val defaults : set = 0w2
               
               val xor : suite = 0w1
               val curve25519 : suite = 0w2
            end
      end
end
