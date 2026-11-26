; ESP32 (Xtensa LX6): the important instructions, one after the other, each with what it does. The program needs no
; pin and shows nothing: it is made to be stepped through in the debugger, watching the registers change.
;
;   1. plug in the board (with the console of Asmonite on it, or without: then the boot ROM loads the program)
;   2. press F7: the program goes into the RAM at 0x40080000 and the debugger stops at _start
;   3. F7 goes one instruction on (into a subroutine too), F8 goes over a call; F5 on a line sets a breakpoint, F9
;      runs to it. The register window shows a0 to a15, pc, sar and the loop registers lbeg, lend and lcount.
;   4. at the end retw goes back to the console: the output window shows a2, the result (120)
;
; The registers: a0 to a15 are the 16 registers a program sees. a0 holds the return address of a call, a1 is the
; stack pointer (sp). With call8 the registers form a window: the subroutine sees the a8 to a15 of its caller as its
; own a0 to a7, so the arguments go in a10, a11 ... and the result comes back in a10 (see part 8).
.target esp32
.arch xtensa
.imagebase 0x40080000

; Literals: values for l32r. l32r loads a word from an address below the instruction, so they come first.
lit_big:    dd 0x12345678          ; a number too large for movi
lit_table:  dd table               ; the address of the table in the DRAM (.data, at the end)
lit_buffer: dd buffer              ; the address of a buffer in the DRAM
lit_square: dd square              ; the address of a subroutine, for callx8

_start:
  entry a1, 48            ; a new register window for this function, 48 bytes of stack for it (a1 goes down)

; ---- 1. Values into registers ----------------------------------------------------------------------------------
  movi  a2, 100           ; a2 = 100 (movi takes -2048 to 2047)
  movi  a3, -5            ; a3 = -5, in the register 0xFFFFFFFB
  l32r  a4, lit_big       ; a4 = 0x12345678, loaded from lit_big
  mov   a5, a4            ; a5 = a4, a copy
  rsr   a6, ccount        ; a6 = the cycle counter CCOUNT (a special register; it counts every clock)

; ---- 2. Arithmetic -----------------------------------------------------------------------------------------------
  add   a7, a2, a3        ; a7 = 100 + (-5) = 95
  addi  a7, a7, 10        ; a7 = 95 + 10 = 105 (addi takes -128 to 127)
  sub   a8, a2, a3        ; a8 = 100 - (-5) = 105
  addx4 a9, a2, a8        ; a9 = 100 * 4 + 105 = 505 (index * 4 + base: the address of a word in a table)
  neg   a10, a2           ; a10 = -100
  abs   a11, a10          ; a11 = 100, the amount
  mull  a12, a2, a3       ; a12 = 100 * (-5) = -500, the low 32 bits of the product
  movi  a13, 7            ; a13 = 7
  quou  a14, a2, a13      ; a14 = 100 / 7 = 14 (unsigned division)
  remu  a15, a2, a13      ; a15 = 100 mod 7 = 2, the remainder
  min   a7, a2, a3        ; a7 = -5: the smaller one, signed
  maxu  a8, a2, a3        ; a8 = 0xFFFFFFFB: the larger one unsigned (-5 is a very large number without sign)

; ---- 3. Bits -----------------------------------------------------------------------------------------------------
  movi  a2, 0xF0          ; a2 = 0xF0 = 1111 0000
  movi  a3, 0x3C          ; a3 = 0x3C = 0011 1100
  and   a4, a2, a3        ; a4 = 0x30: the bits set in both
  or    a5, a2, a3        ; a5 = 0xFC: the bits set in one of them
  xor   a6, a2, a3        ; a6 = 0xCC: the bits set in only one
  slli  a7, a2, 4         ; a7 = 0xF00: shifted left by 4 (times 16)
  srli  a8, a2, 4         ; a8 = 0x0F: shifted right by 4, zeros come in (srli: 0 to 15)
  movi  a9, -64           ; a9 = -64 = 0xFFFFFFC0
  srai  a10, a9, 2        ; a10 = -16: shifted right, the sign bit comes in (divided by 4)
  extui a11, a2, 4, 4     ; a11 = 0xF: 4 bits from bit 4 on, moved down to bit 0
  movi  a12, 3            ; a12 = 3
  ssl   a12               ; the shift register SAR for a shift left by 3 (sar shows 32 - 3 = 29)
  sll   a13, a2           ; a13 = 0xF0 << 3 = 0x780: shifted by the amount in SAR
  nsau  a14, a2           ; a14 = 24: the zero bits above the highest one (0xF0 has its highest one at bit 7)

