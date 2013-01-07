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

signature ADDRESS_EXTRA =
   sig
      include ADDRESS
      
      val init : unit -> unit

      structure Ip :
         sig
            include SERIALIZABLE
            val invalid : t
            (*val fromString : string -> t list*)
            val fromWord32 : Word32.word -> t
            (*val toWord32 : t -> Word32.word*)
         end
         
      val invalidPort : Ip.t -> t
      val invalidIP : Word16.word -> t
      val fromIpPort : Ip.t * Word16.word -> t      
      val ip : t -> Ip.t
      val port : t -> Word16.word

      (*val setDefaultPort : Word16.word -> unit*)
      (*val defaultPort : unit -> Word16.word *)
   end
