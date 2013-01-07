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
#include <time.h>
#include <winsock2.h>
#include <mstcpip.h>
#include <ws2tcpip.h>
#include <inttypes.h>

#include "icmp-packet.h"
#include "cusp-icmp-svc.h"

int running = 0;
int sockRaw = 0;

#define SERVICE_BIND_HOST "127.0.0.1"
#define SERVICE_BIND_PORT 8585

#define MAX_CLIENTS 32
#define MAX_CTRL_PACKET 2048

#define MAX_INTERFACES 16

typedef struct {
	union {
		uint32_t from;
		uint32_t reporter;
	};
	uint32_t to; // (0 -> enable listening for fromport)
	uint16_t fromport;
	uint16_t toport;
	uint16_t code;
	uint16_t datalen; // length of the following data
} ICMPCtrlHeader;

typedef struct {
	int sock;
	int bufFill;
	uint16_t filterPort;
	char buf[MAX_CTRL_PACKET];
} ClientInfo;

typedef struct {
	ipaddress addr;
	int sock;
} InterfaceInfo;

void processCommand(ClientInfo* c, ICMPCtrlHeader* cmd)
{
	serviceDebug("processCommand");
	if (cmd->to == 0) {
		serviceDebug("client listen for packet");
		// filter request
		c->filterPort = cmd->fromport;
	} else {
		// send ICMP
		uint8_t packet[IP_PACKET_LEN];
		int packetlen = sizeof(packet);
		int skip = cusp_icmp_send(packet, &packetlen,
			(uint8_t*) (cmd + 1), cmd->datalen,
			cmd->from, cmd->fromport,
			cmd->to, cmd->toport,
			0, cmd->code);
		if (skip < 0) {
			serviceDebug("cusp_icmp_send: payload too long");
			return;
		}
		serviceDebug("send ICMP");
		/* Send ICMP error to the UDPfrom address */
		struct sockaddr_in dest;
		memset(&dest, 0, sizeof(dest));
		dest.sin_family = PF_INET;
		dest.sin_addr.s_addr = htonl(cmd->from);
		if (sendto(sockRaw, (char*)packet+skip, packetlen-skip, 0,
				(struct sockaddr *)&dest, sizeof(dest)) < 0) {
			serviceDebug("sendto() ICMP error");
			return;
		}
    }
}

int clientRead(ClientInfo* c)
{
	int r;
	ICMPCtrlHeader* h = (ICMPCtrlHeader*) c->buf;
	if (c->bufFill < sizeof(ICMPCtrlHeader)) {
		serviceDebug("read header");
		int len = sizeof(ICMPCtrlHeader) - c->bufFill;
		r = recv(c->sock, c->buf + c->bufFill, len, 0);
		c->bufFill += r;
		// header complete, now convert to host byte order
		h->from = ntohl(h->from);
		h->to = ntohl(h->to);
		h->fromport = ntohs(h->fromport);
		h->toport = ntohs(h->toport);
		h->code = ntohs(h->code);
		h->datalen = ntohs(h->datalen);
	} else {
		serviceDebug("read data");
		if (h->datalen + sizeof(ICMPCtrlHeader) > MAX_CTRL_PACKET) {
			serviceDebug("ICMP control packet buffer overflow!");
			return 0;
		}
		int len = h->datalen + sizeof(ICMPCtrlHeader) - c->bufFill;
		r = recv(c->sock, c->buf + c->bufFill, len, 0);
		// char buf[128];
		// sprintf(buf, "read: %d, len: %d", r);
		// serviceDebug(buf);
		c->bufFill += r;
	}
	if ((c->bufFill >= sizeof(ICMPCtrlHeader)) && (c->bufFill >= sizeof(ICMPCtrlHeader) + h->datalen)) {
		processCommand(c, h);
		c->bufFill = 0;
	}
	return r;
}

int makeRawSocket(u_long bindAddr)
{
	int sockRaw = WSASocket(AF_INET, SOCK_RAW, IPPROTO_ICMP, 0, 0, 0);
    if (sockRaw == INVALID_SOCKET) {
        serviceDebug("WSASocket raw failed!");
		return INVALID_SOCKET;
	}
	struct sockaddr_in service;
	service.sin_family = AF_INET;
	service.sin_addr.s_addr = bindAddr;
	service.sin_port = htons(0);
	if (bind(sockRaw, (SOCKADDR*) &service, sizeof(service)) == SOCKET_ERROR) {
		serviceDebug("bind raw failed!");
		return INVALID_SOCKET;
	}
	DWORD outSize;
	DWORD ctlBuf = 3; // RCVALL_IPLEVEL
	if (WSAIoctl(sockRaw, SIO_RCVALL, &ctlBuf, sizeof(ctlBuf), NULL, 0, &outSize, NULL, NULL) == SOCKET_ERROR) {
        serviceDebug("ioctrl raw failed!");
		return INVALID_SOCKET;
	}
	return sockRaw;
}

