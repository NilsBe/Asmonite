; if / else / endif on ARM 32 (.arch thumb). The exit code is 31 = 1 + 2 + 4 + 8 + 16:
; each block that runs adds its number, so the code tells which ifs were true.
; Operands are written as on ARM; a plain number gets its # by itself.

.format pe console
.arch thumb

.code
start:
  movs r0, #0
  movs r1, #5
  movs r3, #4

  if r1 == 5                 ; cmp r1, #5 / bne
    adds r0, r0, #1
  endif

  if signed r1 < 3           ; cmp r1, #3 / bge: not true, the else runs
    adds r0, r0, #100
  else
    adds r0, r0, #2
  endif

  movs r2, #-1               ; 0xFFFFFFFF
  if unsigned r2 > r1        ; as an unsigned number it is the biggest
    adds r0, r0, #4
  endif
  if signed r2 < r1          ; as a signed number it is -1
    adds r0, r0, #8
  endif

  if r1 & r3                 ; tst r1, r3 / beq: bit 2 of 5 is set
    adds r0, r0, #16
  endif
  bx lr
