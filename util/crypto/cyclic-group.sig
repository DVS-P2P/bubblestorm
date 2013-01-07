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

(* All Diffie-Hellman key exchange protocols use a private exponent.
 * This exponent is used in some group where discrete logarithms are hard.
 * Public keys are elements of the group = well-known-generator ** secret.
 * Shared secrets are similarly = well-known-generator ** (secret1*secret2).
 *)
signature CYCLIC_GROUP =
   sig
      include SERIALIZABLE
      
      exception BadElement (* group element not formed from generator *)
      val generator  : unit -> t
      val multiply   : t * t -> t
      val power      : t * LargeInt.int -> t
      
      (* This is just like power, but specifies an upper bound on the input
       * bits. Using this information, fixedPower is constant time and thus
       * immune to timing attacks. The simple 'power' function counts the
       * bits actually used by the exponent, making it vulnerable.
       *)
      val fixedPower : t * LargeInt.int * int -> t
      
      (* Make a (length-byte) exponent into a valid private-key *)
      val clamp     : LargeInt.int -> LargeInt.int
      val length    : int
   end
