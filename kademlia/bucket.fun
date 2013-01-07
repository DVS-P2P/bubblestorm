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

functor Bucket (
      structure Event : EVENT
      structure NodeRPC : NODE_RPC
   ) : BUCKET
   =
   struct
      structure Id = NodeRPC.Id
      structure Address = NodeRPC.Address
      structure Contact = Contact (
         structure Event = Event
         structure Address = NodeRPC.Address
         structure Id = Id
      )
      
      open Log
      
      (* data type *)
      structure RingMap = RingMap(Id)
      datatype fields = T of {
         maxSize : int,
         entries : Contact.t RingMap.t,
         replacementCache : Contact.t RingMap.t
      }
      withtype t = fields
      fun get f (T fields) = f fields

      val staleTimeouts = 3 (* timeouts until node becomes stale *)
      
      fun new bucketSize =
         T {
            maxSize = bucketSize, (* Kademlia's k *)
            entries = RingMap.new (),
            replacementCache = RingMap.new ()
         }
      
      fun entries this =
         Iterator.map
         RingMap.unwrap
         (RingMap.iterator (get#entries this))
      
      fun isStale contact =
         Contact.getTimeouts contact >= staleTimeouts
      
      fun size this =
         RingMap.size (get#entries this)
      
      fun isEmpty this =
         RingMap.isEmpty (get#entries this)
      
      (* checks whether least-recently seen node is still alive and replace it if not *)
      fun checkReplace (this, contact) =
         let
            fun replace oldContact =
               let
                  val () =
                     log (DEBUG, "kademlia/bucket",
                        fn () => "Replcaing contact " ^ Contact.toString oldContact
                           ^ " with " ^ Contact.toString contact)
                  val contactId = Contact.id contact
                  val entries = get#entries this
                  val replacementCache = get#replacementCache this
                  (* remove old contact from entries *)
                  val () =
                     RingMap.remove (entries, Contact.id oldContact)
                  (* remove new contact from replacement cache *)
                  val () =
                     if RingMap.contains (replacementCache, contactId)
                     then RingMap.remove (replacementCache, contactId)
                     else ()
               in
                  RingMap.addHead (entries, contactId, contact)
               end
            
            fun addToCache () =
               let
                  val contactId = Contact.id contact
                  val replacementCache = get#replacementCache this
                  
                  fun add () =
                     let
                        val () =
                           if (RingMap.size replacementCache) >= (get#maxSize this)
                           then
                              RingMap.remove (replacementCache,
                                 Contact.id (RingMap.unwrap (Option.valOf
                                    (RingMap.tail replacementCache))))
                           else ()
                     in
                        RingMap.addHead (replacementCache, contactId, contact)
                     end
               in
                  case RingMap.get (replacementCache, contactId) of
                     SOME el => RingMap.moveHead (replacementCache, el)
                   | NONE => add ()
               end
         in
            case Iterator.getItem (Iterator.filter isStale (entries this)) of
               SOME (e, _) => replace e
             | NONE => addToCache ()
         end
      
      fun replaceFromCache (this, entry) =
         let
            val oldContact = RingMap.unwrap entry
            val () =
               log (DEBUG, "kademlia/bucket",
                  fn () => "Removing contact " ^ Contact.toString oldContact ^ " (timeout)")
            val entries = get#entries this
            val replacementCache = get#replacementCache this
            
            fun add el =
               let
                  val contact = RingMap.unwrap el
                  val contactId = Contact.id contact
                  val () = RingMap.remove (replacementCache, contactId)
                  val () =
                     log (DEBUG, "kademlia/bucket",
                        fn () => "Adding contact " ^ Contact.toString contact
                           ^ " from replacement cache")
               in
                  RingMap.addTail (entries, contactId, contact)
               end
            
            val () = RingMap.remove (entries, Contact.id oldContact)
         in
            case RingMap.head replacementCache of
               SOME el => add el
             | NONE => ()
         end
      
      fun updateNode (this, nodeId, nodeAddr) =
         let
            val entries = get#entries this
            
            fun updateEntry entry =
               let
                  val contact = RingMap.unwrap entry
                  val () = Contact.updateLastSeen contact
                  (* update address *)
                  val () =
                     if Address.!= (nodeAddr, Contact.address contact)
                     then
                        (log (DEBUG, "kademlia/bucket",
                           fn () => "Updating address of " ^ Contact.toString contact
                              ^ " to " ^ Address.toString nodeAddr)
                        ; Contact.updateAddress (contact, nodeAddr))
                     else ()
               in
                  RingMap.moveTail (entries, entry)
               end
            fun newEntry () =
               let
                  val contact = Contact.new (nodeId, nodeAddr)
                  val () =
                     log (DEBUG, "kademlia/bucket",
                        fn () => "Adding contact " ^ Contact.toString contact)
               in
                  if (size this) < (get#maxSize this)
                  then (RingMap.addTail (entries, nodeId, contact); true)
                  else (checkReplace (this, contact); false)
               end
         in
            case RingMap.get (entries, nodeId) of
               SOME e => (updateEntry e; false)
             | NONE => newEntry ()
         end
      
      fun nodeTimeout (this, nodeId) =
         let
            val entries = get#entries this
            
            fun timeoutEntry entry =
               let
                  val contact = Ring.unwrap entry
                  val () = Contact.incTimeouts contact
               in
                  if isStale contact
                  then replaceFromCache (this, entry)
                  else ()
               end
         in
            case RingMap.get (entries, nodeId) of
               SOME e => timeoutEntry e
             | NONE => ()
         end
            
      fun toString this =
         String.concat
            (Iterator.toList
               ((Iterator.map
               (fn x => (Contact.toString x ^ "\n"))
               (entries this))))
      
   end
