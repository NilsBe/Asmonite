; hello.asm - Win32 console "Hello, World" (NASM syntax)
; nasm -f win32 hello.asm && link /subsystem:console hello.obj kernel32.lib

        bits 32
        global _main
        extern _GetStdHandle@4, _WriteFile@20, _ExitProcess@4

        section .data
msg:    db 'Hello, World!', 13, 10
len     equ $ - msg
written dd 0

        section .text
_main:
        push -11                ; STD_OUTPUT_HANDLE
        call _GetStdHandle@4
        mov ebx, eax

        push 0
        push written
        push len
        push msg
        push ebx
        call _WriteFile@20

        xor eax, eax
        mov ecx, 0x10
.loop:  add eax, ecx            ; sum 16..1
        dec ecx
        jnz .loop

        push 0
        call _ExitProcess@4
