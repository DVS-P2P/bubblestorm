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

structure Crypto =
   struct
      open Crypto
      
      structure Curve25519HMQV = 
         HMQV(structure CyclicGroup = Curve25519
              structure Compressor = WhirlpoolRaw)
      
      local
         val keyLength = Curve25519.length
         open Serial
         val { fromVector=keyFromVector, ... } = methods (intinfl keyLength)
         val { length, toVector, parseSlice, ... } = methods Curve25519.t
      in
         val curve25519Info = {
            publicLength    = length,
            ephemeralLength = length,
            parse = fn { B } => (Suite.PublicKey.curve25519, Word8ArraySlice.vector B)
         }
      
         fun curve25519 ((_, (a, A)), entropy) =
            let
               val x = keyFromVector (entropy keyLength)
               val x = Curve25519.clamp x
               val X = Curve25519.power (Curve25519.generator (), x)
            in {
               A = toVector A,
               X = toVector X,
               symmetric = fn { suite, B, Y } =>
                  let
                     val B = parseSlice B
                     val Y = parseSlice Y
                     val (k1, k2) = 
                        Curve25519HMQV.compute 
                        { length = Crypto.symmetricLength suite, 
                          a=a, x=x, A=A, B=B, X=X, Y=Y }
                  in
                     Crypto.symmetric (suite, k1, k2)
                  end
               }
            end
         end
      
      local
         open Serial 
         (* Write a 64-bit value 4 times to make it "256-bit encryption" *)
         fun t a _ _ _ = a
         fun f x a = x a a a a
         val fatKey = aggregate (t, f) `word64l `word64l `word64l `word64l $
         val { length, toVector, fromVector, parseSlice, ... } = methods fatKey
      in
         val xorInfo = {
            publicLength    = length,
            ephemeralLength = length,
            parse = fn { B } => (Suite.PublicKey.xor, Word8ArraySlice.vector B)
         }
         
         fun xor ((a, _), entropy) =
            let
               val A = toVector a
               val X = entropy length
               val x = fromVector X
            in {
               A = A,
               X = X,
               symmetric = fn { suite, B, Y } =>
                  let
                     val outlen = Crypto.symmetricLength suite
                     val b = parseSlice B
                     val y = parseSlice Y
                     val k1 = Word64.xorb (a, y)
                     val k2 = Word64.xorb (b, x)
                     val K1 = toVector k1
                     val K2 = toVector k2
                     
                     fun fix k =
                        if outlen < length then
                           let
                              open Word8VectorSlice
                              val s = slice (k, 0, SOME outlen)
                           in
                              vector s
                           end
                        else if outlen > length then
                           let
                              val x = Word8Vector.tabulate (outlen-length, 
                                                            fn _ => 0w0)
                           in
                              Word8Vector.concat [ k, x ]
                           end
                        else
                           k
                  in 
                     Crypto.symmetric (suite, fix K1, fix K2)
                  end
               }
            end
      end
      
      type half_negotiation = {
         A : Word8Vector.vector,
         X : Word8Vector.vector,
         symmetric : { suite : Suite.Symmetric.suite,
                       B : Word8ArraySlice.slice, 
                       Y : Word8ArraySlice.slice } -> Crypto.full_negotiation
      }
      
      fun publickeyInfo suite =
         if suite = Suite.PublicKey.curve25519 then curve25519Info else
         if suite = Suite.PublicKey.xor        then xorInfo else
         raise Fail "info for non-existant public-key suite requested"

      fun publickey { key, suite, entropy } =
         if suite = Suite.PublicKey.curve25519 then curve25519 (key, entropy) else
         if suite = Suite.PublicKey.xor        then xor        (key, entropy) else
         raise Fail "methods for non-existant public-key suite requested"
   end

structure Crypto : CRYPTO_EXTRA = Crypto
