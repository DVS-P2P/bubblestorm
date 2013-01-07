# We need to keep rax and rdx free for MUL
# Therefore, we assign aX and bX to registers to skip 3&7 (lin) and 2&5 (win)

# 23457 = rsi rdx rcx r8 rax (linux)
# r8 used by scal for overflow before rax=b102
# r8 used by mask for sqr and mul

              #                     lin  win
int64 counter #  4                  rcx  r9

int64 a0      #  6                  r9   r10
int64 a51     #  1  <---- WARNING   rdi  rcx
int64 a102    #  8                  r10  r12
int64 a153    #  9                  r11  r13
int64 a204    # 10                  r12  r14

int64 b0      # 11                  r13  r15
int64 b51     # 12                  r14  rdi
int64 b102    # 13                  r15  rsi
int64 b153    # 14                  rbx  rbp
int64 b204    # 15                  rbp  rbx

int6464 c0    #  1
int6464 c51   #  2
int6464 c102  #  3
int6464 c153  #  4
int6464 c204  #  5

int6464 d0    #  6
int6464 d51   #  7
int6464 d102  #  8
int6464 d153  #  9
int6464 d204  # 10

int6464 e0    # 11
int6464 e51   # 12
int6464 e102  # 13
int6464 e153  # 14
int6464 e204  # 15

# Let qhasm sort these assignments out
int64 rax
int64 rdx

int64 mask
int64 high
int64 low

int64 scal
int64 overflow

int64 a153M19
int64 a204M19
int64 b153M19
int64 b204M19
int64 c51M19
int64 c102M19
int64 c153M19
int64 c204M19

# Multiply B by 121665 and store result into A
# Input:     B
# Output:    A
# Preserved: B C D E F and counter
enter scalBtoA local
  b0   = register 11
  b51  = register 12
  b102 = register 13
  b153 = register 14
  b204 = register 15
  counter = register 4

  mask = 0x7ffffffffffff
  scal = 121665
  assign 10 to scal

  rax = b0
  (int128) rdx rax = rax * scal
  rdx = (rdx.rax) << 13
  rax &= mask
  a0 = rax
  overflow = rdx

  rax = b51
  (int128) rdx rax = rax * scal
  rdx = (rdx.rax) << 13
  rax &= mask
  a51 = rax + overflow
  overflow = rdx

  rax = b102
  (int128) rdx rax = rax * scal
  rdx = (rdx.rax) << 13
  rax &= mask
  a102 = rax + overflow
  overflow = rdx

  rax = b153
  (int128) rdx rax = rax * scal
  rdx = (rdx.rax) << 13
  rax &= mask
  a153 = rax + overflow
  overflow = rdx

  rax = b204
  (int128) rdx rax = rax * scal
  rdx = (rdx.rax) << 13
  rax &= mask
  a204 = rax + overflow
  
  rdx *= 19
  a0 += rdx

  # force these registers non-destroyed
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204

  assign 6 to a0
  assign 1 to a51
  assign 8 to a102
  assign 9 to a153
  assign 10 to a204

  assign 4 to counter
leave local

# Square A and store result into B
# Input:     A
# Output:    B
# Preserved: A C D E F and counter
enter sqrAtoB local
  a0   = register 6
  a51  = register 1
  a102 = register 8
  a153 = register 9
  a204 = register 10
  counter = register 4

  a153M19 = a153
  a204M19 = a204
  a153M19 *= 19
  a204M19 *= 19

  # by the time b102 and b153 are set, these are dead
  assign 13 to a153M19
  assign 14 to a204M19

  # b0 = 19*(2*a204*a51 + 2*a153*a102) + a0*a0
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
    b0 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b51 = 19*(2*a204*a102 + a153*a153) + 2*a51*a0
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
    b51 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b102 = 19*(2*a204*a153) + 2*a102*a0 + a51*a51
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
    b102 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b153 = 19*(a204*a204) + 2*a153*a0 + 2*a102*a51
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
    b153 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b204 = 2*a204*a0 + 2*a153*a51 + a102*b102
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
    b204 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # *19
  high *= 19
  rax = 19
  (uint128) rdx rax = rax * low
  rdx += high

  mask = 0x7ffffffffffff

  b0   &= mask
  b51  &= mask
  b102 &= mask
  b153 &= mask
  b204 &= mask

  mask &= rax
  rax = (rdx rax) >> 51
  
  b0  += mask
  b51 += rax

  # force these registers non-destroyed
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204

  assign 6 to a0
  assign 1 to a51
  assign 8 to a102
  assign 9 to a153
  assign 10 to a204

  assign 4 to counter
leave local

