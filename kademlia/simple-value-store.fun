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

functor SimpleValueStore(
      structure Event : EVENT
      structure Node : NODE
   ) : VALUE_STORE
   =
   struct
      structure Node = Node
(*       structure Value = Node.Value *)
      structure Id = Node.Id
      
      open Log
      
      (* constants *)
(*       val tExpireMax = Time.fromHours 24 *)
      val tRepublish = Time.fromHours 1
      val checkValueInterval = Time.fromMinutes 10
      
      (* statistics *)
      val statRepublishSuccess =
         Statistics.new {
            parents = nil,
            name = "republish success",
            units = "", (* TODO value *)
            label = "", (* TODO value *)
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }
      val statStoredValues =
         Statistics.new {
            parents = nil,
            name = "stored values",
            units = "", (* TODO value *)
            label = "", (* TODO value *)
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }

      (* value map types *)
      structure ValueMap = HashTable(Id)
      type valueMapEntry = {
         value      : Word8Vector.vector,
(*         publishDate    : Time.t,*)
         storeDate      : Time.t ref,
         expiryDate : Time.t
      }
      
      (* data type *)
      datatype fields = T of {
         node : Node.t option ref,
         values : valueMapEntry ValueMap.t,
         unhookCheckValue : (unit -> unit) ref
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      fun node this = Option.valOf (!(get#node this))
      
      fun checkValues this =
         let
            val values = get#values this
            val () =
               log (DEBUG, "kademlia/simpleValueStore/checkValue",
                  fn () => "Checking " ^ Int.toString (ValueMap.size values)
                     ^ " locally stored values for expiration/republish.")
            val now = Event.time ()
(*             val checked = ref 0 *)
            fun check (id, { value, (*publishDate,*) storeDate, expiryDate }) =
               let
(*                  val () = 
                     log (DEBUG, "kademlia/simpleValueStore/checkValue",
                        fn () => "Check value " ^ Id.toString key)*)
                  fun expire () =
                     let
                        val () =
                           log (DEBUG, "kademlia/simpleValueStore/checkValue/expire",
                              fn () => "Value " ^ Id.toString id ^ " expired.")
                     in
                        ignore (ValueMap.remove (values, id))
                     end
                  fun republish () =
                     let
                        val () =
                           log (DEBUG, "kademlia/simpleValueStore/checkValue/republish",
                              fn () => "Republishing value " ^ Id.toString id)
                        fun storeCb c =
                           if c > 0 then
                              Statistics.add statRepublishSuccess 1.0
                           else
                              (log (WARNING, "kademlia/simpleValueStore/checkValue/republish",
                                 fn () => "Storing value " ^ Id.toString id ^ " failed.")
                              ; Statistics.add statRepublishSuccess 0.0)
                        val () = storeDate := Event.time () (* FIXME only on successful store? *)
                     in
                        Node.store (node this, id, value, SOME expiryDate, storeCb)
                     end
               in
                  (* check for expiration *)
                  if Time.>= (now, expiryDate)
                  then expire ()
                  else
(*                     if !checked >= 1 then ()
                     else*)
                     (* check for republish (Kademlia paper sect 2.5) *)
                     if Time.>= (now, Time.+ (!storeDate, tRepublish)) then
(*                         (checked := !checked + 1; *)
                        republish ()
(*                         ) *)
                        else ()
               end
         in
            Iterator.app check (ValueMap.iterator values)
         end
         
      fun new () =
         let
            val values = ValueMap.new ()
            val unhookCheckValue = ref (fn () => ())
            val this = T {
               node = ref NONE,
               values = values,
               unhookCheckValue = unhookCheckValue
            }

            (* setup value expiration check *)
            fun checkValueFun event =
               (checkValues this
               ; Event.scheduleIn (event, checkValueInterval))
            val checkValueEvent = Event.new checkValueFun
            val () = Event.scheduleIn (checkValueEvent, checkValueInterval)
            val () = unhookCheckValue := (fn () => Event.cancel checkValueEvent)
            
            (* statistics *)
            val () =
               Statistics.addPoll (statStoredValues,
                  (fn () => Statistics.add statStoredValues
                     (Real32.fromInt (ValueMap.size values))))
         in
            this
         end
      
      fun destroy this =
         !(get#unhookCheckValue this) ()
      
      fun setNode (this, node) =
         get#node this := SOME node
      
      fun storeHandler this (id, value, expiryDate) =
         let
            (* hack to stabilize the network load for KV benchmark *)
            (*val maxLifetime = Time.+ (Main.Event.time (), Time.fromMinutes 70)
            val expiryDate = Time.min (expiryDate, maxLifetime)*)
            (* update expiration
               "exponentially inversely proportional to the number of nodes between the current
                node and the node whose ID is closest to the key" (Kademlia paper) *)
            val node = node this
            val now = Event.time ()
            val expire = Time.- (expiryDate, now)
(*             val expire = Time.min (Value.expires value, tExpireMax) *)
            val expire = Time.multReal32 (expire, Node.getExpirationFactor (node, id))
            val expiryDate = Time.+ (now, expire)
            (* store value *)
            val values = get#values this
            val () =
               case ValueMap.get (values, id) of
                  SOME { expiryDate = oldExpiryDate, ... } =>
                     (* replace value if not older
                        if publish date is the same, also replace to update store date *)
                     if Time.>= (expiryDate, oldExpiryDate) then
                        let
                           val () =
                              log (DEBUG, "kademlia/simpleValueStore/storeHandler",
                                 fn () => "Replacing value " ^ Id.toString id
                                    ^ ", expires " ^ Time.toString expiryDate)
                        in
                           (* replace value *)
                           ValueMap.update (values, id,
                              { value = value, (*publishDate = publishDate,*)
                               storeDate = ref now, expiryDate = expiryDate })
                        end
                     else
                        log (DEBUG, "kademlia/simpleValueStore/storeHandler",
                           fn () => "Not replacing newer value " ^ Id.toString id)
                | NONE =>
                     let
                        val () =
                           log (DEBUG, "kademlia/simpleValueStore/storeHandler",
                              fn () => "Adding value " ^ Id.toString id
                                 ^ ", expires " ^ Time.toString expiryDate)
                     in
                        (* add value *)
                        ValueMap.add (values, id,
                           { value = value, (*publishDate = publishDate,*)
                             storeDate = ref now, expiryDate = expiryDate })
                     end
         in
            true (* for now, we always accept the store request *)
         end
      
      fun retrieveHandler this id =
         let
            val value = ValueMap.get (get#values this, id)
         in
            case value of
                SOME {value, expiryDate, ...} => SOME (id, value, expiryDate)
              | NONE => NONE
         end
      
      fun valuesIterator this () =
         Iterator.map
         (fn (id, {value, expiryDate, ...}) => (id, value, expiryDate))
         (ValueMap.iterator (get#values this))
      
   end
