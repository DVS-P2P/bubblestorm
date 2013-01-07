#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import calendar
import datetime
import logging
import os
import pipes
import random
import math
import re
import shlex
import string
import sys
import signal
import threading
import time
import traceback

from .ntplib import NTPClient
from collections import namedtuple
from .Config import Config

try:
	from queue import Queue
except ImportError:
	from Queue import Queue

try:
	import configparser as configparser
except ImportError:
	import ConfigParser as configparser
	
	
log = logging.getLogger(__name__)


class AtomicCounter(object):

	def __init__(self, startValue):
		self.privateLock = WorkerPool.newLock()
		self.value = startValue

	def getNext(self): 
		with self.privateLock:
			self.value += 1
			v = self.value
		return v

	def getCurrent(self):
		return self.value

class Timer(object):

	globalTimer = dict()

	def __init__(self):
		self.measurements = []

	def setGloabl(self, name):
		Timer.globalTimer[name] = self

	@classmethod
	def getGlobal(self, name):
		if not(name in self.globalTimer):
			t = Timer()
			t.setGloabl(name)
		return self.globalTimer[name]
	
	def start(self):
		self.last = time.time()
		
	def stop(self):
		if hasattr(self,"last"):
			self.measurements.append(time.time()-self.last)
			del(self.last)
	
	def getMin(self):
		return min(self.measurements)
	
	def getMax(self):
		return max(self.measurements)
	
	def getAvg(self):
		return sum(self.measurements)/len(self.measurements)
	
	

class NTP(object):
	'''
	Network Time Protocol Client
	'''
	
	server = ['0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org']
	
	delta = None
	ntpClient = None
	
	@classmethod
	def sync(self, maxAttempts=3):
		'''
		syncs with europe.pool.ntp.org
		'''
		testServer = list(NTP.server)
		while maxAttempts > 0 and len(testServer) > 0:
			maxAttempts -= 1
			if NTP.ntpClient == None:
				NTP.ntpClient = NTPClient()
			try:
				host = testServer.pop()
				response = NTP.ntpClient.request(host, version=3)
				NTP.delta = response.offset		
				log.info("ntp sync, new delta:{0}".format(NTP.delta))
				return
			except BaseException as e:
				log.info("ntp sync faild, %d attempts left"%(maxAttempts))
				log.exception(e)
				if not(maxAttempts > 0):
					tb = sys.exc_info()[2]
					if hasattr(BaseException,"with_traceback"):
						raise NameError("ntp error: {0}".format(e)).with_traceback(tb)
					else:
						raise NameError("ntp error: {0}".format(e))
		
	@classmethod
	def utc(self):
		'''
		returns a datetime object
		'''
		localUTC = utcDateTime()
		return localUTC + datetime.timedelta(seconds=NTP.getDelta())
			
	@classmethod
	def utcTime(self):
		'''
		returns a time Object (float)
		'''
		localUTC = utcTime() # local utc time
		if NTP.delta != None:
			return localUTC + NTP.delta
		else:
			return localUTC
			
	@classmethod
	def getDelta(self):
		'''
		returns: local time <-> ntp server		
		'''
		if NTP.delta != None:
			return NTP.delta
		else:
			return 0

		
		

class Random(object):
	'''
	random number generator
	based on python internal mersenne twister implementation
	'''
	
	generator = None

	@classmethod
	def setSeed(self, newSeed):
		'''
		init the random generator
		'''
		self.generator = random.Random(newSeed)
			
	@classmethod
	def randomFloat(self):
		'''
		return float in [0.0, 1.0]
		'''
		assert self.generator != None
		output = self.generator.random()
		return output
		
		
	@classmethod
	def randomInt(self, a, b):
		'''
		return int in [a, b]
		'''
		assert self.generator != None
		output = self.generator.randint(a,b)
		return output
		
	@classmethod
	def choice(self, sequence):
		'''
		return random element from sequence
		'''
		assert self.generator != None
		output = self.generator.choice(sequence)
		return output
		
	@classmethod
	def sample(self, population, k):
		'''
		return unique list, k elements
		'''
		assert self.generator != None
		output = self.generator.sample(population, k)
		return output
	
	@classmethod
	def expovariate(self, mean=1.0):
		'''
		return float with given mean, expovariate
		'''
		assert(mean != 0)
		assert self.generator != None
		output = self.generator.expovariate(1/mean)
		return output
		
