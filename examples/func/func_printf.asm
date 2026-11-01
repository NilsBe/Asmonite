; printf from the C runtime is cdecl: the caller removes the arguments after the call.
; The .import line says it for its names (".import msvcrt.dll cdecl printf"), and then
; "call [printf](...)" adds "add esp, 16" itself. Without the word it is an error (the C
; runtime is always cdecl); the functions of kernel32 and user32 are stdcall, the default.
; "call cdecl [name](...)" or "call stdcall [name](...)" decides for one call.

.format pe console
.arch i386
.import msvcrt.dll cdecl printf
.import kernel32.dll ExitProcess

.code
start:
  nop 
  nop
  call [printf](format, 6, 7, 42)       ; push 42 / push 7 / push 6 / push format / call / add esp, 16
  nop
  nop
  call [ExitProcess](0)

.data
format db '%d * %d = %d', 10, 0