; ---- 4. Memory and stack -----------------------------------------------------------------------------------------
  l32r  a2, lit_table     ; a2 = the address of the table
  l32i  a3, a2, 0         ; a3 = 10: the word at a2 + 0
  l32i  a4, a2, 4         ; a4 = 20: the word at a2 + 4
  l32r  a5, lit_buffer    ; a5 = the address of the buffer
  s32i  a4, a5, 0         ; writes a4 (20) as a word to a5 + 0 (the memory window shows it at that address)
  movi  a6, 0x41          ; a6 = 0x41, the letter 'A'
  s8i   a6, a5, 4         ; writes one byte to a5 + 4
  l8ui  a7, a5, 4         ; a7 = 0x41: one byte read, the upper 24 bits zero
  movi  a6, -2            ; a6 = -2 = 0xFFFFFFFE
  s16i  a6, a5, 6         ; writes the lower 16 bits (0xFFFE) to a5 + 6
  l16ui a8, a5, 6         ; a8 = 0xFFFE = 65534: read without sign
  l16si a9, a5, 6         ; a9 = -2: read with sign (bit 15 fills the upper bits)
  s32i  a3, a1, 0         ; a3 onto the stack: a1 is the stack pointer, entry made room
  l32i  a10, a1, 0        ; a10 = 10, read back from the stack

; ---- 5. Jumps and conditional jumps ------------------------------------------------------------------------------
; A conditional jump goes to its label when the condition holds; otherwise the next line runs. Here a15 counts the
; jumps that were NOT taken: the "addi a15" behind such a jump runs, behind a taken one it is skipped.
  movi  a2, 5             ; a2 = 5
  movi  a3, 7             ; a3 = 7
  movi  a15, 0            ; a15 = 0, the counter
  beq   a2, a3, b1        ; a2 = a3? 5 = 7 no: not taken
  addi  a15, a15, 1       ;   runs (a15 = 1)
b1:
  bne   a2, a3, b2        ; a2 <> a3? yes: jumps to b2
  addi  a15, a15, 1       ;   skipped
b2:
  blt   a2, a3, b3        ; a2 < a3, signed? 5 < 7 yes: jumps
  addi  a15, a15, 1       ;   skipped
b3:
  bge   a2, a3, b4        ; a2 >= a3, signed? no: not taken
  addi  a15, a15, 1       ;   runs (a15 = 2)
b4:
  movi  a4, -1            ; a4 = -1 = 0xFFFFFFFF
  bltu  a2, a4, b5        ; a2 < a4 unsigned? 5 < 0xFFFFFFFF yes: jumps (signed it would be no)
  addi  a15, a15, 1       ;   skipped
b5:
  beqz  a2, b6            ; a2 = 0? no: not taken
  addi  a15, a15, 1       ;   runs (a15 = 3)
b6:
  bnez  a2, b7            ; a2 <> 0? yes: jumps
  addi  a15, a15, 1       ;   skipped
b7:
  bltz  a4, b8            ; a4 < 0? -1 yes: jumps
  addi  a15, a15, 1       ;   skipped
b8:
  beqi  a2, 5, b9         ; a2 = 5? yes: jumps (beqi compares with a constant: -1, 1 to 8, 10, 12, 16 ...)
  addi  a15, a15, 1       ;   skipped
b9:
  bgei  a2, 6, b10        ; a2 >= 6? no: not taken
  addi  a15, a15, 1       ;   runs (a15 = 4)
b10:
  bbsi  a2, 2, b11        ; is bit 2 of a2 set? 5 = 101 binary: yes, jumps
  addi  a15, a15, 1       ;   skipped
b11:
  bbci  a2, 1, b12        ; is bit 1 of a2 clear? yes: jumps
  addi  a15, a15, 1       ;   skipped
b12:
  j     b13               ; jumps always
  addi  a15, a15, 1       ;   never runs
b13:                      ; here a15 = 4

