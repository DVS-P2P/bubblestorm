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

signature VALUE_STORE =
   sig
      structure Id : ID
      structure Node : NODE where type Id.t = Id.t
(*       structure Value : VALUE where type Id.t = Id.t *)
      
      type t
      
      val new : unit -> t
      val destroy : t -> unit
      
      val setNode : t * Node.t -> unit
      
      val storeHandler : t -> Node.storeHandler
      val retrieveHandler : t -> Node.retrieveHandler
      
      val valuesIterator : t -> Node.valuesIterator
   end
