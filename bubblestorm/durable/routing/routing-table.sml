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

structure RoutingTable :> ROUTING_TABLE =
   struct
      structure HashTable = HashTable(ID)
      
      type entry = {
         service   : Service.stub,
         bucket    : bool,
         myBubble  : bool,
         hisBubble : bool,
         alive     : bool
      } ref
      
      datatype t = T of {
         table : entry HashTable.t,
         count : int ref,
         replicate : ID.t * Service.stub -> unit,
         contact   : ID.t * Service.stub -> unit,
         quit      : ID.t * Service.stub -> unit
      }

      fun new { replicate, contact, quit } =
         T {
            table = HashTable.new (),
            count = ref 0,
            replicate = replicate,
            contact = contact,
            quit = quit
         }
         
      (* contact + (if not exists then replicate, add hisBubble else set hisBubble) *)
      fun insert (T this) (id, service, done, bucket) =
         let
            val () = (#contact this) (id, service)
            val () = (#count this) := !(#count this) + 1
            val () = case HashTable.get (#table this, id) of
                  NONE =>
                     let
                        val () = HashTable.set (#table this, id, ref {
                           service   = service,
                           bucket    = bucket,
                           myBubble  = false,
                           hisBubble = true,
                           alive     = true
                        })
                     in
                        (#replicate this) (id, service)
                     end
                | SOME entry =>
                     entry := {
                        service   = service,
                        bucket    = bucket,
                        myBubble  = #myBubble (!entry),
                        hisBubble = true,
                        alive     = true
                     }
         in
            done ()
         end
  
      fun update _ _ = () (* ignore updates *)

      (* if myBubble then unset hisBubble else remove
         used internally by delete and flush *)
      fun remove (T this) (id, entry) =
         let
            val () = (#quit this) (id, #service (!entry))
            val () = (#count this) := !(#count this) - 1
         in
            if #myBubble (!entry) then
               entry := {
                  service   = #service (!entry),
                  bucket    = false,
                  myBubble  = true,
                  hisBubble = false,
                  alive     = true
               }
            else ignore (HashTable.remove (#table this, id))
         end
         
      (* quit + remove *)
      fun delete (T this) (id, done) =
         let
            val () = case HashTable.get (#table this, id) of
               NONE => () (* shouldn't happen *)
             | SOME entry => remove (T this) (id, entry)
         in
            done ()
         end
         
      (* if hisBubble and bucket then remove *)
      fun flush (T this) filter =
         let
            fun perItem (id, entry) =
               if #hisBubble (!entry) andalso filter (#bucket (!entry))
                  then remove (T this) (id, entry)
               else ()
         in
            Iterator.app perItem (HashTable.iterator (#table this))
         end

      fun get (T this) id =
         case HashTable.get (#table this, id) of
               NONE => NONE
             | SOME entry =>
               if (#hisBubble (!entry)) then SOME (#service (!entry)) else NONE

      (* count where hisBubble *)
      fun size (T this) () = !(#count this)

      fun managed this =
         {
            insert = insert this,
            update = update this,
            delete = delete this,
            get    = get this,
            flush  = flush this,
            size   = size this
         }

      (* if exists then set myBubble else add myBubble, replicate *)
      fun contact (T this, id, service) =
         case HashTable.get (#table this, id) of
            NONE =>
               let
                  val () = HashTable.set (#table this, id, ref {
                     service   = service,
                     bucket    = false,
                     myBubble  = true,
                     hisBubble = false,
                     alive     = true
                  })
               in
                  (#replicate this) (id, service)
               end
          | SOME entry =>
               entry := {
                  service   = service,
                  bucket    = #bucket (!entry),
                  myBubble  = true,
                  hisBubble = #hisBubble (!entry),
                  alive     = true
               }
               
      (* if hisBubble then unset myBubble else remove *)
      fun quit (T this, id) =
         case HashTable.get (#table this, id) of
            NONE => () (* shouldn't happen *)
          | SOME entry =>
               if #hisBubble (!entry) then
                  entry := {
                     service   = #service (!entry),
                     bucket    = #bucket (!entry),
                     myBubble  = false,
                     hisBubble = true,
                     alive     = true
                  }
               else ignore (HashTable.remove (#table this, id))

      fun markDead (T this, id) = ()
(*         case HashTable.get (#table this, id) of
            NONE => ()
          | SOME entry =>
               entry := {
                  service   = #service (!entry),
                  bucket    = #bucket (!entry),
                  myBubble  = #myBubble (!entry),
                  hisBubble = #hisBubble (!entry),
                  alive     = false
               }
*)      
      fun iterator (T this) =
         let
            fun alive (id, entry) = 
               if (#alive (!entry)) then SOME (id, #service (!entry)) else NONE
         in
            Iterator.mapPartial alive (HashTable.iterator (#table this))
         end
         
      fun size (T this) = Iterator.length (iterator (T this))
      (* HashTable.size (#table this) *)
   end
