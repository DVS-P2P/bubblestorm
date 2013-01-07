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

structure IdBucket :> ID_BUCKET =
   struct
      datatype 'a cell = FREE of int | FULL of 'a
      type 'a t = { free: int, fill: int, table: 'a cell array } ref

      fun freeTail n i = FREE (if i = (n-1) then ~1 else i+1)
      
      fun emptyVal () =
         { free = 0, fill = 0, table = Array.tabulate (4, freeTail 4) }
      
      fun new () =
         ref (emptyVal ())

      fun sub (ref { free=_, fill=_, table }, i) =
        (case Array.sub (table, i) of
            FREE _ => NONE
          | FULL x => SOME x)
         handle Subscript => NONE
      
      fun fill (ref { free=_, fill, table=_ }) = fill

      fun alloc (self as ref { free, fill, table }, value) =
         let
            val oldlen = Array.length table
            val newlen = oldlen+oldlen
            fun get i =
               if i < oldlen then Array.sub (table, i) else freeTail newlen i
            fun grow () = (oldlen, Array.tabulate (newlen, get))
            val (free, table) =
               if free = ~1 then grow () else (free, table)
         in
            case Array.sub (table, free) of
               FULL _ => raise Fail "Impossibly full cell"
             | FREE next =>
                 (Array.update (table, free, FULL value)
                  ; self := { free = next, fill=fill+1, table = table }
                  ; free)
         end

      exception AlreadyFree
      fun free (self as ref { free, fill, table }, index) =
        (case Array.sub (table, index) of
            FREE _ => raise AlreadyFree
          | FULL _ =>
              (Array.update (table, index, FREE free)
               ; self := { free = index, fill = fill-1, table = table }))
         handle Subscript => raise AlreadyFree

      fun replace (ref { free=_, fill=_, table }, index, value) =
        (case Array.sub (table, index) of
            FREE _ => raise AlreadyFree
          | FULL _ => Array.update (table, index, FULL value))
         handle Subscript => raise AlreadyFree

      fun clear this =
         this := emptyVal ()

      fun iterator (ref { free=_, fill=_, table }) =
         Iterator.mapPartial
         (fn (_, FREE _) => NONE | (i, FULL x) => SOME (i, x))
         (Iterator.fromArraySlicei (ArraySlice.full table))
   end
