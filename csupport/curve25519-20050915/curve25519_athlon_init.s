.text
.p2align 5
.globl _curve25519_athlon_init
.globl curve25519_athlon_init
_curve25519_athlon_init:
curve25519_athlon_init:
mov %esp,%eax
and $31,%eax
add $0,%eax
sub %eax,%esp
fldcw curve25519_athlon_rounding
add %eax,%esp
ret
