#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from .Utils import enum
import signal
import logging

log = logging.getLogger(__name__)

# variables and alias
COMMAND_VARIABLES = enum(OWN_IP='$ip',
							OWN_PORT='$port',
							SEED='$seed',
							DB='$database',
							LOG_INTERVAL='$loginterval',
							ALIAS='$[{0}]',
							ALIAS_REG='\$\[([\w]+)\]'							
)

# runtime engine command string
RUNTIME_ENGINE = enum(COMMAND='@config --seed {0} --db {1} --log {2} --'.format(
										COMMAND_VARIABLES.SEED,COMMAND_VARIABLES.DB,COMMAND_VARIABLES.LOG_INTERVAL))

# file/folder paths
#
# host working dir/
#experiment_[id]/
#
'''

master folder structure:

testbed folder/
	run.sh
	testbed
	Makefile
	...
	COLLECTED_DATA
		COLLECTED_EXPERIMENT_FOLDER
			COLLECTED_DATA_HOST
				same structure as on the hosts
			...
		...

host folder structure:

host working dir/
	THINCLIENT_PYTHON
	THINCLIENT_INSPECT_SCRIPT
	THINCLIENT_EXPERIMENT_FOLDER/
		THINCLIENT_SENDSIGNAL
		THINCLIENT_STD_OUT
		THINCLIENT_STD_ERR
		THINCLIENT_PID_FILE
		THINCLIENT_HOST_ID_FILE
		THINCLIENT_EXPERIMENT_ID_FILE
		THINCLIENT_EXPSTART_FILE
		THINCLIENT_MAIN
		THINCLIENT_IS_READY_FILE
		THINCLIENT_FINISHED_WORK
		THINCLIENT_DB_FILE
		NODE_DATABASE
		
		THINCLIENT_NODEGROUP_DATA
			THINCLIENT_NODEGROUP_DATA_ALLGROUPS
			THINCLIENT_NODEGROUP_DATA_SPECIFIC
			...
		THINCLIENT_PROTOTYPE_BUNDLE
			THINCLIENT_PROTOTYPE_BUNDLE_FOLDER
				THINCLIENT_PROTOTYPE_BUNDLE_BIN
				THINCLIENT_PROTOTYPE_BUNDLE_LIBS
				THINCLIENT_PROTOTYPE_BUNDLE_DATA
			...
		THINCLIENT_NODES/
			THINCLIENT_NODE_FOLDER
				THINCLIENT_NODE_STDOUT_FILE
				THINCLIENT_NODE_STDERR_FILE
			...
		
		
'''				
PATHS = enum(THINCLIENT_NODES='nodes', # contains all nodes
			THINCLIENT_NODE_FOLDER='id_{0}', # node folder
			THINCLIENT_NODE_STDOUT_FILE='std_out_{0}.txt', # prototype stdout file
			THINCLIENT_NODE_STDERR_FILE='std_err_{0}.txt', # prototype stderr file
			THINCLIENT_NODEGROUP_DATA='nodeGroupData', # node group data folder
			THINCLIENT_NODEGROUP_DATA_ALLGROUPS='allNodeGroups', # all nodes data folder
			THINCLIENT_NODEGROUP_DATA_SPECIFIC='nodeGroup_{0}', # node group specific data
			THINCLIENT_PROTOTYPE_BUNDLE='prototypeBundle', # contains all prototypes
			THINCLIENT_PROTOTYPE_BUNDLE_FOLDER='prototype_{0}', # prototype folder
			THINCLIENT_PROTOTYPE_BUNDLE_BIN='bin', # prototype bin
			THINCLIENT_PROTOTYPE_BUNDLE_LIBS='libs', # prototype libs folder
			THINCLIENT_PROTOTYPE_BUNDLE_DATA='data', # prototype data folder
			THINCLIENT_EXPERIMENT_FOLDER='experiment_{0}', # experiment folder
			THINCLIENT_STD_OUT='tc_out', # thin client stdout
			THINCLIENT_STD_ERR='tc_err', # thin client stderr
			THINCLIENT_PID_FILE='tc_pid', # thin client process id
			THINCLIENT_HOST_ID_FILE='host_id', # host id
			THINCLIENT_EXPERIMENT_ID_FILE='experiment_id', # experiment id
			THINCLIENT_MAIN='client.py', # python startup file
			THINCLIENT_EXPSTART_FILE='exp_start_time', # experiment starttime, utc
			THINCLIENT_STATE_FILE='tc_state', # thin client state
			THINCLIENT_DB_FILE='exp.db',  # experiment database
			THINCLIENT_PYTHON='python', # python bin
			THINCLIENT_INSPECT_SCRIPT='inspectHost.py', # inspect host script
			THINCLIENT_SENDSIGNAL='sendSignal.py', # send unix signals
			STATIC_PYTHON3_PATH='python-static', # python static bin
			NODE_DATABASE='experiment_node.db', # node db
			COLLECTED_DATA='collectedData', # contains collected data
			COLLECTED_EXPERIMENT_FOLDER='experiment_{0}', # experiment folder
			COLLECTED_DATA_HOST='host_{0}', # contains collected data for given host
			SSH_KNOWN_HOSTS='knownHosts', # contains all host keys
			SSH_MASTER_CONNECTIONS_PATH='sshConnections', # store all ssh master connections
			CONFIG_FILE='config.ini'
			)
	
