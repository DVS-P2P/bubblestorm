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

/*
curve25519_athlon.h version 20050915
D. J. Bernstein
Public domain.
*/

#ifndef CURVE25519_ATHLON
#define CURVE25519_ATHLON

extern void curve25519_athlon(unsigned char *,const unsigned char *,const unsigned char *);

/* internal functions, exposed purely for testing */
extern void curve25519_athlon_init(void);
extern void curve25519_athlon_mainloop(double *,const unsigned char *);
extern void curve25519_athlon_recip(double *,const double *);
extern void curve25519_athlon_square(double *,const double *);
extern void curve25519_athlon_mult(double *,const double *,const double *);
extern void curve25519_athlon_todouble(double *,const unsigned char *);
extern void curve25519_athlon_fromdouble(unsigned char *,const double *);

#ifndef curve25519_implementation
#define curve25519_implementation "curve25519_athlon"
#define curve25519 curve25519_athlon
#define curve25519_init curve25519_athlon_init
#define curve25519_mainloop curve25519_athlon_mainloop
#define curve25519_recip curve25519_athlon_recip
#define curve25519_square curve25519_athlon_square
#define curve25519_mult curve25519_athlon_mult
#define curve25519_todouble curve25519_athlon_todouble
#define curve25519_fromdouble curve25519_athlon_fromdouble
#endif

#endif
