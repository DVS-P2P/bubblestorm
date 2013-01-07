#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import logging

from ..base import Utils
from ..base.Constants import *

from .Base import *

log = logging.getLogger(__name__)

class CopyDataWrapper(DB_Obj):
	'''
	file/folder wrapper
	'''

	def checkLocalFileAccess(self):
		for path in glob.glob(self.path()):
			if not os.path.exists(path):
				log.error("cant access file: %s", path)
				quit(1)

	def checkTarget(self):
		if self.targetSubDir() != None and self.targetSubDir()[0] == '/':
			log.error('subfolder should be relative; %s',self.getDB('target_sub_dir'))
			quit(1)
		if self.isRecursive() == True and self.targetPath()!=None:
			log.error('combination: recursiveCopy + targetPath; not allowed')
			quit(1)

	def path(self):
		return self.getDB('path')
		
	def targetPath(self):
		return self.getDB('target_file_name')
		
	def targetSubDir(self):
		return self.getDB('target_sub_dir')
		
	def isRecursive(self):
		return self.getDB('recursive') == True
	
	def isNodegroupData(self):
		return False
		
	def isPrototypeData(self):
		return False
	
class PrototypeData(CopyDataWrapper):
	'''
	a prototype file/folder, i.e. bin, libfolder, datafolder
	'''

	FIELDS = ['path', 'target_sub_dir', 'recursive', 'target_file_name']
	
	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
			
		self.identName = 'PrototypeData "{0}"'.format(self.getDB('path'))
		self.checkTarget()
		self.checkLocalFileAccess()
		
	def isPrototypeData(self):
		return True
		
	def setPrototypeID(self, prototypeID):
		self.prototypeID = prototypeID
	
	def getPrototypeID(self):
		return self.prototypeID
	


class ExperimentData(CopyDataWrapper):
	'''
	a experiment file/folder, i.e. liveexp/*.py, exp_database, ...
	'''
	
	FIELDS = ['path', 'target_sub_dir', 'recursive', 'target_file_name']

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])
			
		self.identName = 'ExperimentData "{0}"'.format(self.getDB('path'))
		self.checkTarget()
		self.checkLocalFileAccess()

class NodeData(CopyDataWrapper):
	'''
	a node data file/folder, i.e. protoype_config_files, keyValueTestFile, ...
	'''
	
	FIELDS = ['id', 'path', 'target_sub_dir', 'recursive', 'node_group', 'target_file_name']
	TABLE = 'node_data_view'

	def __init__(self, valuesDict):
		for key in self.FIELDS:
			self.setDB(key, valuesDict[key])

		self.identName = 'NodeData "{0}"'.format(self.getDB('path'))
		self.checkTarget()
		self.checkLocalFileAccess()
	
	def isNodegroupData(self):
		return True
		
	def matchNodeGroup(self, nodeGroup):
		return 	(self.getDB('node_group') == None or
				self.getDB('node_group') == nodeGroup.dbID())
	
	def nodeGroupID(self):
		return self.getDB('node_group')