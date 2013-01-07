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

(* MLton is not multi-threaded *)
structure OncePerThread :> ONCE =
   struct
      type 'a t = 'a
      
      fun new f = f ()
      fun get (x, f) = f x
   end

structure OncePerEntry :> ONCE =
   struct
      type 'a t = 'a option ref * (unit -> 'a)
      
      fun new f = (ref NONE, f)
      
      fun get ((box as ref (SOME x), _), g) = 
            let
               val () = box := NONE
               val out = g x
               val () = box := SOME x
            in
               out
            end
        | get ((box, f), g) =
              let
                 val x = f ()
                 val out = g x
                 val () = box := SOME x
              in
                 out
              end 
   end
