#!/usr/bin/env python
# -*- coding: utf-8 -*-

import errno
import logging
import os
import time
import subprocess
import tempfile
import threading
import socket

from threading import Thread
from threading import Lock
try:
	from queue import Queue, Empty
except ImportError:
	from Queue import Queue, Empty	
from . import Utils
from .Constants import *
from .Utils import quote
from .Config import Config

log = logging.getLogger(__name__)


class SSH(object):
	'''
	basic ssh object
	'''

	def __init__(self, host, username, port, keyfile, customSSHArgs):
		self.host = host
		self.port = port
		self.username = username
		self.keyfile = os.path.abspath(os.path.expanduser(keyfile))
		self.customSSHArgs = customSSHArgs
		
		self.paramsSSH = customSSHArgs + ['-C','-i', str(self.keyfile), '-T','-oConnectTimeout={0}'.format(
			Config.getInt("TIMEOUTS","SSH_CHECK_CONNECTION")),'-oBatchMode=yes','-oPasswordAuthentication=no',
			'-oUserKnownHostsFile={0}'.format(quote(PATHS.SSH_KNOWN_HOSTS)),
			'-p', str(self.port), 
			'-l', str(self.username), str(self.host)]
		
		self.paramsSCP = ['-C','-i', str(self.keyfile),'-oConnectTimeout={0}'.format(
			Config.getInt("TIMEOUTS","SSH_CHECK_CONNECTION")),'-oBatchMode=yes','-oPasswordAuthentication=no',
			'-oUserKnownHostsFile={0}'.format(quote(PATHS.SSH_KNOWN_HOSTS)),
			'-P', str(self.port)]
		
		if (Config.getBool("FLAGS","SSH_DEBUG_OUTPUT")):
			self.paramsSSH.append('-vv')
			self.paramsSCP.append('-vv')
		
		if (Config.getBool("FLAGS","SSH_HOST_KEY_CHECKING")):
			self.paramsSSH.append('-oStrictHostKeyChecking=yes')
			self.paramsSCP.append('-oStrictHostKeyChecking=yes')
		else:
			self.paramsSSH.append('-oStrictHostKeyChecking=no')
			self.paramsSCP.append('-oStrictHostKeyChecking=no')

		if (Config.getBool("FLAGS","SSH_USE_MASTER_CONNECTION")):
			try:
				if (not(os.path.exists(quote(PATHS.SSH_MASTER_CONNECTIONS_PATH)))):
					os.makedirs(quote(PATHS.SSH_MASTER_CONNECTIONS_PATH),0o777)
			except BaseException as e:
				if (not(os.path.exists(quote(PATHS.SSH_MASTER_CONNECTIONS_PATH)))):
					log.exception(e)
					log.error("cant create 'master ssh connections' folder")
			sshMasterConnection = ['-oControlPath={0}/master-%r@%h:%p'.format(quote(PATHS.SSH_MASTER_CONNECTIONS_PATH)), '-oControlMaster=auto', 
				'-oControlPersist={0}'.format(Config.get("TIMEOUTS","SSH_MASTER_CONNECTION_PERSIST"))]
			self.paramsSSH.extend(sshMasterConnection)
			self.paramsSCP.extend(sshMasterConnection)
			

	def check(self, processSetter=None):
		'''
		checks ssh connection
		'''
		ssh = SubProc('ssh',self.paramsSSH + ['exit'], captureErr=False, processSetter=processSetter,timeout=Config.getInt("TIMEOUTS","SSH_CHECK_CONNECTION")) # sleep $[ 1 + $[ RANDOM % 10 ]]; 		
		out = ssh.communicate()
		if ssh.getReturnCode() == 0:
			ssh.cleanup()
			return (True,None)
		
		if 'REMOTE HOST IDENTIFICATION HAS CHANGED' in out[1]:
			msg = 'Remote host identification has changed'		
		elif 'Host key verification failed' in out[1]:
			msg = 'Host key verification failed'
		else:
			msg = 'Unkown error: '
		ssh.cleanup()
		return (False, msg + out[0] + out[1])
	
	def execCmd(self, msg = None, convertInputString2Byte=False, processSetter=None):
		'''
		execs given command
		'''
		if convertInputString2Byte:
			msg = msg.encode()
		ssh = SubProc('ssh',self.paramsSSH, inputMessage=msg ,captureOut=True, captureErr=True, processSetter=processSetter,timeout=Config.getInt("TIMEOUTS","SSH_EXEC_CMDS"))	
		out = ssh.communicate()
		log.debug(out)
		returnCode = ssh.getReturnCode()
		ssh.cleanup()
		return (out[0],out[1],returnCode)
		
	def scp(self, localPath, remotePath, local2remote, recursive=False, processSetter=None):
		'''
		scp files
		'''
		# config
		local = localPath
		remote = ['{0}@{1}:{2}'.format((str(self.username)),(str(self.host)),remotePath)]
		params = self.paramsSCP + []
		if recursive:
			params.append('-r')	
		# copy
		if local2remote:
			scp = SubProc('scp',params + local + remote, processSetter=processSetter,captureErr=True,timeout=Config.getInt("TIMEOUTS","SSH_TRANSFER_FILES"))
		else:
			scp = SubProc('scp',params + remote + local, processSetter=processSetter,captureErr=True,timeout=Config.getInt("TIMEOUTS","SSH_TRANSFER_FILES"))
		out = scp.communicate()
		code = scp.getReturnCode()
		if code == 0:
			result = (True, None, code)
		else:
			result = (False, out[1], code)
		scp.cleanup()
		return result

