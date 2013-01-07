#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import logging

from ..base import Utils
from ..base.Constants import *

from .Base import *

log = logging.getLogger(__name__)

'''
contains all nodeDB models
'''

class DBObjectWithTime(DB_Obj):
	
	def checkTimeValue(self):
		if (type(self.getDB('time')) is datetime.datetime):
			log.error('indirect casting from datetime to str')
			self.setTime(self.getDB('time'))
		
	def getTime(self):
		if not hasattr(self, "time"):
			self.time = Utils.parseSqlDateTime(self.getDB('time'))
		return self.time
		
	def setTime(self, newTime, isUTC=False):
		if (isUTC):
			self.time = Utils.timetime2datetime(newTime)
		else:
			self.time = Utils.utcTimetime2datetime(newTime)
		self.setDB('time', Utils.dateTimeString(self.time))
		self.updateIdentName()
	

class Measurement(DBObjectWithTime):
	'''
	a measurment
	'''
	
	FIELDS = ['statistic', 'time', 'count', 'min', 'max', 'sum', 'sum2']
	TABLE = 'measurements'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.checkTimeValue()
		self.updateIdentName()
			
	def updateIdentName(self):
		if __debug__:
			self.identName = 'Measurement statistic:{0}, time:{1}, count:{2}, min:{3}, max:{4}, sum:{4}, sum2:{6}'.format(
				self.getDB('statistic'), self.getDB('time'), self.getDB('count'), self.getDB('min'), self.getDB('max'), 
				self.getDB('sum'), self.getDB('sum2') )
	
	def statisticID(self):
		return self.getDB('statistic')
	
	def setStatisticID(self, newID):
		self.setDB('statistic', newID)
		self.updateIdentName()
		

#class SingleMeasurement(DBObjectWithTime):
#	'''
#	a singlemeasuremnt
#	'''
#	
#	FIELDS = ['statistic', 'value', 'time']
#	TABLE = 'measurements_single'
#	
#	def __init__(self, valuesDict):
#		for key in self.FIELDS:
#			self.setDB(key, valuesDict[key])
#		self.checkTimeValue()
#		self.updateIdentName()
#	
#	def updateIdentName(self):
#		if __debug__:
#			self.identName = 'SingleMeasurement statistic:{0}, value:{1}, time:{2}'.format(self.getDB('statistic'), 
#				self.getDB('value'), self.getDB('time'))
#			
#	def statisticID(self):
#		return self.getDB('statistic')
#	
#	def setStatisticID(self, newID):
#		self.setDB('statistic', newID)
#		self.updateIdentName()
#		

class Histogram(DBObjectWithTime):
	'''
	a histogram
	'''
	
	FIELDS = ['statistic', 'time', 'bucket', 'width', 'count']
	TABLE = 'histograms'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.checkTimeValue()
		self.updateIdentName()

	def updateIdentName(self):
		if __debug__:
			self.identName = 'Histogram statistic:{0}, time:{1}, bucket:{2}, width:{3}, count:{4}'.format(self.getDB('statistic'), 
				self.getDB('time'), self.getDB('bucket'), self.getDB('width'), self.getDB('count'))
			
	def statisticID(self):
		return self.getDB('statistic')
	
	def setStatisticID(self, newID):
		self.setDB('statistic', newID)
		self.updateIdentName()
		

class Statistic(DB_Obj):
	'''
	a statistic
	'''
	
	FIELDS = ['id', 'experiment', 'name', 'units', 'label', 'node', 'type']
	TABLE = 'statistics'

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.updateIdentName()
		
	def updateIdentName(self):
		if __debug__:
			self.identName = 'Statistic id:{0} name:{1} experiment:{2} node:{3}'.format(self.dbID(), self.getDB('name'), 
				self.getDB('experiment'), self.getDB('node'))
		
	def isSame(self, other):
		return (self.getDB('name') == other.getDB('name') and
				self.getDB('experiment') == other.getDB('experiment') and
				self.getDB('node') == other.getDB('node'))
		
	def isSingleNode(self):
		return -1 != self.getDB('node')
		
	def setID(self, newID):
		self.setDB('id', newID)
		self.updateIdentName()
	
	def getName(self):
		return self.getDB('name')

	def setNode(self, node):
		if node == None:
			self.setDB('node', -1)
		else:
			self.setDB('node', node.dbID())
		self.updateIdentName()
	
	def setExperiment(self, experiment):
		self.setDB('experiment', experiment.dbID())
		self.updateIdentName()
	
	def isLiveExperimentStatistic(self):
		if STATISTIC.hasValue(self.getDB('name')):
			return True
		else:
			return False
			

