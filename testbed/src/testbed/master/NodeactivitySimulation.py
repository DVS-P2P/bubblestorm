#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import datetime
import logging
import sys

from ..models.Experiment import Workload
from ..base.Constants import *
from ..base.Utils import *

log = logging.getLogger(__name__)

LIFE_DISTRIBUTION_STATE = enum('online', 'offline')
WORKLOAD_ONLINE_STATE = enum('active', 'inactive')

NodeEvent = namedtuple('NodeEvent', ['time', 'state', 'isCrash'])

class Node(object):
	
	# node id stuff
	lastNodeId = -1
	@classmethod
	def nextId(self):
		self.lastNodeId += 1
		return self.lastNodeId
	
	def __init__(self, nodeGroup, startTime, endTime):
		self.id = self.nextId()
		self.freezedState = False
		self.nodeGroup = nodeGroup
		self.startTime = startTime
		self.endTime = endTime
		self.stateWorkload = []
		self.stateLifetime = []
		self.receivedSignals = []
		
	'''
	lifetime calculations
	'''
	def hasSessionDuration(self):
		if self.nodeGroup.isLifeTimeTypeExponential():
			return True
		if self.nodeGroup.isLifeTimeTypeAlwaysOn():
			return False
		log.error('unsupported session duration')
	
	def sessionDuration(self):
		if self.nodeGroup.isLifeTimeTypeExponential():
			return max(1, self.nodeGroup.secondsOnline() * Random.expovariate(1))
		if self.nodeGroup.isLifeTimeTypeAlwaysOn():
			return None
		log.error('unsupported session duration')
		
	def intersessionDuration(self):
		if self.nodeGroup.isLifeTimeTypeExponential():
			return max(1, self.nodeGroup.secondsOffline() * Random.expovariate(1))
		if self.nodeGroup.isLifeTimeTypeAlwaysOn():
			return None
		log.error('unsupported session duration')
	
	def initialLifeTimeState(self):
		assert(len(self.stateLifetime)==0)
		if self.nodeGroup.isLifeTimeTypeExponential():
			random = Random.expovariate(1)
			ratio = self.nodeGroup.onlineRatio()
			if random < ratio:
				return self.goOnline(self.startTime)
			else:
				return self.goOffline(self.startTime)
		elif self.nodeGroup.isLifeTimeTypeAlwaysOn():
			return self.goOnline(self.startTime)
		else:
			log.error("unsupported session duration")
			
	'''
	getter
	'''
	
	def getID(self):
		return self.id
	
	def isActive(self):
		return (len(self.stateWorkload) > 0) and (self.stateWorkload[-1].state == WORKLOAD_ONLINE_STATE.active)
		
	def isOnline(self):
		return (len(self.stateLifetime) > 0) and (self.stateLifetime[-1].state == LIFE_DISTRIBUTION_STATE.online)
		
	''' 
	change state
	'''
	
	def receiveSignal(self, time, signal):
		self.receivedSignals.append(NodeEvent(time, signal, None))
	
	def goActive(self, time):
		assert not(self.freezedState)
		assert not(self.isActive())
		self.stateWorkload.append(NodeEvent(time, WORKLOAD_ONLINE_STATE.active, None))
	
	def goInactive(self, time, isCrash=False):
		assert not(self.freezedState)
		assert ((len(self.stateWorkload) == 0) or self.isActive())
		random = Random.expovariate(1)
		ratio = self.nodeGroup.crashRatio()
		if random < ratio:
			isCrash = True
		self.stateWorkload.append(NodeEvent(time, WORKLOAD_ONLINE_STATE.inactive, isCrash))
	
	def goOnline(self, time):
		assert not(self.freezedState)
		assert not(self.isOnline())
		duration = self.sessionDuration()
		self.stateLifetime.append(NodeEvent(time, LIFE_DISTRIBUTION_STATE.online, None))
		return duration
		
	def goOffline(self, time):
		assert not(self.freezedState)
		assert ((len(self.stateLifetime) == 0) or self.isOnline())
		duration = self.intersessionDuration()
		self.stateLifetime.append(NodeEvent(time, LIFE_DISTRIBUTION_STATE.offline, False))
		return duration
	
	
	'''
	determine relevant events
	'''
		
	def getRelevantEvents(self):
		self.stateLifetime = []
		if self.freezedState:
			log.error("node already collected")
		self.freezedState = False
		result = [] # (time, nodeID, NODE_EVENTS)
		self.stateLifetime = []
		
		log.debug("id: %d"%self.getID())
		log.debug(self.stateWorkload)
		
		if len(self.stateWorkload) == 0:
			self.freezedState = True
			return result
		
		timeCurrent = self.startTime
		if self.hasSessionDuration():
			timeLifeDistri = timeCurrent + self.initialLifeTimeState() # current + first (inter)sessionDuration
		else:
			self.initialLifeTimeState()
			timeLifeDistri = self.endTime
			
		while timeLifeDistri < self.endTime:
			if self.isOnline():
				timeLifeDistri += self.goOffline(timeLifeDistri)
			else:
				timeLifeDistri += self.goOnline(timeLifeDistri)
				
		workLoadEvents = list(self.stateWorkload)
		lifetimeEvents = list(self.stateLifetime)
		activity = 0 if self.stateLifetime[0].state == LIFE_DISTRIBUTION_STATE.online else 1
		activityEvents = []
		lastTime = self.startTime
		while (len(workLoadEvents) > 0) or (len(lifetimeEvents) > 0):
			if (len(workLoadEvents) == 0) or (len(lifetimeEvents) > 0 and (lifetimeEvents[0].time < workLoadEvents[0].time)):
				current = lifetimeEvents.pop(0)
				if current.state == LIFE_DISTRIBUTION_STATE.online:
					activity += 1
				else:
					activity -= 1
			else:
				current = workLoadEvents.pop(0)
				if current.state == WORKLOAD_ONLINE_STATE.active:
					activity += 1
				else:
					activity -= 1
			lastTime = current.time
			if len(activityEvents) > 0 and activityEvents[-1][0] == lastTime:
				activityEvents.pop()	
			activityEvents.append((lastTime, activity, current.isCrash))
				
		isOn = False
		while len(activityEvents) > 0:
			current = activityEvents.pop(0)
			if current[0] > self.endTime:
				continue
			assert(current[1] >= 0 and current[1] <= 2)
			if current[1] == 2:
				isOn = True
				result.append((current[0], self.getID(), NODE_EVENTS.START))
			if isOn and not(current[1] == 2):
				isOn = False
				crash = current[2]
				if crash:
					result.append((current[0], self.getID(), NODE_EVENTS.CRASH))
				else:
					result.append((current[0], self.getID(), NODE_EVENTS.QUIT))
				
		
		log.debug("%d:"%self.getID())
		log.debug("\t"+repr(self.stateWorkload))
		log.debug("\t"+repr(self.stateLifetime))
		log.debug("\t"+repr(result))		
		
		self.freezedState = True
		return result
		

