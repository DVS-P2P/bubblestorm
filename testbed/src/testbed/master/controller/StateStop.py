#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from .Base import *
from .Monitoring import Monitoring

log = logging.getLogger(__name__)

class StateStop(Controller):
	
	def process(self):
		'''
		"main": stop a experiment
		'''
		if not(self.experiment.isInitialized()):
			for host in self.dbController.getHostsForExperiment(self.experiment):
				self.experiment.addHost(host)
			self.experiment.setInitialized(True)

		Monitoring.stopThinClient(self)
		self.stopMaster() 