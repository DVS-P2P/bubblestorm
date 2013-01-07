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

structure StoragePool :> STORAGE_POOL =
   struct
      val module = "bubblestorm/bubble/managed/storage-pool"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)

      structure Order = OrderFromCompare(
         struct
            type t = Density.t * StorageService.Description.t option
            
            fun compare ((posA, serviceA), (posB, serviceB)) =
               case Density.compare (posA, posB) of
                  EQUAL => (
                     case (serviceA, serviceB) of
                        (SOME x, SOME y) => StorageService.Description.compare (x, y)
                      | (NONE, SOME _) => LESS
                      | (SOME _, NONE) => GREATER
                      | (NONE, NONE) => EQUAL
                  )
                | x => x 
         end)

      structure Tree = Tree(Order)
      
      structure Table = HashTable(StorageService.Description)
      
      exception KeyExists
      exception KeyDoesNotExist = Table.KeyDoesNotExist
      
      datatype pool = T of {
         tree : StoragePeer.t Tree.t,
         lookup : Density.t Table.t
      }
      type t = pool ref
      
      fun new () = ref (T {
               tree = Tree.empty,
               lookup = Table.new ()
            })

      fun get ((ref (T { tree, lookup })), service) =
         case Table.get (lookup, service) of
            NONE => NONE
          | SOME pos =>
               case Tree.find (tree, (pos, SOME service)) of
                  storage :: nil => SOME (pos, storage)
                | _ => raise At (module, Fail "tree inconsistent")
      
      fun add (this as ref (T { tree, lookup }), pos, storage) =
         let
            val service = StoragePeer.service storage
            val () = log (fn () => "adding " ^ StorageService.Description.toString service)
            val () = Table.add (lookup, service, pos)
            val tree = Tree.insert (tree, (pos, SOME service), storage)
         in
            this := T { tree = tree, lookup = lookup }
         end
         handle KeyExists => raise KeyExists (* to get rid of 'unused' warnings *)
         
      fun update (this as ref (T { tree, lookup }), pos, storage) =
         let
            val service = StoragePeer.service storage
            val () = log (fn () => "updating " ^ StorageService.Description.toString service)
            val (oldPos, _) = case get (this, service) of
                                 SOME x => x 
                               | NONE => raise KeyDoesNotExist
            val () = Table.update (lookup, service, pos)
            val (tree, oldEntry) = Tree.remove (tree, (oldPos, SOME service))
            val () = if Option.isSome oldEntry then () else
                     raise At (module, Fail "cannot update inconsistent tree")
            val tree = Tree.insert (tree, (pos, SOME service), storage)
         in
            this := T { tree = tree, lookup = lookup }
         end
         
      fun remove (this as ref (T { tree, lookup }), storage) =
         let
            val service = StoragePeer.service storage
            val () = log (fn () => "removing " ^ StorageService.Description.toString service)
            val pos = Table.remove (lookup, service)
            val (tree, _) = Tree.remove (tree, (pos, SOME service))
         in
            this := T { tree = tree, lookup = lookup }
         end
         
      fun iterator (ref (T { tree, ... })) =
         let
            val it = Tree.forward tree { left  = NONE, right = NONE }
         in
            Iterator.map (fn ((pos, _), peer) => (pos, peer)) it
         end
               
      fun range (ref (T { tree, ... }), (from, to)) =
         let
            val it = Tree.forward tree {
               left  = SOME (from, NONE),
               right = SOME (to,   NONE)
            }
         in
            Iterator.map (fn ((pos, _), peer) => (pos, peer)) it
         end
      
      fun size (ref (T { lookup, ... })) = Table.size lookup
   end
