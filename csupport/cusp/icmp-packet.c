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
#if defined(__MINGW32__)
#include <winsock2.h>
#else
#include <arpa/inet.h>
#endif

#include "icmp-packet.h"
#include "icmp4.h"

// #define DEBUG 1

// RFC 1071:
//  "The checksum field is the 16 bit one's complement of the one's
//  complement sum of all 16 bit words in the header.  For purposes of
//  computing the checksum, the value of the checksum field is zero."

static unsigned short csum(unsigned short *buf, int nwords) {
    unsigned long sum;
    
    for (sum = 0; nwords > 0; --nwords)
        sum += *buf++;
    
    sum = (sum >> 16) + (sum & 0x0000ffffUL);
    sum += (sum >> 16);
    
    return (unsigned short)(~sum);
}

int cusp_icmp_recv(
  uint8_t *packet, int len,
  uint8_t **UDPdata, int *UDPdatalen,
  ipaddress *UDPfrom, int *UDPfromport,
  ipaddress *UDPto,   int *UDPtoport,
  ipaddress *ICMPreporter, uint16_t *ICMPcode) {
    struct ipheader     *outside = (struct ipheader  *)  (packet);
    struct icmpheader   *icmp    = (struct icmpheader*)  (packet + sizeof(struct ipheader));
    struct ipheader     *inside  = (struct ipheader  *)  (packet + sizeof(struct ipheader) + sizeof(struct icmpheader));
    struct udpheader    *udp     = (struct udpheader *)  (packet + sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader));
    int minlen = sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader) + sizeof(struct udpheader);
    uint16_t chksum;
    
#if DEBUG
    fprintf(stderr, "ICMP received\n");
#endif
    
    /* If it's too short, then we don't care what it contains */
    if (len < minlen) return -1;
    
    /* Clear the last even byte to make checksumming work */
    if ((len & 1) != 0) packet[len] = 0;
    
    /* Confirm this is an ICMP4 message with no IP options */
    if (outside->iph_lenver != 0x45) return -1;
    if (outside->iph_protocol != 1) return -1;
    
    /* Confirm the packet length is as expected... and deal with crazy osx
     * Under osx (and possibly other BSDs) packet length and flagoffset are corrupted.
     */
#if DEBUG
    fprintf(stderr, "Lengths: %x %x\n", len, outside->iph_len);
#endif
    if (len != ntohs(outside->iph_len)) {
         if (len == outside->iph_len + 20) {
             /* MacOS breaks the packet length fields. Fix them. */
             outside->iph_len = htons(outside->iph_len + 20);
             outside->iph_flagoffset = htons(outside->iph_flagoffset);
             inside->iph_len = htons(inside->iph_len);
             inside->iph_flagoffset = htons(inside->iph_flagoffset);
         }  else {
             /* No idea what is wrong. */
             return -1;
         }
    }
    
    /* Confirm that the IP checksum is ok */
    chksum = outside->iph_chksum;
    outside->iph_chksum = 0;
    outside->iph_chksum = csum((unsigned short *)outside,  sizeof(struct ipheader)/2);
#if DEBUG
    fprintf(stderr, "IP1 Checksums: %x %x\n", chksum, outside->iph_chksum);
#endif
    if ((chksum != 0) && (chksum != outside->iph_chksum)) // (outside checksum is 0 in Win7)
        return -1;
    
    /* Check the ICMP status code to see if it's an error we know */
    switch (ntohs(icmp->icmph_typecode)) {
    case 0x0300:
    case 0x0301:
    case 0x0302:
    case 0x0303:
    case 0x0304:
    case 0x0305:
    case 0x0306:
    case 0x0307:
    case 0x0308:
    case 0x0309:
    case 0x030a:
    case 0x030b:
    case 0x030c:
    case 0x0b00:
    case 0x0b01:
        break;
    default:
        return -1;
    }
    
    /* Confirm that the ICMP checksum is ok */
    chksum = icmp->icmph_chksum;
    icmp->icmph_chksum = 0;
    icmp->icmph_chksum = csum((unsigned short *)icmp, (len+1-sizeof(struct ipheader))/2);
#if DEBUG
    fprintf(stderr, "ICMP Checksums: %x %x\n", chksum, icmp->icmph_chksum);
#endif
    if (chksum != icmp->icmph_chksum)
        return -1;
    
    /* Confirm the error is a UDP4 message with no IP options */
    if (inside->iph_lenver != 0x45) return -1;
    if (inside->iph_protocol != 17) return -1;
    
    /* We don't check the length, because ICMP errors often truncate UDP */
    
    /* Confirm that the interior IP checksum is ok */
    chksum = inside->iph_chksum;
    inside->iph_chksum = 0;
    inside->iph_chksum = csum((unsigned short *)inside,  sizeof(struct ipheader)/2);
#if DEBUG
    fprintf(stderr, "IP2 Checksums: %x %x\n", chksum, inside->iph_chksum);
