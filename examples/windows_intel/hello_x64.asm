; Hello world, Windows, Intel 64 bit (.arch x64, PE32+).
; Assemble: asmoc hello_x64.asm

.format pe console
.arch x64
.import msvcrt.dll printf, exit

.code
start:
  sub rsp, 40             ; shadow space for the call, stack aligned
  lea rcx, [msg]          ; first argument in rcx
  call [printf]
  xor ecx, ecx
  call [exit]

.data
msg db 'Hello, World!', 10, 0
