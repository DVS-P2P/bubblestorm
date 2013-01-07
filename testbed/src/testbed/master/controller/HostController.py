#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division

import glob
import json
import shutil

from ...base.Constants import *
from ...base.Utils import *
from ...base.SubProc import SSH

import logging
log = logging.getLogger(__name__)

class CommandBuilder(object):

	GOTO_FOLDER_CREATE_IF_NOT_EXISTS = 'if [ ! -d {0} ]; then mkdir -p {0}; fi \n cd {0}'
	CHECK_FILE_EXISTS = 'if [ -e {0} ]; then echo "{1}"; else echo "{2}"; fi'
	CAT_FILE_CONTENT_BOUNDARY = '{0}=$(cat {2}) ; echo "{1}""${0}""{1}"'

	def __init__(self, job):
		self.cmd = ''
		self.host = job.data.host
		self.basePath = job.data.basePath
	
	def getCmd(self):
		return self.cmd + "\n exit"
		
	def mkdir(self, foldername):
		self.addnl("mkdir {0}".format(quote(foldername)))
		
	def cd(self, foldername):
		self.addnl("cd {0}".format(quote(foldername)))
		
	def add(self, cmd):
		self.cmd += cmd

	def addnl(self, cmd):
		self.add(cmd)
		self.add("\n")
	
	def gotoExp(self):
		self.addnl(CommandBuilder.GOTO_FOLDER_CREATE_IF_NOT_EXISTS.format(quote(self.host.workingDirExperiment)))
	
	def gotoTestbed(self):
		self.addnl(CommandBuilder.GOTO_FOLDER_CREATE_IF_NOT_EXISTS.format(quote(self.host.workingDirTestbed)))
	
	def rmExp(self):
		self.addnl('rm -rf %s'%quote(self.host.workingDirExperiment))
	
	def rmTestbed(self):
		self.addnl('rm -rf %s'%quote(self.host.workingDirTestbed))

	def readFileContent(self, filePath):
		boundary = randomString(10)
		varname = randomString(5)
		self.addnl(CommandBuilder.CAT_FILE_CONTENT_BOUNDARY.format(varname, boundary, quote(filePath)))
		return boundary

	def checkFileExists(self, path):
		ok = randomString(10)
		fail = randomString(10)
		self.addnl(CommandBuilder.CHECK_FILE_EXISTS.format(quote(path),ok,fail))
		return (ok, fail)

class HostInteractionException(Exception):

	def __init__(self, stderr):
		self.unkownError = True
		self.error = str(stderr)
		# determine error
		inpErr = str(stderr).lower()
		errors = ["operation timed out", "ssh connection timed out", "operation timed out", "permission denied (publickey"]
		for e in errors:
			if e in inpErr:
				log.debug("detect known error: %s"%e)
				self.unkownError = False
				self.error = e
				break
		# call super
		Exception.__init__(self, self.error)

	def isUnkownError(self):
		return self.unkownError

	def getError(self):
		return self.error


