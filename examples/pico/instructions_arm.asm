; Raspberry Pi Pico and Pico W (RP2040, Arm core Cortex-M0+, Thumb-1): the important instructions, one after the
; other, each with what it does. The program needs no pin and shows nothing: it is made to be stepped through in the
; debugger, watching the registers and the flags change.
;
;   1. the Pico with the console of Asmonite (Board Manager: Prepare Board) at its USB cable
;   2. press F7: the debugger goes over the debug monitor of the console, the program goes into the RAM at
;      0x20000000 and the debugger stops at _start
;   3. F7 goes one instruction on (into a subroutine too), F8 goes over a call (bl, blx); F5 on a line sets a
;      breakpoint, F9 runs to it. The register window shows r0 to r12, sp, lr, pc and the flags N Z C V.
;   4. at the end the program goes back to the console: "Program ended (code 120)", r0 is the result
;
; The Cortex-M0+ knows Thumb-1: almost only instructions of 16 bits. Most of them work on r0 to r7 only and set the
; flags always (adds, ands, movs ...); r8 to r12 are reached with mov, add and cmp. There is no division, no IT and
; no cbz: examples/pico2/instructions_arm.asm is the same program for the Cortex-M33 of the Pico 2, with them.
;
; The registers: r0 to r12 for anything, sp (r13) the stack pointer, lr (r14) the return address of a call, pc (r15).
; A function gets its arguments in r0 to r3 and gives its result in r0; it keeps r4 to r11 as it found them (AAPCS).
; The flags N (negative), Z (zero), C (carry) and V (overflow) are set by cmp and by the instructions with "s" at the
; end; the conditional branches look at them.
.target pico
.arch thumb
.imagebase 0x20000000

_start:
  push  {r4-r7, lr}       ; r4 to r7 and the return address to the console onto the stack (sp goes down 20 bytes)

; ---- 1. Values into registers ----------------------------------------------------------------------------------
  movs  r0, #100          ; r0 = 100 (movs: 0 to 255 only, sets N and Z)
  movs  r1, #5            ; r1 = 5
  rsbs  r1, r1, #0        ; r1 = 0 - 5 = -5, in the register 0xFFFFFFFB (reverse subtract: the negative)
  ldr   r2, lit_big       ; r2 = 0x12345678: a larger number comes from a word behind the code (lit_big)
  mov   r3, r2            ; r3 = r2, a copy (mov: any register, no flags)
  mov   r8, r2            ; r8 = r2: the upper registers r8 to r12 are reached with mov

; ---- 2. Arithmetic -----------------------------------------------------------------------------------------------
  adds  r3, r0, r1        ; r3 = 100 + (-5) = 95; the flags: C = 1 (an unsigned carry), N = 0, Z = 0
  adds  r3, #10           ; r3 = 95 + 10 = 105 (a constant 0 to 255, the register is the target too)
  subs  r4, r0, r1        ; r4 = 100 - (-5) = 105
  lsls  r5, r0, #2        ; r5 = 100 * 4 = 400 (shifted left by 2)
  adds  r5, r5, r4        ; r5 = 400 + 105 = 505 (index * 4 + base: the address of a word in a table)
  rsbs  r6, r0, #0        ; r6 = 0 - 100 = -100; N = 1
  mov   r7, r0            ; r7 = 100
  muls  r7, r1, r7        ; r7 = (-5) * 100 = -500 (muls: the target is one of the two factors)
                          ; a division the M0+ does not have: the subroutine udiv in part 8

