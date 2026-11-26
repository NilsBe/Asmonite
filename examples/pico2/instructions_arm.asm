; Raspberry Pi Pico 2 (RP2350, Arm core Cortex-M33, Thumb-2): the important instructions, one after the other, each
; with what it does. The program needs no pin and shows nothing: it is made to be stepped through in the debugger,
; watching the registers and the flags change.
;
;   1. the Pico 2 with the console of Asmonite (Board Manager: Prepare Board) at its USB cable
;   2. press F7: the debugger goes over the debug monitor of the console, the program goes into the RAM at
;      0x20000000 and the debugger stops at _start
;   3. F7 goes one instruction on (into a subroutine too), F8 goes over a call (bl, blx); F5 on a line sets a
;      breakpoint, F9 runs to it. The register window shows r0 to r12, sp, lr, pc and the flags N Z C V.
;   4. at the end the program goes back to the console: "Program ended (code 120)", r0 is the result
;
; The registers: r0 to r12 for anything, sp (r13) the stack pointer, lr (r14) the return address of a call, pc (r15).
; A function gets its arguments in r0 to r3 and gives its result in r0; it keeps r4 to r11 as it found them (AAPCS).
; The flags N (negative), Z (zero), C (carry) and V (overflow) are set by cmp and by the instructions with "s" at the
; end (adds, subs, movs ...); the conditional branches look at them.
.target pico2
.arch thumb
.imagebase 0x20000000

_start:
  push  {r4-r7, lr}       ; r4 to r7 and the return address to the console onto the stack (sp goes down 20 bytes)

; ---- 1. Values into registers ----------------------------------------------------------------------------------
  movs  r0, #100          ; r0 = 100 (movs: 0 to 255, sets N and Z)
  mvn   r1, #4            ; r1 = NOT 4 = -5, in the register 0xFFFFFFFB
  movw  r2, #0x5678       ; r2 = 0x00005678: the lower 16 bits, the upper ones 0
  movt  r2, #0x1234       ; r2 = 0x12345678: the upper 16 bits, the lower ones stay
  mov   r3, r2            ; r3 = r2, a copy

; ---- 2. Arithmetic -----------------------------------------------------------------------------------------------
  adds  r3, r0, r1        ; r3 = 100 + (-5) = 95; the flags: C = 1 (an unsigned carry), N = 0, Z = 0
  adds  r3, #10           ; r3 = 95 + 10 = 105
  subs  r4, r0, r1        ; r4 = 100 - (-5) = 105
  add   r5, r4, r0, lsl #2 ; r5 = 105 + 100 * 4 = 505: the last operand is shifted first (the address of a word)
  rsbs  r6, r0, #0        ; r6 = 0 - 100 = -100 (reverse subtract: the negative); N = 1
  mul   r7, r0, r1        ; r7 = 100 * (-5) = -500, the low 32 bits of the product
  movs  r6, #7            ; r6 = 7
  udiv  r5, r0, r6        ; r5 = 100 / 7 = 14 (unsigned division)
  mls   r4, r5, r6, r0    ; r4 = r0 - r5 * r6 = 100 - 98 = 2: the remainder
  sdiv  r3, r7, r6        ; r3 = -500 / 7 = -71 (signed, towards 0)

; ---- 3. Bits -----------------------------------------------------------------------------------------------------
  movs  r0, #0xF0         ; r0 = 0xF0 = 1111 0000
  movs  r1, #0x3C         ; r1 = 0x3C = 0011 1100
  and   r2, r0, r1        ; r2 = 0x30: the bits set in both
  orr   r3, r0, r1        ; r3 = 0xFC: the bits set in one of them
  eor   r4, r0, r1        ; r4 = 0xCC: the bits set in only one
  bic   r5, r0, r1        ; r5 = 0xC0: the bits of r0 without those of r1 (r0 AND NOT r1)
  mvn   r6, r0            ; r6 = 0xFFFFFF0F: every bit turned over
  lsl   r7, r0, #4        ; r7 = 0xF00: shifted left by 4 (times 16)
  lsr   r2, r0, #4        ; r2 = 0x0F: shifted right by 4, zeros come in
  mvn   r3, #63           ; r3 = NOT 63 = -64 = 0xFFFFFFC0
  asr   r4, r3, #2        ; r4 = -16: shifted right, the sign bit comes in (divided by 4)
  ubfx  r5, r0, #4, #4    ; r5 = 0xF: 4 bits from bit 4 on, moved down to bit 0
  clz   r6, r0            ; r6 = 24: the zero bits above the highest one (0xF0 has its highest one at bit 7)

