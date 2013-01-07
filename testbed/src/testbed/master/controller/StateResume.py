#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from ... import models as Models

from .Base import *
from .PostProcessing import PostProcessing
from .Monitoring import Monitoring
from .StatePostprocessing import StatePostprocessing
from .StateStop import StateStop


log = logging.getLogger(__name__)

class StateResume(Controller):
		
	def process(self):
		'''
		"main": resume a experiment
		'''		
		# check duration
		expStart = self.experiment.getLastRun()
		if expStart == None:
			log.error('experiment never started; restart')
			from .StateStart import StateStart
			raise ChangeState(StateStart)
		# load db
		if not(self.experiment.isInitialized()):
			allNodeGroups = {}
			for nodeGroup in self.dbController.getNodeGroupsForExperiment(self.experiment):
				self.experiment.addNodeGroup(nodeGroup)
				allNodeGroups[nodeGroup.dbID()] = nodeGroup
			for host in self.dbController.getHostsForExperiment(self.experiment):
				self.experiment.addHost(host)
				nodes = self.dbController.getNodesForHost(host)
				for node in nodes:
					host.assignNodeGroup(allNodeGroups[node.nodeGroup()], 1, add=True)
					self.experiment.addNode(node)
			self.experiment.setInitialized(True)

		end = expStart + self.experiment.getDuration()
		log.info(highlightedText({
				'start':timetime2String(expStart), 
				'expectedEnd':timetime2String(end)}))
		print(highlightedText({
				'start':timetime2String(expStart), 
				'expectedEnd':timetime2String(end)}))
		while True:
			try:	
				progressWriter(lambda: time.time()<end, 
					lambda:'... waiting until experiment is finished: {0} left '.format(seconds2readableString(end-time.time())))
				break
			except KeyboardInterrupt as e:
				print('')
				input = askUserOption('(q)uit, (stop) experiment, (check) thin clients , (c)ontinue', 
					['q','c','check','stop'], 'c', 'q')
				if input == 'stop':
					raise ChangeState(StateStop)
				if input == 'q':
					return
				if input == 'check':
					hosts = self.experiment.getHosts()	
					resultsState = Monitoring.determineThinClientState(self)	

					runnigStats = {"hosts":[]}
					nonRunningStats = {"hosts":[]}

					for host in hosts:
						state = host.getThinClientState()
						if host.getThinClientIsRunning():
							if not state in runnigStats:
								runnigStats[state] = 0
							runnigStats[state] += 1
							runnigStats["hosts"].append(host)
						else:
							if not state in nonRunningStats:
								nonRunningStats[state] = 0
							nonRunningStats[state] += 1
							nonRunningStats["hosts"].append(host)

					print("running hosts:")
					if len(runnigStats["hosts"]) == 0:
						print("\tnone")
					for state in TC_STATES.values():
						if state in runnigStats:
							print("\t{0}: {1} hosts".format(TC_STATES.getKey(state),runnigStats[state]))

					print("not running hosts:")
					if len(nonRunningStats["hosts"]) == 0:
						print("\tnone")
					for state in TC_STATES.values():
						if state in nonRunningStats:
							print("\t{0}: {1} hosts".format(TC_STATES.getKey(state),nonRunningStats[state]))
					for host in nonRunningStats['hosts']:
						if host.getThinClientState() != TC_STATES.NORMAL_SHUTDOWN:
							print('not running {0}: isRunning:"{1}" state:"{2}"'.format(host, host.getThinClientIsRunning(), TC_STATES.getKey(host.getThinClientState())))
		raise ChangeState(StatePostprocessing)


