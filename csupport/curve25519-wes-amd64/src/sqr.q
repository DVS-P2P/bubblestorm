int64 r
int64 a

int6464 r_copy

int64 a0
int64 a51
int64 a102
int64 a153
int64 a204

int64 a204M19
int64 a153M19

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

enter field25519_wes_sqr
  input r
  input a

  r11_stack = r11
  r12_stack = r12
  r13_stack = r13
  r14_stack = r14
  r15_stack = r15
#MINGW rdi_stack = rdi
#MINGW rsi_stack = rsi

  r_copy = r

  a0   = *(uint64 *) (a +  0)
  a51  = *(uint64 *) (a +  8)
  a102 = *(uint64 *) (a + 16)
  a153 = *(uint64 *) (a + 24)
  a204 = *(uint64 *) (a + 32)

  a204M19 = a204
  a153M19 = a153
  a204M19 *= 19
  a153M19 *= 19

  # r0 = 19*(2*a204*a51 + 2*a153*a102) + a0*a0
  #--------------------------------------------------------------
    # a204*a51
    rax = a51 + a51
    (int128) rdx rax = rax * a204M19
    low = rax
    high = rdx

    # a153*a102
    rax = a102 + a102
    (int128) rdx rax = rax * a153M19
    carry? low  += rax
    carry? high += rdx + carry

    # a0*a0
    rax = a0
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    r0 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r51 = 19*(2*a204*a102 + a153*a153) + 2*a51*a0
  #--------------------------------------------------------------
    # a204*a102
    rax = a102 + a102
    (int128) rdx rax = rax * a204M19
    carry? low  += rax
    carry? high += rdx + carry

    # a153*a153
    rax = a153
    (int128) rdx rax = rax * a153M19
    carry? low  += rax
    carry? high += rdx + carry

    # a51*b0
    rax = a0 + a0
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    r51 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r102 = 19*(2*a204*a153) + 2*a102*a0 + a51*a51
  #--------------------------------------------------------------
    # a204*a153
    rax = a153 + a153
    (int128) rdx rax = rax * a204M19
    carry? low += rax
    carry? high += rdx + carry

    # a102*a0
    rax = a0 + a0
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # a51*a51
    rax = a51
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    r102 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r153 = 19*(a204*a204) + 2*a153*a0 + 2*a102*a51
  #--------------------------------------------------------------
    # a204*a153
    rax = a204
    (int128) rdx rax = rax * a204M19
    carry? low += rax
    carry? high += rdx + carry

    # a153*a0
    rax = a0 + a0
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # a102*a51
    rax = a51 + a51
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    r153 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r204 = 2*a204*a0 + 2*a153*a51 + a102*b102
  #--------------------------------------------------------------
    # a204*a0
    rax = a0 + a0
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # a153*a51
    rax = a51 + a51
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # a102*a102
    rax = a102
    (int128) rdx rax = rax * a102
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
