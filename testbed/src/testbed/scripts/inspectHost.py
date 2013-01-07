#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
usage: ./inspectHost.py -p firstPort,lastPort -b boundary -n maxnodesCnt

checks:
	portrange, test socket bind
	32 or 64 bit system
	available memory
	free space

return json formatted dict
'''

import socket, os, sys, json, subprocess, shlex, random, resource, time

try:
	import argparse
except ImportError:
	import optparse

try:
	try:
		parser = argparse.ArgumentParser()
		parser.add_argument('-p', '--portrange',dest='portrange', action='store', type=str, required=True)	
		parser.add_argument('-b','--boundary', dest='boundary', action='store', type=str, required=True)	
		parser.add_argument('-n','--maxnodes', dest='maxnodes', action='store', type=int, required=True)
			
		args = parser.parse_args()
		
		args.portStart, args.portEnd = None, None
		try:
			portrange = args.portrange.split(",")
			args.portStart, args.portEnd = int(portrange[0]), int(portrange[1])
		except:
			pass
			
	except NameError:
		parser = optparse.OptionParser()
		parser.add_option('-p','--portrange', dest='portrange', action='store', type=str, help='portstart,portend')	
		parser.add_option('-b','--boundary', dest='boundary', action='store', type=str)	
		parser.add_option('-n','--maxnodes', dest='maxnodes', action='store', type=int)
			
		args = parser.parse_args()[0]
		args.portStart, args.portEnd = None, None
		try:
			portrange = args.portrange.split(",")
			args.portStart, args.portEnd = int(portrange[0]), int(portrange[1])
		except:
			pass
		
	
	# check max nodes -> max file handler
	maxNodes = args.maxnodes
	try:
		ressourceCnt = lambda nodes: int(nodes * (2 + 1 + 1) + 20) # 2 (stderr, stdout), 1 (proc), 1 (thread), 20 base
		currentLimits = resource.getrlimit(resource.RLIMIT_NOFILE)
		# check current limits
		if (currentLimits[0] == -1 or ressourceCnt(maxNodes) <= currentLimits[0]) and (currentLimits[1] == -1 or ressourceCnt(maxNodes) <= currentLimits[1]):
			# all ok
			pass
		else:
			# inc limits, on fail: dec nodes
			while maxNodes > 0:
				try:
					target = ressourceCnt(maxNodes)
					if (currentLimits[0] == -1 or target <= currentLimits[0]) and (currentLimits[1] == -1 or target <= currentLimits[1]):
						break
					resource.setrlimit(resource.RLIMIT_NOFILE, (target,-1))
					old = currentLimits
					currentLimits = resource.getrlimit(resource.RLIMIT_NOFILE)
					if old[0] == currentLimits[0] and old[1] == currentLimits[1]:
						maxNodes -= 1
				except:
					maxNodes -= 1
	except:
		maxNodes = 0
	
		
	# port check
	portRange = (args.portStart, args.portEnd)
	portsOk = []
	try:
		assert(portRange[0]<=portRange[1])
		hostName = "127.0.0.1".encode("utf")
		for port in range(portRange[0],portRange[1]+1):
			if (len(portsOk) > maxNodes):
				break
			try:
				s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
				s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
				s.bind((hostName, port))
				portsOk.append(port)
			except BaseException as e:
				pass
			finally:
				s.close()
	except BaseException:
		pass
	
	
	# disc check
	try:
		stat = os.statvfs('.')
		freeDisc = int((stat.f_bavail * stat.f_frsize) / (1024*1024))
	except BaseException:
		freeDisc = 0
		
	# free ram check
	try:
		check = int(subprocess.Popen(shlex.split('grep MemFree /proc/meminfo'), stdout=subprocess.PIPE).communicate()[0].decode("utf8").split()[1])
		totalMemory = check // 1024
	except BaseException as e:
		try:
			result = subprocess.Popen(shlex.split("top -l 1"), stdout=subprocess.PIPE).communicate()[0].decode("utf8").split()
			while len(result) > 0:
				if result.pop(0) == 'PhysMem:':
					if len(result) > 8:
						totalMemory = int(result[8][:-1])
						break
		except BaseException:
			totalMemory = 0
		
	# arch check
	try:
		check = int(subprocess.Popen(shlex.split('getconf LONG_BIT'), stdout=subprocess.PIPE).communicate()[0].decode("utf8"))
		arch = True if check == 64 else False
	except BaseException as e:	
		try:
			check = subprocess.Popen(shlex.split('uname -a'), stdout=subprocess.PIPE).communicate()[0].decode("utf8")
			if 'x86_64' in check:
				arch = True
			else:
				arch = False
		except BaseException:	
			arch = None
	
	
	result = dict()
	result['time'] = time.time()
	result['timezone'] = time.timezone
	result['ram'] = totalMemory
	result['maxnodes'] = maxNodes
	result['disc'] = freeDisc
	result['ports'] = portsOk
	result['arch'] = arch # boolean, true -> 64 bit
	sys.stdout.flush()
	sys.stdout.write(args.boundary)
	sys.stdout.write(json.dumps(result))
	sys.stdout.write(args.boundary)
	sys.stdout.flush()
except BaseException as e:
	print(e)
	quit(1)