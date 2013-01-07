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

#ifndef _MY_IP_ADDRESS_H_
#define _MY_IP_ADDRESS_H_

#include "icmp-packet.h"

#if defined(__MINGW32__)
#include <winsock2.h>
#else
#include <netinet/in.h>
#endif

/* This returns a list of addresses which are bound to local interfaces.
 * It caches the result between calls and refreshes the list if >10s old.
 */
const ipaddress* cusp_my_addresses(int* len);

/* Is this address a local address? 1 is yes, 0 if no. */
int cusp_is_my_address(ipaddress address);

#endif
