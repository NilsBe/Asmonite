; tick_i386.asm - counts in EDX:EBX (64 bits) as fast as it can; once a second another thread reads both
; registers and prints them.
; Windows has no timer interrupt for programs: the thread stops the counting thread, reads its registers
; (GetThreadContext) and lets it go on - the register is read from outside, as the interrupt handler does in DOS.

.format pe console
.arch i386
.import kernel32.dll ExitProcess
.import kernel32.dll CreateThread
.import kernel32.dll GetCurrentThread
.import kernel32.dll GetCurrentProcess
.import kernel32.dll DuplicateHandle
.import kernel32.dll Sleep
.import kernel32.dll SuspendThread
.import kernel32.dll ResumeThread
.import kernel32.dll GetThreadContext
.import msvcrt.dll cdecl printf
.import msvcrt.dll cdecl fflush

.code
start:
  ; a real handle of this thread (GetCurrentThread only gives a pseudo handle that means "the caller")
  call [GetCurrentProcess]
  mov esi, eax
  call [GetCurrentThread]
  call [DuplicateHandle](esi, eax, esi, hMain, 0, 0, 2)    ; 2 = DUPLICATE_SAME_ACCESS
  call [CreateThread](0, 0, Watcher, 0, 0, 0)

  xor ebx, ebx                  ; EDX:EBX is the counter: EBX the low half, EDX the high half
  xor edx, edx
count:
  inc ebx                       ; as often as possible; inc leaves the carry flag alone, but ZF shows the wrap
  if zero
    inc edx                     ; the high half: only when EBX has wrapped around to 0
  endif
  cmp byte [done], 0
  je count

  call [ExitProcess](0)

; the thread that looks at EBX once a second, ten times
func Watcher(arg)
  var n
begin
  mov n, 0
  do
    call [Sleep](1000)
    call [SuspendThread]([hMain])
    mov dword [ctx], 0x10002                ; CONTEXT_INTEGER: the general registers
    call [GetThreadContext]([hMain], ctx)
    call [ResumeThread]([hMain])
    call [printf](fmt, [ctx+168], [ctx+164]) ; Edx is at offset 168 of the CONTEXT, Ebx at 164
    call [fflush](0)                        ; also when the output is redirected
    inc n
  while unsigned n < 10
  mov byte [done], 1
  mov eax, 0
end

.data
fmt:   db 'edx:ebx = %08X%08X', 0x0A, 0
done:  db 0
hMain: dd 0

align 16                        ; GetThreadContext wants a 16-byte aligned CONTEXT (else error 998)
ctx:   resb 716                 ; the CONTEXT of a 32-bit thread
