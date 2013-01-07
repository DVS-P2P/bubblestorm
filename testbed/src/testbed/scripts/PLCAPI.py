#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, signal
import getpass, socket, sys

try:
	import xmlrpc.client as xmlrpclib
except ImportError:
	import xmlrpclib

try:
	import argparse
except ImportError:
	import optparse

def inSlashes(string):
	return "'{0}'".format(str(string).replace("'",'"'))

def buildSqlRowForHost(name, address, port, user_name, key_file, max_prototypes, working_dir, usable_ports_start, usable_ports_end):
	row = 'INSERT INTO "hosts" (name, address, port, user_name, key_file, max_prototypes, working_dir, usable_ports_start, usable_ports_end) \
		VALUES({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8});\n'
	return row.format(inSlashes(name), inSlashes(address),inSlashes(port),inSlashes(user_name), inSlashes(key_file), inSlashes(max_prototypes), 
		inSlashes(working_dir),inSlashes(usable_ports_start),inSlashes(usable_ports_end))


def main():
	# read cmd args

	try:
		parser = argparse.ArgumentParser(description='access planetlab/germanlab, retrieves all hosts of a given slice')


		group = parser.add_mutually_exclusive_group(required=True)
		group.add_argument('--planetlab', dest='planetlab', action='store_true', help='access planetlab plc api')
		group.add_argument('--germanlab', dest='germanlab', action='store_true', help='access germanlab plc api')
		
		parser.add_argument('--slice', dest='slice', action='store', required=True, help='the name of the slice')
		parser.add_argument('--keyfile', dest='keyfile', action='store', required=True, help='ssh keyfile (own private)')
		parser.add_argument('--user', dest='user', action='store', required=True, help='username for plcapi')
		parser.add_argument('--password', dest='password', action='store', required=False, help='password for plcapi')

		parser.add_argument('--default-max-nodes', dest='defaultMaxNodes', action='store', required=False, help='default value for host: max nodes placed on each host')
		parser.add_argument('--default-wd', dest='defaultWd', action='store', required=False, help='default value for host: working directory')
		parser.add_argument('--default-ports-start', dest='defaultPortsStart', action='store', required=False, help='default value for host: portrange (start) used by nodes')
		parser.add_argument('--default-ports-end', dest='defaultPortsEnd', action='store', required=False, help='default value for host: portrange (end) used by nodes')

				
		args = parser.parse_args()
	except NameError: # optparse
		parser = optparse.OptionParser()

		parser.add_option('--planetlab', dest='planetlab', action='store_true', help='access planetlab plc api')
		parser.add_option('--germanlab', dest='germanlab', action='store_true', help='access germanlab plc api')

		parser.add_option('--slice', dest='slice', action='store', help='the name of the slice')
		parser.add_option('--keyfile', dest='keyfile', action='store', help='ssh keyfile (own private)')
		parser.add_option('--user', dest='user', action='store', help='username for plcapi')
		parser.add_option('--password', dest='password', action='store', help='password for plcapi')

		parser.add_option('--default-max-nodes', dest='defaultMaxNodes', action='store', help='default value for host: max nodes placed on each host')
		parser.add_option('--default-wd', dest='defaultWd', action='store', help='default value for host: working directory')
		parser.add_option('--default-ports-start', dest='defaultPortsStart', action='store', help='default value for host: portrange (start) used by nodes')
		parser.add_option('--default-ports-end', dest='defaultPortsEnd', action='store', help='default value for host: portrange (end) used by nodes')

		
		args = parser.parse_args()[0]

		if args.slice == None or args.keyfile == None or args.user == None:
			parser.error("not all options given")
		if (args.planetlab == None and args.germanlab == None) or (args.planetlab != None and args.germanlab != None):
			parser.error("options --planetlab and --germanlab are mutually exclusive")

	# default values
	defaults = {"defaultMaxNodes":10, "defaultWd":'~/testbed/', "defaultPortsStart":49152, "defaultPortsEnd":65535}
	values = vars(args)
	for k in defaults:
		if ((k not in values) or (values[k]==None)):
			values[k] = defaults[k]

	# check planet/german -lab
	if (values['planetlab'] == True):
		values['germanlab'] = False
	else:
		values['germanlab'] = True
		values['planetlab'] = False

	# check for sql file
	sqlFile = 'sql/planetLabNodes.sql' if values['planetlab'] else 'sql/germanLabNodes.sql' 
	if not os.path.isfile(sqlFile):
		quit('cant find sql file %s'%sqlFile)

	# check password
	if (("password" not in values) or (values['password']==None)):
		print("please enter your password: ")
		values['password'] = getpass.getpass()

	plc_host_planetlab='www.planet-lab.eu'
	plc_host_germanlab='master.german-lab.de'
	auth = {'AuthMethod' : 'password',
			'Username' : values['user'],
			'AuthString' : values['password'],
	}

	plc_host = plc_host_planetlab if values['planetlab'] else plc_host_germanlab
	api_url="https://%s:443/PLCAPI/"%plc_host

	try:
		plc_api = xmlrpclib.ServerProxy(api_url,allow_none=True)
		authorized = plc_api.AuthCheck(auth)
		if authorized:
			print("login successful");
		slices = plc_api.GetSlices(auth,values['slice'],['node_ids'])
		if (len(slices) != 1):
			quit('cant find give slice')
		# the slice's node ids
		node_ids = slices[0]['node_ids']
		# get hostname for these nodes
		slice_nodes = plc_api.GetNodes(auth,node_ids,['hostname'])
		print("found %d hosts, write file..."%len(node_ids))
		with open(sqlFile,"w") as f:
			for node in slice_nodes:
				sql = buildSqlRowForHost(node['hostname'], node['hostname'], 22, values['slice'], values['keyfile'], values['defaultMaxNodes'], values['defaultWd'], 
					values['defaultPortsStart'], values['defaultPortsEnd'])
				f.write(sql)
				f.write("\n")
		print("all done")

	except xmlrpclib.Fault as err:
		print("A fault occurred")
		print("Fault code: %d" % err.faultCode)
		print("Fault string: %s" % err.faultString)

	

if __name__ == '__main__':
	sys.exit(main())
