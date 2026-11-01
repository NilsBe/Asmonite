; The local time in a message box (Windows, i386, window program).
;   GetLocalTime(&SYSTEMTIME)          "time" is an array of 16 bytes: wYear at 0, wMonth 2,
;                                      wDayOfWeek 4, wDay 6, wHour 8, wMinute 10, wSecond 12
;   wsprintfA(text, format, h, m, s)   is cdecl: "call cdecl" and the assembler cleans up
;   MessageBoxA(0, text, caption, 0)
; The values are in ebx, esi, edi, which a func has to save: "uses".

.format pe gui
.arch i386
.import kernel32.dll GetLocalTime
.import kernel32.dll ExitProcess
.import user32.dll wsprintfA
.import user32.dll MessageBoxA

.code
start:
  call ShowTime()
  call [ExitProcess](0)

func ShowTime() uses ebx, esi, edi
  var time:16, text:64
begin
  call [GetLocalTime](time)
  movzx ebx, word [time+8]        ; hour
  movzx esi, word [time+10]       ; minute
  movzx edi, word [time+12]       ; second
  call cdecl [wsprintfA](text, format, ebx, esi, edi)
  call [MessageBoxA](0, text, caption, 0)
end

.data
format db 'It is %02d:%02d:%02d', 0
caption db 'func_time', 0
