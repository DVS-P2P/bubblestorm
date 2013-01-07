#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, signal, sys
from testbed.base.Constants import PATHS
from testbed.base.SubProc import SubProc
from testbed.base.Database import DatabaseController
from testbed.base.Utils import quote, WorkerPool, PoolJob 
from testbed.base.Config import Config

try:
	import argparse
except ImportError:
	import optparse


def checkConnection(keyfile, timeout, knownHosts, port, username, host):
	paramsSSH = ['-C','-i', str(keyfile), '-T','-oConnectTimeout={0}'.format(
			timeout),'-oBatchMode=yes','-oPasswordAuthentication=no','-oStrictHostKeyChecking=no','-vv',
			'-oUserKnownHostsFile={0}'.format(quote(knownHosts)),
			'-p', str(port), 
			'-l', str(username), str(host)]
	ssh = SubProc('ssh',paramsSSH + ['exit'], captureErr=False, processSetter=None,timeout=timeout)
	out = ssh.communicate()
	if ssh.getReturnCode() == 0:
		ssh.cleanup()
		return (True,None)
	
	if 'REMOTE HOST IDENTIFICATION HAS CHANGED' in out[1]:
		msg = 'Remote host identification has changed'		
	elif 'Host key verification failed' in out[1]:
		msg = 'Host key verification failed'
	else:
		msg = out[1]
	ssh.cleanup()
	return (False, msg, out)

def main():
	# read cmd args
	try:
		parser = argparse.ArgumentParser(description='Prepare the knownHosts file')
		parser.add_argument('-d', '--database', dest='database', action='store', required=True, 
			help='the filename of the sqlite database for the experiment')
		parser.add_argument('-k', '--knownhosts', dest='knownhosts', action='store', required=True, 
			help='the filename of the known_hosts file')
		parser.add_argument('--config', dest='config', action='store', required=False)
				
		args = parser.parse_args()
	except NameError: # optparse
		parser = optparse.OptionParser()
		parser.add_option('-d','--database', dest='database', action='store',
			help='the filename of the sqlite database for the experiment')
		parser.add_option('-k', '--knownhosts', dest='knownhosts', action='store',
			help='the filename of the known_hosts file')
		parser.add_option('--config', dest='config', action='store')
		
		args = parser.parse_args()[0]
		fail = False
		if args.database == None or args.knownhosts == None:
			fail = True
		if fail:
			quit()


	if args.config == None:
		args.config = PATHS.CONFIG_FILE	
	Config.load(args.config)	

	print("database: {0}".format(args.database))
	print("knownHosts: {0}".format(args.knownhosts))
	fileKnownHosts = os.path.abspath(os.path.realpath(os.path.join(args.knownhosts)))

	db = DatabaseController(args.database)
	basePath = os.path.abspath(os.path.dirname(os.path.realpath(args.database)))
	hosts = db.getHosts()
	print("process %d hosts"%len(hosts))
	pool = WorkerPool(50)
	lock = WorkerPool.newLock()
	results = {'ok':0, 'fail':0, 'logs': [], 'failedHosts': []}
	class SSHJob(object):
		@staticmethod 
		def run(target):
			host = target.data.host
			result = checkConnection(host = host.getDB("address"), port = host.getDB("port"), keyfile = os.path.abspath(os.path.realpath(os.path.join(host.getDB("key_file")))),
							username = host.getDB("user_name"), timeout=Config.getInt("TIMEOUTS","SSH_CHECK_CONNECTION"), knownHosts=fileKnownHosts)
			if (result[0]):
				with target.data.lock:
					target.data.receiver['ok'] += 1
			else:
				with target.data.lock:
					target.data.receiver['fail'] += 1
					if len(result[1]) > 0:
						target.data.receiver['logs'].append(' ({0})'.format(result[1]))
					else:
						target.data.receiver['logs'].append("(unknown error)")
					target.data.receiver['failedHosts'].append(host)

	
	for host in hosts:
		pool.addJob(PoolJob(host, None, None, None, None, results, lock, SSHJob, "run"))
	pool.wait(True,lambda: "... processing: Waiting: {0}, OK: {1}, Failed: {2} ".format((len(hosts)-results['ok']-results['fail']),results['ok'], results['fail']))
	print("all done")
	if results['fail'] > 0:
		print("failed hosts: {0}".format(', '.join(["{0}{1}".format(host.dbID(), results['logs'][i]) for (i,host) in enumerate(results['failedHosts'])])))

if __name__ == '__main__':
	sys.exit(main())
