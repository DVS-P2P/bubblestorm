int64 r
int64 a
int64 b

int64 r0
int64 r51
int64 r102
int64 r153
int64 r204

enter field25519_wes_sub nostack
  input r
  input a
  input b

  r0   = *(uint64 *) (a +  0)
  r51  = *(uint64 *) (a +  8)
  r102 = *(uint64 *) (a + 16)
  r153 = *(uint64 *) (a + 24)
  r204 = *(uint64 *) (a + 32)

  r0   -= *(uint64 *) (b +  0)
  r51  -= *(uint64 *) (b +  8)
  r102 -= *(uint64 *) (b + 16)
  r153 -= *(uint64 *) (b + 24)
  r204 -= *(uint64 *) (b + 32)
  
  *(uint64 *) (r +  0) = r0
  *(uint64 *) (r +  8) = r51
  *(uint64 *) (r + 16) = r102
  *(uint64 *) (r + 24) = r153
  *(uint64 *) (r + 32) = r204
leave nostack
