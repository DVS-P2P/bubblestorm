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

structure BasicBubbleType :> BASIC_BUBBLE_TYPE =
   struct
      fun module () = "bubblestorm/bubble/basic-bubble-type"
      
      exception BubbleIdInUse 

      (* -------------- datatypes -------------------------------------------*)

      datatype t = T of {
         state  : bubbleState,
         class  : bubbleClass,
         typeId : int,
         name   : string,
         priority : Real32.real,
         reliability : Real32.real,
         currentSize : Real64.real ref,
         oldSize  : Real64.real ref,
         matches  : matchConstraint list ref,
         minimum  : (t -> Real64.real) ref,
         cost     : BubbleCostMeasurement.t,
         sizeStat : Statistics.t option ref
      }
      
      and bubbleState =
         STATE of {
            endpoint : CUSP.EndPoint.t,
            topology : Topology.t,
            measurement : Measurement.t,
            attributes : NodeAttributes.t,
            stats : SystemStats.t,
            bubbletypes : t IDHashTable.t
         }
            
      and bubbleClass =
         INSTANT
       | FADING of {
            store : ID.t * Word8VectorSlice.slice -> unit
         }
       | MANAGED of {
             cache     : ManagedDataCache.t,
             datastore : ManagedDataStore.t
          }
       | DURABLE of {
            datastore : DurableDataStore.t
         }
       | MAXIMUM of {
            withBubbles : t list ref,
            handler     : int * Word8VectorSlice.slice -> unit
         }
 
      and matchConstraint = MATCH of {
         object  : t,
         lambda  : Real64.real,
         handler : ID.t * Word8VectorSlice.slice -> unit
      }
      
      (* -------------- bubbleState -----------------------------------------*)

      val endpoint    = fn  (STATE { endpoint, ... })    => endpoint
      val topology    = fn  (STATE { topology, ... })    => topology
      val measurement = fn  (STATE { measurement, ... }) => measurement
      val attributes  = fn  (STATE { attributes, ... })  => attributes
      val stats       = fn  (STATE { stats, ... })       => stats
      val bubbletypes = fn  (STATE { bubbletypes, ... }) => bubbletypes
      
      exception NotConnected

      fun address (STATE { topology, ... }) =
         case Topology.address topology of
            SOME address => address
          | NONE => raise NotConnected

      (* -------------- basic attributes ------------------------------------*)

      val typeId      = fn (T { typeId, ... })   => typeId
      val name        = fn (T { name, ... })     => name
      val priority    = fn (T { priority, ... }) => priority
      val reliability = fn (T { reliability, ... }) => reliability
      val state       = fn (T { state, ... })    => state
      val class       = fn (T { class, ... })    => class
      fun costMeasurement (T { cost, ... }) = cost
      
      fun toString (T { typeId, name, ... }) =
         "#" ^ (Int.toString typeId) ^ " \"" ^ name ^ "\""
      
      (* -------------- bubble size -----------------------------------------*)

      val compensation = 1.0
      
      fun targetSizeReal (this as T { currentSize, ... }) =
         let
            fun compensator () =
               SystemStats.dependencyCompensator (stats (state (this)))
         in
            case class this of
               FADING _ =>  !currentSize * compensator ()
             | MANAGED _ => !currentSize * compensator () * compensation
             | MAXIMUM _ => !currentSize * compensator () * compensation
             | _ => !currentSize
          end

      fun oldSizeReal (this as T { oldSize, ... }) =
         let
            fun compensator' () =
               SystemStats.dependencyCompensator' (stats (state (this)))
         in
            case class this of
               FADING _ =>  !oldSize * compensator' ()
             | MANAGED _ => !oldSize * compensator' () * compensation
             | MAXIMUM _ => !oldSize * compensator' () * compensation 
             | _ => !oldSize
         end

      fun defaultSizeReal this =
         Real64.max (targetSizeReal this, oldSizeReal this)

      val defaultSize = Real64.ceil o defaultSizeReal
      val targetSize = Real64.ceil o targetSizeReal
      val oldSize = Real64.ceil o oldSizeReal
      
      fun setNewSize  (this as T { currentSize, oldSize, ... }, newSize) =
         let
            val () = Log.logExt (Log.DEBUG, module, fn () =>
                  "Bubble " ^ toString this ^ " size = " ^ Real64.toString newSize)
            val () = oldSize := !currentSize
         in
            currentSize := newSize
         end

      fun setSizeStat (this as T { sizeStat, ... }, stat) =
         let
            fun poll stat =
               (* do not contribute to bubble size statistics if we haven't
                  received measurement data yet *)
               if SystemStats.round (stats (state this)) = 0w0 then () else
                  Statistics.add stat (Real32.fromInt (targetSize this))
            val () =
               case stat of
                  SOME stat => Statistics.addPoll (stat, fn () => poll stat)
                | NONE => ()
         in
            sizeStat := stat
         end
         
      fun setCostStat (T { cost, ... }, stat) =
         BubbleCostMeasurement.setStatistic (cost, stat)

      (* -------------- bubblecast ------------------------------------------*)

      fun slicecast { bubbleType as T {typeId, state, cost, ...}, size } =
         let
            fun method () = module () ^ "/slicecast"
            
            (* use the same seed for all slices *)
            (* TODO word64 is too big for the slicecast seed *)
            val seed = Random.word64 (getTopLevelRandom (), NONE)
            
            fun doSlice {data, start, stop} =
               let
                  val topology = topology state
                  (* start & stop should be within [0, bubbleSize] *)
                  val start = Int.max (start, 0)
                  val stop = Int.min (stop, size)
                  (* count the locally injected traffic *)
                  val sliceSize = Real32.fromInt (stop - start)
                  val defaultSize = (Real32.fromInt o defaultSize) bubbleType
                  val () = BubbleCostMeasurement.injectCostFraction 
                              (cost, data, sliceSize / defaultSize)

                  val () = Log.logExt (Log.DEBUG, method, 
                           fn () => "Cast bubble " ^ toString bubbleType ^
                                    " for interval [" ^ Int.toString start ^
                                    "," ^ Int.toString stop ^ ")")
               in
                  Topology.bubblecast (topology, {
                     typ     = typeId,
                     seed    = seed,
                     size    = size,
                     start   = start,
                     stop    = stop,
                     payload = data
                  })
               end
         in
            doSlice
         end

      fun bubblecast { bubbleType, size, data } =
         slicecast { bubbleType=bubbleType, size=size }
                   { data=data, start=0, stop=size }

      (* -------------- minimum constraints ---------------------------------*)
      
      fun setMinimum (T { minimum, ... }, newMinimum) = minimum := newMinimum
      
      fun computeMinimum (this as T { minimum, ... }) = !minimum this
      
      (* -------------- match constraints -----------------------------------*)

      fun match { subject, object, lambda, handler } =
         let
            val T { matches, ... } = subject
            val constraint =
               MATCH {
                  object = object,
                  lambda = lambda,
                  handler = handler
               }     
         in
            matches := constraint :: !matches
         end

      val matches = fn (T { matches, ... }) => !matches

      fun intersects (MATCH { object, lambda, ... }, pos) =
         let
            (* solve bubble size equation for x:
             * 1 - e ^ -l*wm*wm*T <= (1 - e ^ -x*wm) (1 - e ^ -y*wm)
             * x >= -1/wm log ( 1 - (1 - e ^ -l*wm*wm*T) / (1 - e ^ -y*wm))
             * =: matchSize
             * 
             * the matchSize is the size a bubble must have to 
             * fulfill the constraint. only do the matching if
             * pos <= ceil (matchSize)
             *)
            open Real64
            open Math
            
            val T { state, ... } = object
            val stats = stats state
            val d1 = SystemStats.d1 stats
            val d2 = SystemStats.d2 stats
            val dm = SystemStats.dMax stats
            
            val wm = dm / d1
            val Sw2 = d2/(d1*d1)

            val size = (Real64.fromInt o defaultSize) object
            val threshold = 1.0 - exp (~lambda * wm*wm/Sw2)
            val otherBubble = 1.0 - exp (~size * wm)
            val ratio = 1.0 - threshold / otherBubble
            val () =
               if ratio >= 0.0 then () else
               Log.logExt (Log.WARNING, module, fn () => 
                  "Bad ratio; lambda=" ^ toString lambda ^ 
                  ", other=" ^ toString size ^ 
                  ", d2 = " ^ toString d2)
            (* Deal with rounding error making ratio < 0 *)
            val ratio = max (ratio, minPos)
            val matchSize = ~(ln ratio) / wm
            val matchSize = ceil matchSize
            val intersects = Int.<= (pos, matchSize)
            fun toString x = if x then "intersects" else "does not intersect"
            val module = fn () => module () ^ "/intersects"
            val () = Log.logExt (Log.DEBUG, module, fn () => ((toString intersects) ^
                        "! pos=" ^ (Int.toString pos) ^ " matchSize=" ^
                        (Int.toString matchSize)))
         in
            intersects
         end

      (* do rendezvous matching with other bubbletypes *)
      fun doMatching (typ, pos) (id, data) =
         let
            fun match (constraint as MATCH { handler, ... }) =
               if intersects (constraint, pos)
                  then handler (id, data)
                  else ()
         in
            List.app match (matches typ)
         end
         
      (* ------ bubblecast-related callback functions for the topology ------ *)

      fun maxSize typ () = 
         Real64.ceil (defaultSizeReal typ * Config.maxBubbleOvershoot)
      
      fun getPriority typ size =
         let
            val size = Real32.fromInt size
            val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
         in
            (* increase the priority for big bubbles to make bubblecast faster *)
            (priority typ) + size / (toReal32 (defaultSizeReal typ))
         end

      fun getReliability typ size =
         let
            val size = Real32.fromInt size
            val toReal32 = Real32.fromLarge IEEEReal.TO_NEAREST o Real64.toLarge
         in
            (* increase the priority for big bubbles to make bubblecast faster *)
            (reliability typ) + size / (toReal32 (defaultSizeReal typ))
         end

      local      
         val {length, fromVector, ...} = Serial.methods ID.t
      in
         (* an all-zero ID for ID match functions in a type without IDs.
            will never be actually used because such types do not allow 
            match functions that take IDs. *)
         val fakeID = fromVector (Word8Vector.tabulate (length, fn _ => 0w0))
      end
      
      (* process incoming bubblecast messages *)
      fun process typ (pos, payload) =
         let
            (* parse ID, remaining payload is the data *)
            fun extractID payload =
               let
                  (* TODO: cannot extract ID if payload is too short... *)
                  val {length, parseVector, ...} = Serial.methods ID.t
                  val id = parseVector (Word8VectorSlice.slice (payload, 0, SOME length))
                  val data = Word8VectorSlice.slice (payload, length, NONE)
               in
                  (id, data)
               end
            
            fun extractNoID payload = (fakeID, Word8VectorSlice.full payload)
         in
            case class typ of
               INSTANT => doMatching (typ, pos) (extractNoID payload)
             | FADING { store } => 
                  let
                     val payload = extractID payload
                     (* store locally *)
                     val () = store payload
                  in
                     doMatching (typ, pos) payload
                  end
             | MANAGED _ => Log.logExt (Log.INFO, module, 
                     fn () => "dropping bubblecast of managed type")
             | DURABLE _ => Log.logExt (Log.INFO, module, 
                     fn () => "dropping bubblecast of durable type")
             | MAXIMUM { handler, ... } => 
                  handler (pos, Word8VectorSlice.full payload)
         end

      fun setBubblecastHandler (STATE { topology, bubbletypes, ... }) =
         let
            (* register bubblecast handler with topology *)
            fun bubblecaster typ =
               case IDHashTable.get (bubbletypes, typ) of
                  SOME btype => {
                     maxSize = maxSize btype,
                     process = process btype,
                     priority = getPriority btype,
                     reliability = getReliability btype
                  }
                | NONE => 
                  let
                     val () = Log.logExt (Log.INFO, module, 
                           fn () => "unknown bubble type " ^ (Int.toString typ))
                  in
                     {
                        (* we don't know the size, prevent shrinking *)
                        maxSize = fn () => Option.valOf (Int.maxInt),
                        (* we can't process it *)
                        process = fn _ => (),
                        (* leave it at the default priority,
                           that should be lower than other bubbles *)
                        priority = fn _ => Config.defaultQueryPriority,
                        reliability = fn _ => Config.defaultBubblecastReliability
                     }
                  end
         in
            Topology.setBubblecastHandler (topology, bubblecaster)
         end
                  
      (* -------------- new -------------------------------------------------*)

      fun newBubbleState (topology, attributes) =
         let
            (* create measurement set *)
            val measurement = Measurement.new (Config.balanceFrequency ())
            val () = Topology.addMeasurement (topology, measurement)

            val state = STATE {
               endpoint = Topology.endpoint topology,
               topology = topology,
               measurement = measurement,
               attributes = attributes,
               stats = SystemStats.new (topology, measurement, attributes),
               bubbletypes = IDHashTable.new ()
            }

            val () = setBubblecastHandler state
         in
            state
         end

      fun new { state, class, name, typeId, priority, reliability } =
         let
            val bubble = T {
               state = state,
               class = class,
               typeId = typeId,
               name = name,
               priority = priority,
               reliability = reliability,
               currentSize = ref 0.0,
               oldSize = ref 0.0,
               matches = ref [],
               minimum = ref (fn _ => 1.0), (* default minimum size is 1 *)
               cost = BubbleCostMeasurement.new (measurement state),
               sizeStat = ref NONE
            }
            
            val STATE { bubbletypes, ... } = state
            val () = IDHashTable.add (bubbletypes, typeId, bubble) 
               handle IDHashTable.KeyExists => raise BubbleIdInUse
         in
            bubble
         end
   end
