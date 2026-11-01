; if / else / endif: a comparison and the jump around the block, without a label of your own.
; The program ends with the exit code 7 (the larger of 3 and 7): "echo %errorlevel%" shows it.
;
; "if signed eax < b" is "cmp eax, b" and the jump of the opposite condition (jge) to the end of the block.
; == and != need no word; < <= > >= say "signed" (jl jle jg jge) or "unsigned" (jb jbe ja jae).

.format pe console
.arch i386
.import kernel32.dll ExitProcess
.import msvcrt.dll printf

.code
start:
  ;push 3
  ;push 7
  call Max(3,7)
  ;push eax
  call cdecl [Printf](format, eax)  ; push eax, push format
  call [ExitProcess]

func Max(a, b)
begin
  mov eax, a
  if signed eax < b       ; cmp eax, dword [ebp+12] / jge ...
    mov eax, b            ; the larger value
  endif
end

.data
format: db 'eax = %d'


