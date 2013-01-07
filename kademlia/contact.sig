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

signature CONTACT =
   sig
      structure Id : ID
      structure Address : ADDRESS
      
      type t
      
      val new : Id.t * Address.t -> t
      
      val id : t -> Id.t
      
      val address : t -> Address.t
      
      val updateAddress : t * Address.t -> unit
      
      val idAddr : t -> (Id.t * Address.t)
      
      val updateLastSeen : t -> unit
      
      val incTimeouts : t -> unit
      
      val getTimeouts : t -> int
      
      val toString : t -> string
      
   end
