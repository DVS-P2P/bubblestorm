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

functor GlobalDocTable (ID : ID) : GLOBAL_DOC_TABLE =
   struct
      structure ID = ID
      
      datatype doc = DOC of {
         id : ID.t,
         pos : int ref
      }

      datatype table = TABLE of {
         stack : doc Stack.t
      }
      
      val nullID = ID.fromHash (Word8Vector.tabulate (0, fn _ => 0w0))

      fun new () =
         TABLE {
            stack = Stack.new { nill = DOC { id = nullID, pos = ref ~1 } }
         }

      fun getID (DOC { id, ... }) = id
      fun getPos (DOC { pos, ... }) = pos

      fun add (TABLE { stack, ... }, id) =
         let
            val pos = ref ~1
            val doc = DOC { id = id, pos = pos }
            val () = pos := Stack.push (stack, doc)
         in
            doc
         end
      
      fun getRandom (TABLE { stack, ... }) =
         case Stack.length stack of
            0 => NONE
          | count =>
               let
                  val pos = Random.int (getTopLevelRandom (), count)
                  val doc = Stack.sub (stack, pos)
               in
                  SOME (getID doc)
               end

      fun isInvalid (TABLE { stack, ... }, DOC { id, pos }) =
         case Stack.sub (stack, !pos) of
            DOC { id=tableID, ... } => ID.!= (id, tableID)
            
      fun delete (table as TABLE { stack, ... }, doc as DOC { pos = ref delPos, ... }) =
         if isInvalid (table, doc) then
            raise At ("GlobalDocTable", Fail "inconsistency detected")
         else
            case Stack.pop stack of
               NONE => raise At ("GlobalDocTable", Fail "cannot delete from empty list")
             | SOME doc => if delPos = Stack.length stack then () else
                  let
                     val () = (getPos doc) := delPos
                  in
                     Stack.update (stack, delPos, doc)
                  end
   end
