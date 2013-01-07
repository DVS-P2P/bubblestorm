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

functor InPlaceHeap(Value : IN_PLACE_ARGUMENT) 
   :> IN_PLACE_HEAP where type Value.t = Value.t =
   struct
      structure Value = Value
       
      type t = Value.t Stack.t
      
      fun new () = Stack.new { nill = Value.nill }
      
      val { fixTooBig, fixTooSmall, ... } =
         makeHeapOps { store = Stack.update, 
                       extract = Stack.sub, 
                       less = Value.< }        
      
      fun pop h =
         case Stack.pop h of
            NONE => NONE
          | (SOME x) =>
               if Stack.length h = 0 then SOME x else
               SOME (Stack.sub (h, 0)) before 
               fixTooBig (h, 0, Stack.length h, x)
       
      fun peek h =
         if Stack.length h = 0 then NONE else SOME (Stack.sub (h, 0))             
       
      fun push (h, x) =
         fixTooSmall (h, Stack.push (h, x), Stack.length h, x)
   end
