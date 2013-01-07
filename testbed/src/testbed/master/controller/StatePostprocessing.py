#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from .Base import *
from .PostProcessing import PostProcessing
from .Monitoring import Monitoring

from .StateRepeat import StateRepeat

log = logging.getLogger(__name__)

class StatePostprocessing(Controller):
	
	def process(self):		
		'''
		"main": postprocessing actions
		'''		
		expStart = self.experiment.getLastRun()
		end = expStart + self.experiment.getDuration()
		while time.time()<end:
			progressWriter(lambda: time.time()<end, lambda:'... waiting until experiment is finished: {0} left '.format(seconds2readableString(end-time.time())), lowFrequentCheck=True)
		
		# check already collected data
		try:
			PostProcessing.checkCollectedData(self)
		except KeyboardInterrupt as e:
			print("")
			print("collect data aborted")
			quit()
		
		#user promt: collect additional data			
		while True:
			print(highlightedText({
			'collect': 'download data from hosts',
			'cleanup': 'remove (all) data from hosts',
			'rm exp': 'remove (all) experiment data from hosts',
			'repeat': 'rerun experiment with same configuration, create a copy of your database!',
			'[debug]': '"reprocess" collected databases; "create expected" running nodes statistic'
			}))
			input = askUserOption('(collect) data, (cleanup) hosts,  (rm exp) data, (repeat) experiment with same config -- (q)uit', 
				['collect','cleanup','rm exp','repeat','reprocess','create expected'], 'quit', 'q')
			if input == 'cleanup':
				print("reset all hosts")
				PostProcessing.resetHosts(self)
				break
			elif input == 'rm exp':
				print("remove experiment data")
				PostProcessing.removeExperiment(self)
				break
			elif input == 'reprocess':
				print("reprocess data")
				PostProcessing.reprocessCollectedData(self)
				break
			elif input == 'create expected':
				print('create "expected running nodes" statistic')
				PostProcessing.createExpectedStatistics(self)
				break
			elif input == 'repeat':
				log.debug("change state -> repeat")
				raise ChangeState(StateRepeat)
			elif input == 'collect':
				print("collect data, choose criteria:")
				input = askUserOption('collect data by: (host) id, (node) id, node(group) id -- (n)othing', 
					['host','node','group','n'], 'nothing', 'n')
				if input == 'host':
					input = waitForUserInput(msg='enter host id(s):',default='all')
					hosts = self.experiment.getHosts()
					if input == "":
						hosts = list(hosts)
					else:
						hostIDs = set([int(x) for x in re.findall(r'\d+',input)])
						hosts = list(filter(lambda h: h.dbID() in hostIDs, hosts))
					if len(hosts) == 0:
						print('invalid ids')
					else:
						PostProcessing.collectHostData(self,hosts)
				elif input == 'node':
					input = waitForUserInput(msg='enter node id(s):',default='all')
					nodes = self.experiment.getAllNodes()
					if input == "":
						nodes = list(nodes)
					else:
						nodeIDs = set([int(x) for x in re.findall(r'\d+',input)])
						nodes = list(filter(lambda n: n.dbID() in nodeIDs, nodes))
					if len(nodes) == 0:
						print('invalid ids')
					else:
						PostProcessing.collectNodeData(self,nodes)
					pass
				elif input == 'group':
					input = waitForUserInput(msg='enter group id(s):',default='all')
					groups = self.experiment.getNodeGroups()
					if input == "":
						groups = list(groups)
					else:
						groupIDs = set([int(x) for x in re.findall(r'\d+',input)])
						groups = list(filter(lambda g: g.dbID() in groupIDs, groups))
					if len(groups) == 0:
						print('invalid ids')
					else:
						PostProcessing.collectGroupData(self,groups)
			else:
				print('quit')
				self.stopMaster()