class SubProc(object):

	runningProcessesLock = Lock()
	runningProcesses = set()

	@classmethod
	def killAllProcesses(self):
		todoClean = []
		with SubProc.runningProcessesLock:
			while (len(SubProc.runningProcesses) > 0):
				try:
					subproc = SubProc.runningProcesses.pop()
					if subproc.isRunning():
						subproc.sendSignal(SIGNALS.SIGKILL, alsoGroup=True)
					todoClean.append(subproc)
				except BaseException:
					pass
		for sub in todoClean:
			sub.cleanup()

	def cleanup(self):
		if hasattr(self,"cleanupDone"):
			return
		try:
			self.cleanupDone = True
			with SubProc.runningProcessesLock:
				if self in SubProc.runningProcesses:
					SubProc.runningProcesses.remove(self)
			if hasattr(self,"proc"):
				if self.isRunning():
					self.proc.terminate()
				for f in [self.fnull, self.fileOut,  self.fileErr, self.proc.stdin]:
					try:
						f.close()
					except BaseException:
						pass
					del(f)
		except BaseException as e:
			log.debug("some error occour")
			log.exception(e)
	
	def __init__(self, cmd, args, customEnv={}, cwd=None, inputMessage=None ,captureOut=False, captureErr=False, processSetter=None, timeout=-1):				
		self.cmd = cmd
		self.args = args
				
		env = {'SSH_ASKPASS':Utils.scriptPath(), 'DISPLAY':':9999'}
		env = {}

		self.timeout = timeout
		self.fnull = open(os.devnull, "w")
		stdin, stdout, stderr = None, self.fnull, self.fnull
		self.fileOut, self.fileErr = None, None
		self.inputMessage = inputMessage
		self.captureOut = captureOut
		self.captureErr = captureErr
		if inputMessage !=None:
			stdin = subprocess.PIPE
		if captureOut:
			self.fileOut = tempfile.SpooledTemporaryFile(mode='w+b')
			stdout = self.fileOut.fileno()
		if captureErr:
			self.fileErr = tempfile.SpooledTemporaryFile(mode='w+b')
			stderr = self.fileErr.fileno()
		
		for (k,v) in customEnv.items():
			env[k] = v
		log.debug([cmd] + args)

		self.proc = subprocess.Popen([cmd] + args, 
					shell=False, 
					stdout=stdout, 
					stdin=stdin, 
					stderr=stderr, 
					close_fds=False,
					env=env,
					cwd=cwd,
					preexec_fn=os.setsid,
					bufsize=1024)
		self.pid = self.proc.pid

		if processSetter!=None:
			processSetter(self.proc)
		
		with SubProc.runningProcessesLock:
			SubProc.runningProcesses.add(self)
		
	def isRunning(self):
		if hasattr(self,"cleanupDone"):
			return False
		self.proc.poll()
		return self.proc.returncode == None
		
	def getReturnCode(self):
		if hasattr(self,"cleanupDone"):
			return self.proc.returncode
		self.proc.poll()
		return self.proc.returncode
	
	def getPID(self):
		return self.pid

	def waitWithTimeout(self, timeout):
		class Waiter(threading.Thread):
			def __init__(self, cmd):
				threading.Thread.__init__(self)
				self.cmd = cmd
			def run(self):
				self.cmd.wait()
		w = Waiter(self.proc)
		w.start()
		if timeout < 0:
			w.join()
		else:
			w.join(timeout)
		if self.isRunning():
			self.proc.terminate()
			w.join()
			raise(socket.timeout("Connection timed out ({0})".format(timeout)))

		
	def communicate(self):
		log.debug("before communicate")
		if self.inputMessage != None:
			self.proc.stdin.write(self.inputMessage)
			self.proc.stdin.close()

		out = ""
		err = ""

		#self.proc.wait()
		failed = False
		try:
			self.waitWithTimeout(self.timeout)
		except BaseException as e:
			failed = True
			err = str(e)


		if hasattr(self,"cleanupDone"):
			return ('','process terminated')

		if self.captureOut:
			if not(failed):
				self.fileOut.seek(0)
				out = self.fileOut.readlines()
				out = map(lambda x: x.decode('UTF-8'), out)
				out = ''.join(out)
			self.fileOut.close()
		if self.captureErr:
			if not(failed):
				self.fileErr.seek(0)
				err = self.fileErr.readlines()
				err = map(lambda x: x.decode('UTF-8'), err)
				err = ''.join(err)
			self.fileErr.close()

		self.fnull.close()

		log.debug("after communicate")
		return (out,err)

	def sendSignal(self,signal, alsoGroup=False):
		try:
			if alsoGroup:
				try:
					os.killpg(self.proc.pid, signal)
					return
				except:
					pass
			self.proc.send_signal(signal)
		except OSError as e:
			if e.errno == errno.ESRCH: # errno -> child is not running
				pass
			else:
				raise

	
class NodeProc(object):
	'''
	a protoype bin wrapper
	'''
	pid = None
	cmd = None
	args = None
	proc = None

	def __init__(self, cmd, args, customEnv={}, cwd=None, stdout=None, 
					stdin=None, stderr=None):
		self.cmd = cmd
		self.args = args
		env = {'SSH_ASKPASS':Utils.scriptPath(), 'DISPLAY':':9999'}
		for (k,v) in customEnv.items():
			env[k] = v
		self.proc = subprocess.Popen([cmd] + args, 
					shell=False, 
					stdout=stdout, 
					stdin=stdin, 
					stderr=stderr, 
					close_fds=True,
					env=env,
					cwd=cwd,
					preexec_fn=os.setsid,
					bufsize=-1)
		self.pid = self.proc.pid
		
	def isRunning(self):
		self.proc.poll()
		return self.proc.returncode == None
		
	def getReturnCode(self):
		self.proc.poll()
		return self.proc.returncode
	
	def getPID(self):
		return self.pid

	def sendSignal(self,signal):
		try:
			self.proc.send_signal(signal)
		except OSError as e:
			if e.errno == errno.ESRCH: # errno -> child is not running
				pass
			else:
				raise