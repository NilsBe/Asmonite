; Hello world, Windows, Intel 32 bit (.arch i386). Assemble: asmoc hello_i386.asm
; The assembler writes the DOS stub, the PE header, the section table and the
; import table itself (.format pe).

.format pe console
.arch i386
.import msvcrt.dll printf, exit

.code
start:
  push dword msg
  call [printf]           ; through the import address table
  add esp, 4              ; printf does not clean up
  push 0
  call [exit]

.data
msg db 'Hello, World!', 10, 0
