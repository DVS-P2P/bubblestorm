int64 r
int64 a
int64 b

int64 a0load
int64 a51M19
int64 a102M19
int64 a153M19
int64 a204M19

int6464 a0
int6464 a51
int6464 a102
int6464 a153
int6464 a204
int6464 r_copy

int64 b0
int64 b51
int64 b102
int64 b153
int64 b204

int64 r0
int64 r51
int64 r102
int64 r153
int64 r204

int64 rax
int64 rdx

int64 high
int64 low

int64 mask

int64 r11
int64 r12
int64 r13
int64 r14
int64 r15
#MINGW int64 rdi
#MINGW int64 rsi

caller r11
caller r12
caller r13
caller r14
caller r15
#MINGW caller rdi
#MINGW caller rsi

stack64 r11_stack
stack64 r12_stack
stack64 r13_stack
stack64 r14_stack
stack64 r15_stack
#MINGW stack64 rdi_stack
#MINGW stack64 rsi_stack

enter field25519_wes_mul
  input r
  input a
  input b

  r11_stack = r11
  r12_stack = r12
  r13_stack = r13
  r14_stack = r14
  r15_stack = r15
#MINGW rdi_stack = rdi
#MINGW rsi_stack = rsi

  r_copy = r

  a0load  = *(uint64 *) (a +  0)
  a51M19  = *(uint64 *) (a +  8)
  a102M19 = *(uint64 *) (a + 16)
  a153M19 = *(uint64 *) (a + 24)
  a204M19 = *(uint64 *) (a + 32)

  b0   = *(uint64 *) (b +  0)
  b51  = *(uint64 *) (b +  8)
  b102 = *(uint64 *) (b + 16)
  b153 = *(uint64 *) (b + 24)
  b204 = *(uint64 *) (b + 32)

  a0   = a0load
  a51  = a51M19
  a102 = a102M19
  a153 = a153M19
  a204 = a204M19

  a51M19  *= 19
  a102M19 *= 19
  a153M19 *= 19
  a204M19 *= 19
  
  # r0 = 19*(a204*b51 + a153*b102 + a102*b153 + a51*b204) + a0*b0
  #--------------------------------------------------------------
    # a204*b51
    rax = a204M19
    (int128) rdx rax = rax * b51
    low = rax
    high = rdx

    # a153*b102
    rax = a153M19
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # a102*b153
    rax = a102M19
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b204
    rax = a51M19
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # a0*b0
    rax = a0
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    r0 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r51 = 19*(a204*b102 + a153*b153 + a102*b204) + a51*b0 + a0*b51
  #--------------------------------------------------------------
    # a204*b102
    rax = a204M19
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # a153*b153
    rax = a153M19
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # a102*b204
    rax = a102M19
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b0
    rax = a51
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry

    # a0*b51
    rax = a0
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    r51 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r102 = 19*(a204*b153 + a153*b204) + a102*b0 + a51*b51 + a0*b102
  #--------------------------------------------------------------
    # a204*b153
    rax = a204M19
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # a153*b204
    rax = a153M19
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # a102*b0
    rax = a102
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b51
    rax = a51
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry

    # a0*b102
    rax = a0
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    r102 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r153 = 19*(a204*b204) + a153*b0 + a102*b51 + a51*b102 + a0*b153
  #--------------------------------------------------------------
    # a204*b153
    rax = a204M19
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # a153*b0
    rax = a153
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry

    # a102*b51
    rax = a102
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b102
    rax = a51
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # a0*b153
    rax = a0
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    r153 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r204 = a204*b0 + a153*b51 + a102*b102 + a51*b153 + a0*b204
  #--------------------------------------------------------------
    # a204*b0
    rax = a204
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry

    # a153*b51
    rax = a153
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry

    # a102*b102
    rax = a102
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b153
    rax = a51
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # a0*b204
    rax = a0
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    r204 = low
    low = (high low) >> 51
    (int64) high >>= 51

  mask = 0x7ffffffffffff
  r = r_copy

  r0   &= mask
  r51  &= mask
  r102 &= mask
  r153 &= mask
  r204 &= mask

  # *19
  high *= 19
  rax = 19
  (uint128) rdx rax = rax * low
  rdx += high

  mask &= rax
  rax = (rdx rax) >> 51
  
  r0  += mask
  r51 += rax

  *(uint64 *) (r +  0) = r0
  *(uint64 *) (r +  8) = r51
  *(uint64 *) (r + 16) = r102
  *(uint64 *) (r + 24) = r153
  *(uint64 *) (r + 32) = r204

  r11 = r11_stack
  r12 = r12_stack
  r13 = r13_stack
  r14 = r14_stack
  r15 = r15_stack
#MINGW rdi = rdi_stack
#MINGW rsi = rsi_stack

leave
