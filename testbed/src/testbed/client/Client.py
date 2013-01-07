#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import copy
import datetime
import gc
import glob
import logging
import os
import resource
import shlex
import shutil
import signal
import stat
import threading
import time
from pipes import quote

from ..base.Constants import *
from ..base.Database import DatabaseController
from ..base.DatabaseProcessing import DatabaseProcessing
from ..base.Utils import *
from ..base.Config import Config
from ..base.SubProc import NodeProc
from .. import models as Models
from .NodeController import NodeController

log = logging.getLogger(__name__)

class TestbedClientController(object):
	'''
	manages a host	
		- controls program flow, called by main
		- runs on hosts
	'''

	def __init__(self, verbose, experiment, host, debug, autostart):
		self.properties = type(
			"properties",
			(object,),
			{
				"verbose": verbose, 
				"experiment": experiment,
				"autostart": autostart == True, 
				"host": host,
				"debug": debug == True
			})


		Config.load(PATHS.CONFIG_FILE)
														
		# wich state?
		stateFromFile = self.readStateFromFile()
		# all done?
		if stateFromFile == TC_STATES.NORMAL_SHUTDOWN:
			log.info("nothing todo")
			return
		# unkown? 
		if stateFromFile == TC_STATES.UNDEFINED:
			log.info("unkown state -> newState = prepare start")
			self.setState(TC_STATES.PREPARE_START)
		# error recovery?
		if stateFromFile > TC_STATES.NORMAL_SHUTDOWN:
			log.debug("resume from error")
			if stateFromFile == TC_STATES.ERR_PROCESS_DBS:
				print("resume from ERR_PROCESS_DBS")
				print("reset db, set state PROCESS_DBS")
				try:
					db = DatabaseController(PATHS.THINCLIENT_DB_FILE)
					exp = db.getExperiment(expId=self.properties.experiment)
					db.cleanCollectedData(exp)
					db.close()
					self.setState(TC_STATES.PROCESS_DBS)	
				except BaseException as e:
					log.exception(e)
					quit(1)
			elif stateFromFile > TC_STATES.NORMAL_SHUTDOWN:
				log.error("not yet implemented")
				quit(1)
		# last state during prepare exp start
		if self.getState() > TC_STATES.PREPARE_START and self.getState() < TC_STATES.STOP_NODES:
			log.info("last state during prepare exp start, newState = prepare start")
			self.setState(TC_STATES.PREPARE_START)		
		self.processState()
	
	def processState(self):
		self.init()
		log.info("start stateprocessing")
		while self.getState() < TC_STATES.NORMAL_SHUTDOWN:
			oldState = self.getState()
			log.info("process state: %s"%str(TC_STATES.getKey(self.getState())))
			if self.getState() == TC_STATES.PREPARE_START:
				self.statePrepare()
			elif self.getState() == TC_STATES.WAIT_FOR_STARTSIGNAL: 
				self.stateWaitForStartSignal()
			elif self.getState() == TC_STATES.RUNNING_EXP: 
				self.stateRunExp()
			elif self.getState() == TC_STATES.OBSERVE_NODES: 
				self.stateObserveNodes()
			elif self.getState() == TC_STATES.STOP_NODES: 
				self.stateStopNodes()
			elif self.getState() == TC_STATES.PROCESS_DBS: 
				self.stateProcessDBs()
			else:
				log.error("unkown state: %s"%str(self.getState()))
				break
			if oldState == self.getState():
				log.error("state not changed, exit")
				break
		log.info("stateprocessing finished with: %s"%str(TC_STATES.getKey(self.getState())))
			
	def readStateFromFile(self):
		try:
			with open(PATHS.THINCLIENT_STATE_FILE) as f:
				state = int(f.readline())
			if not TC_STATES.hasValue(state):
				raise NameError("unkown state: %d"%state)
			self.state = state
		except Exception as e:
			log.debug(e)
			state = TC_STATES.UNDEFINED
		return state
		
	def getState(self):
		return self.state
	
	def setState(self, newState):
		try:
			log.debug("write new state to file: %d (%s)"%(newState,TC_STATES.getKey(newState)))
			self.state = newState	
			with open(PATHS.THINCLIENT_STATE_FILE, 'w') as f:
				f.write(str(self.state))
		except Exception as e:
			log.exception(e)
		return self.state
	
	def init(self):
		'''
		load db
		'''
		try:
			# read from db
			self.dbController = DatabaseController(PATHS.THINCLIENT_DB_FILE)
			log.info('Reading host "{0}" from database.'.format(self.properties.host))
			self.host = self.dbController.getHost(self.properties.host)
			log.info('Reading experiment "{0}" from database.'.format(self.properties.experiment))
			self.experiment = self.dbController.getExperiment(expId=self.properties.experiment)
			log.info('read logfiler')
			self.logFilters = self.dbController.getLogFilter(experiment=self.experiment)
			log.info('Reading nodes from database.')
			self.nodes = self.dbController.getNodesForHost(self.host)
			log.info('\t{0} nodes read from db'.format(len(self.nodes)))
			nodeGroupsThisHost = set()
			for node in self.nodes:
				nodeGroupsThisHost.add(node.nodeGroup())
			log.info('Reading prototypes from database.')
			self.prototypes = self.dbController.getPrototypes(self.experiment)
			nodeGroups = self.dbController.getNodeGroupsForExperiment(self.experiment)
			self.nodeGroups = dict()
			for nodeGroup in nodeGroups:
				if nodeGroup.dbID() in nodeGroupsThisHost:
					self.nodeGroups[nodeGroup.dbID()] = nodeGroup
			
			self.workingDir = os.getcwd()
			# init random seed
			Random.setSeed(int(self.experiment.getDB("seed")))
			# set number of max allowed resources
			try:
				currentLimits = resource.getrlimit(resource.RLIMIT_NOFILE)
				
				target = int(len(self.nodes) * (2 + 1 + 1) + 20) # 2 (stderr, stdout), 1 (proc), 1 (thread), 20 base
				if target > currentLimits[0]:
					log.info('change the maximum number of open file descriptors for the current process: {0}'.format(target))
					log.info('\tcurrent limit: {0}; # nodes: {1}'.format(currentLimits[0], len(self.nodes)))
					resource.setrlimit(resource.RLIMIT_NOFILE, (target,-1))
				
			except resource.error as e:
				log.error('cant change the maximum number of open file descriptors for the current process;'+
								'currentLimits: ({0}|{1}), target: ({2}|{3}) (soft|hard)'.format(
								currentLimits[0],currentLimits[1],target,currentLimits[1]))
				log.exception(e)
								
			# ntp sync
			try:
				NTP.sync(maxAttempts=3)
				log.info("ntp sync: successful")
			except BaseException as e:
				log.error("ntp sync error")
				log.exception(e)
			
			# process prototypes
			self.prototypeCmdMap = dict()
			for prototype in self.prototypes:
				# filter host specific prototypes (32 or 64 bit)
				if os.path.exists(os.path.join(PATHS.THINCLIENT_PROTOTYPE_BUNDLE, 
								PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(prototype.dbID()))):
					self.prototypeCmdMap[prototype.command()] = prototype
					prototype.libraryPath = os.path.abspath(os.path.join(
						PATHS.THINCLIENT_PROTOTYPE_BUNDLE,
						PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(prototype.dbID()), 
						PATHS.THINCLIENT_PROTOTYPE_BUNDLE_LIBS))

			
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_INIT)	
			
	
	'''
	state operations:
	'''
	
	def statePrepare(self):
		try:
			self.cleanupNodeFolder()
			self.prepareNodesDir()	
			self.prepareNodeController()
			self.setState(TC_STATES.WAIT_FOR_STARTSIGNAL)
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_PREPARE)
		
	def stateWaitForStartSignal(self):
		try:
			self.waitForStartSignal()
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_WAIT_START)
		
	def stateRunExp(self):
		try:
			self.startExperiment()
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_RUNNING_EXP)
		
	def stateObserveNodes(self):
		try:
			self.observeRunningExp()
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_OBSERVE_NODES)
		
	def stateStopNodes(self):
		try:
			self.stopAllNodes()
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_STOP_NODES)
		
	def stateProcessDBs(self):
		try:
			self.processNodeDBs()
		except BaseException as e:
			log.exception(e)
			self.setState(TC_STATES.ERR_PROCESS_DBS)
	
	'''
	worker methods
	'''

	def getLogLevelFilter(self, module):
		for logFilter in self.logFilters:
			if module.find(logFilter.getModule()) == 0:
				return logFilter.getLevel()
		return None
	
	def cleanupNodeFolder(self):
		# cleanup node folder
		nodeFolder = glob.glob(os.path.join(PATHS.THINCLIENT_NODES, PATHS.THINCLIENT_NODE_FOLDER.format('*')))
		for path in nodeFolder:
			try:
				if os.path.exists(path):
					shutil.rmtree(path, False)
			except BaseException as e:
				log.exception(e)
				
	def prepareNodesDir(self):
		'''
		prepare node directory
		contains:
		 - prototype bin sym link
		 - nodegroup data
		 - prototype data
		'''
		log.info('... process prepareNodesDir')
		
		nodeGroupsIDPrototypeMap = dict()
		for (nodeGroupID, nodeGroup) in self.nodeGroups.items():
			nodeGroupsIDPrototypeMap[nodeGroupID] = self.prototypeCmdMap[nodeGroup.prototypeCommand()]

		
		def nodeDataForNodeGroup(nodeGroupID):
			# folder contains: allgroupData, groupSpecificData, prototypeBundleData
			folder = [os.path.join(PATHS.THINCLIENT_NODEGROUP_DATA,PATHS.THINCLIENT_NODEGROUP_DATA_ALLGROUPS),
			os.path.join(PATHS.THINCLIENT_NODEGROUP_DATA,PATHS.THINCLIENT_NODEGROUP_DATA_SPECIFIC.format(nodeGroupID)),
			os.path.join(PATHS.THINCLIENT_PROTOTYPE_BUNDLE,PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(nodeGroupsIDPrototypeMap[nodeGroupID].dbID()),
				PATHS.THINCLIENT_PROTOTYPE_BUNDLE_DATA)]	
			return folder
		
		try:
			# copy data
			dbFile = PATHS.NODE_DATABASE
			nodesFolder = os.path.join(PATHS.THINCLIENT_NODES,PATHS.THINCLIENT_NODE_FOLDER)
		
			for node in self.nodes:
				nodeFolder = nodesFolder.format(node.dbID())
				folderList = nodeDataForNodeGroup(node.nodeGroup())
				# for each src folder
				for folder in folderList:
					# get all subFolders, files
					for srcDir, dirs, files in os.walk(folder):
						# process a folder with all files
						dstDir = srcDir.replace(folder, nodeFolder)
						if not os.path.exists(dstDir):
							os.mkdir(dstDir,0o777)
						if not os.path.isdir(dstDir):
							log.error('filename collision; nodeGroup:{0} target:{1}'.format(node.nodeGroup(),dstDir))
						for f in files:
							srcFile = os.path.join(srcDir, f)
							dstFile = os.path.join(dstDir, f)
							if not os.path.exists(dstFile):
								shutil.copy2(srcFile, dstFile)
				# copy expNode db
				shutil.copy2(dbFile, os.path.join(nodeFolder, dbFile))

				# build prototype bin path
				prototypeBinPath = os.path.abspath(os.path.join(PATHS.THINCLIENT_PROTOTYPE_BUNDLE,
						PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(nodeGroupsIDPrototypeMap[node.nodeGroup()].dbID()), 
						PATHS.THINCLIENT_PROTOTYPE_BUNDLE_BIN))
				# make bin executable
				oldRights = os.stat(prototypeBinPath).st_mode	
				os.chmod(prototypeBinPath, stat.S_IXGRP | stat.S_IXOTH | stat.S_IXUSR | oldRights)
				# create symlink
				os.symlink(prototypeBinPath,os.path.join(nodeFolder,nodeGroupsIDPrototypeMap[node.nodeGroup()].command()))
		except (shutil.Error, OSError, IOError) as e:
			log.error('copy error')
			log.exception(e)
			
	def prepareNodeController(self):
		'''
		prepare node controller
		'''
		log.info('... process prepareNodeController')
		self.nodeController = {} # {nodeId: controller, ...}
		nodesFolder = os.path.join(PATHS.THINCLIENT_NODES,PATHS.THINCLIENT_NODE_FOLDER)
		experimentDuration = self.experiment.getDuration()
		logLevelFilter = self.getLogLevelFilter(LOGS.NODE_CONTROLLER)
		log.debug("logfilter for nodecontroller: {0}".format(logLevelFilter))
		for node in self.nodes:
			events = self.dbController.getNodeEvents(node=node.dbID(), experiment=self.experiment.dbID())
			nodeEvents = []
			for event in events:
				expStart = self.experiment.getStart()
				secondsUntilStart = (event.getTime() - expStart)
				nodeEvents.append((secondsUntilStart, event))
			nodeFolder = nodesFolder.format(node.dbID())
			nodeEvents.sort(key=lambda tuple: tuple[1].getTime())
			controller = NodeController(node=node, path=os.path.join(self.workingDir,nodeFolder), 
										events=nodeEvents, nodeGroup=self.nodeGroups[node.nodeGroup()],
										name='NodeController({0})'.format(node.dbID()),
										experimentDuration=experimentDuration,
										prototype=self.prototypeCmdMap[self.nodeGroups[node.nodeGroup()].prototypeCommand()],
										logLevelFilter=logLevelFilter)
			controller.daemon = True
			self.nodeController[node.dbID()] = controller
		# prepare sigchld handler
		#signal.signal(signal.SIGCHLD, lambda signalnum, frame: log.error("receive SIGCHLD, stack: {0}".format(repr(frame))))

		# set signal receiver, user-signal 2 = stop (abort) experiment
		NodeController.abortExperiment = threading.Event()
		signal.signal(CLIENT_SIGNALS.ABORT_EXP, lambda sigNum, stack: self.receiveStopExperiment(sigNum))
		print('sig: {0} handler: {1}'.format(CLIENT_SIGNALS.ABORT_EXP,signal.getsignal(CLIENT_SIGNALS.ABORT_EXP)))
					


		
	def waitForStartSignal(self):
		receivedStartSigal = False
		wait = Config.getInt("TIMEOUTS","THINCLIENT_WAIT_UNTIL_START_EXP") # max waittime
		# wait for experiment start
		log.info("wait for experiment start")
		if self.properties.autostart == True:
			log.info("autostart flag -> received start")
			receivedStartSigal = True
		else:
			log.info("ready, wait for startfile...")
			poll = 5
			while wait > 0:
				wait -= poll
				try:
					if os.path.exists(PATHS.THINCLIENT_EXPSTART_FILE):
						receivedStartSigal = True
						wait = 0
						log.info("found startfile")
				except BaseException as e:
					log.exception(e)	
				time.sleep(poll)
		if receivedStartSigal:
			self.setState(TC_STATES.RUNNING_EXP)
		else:
			log.error("no start signal received")
			self.setState(TC_STATES.ERR_WAIT_START)	
		
	def startExperiment(self):
		'''
		wait until exp start time reached, invokes node controller
		'''
		expDuration = self.experiment.getDuration()

		self.realTimeStart = utcDateTime()
		# read start time from file
		if self.properties.autostart == False:
			try:
				with open(PATHS.THINCLIENT_EXPSTART_FILE) as f:
					self.realTimeStart = parseSqlDateTime(f.readline().strip())
					log.debug("found starttime: {0}".format(self.realTimeStart))
			except BaseException as e:
				log.error('cant read startTime from file')
				log.exception(e)
		
		expectedTimeEnd = self.realTimeStart + seconds2timedelta(expDuration)
		self.expectedTimeEnd = expectedTimeEnd

		log.info('experiment duration: {0} seconds'.format(expDuration))		
		log.info(highlightedText({
			'start':dateTimeString(self.realTimeStart), 
			'expectedEnd':dateTimeString(expectedTimeEnd)}))
		
		NodeController.abortExperiment = threading.Event()
		
		# wait until expStartTime
		startTime = utcDateTime2timetime(self.realTimeStart)
		delta = startTime - NTP.utcTime()
		print("wait unitl exp starts, ~ {0} seconds (current:{1} starTime:{2})".format(delta, NTP.utcTime(),startTime))
		
		# if starttime is past, skip events
		if delta < 0:
			for nodeController in self.nodeController.values():
				for index,event in enumerate(nodeController.events):
					nodeController.events[index] = (max(0,event[0]+delta),event[1])
		
		while startTime > NTP.utcTime():
			sleepTime = max(1,int(startTime-NTP.utcTime()))
			print("wait unitl exp starts, {0} seconds".format(sleepTime))
			time.sleep(sleepTime)		
				
		for nodeController in self.nodeController.values():
			with NodeController.running_threads_lock:
				NodeController.running_threads += 1
			nodeController.start()
	
		self.setState(TC_STATES.OBSERVE_NODES)
		
	
	def observeRunningExp(self):
		'''
		wait until all node controller finished their job
		'''
		expDuration = self.experiment.getDuration()
			
		realTimeStart = utcDateTime2timetime(self.realTimeStart)
		while NodeController.running_threads > 0:
			realTimeEnd = time.time()
			remainingExpTime = expDuration - (realTimeEnd-realTimeStart)
			sleep = min(Config.getInt("TIMEOUTS","THINCLIENT_RUNNING_THREADS_POLL_INT"), remainingExpTime)
			sleep = max(1,sleep)
			log.info('{0}\tmain-thread waits until no thread is running, running:{1}'.format(dateTimeString(),
				NodeController.running_threads))
			time.sleep(sleep)
			if NodeController.abortExperiment.is_set():
				log.error('main-thread receives stop work')
				for nodeController in self.nodeController.values():
					nodeController.abortExperiment()
				break
		self.realTimeEnd = datetime.datetime.now()
		log.info('no remaining node thread is running')
		
		log.info(highlightedText({
			'start':dateTimeString(self.realTimeStart), 
			'end':dateTimeString(self.realTimeEnd)}))
		# remove protoype symlinks
		self.removePrototypeSymlinks()		
		self.setState(TC_STATES.STOP_NODES)
		
	def removePrototypeSymlinks(self):
		'''
		remove all prototype symlinks
		'''
		log.info('... remove all prototype symlinks')
		# map of all prototypes
		nodeGroupsIDPrototypeMap = dict()
		for (nodeGroupID, nodeGroup) in self.nodeGroups.items():
			nodeGroupsIDPrototypeMap[nodeGroupID] = self.prototypeCmdMap[nodeGroup.prototypeCommand()]
	
		nodesFolder = os.path.join(PATHS.THINCLIENT_NODES,PATHS.THINCLIENT_NODE_FOLDER)
		
		for node in self.nodes:
			nodeFolder = nodesFolder.format(node.dbID())
			symlinkFile = os.path.join(nodeFolder,nodeGroupsIDPrototypeMap[node.nodeGroup()].command())
			try:
				if os.path.exists(symlinkFile):
					os.remove(symlinkFile)
			except BaseException as e:
				log.error('removePrototypeSymlinks failed; node:{0}'.format(node.dbID()))
				log.exception(e)
	
	def receiveStopExperiment(self, sigNum):
		'''
		stop signal event listener
		'''
		log.info("received user-signal-2; stop (abort) experiment")
		print("receive stop-exp")
		signal.signal(sigNum, signal.SIG_IGN)
		timeout = Config.getInt("TIMEOUTS","THINCLIENT_RECEIVE_EXPERIMENT_STOP_SHUTDOWNTIME")
		NodeController.abortExperiment.set()
		for nodeController in self.nodeController.values():
			nodeController.abortExperimentAction()
		time.sleep(timeout)
		for nodeController in self.nodeController.values():
			try:
				nodeController.proc.sendSignal(SIGNALS.SIGKILL)
			except BaseException:
				pass
		self.setState(TC_STATES.ERR_EXP_ABORTED)
		os.kill(os.getpid(), SIGNALS.SIGKILL)

	def stopAllNodes(self):
		# stop nodes
		for nodeController in self.nodeController.values():
			nodeController.abortExperimentAction()
		for nodeController in self.nodeController.values():
			try:
				nodeController.proc.sendSignal(SIGNALS.SIGKILL)
			except BaseException as e:
				log.exception(e)	
		self.setState(TC_STATES.PROCESS_DBS)	

	def processNodeDBs(self):
		'''
		process node dbs
		'''
		log.info('... processNodeDBs')
		
		if not hasattr(self, "nodeController"):
			self.prepareNodeController()
		
		# prepare statistics
		allStatistics = self.dbController.getStatistics()
		controllerEvents = {}
		stats = [stat.dbID() for stat in allStatistics]
		if len(stats) > 0:
			lastStatisticsID = max(stats)
		else:
			lastStatisticsID = 0
		
		# prepare dumps
		allDumps = self.dbController.getDumps()
		dumps = [dump.dbID() for dump in allDumps]
		if len(dumps) > 0:
			lastDumpID = max(dumps)
		else:
			lastDumpID = 0
			
		# create controller staistic events
		controllerStatistics = [];
		for event in STATISTIC.values():
			lastStatisticsID += 1
			
			values = dict.fromkeys(Models.NodeDatabase.Statistic.FIELDS)
			values['id'] = lastStatisticsID
			values['experiment'] = self.experiment.dbID()
			values['name'] = event
			values['units'] = '#'
			values['label'] = event
			values['node'] = -1
			values['type'] = 'unknown type'
			values['units'] = '#'
			stat = Models.NodeDatabase.Statistic(values)	
			controllerEvents[event] = lastStatisticsID
			allStatistics.append(stat)
	
		processString = 'process node {0}/{1}, id: {2}, in {3} sec'
		lock = WorkerPool.newLock()
		for (controllerIndex, nodeController) in enumerate(self.nodeController.values()):
			processTime = time.time()
			# read controller statistic
			controllerStatistics.extend(nodeController.getControllerStatistics()) # [(time, event), ...]

			# process controller logs
			try:
				delta = self.experiment.getStart() - utcDateTime2timetime(self.realTimeStart) + NTP.getDelta()
				logs = nodeController.getControllerLogs() # list of (timestamp, level, message)
				values = dict.fromkeys(Models.NodeDatabase.Log.FIELDS)
				values['node'] = nodeController.node.dbID()
				values['experiment'] = self.experiment.dbID()
				values['module'] = LOGS.NODE_CONTROLLER
				for entry in logs:			
					values['time'] = utcTimetime2String(entry[0]+delta)
					values['level'] = entry[1]
					values['message'] = entry[2]
					logEntry = Models.NodeDatabase.Log(values)
					self.dbController.storeLog(logEntry)
			except BaseException as e:
				log.exception(e)
				log.error('nodeDB error during process logs (id:{0})'.format(nodeController.node.dbID()))

			# read node db
			dbs = nodeController.getNodeDatabases()
			for dbPath in dbs:
				try:					
					# update entries (transver ids)
					db = DatabaseController(dbPath)
					DatabaseProcessing.prepareNodeDbIDs(
						db, 
						nodeController.node, 
						self.experiment,
						NTP.getDelta(), 
						utcDateTime2timetime(self.realTimeStart),
						allStatistics,
						allDumps,
						lock)
					db.commitChanges()
					db.close()
					# move entries to other db

					dbAlias = "nodeDB"
					self.dbController.attachDB(dbPath, dbAlias)
					self.dbController.copyDumpEntriesFromAttachedDB(dbAlias)
					self.dbController.copyLogEntriesFromAttachedDB(dbAlias)
					self.dbController.copyStatisticEntriesFromAttachedDB(dbAlias)
					self.dbController.detachDB(dbAlias)
					self.dbController.commitChanges()	
				except BaseException as e:
					log.error('nodeDB error (id:{0})'.format(nodeController.node.dbID()))
					log.exception(e)
		
			timePast = round(time.time()-processTime,1)
			print(processString.format(controllerIndex+1,len(self.nodeController),nodeController.node.dbID(),timePast))
			sys.stdout.flush()
		
		
		# process controller statistics
		print(repr(controllerStatistics))
		if len(controllerStatistics) > 0:
			print("process controller event statistics, read {0} items".format(len(controllerStatistics)));
			logInterval = round(self.experiment.logInterval(), Config.getInt("LIMITS","EQUAL_TIME_MEASUREMENT_PRECISION"))
			controllerStatistics.sort(key=lambda x: x[0]) # sort by time, in memory
			delta = NTP.getDelta()
			expTimeDelta = self.experiment.getStart() - utcDateTime2timetime(self.realTimeStart)
			currentTime = utcDateTime2timetime(self.realTimeStart)
			part = int(currentTime // logInterval)
			currentTime = round(float(part) *  logInterval, Config.getInt("LIMITS","EQUAL_TIME_MEASUREMENT_PRECISION"))
			endTime = utcDateTime2timetime(self.expectedTimeEnd)
			runningNodes = 0
			currentValues = {}
			for event in controllerEvents:
				if (event != STATISTIC.RUNNING_NODES):
					currentValues[event] = 0
			while(currentTime < endTime or len(controllerStatistics) > 0):
				for event in currentValues:
					currentValues[event] = 0	
				currentTime += logInterval			
				while(len(controllerStatistics) > 0 and (controllerStatistics[0][0]+delta) <= currentTime):
					print(repr(controllerStatistics[0]))
					(t,e) = controllerStatistics.pop(0)
					currentValues[e] += 1
					if (e == STATISTIC.NODE_EVENT_JOINS):
						runningNodes += 1
					elif (e == STATISTIC.NODE_EVENT_LEAVE_TIMEOUTS or e == STATISTIC.NODE_EVENT_CRASHES or e == STATISTIC.NODE_EVENT_LEAVES):
						runningNodes -= 1
						
				dt = utcTimetime2datetime(currentTime + expTimeDelta)
				dt = dateTimeString(dt)
				
				for event in controllerEvents:
					values = dict.fromkeys(Models.NodeDatabase.Measurement.FIELDS) 
					values['statistic'] = controllerEvents[event]
					if (event == STATISTIC.RUNNING_NODES):
						val = runningNodes
					else:
						val = currentValues[event]
					values['time'] = dt
					values['count'] = 1
					values['min'] = val
					values['max'] = val
					values['sum'] = val
					values['sum2'] = val * val
					measurement = Models.NodeDatabase.Measurement(values)
					self.dbController.storeMeasurement(measurement)	

		# save statistic data
		for statistic in allStatistics:
			self.dbController.storeStatistic(statistic)
		# save dump data
		for dump in allDumps:
			self.dbController.storeDump(dump)
		self.dbController.commitChanges()
		self.setState(TC_STATES.NORMAL_SHUTDOWN)
	

