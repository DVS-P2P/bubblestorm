
# qhasm: stack32 arg1

# qhasm: stack32 arg2

# qhasm: input arg1

# qhasm: input arg2

# qhasm: int32 eax

# qhasm: int32 ebx

# qhasm: int32 esi

# qhasm: int32 edi

# qhasm: int32 ebp

# qhasm: caller eax

# qhasm: caller ebx

# qhasm: caller esi

# qhasm: caller edi

# qhasm: caller ebp

# qhasm: stack32 eax_stack

# qhasm: stack32 ebx_stack

# qhasm: stack32 esi_stack

# qhasm: stack32 edi_stack

# qhasm: stack32 ebp_stack

# qhasm: int32 c

# qhasm: int32 k

# qhasm: int32 x0

# qhasm: int32 x1

# qhasm: int32 x2

# qhasm: int32 x3

# qhasm: int32 e

# qhasm: int32 q0

# qhasm: int32 q1

# qhasm: int32 q2

# qhasm: int32 q3

# qhasm: enter aes128_x86mmx1_expand
.text
.p2align 5
.globl _aes128_x86mmx1_expand
.globl aes128_x86mmx1_expand
_aes128_x86mmx1_expand:
aes128_x86mmx1_expand:
mov %esp,%eax
and $31,%eax
add $32,%eax
sub %eax,%esp

# qhasm: eax_stack = eax
# asm 1: movl <eax=int32#1,>eax_stack=stack32#1
# asm 2: movl <eax=%eax,>eax_stack=0(%esp)
movl %eax,0(%esp)

# qhasm: ebx_stack = ebx
# asm 1: movl <ebx=int32#4,>ebx_stack=stack32#2
# asm 2: movl <ebx=%ebx,>ebx_stack=4(%esp)
movl %ebx,4(%esp)

# qhasm: esi_stack = esi
# asm 1: movl <esi=int32#5,>esi_stack=stack32#3
# asm 2: movl <esi=%esi,>esi_stack=8(%esp)
movl %esi,8(%esp)

# qhasm: edi_stack = edi
# asm 1: movl <edi=int32#6,>edi_stack=stack32#4
# asm 2: movl <edi=%edi,>edi_stack=12(%esp)
movl %edi,12(%esp)

# qhasm: ebp_stack = ebp
# asm 1: movl <ebp=int32#7,>ebp_stack=stack32#5
# asm 2: movl <ebp=%ebp,>ebp_stack=16(%esp)
movl %ebp,16(%esp)

# qhasm: c = arg1
# asm 1: movl <arg1=stack32#-1,>c=int32#2
# asm 2: movl <arg1=4(%esp,%eax),>c=%ecx
movl 4(%esp,%eax),%ecx

# qhasm: k = arg2
# asm 1: movl <arg2=stack32#-2,>k=int32#1
# asm 2: movl <arg2=8(%esp,%eax),>k=%eax
movl 8(%esp,%eax),%eax

# qhasm: x0 = *(uint32 *) (k + 0)
# asm 1: movl 0(<k=int32#1),>x0=int32#3
# asm 2: movl 0(<k=%eax),>x0=%edx
movl 0(%eax),%edx

# qhasm: x1 = *(uint32 *) (k + 4)
# asm 1: movl 4(<k=int32#1),>x1=int32#4
# asm 2: movl 4(<k=%eax),>x1=%ebx
movl 4(%eax),%ebx

# qhasm: x2 = *(uint32 *) (k + 8)
# asm 1: movl 8(<k=int32#1),>x2=int32#5
# asm 2: movl 8(<k=%eax),>x2=%esi
movl 8(%eax),%esi

# qhasm: x3 = *(uint32 *) (k + 12)
# asm 1: movl 12(<k=int32#1),>x3=int32#1
# asm 2: movl 12(<k=%eax),>x3=%eax
movl 12(%eax),%eax

# qhasm: *(uint32 *) (c + 0) = x0
# asm 1: movl <x0=int32#3,0(<c=int32#2)
# asm 2: movl <x0=%edx,0(<c=%ecx)
movl %edx,0(%ecx)

# qhasm: *(uint32 *) (c + 4) = x1
# asm 1: movl <x1=int32#4,4(<c=int32#2)
# asm 2: movl <x1=%ebx,4(<c=%ecx)
movl %ebx,4(%ecx)

# qhasm: *(uint32 *) (c + 8) = x2
# asm 1: movl <x2=int32#5,8(<c=int32#2)
# asm 2: movl <x2=%esi,8(<c=%ecx)
movl %esi,8(%ecx)