void updateInterfaces(int sock, InterfaceInfo* iInfo, int* iInfoLen)
{
	INTERFACE_INFO ifaceList[MAX_INTERFACES];
	unsigned long bytesRet;
	if (WSAIoctl(sock, SIO_GET_INTERFACE_LIST, 0, 0, &ifaceList, sizeof(ifaceList), &bytesRet, 0, 0) == SOCKET_ERROR) {
		serviceDebug("ioctl get interfaces fail");
		return;
	}

	int ifaceCount = bytesRet / sizeof(INTERFACE_INFO);
	// printf("found %d interfaces\n", ifaceCount);

	char ifaceExisting[MAX_INTERFACES];
	memset(ifaceExisting, 0, MAX_INTERFACES);
	
	int i, j;
    for (i = 0; i < ifaceCount; i++) {
        struct sockaddr_in *addr = (struct sockaddr_in *) &(ifaceList[i].iiAddress);
		u_long laddr = addr->sin_addr.S_un.S_addr;
		ipaddress my_addr = ntohl(laddr);
		
		// char buf[64];
		// sprintf(buf, "Addr: %s", inet_ntoa((addr->sin_addr)));
		// serviceDebug(buf);
		
		int found = 0;
		for (j = 0; j < *iInfoLen; j++) {
			if (iInfo[j].addr == my_addr) {
				found = 1;
				break;
			}
		}
		if (found) {
			ifaceExisting[j] = 1;
		} else {
			// add interface
			serviceDebug("add iface");
			if (*iInfoLen < MAX_INTERFACES) {
				InterfaceInfo* ii = iInfo + *iInfoLen;
				ii->addr = my_addr;
				ii->sock = makeRawSocket(laddr);
				if (ii->sock != INVALID_SOCKET) {
					ifaceExisting[*iInfoLen] = 1;
					(*iInfoLen)++;
				} else
					serviceDebug("Could not create raw socket!");
			} else
				serviceDebug("Too many interfaces!");
		}
    }
	
	// remove non-existring interfaces
	for (i = 0; i < *iInfoLen; i++) {
		if (!ifaceExisting[i]) {
			serviceDebug("remove iface");
			if (closesocket(sockRaw) != 0)
				serviceFail("closesocket raw failed!");
			(*iInfoLen)--;
			// move last entry to free space
			if (i != *iInfoLen) {
				memcpy(iInfo + i, iInfo + *iInfoLen, sizeof(InterfaceInfo));
				ifaceExisting[i] = ifaceExisting[*iInfoLen];
			}
			// continue
			i--;
		}
	}

	return;
}

