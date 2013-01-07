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
      val subArr : Word8Array.array   * int -> t = Word8Array.sub
      val subVec : Word8Vector.vector * int -> t = Word8Vector.sub
      val update = Word8Array.update
   end

structure PackWord16L = 
   BasisPackWord(structure Pack = PackWord16Little
                 structure Word = Word16)
structure PackWord32L = 
   BasisPackWord(structure Pack = PackWord32Little
                 structure Word = Word32)
structure PackWord64L = 
   BasisPackWord(structure Pack = PackWord64Little
                 structure Word = Word64)

structure PackWord16B = 
   BasisPackWord(structure Pack = PackWord16Big
                 structure Word = Word16)
structure PackWord32B = 
   BasisPackWord(structure Pack = PackWord32Big
                 structure Word = Word32)
structure PackWord64B = 
   BasisPackWord(structure Pack = PackWord64Big
                 structure Word = Word64)

functor BasisPackInt(structure Pack : PACK_WORD
                     structure Integer : INTEGER) : PACK =
   struct
      type t = Integer.int
      fun subArr (a, i) = Integer.fromLarge (LargeWord.toLargeIntX (Pack.subArr (a, i)))
      fun subVec (a, i) = Integer.fromLarge (LargeWord.toLargeIntX (Pack.subVec (a, i)))
      fun update (a, i, x) = Pack.update (a, i, LargeWord.fromLargeInt (Integer.toLarge x))
   end

structure PackInt8 : PACK = 
   struct
      type t = Int8.int
      val subArr : Word8Array.array   * int -> t = Int8.fromInt o Word8.toIntX o Word8Array.sub
      val subVec : Word8Vector.vector * int -> t = Int8.fromInt o Word8.toIntX o Word8Vector.sub
      fun update (a, i, x) = Word8Array.update (a, i, Word8.fromInt (Int8.toInt x))
   end

structure PackInt16L = 
   BasisPackInt(structure Pack = PackWord16Little
                structure Integer = Int16)
structure PackInt32L =
   BasisPackInt(structure Pack = PackWord32Little
                structure Integer = Int32)
structure PackInt64L = 
   BasisPackInt(structure Pack = PackWord64Little
                structure Integer = Int64)

structure PackInt16B = 
   BasisPackInt(structure Pack = PackWord16Big
                structure Integer = Int16)
structure PackInt32B =
   BasisPackInt(structure Pack = PackWord32Big
                structure Integer = Int32)
structure PackInt64B = 
   BasisPackInt(structure Pack = PackWord64Big
                structure Integer = Int64)

functor BasisPackReal(Pack : PACK_REAL) : PACK =
   struct
      type t = Pack.real
      open Pack
   end

structure PackReal32L = BasisPackReal(PackReal32Little)
structure PackReal64L = BasisPackReal(PackReal64Little)

structure PackReal32B = BasisPackReal(PackReal32Big)
structure PackReal64B = BasisPackReal(PackReal64Big)
