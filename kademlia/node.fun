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

functor Node(
      structure Event : EVENT
      structure RPC : RPC
      structure Id : ID
   ) : NODE
   =
   struct
      structure Id = Id
      structure Address = RPC.Address
      
      structure NodeRPC = NodeRPC (
         structure Id = Id
         structure RPC = RPC
      )
      structure Buckets = Buckets(
         structure Event = Event
         structure NodeRPC = NodeRPC
      )
      
      open Log
      
      (* statistics *)
      fun defaultStatistics name =
         Statistics.new {
            parents = nil,
            name = name,
            units = "", (* TODO value *)
            label = "", (* TODO value *)
            histogram = Statistics.NO_HISTOGRAM,
            persistent = true
         }
      val statLookupNodesResults = defaultStatistics "kademlia/node lookup results"
      val statLookupNodesIterations = defaultStatistics "kademlia/node lookup iterations"
      
      (* types *)
      type valueEntry = Id.t * Word8Vector.vector * Time.t
      type storeHandler = valueEntry -> bool
      type retrieveHandler = Id.t -> valueEntry option
      type valuesIterator = unit -> valueEntry Iterator.t
      
      type joinCallback = bool -> unit
      type storeCallback = int -> unit
      type retrieveCallback = (Id.t * Word8Vector.vector) option -> unit
      
      (* datatype *)
      datatype fields = T of {
         myId : Id.t,
         rpc : NodeRPC.t option ref,
         buckets : Buckets.t,
         bucketsRefreshed : Time.t Array.array,
         unhookCheckBuckets : (unit -> unit) ref
      }
      withtype t = fields
      fun get f (T fields) = f fields
      
      (* auxiliary structure for iterative lookups *)
      structure NodeLookupList =
         struct
            (* Entry: id, address, xor-id, checked *)
            type t = (Id.t * Address.t * Id.t * bool) list ref
            
            val maxSize = 2 * Config.k
            
            fun takeMax (_, 0) = nil
              | takeMax (nil, _) = nil
              | takeMax (l::r, i) = l::takeMax(r, i - 1)
            
            fun new () = ref nil
            
            (* add node to the list *)
            fun addNode (this: t, id, addr, targetId, myId) =
               if Id.== (id, myId) then
                  log (WARNING, "kademlia/NodeLookupList",
                     fn () => "Not adding my own ID.")
               else
                  let
                     fun insert (x, nil) = [x]
                       | insert (e1 as (_, _, xid1, _), (e2 as (_, _, xid2, _))::r) =
                        case Id.compare (xid1, xid2) of
                           EQUAL   => e2::r
                         | LESS    => e1::e2::r
                         | GREATER => e2::insert(e1, r)
                     val xid = Id.xor (id, targetId)
                  in
                     this := takeMax (insert ((id, addr, xid, false), !this), maxSize)
                  end
            
            (* mark node as checked *)
            fun checkNode (this: t, checkId) =
               let
                  fun check nil = raise Fail "Check non-existent item"
                    | check ((id, addr, xid, c)::r) =
                     if Id.== (id, checkId)
                     then (id, addr, xid, true)::r
                     else (id, addr, xid, c)::(check r)
               in
                  this := check (!this)
               end
            
            (* remove node from list (-> dead node) *)
            fun removeNode (this: t, removeId) =
               let
                  fun remove nil = nil (* ignore; node may have been sorted out already *)
                    | remove ((e as (id, _, _, _))::r) =
                     if Id.== (id, removeId)
                     then r
                     else e::(remove r)
               in
                  this := remove (!this)
               end
            