; ---- 6. Conditional moves (no jump) ------------------------------------------------------------------------------
  movi  a5, 0             ; a5 = 0
  movi  a6, 111           ; a6 = 111
  movi  a7, 222           ; a7 = 222
  moveqz a6, a7, a5       ; a6 = a7 if a5 = 0: a5 is 0, so a6 = 222
  movnez a7, a2, a5       ; a7 = a2 if a5 <> 0: a5 is 0, so a7 stays 222

; ---- 7. Loops ----------------------------------------------------------------------------------------------------
; a) with a counter and a conditional jump back: a2 = 1 + 2 + ... + 10
  movi  a2, 0             ; a2 = 0, the sum
  movi  a3, 10            ; a3 = 10, the counter
sum_loop:
  add   a2, a2, a3        ; add the counter to the sum
  addi  a3, a3, -1        ; the counter one less
  bnez  a3, sum_loop      ; not 0 yet: once more. At the end a2 = 55
; b) the loop of the core itself (zero overhead): loop repeats the lines up to loop_end a4 times, without a jump
;    instruction; the registers lbeg, lend and lcount hold its start, its end and the rounds left
  movi  a4, 5             ; a4 = 5 rounds
  movi  a5, 0             ; a5 = 0
  loop  a4, loop_end      ; repeat the next lines (up to loop_end) a4 times
  addi  a5, a5, 3         ; a5 grows by 3 each round
loop_end:                 ; here a5 = 15

; ---- 8. Subroutines ----------------------------------------------------------------------------------------------
; a) call0: the return address goes into a0, the subroutine sees the same registers. a0 holds the return address
;    of _start itself, so it is kept in a12 first.
  mov   a12, a0           ; keep a0
  movi  a2, 21            ; a2 = 21, the argument of double
  call0 double            ; a0 = the address of the next line, then on at double (F7 goes in, F8 over it)
  mov   a0, a12           ; a0 back. Now a2 = 42
; b) call8: the window turns by 8 registers. The argument goes in a10, which square sees as its a2; its result comes
;    back in a10. a0 to a7 here are not touched by square.
  movi  a10, 6            ; the argument: 6
  call8 square            ; a10 = 6 * 6 = 36 afterwards (F7: watch a2 inside square)
  mov   a3, a10           ; a3 = 36
; c) callx8: the same, the address of the subroutine in a register
  l32r  a8, lit_square    ; a8 = the address of square
  movi  a10, 9            ; the argument: 9
  callx8 a8               ; a10 = 81 afterwards
  mov   a4, a10           ; a4 = 81

; ---- 9. A subroutine that calls itself: the factorial 5! = 1 * 2 * 3 * 4 * 5 -------------------------------------
  movi  a10, 5            ; the argument: 5
  call8 fact              ; a10 = 120 afterwards. F7 into it: each call opens a new window, retw closes it
  mov   a2, a10           ; a2 = 120: the result of the program
  retw                    ; back to the caller (the console): the output window shows a2 = 120

; double: a2 = a2 + a2. Called with call0: no window of its own, ret jumps to the address in a0.
align 4                   ; a call target stands at an address that is a multiple of 4
double:
  add   a2, a2, a2        ; a2 = 2 * a2
  ret                     ; back to the address in a0

; square: a2 = a2 * a2. Called with call8: entry opens its window, retw closes it again.
align 4
square:
  entry a1, 16            ; the window of square, 16 bytes of stack (the least)
  mull  a2, a2, a2        ; a2 = a2 * a2 (the caller sees it in its a10)
  retw                    ; back: the caller's window again

; fact: a2 = a2! (the factorial), recursive: n! = n * (n-1)!, and 1! = 1
align 4
fact:
  entry a1, 16            ; a new window for each call
  bltui a2, 2, fact_one   ; n < 2? then the result is 1
  addi  a10, a2, -1       ; the argument for the next call: n - 1
  call8 fact              ; a10 = (n-1)!
  mull  a2, a2, a10       ; a2 = n * (n-1)!
  retw                    ; back with a2
fact_one:
  movi  a2, 1             ; 1! = 1 (and 0! = 1)
  retw

; The data, in the DRAM from 0x3FFB0000 on: the core reads and writes bytes, halfwords and words there (the code
; RAM takes only words).
.data
table:  dd 10, 20, 30, 40  ; four words
buffer: resb 16            ; 16 bytes of room, zero at the start
