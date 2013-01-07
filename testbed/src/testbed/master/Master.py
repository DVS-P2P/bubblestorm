#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import os

from ..base.Constants import *
from ..base.Database import *
from ..base.Utils import *
from ..base import Utils
from ..base.Config import Config

from .controller.HostController import HostController
from .NodePlacement import NodePlacement
from .NodeactivitySimulation import NodeactivitySimulation

from . import controller as Controller

log = logging.getLogger(__name__)

class TestbedMasterController(object):
	'''
	manages the master
		- controls program flow, called by main
		- runs on master workstation
	'''

	def __init__(self, verbose, experiment, database, debug, config):
		self.properties = type('properties',(object,),
			{	"verbose": verbose, 
				"experiment": experiment,
				"database": database, 
				"debug": debug,
				"config": config})
					
		self.configure()

	def configure(self):
		'''
		confg stuff
		'''		
		Config.load(self.properties.config)
		self.dbController = DatabaseController(self.properties.database)
		self.basePath = os.path.abspath('{0}{1}..{1}'.format(os.path.dirname(Utils.__file__), os.sep))
		self.cwdPath = os.path.abspath(os.path.dirname(os.path.realpath(self.properties.database)))
		self.scriptsPath = os.path.abspath(os.path.join(self.basePath, 'scripts'))
		log.debug("cwdPath: %s"%self.cwdPath)
		log.debug("basePath: %s"%self.basePath)
		log.debug("scriptsPath: %s"%self.scriptsPath)

	def start(self):
		'''
		determine program state: resume, stop, start
		'''
		try:
			
			log.info('Reading experiment "{0}" from database.'.format(self.properties.experiment))
			# load experiment, nodeGroups, hosts, workloads, prototype data
			try:
				self.experiment = self.dbController.getExperiment(expName=self.properties.experiment)
			except BaseException as e:
				print("##############")
				log.error("cant find experiment: %", self.properties.experiment)
				log.exception(e)
				print("______________")
				quit(1)
			
			check = self.dbController.oldDataExists(self.experiment)
			
			if check:
				log.info('Old data found:')
				input = askUserOption('(r)esume experiment, (stop) experiment, (del)ete old experiment data [db, only local], remove ALL data from hosts (cleanup), (q)uit', 
					['r','stop','del','q','cleanup'], 'r', 'q')
				if input == 'r':
					log.info('resume old experiment')
					self.currentState = Controller.StateResume
				elif input == 'stop':
					log.info('stop old experiment')
					self.currentState = Controller.StateStop
				elif input == 'del':
					log.info('delete old experiment data (only local)')
					self.dbController.cleanDB(self.experiment)
					self.currentState = Controller.StateStart
				elif input == 'cleanup':
					log.info('remove ALL data from hosts')
					self.currentState = Controller.StateCleanup
				elif input == 'q':
					log.info('quit')
					quit()
			else:
				self.currentState = Controller.StateStart

			self.processState()
				
		except NameError as e:
			log.exception(e)
			quit(1)
		
	'''
	States: Start, Stop, Cleanup, Resume
	'''
	
	def processState(self):
		while self.currentState != None:
			log.info("current state: %s"%self.currentState)
			self.stateController = self.currentState(self)
			try:
				self.stateController.process()
				self.currentState = None
			except Controller.Base.ChangeState as changeState:
				self.currentState = changeState.getState()
	
