; Asmonite demo: counts from 1 to 5 and prints a line for each number.
; F9 runs it in the debugger, F5 sets a breakpoint, F8/F7 step.

.arch i386
.format pe console

.import msvcrt.dll printf
.import kernel32.dll ExitProcess

.code
start:  mov ebx,1               ; the counter
next:   push ebx
        push dword line         ; format text
        call [printf]           ; through the import address table
        add esp,8               ; printf does not clean up
        inc ebx
        cmp ebx,6
        jnz short next          ; once more, up to 5
        push 0
        call [ExitProcess]      ; exit code 0

.data
line:   db 'Number %d',0x0D,0x0A,0x00
