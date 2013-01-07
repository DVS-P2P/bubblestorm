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

structure FakeItem : FAKE_ITEM =
   struct
      val module = "benchmark/util/fake-item"
      
      (* create order functions *)
      structure Order = OrderFromCompare(
         struct
               
            type t = {
               id : ID.t,
               publisher : ID.t,
               version : int,
               size : int
            }
      
            fun compare ({ id=id1, publisher=pub1, version=v1, size=s1 },
                         { id=id2, publisher=pub2, version=v2, size=s2 }) =
               case ID.compare (id1, id2) of
                  EQUAL => (case ID.compare (pub1, pub2) of
                     EQUAL => (case Int.compare (v1, v2) of
                        EQUAL => Int.compare (s1, s2)
                      | x => x)
                   | x => x)
                | x => x
         end
      )
      
      fun new x = x
      
      val noVersion = ~1
      val noSize = 0
      fun none { id, publisher } = {
         id = id,
         publisher = publisher,
         version = noVersion,
         size = noSize
      }
      fun isNone { id=_, publisher=_, version, size } =
         version = noVersion andalso size = noSize
      
      (* serialization *)
      local
         open Serial
         val serial = aggregate tuple4 `ID.t `ID.t `Serial.int32l `Serial.int32l $
         fun store { id, publisher, version, size } = (id, publisher, version, size)
         fun load (id, publisher, version, size) = { 
            id = id,
            publisher = publisher,
            version = version,
            size = size
         }
      in
         val t = Serial.map { store = store, load = load, extra = fn x => x } serial
      end
      
      (* encode / decode *)
      local
         open Serial
         val header = aggregate tuple3 `ID.t `ID.t `Serial.int32l $
         val { toVector, parseVector, length, ... } = 
            Serial.methods header
      in
         fun encode { id, publisher, version, size } = 
            let
               val head = toVector (id, publisher, version)
               val tailSize = Int.max (size - length, 0)
               val tail = Word8Vector.tabulate (tailSize, fn _ => 0w0)
            in
               Word8Vector.concat [ head, tail ]
            end
            
         fun decodeSlice data =
            if Word8VectorSlice.length data < length then raise At (module, Fail "too short to decode") else
               let
                  val head = Word8VectorSlice.subslice (data, 0, SOME length)
                  val (id, publisher, version) = parseVector head
                  val size = Word8VectorSlice.length data
               in
                  {
                     id = id,
                     publisher = publisher,
                     version = version,
                     size = size
                  }
               end
      end
      
      val decode = decodeSlice o Word8VectorSlice.full
      
      (* hash the item *)
      local
         val { toVector, ... } = Serial.methods t
      in
         val toHashID = ID.fromHash o toVector
      end
            
      fun toString { id, publisher, version, size } =
         "(id=" ^ ID.toString id ^ ", publisher=" ^ ID.toString publisher ^ 
         ", version=" ^ Int.toString version ^ ", size=" ^ Int.toString size ^ ")"
      
      fun hash { id, publisher, version, size } =
         ID.hash id o ID.hash publisher o Hash.int32 version o Hash.int32 size

      local
         val { parseVector, toVector, ... } = Serial.methods ID.t
      in
         val encodeQuery = toVector
         val decodeQuery = parseVector
      end

      (* make order functions available *)
      open Order
   end
