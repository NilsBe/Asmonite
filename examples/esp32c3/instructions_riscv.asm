; ESP32-C3 (RISC-V, RV32IMC): the important instructions, one after the other, each with what it does. The program
; needs no pin and shows nothing: it is made to be stepped through in the debugger, watching the registers change.
; It runs on every C3 board.
;
;   1. plug the board in at the USB port of the C3 (USB JTAG, 303A:1001; once for each board: Debug > Debug
;      targets > ESP32-C3 > "Set up the USB JTAG")
;   2. press F7: the debugger resets the chip and halts it, the program goes into the RAM at 0x40380000 and the
;      debugger stops at _start
;   3. F7 goes one instruction on (into a subroutine too), F8 goes over a call; F5 on a line sets a breakpoint, F9
;      runs to it. The register window shows x0 to x31 (with their names: ra, sp, t0, a0 ...) and pc.
;   4. at the end the program waits in a loop at done: Debug > Pause stops it there (a0 = 120, the result),
;      Ctrl+F2 ends the session. The flash is not touched: after a reset the program of the board runs again.
;
; The registers: x0 (zero) is always 0; ra holds the return address of a call, sp is the stack pointer; a0 to a7 are
; the arguments and a0 the result of a function, t0 to t6 for anything, s0 to s11 a function keeps as it found them.
; RISC-V has no flags: a branch compares two registers itself.
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
  li    sp, 0x3FCC0000    ; the stack pointer: the end of the free RAM, by the address of the data bus (the RAM of
                          ; 0x40380000 to 0x403BFFFF is 0x3FC80000 to 0x3FCBFFFF there); the stack grows down

; ---- 1. Values into registers ----------------------------------------------------------------------------------
  li    a0, 100           ; a0 = 100 (li: written as addi a0, zero, 100)
  li    a1, -5            ; a1 = -5, in the register 0xFFFFFFFB
  li    a2, 0x12345678    ; a2 = 0x12345678: too large for one instruction, li makes lui + addi of it
  mv    a3, a2            ; a3 = a2, a copy (written as addi a3, a2, 0)
  lui   a4, 0x12345       ; a4 = 0x12345000: the upper 20 bits, the lower 12 zero
  auipc a5, 0             ; a5 = the address of this instruction (pc + 0)

; ---- 2. Arithmetic -----------------------------------------------------------------------------------------------
  add   t0, a0, a1        ; t0 = 100 + (-5) = 95
  addi  t0, t0, 10        ; t0 = 95 + 10 = 105 (addi takes -2048 to 2047)
  sub   t1, a0, a1        ; t1 = 100 - (-5) = 105
  slli  t2, a0, 2         ; t2 = 100 * 4 = 400 (shifted left by 2)
  add   t2, t2, t1        ; t2 = 400 + 105 = 505 (index * 4 + base: the address of a word in a table)
  neg   t3, a0            ; t3 = -100 (written as sub t3, zero, a0)
  mul   t4, a0, a1        ; t4 = 100 * (-5) = -500, the low 32 bits of the product
  li    t5, 7             ; t5 = 7
  divu  t6, a0, t5        ; t6 = 100 / 7 = 14 (unsigned division)
  remu  a6, a0, t5        ; a6 = 100 mod 7 = 2, the remainder
  div   a7, t4, t5        ; a7 = -500 / 7 = -71 (signed, towards 0)
  rem   s0, t4, t5        ; s0 = -3: the remainder of it, with the sign of -500 (-71 * 7 - 3 = -500)

