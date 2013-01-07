#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import glob
import json
import logging
import os
import pdb
import shlex
import sys
import time

from ..base import Utils
from ..base.Constants import *

log = logging.getLogger(__name__)

class DB_Obj(object):
	'''
	basic db object, represent one row of table x
	
	easy getter/setter for db object
	no auto write-through
	'''

	identName = '"none idetifier set"'

	def getDB(self, key):
		assert(key in self.FIELDS)
		return self.dbValues[key]

	def setDB(self, key, value):
		assert(key in self.FIELDS)
		if not(hasattr(self, 'dbValues')):
			self.dbValues = {}
		#if __debug__:
		#	obj = self.identName if self.identName!=None else self
		#	log.info('Object "{0}" stores new value for key "{1}": {2}'.format(obj, key, value))
		self.dbValues[key] = value
	
	def getAllValues(self):
		return self.dbValues
		
	@classmethod
	def getTableName(self):
		return self.TABLE

	def dbID(self):
		return self.getDB('id')

	def __repr__(self):
		return str(self.identName)
	
	def __copy__(self):
		newObj = object.__new__(type(self))
		newObj.__dict__ = self.__dict__.copy()
		newObj.dbValues = self.dbValues.copy()
		return newObj