; cdecl functions: the caller removes the arguments (call adds "add esp, 12" itself).
; Min3 uses a local variable; ShowNumber formats with wsprintfA (also cdecl) into a
; local buffer and shows it in a message box. Try: asmoc func_cdecl.asm

.format pe gui
.arch i386
.import user32.dll MessageBoxA
.import user32.dll wsprintfA
.import kernel32.dll ExitProcess

.code
start:
  call Min3(19, 7, 40)            ; cdecl func: push 40 / push 7 / push 19 / call / add esp, 12
  call ShowNumber(eax)
  call [ExitProcess](0)

func Min3(a, b, c) cdecl
  var best
begin
  mov eax, a
  mov best, eax
  mov eax, b
  cmp eax, best
  jge keep1
  mov best, eax
keep1:
  mov eax, c
  cmp eax, best
  jge keep2
  mov best, eax
keep2:
  mov eax, best
end

func ShowNumber(value)
  var text:32
begin
  ; wsprintfA is cdecl: write it, the assembler cleans up. text is an array: its address.
  call cdecl [wsprintfA](text, format, value)
  call [MessageBoxA](0, text, caption, 0)
end

.data
format db 'The smallest number is %d', 0
caption db 'func_cdecl', 0
