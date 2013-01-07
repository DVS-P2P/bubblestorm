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

(* Sorts to form ascending order *)
structure HeapSort =
   struct
      fun sort less array =
         let
            (* Get heap operators *)
            val { fixTooBig, ... } = 
               makeHeapOps { 
                  store = Array.update, 
                  extract = Array.sub, 
                  less = not o less }
            (* Heapify *)
            val length = Array.length array
            fun heapify 0 = ()
              | heapify i =
               let 
                  val i = i - 1
                  val () = fixTooBig (array, i, length, Array.sub (array, i))
               in  
                  heapify i 
               end
            (* Extract min *)
            fun sortHeap length = 
               if length <= 1 then () else
               let
                  val length = length - 1
                  val last = Array.sub (array, length)
                  val () = Array.update (array, length, Array.sub (array, 0))
                  val () = fixTooBig (array, 0, length, last)
               in
                  sortHeap length
               end
         in
            (heapify (length div 2); sortHeap length)
         end
   end

(*
val a = Array.fromList (List.map (valOf o Int.fromString) (CommandLine.arguments ()))
val () = sort Int.< a
val () = Array.app (fn i => print (Int.toString i ^ " ")) a
val () = print "\n"
*)
