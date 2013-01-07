#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import datetime
import glob
import json
import logging
import os
import pdb
import shlex
import sys
import time

from ..base.Utils import *
from ..base.Config import Config
from ..base.Constants import *

from .Base import *
from .HostInteraction import *

log = logging.getLogger(__name__)

class Prototype(DB_Obj):
	'''
	a prototype
	'''
	
	FIELDS = ['id', 'experiment', 'command', 'x86_64', 'bin_path', 'libs_path', 'data_path', 'req_ram', 'req_disc']
	TABLE = 'prototypes'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		
		self.identName = 'Prototype "{0}" {1}'.format(self.getDB('command'), '64bit' if self.getDB('x86_64') else '32bit')
		
	
	def processFiles(self):
		self.dataFiles = []
		# bin
		values = dict.fromkeys(PrototypeData.FIELDS)
		values['path'] = self.getDB('bin_path')
		values['target_sub_dir'] = None
		values['recursive'] = False
		values['target_file_name'] = PATHS.THINCLIENT_PROTOTYPE_BUNDLE_BIN
		self.dataFiles.append(PrototypeData(values))
		# libs folder
		if self.getDB('libs_path') != None:
			values = dict.fromkeys(PrototypeData.FIELDS)
			values['path'] = os.path.join(self.getDB('libs_path'),'*')
			values['target_sub_dir'] = PATHS.THINCLIENT_PROTOTYPE_BUNDLE_LIBS
			values['recursive'] = True
			values['target_file_name'] = None
			self.dataFiles.append(PrototypeData(values))
		# data folder
		if self.getDB('data_path') != None:
			values = dict.fromkeys(PrototypeData.FIELDS)
			values['path'] = os.path.join(self.getDB('data_path'),'*')
			values['target_sub_dir'] = PATHS.THINCLIENT_PROTOTYPE_BUNDLE_DATA
			values['recursive'] = True
			values['target_file_name'] = None
			self.dataFiles.append(PrototypeData(values))

	def getDataFiles(self):
		return self.dataFiles
	
	def command(self):
		return self.getDB("command")
		
	def is64Bit(self):
		return self.getDB('x86_64')
		
	def getReqRam(self):
		return self.getDB('req_ram')
		
	def getReqDisc(self):
		return self.getDB('req_disc')
		

class NodegroupHostRelation(DB_Obj):
	'''
	a nodegroup - nodegroup relation
	'''
	
	FIELDS = ['id', 'experiment', 'groupA', 'groupB', 'relation']
	TABLE = 'node_host_placement'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
			
		if not NODEGROUP_HOST_RELATION.hasValue(self.getDB('relation')):
			log.error("unkown NodegroupHostRelation; (%)",self.getDB('relation'))
			
	def getGroupNames(self):
		return (self.getDB('groupA'),self.getDB('groupB'))
	
	def isBound(self):
		return self.getDB('relation') == NODEGROUP_HOST_RELATION.BOUND

	def isExclusion(self):
		return self.getDB('relation') == NODEGROUP_HOST_RELATION.EXCLUSION
	

class NodeEvent(DB_Obj):
	'''
	a nodeevent
	'''
	
	FIELDS = ['id', 'node', 'experiment', 'time', 'args', 'seed', 'signal']
	TABLE = 'node_events'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		
		if not NODE_EVENTS.hasValue(self.getDB("signal")):
			log.error("unkown node_event_signal; (%s)", self.getDB('signal'))

		self.identName = 'NodeEvent node:{0} time:{1} signal:{2}'.format(self.getDB('node'),self.getDB('time'),self.getDB('signal'))
		
		self.time = utcDateTime2timetime(parseSqlDateTime(self.getDB('time')))
		
		# parse args
		if self.getDB('args') == None:
			self.setArguments([])
		
		
	'''
	getter
	'''
	
	def getTime(self):
		return self.time
		
	def nodeID(self):
		return self.getDB('node')
	
	def seed(self):
		return self.getDB('seed')
		
	def isCrash(self):
		return self.getDB('signal') == NODE_EVENTS.CRASH
		
	def isStart(self):
		return self.getDB('signal') == NODE_EVENTS.START
		
	def isQuit(self):
		return self.getDB('signal') == NODE_EVENTS.QUIT
		
	def isUsrSig1(self):
		return self.getDB('signal') == NODE_EVENTS.USR_SIG_1
		
	def isUsrSig2(self):
		return self.getDB('signal') == NODE_EVENTS.USR_SIG_2
		
	def arguments(self):
		return {} if self.getDB('args')==None else json.loads(self.getDB('args'))

	'''
	setter
	'''
	
	def setSeed(self, seed):
		self.setDB('seed',seed)
	
	def setArguments(self, data):
		self.setDB('args', json.dumps(data))
		

