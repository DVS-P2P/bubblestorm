stack32 arg1
stack32 arg2
stack32 arg3
input arg1
input arg2
input arg3

int32 eax
int32 ebx
int32 esi
int32 edi
int32 ebp
caller eax
caller ebx
caller esi
caller edi
caller ebp

stack32 eax_stack
stack32 ebx_stack
stack32 esi_stack
stack32 edi_stack
stack32 ebp_stack

int32 c
int32 k
int32 iv

int32 x0
int32 x1
int32 x2
int32 x3
int32 e
int32 q0
int32 q1
int32 q2
int32 q3

int32 in
int32 out
int32 len

int3232 c_stack
int3232 in_stack
int3232 out_stack
int3232 len_stack

int3232 y1_stack
int3232 y2_stack
int3232 y3_stack
int3232 z1_stack
int3232 z2_stack
int3232 z3_stack

stack32 n0
stack32 n1
stack32 n2
stack32 n3

stack32 r0
stack32 r1
stack32 r2
stack32 r3
stack32 r4
stack32 r5
stack32 r6
stack32 r7
stack32 r8
stack32 r9
stack32 r10
stack32 r11
stack32 r12
stack32 r13
stack32 r14
stack32 r15
stack32 r16
stack32 r17
stack32 r18
stack32 r19
stack32 r20
stack32 r21
stack32 r22
stack32 r23
stack32 r24
stack32 r25
stack32 r26
stack32 r27
stack32 r28
stack32 r29
stack32 r30
stack32 r31
stack32 r32
stack32 r33
stack32 r34
stack32 r35
stack32 r36
stack32 r37
stack32 r38
stack32 r39
stack32 r40
stack32 r41
stack32 r42
stack32 r43

int32 y0
int32 y1
int32 y2
int32 y3

int32 z0
int32 z1
int32 z2
int32 z3

int32 p00
int32 p01
int32 p02
int32 p03

int32 p10
int32 p11
int32 p12
int32 p13

int32 p20
int32 p21
int32 p22
int32 p23

int32 p30
int32 p31
int32 p32
int32 p33

int32 b0
int32 b1
int32 b2
int32 b3


enter aes128_x86mmx1_block stackaligned4096 aes128_x86mmx1_constants

eax_stack = eax
ebx_stack = ebx
esi_stack = esi
edi_stack = edi
ebp_stack = ebp

c = arg3

out = arg1
out_stack = out

x0 = *(uint32 *) (c + 0)
x1 = *(uint32 *) (c + 4)
x2 = *(uint32 *) (c + 8)
x3 = *(uint32 *) (c + 12)
r0 = x0
r1 = x1
r2 = x2
r3 = x3

x0 = *(uint32 *) (c + 16)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r4 = x0
r5 = x1
r6 = x2
r7 = x3

x0 = *(uint32 *) (c + 20)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r8 = x0
r9 = x1
r10 = x2
r11 = x3

x0 = *(uint32 *) (c + 24)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r12 = x0
r13 = x1
r14 = x2
r15 = x3

x0 = *(uint32 *) (c + 28)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r16 = x0
r17 = x1
r18 = x2
r19 = x3

x0 = *(uint32 *) (c + 32)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r20 = x0
r21 = x1
r22 = x2
r23 = x3

x0 = *(uint32 *) (c + 36)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r24 = x0
r25 = x1
r26 = x2
r27 = x3

x0 = *(uint32 *) (c + 40)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r28 = x0
r29 = x1
r30 = x2
r31 = x3

x0 = *(uint32 *) (c + 44)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r32 = x0
r33 = x1
r34 = x2
r35 = x3

x0 = *(uint32 *) (c + 48)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r36 = x0
r37 = x1
r38 = x2
r39 = x3

x0 = *(uint32 *) (c + 52)
x1 ^= x0
x2 ^= x1
x3 ^= x2
r40 = x0
r41 = x1
r42 = x2
r43 = x3

in = arg2

y0 = *(uint32 *) (in + 0)
y1 = *(uint32 *) (in + 4)
y2 = *(uint32 *) (in + 8)
y3 = *(uint32 *) (in + 12)

y0 ^= r0
y1 ^= r1
y2 ^= r2
y3 ^= r3


