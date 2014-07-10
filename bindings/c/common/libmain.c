//
// C helper code for libmain.sml
//

#include "inttypes.h"

/// HACK: need a ~1 as Socket.sock_desc, conversion is gone since MLton.Socket has been removed
extern int32_t fakeInvalidSd() { return -1; }
