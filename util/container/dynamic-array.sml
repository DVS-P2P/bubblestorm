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

structure DynamicArray :> DYNAMIC_ARRAY =
   struct
      datatype 'a t = T of {
         init : int -> 'a,
         slice : 'a ArraySlice.slice ref
      }
      
      val defaultSize = 1
      
      fun new init =
         let
            val base = Array.tabulate (defaultSize, init)
            val slice = ArraySlice.slice (base, 0, SOME 0)
         in
            T {
               init = init,
               slice = ref slice
            }
         end
      
      fun capacity (T { slice, ... }) =
         let
            val (base, _, _) = ArraySlice.base (!slice)
         in
            Array.length base
         end
         
      fun expand (T { init, slice }, pos) =
         if ArraySlice.length (!slice) > pos then ()
         else
            let
               val (base, _, _) = ArraySlice.base (!slice)
               val size = Array.length base
               fun tabulate i = if i < size then Array.sub (base, i) else init i
               val base = 
                  if size > pos then base
                  else Array.tabulate (pos * 2, tabulate)
            in
               slice := ArraySlice.slice (base, 0, SOME (pos + 1))
            end
      
      fun truncate (T { init, slice }, size) =
         let
            val (base, _, _) = ArraySlice.base (!slice)
            fun tabulate i = if i < size then Array.sub (base, i) else init i
            val base = Array.tabulate (size * 2, tabulate)
         in
            slice := ArraySlice.slice (base, 0, SOME (size + 1))
         end
            
      fun update (this as T { init=_, slice }, pos, elem) =
         let
            val () = expand (this, pos)
         in
            ArraySlice.update (!slice, pos, elem)
         end

      fun sub (this as T { init=_, slice }, pos) =
         let
            val () = expand (this, pos)
         in
            ArraySlice.sub (!slice, pos)
         end

      fun slice (this as T { slice, ... }, start, size) =
         let
            val () = case size of 
               SOME size => expand (this, start + size - 1)
             | NONE => ()
         in
            ArraySlice.subslice (!slice, start, size)
         end
      
      fun length (T { slice, ... }) = ArraySlice.length (!slice)
      fun vector (T { slice, ... }) = ArraySlice.vector (!slice)
      fun copy { src = T { slice, ... }, dst, di } =
         ArraySlice.copy { src = !slice, dst = dst, di = di }
      fun isEmpty (T { slice, ... }) = ArraySlice.isEmpty (!slice)
      fun appi f (T { slice, ... }) = ArraySlice.appi f (!slice)      
      fun app  f (T { slice, ... }) = ArraySlice.app  f (!slice)
      fun modifyi f (T { slice, ... }) = ArraySlice.modifyi f (!slice)
      fun modify  f (T { slice, ... }) = ArraySlice.modify  f (!slice)
      fun foldli f x (T { slice, ... }) = ArraySlice.foldli f x (!slice)
      fun foldri f x (T { slice, ... }) = ArraySlice.foldri f x (!slice)
      fun foldl  f x (T { slice, ... }) = ArraySlice.foldl  f x (!slice)
      fun foldr  f x (T { slice, ... }) = ArraySlice.foldr f x (!slice)
      fun findi f (T { slice, ... }) = ArraySlice.findi f (!slice)
      fun find  f (T { slice, ... }) = ArraySlice.find f (!slice)
      fun exists f (T { slice, ... }) = ArraySlice.exists f (!slice)
      fun all f (T { slice, ... }) = ArraySlice.all f (!slice)
      fun collate f (T { slice=ref slice1, ... }, T { slice=ref slice2, ... }) = 
         ArraySlice.collate f (slice1, slice2)
   end