_PoolJob = namedtuple('PoolJob', 'host experiment basePath cwdPath scriptsPath receiver lock')

class PoolJob(object):
	'''
	a job
	'''
	
	def __init__(self, host, experiment, basePath, cwdPath, scriptsPath, receiver, lock, target, function):
		self.abort = threading.Event()
		self.data = _PoolJob(host, experiment, basePath, cwdPath, scriptsPath, receiver, lock)
		self.otherData = {}
		self.target = target
		self.function = function
		self.lastCall = None
		self.timeout = Config.getInt("TIMEOUTS","SSH_CHECK_CONNECTION")
		self.currentProcess = None

	def resetTimeout(self):
		self.lastCall = time.time()
		self.currentProcess = None
		return lambda process: self.setCurrentProcess(process)

	def setCurrentProcess(self, process):
		self.currentProcess = process

	def timeoutReached(self):
		if ((self.lastCall != None) and ((time.time()-self.lastCall) > self.timeout)):
			return True
		else:
			return False
	
	def terminate(self):
		self.abort.set()
	
	def isTerminated(self):
		return self.abort.is_set()
	
	def add(self, key, value):
		self.otherData[key] = value
	
	def get(self, key):
		return self.otherData[key]

		
		
class WorkerPool(object):
	'''
	thread pool, process jobs
	'''
	
	def __init__(self, threadCount=None):
		self.threadCount = threadCount if threadCount!=None else Config.getInt("LIMITS","WORKER_THREADS")
	
		self.runInit()
			
	def threadRunner(self):
		'''
		internal function, called by worker thread main
		'''
		while(True):
			job = WorkerPool.queue.get()
			if job.isTerminated():
				WorkerPool.queue.task_done() 
				continue
				
			with WorkerPool.runningThreadsLock:
				WorkerPool.runningThreads += 1
				WorkerPool.runningJobs.add(job)
			try:
				getattr(job.target, job.function)(job)
			except BaseException as e:
				log.error('error during job execution; host:%s'%str(job.data.host))
				log.exception(e)
			with WorkerPool.runningThreadsLock:
				WorkerPool.runningThreads -= 1
				WorkerPool.runningJobs.remove(job)
			WorkerPool.queue.task_done() 
			
	def addJob(self, item):
		'''
		adds a job
		'''
		WorkerPool.queue.put(item)

	def checkTimeout(self):
		with WorkerPool.runningThreadsLock:
			for job in WorkerPool.runningJobs:
				if job.timeoutReached():
					log.error("job reached timeout; host:{0}".format(str(job.data.host)))
					#job.terminate()
					try:
						if job.currentProcess != None:
							status = job.currentProcess.poll()
							if status == None:
								job.currentProcess.terminate()
								job.currentProcess.kill()
								log.error('kill job process successful: {0}'.format(status))	
							else:
								log.error('process already terminted')
					except BaseException as e:
						log.exception(e)
						log.error('kill job process failed')

	
	def wait(self, showProcess=False, statusCallable=None, newLine=True, timer=True, lowFrequentCheck=False):
		'''
		wait until all jobs processed
		'''
		def checkProcess():
			# disable old timeout check
			#self.checkTimeout()
			return self.isFull() or WorkerPool.runningThreads > 0

		if showProcess:
			progressWriter(lambda: checkProcess(), 
				statusCallable=statusCallable, newLine=newLine, timer=timer, lowFrequentCheck=lowFrequentCheck)
		else:
			WorkerPool.queue.join()
			
	def clearAndReturnAllRemaining(self):
		'''
		removes all jobs, return remaining
		'''
		jobs = []
		with WorkerPool.queue.mutex:
			while len(WorkerPool.queue.queue) > 0:
				job = WorkerPool.queue.queue.pop()
				job.terminate()
				jobs.append(job)
		with WorkerPool.runningThreadsLock:
			for job in WorkerPool.runningJobs:
				job.terminate()
				jobs.append(job)
		return jobs		
		
	def clear(self):
		'''
		removes all jobs
		'''
		with WorkerPool.queue.mutex:
			while len(WorkerPool.queue.queue) > 0:
				WorkerPool.queue.queue.pop().terminate()
		with WorkerPool.runningThreadsLock:
			for job in WorkerPool.runningJobs:
				job.terminate()
		
	def isFull(self):
		'''
		checks queue is full
		'''
		return WorkerPool.queue.qsize() > 0
			
	def runInit(self):
		'''
		1st time called, inits thread pool
		'''
		if hasattr(WorkerPool,'isInitialised') and WorkerPool.isInitialised:
			return
		WorkerPool.isInitialised = True
		WorkerPool.runningThreads = 0
		WorkerPool.runningJobs = set([])
		WorkerPool.runningThreadsLock = WorkerPool.newLock()
		WorkerPool.queue = Queue()
		## worker threads
		for i in range(self.threadCount):
			t = threading.Thread(target=self.threadRunner)
			t.daemon = True
			t.name = 'WorkerPool Thread {0}'.format(i)
			t.start()
	
	@staticmethod
	def newLock():
		'''
		generates a new locking object
		'''
		return threading.Lock()
		
