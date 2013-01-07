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

structure Iterator :> ITERATOR =
   struct
      datatype 'a t = EOF | SKIP of (unit -> 'a t) | VALUE of 'a * (unit -> 'a t)
      
      fun getItem EOF = NONE
        | getItem (SKIP r) = getItem (r ())
        | getItem (VALUE (x, r)) = SOME (x, r ())
      
      fun null x = not (Option.isSome (getItem x))
             
      fun map _ EOF = EOF
        | map f (SKIP r) = SKIP (fn () => map f (r ()))
        | map f (VALUE (x, r)) = VALUE (f x, fn () => map f (r ())) 
      
      fun mapPartialWith _ (EOF, _) = EOF
        | mapPartialWith f (SKIP r, w) = SKIP (fn () => mapPartialWith f (r (), w))
        | mapPartialWith f (VALUE (x, r), w) =
              case f (x, w) of
                 (NONE, w) => SKIP (fn () => mapPartialWith f (r (), w))
               | (SOME y, w) => VALUE (y, fn () => mapPartialWith f (r (), w))
      
      fun mapPartial f i = mapPartialWith (fn (x, ()) => (f x, ())) (i, ())
      fun filter f = mapPartial (fn x => if f x then SOME x else NONE)
      fun partition f i = { true = filter f i, false = filter (not o f) i }
      
      fun push (x, r) = VALUE (x, fn () => r)
      
      fun @ (EOF, s) = s
        | @ (SKIP r, s) = SKIP (fn () => r () @ s)
        | @ (VALUE (x, r), s) = VALUE (x, fn () => r () @ s) 
      
      fun cross (x, y) =
         let
            fun loop (EOF, _) = EOF
              | loop (SKIP r, y) = SKIP (fn () => loop (r (), y))
              | loop (VALUE (_, r), EOF) = SKIP (fn () => loop (r (), y))
              | loop (x, SKIP s) = SKIP (fn () => loop (x, s ()))
              | loop (r as VALUE (x, _), VALUE (y, s)) =
                   VALUE ((x, y), fn () => loop (r, s ()))
         in
            loop (x, y)
         end
       
      fun concat EOF = EOF
        | concat (SKIP r) = SKIP (fn () => concat (r ()))
        | concat (VALUE (s, r)) =
              let
                 fun concatSub EOF = SKIP (fn () => concat (r ()))
                   | concatSub (SKIP r) = SKIP (fn () => concatSub (r ()))
                   | concatSub (VALUE (x, r)) = VALUE (x, fn () => concatSub (r ()))
              in
                 concatSub s
              end
      
      fun loop f =
         let
            fun go EOF = go f
              | go (SKIP r) = SKIP (fn () => go (r ()))
              | go (VALUE (x, r)) = VALUE (x, fn () => go (r ()))
         in
            go f
         end
      
      fun truncate _ EOF = EOF
        | truncate f (SKIP r) = SKIP (fn () => truncate f (r ()))
        | truncate f (VALUE (x, r)) = 
            if f x then EOF else 
            VALUE (x, fn () => truncate f (r ()))
      
      fun delay EOF = EOF
        | delay (SKIP r) = SKIP (fn () => delay (r ()))
        | delay (VALUE (x, r)) = SKIP (fn () => VALUE (x, fn () => delay (r ())))
            
      fun app _ EOF = ()
        | app f (SKIP r) = app f (r ())
        | app f (VALUE (x, r)) = let val () = f x in app f (r ()) end
      
      fun appi _ _ EOF = ()
        | appi i f (SKIP r) = appi i f (r ())
        | appi i f (VALUE (x, r)) = let val () = f (i, x) in appi (i+1) f (r ()) end
      val appi = fn f => appi 0 f
      
      fun fold _ a EOF = a
        | fold f a (SKIP r) = fold f a (r ())
        | fold f a (VALUE (x, r)) = fold f (f (x, a)) (r ())
      
      fun find _ EOF = NONE
        | find f (SKIP r) = find f (r ())
        | find f (VALUE (x, r)) =
              if f x then SOME x else find f (r ())
      
      fun exists f = isSome o find f
      
      fun collate _ (EOF, EOF) = EQUAL
        | collate f (SKIP r, s) = collate f (r (), s)
        | collate f (r, SKIP s) = collate f (r, s ())
        | collate _ (EOF, _) = LESS 
        | collate _ (_, EOF) = GREATER
        | collate f (VALUE (x, r), VALUE (y, s)) =
              case f (x, y) of
                 EQUAL => collate f (r (), s ())
               | LESS => LESS
               | GREATER => GREATER               
      
      fun length (r, EOF) = r
        | length (x, SKIP r) = length (x, r ())
        | length (x, VALUE (_, r)) = length (x+1, r ())
      val length = fn l => length (0, l)
      
      fun nth (EOF, _) = raise Subscript
        | nth (SKIP r, i) = nth (r (), i)
        | nth (VALUE (x, _), 0) = x
        | nth (VALUE (_, r), i) = nth (r (), i - 1)
      val nth = fn (r, i) =>  if i < 0 then raise Subscript else nth (r, i)
      
      fun take (_, 0) = []
        | take (EOF, _) = raise Subscript
        | take (SKIP r, i) = take (r (), i)
        | take (VALUE (x, r), i) = x :: take (r (), i - 1)
      val take = fn (r, i) => if i < 0 then raise Subscript else take (r, i)
      
      fun drop (r, 0) = r
        | drop (EOF, _) = raise Subscript
        | drop (SKIP r, i) = drop (r (), i)
        | drop (VALUE (_, r), i) = drop (r (), i - 1)
      val drop = fn (r, i) => if i < 0 then raise Subscript else drop (r, i) 
      
      fun fromElement x = VALUE (x, fn () => EOF)
      
      fun fromList [] = EOF
        | fromList (x :: r) = VALUE (x, fn () => fromList r)
      
      fun fromSubstring s =
         case Substring.getc s of
            NONE => EOF
          | SOME (c, s) => VALUE (c, fn () => fromSubstring s) 
      
      fun fromVectorSlice s =
         case VectorSlice.getItem s of
            NONE => EOF
          | SOME (x, s) => VALUE (x, fn () => fromVectorSlice s)         

      fun fromVectorSlicei (s, i) =
         case VectorSlice.getItem s of
            NONE => EOF
          | SOME (x, s) => VALUE ((i, x), fn () => fromVectorSlicei (s, i+1))
      val fromVectorSlicei = fn s => fromVectorSlicei (s, 0)

      fun fromArraySlice s =
         case ArraySlice.getItem s of
            NONE => EOF
          | SOME (x, s) => VALUE (x, fn () => fromArraySlice s)

      fun fromArraySlicei (s, i) =
         case ArraySlice.getItem s of
            NONE => EOF
          | SOME (x, s) => VALUE ((i, x), fn () => fromArraySlicei (s, i+1))
      val fromArraySlicei = fn s => fromArraySlicei (s, 0)

      fun fromString z = (fromSubstring   o Substring.full)   z
      fun fromVector z = (fromVectorSlice o VectorSlice.full) z
      fun fromArray  z = (fromArraySlice  o ArraySlice.full)  z

      (* Uses the stack... could have also done List.rev o Iterator.fold *)
      fun toList EOF = []
        | toList (SKIP r) = toList (r ())
        | toList (VALUE (x, r)) = x :: toList (r ())
      
      fun fetch x =
         let
            val y = ref x
         in
            fn _ => 
               case getItem (!y) of
                  SOME (x, r) => (y := r; x)
                | NONE => raise Fail "unreachable EOF in Iterator.fetch"                 
         end
         
      fun toString x = CharVector.tabulate (length x, fetch x)
      fun toVector x = Vector.tabulate (length x, fetch x)
      fun toArray x = Array.tabulate (length x, fetch x)
      
      fun fromInterval { start, stop, step } =
         let
            fun next () = VALUE (start, 
                               fn () => fromInterval { start = start + step,
                                                       stop = stop,
                                                       step = step })
         in
            if step > 0
               then if start < stop
                  then next ()
               else EOF
            else if start > stop
                  then next ()
               else EOF
         end
   end