class Node(DB_Obj):
	'''
	a node
	'''
	
	FIELDS = ['id', 'node_group', 'experiment', 'host', 'location', 'address']
	TABLE = 'nodes'

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		
		self.identName = 'Node:{0}; groupId:{1}'.format(self.dbID(),self.getDB('node_group'))

	def nodeGroup(self):
		return self.getDB('node_group')
	
	def hostID(self):
		return self.getDB('host')
	
	def setAddress(self, ip, port):
		self.setDB('address',ipPortToString((ip, port)))
	

class Experiment(DB_Obj):
	'''
	the experient
	'''

	FIELDS = ['id', 'name', 'log_interval', 'seed', 'size', 'start_date', 'runtime', 'last_run']
	TABLE = 'experiments'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])

		self.nodeGroup = []
		self.hostGroup = []
		self.workloads = []
		self.nodeData = []
		self.prototypes = []
		self.experimentData = []
		self.nodegroupHostRelations = []
		
		self.nodes = []
		self.nodeEvents = {}

		self.identName = 'Experiment "{0}"'.format(self.getDB('name'))
		
		self.parseDateTime()

		self.initialized = False

	def isInitialized(self):
		return self.initialized == True

	def setInitialized(self, value):
		self.initialized = value

	
	# check assigned database objects
	def checkObjects(self):
		if len(self.nodeGroup) == 0:
			raise ValueError("no nodegroups given")
		if len(self.hostGroup) == 0:
			raise ValueError("no hosts given")
		prototypeCmd = set()
		for prototype in self.prototypes:
			prototypeCmd.add(prototype.command())
		for nodeGroup in self.nodeGroup:
			if nodeGroup.prototypeCommand() not in prototypeCmd:
				raise ValueError("unkown prototype command: {0}".format(nodeGroup.prototypeCommand()))
		
		return True
		
	'''
	date/time properties	
	'''
	
	def name(self):
		return self.getDB('name')
	
	def parseDateTime(self):
		self.dateTimeStart = parseSqlDateTime(self.getDB('start_date'))
		self.dateTimeEnd = parseSqlDateTime(self.getDB('runtime'), self.dateTimeStart)
		
		if self.dateTimeEnd < self.dateTimeStart:
			time = self.dateTimeEnd.time()
			self.dateTimeEnd = self.dateTimeStart + datetime.timedelta(days=0, milliseconds=0,weeks=0,
													hours=time.hour,
													minutes=time.minute,
													seconds=time.second, 
													microseconds=time.microsecond)
		elif self.dateTimeEnd < self.dateTimeStart:
			log.error('experiment endDate is before startDate;')
			quit(1)
		
		self.timeStart = utcDateTime2timetime(self.dateTimeStart)
		self.timeEnd = utcDateTime2timetime(self.dateTimeEnd)
		
		self.timeDuration = self.timeEnd - self.timeStart
		
		if self.getDB('last_run') != None:
			self.dateTimeLastRun = utcDateTime2timetime(parseSqlDateTime(self.getDB('last_run')))
		else:
			self.dateTimeLastRun = None
	
	def getStart(self):
		return self.timeStart
	
	def getEnd(self):
		return self.timeEnd
	
	def getDuration(self):
		return self.timeDuration
		
	def getLastRun(self):
		return self.dateTimeLastRun


	'''
	adder methods
	'''
	def setLastRun(self, timeObject):
		self.setDB('last_run', str(timeObject))
		self.dateTimeLastRun = utcDateTime2timetime(timeObject)
	
	def addNodeGroup(self, nodeGroup):
		self.nodeGroup.append(nodeGroup)
		nodeGroup.setExperimentNodesSize(self.getDB('size'))

	def addHost(self, host):
		self.hostGroup.append(host)
		host.setExperimentID(self.getDB('id'))

	def addWorkload(self, workload):
		self.workloads.append(workload)
		
	def addPrototype(self, prototype):
		self.prototypes.append(prototype)
		
	def addNodegroupHostRelation(self, relation):
		self.nodegroupHostRelations.append(relation)

	def addNodeData(self, nodeData):
		self.nodeData.append(nodeData)

	def addExperimentData(self, experimentData):
		self.experimentData.append(experimentData)
		
	def addNode(self, node):
		self.nodes.append(node)
	
	def addNodeEventsForNodeGroup(self, nodeGroup, events):
		assert(nodeGroup not in self.nodeEvents)
		self.nodeEvents[nodeGroup] = events
	
	def setListOfRelevantNodeIDs(self, list):	
		self.listOfRelevantNodeIDs = set(list)

	'''
	getter methods
	'''

	def getHosts(self):
		return self.hostGroup

	def getNodeGroups(self):
		return self.nodeGroup

	def getWorkloads(self):
		return self.workloads
	
	def getPrototypes(self):
		return self.prototypes
	
	def getNodegroupHostRelations(self):
		return self.nodegroupHostRelations

	def getNodeData(self):
		return self.nodeData

	def getExperimentData(self):
		return self.experimentData
	
	def getAllNodes(self):
		return self.nodes
	
	def getNodeEventsForNodeGroup(self, nodeGroup):
		return self.nodeEvents[nodeGroup]
		
	def getListOfRelevantNodeIDs(self):
		return self.listOfRelevantNodeIDs

	def logInterval(self):
		log.warn("todo: add parse value")
		return float(self.getDB('log_interval'))
	'''
	calculations
	'''

	def effectiveTotalNodeSize(self):
		return sum(nodeGroup.effectiveTotalSize() for nodeGroup in self.nodeGroup)

	def getFixedNodesCount(self):
		return NodeGroup.sum_fixed_size