def enum(*sequential, **named):
	'''
	creates a new enumeration
	
	> V = enum(A,B,C,D)
	V.A -> 0
	V.B -> 1
	
	> V = enum(A='test', B='test2')
	V.getKey('test') -> 'A'
	'''
	class Enum(object):
		def __init__(self, dictionary):
			self.__dict = dictionary
			for (k,v) in dictionary.items():
				setattr(self, k, v)
		def __iter__(self):
			return [(k,v) for (k,v) in self.__dict.items()].__iter__()
		def values(self):
			return [v for v in self.__dict.values()]
		def hasValue(self, value):
			for (k,v) in self.__dict.items():
				if v == value: return True
			return False
		def getKey(self, value):
			for (k,v) in self.__dict.items():
				if v == value: return k
			raise ValueError('value not found; {0}'.format(value))
		def getValue(self, key):
			return self.__dict[key]
		def assertUniqueValues(self):
			val = self.values()
			valSet = set(val)
			if len(valSet) != len(val):
				log.error(val)
				log.error(valSet)
				raise NameError("values not unique")
		
	enums = dict(zip(sequential, range(len(sequential))), **named)
	return Enum(enums)
	

def exactRound(x, n=0):
	org = x
	x *= 10 ** n
	floor = math.floor(abs(x))
	diff = abs(abs(x)-floor)
	up = diff >= 0.5
	neg = 1 if x >= 0 else -1
	if up:
		result = (neg * math.ceil(abs(x)))/(10**n)
		if result != round(org,n):
			log.debug("different result: x:{0}, n:{1}, round:{2}, exactRound:{3}".format(x,n,round(org,n),result))
		return result
	else:
		result = (neg * math.floor(abs(x)))/(10**n)
		if result != round(org,n):
			log.debug("different result: x:{0}, n:{1}, round:{2}, exactRound:{3}".format(x,n,round(org,n),result))
		return result


	
def scriptPath():
	'''
	return path of called python script
	'''
	return os.path.abspath(os.path.dirname(sys.argv[0]) + sys.argv[0])
	
_quote = set([c for c in '\'\\" '])
def quote(path):
	'''
	quotes a string, scp compatible
	'''
	path = str(path)
	out = ''
	for c in path:
		if c in _quote:
			out += '\\'
		out += c
	return out


def sizeof_fmt(num):
	'''
	human readable filesize
	# http://stackoverflow.com/a/1094933
	'''
	for x in ['bytes','KB','MB','GB']:
		if num < 1024.0:
			return "%3.1f %s" % (num, x)
		num /= 1024.0
	return "%3.1f %s" % (num, 'TB')