; ---- 3. Bits -----------------------------------------------------------------------------------------------------
; and, or, eor and bic take two registers: the first is the target too, so a copy comes first.
  movs  r0, #0xF0         ; r0 = 0xF0 = 1111 0000
  movs  r1, #0x3C         ; r1 = 0x3C = 0011 1100
  mov   r2, r0            ; r2 = 0xF0
  ands  r2, r1            ; r2 = 0x30: the bits set in both
  mov   r3, r0
  orrs  r3, r1            ; r3 = 0xFC: the bits set in one of them
  mov   r4, r0
  eors  r4, r1            ; r4 = 0xCC: the bits set in only one
  mov   r5, r0
  bics  r5, r1            ; r5 = 0xC0: the bits of r0 without those of r1 (r0 AND NOT r1)
  mvns  r6, r0            ; r6 = 0xFFFFFF0F: every bit turned over
  lsls  r7, r0, #4        ; r7 = 0xF00: shifted left by 4 (times 16)
  lsrs  r2, r0, #4        ; r2 = 0x0F: shifted right by 4, zeros come in
  movs  r3, #63           ; r3 = 63
  mvns  r3, r3            ; r3 = NOT 63 = -64 = 0xFFFFFFC0
  asrs  r4, r3, #2        ; r4 = -16: shifted right, the sign bit comes in (divided by 4)
  lsrs  r5, r0, #4        ; r5 = 0x0F ...
  movs  r6, #0x0F         ; r6 = 0x0F
  ands  r5, r6            ; ... and with 0x0F: r5 = 0xF, the 4 bits from bit 4 on (bits 7 to 4)
  movs  r6, #3            ; r6 = 3
  mov   r7, r0            ; r7 = 0xF0
  lsls  r7, r6            ; r7 = 0xF0 << 3 = 0x780: shifted by the number in a register
  movs  r6, #0x80         ; r6 = 0x80 = 128
  sxtb  r7, r6            ; r7 = -128: the lowest byte with its sign (bit 7) widened to 32 bits
  uxtb  r7, r3            ; r7 = 0xC0: the lowest byte of r3 (0xFFFFFFC0), the rest zero

