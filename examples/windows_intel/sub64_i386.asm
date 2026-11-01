; 64-bit numbers with 32-bit registers (.arch i386): the difference of two of them.
; A 64-bit number is two dwords in memory, the low half first (a and a+4), and edx:eax in registers.
; sub subtracts the low halves and leaves the borrow in the carry flag, sbb subtracts the high halves
; and the borrow. For the sum the same is add and adc.
;
; The program prints 4294967295 and -5 and one line that says which of two numbers is the smaller.
; printf("%I64d") takes the low half first on the stack: the arguments are the low half, then the high half.

.format pe console
.arch i386
.import kernel32.dll ExitProcess
.import msvcrt.dll cdecl printf
.import msvcrt.dll cdecl fflush

.code
start:
  call Sub64(a, b, result)
  call [printf](fmt, [result], [result+4])        ; 4294967296 - 1

  call Sub64(c, d, result)
  call [printf](fmt, [result], [result+4])        ; 5 - 10

  call IsLess64(c, d)                             ; signed: 5 < 10
  if eax != 0
    call [printf](yes)
  else
    call [printf](no)
  endif

  call [fflush](0)
  call [ExitProcess](0)

; result = *pa - *pb (all three are the addresses of 64-bit numbers)
func Sub64(pa, pb, pres) uses esi, edi
begin
  mov esi, pa
  mov edi, pb
  mov eax, [esi]           ; edx:eax = a
  mov edx, [esi+4]
  sub eax, [edi]           ; low half minus low half: the borrow is in the carry flag
  sbb edx, [edi+4]         ; high half minus high half minus the borrow
  mov esi, pres
  mov [esi], eax
  mov [esi+4], edx
end

; eax = 1 if *pa < *pb (signed), else 0
func IsLess64(pa, pb) uses esi, edi
begin
  mov esi, pa
  mov edi, pb
  mov eax, [esi]
  mov edx, [esi+4]
  cmp eax, [edi]           ; only the flags: the same as sub / sbb without keeping the result
  sbb edx, [edi+4]
  mov eax, 0
  if less                  ; signed less: after cmp / sbb the flags say it for the whole 64 bits
    mov eax, 1
  endif
end

.data
fmt: db '%I64d', 0x0A, 0
yes: db '5 < 10', 0x0A, 0
no:  db '5 >= 10', 0x0A, 0
a:   dq 0x0000000100000000       ; 4294967296
b:   dq 1
c:   dq 5
d:   dq 10
result: dq 0