void icmpServiceMain()
{ 
	running = 1;
	serviceDebug("icmpServiceMain");
	
	// init sockets
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 1), &wsaData) != 0) {
        serviceFail("WSAStartup failed");
		return;
	}

	// create raw socket for sending
	sockRaw = WSASocket(AF_INET, SOCK_RAW, IPPROTO_ICMP, 0, 0, 0);
    if (sockRaw == INVALID_SOCKET) {
		WSACleanup();
        serviceFail("create raw send socket failed");
		return;
	}
	
	// create TCP control socket
	int sockCtrl = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sockCtrl == INVALID_SOCKET) {
		WSACleanup();
        serviceFail("WSASocket ctrl failed");
		return;
	}
	struct sockaddr_in service;
	service.sin_family = AF_INET;
	service.sin_addr.s_addr = inet_addr(SERVICE_BIND_HOST);
	service.sin_port = htons(SERVICE_BIND_PORT);
	if (bind(sockCtrl, (SOCKADDR*) &service, sizeof(service)) == SOCKET_ERROR) {
		WSACleanup();
        serviceFail("bind ctrl failed");
		return;
	}
	if (listen(sockCtrl, 4) == SOCKET_ERROR) {
		WSACleanup();
        serviceFail("listen ctrl failed");
		return;
	}
	
	// clients structure
	ClientInfo clients[MAX_CLIENTS];
	int numClients = 0;
	InterfaceInfo ifaces[MAX_INTERFACES];
	int numIfaces = 0;
	time_t updIfaceTime = 0;
	int i, j;
	
	while (running)
	{
		// query interfaces
		time_t t = time(NULL);
		if (t >= updIfaceTime) {
			updateInterfaces(sockCtrl, ifaces, &numIfaces);
			updIfaceTime = t + 10;
		}
		
		// fill readfds
		fd_set readfds;
		FD_ZERO(&readfds);
		int maxFds = sockCtrl;
		FD_SET(sockCtrl, &readfds);
		// FD_SET(sockRaw, &readfds);
		for (i = 0; i < numIfaces; i++) {
			int sock = ifaces[i].sock;
			FD_SET(sock, &readfds);
			if (sock > maxFds)
				maxFds = sock;
		}
		for (i = 0; i < numClients; i++) {
			int sock = clients[i].sock;
			FD_SET(sock, &readfds);
			if (sock > maxFds)
				maxFds = sock;
		}
		// select
		struct timeval timeout;
		timeout.tv_sec = 10;
		timeout.tv_usec = 0;
		if (select(maxFds + 1, &readfds, NULL, NULL, &timeout) == SOCKET_ERROR) {
			WSACleanup();
			serviceFail("select failed");
			return;
		}
		
		// process incoming connections
		if (FD_ISSET(sockCtrl, &readfds)) {
			int sockClient = accept(sockCtrl, NULL, NULL);
			if (numClients < MAX_CLIENTS) {
				serviceDebug("client connect");
				// add client
				clients[numClients].sock = sockClient;
				clients[numClients].bufFill = 0;
				clients[numClients].filterPort = 0;
				numClients++;
				continue;
			} else {
				serviceDebug("client connect FAIL: too many clients");
				closesocket(sockClient);
			}
		}
		
		// process raw sockets
		for (i = 0; i < numIfaces; i++) {
			int sockRaw = ifaces[i].sock;
			if (FD_ISSET(sockRaw, &readfds)) {
				serviceDebug("raw socket read");
				uint8_t packet[IP_PACKET_LEN];
				int r = recv(sockRaw, (char*)packet, sizeof(packet), 0);
				if (r > 0) {
					char b[1024];
					sprintf(b, "ICMP read: %d", r);
					serviceDebug(b);
					uint8_t* udpData;
					ipaddress from, to, reporter;
					int udpDataLen, fromPort, toPort;
					uint16_t code;
					if (cusp_icmp_recv(packet, r, &udpData, &udpDataLen,
							&from, &fromPort, &to, &toPort,
							&reporter, &code) == 0) {
						// printf("from: %lx, iface: %lx\n", from, ifaces[i].addr);
						if (from == ifaces[i].addr) {
							// sprintf(b, "ICMP recv: %d, %d", fromPort, toPort);
							serviceDebug(b);
							for (j = 0; j < numClients; j++) {
								ClientInfo* c = &clients[j];
								if (c->filterPort && (c->filterPort == fromPort)) {
									serviceDebug("client notify");
									char buf[IP_PACKET_LEN];
									ICMPCtrlHeader* h = (ICMPCtrlHeader*) buf;
									h->reporter = htonl(reporter);
									h->to = htonl(to);
									h->toport = htons(toPort);
									h->fromport = htons(0);
									h->code = htons(code);
									h->datalen = htons(udpDataLen);
									// printf("%lx\n", ntohl(*(ipaddress*)(udpData)));
									memcpy(h + 1, udpData, udpDataLen);
									// printf("%lx\n", ntohl(*(ipaddress*)(buf+sizeof(ICMPCtrlHeader))));
									send(c->sock, buf, sizeof(ICMPCtrlHeader) + udpDataLen, 0);
								}
							}
						}
					}
				}
			}
		}
		
		// process client sockets
		for (i = 0; i < numClients; i++) {
			ClientInfo* c = clients + i;
			if (FD_ISSET(c->sock, &readfds)) {
				if (clientRead(c) <= 0) {
					serviceDebug("client disconnect");
					// remove client
					if (closesocket(c->sock) != 0)
						serviceDebug("closesocket client failed");
					numClients--;
					// move last entry to free space
					if (i != numClients)
						memcpy(c, clients + numClients, sizeof(ClientInfo));
					// continue
					i--;
				}
			}
		}
	}
	
	// clean up
	if (closesocket(sockCtrl) != 0) {
        serviceFail("closesocket ctrl failed");
		return;
	}
	if (closesocket(sockRaw) != 0) {
        serviceFail("closesocket raw failed");
		return;
	}
	if (WSACleanup() != 0) {
        serviceFail("WSACleanup failed");
		return;
	}
	
	serviceDebug("icmpServiceMain END");
	return; 
}

void icmpServiceStop()
{
	running = 0;
	// TODO trigger select
}
