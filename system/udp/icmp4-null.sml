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

(* Fake implementation for being used when there is no way of getting ICMP to work. *)
structure ICMP4Null : ICMP_PRIMITIVE =
   struct
      type address = INetSock.sock_addr
	  
      fun new _ =
         let
            fun close () = ()
            fun newR () =
               let
                  fun recv _ = NONE
                  fun closeR () = ()
               in
                  { recv=recv, closeR=closeR }
               end
            fun newS () =
               let
                  fun send _ = ()
                  fun closeS () = ()
               in
                  { send=send, closeS=closeS }
               end
         in
            { close=close, newR=newR, newS=newS }
         end
   end
