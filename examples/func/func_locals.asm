; func with local variables, an array, "uses" and an early "ret".
; Exit code: 39 (34 from SumPairs + 5 from Find).

.format pe console
.arch i386
.import kernel32.dll ExitProcess

.code
start:
  push 4
  push 20
  push 10
  call SumPairs           ; 10 + 20 + 4 + 0 = 34
  mov ebx, eax            ; ebx survives the calls: Find saves what it uses
  push 0x78               ; 'x'
  push dword text
  call Find               ; 5: the position of 'x' in "abcdx"
  add eax, ebx
  push eax
  call [ExitProcess]

; SumPairs(a, b, c): puts the values into a table on the stack and adds them.
;   table is an array of 16 bytes -> "table" is its address, "table+4" the second dword
;   i and total are dword locals; "uses ebx" saves ebx
func SumPairs(a, b, c) uses ebx
  var table:16, total
begin
  mov eax, a
  mov table, eax          ; mov [ebp-24], eax
  mov eax, b
  mov table+4, eax
  mov eax, c
  mov table+8, eax
  mov dword table+12, 0
  mov total, 0
  xor ebx, ebx
again:
  mov eax, [table+ebx*4]  ; [ebp-24+ebx*4]
  add total, eax
  inc ebx
  cmp ebx, 4
  jb again
  mov eax, total
end

; Find(text, letter:byte): the 1-based position of letter in the zero terminated text, else 0.
; "letter:byte" reads only the low byte of the argument slot.
func Find(s, letter:byte) uses esi
begin
  mov esi, s
  xor ecx, ecx
next:
  inc ecx
  mov al, byte [esi]
  test al, al
  jnz check
  xor eax, eax
  ret                     ; early return: the epilog (pop esi / pop ebp / ret 8)
check:
  inc esi
  cmp al, letter
  jne next
  mov eax, ecx
end

.data
text db 'abcdx', 0
