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

functor HashAlgorithm(Base : HASH_PRIMITIVE)
   :> HASH_ALGORITHM where type input = Base.initial
                     where type output = Base.final =
   struct
      type state = Base.state
      type input = Base.initial
      type output = Base.final
      
      type 'a t = 'a * input -> output
      
      fun make f (x, init) =
         let
            val state = Base.start init
            val Hash.S (state, _) = f x state
         in
            Base.stop state
         end 
   end