# workload events		
WORKLOAD_EVENTS = enum(LINEAR_JOIN='LinearJoin',
						LINEAR_LEAVE='LinearLeave',
						SIMULTANEOUS_JOIN='SimultaneousJoin',
						SIMULTANEOUS_LEAVE='SimultaneousLeave',
						SIMULTANEOUS_CRASH='SimultaneousCrash',
						SIG_USR_1='SigUsr1',
						SIG_USR_2='SigUsr2',
						EXPONENTIAL_JOIN='ExponentialJoin'
						)

# nodegroup relations
NODEGROUP_HOST_RELATION = enum(BOUND='bound', EXCLUSION='exclusion')
NODEGROUP_HOST_RELATION.assertUniqueValues()

# node events
NODE_EVENTS = enum(START='start',
					QUIT='quit',
					CRASH='crash',
					USR_SIG_1='usr_sig_1',
					USR_SIG_2='usr_sig_1')
	
LOGS = enum(NODE_CONTROLLER='live experiment/node controller');

# thin client, node controller statistics
STATISTIC = enum(NODE_EVENT_LEAVE_TIMEOUTS='live experiment/leave timeouts',
					NODE_EVENT_EXECUTED_EVENTS='live experiment/executed events',
					NODE_EVENT_CRASHES='live experiment/crashes',
					NODE_EVENT_LEAVES='live experiment/leaves',
					NODE_EVENT_JOINS='live experiment/joins',
					RUNNING_NODES='live experiment/running nodes',
					RUNNING_NODES_EXPECTED='live experiment/running nodes (expected)')
STATISTIC.assertUniqueValues()

# unix signals
SIGNALS = enum(SIGINT	=signal.SIGINT	, # Interrupt from keyboard
       			SIGQUIT	=signal.SIGQUIT, # Quit from keyboard
       			SIGKILL	=signal.SIGKILL, # Kill signal
       			SIGTERM	=signal.SIGTERM, 	# Termination signal
       			SIGUSR1	=signal.SIGUSR1, # User-defined signal 1
       			SIGUSR2	=signal.SIGUSR2, # User-defined signal 2
       			SIGCONT = signal.SIGCONT, # Cont signal
       			SIGCHLD = signal.SIGCHLD # child process terminates
				)

# map: event signal - unix signal
EVENT_SIGNALS = enum(QUIT=SIGNALS.SIGINT)

CLIENT_SIGNALS = enum(  CHECK=SIGNALS.SIGCONT,
						ABORT_EXP=SIGNALS.SIGUSR2,
						)

TC_STATES = enum(
	UNDEFINED=0,
	
	PREPARE_START=10,
	WAIT_FOR_STARTSIGNAL=20,
	RUNNING_EXP=30,
	OBSERVE_NODES=35,
	STOP_NODES=40,
	PROCESS_DBS=50,
	NORMAL_SHUTDOWN=60,
		
	ERR_UNKOWN=1000,
	ERR_INIT=1005,
	ERR_PREPARE=1010,
	ERR_WAIT_START=1020,
	ERR_RUNNING_EXP=1030,
	ERR_OBSERVE_NODES=1035,
	ERR_STOP_NODES=1040,
	ERR_PROCESS_DBS=1050,
	ERR_EXP_ABORTED=1060
)
TC_STATES.assertUniqueValues()
      