class Workload(DB_Obj):
	'''
	a workload entry
	'''
	
	FIELDS = ['name', 'event_name', 'type', 'time', 'percentage', 'optional_parameter', 'plot']
	TABLE = 'workload'

	TYPES = enum(ExponentialJoin='ExponentialJoin',LinearJoin='LinearJoin',LinearLeave='LinearLeave',
								SimultaneousJoin='SimultaneousJoin',SimultaneousLeave='SimultaneousLeave',
								SimultaneousCrash='SimultaneousCrash',SigUsr1='SigUsr1',SigUsr2='SigUsr2')

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])

		if not Workload.TYPES.hasValue(self.getDB("type")):
			log.error("unkown workload_type; (%)", self.getDB("type"))
			quit(1)
		
		self.identName = 'Workload {0} (eventName: {1})'.format(self.getDB("name"), self.getDB("event_name"))
		self.time = utcDateTime2timetime(parseSqlDateTime(self.getDB('time')))

	'''
	getter
	'''
	
	def dbID(self):
		raise NameError('Workloads have no IDs')
		
	def getType(self):
		return self.getDB('type')
		
	def getTime(self):
		return self.time

	def getPercentage(self):
		return float(self.getDB('percentage'))
	
	def getOptionalParameter(self):
		return float(self.getDB('optional_parameter'))

