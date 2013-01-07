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

signature ARGUMENT_PARSER =
   sig
      type t
      
      exception ParameterMissing of string
      exception UnparseableValue of string * string
      exception ParseException of string * exn
      exception IllegalArgSequence

      val new : string list * string option -> t * string list
      val empty : unit -> t
      
      val flag        : t -> string * char -> bool
      val exactlyOnce : t -> string * char * (string -> 'a option) -> 'a
      val optional    : t -> string * char * (string -> 'a option) -> 'a option
      val atLeastOnce : t -> string * char * (string -> 'a option) -> 'a list
      val any         : t -> string * char * (string -> 'a option) -> 'a list
      
      val complainUnused : t -> string list
   end

