; if / else / endif on ARM 64 (.arch arm64). The exit code is 31 = 1 + 2 + 4 + 8 + 16:
; each block that runs adds its number, so the code tells which ifs were true.
; Operands are written as on ARM; a plain number gets its # by itself.

.format pe console
.arch arm64

.code
start:
  mov w0, #0
  mov w1, #5
  mov w3, #4

  if w1 == 5                 ; cmp w1, #5 / b.ne
    add w0, w0, #1
  endif

  if signed w1 < 3           ; cmp w1, #3 / b.ge: not true, the else runs
    add w0, w0, #100
  else
    add w0, w0, #2
  endif

  mov w2, #-1                ; 0xFFFFFFFF
  if unsigned w2 > w1        ; as an unsigned number it is the biggest
    add w0, w0, #4
  endif
  if signed w2 < w1          ; as a signed number it is -1
    add w0, w0, #8
  endif

  if w1 & w3                 ; tst w1, w3 / b.eq: bit 2 of 5 is set
    add w0, w0, #16
  endif
  ret
