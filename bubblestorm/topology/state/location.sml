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

structure Location :> LOCATION = 
   struct
      val module = "topology/location"
   
      datatype subjoin = CLIENT | PEER
      datatype subleave = LINGER | QUIT
      datatype goal = JOIN of subjoin | LEAVE of subleave
      
      datatype state =
         STATE of { master : masterInfo peer, slave  : slaveInfo peer }
      and 'a peer =
         NOTHING
       | CONNECTING of bool -> unit
       | CONNECTED of 'a
       | ZOMBIE of 'a
      withtype slaveInfo = {
         slave     : Neighbour.t, 
         makeSlave : makeSlave, 
         leave     : leaveSlaveIn option 
      }
      and masterInfo = { 
         master  : Neighbour.t, 
         upgrade : upgradeIn option,
         leave   : leaveMasterIn option 
      }
      
      datatype t = T of {
         id          : int,
         state       : state ref,
         goal        : goal ref,
         evaluate    : Main.Event.t,
         updateLinks : { min : int, actual : int, max : int } -> unit
      }

      fun toString (T { id, state = ref (STATE {master, slave}), ... }) =
         let
            fun state g x =
               case x of 
                  NOTHING => "-"
                | CONNECTING _ => "connecting"
                | ZOMBIE z => "zombie " ^ g z
                | CONNECTED z => g z
            
            val master = state (Neighbour.toString o #master) master
            val slave  = state (Neighbour.toString o #slave)  slave
            val id = Int.toString id
         in
            concat [ "location #", id, " (", master, ", ", slave, ")" ]
         end
      
      fun goal  (T { goal,  ... }) = !goal
      fun leaving this = case goal this of LEAVE _ => true | _ => false
      fun state (T { state, ... }) = !state
      fun evaluate (T { evaluate, ... }) =
         Main.Event.scheduleIn (evaluate, Time.fromNanoseconds 0)
      
      (* our slave is only stable if:
       *   -- we have a CONNECTED slave
       *   -- we master a CONNECTED master with no upgrade function
       *)
      fun peerWithStableSlave (STATE {slave=CONNECTED _, ... }) = true
        | peerWithStableSlave (STATE {slave=NOTHING, master=CONNECTED {upgrade=NONE, ... }, ... }) = true
        | peerWithStableSlave _ = false
      fun hasStableSlave this = 
         peerWithStableSlave (state this) andalso not (leaving this)
      
      fun slave this =
         case state this of
            STATE { slave=CONNECTED {slave, ...}, ... } => SOME slave
          | STATE { slave=ZOMBIE    {slave, ...}, ... } => SOME slave
          | _ => NONE
      fun master this =
         case state this of
            STATE { master=CONNECTED { master, ... }, ... } => SOME master
          | STATE { master=ZOMBIE    { master, ... }, ... } => SOME master
          | _ => NONE
      
      fun slaveIs (this, n) =
         case slave this of
            NONE => false
          | SOME m => Neighbour.eq (n, m)
      fun masterIs (this, n) =
         case master this of
            NONE => false
          | SOME m => Neighbour.eq (n, m)

      (* fully connected neighbours *)
      fun actualDegree (CONNECTED _) = 1
         | actualDegree _ = 0
            
      (* count only fully connected neighbours in locations that are not leaving *)
      fun minDegree (this as T { state = ref (STATE { master, slave }), ... }) =
         if leaving this then 0 
         else actualDegree master + actualDegree slave

      fun maxDegree (this as T { state = ref (STATE { master, slave }), ... }) =
         let
            (* count zombies as nothing for max degree, they will get disconnected *)
            fun zombieToNothing x = 
               case x of
                  ZOMBIE _ => NOTHING 
                | x => x
         in            
            case (zombieToNothing master, zombieToNothing slave) of
               (NOTHING, NOTHING) => if leaving this then 0 else 2 (* will only rejoin if not leaving *)
             | (NOTHING, _) => 1 (* master is broken edge *)
             | (CONNECTED { upgrade = NONE, ... }, NOTHING) => 1 (* slave is broken edge *)
             | _ => 2 (* count connected & connecting *)
         end

      (* link counting and updating *)
      fun updateMyLinks (this as T { updateLinks, state = ref (STATE { master, slave }), ... }) =
         updateLinks ( { 
            min = minDegree this,
            actual = actualDegree master + actualDegree slave,
            max = maxDegree this
         } )
      
      fun setState (this as T { state, ... }, newState) =
         (state := newState
         ; updateMyLinks this)
      
      fun goalToString x =
         case x of
            JOIN CLIENT  => "join as client"
          | JOIN PEER    => "join as peer"
          | LEAVE LINGER => "leave and linger"
          | LEAVE QUIT   => "leave and quit"
      
      fun connectSlave (this as T { id, state, ... }, done) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/connectSlave"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val master =
               case !state of
                  STATE { master, slave=NOTHING } => master
                | _ => raise At (method (), Fail "not NOTHING") 
            val () = setState (this, STATE { master=master, slave=CONNECTING done })
         in
            evaluate this
         end
      
      fun connectMaster (this as T { id, state, ... }, done) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/connectMaster"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val slave =
               case !state of
                  STATE { slave, master=NOTHING } => slave
                | _ => raise At (method (), Fail "not NOTHING") 
            val () = setState (this, STATE { slave=slave, master=CONNECTING done })
         in
            evaluate this
         end
         
      fun connectSlave' (this as T { id, state, ... }, done) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/connectSlave'"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")

            val master =
               case !state of
                  STATE { master, slave=CONNECTING done } => (done true; master)
                | _ => raise At (method (), Fail "not CONNECTING") 
         in
            setState (this, STATE { master=master, slave=CONNECTING done })
         end
         
      fun connectMaster' (this as T { id, state, ... }, done) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/connectMaster'"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")

            val slave =
               case !state of
                  STATE { slave, master=CONNECTING done } => (done true; slave)
                | _ => raise At (method (), Fail "not CONNECTING") 
         in
            setState (this, STATE { slave=slave, master=CONNECTING done })
         end
      
      fun upgrade (this as T { id, state, ... }, done) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/upgrade"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val (slave, { master, leave, upgrade }, constate) =
               case !state of
                  STATE { slave, master=CONNECTED x } => (slave, x, CONNECTED)
                | STATE { slave, master=ZOMBIE x } => (slave, x, ZOMBIE)
                | _ => raise At (method (), Fail "no master") 
            
            val state' = { master=master, upgrade=NONE, leave=leave }
            val () = setState (this, STATE { slave=slave, master=constate state' })
            val () = evaluate this
            (* make sure the slave is marked as connecting now to prevent race *)
            val () = connectSlave (this, done)
         in
            valOf upgrade
         end
      
      fun leaveMaster (this as T { id, state, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/leaveMaster"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val (slave, { master, leave, upgrade }, constate) =
               case !state of
                  STATE { slave, master=CONNECTED x } => (slave, x, CONNECTED)
                | STATE { slave, master=ZOMBIE x } => (slave, x, ZOMBIE)
                | _ => raise At (method (), Fail "no master") 
            
            val state' = { master=master, upgrade=upgrade, leave=NONE }
            val () = setState (this, STATE { slave=slave, master=constate state' })
            val () = evaluate this
         in
            leave
         end
      
      fun leaveSlave (this as T { id, state, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/leaveSlave"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val (master, { slave, leave, makeSlave }, constate) =
               case !state of
                  STATE { master, slave=CONNECTED x } => (master, x, CONNECTED)
                | STATE { master, slave=ZOMBIE x } => (master, x, ZOMBIE)
                | _ => raise At (method (), Fail "no slave") 
            
            val state' = { slave=slave, makeSlave=makeSlave, leave=NONE }
            val () = setState (this, STATE { master=master, slave=constate state' })
            val () = evaluate this
         in
            leave
         end
      
      fun setLeaveMaster (this as T { id, state, ... }, leaveMaster) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/setLeaveMaster"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val (slave, { master, leave, upgrade }, constate) =
               case !state of
                  STATE { slave, master=CONNECTED x } => (slave, x, CONNECTED)
                | STATE { slave, master=ZOMBIE x } => (slave, x, ZOMBIE)
                | _ => raise At (method (), Fail "no master") 
            
            val () = 
               if isSome leave 
               then raise At (method (), Fail "existing leaveMaster")
               else ()
            
            val state' = { master=master, upgrade=upgrade, leave=SOME leaveMaster }
            val () = setState (this, STATE { slave=slave, master=constate state' })
         in
            evaluate this
         end
      
      fun setLeaveSlave (this as T { id, state, ... }, leaveSlave) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/setLeaveSlave"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            
            val (master, { slave, leave, makeSlave }, constate) =
               case !state of
                  STATE { master, slave=CONNECTED x } => (master, x, CONNECTED)
                | STATE { master, slave=ZOMBIE x } => (master, x, ZOMBIE)
                | _ => raise At (method (), Fail "no slave") 
            
            val () = 
               if isSome leave 
               then raise At (method (), Fail "existing leaveSlave")
               else ()
            
            val state' = { slave=slave, makeSlave=makeSlave, leave=SOME leaveSlave }
            val () = setState (this, STATE { master=master, slave=constate state' })
         in
            evaluate this
         end
      
      fun failedSlave (this as T { id, state, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/failedSlave"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            val master =
               case !state of
                  STATE { master, slave=CONNECTING done } => (done false; master)
                | _ => raise At (method (), Fail "not CONNECTING")
            val () = setState (this, STATE { master=master, slave=NOTHING })
         in
            evaluate this
         end
      
      fun failedMaster (this as T { id, state, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/failedMaster"
            val () = Log.logExt (Log.DEBUG, method, fn () => "called")
            val slave =
               case !state of
                  STATE { slave, master=CONNECTING done } => (done false; slave)
                | _ => raise At (method (), Fail "not CONNECTING")
            val () = setState (this, STATE { slave=slave, master=NOTHING })
         in
            evaluate this
         end
      
      fun installSlave (this as T { id, state, ... }, slaveInfo as { slave=newSlave, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/installSlave"
            val () = Log.logExt (Log.DEBUG, method, 
                                 fn () => "called with " ^ Neighbour.toString newSlave)
            val master =
               case !state of
                  STATE { master, slave=CONNECTING done } => (done true; master)
                | _ => raise At (method (), Fail "not CONNECTING")
            
            fun unhook () =
               let
                  val T { id, state, ... } = this
                  fun method () = module ^ "/" ^ Int.toString id ^ "/unhookSlave"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " 
                                    ^ (Neighbour.toString o valOf o slave) this)

                  val () = 
                     case !state of
                        STATE {master, slave=_} =>
                           setState (this, STATE {master=master, slave=NOTHING})
                  val () = Neighbour.setName (newSlave, "unhooked slave " ^ Int.toString id)
               in
                  evaluate this
               end
            
            fun teardown () =
               let
                  val T { id, state, ... } = this
                  fun method () = module ^ "/" ^ Int.toString id ^ "/teardownSlave"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " 
                                    ^ (Neighbour.toString o valOf o slave) this)
                  
                  val () =
                     case !state of
                        STATE {master, slave=CONNECTED s} =>
                           setState (this, STATE {master=master, slave=ZOMBIE s})
                      | _ => 
                         raise At (method (), Fail "not CONNECTED")
                  val () = Neighbour.setName (newSlave, "torn down slave " ^ Int.toString id)
               in
                  evaluate this
               end
               
            val () = Neighbour.setUnhook (newSlave, unhook)
            val () = Neighbour.setTeardownHandler (newSlave, teardown)
            val () = Neighbour.setName (newSlave, "slave " ^ Int.toString id)
            
            val () = setState (this, STATE { slave=CONNECTED slaveInfo, master=master })
         in
            evaluate this
         end
      
      fun installMaster (this as T { id, state, ... }, masterInfo as { master=newMaster, ... }) =
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/installMaster"
            val () = Log.logExt (Log.DEBUG, method, 
                                 fn () => "called with " ^ Neighbour.toString newMaster)
            val slave =
               case !state of
                  STATE { slave, master=CONNECTING done } => (done true; slave)
                | _ => raise At (method (), Fail "not CONNECTING")
            
            fun unhook () =
               let
                  val T { id, state, ... } = this
                  fun method () = module ^ "/" ^ Int.toString id ^ "/unhookMaster"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " 
                                 ^ (Neighbour.toString o valOf o master) this)

                  val () = 
                     case !state of
                        STATE {slave, master=_} =>
                           setState (this, STATE {slave=slave, master=NOTHING})
                  val () = Neighbour.setName (newMaster, "unhooked master " ^ Int.toString id)
               in
                  evaluate this
               end
            
            fun teardown () =
               let
                  val T { id, state, ... } = this
                  fun method () = module ^ "/" ^ Int.toString id ^ "/teardownMaster"
                  val () = Log.logExt (Log.DEBUG, method, fn () => "called with " 
                                    ^ (Neighbour.toString o valOf o master) this)
                  
                  val () =
                     case !state of
                        STATE {slave, master=CONNECTED m} =>
                           setState (this, STATE {slave=slave, master=ZOMBIE m})
                      | _ => 
                         raise At (method (), Fail "not CONNECTED")
                  val () = Neighbour.setName (newMaster, "torn down master " ^ Int.toString id)
               in
                  evaluate this
               end
            
            val () = Neighbour.setUnhook (newMaster, unhook)
            val () = Neighbour.setTeardownHandler (newMaster, teardown)
            val () = Neighbour.setName (newMaster, "master " ^ Int.toString id)
            
            val () = setState (this, STATE { master=CONNECTED masterInfo, slave=slave })
         in
            evaluate this
         end

      
      fun setGoal (this as T { id, goal, state, ... }, goal')  = 
         let
            fun method () = module ^ "/" ^ Int.toString id ^ "/setGoal"
            val () = Log.logExt (Log.DEBUG, method, fn () => "transition:  " ^ 
                           goalToString (!goal) ^ " -> " ^ goalToString goal')
            
            val change = !goal <> goal'
            val () = goal := goal'
            val () = updateMyLinks this

            val () = case (change, !goal, !state) of
               (true, LEAVE _, STATE { master, slave = CONNECTING doneFn }) =>
                  (* set a more aggressive timeout for outstanding contact slave *)
                  let
                     fun cancel _ =
                        let
                           val () = Log.logExt (Log.WARNING, method, fn () => 
                              "contact slave timed out because we're leaving.")
                        in
                           failedSlave this
                        end
                     val timeout = Main.Event.new cancel
                     val () = Main.Event.scheduleIn (timeout, Config.slaveLeaveTimeout ())
                     (* make sure timeout is canceled if contact succeeds *)
                     fun wrappedDone x =
                        let
                           val () = Main.Event.cancel timeout
                        in
                           doneFn x
                        end
                  in
                     setState (this, STATE { master = master, slave = CONNECTING wrappedDone })
                  end
             | _ => ()
         in
            if change then evaluate this else ()
         end

      fun new { id, updateLinks, evaluate } = 
         let
            val this = ref NONE
            fun eval _ = evaluate (valOf (!this))
            val eval = Main.Event.new eval
            val out = T {
               id = id,
               goal = ref (LEAVE QUIT),
               state = ref (STATE {master=NOTHING, slave=NOTHING}),
               evaluate = eval,
               updateLinks = updateLinks
            }
            val () = this := SOME out
         in
            out
         end
   end
