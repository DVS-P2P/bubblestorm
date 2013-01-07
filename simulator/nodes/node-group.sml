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

structure NodeGroup :> NODE_GROUP =
   struct
      datatype t = T of {
         definition : NodeDefinition.t,
         mask : int ref,
         nodes : SimulatorNode.t array
      }

      fun definition (T fields) = #definition fields

      fun nodes (T fields) = #nodes fields
      fun totalNodes (T fields) = Array.length (#nodes fields)
      fun activeNodes (T fields) = ! (#mask fields)
      fun getActiveNodes (T fields) =
         let
            val nodes = #nodes fields
            val pos = ! (#mask fields)
         in
            ArraySlice.slice (nodes, 0, SOME pos)
         end
      fun isAlive node = SimulatorNode.isRunning node andalso SimulatorNode.isOnline node
      fun getAliveNodes this =
         Iterator.filter isAlive (Iterator.fromArraySlice (getActiveNodes this))

      (*fun inactiveNodes (this as T fields) =
         let
            val nodes = #nodes fields
            val pos = ! (#mask fields)
         in
            ArraySlice.slice (nodes, pos, NONE)
         end

      fun countOnline (node, count) =
         if SimulatorNode.isOnline node
            then count + 1
         else count

      fun onlineNodes (T fields) = Array.foldl countOnline 0 (#nodes fields)
      fun runningNodes (this) =
         ArraySlice.foldl countOnline 0 (getActiveNodes this)*)

      datatype activeSetChange =
         ADD of SimulatorNode.t ArraySlice.slice
       | REMOVE of SimulatorNode.t ArraySlice.slice
       | NOCHANGE

      fun permuteHead (base, it) =
         let
            val length = ArraySlice.length base

            fun permute pos =
               let
                  val random = Experiment.random ()
                  val randPos = pos + Random.int (random, length - pos)
                  val candidate = ArraySlice.sub (base, randPos)
                  val () = ArraySlice.update (base, randPos, ArraySlice.sub (base, pos))
               in
                  ArraySlice.update (base, pos, candidate)
               end
         in
            Iterator.app permute it
         end

      fun permuteTail (base, it) =
         let
            fun permute pos =
               let
                  val random = Experiment.random ()
                  val randPos = Random.int (random, pos)
                  val candidate = ArraySlice.sub (base, randPos)
                  val () = ArraySlice.update (base, randPos, ArraySlice.sub (base, pos - 1))
               in
                  ArraySlice.update (base, pos - 1, candidate)
               end
         in
            Iterator.app permute it
         end

      fun setActiveNodes (T fields, newPos) =
         let
            val nodes = #nodes fields
            val mask = #mask fields
            val pos = !mask
            val diff = newPos - pos
            val () = mask := newPos
         in
            if diff = 0 then
               NOCHANGE
            else if diff > 0 then
               let
                  (* pick random inactive nodes and activate them *)
                  val it = Iterator.fromInterval {start = 0, stop = diff, step = 1}
                  val () = permuteHead (ArraySlice.slice (nodes, pos, NONE), it)
                  val slice = ArraySlice.slice (nodes, pos, SOME diff)
                  val () = ArraySlice.app (SimulatorNode.setActive true) slice
               in
                  ADD slice
               end
            else
               let
                  (* pick random active nodes and inactivate them *)
                  val it = Iterator.fromInterval {start = pos, stop = newPos, step = ~1}
                  val () = permuteTail (ArraySlice.slice (nodes, 0, SOME pos), it)
                  val slice = ArraySlice.slice (nodes, newPos, SOME (~diff))
                  val () = ArraySlice.app (SimulatorNode.setActive false) slice
               in
                  REMOVE slice
               end
         end

      (* print to log and console *)
      fun myPrint x = (GlobalLog.print x ; print x)
      val nodeGroups = ref NONE
      fun getAll () = case !nodeGroups of
         SOME x => x
       | NONE => raise At ("NodeGroup", Fail ("nodeGroups not initialized"))

      structure AddressMap = HashTable (Address.Ip)
      val staticAddresses = AddressMap.new ()

      fun registerStaticAddress addr =
         case AddressMap.get (staticAddresses, addr) of
            SOME () => raise At ("simulator/node-group",
               Fail ("Duplicate static address: " ^ Address.Ip.toString addr))
          | NONE => AddressMap.add (staticAddresses, addr, ())

      fun isStaticAddress addr =
         Option.isSome (AddressMap.get (staticAddresses, addr))

      (* mapPartial function that takes an array instead of a list *)
      fun mapPartial f arr =
         let
            fun map (~1, lis) = lis
              | map (pos, lis) = map (pos-1, 
                   case f (Array.sub (arr, pos)) of
                      SOME x => x :: lis
                    | NONE => lis
                )
         in
            map (Array.length arr - 1, nil)
         end

      (* database queries for node creation *)
      fun init (totalLPs, localLPId, create, writeDB) =
         let
            val experimentID = Experiment.id ()
            val experimentName = Experiment.name ()
            val random = Experiment.random ()
            val db = Experiment.database ()
            open SQL.Query

            val () = if writeDB then (
                    print "Removing old data from the \"nodes\" table.\n"
                  ; SQL.simpleExec (db, "DELETE FROM nodes WHERE experiment=" ^
                                            (Int.toString experimentID) ^ ";")
               ) else ()

            val nodeDefInsert = prepare db
               "INSERT INTO nodes (experiment, id, node_group, \
               \ location, host, address) VALUES ("iI", "iI", "iI", "iI", NULL, "iX");" $

            val fixedSizeQuery = prepare db
               "SELECT SUM(fixed_size) FROM experiment_node_group WHERE experiment="iS";" oI $
            val relativeSizeQuery = prepare db
               "SELECT SUM(remainder_weight) FROM experiment_node_group WHERE experiment="iS";" oR $
            val nodeGroupQuery = prepare db
               "SELECT id, name,\
               \ fixed_size, remainder_weight, location, static_address,\
               \ connection, crash_ratio, lifetime_type, online_time,\
               \ offline_time, workload, command FROM experiment_node_group\
               \ WHERE experiment="iS" ORDER BY id;"
               (*\ ORDER BY fixed_size DESC, remainder_weight ASC;"*)
                  oI oS oI oR oS oS oS oR oS oS oS oS oS $
            val connectionQuery = prepare db
               "SELECT downstream, upstream, receive_buffer,\
               \ send_buffer, lasthop_delay, msg_loss\
               \ FROM connection_type WHERE name="iS";" oI oI oI oI oI oR $

            (* the total number of nodes from fixed-size node groups *)
            val expFixedSize =
               Vector.sub (SQL.table fixedSizeQuery experimentName, 0)
            (* the sum of all remainder_weights in the node groups *)
            val expRelativeSum =
               Vector.sub (SQL.table relativeSizeQuery experimentName, 0)
            (* total number of nodes in the experiment *)
            val expSize = Int.max (expFixedSize, Experiment.size ())
            val () = myPrint ("Average number of online nodes = " ^ (Int.toString expSize) ^
                              ", number of fixed nodes = " ^ (Int.toString expFixedSize) ^
                              "\n")

            val idCounter = ref 1
            
            (* function to create individual nodes. has to be polymorphic,
               because the master does not want to create SimulatorNode.t *)
            fun initNode (locations, definition, static) createNode pos =
               let
                  val location = Vector.sub (locations, pos)
                  val id = !idCounter
                  val () = idCounter := !idCounter + 1
                  val staticAddress = if static
                     then SOME (Address.Ip.fromWord32 (Word32.fromInt id))
                     else NONE
                  
                  val () = if create then Option.app registerStaticAddress staticAddress else ()
                  val address =
                     case staticAddress of
                        SOME x => SQL.STRING (Address.Ip.toString x)
                      | NONE => SQL.NULL
                  
                  val () = if writeDB then SQL.exec nodeDefInsert (
                     experimentID & id & (NodeDefinition.id definition) &
                     (Location.id location) & address
                  ) else ()

                  (* TODO: better node distribution to increase lookahead and load balance *)
                  fun mode () =
                     case localLPId of
                        NONE => SimulatorNode.IS_LOCAL
                      | SOME LPid => 
                           (case id mod totalLPs of runningOnLP =>
                              if (runningOnLP = LPid)
                                 then SimulatorNode.IS_LOCAL
                                 else SimulatorNode.IS_REMOTE runningOnLP
                           )
               in
                  createNode {
                     mode = mode (),
                     id = id,
                     definition = definition,
                     staticAddress = staticAddress,
                     location = location,
                     random = Random.new (Random.word32 (random, NONE))
                  }
               end
                
            (* read a connection definition from the database *)
            fun connectionProperties name =
               let
                  fun convert (downstream & upstream & receiveBuffer & sendBuffer &
                               lastHopDelay & messageLoss) =
                     ConnectionProperties.new (
                        Bandwidth.fromBytesPerSec downstream,
                        Bandwidth.fromBytesPerSec upstream,
                        receiveBuffer,
                        sendBuffer,
                        Time.fromMilliseconds lastHopDelay,
                        messageLoss
                     )
               in
                  Vector.sub (SQL.map convert connectionQuery name, 0)
                     handle Subscript =>
                        raise At ("simulator/node-group/connection-properties",
                           Fail ("ConnectionProperties " ^ name ^ "not found."))
               end

            fun groupSize (fixedSize, fraction) =
               let
                  val relativeSize = if (Real.== (expRelativeSum, 0.0))
                     then 0
                     else Real.round (Real.fromInt (expSize - expFixedSize) *
                                      fraction / expRelativeSum)
               in
                  fixedSize + relativeSize
               end

            fun parseLifetime (lifetimeType, onlineTime, offlineTime) =
               case lifetimeType of
                  "always on" => LifetimeDistribution.newAlwaysOn ()
                | "exponential" =>
                     let
                        val onlineTime =
                           case Time.fromString onlineTime of
                             SOME x => x
                           | NONE => raise At ("simulator/node-group/parse-lifetime",
                                 Fail ("Online time (" ^ onlineTime ^ ") is not a parseable timestamp."))
                        val offlineTime =
                           case Time.fromString offlineTime of
                             SOME x => x
                           | NONE => raise At ("simulator/node-group/parse-lifetime",
                                 Fail ("Offline time (" ^ offlineTime ^ ") is not a parseable timestamp."))
                     in
                        LifetimeDistribution.newExponential (onlineTime, offlineTime)
                     end
                | _ => raise At ("simulator/node-group/parse-lifetime",
                           Fail ("Unparseable lifetime type (" ^ lifetimeType ^ ")."))

            (* generate group description from database *)
            fun createGroup (id & name & count & fraction & area & static_address &
                             connection & crashRatio & lifetimeType &
                             onlineTime & offlineTime & workload & command) =
               let
                  val lifetime = parseLifetime (lifetimeType, onlineTime, offlineTime)
                  val sizeFactor = Real32./ (1.0, LifetimeDistribution.onlineRatio lifetime)
                  (* The total node group size is computed depending on the lifetime distribution
                     to achieve the desired average number of online nodes. *)
                  val size = Real32.round (Real32.fromInt (groupSize (count, fraction)) * sizeFactor)
                  val convert = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
                  val groupDef = NodeDefinition.new {
                        id = id,
                        name = name,
                        connection = connectionProperties connection,
                        cmdLine = Arguments.fromString command,
                        lifetime = lifetime,
                        crashRatio = convert crashRatio,
                        workload = workload
                     }
                  val locations = Location.generate (area, size)
                  val () =
                     myPrint ("Node group '" ^ name ^ "' (" ^ Int.toString id
                        ^ ") has an effective total size of " ^ Int.toString size ^ "\n")

                  (* use static addresses? *)
                  val static = (static_address = "yes")

                  val nodes = 
                     if create then
                        Array.tabulate (size, initNode (locations, groupDef, static) SimulatorNode.new)
                     else
                        let
                           (* don't create simulator nodes *)
                           val it = Iterator.fromInterval { start=0, stop=size, step=1 }
                           val () = Iterator.app (initNode (locations, groupDef, static) (fn _ => ())) it
                        in
                           Array.fromList []
                        end
                        
                  val addresses = mapPartial SimulatorNode.staticAddress nodes
                  val () = Arguments.registerGroup (name, addresses)
               in
                  T {
                     definition = groupDef,
                     mask = ref 0,
                     nodes = nodes
                  }
               end
         in
            nodeGroups := SOME (SQL.map createGroup nodeGroupQuery experimentName)
         end

      (*fun totalNodesInExperiment () =
         Vector.foldl Int.+ 0 (Vector.map totalNodes nodeGroups)
      fun activeNodesInExperiment () =
         Vector.foldl Int.+ 0 (Vector.map activeNodes nodeGroups)
      fun onlineNodesInExperiment () =
         Vector.foldl Int.+ 0 (Vector.map onlineNodes nodeGroups)
      fun runningNodesInExperiment () =
         Vector.foldl Int.+ 0 (Vector.map runningNodes nodeGroups)*)
  end