# Square B and store result into A
# Input:     B
# Output:    A
# Preserved: B C D E F and counter
enter sqrBtoA local
  b0   = register 11
  b51  = register 12
  b102 = register 13
  b153 = register 14
  b204 = register 15
  counter = register 4

  b153M19 = b153
  b204M19 = b204
  b153M19 *= 19
  b204M19 *= 19

  # by the time a102 and a153 are set, these are dead
  assign 8 to b153M19
  assign 9 to b204M19

  # r0 = 19*(2*b204*b51 + 2*b153*b102) + b0*b0
  #--------------------------------------------------------------
    # b204*b51
    rax = b51 + b51
    (int128) rdx rax = rax * b204M19
    low = rax
    high = rdx

    # b153*b102
    rax = b102 + b102
    (int128) rdx rax = rax * b153M19
    carry? low  += rax
    carry? high += rdx + carry

    # b0*b0
    rax = b0
    (int128) rdx rax = rax * b0
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    a0 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r51 = 19*(2*b204*b102 + b153*b153) + 2*b51*b0
  #--------------------------------------------------------------
    # b204*b102
    rax = b102 + b102
    (int128) rdx rax = rax * b204M19
    carry? low  += rax
    carry? high += rdx + carry

    # b153*b153
    rax = b153
    (int128) rdx rax = rax * b153M19
    carry? low  += rax
    carry? high += rdx + carry

    # b51*b0
    rax = b0 + b0
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    a51 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r102 = 19*(2*b204*b153) + 2*b102*b0 + b51*b51
  #--------------------------------------------------------------
    # b204*b153
    rax = b153 + b153
    (int128) rdx rax = rax * b204M19
    carry? low += rax
    carry? high += rdx + carry

    # b102*b0
    rax = b0 + b0
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # b51*b51
    rax = b51
    (int128) rdx rax = rax * b51
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    a102 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r153 = 19*(b204*b204) + 2*b153*b0 + 2*b102*b51
  #--------------------------------------------------------------
    # b204*b153
    rax = b204
    (int128) rdx rax = rax * b204M19
    carry? low += rax
    carry? high += rdx + carry

    # b153*b0
    rax = b0 + b0
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # b102*b51
    rax = b51 + b51
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    a153 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # r204 = 2*b204*b0 + 2*b153*b51 + b102*b102
  #--------------------------------------------------------------
    # b204*b0
    rax = b0 + b0
    (int128) rdx rax = rax * b204
    carry? low  += rax
    carry? high += rdx + carry

    # b153*b51
    rax = b51 + b51
    (int128) rdx rax = rax * b153
    carry? low  += rax
    carry? high += rdx + carry

    # b102*b102
    rax = b102
    (int128) rdx rax = rax * b102
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    a204 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # *19
  high *= 19
  rax = 19
  (uint128) rdx rax = rax * low
  rdx += high

  mask = 0x7ffffffffffff

  a0   &= mask
  a51  &= mask
  a102 &= mask
  a153 &= mask
  a204 &= mask

  mask &= rax
  rax = (rdx rax) >> 51
  
  a0  += mask
  a51 += rax

  # force these registers non-destroyed
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204

  assign 6 to a0
  assign 1 to a51
  assign 8 to a102
  assign 9 to a153
  assign 10 to a204

  assign 4 to counter
leave local

# Multiply A by C and store result into B
# Input:     A C
# Output:    B
# Preserved: A C D E F and counter
enter mulACtoB local
  a0   = register 6
  a51  = register 1
  a102 = register 8
  a153 = register 9
  a204 = register 10

  c0   = register 1
  c51  = register 2
  c102 = register 3
  c153 = register 4
  c204 = register 5

  counter = register 4

  c51M19  = c51
  c102M19 = c102
  c153M19 = c153
  c204M19 = c204

  # These get killed off one at a time (making room for b)
  assign 11 to c51M19
  assign 12 to c102M19
  assign 13 to c153M19
  assign 14 to c204M19

  c51M19  *= 19
  c102M19 *= 19
  c153M19 *= 19
  c204M19 *= 19
  
  # b0 = 19*(c204*a51 + c153*a102 + c102*a153 + c51*a204) + c0*a0
  #--------------------------------------------------------------
    # c204*a51
    rax = c204M19
    (int128) rdx rax = rax * a51
    low = rax
    high = rdx

    # c153*a102
    rax = c153M19
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # c102*a153
    rax = c102M19
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # c51*a204
    rax = c51M19
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # c0*a0
    rax = c0
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    b0 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b51 = 19*(c204*a102 + c153*a153 + c102*a204) + c51*a0 + c0*a51
  #--------------------------------------------------------------
    # c204*a102
    rax = c204M19
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # c153*a153
    rax = c153M19
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # c102*a204
    rax = c102M19
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # c51*a0
    rax = c51
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry

    # c0*a51
    rax = c0
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    b51 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b102 = 19*(c204*a153 + c153*a204) + c102*a0 + c51*a51 + c0*a102
  #--------------------------------------------------------------
    # c204*a153
    rax = c204M19
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # c153*a204
    rax = c153M19
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # c102*a0
    rax = c102
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry

    # c51*a51
    rax = c51
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry

    # c0*a102
    rax = c0
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    b102 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b153 = 19*(c204*a204) + c153*a0 + c102*a51 + c51*a102 + c0*a153
  #--------------------------------------------------------------
    # c204*a153
    rax = c204M19
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # c153*a0
    rax = c153
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry

    # c102*a51
    rax = c102
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry

    # c51*a102
    rax = c51
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # c0*a153
    rax = c0
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry
    
    # store and carry
    b153 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # b204 = c204*a0 + c153*a51 + c102*a102 + c51*a153 + c0*a204
  #--------------------------------------------------------------
    # c204*a0
    rax = c204
    (int128) rdx rax = rax * a0
    carry? low  += rax
    carry? high += rdx + carry

    # c153*a51
    rax = c153
    (int128) rdx rax = rax * a51
    carry? low  += rax
    carry? high += rdx + carry

    # c102*a102
    rax = c102
    (int128) rdx rax = rax * a102
    carry? low  += rax
    carry? high += rdx + carry

    # c51*a153
    rax = c51
    (int128) rdx rax = rax * a153
    carry? low  += rax
    carry? high += rdx + carry

    # c0*a204
    rax = c0
    (int128) rdx rax = rax * a204
    carry? low  += rax
    carry? high += rdx + carry

    # store and carry
    b204 = low
    low = (high low) >> 51
    (int64) high >>= 51

  # *19
  high *= 19
  rax = 19
  (uint128) rdx rax = rax * low
  rdx += high

  mask = 0x7ffffffffffff

  b0   &= mask
  b51  &= mask
  b102 &= mask
  b153 &= mask
  b204 &= mask

  mask &= rax
  rax = (rdx rax) >> 51
  
  b0  += mask
  b51 += rax

  # force these registers non-destroyed
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204

  assign 6 to a0
  assign 1 to a51
  assign 8 to a102
  assign 9 to a153
  assign 10 to a204

  assign 4 to counter
