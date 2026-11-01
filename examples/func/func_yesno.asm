; MessageBoxA with buttons and the answer as the exit code (Windows, i386, window program).
; MB_YESNO | MB_ICONQUESTION = 0x24; the answer is IDYES (6) or IDNO (7).
; Run it from a console and look at "echo %errorlevel%".

.format pe gui
.arch i386
.import user32.dll MessageBoxA
.import kernel32.dll ExitProcess

.code
start:
  call Ask(question, title)
  call [ExitProcess](eax)

func Ask(text, caption)
begin
  call [MessageBoxA](0, text, caption, 0x24)
end

.data
question db 'Do you like functions with arguments?', 0
title db 'func_yesno', 0
