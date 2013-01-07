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

fun doEvaluate 
   (HANDLERS { ... })
   (ACTIONS { join, upgrade, ... }) 
   (STATE { ... }) 
   location = 
   let
      fun method () = "topology/action/evaluate"
      val () = Log.logExt (Log.DEBUG, method, fn () => "called on " ^ Location.toString location)
      
      (* scope in the datatype constructors *)
      datatype z = datatype Location.subjoin
      datatype z = datatype Location.subleave
      datatype z = datatype Location.goal
      datatype z = datatype Location.state
      datatype z = datatype Location.peer
      
      fun slaveLeaveOrDie location =
         let
            fun method' () = (method ()) ^ "/slaveLeaveOrDie"
            val () = Log.logExt (Log.DEBUG, method', fn () => "called on " ^ Location.toString location)
            val slave = valOf (Location.slave location)
            
            fun killHim _ = 
               if Location.slaveIs (location, slave) andalso
                  not (Neighbour.isZombie slave)
               then Neighbour.reset slave
               else ()
            val killHim = Main.Event.new killHim
            val () = Main.Event.scheduleIn (killHim, Config.leaveWait ())
            val () = Neighbour.addDeathHandler (slave, fn () => Main.Event.cancel killHim)
         in
            valOf (Location.leaveSlave location) ()
         end
      
      fun postponeLeaveSlave location =
         case Location.slave location of NONE => () | SOME slave =>
         case Location.leaveSlave location of NONE => () | SOME leaveSlave =>
         let
            fun method' () = (method ()) ^ "/postponeLeaveSlave"
            val () = Log.logExt (Log.DEBUG, method', fn () => "called on " ^ Location.toString location)
            
            fun restoreLeaveSlave _ =
               if Location.slaveIs (location, slave) andalso
                  not (Neighbour.isZombie slave)
               then Location.setLeaveSlave (location, leaveSlave)
               else ()
            val restoreLeaveSlave = Main.Event.new restoreLeaveSlave
            val () = Main.Event.scheduleIn (restoreLeaveSlave, Config.leaveWait ())
            val () = Neighbour.addDeathHandler (slave, fn () => Main.Event.cancel restoreLeaveSlave)
         in
            ()
         end
          
      fun masterLeaveOrDie location =
         let
            fun method' () = (method ()) ^ "/masterLeaveOrDie"
            val () = Log.logExt (Log.DEBUG, method', fn () => "called on " ^ Location.toString location)
            val master = valOf (Location.master location)
            fun killHim _ = 
               if Location.masterIs (location, master) andalso
                  not (Neighbour.isZombie master)
               then Neighbour.reset master
               else ()
            val killHim = Main.Event.new killHim
            val () = Main.Event.scheduleIn (killHim, Config.leaveWait ())
            val () = Neighbour.addDeathHandler (master, fn () => Main.Event.cancel killHim)
            
            val () = postponeLeaveSlave location

            val STATE { slave, ... } = Location.state location
            fun address (slave, makeSlave) =
              case Neighbour.address slave of
                 NONE => (badSlave, badMakeSlave)
               | SOME a => (a, makeSlave)
            val (slave, makeSlave) =
               case slave of
                  NOTHING => (badSlave, badMakeSlave)
                | CONNECTING _ => raise At (method (), Fail "impossible")
                | CONNECTED { slave, makeSlave, ... } => address (slave, makeSlave)
                | ZOMBIE    { slave, makeSlave, ... } => address (slave, makeSlave)
         in
            valOf (Location.leaveMaster location) slave makeSlave
         end
         
   in
      case (Location.goal location, Location.state location) of
         (JOIN _, STATE { master = NOTHING, slave = NOTHING }) 
         => join location
       | (JOIN PEER, STATE { master = CONNECTED { upgrade = SOME _, ...}, slave = CONNECTING stop })
         => stop false (* Our server was replaced, cancel connect and upgrade again *)
       | (JOIN _, STATE { master = CONNECTING _, ... })
         => () (* nothing to do. location has in-progress operation. *)
       | (JOIN _, STATE { slave = CONNECTING _, ... })
         => () (* nothing to do. location has in-progress operation. *)
       | (JOIN _, STATE { master = ZOMBIE { master, ... }, ... })
         => Neighbour.completeTeardown master (* master quit before our upgrade *)
       | (JOIN _, STATE { slave = ZOMBIE { slave, ... }, ... })
         => Neighbour.completeTeardown slave (* became join after leaving *)
       | (JOIN _, STATE { slave = CONNECTED _, ... })
         => () (* nothing to do. location is fully joined. *)
       | (JOIN CLIENT, STATE { master = CONNECTED _, ... })
         => () (* nothing to do. already have a server. *)
       | (JOIN PEER, STATE { master = CONNECTED { upgrade = NONE, ...}, ... })
         => () (* nothing to do. already upgraded. *)
       | (JOIN PEER, STATE { master = CONNECTED { upgrade = SOME _, ...}, ... })
         => upgrade location
       | (LEAVE _, STATE { master = NOTHING, slave = NOTHING })
         => () (* nothing to do. fully left *)
       | (LEAVE _, STATE { master = CONNECTING _, ... })
         => Location.failedMaster location (* kill the join *)
       | (LEAVE _, STATE { slave = ZOMBIE { slave, ... }, ... })
         => Neighbour.completeTeardown slave (* cannot keep slave; he might exit *)
       | (LEAVE _, STATE { slave = CONNECTING _, ... })
         => () (* nothing we can do w/o breaking the topology *)
       | (LEAVE _, STATE { master = NOTHING, slave=CONNECTED { leave = NONE, ... } })
         => () (* nothing to do. leave already sent *)
       | (LEAVE _, STATE { master = NOTHING, slave=CONNECTED { leave = SOME _, ... } })
         => slaveLeaveOrDie location
       | (LEAVE _, STATE { master = CONNECTED { leave = NONE, ... }, ... })
         => () (* nothing to do. leave already sent *)
       | (LEAVE _, STATE { master = CONNECTED { leave = SOME _, ... }, ... })
         => masterLeaveOrDie location
       | (LEAVE LINGER, STATE { master = ZOMBIE { leave = NONE, ... }, ... })
         => () (* nothing to do. leave already sent *)
       | (LEAVE LINGER, STATE { master = ZOMBIE { leave = SOME _, ... }, ... })
         => masterLeaveOrDie location
       | (LEAVE QUIT, STATE { master = ZOMBIE { master, ... }, ... })
         => Neighbour.completeTeardown master (* completely done leaving *)
   end
