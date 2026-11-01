; A message box, Windows, Intel 64 bit (.arch x64, PE32+, .format pe gui).
; Assemble: asmoc messagebox_x64.asm
; The first four arguments are in rcx, rdx, r8 and r9; the caller reserves 32 bytes
; of shadow space (and 8 more to keep the stack aligned).
; The window opens on the desktop where the program runs: on the same computer
; under the debugger, on the remote one with a debug server.

.format pe gui
.arch x64
.import user32.dll MessageBoxA
.import kernel32.dll ExitProcess

.code
start:
  sub rsp, 40
  xor ecx, ecx            ; no owner window
  lea rdx, [text]
  lea r8, [caption]
  xor r9d, r9d            ; type: MB_OK
  call [MessageBoxA]
  xor ecx, ecx
  call [ExitProcess]

.data
text db 'Hello from a message box!', 0
caption db 'messagebox_x64', 0
