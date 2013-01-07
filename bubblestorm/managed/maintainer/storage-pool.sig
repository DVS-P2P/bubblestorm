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

signature STORAGE_POOL =
   sig
      type t
            
      exception KeyDoesNotExist
      
      val new : unit -> t
      
      val get : t * StorageService.Description.t -> (Density.t * StoragePeer.t) option
      
      val add    : t * Density.t * StoragePeer.t -> unit (* raises KeyExists *)
      val update : t * Density.t * StoragePeer.t -> unit (* raises KeyDoesNotExist *)
      val remove : t * StoragePeer.t -> unit (* raises KeyDoesNotExist *)
      
      val iterator : t  -> (Density.t * StoragePeer.t) Iterator.t
      val range    : t * Density.range -> (Density.t * StoragePeer.t) Iterator.t
      val size : t -> int
   end
