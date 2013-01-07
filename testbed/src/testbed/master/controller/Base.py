#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *
from ...base.SubProc import SubProc

from .HostController import HostController
from .Monitoring import Monitoring

import os
import logging
log = logging.getLogger(__name__)

class ChangeState(BaseException):
	
	def __init__(self, newState):
		self.state = newState
	
	def getState(self):
		return self.state

class Controller(object):

	def __init__(self, master):
		self.master = master
		self.experiment = self.master.experiment
		self.dbController = self.master.dbController
		self.basePath = self.master.basePath
		self.cwdPath = self.master.cwdPath
		self.scriptsPath = self.master.scriptsPath
		self.properties = self.master.properties
	
	def process(self):
		raise NotImplementedError()
		
	def stopMaster(self):
		'''
		stops workerpool, send quit
		'''
		log.info('stop master\nclear worker queue...')
		WorkerPool().clear()
		SubProc.killAllProcesses()
		log.info('quit')
		quit()
	
	def removeHosts(self, hosts):
		'''
		removes host from experiment
		'''
		for h in hosts:
			try:
				self.experiment.hostGroup.remove(h)
			except BaseException:
				log.error(h)
			
	def processJobs(self, hosts, function, desc, optionalObjects=None, onFailAskUser=True, onInterruptReturnRemainingAsFailed=False):
		'''
		creates a job queue, process all hosts		
		'''
		pool = WorkerPool()
		digits = len(str(len(hosts)))
		lock = WorkerPool.newLock()
		results = {'ok':0, 'okHosts': [], 'fail':0, 'logs': [], 'failedHosts': []}
		try:
			for host in hosts:
				job = PoolJob(host, self.experiment, self.basePath, self.cwdPath, self.scriptsPath, results, lock, HostController, function)
				if optionalObjects != None:
					for (k,v) in optionalObjects.items():
					    job.add(k,v)
				pool.addJob(job)
			pool.wait(True, lambda: "... processing {0}: Waiting: {1}, OK: {2}, Failed: {3} ".format(
									desc,
									str((len(hosts)-results["fail"]-results["ok"])).zfill(digits),
									str(results["ok"]).zfill(digits),
									str(results["fail"]).zfill(digits)))

			if onFailAskUser:
				while len(results['failedHosts']) > 0:
					input = askUserOption('{0} failed: (r)etry, (l)ist failed, (i)gnore'.format(len(results['failedHosts'])), 
						['r','l','i'], 'r', 'i')
					if input == 'r':
						results = self.processJobs(results['failedHosts'], function, desc, optionalObjects=optionalObjects, onFailAskUser=False)
					elif input == 'l':
						for index,host in enumerate(results['failedHosts']):
							print('\thost: {0}; {1}'.format(host,results['logs'][index]))
					elif input == 'i':
						break
		except KeyboardInterrupt as e:	
			if onInterruptReturnRemainingAsFailed:
				print('KeyboardInterrupt by user')		
				remaining = WorkerPool().clearAndReturnAllRemaining()
				SubProc.killAllProcesses()
				with lock:
					for job in remaining:
						results['fail'] += 1
						results['failedHosts'].append(job.data.host)
						results['logs'].append('KeyboardInterrupt by user')
					for host in hosts:
						if (not(host in results['failedHosts']) and not(host in results['okHosts'])):
							results['fail'] += 1
							results['failedHosts'].append(host)
							results['logs'].append('KeyboardInterrupt by user') 
			else:
				raise
		return results
	