class NodeGroup(DB_Obj):
	'''
	a nodegroup
	'''

	LIFE_TYPES = enum(ALWAYS_ON='always on', EXPONENTIAL='exponential')
	TABLE = 'experiment_node_group'
	
	FIELDS = ['experiment', 'id', 'name', 'fixed_size', 'remainder_weight', 'connection', 'location', 
			'crash_ratio', 'lifetime_type', 'online_time', 'offline_time', 'workload', 'command']

	sum_fixed_size = 0
	sum_remainder_weight = 0

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		
		# check lifetime
		if not NodeGroup.LIFE_TYPES.hasValue(self.getDB('lifetime_type')):
			log.error("unkown lifetime_type; (%)", self.getDB('lifetime_type'))
			quit(1)
			
		
		# sum size
		NodeGroup.sum_fixed_size += self.getDB("fixed_size")
		NodeGroup.sum_remainder_weight += self.getDB("remainder_weight")
		
		# parse time
		if self.getDB("online_time") is None:
			self.online_time = None
		else:
			self.online_time = time2seconds(parseSqlDateTime(self.getDB("online_time")).time())
	
		if self.getDB("offline_time") is None:
			self.offline_time = None
		else:
			self.offline_time = time2seconds(parseSqlDateTime(self.getDB("offline_time")).time())


		# create name
		self.updateIdentName()
		
		# init values
		self.assignedNodes = 0
		
		# parse command
		self.commandSplitted = shlex.split(self.getDB("command"))
		if len(self.commandSplitted) < 1:
			log.error("invald command; (%)", self.getDB('command'))
			quit(1)
		self.commandPrototype = self.commandSplitted[0]
	
	def updateIdentName(self):
		self.identName = 'NodeGroup {0} (id {1})'.format(self.getDB("name"), self.getDB("id"))
	

	'''
	getter
	'''
	
	def command(self):
		return self.getDB('command')
		
	def prototypeCommand(self):
		return self.commandPrototype
		
	def splittedCommand(self):
		return self.commandSplitted

	def secondsOnline(self):
		return self.online_time

	def secondsOffline(self):
		return self.offline_time

	def isLifeTimeTypeAlwaysOn(self):
		return self.getDB("lifetime_type") == NodeGroup.LIFE_TYPES.ALWAYS_ON

	def isLifeTimeTypeExponential(self):
		return self.getDB("lifetime_type") == NodeGroup.LIFE_TYPES.EXPONENTIAL

	def crashRatio(self):
		return self.getDB('crash_ratio')
	
	def getAssignedNodes(self):
		return self.assignedNodes
		
	def getAlias(self):
		return self.getDB('name')
		
	def getExperimentNodesSize(self):
		return self.experimentNodesSize
	
	def getRelevantGroupSize(self):
		return self.relevantGroupSize

	'''
	modify assigned nodes
	'''

	def modifyAssignedNodes(self, amount, add=False):
		if add:
			self.assignedNodes += amount
		else:
			self.assignedNodes = amount
	
	def setExperimentNodesSize(self, size):
		self.experimentNodesSize = size
	
	def setRelevantGroupSize(self, size):
		self.relevantGroupSize = size

	'''
	calculations
	'''

	def onlineRatio(self):
		# TODO: use cache
		if self.isLifeTimeTypeAlwaysOn():
			return 1
		elif self.isLifeTimeTypeExponential():
			secOnline = self.secondsOnline()
			secOffline = self.secondsOffline()
			return float(secOnline) / float(secOnline + secOffline)
		else:
			raise NameError("unhandled lifetype_type; ({0})".format(self.getDB("lifetime_type")))

	def groupSize(self):
		# TODO: use cache
		if NodeGroup.sum_remainder_weight == 0:
			relativeSize = 0
		else:
			relativeSize = ((max(NodeGroup.sum_fixed_size, self.getExperimentNodesSize()) - NodeGroup.sum_fixed_size)
							* self.getDB("remainder_weight") / NodeGroup.sum_remainder_weight)
		return exactRound(self.getDB("fixed_size") + relativeSize,0)

	def effectiveTotalSize(self):
		# TODO: use cache
		return int(exactRound(self.groupSize() * (1.0 / self.onlineRatio()),0))

	def getPartOfNotAssignedEffectiveTotalSize(self, maxPortion=1.0):
		assert maxPortion <= 1.0 and maxPortion >= 0
		# return at least 1, but never more than not assigned
		return min(max(1,int(maxPortion*self.getNotAssignedEffectiveTotalSize())),self.getNotAssignedEffectiveTotalSize())

	def getNotAssignedEffectiveTotalSize(self):
		return self.effectiveTotalSize() - self.assignedNodes


