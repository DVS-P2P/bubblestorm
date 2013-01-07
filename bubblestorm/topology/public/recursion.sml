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

local
   fun handlers state = HANDLERS {
      bootstrap = bootstrap' state,
      bootstrapOk = bootstrapOk' state,
      bubblecast = bubblecast' state,
      findServer = findServer' state,
      foundBootstrap = foundBootstrap' state,
      foundClient = foundClient' state,
      foundSlave = foundSlave' state,
      gossip = gossip' state,
      leaveClient = leaveClient' state,
      leaveMaster = leaveMaster' state,
      leaveSlave = leaveSlave' state,
      makeClient = makeClient' state,
      makeSlave = makeSlave' state,
      upgrade = upgrade' state,
      upgradeOk = upgradeOk' state,
      yesServer = yesServer' state,
      yesMaster = yesMaster' state
   }
   and bootstrap' state z = handleBootstrap (handlers state) (actions state) state z
   and bootstrapOk' state z = handleBootstrapOk (handlers state) (actions state) state z
   and bubblecast' state z = handleBubblecast (handlers state) (actions state) state z
   and findServer' state z = handleFindServer (handlers state) (actions state) state z
   and foundBootstrap' state z = handleFoundBootstrap (handlers state) (actions state) state z
   and foundClient' state z = handleFoundClient (handlers state) (actions state) state z
   and foundSlave' state z = handleFoundSlave (handlers state) (actions state) state z
   and gossip' state z = handleGossip (handlers state) (actions state) state z
   and leaveClient' state z = handleLeaveClient (handlers state) (actions state) state z
   and leaveMaster' state z = handleLeaveMaster (handlers state) (actions state) state z
   and leaveSlave' state z = handleLeaveSlave (handlers state) (actions state) state z
   and makeClient' state z = handleMakeClient (handlers state) (actions state) state z
   and makeSlave' state z = handleMakeSlave (handlers state) (actions state) state z
   and upgrade' state z = handleUpgrade (handlers state) (actions state) state z
   and upgradeOk' state z = handleUpgradeOk (handlers state) (actions state) state z
   and yesServer' state z = handleYesServer (handlers state) (actions state) state z
   and yesMaster' state z = handleYesMaster (handlers state) (actions state) state z
   
   and actions state = ACTIONS {
      bubblecast = bubblecast state,
      contactClient = contactClient' state,
      contactSlave = contactSlave' state,
      create = create' state,
      flushClients = flushClients' state,
      join = join' state,
      makeMethods = makeMethods' state,
      pushFish = pushFish' state,
      startGossip = startGossip' state,
      startWalk = startWalk' state,
      upgrade = doUpgrade' state
   }
   and bubblecast state z = doBubblecast (handlers state) (actions state) state z
   and contactClient' state z = doContactClient (handlers state) (actions state) state z
   and contactSlave' state z = doContactSlave (handlers state) (actions state) state z
   and create' state z = doCreate (handlers state) (actions state) state z
   and evaluate' state z = doEvaluate (handlers state) (actions state) state z
   and evaluateN' state z = doEvaluateN (handlers state) (actions state) state z
   and flushClients' state z = doFlushClients (handlers state) (actions state) state z
   and join' state z = doJoin (handlers state) (actions state) state z
   and makeMethods' state z = doMakeMethods (handlers state) (actions state) state z
   and pushFish' state z = doPushFish (handlers state) (actions state) state z
   and startGossip' state z = doStartGossip (handlers state) (actions state) state z
   and startWalk' state z = doStartWalk (handlers state) (actions state) state z
   and doUpgrade' state z = doUpgrade (handlers state) (actions state) state z
in
   val bubblecast = bubblecast
   val evaluate = evaluate'
   val evaluateN = evaluateN'
   val create = create'
   val flushClients = flushClients'
end