(*            fun firstCheckedNode (this: t) =
               Option.map
               (fn (id, addr, _, _) => (id, addr))
               (List.find (fn (_, _, _, c) => c) (!this))*)
         end
      
      fun idAddrsToString (l, xid) =
         String.concat (List.map (fn (id, addr) =>
            (Id.toString id ^ " - " ^ Address.toString addr ^
               " (XOR " ^ Id.toString (Id.xor (id, xid)) ^ ")\n")) l)
      
      fun rpc this = Option.valOf (!(get#rpc this))
      
      (* called whenever a node is seen (i.e., a message has been received) *)
      fun updateNode (this, valuesIterator) (id, addr) =
         let
            val () =
               log (DEBUG, "kademlia/updateNode",
                  fn () => "UpdateNode " ^ Id.toString id
                     ^ " (" ^ Address.toString addr ^ ")")
            val buckets = get#buckets this
            val rpc = rpc this
            (* store relevant values to new node if necessary *)
            fun checkStore (valId, value, expiryDate) =
               let
(*                   val valId = Value.id value *)
                  fun doStore () =
                     let
                        val () =
                           log (DEBUG, "kademlia/updateNode/store",
                              fn () => "Storing value " ^ Id.toString valId
                                 ^ " to new node " ^ Id.toString id)
                        fun storeCb (SOME _) = ()
                        | storeCb NONE = 
                           log (WARNING, "kademlia/updateNode/store",
                              fn () => "Storing value " ^ Id.toString valId
                                 ^ " to new node " ^ Id.toString id ^ " failed.")
                     in
                        ignore (NodeRPC.store (rpc,
                           { destAddr = addr, destId = SOME id, id = valId, value = value,
                              expiryDate = expiryDate, callback = storeCb }))
                     end
               in
                  (* store value if I am closest to value and new node is within k to value *)
                  if not (Buckets.knowNodesCloserTo (buckets, valId))
                     andalso Buckets.countCloserNodesFor (buckets, valId, id) < Config.k
                  then doStore ()
                  else ()
               end
            (* update node in bucket *)
            val nodeWasAdded = Buckets.updateNode (buckets, id, addr)
         in
            (* if added, store values *)
            if nodeWasAdded
            then
               Iterator.app
               checkStore
               (valuesIterator ())
            else ()
         end
      
      (* called whenever request to a node is timed out *)
      fun nodeTimeout buckets (id, addr) =
         let
            fun idStr id = Option.getOpt (Option.map Id.toString id, "?")
            val () = log (DEBUG, "kademlia/nodeTimeout",
               fn () => "Node timeout: " ^ idStr id
                  ^ " (" ^ Address.toString addr ^ ")")
         in
            case id of
               SOME id => Buckets.nodeTimeout (buckets, id)
             | NONE => ()
         end
      
      (* ---------------------- *)
      (*  PING request handler  *)
      (* ---------------------- *)
      fun pingRequestHandler { fromAddr=_, fromId=_ } = true
      
      (* --------------------------- *)
      (*  FIND_NODE request handler  *)
      (* --------------------------- *)
      fun findNodeRequestHandler buckets { fromAddr=_, fromId, targetId } =
         let
            val entries =
               Buckets.getCloseNodes (buckets, { targetId = targetId, requestorId = fromId, count = Config.k })
            fun mapEntry ni =
               (Buckets.Bucket.Contact.id ni, Buckets.Bucket.Contact.address ni)
         in
            Iterator.map mapEntry (Iterator.fromList entries)
         end
      
      (* ----------------------- *)
      (*  STORE request handler  *)
      (* ----------------------- *)
      fun storeRequestHandler storeHandler { fromAddr=_, fromId=_, id, value, expiryDate } =
         storeHandler (id, value, expiryDate)
      
      (* ---------------------------- *)
      (*  FIND_VALUE request handler  *)
      (* ---------------------------- *)
      fun findValueRequestHandler (buckets, retrieveHandler) { fromAddr=_, fromId, targetId } =
         let
            fun entries () =
               Buckets.getCloseNodes (buckets, { targetId = targetId, requestorId = fromId, count  =Config.k })
            fun mapEntry ni =
               (Buckets.Bucket.Contact.id ni, Buckets.Bucket.Contact.address ni)
         in
            case retrieveHandler targetId of
               SOME (id, value, expiryDate) => NodeRPC.VALUE (id, value, expiryDate)
             | NONE => NodeRPC.NODES (Iterator.map mapEntry (Iterator.fromList (entries ())))
         end
      
      (* iterative node lookup *)
      fun lookupNodes (this, {
            targetId : Id.t,
            callback : (Id.t * Address.t) list -> unit
         }) =
         let
            val () = log (DEBUG, "kademlia/lookupNode",
               fn () => ("Starting lookup for node " ^ Id.toString targetId))
            
            val rpc = rpc this
            val buckets = get#buckets this
            val myId = get#myId this
            
            (* node list, contains tuples (id, addr, id xor targetId, checked) *)
            val nodeList = NodeLookupList.new ()
            val activeLookups = ref 0
            val lookupCount = ref 0
            
            fun lookup (id, addr) =
               let
                  val () = NodeLookupList.checkNode (nodeList, id)
                  val () = activeLookups := !activeLookups + 1
                  val () = lookupCount := !lookupCount + 1
                  
                  val () = log (DEBUG, "kademlia/lookupNode/findNode",
                     fn () => ("Sending FIND_NODE for " ^ Id.toString targetId
                        ^ " to " ^ Id.toString id))
                  
                  fun findNodeCb NONE =
                     let
                        val () =
                           log (DEBUG, "kademlia/lookupNode/findNode",
                              fn () => ("FIND_NODE call to " ^ Id.toString id ^ " failed."))
                        val () = NodeLookupList.removeNode (nodeList, id)
                        val () = activeLookups := !activeLookups - 1
                     in
                        startLookups ()
                     end
                    | findNodeCb (SOME (_, idList)) =
                     let
                        val () =
                           Iterator.app (fn (id, addr) =>
                              NodeLookupList.addNode (nodeList, id, addr, targetId, myId)) idList
                        val () = activeLookups := !activeLookups - 1
                     in
                        startLookups ()
                     end
               in
                  ignore (NodeRPC.findNode (rpc,
                     {destAddr=addr, destId=SOME id, targetId=targetId, callback=findNodeCb}))
               end
            and startLookups () =
               let
                  val count = Config.alpha - !activeLookups
                  val kNodes = NodeLookupList.takeMax (!nodeList, Config.k)
                  val uncheckedNodes = List.filter (fn (_, _, _, checked) => not checked) kNodes
                  fun mapIdAddr (id, addr, _ , _) = (id, addr)
               in
                  if not (List.null uncheckedNodes) then
                     List.app lookup (List.map mapIdAddr (NodeLookupList.takeMax (uncheckedNodes, count)))
                  else
                     if !activeLookups > 0 then ()
                     else
                        let
                           val resultList = List.map mapIdAddr kNodes
                           val () = log (DEBUG, "kademlia/lookupNode",
                              fn () => ("Node Lookup completed:\n"
                              ^ idAddrsToString (resultList, targetId)))
                           (* node lookup statistics *)
                           val () =
                              Statistics.add
                              statLookupNodesResults
                              (Real32.fromInt (List.length resultList))
                           val () =
                              Statistics.add
                              statLookupNodesIterations
                              (Real32.fromInt (!lookupCount))
                        in
                           callback resultList
                        end
               end
            
            (* set bucket as refreshed *)
            local
               val bucketId = Buckets.bucketId (buckets, targetId)
            in
               val () =
                  if bucketId >= 0
                  then Array.update (get#bucketsRefreshed this, bucketId, Event.time ())
                  else ()
            end
            
            (* init node list with alpha known nodes *)
            local
               val startNodes =
                  List.map Buckets.Bucket.Contact.idAddr
                     (Buckets.getCloseNodes (buckets,
                        { targetId = targetId, requestorId = myId, count = Config.k }))
               val () =
                  log (DEBUG, "kademlia/lookupNode/startNodes",
                     fn () => ("StartNodes:\n" ^ idAddrsToString (startNodes, targetId)))
            in
               val () =
                  List.app (fn (id, addr) =>
                     NodeLookupList.addNode (nodeList, id, addr, targetId, myId)) startNodes
            end
         in
            startLookups ()
         end
      
      (* iterative value lookup *)
      fun lookupValue (this, {
            targetId : Id.t,
            callback : (Id.t * Word8Vector.vector) option -> unit
         }) =
         let
            val () = log (DEBUG, "kademlia/lookupValue",
               fn () => ("Starting lookup for value " ^ Id.toString targetId))
            
            val rpc = rpc this
            val buckets = get#buckets this
            val myId = get#myId this
            
            (* node list, contains tuples (id, addr, id xor targetId, checked) *)
            val nodeList = NodeLookupList.new ()
            (* the active lookups list, or precisely: the abort functions *)
            val activeLookups = Array.tabulate (Config.alpha, fn _ => NONE)
            
            fun clearLookup i =
               Array.update (activeLookups, i, NONE)
            
            fun abortLookups () =
               Array.app (Option.app (fn x => x ())) activeLookups

            (* node closest to ID but which soes not have value -> for cache *)
            val closestNodeWithoutValue = ref NONE
               
            fun lookup (i, id, addr) =
               let
                  val () = log (DEBUG, "kademlia/lookupValue/findNode",
                     fn () => ("Sending FIND_VALUE for " ^ Id.toString targetId
                        ^ " to " ^ Id.toString id))
                  
                  val () = NodeLookupList.checkNode (nodeList, id)
                  
                  fun findValueCb NONE =
                     (* FIND_VALUE call failed *)
                     let
                        val () =
                           log (DEBUG, "kademlia/lookupValue/findNode",
                              fn () => ("FIND_VALUE call to " ^ Id.toString id ^ " failed."))
                        val () = NodeLookupList.removeNode (nodeList, id)
                        val () = clearLookup i
                     in
                        startLookups ()
                     end
                   | findValueCb (SOME (_, NodeRPC.NODES idList)) =
                     (* FIND_VALUE call returned node list *)
                     let
                        val () =
                           Iterator.app (fn (id, addr) =>
                              NodeLookupList.addNode (nodeList, id, addr, targetId, myId)) idList
                        val () = clearLookup i
                        (* candidate for caching *)
                        val xid = Id.xor (id, targetId)
                        val () = closestNodeWithoutValue :=
                           SOME (case (!closestNodeWithoutValue) of
                              SOME (cid, caddr) => if Id.< (xid, cid) then (id, addr) else (cid, caddr)
                            | NONE => (id, addr))
                     in
                        startLookups ()
                     end
                   | findValueCb (SOME (_, NodeRPC.VALUE (id, value, expiryDate))) =
                     (* FIND_VALUE call returned value *)
                     let
                        val () =
                           log (DEBUG, "kademlia/lookupValue",
                              fn () => ("Value Lookup for " ^ Id.toString targetId ^ " completed: "
                                 ^ Id.toString id))
                        val () = clearLookup i
                        val () = abortLookups ()
                        (* caching: store value to closest node (to key) that does not have the value *)
                        fun store (toXId, toAddr) =
                           let
                              val toId = Id.xor (toXId, targetId)
                              val () =
                                 log (DEBUG, "kademlia/lookupValue/store",
                                    fn () => ("Replicating value " ^ Id.toString id
                                       ^ " to " ^ Id.toString toId ^ " for caching"))
                           in
                              ignore (NodeRPC.store (rpc,
                                 {destAddr=toAddr, destId=SOME toId, id=id, value=value,
                                 expiryDate=expiryDate, callback=(fn _ => ())}))
                           end
                        (* here's where the caching happens *)
                        val () = Option.app store (!closestNodeWithoutValue)
                     in
                        callback (SOME (id, value))
                     end
                  
                  val abortRPC =
                     NodeRPC.findValue (rpc,
                        { destAddr = addr, destId = SOME id, targetId = targetId, callback = findValueCb })
                  fun abort () =
                     (abortRPC ()
(*                      ; NodeLookupList.removeNode (nodeList, id) *)
                     ; clearLookup i)
               in
                  Array.update (activeLookups, i, SOME abort)
               end
            and startLookups () =
               let
                  val kNodes = NodeLookupList.takeMax (!nodeList, Config.k)
                  val uncheckedNodes = ref (List.filter (fn (_, _, _, checked) => not checked) kNodes)
                  val freeLookupSlots =
                     Iterator.filter (fn i => not (Option.isSome (Array.sub (activeLookups, i))))
                     (Iterator.fromInterval { start = 0, stop = Config.alpha, step = 1 })
                  
                  fun startLookup i =
                     let
                        fun nextUncheckedNode () =
                           case !uncheckedNodes of
                              nil => NONE
                            | h::t => (uncheckedNodes := t; SOME h)
                     in
                        case nextUncheckedNode () of
                           SOME (id, addr, _ , _) => lookup (i, id, addr)
                         | NONE => ()
                     end
                  
(*                   fun mapIdAddr (id, addr, _ , _) = (id, addr) *)
              in
                  if not (List.null (!uncheckedNodes)) then
                     Iterator.app startLookup freeLookupSlots
                  else
                     if Option.isSome (Array.find Option.isSome activeLookups) then ()
                     else
                        (log (DEBUG, "kademlia/lookupValue",
                           fn () => ("Value Lookup for " ^ Id.toString targetId ^ " failed."))
(*                       ; log (WARNING, "kademlia/lookupValue",
                           fn () => ("Nodes:\n" ^ idAddrsToString (List.map mapIdAddr kNodes, targetId)))
                       ; log (WARNING, "kademlia/lookupValue/startNodes",
                           fn () => ("StartNodes:\n" ^ idAddrsToString (startNodes, targetId)))*)
                       ; callback NONE)
               end
            
            (* set bucket as refreshed *)
            local
               val bucketId = Buckets.bucketId (buckets, targetId)
            in
               val () =
                  if bucketId >= 0
                  then Array.update (get#bucketsRefreshed this, bucketId, Event.time ())
                  else ()
            end
            
            (* init node list with alpha known nodes *)
            local
               val startNodes =
                  List.map Buckets.Bucket.Contact.idAddr
                     (Buckets.getCloseNodes (buckets,
                        { targetId = targetId, requestorId = myId, count = Config.k }))
               val () =
                  log (DEBUG, "kademlia/lookupValue/startNodes",
                     fn () => ("StartNodes:\n" ^ idAddrsToString (startNodes, targetId)))
               val () =
                  if List.null startNodes
                  then log (WARNING, "kademlia/lookupValue/startNodes",
                     fn () => "StartNodes empty!")
                  else ()
            in
               val () =
                  List.app (fn (id, addr) =>
                     NodeLookupList.addNode (nodeList, id, addr, targetId, myId)) startNodes
            end
         in
            startLookups ()
         end
      
      (* performs a ping with retry *)
      fun pingRetry (this, {
            destAddr : Address.t,
            destId : Id.t option,
            retries : int,
            callback : NodeRPC.pingCallback
         }) =
         let
            val rpc = rpc this
            fun ping retries =
               let
                  fun cb NONE =
                     if retries > 0
                     then 
                        (log (WARNING, "kademlia/ping",
                           fn () => ("Ping failed. " ^ Int.toString retries
                              ^ " retries left."))
                        ; ping (retries - 1))
                     else callback NONE
                    | cb (SOME id) = callback (SOME id)
               in
                  ignore (NodeRPC.ping (rpc, {destAddr=destAddr, destId=destId, callback=cb}))
               end
         in
            ping retries
         end
      
      (* performs a node lookup with retry *)
      fun lookupNodesRetry (this, {
            targetId : Id.t,
            retries : int,
            callback : (Id.t * Address.t) list -> unit
         }) =
         let
            fun lookup retries =
               let
                  fun cb nil =
                     if retries > 0
                     then
                        (log (WARNING, "kademlia/lookupNode",
                           fn () => ("Node lookup failed. " ^ Int.toString retries
                              ^ " retries left."))
                        ; lookup (retries - 1))
                     else callback nil
                    | cb l = callback l
               in
                  lookupNodes (this, {targetId=targetId, callback=cb})
               end
         in
            lookup retries
         end
      
      (* performs a node lookup for a random ID in the given bucket *)
      fun refreshBucket (this, bucketId, completeCb) =
         let
            val () = log (DEBUG, "kademlia/refreshBucket",
               fn () => "Refreshing bucket #" ^ Int.toString bucketId)
            val myId = get#myId this
            val targetId =
               Id.xor (Id.setBit (Id.fromRandomBits (getTopLevelRandom (), bucketId), bucketId), myId)
         in
            lookupNodes (this, {targetId=targetId, callback=(fn _ => completeCb ())})
         end
     
      (* auto-refresh buckets if no refresh in the past hour *)
      fun checkBuckets this =
         let
            val tRef = Time.- (Event.time (), Config.bucketRefreshInterval)
            fun check (bucketId, lastRefresh) =
               if (Time.< (lastRefresh, tRef))
                  andalso (not (Buckets.isEmpty (get#buckets this, bucketId)))
               then refreshBucket (this, bucketId, fn () => ())
               else ()
         in
            Array.appi check (get#bucketsRefreshed this)
         end
     
     fun storeWithExpiryDate (this, id, value, expiryDate, callback) =
         let
(*             val key = Value.id value *)
            val () = log (DEBUG, "kademlia/store",
               fn () => ("Store value " ^ Id.toString id))
            
            fun nodeLookupCb nil =
               (log (WARNING, "kademlia/store",
                  fn () => "Node lookup failed while storing value "
                     ^ Id.toString id)
               ; callback 0)
              | nodeLookupCb l =
               let
                  val count = ref (List.length l)
                  val success = ref 0
                  val rpc = rpc this
                  fun doStore (nodeId, addr) =
                     let
                        fun storeCb sid =
                           let
                              val () = count := !count - 1
                              val () =
                                 case sid of
                                    SOME _ => success := !success + 1
                                  | NONE => ()
                           in
                              if !count <= 0 then
                                 (log (DEBUG, "kademlia/store",
                                    fn () => ("Stored value to " ^ Int.toString (!success)
                                       ^ " nodes."))
                                 ; callback (!success))
                              else ()
                           end
                     in
                        ignore (NodeRPC.store (rpc,
                           { destAddr = addr, destId = SOME nodeId, id = id, value = value,
                             expiryDate = expiryDate, callback = storeCb }))
                     end
               in
                  List.app doStore l
               end
         in
            lookupNodes (this, { targetId = id, callback = nodeLookupCb })
         end
      
      (* ------------- *)
      (*  constructor  *)
      (* ------------- *)
      fun new (port, storeHandler, retrieveHandler, valuesIterator) =
         let
            (* build fields *)
            val myId = Id.fromRandom (getTopLevelRandom ())
            val buckets = Buckets.new (myId, Config.k)
            val unhookCheckBuckets = ref (fn () => ())
            
            (* create this *)
            val this = T {
               myId = myId,
               rpc = ref NONE,
               buckets = buckets,
               bucketsRefreshed = Array.tabulate (Id.numberOfBits, fn _ => Time.zero),
               unhookCheckBuckets = unhookCheckBuckets
            }
            
            val () = (get#rpc this) := SOME (NodeRPC.new {
               port = port,
               myId = myId,
               updateNode = updateNode (this, valuesIterator),
               nodeTimeout = nodeTimeout buckets,
               pingRequestHandler = pingRequestHandler,
               findNodeRequestHandler = findNodeRequestHandler buckets,
               storeRequestHandler = storeRequestHandler storeHandler,
               findValueRequestHandler = findValueRequestHandler (buckets, retrieveHandler)
            })
            
            (* setup buckets refresh check *)
            fun checkBucketsFun event =
               (checkBuckets this
               ; Event.scheduleIn (event, Config.checkBucketsInterval))
            val checkBucketsEvent = Event.new checkBucketsFun
            val () = Event.scheduleIn (checkBucketsEvent, Config.checkBucketsInterval)
            val () = unhookCheckBuckets := (fn () => Event.cancel checkBucketsEvent)
            
            (* print my id *)
            val () =
               log (INFO, "kademlia/init",
                  fn () => ("Hello, I am " ^ Id.toString myId ^ "."))
         in
            this
         end
      
      fun destroy this =
         let
            (* unschedule check-buckets event *)
            val () = !(get#unhookCheckBuckets this) ()
         in
            NodeRPC.destroy (rpc this)
         end
      
      fun myId this =
         get#myId this
      
      fun join (this, addr, callback) =
         let
            val myId = get#myId this
            val buckets = get#buckets this
            
            fun refreshBucketsFrom closestNeighbor =
               let
                  fun refreshFrom bid =
                     if bid < Id.numberOfBits
                     then refreshBucket (this, bid, fn () => refreshFrom (bid + 1))
                     else ()
                  val refBucket = Buckets.bucketId (buckets, closestNeighbor) + 1
               in
                  refreshFrom refBucket
               end
            
            (* connect to bootstrap node *)
            fun nodeLookupCallback nil =
               let
                  val () = log (ERROR, "kademlia/join",
                     fn () => "Could not lookup nodes using bootstrap node!")
               in
                  (* indicate join failure *)
                  callback false
               end
             | nodeLookupCallback l =
               let
                  (* further lookups for populating routing table *)
                  val () = refreshBucketsFrom (#1 (List.hd l))
               in
                  (* indicate join success *)
                  callback true
               end
            
            fun pingCallback NONE =
               let
                  val () = log (ERROR, "kademlia/join",
                     fn () => "Could not contact bootstrap node!")
               in
                  (* indicate join failure *)
                  callback false
               end
             | pingCallback (SOME id) =
               let
                  val () = log (INFO, "kademlia/join",
                     fn () => ("Bootstrap node is " ^ Id.toString id ^ "."))
               in
                  lookupNodesRetry (this, { targetId = myId, retries = 3, callback = nodeLookupCallback })
               end
               
            val () = log (INFO, "kademlia/join",
               fn () => ("Contacting " ^ Address.toString addr ^ "..."))
         in
            pingRetry (this, { destAddr = addr, destId = NONE, retries = 3, callback = pingCallback })
         end
      
      fun store (this, id, value, expiryDate, callback) =
         let
            val expiryDate =
               case expiryDate of
                  SOME d => d
                | NONE => Time.+ (Event.time (), Config.defaultExpiration)
         in
            storeWithExpiryDate (this, id, value, expiryDate, callback)
         end
      
      fun retrieve (this, id, callback) =
         lookupValue (this, { targetId = id, callback = callback })
      
      fun getExpirationFactor (this, id) =
         let
            val c = Buckets.countCloserNodes (get#buckets this, id)
         in
            if c <= Config.k then 1.0
            else Real32.fromLarge IEEEReal.TO_NEAREST
                 (Math.exp (Real.fromInt (Config.k - c) / Real.fromInt Config.k))
         end
      
   end
