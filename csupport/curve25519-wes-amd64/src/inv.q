              #                     lin  win
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

int6464 e0    # 11
int6464 e51   # 12
int6464 e102  # 13
int6464 e153  # 14
int6464 e204  # 15

int6464 xmm6
int6464 xmm7
int6464 xmm8
int6464 xmm9
int6464 xmm10
int6464 xmm11
int6464 xmm12
int6464 xmm13
int6464 xmm14
int6464 xmm15

int64 r11
int64 r12
int64 r13
int64 r14
int64 r15
#MINGW int64 rdi
#MINGW int64 rsi
int64 rbx
int64 rbp

stack128 xmm6_stack
stack128 xmm7_stack
stack128 xmm8_stack
stack128 xmm9_stack
stack128 xmm10_stack
stack128 xmm11_stack
stack128 xmm12_stack
stack128 xmm13_stack
stack128 xmm14_stack
stack128 xmm15_stack

stack64 r11_stack
stack64 r12_stack
stack64 r13_stack
stack64 r14_stack
stack64 r15_stack
#MINGW stack64 rdi_stack
#MINGW stack64 rsi_stack
stack64 rbx_stack
stack64 rbp_stack

caller xmm6
caller xmm7
caller xmm8
caller xmm9
caller xmm10
caller xmm11
caller xmm12
caller xmm13
caller xmm14
caller xmm15

caller r11
caller r12
caller r13
caller r14
caller r15
#MINGW caller rdi
#MINGW caller rsi
caller rbx
caller rbp

int64 r
int64 a

stack64 r_stack

input r
input a

enter field25519_wes_inv
  xmm6_stack = xmm6
  xmm7_stack = xmm7
  xmm8_stack = xmm8
  xmm9_stack = xmm9
  xmm10_stack = xmm10
  xmm11_stack = xmm11
  xmm12_stack = xmm12
  xmm13_stack = xmm13
  xmm14_stack = xmm14
  xmm15_stack = xmm15

  r11_stack = r11
  r12_stack = r12
  r13_stack = r13
  r14_stack = r14
  r15_stack = r15
#MINGW  rdi_stack = rdi
#MINGW  rsi_stack = rsi
  rbx_stack = rbx
  rbp_stack = rbp

  r_stack = r

  b0   = *(uint64 *)(a +  0)
  b51  = *(uint64 *)(a +  8)
  b102 = *(uint64 *)(a + 16)
  b153 = *(uint64 *)(a + 24)
  b204 = *(uint64 *)(a + 32)

  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204

  call powtrick local
  call sqrBtoA local
  call sqrAtoB local
  call sqrBtoA local
  call sqrAtoB local
  call sqrBtoA local

  e0   = register 11
  e51  = register 12
  e102 = register 13
  e153 = register 14
  e204 = register 15

  c0   = e0
  c51  = e51
  c102 = e102
  c153 = e153
  c204 = e204

  assign 1 to c0
  assign 2 to c51
  assign 3 to c102
  assign 4 to c153
  assign 5 to c204

  call mulACtoB local

  r = r_stack
  *(uint64 *)(r +  0) = b0
  *(uint64 *)(r +  8) = b51
  *(uint64 *)(r + 16) = b102
  *(uint64 *)(r + 24) = b153
  *(uint64 *)(r + 32) = b204

  xmm6 = xmm6_stack
  xmm7 = xmm7_stack
  xmm8 = xmm8_stack
  xmm9 = xmm9_stack
  xmm10 = xmm10_stack
  xmm11 = xmm11_stack
  xmm12 = xmm12_stack
  xmm13 = xmm13_stack
  xmm14 = xmm14_stack
  xmm15 = xmm15_stack

  r11 = r11_stack
  r12 = r12_stack
  r13 = r13_stack
  r14 = r14_stack
  r15 = r15_stack
#MINGW  rdi = rdi_stack
#MINGW  rsi = rsi_stack
  rbx = rbx_stack
  rbp = rbp_stack
leave
