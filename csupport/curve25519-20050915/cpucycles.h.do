# cpucycles.h.do version 20050915
# D. J. Bernstein
# Public domain.

case `cat curve25519.impl` in
  athlon) echo '#include "cpucycles_athlon.h"' ;;
  *) echo 'unknown implementation' >&2; exit 1 ;;
esac
