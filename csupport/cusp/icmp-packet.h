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

#ifndef _CUSP_ICMP_PACKET_H_
#define _CUSP_ICMP_PACKET_H_

#include <stdint.h>

typedef uint32_t ipaddress; /* host-byte order */

#define IP_PACKET_LEN 576

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

/* Process the received >IP< packet [packet, packet+plen) bytes.
 * All other parameters are written to by this method.
 * 
 * The destination of the ICMP error packet is UDPfrom:UDPfromport.
 * The caller should confirm that this corresponds to the local IP:port.
 *
 * [*UDPdata, *UDPdata+*UDPdatalen) lies inside packet with the UDP payload.
 * 
 * Returns 0 on successful parse, -1 if the message was not an ICMP UDP error.
 */
int cusp_icmp_recv(
  uint8_t *packet, int len,
  uint8_t **UDPdata, int *UDPdatalen,
  ipaddress *UDPfrom, int *UDPfromport,
  ipaddress *UDPto,   int *UDPtoport,
  ipaddress *ICMPreporter, uint16_t *ICMPcode);

/* Create an IP packet in [packet, packet+plen) bytes.
 * Maximum initial value for len should be 576.
 * packet and len are written by this method on completion.
 *
 * The destination of the ICMP error packet is UDPfrom:UDPport.
 * The ICMPreporter should be the local IP address (which can be 0 if the
 * operating system generates its own IP header).
 *
 * Returns the length of the IP >header< on successful composition.
 * *len contains the length of the complete IP packet.
 * -1 if the packet buffer was too short and/or the UDPdata too big.
 */
int cusp_icmp_send(
  uint8_t *packet, int *len,
  uint8_t *UDPdata, int UDPdatalen,
  ipaddress UDPfrom, int UDPfromport,
  ipaddress UDPto,   int UDPtoport,
  ipaddress ICMPreporter, uint16_t ICMPcode);

#endif
