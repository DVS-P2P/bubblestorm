# curve25519.a.do version 20050915
# D. J. Bernstein
# Public domain.

rm -f curve25519tmp.a

impl=`cat curve25519.impl`

case ${impl} in
  athlon)
    $* -c curve25519_${impl}.c
    $* -c curve25519_${impl}_const.s
    $* -c curve25519_${impl}_fromdouble.s
    $* -c curve25519_${impl}_init.s
    $* -c curve25519_${impl}_mainloop.s
    $* -c curve25519_${impl}_mult.s
    $* -c curve25519_${impl}_square.s
    $* -c curve25519_${impl}_todouble.s
    ar cr curve25519tmp.a \
      curve25519_${impl}.o \
      curve25519_${impl}_const.o \
      curve25519_${impl}_fromdouble.o \
      curve25519_${impl}_init.o \
      curve25519_${impl}_mainloop.o \
      curve25519_${impl}_mult.o \
      curve25519_${impl}_square.o \
      curve25519_${impl}_todouble.o
    ;;
  *) echo 'unknown implementation' >&2; exit 1 ;;
esac

ranlib curve25519tmp.a >/dev/null 2>/dev/null || :
cat curve25519tmp.a
rm curve25519tmp.a