class Log(DBObjectWithTime):
	'''
	a log entry
	'''
	
	FIELDS = ['experiment', 'node', 'ip', 'time', 'level', 'module', 'message']
	TABLE = 'log'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.checkTimeValue()
		self.updateIdentName()

	def updateIdentName(self):
		if __debug__:
			self.identName = 'Log experiment:{0}, node:{1}, ip:{2}, time:{3}, level:{4}, module:{5}, message:{6}'.format(self.getDB('experiment'), 
				self.getDB('node'), self.getDB('ip'), self.getDB('time'), self.getDB('level'), self.getDB('module'), self.getDB('message'))
	
	def setExperiment(self, experiment):
		self.setDB('experiment', experiment.dbID())
		self.updateIdentName()
		
	def setNode(self, node):
		if node == None:
			self.setDB('node', -1)
		else:
			self.setDB('node', node.dbID())
		self.updateIdentName()
			

class LogFilter(DB_Obj):
	'''
	a logfilter entry
	'''
	
	FIELDS = ['experiment', 'module', 'level']
	TABLE = 'log_filters'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.updateIdentName()

	def getLevel(self):
		return int(self.getDB("level"))

	def getModule(self):
		return self.getDB("module")

	def updateIdentName(self):
		if __debug__:
			self.identName = 'LogFilter experiment:{0}, module:{1}, level:{2}'.format(self.getDB('experiment'), 
				self.getDB('module'), self.getDB('level'))
	
	def setExperiment(self, experiment):
		self.setDB('experiment', experiment.name())
		self.updateIdentName()
			

class Dump(DB_Obj):
	'''
	a dumpp entry
	'''

	FIELDS = ['id', 'experiment', 'name', 'prefix', 'suffix']
	TABLE = 'dumps'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.updateIdentName()
		
	def updateIdentName(self):
		if __debug__:
			self.identName = 'Dump id:{0}, experiment:{1}, name:{2}, prefix:{3}, suffix:{4}'.format(self.getDB('id'),
				self.getDB('experiment'), self.getDB('name'), self.getDB('prefix'), self.getDB('suffix'))
	
	def setExperiment(self, experiment):
		self.setDB('experiment', experiment.dbID())
		self.updateIdentName()
		
	def setID(self, newID):
		self.setDB('id', newID)
		self.updateIdentName()
		
	def isSame(self, other):
		return (self.getDB('experiment') == other.getDB('experiment') and
				self.getDB('name') == other.getDB('name') and
				self.getDB('suffix') == other.getDB('suffix') and
				self.getDB('prefix') == other.getDB('prefix'))
			

class DumpData(DBObjectWithTime):
	'''
	a dumpdata entry
	'''

	FIELDS = ['dump', 'time', 'node', 'text']
	TABLE = 'dump_data'
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
		self.checkTimeValue()
		self.updateIdentName()

	def updateIdentName(self):
		if __debug__:
			self.identName = 'DumpData dump:{0}, time:{1}, node:{2}, text:{3}'.format(self.getDB('dump'),self.getDB('time'), 
				self.getDB('node'), self.getDB('text'))
	
	def setDumpID(self, dumpID):
		self.setDB('dump', dumpID)
		self.updateIdentName()
		
	def dumpID(self):
		return self.getDB('dump')
	
	def setNode(self, node):
		self.setDB('node', node.dbID())
		self.updateIdentName()