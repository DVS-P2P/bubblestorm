#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import copy
import datetime
import glob
import logging
import os
import shutil
import signal
import sqlite3
import random
import sys
import time
import traceback

from .SubProc import SSH, SubProc
from .Constants import *
from .Config import Config
from .Utils import *

from .. import models as Models

log = logging.getLogger(__name__)

class DatabaseController(object):

	def __init__(self, sqliteFile):
		self.sqliteFile = sqliteFile
		self.init()
		self.allSaved = True

		self.registeredFunctions = set()

	def setSafeWrite(self, active):
		if active == True:
			self.cursor.execute('PRAGMA synchronous = on;')
		else:
			self.cursor.execute('PRAGMA synchronous = off;')

	def transactionBegin(self):
		self.cursor.execute('BEGIN TRANSACTION;')
	
	def transactionCommit(self):
		self.cursor.execute('COMMIT;')
	
	def buildInsertStatements(self, valuesDict):
		keys = valuesDict.keys()
		fields = '({0})'.format(','.join(keys))
		placeHolder = '({0})'.format(','.join([':{0}'.format(k) for k in keys]))
		return '{0} VALUES {1}'.format(fields, placeHolder)
		
	def buildPlaceholderPairs(self, keys, delimiter):
		return delimiter.join(['{0} = :{0}'.format(k) for k in keys])

	def init(self):
		'''
		open connection, set factories
		'''
		try:
			log.info('check database file access')
			os.access(self.sqliteFile, os.W_OK | os.R_OK)
		except IOError as e:
			log.error("cant access database")
			log.exception(e)
			raise NameError(e)
			
		try:
			self.connection = sqlite3.connect(self.sqliteFile)
			self.connection.text_factory = str
			self.connection.row_factory = sqlite3.Row
			self.cursor = self.connection.cursor()
			# TODO fix "Error: foreign key mismatch" if PRAGMA foreign_keys = on
			self.cursor.execute('PRAGMA foreign_keys = off;')
			self.cursor.execute('PRAGMA temp_store = 2;')
			self.cursor.execute('PRAGMA page_size = 65536;')
			log.info('{0} database connection successful'.format(self))
		except sqlite3.Error as e:
			log.exception(e)
			raise NameError(e)

	def registerFunction(self, name, parameterCnt, func):
		if name in self.registeredFunctions:
			log.debug("%s already registered"%name)
		log.debug("register db function %s"%name)
		try:
			self.connection.create_function(name, parameterCnt, func)
			self.registeredFunctions.add(name)
		except sqlite3.Error as e:
			log.exception(e)
			log.error("error during function (%s) create"%name)		

	def oldDataExists(self, experiment):
		'''
		checks existence of old data
		'''
		try:
			self.cursor.execute('SELECT count(id) FROM nodes WHERE experiment=:experiment',
							{'experiment':experiment.dbID()})
			row = self.cursor.fetchone()
			if row == None or row[0] == 0:
				return False
			else:
				return True
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)

	def cleanDB(self, experiment):
		'''
		removes old data
		'''
		# clean collected data
		self.cleanCollectedData(experiment)
		# clean remaining data
		try:		
			log.info('removing old data from db')
			self.allSaved = False
			keys = {'experiment':experiment.dbID()}
			cmds = ['delete from node_events where experiment = :experiment;',
			'delete from nodes where experiment = :experiment;',
			'vacuum;']
			for cmd in cmds:
				self.cursor.execute(cmd,keys)
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
	
	def cleanCollectedData(self, experiment):
		'''
		removes collected data from hosts (statistics, logs, ...)
		'''
		try:		
			log.info('removing old data from db')
			self.allSaved = False
			keys = {'experiment':experiment.dbID()}
			cmds = ['delete from measurements where statistic in (select id from statistics where experiment = :experiment);',
			#'delete from measurements_single where statistic in (select id from statistics where experiment = :experiment);' ,
			'delete from histograms where statistic in (select id from statistics where experiment = :experiment);' ,
			'delete from statistics where experiment = :experiment;',
			'delete from log where experiment = :experiment;',
			'delete from dump_data where dump in (select id from dumps where experiment = :experiment);',
			'delete from dumps where experiment = :experiment;',
			'vacuum;']
			for cmd in cmds:
				self.cursor.execute(cmd,keys)
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
			
	def commitChanges(self):
		'''
		writes file
		'''
		log.debug("commitChanges")
		try:		
			if not(self.allSaved):
				self.allSaved = True
				self.connection.commit()
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)

	def close(self, commit=True):
		'''
		close connection
		'''
		if commit:
			try:
				self.commitChanges()
			except:
				pass
		try:
			self.connection.close()
			log.info('{0} database closed successful'.format(self))
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)

	'''
	generic methods, getter & setter
	'''
	
	def getObject(self, objClass, whereDict):
		'''
		returns one object
		'''
		try:		
			keys = ','.join(objClass.FIELDS)
			table = objClass.TABLE
			where = self.buildPlaceholderPairs(whereDict.keys(), ' AND ')
			sql = 'SELECT {0} FROM {1} WHERE {2}'.format(keys, table, where)
			self.cursor.execute(sql, whereDict)
			row = self.cursor.fetchone()
			if row == None:
				raise ValueError('cant find {0} with {1}'.format(objClass, whereDict))
			else:
				return objClass(row)
		except (sqlite3.Error, ValueError) as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
	
	def getObjects(self, objClass, whereDict=None, bucket=None, specialTable=None):
		'''
		returns a list of objects
		'''
		try:		
			keys = ','.join(objClass.FIELDS)
			table = objClass.TABLE if specialTable == None else specialTable
			sql = 'SELECT {0} FROM {1}'.format(keys, table)
			
			where = '' if whereDict == None else ' WHERE {0}'.format(self.buildPlaceholderPairs(whereDict.keys(), ' AND '))
			sql = '{0} {1}'.format(sql, where)
			
			bucketSize = Config.getInt("LIMITS","SQLITE_STATS_BUCKET")
			limit = '' if bucket == None else 'LIMIT {0},{1}'.format(bucketSize * bucket, bucketSize)
			sql = '{0} {1}'.format(sql, limit)
				
			if whereDict == None:
				self.cursor.execute(sql)
			else:
				self.cursor.execute(sql, whereDict)
				
			out = []
			for row in self.cursor:
				out.append(objClass(row))
			return out
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
			
	def insertOrReplace(self, dbObject, withReplace):
		'''
		insert or replace the given object
		'''
		try:	
			values = dbObject.getAllValues()
			table = dbObject.getTableName()
			sqlFields = self.buildInsertStatements(values)
			replace = 'OR REPLACE' if withReplace else ''
			self.cursor.execute('INSERT {0} INTO {1} {2}'.format(replace, table, sqlFields), values)
			self.allSaved = False
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
			
	def insert(self, dbObject):
		self.insertOrReplace(dbObject, False)
			
	def replace(self, dbObject):
		self.insertOrReplace(dbObject, True)
			
	def update(self, dbObject, identKeys, updateKeys):
		'''
		updates an entry
		'''
		try:		
			values = dbObject.getAllValues()
			table = dbObject.getTableName()
			updateKeys = set(updateKeys) - set(identKeys)
			sql = 'UPDATE {0} SET {1} WHERE {2}'.format(table,
				self.buildPlaceholderPairs(updateKeys, ', '), self.buildPlaceholderPairs(identKeys, ' AND '))
			self.cursor.execute(sql, values)
			self.allSaved = False
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
	
	'''
	merge db processing
	'''
	
	def attachDB(self, dbPath, dbAlias):
		log.debug("attach %s(%s)"%(dbAlias,dbPath))
		sql = 'attach :path as :alias'
		val = {'path': dbPath, 'alias':dbAlias}
		try:		
			self.cursor.execute(sql, val)
		except sqlite3.Error as e:
			log.exception(e)
			raise NameError(e)
			
	def detachDB(self, dbAlias):
		log.debug("detach %s"%dbAlias)
		sql = 'detach database :alias'
		val = {'alias':dbAlias}
		try:		
			self.cursor.execute(sql, val)
		except sqlite3.Error as e:
			log.exception(e)
			raise NameError(e)

	def copyFromAttachedInsertOrIgnore(self, attachedDbAlias, tableName):
		sql = 'INSERT OR IGNORE INTO {0} SELECT * FROM {1}.{0};'.format(tableName, attachedDbAlias)
		#log.debug(sql)
		try:		
			self.cursor.execute(sql)
		except sqlite3.Error as e:
			log.exception(e)
			raise NameError(e)

	def copyDumpEntriesFromAttachedDB(self, attachedDbAlias):
		log.debug("copyDumpEntriesFromAttachedDB:")
		self.copyFromAttachedInsertOrIgnore(attachedDbAlias,"dumps")	
		self.copyFromAttachedInsertOrIgnore(attachedDbAlias,"dump_data")	

	def copyLogEntriesFromAttachedDB(self, attachedDbAlias):
		log.debug("copyLogEntriesFromAttachedDB:")
		self.copyFromAttachedInsertOrIgnore(attachedDbAlias,"log")	

	def copyStatisticEntriesFromAttachedDB(self, attachedDbAlias):
		try:	
			sqlCopyNull = 'INSERT OR IGNORE INTO measurements (statistic, time) SELECT statistic, time FROM {0}.measurements'.format(attachedDbAlias)
			sqlCopyEntries = 'REPLACE INTO measurements \
				(statistic, time, count, sum, sum2, max, min) \
			SELECT mm.statistic as statistic, \
				mm.time as time, \
				COALESCE((nn.count+mm.count),mm.count) as count , \
				COALESCE((nn.sum+mm.sum),mm.sum) as sum, \
				COALESCE((nn.sum2+mm.sum2),mm.sum2) as sum2 , \
				COALESCE(max(nn.max,mm.max),mm.max) as max , \
				COALESCE(min(nn.min,mm.min),mm.min) as min  \
			FROM {0}.measurements AS mm \
			JOIN measurements AS nn USING(statistic, time)'.format(attachedDbAlias)
			log.debug("sqlCopyNull:")
			self.cursor.execute(sqlCopyNull)
			log.debug("sqlCopyEntries:")
			self.cursor.execute(sqlCopyEntries)
		except sqlite3.Error as e:
			log.exception(e)
			try:
				self.cursor.execute(viewDelete)
			except:
				pass
			raise NameError(e)	
		#log.debug("copyFromAttachedInsertOrIgnore : measurements_single")
		#self.copyFromAttachedInsertOrIgnore(attachedDbAlias,"measurements_single")
		log.debug("copyFromAttachedInsertOrIgnore : histograms")	
		self.copyFromAttachedInsertOrIgnore(attachedDbAlias,"histograms")	
		log.debug("copyStatisticEntriesFromAttachedDB finished")	

	def addTimeDeltaAndAlignValues(self, secondsDelta, logInterval):
		def align(dateTimeObj):
			# align time and add delta
			try:
				oldTime = utcDateTime2timetime(parseSqlDateTime(dateTimeObj))
				part = int((oldTime + secondsDelta) // logInterval)
				newTime = round(float(part) * logInterval, Config.getInt("LIMITS","EQUAL_TIME_MEASUREMENT_PRECISION"))
				return dateTimeString(utcTimetime2datetime(newTime))
			except BaseException as e:
				log.exception(e)
			return dateTimeObj

		def addDelta(dateTimeObj):
			# adds delta
			try:
				oldTime = utcDateTime2timetime(parseSqlDateTime(dateTimeObj))
				newTime = oldTime + secondsDelta
				return dateTimeString(utcTimetime2datetime(newTime))
			except BaseException as e:
				log.exception(e)
			return dateTimeObj

		# modify (add delta) all entries
		sqlTimeAllAddDelta = 'UPDATE {0} SET time = addDelta(time)'

		# align&add "all host statistics"
		sqlTimeAlignAndAddDelta = 'UPDATE {0} SET time = align(time) WHERE statistic IN (SELECT id FROM statistics WHERE node < 0);'
		# add delta for all "host specific statistics"
		sqlTimeAddDelta = 'UPDATE {0} SET time = addDelta(time) WHERE statistic IN (SELECT id FROM statistics WHERE node >= 0);'

		sql = [
		sqlTimeAlignAndAddDelta.format(Models.NodeDatabase.Measurement.getTableName()),
		sqlTimeAddDelta.format(Models.NodeDatabase.Measurement.getTableName()),
		
		#sqlTimeAlignAndAddDelta.format(Models.NodeDatabase.SingleMeasurement.getTableName()),
		#sqlTimeAddDelta.format(Models.NodeDatabase.SingleMeasurement.getTableName()),
		
		sqlTimeAlignAndAddDelta.format(Models.NodeDatabase.Histogram.getTableName()),
		sqlTimeAddDelta.format(Models.NodeDatabase.Histogram.getTableName()),

		sqlTimeAllAddDelta.format(Models.NodeDatabase.Log.getTableName()),
		sqlTimeAllAddDelta.format(Models.NodeDatabase.DumpData.getTableName())
		]

		self.registerFunction("align", 1, align)
		self.registerFunction("addDelta", 1, addDelta)

		for sqlStmt in sql:
			try:		
				self.cursor.execute(sqlStmt)
				self.allSaved = False
			except sqlite3.Error as e:
				log.exception(e)
	
	def setMissingNodeDbValues(self, experiment, node):
		'''
		replace node, experiment information
		'''
		sql = []
		# statistics
		sql.append('UPDATE %s SET node = :node WHERE node >= 0'%Models.NodeDatabase.Statistic.getTableName())
		sql.append('UPDATE %s SET experiment = :experiment'%Models.NodeDatabase.Statistic.getTableName())
		# log
		sql.append('UPDATE %s SET node = :node WHERE node >= 0'%Models.NodeDatabase.Log.getTableName())
		sql.append('UPDATE %s SET experiment = :experiment'%Models.NodeDatabase.Log.getTableName())
		# dump
		sql.append('UPDATE %s SET experiment = :experiment'%Models.NodeDatabase.Dump.getTableName())
		# dumpdata
		sql.append('UPDATE %s SET node = :node WHERE node >= 0'%Models.NodeDatabase.DumpData.getTableName())
		for sqlStmt in sql:
			try:		
				self.cursor.execute(sqlStmt, {'node': node.dbID(), 'experiment': experiment.dbID()})
				self.allSaved = False
			except sqlite3.Error as e:
				log.exception(e)
			
	def replaceDumpIDs(self, transferMap):
		'''
		replace old dump id with new values
		input map: oldID -> newID
		'''
		log.debug("replaceDumpIDs")
		self.replaceIDs(transferMap, self.replaceSingleDumpID)
		log.debug("replaceDumpIDs done")
	
	def replaceStatisticIDs(self, transferMap):
		'''
		replace old statistic id with new values
		input map: oldID -> newID
		'''
		log.debug("replaceStatisticIDs")
		self.replaceIDs(transferMap, self.replaceSingleStatisticID)
		log.debug("replaceStatisticIDs done")
	
	def replaceIDs(self, transferMap, transFnc):
		ununsedID = 1 + max(max(transferMap.values()), max(transferMap.keys())) 
		transferMap = dict(transferMap)
		#log.debug(transferMap)
		for k in list(transferMap.keys()):
			if k == transferMap[k]:
				del(transferMap[k])
		#log.debug(transferMap)
		while (len(transferMap) > 0):
			# find next id
			found = None
			for (oldK,newK) in transferMap.items():
				if not newK in transferMap.keys():
					found = newK
					break
			if found == None:
				randomChoice = random.choice(list(transferMap.keys()))
				ununsedID += 1
				transFnc(randomChoice, ununsedID)
				transferMap[ununsedID] = transferMap[randomChoice]
				del(transferMap[randomChoice])
			else:
				del(transferMap[oldK])
				self.replaceSingleStatisticID(oldK, newK)	
			log.debug("old (%d) > new (%d)"%(oldK, newK))
		
	def replaceSingleDumpID(self, oldID, newID):
		val = {'oldid':oldID, 'newid':newID}
		sql = []
		sql.append('UPDATE %s SET dump = :newid WHERE dump = :oldid'%Models.NodeDatabase.DumpData.getTableName())
		sql.append('UPDATE %s SET id = :newid WHERE id = :oldid'%Models.NodeDatabase.Dump.getTableName())
		for sqlStmt in sql:
			try:		
				self.cursor.execute(sqlStmt, val)
				self.allSaved = False
			except sqlite3.Error as e:
				log.error(e)
				raise

	def replaceSingleStatisticID(self, oldID, newID):
		val = {'oldid':oldID, 'newid':newID}
		sql = ['UPDATE %s SET statistic = :newid WHERE statistic = :oldid'%Models.NodeDatabase.Measurement.getTableName(),
		#'UPDATE %s SET statistic = :newid WHERE statistic = :oldid'%Models.NodeDatabase.SingleMeasurement.getTableName(),
		'UPDATE %s SET statistic = :newid WHERE statistic = :oldid'%Models.NodeDatabase.Histogram.getTableName(),
		'UPDATE %s SET id = :newid WHERE id = :oldid'%Models.NodeDatabase.Statistic.getTableName()]
		for sqlStmt in sql:
			try:		
				self.cursor.execute(sqlStmt, val)
				self.allSaved = False
			except sqlite3.Error as e:
				log.error(e)
				raise
	
	'''
	read objects from db
	'''
	
	def getNodeData(self, experiment):
		return self.getObjects(Models.HostInteraction.NodeData, {'experiment': experiment.name()})
	
	def getPrototypes(self, experiment):
		return self.getObjects(Models.Experiment.Prototype, {'experiment': experiment.name()})

	def getNodeGroupsForExperiment(self, experiment):
		return self.getObjects(Models.Experiment.NodeGroup, {'experiment': experiment.name()})

	def getNodegroupHostRelations(self, experiment):
		return self.getObjects(Models.Experiment.NodegroupHostRelation, {'experiment': experiment.name()})
		
	def getHostsForExperiment(self, experiment):	
		return self.getObjects(Models.Experiment.Host, {'experiment': experiment.dbID()}, specialTable=Models.Experiment.Host.TABLE_EXPERIMENTS)

	def getHost(self, hostID):
		return self.getObject(Models.Experiment.Host, {'id': hostID})
		
	def getHosts(self):
		return self.getObjects(Models.Experiment.Host)

	def getWorkloads(self):
		return self.getObjects(Models.Experiment.Workload)

	def getExperiment(self, expName=None, expId=None):
		if expName != None:
			return self.getObject(Models.Experiment.Experiment, {'name': expName})
		elif expId != None:
			return self.getObject(Models.Experiment.Experiment, {'id': expId})
		else:
			raise ValueError('none parameter given')
	
	def getNodesForHost(self, host):
		return self.getObjects(Models.Experiment.Node, {'host': host.dbID()})
	
	def getNodeEvents(self, node, experiment):
		return self.getObjects(Models.Experiment.NodeEvent, {'experiment': experiment, 'node': node})
		
	def getMeasurement(self, measurement):
		return self.getObject(Models.NodeDatabase.Measurement, {'statistic': measurement.getDB('statistic'), 'time': measurement.getDB('time')})
	
	def getMeasurements(self, bucket=0, statistic=None):
		if statistic == None:
			return self.getObjects(Models.NodeDatabase.Measurement, bucket=bucket)
		else:
			return self.getObjects(Models.NodeDatabase.Measurement, {'statistic': statistic.dbID()}, bucket=bucket)
	
	#def getSingleMeasurements(self, bucket=0, statistic=None):
		#if statistic == None:
			#return self.getObjects(Models.NodeDatabase.SingleMeasurement, bucket=bucket)
		#else:
			#return self.getObjects(Models.NodeDatabase.SingleMeasurement, {'statistic': statistic.dbID()}, bucket=bucket)
	
	def getHistograms(self, bucket=0, statistic=None):
		if statistic == None:
			return self.getObjects(Models.NodeDatabase.Histogram, bucket=bucket)
		else:
			return self.getObjects(Models.NodeDatabase.Histogram, {'statistic': statistic.dbID()}, bucket=bucket)
	
	def getLogs(self, bucket=0, experiment=None):
		if experiment == None:
			return self.getObjects(Models.NodeDatabase.Log, bucket=bucket)
		else:
			return self.getObjects(Models.NodeDatabase.Log, {'experiment': experiment.dbID()}, bucket=bucket)
	
	def getLogFilter(self, bucket=0, experiment=None):
		if experiment == None:
			return self.getObjects(Models.NodeDatabase.LogFilter, bucket=bucket)
		else:
			return self.getObjects(Models.NodeDatabase.LogFilter, {'experiment': experiment.name()}, bucket=bucket)
			
	def getStatistics(self, experiment=None):
		if experiment == None:
			return self.getObjects(Models.NodeDatabase.Statistic)
		else:
			return self.getObjects(Models.NodeDatabase.Statistic, {'experiment': experiment.dbID()})
			
	def getDumps(self, experiment=None):
		if experiment == None:
			return self.getObjects(Models.NodeDatabase.Dump)
		else:
			return self.getObjects(Models.NodeDatabase.Dump, {'experiment': experiment.dbID()})
	
	def getDumpData(self, bucket=0, dump=None):
		if dump == None:
			return self.getObjects(Models.NodeDatabase.DumpData, bucket=bucket)
		else:
			return self.getObjects(Models.NodeDatabase.DumpData, {'dump': dump.dbID()}, bucket=bucket)

	'''
	store objects in db
	'''
	
	def updateExperiment(self, experiment, identKeys, updateKeys):
		self.update(experiment, identKeys, updateKeys)

	def storeStatistic(self, statistic):
		self.replace(statistic)
	
	#def storeSingleMeasurement(self, singleMeasurement):
		#self.replace(singleMeasurement)
	
	def storeMeasurement(self, measurement):
		try:
			self.insert(measurement)
		except BaseException:
			try:		
				# entry exists, so merge
				values = measurement.getAllValues()
				table = measurement.getTableName()
				# count = count + :count, ...
				update = ['{0} = {0} + :{0}'.format(k) for k in ['count','sum','sum2']]
				update.append('{0} = max({0},:{0})'.format('max'))
				update.append('{0} = min({0},:{0})'.format('min'))
				update = ', '.join(update)
				identKeys = ['statistic','time']
				sql = 'UPDATE {0} SET {1} WHERE {2}'.format(table, update, self.buildPlaceholderPairs(identKeys, ' AND '))
				self.cursor.execute(sql, values)
				self.allSaved = False
			except sqlite3.Error as e:
				tb = sys.exc_info()[2]
				if hasattr(BaseException,"with_traceback"):
					raise NameError(e).with_traceback(tb)
				else:
					raise NameError(e)		
	
	def storeHistogram(self, histogram):
		self.replace(histogram)
	
	def storeLog(self, log):
		self.replace(log)
	
	def storeDumpData(self, dumpData):
		self.replace(dumpData)
	
	def storeDump(self, dump):
		self.replace(dump)

	def storeNode(self, node):
		self.insert(node)

	def storeNodeEvent(self, nodeEvent):
		self.insert(nodeEvent)

	def updateExperimentMeasurementsFromEventlist(self, statistic, eventPairs):
		# eventPairs = [(time, inc), ...]
		eventPairs.sort(key=lambda x: x[0])
		akku = 0
		itemCnt = len(eventPairs)
		updates = [] # (t1,t2,c) = update set +c where >=t1 and <t2 
		for i, (time, inc) in enumerate(eventPairs, start=0):
			eventPairs[i] = (time, inc+akku)
			akku += inc
			if i+1 >= itemCnt:
				nextTime = None
			else:
				nextTime = utcTimetime2datetime(eventPairs[i+1][0])
			updates.append((utcTimetime2datetime(time), nextTime, eventPairs[i][1]))

		
		table = Models.NodeDatabase.Measurement.TABLE
		sql = 'UPDATE {0} SET SUM = SUM + :val, SUM2 = (SUM + :val) * (SUM + :val), \
		MIN = SUM + :val, MAX = SUM + :val, COUNT = 1 WHERE statistic = :statistic \
		and time >= :timeStart'.format(table)
		sqlWithEnd = sql + ' and time < :timeEnd'

		values = {'statistic':statistic.dbID()}
		for (t1,t2,c) in updates:
			try:		
				values['val'] = c
				values['timeStart'] = t1
				if t2 == None:
					self.cursor.execute(sql, values)
				else:
					values['timeEnd'] = t2
					self.cursor.execute(sqlWithEnd, values)
				self.allSaved = False
			except sqlite3.Error as e:
				log.exception(e)


	def alignLiveExperimentStatistics(self, statistic):
		try:
			log.debug("alignLiveExperimentStatistics: {0}".format(statistic))
			table = Models.NodeDatabase.Measurement.TABLE
			update = ['{0} = sum'.format(k) for k in ['min','max']]
			update.append('sum2 = sum * sum')
			update.append('count = 1')
			update = ', '.join(update)
			identKeys = ['statistic']	
			sql = 'UPDATE {0} SET {1} WHERE {2}'.format(table, update, self.buildPlaceholderPairs(identKeys, ' AND '))
			self.cursor.execute(sql, {'statistic': statistic.dbID()})
			self.allSaved = False
		except sqlite3.Error as e:
			tb = sys.exc_info()[2]
			if hasattr(BaseException,"with_traceback"):
				raise NameError(e).with_traceback(tb)
			else:
				raise NameError(e)
	