# qhasm: *(uint32 *) (c + 12) = x3
# asm 1: movl <x3=int32#1,12(<c=int32#2)
# asm 2: movl <x3=%eax,12(<c=%ecx)
movl %eax,12(%ecx)

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x01
# asm 1: xor  $0x01,<e=int32#6
# asm 2: xor  $0x01,<e=%edi
xor  $0x01,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 16) = x0
# asm 1: movl <x0=int32#3,16(<c=int32#2)
# asm 2: movl <x0=%edx,16(<c=%ecx)
movl %edx,16(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x02
# asm 1: xor  $0x02,<e=int32#6
# asm 2: xor  $0x02,<e=%edi
xor  $0x02,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 20) = x0
# asm 1: movl <x0=int32#3,20(<c=int32#2)
# asm 2: movl <x0=%edx,20(<c=%ecx)
movl %edx,20(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x04
# asm 1: xor  $0x04,<e=int32#6
# asm 2: xor  $0x04,<e=%edi
xor  $0x04,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 24) = x0
# asm 1: movl <x0=int32#3,24(<c=int32#2)
# asm 2: movl <x0=%edx,24(<c=%ecx)
movl %edx,24(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x08
# asm 1: xor  $0x08,<e=int32#6
# asm 2: xor  $0x08,<e=%edi
xor  $0x08,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 28) = x0
# asm 1: movl <x0=int32#3,28(<c=int32#2)
# asm 2: movl <x0=%edx,28(<c=%ecx)
movl %edx,28(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x10
# asm 1: xor  $0x10,<e=int32#6
# asm 2: xor  $0x10,<e=%edi
xor  $0x10,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 32) = x0
# asm 1: movl <x0=int32#3,32(<c=int32#2)
# asm 2: movl <x0=%edx,32(<c=%ecx)
movl %edx,32(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x20
# asm 1: xor  $0x20,<e=int32#6
# asm 2: xor  $0x20,<e=%edi
xor  $0x20,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 36) = x0
# asm 1: movl <x0=int32#3,36(<c=int32#2)
# asm 2: movl <x0=%edx,36(<c=%ecx)
movl %edx,36(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x40
# asm 1: xor  $0x40,<e=int32#6
# asm 2: xor  $0x40,<e=%edi
xor  $0x40,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 40) = x0
# asm 1: movl <x0=int32#3,40(<c=int32#2)
# asm 2: movl <x0=%edx,40(<c=%ecx)
movl %edx,40(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x80
# asm 1: xor  $0x80,<e=int32#6
# asm 2: xor  $0x80,<e=%edi
xor  $0x80,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 44) = x0
# asm 1: movl <x0=int32#3,44(<c=int32#2)
# asm 2: movl <x0=%edx,44(<c=%ecx)
movl %edx,44(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#6
# asm 2: movzbl <x3=%ah,>e=%edi
movzbl %ah,%edi

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#6,8),>e=int32#6
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%edi,8),>e=%edi
movzbl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: e ^= 0x1b
# asm 1: xor  $0x1b,<e=int32#6
# asm 2: xor  $0x1b,<e=%edi
xor  $0x1b,%edi

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#7
# asm 2: movzbl <x3=%al,>q3=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#7,8),>q3=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<q3=%ebp,8),>q3=%ebp
movl aes128_x86mmx1_table1(,%ebp,8),%ebp

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#7
# asm 2: and  $0xff000000,<q3=%ebp
and  $0xff000000,%ebp

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#7,<e=int32#6
# asm 2: xorl <q3=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#7
# asm 2: movzbl <x3=%ah,>q2=%ebp
movzbl %ah,%ebp

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#7,8),>q2=int32#7
# asm 2: movl aes128_x86mmx1_table0(,<q2=%ebp,8),>q2=%ebp
movl aes128_x86mmx1_table0(,%ebp,8),%ebp

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#7
# asm 2: and  $0x00ff0000,<q2=%ebp
and  $0x00ff0000,%ebp

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#7,<e=int32#6
# asm 2: xorl <q2=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#7
# asm 2: movzbl <x3=%al,>q1=%ebp
movzbl %al,%ebp

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#7,8),>q1=int32#7
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%ebp,8),>q1=%ebp
movzwl aes128_x86mmx1_tablex(,%ebp,8),%ebp

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#7,<e=int32#6
# asm 2: xorl <q1=%ebp,<e=%edi
xorl %ebp,%edi

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#6,<x0=int32#3
# asm 2: xorl <e=%edi,<x0=%edx
xorl %edi,%edx

