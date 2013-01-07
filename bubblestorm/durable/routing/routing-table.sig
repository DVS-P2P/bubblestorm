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

signature ROUTING_TABLE =
   sig
      type t

      val new : {
         replicate : ID.t * Service.stub -> unit,
         contact   : ID.t * Service.stub -> unit,
         quit      : ID.t * Service.stub -> unit
      } -> t
      
      val managed  : t -> Service.stub ManagedDataStore.interface

      val contact  : t * ID.t * Service.stub -> unit
      
      val quit     : t * ID.t -> unit
      
      val iterator : t -> (ID.t * Service.stub) Iterator.t
      
      val markDead : t * ID.t -> unit
      
      val size     : t -> int
   end
