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

signature PROPERTY =
   sig
      type ('object, 'value) init

      val initConst: 'value -> ('object, 'value) init
      val initFun: ('object -> 'value) -> ('object, 'value) init
      val initRaise: exn -> ('object, 'value) init
      
      (* It is ok to call remove if the object has no value *)

      val get: ('object -> PropertyList.t) * ('object, 'value) init -> {
         remove: 'object -> unit,
         get: 'object -> 'value
      }

      val getSet: ('object -> PropertyList.t) * ('object, 'value) init -> {
         remove: 'object -> unit,
         get: 'object -> 'value,
         set: 'object * 'value -> unit
      }

      (* Property can only be set or initialized once. *)
      val getSetOnce: ('object -> PropertyList.t) * ('object, 'value) init -> {
         remove: 'object -> unit,
         get: 'object -> 'value,
         set: 'object * 'value -> unit
      }
   end
