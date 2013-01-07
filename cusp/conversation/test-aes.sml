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

fun handler exn =
   Log.log (Log.WARNING, "conversation/test/endpoint", 
            fn () => General.exnMessage exn)
  
fun endpoint port = 
   CUSP.EndPoint.new { 
      port    = port,
      handler = handler,
      entropy = Entropy.get,
      key     = CUSP.Crypto.PrivateKey.new { entropy = Entropy.get },
      options = SOME {
         encrypt   = true,
         publickey = CUSP.Suite.PublicKey.defaults,
         symmetric = CUSP.Suite.Symmetric.defaults
      } }

