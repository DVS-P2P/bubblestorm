#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

from ...base.Constants import *
from ...base.Utils import *

from ... import models as Models

from .Base import *
from .PostProcessing import PostProcessing
from .Monitoring import Monitoring

log = logging.getLogger(__name__)

class StateRepeat(Controller):

	def process(self):
		'''
		"main": repeat a experiment
		'''		
		raise NotImplementedError()