stack32 arg1
stack32 arg2
input arg1
input arg2

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

int32 x0
int32 x1
int32 x2
int32 x3
int32 e
int32 q0
int32 q1
int32 q2
int32 q3


enter aes128_x86mmx1_expand

eax_stack = eax
ebx_stack = ebx
esi_stack = esi
edi_stack = edi
ebp_stack = ebp

c = arg1
k = arg2

x0 = *(uint32 *) (k + 0)
x1 = *(uint32 *) (k + 4)
x2 = *(uint32 *) (k + 8)
x3 = *(uint32 *) (k + 12)
*(uint32 *) (c + 0) = x0
*(uint32 *) (c + 4) = x1
*(uint32 *) (c + 8) = x2
*(uint32 *) (c + 12) = x3

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x01
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 16) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x02
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 20) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x04
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 24) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x08
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 28) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x10
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 32) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x20
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 36) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x40
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 40) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x80
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 44) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x1b
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 48) = x0
x1 ^= x0
x2 ^= x1
x3 ^= x2

e = (x3 >> 8) & 255
e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
e ^= 0x36
q3 = x3 & 255
x3 <<<= 16
q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
q3 &= 0xff000000
e ^= q3
q2 = (x3 >> 8) & 255
q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
q2 &= 0x00ff0000
e ^= q2
q1 = x3 & 255
x3 <<<= 16
q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
e ^= q1
x0 ^= e
*(uint32 *) (c + 52) = x0

eax = eax_stack
ebx = ebx_stack
esi = esi_stack
edi = edi_stack
ebp = ebp_stack

leave
