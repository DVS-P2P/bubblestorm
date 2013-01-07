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

structure ManagedDataStore :> MANAGED_DATA_STORE =
   struct
      type 'a interface = {
         insert : ID.t * 'a * (unit -> unit) * bool -> unit,
         update : ID.t * 'a * (unit -> unit) -> unit,
         delete : ID.t * (unit -> unit) -> unit,
         get    : ID.t -> 'a option,
         flush  : (bool -> bool) -> unit,
         size   : unit -> int
      }
      
      datatype t = T of Word8Vector.vector interface

      fun new interface = T interface

      fun insert (T { insert, ... }) x = insert x
      fun update (T { update, ... }) x = update x
      fun delete (T { delete, ... }) x = delete x
      fun flush  (T { flush,  ... }) x = flush x
      fun size   (T { size,   ... }) x = size x

      fun map ({insert, update, delete, get, flush, size}, load, store) =
         {
            insert = fn (id, data, done, bucket) => insert (id, load data, done, bucket),
            update = fn (id, data, done) => update (id, load data, done),
            get    = fn x => Option.map store (get x),
            delete = delete,
            flush  = flush,
            size   = size
         }

      fun encode (interface, serial) =
         map (interface, #fromVector (Serial.methods serial), #toVector (Serial.methods serial))
      
      fun monitor ({insert, update, delete, get, flush, size}, notify) =
         {
            insert = fn (id, data, done, bucket) => 
               insert (id, data, 
                  fn () => let val () = done () in notify (id, data, NONE) end, bucket),
            update = fn (id, data, done) =>
               let
                  val old = get id
               in
                  update (id, data, fn () => let val () = done () in notify (id, data, old) end)
               end,
            get    = get,
            delete = delete,
            flush  = flush,
            size   = size
         }
   end
