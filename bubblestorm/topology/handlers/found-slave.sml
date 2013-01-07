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

fun handleFoundSlave
   (HANDLERS { leaveMaster, yesMaster, ... })
   (ACTIONS { makeMethods, ... })
   (STATE { ... }) 
   location (conversation, makeSlave) =
   let
      fun method () = "topology/handler/foundSlave"
      val () = Log.logExt (Log.DEBUG, method, fn () => ("contacted slave " ^ Conversation.toString conversation))

      fun fail () = Location.failedSlave location
      val () = setTopologyLimits (conversation, fail)
      
      fun myLeaveMaster (newSlave, (newAddress, newMakeSlave)) =
         leaveMaster (location, newSlave) newAddress newMakeSlave
      val (setupNewSlave, leaveMaster) = combine myLeaveMaster
      val (leaveMaster, _) =
         Conversation.response (conversation, {
            method   = fn x => fn y => leaveMaster (x, y),
            methodTy = leaveMasterTy
         })

      fun myYesMaster ((x, y, z, a), outstream) =
         yesMaster (conversation, outstream, location, setupNewSlave) x y z a
      val (yesMaster, gotOutstream) = combine myYesMaster
      val (yesMaster, _) =
         Conversation.response (conversation, {
            method   = fn x => fn y => fn z => fn a => yesMaster (x, y, z, a),
            methodTy = yesMasterTy
         })
      
      (* killing the conversation kills the outstream up until saveOutstream *)
      fun done true = ()
        | done false = Conversation.reset conversation
      val () = Location.connectSlave' (location, done)
      
      fun saveOutstream outstream =
         let
            fun done' ok = 
               (if ok then () else CUSP.OutStream.reset outstream; done ok)
            val () = Location.connectSlave' (location, done')
         in
            gotOutstream outstream
         end
      
      val (methods, _) = makeMethods conversation
   in
      makeSlave methods yesMaster leaveMaster saveOutstream
   end