def stringEndsWithInt(str, end=1):
	'''
	checks whether string ends with int
	'''
	try:
		result = int(str[-2])
		if result == end:
			result = True
		else:
			result = False
	except (ValueError, IndexError):
		result = False
	return result

def seconds2time(secondsIn):
	'''
	converts seconds to time object
	'''
	h = int(secondsIn / 3600)
	s = secondsIn - 3600 * h
	m = int(s / 60)
	s -= 60 * m
	ms = int((s % 1.0) * 1000000)
	s = int(s)
	if not(	(h >= 0 and h < 24) 
			and (m >= 0 and m < 60) 
			and (s >= 0 and s < 60)):
		raise ValueError('H:{0}, M:{1}, S:{2}, input: {3}'.format(h,m,s,secondsIn))
	return datetime.time(hour=h, minute=m, second=s, microsecond=ms)	
	
def parseSqlDateTime(dtImput, baseDateTime=None):
	'''
	http://www.sqlite.org/cvstrac/wiki?p=DateAndTimeFunctions
	Time Strings

		A time string can be in any of the following formats:
		
			YYYY-MM-DD
			YYYY-MM-DD HH:MM
			YYYY-MM-DD HH:MM:SS
			YYYY-MM-DD HH:MM:SS.SSS
			YYYY-MM-DDTHH:MM
			YYYY-MM-DDTHH:MM:SS
			YYYY-MM-DDTHH:MM:SS.SSS
			SS
			MM:SS
			HH:MM:SS
			now
			DDDD.DDDD

		In formats 5 through 7, the "T" is a literal character separating the date and the time, as required by the ISO-8601 standard. These formats are supported in SQLite 3.2.0 and later. Formats 8 through 10 that specify only a time assume a date of 2000-01-01. Format 11, the string 'now', is converted into the current date and time. Universal Coordinated Time (UTC) is used. Format 12 is the julian day number expressed as a floating point value.
	'''

	formats = [
			'%Y-%m-%d',
			'%Y-%m-%d %H:%M',
			'%Y-%m-%d %H:%M:%S',
			'%Y-%m-%d %H:%M:%S.%f',
			'%Y-%m-%dT%H:%M',
			'%Y-%m-%dT%H:%M:%S',
			'%Y-%m-%dT%H:%M:%S.%f',
			'now'
		]
	
	# ms only max 6 digits
	log.debug(dtImput)
	dtImput = str(dtImput)
	dtImput = re.sub('(?P<target>\.[0-9]{6})[0-9]+','\g<target>',dtImput)

	# try normal formats
	for format in formats:
		try:
			return datetime.datetime.strptime(dtImput, format)	 
		except ValueError:
			pass
	# try hh:mm:ss pattern hh, mm, ss > 60 
	try:
		matches = list(map(lambda x: int(x), re.findall('([0-9]+)+', dtImput)))
		seconds = 0
		entries = len(matches)
		if entries >= 1 and entries <= 3:
			if entries >= 1:
				seconds += int(matches[-1])
			if entries >= 2:
				seconds += 60 * int(matches[-2])
			if entries == 3:
				seconds += 3600 * int(matches[-3])
			delta = seconds2timedelta(seconds)
			if baseDateTime != None:
				return baseDateTime + delta
			else:
				return datetime.datetime.strptime("00:00","%H:%M") + delta
	except BaseException as e:
		log.debug("cant read datetime input: {0}".format(dtImput))
		log.exception(e)

	raise ValueError("unsupported datetime string; ({0})".format(dtImput))	

def seconds2timedelta(secondsIn):
	return datetime.timedelta(seconds=secondsIn)		
	
def seconds2readableString(seconds):
	seconds = max(0, seconds)
	d, r = divmod(seconds, 86400)
	h, r = divmod(r, 3600)
	m, s = divmod(r, 60)
	return '%d day%s, %0*d:%0*d:%0*d'%(d,'s' if d != 1 else '',2,h,2,m,2,s)

