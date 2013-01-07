# cpucycles.a.do version 20050915
# D. J. Bernstein
# Public domain.

rm -f cpucyclestmp.a

impl=`cat curve25519.impl`

case $impl in
  athlon)
    $* -c cpucycles_${impl}.s
    ar cr cpucyclestmp.a cpucycles_${impl}.o
    ;;
  *) echo 'unknown implementation' >&2; exit 1 ;;
esac

ranlib cpucyclestmp.a >/dev/null 2>/dev/null || :
cat cpucyclestmp.a
rm cpucyclestmp.a
