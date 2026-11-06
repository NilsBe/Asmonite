; MangoPi MQ-Pro (Allwinner D1, RV64): the 90th Fibonacci number, 2880067194370816120, returned in a0.
; It needs 62 bits: on a 32-bit core it would take two registers per number, here one is enough.
; F9 runs it (see sum_ram.asm); the output window shows a0 and a1 (the 89th number).
.target d1
.arch riscv64
.imagebase 0x20000

_start:
  li   a1, 0              ; F(0)
  li   a0, 1              ; F(1)
  li   t0, 89             ; 89 more steps give F(90)
next:
  add  t1, a0, a1         ; F(n+1) = F(n) + F(n-1), all 64 bits
  mv   a1, a0
  mv   a0, t1
  addi t0, t0, -1
  bnez t0, next
  ret