class HostController(object):
	'''
	stateless host controller
	holds all tasks called by threadPool worker

	locking convention:
		only one thread is writing on specific host object, so no lock required
		multiple threads can write on receiver object, so lock is required
	'''
	
	def __init__(self):
		raise NotImplementedException()
	
	@staticmethod
	def prepareHostSSH(host):
		'''
		prepare host specific ssh stuff: creates ssh object, build paths, ...
		'''
		if not(hasattr(host, "ssh")):
			host.ssh = SSH(host = host.getDB("address"), port = host.getDB("port"), keyfile=host.getDB("key_file"),
							username=host.getDB("user_name"), customSSHArgs=host.getSSHArgs())
			experimentFolder = PATHS.THINCLIENT_EXPERIMENT_FOLDER.format(host.getExperimentID())
			host.workingDirExperiment = os.path.join(host.getDB("working_dir"),experimentFolder)
			host.workingDirTestbed = host.getDB("working_dir")
			host.python = os.path.join(host.workingDirTestbed,PATHS.THINCLIENT_PYTHON)
			
	@staticmethod
	def writeSuccess(job):
		if job.isTerminated():
			log.debug("job is terminated")
			return
		with job.data.lock:
			assert(not(job.data.host in job.data.receiver['okHosts']))
			assert(not(job.data.host in job.data.receiver['failedHosts']))
			job.data.receiver['ok'] += 1
			job.data.receiver['okHosts'].append(job.data.host)

	@staticmethod	
	def writeFail(job, msg):
		if job.isTerminated():
			log.debug("job is terminated")
			return
		with job.data.lock:
			assert(not(job.data.host in job.data.receiver['okHosts']))
			assert(not(job.data.host in job.data.receiver['failedHosts']))
			job.data.receiver['fail'] += 1
			job.data.receiver['logs'].append(msg)
			job.data.receiver['failedHosts'].append(job.data.host)

	@staticmethod
	def runSetThinClientState(job):
		'''
		set thin clint state
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		cmdBuilder = CommandBuilder(job)
		cmdBuilder.gotoExp()
		newState = int(job.get('state'))
		# write state
		cmdBuilder.addnl('echo "{0}" > {1}'.format(quote(newState),quote(PATHS.THINCLIENT_STATE_FILE)))
		# read state
		boundary = cmdBuilder.readFileContent(PATHS.THINCLIENT_STATE_FILE)
		
		processSetter = job.resetTimeout()
		out = host.ssh.execCmd(
			cmdBuilder.getCmd(),
			convertInputString2Byte=True,
			processSetter=processSetter)

		if boundary in out[0]:
			message = extractMessageWithBoundary(out[0], boundary)
			try:
				state = int(message)
			except BaseException:
				state = -1
			if not(TC_STATES.hasValue(state)):
				log.debug(out[0])
				log.debug(out[1])
				state = TC_STATES.UNDEFINED

			if state == newState:
				HostController.writeSuccess(job)
			else:
				log.debug(out[0])
				log.debug(out[1])
				HostController.writeFail(job, "cant write statefile: {0}, {1}".format(out[0],out[1]))
		else:
			log.debug(out[0])
			log.error(out[1])
			HostController.writeFail(job, "cant set state")


	@staticmethod
	def runDetermineThinClientState(job):
		'''
		determine thin clint state
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		cmdBuilder = CommandBuilder(job)
		cmdBuilder.gotoExp()
		tcIsRunning = randomString()
		tcIsNotRunning = randomString()
		cmdBuilder.addnl('kill -0 $(cat {0}) \n if [ $(echo $?) -eq "0" ]; then echo "{1}"; else echo "{2}"; fi'.format(
			quote(PATHS.THINCLIENT_PID_FILE),
			tcIsRunning,
			tcIsNotRunning
			))
		cmdBuilder.gotoExp()
		boundary = cmdBuilder.readFileContent(PATHS.THINCLIENT_STATE_FILE)

		processSetter = job.resetTimeout()
		out = host.ssh.execCmd(
			cmdBuilder.getCmd(),
			convertInputString2Byte=True,
			processSetter=processSetter)

		if (boundary in out[0]) and (tcIsRunning in out[0] or tcIsNotRunning in out[0]):
			message = extractMessageWithBoundary(out[0], boundary)
			try:
				state = int(message)
			except BaseException:
				state = -1
			if not(TC_STATES.hasValue(state)):
				log.debug(out[0])
				log.debug(out[1])
				state = TC_STATES.UNDEFINED
			host.setThinClientState(state)
			if tcIsRunning in out[0]:
				host.setThinClientIsRunning(True)
			elif tcIsNotRunning in out[0]:
				host.setThinClientIsRunning(False)

			HostController.writeSuccess(job)
		else:
			state = TC_STATES.UNDEFINED
			host.setThinClientIsRunning(False)
			host.setThinClientState(state)
			log.debug(out[0])
			log.error(out[1])
			HostController.writeFail(job, "cant determine state")

	@staticmethod
	def runCheckHost(job):
		'''
		check ssh connection
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		processSetter = job.resetTimeout()
		check = host.ssh.check(processSetter=processSetter)
		if check[0] == True:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, check[1])

	@staticmethod
	def runInspectHost(job):
		'''
		determine host properties
		'''
		host, basePath, scriptsPath, receiver, lock = job.data.host, job.data.basePath, job.data.scriptsPath, job.data.receiver, job.data.lock 
		HostController.prepareHostSSH(host)
		
		measuremtTimer = Timer()
		
		# check ssh connection
		measuremtTimer.start()
		processSetter = job.resetTimeout()
		check = host.ssh.check(processSetter=processSetter)
		measuremtTimer.stop()
		if check[0] != True:
			if "Operation timed out" in check[1]:
				log.debug("ssh connection timed out")
				HostController.writeFail(job, "ssh connection timed out")
				return
			HostController.writeFail(job, check[1])
			return

		# build check python cmd
		cmd = CommandBuilder(job)
		cmd.gotoTestbed() # goto testbed dir
		scriptOk, scriptFail = cmd.checkFileExists(PATHS.THINCLIENT_INSPECT_SCRIPT) # check inspect script exists
		
		# check python version
		copyPythonMsg = 'no python available, copy custom python'
		useCopiedPythonMsg = 'use copied python'
		useSystemPythonMsg = 'use system python'
		checkPythonCmd = '''
