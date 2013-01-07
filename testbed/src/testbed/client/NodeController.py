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
import sqlite3
import stat
import sys
import threading
import time
import traceback

from pipes import quote

from ..base import Utils
from ..base.SubProc import SSH, SubProc, NodeProc
from ..base.Constants import *
from ..base.Utils import NTP, Random
from ..base.Config import Config
from ..base.Database import *

log = logging.getLogger(__name__)


class NodeController(threading.Thread):
	'''
	a node controller processes all node events
	'''

	running_threads = 0
	running_threads_lock = threading.Lock()
	
	def __init__(self, node, nodeGroup, path, events, name, experimentDuration, prototype, logLevelFilter=None):
		threading.Thread.__init__(self, name=name) 
		self.node = node
		self.nodeGroup = nodeGroup
		self.path = path
		self.events = events
		self.allEvents = list(events)
		self.prototype = prototype
		self.experimentDuration = experimentDuration
		self.logLevelFilter = logLevelFilter
		
		self.proc = None
		self.currentState = False
		
		self.startUpCount = 0
		self.stdOut = None
		self.stdErr = None
		self.pipesReady = False
		
		self.statistics = [] # list of (timestamp, event)
		self.logs = [] # list of (timestamp, level, message)

		self.experimentIsFinished = False
		
		#log.debug("{0}: created with {1} event(s)".format(self.name, len(self.events)))
	
	
	def addStatistic(self, event, t=None):
		assert STATISTIC.hasValue(event)
		if t == None:
			t = time.time()
		self.statistics.append((t, event))

	def addLog(self, level, message):
		if (self.logLevelFilter != None) and (self.logLevelFilter >= level):
			self.logs.append((time.time(), level, message))

		
	def run(self): 
		'''
		prototype controller main: event loop
		'''
		expTime = 0
		realTimeStart = time.time()
		
		log.info("{0}: started work".format(self.name))
		
		while len(self.events) > 0:
			if NodeController.abortExperiment.is_set():
				self.abortExperimentAction()
				return
			realTime = time.time()
			expTime = realTime-realTimeStart
			(eventTime, event) = self.events.pop(0)
			
			if self.currentState:
				# proc is running, so observe status
				sleepTime = eventTime - expTime
				self.observeRunningPrototype(sleepTime)
				t2 = time.time() - realTime
				realTime += t2
				expTime += t2			
			
			sleepTime = eventTime - expTime
			while sleepTime > 0:
				log.info("{0}: wait for next event, sleepTime: {1}".format(self.name, sleepTime))
				time.sleep(sleepTime)
				t2 = time.time() - realTime
				realTime += t2
				expTime += t2	
				sleepTime = eventTime - expTime

			if NodeController.abortExperiment.is_set():
				self.abortExperimentAction()
				return
		
			log.info('\tnode:{0} event:{1}'.format(self.node.dbID(), event))
			
			self.addStatistic(STATISTIC.NODE_EVENT_EXECUTED_EVENTS)			
			if event.isStart():
				self.addLog(0,"execute event: start node")
				self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
				self.startProc(event)
			elif event.isCrash() or event.isQuit():
				if not self.currentState:
					# node is crashed before that event, ignore event
					log.info('\tnode:{0} event:{1} node already down')
				else:
					timeOut = 1
					if event.isQuit():
						self.sendSignal(EVENT_SIGNALS.QUIT)
						if len(self.events) > 0:
							(nextEventTime, _) = self.events[0]
							# timeout min(time before next event, normal timeout, time until experiment ends)
							timeOut = min(nextEventTime - eventTime, 
								Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL"),
								 self.experimentDuration - eventTime)
							# timeout = max(recent value, timeout for quit events after experiment ended)
							timeOut = max(timeOut, Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL_EXPERIMENT_END"))
							self.addLog(0,"execute event: stop node, timeout: {0}".format(timeOut))
							self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
							self.quitProc(timeOut, addStatistic=True)
						else:
							# timeout = min(time until experiment ends, normal timeout)
							timeOut = min(self.experimentDuration - eventTime, Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL"))
							# timeout = max(recent value, timeout for quit events after experiment ended)
							timeOut = max(timeOut, Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL_EXPERIMENT_END"))
							self.addLog(0,"execute event: stop node, timeout: {0}".format(timeOut))
							self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
							self.quitProc(timeOut, addStatistic=True)
					else:
						self.addLog(0,"execute event: crash node")
						self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
						self.addStatistic(STATISTIC.NODE_EVENT_CRASHES)
						self.terminateProc()
					self.closeStdFiles()
			elif event.isUsrSig1():
				self.addLog(0,"execute event: send usrSig1")
				self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
				self.sendSignal(SIGNALS.SIGUSR1)
			elif event.isUsrSig2():
				self.addLog(0,"execute event: send usrSig2")
				self.addLog(2,"eventtime, expected/actual: {0}/{1}".format(eventTime,(time.time()-realTimeStart)))
				self.sendSignal(SIGNALS.SIGUSR2)
			else:
				self.internalNodeControllerError('unkown event type: {0}'.format(event))
			# set new experimentTime
			# simple solution: expTime = eventTime
			expTime += (time.time() - realTime)
		
		if self.currentState and expTime < self.experimentDuration and not(NodeController.abortExperiment.is_set()):
			log.info("{0}: no further events, but still running, so check pipes".format(self.name))
			t1 = time.time()
			self.observeRunningPrototype(self.experimentDuration-expTime)
			t2 = (time.time()-t1)
			expTime += t2	
		
		if not Config.getBool("FLAGS","COLLECT_PROTOTYPE_STDOUT_AFTER_EXPERIMENT"):
			self.closeStdFiles()
		
		if expTime > self.experimentDuration:
			self.experimentIsFinished = True
		
		if self.isRunning() == True:
			timeout = Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL_EXPERIMENT_END")
			log.info("{0}: experiment over, send quit (kill timeout = {1} sec)".format(self.name,timeout))
			self.addLog(0,"experiment over, node is running, send quit")
			self.quitProc(timeout)
		
		if Config.getBool("FLAGS","COLLECT_PROTOTYPE_STDOUT_AFTER_EXPERIMENT"):
			self.closeStdFiles()
		
		self.addLog(1,"finished work, shutdown controller, startup cnt: {0}".format(self.startUpCount))
			
		with NodeController.running_threads_lock:
			NodeController.running_threads -= 1
		log.info("{0}: finished work".format(self.name))
		
			
	def abortExperimentAction(self):
		log.info('receive abortExperiment, node:{0}'.format(self.nodeID()))
		if self.proc != None:
			self.terminateProc()
	
	'''
	public controller interface
	'''
	
	def nodeID(self):
		return self.node.dbID()
		
	def isRunning(self):
		return self.proc != None and self.proc.isRunning()
	
	def getControllerStatistics(self):
		self.statistics.sort(key=lambda x: x[0])

		# check values
		cnt = 0
		cntShould = 0
		for (_,e) in self.statistics:
			if (e == STATISTIC.NODE_EVENT_JOINS):
				cnt += 1
			elif (e == STATISTIC.NODE_EVENT_LEAVE_TIMEOUTS or e == STATISTIC.NODE_EVENT_CRASHES or e == STATISTIC.NODE_EVENT_LEAVES):
				cnt -= 1
		for (_,e) in self.allEvents:
			if e.isStart():
				cntShould += 1
			elif e.isCrash() or e.isQuit():
				cntShould -= 1
		if cnt != cntShould:
			log.error("error detected: {0} != {1}".format(cnt,cntShould))
			log.error(repr(self.statistics))

		return list(self.statistics)
	
	def getControllerLogs(self):
		self.logs.sort(key=lambda x: x[0])
		return list(self.logs)
		
	def getNodeDatabases(self):
		out = [os.path.join(self.path,PATHS.NODE_DATABASE)]
		return out
		
	
	'''
	controls subproc
	'''
	
	def observeRunningPrototype(self, maxTime):
		'''
		polls prototype state
		'''
		pollTimeout = Config.getInt("TIMEOUTS","THINCLIENT_POLL_NODE_STATUS")
		t1 = time.time()
		while (maxTime - (time.time()-t1)) > pollTimeout:
			time.sleep(pollTimeout)
			if not self.isRunning():
				self.currentState = False
				self.addLog(0,"node crashed, return code: {0}".format(repr(self.proc.getReturnCode())))
				self.addStatistic(STATISTIC.NODE_EVENT_CRASHES)
				self.closeStdFiles()
				log.info('{0}: crashed node, return code: {1}'.format(self.name, repr(self.proc.getReturnCode())))
				return


	def internalNodeControllerError(self, error):
		'''
		logs error
		'''
		log.error('{0}: internal error'.format(self.name))
		log.exception(error)
		
	def closeStdFiles(self):
		'''
		close file descriptor
		'''
		self.pipesReady = False
		try:
			if self.stdOut != None:
				self.stdOut.close()
			if self.stdErr != None:
				self.stdErr.close()
		except IOError as e:
			self.internalNodeControllerError('closeStdFiles error: {0}'.format(e))
		
	def prepareStdFiles(self):
		'''
		prepare std (out|err) files
		'''
		pipesStdOut = os.path.join(self.path,PATHS.THINCLIENT_NODE_STDOUT_FILE).format(self.startUpCount)
		pipesStdErr = os.path.join(self.path,PATHS.THINCLIENT_NODE_STDERR_FILE).format(self.startUpCount)
		self.pipesReady = False
		try:
			self.closeStdFiles()
			self.stdOut = open(pipesStdOut, 'wb')
			self.stdErr = open(pipesStdErr, 'wb')
		except IOError as e:
			self.internalNodeControllerError('prepareStdFiles error: {0}'.format(e))
		self.pipesReady = True
	
	def startProc(self, event):
		'''
		start prototype event
		'''
		log.info('\tstartProc, node:{0}'.format(self.nodeID()))
		
		if self.currentState:
			self.internalNodeControllerError('startProc called, but currentState is running!, node:{0}'.format(self.nodeID()))
			self.terminateProc()
		
		self.currentState = True
		self.startUpCount += 1
		self.prepareStdFiles()
		
		libPath = self.prototype.libraryPath
		try: 
			libPath = '{0}:{1}'.format(os.environ["LD_LIBRARY_PATH"],libPath)
		except KeyError:
			pass
		
		command = 'nice'
		env = {'LD_LIBRARY_PATH': libPath}
		
		cwd = self.path
		
		arguments = ['-n', '+20']
		eventArgs = list(event.arguments())
		
		if eventArgs[0] != self.prototype.command():
			self.internalNodeControllerError('event prototype command != nodegroup prototype command, node:{0}'.format(self.nodeID()))
		
		arguments.append('./{0}'.format(eventArgs.pop(0)))
		arguments.extend(eventArgs)
	
		self.addLog(2,"start node, args: {0}".format(repr(arguments)))

		try:
			self.addStatistic(STATISTIC.NODE_EVENT_JOINS)
			self.proc = NodeProc(cmd=command, args=arguments, customEnv=env, cwd=cwd, stdout=self.stdOut, stderr=self.stdErr)
		except BaseException as e:
			self.addStatistic(STATISTIC.NODE_EVENT_CRASHES)
			self.internalNodeControllerError('{0}: startProc error: {1}'.format(self.name, e))
			self.currentState = False
		
		if self.currentState and self.isRunning() == False:
			self.addStatistic(STATISTIC.NODE_EVENT_CRASHES)
			self.stdErr.write('{0}: startProc error, return code:{1}'.format(self.name, self.proc.getReturnCode()).encode('utf-8'))
			self.currentState = False
	
	
		
	def quitProc(self, timeOut=Config.getInt("TIMEOUTS","THINCLIENT_QUIT_SIGNAL_BEFORE_KILL"), addStatistic=False):
		'''
		quit prototype event
		'''
		log.info('\tquitProc, node:{0}'.format(self.nodeID()))
		t1 = time.time()
		while self.isRunning():
			t2 = time.time() - t1
			if t2 > timeOut:
				log.info('\tquitProc: timeout reached->kill, node:{0}'.format(self.nodeID()))
				if addStatistic:
					self.addStatistic(STATISTIC.NODE_EVENT_LEAVE_TIMEOUTS)
				self.addLog(0,"quit node timeout reached, terminate node")
				self.terminateProc()
				return			
			time.sleep(5)
		self.currentState = False
		if addStatistic:
			self.addStatistic(STATISTIC.NODE_EVENT_LEAVES, t1)
	
	def terminateProc(self):
		'''
		send term signal to prototype
		'''
		log.info('\tterminateProc, node:{0}'.format(self.nodeID()))
		while self.isRunning():
			self.sendSignal(SIGNALS.SIGKILL)
			time.sleep(1)
		self.currentState = False
	
	def sendSignal(self, signal):
		'''
		send signal 
		'''
		log.info('\tsendSignal, node:{0}, signal:{1}'.format(self.nodeID(), signal))
		self.addLog(0,'send signal: {0}'.format(signal))
		try:
			self.proc.sendSignal(signal)
		except BaseException as e:
			self.internalNodeControllerError("\texception during send signal, node{0}, signal:{1} error:{2}".format(self.name, signal, e))


