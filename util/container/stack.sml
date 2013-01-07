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

structure Stack :> RAM_STACK =
   struct
      type 'a t = { stack: 'a array, use: int, nill: 'a } ref
      
      fun emptyData nill =
         { stack = (Array.tabulate (4, fn _ => nill)),
           use = 0,
           nill = nill }
      
      fun new { nill } = ref (emptyData nill)
      
      fun push (s as ref { stack, use, nill }, x) =
         let
            fun copy i = if i < use then Array.sub (stack, i) else nill
            val stack = if use = Array.length stack
                        then Array.tabulate (Array.length stack * 2, copy)
                        else stack
         in
            Array.update (stack, use, x)
            ; s := { stack = stack, use = use + 1, nill = nill }
            ; use
         end
      
      fun pop (s as ref { stack, use, nill }) =
         if use = 0 then NONE else
         let
            fun copy i = Array.sub (stack, i)
            val stack = if use*4 = Array.length stack
                        then Array.tabulate (use*2, copy)
                        else stack
            val use = use - 1
            val out = Array.sub (stack, use)
         in
            s := { stack = stack, use = use, nill = nill }
            ; Array.update (stack, use, nill)
            ; SOME out
         end
      
      fun length (ref { stack=_, use, nill=_ }) = use
      fun isEmpty (ref { stack=_, use, nill=_ }) = use = 0
      
      fun clear (this as (ref { stack=_, use=_, nill })) =
         this := emptyData nill
      
      fun sub (ref { stack, use=_ , nill=_ }, i) = 
         Array.sub (stack, i)
      
      fun update (ref { stack, use=_, nill=_ }, i, v) = 
         Array.update (stack, i, v)
      
      fun iterator (ref { stack, use, nill=_ }) =
         Iterator.fromArraySlice (ArraySlice.slice (stack, 0, SOME use))
   end
