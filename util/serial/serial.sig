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

(*
signature SERIAL =
   sig
      type 'a t
      
      val unit : unit t
      val word8  : word8 t      
      
      val toVector : 'a t * 'a -> vector
      val fromVector : 'a t * vector -> 'a
   end
*)

signature SERIAL =
   sig
      (* The serializable type has three parameters:
       *   'stored is the type of variable it stores into a stream
       *   'parsed is the type of variable it parses out of a stream
       *   'extra is an ignored bit of user-defined associated data
       *)
      type ('stored, 'parsed, 'extra) serial
      type ('stored, 'parsed, 'extra) t = 
         unit -> ('stored, 'parsed, 'extra) serial
      
      (* Serialize fundamental types *)
      val unit : (unit, unit, unit) t
      
      val word8   : (Word8.word,  Word8.word,  unit) t
      val word16l : (Word16.word, Word16.word, unit) t
      val word16b : (Word16.word, Word16.word, unit) t
      val word32l : (Word32.word, Word32.word, unit) t
      val word32b : (Word32.word, Word32.word, unit) t
      val word64l : (Word64.word, Word64.word, unit) t
      val word64b : (Word64.word, Word64.word, unit) t
      
      val int8   : (Int8.int,  Int8.int,  unit) t
      val int16l : (Int16.int, Int16.int, unit) t
      val int16b : (Int16.int, Int16.int, unit) t
      val int32l : (Int32.int, Int32.int, unit) t
      val int32b : (Int32.int, Int32.int, unit) t
      val int64l : (Int64.int, Int64.int, unit) t
      val int64b : (Int64.int, Int64.int, unit) t
      
      val real32l : (Real32.real, Real32.real, unit) t
      val real32b : (Real32.real, Real32.real, unit) t
      val real64l : (Real64.real, Real64.real, unit) t
      val real64b : (Real64.real, Real64.real, unit) t      

      val bool    : (bool,  bool,  unit) t

      val vector  : ('a, 'b, unit) t * int -> ('a vector, 'b vector, unit) t
      val intinfl : int -> (IntInf.int, IntInf.int, unit) t
      val intinfb : int -> (IntInf.int, IntInf.int, unit) t

      (* Access the user-defined associated data *)
      val extra : ('a, 'b, 'extra) t -> 'extra
      
      (* Convert a serializer for an existing type into a derived type.
       * You have the opportunity here to add 'extra' data.
       *)
      val map : {
         store : 'a -> 'd,
         load  : 'b -> 'e,
         extra : 'c -> 'f } -> ('d, 'b, 'c) t -> ('a, 'e, 'f) t
      
      (* This type is the hidden accumulator state used when folding *)
      type ('a, 'b, 'c, 'd) a
      
      (* To use aggregate, consider the following example:
       *   val x = aggregate tuple3 `int32 `word8 `real32 $
       * this creates a new serializer for the type int32 * word8 * real32.
       *   fun to a b c = { a=a, b=b, c=c }
       *   fun from t { a, b, c } = t a b c
       *   val y = aggregate (to, from) `word8 `x `word16 $
       * will create a serializer for type { a : word8, b : x, c : word16 }
       *
       * If you invoke pickle like this:
       *   pickleVector `int32 `x $
       * you get the following:
       *   length = 16 (3 words + 1 byte + 3 padding bytes)
       *   writer : (Word8Vector.vector -> 'a) 
       *            -> int32 -> int32 * word8 * real32 -> 'a
       *   parser : Word8Vector.vector * (int32 -> int32 * word8* real32 -> 'a)
       *            -> 'a
       * 
       *   The writer method takes a callback and then the parameters defined
       *   in the pickle statement. Once the last parameter has been provided,
       *   they are all serialized into a vector which is handed off to the 
       *   callback. Whatever the callback returns, writer returns.
       *
       *   The parser function takes an array and a function. The contents of
       *   the array are parsed and handed off to the function, whose result
       *   will also be the result of parser.
       *)
      val ` : 
         (('a, 'b, 'c) t,
          ('d, 'e, 'f, 'g) a, 
          ('a -> 'd, 'e, 'b -> 'f, 'g) a, 
          'h, 'i, 'j) FoldR.step1
      
      val aggregate : 
         'a * ('b -> 'c -> unit) -> 
         ((unit, unit, 'd, 'd) a, 
          ('b,   unit, 'a, 'e) a, 
          ('c, 'e, unit) t, 'f) FoldR.fold
      
      exception BadAlignment (* raised by (write/parse)Slice *)
      val methods : ('a, 'b, 'e) t -> {
         align      : int,
         length     : int,
         toVector   : 'a -> Word8Vector.vector,
         fromVector : Word8Vector.vector -> 'b,
         writeSlice : Word8ArraySlice.slice * 'a -> unit,
         parseSlice : Word8ArraySlice.slice -> 'b,
         parseVector: Word8VectorSlice.slice -> 'b
      }
      
      (* Used to implement derived serialization methods (like RPC) *)
      val pickle : (('a, 'a, 'b, 'b) a, ('c, 'a, 'd, 'b) a, {
         align  : unit -> int,
         length : unit -> int,
         writeVector : (Word8Vector.vector -> 'a) -> 'c, 
         writeSlice  : Word8ArraySlice.slice  * 'a -> 'c,
         parseVector : Word8VectorSlice.slice * 'd -> 'b,
         parseSlice  : Word8ArraySlice.slice  * 'd -> 'b 
      }, 'e) FoldR.fold
   end
