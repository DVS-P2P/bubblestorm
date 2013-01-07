#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
usage: ./sendSignal.py -pid processID -signal UNIX_SIGNAL

UNIX_SIGNAL = SIGINT, SIGQUIT, SIGKILL, SIGTERM, SIGUSR1, SIGUSR2, SIGCONT
'''

import os, signal, os
from testbed.base.Constants import SIGNALS



try:
	import argparse
except ImportError:
	import optparse
	
try:
	parser = argparse.ArgumentParser()
	parser.add_argument('--pid', dest='pid', action='store', type=int, required=True)
	parser.add_argument('--signal', dest='sig', action='store', required=True)
	args = parser.parse_args()
except NameError: # optparse
	parser = optparse.OptionParser()
	parser.add_option('--pid', dest='pid', action='store', type=int)
	parser.add_option('--signal', dest='sig', action='store')
	args = parser.parse_args()[0]


try:
	sig = SIGNALS.getValue(args.sig)
except BaseException as e:
	print("an error occurred; unkown signal: %s"%str(e))
	quit(1)


#os.kill(args.pid, sig)

try:
	group = os.getpgid(args.pid)
	print("send signal:{0} process:{1}, group:{2}".format(sig, args.pid, group))
	os.killpg(group, sig)
except BaseException as e:
	print("an error occurred; send signal failed: %s"%str(e))
	quit(1)