int64 r
int64 a

int64 mask

int64 r0
int64 r48
int64 r96
int64 r152
int64 r200

enter field25519_wes_expand nostack
  input r
  input a

  mask = 0x7ffffffffffff

  r0   = *(uint64 *) (a +  0)
  r48  = *(uint64 *) (a +  6)
  r96  = *(uint64 *) (a + 12)
  r152 = *(uint64 *) (a + 19)
  r200 = *(uint64 *) (a + 25)
  
  (uint64) r48  >>= 3
  (uint64) r96  >>= 6
  (uint64) r152 >>= 1
  (uint64) r200 >>= 4

  r0   &= mask
  r48  &= mask
  r96  &= mask
  r152 &= mask
  r200 &= mask
  
  *(uint64 *) (r +  0) = r0
  *(uint64 *) (r +  8) = r48
  *(uint64 *) (r + 16) = r96
  *(uint64 *) (r + 24) = r152
  *(uint64 *) (r + 32) = r200
leave nostack
