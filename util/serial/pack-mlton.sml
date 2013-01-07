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

functor BasisPackWord(structure Pack : PACK_WORD
                      structure Word : WORD) : PACK =
   struct
      type t = Word.word
      fun subArr (a, i) = Word.fromLarge (Pack.subArr (a, i))
      fun subVec (a, i) = Word.fromLarge (Pack.subVec (a, i))
      fun update (a, i, x) = Pack.update (a, i, Word.toLarge x)
   end

structure PackWord8 : PACK =
   struct
      type t = Word8.word
      val subArr : Word8Array.array   * int -> t = Unsafe.Word8Array.sub
      val subVec : Word8Vector.vector * int -> t = Unsafe.Word8Vector.sub
      val update = Unsafe.Word8Array.update
   end

structure PackWord16L = 
   BasisPackWord(structure Pack = Unsafe.PackWord16Little
                 structure Word = Word16)
structure PackWord32L = 
   BasisPackWord(structure Pack = Unsafe.PackWord32Little
                 structure Word = Word32)
structure PackWord64L = 
   BasisPackWord(structure Pack = Unsafe.PackWord64Little
                 structure Word = Word64)

structure PackWord16B = 
   BasisPackWord(structure Pack = Unsafe.PackWord16Big
                 structure Word = Word16)
structure PackWord32B = 
   BasisPackWord(structure Pack = Unsafe.PackWord32Big
                 structure Word = Word32)
structure PackWord64B = 
   BasisPackWord(structure Pack = Unsafe.PackWord64Big
                 structure Word = Word64)

functor BasisPackInt(structure Word : WORD
                     structure Pack : PACK where type t = Word.word
                     structure Integer : INTEGER) : PACK =
   struct
      type t = Integer.int
      fun subArr (a, i) = Integer.fromLarge (Word.toLargeIntX (Pack.subArr (a, i)))
      fun subVec (a, i) = Integer.fromLarge (Word.toLargeIntX (Pack.subVec (a, i)))
      fun update (a, i, x) = Pack.update (a, i, Word.fromLargeInt (Integer.toLarge x))
   end

structure PackInt8 : PACK = 
   struct
      type t = Int8.int
      val subArr : Word8Array.array   * int -> t = Int8.fromInt o Word8.toIntX o Unsafe.Word8Array.sub
      val subVec : Word8Vector.vector * int -> t = Int8.fromInt o Word8.toIntX o Unsafe.Word8Vector.sub
      fun update (a, i, x) = Unsafe.Word8Array.update (a, i, Word8.fromInt (Int8.toInt x))
   end

structure PackInt16L = 
   BasisPackInt(structure Pack = PackWord16L
                structure Word = Word16
                structure Integer = Int16)
structure PackInt32L =
   BasisPackInt(structure Pack = PackWord32L
                structure Word = Word32
                structure Integer = Int32)
structure PackInt64L = 
   BasisPackInt(structure Pack = PackWord64L
                structure Word = Word64
                structure Integer = Int64)

structure PackInt16B = 
   BasisPackInt(structure Pack = PackWord16B
                structure Word = Word16
                structure Integer = Int16)
structure PackInt32B =
   BasisPackInt(structure Pack = PackWord32B
                structure Word = Word32
                structure Integer = Int32)
structure PackInt64B = 
   BasisPackInt(structure Pack = PackWord64B
                structure Word = Word64
                structure Integer = Int64)

functor BasisPackReal(Pack : PACK_REAL) : PACK =
   struct
      type t = Pack.real
      open Pack
   end

structure PackReal32L = BasisPackReal(Unsafe.PackReal32Little)
structure PackReal64L = BasisPackReal(Unsafe.PackReal64Little)

structure PackReal32B = BasisPackReal(Unsafe.PackReal32Big)
structure PackReal64B = BasisPackReal(Unsafe.PackReal64Big)

