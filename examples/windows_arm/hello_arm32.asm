; Hello world, Windows on ARM, 32 bit (.arch thumb: Thumb-2, PE32, machine ARMNT).
; Assemble: asmoc hello_arm32.asm
; The image is not placed at a fixed address, the code must not use absolute
; addresses: adr and ldr with a label are relative to the pc. Code, data and
; imports are in one section, so that they are within the reach (4 KB) of them.

.format pe console
.arch thumb
.import msvcrt.dll printf, exit

.code
start:
  push {r4, lr}
  adr r0, msg             ; first argument in r0
  ldr r3, printf          ; the address of printf, from the import address table
  blx r3
  movs r0, #0
  ldr r3, exit
  blx r3

.data
msg db 'Hello, World!', 10, 0
