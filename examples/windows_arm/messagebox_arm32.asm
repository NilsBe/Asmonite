; A message box, Windows on ARM, 32 bit (.arch thumb: Thumb-2, PE32, .format pe gui).
; Assemble: asmoc messagebox_arm32.asm
; The arguments of MessageBoxA are in r0..r3; the address of the function comes from
; the import address table (ldr with a label, relative to the pc).
; The window opens on the desktop where the program runs: on the same computer
; under the debugger, on the remote one with a debug server.

.format pe gui
.arch thumb
.import user32.dll MessageBoxA
.import kernel32.dll ExitProcess

.code
start:
  push {r4, lr}
  movs r0, #0             ; no owner window
  adr r1, text
  adr r2, caption
  movs r3, #0             ; type: MB_OK
  ldr r4, MessageBoxA
  blx r4
  movs r0, #0
  ldr r4, ExitProcess
  blx r4

.data
text db 'Hello from a message box!', 0
caption db 'messagebox_arm32', 0
