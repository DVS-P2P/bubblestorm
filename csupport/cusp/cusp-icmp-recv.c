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
#include <fcntl.h>
#else
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/udp.h>
#endif

#include "icmp-packet.h"
#include "my-ip-address.h"

#if defined(__MINGW32__)
void die(const char* op) {
    const char buf[1024] = "failed";
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, (LPTSTR)buf, sizeof(buf)-1, 0);
    fprintf(stderr, "%s: %s\n", op, buf);
    fflush(stderr);
    exit(-1);
}
#endif

int main(int argc, const char **argv) {
    uint8_t packet[IP_PACKET_LEN];
    uint8_t *data;
    int packetlen, datalen, fd;
    
    ipaddress from, to, reporter;
    int fromport, toport, myport;
    uint16_t toport16, reporterport16 = 0;
    uint16_t code, outlen;
    
    if (argc != 2) {
        fprintf(stderr, "Usage %s <UDP port>\n", argv[0]);
        fprintf(stderr, "ICMP error messages are written to stdout.\n");
        fprintf(stderr, "Format: <4 IP reporter> <6 dest IP> <2 zero> <2 dest port> <2 ICMP code> <2 len> <len payload>\n");
        exit(-1);
    }
    myport = atol(argv[1]);

#if defined(__MINGW32__)
    _setmode (1, _O_BINARY);
    
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 1), &wsaData) != 0)
        die("WSAStartup failed");
#else
    setsid();
#endif
    
    if ((fd = socket(PF_INET, SOCK_RAW, IPPROTO_ICMP)) == -1) {
        perror("socket");
        exit(-1);
    }
    
    while ((packetlen = recvfrom(fd, (char*)packet, sizeof(packet), 0, 0, 0)) > 0) {
        if (cusp_icmp_recv(packet, packetlen, &data, &datalen, 
                           &from, &fromport, &to, &toport, &reporter, &code) == 0) {
            if (fromport == myport && cusp_is_my_address(from)) {
                reporter = htonl(reporter);
                to = htonl(to);
                toport16 = htons(toport);
                code = htons(code);
                outlen = htons(datalen);
                
                fwrite(&reporter, sizeof(reporter), 1, stdout);
                fwrite(&to, sizeof(to), 1, stdout);
                fwrite(&reporterport16, sizeof(reporterport16), 1, stdout);
                fwrite(&toport16, sizeof(toport16), 1, stdout);
                fwrite(&code, sizeof(code), 1, stdout);
                fwrite(&outlen, sizeof(outlen), 1, stdout);
                fwrite(data, 1, datalen, stdout);
                fflush(stdout);
            }
        }
    }
    
    return 0;
}
