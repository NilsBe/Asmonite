; The factorial two ways: recursive (func, if / else / endif) and iterative (do ... while).
; The program prints "10! = 3628800" and "5! = 120" and ends with the exit code 0.
;
; There are no expressions and no calls inside a call: "call Fact(n-1)" is not possible, so the
; counter is decremented first ("dec ebx") and then passed. The result of a func is in eax.
; ".import msvcrt.dll cdecl printf" tells call [printf](...) that the caller cleans up the stack.

.format pe console
.arch i386
.import kernel32.dll ExitProcess
.import msvcrt.dll cdecl printf

.code
start:
  call Fact(10)
  call [printf](fmt, 10, eax)
  call FactLoop(5)
  call [printf](fmt, 5, eax)
  call [ExitProcess](0)

; recursive: n! = n * (n-1)!, 0! = 1! = 1
func Fact(n) uses ebx
begin
  if unsigned n > 1
    mov ebx, n
    dec ebx
    call Fact(ebx)
    imul eax, n
  else
    mov eax, 1
  endif
end

; iterative
func FactLoop(n)
begin
  mov ecx, n
  mov eax, 1
  if unsigned ecx > 1
    do
      imul eax, ecx
      dec ecx
    while unsigned ecx > 1
  endif
end

.data
fmt: db '%d! = %d', 0x0A, 0
