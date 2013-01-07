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

(* To understand the types involved here, recall the definition of fold/foldr:
 * foldl (a, f) (step0 g1) (step0 g2) (step0 g3) ... (step0 gy) (step0 gz) $
 *     = f (gz (gy (... (g3 (g2 (g1 a))))))
 * foldr (a, f) (step0 gz) (step0 gy) ... (step0 g3) (step0 g2) (step0 g1) $
 *     = f (gz (gy (... (g3 (g2 (g1 a))))))
 *
 * The variable typed piece involed here is the accumulator as it is passed
 * along the composition of functions. At every step along the way, either
 * the gX function is composed with f or evaluated on a.
 *
 * 'r  is the result of the final invocation of f on the accumulated a
 * 'az is the final type of a before given to f
 * 'a0 is the type of a before being handed off to g1
 *
 * It follows that 'ay is the type given to gz : 'ay -> 'az
 *        and that 'a1 is the type given by g1 : 'a0 -> 'a1
 *)
structure Fold : FOLD =
   struct
      type ('a0, 'az, 'r) t = 'a0 * ('az -> 'r)
      type ('a0, 'ay, 'az, 'r) fold = (('a0, 'ay, 'az) t -> 'r) -> 'r
      type ('a0, 'a1, 'ay, 'az, 'r) step0 = ('a0, 'ay, 'az) t -> ('a1, 'ay, 'az, 'r) fold
      type ('b, 'a0, 'a1, 'ay, 'az, 'r) step1 = ('a0, 'ay, 'az) t -> 'b -> ('a1, 'ay, 'az, 'r) fold
      type ('b, 'c, 'a0, 'a1, 'ay, 'az, 'r) step2 = ('a0, 'ay, 'az) t -> 'b -> 'c -> ('a1, 'ay, 'az, 'r) fold
      
      fun fold (a, f) g = g (a, f)
      fun post (w, g) s = w (fn (a, h) => s (a, g o h))
      
      fun step0 h (a, f)     = fold (h a, f)
      fun step1 h (a, f) b   = fold (h (b, a), f)
      fun step2 h (a, f) b c = fold (h (b, c, a), f) 
   end

structure FoldR : FOLDR =
   struct
      type ('a0, 'az, 'r) t = 'a0 * ('az -> 'r)
      type ('a0, 'ay, 'az, 'r) fold = (('a0, 'ay, 'az) t -> 'r) -> 'r
      type ('ax, 'ay, 'a0, 'az, 'r) step0 = ('a0, 'ay, 'az) t -> ('a0, 'ax, 'az, 'r) fold
      type ('b, 'ax, 'ay, 'a0, 'az, 'r) step1 = ('a0, 'ay, 'az) t -> 'b -> ('a0, 'ax, 'az, 'r) fold
      type ('b, 'c, 'ax, 'ay, 'a0, 'az, 'r) step2 = ('a0, 'ay, 'az) t -> 'b -> 'c -> ('a0, 'ax, 'az, 'r) fold
      
      val fold = Fold.fold
      val post = Fold.post
      
      fun step0 h (a, f)     = fold (a, f o h)
      fun step1 h (a, f) b   = fold (a, fn a => f (h (b, a)))
      fun step2 h (a, f) b c = fold (a, fn a => f (h (b, c, a)))
   end
