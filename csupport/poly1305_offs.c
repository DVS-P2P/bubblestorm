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

#if (defined(__x86_64__))
#include "poly1305aes-wes-amd64/poly1305.h"
#elif (defined(__i386__))
#include "poly1305aes-20050218/poly1305_ppro.h"
#else
#error No assembler available
#endif

void poly1305_offs(
  unsigned char *dest,
  unsigned char *key,
  unsigned char *nonce,
  unsigned char *text, int text_offset, int text_length)
{
  poly1305(dest, key, nonce, text+text_offset, text_length);
}
