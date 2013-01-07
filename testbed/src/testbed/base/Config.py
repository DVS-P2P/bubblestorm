#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import logging, os

try:
	import configparser as configparser
except ImportError:
	import ConfigParser as configparser
	
log = logging.getLogger(__name__)

class Config(object):

	def __init__(self):
		pass
	
	@classmethod	
	def load(self, path, isDefaultConfig=False):
		self.config = configparser.ConfigParser()
		self.config.read(path)
		result = self.check(isDefaultConfig)
		if not result[0]:
			log.error(result[1])
			# load default
			defaultPath = os.path.abspath('{0}{1}..{1}scripts{1}config.ini'.format(os.path.dirname(__file__), os.sep))
			log.info("load default config")
			if defaultPath == path:
				log.error('default config has some errors')
				return
			self.load(defaultPath, True)

	@classmethod
	def get(self, section, key):
		return self.config.get(section,str(key).lower())

	@classmethod
	def getBool(self, section, key):
		return self.config.getboolean(section, str(key).lower())

	@classmethod
	def getInt(self, section, key):
		return self.config.getint(section, str(key).lower())

	@classmethod
	def check(self, isDefaultConfig):
		try:
			expectInt = {'TIMEOUTS': ["THINCLIENT_QUIT_SIGNAL_BEFORE_KILL","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL_EXPERIMENT_END",
			"THINCLIENT_RECEIVE_EXPERIMENT_STOP_SHUTDOWNTIME","THINCLIENT_POLL_NODE_STATUS","THINCLIENT_RUNNING_THREADS_POLL_INT",
			"THINCLIENT_WAIT_UNTIL_START_EXP","SSH_CHECK_CONNECTION","SSH_EXEC_CMDS","SSH_TRANSFER_FILES"], 'LIMITS': ['MAX_NODES_PER_HOST',
			'WORKER_THREADS','MAX_ADRESSES_ALIAS','MAX_SEED_INT','SQLITE_STATS_BUCKET','EQUAL_TIME_MEASUREMENT_PRECISION','START_EXPERIMENT_LEADTIME_SECONDS']}
			for section in expectInt:
				for k in expectInt[section]:
					self.getInt(section,k)
			expectStr = {'TIMEOUTS': ["SSH_MASTER_CONNECTION_PERSIST"]}
			for section in expectStr:
				for k in expectStr[section]:
					self.get(section,k)
			expectBool = {'FLAGS': ['COLLECT_PROTOTYPE_STDOUT_AFTER_EXPERIMENT','SSH_DEBUG_OUTPUT','SSH_HOST_KEY_CHECKING','SSH_USE_MASTER_CONNECTION']}
			for section in expectBool:
				for k in expectBool[section]:
					self.getBool(section,k)
		except BaseException as e:
			if isDefaultConfig:
				msg = 'default config has some errors'
				log.exception(e)
			else:
				msg = 'config file has some error: section:"'+section+'" key:"'+k+'" -- load default values'
			return (False, msg)
		return (True,None)

