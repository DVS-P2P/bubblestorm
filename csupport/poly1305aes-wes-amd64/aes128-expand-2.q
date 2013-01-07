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
int64 q0
int64 q1
int64 q2
int64 q3

int64 in
int64 out
int64 len

stack64 in_stack


enter aes128_amd64_2_expand
input c
input k

r11_stack = r11_caller
r12_stack = r12_caller
r13_stack = r13_caller
r14_stack = r14_caller
r15_stack = r15_caller
#MINGW rdi_stack = rdi_caller
#MINGW rsi_stack = rsi_caller
rbp_stack = rbp_caller
rbx_stack = rbx_caller

x0 = *(uint32 *) (k + 0)
x1 = *(uint32 *) (k + 4)
x2 = *(uint32 *) (k + 8)
x3 = *(uint32 *) (k + 12)
*(uint32 *) (c + 0) = x0
*(uint32 *) (c + 4) = x1
*(uint32 *) (c + 8) = x2
*(uint32 *) (c + 12) = x3

table = &aes128_amd64_2_tablex

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x01
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 16) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x02
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 20) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x04
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 24) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x08
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 28) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x10
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 32) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x20
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 36) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x40
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 40) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x80
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 44) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x1b
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 48) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (table + 1 + e * 8)
(uint32) e ^= 0x36
q3 = x3 & 255
(uint32) x3 <<<= 16
q3 = *(uint32 *) (table + 2 + q3 * 8)
(uint32) q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (table + 3 + q2 * 8)
(uint32) q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
(uint32) x3 <<<= 16
q1 = *(uint16 *) (table + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 52) = x0

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
