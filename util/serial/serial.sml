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

structure Serial :> SERIAL =
   struct
      datatype ('a, 'b, 'c) serial = S of {
         align  : word,
         length : int,
         write  : Word8Array.array   * int * int * 'a -> unit,
         readA  : Word8Array.array   * int * int -> 'b,
         readV  : Word8Vector.vector * int * int -> 'b,
         extra  : 'c }
      type ('a, 'b, 'c) t = unit -> ('a, 'b, 'c) serial
      
      datatype ('a, 'b, 'c, 'd) a = A of {
         align  : unit -> word,
         offset : int -> int,
         store  : ((Word8Array.array  * int * int -> unit) -> 'b) -> 'a,
         loadA  : (Word8Array.array   * int * int * 'c) -> 'd,
         loadV  : (Word8Vector.vector * int * int * 'c) -> 'd
      }
      
      val { write=write8,  ... } = word8   ()
      val { write=write16, ... } = word16l ()
      val { write=write32, ... } = word32l ()
      
      val unit    = S o unit
      val word8   = S o word8
      val word16l = S o word16l
      val word16b = S o word16b
      val word32l = S o word32l
      val word32b = S o word32b
      val word64l = S o word64l
      val word64b = S o word64b
      val int8    = S o int8
      val int16l  = S o int16l
      val int16b  = S o int16b
      val int32l  = S o int32l
      val int32b  = S o int32b
      val int64l  = S o int64l
      val int64b  = S o int64b
      val real32l = S o real32l
      val real32b = S o real32b
      val real64l = S o real64l
      val real64b = S o real64b      
      val bool = S o bool

      exception BadAlignment
      fun intinfl l = 
         let
            val () = if l mod 8 = 0 then () else raise BadAlignment
            val () = if l = 0 then raise BadAlignment else ()
            val l = l div 8
         in
            fn () => S
            { align  = 0w7, 
              length = l*8, 
              write  = fn (a, i, j, x) => storeIntInfl (a, (i+j) div 8, l, x),
              readA  = fn (a, i, j)    => loadIntInfAl (a, (i+j) div 8, l),
              readV  = fn (v, i, j)    => loadIntInfVl (v, (i+j) div 8, l),
              extra  = () } 
         end
      
      fun intinfb l =
         let
            val () = if l mod 8 = 0 then () else raise BadAlignment
            val () = if l = 0 then raise BadAlignment else ()
            val l = l div 8
         in
            fn () => S
            { align  = 0w7, 
              length = l*8, 
              write  = fn (a, i, j, x) => storeIntInfb (a, (i+j) div 8, l, x),
              readA  = fn (a, i, j)    => loadIntInfAb (a, (i+j) div 8, l),
              readV  = fn (v, i, j)    => loadIntInfVb (v, (i+j) div 8, l),
              extra  = () } 
         end
      
      fun extra base = 
         let
            val S { extra, ... } = base ()
         in
            extra
         end
      
      fun map { store, load, extra=extraFn } base () = 
         let
            val S { align, length, write, readA, readV, extra } = base ()
         in S {
            align  = align,
            length = length,
            write  = fn (a, i, j, x) => write (a, i, j, store x),
            readA  = fn z => load (readA z),
            readV  = fn z => load (readV z),
            extra  = extraFn extra
         }
         end
      
      (* Unsigned (and unchecked) arithmetic *)
      fun alignTo (i, a) = 
         Word.toIntX (Word.andb (Word.notb a, Word.fromInt i + a))
      fun add (x, y) = Word.toIntX (Word.fromInt x + Word.fromInt y)
      fun sub (x, y) = Word.toIntX (Word.fromInt x - Word.fromInt y)
      fun set (x, y) = Word.andb (Word.fromInt x, y) <> 0w0
      
      (* After folding, the store function should look like this:
       *   finishCb -> arg1 -> arg2 -> ... -> argn -> 'b
       * The first argument is a method to call upon receiving argn.
       *  
       * The finish callback has type:
       *    (Word8Array.array * int * int -> unit) -> 'b
       * The callback receives a write method for writing out arg1..n.
       * The second argument is the offset where the writing begins.
       *)

      (* After folding, the load function should look like this:
       *   Word8Array.array * int * int * result * 
       *     (arg1 -> ... -> argn -> 'a) -> 'a
       * The passed function gets called with the loaded arguments.
       *)
      fun ` (base, A { align=a, offset, store, loadA, loadV }) = A {
         align = fn () =>
            let
               val S { align, ... } = base ()
            in
               Word.max (align, a ())
            end,
         offset = fn off => 
            let
               val S { align, length, ... } = base ()
               val off' = alignTo (off, align)
            in
               offset (add (off', length))
            end,
         store = fn finish => fn x => store (fn writer => finish (fn (a, offset, i) =>
            let
               val S { align, length, write, ... } = base ()
               val offset' = alignTo (offset, align)
               
               (* Fill in padding. Do it using concrete arithmetic involving
                * only offset. This way it is optimized away.
                *)
               val pad = sub (offset', offset)
               val (pad, offset) =
                  if set (pad, 0w1)
                  then (write8 (a, offset, i, 0w0); (sub (pad, 1), add (offset, 1)))
                  else (pad, offset)
               val (pad, offset) =
                  if set (pad, 0w2)
                  then (write16 (a, offset, i, 0w0); (sub (pad, 2), add (offset, 2)))
                  else (pad, offset)
               val _ =
                  if set (pad, 0w4)
                  then (write32 (a, offset, i, 0w0); (sub (pad, 4), add (offset, 4)))
                  else (pad, offset)
               
               (* write the actual value *)
               val () = write (a, offset', i, x)
            in
               writer (a, add (offset', length), i)
            end)),
         loadA = fn (a, offset, i, f) =>
            let
               val S { align, length, readA, ... } = base ()
               val offset' = alignTo (offset, align)
               val x = readA (a, offset', i)
            in
               loadA (a, add (offset', length), i, f x)
            end,
         loadV = fn (v, offset, i, f) =>
            let
               val S { align, length, readV, ... } = base ()
               val offset' = alignTo (offset, align)
               val x = readV (v, offset', i)
            in
               loadV (v, add (offset', length), i, f x)
            end
      }
      val ` = fn x => FoldR.step1 ` x

      (* The start of all compositions *)
      val a = A {
         align  = fn () => 0w0,
         offset = fn i => i,
         store  = fn finish => finish (fn _ => ()),
         loadA  = fn (_, _, _, r) => r,
         loadV  = fn (_, _, _, r) => r
      }
      
      fun aggregate (t, f) =
         let
            fun F (A { align, offset, store, loadA, loadV }) () = S {
               align  = align (),
               length = offset 0,
               write  = fn (a, i, j, x) => f (store (fn cb => cb (a, i, j))) x,
               readA  = fn (a, i, j) => loadA (a, i, j, t),
               readV  = fn (v, i, j) => loadV (v, i, j, t),
               extra  = ()
            }
         in
            FoldR.fold (a, F)
         end
      
      fun vector (base, len) () =
         let
            val S { align, length, write, readA, readV, extra=() } = base ()
         in S {
            align  = align,
            length = len * length,
            write  = fn (a, i, j, v) =>
               let
                  val i = add (i, j)
                  fun f (j, x) = write (a, 0, i+j*length, x)
               in
                  if Vector.length v <> len then raise Subscript else
                  Vector.appi f v
               end,
            readA  = fn (a, i, j) =>
               let
                  val i = add (i, j)
                  fun f j = readA (a, 0, i+j*length)
               in
                  Vector.tabulate (len, f)
               end,
            readV  = fn (v, i, j) =>
               let
                  val i = add (i, j)
                  fun f j = readV (v, 0, i+j*length)
               in
                  Vector.tabulate (len, f)
               end,
            extra  = ()
         }
         end
      
      fun pickle x =
         let
            fun F (A { align, offset, store, loadV, loadA }) = {
               align  = fn () => Word.toInt (align () + 0w1),
               length = fn () => offset 0,
               writeVector = fn cb => store (fn writer =>
                   cb (MakeVector.word8 (offset 0, fn a => writer (a, 0, 0)))),
               parseVector = fn (s, f) => 
                  let
                     val (v, i, n) = Word8VectorSlice.base s
                     val d = Word.andb (Word.fromInt i, align ())
                  in
                     if d <> 0w0 then raise BadAlignment else
                     if n < offset 0 then raise Subscript else
                     loadV (v, 0, i, f)
                  end,
               writeSlice = fn (s, r) => store (fn writer =>
                  let
                     val (a, i, n) = Word8ArraySlice.base s
                     val d = Word.andb (Word.fromInt i, align ())
                     val () = if d <> 0w0 then raise BadAlignment else ()
                     val () = if n < offset 0 then raise Subscript else ()
                     val () = writer (a, 0, i)
                  in
                     r
                  end),
               parseSlice = fn (s, f) => 
                  let
                     val (a, i, n) = Word8ArraySlice.base s
                     val d = Word.andb (Word.fromInt i, align ())
                  in
                     if d <> 0w0 then raise BadAlignment else
                     if n < offset 0 then raise Subscript else
                     loadA (a, 0, i, f)
                  end
            }
         in
            FoldR.fold (a, F) x
         end
      
      fun methods ty =
         let
            val S { align, length, write, readA, readV, ... } = ty ()
         in {
            align = Word.toInt (align + 0w1),
            length = length,
            toVector = fn x =>
               MakeVector.word8 (length, fn a => write (a, 0, 0, x)),
            fromVector = fn v =>
               if Word8Vector.length v < length then raise Subscript else 
               readV (v, 0, 0),
            writeSlice = fn (s, x) =>
               let
                  val (a, i, n) = Word8ArraySlice.base s
                  val d = Word.andb (Word.fromInt i, align)
                  val () = if d <> 0w0 then raise BadAlignment else ()
                  val () = if n < length then raise Subscript else ()
               in
                  write (a, 0, i, x)
               end,
            parseSlice = fn s =>
               let
                  val (a, i, n) = Word8ArraySlice.base s
                  val d = Word.andb (Word.fromInt i, align)
                  val () = if d <> 0w0 then raise BadAlignment else ()
                  val () = if n < length then raise Subscript else ()
               in
                  readA (a, 0, i)
               end,
            parseVector = fn s =>
               let
                  val (v, i, n) = Word8VectorSlice.base s
                  val d = Word.andb (Word.fromInt i, align)
                  val () = if d <> 0w0 then raise BadAlignment else ()
                  val () = if n < length then raise Subscript else ()
               in
                  readV (v, 0, i)
               end
         } end
   end
