#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import sys
import logging.handlers



try:
    import SocketServer 
except:
    import socketserver as SocketServer

default_formatter = logging.Formatter('%(asctime)s:%(name)16s:%(lineno)4d:%(levelname)5s:%(message)s')



root = logging.getLogger()
root.setLevel(logging.ERROR)


class SimpleStreamHandler(logging.StreamHandler):
	def emit(self, record):
		if isinstance(record,BaseException):
			return super(SimpleStreamHandler, self).emit(record.getMessage())
		else:
			return super(SimpleStreamHandler, self).emit(record)	

	
def setupMaster(withLogServer=False, level=0):
	# coloured error, warning
	#logging.addLevelName( logging.ERROR, "\033[01;31m%s\033[0;0m" % logging.getLevelName(logging.ERROR))
	#logging.addLevelName( logging.WARNING, "\033[01;31m%s\033[0;0m" % logging.getLevelName(logging.WARNING))
	
	logfile_handler = logging.handlers.RotatingFileHandler("error.log", "a", maxBytes=10**10)
	logfile_handler.setLevel(logging.DEBUG)
	logfile_handler.setFormatter(default_formatter)
	
	logging.getLogger("testbed").setLevel(logging.ERROR)
	logging.getLogger("testbed.master.Master").setLevel(logging.INFO)

	if level > 0:
		logging.getLogger("testbed.master.controller").setLevel(logging.INFO)
	if level > 1:
		logging.getLogger("testbed.master").setLevel(logging.INFO)
	if level > 2:
		logging.getLogger("testbed").setLevel(logging.INFO)
	if level > 3:
		logging.getLogger("testbed").setLevel(logging.DEBUG)

	#logging.getLogger("testbed.master.controller").setLevel(logging.DEBUG)
	#logging.getLogger("testbed.base.Utils").setLevel(logging.DEBUG)
	logging.getLogger("testbed.base.SubProc").setLevel(logging.DEBUG)
	#logging.getLogger("testbed.base.Database").setLevel(logging.DEBUG)
	#logging.getLogger("testbed.base.DatabaseProcessing").setLevel(logging.DEBUG)
	
	# add handler
	console_handler = SimpleStreamHandler(sys.stdout)
	console_handler.setFormatter(default_formatter)
	root.addHandler(logfile_handler)
	if withLogServer:
		socket_handler = logging.handlers.SocketHandler('localhost', logging.handlers.DEFAULT_TCP_LOGGING_PORT)
		root.addHandler(socket_handler)
		console_handler.setLevel(logging.ERROR)
		root.addHandler(console_handler)
	else:
		console_handler.setLevel(logging.ERROR)
		root.addHandler(console_handler)
	
def setupClient(withLogServer=False, level=0):
	logging.getLogger("testbed").setLevel(logging.ERROR)
	logging.getLogger("testbed.client.Client").setLevel(logging.INFO)
	#logging.getLogger("testbed.base.Database").setLevel(logging.DEBUG)
	#logging.getLogger("testbed.base.DatabaseProcessing").setLevel(logging.DEBUG)
	
	root.setLevel(logging.ERROR)

	#root.addHandler(socket_handler)
	console_handler = logging.StreamHandler(sys.stdout)
	console_handler.setFormatter(default_formatter)
	console_handler.setLevel(logging.INFO)
	root.addHandler(console_handler)

	console_handler = logging.StreamHandler(sys.stderr)
	console_handler.setFormatter(default_formatter)
	console_handler.setLevel(logging.ERROR)
	root.addHandler(console_handler)

	if level > 0:
		logging.getLogger("testbed.client").setLevel(logging.INFO)
	if level > 1:
		logging.getLogger("testbed").setLevel(logging.INFO)
	if level > 2:
		logging.getLogger("testbed.base.Database").setLevel(logging.DEBUG)
		logging.getLogger("testbed.base.DatabaseProcessing").setLevel(logging.DEBUG)
	if level > 3:
		logging.getLogger("testbed").setLevel(logging.DEBUG)
	
	if withLogServer:
		socket_handler = logging.handlers.SocketHandler('localhost', SocketServer.ThreadingTCPServer)
		root.addHandler(socket_handler)