class NodeactivitySimulation(object):
	'''
	process lifetime&workload information, creates nodeevenets
	'''

	def __init__(self, nodeGroups, startTime, endTime):
		self.nodeGroups = nodeGroups
		self.startTime = startTime
		self.endTime = endTime
		
		self.prepareNodes()
		
	def prepareNodes(self):
		self.status = {}
		for ng in self.nodeGroups:
			self.status[ng] = {'active':[], 'inactive':[], 'total': ng.effectiveTotalSize()}
			for i in range(ng.effectiveTotalSize()):
				node = Node(nodeGroup=ng, startTime=self.startTime, endTime=self.endTime)
				self.status[ng]['inactive'].append(node)
		
	def getRelevantEvents(self, nodeGroup):
		out = [] # (time, nodeId, nodeEventSignal)
		for node in self.status[nodeGroup]['active']:
			out.extend(node.getRelevantEvents())
		for node in self.status[nodeGroup]['inactive']:
			out.extend(node.getRelevantEvents())
		return out
		
	def getNodeIds(self, nodeGroup):
		out = []
		for node in self.status[nodeGroup]['active']:
			out.append(node.getID())
		for node in self.status[nodeGroup]['inactive']:
			out.append(node.getID())
		return set(out)
	
	def processWorkloadsForGroup(self, listOfWorkloads, nodeGroup):
		log.debug("process workload, group %s, %d workloads"%(str(nodeGroup), len(listOfWorkloads)))
		groupState = self.status[nodeGroup]
		workloadActions = {}
		# create workloadActions
		for workload in listOfWorkloads:	
			workloadType = workload.getType()
			workloadTime = workload.getTime()
			if workloadType == WORKLOAD_EVENTS.SIG_USR_1:
				action = WorkloadActionSendSignal(nodeGroup, startTime=workloadTime, signal=NODE_EVENTS.USR_SIG_1)
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.SIG_USR_2:
				action = WorkloadActionSendSignal(nodeGroup, startTime=workloadTime, signal=NODE_EVENTS.USR_SIG_2)
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.SIMULTANEOUS_JOIN:
				action = WorkloadActionSimultaneous(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), newState=WORKLOAD_ONLINE_STATE.active)
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.SIMULTANEOUS_LEAVE:
				action = WorkloadActionSimultaneous(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), newState=WORKLOAD_ONLINE_STATE.inactive)
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.SIMULTANEOUS_CRASH:
				action = WorkloadActionSimultaneous(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), newState=WORKLOAD_ONLINE_STATE.inactive, isCrash=True)
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.LINEAR_LEAVE:
				action = WorkloadActionLinear(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), isCrash=False,
					newState=WORKLOAD_ONLINE_STATE.inactive, optionalParameter=workload.getOptionalParameter())
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.LINEAR_JOIN:
				action = WorkloadActionLinear(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), isCrash=False,
					newState=WORKLOAD_ONLINE_STATE.active, optionalParameter=workload.getOptionalParameter())
				workloadActions[action] = workloadTime
			elif workloadType == WORKLOAD_EVENTS.EXPONENTIAL_JOIN:
				action = WorkloadActionExponential(nodeGroup, startTime=workloadTime, 
					percentage=workload.getPercentage(), optionalParameter=workload.getOptionalParameter())
				workloadActions[action] = workloadTime
			else:
				log.error("unimplemented workload event %s",workload)
							
		# process actions	
		currentTime = self.startTime
		while currentTime < self.endTime:
			selectedAction = None
			selectedTime = self.endTime
			# select next event
			for (action, time) in workloadActions.items():
				if time < selectedTime:
					selectedTime = time
					selectedAction = action
			currentTime = selectedTime
			# action found?
			if selectedAction != None:
				o1,o2 = len(groupState['active']), len(groupState['inactive'])
				workloadActions[selectedAction] = selectedAction.process(currentTime, groupState)
				
				log.debug("select action %s group: %s, before: %d/%d after: %d/%d nextTime: %s"%(selectedAction,selectedAction.nodeGroup,
					o1,o2,len(groupState['active']), len(groupState['inactive']), str(workloadActions[selectedAction])))

				if workloadActions[selectedAction] == None:
					del(workloadActions[selectedAction])
				
		


