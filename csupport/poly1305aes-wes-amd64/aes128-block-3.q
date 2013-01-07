int64 r11_caller
int64 r12_caller
int64 r13_caller
int64 r14_caller
int64 r15_caller
#MINGW int64 rdi_caller
#MINGW int64 rsi_caller
int64 rbp_caller
int64 rbx_caller
caller r11_caller
caller r12_caller
caller r13_caller
caller r14_caller
caller r15_caller
#MINGW caller rdi_caller
#MINGW caller rsi_caller
caller rbp_caller
caller rbx_caller
stack64 r11_stack
stack64 r12_stack
stack64 r13_stack
stack64 r14_stack
stack64 r15_stack
#MINGW stack64 rdi_stack
#MINGW stack64 rsi_stack
stack64 rbp_stack
stack64 rbx_stack


int64 table

int64 c
int64 k
int64 iv

int64 x0
int64 x1
int64 x2
int64 x3
int64 e

int64 in
int64 out

#LINUX stack64 c_stack
stack64 out_stack

stack64 n0
stack64 n1
stack64 n2
stack64 n3

int64 y0
int64 y1
int64 y2
int64 y3

int64 z0
int64 z1
int64 z2
int64 z3

int64 p00
int64 p01
int64 p02
int64 p03

int64 p10
int64 p11
int64 p12
int64 p13

int64 p20
int64 p21
int64 p22
int64 p23

int64 p30
int64 p31
int64 p32
int64 p33

int64 q00
int64 q01
int64 q02
int64 q03

int64 q10
int64 q11
int64 q12
int64 q13

int64 q20
int64 q21
int64 q22
int64 q23

int64 q30
int64 q31
int64 q32
int64 q33


enter aes128_amd64_2_block stackaligned4096 aes128_amd64_2_constants
input out
input in
input c

#LINUX c_stack = c
out_stack = out
r11_stack = r11_caller
r12_stack = r12_caller
r13_stack = r13_caller
r14_stack = r14_caller
r15_stack = r15_caller
#MINGW rdi_stack = rdi_caller
#MINGW rsi_stack = rsi_caller
rbp_stack = rbp_caller
rbx_stack = rbx_caller

x0 = *(uint32 *) (c + 0)
x1 = *(uint32 *) (c + 4)
x2 = *(uint32 *) (c + 8)
x3 = *(uint32 *) (c + 12)

y0 = *(uint32 *) (in + 0)
y1 = *(uint32 *) (in + 4)
y2 = *(uint32 *) (in + 8)
y3 = *(uint32 *) (in + 12)

#LINUX assign 3 to y0
#LINUX assign 4 to y1
#LINUX assign 7 to y2
#LINUX assign 14 to y3

table = &aes128_amd64_2_tablex

#LINUX c = c_stack
y0 ^= x0
y1 ^= x1
y2 ^= x2
y3 ^= x3

x0 = *(uint32 *) (c + 16)
x1 ^= x0
x2 ^= x1
x3 ^= x2

p00 = y0 & 255
p01 = (y0 >> 8) & 255
(uint32) y0 >>= 16
p02 = y0 & 255
p03 = (y0 >> 8) & 255
z0 = *(uint32 *) (table + 3 + p00 * 8)
#LINUX assign 3 to z0
z0 ^= x0

