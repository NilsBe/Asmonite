; Hello world with .format pe: the assembler writes the DOS stub, the
; PE header, the section table and the import table itself.

.arch i386
.format pe console

.import msvcrt.dll printf

.code
start:  nop
        push dword hello
        call [printf]           ; through the import address table
        pop ecx
        ret                     ; exit code: EAX = 13 from printf

.data
hello:  db 'Hello world!',0x0A,0x00