class Host(DB_Obj):
	'''
	a host
	'''
	
	FIELDS = ['name', 'id', 'address', 'port', 'user_name', 'key_file', 'max_prototypes', 'working_dir', 'ssh_args', 'insp_time_zone', 'insp_time_delta',
				'public_interface', 'usable_ports_start', 'usable_ports_end', 'insp_free_disc', 'insp_free_ram', 'insp_cpu_64bit', 'insp_max_nodes', 'insp_ping']
	TABLE = 'hosts'
	TABLE_EXPERIMENTS = 'hosts_experiments_node_groups'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])

		self.identName = '{0} (id {1}, {2})'.format(self.getDB("name"), self.getDB("id"), self.getDB("address"))

		if self.getDB('max_prototypes') > Config.getInt("LIMITS","MAX_NODES_PER_HOST"):
			log.info('host exceeds MAX_NODES_PER_HOST; host:{0} original:{1} new:{2}'.format(
											self,self.getDB('max_prototypes'), Config.getInt("LIMITS","MAX_NODES_PER_HOST")))
			self.setDB('max_prototypes', Config.getInt("LIMITS","MAX_NODES_PER_HOST"))

		if self.getDB("ssh_args") != None:
			self.sshArgs = shlex.split(self.getDB("ssh_args"))
		else:
			self.sshArgs = []
		
		self.assignedNodeGroups = {}
		self.dataFiles = []
		self.prototypes = set()
		self.inspection = dict()
		
		self.localFolderCollectedData = os.path.join(PATHS.COLLECTED_DATA, PATHS.COLLECTED_EXPERIMENT_FOLDER,
			PATHS.COLLECTED_DATA_HOST.format(self.dbID()))

		self.thinClientState = TC_STATES.UNDEFINED
		self.thinClientIsRunning = False



	'''
	ThinClient state
	'''

	def setThinClientState(self, state):
		self.thinClientState = state
		
	def getThinClientState(self):
		return self.thinClientState

	def setThinClientIsRunning(self, isRunning):
		self.thinClientIsRunning = isRunning

	def getThinClientIsRunning(self):
		return self.thinClientIsRunning

	'''
	host inspection
	'''
	
	def setFreeDisc(self, amountInMB):
		self.inspection['freeDisc'] = int(amountInMB)
		return self.setDB('insp_free_disc', int(amountInMB))
		
	def setFreeRam(self, amountInMB):
		self.inspection['freeRam'] = int(amountInMB)
		return self.setDB('insp_free_ram', int(amountInMB))
		
	def setCheckedPorts(self, listOfPorts):
		portRange = self.getDefinedPortRange()
		self.inspection['checkedPorts'] = list(listOfPorts)
		for port in self.inspection['checkedPorts']:
			if port < portRange[0] or port > portRange[1]:
				raise ValueError("port out of range")
	
	def setCpuArch(self, isX86_64):
		self.inspection['cpuArch'] = bool(isX86_64)
		return self.setDB('insp_cpu_64bit', bool(isX86_64))
		
	def setMaxNodes(self, maxNodes):
		self.inspection['maxNodes'] = int(maxNodes)
		return self.setDB('insp_max_nodes', int(maxNodes))
		
	def setPing(self, minPing):
		self.inspection['ping'] = exactRound(minPing,2)
		return self.setDB('insp_ping', exactRound(minPing,2))

	def setTimeDelta(self, timeDelta):
		self.inspection['timeDelta'] = exactRound(timeDelta,3)
		return self.setDB('insp_time_delta', exactRound(timeDelta,3))

	def setTimezone(self, timeZone):
		self.inspection['timeZone'] = timeZone
		return self.setDB('insp_time_zone', int(timeZone))

	def setRankingPoints(self, points):
		self.inspection['rankingPoints'] = points

	def getRankingPoints(self):
		return self.inspection['rankingPoints']
		
	def getTimeZone(self):
		return self.getDB('insp_time_zone')
		
	def getTimeDelta(self):
		return self.getDB('insp_time_delta')	
		
	def getMaxNodes(self):
		return self.getDB('insp_max_nodes')
		
	def getFreeDisc(self):
		return self.getDB('insp_free_disc')
		
	def getFreeRam(self):
		return self.getDB('insp_free_ram')
		
	def getCheckedPorts(self):
		return self.inspection['checkedPorts'] 
		
	def is64Bit(self):
		return self.getDB('insp_cpu_64bit')
		
	def getPing(self):
		return self.getDB('insp_ping')

	'''
	modify assigned nodes, nodeGroup, dataFiles, experiment
	'''
	
	def setExperimentID(self, expID):
		self.experimentID = expID
	
	def assignNodeGroup(self, nodeGroup, nodesCount, add=False):
		if nodeGroup in self.assignedNodeGroups and add:
			self.assignedNodeGroups[nodeGroup] += nodesCount
		else:
			self.assignedNodeGroups[nodeGroup] = nodesCount
		self.checkAssignedNodes()
		return self.assignedNodeGroups[nodeGroup]
	
	def checkAssignedNodes(self):
		totalPlaces = self.getNodePlaces()
		for (nodeGroup, amount) in self.assignedNodeGroups.items():
			totalPlaces -= amount
		if totalPlaces < 0:
			log.error('more nodes assigned than places: %', str(self))
			quit(1)
			
	def addDataFile(self, dataFile):
		self.dataFiles.append(dataFile)
	
	def addPrototype(self, prototype):
		self.prototypes.add(prototype)
		


	'''
	getter
	'''
	
	def getDefinedPortRange(self):
		return (int(self.getDB("usable_ports_start")),int(self.getDB("usable_ports_end")))
	
	def getSSHArgs(self):
		return self.sshArgs
	
	def getDataFiles(self):
		return self.dataFiles
	
	def getPrototypes(self):
		return list(self.prototypes)

	def getAssignedNodes(self):
		return sum([cnt for cnt in self.assignedNodeGroups.values()])

	def getAssignedNodeGroups(self):
		return self.assignedNodeGroups
	
	def getNodePlaces(self):	
		return self.getDB("max_prototypes")
			
	def getPublicInterface(self):
		publicAddress = self.getDB("public_interface")
		if publicAddress == None:
			publicAddress = self.getDB("address")
		return publicAddress
	
	def getNodeAddressGenerator(self):
		addresses = [(self.getPublicInterface(), port) for port in self.inspection['checkedPorts']]
		return lambda: addresses.pop(0)
			
	def getExperimentID(self):
		return self.experimentID
		
	def getLocalFolderCollectedData(self):
		return self.localFolderCollectedData.format(self.getExperimentID())
		