class WorkloadAction(object):
	
	def __init__(self, nodeGroup, startTime):
		self.nodeGroup = nodeGroup
		self.startTime = startTime

	def process(self, currentTime, groupState):
		log.error("unimplemented method")
		assert(False)
		
	def swapRandomNode(self, sourceNodes, targetNodes):
		'''
		swap a random node from source to target
		returns node
		'''
		node = Random.choice(sourceNodes)
		sourceNodes.remove(node)
		targetNodes.append(node)
		return node


class WorkloadActionSendSignal(WorkloadAction):
	
	def __init__(self, nodeGroup, startTime, signal):
		super(WorkloadActionSendSignal, self).__init__(nodeGroup, startTime)
		self.signal = signal
		
		log.info('Send Signal: %s'%self.signal)
		
	def process(self, currentTime, groupState):
		# send signal to all nodes!
		# only active nodes will receive this signal
		for node in groupState['active']:
			node.receiveSignal(currentTime, self.signal)
		for node in groupState['inactive']:
			node.receiveSignal(currentTime, self.signal)
		return None
	
class WorkloadActionSimultaneous(WorkloadAction):
	
	def __repr__(self):
		return "Simultaneous %d, %f, %s"%(self.startTime, self.percentage, self.newState)
	
	def __init__(self, nodeGroup, startTime, percentage, newState, isCrash=False):
		super(WorkloadActionSimultaneous, self).__init__(nodeGroup, startTime)
		self.newState = newState
		self.isCrash = isCrash
		self.percentage = percentage
		
		self.target = int(round(self.nodeGroup.effectiveTotalSize() * self.percentage))
		
		if self.newState == WORKLOAD_ONLINE_STATE.active:
			log.info('Simultaneous join: %d'%self.target)
		elif self.newState == WORKLOAD_ONLINE_STATE.inactive:
			log.info('Simultaneous leave/crash: %d'%self.target)
		
	def process(self, currentTime, groupState):
		if self.newState == WORKLOAD_ONLINE_STATE.active:
			if self.target > len(groupState['inactive']):
				log.error("Cannot remove nodes by executing linear join")
			while self.target > 0 and len(groupState['inactive']) > 0:
				node = self.swapRandomNode(groupState['inactive'],groupState['active'])
				node.goActive(currentTime)
				self.target -= 1
		elif self.newState == WORKLOAD_ONLINE_STATE.inactive:
			if self.target > len(groupState['active']):
				log.error("Cannot add nodes by executing linear leave/crash")
			while self.target > 0 and len(groupState['active']) > 0:
				node = self.swapRandomNode(groupState['active'],groupState['inactive'])
				node.goInactive(currentTime, self.isCrash)
				self.target -= 1
		else:
			log.error("unkown state: %"%(self.newState))
		return None
		
	
	
