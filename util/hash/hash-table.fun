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

(* Cuckoo hash table. Average fill is >= 25% (more if only insertions made).
 * Overhead is thus 4 pointers in the table + 1 object heder for the record.
 * Storage overhead per element is thus 5 words = 20/40 bytes for 32/64 bit.
 *)
functor HashTable(Key : HASH_KEY) :> HASH_TABLE where type Key.t = Key.t =
   struct
      structure Key = Key
      open Key
      
      type 'a record = (Key.t * 'a) ref
      type 'a t = { mask: Word32.word,
                    seed : Word32.word,
                    fill: int,
                    table: 'a record option array } ref
      
      fun emptyData () =
         { mask = 0wx3,
           seed = 0w1, (* a counter for each rehash *)
           fill = 0,
           table = Array.array (4, NONE) }
      
      fun new () = ref (emptyData ())

      exception KeyExists
      exception KeyDoesNotExist

      val address = Word32.toInt o Word32.andb
      val hash = Lookup3.make Key.hash
      
      fun size (ref { mask=_, seed=_, fill, table=_ }) = fill
      fun isEmpty x = size x = 0
      
      fun clear this = this := emptyData ()
      
      fun get (ref { mask, seed, fill=_, table }, key) =
         let
            val (k1, k2) = hash (key, seed)

            fun try NONE = NONE
              | try (SOME (ref (k, v))) =
                  if k == key then SOME v else NONE

            fun fetch k = Array.sub (table, address (k, mask))
         in
            case try (fetch k1) of NONE => try (fetch k2) | x => x
         end
      
      fun modify (ref { mask, seed, fill=_, table }, key, map) =
         let
            val (k1, k2) = hash (key, seed)
            
            fun upd i = 
               case Array.sub (table, i) of
                   NONE => false
                | (SOME (r as ref (k, v))) =>
                      if k == key
                      then (r := (k, map v); true)
                      else false
         in
            if upd (address (k1, mask)) then () else
            if upd (address (k2, mask)) then () else
            raise KeyDoesNotExist
         end
      
      fun update (this, key, value) = modify (this, key, fn _ => value)

      (* This function accepts a record which was previously located at off.
       * It places that record in its alternative location. If this location
       * is full, it will displace that record as well.
       * If a loop is detected, returns a record that couldn't be stored.
       *)
      fun shove ({ mask, seed, table }, origoff, record) =
         let
            fun store (_, NONE) = NONE
              | store (prevoff, SOME (record as ref (k, _))) =
               let
                  val (h1, h2) = hash (k, seed)
                  val off2 = address (h2, mask)
                  val off = if off2 <> prevoff then off2 else address (h1, mask)
                  val old = Array.sub (table, off) (* move this now too *)
                  val () = Array.update (table, off, SOME record)
               in
                  if off = origoff then old else store (off, old)
               end
         in
            store (origoff, record)
         end

      fun rehash (cuckoo as ref { mask=_, seed, fill, table=old }) =
         let
            fun pickmask x =
               let
                  open Word32
                  infix 0 >> orb
                  val x = x orb (x >> 0w1)
                  val x = x orb (x >> 0w2)
                  val x = x orb (x >> 0w4)
                  val x = x orb (x >> 0w8)
                  val x = x orb (x >> 0w16)
               in
                  x
               end

            (* Rehash occures at 50% full. New fill must be < 33%. *)
            val minsize = fill * 3
            val mask = pickmask (Word32.fromInt minsize)
            val table = Array.array (Word32.toInt mask + 1, NONE)
            
            fun rawadd (cuckoo as { mask, seed, table }, 
                              record as ref (key, _)) =
               let
                  val (k1, k2) = hash (key, seed)
                  val off1 = address (k1, mask)
                  val off2 = address (k2, mask)
               in
                  case Array.sub (table, off2) of
                     NONE => (Array.update (table, off2, SOME record); NONE)
                   | SOME _ =>
                        case Array.sub (table, off1) of
                           NONE => (Array.update (table, off1, SOME record); NONE)
                         | old as SOME _ =>
                              (Array.update (table, off1, SOME record)
                               ; shove (cuckoo, off1, old))
               end

            fun attempt seed =
               let
