; Hello world, Windows on ARM, 64 bit (.arch arm64, PE32+, machine ARM64).
; Assemble: asmoc hello_arm64.asm
; The image is not placed at a fixed address: adrp/add and adrp/ldr are
; relative to the pc.

.format pe console
.arch arm64
.import msvcrt.dll printf, exit

.code
start:
  stp x29, x30, [sp, #-16]!
  adrp x0, msg
  add x0, x0, :lo12:msg   ; first argument in x0
  adrp x16, printf
  ldr x16, [x16, :lo12:printf]
  blr x16
  mov x0, #0
  adrp x16, exit
  ldr x16, [x16, :lo12:exit]
  blr x16

.data
msg db 'Hello, World!', 10, 0
