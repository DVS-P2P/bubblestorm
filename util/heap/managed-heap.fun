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

functor ManagedHeap(Key : ORDER) :> MANAGED_HEAP where type Key.t = Key.t=
   struct
      structure Key = Key
        
      (* b/c we compare 'a records we need them to be a ref for equality *)
      type 'a record =  { offset : int, key : Key.t, value : 'a } ref
      type 'a t = 'a record option Stack.t
        
      val ops = { store = fn (h, i, r as ref { offset=_, key, value }) =>
                             (Stack.update (h, i, SOME r)
                              ; r := { offset = i, key = key, value = value }),
                  extract = fn (h, i) => valOf (Stack.sub (h, i)),
                  less = fn (a, b) => Key.< (#key (!a), #key (!b)) }
      
      fun fixTooBig x = (#fixTooBig (makeHeapOps ops)) x
      fun fixTooSmall x = (#fixTooSmall (makeHeapOps ops)) x
      
(*
      fun checkInvariant x = (#checkInvariant (makeHeapOps ops)) x
      val fixTooBig = fn args as (a, _, l, _) => (fixTooBig args; checkInvariant (a, l))
      val fixTooSmall = fn args as (a, _, l, _) => (fixTooSmall args; checkInvariant (a, l)) 
*)
      
      fun wrap (k, v) = ref { offset = ~1, key = k, value = v }
      fun sub (ref { offset, key, value }) = (offset <> ~1, key, value)
      
      fun new () = Stack.new { nill = NONE }
      
      fun pop h =
         case Stack.sub (h, 0) of
            NONE => NONE
          | (SOME (r as ref { offset=_, key, value })) =>
               (if Stack.length h = 1
                   then ignore (Stack.pop h)
                   else fixTooBig (h, 0, Stack.length h-1, valOf (valOf (Stack.pop h)))
                ; r := { offset = ~1, key = key, value = value }
                ; SOME r)
      
      fun peek h =
         if Stack.length h = 0 then NONE else
         Stack.sub (h, 0)
      
      val size = Stack.length
      val isEmpty = Stack.isEmpty
      
      val clear = Stack.clear
      
      fun popIf (h, f) =
         case Option.map (f o (fn ref { key, value, offset=_ } => (key, value)))
                         (Stack.sub (h, 0)) of
            SOME true => pop h
          | _ => NONE
      
      fun peekIf (h, f) =
         case Option.map (f o (fn ref { key, value, offset=_ } => (key, value)))
                         (Stack.sub (h, 0)) of
            SOME true => Stack.sub (h, 0)
          | _ => NONE
      
      fun popBounded (h, k) =
         popIf (h, fn (l, _) => not (Key.< (k, l)))
      
      fun peekBounded (h, k) =
         peekIf (h, fn (l, _) => not (Key.< (k, l)))
      
      exception WrongHeap
       
      (* The <> forces the ref to be broken out *)
      fun wrongHeap (h, r as ref { offset, key=_ , value=_ }) =
         offset >= Stack.length h orelse
         valOf (Stack.sub (h, offset)) <> r
       
      fun push (h, r as ref { offset, key=_, value=_ }) =
         if offset = ~1
            then fixTooSmall (h, Stack.push (h, SOME r), Stack.length h, r)
         else if wrongHeap (h, r)
            then raise WrongHeap
         else ()
            
      fun remove (h, r as ref { offset, key, value }) = 
         if offset = ~1 
            then () 
         else if wrongHeap (h, r)
            then raise WrongHeap 
         else if Stack.length h - 1 = offset
            then (ignore (Stack.pop h)
                  ; r := { offset = ~1, key = key, value = value })
         else
            let
               val last = valOf (valOf (Stack.pop h))
               val newKey = #key (!last)
               val () = r := { offset = ~1, key = key, value = value }
            in
               if Key.< (key, newKey) 
               then fixTooBig (h, offset, Stack.length h, last)
               else fixTooSmall (h, offset, Stack.length h, last) 
            end
          
      fun update (h, r as ref { offset, key, value }, k) =
         if offset = ~1
            then (r := { offset = offset, key = k, value = value }
                  ; fixTooSmall (h, Stack.push (h, SOME r), Stack.length h, r))
         else if wrongHeap (h, r)
            then raise WrongHeap
         else (r := { offset = offset, key = k, value = value }
               ; if Key.< (key, k)
                 then fixTooBig (h, offset, Stack.length h, r)
                 else fixTooSmall (h, offset, Stack.length h, r))
      
      fun updateValue (r as ref { offset, key, value=_ }, value) =
         r := { offset = offset, key = key, value = value }
      
      fun iterator stack =
         Iterator.mapPartial (fn x => x) (Stack.iterator stack)
   end