; ---- 3. Bits and comparisons -------------------------------------------------------------------------------------
  li    a0, 0xF0          ; a0 = 0xF0 = 1111 0000
  li    a1, 0x3C          ; a1 = 0x3C = 0011 1100
  and   a2, a0, a1        ; a2 = 0x30: the bits set in both
  or    a3, a0, a1        ; a3 = 0xFC: the bits set in one of them
  xor   a4, a0, a1        ; a4 = 0xCC: the bits set in only one
  andi  a5, a0, 0x1F      ; a5 = 0x10: and with a constant (the lower 5 bits of 0xF0)
  not   a6, a0            ; a6 = 0xFFFFFF0F: every bit turned over (written as xori a6, a0, -1)
  slli  a7, a0, 4         ; a7 = 0xF00: shifted left by 4 (times 16)
  srli  t0, a0, 4         ; t0 = 0x0F: shifted right by 4, zeros come in
  li    t1, -64           ; t1 = -64 = 0xFFFFFFC0
  srai  t2, t1, 2         ; t2 = -16: shifted right, the sign bit comes in (divided by 4)
  srli  t3, t1, 28        ; t3 = 0xF: the top 4 bits, zeros came in
  li    t4, 3             ; t4 = 3
  sll   t5, a0, t4        ; t5 = 0xF0 << 3 = 0x780: shifted by the number in a register
  slt   t6, t1, a0        ; t6 = 1: -64 < 240 signed? yes (1, else 0)
  sltu  s1, t1, a0        ; s1 = 0: 0xFFFFFFC0 < 240 unsigned? no
  seqz  s2, a0            ; s2 = 0: a0 = 0? no (written as sltiu s2, a0, 1)

; ---- 4. Memory and stack -----------------------------------------------------------------------------------------
  addi  sp, sp, -16       ; 16 bytes on the stack: sp goes down (the memory window shows them at sp)
  li    a0, 10            ; a0 = 10
  sw    a0, 0(sp)         ; writes a0 as a word to sp + 0
  lw    a1, 0(sp)         ; a1 = 10: the word at sp + 0
  li    a2, 0x41          ; a2 = 0x41, the letter 'A'
  sb    a2, 4(sp)         ; writes one byte to sp + 4
  lbu   a3, 4(sp)         ; a3 = 0x41: one byte read, the upper 24 bits zero
  li    a4, -2            ; a4 = -2 = 0xFFFFFFFE
  sh    a4, 6(sp)         ; writes the lower 16 bits (0xFFFE) to sp + 6
  lhu   a5, 6(sp)         ; a5 = 0xFFFE = 65534: read without sign
  lh    a6, 6(sp)         ; a6 = -2: read with sign (bit 15 fills the upper bits)
  lb    a7, 6(sp)         ; a7 = -2: the byte 0xFE with sign
  addi  sp, sp, 16        ; the 16 bytes given back: sp as before

; ---- 5. Conditional branches -------------------------------------------------------------------------------------
; A branch compares two registers and jumps when the condition holds; otherwise the next line runs. s3 counts the
; branches that were NOT taken: the "addi s3" behind such a branch runs, behind a taken one it is skipped.
  li    a0, 5             ; a0 = 5
  li    a1, 7             ; a1 = 7
  li    s3, 0             ; s3 = 0, the counter
  beq   a0, a1, b1        ; a0 = a1? 5 = 7 no: not taken
  addi  s3, s3, 1         ;   runs (s3 = 1)
b1:
  bne   a0, a1, b2        ; a0 <> a1? yes: jumps to b2
  addi  s3, s3, 1         ;   skipped
b2:
  blt   a0, a1, b3        ; a0 < a1, signed? 5 < 7 yes: jumps
  addi  s3, s3, 1         ;   skipped
b3:
  bge   a0, a1, b4        ; a0 >= a1, signed? no: not taken
  addi  s3, s3, 1         ;   runs (s3 = 2)
b4:
  li    a2, -1            ; a2 = -1 = 0xFFFFFFFF
  bltu  a0, a2, b5        ; a0 < a2 unsigned? 5 < 0xFFFFFFFF yes: jumps (signed it would be no)
  addi  s3, s3, 1         ;   skipped
b5:
  beqz  a0, b6            ; a0 = 0? no: not taken (written as beq a0, zero, b6)
  addi  s3, s3, 1         ;   runs (s3 = 3)
b6:
  bnez  a0, b7            ; a0 <> 0? yes: jumps
  addi  s3, s3, 1         ;   skipped