#endif
    if (chksum != inside->iph_chksum)
        return -1;
    
    /* Confirm that the ICMP error was sent to the UDP source */
    if (outside->iph_destip != inside->iph_sourceip) 
        return -1;
    
    /* We can't check the UDP checksum because it is potentially clipped */
    
    /* Results */
    *ICMPreporter = ntohl(outside->iph_sourceip);
    *ICMPcode = ntohs(icmp->icmph_typecode);
    
    *UDPto   = ntohl(inside->iph_destip);
    *UDPfrom = ntohl(inside->iph_sourceip);
    *UDPtoport   = ntohs(udp->udph_destport);
    *UDPfromport = ntohs(udp->udph_srcport);
    
    *UDPdata = packet + minlen;
    *UDPdatalen = len - minlen;
    
    return 0;
}

int cusp_icmp_send(
  uint8_t *packet, int *len,
  uint8_t *UDPdata, int UDPdatalen,
  ipaddress UDPfrom, int UDPfromport,
  ipaddress UDPto,   int UDPtoport,
  ipaddress ICMPreporter, uint16_t ICMPcode) {
    struct ipheader     *outside = (struct ipheader  *)  (packet);
    struct icmpheader   *icmp    = (struct icmpheader*)  (packet + sizeof(struct ipheader));
    struct ipheader     *inside  = (struct ipheader  *)  (packet + sizeof(struct ipheader) + sizeof(struct icmpheader));
    struct pseudoheader *ph      = (struct pseudoheader*)(packet + sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader) - sizeof(struct pseudoheader));
    struct udpheader    *udp     = (struct udpheader *)  (packet + sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader));
    int minlen = sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader) + sizeof(struct udpheader);
    
    // Test for sufficient buffer space
    if (minlen > *len) return -1;
    if (minlen + ((UDPdatalen+1)&(~1)) > *len) return -1;
    
    // Copy the payload, and zero the last byte
    packet[minlen+((UDPdatalen+1)&(~1))-1] = 0;
    memcpy(packet+minlen, UDPdata, UDPdatalen);

    // Fabricate a pseudo-IP header for computing UDP checksum
    ph->ph_sourceip = htonl(UDPfrom);
    ph->ph_destip   = htonl(UDPto);
    ph->ph_zero     = 0;
    ph->ph_protocol = 17; // UDP
    ph->ph_len      = htons(UDPdatalen + sizeof(struct udpheader));
    
    // Fabricate the 'lost' UDP header.
    udp->udph_srcport  = htons(UDPfromport);
    udp->udph_destport = htons(UDPtoport);
    udp->udph_len      = htons(UDPdatalen + sizeof(struct udpheader));
    udp->udph_chksum   = 0;
    udp->udph_chksum =
        csum(
            (unsigned short*)ph,
            (sizeof(struct pseudoheader) + sizeof(struct udpheader) + UDPdatalen + 1) /2);
    
    // Fabricate the 'lost' IP header.
    inside->iph_lenver = 0x45; /* 5 words, IP version 4 */
    inside->iph_tos = 0;
    inside->iph_len = htons(UDPdatalen + sizeof(struct ipheader) + sizeof(struct udpheader));
    inside->iph_ident = 0;
    inside->iph_flagoffset = 0;
    inside->iph_ttl = 1; // hops (remaining)
    inside->iph_protocol = 17; // UDP
    inside->iph_chksum = 0;
    inside->iph_sourceip = htonl(UDPfrom);
    inside->iph_destip   = htonl(UDPto);
    inside->iph_chksum = 
        csum((unsigned short *)inside,  sizeof(struct ipheader)/2);

    // Create the ICMP error message
    icmp->icmph_typecode = htons(ICMPcode);
    icmp->icmph_chksum   = 0;
    icmp->icmph_id       = 0;
    icmp->icmph_seq      = 0;
    icmp->icmph_chksum =
        csum(
            (unsigned short *)icmp, 
            (sizeof(struct icmpheader)+sizeof(struct ipheader)+sizeof(struct udpheader)+UDPdatalen+1)/2);
    
    // The exterior IP header
    outside->iph_lenver = 0x45; /* 5 words, IP version 4 */
    outside->iph_tos = 0;
    outside->iph_len = htons(UDPdatalen + sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader) + sizeof(struct udpheader));
    outside->iph_ident = 0;
    outside->iph_flagoffset = 0;
    outside->iph_ttl = 64; // hops (remaining)
    outside->iph_protocol = 1; // ICMP
    outside->iph_chksum = 0;
    outside->iph_sourceip = htonl(ICMPreporter);
    outside->iph_destip = htonl(UDPfrom);
    outside->iph_chksum = 
        csum((unsigned short *)outside,  sizeof(struct ipheader)/2);
    
    *len = UDPdatalen + sizeof(struct ipheader) + sizeof(struct icmpheader) + sizeof(struct ipheader) + sizeof(struct udpheader);
    return sizeof(struct ipheader);
}
