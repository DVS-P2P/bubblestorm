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

signature COMPRESSOR_RAW =
   sig
      type state
      
      val inputLength  : int
      val outputLength : int
      
      (* This is the format used to append the length of the hash *)
      val length : (Word64.word, Word64.word, unit) Serial.t
      
      (* The compresed array/vector must have inputLength *)
      (* The finish array must have outputLength *)
      val initial   : state
      val compressA : state * Word8ArraySlice.slice  -> state
      val compressV : state * Word8VectorSlice.slice -> state
      val finish    : state * Word8ArraySlice.slice  -> unit
   end

signature COMPRESSOR_COOKED =
   sig
      type state
      
      (* These methods allow any sized array/vectors *)
      val initial   : unit -> state
      val compressA : state * Word8ArraySlice.slice  -> state
      val compressV : state * Word8VectorSlice.slice -> state
      val finish    : state -> Word8Vector.vector
      
      (* Convenience method *)
      val hash : Word8Vector.vector -> Word8Vector.vector
   end
