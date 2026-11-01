; The factorial recursive: Fac(n) = n * Fac(n-1) with if / else / endif, no label of your own.
; The program prints "10! = 3628800" and ends with the exit code 0.
; (func_loop.asm has the same function and the loops Sum and Mult with do ... while.)

.format pe console
.arch i386
.import kernel32.dll ExitProcess
.import msvcrt.dll printf

.code
start:
  mov [op], 10
  call Fac([op])
  ;mov ebx, eax
  call cdecl [Printf](format2, [op], eax)
  push 0
  call [ExitProcess]

func Fac(n) uses ebx
begin
  if unsigned n > 1
    ; return n * Fac(n-1)
    mov ebx, n
    sub n,1
    call Fac(n)
    mul eax, ebx          ; n * Fac(n-1)
  else
    mov eax, 1    
  endif
end

func Sum(n)
begin
  mov ecx, n              ; the counter
  mov eax, 0
  do
    add eax, ecx          ; 10 + 9 + ... + 1
    dec ecx
  while not zero          ; jnz: back to the do while ecx is not 0
end

func Mult(n)
begin
  mov ecx, n              ; the counter
  mov eax, 1
  do
    mul eax, ecx          ; 10 * 9 * ... * 1
    dec ecx
  while not zero          ; jnz: back to the do while ecx is not 0
end

.data
op: dd 10
format: db 'sum = %d', 0x0A, 0
format2: db '%d! = %d', 0x0A, 0

