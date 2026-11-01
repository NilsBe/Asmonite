; if / else / endif on x64 (.arch x64). The exit code is 31 = 1 + 2 + 4 + 8 + 16:
; each block that runs adds its number, so the code tells which ifs were true.

.format pe console
.arch x64

.code
start:
  xor eax, eax
  mov ecx, 5
  mov r8d, 4

  if ecx == 5                ; cmp ecx, 5 / jne
    add eax, 1
  endif

  if signed ecx < 3          ; cmp ecx, 3 / jge: not true, the else runs
    add eax, 100
  else
    add eax, 2
  endif

  mov edx, -1                ; 0xFFFFFFFF
  if unsigned edx > ecx      ; as an unsigned number it is the biggest
    add eax, 4
  endif
  if signed edx < ecx        ; as a signed number it is -1
    add eax, 8
  endif

  if ecx & r8d               ; test ecx, r8d / jz: bit 2 of 5 is set
    add eax, 16
  endif
  ret
