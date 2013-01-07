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

functor Contact(
      structure Event : EVENT
      structure Address : ADDRESS
      structure Id : ID
   ) : CONTACT
   =
   struct
      structure Id = Id
      structure Address = Address
      
      datatype fields = T of {
         id: Id.t,
         addr: Address.t ref,
         lastSeen: Time.t ref,
         timeouts: int ref
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      fun new (id, addr) =
         T {
            id = id,
            addr = ref addr,
            lastSeen = ref (Event.time ()),
            timeouts = ref 0
         }
      
      fun id this = get#id this
      
      fun address this = !(get#addr this)
      
      fun updateAddress (this, newAddr) =
         (get#addr this) := newAddr
      
      fun idAddr this = (get#id this, !(get#addr this))
      
      fun updateLastSeen this =
         (get#lastSeen this := Event.time ();
         get#timeouts this := 0)
      
      fun incTimeouts this =
         let
            val timeouts = get#timeouts this
         in
            timeouts := !timeouts + 1
         end
      
      fun getTimeouts this = !(get#timeouts this)
      
      fun toString this =
         Id.toString (id this) ^ ": " ^ Address.toString (address this)
      
   end