def time2seconds(time):
	if type(time) is str:
		ts = time.split(":")
		return int(ts[2]) + int(ts[1])*60 + int(ts[0])*3600
	elif type(time) is datetime.time:
		return int(time.second) + int(time.minute)*60 + int(time.hour)*3600
	else:
		raise ValueError("unsupported time of type: ({0});".format(type(time)))

def datetime2timetime(datetimeObj):
	t = time.mktime(datetimeObj.timetuple()) 
	t += datetimeObj.microsecond / 1000000
	return t

def timetime2datetime(timeObj):
	return datetime.datetime.fromtimestamp(timeObj)

def utcTime():
	return time.time();

def utcDateTime():
	return datetime.datetime.utcfromtimestamp(time.time());
	
def utcDateTime2timetime(datetimeObj):
	return calendar.timegm(datetimeObj.timetuple())

def utcTimetime2datetime(timeObj):
	return datetime.datetime.utcfromtimestamp(timeObj)

def timetime2String(time=None):
	if time == None:
		time = utcTime()
	return dateTimeString(timetime2datetime(time))

def utcTimetime2String(time=None):
	if time == None:
		time = utcTime()
	return dateTimeString(utcTimetime2datetime(time))
	
def dateTimeString(time=None):
	if time == None:
		time = utcDateTime()
	return time.isoformat(' ') # use isoformat instead of strftime, problem with static python
	#return time.strftime("%A, %d. %B %Y %H:%M:%S.%f UTC")

def totalSeconds(timedelta):
	'''
	python 2.7+ feature backported
	'''
	if hasattr(timedelta, 'total_seconds'):
		return timedelta.total_seconds()
	else:
		return (timedelta.microseconds + (timedelta.seconds + timedelta.days * 24 * 3600) * 10**6) / 10**6

'''
bash interaction
'''	
def highlightedText(msgDict):
	stars = '*'*30
	prefix = '\t'
	lines = ''
	maxKeyLength = max([len(str(k)) for k in msgDict.keys()])
	for (k,v) in msgDict.items():
		orgKey = str(k)
		key = (' '*(maxKeyLength-len(orgKey))) + orgKey
		value = v.replace("\n","\n{0}{1}".format(prefix,' '*maxKeyLength))
		lines = lines + '\n{0}{1}: {2}'.format(prefix,key,value)
	return '{0}{1}\n{0}'.format(stars, lines)

def askUserOption(question, keys, default, onCtrlC):
	try:
		userInput = -1
		while (len(str(userInput)) != 0) and (userInput not in keys):
			userInput = waitForUserInput(question, ', '.join(keys),default)
		return userInput if userInput in keys else default
	except KeyboardInterrupt:
		print()
		return onCtrlC
	except EOFError:
		print()
		return onCtrlC

def waitForUserInput(msg='',keys='',default='enter'):
	# python 3.0+ feature backport
	try:
		s = raw_input('--> {0} -- options: {1}\n--> [{2}]	 '.format(msg,keys,default))
	except:
		s = input('--> {0} -- options: {1}\n--> [{2}]	 '.format(msg,keys,default))
	return s

def progressWriter(testFnc, statusCallable=None, newLine=True, timer=True, lowFrequentCheck=False):
	'''
	progressWriter(lambda: doPrivateCheck(), lambda: "this is a current status msg")
	'''		
	start = time.time()
	if lowFrequentCheck:
		sleepTime = 1
	else:
		sleepTime = 0.2
	while testFnc():
		if statusCallable != None:
			sys.stdout.write(statusCallable())
		for i in range(5):		
			sys.stdout.write(".")		
			sys.stdout.flush()	
			time.sleep(sleepTime)				
		sys.stdout.write("\r")		
		sys.stdout.flush()	
	if statusCallable != None:
		sys.stdout.write(statusCallable())		
		sys.stdout.flush()
	if timer:
		sys.stdout.write("..... done in ({0} s)".format(round(time.time()-start,3)))		
		sys.stdout.flush()
	if newLine:
		sys.stdout.write("\n")
		sys.stdout.flush()	
		

'''
command / ip stuff
'''

