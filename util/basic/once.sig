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

(* The idea of ONCE is that it can provide a "global variable" that is
 * thread-safe. You can go:
 *   val myBuffer = Once.new (fn () => Word8ArrayTabulate (256, fn _ => 0w0))
 * Then make a function which uses this temporary buffer:
 *   fun doWork x = Once.get (myBuffer, fn buf => ... work with buf ...)
 *
 * We provide a OncePerThread and OncePerEntry. OncePerEntry is needed
 * if the function doWork might be called recursively and need two values.
 *)
signature ONCE =
   sig
      type 'a t
      
      val new: (unit -> 'a) -> 'a t
      val get: 'a t * ('a -> 'b) -> 'b
   end
