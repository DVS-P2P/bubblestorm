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

structure DurableDataStore :> DURABLE_DATA_STORE =
   struct
      type 'a interface = {
         store    : ID.t * Version.t * 'a option * (bool -> unit) -> unit,
         lookup   : ID.t * ((Version.t * 'a option) option -> unit) -> unit,
         remove   : ID.t -> unit,
         iterator : ((ID.t * Version.t * 'a option) Iterator.t -> unit) -> unit,
         size     : unit -> int
      }
      
      datatype t = T of Word8Vector.vector interface

      fun new interface = T interface

      fun mapStore (store, decode) (id, version, data, success) =
         store (id, version, Option.map decode data, success)
         
      fun mapLookup (lookup, encode) (id, callback) =
         let
            fun map (version, data) = (version, Option.map encode data)
            fun getResult result = callback (Option.map map result)
         in
            lookup (id, getResult)
         end
      
      fun mapIterator (iterator, encode) callback =
         let
            fun map (id, version, data) = (id, version, Option.map encode data)
            fun getIterator it = callback (Iterator.map map it)
         in
            iterator getIterator
         end
         
      fun map ({store, lookup, remove, iterator, size}, decode, encode) =
         {
            store = mapStore (store, decode),
            lookup = mapLookup (lookup, encode),
            remove = remove,
            iterator = mapIterator (iterator, encode),
            size   = size
         }

      fun encode (interface, serial) = map (
         interface, 
         #fromVector (Serial.methods serial),
         #toVector (Serial.methods serial)
      )
      
      fun hookMonitor (store, lookup, notify) (id, version, data, success) = 
         let
            fun onSuccess old storedSuccessfully =
               let
                  val () = if storedSuccessfully then notify (id, data, old) else ()
               in
                  success storedSuccessfully
               end

            fun getCurrent current =
               store (id, version, data, onSuccess (Option.map (fn (_, d) => d) current))
         in
            lookup (id, getCurrent)
         end

      fun monitor ({store, lookup, remove, iterator, size}, notify) =
         {
            store    = hookMonitor (store, lookup, notify),
            remove   = remove,
            lookup   = lookup,
            iterator = iterator,
            size     = size
         }

      fun store    (T { store,    ... }) x = store x
      fun lookup   (T { lookup,   ... }) x = lookup x
      fun remove   (T { remove,   ... }) x = remove x
      fun iterator (T { iterator, ... }) x = iterator x
      fun size     (T { size,     ... }) x = size x
   end
