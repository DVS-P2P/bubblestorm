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

#include <sys/types.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#ifndef SIOCGIFCONF
#include <sys/sockio.h>
#endif
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include "my-ip-address.h"

/* Never return an address list older than 10 seconds */
#define UPDATE_FREQ 10

#if defined(__linux__)
//#define HASSALEN 0
#else
#define HASSALEN 1
#endif

static ipaddress *cached_addr = 0;
static int cached_addrs = -1;
static time_t cached_update = 0;

static int pad(int x) {
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return ++x;
}

static int resize_cache(int num) {
    int newsize, oldsize;
    ipaddress *tmp;
    
    newsize = pad(num);
    oldsize = pad(cached_addrs);
    
    if (newsize == oldsize) {
        cached_addrs = num;
        return 0;
    }
    
    if (cached_addr)
        tmp = (ipaddress *)realloc(cached_addr, sizeof(ipaddress) * newsize);
    else
        tmp = (ipaddress *)malloc(sizeof(ipaddress) * newsize);
    
    if (tmp) {
        cached_addrs = num;
        cached_addr = tmp;
        return 0;
    } else {
        return -1;
    }
}

static void update_cache() {
    struct ifconf ifc;
    struct ifreq *ifr;
    struct sockaddr_in *sin;
    char *buf, *x;
    int fd, len, ipc, skip;
    
    fd = socket(PF_INET, SOCK_DGRAM, 0);
    if (fd == -1) goto fail0;

    len = 1024;
    while (1) {
        buf = (char*)malloc(len);
        if (!buf) goto fail1;
        
        ifc.ifc_buf = buf;
        ifc.ifc_len = len;
        
        if (ioctl(fd, SIOCGIFCONF, &ifc) >= 0 && /* > is for System V */
            ifc.ifc_len + sizeof(struct ifreq) + 64 < len) 
        {
            len = ifc.ifc_len;
            break;
        }
        free(buf);
        
        if (len > 100*1024) goto fail1;
        len += 100 + (len/2);
    }
    
    ipc = 0;
    if (resize_cache(ipc) < 0) goto fail2;
    
    for (x = buf; x < buf + len; x += skip) {
        ifr = (struct ifreq *)x;
#if HASSALEN
        skip = sizeof(ifr->ifr_name) + ifr->ifr_addr.sa_len;
#else
        skip = sizeof(*ifr);
#endif

        if (ioctl(fd, SIOCGIFFLAGS, x) == 0 && 
            (ifr->ifr_flags & IFF_UP) != 0 &&
            ioctl(fd, SIOCGIFADDR, x) == 0 &&
	    ifr->ifr_addr.sa_family == AF_INET) 
        {
	    sin = (struct sockaddr_in *) &ifr->ifr_addr;
	    cached_addr[ipc] = ntohl(sin->sin_addr.s_addr);
	    if (resize_cache(++ipc) < 0) goto fail2;
	}
    }

fail2:
    free(buf);
fail1:
    close(fd);
fail0:
    return;
}

const ipaddress* cusp_my_addresses(int* len) {
    time_t now;
    
    now = time(0);
    if (cached_update + UPDATE_FREQ < now) {
        update_cache();
        cached_update = now;
    }
    
    if (len) *len = cached_addrs;
    return cached_addr;
}

int cusp_is_my_address(ipaddress address) {
    int i;
    
    cusp_my_addresses(0); /* update cache */

    for (i = 0; i < cached_addrs; ++i)
        if (address == cached_addr[i])
            return 1;
    
    return 0;
}
