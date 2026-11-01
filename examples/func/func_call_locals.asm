; call with the locals of a func as arguments: an array, a byte, "&" for an address.
; The exit code is 36: Sum4(table) = 10, Twice(small) = 10, then Bump(&n) makes n 8
; and Twice(n) = 16.
;
; An array name, "&name" and a byte/word variable need a register for the address
; or for the zero extension: the assembler takes eax, else ecx, else edx - the first
; one that the argument list does not name. So "call F(table)" is
;   lea eax, [ebp-..] / push eax / call F

.format pe console
.arch i386
.import kernel32.dll ExitProcess

.code
start:
  call Run()
  call [ExitProcess](eax)

; Sum4(p) adds the four bytes at p
func Sum4(p) uses esi
begin
  mov esi, p
  movzx eax, byte [esi]
  movzx ecx, byte [esi+1]
  add eax, ecx
  movzx ecx, byte [esi+2]
  add eax, ecx
  movzx ecx, byte [esi+3]
  add eax, ecx
end

func Twice(v)
begin
  mov eax, v
  add eax, eax
end

; Bump(p) adds 1 to the dword at p
func Bump(p)
begin
  mov eax, p
  inc dword [eax]
end

func Run() uses ebx
  var table:4, small:byte, n
begin
  mov dword table, 0x04030201     ; the bytes 1, 2, 3, 4
  mov small, 5
  mov n, 7
  call Sum4(table)                ; 10: the address of the array
  mov ebx, eax
  call Twice(small)               ; 10: movzx eax, byte [ebp-..] / push eax
  add ebx, eax                    ; 20 in ebx
  call Bump(&n)                   ; n = 8
  call Twice(n)                   ; 16
  add eax, ebx                    ; 36
end