y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r4
y0 ^= z0
y1 = r5
y1 ^= z1
y2 = r6
y2 ^= z2
y3 = r7
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r8
y0 ^= z0
y1 = r9
y1 ^= z1
y2 = r10
y2 ^= z2
y3 = r11
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r12
y0 ^= z0
y1 = r13
y1 ^= z1
y2 = r14
y2 ^= z2
y3 = r15
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r16
y0 ^= z0
y1 = r17
y1 ^= z1
y2 = r18
y2 ^= z2
y3 = r19
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r20
y0 ^= z0
y1 = r21
y1 ^= z1
y2 = r22
y2 ^= z2
y3 = r23
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r24
y0 ^= z0
y1 = r25
y1 ^= z1
y2 = r26
y2 ^= z2
y3 = r27
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r28
y0 ^= z0
y1 = r29
y1 ^= z1
y2 = r30
y2 ^= z2
y3 = r31
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r32
y0 ^= z0
y1 = r33
y1 ^= z1
y2 = r34
y2 ^= z2
y3 = r35
y3 ^= z3

y3_stack = y3
p00 = y0 & 255
z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
p03 = (y0 >> 8) & 255
(uint32) y0 >>= 16
z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
p02 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
p01 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
p10 = y1 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
p11 = (y1 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
(uint32) y1 >>= 16
p12 = y1 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
p13 = (y1 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
y3 = y3_stack
p20 = y2 & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
p21 = (y2 >> 8) & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
(uint32) y2 >>= 16
p22 = y2 & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
p23 = (y2 >> 8) & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
p30 = y3 & 255
z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
p31 = (y3 >> 8) & 255
z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
(uint32) y3 >>= 16
p32 = y3 & 255
z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
p33 = (y3 >> 8) & 255
z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
y0 = r36
y0 ^= z0
y1 = r37
y1 ^= z1
y2 = r38
y2 ^= z2
y3 = r39
y3 ^= z3


y3_stack = y3

z0 = y0 & 255
z0 = *(uint8 *) (&aes128_x86mmx1_table2 + z0 * 8)
z3 = (y0 >> 8) & 255
z3 = *(uint16 *) (&aes128_x86mmx1_tablex + z3 * 8)
(uint32) y0 >>= 16
z2 = y0 & 255
z2 = *(uint32 *) (&aes128_x86mmx1_table0 + z2 * 8)
z2 &= 0x00ff0000
z1 = (y0 >> 8) & 255
z1 = *(uint32 *) (&aes128_x86mmx1_table1 + z1 * 8)
z1 &= 0xff000000
z0 ^= r40
z3 ^= r43
z1 ^= r41
z2 ^= r42

p10 = y1 & 255
p10 = *(uint8 *) (&aes128_x86mmx1_table2 + p10 * 8)
z1 ^= p10
p11 = (y1 >> 8) & 255
p11 = *(uint16 *) (&aes128_x86mmx1_tablex + p11 * 8)
z0 ^= p11
(uint32) y1 >>= 16
p12 = y1 & 255
p12 = *(uint32 *) (&aes128_x86mmx1_table0 + p12 * 8)
p12 &= 0x00ff0000
z3 ^= p12
p13 = (y1 >> 8) & 255
p13 = *(uint32 *) (&aes128_x86mmx1_table1 + p13 * 8)
p13 &= 0xff000000
z2 ^= p13

y3 = y3_stack

p20 = y2 & 255
p20 = *(uint8 *) (&aes128_x86mmx1_table2 + p20 * 8)
z2 ^= p20
p21 = (y2 >> 8) & 255
p21 = *(uint16 *) (&aes128_x86mmx1_tablex + p21 * 8)
z1 ^= p21
(uint32) y2 >>= 16
p22 = y2 & 255
p22 = *(uint32 *) (&aes128_x86mmx1_table0 + p22 * 8)
p22 &= 0x00ff0000
z0 ^= p22
p23 = (y2 >> 8) & 255
p23 = *(uint32 *) (&aes128_x86mmx1_table1 + p23 * 8)
p23 &= 0xff000000
z3 ^= p23

p30 = y3 & 255
p30 = *(uint8 *) (&aes128_x86mmx1_table2 + p30 * 8)
z3 ^= p30
p31 = (y3 >> 8) & 255
p31 = *(uint16 *) (&aes128_x86mmx1_tablex + p31 * 8)
z2 ^= p31
(uint32) y3 >>= 16
p32 = y3 & 255
p32 = *(uint32 *) (&aes128_x86mmx1_table0 + p32 * 8)
p32 &= 0x00ff0000
z1 ^= p32
p33 = (y3 >> 8) & 255
p33 = *(uint32 *) (&aes128_x86mmx1_table1 + p33 * 8)
p33 &= 0xff000000
z0 ^= p33

out = out_stack

*(uint32 *) (out + 0) = z0
*(uint32 *) (out + 4) = z1
*(uint32 *) (out + 8) = z2
*(uint32 *) (out + 12) = z3

emms

eax = eax_stack
ebx = ebx_stack
esi = esi_stack
edi = edi_stack
ebp = ebp_stack

leave