# qhasm: *(uint32 *) (c + 48) = x0
# asm 1: movl <x0=int32#3,48(<c=int32#2)
# asm 2: movl <x0=%edx,48(<c=%ecx)
movl %edx,48(%ecx)

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#1
# asm 2: xorl <x2=%esi,<x3=%eax
xorl %esi,%eax

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>e=int32#4
# asm 2: movzbl <x3=%ah,>e=%ebx
movzbl %ah,%ebx

# qhasm: e = *(uint8 *) (&aes128_x86mmx1_table2 + e * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<e=int32#4,8),>e=int32#4
# asm 2: movzbl aes128_x86mmx1_table2(,<e=%ebx,8),>e=%ebx
movzbl aes128_x86mmx1_table2(,%ebx,8),%ebx

# qhasm: e ^= 0x36
# asm 1: xor  $0x36,<e=int32#4
# asm 2: xor  $0x36,<e=%ebx
xor  $0x36,%ebx

# qhasm: q3 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q3=int32#5
# asm 2: movzbl <x3=%al,>q3=%esi
movzbl %al,%esi

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q3 = *(uint32 *) (&aes128_x86mmx1_table1 + q3 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<q3=int32#5,8),>q3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<q3=%esi,8),>q3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int32#5
# asm 2: and  $0xff000000,<q3=%esi
and  $0xff000000,%esi

# qhasm: e ^= q3
# asm 1: xorl <q3=int32#5,<e=int32#4
# asm 2: xorl <q3=%esi,<e=%ebx
xorl %esi,%ebx

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl <x3=int32#1%next8,>q2=int32#5
# asm 2: movzbl <x3=%ah,>q2=%esi
movzbl %ah,%esi

# qhasm: q2 = *(uint32 *) (&aes128_x86mmx1_table0 + q2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<q2=int32#5,8),>q2=int32#5
# asm 2: movl aes128_x86mmx1_table0(,<q2=%esi,8),>q2=%esi
movl aes128_x86mmx1_table0(,%esi,8),%esi

# qhasm: q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int32#5
# asm 2: and  $0x00ff0000,<q2=%esi
and  $0x00ff0000,%esi

# qhasm: e ^= q2
# asm 1: xorl <q2=int32#5,<e=int32#4
# asm 2: xorl <q2=%esi,<e=%ebx
xorl %esi,%ebx

# qhasm: q1 = x3 & 255
# asm 1: movzbl <x3=int32#1%8,>q1=int32#5
# asm 2: movzbl <x3=%al,>q1=%esi
movzbl %al,%esi

# qhasm: x3 <<<= 16
# asm 1: rol  $16,<x3=int32#1
# asm 2: rol  $16,<x3=%eax
rol  $16,%eax

# qhasm: q1 = *(uint16 *) (&aes128_x86mmx1_tablex + q1 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<q1=int32#5,8),>q1=int32#1
# asm 2: movzwl aes128_x86mmx1_tablex(,<q1=%esi,8),>q1=%eax
movzwl aes128_x86mmx1_tablex(,%esi,8),%eax

# qhasm: e ^= q1
# asm 1: xorl <q1=int32#1,<e=int32#4
# asm 2: xorl <q1=%eax,<e=%ebx
xorl %eax,%ebx

# qhasm: x0 ^= e
# asm 1: xorl <e=int32#4,<x0=int32#3
# asm 2: xorl <e=%ebx,<x0=%edx
xorl %ebx,%edx

# qhasm: *(uint32 *) (c + 52) = x0
# asm 1: movl <x0=int32#3,52(<c=int32#2)
# asm 2: movl <x0=%edx,52(<c=%ecx)
movl %edx,52(%ecx)

# qhasm: eax = eax_stack
# asm 1: movl <eax_stack=stack32#1,>eax=int32#1
# asm 2: movl <eax_stack=0(%esp),>eax=%eax
movl 0(%esp),%eax

# qhasm: ebx = ebx_stack
# asm 1: movl <ebx_stack=stack32#2,>ebx=int32#4
# asm 2: movl <ebx_stack=4(%esp),>ebx=%ebx
movl 4(%esp),%ebx

# qhasm: esi = esi_stack
# asm 1: movl <esi_stack=stack32#3,>esi=int32#5
# asm 2: movl <esi_stack=8(%esp),>esi=%esi
movl 8(%esp),%esi

# qhasm: edi = edi_stack
# asm 1: movl <edi_stack=stack32#4,>edi=int32#6
# asm 2: movl <edi_stack=12(%esp),>edi=%edi
movl 12(%esp),%edi

# qhasm: ebp = ebp_stack
# asm 1: movl <ebp_stack=stack32#5,>ebp=int32#7
# asm 2: movl <ebp_stack=16(%esp),>ebp=%ebp
movl 16(%esp),%ebp

# qhasm: leave
add %eax,%esp
ret