MSG_USE_COPIED_PYTHON="''' + useCopiedPythonMsg + '''"
MSG_COPY_CUSTOM_PYTHON="''' + copyPythonMsg + '''"
MSG_USE_CMD="''' + useSystemPythonMsg + '''"
CUSTOM_PYTHON="''' + PATHS.THINCLIENT_PYTHON + '''"

TESTBED_DIR="''' + quote(host.workingDirTestbed) + '''"

FOUND_CMD=''

# locate system-python bin
PYTHON_BIN=("python3.3" "python3.2" "python3.1" "python3" "python2.7" "python2.6" "python2" "python")
#PYTHON_BIN=("python2.7" "python2.6" "python2" "python")
for bin in ${PYTHON_BIN[*]}; do
	PYTHON_INSTALLED=1
	command -v $bin >/dev/null 2>&1 || { PYTHON_INSTALLED=0; }
	if  [ $PYTHON_INSTALLED = 1 ]; then
		FOUND_CMD=$bin
		break
	fi
done

# check system-python version
if [ $PYTHON_INSTALLED = 1 ]; then
	VERSION_OK=$($FOUND_CMD -c 'import sys;print("1" if (sys.version_info >= (2, 6)) else "0")')
	if [ $VERSION_OK = 1 ]; then 
		PYTHON_INSTALLED=1
	else
		echo "python version too old"
		PYTHON_INSTALLED=0
	fi
fi

# create exp dir
eval REAL_DIR=$TESTBED_DIR
mkdir -p "$REAL_DIR"
cd "$REAL_DIR"

# check custon python?
if [ $PYTHON_INSTALLED = 1 ]; then
	echo "$MSG_USE_CMD"
	if [ ! -e "$CUSTOM_PYTHON" ]; then
		SYS_PYTHON_PATH=$(which $FOUND_CMD)
		echo "ln -s $SYS_PYTHON_PATH $CUSTOM_PYTHON"
		ln -s $SYS_PYTHON_PATH "$CUSTOM_PYTHON"
	fi
else
	if [ ! -e "$CUSTOM_PYTHON" ]; then
		echo "$MSG_COPY_CUSTOM_PYTHON"
	else
		VERSION_OK=$("./$CUSTOM_PYTHON" -c 'import sys, sqlite3, traceback, os, glob, time, datetime, shutil, signal, threading, stat, resource, gc, shlex, copy;print("1" if (sys.version_info >= (2, 6)) else "0")')
		if [ $VERSION_OK = 1 ]; then 
			echo "$MSG_USE_COPIED_PYTHON"
		else
			echo "$MSG_COPY_CUSTOM_PYTHON"
		fi
		
	fi
