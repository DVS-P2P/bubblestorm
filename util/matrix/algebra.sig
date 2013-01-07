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

signature ELEMENT =
   sig
      type t
      val zero : t
      val one : t
      val * : t * t -> t
      val / : t * t -> t
      val + : t * t -> t
      val - : t * t -> t
      val < : t * t -> bool
   end

signature ALGEBRA =
   sig
      structure Element : ELEMENT
      
      (* Vectors have "infinite" length ... in that they are zero extended *)
      structure Vector :
         sig
            type t
            
            val zero : t
            val + : t * t -> t
            val - : t * t -> t
            val * : t * t -> t
            val dot : t * t -> Element.t
            val scale : t * Element.t -> t
            val sub : t -> int -> Element.t
            
            (* The maximum of the elements in the vector *)
            val max : t -> Element.t
            val min : t -> Element.t
            (* Sum all the non-zero elements *)
            val sum : t -> Element.t
            (* Map all the non-zero elements through this function *)
            val mapi : (int * Element.t -> Element.t) -> t -> t
            val map : (Element.t -> Element.t) -> t -> t
            
            val fromArray : Element.t array * int -> t
            
            val tabulate : {
               start  : int,
               length : int,
               fetch  : int -> Element.t
            } -> t
            datatype order = TOP_DOWN | BOTTOM_UP
            val unfold : {
               start  : int,
               length : int,
               order  : order,
               fetch  : t * int -> Element.t
            } -> t
         end
      
      (* Matrices also have infinite length, but they guarantee to have zero
       * entries outside their dimeneions and bandwidth.
       *)
      structure Matrix :
         sig
            type t
            
            val + : t * t -> t
            val - : t * t -> t
            val * : t * t -> t
            
            val map : t * Vector.t -> Vector.t
            val row : t -> int -> Vector.t
            val column : t -> int -> Vector.t
            val sub : t -> int * int -> Element.t
            
            val dimension : t -> int * int
            val bandwidth : t -> int * int
            val symmetric : t -> bool
            
            val transpose : t -> t
            (* If updating a symmetric matrix, update the transpose too! *)
            val update : t -> int * int * Element.t -> unit
            
            val tabulate : {
               dimension : int * int, (* (rows,  cols)  *)
               bandwidth : int * int, (* (lower, upper) *)
               symmetric : bool,
               fetch     : int * int -> Element.t
            } -> t
            val unfold : {
               dimension : int * int, (* (rows,  cols)  *)
               bandwidth : int * int, (* (lower, upper) *)
               symmetric : bool,
               fetch     : t * int * int -> Element.t
            } -> t
            
            val toIterator : t -> (int * int * Element.t) Iterator.t
            (* Walk only the non-zero non-symmetric entries *)
            val toBandedIterator : t -> (int * int * Element.t) Iterator.t
            
            (* Row/column iterator *)
            val rows : t -> (int * Vector.t) Iterator.t
            val columns : t -> (int * Vector.t) Iterator.t
            
            (* Pretty print *)
            val toString : (Element.t -> string) -> t -> string
         end
   end