(*
                  val () = print ("Rehash triggered: " ^ 
                                  Int.toString fill ^ "/" ^ Int.toString (Array.length old) ^
                                  " -> " ^ Int.toString (Array.length table) ^ 
                                  ", seed " ^ Word32.toString seed ^ "\n")
*)                  
                  val new = { mask = mask, seed = seed, table = table }
                  fun copy (_, SOME x) = SOME x
                    | copy (NONE, NONE) = NONE
                    | copy (SOME record, NONE) = rawadd (new, record)                
               in
                  case Array.foldl copy NONE old of
                     NONE => seed
                   | SOME _ => (Array.modify (fn _ => NONE) table 
                                ; attempt (seed + 0w1))
               end
            
            val seed = attempt (seed + 0w1) 
         in
            cuckoo := { mask = mask, seed = seed, fill = fill, table = table }
         end
      
      fun add (cuckoo as ref { mask, seed, fill, table }, key, value) =
         let
            val record = ref (key, value)
            val (k1, k2) = hash (key, seed)
            val off1 = address (k1, mask)
            val off2 = address (k2, mask)
            val insert =
               case Array.sub (table, off2) of
                  NONE =>
                     (case Array.sub (table, off1) of
                         NONE => (Array.update (table, off2, SOME record); NONE)
                       | SOME (ref (k, _)) =>
                            if k == key then raise KeyExists else
                            (Array.update (table, off2, SOME record); NONE))
                | SOME (ref (k, _)) =>
                     (if k == key then raise KeyExists else
                      case Array.sub (table, off1) of
                         NONE => (Array.update (table, off1, SOME record); NONE)
                       | old as SOME (ref (k, _)) =>
                            if k == key then raise KeyExists else
                            (Array.update (table, off1, SOME record)
                              ; shove ({ mask=mask, seed=seed, table=table }, off1, old)))
          in
             case insert of
                NONE => cuckoo := { mask=mask, seed=seed, fill=fill+1, table=table } 
              | SOME (ref (k, v)) => (rehash cuckoo; add (cuckoo, k, v)) 
         end
      
      fun set (cuckoo as ref { mask, seed, fill, table }, key, value) =
         let
            fun record () = ref (key, value)
            val (k1, k2) = hash (key, seed)
            val off1 = address (k1, mask)
            val off2 = address (k2, mask)
            
            datatype 'a what = GROW | REPLACE | OVERFLOW of 'a
            val insert =
               case Array.sub (table, off2) of
                  NONE =>
                     (case Array.sub (table, off1) of
                         NONE => (Array.update (table, off2, SOME (record ())); GROW)
                       | SOME (r as ref (k, _)) =>
                            if k == key 
                            then (r := (k, value); REPLACE)
                            else (Array.update (table, off2, SOME (record ())); GROW))
                | SOME (r as ref (k, _)) =>
                     (if k == key then (r := (k, value); REPLACE) else
                      case Array.sub (table, off1) of
                         NONE => (Array.update (table, off1, SOME (record ())); GROW)
                       | old as SOME (r as ref (k, _)) =>
                            if k == key then (r := (k, value); REPLACE) else
                            (Array.update (table, off1, SOME (record ()))
                              ; case shove ({ mask=mask, seed=seed, table=table }, off1, old) of
                                   NONE => GROW
                                 | SOME x => OVERFLOW x))
          in
             case insert of
                REPLACE => ()
              | GROW => cuckoo := { mask=mask, seed=seed, fill=fill+1, table=table } 
              | OVERFLOW (ref (k, v)) => (rehash cuckoo; set (cuckoo, k, v)) 
         end
      
      fun remove (cuckoo as ref { mask, seed, fill, table }, key) =
         let
            val (k1, k2) = hash (key, seed)
                         
            fun rem i = 
               case Array.sub (table, i) of
                   NONE => NONE
                | (SOME (ref (k, v))) =>
                      if k == key
                      then (Array.update (table, i, NONE); SOME v)
                      else NONE
            
            fun shrink () = 
               (cuckoo := { mask = mask, seed = seed, fill = fill-1, table = table }
                ; if fill*8 = Array.length table then rehash cuckoo else ())
         in
            case rem (address (k1, mask)) of
               SOME v => (shrink (); v)
             | NONE => 
                  case rem (address (k2, mask)) of
                     SOME v => (shrink (); v)
                   | NONE => raise KeyDoesNotExist
         end
      
(*
      fun mapelt table f i =
         case Array.sub (table, i) of
            NONE => NONE
          | SOME (ref (k, v)) => SOME (ref (k, f (k, v)))
      
      fun map f (ref { mask, seed, fill, table}) =
          ref { mask = mask,
                seed = seed,
                fill = fill,
                table = Array.tabulate (Array.length table,
                                        mapelt table f) }
*)
   
      fun iterator (ref { mask=_, seed=_, fill=_, table }) =
         Iterator.mapPartial
         (Option.map !)
         (Iterator.fromArraySlice (ArraySlice.full table))
   end
