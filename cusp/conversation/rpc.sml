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

signature RPC =
   sig
      val new : string * 'a -> 'b * ('a, 'b, 'c) Serial.t * 
   end

structure RPC =
   struct
   end


datatype foo = FOO of int -> 'a


caller finish -> 
  close
  on ack, unbind shares
  notify user

callee finish ->
  raise exception if used later


entry/method? ... passing a method via a third party
  ... starts a new conversation or not
  => NEED

why would i need my own context? -> report caller to log
  global variable grab? would be useful to log later
  => GLOBAL VAR

... how to get handle on calls?

