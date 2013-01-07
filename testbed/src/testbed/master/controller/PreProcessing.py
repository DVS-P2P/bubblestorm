#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import math

from ...base.Constants import *
from ...base.Utils import *
from ...base.Config import Config
from ...base.Database import DatabaseController
from ...base.DatabaseProcessing import DatabaseProcessing
from ... import models as Models

from ..NodeactivitySimulation import NodeactivitySimulation
from ..NodePlacement import NodePlacement

from .Monitoring import Monitoring

log = logging.getLogger(__name__)

class PreProcessing(object):

	def __init__(self):
		raise NotImplementedException()

	@staticmethod
	def processWorkload(state):
		'''
		process workload
		'''
		log.info("... processWorkload:")
	
		# parse time
		expStart = state.experiment.getStart()
		expEnd = state.experiment.getEnd()
		expDuration = state.experiment.getDuration()
	
		log.info("\tstart: {0}".format(expStart))
		log.info("\tend: {0}".format(expEnd))
		log.info("\tduration: {0}".format(expDuration))

		print("experiment duration: {0}".format(seconds2readableString(expDuration)))
	
		# parse workload, build (nodeGroup, workload) pairs
		nodeGroupWorkloads = [] # (nodeGroup, workload)
		for nodeGroup in state.experiment.getNodeGroups():
			workloads = [wl for wl in state.experiment.getWorkloads() 
									if wl.getDB('name') == nodeGroup.getDB('workload')]
			log.info("\t{0}:".format(nodeGroup))
			nodeGroupWorkloads.append((nodeGroup,workloads))
			if len(workloads) == 0:
				log.error('no workload found for nodeGroup: {0}, workload-name: {1}'.format(nodeGroup, 
																				nodeGroup.getDB("workload")))
				quit(1)
	
		# process workloadSimulation
		state.workloadSimulation = NodeactivitySimulation(nodeGroups=state.experiment.getNodeGroups(), 
												startTime=expStart, endTime=expEnd)
		
		#processString = '\r... process NodeactivitySimulation ({0} %)'
		i = 0
		for (nodeGroup, workloads) in nodeGroupWorkloads:
			#sys.stdout.write(processString.format(round(i/len(nodeGroupWorkloads)*100,2)))
			#sys.stdout.flush()
			state.workloadSimulation.processWorkloadsForGroup(listOfWorkloads=workloads, nodeGroup=nodeGroup)
			i += 1
		#sys.stdout.write(processString.format(round(i/len(nodeGroupWorkloads)*100,2))+"\n")
		#sys.stdout.flush()
		
		listOfRelevantNodeIDs = []
		
		# filter relevantEvents
		logString = ''
		#processString = '\r... process filter relevant events ({0} %)'
		i = 0
		allEvents = []
		for nodeGroup in state.experiment.getNodeGroups():
			#sys.stdout.write(processString.format(round(i/len(state.experiment.getNodeGroups())*100,2)))
			#sys.stdout.flush()
			i += 1
			eventsTuple = state.workloadSimulation.getRelevantEvents(nodeGroup) 
			events = []
			# list of tuple -> [(time, nodeId, nodeEventSignal), …]
			# create event obj
			for (time, nodeId, nodeEventSignal) in eventsTuple:
				listOfRelevantNodeIDs.append(nodeId)
				
				values = dict.fromkeys(Models.Experiment.NodeEvent.FIELDS)
				values['node'] = nodeId
				values['experiment'] = state.experiment.dbID()
				values['time'] = utcTimetime2datetime(time).isoformat()
				values['signal'] = nodeEventSignal
				events.append(Models.Experiment.NodeEvent(values))		
				allEvents.append((time, nodeEventSignal))
			
			eventsTuple.sort(key=lambda x: x[0])
			state.experiment.addNodeEventsForNodeGroup(nodeGroup, events)
			#logString = logString + ('\t\t{0} has {1} relevant event(s)\n'.format(nodeGroup, len(events)))
			#for e in eventsTuple:
			#	logString = logString + ('\t\t\ttime:{0} nodeId:{1} signal:{2}\n'.format(e[0],e[1],e[2]))
					
					
		#sys.stdout.write(processString.format(round(i/len(state.experiment.getNodeGroups())*100,2))+"\n")
		#sys.stdout.flush()
		
		listOfRelevantNodeIDs = set(listOfRelevantNodeIDs)
		state.experiment.setListOfRelevantNodeIDs(listOfRelevantNodeIDs)

		print('{0} nodes created'.format(len(listOfRelevantNodeIDs)))
	
		log.info('\t{0} nodes created'.format(len(listOfRelevantNodeIDs)))
		log.info(logString)
		
		'''
		t = expStart
		allEvents.sort(key=lambda x: x[0])
		v = 0
		nc = []
		while t < expEnd:
			t += 1
			while ((len(allEvents) > 0) and (allEvents[0][0] < t)):
				e = allEvents.pop(0)
				if e[1] == NODE_EVENTS.START:
					v += 1
				elif (e[1] == NODE_EVENTS.QUIT) or (e[1] == NODE_EVENTS.CRASH):
					v -= 1		
			nc.append((t,v))
		
		l = -1
		lt = 0
		for (t,v) in nc:
			if v != l:
				print("t: %s -- %d"%(utcTimetime2datetime(lt),l))
				print("t: %s -- %d"%(utcTimetime2datetime(t),v))
				l = v
				lt = t
			else:
				lt = t
		'''
		
	@staticmethod		
	def assignNodesToHosts(state, greedyHostSelection):
		'''
		assigns nodes to hosts
		'''
		log.info("... assignNodesToHosts:")
		relevantIDs = state.experiment.getListOfRelevantNodeIDs()
		nodeIDs = {}
		for nodeGroup in state.experiment.getNodeGroups():
			nodeIDs[nodeGroup] = relevantIDs & state.workloadSimulation.getNodeIds(nodeGroup)
			nodeGroup.setRelevantGroupSize(len(nodeIDs[nodeGroup]))
		
		# created nodes
		totalNodes = sum([len(ids) for ids in nodeIDs.values()])
		log.info('... assign nodes to hosts')
		log.info('\t{0} nodes created'.format(totalNodes))

		# calculate host rankings
		stats = {'freeDisc':{}, 'freeRam':{}, 'maxNodes':{}, 'ping':{}}
		for (k,v) in stats.items():
			v['max'] = float("-inf")
			v['min'] = float("inf")
			v['sum'] = 0

		# sum all hosts values
		hosts = list(state.experiment.getHosts())
		while len(hosts) > 0:
			h = hosts.pop()
			hInsp = dict(h.inspection)
			# remove host?
			if hInsp['freeDisc'] == 0 or hInsp['freeRam'] == 0 or hInsp['maxNodes'] == 0:
				state.removeHosts([h])
				continue
			for k in stats.keys():
				stats[k]['max'] = max(stats[k]['max'],hInsp[k])
				stats[k]['min'] = min(stats[k]['min'],hInsp[k])
				stats[k]['sum'] += hInsp[k]
		# avg
		for (k,v) in stats.items():
			v['avg'] = v['sum'] / len(state.experiment.getHosts())
		# calculate ranking
		for h in state.experiment.getHosts():
			hInsp = dict(h.inspection)
			ranking = 0
			# less is better -> avg/h
			# more is better -> h/avg
			ranking += 1.0 * (hInsp['freeDisc'] / stats['freeDisc']['avg'])
			ranking += 2.0 * (hInsp['freeRam'] / stats['freeRam']['avg'])
			ranking += 1.0 * (hInsp['maxNodes'] / stats['maxNodes']['avg'])
			ranking += 5.0 * (stats['ping']['avg'] / hInsp['ping'])

			# clock more 0.5 h wrong, high cohesion with ntp fail
			if math.fabs(hInsp['timeDelta']) > 1800:
				ranking *= 0.3

			h.setRankingPoints(ranking)
			log.debug("ranking: %d; ram: %d, disc: %d, maxNodes: %d, ping: %d, timeZone: %d"%(ranking, hInsp['freeRam'], hInsp['freeDisc'], hInsp['maxNodes'], hInsp['ping'], hInsp['timeZone']))
			
		# NodePlacement
		try:
			nodePlacement = NodePlacement(state.experiment.getHosts(), state.experiment.getNodeGroups(), state.experiment.getPrototypes(), state.experiment.getNodegroupHostRelations())
			
			nodePlacement.processGroupsWithRelations()
			
			if greedyHostSelection:
				nodePlacement.placementGreedy()
			else:
				nodePlacement.placementNonGreedy()
				
			nodePlacement.processBookings()
			
			del nodePlacement
		except ValueError as e:
			log.error("error during assignment")
			log.exception(e)
			quit(1)		
		
		sortedHostList = sorted(state.experiment.getHosts(), key=lambda host: host.getRankingPoints(), reverse=True)
		for h in sortedHostList:
			cnt = 0
			msg = []
			for (g,a) in h.getAssignedNodeGroups().items():
				msg.append('\t\t{0} from {1}'.format(a,g))
				cnt += a
			log.info('\t{0} ({1}): {2} nodes'.format(h,h.getRankingPoints(),cnt))
			for m in msg:
				log.info(m)

		# remove unused hosts
		state.removeHosts([host for host in state.experiment.getHosts() if host.getAssignedNodes() == 0])
					
		# create node objects
		for host in state.experiment.getHosts():
			for (nodeGroup,amount) in host.getAssignedNodeGroups().items():
				for i in range(amount):
					nodeID = nodeIDs[nodeGroup].pop()
					
					values = dict.fromkeys(Models.Experiment.Node.FIELDS)
					values['id'] = nodeID
					values['node_group'] = nodeGroup.dbID()
					values['experiment'] = state.experiment.dbID()
					values['host'] = host.dbID()
					node = Models.Experiment.Node(values)
					state.experiment.addNode(node)
		
		# check: all nodes assigned
		for (group, ids) in nodeIDs.items():
			if len(ids) > 0:
				log.error("{0} nodes of {1} not assigned".format(len(ids), group))
				quit(1)

		
	@staticmethod	
	def processNodeEventParameter(state):
		'''
		process event parameter: alias & variable assignment
		'''
		log.info("... processNodeEventParameter:")
		
		
		hostIPs = {}
		addressGenerator = {}
		for host in state.experiment.getHosts():
			addressGenerator[host.dbID()] = host.getNodeAddressGenerator()
			hostIPs[host.dbID()] = host.getPublicInterface()
		allNodes = {}
		for node in state.experiment.getAllNodes():
			allNodes[node.dbID()] = node
		
		aliasMap = {} # map of {alias: {nodeID: (ip,port), nodeID: (ip,port)}, alias2: ...}
		
		# assign address for aliased groups, one ip:port per node
		for nodeGroup in state.experiment.getNodeGroups():
			if nodeGroup.getAlias() not in aliasMap:
				aliasMap[nodeGroup.getAlias()] = {}
			events = state.experiment.getNodeEventsForNodeGroup(nodeGroup)
			for event in events:
				if event.isStart():
					node = allNodes[event.nodeID()]
					if node.dbID() not in aliasMap[nodeGroup.getAlias()]:
						(ip,port) = addressGenerator[node.hostID()]()
						aliasMap[nodeGroup.getAlias()][node.dbID()] = (ip, port)
		
		# all nodes
		for nodeGroup in state.experiment.getNodeGroups():
			events = state.experiment.getNodeEventsForNodeGroup(nodeGroup)
			for event in events:
				if event.isStart():
					node = allNodes[event.nodeID()]
					# get assigned ip,port
					ipPort = aliasMap[nodeGroup.getAlias()][node.dbID()]
					node.setAddress(ipPort[0], ipPort[1])
					# generate seed
					seed = Random.randomInt(0,Config.getInt("LIMITS","MAX_SEED_INT"))
					event.setSeed(seed)
					# parse command
					try:
						commandParts = parseCommand(command=nodeGroup.command(), aliasMap=aliasMap, seed=seed, 
							db=PATHS.NODE_DATABASE, logInterval=state.experiment.logInterval(), ipPort=ipPort)
					except ValueError as e:
						log.error('malformed command: {0}'.format(nodeGroup.command()))
						log.exception(e)
						quit(1)
					except BaseException as e:	
						log.error('unkown exception during command parsing; command:{0}'.format(
							nodeGroup.command()))
						quit(1)
					event.setArguments(commandParts)
	
	@staticmethod
	def processExperimentAndPrototypeData(state):
		'''
		process exp and prototype data: determine necessary files for each host
		'''
		log.info("... processExperimentAndPrototypeData:")
		# add experiment data, all hosts
		for dataFile in state.experiment.getExperimentData():
			for host in state.experiment.getHosts():
				host.addDataFile(dataFile)
		
		# add node data, check necessary files for each host
		for host in state.experiment.getHosts():
			for nodeGroup in host.getAssignedNodeGroups():
				for dataFile in state.experiment.getNodeData():
					if dataFile.matchNodeGroup(nodeGroup):
						host.addDataFile(dataFile)
		
		# process prototypes
		prototypes32 = dict()
		prototypes64 = dict()
		for prototype in state.experiment.getPrototypes():
			if prototype.is64Bit():
				prototypes64[prototype.command()] = prototype
			else:
				prototypes32[prototype.command()] = prototype
	
		
		# add prototype data
		for host in state.experiment.getHosts():
			if host.is64Bit():
				prototypes = prototypes64
			else:
				prototypes = prototypes32
			prototypeCmds = []
			for nodeGroup in host.getAssignedNodeGroups():
				prototypeCmds.append(nodeGroup.prototypeCommand())
			for prototypeCmd in prototypeCmds:	
				host.addPrototype(prototypes[prototypeCmd])
			
		
		text = 'Process all files/folders:\n'
	
		text = text + ('\tNodedata bundle:\n')
		for dataFile in state.experiment.getNodeData():
			# access filesize or in case of exception print filename
			try:
				text = text + ('\t\t{0} (recursive:{1})'.format(dataFile.path(),dataFile.isRecursive()))
				text = text + (' ({0})\n'.format(sizeof_fmt(os.path.getsize(dataFile.path()))))
			except OSError as e:
				text = text + '\n'
	
		text = text + ('\tExperiment data:\n')
		for dataFile in state.experiment.getExperimentData():
			# access filesize or in case of exception print filename
			try:
				text = text + ('\t\t{0} (recursive:{1})'.format(dataFile.path(),dataFile.isRecursive()))
				text = text + (' ({0})\n'.format(sizeof_fmt(os.path.getsize(dataFile.path()))))
			except OSError as e:
				text = text + '\n'
		log.info(text)
	
	
	@staticmethod
	def storeNodesAndEvents(state):
		'''
		store nodes & events into db
		'''
		log.info("... storeNodesAndEvents:")
	
		# nodes
		nodes = state.experiment.getAllNodes()
		for node in nodes:
			state.dbController.storeNode(node)
		log.info('\t{0} nodes created'.format(len(nodes)))
		
		# node events
		for nodeGroup in state.experiment.getNodeGroups():
			events = state.experiment.getNodeEventsForNodeGroup(nodeGroup)
			log.info('\t{0} node event(s) created for {1}'.format(len(events), nodeGroup))
			for event in events:
				state.dbController.storeNodeEvent(event)
		
		state.dbController.commitChanges()

	@staticmethod
	def prepareHostsWorkingDir(state):
		log.info("... prepareHostsWorkingDir")
		hosts = state.experiment.getHosts()
		result = state.processJobs(hosts, 'runPrepareWorkingDir', 'prepare working dir')
		return result
	
	@staticmethod
	def prepareNodeDB(state):		
		log.info("... prepareNodeDB")
		nodeDB = DatabaseController(PATHS.NODE_DATABASE)
		DatabaseProcessing.transerAllObject(state.dbController, nodeDB, Models.NodeDatabase.LogFilter, {'experiment': state.experiment.name()})
		nodeDB.commitChanges()
		nodeDB.close()
		del nodeDB
	
	@staticmethod
	def copyExperimentAndPrototype(state, hosts=None):
		'''
		copy all exp files
		'''
		log.info("... copyExperimentAndPrototype:")
		if hosts == None:
			hosts = set(state.experiment.getHosts())
		result = state.processJobs(hosts, 'runCopyExperiment', 'copy experiment/prototype data')
		return result

	@staticmethod
	def prepareStartExperiment(state, minDelay=0):
		# start thinClients
		log.info("... prepareStartExperiment:")
		timeStart = time.time()
		PreProcessing.startThinClients(state)
		workingTime = [time.time() - timeStart]
	
		# check thinClients startUp
		timeStart = time.time()
		#PreProcessing.checkThinClientIsRunning(state)
		workingTime.append(time.time() - timeStart)
	
		# wait for all hosts
		PreProcessing.checkThinClientIsReady(state)
		
		maxWorkingTime = max(workingTime)
		minDelay = max(minDelay, (int(maxWorkingTime * 2) + 10))
		minDelay = Config.getInt("LIMITS","START_EXPERIMENT_LEADTIME_SECONDS") + minDelay
		PreProcessing.startExperiment(state, minDelay)

	@staticmethod
	def checkThinClientIsReady(state):
		log.info("... checkThinClientIsReady:")
		hosts = list(state.experiment.getHosts())
		while len(hosts) > 0:
			result = Monitoring.determineThinClientState(state, hosts)

			# filter ready hosts
			remainingHosts = [h for h in hosts if h.getThinClientState() != TC_STATES.WAIT_FOR_STARTSIGNAL] 
			readyHosts =  [h for h in hosts if h.getThinClientState() == TC_STATES.WAIT_FOR_STARTSIGNAL] 
			# determine preparing hosts
			preparingHosts = [h for h in remainingHosts if h.getThinClientState() == TC_STATES.PREPARE_START]
			hosts = remainingHosts	

			print("%d hosts ready, %d hosts preparing, %d hosts failed"%(
				len(readyHosts),len(preparingHosts),len(remainingHosts)-len(preparingHosts)))

			if len(preparingHosts) != len(remainingHosts):
				failedHosts = [h for h in remainingHosts if h.getThinClientState() != TC_STATES.PREPARE_START]
				log.debug("some errors occur")
				askUser = True
				while askUser:
					input = askUserOption('(w)ait, (ignore) failed, show (e)rror, re(start) client, re(copy) data and start client',
						['w','e','start','copy','ignore'], 'w', 'w')
					if input == 'e':
						for h in failedHosts:
							log.debug(TC_STATES.getKey(h.getThinClientState()))
							msg = TC_STATES.getKey(h.getThinClientState())
							try:
								indx = result['failedHosts'].index(h)
								msg += " error: {0}".format(result['logs'][indx].strip())
							except:
								pass
							print("host: {0}; {1}".format(h,msg))
					elif input == 'start':
						askUser = False
						PreProcessing.startThinClients(state,failedHosts)
					elif input == 'copy':
						askUser = False
						copied = PreProcessing.copyExperimentAndPrototype(state,failedHosts)
						PreProcessing.startThinClients(state,copied['okHosts'])
					elif input == 'ignore':
						askUser = False
						hosts = preparingHosts
					else:
						askUser = False 
						hosts = remainingHosts

			if len(hosts) > 0:	
				waitUntil = time.time() + 30
				progressWriter(lambda: time.time()<waitUntil, newLine=True, timer=False, lowFrequentCheck=False,
					statusCallable=lambda: '{0} seconds until next check '.format(str(round(waitUntil-time.time()))))


	@staticmethod
	def startExperiment(state, minDelay=0):	
		# determine expStartTime
		log.info("... startExperiment:")
		delay = minDelay
		while True:
			try:
				userIn = waitForUserInput(msg='enter starttime ("now" or utc "YYYY-MM-DD HH:MM:SS")',default='now')
				if len(userIn) == 0 or userIn == "now":
					break
				parsed = parseSqlDateTime(userIn)
				print("parsed starttime: {0}".format(parsed))
				seconds = utcDateTime2timetime(parsed)
				startTime = seconds - NTP.utcTime()
				delay = max(startTime, minDelay)
				print("... start experiment in +{0} seconds".format(delay))	
				break
			except ValueError as e:
				log.exception(e)
				log.debug(userIn)
				print("cant parse input")
		
		# sync time
		print("... ntp sync")
		try:
			NTP.sync()
		except BaseException:
			pass
			
		startTime = NTP.utc() + datetime.timedelta(seconds=delay)
		
		print(startTime)

		state.experiment.setLastRun(startTime)
		state.dbController.updateExperiment(state.experiment, identKeys=['id'], updateKeys=state.experiment.FIELDS)
		state.dbController.commitChanges()
		
		# start thin clients
		PreProcessing.startExperimentOnEachThinClient(state, dateTimeString(startTime)) 
		
		expDuration = state.experiment.getDuration()
		expectedTimeEnd = startTime + seconds2timedelta(expDuration)
		msgDict = {'start (UTC)':dateTimeString(startTime), 
				'end (UTC)':dateTimeString(expectedTimeEnd)}
		log.info(highlightedText(msgDict))
		
			
	@staticmethod
	def startExperimentOnEachThinClient(state, expStartTime):
		'''
		set experiment starttime
		invokes thin client
		'''
		log.info("... startExperimentOnEachThinClient:")
		hosts = state.experiment.getHosts()
		optional = {'expStartTime': expStartTime}
		result = state.processJobs(hosts, 'runStartExperiment', 'start experiment', optional)
		return result
	
	@staticmethod
	def startThinClients(state, hosts=None):
		'''
		start thin clients
		'''
		log.info("... startThinClients:")
		if hosts == None:
			hosts = set(state.experiment.getHosts())
		result = state.processJobs(hosts, 'runStartThinClient', 'start thinClient')
		return result

