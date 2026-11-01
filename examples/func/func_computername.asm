; The name of this computer: GetComputerNameA(buffer, &size) and WriteFile (Windows, i386).
; "name" is an array of 64 bytes: its address is the first argument; "&size" is the
; address of a local that holds the size of the buffer before and the length after the call.
; The exit code is the length of the name.

.format pe console
.arch i386
.import kernel32.dll GetComputerNameA
.import kernel32.dll GetStdHandle
.import kernel32.dll WriteFile
.import kernel32.dll ExitProcess

.code
start:
  call Main()
  call [ExitProcess](eax)

func Main()
  var name:64, size, written, console
begin
  mov size, 64
  call [GetComputerNameA](name, &size)
  call [GetStdHandle](-11)
  mov console, eax
  call [WriteFile](console, name, size, &written, 0)
  call [WriteFile](console, newline, 2, &written, 0)
  mov eax, size
end

.data
newline db 13, 10
