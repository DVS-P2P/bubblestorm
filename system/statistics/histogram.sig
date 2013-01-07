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

signature HISTOGRAM =
   sig
      type t
      
      datatype bucket_mode =
         CONSTANT_SIZE of Real32.real
       | EXPONENTIAL_SIZE of Real.real
      
      val new : bucket_mode -> t
      val reset : t -> unit
      
      val add : t -> Real32.real -> unit
      val aggregate : t -> t -> unit

      val buckets : t -> (real * int * real) Iterator.t
   end
