#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from ... import models as Models

from .Base import *
from .PreProcessing import PreProcessing
from .Monitoring import Monitoring

from .StateResume import StateResume

log = logging.getLogger(__name__)

class StateStart(Controller):

	def process(self):
		# load exp from db
		for nodeGroup in self.dbController.getNodeGroupsForExperiment(self.experiment):
			self.experiment.addNodeGroup(nodeGroup)
		for host in self.dbController.getHosts():
			if host.getNodePlaces() > 0:
				self.experiment.addHost(host)
		for workload in self.dbController.getWorkloads():
			self.experiment.addWorkload(workload)
		for nodeData in self.dbController.getNodeData(self.experiment):
			self.experiment.addNodeData(nodeData)
		for prototype in self.dbController.getPrototypes(self.experiment):
			prototype.processFiles()
			self.experiment.addPrototype(prototype)
		for nodegroupHostRelation in self.dbController.getNodegroupHostRelations(self.experiment):
			self.experiment.addNodegroupHostRelation(nodegroupHostRelation)
			
		# init random seed
		Random.setSeed(int(self.experiment.getDB("seed")))
		
		self.specifyClientExperimentFiles()


		
		experiment = self.experiment
		
		try:
			try:
				experiment.checkObjects()
			except Exception as e:
				log.exception(e)
				quit(1)
			
			# check experiment size (# nodes)
			message = 'Average number of online nodes = {0}, number of fixed nodes = {1}, effective number of nodes = {2}'
			log.info(message.format(experiment.getDB("size"), experiment.getFixedNodesCount(),
											experiment.effectiveTotalNodeSize()))
			print(message.format(experiment.getDB("size"), experiment.getFixedNodesCount(),
											experiment.effectiveTotalNodeSize()))
			# process workload
			PreProcessing.processWorkload(state=self)
			
			# check hosts
			# check ssh connection
			# inspect hosts
			checkingHosts = True
			hosts = self.experiment.getHosts()
			log.debug("%d hosts in list"%len(hosts))
			while checkingHosts:
				results = Monitoring.inspectHosts(state=self, hosts=hosts)
				if 0 < len(results['failedHosts']):
					while True:
						input = askUserOption('(l)ist failed Hosts, (r)etry, (a)bort, (c)ontinue', ['r','a','c', 'l'], 'c', 'a')
						if input == 'r':
							break
						elif input == 'c':
							failedHosts = results['failedHosts']
							log.debug("continue and remove failed hosts (%d)"%len(failedHosts))
							self.removeHosts(failedHosts)
							checkingHosts = False
							break
						elif input == 'a':
							log.info('abort check ssh connection, quit')
							quit(0)
						elif input == 'l':
							for index,host in enumerate(results['failedHosts']):
								print('host: {0}; {1}'.format(host,results['logs'][index]))
							continue
				else:
					checkingHosts = False
							
			# assign nodes to hosts
			greedy = askUserOption('node-host assignment: use as (less)/(many) as possible hosts', ['less','many'],'many','')
			if greedy == 'less':
				greedy = False
			else:
				greedy = True
							
			PreProcessing.assignNodesToHosts(state=self, greedyHostSelection = greedy)
			
			# complete node events
			# set node args for each event, with addr, port, seed, ...
			PreProcessing.processNodeEventParameter(state=self)
			
			# prepare experiment
			PreProcessing.processExperimentAndPrototypeData(state=self)
			
			# write all nodes and all events in db
			PreProcessing.storeNodesAndEvents(state=self)

			# prepare hosts
			PreProcessing.prepareHostsWorkingDir(state=self)
			
			# prepare nodeDB
			PreProcessing.prepareNodeDB(state=self)
			
			# copy files
			PreProcessing.copyExperimentAndPrototype(state=self)
			
			# prepare exp start
			PreProcessing.prepareStartExperiment(state=self)	
			
			self.experiment.setInitialized(True)
			raise ChangeState(StateResume)
		except KeyboardInterrupt as e:
			log.error('\nctrl-c received\n')
			self.stopMaster()


	def specifyClientExperimentFiles(self):
		# thinClient main
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.scriptsPath,PATHS.THINCLIENT_MAIN)
		values['target_sub_dir'] = None
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		# experiment_node.db
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.cwdPath,PATHS.NODE_DATABASE)
		values['target_sub_dir'] = None
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		# sendSignal.py
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.scriptsPath,PATHS.THINCLIENT_SENDSIGNAL)
		values['target_sub_dir'] = None
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		# all testbed modules
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.basePath, '*.py')
		values['target_sub_dir'] = 'testbed'
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.basePath,'base','*.py')
		values['target_sub_dir'] = 'testbed/base'
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.basePath,'client','*.py')
		values['target_sub_dir'] = 'testbed/client'
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
		
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = os.path.join(self.basePath, 'models','*.py')
		values['target_sub_dir'] = 'testbed/models'
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
											
		# experiment_db
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = str(os.path.abspath(self.properties.database))
		values['target_sub_dir'] = None
		values['target_file_name'] = PATHS.THINCLIENT_DB_FILE
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))
											
		# config
		values = dict.fromkeys(Models.HostInteraction.ExperimentData.FIELDS)
		values['path'] = str(os.path.abspath(self.properties.config))
		values['target_sub_dir'] = None
		values['target_file_name'] = PATHS.CONFIG_FILE
		values['recursive'] = False
		self.experiment.addExperimentData(Models.HostInteraction.ExperimentData(values))





		