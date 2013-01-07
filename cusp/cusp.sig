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

signature CUSP =
   sig
      (* This exception is thrown by read and write on streams *)
      exception RaceCondition
      (* Thrown when out of listen ports or using a taken fixed port *)
      exception AddressInUse
      
      structure Address : ADDRESS
      
      structure Suite  : SUITE
      structure Crypto : CRYPTO where type PublicKey.suite = Suite.PublicKey.suite
      structure InStream : IN_STREAM
      structure OutStream : OUT_STREAM
      structure BufferedOutStream : BUFFERED_OUT_STREAM
         where type OutStream.t = OutStream.t
      
      structure Host : HOST
         where type address = Address.t
         where type instream = InStream.t
         where type outstream = OutStream.t
         where type publickey = Crypto.PublicKey.t
      structure EndPoint : END_POINT
         where type address = Address.t
         where type host = Host.t
         where type instream = InStream.t
         where type outstream = OutStream.t
         where type publickey = Crypto.PublicKey.t
         where type privatekey = Crypto.PrivateKey.t
         where type publickey_set = Suite.PublicKey.set
         where type symmetric_set = Suite.Symmetric.set
   end
