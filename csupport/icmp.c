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

/* Some address terminology.
 * 
 * A UDP message has a <from IP:port> and a <to IP:port>
 * When a UDP message generates an ICMP error-message, there is an additional
 * address of the node who reported the error.
 * An ICMP error is always sent to the failed UDP's from IP.
 *
 * In an ICMP message, we label the fields UDPfrom/UDPto/reporter,
 * regardless of who is sending/receiving the ICMP message.
 */

/* Implement these methods to allow ICMP send/recv for a UDP socket:
 *    void* cusp_icmp_open(int udpSock);  // null on error
 *    int cusp_icmp_close(void*);         // -1 on error
 *
 *    // UDPfrom and UDPfromport are assumed to match the initial udpSock 
 *    int cusp_icmp_recv(void*,                            // udplen or -1 on error
 *          char *UDPdata, int UDPdataoff, int UDPdatalen, // the payload of the failed UDP
 *          char *ICMPreporter,                            // the host reporting the error
 *          char *UDPto, int *UDPtoport                    // the destination of the failed UDP
 *          uint16_t *ICMPcode);                           // the ICMP status
 *
 *    // ICMPreporter is assumed to be the local IP address
 *    int cusp_icmp_send(void*,                            // udplen or -1 on error
 *          char *UDPdata, int UDPdataoff, int UDPdatalen, // the payload of the failed UDP
 *          char *UDPto,   int UDPtoport,                  // the destination of the failed UDP
 *          char *UDPfrom, int UDPfromport,                // the source of the failed UDP
 *          uint16_t ICMPcode);                            // the ICMP status
 */

#if defined(__linux__)

#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <asm/types.h>
#include <linux/errqueue.h>

struct session {
    int fd;
};

void* cusp_icmp_open(int udpSock) {
    int one = 1;
    struct session *out;
  
    if (setsockopt (udpSock, IPPROTO_IP, IP_RECVERR, &one, sizeof(one)) < 0) {
        perror("setsockopt");
        return 0;
    }
  
    out = (struct session *)malloc(sizeof(struct session));
    out->fd = udpSock;
    return out;
}

int cusp_icmp_close(void *session) {
    free(session);
    return 0;
}

uint16_t cusp_icmp_recv(void *session,
                        char *UDPdata, int UDPdataoff, int UDPdatalen,
                        char *ICMPreporter, 
                        char *UDPto, int *UDPtoport,
                        uint16_t *ICMPcode) {
    struct session *s;
    struct cmsghdr *cmsg;
    struct sock_extended_err *ext;
    struct sockaddr_in *off;
    struct sockaddr_in sin;
    struct msghdr hdr;
    struct iovec iov;
    char buf[1024];
    int out;
    
    s = (struct session*)session;
    memset(&iov, 0, sizeof(iov));
    memset(&hdr, 0, sizeof(hdr));
    
    iov.iov_base = UDPdata + UDPdataoff;
    iov.iov_len = UDPdatalen;
    hdr.msg_name = &sin;
    hdr.msg_namelen = sizeof(sin);
    hdr.msg_iov = &iov;
    hdr.msg_iovlen = 1;
    hdr.msg_control = buf;
    hdr.msg_controllen = sizeof(buf);
    hdr.msg_flags = 0;
    
    out = recvmsg(s->fd, &hdr, MSG_ERRQUEUE | MSG_DONTWAIT);
    if (out == -1) return -1;
    
    for (cmsg = CMSG_FIRSTHDR(&hdr); cmsg; cmsg = CMSG_NXTHDR(&hdr, cmsg)) {
        if (cmsg->cmsg_level == IPPROTO_IP && cmsg->cmsg_type == IP_RECVERR) {
            ext = (struct sock_extended_err*)CMSG_DATA(cmsg);
            off = (struct sockaddr_in*)SO_EE_OFFENDER(ext);
            if (ext->ee_origin == SO_EE_ORIGIN_ICMP) {
                /* This is what we are looking for! */
                memcpy(ICMPreporter, &off->sin_addr, sizeof(struct in_addr));
                memcpy(UDPto, &sin.sin_addr, sizeof(struct in_addr));
                *UDPtoport = ntohs(sin.sin_port);
                *ICMPcode = ext->ee_type << 8 | ext->ee_code;
                
                return out;
            }
        }
    }
    
    return -1;
}

/* Linux cannot send ICMP without root.
 * SML-side selection should use setuid approach.
 * We include this stub in case the compiler doesn't optimize the _import away.
 */
int cusp_icmp_send(void *session,
                   char *UDPdata, int UDPdataoff, int UDPdatalen,
                   char *UDPto,   int UDPtoport,
                   char *UDPfrom, int UDPfromport,
                   uint16_t ICMPcode) {
    return -1;
}

#else

#include <stdint.h>

/* Include stubs to placate the linker.
 */
void* cusp_icmp_open(int udpSock) {
    return 0;
}

int cusp_icmp_close(void *session) {
    return -1;
}

uint16_t cusp_icmp_recv(void *session,
                        char *UDPdata, int UDPdataoff, int UDPdatalen,
                        char *ICMPreporter, 
                        char *UDPto, int *UDPtoport,
                        uint16_t *ICMPcode) {
    return -1;
}

int cusp_icmp_send(void *session,
                   char *UDPdata, int UDPdataoff, int UDPdatalen,
                   char *UDPto,   int UDPtoport,
                   char *UDPfrom, int UDPfromport,
                   uint16_t ICMPcode) {
    return -1;
}

#endif
