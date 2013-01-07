#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__all__ = ['base','master','client','models']



def startNewMasterInstance():
	try:
		import argparse
	except ImportError:
		import optparse

	import logging

	from testbed.base import Logging
	from testbed.master import Master
	from testbed.base.Constants import PATHS
		
	# specify args
	try:
		parser = argparse.ArgumentParser(description='The master control program')
		parser.add_argument('-d', '--database', dest='database', action='store', required=True, 
			help='the filename of the sqlite database for the experiment')
		parser.add_argument('-e', '--experiment', dest='experiment', action='store', required=True, 
			help='the name of the experiment to execute')
		parser.add_argument('-v', '--verbose', action='count', required=False, 
			help='be verbose')
		parser.add_argument('--debug', dest='debug', action='store_true', required=False)
		parser.add_argument('--profile', dest='profile', action='store_true', required=False)
		parser.add_argument('--config', dest='config', action='store', required=False)
		parser.add_argument('--logserver', dest='logserver', action='store_true', required=False,
			help='use logserver @localhost:'+str(logging.handlers.DEFAULT_TCP_LOGGING_PORT))
				
		# parse args
		args = parser.parse_args()
		if args.verbose == None:
			args.verbose = 0
	except NameError: # optparse
		parser = optparse.OptionParser()
		parser.add_option('-d','--database', dest='database', action='store',
			help='the filename of the sqlite database for the experiment')
		parser.add_option('-e', '--experiment', dest='experiment', action='store',
			help='the name of the experiment to execute')
		parser.add_option('-v', '--verbose', action='count',
			help='be verbose')
		parser.add_option('--debug', dest='debug', action='store_true')
		parser.add_option('--config', dest='config', action='store')
		parser.add_option('--profile', dest='profile', action='store_true')
		parser.add_option('--logserver', dest='logserver', action='store_true',
			help='use logserver @localhost:'+str(logging.handlers.DEFAULT_TCP_LOGGING_PORT))
		
			
		args = parser.parse_args()[0]
		fail = False
		if args.verbose == None:
			args.verbose = 0
		if args.database == None or args.experiment == None:
			fail = True
		if fail:
			quit()
	
	if args.config == None:
		args.config = PATHS.CONFIG_FILE		

	withLogServer=False
	if args.logserver == True:
		withLogServer = True
	Logging.setupMaster(withLogServer, level=args.verbose)

	# start main controller
	def start():
		controller = Master.TestbedMasterController(verbose=args.verbose, experiment=args.experiment, 
													database=args.database, debug=args.debug, config=args.config)
		controller.start()

	if args.profile == True:
		import cProfile
		profileFile = 'masterProfile'
		print('profileOutput: {0}'.format(profileFile))
		cProfile.run('start()', profileFile)
	else:
		start()

def startNewClientInstance():
	import datetime

	try:
		import argparse
	except ImportError:
		import optparse

	from testbed.base.Config import Config
	from testbed.base.Constants import PATHS
	
	Config.load(PATHS.CONFIG_FILE)

	from testbed.base import Logging
	from testbed.client import Client
	from testbed.base.Utils import dateTimeString
	

	# specify args
	try:
		parser = argparse.ArgumentParser(description='Thin-Client')
		parser.add_argument('-v', '--verbose', action='count', required=False, 
			help='be verbose')
		parser.add_argument('--autostart', dest='autostart', action='store_true', required=False, help='starts experiment immediately')
		parser.add_argument('--debug', dest='debug', action='store_true', required=False)
		parser.add_argument('--version', action='version', version='%(prog)s, trunk build')
		parser.add_argument('--logserver', dest='logserver', action='store_true', required=False,
			help='use logserver @localhost:8888')
			
		# parse args
		args = parser.parse_args()
		if args.verbose == None:
			args.verbose = 0
	except NameError:
		parser = optparse.OptionParser()
		parser.add_option('-v', '--verbose', action='count', dest='verbose', help='be verbose')
		parser.add_option('--autostart', dest='autostart', action='store_true', help='starts experiment immediately')
		parser.add_option('--debug', dest='debug', action='store_true')
		parser.add_option('--logserver', dest='logserver', action='store_true',
			help='use logserver @localhost:8888')
		
		# parse args
		args = parser.parse_args()[0]
		if args.verbose == None:
			args.verbose = 0

			
	withLogServer=False
	if args.logserver == True:
		withLogServer = True
	Logging.setupClient(withLogServer, level=args.verbose)
	
	# read experimentID, hostID from file
	try:
		with open(PATHS.THINCLIENT_HOST_ID_FILE) as f:
			hostId = int(f.readline())
		with open(PATHS.THINCLIENT_EXPERIMENT_ID_FILE) as f:
			experimentId = int(f.readline())
	except Exception as e:
		tb = sys.exc_info()[2]
		print('cant access id file: {0}'.format(e))
	
	print('args: {0}'.format(args))
	print('thinClient startup on: {0}'.format(dateTimeString()))

	# start main controller
	controller = Client.TestbedClientController(verbose=args.verbose, experiment=experimentId, autostart=args.autostart,
													host=hostId, debug=args.debug)


	print('thinClient shutdown on: {0}'.format(dateTimeString()))