val z = MLton.IntInf.BigWord.fromInt 0
fun loadIntInfl f (a, i, l) =
   let
      val off = i - 1
      fun get 0 = z
        | get j = MLton.IntInf.BigWord.fromLarge (f (a, off+j))
      fun trim 2 = 2
        | trim i = if get (i-1) = z then trim (i-1) else i
      val v = Vector.tabulate (trim (l+1), get)
   in
      valOf (MLton.IntInf.fromRep (MLton.IntInf.Big v))
   end

fun loadIntInfb f (a, i, l) =
   let
      val off = l + i
      fun get 0 = z
        | get j = MLton.IntInf.BigWord.fromLarge (f (a, off-j))
      fun trim 2 = 2
        | trim i = if get (i-1) = z then trim (i-1) else i
      val v = Vector.tabulate (trim (l+1), get)
   in
      valOf (MLton.IntInf.fromRep (MLton.IntInf.Big v))
   end

fun cvtRep (MLton.IntInf.Big v) = v
  | cvtRep (MLton.IntInf.Small i) =
   let
      val w = 
         MLton.IntInf.BigWord.fromLargeInt 
         (MLton.IntInf.SmallInt.toLarge i)
   in
      Vector.tabulate (2, fn 1 => w | _ => z)
   end

fun storeIntInfl f (a, i, l, x) =
   let
      val l = l+1
      val off = i - 1
      fun put (0, _) = ()
        | put (j, v) = f (a, off+j, MLton.IntInf.BigWord.toLarge v)
      val v = cvtRep (MLton.IntInf.rep x)
      val vs = 
         if Vector.length v > l
         then VectorSlice.slice (v, 0, SOME l)
         else VectorSlice.full v
      val () = VectorSlice.appi put vs
      fun tail j = if j >= l then () else (f (a, off+j, 0w0); tail (j+1))
   in
      tail (Vector.length v)
   end

fun storeIntInfb f (a, i, l, x) =
   let
      val off = i + l
      val l = l+1
      fun put (0, _) = ()
        | put (j, v) = f (a, off-j, MLton.IntInf.BigWord.toLarge v)
      val v = cvtRep (MLton.IntInf.rep x)
      val vs = 
         if Vector.length v > l
         then VectorSlice.slice (v, 0, SOME l)
         else VectorSlice.full v
      val () = VectorSlice.appi put vs
      fun tail j = if j >= l then () else (f (a, off-j, 0w0); tail (j+1))
   in
      tail (Vector.length v)
   end

fun i32 (a, i, l) = (a, i*2, l*2)
fun i64 (a, i, l) = (a, i,   l)
val loadIntInfAl =
   case MLton.IntInf.BigWord.wordSize of
      64 => loadIntInfl Unsafe.PackWord64Little.subArr o i64
    | 32 => loadIntInfl Unsafe.PackWord32Little.subArr o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"
val loadIntInfVl =
   case MLton.IntInf.BigWord.wordSize of
      64 => loadIntInfl Unsafe.PackWord64Little.subVec o i64
    | 32 => loadIntInfl Unsafe.PackWord32Little.subVec o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"
val loadIntInfAb =
   case MLton.IntInf.BigWord.wordSize of
      64 => loadIntInfb Unsafe.PackWord64Big.subArr o i64
    | 32 => loadIntInfb Unsafe.PackWord32Big.subArr o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"
val loadIntInfVb =
   case MLton.IntInf.BigWord.wordSize of
      64 => loadIntInfb Unsafe.PackWord64Big.subVec o i64
    | 32 => loadIntInfb Unsafe.PackWord32Big.subVec o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"

fun i32 (a, i, l, x) = (a, i*2, l*2, x)
fun i64 (a, i, l, x) = (a, i,   l,   x)
val storeIntInfl =
   case MLton.IntInf.BigWord.wordSize of
      64 => storeIntInfl Unsafe.PackWord64Little.update o i64
    | 32 => storeIntInfl Unsafe.PackWord32Little.update o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"
val storeIntInfb =
   case MLton.IntInf.BigWord.wordSize of
      64 => storeIntInfb Unsafe.PackWord64Big.update o i64
    | 32 => storeIntInfb Unsafe.PackWord32Big.update o i32
    | _ => raise Fail "Unsupported MLton.IntInf.BigWord.wordSize"