leave local

# Input: B=1
# Output: B=f250 E=11
enter powtrick local
   b0   = register 11
   b51  = register 12
   b102 = register 13
   b153 = register 14
   b204 = register 15       # B = 1     C D E

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D E     1

   call sqrBtoA local       # A = 2       D E     1

   a0   = register 6
   a51  = register 1
   a102 = register 8
   a153 = register 9
   a204 = register 10

   d0   = a0
   d51  = a51
   d102 = a102
   d153 = a153
   d204 = a204

   assign  6 to d0
   assign  7 to d51
   assign  8 to d102
   assign  9 to d153
   assign 10 to d204        #               E     1   2

   call sqrAtoB local       # B = 4
   call sqrBtoA local       # A = 8
   call mulACtoB local      # B = 9     C   E         2

   a0   = d0
   a51  = d51
   a102 = d102
   a153 = d153
   a204 = d204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = 2     C D E

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D E     9

   call mulACtoB local      # B = 11

   e0   = b0
   e51  = b51
   e102 = b102
   e153 = b153
   e204 = b204

   assign 11 to e0
   assign 12 to e51
   assign 13 to e102
   assign 14 to e153
   assign 15 to e204        #             D       9     11

   call sqrBtoA local       # A = 22  
   call mulACtoB local      # B = f5    C D             11

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D      f5     11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local       # A = f5^5
   call mulACtoB local      # B = f10   C D             11

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D     f10     11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f10^10

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f10^10

   call mulACtoB local      # B = f20     D     f10     11

   d0   = c0
   d51  = c51
   d102 = c102
   d153 = c153
   d204 = c204

   assign  6 to d0
   assign  7 to d51
   assign  8 to d102
   assign  9 to d153
   assign 10 to d204        #           C           f10 11

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #                   f20 f10 11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f20^20

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f20^20

   call mulACtoB local      # B = f40

   c0   = d0
   c51  = d51
   c102 = d102
   c153 = d153
   c204 = d204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D     f10     11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f40^10

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f40^10

   call mulACtoB local      # B = f50   C D             11

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D     f50     11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f50^50

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f50^50

   call mulACtoB local      # B = f100    D     f50     11

   d0   = c0
   d51  = c51
   d102 = c102
   d153 = c153
   d204 = c204

   assign  6 to d0
   assign  7 to d51
   assign  8 to d102
   assign  9 to d153
   assign 10 to d204        #           C           f50 11

   c0   = b0
   c51  = b51
   c102 = b102
   c153 = b153
   c204 = b204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #                  f100 f50 11

   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f100^100

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f100^100     f100 f50 11

   call mulACtoB local      # B = f200  C           f50 11
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local
   call sqrBtoA local
   call sqrAtoB local       # B = f200^50

   a0   = b0
   a51  = b51
   a102 = b102
   a153 = b153
   a204 = b204

   assign  6 to a0
   assign  1 to a51
   assign  8 to a102
   assign  9 to a153
   assign 10 to a204        # A = f200^50

   c0   = d0
   c51  = d51
   c102 = d102
   c153 = d153
   c204 = d204

   assign 1 to c0
   assign 2 to c51
   assign 3 to c102
   assign 4 to c153
   assign 5 to c204         #             D     f50     11

   call mulACtoB local      # B = f250  C D             11
leave local
