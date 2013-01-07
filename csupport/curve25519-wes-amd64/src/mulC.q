int64 r
int64 a
int64 b
int64 x
int64 y

int64 r0
int64 mask
int6464 tmp

int64 rax
int64 rdx

int64 carry51
int64 carry102
int64 carry153
int64 carry204
int64 carry255

enter field25519_wes_mulC nostack
  input r
  input b
  input y

  x = y # free up rdx on linux
  a = b # free up rdx on mingw

  mask = 0x7ffffffffffff

  rax  = *(uint64 *) (a +  0)
  (int128) rdx rax = rax * x
  rdx = (rdx.rax) << 13
  rax &= mask
  carry51 = rdx
  tmp = rax

  rax = *(uint64 *) (a +  8)
  (int128) rdx rax = rax * x
  rdx = (rdx.rax) << 13
  rax &= mask
  rax += carry51
  carry102 = rdx
  *(uint64 *) (r + 8) = rax

  rax = *(uint64 *) (a + 16)
  (int128) rdx rax = rax * x
  rdx = (rdx.rax) << 13
  rax &= mask
  rax += carry102
  carry153 = rdx
  *(uint64 *) (r + 16) = rax

  rax = *(uint64 *) (a + 24)
  (int128) rdx rax = rax * x
  rdx = (rdx.rax) << 13
  rax &= mask
  rax += carry153
  carry204 = rdx
  *(uint64 *) (r + 24) = rax

  rax = *(uint64 *) (a + 32)
  (int128) rdx rax = rax * x
  rdx = (rdx.rax) << 13
  rax &= mask
  rax += carry204
  carry255 = rdx
  *(uint64 *) (r + 32) = rax

  r0 = tmp
  carry255 *= 19
  r0 += carry255
  *(uint64 *) (r + 0) = r0
leave nostack
