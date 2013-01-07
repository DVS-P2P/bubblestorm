#!/usr/bin/env bash

# checks installed python version
# starts master
# os support: linux + osx

# args: 
# --find-python   -> do search for python
# --optimized    -> runs python with -OO


DOWNLOAD_VERSION="2.7"
ONLY_DOWNLOAD_STATIC_PYTHON_THEN_EXIT=0

SEARCH_FOR_INSTALLED_BIN=0 # 1 -> search for system installed python; 0 -> use $USE_PYTHON_BIN python interpreter
USE_PYTHON_BIN=__PLACEHOLDER_PYTHON__
optimized=" "


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check args, remove startscript specific args
MASTER_ARGS=()
index=0
for i in "$@"; do
	if ([ "$i" == '--downloadpython' ]); then
		ONLY_DOWNLOAD_STATIC_PYTHON_THEN_EXIT=1
	elif ([ "$i" == '--optimized' ]); then
		optimized='-OO'
	elif ([ "$i" == '--find-python' ]); then
		SEARCH_FOR_INSTALLED_BIN=1
	else
		MASTER_ARGS[index]="$i"
		index=$((index+1))
	fi
done 

# load static python
if [ ! -e "python-static" ]; then
	echo "download static linked python"
	curl -o "python-static" "http://pts-mini-gpl.googlecode.com/svn/trunk/staticpython/release/python$DOWNLOAD_VERSION-static"
	chmod +x "python-static"
fi

# only download python?
if [ $ONLY_DOWNLOAD_STATIC_PYTHON_THEN_EXIT = 1 ]; then
	exit
fi

####
#### start master, check python version
####

# locate system-python bin
if [ $SEARCH_FOR_INSTALLED_BIN = 1 ]; then
	PYTHON_BIN=("python3.3" "python3.2" "python3.1" "python3" "python2.7" "python2.6" "python2" "python")

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
			PYTHON_INSTALLED=0
		fi
	fi
fi

# start master
if [ $SEARCH_FOR_INSTALLED_BIN = 1 ]; then
	if [ $PYTHON_INSTALLED = 1 ]; then
		PYTHON_PATH=$(which $FOUND_CMD)
		echo "start master (system-installed python), use $PYTHON_PATH"
		$PYTHON_PATH $optimized -m testbed.scripts.startMaster ${MASTER_ARGS[@]}
	else
		echo "start master (static linked python), use $DOWNLOAD_VERSION"
		if test "`uname`" = Darwin; then
			if [ ! -e "python-static.darwin" ]; then
				echo "download static linked python (darwin)"
				curl -o "python-static.darwin" "http://pts-mini-gpl.googlecode.com/svn/trunk/staticpython/release.darwin/python$DOWNLOAD_VERSION-static"
				chmod +x "python-static.darwin"
			fi
			./python-static.darwin $optimized -m testbed.scripts.startMaster ${MASTER_ARGS[@]}
		else	 
			./python-static $optimized -m testbed.scripts.startMaster ${MASTER_ARGS[@]}
		fi
	fi
else
	echo "start master (given python), use $USE_PYTHON_BIN"
	$USE_PYTHON_BIN $optimized -m testbed.scripts.startMaster ${MASTER_ARGS[@]}
fi


