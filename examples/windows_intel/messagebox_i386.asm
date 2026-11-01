; A message box, Windows, Intel 32 bit (.arch i386, .format pe gui).
; Assemble: asmoc messagebox_i386.asm
; MessageBoxA(hWnd, text, caption, type) is stdcall: the arguments are pushed
; from right to left and the function removes them itself.
; The window opens on the desktop where the program runs: on the same computer
; under the debugger, on the remote one with a debug server.

.format pe gui
.arch i386
.import user32.dll MessageBoxA
.import kernel32.dll ExitProcess

.code
start:
  push 0                  ; type: MB_OK
  push dword caption
  push dword text
  push 0                  ; no owner window
  call [MessageBoxA]
  push 0
  call [ExitProcess]

.data
text db 'Hello from a message box!', 0
caption db 'messagebox_i386', 0
