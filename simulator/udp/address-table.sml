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

(* A lookup table to map simulator network address to SimulatorNodes and message handler callbacks *)
structure AddressTable :> ADDRESS_TABLE =
   struct
      val module = "simulator/udp/address-table"

      fun log (node, method, msg) =
         if SimulatorNode.isLocal node then
            GlobalLog.logExt (Log.DEBUG, fn () => module ^ "/" ^ method (), msg)
         else ()
         
      structure HashTable = HashTable(Address.Ip)
      val table = HashTable.new ()
      val modCount = ref 0

      fun randomAddress retries =
         if retries > 0 then
            let
               val rawAddress = Random.word32 (Experiment.random (), NONE)
               val address = Address.Ip.fromWord32 rawAddress
            in
               case (HashTable.get (table, address), NodeGroup.isStaticAddress address) of
                  (NONE, false) => address
                  (* hash table collision, try again *)
                | _ => randomAddress (retries - 1)
            end
         else raise At (module ^ "/random-address",
                 Fail "Could not find an unused IP address.")               

      fun assignAddress node =
         let
            val address = case SimulatorNode.staticAddress node of
                             NONE => randomAddress 50000
                           | SOME address => address
            val () = log (node, fn () => "assign", fn () => "Assigned " ^ 
               Address.Ip.toString address ^ " to node " ^ 
               SimulatorNode.toString node)
            val () = HashTable.add (table, address, (node, !modCount))
            val () = modCount := !modCount + 1
         in
            SimulatorNode.setCurrentAddress (node, SOME address)
         end
      
      fun cannotRelease node = At (module ^ "/release-address", Fail ("Node " ^ 
         SimulatorNode.toString node ^ " has no address to release."))
            
      fun releaseAddress node =
         let
            val address = case SimulatorNode.currentAddress node of
               SOME x => x
             | NONE => raise cannotRelease node
            val () = log (node, fn () => "assign", fn () => "Released " ^ 
               Address.Ip.toString address ^ " previously assigned to node " ^ 
               SimulatorNode.toString node)
            val () = ignore (HashTable.remove (table, address))
         in
            SimulatorNode.setCurrentAddress (node, NONE)            
         end
      
      fun scheduleRelease (node, time) =
         let
            val address = case SimulatorNode.currentAddress node of
               SOME x => x
             | NONE => raise cannotRelease node
            
            val () = log (node, fn () => "schedule", fn () => "schedule " ^ 
               Address.Ip.toString address ^ " release for node " ^ 
               SimulatorNode.toString node)

            fun releaseEvent (node, curModCount) =
               let
                  fun release _ =
                     (case HashTable.get (table, address) of
                        SOME (newNode, newModCount) =>
                           if SimulatorNode.equals (node, newNode)
                              andalso curModCount = newModCount
                              then releaseAddress node
                              else () (* address got re-assigned in the meantime *)
                      | NONE => () (* address already released *))
               in
                  Experiment.Event.scheduleIn (Experiment.Event.new release, time)
               end
         in
            case HashTable.get (table, address) of
               SOME (node, curModCount) => releaseEvent (node, curModCount)
             | NONE => raise cannotRelease node
         end
         
      fun get address = case HashTable.get (table, address) of
         SOME (x, _) => x
       | NONE => raise Routing.HostUnreachable
   end