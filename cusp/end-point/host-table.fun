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

functor HostTable(structure Event : EVENT
                  structure Address : ADDRESS
                  structure HostDispatch : HOST_DISPATCH
                    where type address = Address.t) =
   struct
      structure ListenKey =
         struct
            type t = Word16.word
            val op == = op =
            val hash = Hash.word16
         end
         
      structure ListenMap = HashTable(ListenKey)
      structure HostMap = HashTable(Crypto.PublicKey)
      
      type service = Word16.word
      
      type host = HostDispatch.t
      type t = {
         listen   : (host * service * InStreamQueue.t -> unit) ListenMap.t,
         counter  : service ref,
         hosts    : host Weak.t HostMap.t,
         cleanup  : Event.t,
         lastSeen : Address.t option ref,
         onAddressChange : (Address.t -> unit) Ring.t
      }
      
      val wipeTime = Time.fromMinutes 2 (* Clean dead hosts every 2 minutes *)
      
      fun advertise ({ listen, ... }:t, SOME sv, cb) =
         if sv = 0w0 then raise AddressInUse else
         if Word16.>> (sv, 0w14) <> 0w0 then raise AddressInUse else
         (case ListenMap.get (listen, sv) of
             SOME _ => raise AddressInUse
           | NONE => (ListenMap.add (listen, sv, cb); sv))
        | advertise ({ listen, counter, ... }:t, NONE, cb) =
          let
             val last = !counter
             fun inc () = counter := Word16.andb (0wx3fff, !counter + 0w1)
             fun id w = Word16.orb (0wx4000, w)
             val () = inc ()
             val () = 
               while !counter <> last andalso 
                     isSome (ListenMap.get (listen, id (!counter)))
               do inc ()
          in
             if !counter = last then raise AddressInUse else
             (ListenMap.add (listen, id (!counter), cb)
              ; id (!counter))
          end
      
      fun unadvertise ({ listen, ... }:t, sv) =
         ignore (ListenMap.remove (listen, sv))
      
      fun host ({ hosts, ...}:t, key) =
         Option.mapPartial Weak.get (HostMap.get (hosts, key))
      
      fun numHosts ({ hosts, ... }:t) =
         HostMap.size hosts

      fun existHost z = 
         let
            (* If we have state to resume, then resume.
             * If we promised to resume, force that the host stays alive.
             *  => need the matching sequence tables
             *)
            fun keepAlive h = 
               if HostDispatch.effectivelyDead h then false else
               (HostDispatch.poke h; true)
         in
            getOpt (Option.map keepAlive (host z), false)
         end
      
      fun findCb ({ listen, ... }:t, sv) =
         ListenMap.get (listen, sv)
      
      fun newHost (this, {key, localAddress, remoteAddress, reconnect}) =
         HostDispatch.new {
            key = key,
            localAddress  = localAddress,
            remoteAddress = remoteAddress,
            global = fn p =>
               Option.map 
               (fn cb => fn (h, f) => cb (h, p, f)) (findCb (this, p)),
            reconnect = reconnect
         }
      
      fun lastSeen ({ lastSeen, onAddressChange, ... }:t, address) =
         let
            val changed =
               case !lastSeen of 
                  NONE => true
                | SOME x => Address.compare (x, address) <> EQUAL
            val () = lastSeen := SOME address
            fun inform _ =
               Ring.app (fn r => Ring.unwrap r address) onAddressChange
         in
            if changed andalso not (Ring.isEmpty onAddressChange)
            then Event.scheduleIn (Event.new inform, Time.fromSeconds 0)
            else ()
         end
      
      fun onAddressChange ({ onAddressChange, ... }:t, cb) =
         let
            val r = Ring.wrap cb
            val () = Ring.add (onAddressChange, r)
         in
            fn () => Ring.remove r
         end
      
      fun attachHost (this as { hosts, ... }:t, 
                      args as {key, localAddress, remoteAddress, ...}) =
         case HostMap.get (hosts, key) of
            SOME host => 
              (case Weak.get host of 
                  SOME host =>
                  let
                     val () = lastSeen (this, localAddress)
                     val () = 
                        HostDispatch.updateAddress (host, {
                           remoteAddress = remoteAddress,
                           localAddress  = localAddress
                           })
                  in
                     host
                  end
                | NONE =>
                  let
                     val () = lastSeen (this, localAddress)
                     val host = newHost (this, args)
                     val () = HostMap.update (hosts, key, Weak.new host)
                  in
                     host
                  end)
          | NONE =>
            let
               val () = lastSeen (this, localAddress)
               val host = newHost (this, args)
               val () = HostMap.add (hosts, key, Weak.new host)
            in
               host
            end
      
      fun hosts ({ hosts, ... }:t) =
         Iterator.mapPartial (fn (_, h) => Weak.get h) (HostMap.iterator hosts)
      
      fun cleanup hosts event =
         let
            fun tidy (pubkey, host) =
               if isSome (Weak.get host) then () else
               ignore (HostMap.remove (hosts, pubkey))
         in
            Iterator.app tidy (HostMap.iterator hosts)
            ; Event.scheduleIn (event, wipeTime)
         end
      
      fun destroy ({ listen, cleanup, hosts, onAddressChange, ... }:t) =
         let
            val () = 
               Iterator.app 
               (fn (k, _) => ignore (ListenMap.remove (listen, k)))
               (ListenMap.iterator listen)
            val () =
               Iterator.app
               (fn (k, h) => (Option.app HostDispatch.destroy (Weak.get h)
                              ; ignore (HostMap.remove (hosts, k))))
               (HostMap.iterator hosts)
            val () =
               Iterator.app
               (fn r => Ring.remove r)
               (Ring.iterator onAddressChange)
         in
            Event.cancel cleanup
         end
      
      fun new () = 
         let
            val hosts = HostMap.new ()
            val cleanup = Event.new (cleanup hosts)
            val () = Event.scheduleIn (cleanup, wipeTime)
         in
            { listen  = ListenMap.new (),
              counter = ref (0w0:service),
              hosts   = hosts,
              cleanup = cleanup,
              lastSeen = ref NONE,
              onAddressChange = Ring.new () }
         end
   end
