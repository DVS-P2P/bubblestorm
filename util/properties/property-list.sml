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

structure PropertyList :> PROPERTY_LIST =
   struct
      type t = UniversalType.t list ref
      
      fun new () = ref []
      
      fun 'a newProperty () =
         let
            open List
            val (inject, extract) = UniversalType.embed ()
         in {
            peek = fn list =>
               Option.map (valOf o extract) (find (isSome o extract) (!list)),
            remove = fn list => 
               list := filter (not o isSome o extract) (!list),
            add = fn (list, x) =>
               list := inject x :: !list
            } 
         end
   end
