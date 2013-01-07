#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from .Base import *
from .PostProcessing import PostProcessing

log = logging.getLogger(__name__)

class StateCleanup(Controller):
	
	def process(self):
		'''
		"main": cleanup all hosts
		'''
		for host in self.dbController.getHostsForExperiment(self.experiment):
			self.experiment.addHost(host)
		PostProcessing.resetHosts(self)