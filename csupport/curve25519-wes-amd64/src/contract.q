int64 r
int64 a

int64 low
int64 neg1
int6464 tmp

int64 r0
int64 r1
int64 r2
int64 r3
int64 r4

int64 Y
int64 m19

enter field25519_wes_contract nostack
  input r
  input a

  tmp = r

  r0 = *(uint64 *) (a +  0)
  r1 = *(uint64 *) (a +  8)
  r2 = *(uint64 *) (a + 16)
  r3 = *(uint64 *) (a + 24)
  r4 = *(uint64 *) (a + 32)

  neg1 = r0
  (int64) neg1 >>= 63
  low = r1
  low <<= 51
  (int64) r1 >>= 13
  carry? r0 += low
  carry? r1 += neg1 + carry

  neg1 = r1
  (int64) neg1 >>= 63
  low = r2
  low <<= 38
  (int64) r2 >>= 26
  carry? r1 += low
  carry? r2 += neg1 + carry

  neg1 = r2
  (int64) neg1 >>= 63
  low = r3
  low <<= 25
  (int64) r3 >>= 39
  carry? r2 += low
  carry? r3 += neg1 + carry

  neg1 = r3
  (int64) neg1 >>= 63
  low = r4
  low <<= 12
  (int64) r4 >>= 52
  carry? r3 += low
  carry? r4 += neg1 + carry

  # Pull the 255th bit out
  r4 = (r4.r3) << 1
  r3 <<= 1
  (uint64) r3 >>= 1

  # At this point we have:
  # x = (r0 r1 r2 r3) in [0, 2^255)
  # y = r4 in (-E, +E) for some small E < 2^12
  # We want to calculate r = (x + 19y) mod p
  #
  # First let's ensure things are positive:
  #   If y is negative (<= -1) then add p=2^255-19, else add 0:
  #   A = x + 19y + p*(y<=-1)
  # The resulting A is in [0, 2*p) for both cases.
  #
  # To reduce (A mod p), we need to know if A >= p.
  # The easiest approach is to check if A+19 >= 2^255 (i.e. check bit 255).
  # If the bit is set then clear it, else subtract 19.
  #
  # To summarize, our plan is:
  #   calculate A+19 = x + 19*(y+1-(y<=-1)) + 2^255*(y<=-1)
  #   if bit 255 is NOT set, subtract 19
  #   clear bit 255

  # First step, find Y = y+1-(y<=-1). neg1=-(y<=-1)
  neg1 = r4
  (int64) neg1 >>= 63
  Y = r4 + neg1 + 1

  # Now find x + 19Y. Make sure to sign-extend Y; note: sign(Y) = sign(y)
  Y *= 19
  carry? r0 += Y
  carry? r1 += neg1 + carry
  carry? r2 += neg1 + carry
  carry? r3 += neg1 + carry

  # Now find A+19 by adding 2^255*(y<=-1)
  neg1 <<= 63
  r3 += neg1

  # Decide if we are subtracting 19 or not (YES if bit CLEAR)
  m19 = 19
  neg1 = r3
  (int64) neg1 >>= 63
  neg1 = ~neg1
  m19 &= neg1
  
  # Potentially subtract 19
  carry? r0 -= m19
  carry? r1 -= 0 - carry
  carry? r2 -= 0 - carry
  carry? r3 -= 0 - carry

  # Clear high bit
  r3 <<= 1
  (uint64) r3 >>= 1

  r = tmp
  *(uint64 *) (r +  0) = r0
  *(uint64 *) (r +  8) = r1
  *(uint64 *) (r + 16) = r2
  *(uint64 *) (r + 24) = r3
leave nostack