; ---- 4. Memory and stack -----------------------------------------------------------------------------------------
  adr   r0, table         ; r0 = the address of the table (at the end of the program)
  ldr   r1, [r0]          ; r1 = 10: the word at r0
  ldr   r2, [r0, #4]      ; r2 = 20: the word at r0 + 4
  adr   r3, buffer        ; r3 = the address of the buffer
  str   r2, [r3]          ; writes r2 (20) as a word to r3 (the memory window shows it at that address)
  movs  r4, #0x41         ; r4 = 0x41, the letter 'A'
  strb  r4, [r3, #4]      ; writes one byte to r3 + 4
  ldrb  r5, [r3, #4]      ; r5 = 0x41: one byte read, the upper 24 bits zero
  mvn   r4, #1            ; r4 = -2 = 0xFFFFFFFE
  strh  r4, [r3, #6]      ; writes the lower 16 bits (0xFFFE) to r3 + 6
  ldrh  r6, [r3, #6]      ; r6 = 0xFFFE = 65534: read without sign
  ldrsh r7, [r3, #6]      ; r7 = -2: read with sign (bit 15 fills the upper bits)
  push  {r1}              ; r1 (10) onto the stack: sp goes down 4 bytes, then the word is written there
  pop   {r2}              ; r2 = 10, read back from the stack; sp goes up again

; ---- 5. Flags and conditional branches ---------------------------------------------------------------------------
; cmp subtracts and keeps only the flags; a conditional branch then jumps when its condition holds, otherwise the
; next line runs. r7 counts the branches that were NOT taken: the "adds r7" behind such a branch runs, behind a
; taken one it is skipped. (adds changes the flags too: so cmp comes again where it is needed.)
  movs  r0, #5            ; r0 = 5
  movs  r1, #7            ; r1 = 7
  movs  r7, #0            ; r7 = 0, the counter
  cmp   r0, r1            ; 5 - 7 = -2: N = 1, Z = 0, C = 0 (a borrow), V = 0
  beq   b1                ; equal (Z = 1)? no: not taken
  adds  r7, #1            ;   runs (r7 = 1)
b1:
  cmp   r0, r1            ; the flags again
  bne   b2                ; not equal (Z = 0)? yes: jumps to b2
  adds  r7, #1            ;   skipped
b2:
  blt   b3                ; less, signed (N <> V)? 5 < 7 yes: jumps
  adds  r7, #1            ;   skipped
b3:
  bge   b4                ; greater or equal, signed (N = V)? no: not taken
  adds  r7, #1            ;   runs (r7 = 2)
b4:
  mvn   r2, #0            ; r2 = -1 = 0xFFFFFFFF
  cmp   r0, r2            ; 5 - 0xFFFFFFFF
  blo   b5                ; lower, unsigned (C = 0)? 5 < 0xFFFFFFFF yes: jumps (signed it would be no)
  adds  r7, #1            ;   skipped
b5:
  cbz   r0, b6            ; r0 = 0? no: not taken (cbz needs no flags, it only jumps forward)
  adds  r7, #1            ;   runs (r7 = 3)
b6:
  cbnz  r0, b7            ; r0 <> 0? yes: jumps
  adds  r7, #1            ;   skipped
b7:
  cmp   r2, #0            ; -1 - 0: N = 1
  bmi   b8                ; minus (N = 1)? yes: jumps
  adds  r7, #1            ;   skipped
b8:
  tst   r0, #4            ; r0 AND 4 = 4, kept only in the flags: Z = 0, so bit 2 is set
  bne   b9                ; Z = 0? yes: jumps
  adds  r7, #1            ;   skipped
b9:
  tst   r0, #2            ; r0 AND 2 = 0: Z = 1, bit 1 is clear
  beq   b10               ; Z = 1? yes: jumps
  adds  r7, #1            ;   skipped
b10:
  cmp   r0, #6            ; 5 - 6
  bge   b11               ; 5 >= 6? no: not taken
  adds  r7, #1            ;   runs (r7 = 4)
b11:
  b     b12               ; jumps always
  adds  r7, #1            ;   never runs
b12:                      ; here r7 = 4

; ---- 6. Conditional instructions (IT) ----------------------------------------------------------------------------
; it makes the next instruction conditional, ite the next two (the first if, the second else); no jump.
  movs  r0, #0            ; r0 = 0 (Z = 1)
  movs  r1, #111          ; r1 = 111
  movs  r2, #222          ; r2 = 222
  cmp   r0, #0            ; 0 - 0: Z = 1
  it    eq                ; the next instruction only if equal
  moveq r1, r2            ; equal: r1 = 222
  ite   ne                ; the next one if not equal, the one after it if equal
  movne r3, #1            ;   skipped (it is equal); the debugger steps over it
  moveq r3, #2            ;   r3 = 2

; ---- 7. A loop -------------------------------------------------------------------------------------------------
; a counter and a conditional branch back: r0 = 1 + 2 + ... + 10
  movs  r0, #0            ; r0 = 0, the sum
  movs  r1, #10           ; r1 = 10, the counter
sum_loop:
  adds  r0, r0, r1        ; add the counter to the sum
  subs  r1, #1            ; the counter one less; Z = 1 when it is 0
  bne   sum_loop          ; not 0 yet: once more. At the end r0 = 55

; ---- 8. Subroutines ----------------------------------------------------------------------------------------------
; bl puts the return address into lr and jumps; the subroutine ends with bx lr. The argument goes in r0, the result
; comes back in r0.
  movs  r0, #21           ; the argument: 21
  bl    double            ; lr = the address of the next line, then on at double (F7 goes in, F8 over it)
  mov   r4, r0            ; r4 = 42
  movs  r0, #6            ; the argument: 6
  bl    square            ; r0 = 6 * 6 = 36 afterwards
  mov   r5, r0            ; r5 = 36
; blx: the same with the address in a register. Bit 0 of it must be 1: that says Thumb (the only state of the M33).
  adr   r3, square        ; r3 = the address of square
  adds  r3, #1            ; bit 0 set: a Thumb address
  movs  r0, #9            ; the argument: 9
  blx   r3                ; r0 = 81 afterwards
  mov   r6, r0            ; r6 = 81

; ---- 9. A subroutine that calls itself: the factorial 5! = 1 * 2 * 3 * 4 * 5 -------------------------------------
  movs  r0, #5            ; the argument: 5
  bl    fact              ; r0 = 120 afterwards. F7 into it: each call puts lr and r4 on the stack
  pop   {r4-r7, pc}       ; r4 to r7 back, and the saved return address into pc: back to the console, r0 = 120

; double: r0 = r0 + r0. Calls nothing, so lr stays as it is.
double:
  adds  r0, r0, r0        ; r0 = 2 * r0
  bx    lr                ; back to the address in lr

; square: r0 = r0 * r0
align 4                   ; adr above needs the address on a multiple of 4
square:
  muls  r0, r0, r0        ; r0 = r0 * r0
  bx    lr                ; back

; fact: r0 = r0! (the factorial), recursive: n! = n * (n-1)!, and 1! = 1. It calls itself, and bl overwrites lr:
; so lr goes onto the stack first, with r4, which keeps n.
fact:
  push  {r4, lr}          ; r4 and the return address onto the stack (each call a new pair: the stack window shows them)
  mov   r4, r0            ; r4 = n
  cmp   r0, #2            ; n - 2
  blt   fact_one          ; n < 2? then the result is 1
  subs  r0, #1            ; the argument for the next call: n - 1
  bl    fact              ; r0 = (n-1)!
  muls  r0, r4, r0        ; r0 = n * (n-1)!
  pop   {r4, pc}          ; r4 back, and the return address into pc: back
fact_one:
  movs  r0, #1            ; 1! = 1 (and 0! = 1)
  pop   {r4, pc}

; The data: in the RAM like the program, so it can be written too.
align 4
table:  dd 10, 20, 30, 40  ; four words
buffer: dd 0, 0, 0, 0      ; 16 bytes of room
