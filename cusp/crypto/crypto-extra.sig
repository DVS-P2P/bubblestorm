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

signature CRYPTO_EXTRA =
   sig
      include CRYPTO
      
      type full_negotiation = {
         macLen   : int,
         loopback : bool,
         encipher: LargeInt.int -> {
           f   : Word8ArraySlice.slice -> unit,
           mac : Word8ArraySlice.slice -> Word8Vector.vector
         },
         decipher : LargeInt.int -> {
           f   : Word8ArraySlice.slice -> unit,
           mac : Word8ArraySlice.slice -> Word8Vector.vector
         }
      }
      
      type half_negotiation = {
         A : Word8Vector.vector,
         X : Word8Vector.vector,
         symmetric : { suite : Suite.Symmetric.suite,
                       B : Word8ArraySlice.slice, 
                       Y : Word8ArraySlice.slice } -> full_negotiation
      }
      
      val publickeyInfo : Suite.PublicKey.suite -> {
         publicLength    : int,
         ephemeralLength : int,
         parse : { B : Word8ArraySlice.slice } -> PublicKey.t
      }
      
      val publickey : {
         suite   : Suite.PublicKey.suite,
         key     : PrivateKey.t,
         entropy : int -> Word8Vector.vector
      } -> half_negotiation
   end
