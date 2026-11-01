; A message box, Windows on ARM, 64 bit (.arch arm64, PE32+, .format pe gui).
; Assemble: asmoc messagebox_arm64.asm
; The arguments of MessageBoxA are in x0..x3; adrp/add and adrp/ldr are relative
; to the pc.
; The window opens on the desktop where the program runs: on the same computer
; under the debugger, on the remote one with a debug server.

.format pe gui
.arch arm64
.import user32.dll MessageBoxA
.import kernel32.dll ExitProcess

.code
start:
  stp x29, x30, [sp, #-16]!
  mov x0, #0              ; no owner window
  adrp x1, text
  add x1, x1, :lo12:text
  adrp x2, caption
  add x2, x2, :lo12:caption
  mov w3, #0              ; type: MB_OK
  adrp x16, MessageBoxA
  ldr x16, [x16, :lo12:MessageBoxA]
  blr x16
  mov x0, #0
  adrp x16, ExitProcess
  ldr x16, [x16, :lo12:ExitProcess]
  blr x16

.data
text db 'Hello from a message box!', 0
caption db 'messagebox_arm64', 0
