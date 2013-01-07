#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import time
import copy

from .Database import DatabaseController
from .SubProc import SSH, SubProc
from .Constants import *
from .Utils import *

from .. import models as Models

log = logging.getLogger(__name__)

class DatabaseProcessing(object):

	@staticmethod
	def prepareNodeDbIDs(nodeDB, node, experiment, ntpDelta, realtimeExpStart, globalStatistics, globalDumps, modifyGlobalLock):
		'''
		prepare nodeDB for merge

		set unkown values (nodeID, expId)
		transver statisticIDs, dumpIDs (match local with global IDs)
		ntpDelta processing
		'''
		# replace unkown information
		nodeDB.setMissingNodeDbValues(experiment, node)
		# check statistic ids
		statIdTranserMap = {}
		statistics = nodeDB.getStatistics()
		with modifyGlobalLock:
			statIdTranserMap = DatabaseProcessing.matchObjectsWithGlobalSpace(statistics, globalStatistics)
		# update statistic id references
		if len(statIdTranserMap) > 0:
			nodeDB.replaceStatisticIDs(statIdTranserMap)	
		# check dump ids
		dumpIdTranserMap = {}
		dumps = nodeDB.getDumps()
		with modifyGlobalLock:
			dumpIdTranserMap = DatabaseProcessing.matchObjectsWithGlobalSpace(dumps, globalDumps)
		# update dump id references
		if len(dumpIdTranserMap) > 0:
			nodeDB.replaceDumpIDs(dumpIdTranserMap)
		# update measurements where node = -1: time = time - (time % logint)
		logInterval = experiment.logInterval()
		timeDiff = experiment.getStart() - realtimeExpStart + ntpDelta
		nodeDB.addTimeDeltaAndAlignValues(timeDiff, logInterval)
		nodeDB.commitChanges()

	@staticmethod
	def prepareHostDbIDs(hostDB, globalStatistics, globalDumps, modifyGlobalLock):
		'''
		prepare hostDB for merge


		transver statisticIDs, dumpIDs (match local with global IDs)
		'''
		log.debug("prepareHostDbIDs")
		# check statistic ids
		statIdTranserMap = {}
		statistics = hostDB.getStatistics()
		log.debug("matchObjectsWithGlobalSpace: statistics")
		with modifyGlobalLock:
			statIdTranserMap = DatabaseProcessing.matchObjectsWithGlobalSpace(statistics, globalStatistics)
		# update statistic id references
		if len(statIdTranserMap) > 0:
			hostDB.replaceStatisticIDs(statIdTranserMap)	
		hostDB.commitChanges()	
		# check dump ids
		dumpIdTranserMap = {}
		dumps = hostDB.getDumps()
		log.debug("matchObjectsWithGlobalSpace: dumps")
		with modifyGlobalLock:
			dumpIdTranserMap = DatabaseProcessing.matchObjectsWithGlobalSpace(dumps, globalDumps)
		# update dump id references
		if len(dumpIdTranserMap) > 0:
			hostDB.replaceDumpIDs(dumpIdTranserMap)
		hostDB.commitChanges()
	
	@staticmethod
	def matchObjectsWithGlobalSpace(localObjects, globalObjects):
		'''
		find for each local obj a matching global obj or create a global if nothing found
		'''
		idTranserMap = {}
		#log.debug(len(localObjects))
		#log.debug(len(globalObjects))
		#t = time.time()
		for localObj in localObjects:
			# check for existing object
			found = None
			lastId = 0
			for globalObj in globalObjects:
				lastId = max(lastId, globalObj.dbID())
				if globalObj.isSame(localObj):
					found = globalObj
					break
			if found == None:
				lastId += 1
				found = copy.copy(localObj)
				found.setID(lastId)
				globalObjects.append(found)
			idTranserMap[localObj.dbID()] = found.dbID()
		#log.debug("calc time: %d"%(time.time()-t))
		return idTranserMap	

	@staticmethod
	def transerAllObject(sourceDB, targetDB, dbobjectClass, whereDict):
		'''
		transfer all onject from source to target

		do not use for large data amount!
		'''
		bucket = 0
		while True:
			objects = sourceDB.getObjects(dbobjectClass, whereDict, bucket)
			if len(objects) == 0:
				break
			bucket += 1			
			
			for obj in objects:
				targetDB.insertOrReplace(obj,True)
	
