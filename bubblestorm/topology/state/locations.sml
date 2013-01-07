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

structure Locations :> LOCATIONS =
   struct
      val module = "topology/locations"

      structure NeighbourKey =
         struct
            type t = int
            val hash = Hash.int
            val op == = op =
         end
      structure NeighbourHash = HashTable(NeighbourKey)
      structure AddressHash = HashTable(CUSP.Address)

      datatype minDegree    = LOW | ENOUGH | TOO_MUCH
      datatype maxDegree    = ZERO | NEED_MORE | SATISFIED

      datatype progress =
           IN_PROGRESS of unit -> unit
         | COMPLETE of unit -> unit
      datatype goal = JOIN of progress | LEAVE of progress

      datatype t = T of {
         goal            : goal ref,
         desiredDegree   : int,
         minDegree       : int ref, (* # of links that are not disconnecting *)
         actualDegree    : int ref, (* # of connected links *)
         maxDegree       : int ref, (* # of current + connecting/planned *)
         degreeTable     : (int * int * int) array, (* degrees of locations *)
         table           : Location.t array,
         activeLocations : int ref, (* the number of locations currently set to join *)
         evaluate        : unit -> unit
      }

      (* returns a random-permitation iterator over [0..n) *)
      fun permute (seed, n) =
         let
            val seed = Word32.fromLarge (Word64.toLarge seed)
            val count = ref 0
            val hash = Lookup3.make Hash.int
            
            fun rand m =
               let
                  val last = !count
                  val () = count := last + 1
                  val (out, _) = hash (last, seed)
               in
                  Word32.toInt (out mod Word32.fromInt m)
               end
               
            (* [front, back) is the unpermuted range *)
            val front = ref 0
            val back = ref n
            val map = NeighbourHash.new ()
            
            fun swap i =
               let
                  val j = !front + rand (!back - !front)
                  fun get i = getOpt (NeighbourHash.get (map, i), i)
                  val out = get j
                  val () = NeighbourHash.set (map, j, get i)
                  val () = NeighbourHash.set (map, i, out)
               in
                  out
               end
            
            fun swapFront () =
               swap (!front) before front := !front + 1
            fun swapBack () =
               swap (!back - 1) before back := !back - 1
            
            fun cached (i, f) =
               if i < !front orelse i >= !back
               then valOf (NeighbourHash.get (map, i))
               else f ()
            
            fun forward i =
               if i = n then Iterator.EOF else
               Iterator.VALUE (cached (i, swapFront), fn () => forward (i+1))
            fun backward i =
               if i = ~1 then Iterator.EOF else
               Iterator.VALUE (cached (i, swapBack), fn () => backward (i-1))
         in
            (forward 0, backward (n-1))
         end
      
      fun degreeTolerance desired = 
         (Real.round o Real.Math.sqrt)
         (Real.fromInt desired / Real.fromInt Config.minDegree)         
      fun minIdeal desired = desired - (degreeTolerance desired)
      fun maxIdeal desired = desired + (degreeTolerance desired)

      fun degreeState (min, max, desired) =
         let
            val minState =
               if min < (Config.minDegree div 4) then LOW else
               if min <= (maxIdeal desired) then ENOUGH else TOO_MUCH
            val maxState =
               if max = 0 then ZERO else
               if max < (minIdeal desired) then NEED_MORE else SATISFIED
         in
            (minState, maxState)
         end
      fun state (T { desiredDegree, minDegree, maxDegree, ... }) =
         degreeState (!minDegree, !maxDegree, desiredDegree)

      fun desiredDegree ( T { desiredDegree, ... }) = desiredDegree

      fun actualDegree ( T { actualDegree, ... }) = !actualDegree

      fun sub (T { table, ... }, i) = Array.sub (table, i)

      fun totalLocations (T { table, ... }) = Array.length table

      fun activeLocations (T { activeLocations, ... }) = !activeLocations

      fun setActiveLocations (T { activeLocations, ... }, value) = activeLocations := value

      fun activeIterator (T { table, activeLocations, ... }) = 
         Iterator.fromArraySlice (ArraySlice.slice (table, 0, SOME (!activeLocations)))

      fun totalIterator (T { table, ... }) = Iterator.fromArray table

      fun randomActiveIterator (this, seed) =
         let
            fun convert i = sub (this, i)
         in
            Iterator.map convert (#1 (permute (seed, activeLocations this)))
         end

      fun activeIndexes this =
         Iterator.fromInterval { start = 0, stop = activeLocations this, step = 1 }

      (* Returns an iterator over the set of neighbours. *)
      fun totalNeighbours this =
         let
            open Iterator
         in
            mapPartial Location.master (Iterator.delay (totalIterator this)) @
            mapPartial Location.slave  (Iterator.delay (totalIterator this))
         end

      fun toTotalNeighbour (this, excludedConversation) i =
         let
            val locations = totalLocations this
            val (pickMaster, i) =
               if i < locations then (true, i) else (false, i - locations)
            val l = sub (this, i)
            val (master, slave) = (Location.master l, Location.slave l)
            fun excluded n =
               case excludedConversation of
                  SOME exC => Conversation.eq (exC, Neighbour.conversation n)
                | NONE => false
            val master : Neighbour.t option = master
         in
            if getOpt (Option.map excluded master, false) orelse
               getOpt (Option.map excluded slave,  false)
            then NONE
            else if pickMaster then master else slave
         end

      (* Returns a random permutation iterator over the set of neighbors. *)
      fun randomTotalNeighbours (this, excludedConversation, seed) =
         Iterator.mapPartial
         (toTotalNeighbour (this, excludedConversation))
         (#1 (permute (seed, totalLocations this * 2)))

      (* Returns to random permutations iterator over the set of neighbors,
         the first starting at the front, the second at the end. *)
      fun randomSplitTotalNeighbours (this, excludedConversation, seed) =
         let
            open Iterator
            val locations = totalLocations this
            val (forward, backward) = permute (seed, locations*2)

            fun get i =
               Iterator.mapPartial (toTotalNeighbour (this, excludedConversation)) i
         in
            (get forward, get backward)
         end

      (* returns the local address on a best-effort basis *)
      fun localAddress this =
         let
            val bestValue = ref NONE
            val bestCount = ref 0
            val count = AddressHash.new ()

            val map =
               CUSP.Host.localAddress o
               Conversation.host      o
               Neighbour.conversation
            val iter = Iterator.mapPartial map (totalNeighbours this)

            fun add a =
               let
                  val x = getOpt (AddressHash.get (count, a), 0) + 1
                  val () =
                     if x <= !bestCount then () else
                     (bestValue := SOME a; bestCount := x)
                  val () = AddressHash.set (count, a, x)
               in
                  x = 3
               end
         in
            case Iterator.find add iter of
               NONE => !bestValue
            | SOME x => SOME x
         end

      (*fun totalIndexes this =
         Iterator.fromInterval { start = 0, stop = totalLocations this, step = 1 }

      (* graphviz dot dump *)
      fun dumpGraphViz this () =
         let
            fun lineStyle (zombie, edgeColour, tail) =
               "[" ::
               (if zombie then "style=dotted," else "") ::
               "color=" :: edgeColour :: "]" :: tail

            val address = getOpt (localAddress this, badSlave)
            val (hash, _) = Lookup3.make CUSP.Address.hash (address, 0w42)

            val pad = "#000000"
            val code = Word32.toString (Word32.>> (hash, 0w8))
            val pad = String.substring (pad, 0, 7 - String.size code)
            val colour = pad ^ code

            fun doit (zombie, idx, f, x, edgeColour, tail) =
               "  \"" :: Neighbour.localName (f x) :: "\""
                  :: " [shape=box,color=\"" :: colour :: "\",label=\""
                  :: CUSP.Address.toString address :: "/" :: Int.toString idx
                  :: "\"];\n"
                  :: "  \"" ^ Neighbour.localName (f x) :: "\" -> "
                  :: "\"" ^ Neighbour.remoteName (f x) :: "\" "
                  :: lineStyle (zombie, edgeColour, ";\n" :: tail)
            fun processPeer (_, _, Location.NOTHING, _, tail) = tail
              | processPeer (_, _, Location.CONNECTING _, _, tail) = tail
              | processPeer (idx, f, Location.CONNECTED x, edgeColour, tail) = doit (false, idx, f, x, edgeColour, tail)
              | processPeer (idx, f, Location.ZOMBIE    x, edgeColour, tail) = doit (true,  idx, f, x, edgeColour, tail)
            fun locationEdge ((Location.CONNECTED {master, ...},
                               Location.CONNECTED {slave, ...}), tail) =
                   "  \"" ^ Neighbour.localName master :: "\" -> "
                      :: "\"" ^ Neighbour.localName slave :: "\""
                      :: " [style=\"setlinewidth(10)\",weight=10,dir=none];\n" :: tail
              | locationEdge (_, tail) = tail

            fun processLocation (locIdx, tail) =
               case Location.state (sub (this, locIdx)) of
                  Location.STATE {master, slave} =>
                     locationEdge ((master, slave),
                        processPeer (locIdx, #master, master, "black",
                           processPeer (locIdx, #slave, slave, "blue", tail)))

(*
            fun processClient (client, tail) =
                  "  \"" :: Neighbour.localName client :: "\""
                     :: " [shape=circle,color=\"" :: colour :: "\"];\n"
                     :: "  \"" ^ Neighbour.localName client :: "\" -> "
                     :: "\"" ^ Neighbour.remoteName client :: "\""
                     :: lineStyle (false, "black", ";\n" :: tail)
*)
         in
            concat (Iterator.fold processLocation [] (totalIndexes this))
         end
*)
      fun goal (T { goal, ... }) = !goal

      fun leaving this =
         case goal this of
            JOIN _  => false
          | LEAVE _ => true

      fun goalToString x =
         case x of
            JOIN (IN_PROGRESS _)  => "join"
          | JOIN (COMPLETE _)     => "joined"
          | LEAVE (IN_PROGRESS _) => "leave"
          | LEAVE (COMPLETE _)    => "left"

      fun increaseDegree (this as T { activeLocations as ref active, evaluate, ...}) =
         let
            fun method () = module ^ "/increaseDegree"
            val () = Log.logExt (Log.DEBUG, method, fn () => 
               "Activating location " ^ (Int.toString active))
            val loc = sub (this, active)
            val () = activeLocations := active + 1
            val () = Location.setGoal (loc, Location.JOIN Location.PEER)
         in
            evaluate ()
         end

      fun decreaseDegree (this as T { activeLocations as ref active, evaluate, ...}) =
         let
            val newActive = active - 1
            fun method () = module ^ "/decreaseDegree"
            val () = Log.logExt (Log.DEBUG, method, fn () => 
               "Deactivating location " ^ (Int.toString (newActive)))
            val () = activeLocations := newActive
            val loc = sub (this, newActive)
            val () = Location.setGoal (loc, Location.LEAVE Location.QUIT)
         in
            evaluate ()
         end

      fun setGoal (T { goal, table, activeLocations, evaluate, ... }, goal') =
         let
            fun method () = module ^ "/setGoal"
            val () = Log.logExt (Log.DEBUG, method, fn () => 
               "transition:  " ^ goalToString (!goal) ^ " -> " ^ goalToString goal')

            datatype z = datatype Location.peer
            datatype z = datatype Location.state

            val () =
               case (!goal, goal') of
                  (JOIN  (IN_PROGRESS cb), JOIN  (COMPLETE _))    => cb () (* successful join *)
                | (JOIN  (IN_PROGRESS _),  LEAVE (IN_PROGRESS _)) => ()    (* aborted join -> no cb *)
                | (JOIN  (COMPLETE cb),    LEAVE (IN_PROGRESS _)) => cb () (* start leaving *)
                | (LEAVE (IN_PROGRESS cb), LEAVE (COMPLETE _))    => cb () (* successful leave *)
                | (LEAVE (IN_PROGRESS _),  JOIN  (IN_PROGRESS _)) => ()    (* aborted leave -> no cb *)
                | (LEAVE (COMPLETE cb),    JOIN  (IN_PROGRESS _)) => cb () (* start joining *)
                | _ => raise At ("topology/locations", Fail "bad goal transition")

            val () = goal := goal'

            (* update subgoals *)
            fun setGoals goalFn =
               Array.appi (fn (i, l) => Location.setGoal (l, goalFn (i, l))) table
            fun joinDecision (i, l) =
               (* flush superfluous connections *)
               if i >= Config.minDegree div 2 then Location.LEAVE Location.QUIT else
                  case Location.state l of
                     STATE { master = NOTHING, slave = NOTHING }
                     => Location.JOIN Location.CLIENT (* join normally *)
                   | _
                     => Location.JOIN Location.PEER (* restore old location *)
                  
            fun upgradeServers () =
               let
                  fun upgrade l = Location.setGoal (l, Location.JOIN Location.PEER)
               in
                  ArraySlice.app upgrade (ArraySlice.slice (table, 0, SOME (Config.minDegree div 2)))
               end
            val () =
               case goal' of
                  JOIN  (IN_PROGRESS _)  
                  => (setGoals joinDecision; activeLocations := Config.minDegree div 2)
                | JOIN  (COMPLETE _)     
                  => upgradeServers ()
                | LEAVE (IN_PROGRESS _)  
                  => (setGoals (fn _ => Location.LEAVE Location.LINGER); activeLocations := 0)
                | LEAVE (COMPLETE _)     
                  => (setGoals (fn _ => Location.LEAVE Location.QUIT); activeLocations := 0)
         in
            evaluate ()
         end

      fun new { desiredDegree, eval1, evalN } =
         let
            val desiredDegree = Int.max (desiredDegree, Config.minDegree)
            (* keep twice the normally needed locations to be able to
               compensate for broken edges *)
            val numLocations = desiredDegree
            val degreeTable = Array.array (numLocations, (0, 0, 0))
            val minDegree' = ref 0
            val actualDegree' = ref 0
            val maxDegree' = ref 0

            fun update i ( { min, actual, max} ) =
               let
                  val oldState = degreeState (!minDegree', !maxDegree', desiredDegree)

                  fun change (old, new, accumulator) = accumulator := !accumulator - old + new
                  val (oldMin, oldActual, oldMax) = Array.sub (degreeTable, i)
                  val () = change (oldMin, min, minDegree')
                  val () = change (oldActual, actual, actualDegree')
                  val () = change (oldMax, max, maxDegree')
                  val () = Array.update (degreeTable, i, (min, actual, max))

                  val () = if ((!minDegree') <= (!actualDegree') ) then ()
                     else raise At("topology/locations/update",
                               Fail("minimum degree bigger than actual degree"));
                  val () = if ((!actualDegree') <= (!maxDegree') ) then ()
                     else raise At("topology/locations/update",
                               Fail("maximum degree smaller than actual degree"));

                  val state = degreeState (!minDegree', !maxDegree', desiredDegree)
               in
                  if state = oldState then () else evalN ()
               end

            fun make i =
               Location.new { id = i, updateLinks = update i, evaluate = eval1 }

            val table = Array.tabulate (numLocations, make)
            val out = T {
               goal            = ref (LEAVE (COMPLETE (fn () => ()))),
               desiredDegree   = desiredDegree,
               minDegree       = minDegree',
               actualDegree    = actualDegree',
               maxDegree       = maxDegree',
               degreeTable     = degreeTable,
               table           = table,
               activeLocations = ref 0,
               evaluate        = evalN
            }

            val () = Statistics.addPoll (Stats.nodeDegree,
               fn () => (Statistics.add Stats.nodeDegree (Real32.fromInt (actualDegree out))))
            
            fun reportNeighbour n =
               let
                  val conv = Neighbour.conversation n
                  val traffic = Conversation.traffic conv
                  val created = Conversation.created conv
                  val age = Time.- (Main.Event.time (), created)
                  
                  val rate = 
                     (Real32.fromLargeInt (Int64.toLarge traffic)) /
                     (Time.toSecondsReal32 age)
               in
                  Statistics.add Stats.loadBalance rate
               end
            val () = Statistics.addPoll (Stats.loadBalance,
               fn () => Iterator.app reportNeighbour (totalNeighbours out))
               
            (*val () = SimultaneousDump.addDumper (Stats.graphVizDumper, dumpGraphViz out)*)
         in
            out
         end
   end
