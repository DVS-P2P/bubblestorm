#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import stat
import logging
from logging.handlers import SocketHandler
from logging import StreamHandler


from .base.Utils import askUserOption

cwd = os.getcwd()
basePath = os.path.abspath('{0}{1}'.format(os.path.dirname(__file__), os.sep))

rootlogger = logging.getLogger('')
rootlogger.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.ERROR)
socketh = SocketHandler('localhost', 7777)
rootlogger.addHandler(console_handler)
rootlogger.addHandler(socketh)
log = logging.getLogger(__name__)

    
def askOverwrite(obj):
	return 'y' == askUserOption('"{0}": do you want to overwrite?'.format(obj), ['y','n'], 'y', 'n')

def makeExecutalble(filePath):
	oldRights = os.stat(filePath).st_mode	
	os.chmod(filePath, stat.S_IXGRP | stat.S_IXOTH | stat.S_IXUSR | oldRights)

def copyFile(filePath, fileName):
	dstFile = os.path.join(cwd,fileName)
	if os.path.exists(dstFile):
		if not askOverwrite(fileName):
			return 
	log.info('copy: {0}'.format(fileName))
	shutil.copy2(filePath, dstFile)

def copyFolder(folderPath, dirName):
	dstDir = os.path.join(cwd,dirName)
	if os.path.exists(dstDir):
		if not askOverwrite(dirName):
			return 
		else:
			shutil.rmtree(dstDir)
	log.info('copy: {0}'.format(dirName))
	shutil.copytree(folderPath, dstDir)

def replaceTextInFile(path, placeholder, newText):	
	with open(path, 'r') as f:
		orgText = f.read()
	with open(path, 'w') as f:
		f.write(orgText.replace(placeholder, newText))


if __name__ == "__main__":
	try:
	    log.info("init working dir")

	    copyFile(os.path.join(basePath,'scripts','Makefile'),'Makefile')
	    copyFile(os.path.join(basePath,'scripts','config.ini'),'config.ini')
	    copyFile(os.path.join(basePath,'scripts','run.sh'),'run.sh')
	    makeExecutalble('run.sh')

	    copyFolder(os.path.join(basePath,'sql'), 'sql')

	    pyBin = '"{0}"'.format(os.path.normpath(sys.executable))
	    replaceTextInFile('run.sh', '__PLACEHOLDER_PYTHON__', pyBin)

	except BaseException as e:
		log.exception(e)
