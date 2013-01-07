#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *
from ...base.Database import DatabaseController
from ... import models as Models

log = logging.getLogger(__name__)

class Monitoring(object):

	def __init__(self):
		raise NotImplementedException()
	
	@staticmethod		
	def stopThinClient(state):
		'''
		send stop signal
		'''
		hosts = state.experiment.getHosts()
		optional = {'signal': SIGNALS.SIGKILL}
		result = state.processJobs(hosts, 'runTerminateThinClient', 'terminate thinClient', optional)
		return result

	@staticmethod		
	def determineThinClientState(state, hosts=None, onFailAskUser=False):
		'''
		determine client execution state
		'''
		if hosts == None:
			hosts = state.experiment.getHosts()
		else:
			hosts = list(hosts)
		result = state.processJobs(hosts, 'runDetermineThinClientState', 'determine thinClient state',onFailAskUser=onFailAskUser)
		return result
		
	@staticmethod
	def checkThinClientIsRunning(state, hosts=None, onFailAskUser=True):
		'''
		checks whether thin client is running
		'''
		log.info("... checkThinClientIsRunning:")
		if hosts == None:
			hosts = set(state.experiment.getHosts())
		optional = {'signal': CLIENT_SIGNALS.CHECK}
		result = state.processJobs(hosts, 'runSendSignalToThinClient', 'check thinClient startup', optional, onFailAskUser=onFailAskUser)
		for h in result['failedHosts']:
			h.setThinClientIsRunning(False)
		for h in result['okHosts']:
			h.setThinClientIsRunning(True)
		return result	
		
	@staticmethod
	def checkHosts(state, hosts=None):
		'''
		check ssh connection
		'''
		if hosts == None:
			hosts = list(filter(lambda x: x.getNodePlaces()>0, state.experiment.hostGroup))
		else:
			hosts = list(hosts)
		result = state.processJobs(hosts, 'runCheckHost', 'check ssh connection')
		return result
	
	@staticmethod
	def inspectHosts(state, hosts=None):
		'''
		determine host properties
		'''
		if hosts == None:
			hosts = list(filter(lambda x: x.getNodePlaces()>0, state.experiment.hostGroup))
		else:
			hosts = list(hosts)
		log.debug(len(hosts))
		result = state.processJobs(hosts, 'runInspectHost', 'inspect hosts', onFailAskUser=False, onInterruptReturnRemainingAsFailed=True)
		log.debug("hosts ok: %d"%len(result['okHosts']))
		log.debug("hosts failed: %d"%len(result['failedHosts']))

		for host in result['okHosts']:
			state.dbController.update(host, identKeys=['id'], updateKeys=host.FIELDS)
		state.dbController.commitChanges()

		return result
