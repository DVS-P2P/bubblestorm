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

structure BubbleStorm :> BUBBLESTORM =
   struct
      (* TODO: move to config *)
      val leaveTimeout = Time.fromSeconds 30

      val module = "bubblestorm"
      
      datatype t = T of {
         initialized : bool ref,
         endpoint    : CUSP.EndPoint.t,
         ownEndpoint : bool,
         attributes  : NodeAttributes.t,
         topology    : Topology.t,
         master      : BubbleType.master,
         hostCache   : HostCache.t,
         leaveHook   : (unit -> unit) ref
      }
      
      fun id (T { attributes, ... }) = NodeAttributes.id attributes

      fun determineDegree (bandwidth, minBandwidth) =
         let
            (* determine the degree of the node *)
            (* TODO: if the bandwidth is below the minimum, the node should
               become a client instead of a peer. *)
            val minBandwidth = Option.getOpt (minBandwidth, Config.minBandwidth)
            val bandwidth = Real32.max (minBandwidth, Option.getOpt (bandwidth, 1.0))
            
            val capacity = bandwidth / minBandwidth
            val minDegree = Real32.fromInt (Config.minDegree)
            val degree = Real32.round (minDegree * capacity)
         in
            (degree, bandwidth)
         end
         
      fun newWithEndpointInner { degree, endpoint, ownEndpoint } =
         let           
            val () = IcmpNatTraversal.init endpoint
            
            (* create host cache *)
            val hostCache = HostCache.new ()
            
            (* create the topology *)
            val topology =
               Topology.new {
                  endpoint      = endpoint,
                  desiredDegree = degree,
                  hostCache     = fn () => HostCache.getAddress hostCache,
                  foundBootstrapHandler = IcmpNatTraversal.onFoundBootstrap endpoint
               }

            (* TODO make node ID persistent over sessions *)
            val id = ID.fromRandom (getTopLevelRandom ())
            val capacity = (Real64.fromInt degree) / (Real64.fromInt Config.minDegree)
            val attributes = NodeAttributes.new (id, capacity)
            
            (* create the master *)
            val master = BubbleType.newMaster (topology, attributes)
            
         in
            T {
               initialized = ref false,
               endpoint    = endpoint,
               ownEndpoint = ownEndpoint,
               attributes  = attributes,
               topology    = topology,
               master      = master,
               hostCache   = hostCache,
               leaveHook   = ref (fn () => ())
            }
         end

      fun newWithEndpoint { bandwidth, minBandwidth, endpoint } =
         newWithEndpointInner {
            degree = #1 (determineDegree (bandwidth, minBandwidth)),
            endpoint = endpoint,
            ownEndpoint = false
         }         

      fun new { bandwidth, minBandwidth, port, privateKey, encrypt } =
         let
            val (degree, bandwidth) = determineDegree (bandwidth, minBandwidth)
            
            (* create a CUSP endpoint *)
            fun cuspErrorHandler exn =
               Log.logExt (Log.INFO, fn () => module ^ "/endpoint", fn () => General.exnMessage exn)

            val endpoint =
               CUSP.EndPoint.new {
                  port    = port,
                  handler = cuspErrorHandler,
                  entropy = Entropy.get,
                  key     = privateKey,
                  options = SOME {
                     encrypt   = encrypt,
                     publickey = CUSP.Suite.PublicKey.defaults,
                     symmetric = CUSP.Suite.Symmetric.defaults
                     (* crappy CRC crypto allowed *)
(*
                     publickey = CUSP.Suite.PublicKey.all,
                     symmetric = CUSP.Suite.Symmetric.all
*)
                  }
               }
            val () = CUSP.EndPoint.setRate (endpoint, SOME {
               rate = bandwidth,
               burst = Config.bandwidthBurstWindow
            })
         in
            newWithEndpointInner {
               degree = degree,
               endpoint = endpoint,
               ownEndpoint = true
            }
         end
      
      fun endpoint (T { endpoint, ... }) = endpoint

      fun bubbleMaster (T { master, ... }) = master

      fun address (T { topology, ... }) = Topology.address topology
      
      fun init (T { initialized, topology, ... }) =
         if !initialized then () else
            let
               (* TODO: val () = BubbleType.init master *)
               val () = Topology.init topology
            in
               initialized := true
            end

      fun create (this as T { topology, master, ... }, myAddress, notify) =
         let
            val () = Log.logExt (Log.INFO, fn () => module, fn () => "Creating new network")
            
            val () = init this
            fun done () = ( BubbleType.onJoinComplete master ; notify () )
            val () = Topology.create (topology, myAddress, done)
            val () = BubbleType.join master
         in
            ()
         end

      fun join (this as T { endpoint, topology, master, hostCache, leaveHook, ... }, notify) =
         let
            val () = Log.logExt (Log.INFO, fn () => module, fn () => "Joining")
            
            val now = Main.Event.time ()
            val () = init this
            
            fun addLeaveHook (hook : unit -> unit) =
               let
                  val oldLeaveHook = !leaveHook
               in
                  leaveHook := (fn () => (hook (); oldLeaveHook ()))
               end
            
            fun onJoinComplete () =
               let
                  val () = IcmpNatTraversal.onJoinComplete {
                     endpoint = endpoint,
                     address = fn () => address this,
                     hostCache = hostCache,
                     registerUnhook = addLeaveHook
                  }

                  val () = BubbleType.onJoinComplete master

                  val delay = Time.- (Main.Event.time (), now)
                  val () = Statistics.add Stats.joinTime (Time.toSecondsReal32 delay)
               in
                  notify ()
               end               
            val () = Topology.join (topology, onJoinComplete)
            val () = BubbleType.join master
         in
            ()
         end

      fun dumpStreams endpoint =
         let
            open CUSP
            val method = module ^ "/dump"
            fun hostToString h =
               getOpt (Option.map Address.toString (Host.remoteAddress h), "<dead>")
            fun log (h, msg, id, name) = Log.log (Log.ERROR, method, fn () => 
               msg ^ " (" ^ hostToString h ^ "/" ^ Word16.toString id ^ "): " ^ name)
            fun ist h s = log (h, "not closed InStream",  InStream.globalID s, InStream.localName s)
            fun ost h s = log (h, "not closed OutStream", OutStream.globalID s, OutStream.localName s)
            fun host h =
               ( Iterator.app (ist h) (Host.inStreams h)
               ; Iterator.app (ost h) (Host.outStreams h))
            val () = Iterator.app host (EndPoint.hosts endpoint)
            fun chan (addr, SOME _) = Log.log (Log.INFO, method, fn () => 
               "not closed Channel: " ^ Address.toString addr)
              | chan (addr, NONE) = Log.log (Log.DEBUG, method, fn () => 
               "waiting on connecting Channel: " ^ Address.toString addr)
            val () = Iterator.app chan (EndPoint.channels endpoint)
         in
            ()
         end
      
      fun leave (T { topology, master, endpoint, ownEndpoint, leaveHook, ... }, notify) =
         let
            val () = Log.logExt (Log.DEBUG, fn () => module, fn () => "Leaving")
            val now = Main.Event.time ()

            fun onCuspDone () =
               let
                  val () = Log.logExt (Log.INFO, fn () => module, fn () => "Done CUSP!")
               in
                  notify ()
               end
            
            fun onLeaveComplete () =
               let
                  val () = Log.logExt (Log.INFO, fn () => module, fn () => "Done leave!")
                  val () = BubbleType.onLeaveComplete master
                  val delay = Time.- (Main.Event.time (), now)
                  val () = Statistics.add Stats.leaveTime (Time.toSecondsReal32 delay)
               in
                  (* destroy the endpoint (if we own it) *)
                  if ownEndpoint then
                     let
                        val complain = Main.Event.new (fn _ => dumpStreams endpoint)
                        val () = Main.Event.scheduleIn (complain, leaveTimeout)
                     in
                        ignore (CUSP.EndPoint.whenSafeToDestroy (endpoint, onCuspDone))
                     end
                  else notify ()
               end
            
            (* leave hook (s) *)
            val () = (!leaveHook) ()
            val () = leaveHook := (fn () => ())
            
            val () = Topology.leave (topology, onLeaveComplete)
            val () = BubbleType.leave master
         in
            ()
         end  

      fun saveHostCache (T { hostCache, ... }) =
         HostCache.getHostCacheData hostCache
      
      exception InvalidHostCacheData = HostCache.InvalidHostCacheData
      
      fun loadHostCache (T { hostCache, ... }, { data, wellKnown, bootstrap }) =
         HostCache.setHostCacheData (hostCache, data, wellKnown, bootstrap)
      
      val setLanMode = Config.setLanMode
      
      fun networkSize (T { master, ... }) = BubbleType.networkSize master
      
      fun addMeasurement (T this, measurement) =
         Topology.addMeasurement (#topology this, measurement)
   end
