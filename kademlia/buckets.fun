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

functor Buckets (
      structure Event : EVENT
      structure NodeRPC : NODE_RPC
   ) : BUCKETS
   =
   struct
      structure Id = NodeRPC.Id
      structure Address = NodeRPC.Address
      structure Bucket = Bucket (
         structure Event = Event
         structure NodeRPC = NodeRPC
      )
      
      (* data type *)
      datatype fields = T of {
         myId : Id.t,
         buckets : Bucket.t vector
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      (* TODO relaxed routing table *)
      
      fun new (myId, bucketSize) =
         let
            val buckets = Vector.tabulate (Id.numberOfBits, fn _ => Bucket.new bucketSize)
            val this = T {
               myId = myId,
               buckets = buckets
            }
         in
            this
         end
      
      fun bucketId (this, id) =
         Id.highestOneBit (Id.xor (get#myId this, id))
      
      fun updateNode (this, id, addr) =
(*          if Id.== (id, get#myId this) then true else (* ignore my ID *) *)
         let
            val bid = bucketId (this, id)
         in
            if bid >= 0
            then Bucket.updateNode (Vector.sub (get#buckets this, bid), id, addr)
            else false
         end
      
      fun nodeTimeout (this, id) =
(*          if Id.== (id, get#myId this) then true else (* ignore my ID *) *)
         let
            val bid = bucketId (this, id)
         in
            if bid >= 0
            then Bucket.nodeTimeout (Vector.sub (get#buckets this, bid), id)
            else ()
         end
      
      fun getCloseNodes (this, {targetId, requestorId, count}) =
         (* bucket traversal order: start with primary bucket for ID,
            proceed by descending buckets for which XOR'ed ID bit is 1,
            finally ascend buckets for which XOR'ed ID bit is 0
         *)
         let
            val idX = Id.xor (get#myId this, targetId)
(*             val () = print ("... highest 1 bit: " ^ Int.toString (Id.highestOneBit idX) ^ "\n") *)
            
            fun getEntries bid =
               let
                  val bucket = Vector.sub (get#buckets this, bid)
                  val entries =
                     Iterator.toList
                        (Iterator.filter
                         (fn e => not (Id.== (Bucket.Contact.id e, requestorId)))
                         (Bucket.entries bucket))
                  val le = List.length entries
               in
                  (entries, le)
               end
            
            fun getNodeAscend (bid, count) =
               if bid < Id.numberOfBits then
                  if not (Id.getBit (idX, bid)) then
                     let
                        val (entries, le) = getEntries bid
(*                        val () = print ("... asc from bucket #" ^ Int.toString bid
                           ^ " (" ^ Int.toString le ^ ")\n")*)
                     in
                        if le >= count
                        then List.take (entries, count)
                        else (entries @ getNodeAscend (bid + 1, count - le))
                     end
                  else
                     getNodeAscend (bid + 1, count)
               else
                  nil
            
            fun getNodesDescend (bid, count) =
               if bid >= 0 then
                  if Id.getBit (idX, bid) then
                     let
                        val (entries, le) = getEntries bid
(*                        val () = print ("... desc from bucket #" ^ Int.toString bid
                           ^ " (" ^ Int.toString le ^ ")\n")*)
                     in
                        if le >= count
                        then List.take (entries, count)
                        else (entries @ getNodesDescend (bid - 1, count - le))
                     end
                  else
                     getNodesDescend (bid - 1, count)
               else
                  getNodeAscend (0, count)
         in
            getNodesDescend (Id.highestOneBit idX, count)
         end
      
      fun countCloserNodes (this, id) =
         let
            val myId = get#myId this
            val xid = Id.xor (id, myId)
            fun countCloser (e, c) =
               if Id.< (Id.xor (Bucket.Contact.id e, myId), xid) then c + 1
               else c
               
            val buckets = get#buckets this
            fun countAll bid =
               if bid < 0 then 0
               else
                  Bucket.size (Vector.sub (buckets, bid))
                     + countAll (bid - 1)
            val bid = bucketId (this, id)
         in
            Iterator.fold countCloser 0 (Bucket.entries (Vector.sub (buckets, bid)))
               + countAll (bid - 1)
         end
      
      fun isEmpty (this, bid) =
         Bucket.isEmpty (Vector.sub (get#buckets this, bid))
      
      fun bucketSize (this, bid) =
         Bucket.size (Vector.sub (get#buckets this, bid))
      
      fun knowNodesCloserTo (this, id) =
         let
            fun checkBucket bid =
               if bid < 0 then false
               else
                  if isEmpty (this, bid)
                  then checkBucket (bid - 1)
                  else true
            val bid = bucketId (this, id)
         in
            checkBucket bid
         end
      
(*      fun countNodesCloserTo (this, id) =
         let
            fun checkBucket (bid, c) =
               if bid >= 0
               then checkBucket (bid - 1, c + Bucket.size (Vector.sub (get#buckets this, bid)))
               else c
            val bid = bucketId (this, id)
         in
            checkBucket (bid, 0)
         end*)
      
      fun countCloserNodesFor (this, for, id) =
         let
            val forBid = bucketId (this, for)
            val idBid = bucketId (this, id)
            val buckets = get#buckets this
            
            fun countCloser bucket =
               let
                  val dist = Id.xor (for, id)
                  fun count (e, c) =
                     if Id.< (Id.xor (for, Bucket.Contact.id e), dist)
                     then c + 1
                     else c
               in
                  Iterator.fold
                  count
                  0
                  (Bucket.entries bucket)
               end
            
(*            fun ascend (bid, c) =
               if bid < Id.numberOfBits then
                  if bid = idBid then
                     c + countCloser (Vector.sub (buckets, bid))
                  else
                     ascend (bid + 1, c + bucketSize (this, bid))
               else
                  c + bucketSize (this, bid)
            
            fun descend (bid, c) =
               if bid >= 0 then
                  if bid = idBid then
                     c + countCloser (Vector.sub (buckets, bid))
                  else
                     descend (bid - 1, c + bucketSize (this, bid))
               else
                  ascend (0, c + bucketSize (this, bid))*)
         in
(*             descend (forBid, 0) *)
            if forBid = idBid then countCloser (Vector.sub (buckets, forBid))
            else
               if forBid > idBid then bucketSize (this, forBid)
               else
                  Iterator.fold
                  (fn (bid, c) => c + bucketSize (this, bid))
                  0
                  (Iterator.fromInterval {start=0, stop=idBid, step=1})
         end
      
      fun toString this =
         let
            fun map (i, bucket) =
               if Bucket.isEmpty bucket
               then ""
               else ("### " ^ Int.toString i ^ " ###\n" ^ Bucket.toString bucket)
            val it = Iterator.fromVector (Vector.mapi map (get#buckets this))
         in
            String.concat (Iterator.toList it)
         end
      
   end
