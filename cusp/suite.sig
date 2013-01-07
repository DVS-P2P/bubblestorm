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

signature SUITE_SET =
   sig
      type set
      eqtype suite
      
      (* Intersects two suite sets. *)
      val intersect : set * set -> set
      (* Creates the union of two suite sets. *)
      val union     : set * set -> set
      (* Removes the suites contained in one set from another. *)
      val subtract  : set * set -> set
      (* Checks whether the suite set is empty. *)
      val isEmpty   : set -> bool
      
      (* Checks wether the suite set contains a particular suite. *)
      val contains  : set * suite -> bool
      (* Creates a suite set containing one element. *)
      val element   : suite -> set
      
      (* Returns the cheapest suite from the set. *)
      val cheapest  : set -> suite option
      (* Returns an iterator over the set. *)
      val iterator  : set -> suite Iterator.t
      
      (* Returns the name of the suite. *)
      val name : suite -> string
      (* Returns the relative computational cost of the suite. *)
      val cost : suite -> Real32.real
      
      (* DO NOT USE! Only for C bindings. *)
      val fromMask : Word16.word -> set
      val toMask   : set -> Word16.word
      val fromValue : Word16.word -> suite
      val toValue   : suite -> Word16.word
      
      (* The set of all available suites. *)
      val all : set
      (* The default set of suites. *)
      val defaults : set
   end

signature SUITE =
   sig
      structure Symmetric : SUITE_SET
      structure PublicKey : SUITE_SET
   end
