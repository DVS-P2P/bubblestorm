
# curve25519 Makefile.lib version 20050915
# D. J. Bernstein
# Public domain.

curve25519: curve25519.a curve25519.h

curve25519.h: curve25519.impl \
curve25519.h.do
	sh -e curve25519.h.do > curve25519.h.new
	mv curve25519.h.new curve25519.h

curve25519.a: curve25519.impl \
curve25519.a.do \
curve25519_athlon.h \
curve25519_athlon.c \
curve25519_athlon_const.s \
curve25519_athlon_fromdouble.s \
curve25519_athlon_init.s \
curve25519_athlon_mainloop.s \
curve25519_athlon_mult.s \
curve25519_athlon_square.s \
curve25519_athlon_todouble.s
	sh -e curve25519.a.do $(CC) > curve25519.a.new
	mv curve25519.a.new curve25519.a

curve25519.impl: \
curve25519.impl.do \
x86cpuid.c \
curve25519.impl.check.c \
curve25519_athlon.h \
curve25519_athlon.c \
curve25519_athlon_const.s \
curve25519_athlon_fromdouble.s \
curve25519_athlon_init.s \
curve25519_athlon_mainloop.s \
curve25519_athlon_mult.s \
curve25519_athlon_square.s \
curve25519_athlon_todouble.s
	sh -e curve25519.impl.do $(CC) > curve25519.impl.new
	mv curve25519.impl.new curve25519.impl
