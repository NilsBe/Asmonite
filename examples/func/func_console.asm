; System functions with arguments: write text to the console (Windows, i386).
;   GetStdHandle(-11)                          the console output
;   lstrlenA(text)                             the length of a zero terminated text
;   WriteFile(handle, text, length, &written, 0)
; WriteFile gets the address of the local "written": the assembler needs a register for
; it and takes ecx, because eax is named in the argument list (the length).

.format pe console
.arch i386
.import kernel32.dll GetStdHandle
.import kernel32.dll WriteFile
.import kernel32.dll lstrlenA
.import kernel32.dll ExitProcess

.code
start:
  call Print(hello)
  call Print(second)
  call [ExitProcess](0)

; Print(text): writes the zero terminated text to the console
func Print(text)
  var console, written
begin
  call [GetStdHandle](-11)
  mov console, eax
  call [lstrlenA](text)
  call [WriteFile](console, text, eax, &written, 0)
end

.data
hello db 'Hello from a func with arguments', 13, 10, 0
second db 'The assembler pushes the arguments for you', 13, 10, 0
