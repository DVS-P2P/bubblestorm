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

signature IP_STACK =
   sig
      type t

      (* The message will be sent at 'when' which never earlier than now.
       * Some networking components (OutQueue) may require when=now.
       *)
      val send : {
         stack    : t,
         port     : Word16.word,
         receiver : Address.t,
         data     : Routing.message,
         size     : int,
         when     : Time.t
      } -> unit

      (* Internal bind sets the receive callback for a node. *)
      val bind : Routing.msgHandler -> t
      val close : t -> unit
   end
