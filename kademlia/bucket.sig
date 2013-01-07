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

signature BUCKET =
   sig
      structure Id : ID
      structure Address : ADDRESS
      structure Contact : CONTACT where type Id.t = Id.t and type Address.t = Address.t
      
      type t
      
      val new : int -> t
      
      (* Returns the list of entries. *)
      val entries : t -> Contact.t Iterator.t
      
      (* Returns the number of entries currently stored. *)
      val size : t -> int
      
      val isEmpty : t -> bool
      
      (* Updates (or adds or ignores) a seen node,
         returns whether node has been added *)
      val updateNode : t * Id.t * Address.t -> bool

      (* Notifies about a timeout when talking to a node *)
      val nodeTimeout : t * Id.t -> unit
      
      val toString : t -> string
      
   end
