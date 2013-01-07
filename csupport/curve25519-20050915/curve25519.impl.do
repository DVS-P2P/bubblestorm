# curve25519.impl.do version 20050915
# D. J. Bernstein
# Public domain.

echo '#include "curve25519_athlon.h"' > curve25519.impl.check.h
if gcc -o x86cpuid x86cpuid.c >/dev/null 2>&1 \
&& ./x86cpuid > x86cpuid.out \
&& $* -o curve25519.impl.check curve25519.impl.check.c \
curve25519_athlon.c \
curve25519_athlon_const.s \
curve25519_athlon_fromdouble.s \
curve25519_athlon_init.s \
curve25519_athlon_mainloop.s \
curve25519_athlon_mult.s \
curve25519_athlon_square.s \
curve25519_athlon_todouble.s \
>/dev/null 2>&1 \
&& ./curve25519.impl.check
then
  echo athlon
  exit 0
fi

echo 'curve25519.impl.do: fatal: all tests failed! unsupported platform or compiler' >&2
exit 1
