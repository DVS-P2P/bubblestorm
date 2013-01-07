#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *
from ...base.Database import DatabaseController
from ...base.DatabaseProcessing import DatabaseProcessing

from ... import models as Models

from .Monitoring import Monitoring

log = logging.getLogger(__name__)

class PostProcessing(object):

	def __init__(state):
		raise NotImplementedException()		
	
	@staticmethod
	def resetHosts(state, hosts=None):
		'''
		reset hosts
		'''
		if hosts == None:
			hosts = state.experiment.getHosts()
		result = state.processJobs(hosts, 'runResetHosts', 'reset hosts')
		return result
	
	@staticmethod
	def removeExperiment(state, hosts=None):
		'''
		reset hosts
		'''
		if hosts == None:
			hosts = state.experiment.getHosts()
		result = state.processJobs(hosts, 'runRemoveExperiment', 'remove experiment')
		return result
	
	@staticmethod
	def repeatExperiment(state):
		log.error("not refactored")
		'''
		rerun experiment with same configuration
		'''
		log.info('repeat experiment, check hosts...')
		result = state.checkHosts()
		while len(result['failedHosts']) > 0:
			log.info('{0} not available'.format(len(result['failedHosts'])))
			input = askUserOption('(r)etry, (a)bort', 
						['r','a'], 'abort', 'a')
			if input == 'r':
				result = state.checkHosts(result['failedHosts'])
			else:
				state.stopMaster()
		log.info('prepare database...')
		state.dbController.cleanCollectedData(state.experiment)
		state.dbController.commitChanges()
		log.info('prepare hosts...')
		t = time.time()
		state.repeatExperimentPrepareHosts()
		delay = time.time() - t
		log.info('start experiment...')
		state.prepareStartExperiment(delay)
	
	@staticmethod
	def repeatExperimentPrepareHosts(state):
		'''
		prepare directory
		'''
		hosts = state.experiment.getHosts()
		result = state.processJobs(hosts, 'runPrepareWorkingDirRepeatExperiment', 'prepare working dir')
		return result	
	
	@staticmethod
	def cleanupHosts(state):	
		'''
		cleanup hosts
		'''
		hosts = state.experiment.getHosts()
		result = state.processJobs(hosts, 'runCleanupHosts', 'cleanup hosts')
		return result
	
	@staticmethod
	def reprocessCollectedData(state):
		'''
		reprocess collected client dbs
		'''
		log.info("... reprocess collected databases")
		state.dbController.cleanCollectedData(state.experiment)
		assert(len(state.dbController.getStatistics(state.experiment)) == 0)
		PostProcessing.processCollectedDBs(state, state.experiment.getHosts())

	
	@staticmethod
	def checkCollectedData(state):
		'''
		checks collected client dbs
		load missing
		'''
		log.info("... check collected databases")
		hosts = state.experiment.getHosts()
		allDownloaded = False	
		while not(allDownloaded):
			unfinishedHosts = []
			for host in hosts:
				localHostFolder = os.path.join(state.cwdPath,host.getLocalFolderCollectedData())
				hostDB = os.path.join(localHostFolder, PATHS.THINCLIENT_DB_FILE)
				if not(os.path.exists(hostDB)):
					unfinishedHosts.append(host)
			log.info('{0}/{1} databases collected'.format((len(hosts)-len(unfinishedHosts)),len(hosts)))
			# wait until clients ready

			downloadableHosts, failedHosts = PostProcessing.checkThinClientFinishedWork(state, unfinishedHosts)
			if len(downloadableHosts) > 0:
				result = PostProcessing.collectDatabase(state, downloadableHosts)
				try:
					while len(result['failedHosts']) > 0:
						 downloadableHosts.remove(result['failedHosts'].pop())
				except: 
					pass
				PostProcessing.processCollectedDBs(state, downloadableHosts)
			elif len(failedHosts):
				input = askUserOption('remaining hosts failed - retry? (y)es, (n)o', ['y','n'], 'y', 'n')
				if input == "n":
					return
			if len(unfinishedHosts) == 0 or len(unfinishedHosts) == len(downloadableHosts):
				allDownloaded = True
			

	
	@staticmethod
	def checkThinClientFinishedWork(state, hosts):
		'''
		checks whether thin client has done all postprocessing stuff
		'''		
		startWait = 10
		while len(hosts) > 0:	
			startWait = min(startWait + 20, 120)
			result = Monitoring.determineThinClientState(state, hosts, onFailAskUser=False)
			hostsOK = [h for h in hosts if h.getThinClientState() == TC_STATES.NORMAL_SHUTDOWN]
			hostsWorking = [h for h in hosts if h.getThinClientIsRunning() and  h.getThinClientState() < TC_STATES.NORMAL_SHUTDOWN and h.getThinClientState() >= TC_STATES.RUNNING_EXP]
			hostsFailed = [h for h in hosts if h not in set(hostsOK) and h not in set(hostsWorking)]
			log.debug("hostsOK: %d"%len(hostsOK))
			log.debug("hostsFailed: %d"%len(hostsFailed))
			log.debug("hostsWorking: %d"%len(hostsWorking))
			print("hosts ok/working/failed: {0}/{1}/{2}".format(len(hostsOK),len(hostsWorking),len(hostsFailed)))
			ignoreFailed = False
			if len(hostsFailed) > 0:
				while True:
					input = askUserOption('(i)gnore, show (e)rror, (restart) clients and reprocess data', ['i','e',"restart"], 'i', 'i')
					if input == "e":
						for h in hostsFailed:
							print("{0}: last state: {1}".format(h, TC_STATES.getKey(h.getThinClientState())))
					elif input == "restart":
						print("restart clients")
						resultSetState = state.processJobs(hostsFailed, 'runSetThinClientState', 'set thinClient state',{'state': TC_STATES.ERR_PROCESS_DBS})
						resultStart = state.processJobs(resultSetState['okHosts'], 'runStartThinClient', 'start thinClient')
						break
					else:
						ignoreFailed = True
						break
			if len(hostsOK) > 0:
				return (hostsOK,hostsFailed)
			else:
				if ignoreFailed:
					break
				waitUntil = time.time() + min(startWait, 120)
				progressWriter(lambda: time.time()<waitUntil, newLine=True, timer=False, lowFrequentCheck=False,
					statusCallable=lambda: '{0} seconds until next check '.format(str(round(waitUntil-time.time()))))	
		return ([],hostsFailed)

	'''
	create expected statistics
	'''
	@staticmethod
	def createExpectedStatistics(state, hosts=None):
		if hosts == None:
			hosts = list(state.experiment.getHosts())
		# read statistics
		allStatistics = list(state.dbController.getStatistics())
		# create new statistic
		values = dict.fromkeys(Models.NodeDatabase.Statistic.FIELDS)
		if len(allStatistics) > 0:
			values['id'] = 1 + max([s.dbID() for s in allStatistics])
		else:
			values['id'] = 1
		values['experiment'] = state.experiment.dbID()
		values['name'] = STATISTIC.RUNNING_NODES_EXPECTED
		values['units'] = '#'
		values['label'] = STATISTIC.RUNNING_NODES_EXPECTED
		values['node'] = -1
		values['type'] = 'unknown type'
		values['units'] = '#'
		statistic = Models.NodeDatabase.Statistic(values)
		# check for existing statistic
		for s in allStatistics:
			if s.isSame(statistic):
				statistic = s
				break
		state.dbController.storeStatistic(statistic)
		# determine events
		hostIDs = set([h.dbID() for h in hosts])
		nodes = state.experiment.getAllNodes()
		filteredNodes = [n for n in nodes if n.hostID() in hostIDs]

		expStart = state.experiment.getStart()			
		expStartRealtime = state.experiment.getLastRun()			
		# parse events
		updates = dict()
		for node in filteredNodes:
			events = state.dbController.getNodeEvents(node.dbID(), state.experiment.dbID())
			for event in events:
				eventTime = event.getTime()
				if event.isStart():
					if eventTime in updates:
						updates[eventTime] += 1
					else:
						updates[eventTime] = 1
				elif event.isCrash() or event.isQuit():
					if eventTime in updates:
						updates[eventTime] -= 1
					else:
						updates[eventTime] = -1
		# process parsed events
		updateList = [(t,v) for (t,v) in updates.items()]
		state.dbController.updateExperimentMeasurementsFromEventlist(statistic, updateList)
		state.dbController.commitChanges()





	'''
	experiment is finished, collect data
	'''
	@staticmethod
	def processCollectedDBs(state, hosts):
		'''
		process collected dbs
		'''
		log.info('... processing collected database (merge statistics, dumps, logs)')	
		# read statistics
		allStatistics = list(state.dbController.getStatistics())
		# read dumps
		allDumps = list(state.dbController.getDumps())
		modifyGlobalLock = WorkerPool.newLock()

		statusText = '\r... prepare host db (update ids) {0}/{1} in ({2} s)'
		startTime = time.time()
		hostCnt = len(hosts)
		for (index, host) in enumerate(hosts):
			try:
				state.dbController.commitChanges()	
				sys.stdout.write(statusText.format(index+1,hostCnt,round(time.time()-startTime,3)))
				sys.stdout.flush()

				localHostFolder = os.path.join(state.cwdPath,host.getLocalFolderCollectedData())
				# read host db
				hostDBPath = os.path.join(localHostFolder, PATHS.THINCLIENT_DB_FILE)
				hostDB = DatabaseController(hostDBPath)
				# prepare ids
				DatabaseProcessing.prepareHostDbIDs(hostDB, allStatistics, allDumps, modifyGlobalLock)
				hostDB.close()	
			except BaseException as e:
				log.error('hostDB error (id:{0})'.format(host.dbID()))
				log.exception(e)

		sys.stdout.write(statusText.format(hostCnt,hostCnt,round(time.time()-startTime,3)) + "\n")
		sys.stdout.flush()

		for statistic in allStatistics:
			if statistic.isLiveExperimentStatistic():
				state.dbController.alignLiveExperimentStatistics(statistic)
			state.dbController.storeStatistic(statistic)	
		for dump in allDumps:
			state.dbController.storeDump(dump)
		state.dbController.commitChanges()

		state.dbController.setSafeWrite(False)

		statusText = '\r... copy entries from host {0}/{1} in ({2} s)'
		startTime = time.time()
		hostCnt = len(hosts)
		for (index, host) in enumerate(hosts):
			try:
				state.dbController.commitChanges()	
				sys.stdout.write(statusText.format(index+1,hostCnt,round(time.time()-startTime,3)))
				sys.stdout.flush()

				localHostFolder = os.path.join(state.cwdPath,host.getLocalFolderCollectedData())
				# read host db
				hostDBPath = os.path.join(localHostFolder, PATHS.THINCLIENT_DB_FILE)

				dbAlias = "hostdb%d"%host.dbID()

				state.dbController.attachDB(hostDBPath, dbAlias)
				state.dbController.copyDumpEntriesFromAttachedDB(dbAlias)
				state.dbController.copyLogEntriesFromAttachedDB(dbAlias)
				state.dbController.copyStatisticEntriesFromAttachedDB(dbAlias)
				
				state.dbController.detachDB(dbAlias)
			except BaseException as e:
				log.error('hostDB error (id:{0})'.format(host.dbID()))
				log.exception(e)
				try:
					state.dbController.detachDB(dbAlias)
				except:
					pass
				
		sys.stdout.write(statusText.format(hostCnt,hostCnt,round(time.time()-startTime,3)) + "\n")
		sys.stdout.flush()

		for statistic in allStatistics:
			if statistic.isLiveExperimentStatistic():
				state.dbController.alignLiveExperimentStatistics(statistic)

		state.dbController.commitChanges()
		state.dbController.setSafeWrite(True)

		PostProcessing.createExpectedStatistics(state, hosts)
			
		
	@staticmethod
	def collectDatabase(state, hosts):
		'''
		collects host dbs
		'''
		result = state.processJobs(hosts, 'runCollectDatabase', 'collect databases')
		return result
	
	@staticmethod
	def collectHostData(state, hosts):	
		'''
		collects host data
		'''
		result = state.processJobs(hosts, 'runCollectHostData', 'collect hostdata')
		return result
	
	@staticmethod
	def collectGroupData(state, groups):
		'''
		collects node data by given groups
		'''
		nodes = state.experiment.getAllNodes()
		groupIDs = [g.dbID() for g in groups]
		nodes = list(filter(lambda n: n.nodeGroup() in groupIDs, nodes))
		return PostProcessing.collectNodeData(state, nodes)
		
	@staticmethod
	def collectNodeData(state, nodes):
		'''
		collects node data
		'''
		nodeHostMap = {}
		for node in nodes:
			if node.hostID() not in nodeHostMap:
				nodeHostMap[node.hostID()] = []
			nodeHostMap[node.hostID()].append(node)
		
		hosts = []
		for host in state.experiment.getHosts():
			if host.dbID() in nodeHostMap:
				hosts.append(host)
		
		result = state.processJobs(hosts, 'runCollectNodeData', 'collect nodedata', nodeHostMap)
		return result