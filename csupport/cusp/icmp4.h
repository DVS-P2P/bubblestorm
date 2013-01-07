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

#ifndef _CUSP_ICMP4_H_
#define _CUSP_ICMP4_H_

#include "icmp-packet.h"

// The IP header's structure
struct ipheader {
    uint8_t   iph_lenver;
    uint8_t   iph_tos;
    uint16_t  iph_len;
    uint16_t  iph_ident;
    uint16_t  iph_flagoffset;
    uint8_t   iph_ttl;
    uint8_t   iph_protocol;
    uint16_t  iph_chksum;
    ipaddress iph_sourceip;
    ipaddress iph_destip;
};

// ICMP header structure
struct icmpheader {
    uint16_t icmph_typecode;
    uint16_t icmph_chksum;
    uint16_t icmph_id;
    uint16_t icmph_seq;
};

// Pseudo-header used when computing UDP checksum
struct pseudoheader {
    ipaddress ph_sourceip;
    ipaddress ph_destip;
    uint8_t   ph_zero;
    uint8_t   ph_protocol;
    uint16_t  ph_len;
};

// UDP header's structure
struct udpheader {
    uint16_t udph_srcport;
    uint16_t udph_destport;
    uint16_t udph_len;
    uint16_t udph_chksum;
};

#endif