def parseCommand(command, aliasMap, seed, db, logInterval, ipPort):
	'''
	parse commandstring, replaces all variables and aliases, returns list of cmd Args
	
	sample:
		input command: 'prototypeName -nongui -custom "test name" -ip $ip --hosts $hosts'
		output: ['prototypeName', '@', '-seed', 'seed', '-logint', '1', '--', '-nongui', '-custom', 'test name',
				'-ip', '1.1.1.2', '--hosts', '1.1.1.1:90,2.2.2.2:91']
	'''
	from .Constants import COMMAND_VARIABLES,RUNTIME_ENGINE
	(ip, port) = ipPort
	
	nodeCommandSplit = shlex.split(command)
	runtimeEngineCommand = shlex.split(RUNTIME_ENGINE.COMMAND)
	
	commandSplit = [nodeCommandSplit.pop(0)]
	commandSplit.extend(runtimeEngineCommand)
	commandSplit.extend(nodeCommandSplit)

	
	for (index, cmd) in enumerate(commandSplit):
		cmd = str(cmd)
		try:
			if COMMAND_VARIABLES.OWN_IP in cmd:
				if ip == None: raise TypeError()
				cmd = cmd.replace(COMMAND_VARIABLES.OWN_IP, str(ip))	
			if COMMAND_VARIABLES.OWN_PORT in cmd:
				cmd = cmd.replace(COMMAND_VARIABLES.OWN_PORT, str(port))
			if COMMAND_VARIABLES.SEED in cmd:
				cmd = cmd.replace(COMMAND_VARIABLES.SEED, str(seed))
			if COMMAND_VARIABLES.DB in cmd:
				cmd = cmd.replace(COMMAND_VARIABLES.DB, str(db))
			if COMMAND_VARIABLES.LOG_INTERVAL in cmd:
				cmd = cmd.replace(COMMAND_VARIABLES.LOG_INTERVAL, str(logInterval))
			if COMMAND_VARIABLES.SEED in cmd:
				cmd = cmd.replace(COMMAND_VARIABLES.SEED, str(seed))
		except TypeError as e:
			msg = 'variable is requested, but is None; commandPart:{0}\n'.format(cmd)
			msg = msg + 'command:{0}\naliasMap:{1}\nseed:{2}\ndb:{3}\nlogInterval:{4}\nipPort:{5}'.format(
				command, aliasMap, seed, db, logInterval, ipPort)
			raise ValueError(msg)
			
		# parse alias
		found_alias = re.findall(COMMAND_VARIABLES.ALIAS_REG,cmd)
		values = dict.fromkeys(found_alias)
		for alias in values.keys():
			# for each alias
			if alias not in aliasMap:
				raise ValueError('unkown alias requested: {0}'.format(alias))
			# random choice, without own ip/port
			aliasAddresses = set(aliasMap[alias].values())# - set([ipPort]) # do not filter own ip
			targetListLength = min(len(aliasAddresses),Config.getInt("LIMITS","MAX_ADRESSES_ALIAS"))
			adresses = [ipPortToString(elem) for elem in Random.sample(aliasAddresses,targetListLength)]
			values[alias] = ','.join(adresses)
		for (alias, new) in values.items():
 			# substitute
			cmd = cmd.replace(COMMAND_VARIABLES.ALIAS.format(alias), new)	
		
		commandSplit[index] = cmd
	
	return commandSplit
	
def randomString(length=10, charsset=string.ascii_letters):
	return ''.join(random.choice(charsset) for c in range(length))

def extractMessageWithBoundary(text, boundary):
	'''
	extracts from text a message, bounded with boundary
	'''
	firstSplit = text.partition(boundary) # (_,boundary,message + boundary + _)
	secondSplit = firstSplit[2].partition(boundary) # (message,boundary,_)
	message = secondSplit[0]
	return message

def ipPortToString(tuple):
	'''
	build ip:port string
	'''
	(ip, port) = tuple
	if port == None:
		return '{0}'.format(ip)
	else:
		return '{0}:{1}'.format(ip, port)
		