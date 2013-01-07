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
   datatype bootstrap     = BOOTSTRAP
   datatype bootstrapOk   = BOOTSTRAP_OK
   datatype findServer    = FIND_SERVER
   datatype makeClient    = MAKE_CLIENT
   datatype yesServer     = YES_SERVER
   datatype upgrade       = UPGRADE
   datatype upgradeOk     = UPGRADE_OK
   datatype makeSlave     = MAKE_SLAVE
   datatype yesMaster     = YES_MASTER
   datatype leaveClient   = LEAVE_CLIENT
   datatype leaveSlave    = LEAVE_SLAVE
   datatype leaveMaster   = LEAVE_MASTER
   datatype bubblecast    = BUBBLECAST
   datatype gossip        = GOSSIP
   datatype keepAlive     = KEEP_ALIVE

   structure Address = CUSP.Address
   open Conversation
   open Serial
   open Config

   fun tMethods b g k f d = { bubblecast=b, gossip=g, keepAlive=k, findServer=f, degree=d }
   fun fMethods F { bubblecast=b, gossip=g, keepAlive=k, findServer=f, degree=d } = F b g k f d
in
   fun bootstrapTy x = Entry.new  {
      name     = "topology/bootstrap",
      datatyp  = BOOTSTRAP,
      ackInfo  = AckInfo.silent,
      duration = Duration.permanent,
      qos      = QOS.static (bootstrapPriority, bootstrapRealiability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyBootstrap,
      receiveStatistics = SOME Stats.receivedTopologyBootstrap
   } `makeClientTy `bootstrapOkTy $ x

   and bootstrapOkTy x = Method.new {
      name     = "topology/bootstrapOk",
      datatyp  = BOOTSTRAP_OK,
      ackInfo  = AckInfo.callback,
      duration = Duration.permanent,
      qos      = QOS.static (bootstrapPriority, topologyReliability),
      tailData = TailData.vector { maxLength = Config.maxGossip },
      sendStatistics    = SOME Stats.sentTopologyBootstrapOk,
      receiveStatistics = SOME Stats.receivedTopologyBootstrapOk
   } `int16l `word32l `word64l `real32l $ x

   and findServerTy x = Method.new {
      name     = "topology/findServer",
      datatyp  = FIND_SERVER,
      ackInfo  = AckInfo.silent,
      duration = Duration.permanent,
      qos      = QOS.static (walkPriority, walkReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyFindServer,
      receiveStatistics = SOME Stats.receivedTopologyFindServer
   } `Address.t `makeClientTy `int16l $ x

   and makeClientTy x = Entry.new  {
      name     = "topology/makeClient",
      datatyp  = MAKE_CLIENT,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.manual,
      sendStatistics    = SOME Stats.sentTopologyMakeClient,
      receiveStatistics = SOME Stats.receivedTopologyMakeClient
   } `methodsTy `yesServerTy `upgradeTy `leaveClientTy $ x

   and yesServerTy x = Method.new {
      name     = "topology/yesServer",
      datatyp  = YES_SERVER,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.manual,
      sendStatistics    = SOME Stats.sentTopologyYesServer,
      receiveStatistics = SOME Stats.receivedTopologyYesServer
   } `methodsTy `makeClientTy $ x

   and upgradeTy x = Method.new {
      name     = "topology/upgrade",
      datatyp  = UPGRADE,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyUpgrade,
      receiveStatistics = SOME Stats.receivedTopologyUpgrade
   } `makeSlaveTy `leaveSlaveTy `upgradeOkTy $ x
   
   and upgradeOkTy x = Method.new {
      name     = "topology/upgradeOk",
      datatyp  = UPGRADE_OK,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyUpgradeOk,
      receiveStatistics = SOME Stats.receivedTopologyUpgradeOk
   } `Address.t `makeSlaveTy `leaveMasterTy $ x
   
   and makeSlaveTy x = Entry.new  {
      name     = "topology/makeSlave",
      datatyp  = MAKE_SLAVE,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.manual,
      sendStatistics    = SOME Stats.sentTopologyMakeSlave,
      receiveStatistics = SOME Stats.receivedTopologyMakeSlave
   } `methodsTy `yesMasterTy `leaveMasterTy $ x
   
   and yesMasterTy x = Method.new {
      name     = "topology/yesMaster",
      datatyp  = YES_MASTER,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.manual,
      sendStatistics    = SOME Stats.sentTopologyYesMaster,
      receiveStatistics = SOME Stats.receivedTopologyYesMaster
   } `methodsTy `makeSlaveTy `leaveSlaveTy $ x
   
   and leaveClientTy x = Method.new {
      name     = "topology/leaveClient",
      datatyp  = LEAVE_CLIENT,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyLeaveClient,
      receiveStatistics = SOME Stats.receivedTopologyLeaveClient
   } `unit $ x
   
   and leaveSlaveTy x = Method.new {
      name     = "topology/leaveSlave",
      datatyp  = LEAVE_SLAVE,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyLeaveSlave,
      receiveStatistics = SOME Stats.receivedTopologyLeaveSlave
   } `unit $ x
   
   and leaveMasterTy x = Method.new {
      name     = "topology/leaveMaster",
      datatyp  = LEAVE_MASTER,
      ackInfo  = AckInfo.silent,
      duration = Duration.oneShot,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyLeaveMaster,
      receiveStatistics = SOME Stats.receivedTopologyLeaveMaster
   } `Address.t `makeSlaveTy $ x
   
   and bubblecastTy x = Method.new {
      name     = "topology/bubblecast",
      datatyp  = BUBBLECAST,
      ackInfo  = AckInfo.silent,
      duration = Duration.permanent,
      qos      = QOS.dynamic,
      tailData = TailData.vector { maxLength = Config.maxBubblecast },
      sendStatistics    = SOME Stats.sentBubblecast,
      receiveStatistics = SOME Stats.receivedBubblecast
   } `int32l `word64l `int32l `int32l `int32l `int32l   $ x
   
   and gossipTy x = Method.new {
      name     = "topology/gossip",
      datatyp  = GOSSIP,
      ackInfo  = AckInfo.callback,
      duration = Duration.permanent,
      qos      = QOS.static (gossipPriority, gossipReliability),
      tailData = TailData.vector { maxLength = Config.maxGossip },
      sendStatistics    = SOME Stats.sentTopologyGossip,
      receiveStatistics = SOME Stats.receivedTopologyGossip
   } `int16l `word32l `word64l `real32l $ x
   
   and keepAliveTy x = Method.new {
      name     = "topology/keepAlive",
      datatyp  = KEEP_ALIVE,
      ackInfo  = AckInfo.callback,
      duration = Duration.permanent,
      qos      = QOS.static (topologyPriority, topologyReliability),
      tailData = TailData.none,
      sendStatistics    = SOME Stats.sentTopologyKeepAlive,
      receiveStatistics = SOME Stats.receivedTopologyKeepAlive
   } $ x
   
   and methodsTy x = aggregate (tMethods, fMethods)
      `bubblecastTy `gossipTy `keepAliveTy `findServerTy `Serial.word16l $ x

   (* This is usually unnecessary, but we tag most of these methods *)
   
   (*
   type bootstrap = bootstrap Entry.t
   *)
   type bootstrapOk = bootstrapOk Method.t
   type findServer = findServer Method.t
   type makeClient = makeClient Entry.t
   type yesServer = yesServer Method.t
   type upgrade = upgrade Method.t
   type upgradeOk = upgradeOk Method.t
   type makeSlave = makeSlave Entry.t
   type yesMaster = yesMaster Method.t
   type leaveClient = leaveClient Method.t
   type leaveSlave = leaveSlave Method.t
   type leaveMaster = leaveMaster Method.t
   type bubblecast = bubblecast Method.t
   type gossip = gossip Method.t
   type keepAlive = keepAlive Method.t
   type methods = { bubblecast : bubblecast, gossip : gossip, keepAlive : keepAlive, findServer : findServer, degree : Word16.word }
   
   type bootstrapIn = makeClient -> bootstrapOk -> unit
   type bootstrapOkIn = (bool -> unit) -> Int16.int -> Word32.word -> Word64.word -> Real32.real -> Word8Vector.vector -> unit
   type findServerIn = CUSP.Address.t -> makeClient -> Int16.int -> unit
   type makeClientIn = methods -> yesServer -> upgrade -> leaveClient -> (CUSP.OutStream.t -> unit) -> unit
   type yesServerIn = methods -> makeClient -> (CUSP.OutStream.t -> unit) -> unit
   type upgradeIn = makeSlave -> leaveSlave -> upgradeOk -> unit
   type upgradeOkIn = CUSP.Address.t -> makeSlave -> leaveMaster -> unit
   type makeSlaveIn = methods -> yesMaster -> leaveMaster -> (CUSP.OutStream.t -> unit) -> unit
   type yesMasterIn = methods -> makeSlave -> leaveSlave -> (CUSP.OutStream.t -> unit) -> unit
   type leaveClientIn = unit -> unit
   type leaveSlaveIn = unit -> unit
   type leaveMasterIn = CUSP.Address.t -> makeSlave -> unit
   type bubblecastIn  = (Priority.t * Reliability.t) -> Int32.int -> Word64.word -> Int32.int -> Int32.int -> Int32.int -> Int32.int -> Word8Vector.vector -> unit
   type gossipIn = (bool -> unit) -> Int16.int -> Word32.word -> Word64.word -> Real32.real -> Word8Vector.vector -> unit
   type keepAliveIn = (bool -> unit) -> unit
   type methodsIn = { bubblecast : bubblecastIn, gossip : gossipIn, keepAlive : keepAliveIn, findServer : findServerIn, degree : Word16.word }
   
   type bootstrapOut = Conversation.t -> makeClient -> bootstrapOkIn -> unit
   type bootstrapOkOut = Int16.int -> Word32.word -> Word64.word -> Real32.real -> Word8Vector.vector -> unit
   type findServerOut = CUSP.Address.t -> makeClient -> Int16.int -> unit
   type makeClientOut = Conversation.t -> methodsIn -> yesServerIn -> upgradeIn -> leaveClientIn -> CUSP.InStream.t -> unit
   type yesServerOut = methodsIn -> makeClient -> CUSP.InStream.t  -> unit
   type upgradeOut = makeSlave -> leaveSlaveIn -> upgradeOkIn -> unit
   type upgradeOkOut = CUSP.Address.t -> makeSlave -> leaveMasterIn -> unit
   type makeSlaveOut = Conversation.t -> methodsIn -> yesMasterIn -> leaveMasterIn -> CUSP.InStream.t  -> unit
   type yesMasterOut = methodsIn -> makeSlave -> leaveSlaveIn -> CUSP.InStream.t  -> unit
   type leaveClientOut = unit -> unit
   type leaveSlaveOut = unit -> unit
   type leaveMasterOut = CUSP.Address.t -> makeSlave -> unit
   type bubblecastOut  = Int32.int -> Word64.word -> Int32.int -> Int32.int -> Int32.int -> Int32.int -> Word8Vector.vector -> unit
   type gossipOut = Int16.int -> Word32.word -> Word64.word -> Real32.real -> Word8Vector.vector -> unit
   (*
   type keepAliveOut = unit
   type methodsOut = { bubblecast : bubblecastOut, gossip : gossipOut, keepAlive : keepAliveOut, findServer : findServerOut, degree : Word16.word }
   *)
   
   val badSlave = CUSP.Address.invalid
   val badMakeSlave : makeSlave = Entry.fromWellKnownService 0w0
end
