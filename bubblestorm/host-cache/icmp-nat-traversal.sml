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

structure IcmpNatTraversal :> ICMP_NAT_TRAVERSAL =
   struct
      (* TODO: move to config *)
      (* default fake address for NAT penetration *)
      val fakeContactAddr = "nat-contact.bubblestorm.net:8586"
      (* default NAT life line address *)
      val natLifeLineAddr = "nat-listen.bubblestorm.net:8586"
      (* delay after join to first check for bootstrap capabilities *)
      val checkCapabilitiesDelay = Time.fromSeconds 15

      fun module () = "bubblestorm/nat"
      
      (* sets NAT penetration to using ICMP (if fake contact available) *)
      fun setNATPenetrationICMP endpoint =
         case CUSP.Address.fromString fakeContactAddr of
            nil =>
               (Log.logExt (Log.DEBUG, module,
                  fn () => "Could not resolve " ^ fakeContactAddr ^ ", disabling NAT penetration.")
               ; CUSP.EndPoint.setNATPenetration (endpoint, CUSP.EndPoint.NAT_FAIL))
          | addr::_ =>
               CUSP.EndPoint.setNATPenetration (endpoint,
                  CUSP.EndPoint.NAT_ICMP { fakeContact = addr })
      (* sets NAT penetration to using Via (if fake contact available) *)
      fun setNATPenetrationVia (endpoint, helper) =
         case CUSP.Address.fromString fakeContactAddr of
            nil =>
               (Log.logExt (Log.DEBUG, module,
                  fn () => "Could not resolve " ^ fakeContactAddr ^ ", disabling NAT penetration.")
               ; CUSP.EndPoint.setNATPenetration (endpoint, CUSP.EndPoint.NAT_FAIL))
          | addr::_ =>
               CUSP.EndPoint.setNATPenetration (endpoint,
                  CUSP.EndPoint.NAT_VIA { fakeContact = addr, helper = helper })

      fun init endpoint =
         let
            (* set initial NAT penetration mode *)
            val () = CUSP.EndPoint.setNATLifeLine (endpoint, SOME natLifeLineAddr)
            val () = Log.logExt (Log.DEBUG, module,
                        fn () => "Setting initial NAT penetration: ICMP")
         in
            setNATPenetrationICMP endpoint
         end   

      (* invoked by topology once the connection to a bootstrap node has been established *)
      fun onFoundBootstrap endpoint addr =
         let
            val () = Log.logExt (Log.DEBUG, module,
                        fn () => ("Setting NAT penetration: VIA " ^
                         CUSP.Address.toString addr))
         in
            setNATPenetrationVia (endpoint, fn () => addr)
         end

      fun onJoinComplete { endpoint, address, hostCache, distributedHostCache, registerUnhook } =
         let
            fun periodicCheck () =
               let
                  (* get my capabilities *)
                  val canRecvUDP = CUSP.EndPoint.canReceiveUDP endpoint
                  val canSendICMP = CUSP.EndPoint.canSendOwnICMP endpoint
                  val myAddr = address ()
                  
                  (* print capabilities *)
                  fun fmtBool true = "YES" | fmtBool false = "NO"
                  fun fmtAddr (SOME addr) = CUSP.Address.toString addr | fmtAddr NONE = "NONE"
                  val () = Log.logExt (Log.DEBUG, module,
                           fn () => "My capabilities: receive UDP: " ^ fmtBool canRecvUDP
                              ^ ", send ICMP: " ^ fmtBool canSendICMP
                              ^ ", my address: " ^ fmtAddr myAddr)
                  
                  (* update ICMP mode *)
                  val () =
                     if canSendICMP
                     then
                        (Log.logExt (Log.DEBUG, module,
                           fn () => "Setting NAT penetration: ICMP")
                        ; setNATPenetrationICMP endpoint)
                     else
                        (Log.logExt (Log.DEBUG, module,
                           fn () => ("Setting NAT penetration: VIA (from host cache)"))
                        ; setNATPenetrationVia (endpoint, fn () => HostCache.getAddress hostCache))
                  (* publish myself as bootstrap if capable *)
                  val () =
                     if canRecvUDP andalso canSendICMP andalso isSome myAddr
                     then DistributedHostCache.publishBootstrap (distributedHostCache, myAddr)
                     else DistributedHostCache.unpublishBootstrap distributedHostCache
               in
                  ()
               end
            
            (* NAT penetration and bootstrap capabilities check *)
            fun delayedCheck _ =
               let
                  (* watch for CUSP status changes *)
                  val unwatchCUSP = CUSP.EndPoint.watchStatus (endpoint, periodicCheck)
                  val () = registerUnhook unwatchCUSP
               in
                  (* check now *)
                  periodicCheck ()
               end
         in
            Main.Event.scheduleIn (Main.Event.new delayedCheck, checkCapabilitiesDelay)
         end
   end
