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

functor Tree(Key : ORDER) :> TREE where type Key.t = Key.t =
   struct
      val op < = Key.<
      structure Key = Key
      
      datatype 'a t = LEAF | RED of 'a node | BLACK of 'a node
      withtype 'a node = 'a t * (Key.t * 'a) * 'a t
      
      val empty = LEAF
      
      fun isEmpty LEAF = true
        | isEmpty _ = false
      
      fun insert (t, x, v) =
         let
            fun up (RED (RED (a, x, b), y, c), z, d) = RED (BLACK (a, x, b), y, BLACK (c, z, d))
              | up (RED (a, x, RED (b, y, c)), z, d) = RED (BLACK (a, x, b), y, BLACK (c, z, d))
              | up (a, x, RED (RED (b, y, c), z, d)) = RED (BLACK (a, x, b), y, BLACK (c, z, d))
              | up (a, x, RED (b, y, RED (c, z, d))) = RED (BLACK (a, x, b), y, BLACK (c, z, d))   
              | up (a, x, b) = BLACK (a, x, b)
            
            fun node f (l, (y, w), r) = 
               if x < y then f (down l, (y, w), r) else f (l, (y, w), down r)
            and down LEAF = RED (LEAF, (x, v), LEAF)
              | down (RED z) = node RED z
              | down (BLACK z) = node up z
         in
            case t of
               LEAF => BLACK (LEAF, (x, v), LEAF)
             | (RED z) => node up z
             | (BLACK z) => node up z
         end
      
      fun remove (t, x) =
         let
            fun lr (_, _, RED _) = raise Fail "impossible R-R tree"
              | lr (l, w, BLACK (RED (a, x, b), y, c)) = (RED (BLACK (l, w, a), x, BLACK (b, y, c)), false)
              | lr (l, w, BLACK (a, x, RED (b, y, c))) = (RED (BLACK (l, w, a), x, BLACK (b, y, c)), false)
              | lr (l, w, BLACK (a, x, b)) = (BLACK (l, w, RED (a, x, b)), false) (* a&b are black/leaf *)
              | lr (_, _, LEAF) = raise Fail "impossible B depth tree"
            fun lb (l, w, BLACK (RED (a, x, b), y, c)) = (BLACK (BLACK (l, w, a), x, BLACK (b, y, c)), false)
              | lb (l, w, BLACK (a, x, RED (b, y, c))) = (BLACK (BLACK (l, w, a), x, BLACK (b, y, c)), false)
              | lb (l, w, BLACK (a, x, b)) = (BLACK (l, w, RED (a, x, b)), true) (* a&b are black/leaf *)
              | lb (_, _, RED (RED _, _, _)) = raise Fail "impossible R-R tree"
              | lb (l, w, RED (BLACK (RED (a, x, b), y, c), z, d)) = (BLACK (RED (BLACK (l, w, a), x, BLACK (b, y, c)), z, d), false)
              | lb (l, w, RED (BLACK (a, x, RED (b, y, c)), z, d)) = (BLACK (RED (BLACK (l, w, a), x, BLACK (b, y, c)), z, d), false)
              | lb (l, w, RED (BLACK (a, x, b), y, c)) = (BLACK (BLACK (l, w, RED (a, x, b)), y, c), false) (* a&b are black/leaf *)
              | lb (_, _, RED (LEAF, _, _)) = raise Fail "impossible B depth tree"
              | lb (_, _, LEAF) = raise Fail "impossible B depth tree"
            fun rr (RED _, _, _) = raise Fail "impossible tree"
              | rr (BLACK (RED (a, w, b), x, c), y, r) = (RED (BLACK (a, w, b), x, BLACK (c, y, r)), false)
              | rr (BLACK (a, w, RED (b, x, c)), y, r) = (RED (BLACK (a, w, b), x, BLACK (c, y, r)), false)
              | rr (BLACK (a, w, b), x, r) = (BLACK (RED (a, w, b), x, r), false) (* a&b are black/leaf *)
              | rr (LEAF, _, _) = raise Fail "impossible B depth tree"
            fun rb (BLACK (RED (a, w, b), x, c), y, r) = (BLACK (BLACK (a, w, b), x, BLACK (c, y, r)), false)
              | rb (BLACK (a, w, RED (b, x, c)), y, r) = (BLACK (BLACK (a, w, b), x, BLACK (c, y, r)), false)
              | rb (BLACK (a, w, b), x, r) = (BLACK (RED (a, w, b), x, r), true) (* a&b are black/leaf *)
              | rb (RED (_, _, RED _), _, _) = raise Fail "impossible tree"
              | rb (RED (a, w, BLACK (RED (b, x, c), y, d)), z, r) = (BLACK (a, w, RED (BLACK (b, x, c), y, BLACK (d, z, r))), false)
              | rb (RED (a, w, BLACK (b, x, RED (c, y, d))), z, r) = (BLACK (a, w, RED (BLACK (b, x, c), y, BLACK (d, z, r))), false)
              | rb (RED (a, w, BLACK (b, x, c)), y, r) = (BLACK (a, w, BLACK (RED (b, x, c), y, r)), false) (* b&c are black/leaf *)
              | rb (RED (_, _, LEAF), _, _) = raise Fail "impossible B depth tree"
              | rb (LEAF, _, _) = raise Fail "impossible B depth tree"
            
            fun mlr b t = if b then lr t else (RED   t, false)
            fun mlb b t = if b then lb t else (BLACK t, false)
            fun mrr b t = if b then rr t else (RED   t, false)
            fun mrb b t = if b then rb t else (BLACK t, false)
            
            fun popSmallest LEAF = raise Fail "unreachable code"
              | popSmallest (RED   (LEAF, x, r)) = ((r, false), x)
              | popSmallest (BLACK (LEAF, x, r)) = ((r, true),  x)
              | popSmallest (RED   (l, x, r)) = (fn ((t, b), z) => (mlr b (t, x, r), z)) (popSmallest l)
              | popSmallest (BLACK (l, x, r)) = (fn ((t, b), z) => (mlb b (t, x, r), z)) (popSmallest l)
            
            fun down LEAF = ((LEAF, false), NONE)
              | down (RED (l, (y, w), r)) = 
                  if x < y
                     then (fn ((t, b), z) => (mlr b (t, (y, w), r), z)) (down l)
                  else if y < x
                     then (fn ((t, b), z) => (mrr b (l, (y, w), t), z)) (down r)
                  else
                     (case (l, r) of
                         (LEAF, _) => ((r, false), SOME (y, w))
                       | (_, LEAF) => ((l, false), SOME (y, w))
                       | _ => (fn ((t, b), z) => (mrr b (l, z, t), SOME (y, w))) (popSmallest r))
              | down (BLACK (l, (y, w), r)) =
                  if x < y
                     then (fn ((t, b), z) => (mlb b (t, (y, w), r), z)) (down l)
                  else if y < x
                     then (fn ((t, b), z) => (mrb b (l, (y, w), t), z)) (down r)
                  else
                     (case (l, r) of
                         (LEAF, _) => ((r, true), SOME (y, w))
                        | (_, LEAF) => ((l, true), SOME (y, w))
                       | _ => (fn ((t, b), z) => (mrb b (l, z, t), SOME (y, w))) (popSmallest r))
         in
            (fn ((t, _), z) => (t, z)) (down t)
         end
         
      fun find (t, y) =
         let
            fun node ((a, (x, v), b), l) = 
                 if y < x then down (a, l) else
                 if x < y then down (b, l) else
                 down (a, v :: down (b, l)) 
            and down (LEAF, l) = l
              | down (RED z, l) = node (z, l)
              | down (BLACK z, l) = node (z, l)
         in
            down (t, [])
         end 
      
      datatype order = POST_ORDER | PRE_ORDER | IN_ORDER
      
      fun app ord f =
         let
            fun post LEAF = ()
              | post (RED   (a, x, b)) = (post a; post b; f x)
              | post (BLACK (a, x, b)) = (post a; post b; f x)
            fun pre LEAF = ()
              | pre (RED   (a, x, b)) = (f x; pre a; pre b)
              | pre (BLACK (a, x, b)) = (f x; pre a; pre b)
            fun ino LEAF = ()
              | ino (RED   (a, x, b)) = (ino a; f x; ino b)
              | ino (BLACK (a, x, b)) = (ino a; f x; ino b)
         in
            case ord of
               POST_ORDER => post
             | PRE_ORDER => pre
             | IN_ORDER => ino
         end
        
      fun map ord f =
         let
            fun post LEAF = LEAF
              | post (RED z) = RED (node z)
              | post (BLACK z) = BLACK (node z)
            and node (a, (x, v), b) =
               let val (a, b, v) = (post a, post b, f (x, v)) in (a, (x, v), b) end 
   
            fun pre LEAF = LEAF
              | pre (RED z) = RED (node z)
              | pre (BLACK z) = BLACK (node z)
            and node (a, (x, v), b) =
               let val (v, a, b) = (f (x, v), pre a, pre b) in (a, (x, v), b) end
                
            fun ino LEAF = LEAF
              | ino (RED z) = RED (node z)
              | ino (BLACK z) = BLACK (node z)
            and node (a, (x, v), b) = (ino a, (x, f (x, v)), ino b)
         in
            case ord of
               POST_ORDER => post
             | PRE_ORDER => pre
             | IN_ORDER => ino
         end  

      fun fold ord f a t =
         let
            fun post (LEAF, y) = y
              | post (RED z, y) = node (z, y)
              | post (BLACK z, y) = node (z, y)
            and node ((a, (x, v), b), y) =
              f (x, v, post (b, post (a, y)))
              
            fun pre (LEAF, y) = y
              | pre (RED z, y) = node (z, y)
              | pre (BLACK z, y) = node (z, y)
            and node ((a, (x, v), b), y) =
              pre (b, pre (a, f (x, v, y)))
              
            fun ino (LEAF, y) = y
              | ino (RED z, y) = node (z, y)
              | ino (BLACK z, y) = node (z, y)
            and node ((a, (x, v), b), y) =
              ino (b, f (x, v, ino (a, y)))
         in
            case ord of
               POST_ORDER => post (t, a)
             | PRE_ORDER => pre (t, a)
             | IN_ORDER => ino (t, a)
         end  
      
      
      fun first LEAF = NONE
        | first (BLACK z) = fnode z
        | first (RED z) = fnode z
      and fnode (a, (x, v), _) =
         case a of 
            LEAF => SOME (x, v)
          | BLACK z => fnode z
          | RED z => fnode z
      
      fun last LEAF = NONE
        | last (BLACK z) = lnode z
        | last (RED z) = lnode z
      and lnode (_, (x, v), b) =
         case b of 
            LEAF => SOME (x, v)
          | BLACK z => lnode z
          | RED z => lnode z
      
      type range = { left: Key.t option, right: Key.t option }
      
      (* build a stack going left then right *)
      fun forward t { left, right } =
         let
            open Iterator
            
            fun tooSmall x = case left of SOME y => x < y | NONE => false
            fun tooBig x = case right of SOME y => not (x < y) | NONE => false
            
            fun pop (BLACK (_, x, r) :: s) = VALUE (x, goLeft (r, s))
              | pop (RED (_, x, r) :: s) = VALUE (x, goLeft (r, s))
              | pop (LEAF :: _) = raise Fail "unreachable LEAF in Tree.forward"
              | pop [] = EOF
            and goLeft (LEAF, s) = (fn () => pop s)
              | goLeft (z as BLACK (l, (x, _), _), s) = 
                   goLeft (l, if tooBig x then s else z :: s)
              | goLeft (z as RED   (l, (x, _), _), s) =
                   goLeft (l, if tooBig x then s else z :: s)
            
            fun descend (LEAF, s) = SKIP (fn () => pop s)
              | descend (z as BLACK (l, (x, _), r), s) =
                     if tooSmall x then descend (r, s) else
                     if tooBig   x then descend (l, s) else
                     descend (l, z :: s) 
              | descend (z as RED (l, (x, _), r), s) =
                     if tooSmall x then descend (r, s) else
                     if tooBig   x then descend (l, s) else
                     descend (l, z :: s) 
         in
            descend (t, [])
         end
               
      fun backward t { left, right } =
         let
            open Iterator
            
            fun tooSmall x = case left of SOME y => x < y | NONE => false
            fun tooBig x = case right of SOME y => not (x < y) | NONE => false
            
            fun pop (BLACK (l, x, _) :: s) = VALUE (x, goRight (l, s))
              | pop (RED (l, x, _) :: s) = VALUE (x, goRight (l, s))
              | pop (LEAF :: _) = raise Fail "unreachable LEAF in Tree.backward"
              | pop [] = EOF
            and goRight (LEAF, s) = (fn () => pop s)
              | goRight (z as BLACK (_, (x, _), r), s) = 
                   goRight (r, if tooSmall x then s else z :: s)
              | goRight (z as RED   (_, (x, _), r), s) =
                   goRight (r, if tooSmall x then s else z :: s)
            
            fun descend (LEAF, s) = SKIP (fn () => pop s)
              | descend (z as BLACK (l, (x, _), r), s) =
                     if tooBig   x then descend (l, s) else
                     if tooSmall x then descend (r, s) else
                     descend (r, z :: s) 
              | descend (z as RED (l, (x, _), r), s) =
                     if tooBig   x then descend (l, s) else
                     if tooSmall x then descend (r, s) else
                     descend (r, z :: s) 
         in
            descend (t, [])
         end      
   end