class WorkloadActionLinear(WorkloadAction):
	
	def __repr__(self):
		return "Linear %d, %d, %s, %f"%(self.startTime, self.target, self.newState, self.optionalParameter)

	def __init__(self, nodeGroup, startTime, percentage, optionalParameter, newState, isCrash=False):
		super(WorkloadActionLinear, self).__init__(nodeGroup, startTime)
		self.newState = newState
		self.isCrash = isCrash
		self.optionalParameter = optionalParameter
		self.percentage = percentage
		
		self.delay = nodeGroup.onlineRatio() * optionalParameter
		
		self.target = int(round(self.nodeGroup.effectiveTotalSize() * self.percentage))
		
		if self.newState == WORKLOAD_ONLINE_STATE.active:
			log.info('Linear join: %d'%self.target)
		elif self.newState == WORKLOAD_ONLINE_STATE.inactive:
			log.info('Linear leave/crash: %d'%self.target)
		
		
	def process(self, currentTime, groupState):		
		if self.newState == WORKLOAD_ONLINE_STATE.active:
			if len(groupState['inactive']) == 0:
				log.error("Cannot remove nodes by executing linear join")
			elif self.target > 0:
				self.target -= 1
				node = self.swapRandomNode(groupState['inactive'],groupState['active'])
				node.goActive(currentTime)
				if self.target > 0:
					return currentTime + self.delay
		elif self.newState == WORKLOAD_ONLINE_STATE.inactive:
			if len(groupState['active']) == 0:
				log.error("Cannot add nodes by executing linear leave/crash")
			elif self.target > 0:
				self.target -= 1
				node = self.swapRandomNode(groupState['active'],groupState['inactive'])
				node.goInactive(currentTime, self.isCrash)
				if self.target > 0:
					return currentTime + self.delay
		else:
			log.error("unkown state: %"%(self.newState))
		return None	
	
class WorkloadActionExponential(WorkloadAction):
	
	def __repr__(self):
		return "Exponential %d, %f, %f, %d"%(self.startTime, self.percentage, self.optionalParameter, self.target)

	def __init__(self, nodeGroup, startTime, percentage, optionalParameter):
		super(WorkloadActionExponential, self).__init__(nodeGroup, startTime)
		self.optionalParameter = optionalParameter
		self.percentage = percentage
		
		self.rate = self.optionalParameter / self.nodeGroup.onlineRatio()
		self.target = int(round(self.nodeGroup.effectiveTotalSize() * self.percentage))
		
		log.info('Exponential join: %d'%self.target)
		
	def process(self, currentTime, groupState):
		currentSize = len(groupState['active'])
		if self.target > 0:
			if len(groupState['inactive']) == 0:
				log.error("Cannot remove nodes by executing exponential join")
			else:
				self.target -= 1
				
				delay = float(1 + currentSize) * self.rate
				when = float(1/delay)
				
				node = self.swapRandomNode(groupState['inactive'],groupState['active'])
				node.goActive(currentTime)
				if self.target > 0:
					return currentTime + when
		return None