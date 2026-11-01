; call name(arguments): the assembler pushes the arguments and cleans up.
; The exit code is 33: Add2(7, 5) = 12, then Sum3(10, 12, 11) = 33.
;
;   call Add2(7, 5)
; becomes
;   push 5 / push 7 / call Add2           (stdcall: Add2 removes its arguments)
; and for a cdecl function
;   call cdecl Sum3(10, ebx, 11)  ->  push 11 / push ebx / push 10 / call Sum3 / add esp, 12
; A func tells its convention itself: "call Sum3(...)" is enough once Sum3 is declared
; "cdecl"; for a label or an import that is no func, stdcall is assumed unless you write
; "call cdecl name(...)".
;
; An argument is a register, a number, a label (its address), a parameter or local of
; the func (a dword: its value; a byte/word: zero extended; an array: its address),
; "&name" (the address of any local) or a memory operand "[ebx+4]".

.format pe console
.arch i386
.import kernel32.dll ExitProcess

.code
start:
  call Add2(7, 5)                 ; 12
  mov ebx, eax
  call Sum3(10, ebx, 11)          ; 33: a register as an argument
  call [ExitProcess](eax)         ; an import: stdcall

func Add2(a, b)
begin
  mov eax, a
  add eax, b
end

func Sum3(x, y, z) cdecl
begin
  mov eax, x
  add eax, y
  add eax, z
end
