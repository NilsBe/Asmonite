; func: parameters and the stack frame without counting offsets (Windows, i386).
; The program ends with the exit code 12 (7 + 5): "echo %errorlevel%" shows it.
;
; Without func the function would be
;     Add2:  push ebp / mov ebp, esp / mov eax, [ebp+8] / add eax, [ebp+12] / pop ebp / ret 8
; With func the assembler writes the frame, the parameters have names, and
; "end" adds "pop ebp / ret 8" (stdcall: the function removes its two arguments).

.format pe console
.arch i386
.import kernel32.dll ExitProcess

.code
start:
  push 5                  ; b
  push 7                  ; a (arguments are pushed from right to left)
  call Add2
  push eax
  call [ExitProcess]

func Add2(a, b)
begin
  mov eax, a              ; mov eax, dword [ebp+8]
  add eax, b              ; add eax, dword [ebp+12]
end