b7:
  bltz  a2, b8            ; a2 < 0? -1 yes: jumps
  addi  s3, s3, 1         ;   skipped
b8:
  bgt   a0, a1, b9        ; a0 > a1? no: not taken (written as blt a1, a0, b9)
  addi  s3, s3, 1         ;   runs (s3 = 4)
b9:
  andi  t0, a0, 4         ; t0 = a0 AND 4 = 4: bit 2 of a0
  bnez  t0, b10           ; bit 2 set? yes: jumps
  addi  s3, s3, 1         ;   skipped
b10:
  j     b11               ; jumps always (written as jal zero, b11)
  addi  s3, s3, 1         ;   never runs
b11:                      ; here s3 = 4

; ---- 6. A loop -------------------------------------------------------------------------------------------------
; a counter and a conditional branch back: a0 = 1 + 2 + ... + 10
  li    a0, 0             ; a0 = 0, the sum
  li    t0, 10            ; t0 = 10, the counter
sum_loop:
  add   a0, a0, t0        ; add the counter to the sum
  addi  t0, t0, -1        ; the counter one less
  bnez  t0, sum_loop      ; not 0 yet: once more. At the end a0 = 55

; ---- 7. Subroutines ----------------------------------------------------------------------------------------------
; call puts the return address into ra and jumps; the subroutine ends with ret (jalr zero, ra, 0). The argument
; goes in a0, the result comes back in a0. call is two instructions, auipc ra + jalr ra (it reaches any address):
; F7 shows the auipc first, then the jump. jal ra reaches 1 MB in one instruction.
  li    a0, 21            ; the argument: 21
  call  double            ; ra = the address of the next line, then on at double (F7 goes in, F8 over it)
  mv    s4, a0            ; s4 = 42
  li    a0, 6             ; the argument: 6
  jal   ra, square        ; the same in one instruction: a0 = 6 * 6 = 36 afterwards
  mv    s5, a0            ; s5 = 36
; jalr: the same with the address in a register
  la    t1, square        ; t1 = the address of square (written as auipc + addi)
  li    a0, 9             ; the argument: 9
  jalr  ra, 0(t1)         ; ra = the address of the next line, then on at t1: a0 = 81 afterwards
  mv    s6, a0            ; s6 = 81

; ---- 8. A subroutine that calls itself: the factorial 5! = 1 * 2 * 3 * 4 * 5 -------------------------------------
  li    a0, 5             ; the argument: 5
  call  fact              ; a0 = 120 afterwards. F7 into it: each call puts ra and s0 on the stack
done:
  j     done              ; wait here: Debug > Pause shows a0 = 120

; double: a0 = a0 + a0. Calls nothing, so ra stays as it is.
double:
  add   a0, a0, a0        ; a0 = 2 * a0
  ret                     ; back to the address in ra

; square: a0 = a0 * a0
square:
  mul   a0, a0, a0        ; a0 = a0 * a0
  ret                     ; back

; fact: a0 = a0! (the factorial), recursive: n! = n * (n-1)!, and 1! = 1. It calls itself, and call overwrites ra:
; so ra goes onto the stack first, with s0, which keeps n.
fact:
  addi  sp, sp, -16       ; room on the stack for this call (16 bytes: sp stays a multiple of 16)
  sw    ra, 12(sp)        ; the return address onto the stack
  sw    s0, 8(sp)         ; s0 of the caller onto the stack
  mv    s0, a0            ; s0 = n
  li    t0, 2             ; t0 = 2
  blt   a0, t0, fact_one  ; n < 2? then the result is 1
  addi  a0, a0, -1        ; the argument for the next call: n - 1
  call  fact              ; a0 = (n-1)!
  mul   a0, s0, a0        ; a0 = n * (n-1)!
  j     fact_end
fact_one:
  li    a0, 1             ; 1! = 1 (and 0! = 1)
fact_end:
  lw    s0, 8(sp)         ; s0 of the caller back
  lw    ra, 12(sp)        ; the return address back
  addi  sp, sp, 16        ; the room given back
  ret                     ; back with a0
