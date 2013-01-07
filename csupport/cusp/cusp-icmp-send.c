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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#if defined(__MINGW32__)
#include <winsock2.h>
#else
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#endif

#include "icmp-packet.h"

#if defined(__MINGW32__)
void die(const char* op) {
    const char buf[1024] = "failed";
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, (LPTSTR)buf, sizeof(buf)-1, 0);
    fprintf(stderr, "%s: %s\n", op, buf);
    fflush(stderr);
    exit(-1);
}
#endif

int main(int argc, char *argv[]) {
    struct sockaddr_in dest;
    uint8_t packet[IP_PACKET_LEN];
    uint8_t data[1024];
    ipaddress to, from;
    uint16_t code;
    int toport, fromport;
    int got, skip, sock, datalen, packetlen;
    char *colon;
    
    if (argc != 4) {
        printf("Usage %s <UDPto IP:port> <UDPfrom IP:port> <ICMPcode>\n", argv[0]);
        printf("UDP payload is read from stdin.\n");
        exit(-1);
    }
    
    datalen = 0;
    while ((got = fread(data+datalen, 1, sizeof(data)-datalen, stdin)) > 0) {
        datalen += got;
    }
    
    if ((colon = strrchr(argv[1], ':')) == 0) {
        fprintf(stderr, "UDPto IP:port missing colon\n");
        exit(-1);
    }
    
    *colon++ = 0;
    toport = atoi(colon);
    to = ntohl(inet_addr(argv[1]));
    
    if ((colon = strrchr(argv[2], ':')) == 0) {
        fprintf(stderr, "UDPfrom IP:port missing colon\n");
        exit(-1);
    }
    
    *colon++ = 0;
    fromport = atoi(colon);
    from = ntohl(inet_addr(argv[2]));
    
    code = atol(argv[3]);
    
    packetlen = sizeof(packet);
    skip = 
        cusp_icmp_send(
            packet, &packetlen,
            data, datalen,
            from, fromport,
            to, toport,
            0, code);
    if (skip == -1) {
        fprintf(stderr, "Payload too long\n");
        exit(-1);
    }
    
    /* Send ICMP error to the UDPfrom address */
    memset(&dest, 0, sizeof(dest));
    dest.sin_family = PF_INET;
    dest.sin_addr.s_addr = htonl(from);
    
#if defined(__MINGW32__)
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 1), &wsaData) != 0)
        die("WSAStartup failed");
    
    if ((sock = WSASocket(AF_INET, SOCK_RAW, IPPROTO_ICMP, 0, 0, 0)) == -1)
        die("WSASocket failed");
    
    if (sendto(sock, (char*)packet+skip, packetlen-skip, 0, (struct sockaddr*)&dest, sizeof(dest)) < 0)
        die("sendto");
    
    closesocket(sock);
#else
    /* This should be fairly portable, so use it by default */
    if ((sock = socket(PF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
        perror("socket() error");
        exit(-1);
    }
    
    if (sendto(sock, packet+skip, packetlen-skip, 0, (struct sockaddr *)&dest, sizeof(dest)) < 0) {
        perror("sendto() error");
        exit(-1);
    }

    close(sock);

#endif

#if defined(__MINGW32__) || defined(__linux__) || defined(__APPLE_CC__)
/* platform supported */
#else
#warning Unknown OS. Check RAW socket usage.
#endif

    return 0;
}