; ---- 4. Memory and stack -----------------------------------------------------------------------------------------
  adr   r0, table         ; r0 = the address of the table (at the end of the program)
  ldr   r1, [r0]          ; r1 = 10: the word at r0
  ldr   r2, [r0, #4]      ; r2 = 20: the word at r0 + 4
  adr   r3, buffer        ; r3 = the address of the buffer
  str   r2, [r3]          ; writes r2 (20) as a word to r3 (the memory window shows it at that address)
  movs  r4, #0x41         ; r4 = 0x41, the letter 'A'
  strb  r4, [r3, #4]      ; writes one byte to r3 + 4
  ldrb  r5, [r3, #4]      ; r5 = 0x41: one byte read, the upper 24 bits zero
  movs  r4, #2
  rsbs  r4, r4, #0        ; r4 = -2 = 0xFFFFFFFE
  strh  r4, [r3, #6]      ; writes the lower 16 bits (0xFFFE) to r3 + 6
  ldrh  r6, [r3, #6]      ; r6 = 0xFFFE = 65534: read without sign
  movs  r7, #6            ; r7 = 6
  ldrsh r7, [r3, r7]      ; r7 = -2: read with sign (bit 15 fills the upper bits); ldrsh takes a register as offset
  ldm   r0!, {r4, r5}     ; r4 = 10, r5 = 20: two words at once from r0, and r0 goes on by 8 ("!")
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
  movs  r2, #0
  mvns  r2, r2            ; r2 = -1 = 0xFFFFFFFF
  cmp   r0, r2            ; 5 - 0xFFFFFFFF
  blo   b5                ; lower, unsigned (C = 0)? 5 < 0xFFFFFFFF yes: jumps (signed it would be no)
  adds  r7, #1            ;   skipped
b5:
  cmp   r0, #0            ; 5 - 0
  beq   b6                ; r0 = 0? no: not taken
  adds  r7, #1            ;   runs (r7 = 3)
b6:
  cmp   r0, #0
  bne   b7                ; r0 <> 0? yes: jumps
  adds  r7, #1            ;   skipped
b7:
  cmp   r2, #0            ; -1 - 0: N = 1
  bmi   b8                ; minus (N = 1)? yes: jumps
  adds  r7, #1            ;   skipped
b8:
  movs  r6, #4            ; r6 = 4 = bit 2
  tst   r0, r6            ; r0 AND 4 = 4, kept only in the flags: Z = 0, so bit 2 is set
  bne   b9                ; Z = 0? yes: jumps
  adds  r7, #1            ;   skipped
b9:
  movs  r6, #2            ; r6 = 2 = bit 1
  tst   r0, r6            ; r0 AND 2 = 0: Z = 1, bit 1 is clear
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

; ---- 6. Doing something only if: a short jump around it ----------------------------------------------------------
; The M0+ has no IT block: a branch jumps over the instruction that is to run only under a condition.
  movs  r0, #0            ; r0 = 0
  movs  r1, #111          ; r1 = 111
  movs  r2, #222          ; r2 = 222
  cmp   r0, #0            ; 0 - 0: Z = 1
  bne   if_end            ; not equal? then jump over the next line (here it is equal: no jump)
  mov   r1, r2            ; only if equal: r1 = 222
if_end:

; ---- 7. A loop -------------------------------------------------------------------------------------------------
; a counter and a conditional branch back: r0 = 1 + 2 + ... + 10
  movs  r0, #0            ; r0 = 0, the sum
  movs  r1, #10           ; r1 = 10, the counter
sum_loop:
  adds  r0, r0, r1        ; add the counter to the sum
  subs  r1, #1            ; the counter one less; Z = 1 when it is 0
  bne   sum_loop          ; not 0 yet: once more. At the end r0 = 55

; ---- 8. Subroutines ----------------------------------------------------------------------------------------------
; bl puts the return address into lr and jumps; the subroutine ends with bx lr. The arguments go in r0 and r1, the
; result comes back in r0 (and r1).
  movs  r0, #21           ; the argument: 21
  bl    double            ; lr = the address of the next line, then on at double (F7 goes in, F8 over it)
  mov   r4, r0            ; r4 = 42
  movs  r0, #6            ; the argument: 6
  bl    square            ; r0 = 6 * 6 = 36 afterwards
  mov   r5, r0            ; r5 = 36
; blx: the same with the address in a register. Bit 0 of it must be 1: that says Thumb (the only state of the M0+).
  adr   r3, square        ; r3 = the address of square
  adds  r3, #1            ; bit 0 set: a Thumb address
  movs  r0, #9            ; the argument: 9
  blx   r3                ; r0 = 81 afterwards
  mov   r6, r0            ; r6 = 81
; the division as a subroutine with two results
  movs  r0, #100          ; the number: 100
  movs  r1, #7            ; divided by 7
  bl    udiv              ; r0 = 14, r1 = 2 afterwards (F8: its 32 rounds at once)

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

; udiv: r0 / r1 without sign: r0 = the quotient, r1 = the remainder. Bit by bit as on paper: each bit of r0 from the
; top into the remainder; when the remainder reaches r1, r1 less and a 1 into the quotient.
udiv:
  push  {r4, lr}          ; r4 is used here: keep it for the caller
  movs  r2, #0            ; r2 = 0, the remainder
  movs  r3, #0            ; r3 = 0, the quotient
  movs  r4, #32           ; r4 = 32, the bits
udiv_bit:
  lsls  r0, r0, #1        ; the top bit of r0 into the carry C ...
  adcs  r2, r2            ; ... and into the remainder: r2 = r2 + r2 + C
  lsls  r3, r3, #1        ; the quotient times 2
  cmp   r2, r1            ; the remainder - the divisor
  blo   udiv_next         ; smaller? then a 0 in the quotient
  subs  r2, r2, r1        ; else the divisor off the remainder ...
  adds  r3, #1            ; ... and a 1 into the quotient
udiv_next:
  subs  r4, #1            ; one bit less
  bne   udiv_bit          ; not all 32 yet: the next one
  mov   r0, r3            ; r0 = the quotient
  mov   r1, r2            ; r1 = the remainder
  pop   {r4, pc}          ; r4 back, and back to the caller

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

; The data: in the RAM like the program, so it can be written too. ldr r2, lit_big and adr read them pc relative:
; they must stand behind the instruction, on a multiple of 4.
align 4
lit_big: dd 0x12345678     ; the larger number of part 1
table:   dd 10, 20, 30, 40 ; four words
buffer:  dd 0, 0, 0, 0     ; 16 bytes of room