p10 = y1 & 255
p11 = (y1 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
p13 = (y1 >> 8) & 255
z1 = *(uint32 *) (table + 4 + p03 * 8)
(uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
#LINUX assign 4 to z1

p20 = y2 & 255
p21 = (y2 >> 8) & 255
(uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
(uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
p23 = (y2 >> 8) & 255
z2 = *(uint32 *) (table + 1 + p02 * 8)
(uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
(uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
#LINUX assign 7 to z2

p30 = y3 & 255
p31 = (y3 >> 8) & 255
(uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
(uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
p33 = (y3 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
z3 = *(uint32 *) (table + 2 + p01 * 8)
z2 ^= x2
(uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
z1 ^= x1
(uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
(uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
z3 ^= x3
#LINUX assign 14 to z3

x0 = *(uint32 *) (c + 20)
x1 ^= x0
x2 ^= x1
x3 ^= x2

q00 = z0 & 255
q03 = (z0 >> 8) & 255
(uint32) z0 >>= 16
q02 = z0 & 255
q01 = (z0 >> 8) & 255
y0 = *(uint32 *) (table + 3 + q00 * 8)
#LINUX assign 3 to y0
y0 ^= x0

q10 = z1 & 255
q11 = (z1 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
(uint32) z1 >>= 16
q12 = z1 & 255
q13 = (z1 >> 8) & 255
y1 = *(uint32 *) (table + 4 + q01 * 8)
(uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
#LINUX assign 4 to y1

q20 = z2 & 255
q21 = (z2 >> 8) & 255
(uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
(uint32) z2 >>= 16
q22 = z2 & 255
(uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
q23 = (z2 >> 8) & 255
y2 = *(uint32 *) (table + 1 + q02 * 8)
(uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
(uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
#LINUX assign 7 to y2

q30 = z3 & 255
q31 = (z3 >> 8) & 255
(uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
(uint32) z3 >>= 16
q32 = z3 & 255
(uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
q33 = (z3 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
y3 = *(uint32 *) (table + 2 + q03 * 8)
y2 ^= x2
(uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
y1 ^= x1
(uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
(uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
y3 ^= x3
#LINUX assign 14 to y3


x0 = *(uint32 *) (c + 24)
x1 ^= x0
x2 ^= x1
x3 ^= x2

p00 = y0 & 255
p01 = (y0 >> 8) & 255
(uint32) y0 >>= 16
p02 = y0 & 255
p03 = (y0 >> 8) & 255
z0 = *(uint32 *) (table + 3 + p00 * 8)
#LINUX assign 3 to z0
z0 ^= x0

p10 = y1 & 255
p11 = (y1 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
p13 = (y1 >> 8) & 255
z1 = *(uint32 *) (table + 4 + p03 * 8)
(uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
#LINUX assign 4 to z1

p20 = y2 & 255
p21 = (y2 >> 8) & 255
(uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
(uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
p23 = (y2 >> 8) & 255
z2 = *(uint32 *) (table + 1 + p02 * 8)
(uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
(uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
#LINUX assign 7 to z2

p30 = y3 & 255
p31 = (y3 >> 8) & 255
(uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
(uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
p33 = (y3 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
z3 = *(uint32 *) (table + 2 + p01 * 8)
(uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
(uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
z1 ^= x1
(uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
#LINUX assign 14 to z3

z2 ^= x2
z3 ^= x3

x0 = *(uint32 *) (c + 28)
x1 ^= x0
x2 ^= x1
x3 ^= x2

q00 = z0 & 255
q03 = (z0 >> 8) & 255
(uint32) z0 >>= 16
q02 = z0 & 255
q01 = (z0 >> 8) & 255
y0 = *(uint32 *) (table + 3 + q00 * 8)
#LINUX assign 3 to y0
y0 ^= x0

q10 = z1 & 255
q11 = (z1 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
(uint32) z1 >>= 16
q12 = z1 & 255
q13 = (z1 >> 8) & 255
y1 = *(uint32 *) (table + 4 + q01 * 8)
(uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
#LINUX assign 4 to y1

q20 = z2 & 255
q21 = (z2 >> 8) & 255
(uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
(uint32) z2 >>= 16
q22 = z2 & 255
(uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
q23 = (z2 >> 8) & 255
y2 = *(uint32 *) (table + 1 + q02 * 8)
(uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
(uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
#LINUX assign 7 to y2

q30 = z3 & 255
q31 = (z3 >> 8) & 255
(uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
(uint32) z3 >>= 16
q32 = z3 & 255
(uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
q33 = (z3 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
y3 = *(uint32 *) (table + 2 + q03 * 8)
(uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
(uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
y1 ^= x1
(uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
#LINUX assign 14 to y3

y2 ^= x2
y3 ^= x3



x0 = *(uint32 *) (c + 32)
x1 ^= x0
x2 ^= x1
x3 ^= x2

p00 = y0 & 255
p01 = (y0 >> 8) & 255
(uint32) y0 >>= 16
p02 = y0 & 255
p03 = (y0 >> 8) & 255
z0 = *(uint32 *) (table + 3 + p00 * 8)
#LINUX assign 3 to z0
z0 ^= x0

p10 = y1 & 255
p11 = (y1 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
p13 = (y1 >> 8) & 255
z1 = *(uint32 *) (table + 4 + p03 * 8)
(uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
#LINUX assign 4 to z1

p20 = y2 & 255
p21 = (y2 >> 8) & 255
(uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
(uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
p23 = (y2 >> 8) & 255
z2 = *(uint32 *) (table + 1 + p02 * 8)
(uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
(uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
#LINUX assign 7 to z2

p30 = y3 & 255
p31 = (y3 >> 8) & 255
(uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
(uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
p33 = (y3 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
z3 = *(uint32 *) (table + 2 + p01 * 8)
(uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
(uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
z1 ^= x1
(uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
#LINUX assign 14 to z3

z2 ^= x2
z3 ^= x3

x0 = *(uint32 *) (c + 36)
x1 ^= x0
x2 ^= x1
x3 ^= x2

q00 = z0 & 255
q03 = (z0 >> 8) & 255
(uint32) z0 >>= 16
q02 = z0 & 255
q01 = (z0 >> 8) & 255
y0 = *(uint32 *) (table + 3 + q00 * 8)
#LINUX assign 3 to y0
y0 ^= x0

q10 = z1 & 255
q11 = (z1 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
(uint32) z1 >>= 16
q12 = z1 & 255
q13 = (z1 >> 8) & 255
y1 = *(uint32 *) (table + 4 + q01 * 8)
(uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
#LINUX assign 4 to y1

q20 = z2 & 255
q21 = (z2 >> 8) & 255
(uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
(uint32) z2 >>= 16
q22 = z2 & 255
(uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
q23 = (z2 >> 8) & 255
y2 = *(uint32 *) (table + 1 + q02 * 8)
(uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
(uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
#LINUX assign 7 to y2

q30 = z3 & 255
q31 = (z3 >> 8) & 255
(uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
(uint32) z3 >>= 16
q32 = z3 & 255
(uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
q33 = (z3 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
y3 = *(uint32 *) (table + 2 + q03 * 8)
(uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
(uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
y1 ^= x1
(uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
#LINUX assign 14 to y3

y2 ^= x2
y3 ^= x3



x0 = *(uint32 *) (c + 40)
x1 ^= x0
x2 ^= x1
x3 ^= x2

p00 = y0 & 255
p01 = (y0 >> 8) & 255
(uint32) y0 >>= 16
p02 = y0 & 255
p03 = (y0 >> 8) & 255
z0 = *(uint32 *) (table + 3 + p00 * 8)
#LINUX assign 3 to z0
z0 ^= x0

p10 = y1 & 255
p11 = (y1 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
p13 = (y1 >> 8) & 255
z1 = *(uint32 *) (table + 4 + p03 * 8)
(uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
#LINUX assign 4 to z1

p20 = y2 & 255
p21 = (y2 >> 8) & 255
(uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
(uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
p23 = (y2 >> 8) & 255
z2 = *(uint32 *) (table + 1 + p02 * 8)
(uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
(uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
#LINUX assign 7 to z2

p30 = y3 & 255
p31 = (y3 >> 8) & 255
(uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
(uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
p33 = (y3 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
z3 = *(uint32 *) (table + 2 + p01 * 8)
(uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
(uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
z1 ^= x1
(uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
#LINUX assign 14 to z3

z2 ^= x2
z3 ^= x3

x0 = *(uint32 *) (c + 44)
x1 ^= x0
x2 ^= x1
x3 ^= x2

q00 = z0 & 255
q03 = (z0 >> 8) & 255
(uint32) z0 >>= 16
q02 = z0 & 255
q01 = (z0 >> 8) & 255
y0 = *(uint32 *) (table + 3 + q00 * 8)
#LINUX assign 3 to y0
y0 ^= x0

q10 = z1 & 255
q11 = (z1 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
(uint32) z1 >>= 16
q12 = z1 & 255
q13 = (z1 >> 8) & 255
y1 = *(uint32 *) (table + 4 + q01 * 8)
(uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
#LINUX assign 4 to y1

q20 = z2 & 255
q21 = (z2 >> 8) & 255
(uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
(uint32) z2 >>= 16
q22 = z2 & 255
(uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
q23 = (z2 >> 8) & 255
y2 = *(uint32 *) (table + 1 + q02 * 8)
(uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
(uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
#LINUX assign 7 to y2

q30 = z3 & 255
q31 = (z3 >> 8) & 255
(uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
(uint32) z3 >>= 16
q32 = z3 & 255
(uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
q33 = (z3 >> 8) & 255
(uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
y3 = *(uint32 *) (table + 2 + q03 * 8)
(uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
(uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
y1 ^= x1
(uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
#LINUX assign 14 to y3

y2 ^= x2
y3 ^= x3


x0 = *(uint32 *) (c + 48)
x1 ^= x0
x2 ^= x1
x3 ^= x2

p00 = y0 & 255
p01 = (y0 >> 8) & 255
(uint32) y0 >>= 16
p02 = y0 & 255
p03 = (y0 >> 8) & 255
z0 = *(uint32 *) (table + 3 + p00 * 8)
#LINUX assign 3 to z0
z0 ^= x0

p10 = y1 & 255
p11 = (y1 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
p13 = (y1 >> 8) & 255
z1 = *(uint32 *) (table + 4 + p03 * 8)
(uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
#LINUX assign 4 to z1

p20 = y2 & 255
p21 = (y2 >> 8) & 255
(uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
(uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
p23 = (y2 >> 8) & 255
z2 = *(uint32 *) (table + 1 + p02 * 8)
(uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
(uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
#LINUX assign 7 to z2

p30 = y3 & 255
p31 = (y3 >> 8) & 255
(uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
(uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
p33 = (y3 >> 8) & 255
(uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
z3 = *(uint32 *) (table + 2 + p01 * 8)
(uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
(uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
z1 ^= x1
(uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
#LINUX assign 14 to z3

z2 ^= x2
z3 ^= x3


x0 = *(uint32 *) (c + 52)
x1 ^= x0
x2 ^= x1
x3 ^= x2


y0 = z0 & 255
y0 = *(uint8 *) (table + 1 + y0 * 8)
y3 = (z0 >> 8) & 255
y3 = *(uint16 *) (table + y3 * 8)
(uint32) z0 >>= 16
y2 = z0 & 255
y2 = *(uint32 *) (table + 3 + y2 * 8)
(uint32) y2 &= 0x00ff0000
y1 = (z0 >> 8) & 255
y1 = *(uint32 *) (table + 2 + y1 * 8)
(uint32) y1 &= 0xff000000
y0 ^= x0
y3 ^= x3
y1 ^= x1
y2 ^= x2

q10 = z1 & 255
q10 = *(uint8 *) (table + 1 + q10 * 8)
y1 ^= q10
q11 = (z1 >> 8) & 255
q11 = *(uint16 *) (table + q11 * 8)
y0 ^= q11
(uint32) z1 >>= 16
q12 = z1 & 255
q12 = *(uint32 *) (table + 3 + q12 * 8)
(uint32) q12 &= 0x00ff0000
y3 ^= q12
q13 = (z1 >> 8) & 255
q13 = *(uint32 *) (table + 2 + q13 * 8)
(uint32) q13 &= 0xff000000
y2 ^= q13

q20 = z2 & 255
q20 = *(uint8 *) (table + 1 + q20 * 8)
y2 ^= q20
q21 = (z2 >> 8) & 255
q21 = *(uint16 *) (table + q21 * 8)
y1 ^= q21
(uint32) z2 >>= 16
q22 = z2 & 255
q22 = *(uint32 *) (table + 3 + q22 * 8)
(uint32) q22 &= 0x00ff0000
y0 ^= q22
q23 = (z2 >> 8) & 255
q23 = *(uint32 *) (table + 2 + q23 * 8)
(uint32) q23 &= 0xff000000
y3 ^= q23

q30 = z3 & 255
q30 = *(uint8 *) (table + 1 + q30 * 8)
y3 ^= q30
q31 = (z3 >> 8) & 255
q31 = *(uint16 *) (table + q31 * 8)
y2 ^= q31
(uint32) z3 >>= 16
q32 = z3 & 255
q32 = *(uint32 *) (table + 3 + q32 * 8)
(uint32) q32 &= 0x00ff0000
y1 ^= q32
q33 = (z3 >> 8) & 255
q33 = *(uint32 *) (table + 2 + q33 * 8)
(uint32) q33 &= 0xff000000
y0 ^= q33


out = out_stack

*(uint32 *) (out + 0) = y0
*(uint32 *) (out + 4) = y1
*(uint32 *) (out + 8) = y2
*(uint32 *) (out + 12) = y3

r11_caller = r11_stack
r12_caller = r12_stack
r13_caller = r13_stack
r14_caller = r14_stack
r15_caller = r15_stack
#MINGW rdi_caller = rdi_stack
#MINGW rsi_caller = rsi_stack
rbp_caller = rbp_stack
rbx_caller = rbx_stack

leave
