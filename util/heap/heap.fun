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

functor Heap(Key : ORDER) :> HEAP where type Key.t = Key.t =
   struct
      structure Key = Key
        
      type 'a record = (Key.t * 'a) ref 
      type 'a t = 'a record option Stack.t
      
      val ops = { store = fn (h, i, x) => Stack.update (h, i, SOME x), 
                  extract = fn (h, i) => valOf (Stack.sub (h, i)), 
                  less = fn (ref (a, _), ref (b, _)) => Key.< (a, b) }
      fun fixTooBig x = (#fixTooBig (makeHeapOps ops)) x
      fun fixTooSmall x = (#fixTooSmall (makeHeapOps ops)) x
      
      fun new () = Stack.new { nill = NONE }
      
      fun pop h =
         case Stack.pop h of
            NONE => NONE
          | (SOME x) =>
               if Stack.length h = 0 then Option.map ! x else
               Option.map ! (Stack.sub (h, 0)) before 
               fixTooBig (h, 0, Stack.length h, valOf x)
      
      fun peek h =
         Option.map ! (Stack.sub (h, 0))             
        
      val size = Stack.length
      val isEmpty = Stack.isEmpty
      
      fun popIf (h, f) =
         case Option.map (f o !) (Stack.sub (h, 0)) of
            SOME true => pop h
          | _ => NONE
      
      fun popBounded (h, k) =
         popIf (h, fn (l, _) => not (Key.< (k, l)))
      
      fun push (h, k, v) =
         let
            val record = ref (k, v)
         in
            fixTooSmall (h, Stack.push (h, SOME record), Stack.length h, record)
         end
   end