fi

		'''
		
		
		cmd.add(checkPythonCmd)
		
		# create cmd string
		cmdString = cmd.getCmd()
		measuremtTimer.start()
		processSetter = job.resetTimeout()
		out = host.ssh.execCmd(
			cmdString,
			convertInputString2Byte=True,
			processSetter=processSetter)
		measuremtTimer.stop()
		# (stdout, stderr, returncode) = out
		
		# check output
		copyFiles = []
		
		# check python: copyPythonMsg, useCopiedPythonMsg, useSystemPythonMsg
		if copyPythonMsg in out[0]:
			copyFiles.append(([PATHS.STATIC_PYTHON3_PATH], quote(host.python)))
		elif not(useCopiedPythonMsg in out[0] or useSystemPythonMsg in out[0]):
			log.debug("script failed")
			log.debug(out[0])
			log.debug(out[1])
			HostController.writeFail(job, "script failed")
			return
		
		# check inspect script: scriptOk, scriptFail
		if scriptFail in out[0]:
			copyFiles.append(([os.path.join(scriptsPath,PATHS.THINCLIENT_INSPECT_SCRIPT)], quote(os.path.join(host.workingDirTestbed, PATHS.THINCLIENT_INSPECT_SCRIPT))))
		elif not scriptOk in out[0]:
			if "Operation timed out" in out[1]:
				log.debug("ssh connection timed out")
				HostController.writeFail(job, "ssh connection timed out")
				return
			else:
				log.debug("script failed")
				log.debug(out[0])
				log.debug(out[1])
				HostController.writeFail(job, "script failed")
				return
		
		# copy files
		for localPaths, remotePath in copyFiles:
			processSetter = job.resetTimeout()
			scp = host.ssh.scp(localPaths, remotePath, local2remote=True, recursive=False,processSetter=processSetter)
			if scp[0] == False:
				log.debug("scp failed")
				log.debug(scp[1])
				HostController.writeFail(job, scp[1]) 
				return
		
		# run inspect script
		cmd = CommandBuilder(job)
		cmd.gotoTestbed() # goto testbed dir
		
		boundary = randomString(10)
		runInsp = '{0} {1} -p {2},{3} -b {4} -n {5}'.format(
			quote(host.python),
			quote(PATHS.THINCLIENT_INSPECT_SCRIPT),
			host.getDefinedPortRange()[0],
			host.getDefinedPortRange()[1],
			boundary,
			host.getNodePlaces()
		)
		
		cmd.addnl(runInsp)
		measuremtTimer.start()
		localTimeStamp = time.time()
		processSetter = job.resetTimeout()
		out = host.ssh.execCmd(
			cmd.getCmd(),
			convertInputString2Byte=True,
			processSetter=processSetter)	
		measuremtTimer.stop()
		localTimeStamp += ((time.time() - localTimeStamp) / 2)
		try:
			message = extractMessageWithBoundary(out[0], boundary)
			encodedData = json.loads(message)
			keys = set(['ram','disc','ports','arch','maxnodes','time','timezone'])	
			if not(encodedData != None and (set(encodedData.keys()) & keys) == keys):
				log.debug(message)
				raise NameError("some keys missing")
			host.setFreeDisc(encodedData['disc'])
			host.setFreeRam(encodedData['ram'])
			host.setCheckedPorts(encodedData['ports'])
			host.setCpuArch(encodedData['arch'])
			host.setMaxNodes(encodedData['maxnodes'])
			host.setPing(measuremtTimer.getAvg())
			host.setTimeDelta(float(localTimeStamp-encodedData['time']))
			host.setTimezone(encodedData['timezone'])
		except BaseException as e:
			if "No JSON object could be decoded" in str(e):
				log.debug("Hostinspection failed (start python bin failed)")
				HostController.writeFail(job, "Hostinspection failed (start python bin failed)")
			else:	
				log.exception(e)
				log.debug(out[0])
				log.debug(boundary)
				log.debug(out[1])
				HostController.writeFail(job, "Hostinspection failed")	
			return 
		
		HostController.writeSuccess(job)
		
		
	'''
	collect  data
	'''
	
	@staticmethod
	def runCollectDatabase(job):
		'''
		collects host dbs
		'''
		host, experiment, basePath, cwdPath = job.data.host, job.data.experiment, job.data.basePath, job.data.cwdPath
		receiver, lock = job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		localHostFolder = os.path.join(cwdPath,host.getLocalFolderCollectedData())
		try:
			shutil.rmtree(localHostFolder,ignore_errors=True)
			if not os.path.exists(localHostFolder):
				os.makedirs(localHostFolder,0o777)
			dataFiles = [PATHS.THINCLIENT_DB_FILE, PATHS.THINCLIENT_STD_OUT, PATHS.THINCLIENT_STD_ERR]
			for dataFile in dataFiles:
				remote = quote(os.path.join(host.workingDirExperiment, dataFile))
				local = [os.path.join(localHostFolder, dataFile)]
				scp = host.ssh.scp(local, remote, local2remote=False, recursive=False)
				if scp[0] == False:
					break
		except (shutil.Error, OSError, IOError) as e:
			scp = (False, e, None)		
		if scp[0] == True:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, scp[1])

	
	@staticmethod
	def runCollectHostData(job):
		'''
		collects host data
		'''
		host, basePath, receiver, lock, cwdPath = job.data.host, job.data.basePath, job.data.receiver, job.data.lock, job.data.cwdPath
		HostController.prepareHostSSH(host)
		localHostFolder = os.path.join(cwdPath,host.getLocalFolderCollectedData())
		try:
			if not os.path.exists(localHostFolder):
				os.makedirs(localHostFolder,0o777)
			remote = quote(os.path.join(host.workingDirExperiment,'*'))
			scp = host.ssh.scp([localHostFolder], remote, local2remote=False, recursive=True)
		except (shutil.Error, OSError, IOError) as e:
			scp = (False, e, None)		

		if scp[0] == True:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, scp[1])

	
	@staticmethod
	def runCollectNodeData(job):	
		'''
		collects node data
		'''
		host, basePath, receiver, lock, cwdPath= job.data.host, job.data.basePath, job.data.receiver, job.data.lock, job.data.cwdPath
		nodes = job.get(host.dbID())
		HostController.prepareHostSSH(host)
		localHostFolder = os.path.join(cwdPath,host.getLocalFolderCollectedData(),PATHS.THINCLIENT_NODES)
		try:
			if not os.path.exists(localHostFolder):
				os.makedirs(localHostFolder,0o777)
			nodeIDs = [node.dbID() for node in nodes]
			for nodeID in nodeIDs:
				if not os.path.exists(os.path.join(localHostFolder,PATHS.THINCLIENT_NODE_FOLDER.format(nodeID))):
					os.makedirs(os.path.join(localHostFolder,PATHS.THINCLIENT_NODE_FOLDER.format(nodeID)),0o777)
				remote = quote(os.path.join(host.workingDirExperiment, PATHS.THINCLIENT_NODES,PATHS.THINCLIENT_NODE_FOLDER.format(nodeID)))
				local = [localHostFolder]
				scp = host.ssh.scp(local, remote, local2remote=False, recursive=True)
				if scp[0] == False:
					pass
				if job.isTerminated():
					break	
					
		except (shutil.Error, OSError, IOError) as e:
			scp = (False, e, None)		
		if scp[0] == True:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, scp[1])
		
		
	'''
	preapare experiment
		- runCopyExperiment
		- runPrepareWorkingDir
	'''

	@staticmethod
	def runCopyExperiment(job):
		'''
		copy all exp files
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		
		# nodeGroup and experiment datafiles
		dataFiles = host.getDataFiles()
		# add prototpyes
		for prototype in host.getPrototypes():
			for dataFile in prototype.getDataFiles():
				dataFile.setPrototypeID(prototype.dbID())
				dataFiles.append(dataFile)
				
		for dataFile in dataFiles:		
			if dataFile.isNodegroupData():
				if dataFile.nodeGroupID() == None:
					groupDir = PATHS.THINCLIENT_NODEGROUP_DATA_ALLGROUPS
				else:
					groupDir = PATHS.THINCLIENT_NODEGROUP_DATA_SPECIFIC.format(dataFile.nodeGroupID())
				target = os.path.join(host.workingDirExperiment,PATHS.THINCLIENT_NODEGROUP_DATA,groupDir)
			elif dataFile.isPrototypeData():
				target = os.path.join(host.workingDirExperiment, PATHS.THINCLIENT_PROTOTYPE_BUNDLE,
									PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(dataFile.getPrototypeID()))
			else:
				target = host.workingDirExperiment
			if dataFile.targetSubDir() != None:
				target = os.path.join(target, dataFile.targetSubDir()) 			
			# check access
			files = glob.glob(dataFile.path())
			if len(files) == 0:
				log.error("path not found:{0}".format(dataFile.path()))
				HostController.writeFail(job, '\t"{0}": path not found:{1}'.format(host.identName,dataFile.path()))
				return			
			recursive = dataFile.isRecursive()	
			if dataFile.targetPath() != None:
				target = os.path.join(target, dataFile.targetPath())
			elif target[-1] != '/':
				target = target + '/'	
			scp = host.ssh.scp(files, quote(target), local2remote=True, recursive=recursive)
			if scp[0] == False:
				break
			if job.isTerminated():
				break
				
		if scp[0] == True:
			HostController.writeSuccess(job)
		else:
			log.debug(scp[1])
			HostController.writeFail(job, scp[1])

	
	@staticmethod
	def runPrepareWorkingDirRepeatExperiment(job):
		log.error("not refactored")
		HostController.writeFail(job,"not refactored")
		return
		'''
		prepare directory
		'''
		host, experiment, receiver, lock = job.data.host, job.data.experiment, job.data.receiver, job.data.lock 
		HostController.prepareHostSSH(host)
		# cleanup working dir
		
		# cd exp, python client.py --reset 
		cmd = 'cd {0} \n '
	
		client = PATHS.THINCLIENT_MAIN

		testOk = 'client reset successful'
		testFail = 'failed'

		path = host.workingDirExperiment	
		
		cmd = 'cd {0} \n {1} {2} --reset 2> resetLog \n if [ $(echo $?) -eq "0" ]; then echo "{3}"; else echo "{4}"; cat resetLog; fi \n rm resetLog'
		cmd = cmd.format(quote(path), quote(host.python), quote(client), testOk, testFail)
			
		out = host.ssh.execCmd(cmd,
							convertInputString2Byte=True)
		
		if testOk in out[0]:
			result = True
		elif testFail in out[0]:
			result = False
			msg = 'error during reset; "{0}"'.format(out[0][out[0].find(testFail)+len(testFail)+1:])
		else:
			result = False
			msg = 'Internal Error; {0} {1}'.format(out[0],out[1])

		lock.acquire()
		if result:
			receiver['ok'] += 1
			receiver['okHosts'].append(host)
		else:
			receiver['fail'] += 1
			receiver['failedHosts'].append(host)
			receiver['logs'].append('\t"{0}": return code: {1}, error: {2}'.format(host.identName,out[2],msg))
		lock.release()
		
	
	@staticmethod
	def runRemoveExperiment(job):
		'''
		remove experiment
		'''
		host, experiment, receiver, lock = job.data.host, job.data.experiment, job.data.receiver, job.data.lock 
		HostController.prepareHostSSH(host)
		# build cmd
		cmd = CommandBuilder(job)
		cmd.rmExp()
		out = host.ssh.execCmd(
			cmd.getCmd(),
			convertInputString2Byte=True)	
		if out[2] == 0:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, out[1])	
		
	
	@staticmethod
	def runResetHosts(job):
		'''
		resets host
		'''
		host, experiment, receiver, lock = job.data.host, job.data.experiment, job.data.receiver, job.data.lock 
		HostController.prepareHostSSH(host)
		# build cmd
		cmd = CommandBuilder(job)
		cmd.rmTestbed()
		out = host.ssh.execCmd(
			cmd.getCmd(),
			convertInputString2Byte=True)	
		if out[2] == 0:
			HostController.writeSuccess(job)
		else:
			HostController.writeFail(job, out[1])	
		
	@staticmethod
	def runPrepareWorkingDir(job):
		'''
		prepare directory
		'''
		host, experiment, receiver, lock = job.data.host, job.data.experiment, job.data.receiver, job.data.lock 
		HostController.prepareHostSSH(host)
		
		hostIdFile = PATHS.THINCLIENT_HOST_ID_FILE
		experimentIdFile = PATHS.THINCLIENT_EXPERIMENT_ID_FILE
		
		# check target subdir of dataFiles
		dataFiles = host.getDataFiles()
		targetDirExpData = []
		targetDirNodeGroupData = []
		for dataFile in dataFiles:
			if dataFile.targetSubDir() != None:
				if dataFile.isNodegroupData():
					if dataFile.nodeGroupID() == None:
						groupDir = PATHS.THINCLIENT_NODEGROUP_DATA_ALLGROUPS
					else:
						groupDir = PATHS.THINCLIENT_NODEGROUP_DATA_SPECIFIC.format(dataFile.nodeGroupID())
					targetDirNodeGroupData.append('{0}/{1}/'.format(groupDir,dataFile.targetSubDir()))
				else:
					targetDirExpData.append(dataFile.targetSubDir())
		# nodegroup dirs
		for nodeGroup in host.getAssignedNodeGroups():
			targetDirNodeGroupData.append(PATHS.THINCLIENT_NODEGROUP_DATA_SPECIFIC.format(nodeGroup.dbID()))
		targetDirNodeGroupData.append(PATHS.THINCLIENT_NODEGROUP_DATA_ALLGROUPS)
		
		# prototpyes
		for prototype in host.getPrototypes():
			# data files
			for dataFile in prototype.getDataFiles():
				path = os.path.join(PATHS.THINCLIENT_PROTOTYPE_BUNDLE,
									PATHS.THINCLIENT_PROTOTYPE_BUNDLE_FOLDER.format(prototype.dbID()))
				if dataFile.targetSubDir() != None:
					path = os.path.join(path, dataFile.targetSubDir())
				targetDirExpData.append(path)
		
		# create cmd: ... && mkdir -p subDir/bla && mkdir -p subdir2 ...
		targetDirExpData = ' \n '.join(['mkdir -p {0}'.format(quote(subDir)) for subDir in targetDirExpData])
		targetDirNodeGroupData = ' \n '.join(['mkdir -p {0}'.format(quote(subDir)) for subDir in targetDirNodeGroupData])
		
		cmdBuilder = CommandBuilder(job)
		cmdBuilder.rmExp()
		cmdBuilder.gotoExp()
		# hostid
		cmdBuilder.addnl("echo {0} > {1}".format(host.dbID(),quote(PATHS.THINCLIENT_HOST_ID_FILE)))
		# expid
		cmdBuilder.addnl("echo {0} > {1}".format(experiment.dbID(),quote(PATHS.THINCLIENT_EXPERIMENT_ID_FILE)))
		# node foöder
		cmdBuilder.mkdir(PATHS.THINCLIENT_NODES)
		# nodegroup folder
		cmdBuilder.mkdir(PATHS.THINCLIENT_NODEGROUP_DATA)
		# exp data folder
		cmdBuilder.gotoExp()
		cmdBuilder.addnl(targetDirExpData)		
		# nodegroup data folder
		cmdBuilder.gotoExp()
		cmdBuilder.cd(PATHS.THINCLIENT_NODEGROUP_DATA)
		cmdBuilder.addnl(targetDirNodeGroupData)
		# check created folder
		cmdBuilder.gotoExp()
		check1 = cmdBuilder.checkFileExists(PATHS.THINCLIENT_HOST_ID_FILE)
		check2 = cmdBuilder.checkFileExists(PATHS.THINCLIENT_EXPERIMENT_ID_FILE)
		check3 = cmdBuilder.checkFileExists(PATHS.THINCLIENT_NODES)
		check4 = cmdBuilder.checkFileExists(PATHS.THINCLIENT_NODEGROUP_DATA)
					
		#log.debug(cmdBuilder.getCmd())
		out = host.ssh.execCmd(
			cmdBuilder.getCmd(),
			convertInputString2Byte=True)
			
		if check1[0] in out[0] and check2[0] in out[0] and check3[0] in out[0] and check4[0] in out[0]:
			HostController.writeSuccess(job)
		else:
			log.debug(out[0])
			log.debug(out[1])
			HostController.writeFail(job, out[1])
			
	
	@staticmethod
	def runStartExperiment(job):
		'''
		set experiment starttime
		invokes thin client
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		startTime = job.get('expStartTime')
		HostController.prepareHostSSH(host)
		
		tcStartTimeFile = PATHS.THINCLIENT_EXPSTART_FILE
		tcPidFile = PATHS.THINCLIENT_PID_FILE
		tcStdErr = PATHS.THINCLIENT_STD_ERR
		
		testOk = 'pid is running'
		testFail = 'pid is not running'
		
		cmdBuilder = CommandBuilder(job)
		cmdBuilder.gotoExp()
		beforeExists, beforeNotExists = cmdBuilder.checkFileExists(tcStartTimeFile)
		cmdBuilder.addnl('echo "{0}" > {1}'.format(startTime,quote(tcStartTimeFile)))
		afterExists, afterNotExists = cmdBuilder.checkFileExists(tcStartTimeFile)
		
		out = host.ssh.execCmd(cmdBuilder.getCmd(),convertInputString2Byte=True)

		if beforeNotExists in out[0] and afterExists in out[0]:
			HostController.writeSuccess(job)
		else:
			log.debug(cmdBuilder.getCmd())
			log.debug(out[0])
			log.debug(out[1])
			if beforeExists in out[0]:
				HostController.writeFail(job, "tc startTimeFile exists before")
			elif afterNotExists in out[0]:
				HostController.writeFail(job, "tc startTimeFile write failed")
			else:
				HostController.writeFail(job, "unkown error")

	@staticmethod
	def runTerminateThinClient(job):
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)
		cmdBuilder = CommandBuilder(job)
		cmdBuilder.gotoExp()

		tcPidFile = PATHS.THINCLIENT_PID_FILE
		cmdBuilder.addnl('pkill -KILL -P $(cat {0})'.format(quote(tcPidFile)))
		cmdBuilder.addnl('sleep 2')
		cmdBuilder.addnl('pkill -KILL -P $(cat {0})'.format(quote(tcPidFile)))
		cmdBuilder.addnl('kill -KILL $(cat {0})'.format(quote(tcPidFile)))
		ok = randomString(10)
		cmdBuilder.addnl('echo "{0}"'.format(ok))

		out = host.ssh.execCmd(cmdBuilder.getCmd(),convertInputString2Byte=True)
		if ok in out[0]:
			HostController.writeSuccess(job)
			log.debug(out[0])
			log.debug(out[1])
		else:
			log.debug(cmdBuilder.getCmd())
			log.debug(out[0])
			log.debug(out[1])
			HostController.writeFail(job, "unkown error")


	@staticmethod
	def runSendSignalToThinClient(job):
		'''
		send specific signal
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		signal = job.get('signal')
		HostController.prepareHostSSH(host)
		# check thin Client startup
		tcStdErr = PATHS.THINCLIENT_STD_ERR
		tcPidFile = PATHS.THINCLIENT_PID_FILE
		signalScript = PATHS.THINCLIENT_SENDSIGNAL

		testOk = 'pid is running'
		testFail = 'pid is not running'
		
		signal = SIGNALS.getKey(signal)

		path = host.workingDirExperiment	
		
		cmd = 'cd {0} \n {6} {7} --signal {5} --pid $(cat {1}) \n if [ $(echo $?) -eq "0" ]; then echo "{3}"; else echo "{4}"; cat {2}; fi'
		cmd = cmd.format(quote(path), quote(tcPidFile), quote(tcStdErr), testOk, testFail, quote(signal),
							quote(host.python), quote(signalScript))

		out = host.ssh.execCmd(cmd,
							convertInputString2Byte=True)
		
		if testOk in out[0]:
			HostController.writeSuccess(job)
		elif testFail in out[0]:
			msg = 'ThinClient is not running;'
			HostController.writeFail(job, msg)
		else:
			msg = 'Internal Error; {0} {1}'.format(out[0],out[1])
			HostController.writeFail(job, msg)

	@staticmethod
	def runStartThinClient(job):
		'''
		start thin clients
		'''
		host, receiver, lock = job.data.host, job.data.receiver, job.data.lock
		HostController.prepareHostSSH(host)

		path = host.workingDirExperiment
		
		tcBin = PATHS.THINCLIENT_MAIN
		tcStdOut = PATHS.THINCLIENT_STD_OUT
		tcStdErr = PATHS.THINCLIENT_STD_ERR
		tcPidFile = PATHS.THINCLIENT_PID_FILE

		pythonArgs = '-OO '
		thinClientArgs = '-vv'

		okMessage = 'thinclient running'
		failMessage = 'thinclient startup failed'
		
		# cd workingDir, check client is running
		# nohup py3bin thinClientBin > stdoutfile  2> stderr file, save thinClientPid
		# sleep, check startup
		cmd = 'cd {0} \n  if [ -e {5} ]; then kill -0 $(cat {5}); if [ $(echo $?) -eq "0" ]; then echo "{8}"; exit ; fi ; fi \n  \
		nohup {1} {6} {2} {7} > "{3}" 2> "{4}" < /dev/null & \n tcPid=$! && echo "$tcPid" > "{5}" \n \
		sleep 2 \n kill -0 $(cat {5}) \n if [ $(echo $?) -eq "0" ]; then echo "{8}"; else echo "{9}"; cat "{4}" ; fi'
		cmd = cmd.format(
				quote(path), #0# working dir
				quote(host.python), #1# python3
				quote(tcBin), #2# thin Client bin
				quote(tcStdOut), #3# STD_OUT
				quote(tcStdErr), #4# STD_ERR
				quote(tcPidFile), #5# thinClient PID
				pythonArgs, #6# pythonArgs args
				thinClientArgs, #7# pythonArgs args
				okMessage, #8# ok message
				failMessage #9# fail message
				)
				
		out = host.ssh.execCmd(cmd, 
			convertInputString2Byte=True)

		if okMessage in out[0]:
			HostController.writeSuccess(job)
		elif failMessage in out[0]:
			msg = "thinclient startup failed"
			log.debug(msg)
			log.debug(out[1])
			HostController.writeFail(job, "{0}: {1}".format(msg,out[1]))
		else:
			msg = 'Internal Error; {0} {1}'.format(out[0],out[1])
			log.error(msg)
			HostController.writeFail(job, msg)


	
