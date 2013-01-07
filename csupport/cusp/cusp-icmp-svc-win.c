/*
	This file is part of BubbleStorm.
	Copyright © 2008-2013 the BubbleStorm authors

	BubbleStorm is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BubbleStorm is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <windows.h>
#include <stdio.h>
#include <winsock2.h>

#include "cusp-icmp-svc.h"

SERVICE_STATUS          ServiceStatus; 
SERVICE_STATUS_HANDLE   hStatus; 
 
int logWrite(const char* str)
{
#if 0
#define LOGFILE "C:\\servicelog.txt"
   FILE* log;
   log = fopen(LOGFILE, "a+");
   if (log == NULL)
      return -1;
   fprintf(log, "%s\n", str);
   fclose(log);
#endif
   return 0;
}

void serviceDebug(const char* msg)
{
	logWrite(msg);
}

void serviceFail(const char* msg)
{
	ServiceStatus.dwCurrentState = SERVICE_STOPPED; 
	ServiceStatus.dwWin32ExitCode = -1; 
	SetServiceStatus(hStatus, &ServiceStatus); 
}

// void die(const char* op) {
    // const char buf[1024] = "failed";
    // FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, (LPTSTR)buf, sizeof(buf)-1, 0);
	// char buf2[1024];
    // sprintf(buf2, "%s: %s\n", op, buf);
	// WriteToLog(buf2);
    // exit(-1);
// }

void ControlHandler(DWORD request) 
{ 
   switch(request) 
   { 
      case SERVICE_CONTROL_STOP: 
      case SERVICE_CONTROL_SHUTDOWN: 
         // serviceDebug("Service stopping.");
         ServiceStatus.dwWin32ExitCode = 0; 
         ServiceStatus.dwCurrentState = SERVICE_STOPPED; 
		 icmpServiceStop();
         break;
        
      default:
         break;
    } 
	// report to SCM
    SetServiceStatus(hStatus, &ServiceStatus);
}

void ServiceMain(int argc, char** argv) 
{ 
	ServiceStatus.dwServiceType = SERVICE_WIN32; 
	ServiceStatus.dwCurrentState = SERVICE_START_PENDING; 
	ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
	ServiceStatus.dwWin32ExitCode = 0; 
	ServiceStatus.dwServiceSpecificExitCode = 0; 
	ServiceStatus.dwCheckPoint = 0; 
	ServiceStatus.dwWaitHint = 0; 

	hStatus = RegisterServiceCtrlHandler("CUSP ICMP Service", (LPHANDLER_FUNCTION)ControlHandler); 
	if (hStatus == (SERVICE_STATUS_HANDLE)0) 
		return; 
	
	// report to SCM
	ServiceStatus.dwCurrentState = SERVICE_RUNNING; 
	SetServiceStatus(hStatus, &ServiceStatus);

	icmpServiceMain();
	
	return; 
}

int main()
{ 
	SERVICE_TABLE_ENTRY ServiceTable[2];
	ServiceTable[0].lpServiceName = "CUSP ICMP Service";
	ServiceTable[0].lpServiceProc = (LPSERVICE_MAIN_FUNCTION)ServiceMain;
	ServiceTable[1].lpServiceName = NULL;
	ServiceTable[1].lpServiceProc = NULL;
	StartServiceCtrlDispatcher(ServiceTable);
	return 0;
}
