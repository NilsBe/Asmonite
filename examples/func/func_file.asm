; Files: CreateFileA, WriteFile, ReadFile, CloseHandle, DeleteFileA (Windows, i386).
; The program writes 11 bytes to a file, reads them back, deletes the file and ends with
; the number of bytes read (exit code 11). CreateFileA has seven arguments:
;   CreateFileA(name, access, share, security, creation, attributes, template)
; "buffer" is an array of the func: its address goes to ReadFile; "&count" is the address
; of the local "count".

.format pe console
.arch i386
.import kernel32.dll CreateFileA
.import kernel32.dll WriteFile
.import kernel32.dll ReadFile
.import kernel32.dll CloseHandle
.import kernel32.dll DeleteFileA
.import kernel32.dll ExitProcess

.code
start:
  call RoundTrip()
  call [ExitProcess](eax)

; RoundTrip() returns the number of bytes it read back
func RoundTrip()
  var handle, count, buffer:16
begin
  ; GENERIC_WRITE = 0x40000000, CREATE_ALWAYS = 2, FILE_ATTRIBUTE_NORMAL = 0x80
  call [CreateFileA](filename, 0x40000000, 0, 0, 2, 0x80, 0)
  mov handle, eax
  call [WriteFile](handle, content, 11, &count, 0)
  call [CloseHandle](handle)

  ; GENERIC_READ = 0x80000000, OPEN_EXISTING = 3
  call [CreateFileA](filename, 0x80000000, 0, 0, 3, 0x80, 0)
  mov handle, eax
  call [ReadFile](handle, buffer, 16, &count, 0)
  call [CloseHandle](handle)
  call [DeleteFileA](filename)
  mov eax, count
end

.data
filename db 'func_file_test.tmp', 0
content db 'Hello world', 0
