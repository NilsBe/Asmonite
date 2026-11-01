# Windows functions (imports)

The instruction info of Dismonite (F1) shows, for a row that uses an imported function
(`call [ExitProcess]`, the entry of the import table, ARM: `ldr r3, =ExitProcess`), the
section of the function: DLL, calling convention, parameters in the order of the C
declaration, result and a short explanation. Each section starts with `## ` and the names
(the A and W forms together).

## !calling

**Calling convention.** Almost all Windows functions are `stdcall`: the parameters are
put on the stack with `push` from right to left (the first parameter last), the function
removes them itself (`ret 16` for 4 parameters). The result is in `eax` (64 bit: `edx:eax`).
`eax`, `ecx` and `edx` may be changed, `ebx`, `esi`, `edi`, `ebp` and `esp` are the
same afterwards.

The C runtime (`msvcrt.dll`, `api-ms-win-crt-*.dll`) is `cdecl`: same order, but the
caller removes the parameters from the stack (`add esp, 8` after two parameters). Only
this way `printf` works with any number of parameters.

ARM (Thumb): the first four parameters in `r0` to `r3`, more on the stack, result in
`r0`; called with `blx` through the address from the import table.

All parameters are 4 bytes large (numbers, handles, pointers); `LARGE_INTEGER` and
`FILETIME` are 8 bytes. An error usually shows as result 0, `-1`
(`INVALID_HANDLE_VALUE`) or `FALSE`; `GetLastError` then says which one.

## !import

**Imported function** `{name}` from `{dll}`.

There is no section for this function in `help\en\winapi.md` yet.

## ExitProcess – end the process

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `ExitProcess(uExitCode)`

- uExitCode: UINT – the return value of the program (`%ERRORLEVEL%`, 0 = good)

**Result:** does not return

Ends the process with all threads; Windows closes open handles. The usual last call of an assembler program.

```asm
push 0
call [ExitProcess]
```

## GetStdHandle – get a standard handle

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetStdHandle(nStdHandle)`

- nStdHandle: DWORD – `-10` input (STD_INPUT_HANDLE), `-11` output (STD_OUTPUT_HANDLE), `-12` error output (STD_ERROR_HANDLE)

**Result:** eax = handle of the console or the redirection; `-1` on error, 0 without a console

The handle for `WriteFile`, `ReadFile`, `WriteConsoleA`. It need not be closed.

```asm
push -11
call [GetStdHandle]
mov [hOut], eax
```

## WriteFile – write to a file or the console

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `WriteFile(hFile, lpBuffer, nBytes, lpWritten, lpOverlapped)`

- hFile: HANDLE – file, pipe or console (`GetStdHandle`, `CreateFileA`)
- lpBuffer: LPCVOID – the bytes
- nBytes: DWORD – how many
- lpWritten: LPDWORD – address of a double word for the number written (may be 0 if lpOverlapped is set)
- lpOverlapped: LPOVERLAPPED – 0 (synchronous)

**Result:** eax = 1 on success, 0 on error (`GetLastError`)

Writes raw bytes, also text without conversion. For the console the OEM code page applies.

```asm
push 0
push written
push 13
push text
push [hOut]
call [WriteFile]
```

## ReadFile – read from a file or the console

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `ReadFile(hFile, lpBuffer, nBytes, lpRead, lpOverlapped)`

- hFile: HANDLE – file, pipe or console input
- lpBuffer: LPVOID – the buffer
- nBytes: DWORD – at most this many bytes
- lpRead: LPDWORD – the number read (0 at the end of the file)
- lpOverlapped: LPOVERLAPPED – 0 (synchronous)

**Result:** eax = 1 on success (also at the end of the file with 0 bytes), 0 on error

From the console it reads a line with `0x0D 0x0A` when the Enter key is pressed.

## CreateFileA, CreateFileW – open or create a file

kernel32.dll · stdcall · 7 parameters (28 bytes)

**Call:** `CreateFileA(lpFileName, dwAccess, dwShareMode, lpSecurity, dwCreation, dwFlags, hTemplate)`

- lpFileName: LPCSTR – path, 0-terminated
- dwAccess: DWORD – `0x80000000` GENERIC_READ, `0x40000000` GENERIC_WRITE (also both)
- dwShareMode: DWORD – `1` FILE_SHARE_READ, `2` FILE_SHARE_WRITE, 0 exclusive
- lpSecurity: LPSECURITY_ATTRIBUTES – 0
- dwCreation: DWORD – `1` CREATE_NEW, `2` CREATE_ALWAYS, `3` OPEN_EXISTING, `4` OPEN_ALWAYS, `5` TRUNCATE_EXISTING
- dwFlags: DWORD – `0x80` FILE_ATTRIBUTE_NORMAL
- hTemplate: HANDLE – 0

**Result:** eax = handle; `-1` (INVALID_HANDLE_VALUE) on error

Also opens devices like `CONOUT$` and `COM1`. Close with `CloseHandle`.

```asm
push 0
push 0x80
push 3
push 0
push 1
push 0x80000000
push name
call [CreateFileA]
```

## CloseHandle – close a handle

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `CloseHandle(hObject)`

- hObject: HANDLE – file, event, thread, process, ... (not the standard handles)

**Result:** eax = 1 on success, 0 on error

Frees the object; a file is written and released.

## GetFileSize – file size

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetFileSize(hFile, lpSizeHigh)`

- hFile: HANDLE – open file
- lpSizeHigh: LPDWORD – address for the upper 32 bits or 0

**Result:** eax = lower 32 bits of the size; `0xFFFFFFFF` on error (then check `GetLastError` if lpSizeHigh was set)

## SetFilePointer – set the file position

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `SetFilePointer(hFile, lDistance, lpDistanceHigh, dwMoveMethod)`

- hFile: HANDLE – open file
- lDistance: LONG – displacement in bytes (signed)
- lpDistanceHigh: PLONG – upper 32 bits or 0
- dwMoveMethod: DWORD – `0` FILE_BEGIN, `1` FILE_CURRENT, `2` FILE_END

**Result:** eax = new position (lower 32 bits); `0xFFFFFFFF` on error

## SetEndOfFile – cut the file here

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetEndOfFile(hFile)`

- hFile: HANDLE – open file with write access

**Result:** eax = 1 on success, 0 on error

Makes the current file position (`SetFilePointer`) the end of the file: shortens or extends.

## FlushFileBuffers – write buffers to the disk

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `FlushFileBuffers(hFile)`

- hFile: HANDLE – open file

**Result:** eax = 1 on success, 0 on error

## GetFileType – kind of a handle

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetFileType(hFile)`

- hFile: HANDLE – a handle from `CreateFileA` or `GetStdHandle`

**Result:** eax = `1` file (FILE_TYPE_DISK), `2` console or device (FILE_TYPE_CHAR), `3` pipe (FILE_TYPE_PIPE), `0` unknown or error

This is how a program recognizes whether its output is redirected into a file.

## GetFileAttributesA, GetFileAttributesW – read file attributes

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetFileAttributesA(lpFileName)`

- lpFileName: LPCSTR – path

**Result:** eax = attributes (`0x10` directory, `0x01` read-only, `0x02` hidden, `0x80` normal); `0xFFFFFFFF` if the file does not exist

The simplest test whether a file exists.

## DeleteFileA, DeleteFileW – delete a file

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `DeleteFileA(lpFileName)`

- lpFileName: LPCSTR – path

**Result:** eax = 1 on success, 0 on error

## GetFullPathNameA, GetFullPathNameW – full path

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `GetFullPathNameA(lpFileName, nBufferLength, lpBuffer, lpFilePart)`

- lpFileName: LPCSTR – a (relative) path
- nBufferLength: DWORD – size of the buffer in characters
- lpBuffer: LPSTR – the buffer for the full path
- lpFilePart: LPSTR* – address of a pointer that is set to the file name in the buffer, or 0

**Result:** eax = length of the path without 0; 0 on error; larger than nBufferLength: the buffer was too small

## GetTempPathA, GetTempPathW – folder for temporary files

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetTempPathA(nBufferLength, lpBuffer)`

- nBufferLength: DWORD – size of the buffer in characters
- lpBuffer: LPSTR – the buffer

**Result:** eax = length of the path (ends with `\`); 0 on error

## GetDiskFreeSpaceA, GetDiskFreeSpaceW – free space of a drive

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `GetDiskFreeSpaceA(lpRootPath, lpSectorsPerCluster, lpBytesPerSector, lpFreeClusters, lpTotalClusters)`

- lpRootPath: LPCSTR – `C:\` or 0 for the current drive
- lpSectorsPerCluster, lpBytesPerSector, lpFreeClusters, lpTotalClusters: LPDWORD – addresses for the four values

**Result:** eax = 1 on success, 0 on error

Free space = free clusters times sectors per cluster times bytes per sector.

## FindFirstFileA, FindFirstFileW – begin a file search

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `FindFirstFileA(lpFileName, lpFindFileData)`

- lpFileName: LPCSTR – pattern with `*` and `?`, e.g. `*.asm`
- lpFindFileData: LPWIN32_FIND_DATAA – structure of 320 bytes: attributes, three times, size (high, low), name from offset 44

**Result:** eax = search handle for `FindNextFileA` and `FindClose`; `-1` if nothing matches

## FindNextFileA, FindNextFileW – next file of the search

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `FindNextFileA(hFindFile, lpFindFileData)`

- hFindFile: HANDLE – from `FindFirstFileA`
- lpFindFileData: LPWIN32_FIND_DATAA – the structure as there

**Result:** eax = 1 found, 0 no more (`GetLastError` = 18, ERROR_NO_MORE_FILES)

## FindClose – end a file search

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `FindClose(hFindFile)`

- hFindFile: HANDLE – from `FindFirstFileA`

**Result:** eax = 1 on success, 0 on error

## WriteConsoleA, WriteConsoleW – text to the console

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `WriteConsoleA(hConsoleOutput, lpBuffer, nChars, lpWritten, lpReserved)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- lpBuffer: LPCVOID – the text
- nChars: DWORD – number of characters
- lpWritten: LPDWORD – the number written (may be 0)
- lpReserved: LPVOID – 0

**Result:** eax = 1 on success, 0 on error

Like `WriteFile`, but only for a real console: with a redirection into a file it fails.

## ReadConsoleA, ReadConsoleW – a line from the console

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `ReadConsoleA(hConsoleInput, lpBuffer, nChars, lpRead, pInputControl)`

- hConsoleInput: HANDLE – `GetStdHandle(-10)`
- lpBuffer: LPVOID – the buffer
- nChars: DWORD – at most this many characters
- lpRead: LPDWORD – the number read, including `0x0D 0x0A` at the end
- pInputControl: PCONSOLE_READCONSOLE_CONTROL – 0

**Result:** eax = 1 on success, 0 on error

## SetConsoleTextAttribute – colors of the console

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetConsoleTextAttribute(hConsoleOutput, wAttributes)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- wAttributes: WORD – foreground bits 0..3 (1 blue, 2 green, 4 red, 8 bright), background bits 4..7; `0x07` is light gray on black

**Result:** eax = 1 on success, 0 on error

## SetConsoleCursorPosition – set the cursor of the console

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetConsoleCursorPosition(hConsoleOutput, dwCursorPosition)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- dwCursorPosition: COORD – column in the lower 16 bits, row in the upper (a structure of 4 bytes, passed by value)

**Result:** eax = 1 on success, 0 on error

## GetConsoleScreenBufferInfo – size and cursor of the console

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetConsoleScreenBufferInfo(hConsoleOutput, lpInfo)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- lpInfo: PCONSOLE_SCREEN_BUFFER_INFO – structure of 22 bytes: size (columns, rows), cursor position, attributes, visible window, largest size

**Result:** eax = 1 on success, 0 on error

## SetConsoleTitleA, SetConsoleTitleW – title of the console window

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetConsoleTitleA(lpConsoleTitle)`

- lpConsoleTitle: LPCSTR – the title

**Result:** eax = 1 on success, 0 on error

## AllocConsole, FreeConsole – create and release a console

kernel32.dll · stdcall · no parameters

**Call:** `AllocConsole()`, `FreeConsole()`

**Result:** eax = 1 on success, 0 on error

A window program (subsystem GUI) gets a console window with `AllocConsole`; after that `GetStdHandle` and `WriteConsoleA` apply.

## GetCommandLineA, GetCommandLineW – the command line

kernel32.dll · stdcall · no parameters

**Call:** `GetCommandLineA()`

**Result:** eax = pointer to the whole command line, 0-terminated, with the program name first

The program must split the line itself (watch the quotation marks).

## GetEnvironmentVariableA, GetEnvironmentVariableW – read an environment variable

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `GetEnvironmentVariableA(lpName, lpBuffer, nSize)`

- lpName: LPCSTR – the name, e.g. `PATH`
- lpBuffer: LPSTR – the buffer
- nSize: DWORD – its size in characters

**Result:** eax = length of the value; 0 if there is no such variable; larger than nSize: needed size

## GetModuleHandleA, GetModuleHandleW – base address of a module

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetModuleHandleA(lpModuleName)`

- lpModuleName: LPCSTR – name of a loaded DLL or 0 for the program itself

**Result:** eax = HMODULE = the address at which the module lies in memory (`.imagebase`, usually `0x400000`); 0 if it is not loaded

Window programs need the handle for `RegisterClassExA` and `CreateWindowExA`.

## GetModuleFileNameA, GetModuleFileNameW – path of a module

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `GetModuleFileNameA(hModule, lpFilename, nSize)`

- hModule: HMODULE – 0 for the program itself
- lpFilename: LPSTR – the buffer
- nSize: DWORD – its size in characters

**Result:** eax = length of the path; 0 on error

## LoadLibraryA, LoadLibraryW – load a DLL

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `LoadLibraryA(lpLibFileName)`

- lpLibFileName: LPCSTR – file name of the DLL, with or without path

**Result:** eax = HMODULE of the DLL; 0 on error

Loads a DLL only at run time; its functions are fetched by `GetProcAddress`. Give it back with `FreeLibrary`.

## LoadLibraryExA, LoadLibraryExW – load a DLL with options

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `LoadLibraryExA(lpLibFileName, hFile, dwFlags)`

- lpLibFileName: LPCSTR – file name of the DLL
- hFile: HANDLE – 0 (reserved)
- dwFlags: DWORD – 0 like `LoadLibraryA`; `2` LOAD_LIBRARY_AS_DATAFILE (resources only, no code); `8` LOAD_WITH_ALTERED_SEARCH_PATH

**Result:** eax = HMODULE; 0 on error

## FreeLibrary – give a DLL back

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `FreeLibrary(hLibModule)`

- hLibModule: HMODULE – from `LoadLibraryA`

**Result:** eax = 1 on success, 0 on error

## GetProcAddress – address of a DLL function

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetProcAddress(hModule, lpProcName)`

- hModule: HMODULE – from `LoadLibraryA` or `GetModuleHandleA`
- lpProcName: LPCSTR – the name of the function (case matters) or an ordinal number in the lower 16 bits

**Result:** eax = address of the function, to call with `call eax`; 0 if there is none

This is how you call functions that are not in the import table.

```asm
push name
push [hDll]
call [GetProcAddress]
mov [pFunc], eax
```

## GetLastError – last error code

kernel32.dll · stdcall · no parameters

**Call:** `GetLastError()`

**Result:** eax = the error code of the last failed call in this thread: `2` file not found, `5` access denied, `6` invalid handle, `32` used by another process, `87` wrong parameter, `183` exists already

Read it right after the failed call; another call may overwrite it. `FormatMessageA` turns it into text.

## SetLastError – set the error code

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetLastError(dwErrCode)`

- dwErrCode: DWORD – the code

**Result:** none

## FormatMessageA, FormatMessageW – text for an error code

kernel32.dll · stdcall · 7 parameters (28 bytes)

**Call:** `FormatMessageA(dwFlags, lpSource, dwMessageId, dwLanguageId, lpBuffer, nSize, Arguments)`

- dwFlags: DWORD – `0x1000` FORMAT_MESSAGE_FROM_SYSTEM (Windows errors), plus `0x200` IGNORE_INSERTS; `0x100` ALLOCATE_BUFFER creates the buffer itself (then lpBuffer = address of a pointer, free it with `LocalFree`)
- lpSource: LPCVOID – 0 with FROM_SYSTEM
- dwMessageId: DWORD – the code from `GetLastError`
- dwLanguageId: DWORD – 0 (language of the user)
- lpBuffer: LPSTR – the buffer
- nSize: DWORD – size in characters
- Arguments: va_list* – 0

**Result:** eax = length of the text; 0 on error

## GetVersion – Windows version (old)

kernel32.dll · stdcall · no parameters

**Call:** `GetVersion()`

**Result:** eax = major version in the lowest byte, minor version in the second, build in the upper 16 bits (bit 31 = 0 on Windows NT)

Since Windows 8.1 it reports 6.2 for programs without a manifest. Delphi programs call it at startup.

## GetVersionExA, GetVersionExW – Windows version (structure)

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetVersionExA(lpVersionInfo)`

- lpVersionInfo: LPOSVERSIONINFOA – structure of 148 bytes, set the first double word to 148 before; afterwards major and minor version, build, platform (`2` = NT), service pack text

**Result:** eax = 1 on success, 0 on error

## GetNativeSystemInfo, GetSystemInfo – processor and memory

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetNativeSystemInfo(lpSystemInfo)`

- lpSystemInfo: LPSYSTEM_INFO – structure of 36 bytes: architecture (word at the start: `0` x86, `5` ARM, `9` x64, `12` ARM64), page size, lowest and highest address, number of processors

**Result:** none

`GetNativeSystemInfo` tells the real architecture also under emulation (x86 program on ARM64); `GetSystemInfo` the emulated one.

## GetStartupInfoA, GetStartupInfoW – startup information

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetStartupInfoA(lpStartupInfo)`

- lpStartupInfo: LPSTARTUPINFOA – structure of 68 bytes: window title, position, size, `wShowWindow` (offset 48), standard handles, as the parent process passed them

**Result:** none

Delphi programs call it at startup to determine `ShowWindow`.

## GetCurrentProcess, GetCurrentProcessId – the own process

kernel32.dll · stdcall · no parameters

**Call:** `GetCurrentProcess()`, `GetCurrentProcessId()`

**Result:** eax = pseudo handle `-1` for the own process (do not close) or the process number (PID)

## GetCurrentThread, GetCurrentThreadId – the own thread

kernel32.dll · stdcall · no parameters

**Call:** `GetCurrentThread()`, `GetCurrentThreadId()`

**Result:** eax = pseudo handle `-2` for the own thread or the thread number (TID)

## TerminateProcess – abort a process

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `TerminateProcess(hProcess, uExitCode)`

- hProcess: HANDLE – the process (`GetCurrentProcess` for the own one)
- uExitCode: UINT – the return value

**Result:** eax = 1 on success, 0 on error (does not return for the own process)

Harder than `ExitProcess`: no DLL is notified.

## CreateProcessA, CreateProcessW – start a program

kernel32.dll · stdcall · 10 parameters (40 bytes)

**Call:** `CreateProcessA(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation)`

- lpApplicationName: LPCSTR – path of the EXE or 0 (then it stands at the start of lpCommandLine)
- lpCommandLine: LPSTR – the command line (a changeable buffer)
- lpProcessAttributes, lpThreadAttributes: LPSECURITY_ATTRIBUTES – 0
- bInheritHandles: BOOL – 1: the new process inherits the handles
- dwCreationFlags: DWORD – 0; `0x10` CREATE_NEW_CONSOLE; `0x8000000` CREATE_NO_WINDOW
- lpEnvironment: LPVOID – 0 (the own environment)
- lpCurrentDirectory: LPCSTR – 0 (the own directory)
- lpStartupInfo: LPSTARTUPINFOA – structure of 68 bytes, the first double word = 68, the rest 0
- lpProcessInformation: LPPROCESS_INFORMATION – 16 bytes: process handle, thread handle, PID, TID

**Result:** eax = 1 on success, 0 on error

Close both handles with `CloseHandle`; `WaitForSingleObject` on the process handle waits for the end.

## Sleep – wait

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `Sleep(dwMilliseconds)`

- dwMilliseconds: DWORD – waiting time in milliseconds; 0 only gives up the processor

**Result:** none

## GetTickCount – milliseconds since Windows started

kernel32.dll · stdcall · no parameters

**Call:** `GetTickCount()`

**Result:** eax = milliseconds since system start (wraps around after 49.7 days)

For time measurements the difference of two calls; the resolution is about 16 ms.

## QueryPerformanceCounter, QueryPerformanceFrequency – fine counter

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `QueryPerformanceCounter(lpCount)`, `QueryPerformanceFrequency(lpFrequency)`

- lpCount, lpFrequency: LARGE_INTEGER* – address of 8 bytes for the counter value or the steps per second

**Result:** eax = 1 on success

Time in seconds = difference of the counter values divided by the frequency.

## GetLocalTime, GetSystemTime – date and time

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetLocalTime(lpSystemTime)`

- lpSystemTime: LPSYSTEMTIME – structure of 16 bytes, one word each: year, month, weekday (0 = Sunday), day, hour, minute, second, millisecond

**Result:** none

`GetLocalTime` in the time zone of the computer, `GetSystemTime` in UTC.

## GetDateFormatA, GetDateFormatW – date as text

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `GetDateFormatA(Locale, dwFlags, lpDate, lpFormat, lpDateStr, cchDate)`

- Locale: LCID – `0x400` LOCALE_USER_DEFAULT
- dwFlags: DWORD – `1` DATE_SHORTDATE, `2` DATE_LONGDATE; 0 with an own format
- lpDate: SYSTEMTIME* – the date or 0 for today
- lpFormat: LPCSTR – pattern like `dd.MM.yyyy` or 0
- lpDateStr: LPSTR – the buffer
- cchDate: int – its size in characters (0: only determine the needed size)

**Result:** eax = number of characters including 0; 0 on error

## GetThreadLocale – language of the thread

kernel32.dll · stdcall · no parameters

**Call:** `GetThreadLocale()`

**Result:** eax = LCID (`0x407` German, `0x409` English USA)

## GetLocaleInfoA, GetLocaleInfoW – a setting of a language

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `GetLocaleInfoA(Locale, LCType, lpLCData, cchData)`

- Locale: LCID – from `GetThreadLocale` or `0x400`
- LCType: LCTYPE – what: `0x0E` LOCALE_SDECIMAL (decimal separator), `0x0F` LOCALE_STHOUSAND, `0x1D` LOCALE_SDATE, `0x1E` LOCALE_STIME, `0x1F` LOCALE_SSHORTDATE, `0x20` LOCALE_SLONGDATE
- lpLCData: LPSTR – the buffer
- cchData: int – its size in characters

**Result:** eax = number of characters including 0; 0 on error

This is how Delphi reads the formats for `DateToStr` and `FloatToStr`.

## EnumCalendarInfoA, EnumCalendarInfoW – list calendar names

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `EnumCalendarInfoA(lpCalInfoEnumProc, Locale, Calendar, CalType)`

- lpCalInfoEnumProc: CALINFO_ENUMPROCA – an own function that is called once per entry with the text (stdcall, 1 parameter; result 1 = go on)
- Locale: LCID – the language
- Calendar: CALID – `1` CAL_GREGORIAN, `0xFFFFFFFF` all
- CalType: CALTYPE – `0x15` CAL_SMONTHNAME1 (month names from January), `0x07` CAL_SDAYNAME1 (weekdays), ...

**Result:** eax = 1 on success, 0 on error

This is how Delphi fills the month and day names.

## GetACP, GetOEMCP – code page of Windows and the console

kernel32.dll · stdcall · no parameters

**Call:** `GetACP()`, `GetOEMCP()`

**Result:** eax = code page (`1252` Western Europe Windows, `850` or `437` DOS/console, `65001` UTF-8)

## GetCPInfo – properties of a code page

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetCPInfo(CodePage, lpCPInfo)`

- CodePage: UINT – the code page (`0` CP_ACP = the one of Windows)
- lpCPInfo: LPCPINFO – structure of 20 bytes: largest character length in bytes, replacement character, lead-byte ranges

**Result:** eax = 1 on success, 0 on error

## MultiByteToWideChar – convert text to UTF-16

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `MultiByteToWideChar(CodePage, dwFlags, lpMultiByteStr, cbMultiByte, lpWideCharStr, cchWideChar)`

- CodePage: UINT – code page of the source text (`0` CP_ACP, `65001` CP_UTF8)
- dwFlags: DWORD – 0 or `1` MB_PRECOMPOSED
- lpMultiByteStr: LPCSTR – the source text
- cbMultiByte: int – its length in bytes; `-1`: up to the 0 including the 0
- lpWideCharStr: LPWSTR – the buffer for UTF-16 (2 bytes each)
- cchWideChar: int – its size in characters; 0: only determine the needed size

**Result:** eax = number of characters written (or needed); 0 on error

## WideCharToMultiByte – convert UTF-16 to text

kernel32.dll · stdcall · 8 parameters (32 bytes)

**Call:** `WideCharToMultiByte(CodePage, dwFlags, lpWideCharStr, cchWideChar, lpMultiByteStr, cbMultiByte, lpDefaultChar, lpUsedDefaultChar)`

- CodePage: UINT – code page of the target
- dwFlags: DWORD – 0
- lpWideCharStr: LPCWSTR – the UTF-16 text
- cchWideChar: int – its length in characters; `-1`: up to the 0 including the 0
- lpMultiByteStr: LPSTR – the buffer
- cbMultiByte: int – its size in bytes; 0: only determine the needed size
- lpDefaultChar: LPCSTR – replacement for characters that cannot be shown, or 0 (`?`)
- lpUsedDefaultChar: LPBOOL – address of a flag whether the replacement was needed, or 0

**Result:** eax = number of bytes written (or needed); 0 on error

## CompareStringA, CompareStringW – compare texts by language

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `CompareStringA(Locale, dwCmpFlags, lpString1, cchCount1, lpString2, cchCount2)`

- Locale: LCID – the language (`0x400` LOCALE_USER_DEFAULT)
- dwCmpFlags: DWORD – 0; `1` NORM_IGNORECASE
- lpString1, lpString2: LPCSTR – the texts
- cchCount1, cchCount2: int – their lengths; `-1`: up to the 0

**Result:** eax = `1` less (CSTR_LESS_THAN), `2` equal, `3` greater; 0 on error

Sorts like a dictionary (umlauts with their base letters), unlike a byte comparison.

## GetStringTypeExA, GetStringTypeExW – character classes of a text

kernel32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `GetStringTypeExA(Locale, dwInfoType, lpSrcStr, cchSrc, lpCharType)`

- Locale: LCID – the language
- dwInfoType: DWORD – `1` CT_CTYPE1 (letter, digit, space, ...)
- lpSrcStr: LPCSTR – the text
- cchSrc: int – its length; `-1`: up to the 0
- lpCharType: LPWORD – one word per character: bit 0 upper case (C1_UPPER), bit 1 lower case, bit 2 digit, bit 3 white space, bit 4 punctuation, bit 8 letter (C1_ALPHA)

**Result:** eax = 1 on success, 0 on error

This is how Delphi builds its tables for `UpperCase` and `IsCharAlpha`.

## lstrlenA, lstrlenW – length of a text

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `lstrlenA(lpString)`

- lpString: LPCSTR – 0-terminated text (0 allowed: result 0)

**Result:** eax = number of characters without the 0

Like `strlen`, but without the C runtime.

## lstrcpyA, lstrcpyW – copy a text

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `lstrcpyA(lpString1, lpString2)`

- lpString1: LPSTR – the destination (large enough)
- lpString2: LPCSTR – the source, 0-terminated

**Result:** eax = lpString1; 0 on error

## lstrcpynA, lstrcpynW – copy a text, limited

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `lstrcpynA(lpString1, lpString2, iMaxLength)`

- lpString1: LPSTR – the destination
- lpString2: LPCSTR – the source
- iMaxLength: int – size of the destination in characters including the 0

**Result:** eax = lpString1; 0 on error

Copies at most iMaxLength - 1 characters and always writes a 0 at the end.

## lstrcatA, lstrcatW – append a text

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `lstrcatA(lpString1, lpString2)`

- lpString1: LPSTR – the text to which is appended (large enough)
- lpString2: LPCSTR – what is appended

**Result:** eax = lpString1; 0 on error

## lstrcmpA, lstrcmpW, lstrcmpiA, lstrcmpiW – compare texts

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `lstrcmpA(lpString1, lpString2)`

- lpString1, lpString2: LPCSTR – the texts

**Result:** eax = negative, 0 or positive if the first is smaller, equal or larger; `lstrcmpi` ignoring case

Compares by the language of the user like `CompareStringA`.

## HeapAlloc – memory from the heap

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `HeapAlloc(hHeap, dwFlags, dwBytes)`

- hHeap: HANDLE – from `GetProcessHeap` or `HeapCreate`
- dwFlags: DWORD – 0; `8` HEAP_ZERO_MEMORY (filled with zeros)
- dwBytes: SIZE_T – number of bytes

**Result:** eax = address of the block; 0 if no memory is left

Free with `HeapFree`. The block is aligned to 8 bytes.

```asm
push 100
push 8
push [hHeap]
call [HeapAlloc]
```

## HeapReAlloc – enlarge or shrink a heap block

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `HeapReAlloc(hHeap, dwFlags, lpMem, dwBytes)`

- hHeap: HANDLE – the heap
- dwFlags: DWORD – 0; `8` HEAP_ZERO_MEMORY for the new part; `0x10` HEAP_REALLOC_IN_PLACE_ONLY
- lpMem: LPVOID – the block from `HeapAlloc`
- dwBytes: SIZE_T – the new size

**Result:** eax = address of the block (may be another one, the content is copied); 0 on error

## HeapFree – free a heap block

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `HeapFree(hHeap, dwFlags, lpMem)`

- hHeap: HANDLE – the heap the block came from
- dwFlags: DWORD – 0
- lpMem: LPVOID – the block

**Result:** eax = 1 on success, 0 on error

## GetProcessHeap – the default heap

kernel32.dll · stdcall · no parameters

**Call:** `GetProcessHeap()`

**Result:** eax = handle of the heap that every process has from the start (do not close)

## HeapCreate, HeapDestroy – an own heap

kernel32.dll · stdcall · 3 parameters (12 bytes) / 1 parameter

**Call:** `HeapCreate(flOptions, dwInitialSize, dwMaximumSize)`, `HeapDestroy(hHeap)`

- flOptions: DWORD – 0; `1` HEAP_NO_SERIALIZE (one thread only); `4` HEAP_GENERATE_EXCEPTIONS
- dwInitialSize: SIZE_T – initial size in bytes (0: one page)
- dwMaximumSize: SIZE_T – maximum size; 0: grows as needed

**Result:** eax = handle of the heap; 0 on error. `HeapDestroy` frees it with all blocks.

## LocalAlloc, GlobalAlloc – memory (old)

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `LocalAlloc(uFlags, uBytes)`

- uFlags: UINT – `0` LMEM_FIXED (address), `0x40` LMEM_ZEROINIT (with zeros); `GlobalAlloc`: `0x42` GMEM_MOVEABLE|ZEROINIT for the clipboard
- uBytes: SIZE_T – number of bytes

**Result:** eax = address (fixed) or handle (moveable); 0 on error

From 16-bit times; today the same heap as `HeapAlloc`. Free with `LocalFree` / `GlobalFree`.

## LocalFree, GlobalFree – free memory (old)

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `LocalFree(hMem)`

- hMem: HLOCAL – from `LocalAlloc` or from Windows (e.g. `FormatMessageA` with ALLOCATE_BUFFER, `CommandLineToArgvW`)

**Result:** eax = 0 on success, else hMem

## VirtualAlloc – reserve and commit pages

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)`

- lpAddress: LPVOID – wanted address or 0 (Windows chooses)
- dwSize: SIZE_T – number of bytes (rounded up to 4 KB)
- flAllocationType: DWORD – `0x1000` MEM_COMMIT, `0x2000` MEM_RESERVE (usually `0x3000` both)
- flProtect: DWORD – `4` PAGE_READWRITE, `0x40` PAGE_EXECUTE_READWRITE, `2` PAGE_READONLY

**Result:** eax = start address (filled with zeros); 0 on error

For large blocks and for memory in which code is to be executed. Free with `VirtualFree`.

## VirtualFree – free pages

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `VirtualFree(lpAddress, dwSize, dwFreeType)`

- lpAddress: LPVOID – from `VirtualAlloc`
- dwSize: SIZE_T – 0 with MEM_RELEASE
- dwFreeType: DWORD – `0x8000` MEM_RELEASE (everything back), `0x4000` MEM_DECOMMIT (only the content)

**Result:** eax = 1 on success, 0 on error

## VirtualProtect – change page protection

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect)`

- lpAddress: LPVOID – start of the area
- dwSize: SIZE_T – its size
- flNewProtect: DWORD – `4` PAGE_READWRITE, `0x20` PAGE_EXECUTE_READ, `0x40` PAGE_EXECUTE_READWRITE
- lpflOldProtect: PDWORD – address for the old protection (required)

**Result:** eax = 1 on success, 0 on error

Needed to write code at run time or to make data executable.

## VirtualQuery – state of a memory area

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `VirtualQuery(lpAddress, lpBuffer, dwLength)`

- lpAddress: LPCVOID – an address
- lpBuffer: PMEMORY_BASIC_INFORMATION – structure of 28 bytes: base address, base of the reservation, its protection, size of the area, state (`0x1000` MEM_COMMIT, `0x2000` MEM_RESERVE, `0x10000` MEM_FREE), protection, type (`0x1000000` MEM_IMAGE)
- dwLength: SIZE_T – 28

**Result:** eax = number of bytes written; 0 on error

This is how the runtime checks whether a pointer points to readable memory.

## IsBadReadPtr, IsBadWritePtr – check a pointer (obsolete)

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `IsBadReadPtr(lp, ucb)`

- lp: const void* – the address
- ucb: UINT_PTR – number of bytes

**Result:** eax = 0 if the area is readable (writable), else 1

## CreateThread – start a thread

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `CreateThread(lpThreadAttributes, dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId)`

- lpThreadAttributes: LPSECURITY_ATTRIBUTES – 0
- dwStackSize: SIZE_T – 0 (default, 1 MB)
- lpStartAddress: LPTHREAD_START_ROUTINE – the function of the thread (stdcall, 1 parameter, result = exit code)
- lpParameter: LPVOID – its parameter
- dwCreationFlags: DWORD – 0 immediately; `4` CREATE_SUSPENDED (only `ResumeThread` starts it)
- lpThreadId: LPDWORD – address for the thread number or 0

**Result:** eax = handle of the thread (close with `CloseHandle`); 0 on error

## ExitThread – end the own thread

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `ExitThread(dwExitCode)`

- dwExitCode: DWORD – the exit code of the thread

**Result:** does not return

If the last thread ends, the process ends. A `ret` from the thread function does the same.

## WaitForSingleObject – wait for an object

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `WaitForSingleObject(hHandle, dwMilliseconds)`

- hHandle: HANDLE – thread, process, event, mutex, semaphore
- dwMilliseconds: DWORD – waiting time; `0xFFFFFFFF` INFINITE

**Result:** eax = `0` WAIT_OBJECT_0 (signaled: thread or process ended, event set), `0x102` WAIT_TIMEOUT, `0xFFFFFFFF` WAIT_FAILED

## CreateEventA, CreateEventW – create an event

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `CreateEventA(lpEventAttributes, bManualReset, bInitialState, lpName)`

- lpEventAttributes: LPSECURITY_ATTRIBUTES – 0
- bManualReset: BOOL – 1: stays set until `ResetEvent`; 0: resets itself after one wait
- bInitialState: BOOL – 1: set at the start
- lpName: LPCSTR – name (for other processes) or 0

**Result:** eax = handle; 0 on error

## SetEvent, ResetEvent – set and reset an event

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetEvent(hEvent)`, `ResetEvent(hEvent)`

- hEvent: HANDLE – from `CreateEventA`

**Result:** eax = 1 on success, 0 on error

`SetEvent` wakes the threads that wait for it with `WaitForSingleObject`.

## InitializeCriticalSection, DeleteCriticalSection – create and delete a lock

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `InitializeCriticalSection(lpCriticalSection)`, `DeleteCriticalSection(lpCriticalSection)`

- lpCriticalSection: LPCRITICAL_SECTION – address of 24 bytes in the own memory

**Result:** none

A critical section lets only one thread at a time into the area between `EnterCriticalSection` and `LeaveCriticalSection`.

## EnterCriticalSection, LeaveCriticalSection – take and give a lock

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `EnterCriticalSection(lpCriticalSection)`, `LeaveCriticalSection(lpCriticalSection)`

- lpCriticalSection: LPCRITICAL_SECTION – the section from `InitializeCriticalSection`

**Result:** none

`Enter` waits until no other thread holds the section; the same thread may take it several times and must give it as often.

## InterlockedIncrement, InterlockedDecrement – change a counter atomically

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `InterlockedIncrement(lpAddend)`, `InterlockedDecrement(lpAddend)`

- lpAddend: LONG* – address of the counter (4 bytes, aligned)

**Result:** eax = the new value

Increases or decreases by 1 without another thread getting in between (like `lock inc`). Delphi counts the references of strings and interfaces this way.

## InterlockedExchange, InterlockedCompareExchange – exchange a value atomically

kernel32.dll · stdcall · 2 parameters (8 bytes) / 3 parameters

**Call:** `InterlockedExchange(Target, Value)`, `InterlockedCompareExchange(Destination, Exchange, Comparand)`

- Target, Destination: LONG* – address of the value
- Value, Exchange: LONG – the new value
- Comparand: LONG – exchange only if the old value equals this

**Result:** eax = the old value

## TlsAlloc, TlsFree – create space per thread

kernel32.dll · stdcall · no parameters / 1 parameter

**Call:** `TlsAlloc()`, `TlsFree(dwTlsIndex)`

**Result:** eax = index of a double word that every thread has for itself; `0xFFFFFFFF` on error

## TlsGetValue, TlsSetValue – read and set a value per thread

kernel32.dll · stdcall · 1 parameter (4 bytes) / 2 parameters

**Call:** `TlsGetValue(dwTlsIndex)`, `TlsSetValue(dwTlsIndex, lpTlsValue)`

- dwTlsIndex: DWORD – from `TlsAlloc`
- lpTlsValue: LPVOID – the value for the current thread

**Result:** `TlsGetValue`: eax = the value of this thread (0 if never set); `TlsSetValue`: 1 on success

Delphi keeps `threadvar` variables this way.

## RaiseException – raise an exception

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments, lpArguments)`

- dwExceptionCode: DWORD – own code (Delphi: `0x0EEDFADE`)
- dwExceptionFlags: DWORD – 0 continuable; `1` EXCEPTION_NONCONTINUABLE
- nNumberOfArguments: DWORD – number of values in lpArguments (at most 15)
- lpArguments: const ULONG_PTR* – additional values (Delphi: address and object of the exception)

**Result:** returns only if a handler continues the execution

The exception runs through the SEH chain (`fs:[0]`); this is how Delphi throws `raise`.

## RtlUnwind – unwind the SEH chain

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `RtlUnwind(TargetFrame, TargetIp, ExceptionRecord, ReturnValue)`

- TargetFrame: PVOID – up to which handler (frame) is unwound
- TargetIp: PVOID – where it goes on (unused on x86)
- ExceptionRecord: PEXCEPTION_RECORD – the exception or 0
- ReturnValue: PVOID – value for `eax`

**Result:** none

Calls the handlers of the inner frames with `EXCEPTION_UNWINDING` (`finally` blocks) and removes them from the chain. Part of the Delphi exception handling.

## SetUnhandledExceptionFilter – last exception filter

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetUnhandledExceptionFilter(lpTopLevelExceptionFilter)`

- lpTopLevelExceptionFilter: LPTOP_LEVEL_EXCEPTION_FILTER – own function (stdcall, 1 parameter: pointer to EXCEPTION_POINTERS; result `1` EXCEPTION_EXECUTE_HANDLER ends, `0` shows the Windows dialog, `-1` continues) or 0

**Result:** eax = the previous filter

Called when no handler takes an exception; the C runtime sets it at startup.

## UnhandledExceptionFilter – default handling of an exception

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `UnhandledExceptionFilter(ExceptionInfo)`

- ExceptionInfo: struct _EXCEPTION_POINTERS* – exception and register contents

**Result:** eax = `1` EXCEPTION_EXECUTE_HANDLER or `0` EXCEPTION_CONTINUE_SEARCH (a debugger takes over)

Shows the dialog "The program has stopped working" or hands over to the debugger.

## IsDebuggerPresent – is a debugger running?

kernel32.dll · stdcall · no parameters

**Call:** `IsDebuggerPresent()`

**Result:** eax = 1 if a debugger (also Dismonite) holds the process, else 0

## OutputDebugStringA, OutputDebugStringW – text to the debugger

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `OutputDebugStringA(lpOutputString)`

- lpOutputString: LPCSTR – the text

**Result:** none

The debugger shows the text in its output; without a debugger nothing happens.

## DebugBreak – trigger a breakpoint

kernel32.dll · stdcall · no parameters

**Call:** `DebugBreak()`

**Result:** none

Like `int 3`: the debugger stops; without a debugger it is an exception.

## MessageBoxA, MessageBoxW – message window

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `MessageBoxA(hWnd, lpText, lpCaption, uType)`

- hWnd: HWND – owner window or 0
- lpText: LPCSTR – the text (line break with `0x0A`)
- lpCaption: LPCSTR – the title or 0 ("Error")
- uType: UINT – buttons `0` MB_OK, `1` MB_OKCANCEL, `3` MB_YESNOCANCEL, `4` MB_YESNO; icon `0x10` MB_ICONERROR, `0x20` MB_ICONQUESTION, `0x30` MB_ICONWARNING, `0x40` MB_ICONINFORMATION

**Result:** eax = button pressed: `1` IDOK, `2` IDCANCEL, `6` IDYES, `7` IDNO; 0 on error

The simplest window: waits until the user clicks.

```asm
push 0            ; uType
push title        ; lpCaption
push text         ; lpText
push 0            ; hWnd
call [MessageBoxA]
```

## MessageBeep – system sound

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `MessageBeep(uType)`

- uType: UINT – `0xFFFFFFFF` simple beep; `0` MB_OK, `0x10` MB_ICONERROR, ... as for `MessageBoxA`

**Result:** eax = 1 on success

## RegisterClassA, RegisterClassW – register a window class

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `RegisterClassA(lpWndClass)`

- lpWndClass: const WNDCLASSA* – structure of 40 bytes: style, lpfnWndProc (the window function), cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName

**Result:** eax = atom of the class (16 bit); 0 on error

A class describes how windows look and which function gets their messages. After it `CreateWindowExA` with the class name.

## RegisterClassExA, RegisterClassExW – register a window class (with small icon)

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `RegisterClassExA(lpWndClassEx)`

- lpWndClassEx: const WNDCLASSEXA* – structure of 48 bytes: cbSize (= 48), then as WNDCLASSA, finally hIconSm

**Result:** eax = atom of the class; 0 on error

## CreateWindowExA, CreateWindowExW – create a window

user32.dll · stdcall · 12 parameters (48 bytes)

**Call:** `CreateWindowExA(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)`

- dwExStyle: DWORD – 0 or `0x200` WS_EX_CLIENTEDGE, `0x8` WS_EX_TOPMOST
- lpClassName: LPCSTR – own class (`RegisterClassExA`) or one of Windows: `BUTTON`, `EDIT`, `STATIC`, `LISTBOX`, `COMBOBOX`
- lpWindowName: LPCSTR – title or text of the control
- dwStyle: DWORD – `0xCF0000` WS_OVERLAPPEDWINDOW, `0x10000000` WS_VISIBLE, `0x40000000` WS_CHILD, `0x800000` WS_BORDER; button: `1` BS_DEFPUSHBUTTON; edit: `4` ES_MULTILINE
- X, Y, nWidth, nHeight: int – position and size; `0x80000000` CW_USEDEFAULT
- hWndParent: HWND – parent window (required with WS_CHILD) or 0
- hMenu: HMENU – menu, with WS_CHILD the number of the control (ID)
- hInstance: HINSTANCE – `GetModuleHandleA(0)`
- lpParam: LPVOID – 0 (arrives in WM_CREATE)

**Result:** eax = HWND; 0 on error

Sends WM_CREATE to the window function before it returns.

## DestroyWindow – destroy a window

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `DestroyWindow(hWnd)`

- hWnd: HWND – the window (with all child windows)

**Result:** eax = 1 on success, 0 on error

Sends WM_DESTROY; there the main window usually calls `PostQuitMessage`.

## ShowWindow – show or hide a window

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `ShowWindow(hWnd, nCmdShow)`

- hWnd: HWND – the window
- nCmdShow: int – `0` SW_HIDE, `1` SW_SHOWNORMAL, `3` SW_MAXIMIZE, `5` SW_SHOW, `6` SW_MINIMIZE

**Result:** eax = 1 if the window was visible before, else 0

## UpdateWindow – paint at once

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `UpdateWindow(hWnd)`

- hWnd: HWND – the window

**Result:** eax = 1 on success

Sends WM_PAINT at once if a part of the window is invalid (`InvalidateRect`).

## InvalidateRect – have an area repainted

user32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `InvalidateRect(hWnd, lpRect, bErase)`

- hWnd: HWND – the window
- lpRect: const RECT* – rectangle (left, top, right, bottom) or 0 for everything
- bErase: BOOL – 1: erase the background first

**Result:** eax = 1 on success

The window gets WM_PAINT in the next pass of the message loop.

## GetMessageA, GetMessageW – get the next message

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `GetMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax)`

- lpMsg: LPMSG – structure of 28 bytes: hwnd, message, wParam, lParam, time, pt (x, y)
- hWnd: HWND – only messages of this window or 0 for all of the thread
- wMsgFilterMin, wMsgFilterMax: UINT – 0, 0 (all)

**Result:** eax = 0 on WM_QUIT (the loop ends), `-1` on error, else 1

Waits until a message is there. The core of every message loop:

```asm
L: push 0
   push 0
   push 0
   push msg
   call [GetMessageA]
   test eax, eax
   jz done
   ; Translate, Dispatch
   jmp L
```

## PeekMessageA, PeekMessageW – look for a message without waiting

user32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `PeekMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg)`

- lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax: as for `GetMessageA`
- wRemoveMsg: UINT – `1` PM_REMOVE (take it from the queue), `0` PM_NOREMOVE

**Result:** eax = 1 if a message is there, else 0

For programs that go on calculating between the messages (games).

## TranslateMessage – translate a key press into characters

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `TranslateMessage(lpMsg)`

- lpMsg: const MSG* – the message from `GetMessageA`

**Result:** eax = 1 if a character message was produced

Makes a WM_CHAR with the character of the keyboard from WM_KEYDOWN. Stands before `DispatchMessageA`.

## DispatchMessageA, DispatchMessageW – message to the window function

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `DispatchMessageA(lpMsg)`

- lpMsg: const MSG* – the message

**Result:** eax = what the window function returned

Calls the window function of the window the message goes to (`lpfnWndProc` of the class).

## DefWindowProcA, DefWindowProcW – default handling of a message

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `DefWindowProcA(hWnd, Msg, wParam, lParam)`

- hWnd, Msg, wParam, lParam: the four parameters of the window function

**Result:** eax = the result of the default handling

The own window function calls it for all messages it does not handle itself (frame, moving, closing, resizing).

## PostQuitMessage – end the message loop

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `PostQuitMessage(nExitCode)`

- nExitCode: int – the value that `GetMessageA` delivers in wParam of WM_QUIT

**Result:** none

Puts WM_QUIT in the queue; `GetMessageA` then returns 0. Usual in WM_DESTROY.

## SendMessageA, SendMessageW – send a message and wait

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `SendMessageA(hWnd, Msg, wParam, lParam)`

- hWnd: HWND – the target window
- Msg: UINT – the message: `0x0C` WM_SETTEXT, `0x0D` WM_GETTEXT, `0x0E` WM_GETTEXTLENGTH, `0x30` WM_SETFONT, `0x10` WM_CLOSE, controls from `0x100` (e.g. `0x180` LB_ADDSTRING, `0xB1` EM_SETSEL)
- wParam, lParam: WPARAM, LPARAM – depending on the message

**Result:** eax = the answer of the window function

Calls the window function directly and returns with its result. `PostMessageA` only puts the message in the queue.

## PostMessageA, PostMessageW – put a message in the queue

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `PostMessageA(hWnd, Msg, wParam, lParam)`

- hWnd, Msg, wParam, lParam: as for `SendMessageA`

**Result:** eax = 1 on success, 0 on error

Returns at once; the message is fetched by the loop of the target thread.

## GetClientRect – inner size of a window

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetClientRect(hWnd, lpRect)`

- hWnd: HWND – the window
- lpRect: LPRECT – structure of 16 bytes: left, top (always 0), right, bottom = width, height

**Result:** eax = 1 on success

## GetWindowRect – position of a window on the screen

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetWindowRect(hWnd, lpRect)`

- hWnd: HWND – the window
- lpRect: LPRECT – left, top, right, bottom in screen coordinates, with frame

**Result:** eax = 1 on success

## MoveWindow – move and resize a window

user32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `MoveWindow(hWnd, X, Y, nWidth, nHeight, bRepaint)`

- hWnd: HWND – the window
- X, Y: int – new position (child windows: in the parent window)
- nWidth, nHeight: int – new size
- bRepaint: BOOL – 1: repaint

**Result:** eax = 1 on success

Typical in WM_SIZE to adapt the controls to the window size.

## SetWindowPos – position, size and order of a window

user32.dll · stdcall · 7 parameters (28 bytes)

**Call:** `SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags)`

- hWnd: HWND – the window
- hWndInsertAfter: HWND – where in the Z order: `0` HWND_TOP, `-1` HWND_TOPMOST, `1` HWND_BOTTOM
- X, Y, cx, cy: int – position and size
- uFlags: UINT – `1` SWP_NOSIZE, `2` SWP_NOMOVE, `4` SWP_NOZORDER, `0x40` SWP_SHOWWINDOW

**Result:** eax = 1 on success

## SetWindowTextA, SetWindowTextW – set title or text

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetWindowTextA(hWnd, lpString)`

- hWnd: HWND – window or control (edit, static, button)
- lpString: LPCSTR – the new text

**Result:** eax = 1 on success

The same as `SendMessageA` with WM_SETTEXT.

## GetWindowTextA, GetWindowTextW – read title or text

user32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `GetWindowTextA(hWnd, lpString, nMaxCount)`

- hWnd: HWND – window or control
- lpString: LPSTR – the buffer
- nMaxCount: int – its size in characters including 0

**Result:** eax = number of characters copied; 0 for an empty text or on error

This is how you read what was typed into an edit field.

## GetWindowTextLengthA, GetWindowTextLengthW – length of the text

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetWindowTextLengthA(hWnd)`

- hWnd: HWND – window or control

**Result:** eax = number of characters without 0

This determines the buffer size for `GetWindowTextA` (plus 1).

## SetFocus – direct keyboard input to a window

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetFocus(hWnd)`

- hWnd: HWND – the window that gets the keyboard (e.g. an edit field)

**Result:** eax = the window that had the focus before; 0 on error

## GetDlgItem – control of a dialog

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetDlgItem(hDlg, nIDDlgItem)`

- hDlg: HWND – the dialog or the parent window
- nIDDlgItem: int – the number of the control (hMenu with `CreateWindowExA`)

**Result:** eax = HWND of the control; 0 if there is none

## DialogBoxParamA, DialogBoxParamW – show a dialog from the resource

user32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `DialogBoxParamA(hInstance, lpTemplateName, hWndParent, lpDialogFunc, dwInitParam)`

- hInstance: HINSTANCE – the module with the resource
- lpTemplateName: LPCSTR – name or number of the dialog template (number in the lower 16 bits)
- hWndParent: HWND – owner or 0
- lpDialogFunc: DLGPROC – the dialog function (like a window function; result 1 = handled)
- dwInitParam: LPARAM – value for WM_INITDIALOG

**Result:** eax = the value of `EndDialog`; `-1` on error

Modal: returns only when the dialog was closed with `EndDialog`.

## EndDialog – close a modal dialog

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `EndDialog(hDlg, nResult)`

- hDlg: HWND – the dialog
- nResult: INT_PTR – the value that `DialogBoxParamA` returns

**Result:** eax = 1 on success

## LoadCursorA, LoadCursorW – load a mouse cursor

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `LoadCursorA(hInstance, lpCursorName)`

- hInstance: HINSTANCE – 0 for the cursors of Windows
- lpCursorName: LPCSTR – `32512` IDC_ARROW, `32513` IDC_IBEAM, `32514` IDC_WAIT, `32515` IDC_CROSS, `32649` IDC_HAND (as a number)

**Result:** eax = HCURSOR; 0 on error

For `hCursor` of the window class.

## LoadIconA, LoadIconW – load an icon

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `LoadIconA(hInstance, lpIconName)`

- hInstance: HINSTANCE – 0 for the icons of Windows, else the module
- lpIconName: LPCSTR – `32512` IDI_APPLICATION, `32513` IDI_ERROR, `32514` IDI_QUESTION, `32516` IDI_INFORMATION; own: name or number of the resource

**Result:** eax = HICON; 0 on error

## LoadStringA, LoadStringW – text from the resource

user32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `LoadStringA(hInstance, uID, lpBuffer, cchBufferMax)`

- hInstance: HINSTANCE – the module with the string table
- uID: UINT – the number of the text
- lpBuffer: LPSTR – the buffer
- cchBufferMax: int – its size in characters

**Result:** eax = number of characters copied; 0 if there is no such text

This is how Delphi fetches its `resourcestring` texts.

## BeginPaint, EndPaint – painting in WM_PAINT

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `BeginPaint(hWnd, lpPaint)`, `EndPaint(hWnd, lpPaint)`

- hWnd: HWND – the window
- lpPaint: LPPAINTSTRUCT – structure of 64 bytes: hdc, fErase, rcPaint (the invalid area), ...

**Result:** `BeginPaint`: eax = HDC for painting (only inside WM_PAINT); `EndPaint`: 1

Between the two the window function paints with GDI (`TextOutA`, `Rectangle`); `EndPaint` makes the area valid again.

## GetDC, ReleaseDC – device context outside WM_PAINT

user32.dll · stdcall · 1 parameter (4 bytes) / 2 parameters

**Call:** `GetDC(hWnd)`, `ReleaseDC(hWnd, hDC)`

- hWnd: HWND – the window or 0 for the whole screen
- hDC: HDC – from `GetDC`

**Result:** `GetDC`: eax = HDC; 0 on error. `ReleaseDC`: 1 on success

Always give it back, otherwise the contexts run out.

## FillRect – fill a rectangle

user32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `FillRect(hDC, lprc, hbr)`

- hDC: HDC – the device context
- lprc: const RECT* – the rectangle
- hbr: HBRUSH – a brush (`CreateSolidBrush`, `GetStockObject`) or a system color + 1 (`COLOR_WINDOW + 1` = 6)

**Result:** eax = 1 on success

## SetTimer, KillTimer – timer

user32.dll · stdcall · 4 parameters (16 bytes) / 2 parameters

**Call:** `SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc)`, `KillTimer(hWnd, uIDEvent)`

- hWnd: HWND – the window that gets WM_TIMER (`0x113`)
- nIDEvent: UINT_PTR – an own number of the timer
- uElapse: UINT – interval in milliseconds
- lpTimerFunc: TIMERPROC – 0 (message) or a function

**Result:** `SetTimer`: eax = the number; 0 on error. `KillTimer`: 1

## GetKeyState, GetAsyncKeyState – state of a key

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetKeyState(nVirtKey)`, `GetAsyncKeyState(vKey)`

- nVirtKey: int – virtual key code: `0x10` VK_SHIFT, `0x11` VK_CONTROL, `0x12` VK_MENU (Alt), `0x0D` VK_RETURN, `0x1B` VK_ESCAPE, `0x41` to `0x5A` A to Z

**Result:** eax = bit 15 (negative): pressed; `GetKeyState` bit 0: toggle key active (caps lock)

`GetKeyState` applies at the time of the current message, `GetAsyncKeyState` now.

## GetKeyboardType – kind of keyboard

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetKeyboardType(nTypeFlag)`

- nTypeFlag: int – `0` type (4 = enhanced 101/102-key keyboard), `1` subtype, `2` number of function keys

**Result:** eax = the value; 0 on error

Delphi uses it at startup to check whether it is a Japanese keyboard.

## GetSystemMetrics – dimensions of the system

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetSystemMetrics(nIndex)`

- nIndex: int – `0` SM_CXSCREEN screen width, `1` SM_CYSCREEN height, `4` SM_CYCAPTION title height, `43` SM_CMOUSEBUTTONS mouse buttons, `80` SM_CMONITORS number of monitors

**Result:** eax = the value in pixels or the number; 0 on error

## CharNextA, CharNextW – to the next character

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `CharNextA(lpsz)`

- lpsz: LPCSTR – pointer into a text

**Result:** eax = pointer to the next character (2 further for double-byte characters; at the end the same pointer)

This is how Delphi walks through strings that might contain multibyte characters.

## CharToOemA, OemToCharA – Windows and DOS character set

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `CharToOemA(pSrc, pDst)`

- pSrc: LPCSTR – text in the Windows character set (1252)
- pDst: LPSTR – buffer for the OEM code page (850/437), may be pSrc

**Result:** eax = 1

Needed so that umlauts appear correctly on the console when writing with `WriteFile`.

## CharUpperA, CharLowerA – upper and lower case

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `CharUpperA(lpsz)`

- lpsz: LPSTR – a text (changed in place) or a single character in the lower 16 bits (upper 16 bits 0)

**Result:** eax = the pointer or the converted character

Knows umlauts too, unlike `and 0xDF`.

## wsprintfA, wsprintfW – format text (without the C runtime)

user32.dll · cdecl · 2 parameters and more (the caller removes the parameters)

**Call:** `wsprintfA(lpOut, lpFmt, ...)`

- lpOut: LPSTR – the buffer (at most 1024 characters)
- lpFmt: LPCSTR – the format: `%d`, `%u`, `%x`, `%08X`, `%s`, `%c`, `%%` (no floating-point numbers)
- ...: the values in the order of the format

**Result:** eax = number of characters written

The only cdecl function in user32: after the call `add esp, 4 * count`.

```asm
push [value]
push fmt
push buf
call [wsprintfA]
add esp, 12
```

## CreateFontA, CreateFontW – create a font

gdi32.dll · stdcall · 14 parameters (56 bytes)

**Call:** `CreateFontA(cHeight, cWidth, cEscapement, cOrientation, cWeight, bItalic, bUnderline, bStrikeOut, iCharSet, iOutPrecision, iClipPrecision, iQuality, iPitchAndFamily, pszFaceName)`

- cHeight: int – height in pixels (negative: character height without internal leading, usual)
- cWidth: int – 0 (fitting)
- cEscapement, cOrientation: int – rotation in tenths of a degree, 0
- cWeight: int – `400` FW_NORMAL, `700` FW_BOLD
- bItalic, bUnderline, bStrikeOut: DWORD – 0 or 1
- iCharSet: DWORD – `0` ANSI_CHARSET, `1` DEFAULT_CHARSET, `255` OEM_CHARSET
- iOutPrecision, iClipPrecision: DWORD – 0
- iQuality: DWORD – `0` DEFAULT_QUALITY, `5` CLEARTYPE_QUALITY
- iPitchAndFamily: DWORD – `0` DEFAULT_PITCH, `1` FIXED_PITCH (fixed width) | `0x30` FF_MODERN
- pszFaceName: LPCSTR – `Courier New`, `Segoe UI`, ... or 0

**Result:** eax = HFONT; 0 on error

Assign it to a control with `SendMessageA(hWnd, WM_SETFONT, hFont, 1)`; at the end `DeleteObject`.

## GetStockObject – standard object of Windows

gdi32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetStockObject(i)`

- i: int – `0` WHITE_BRUSH, `4` BLACK_BRUSH, `5` NULL_BRUSH, `6` WHITE_PEN, `7` BLACK_PEN, `13` SYSTEM_FONT, `17` DEFAULT_GUI_FONT

**Result:** eax = handle of the object (do not delete)

## CreateSolidBrush – brush of one color

gdi32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `CreateSolidBrush(color)`

- color: COLORREF – `0x00BBGGRR`: red in the lowest byte, then green, blue (`0xFF0000` is blue)

**Result:** eax = HBRUSH; 0 on error

For `hbrBackground` of the window class or `FillRect`; at the end `DeleteObject`.

## CreatePen – pen for lines

gdi32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `CreatePen(iStyle, cWidth, color)`

- iStyle: int – `0` PS_SOLID, `1` PS_DASH, `2` PS_DOT, `5` PS_NULL
- cWidth: int – width in pixels (0 = 1)
- color: COLORREF – the color

**Result:** eax = HPEN; 0 on error

## SelectObject – choose an object into the context

gdi32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SelectObject(hdc, h)`

- hdc: HDC – the device context
- h: HGDIOBJ – pen, brush, font or bitmap

**Result:** eax = the object of the same kind chosen before (choose it back at the end); 0 on error

Drawing commands use the current pen, brush and font of the context.

## DeleteObject – delete a GDI object

gdi32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `DeleteObject(ho)`

- ho: HGDIOBJ – pen, brush, font, bitmap (not the stock objects, not one that is currently chosen)

**Result:** eax = 1 on success, 0 on error

## TextOutA, TextOutW – draw text

gdi32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `TextOutA(hdc, x, y, lpString, c)`

- hdc: HDC – the device context (`BeginPaint`, `GetDC`)
- x, y: int – the upper left corner of the text
- lpString: LPCSTR – the text (no 0 needed)
- c: int – number of characters

**Result:** eax = 1 on success

Font, text color (`SetTextColor`) and background (`SetBkColor`, `SetBkMode`) come from the context.

## SetTextColor, SetBkColor – text and background color

gdi32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetTextColor(hdc, color)`, `SetBkColor(hdc, color)`

- hdc: HDC – the device context
- color: COLORREF – `0x00BBGGRR`

**Result:** eax = the previous color; `0xFFFFFFFF` CLR_INVALID on error

## SetBkMode – background of the text

gdi32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetBkMode(hdc, mode)`

- hdc: HDC – the device context
- mode: int – `1` TRANSPARENT (only the characters), `2` OPAQUE (fill the background in `SetBkColor`)

**Result:** eax = the previous mode; 0 on error

## MoveToEx, LineTo – draw a line

gdi32.dll · stdcall · 4 parameters (16 bytes) / 3 parameters

**Call:** `MoveToEx(hdc, x, y, lppt)`, `LineTo(hdc, x, y)`

- hdc: HDC – the device context
- x, y: int – the point
- lppt: LPPOINT – address for the old point or 0

**Result:** eax = 1 on success

`MoveToEx` sets the start, `LineTo` draws with the current pen up to the point (exclusive) and sets the start there.

## Rectangle, Ellipse – draw a rectangle and an ellipse

gdi32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `Rectangle(hdc, left, top, right, bottom)`

- hdc: HDC – the device context
- left, top, right, bottom: int – the corners (right and bottom exclusive)

**Result:** eax = 1 on success

Border with the current pen, area with the current brush (`NULL_BRUSH`: border only).

## CreateCompatibleDC, DeleteDC – context in memory

gdi32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `CreateCompatibleDC(hdc)`, `DeleteDC(hdc)`

- hdc: HDC – a context as a model (0: the screen); with `DeleteDC` the one to delete

**Result:** `CreateCompatibleDC`: eax = HDC; 0 on error. `DeleteDC`: 1

For drawing into a bitmap (`SelectObject` with an HBITMAP) that `BitBlt` then copies into the window (flicker-free).

## CreateCompatibleBitmap – bitmap for a context

gdi32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `CreateCompatibleBitmap(hdc, cx, cy)`

- hdc: HDC – the context the bitmap should fit
- cx, cy: int – width and height

**Result:** eax = HBITMAP; 0 on error. At the end `DeleteObject`.

## BitBlt – copy a block of pixels

gdi32.dll · stdcall · 9 parameters (36 bytes)

**Call:** `BitBlt(hdc, x, y, cx, cy, hdcSrc, x1, y1, rop)`

- hdc: HDC – the destination
- x, y: int – destination corner
- cx, cy: int – width and height
- hdcSrc: HDC – the source
- x1, y1: int – source corner
- rop: DWORD – `0xCC0020` SRCCOPY, `0xEE0086` SRCPAINT (or), `0x660046` SRCINVERT (xor)

**Result:** eax = 1 on success

## GetOpenFileNameA, GetOpenFileNameW – dialog "Open"

comdlg32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetOpenFileNameA(lpofn)`

- lpofn: LPOPENFILENAMEA – structure OPENFILENAME of 76 bytes (with the fields for Windows 2000: 88): lStructSize, hwndOwner, hInstance, lpstrFilter (`Text\0*.txt\0All\0*.*\0\0`), lpstrCustomFilter, nMaxCustFilter, nFilterIndex, lpstrFile (buffer, receives the path), nMaxFile, lpstrFileTitle, nMaxFileTitle, lpstrInitialDir, lpstrTitle, Flags (`0x1000` OFN_FILEMUSTEXIST, `0x800` OFN_PATHMUSTEXIST, `0x4` OFN_HIDEREADONLY), nFileOffset, nFileExtension, lpstrDefExt, ...

**Result:** eax = 1 if the user chose a file (path in lpstrFile); 0 on cancel or error (`CommDlgExtendedError`)

## GetSaveFileNameA, GetSaveFileNameW – dialog "Save as"

comdlg32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetSaveFileNameA(lpofn)`

- lpofn: LPOPENFILENAMEA – the same structure as for `GetOpenFileNameA`; flag `0x2` OFN_OVERWRITEPROMPT asks before overwriting

**Result:** eax = 1 on selection, 0 on cancel

## RegOpenKeyExA, RegOpenKeyExW – open a registry key

advapi32.dll · stdcall · 5 parameters (20 bytes)

**Call:** `RegOpenKeyExA(hKey, lpSubKey, ulOptions, samDesired, phkResult)`

- hKey: HKEY – `0x80000001` HKEY_CURRENT_USER, `0x80000002` HKEY_LOCAL_MACHINE, `0x80000000` HKEY_CLASSES_ROOT or an open key
- lpSubKey: LPCSTR – the path below it, e.g. `Software\Microsoft\Windows\CurrentVersion`
- ulOptions: DWORD – 0
- samDesired: REGSAM – `0x20019` KEY_READ, `0x20006` KEY_WRITE, `0xF003F` KEY_ALL_ACCESS
- phkResult: PHKEY – address for the handle

**Result:** eax = 0 ERROR_SUCCESS; else the error code (`2` not found, `5` access denied); not `GetLastError`

Close with `RegCloseKey`.

## RegCreateKeyExA, RegCreateKeyExW – create or open a key

advapi32.dll · stdcall · 9 parameters (36 bytes)

**Call:** `RegCreateKeyExA(hKey, lpSubKey, Reserved, lpClass, dwOptions, samDesired, lpSecurityAttributes, phkResult, lpdwDisposition)`

- hKey, lpSubKey, samDesired, phkResult: as for `RegOpenKeyExA`
- Reserved: DWORD – 0
- lpClass: LPSTR – 0
- dwOptions: DWORD – 0 (REG_OPTION_NON_VOLATILE)
- lpSecurityAttributes: LPSECURITY_ATTRIBUTES – 0
- lpdwDisposition: LPDWORD – address for `1` REG_CREATED_NEW_KEY or `2` REG_OPENED_EXISTING_KEY, or 0

**Result:** eax = 0 on success, else the error code

## RegQueryValueExA, RegQueryValueExW – read a value

advapi32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `RegQueryValueExA(hKey, lpValueName, lpReserved, lpType, lpData, lpcbData)`

- hKey: HKEY – open key
- lpValueName: LPCSTR – name of the value (empty or 0: the default value)
- lpReserved: LPDWORD – 0
- lpType: LPDWORD – address for the type: `1` REG_SZ, `2` REG_EXPAND_SZ, `3` REG_BINARY, `4` REG_DWORD, `7` REG_MULTI_SZ; or 0
- lpData: LPBYTE – the buffer or 0 (only determine the size)
- lpcbData: LPDWORD – address of the buffer size in bytes; afterwards the size of the data

**Result:** eax = 0 on success; `234` ERROR_MORE_DATA if the buffer is too small; `2` if there is no such value

## RegSetValueExA, RegSetValueExW – write a value

advapi32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `RegSetValueExA(hKey, lpValueName, Reserved, dwType, lpData, cbData)`

- hKey: HKEY – open key with write access
- lpValueName: LPCSTR – name of the value
- Reserved: DWORD – 0
- dwType: DWORD – `1` REG_SZ, `4` REG_DWORD, `3` REG_BINARY
- lpData: const BYTE* – the data (REG_SZ including the 0)
- cbData: DWORD – their size in bytes

**Result:** eax = 0 on success, else the error code

## RegCloseKey – close a key

advapi32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `RegCloseKey(hKey)`

- hKey: HKEY – from `RegOpenKeyExA` or `RegCreateKeyExA` (not the HKEY_ constants)

**Result:** eax = 0 on success

## ShellExecuteA, ShellExecuteW – open a file like the Explorer

shell32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `ShellExecuteA(hwnd, lpOperation, lpFile, lpParameters, lpDirectory, nShowCmd)`

- hwnd: HWND – parent window or 0
- lpOperation: LPCSTR – `open`, `print`, `explore` or 0 (= open)
- lpFile: LPCSTR – file, program, folder or URL (`https://...`)
- lpParameters: LPCSTR – command line for a program or 0
- lpDirectory: LPCSTR – working directory or 0
- nShowCmd: int – `1` SW_SHOWNORMAL, `0` SW_HIDE

**Result:** eax = larger than 32 on success; else an error code (`2` not found, `31` no association)

## CommandLineToArgvW – split the command line

shell32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `CommandLineToArgvW(lpCmdLine, pNumArgs)`

- lpCmdLine: LPCWSTR – the command line as UTF-16 (`GetCommandLineW`)
- pNumArgs: int* – address for the number of parts

**Result:** eax = pointer to a table of pointers to the parts (UTF-16); 0 on error. Free with `LocalFree`.

Only the W form exists; quotation marks are treated as in C programs.

## SysAllocString, SysAllocStringLen – create a BSTR

oleaut32.dll · stdcall · 1 parameter (4 bytes) / 2 parameters

**Call:** `SysAllocString(psz)`, `SysAllocStringLen(strIn, ui)`

- psz, strIn: const OLECHAR* – UTF-16 text (0 allowed with `SysAllocStringLen`: only space)
- ui: UINT – number of characters

**Result:** eax = BSTR: pointer to the UTF-16 text, in front of it (offset -4) its length in bytes; 0 on error

The string type of COM and automation; Delphi uses it for `WideString`. Free with `SysFreeString`.

## SysReAllocString, SysReAllocStringLen – reallocate a BSTR

oleaut32.dll · stdcall · 2 parameters (8 bytes) / 3 parameters

**Call:** `SysReAllocStringLen(pbstr, psz, len)`

- pbstr: BSTR* – address of the variable with the old BSTR (may contain 0)
- psz: const OLECHAR* – the new text or 0
- len: UINT – number of characters

**Result:** eax = 1 on success, 0 if no memory is left

Delphi calls it on every assignment to a `WideString`.

## SysFreeString – free a BSTR

oleaut32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SysFreeString(bstrString)`

- bstrString: BSTR – the string (0 allowed)

**Result:** none

## SysStringLen – length of a BSTR

oleaut32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SysStringLen(pbstr)`

- pbstr: BSTR – the string (0 allowed: result 0)

**Result:** eax = number of characters (the double word in front of the text divided by 2)

## VariantInit, VariantClear – create and empty a variant

oleaut32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `VariantInit(pvarg)`, `VariantClear(pvarg)`

- pvarg: VARIANTARG* – address of a VARIANT of 16 bytes: type in the first word (`0` VT_EMPTY, `2` VT_I2, `3` VT_I4, `5` VT_R8, `8` VT_BSTR, `11` VT_BOOL, `12` VT_VARIANT, `0x2000` VT_ARRAY, `0x4000` VT_BYREF), the value from offset 8

**Result:** `VariantInit`: none (sets VT_EMPTY). `VariantClear`: eax = 0 on success; frees BSTR, interface or SafeArray in the variant

Delphi: the type `Variant`/`OleVariant`.

## VariantCopy – copy a variant

oleaut32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `VariantCopy(pvargDest, pvargSrc)`

- pvargDest: VARIANTARG* – the destination (emptied with `VariantClear` before)
- pvargSrc: const VARIANTARG* – the source

**Result:** eax = HRESULT: 0 S_OK, negative on error

A BSTR or SafeArray is copied, an interface gets `AddRef`.

## VariantChangeType – change the type of a variant

oleaut32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `VariantChangeType(pvargDest, pvarSrc, wFlags, vt)`

- pvargDest: VARIANTARG* – the destination (may be pvarSrc)
- pvarSrc: const VARIANTARG* – the source
- wFlags: USHORT – 0; `2` VARIANT_ALPHABOOL (True/False instead of -1/0)
- vt: VARTYPE – the wanted type (`3` VT_I4, `5` VT_R8, `8` VT_BSTR, ...)

**Result:** eax = HRESULT: 0 S_OK; `0x80020005` DISP_E_TYPEMISMATCH; `0x8002000A` DISP_E_OVERFLOW

This turns `'42'` into the number 42 and back (Delphi `VarAsType`, implicit variant conversions).

## SafeArrayCreate – create an array for variants

oleaut32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `SafeArrayCreate(vt, cDims, rgsabound)`

- vt: VARTYPE – type of the elements (`12` VT_VARIANT, `3` VT_I4, `8` VT_BSTR, `17` VT_UI1 for bytes)
- cDims: UINT – number of dimensions
- rgsabound: SAFEARRAYBOUND* – per dimension 8 bytes: cElements, lLbound (lower index)

**Result:** eax = SAFEARRAY*; 0 on error. Free with `SafeArrayDestroy` or through `VariantClear`.

Delphi: `VarArrayCreate`.

## SafeArrayGetLBound, SafeArrayGetUBound – bounds of a SafeArray

oleaut32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `SafeArrayGetLBound(psa, nDim, plLbound)`, `SafeArrayGetUBound(psa, nDim, plUbound)`

- psa: SAFEARRAY* – the array
- nDim: UINT – the dimension, from 1
- plLbound, plUbound: LONG* – address for the lower or upper bound (inclusive)

**Result:** eax = HRESULT: 0 S_OK; `0x8002000B` DISP_E_BADINDEX

Delphi: `VarArrayLowBound`, `VarArrayHighBound`.

## SafeArrayPtrOfIndex – address of an element

oleaut32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `SafeArrayPtrOfIndex(psa, rgIndices, ppvData)`

- psa: SAFEARRAY* – the array
- rgIndices: LONG* – one index per dimension (the last dimension first)
- ppvData: void** – address for the pointer to the element

**Result:** eax = HRESULT: 0 S_OK; `0x8002000B` DISP_E_BADINDEX

This is how Delphi reads and writes `V[i]` of a variant array.

## SafeArrayAccessData, SafeArrayUnaccessData – lock the data

oleaut32.dll · stdcall · 2 parameters (8 bytes) / 1 parameter

**Call:** `SafeArrayAccessData(psa, ppvData)`, `SafeArrayUnaccessData(psa)`

- psa: SAFEARRAY* – the array
- ppvData: void** – address for the pointer to the first element

**Result:** eax = HRESULT: 0 S_OK

Between the two you may read and write the elements directly in memory (Delphi `VarArrayLock`, `VarArrayUnlock`).

## printf – print formatted

msvcrt.dll · cdecl · 1 parameter and more (the caller removes the parameters)

**Call:** `printf(format, ...)`

- format: const char* – the text with placeholders: `%d` number with sign, `%u` without, `%x`/`%X` hexadecimal, `%08X` with 8 digits and zeros, `%s` text, `%c` character, `%f` floating point (8 bytes), `%%` percent, `\n` is the byte `0x0A`
- ...: the values in the order of the placeholders, 4 bytes each (`%f`: 8)

**Result:** eax = number of characters written; negative on error

Writes to the standard output (buffered: up to the end of the line or the end of the program). After the call remove the stack yourself.

```asm
push 42
push fmt       ; "x = %d", 10, 0
call [printf]
add esp, 8
```

## sprintf – format into a buffer

msvcrt.dll · cdecl · 2 parameters and more (the caller removes the parameters)

**Call:** `sprintf(buffer, format, ...)`

- buffer: char* – the buffer (large enough; `_snprintf` limits)
- format, ...: as for `printf`

**Result:** eax = number of characters written without the 0

## puts, putchar – print text and character

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `puts(str)`, `putchar(c)`

- str: const char* – 0-terminated text; `puts` appends a line break
- c: int – the character

**Result:** eax = not negative on success or the character; `-1` EOF on error

## getchar, _getch – read a character

msvcrt.dll · cdecl · no parameters

**Call:** `getchar()`, `_getch()`

**Result:** eax = the character; `-1` EOF at the end of the input

`getchar` reads from the buffered standard input (only after the Enter key); `_getch` waits for a single key without echo, typical for "press a key" at the end of the program.

## scanf – read formatted

msvcrt.dll · cdecl · 1 parameter and more (the caller removes the parameters)

**Call:** `scanf(format, ...)`

- format: const char* – placeholders as for `printf` (`%d`, `%s`, `%c`, `%f` expects `float*`, `%lf` `double*`)
- ...: addresses of the variables into which is read

**Result:** eax = number of values assigned; `-1` EOF

## strlen – length of a text

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `strlen(str)`

- str: const char* – 0-terminated text

**Result:** eax = number of bytes without the 0

Also in `api-ms-win-crt-string-l1-1-0.dll` (clang, Visual C++ from 2015).

## strcpy, strncpy, strcat – copy and append text

msvcrt.dll · cdecl · 2 parameters (the caller removes the parameters); `strncpy` 3

**Call:** `strcpy(dest, src)`, `strcat(dest, src)`, `strncpy(dest, src, count)`

- dest: char* – the destination (large enough)
- src: const char* – the source, 0-terminated
- count: size_t – at most this many bytes (`strncpy` fills with zeros, but sets no 0 if src is longer)

**Result:** eax = dest

## strcmp, strncmp, _stricmp – compare texts

msvcrt.dll · cdecl · 2 parameters (the caller removes the parameters); `strncmp` 3

**Call:** `strcmp(str1, str2)`

- str1, str2: const char* – the texts
- count: size_t – `strncmp`: at most this many bytes

**Result:** eax = 0 equal, negative if str1 is smaller, positive if larger (byte comparison; `_stricmp` ignoring case)

## memcpy, memmove, memset – copy and fill memory

msvcrt.dll · cdecl · 3 parameters (the caller removes the parameters)

**Call:** `memcpy(dest, src, count)`, `memmove(dest, src, count)`, `memset(dest, c, count)`

- dest: void* – the destination
- src: const void* – the source (`memmove` may overlap with dest)
- c: int – the fill byte (`memset`)
- count: size_t – number of bytes

**Result:** eax = dest

Also in `api-ms-win-crt-private-l1-1-0.dll` (clang). Corresponds to `rep movsb` / `rep stosb`.

## malloc, calloc, realloc, free – memory of the C runtime

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters); `calloc`, `realloc` 2

**Call:** `malloc(size)`, `calloc(num, size)`, `realloc(ptr, size)`, `free(ptr)`

- size: size_t – number of bytes (`calloc`: per element, filled with zeros)
- num: size_t – number of elements
- ptr: void* – a block from `malloc` (`free(0)` is allowed)

**Result:** eax = address of the block; 0 if no memory is left. `free`: none

Also in `api-ms-win-crt-heap-l1-1-0.dll`. Internally a heap like `HeapAlloc`.

## atoi, atol, strtol – text to number

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters); `strtol` 3

**Call:** `atoi(str)`, `strtol(str, endptr, base)`

- str: const char* – digits, white space and sign before are allowed
- endptr: char** – address for the pointer behind the number or 0
- base: int – base 2 to 36; 0: `0x` hexadecimal, `0` octal, else decimal

**Result:** eax = the number; 0 if no digit is there

## exit, _exit – end the program (C runtime)

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `exit(status)`, `_exit(status)`

- status: int – the return value of the program

**Result:** does not return

`exit` first calls the `atexit` functions, closes the files and empties the buffers (`_cexit`), then `ExitProcess`; `_exit` ends at once. Also in `api-ms-win-crt-runtime-l1-1-0.dll`.

## abort – abort the program

msvcrt.dll · cdecl · no parameters

**Call:** `abort()`

**Result:** does not return

Raises SIGABRT and ends with code 3; under Windows usually with the dialog "abnormal program termination". The compiler puts it behind code that must not return.

## system – run a command

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `system(command)`

- command: const char* – a command line for `cmd.exe` (`pause`, `cls`, `dir`); 0: checks whether there is a command interpreter

**Result:** eax = return value of the command; `-1` on error

## rand, srand – random numbers

msvcrt.dll · cdecl · no parameters / 1 parameter

**Call:** `rand()`, `srand(seed)`

- seed: unsigned int – start value, often `time(0)`

**Result:** `rand`: eax = number from 0 to 32767; without `srand` the same sequence every time

## time – seconds since 1970

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `time(destTime)`

- destTime: time_t* – address for the value or 0

**Result:** edx:eax = seconds since 1.1.1970 UTC (64 bit; `_time32`: 32 bit in eax)

## fopen, fclose – open and close a file (C runtime)

msvcrt.dll · cdecl · 2 parameters (the caller removes the parameters); `fclose` 1

**Call:** `fopen(filename, mode)`, `fclose(stream)`

- filename: const char* – the path
- mode: const char* – `r` read, `w` write (new), `a` append, plus `b` binary (`rb`, `wb`), `+` read and write
- stream: FILE* – from `fopen`

**Result:** `fopen`: eax = FILE* or 0 on error. `fclose`: 0 on success, `-1` EOF

## fread, fwrite – read and write blocks (C runtime)

msvcrt.dll · cdecl · 4 parameters (the caller removes the parameters)

**Call:** `fread(buffer, size, count, stream)`, `fwrite(buffer, size, count, stream)`

- buffer: void* – the buffer
- size: size_t – size of one element in bytes
- count: size_t – number of elements
- stream: FILE* – from `fopen`, or `stdin`/`stdout`/`stderr` (`__acrt_iob_func(0..2)`)

**Result:** eax = number of elements read or written completely (smaller than count: end of file or error)

## fprintf – formatted into a file

msvcrt.dll · cdecl · 2 parameters and more (the caller removes the parameters)

**Call:** `fprintf(stream, format, ...)`

- stream: FILE* – the file or `stderr` for error messages
- format, ...: as for `printf`

**Result:** eax = number of characters written; negative on error

## fflush – empty the buffer of a file

msvcrt.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `fflush(stream)`

- stream: FILE* – the file or `stdout`; 0: all open files

**Result:** eax = 0 on success; `-1` EOF on error

Also in `api-ms-win-crt-stdio-l1-1-0.dll`. Needed if the output should appear at once (`printf` without line end before `_getch`).

## setvbuf – buffering of a file

msvcrt.dll · cdecl · 4 parameters (the caller removes the parameters)

**Call:** `setvbuf(stream, buffer, mode, size)`

- stream: FILE* – the file or `stdout`
- buffer: char* – own buffer or 0
- mode: int – `0` _IOFBF fully buffered, `0x40` _IOLBF line-buffered, `4` _IONBF unbuffered
- size: size_t – buffer size

**Result:** eax = 0 on success

The startup routine of clang/MinGW uses it to switch the buffering of stdout and stderr.

## __acrt_iob_func – stdin, stdout, stderr

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `__acrt_iob_func(index)`

- index: unsigned – `0` stdin, `1` stdout, `2` stderr

**Result:** eax = FILE* of the standard stream

The universal C runtime (ucrt, Visual C++ from 2015, clang) has no variables `stdin`/`stdout` any more; `printf(...)` is with it `__stdio_common_vfprintf(..., __acrt_iob_func(1), ...)`.

## __stdio_common_vfprintf – the printf of the ucrt

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · 5 parameters, 24 bytes (the caller removes the parameters)

**Call:** `__stdio_common_vfprintf(options, stream, format, locale, arglist)`

- options: unsigned __int64 – options (8 bytes), usually `1` (_CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION) or 0
- stream: FILE* – `__acrt_iob_func(1)` for stdout
- format: const char* – the format as for `printf`
- locale: _locale_t – 0
- arglist: va_list – pointer to the values on the stack

**Result:** eax = number of characters written; negative on error

All `printf` variants of the ucrt (`printf`, `fprintf`, `vprintf`) are reduced to this call as inline functions in the header file; so you never see `printf` itself in the program.

## __p__commode, __p__fmode – mode variables of the ucrt

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · no parameters

**Call:** `__p__commode()`, `__p__fmode()`

**Result:** eax = address of the variable `_commode` (commit mode when writing) or `_fmode` (`0x4000` text, `0x8000` binary for new files)

The startup routine writes its defaults into them.

## __p___argc, __p___argv, __p__environ – argc, argv, environ of the ucrt

api-ms-win-crt-runtime-l1-1-0.dll, api-ms-win-crt-environment-l1-1-0.dll · cdecl · no parameters

**Call:** `__p___argc()`, `__p___argv()`, `__p__environ()`

**Result:** eax = address of the variable: `int argc`, `char** argv`, `char** environ`

After `_configure_narrow_argv` the split command line and the environment are there; `main(argc, argv)` gets the values from here.

## _configure_narrow_argv, _initialize_narrow_environment – set up command line and environment

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 parameter / none (the caller removes the parameters)

**Call:** `_configure_narrow_argv(mode)`, `_initialize_narrow_environment()`

- mode: int – `0` no wildcards, `1` expand `*` and `?` in arguments (_crt_argv_expanded_arguments)

**Result:** eax = 0 on success (errno value)

Part of the startup routine before `main`: splits `GetCommandLineA` into argc/argv and copies the environment.

## _initterm, _initterm_e – call initialization functions

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 2 parameters (the caller removes the parameters)

**Call:** `_initterm(first, last)`, `_initterm_e(first, last)`

- first, last: _PVFV* – start and end of a table of function pointers (section `.CRT$XCA` to `.CRT$XCZ`); entries 0 are skipped

**Result:** `_initterm`: none. `_initterm_e`: eax = 0, or the first error code a function returned (they return `int`)

This is how the constructors of global C++ objects and the initialization of the runtime run before `main`.

## _crt_atexit, _cexit – clean up at the end

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 parameter / none (the caller removes the parameters)

**Call:** `_crt_atexit(function)`, `_cexit()`

- function: _PVFV – a function without parameters that `exit` calls later (the `atexit` of the ucrt)

**Result:** `_crt_atexit`: eax = 0 on success. `_cexit`: none

`_cexit` calls the `atexit` functions and empties the buffers, but does not end the process; the startup routine calls it when `main` returns, and then `ExitProcess`.

## _set_app_type – console or window

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `_set_app_type(type)`

- type: int – `1` _crt_console_app, `2` _crt_gui_app

**Result:** none

Decides whether error messages of the runtime appear on stderr or in a message window.

## _set_invalid_parameter_handler, _set_new_mode, __setusermatherr – behavior of the runtime

api-ms-win-crt-runtime-l1-1-0.dll, api-ms-win-crt-heap-l1-1-0.dll, api-ms-win-crt-math-l1-1-0.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `_set_invalid_parameter_handler(handler)`, `_set_new_mode(mode)`, `__setusermatherr(handler)`

- handler: function pointer – called on invalid parameters (e.g. `strcpy_s` with 0) or on mathematics errors; 0: the default
- mode: int – `1`: `malloc` calls the `new` handler when memory runs out

**Result:** eax = the previous handler or mode

The startup routine of MinGW/clang sets all three once.

## _configthreadlocale – locale per thread

api-ms-win-crt-locale-l1-1-0.dll · cdecl · 1 parameter (the caller removes the parameters)

**Call:** `_configthreadlocale(type)`

- type: int – `1` _ENABLE_PER_THREAD_LOCALE, `2` _DISABLE_PER_THREAD_LOCALE, `0` only read

**Result:** eax = the previous setting; `-1` on error

## _fpreset – reset the floating-point unit

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · no parameters

**Call:** `_fpreset()`

**Result:** none

Sets the control word of the FPU to the default of the runtime (`fninit` and rounding); after exceptions and at startup.

## _seh_filter_exe – exception filter of the runtime

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 2 parameters (the caller removes the parameters)

**Call:** `_seh_filter_exe(exceptionNum, exceptionPtr)`

- exceptionNum: unsigned long – the exception code (`0xC0000005` access violation, `0xC0000094` division by 0)
- exceptionPtr: struct _EXCEPTION_POINTERS* – exception and registers

**Result:** eax = `1` EXCEPTION_EXECUTE_HANDLER, `0` CONTINUE_SEARCH, `-1` CONTINUE_EXECUTION

Turns hardware exceptions into the signals SIGSEGV and SIGFPE for `signal()`; the startup routine wraps `main` with it.

## CLSIDFromString – convert text to a GUID

ole32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `CLSIDFromString(lpsz, pclsid)`

- lpsz: LPCOLESTR – UTF-16 text of the form `{00000000-0000-0000-0000-000000000000}`
- pclsid: LPCLSID – address of 16 bytes for the GUID

**Result:** eax = HRESULT: 0 S_OK; `0x800401F3` CO_E_CLASSSTRING for a wrong text

The reverse of `StringFromGUID2`. Delphi: `StringToGUID`.

## StringFromGUID2 – convert a GUID to text

ole32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `StringFromGUID2(rguid, lpsz, cchMax)`

- rguid: REFGUID – address of the 16 bytes
- lpsz: LPOLESTR – the buffer for UTF-16 text
- cchMax: int – its size in characters (at least 39)

**Result:** eax = number of characters written including 0 (39); 0 if the buffer is too small

Writes the GUID as `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`. Delphi: `GUIDToString`.

## CharToOemBuffA, OemToCharBuffA – Windows and DOS character set (with length)

user32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `CharToOemBuffA(lpszSrc, lpszDst, cchDstLength)`

- lpszSrc: LPCSTR – the text (no 0 needed)
- lpszDst: LPSTR – the buffer, may be lpszSrc
- cchDstLength: DWORD – number of characters

**Result:** eax = 1

Like `CharToOemA`, but for a text of known length.

## CharUpperBuffA, CharLowerBuffA – upper and lower case (with length)

user32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `CharUpperBuffA(lpsz, cchLength)`

- lpsz: LPSTR – the text, changed in place
- cchLength: DWORD – number of characters (no 0 needed)

**Result:** eax = number of characters processed

## EnumThreadWindows – list the windows of a thread

user32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `EnumThreadWindows(dwThreadId, lpfn, lParam)`

- dwThreadId: DWORD – the thread number
- lpfn: WNDENUMPROC – own function (stdcall, 2 parameters: hwnd, lParam) that is called per window; result 1 = go on, 0 = end
- lParam: LPARAM – passed on to the function

**Result:** eax = 0 if the function returned 0 or there are no windows, else 1

This is how Delphi disables all windows of the program when a modal window opens.

## FileTimeToDosDateTime – file time to DOS date and time

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `FileTimeToDosDateTime(lpFileTime, lpFatDate, lpFatTime)`

- lpFileTime: const FILETIME* – 8 bytes, 100-ns steps since 1601
- lpFatDate: LPWORD – date: bits 0..4 day, 5..8 month, 9..15 year minus 1980
- lpFatTime: LPWORD – time: bits 0..4 seconds / 2, 5..10 minute, 11..15 hour

**Result:** eax = 1 on success, 0 on error

The format of the file time in FAT directories and in Delphi `FileAge`. Reverse: `DosDateTimeToFileTime`.

## FileTimeToLocalFileTime, LocalFileTimeToFileTime – UTC and local time

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `FileTimeToLocalFileTime(lpFileTime, lpLocalFileTime)`

- lpFileTime: const FILETIME* – the time in UTC
- lpLocalFileTime: LPFILETIME – address for the local time (may be lpFileTime)

**Result:** eax = 1 on success, 0 on error

Shifts by the current time zone (`GetTimeZoneInformation`).

## SystemTimeToFileTime, FileTimeToSystemTime – convert time formats

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SystemTimeToFileTime(lpSystemTime, lpFileTime)`

- lpSystemTime: const SYSTEMTIME* – 16 bytes (year, month, weekday, day, hour, minute, second, millisecond)
- lpFileTime: LPFILETIME – address for 8 bytes (100-ns steps since 1601)

**Result:** eax = 1 on success, 0 on error (e.g. month 13)

`FileTimeToSystemTime` converts back, the parameters in reversed roles.

## GetTimeZoneInformation – time zone

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetTimeZoneInformation(lpTimeZoneInformation)`

- lpTimeZoneInformation: LPTIME_ZONE_INFORMATION – structure of 172 bytes: bias (minutes, UTC = local time + bias; Germany in winter -60), name of the standard time, start, bias of the standard time, name of the daylight time, start, bias of the daylight time

**Result:** eax = `0` unknown, `1` standard time applies, `2` daylight saving time applies; `0xFFFFFFFF` on error

## FindResourceA, FindResourceW – find a resource

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `FindResourceA(hModule, lpName, lpType)`

- hModule: HMODULE – the module with the resource, 0 for the program
- lpName: LPCSTR – name or number (number in the lower 16 bits, upper 0)
- lpType: LPCSTR – type: `3` RT_ICON, `6` RT_STRING, `10` RT_RCDATA, `14` RT_GROUP_ICON, `16` RT_VERSION, `24` RT_MANIFEST or a name

**Result:** eax = HRSRC; 0 on error

After it `LoadResource`, `LockResource` and `SizeofResource`.

## FindResourceExA, FindResourceExW – find a resource (with language)

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `FindResourceExA(hModule, lpType, lpName, wLanguage)`

- hModule: HMODULE – the module with the resource
- lpType: LPCSTR – type (note: before the name, unlike `FindResourceA`)
- lpName: LPCSTR – name or number
- wLanguage: WORD – language (`0` neutral, `0x407` German, `0x409` English USA)

**Result:** eax = HRSRC; 0 on error

## LoadResource – load a resource

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `LoadResource(hModule, hResInfo)`

- hModule: HMODULE – the module
- hResInfo: HRSRC – from `FindResourceA`

**Result:** eax = HGLOBAL; 0 on error

Under Win32 the resource is in memory already: `LockResource` makes the pointer of it.

## LockResource, FreeResource – lock and free a resource

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `LockResource(hResData)`

- hResData: HGLOBAL – from `LoadResource`

**Result:** eax = pointer to the data; 0 on error. `FreeResource`: 0 on success

## SizeofResource – size of a resource

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SizeofResource(hModule, hResInfo)`

- hModule: HMODULE – the module
- hResInfo: HRSRC – from `FindResourceA`

**Result:** eax = size in bytes; 0 on error

## GetCurrentDirectoryA, GetCurrentDirectoryW – current directory

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetCurrentDirectoryA(nBufferLength, lpBuffer)`

- nBufferLength: DWORD – size of the buffer in characters including 0
- lpBuffer: LPSTR – the buffer

**Result:** eax = length of the path without 0; larger than nBufferLength: needed size including 0; 0 on error

## SetCurrentDirectoryA, SetCurrentDirectoryW – set the current directory

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetCurrentDirectoryA(lpPathName)`

- lpPathName: LPCSTR – the path

**Result:** eax = 1 on success, 0 on error

Applies to the whole process, not only to one thread.

## GetDriveTypeA, GetDriveTypeW – kind of a drive

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GetDriveTypeA(lpRootPathName)`

- lpRootPathName: LPCSTR – `C:\` or 0 for the current drive

**Result:** eax = `0` unknown, `1` there is no drive, `2` removable medium, `3` hard disk, `4` network drive, `5` CD/DVD, `6` RAM disk

## GetLogicalDrives – existing drives

kernel32.dll · stdcall · no parameters

**Call:** `GetLogicalDrives()`

**Result:** eax = bit mask: bit 0 drive A, bit 1 B, bit 2 C, ...; 0 on error

## GetEnvironmentStrings, GetEnvironmentStringsA, GetEnvironmentStringsW, FreeEnvironmentStringsA, FreeEnvironmentStringsW – the whole environment

kernel32.dll · stdcall · no parameters / 1 parameter

**Call:** `GetEnvironmentStrings()`, `FreeEnvironmentStringsA(lpszEnvironmentBlock)`

- lpszEnvironmentBlock: LPSTR – the pointer from `GetEnvironmentStrings`

**Result:** eax = pointer to a block of texts `NAME=value`, each ended by 0, at the end an additional 0

To walk through: read up to the 0, then go on at once; an empty text ends the block. Free with `FreeEnvironmentStringsA`.

## SetEnvironmentVariableA, SetEnvironmentVariableW – set an environment variable

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetEnvironmentVariableA(lpName, lpValue)`

- lpName: LPCSTR – the name
- lpValue: LPCSTR – the value; 0 deletes the variable

**Result:** eax = 1 on success, 0 on error

Applies only to the own process and the programs it starts afterwards.

## GetFileInformationByHandle – information about a file

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `GetFileInformationByHandle(hFile, lpFileInformation)`

- hFile: HANDLE – open file
- lpFileInformation: LPBY_HANDLE_FILE_INFORMATION – structure of 52 bytes: attributes, creation time, last access, last change (8 bytes each), serial number of the drive, size (high, low), number of links, index of the file (high, low)

**Result:** eax = 1 on success, 0 on error

Two handles are the same file if serial number and index are equal.

## GetTempFileNameA, GetTempFileNameW – name for a temporary file

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `GetTempFileNameA(lpPathName, lpPrefixString, uUnique, lpTempFileName)`

- lpPathName: LPCSTR – the folder (`GetTempPathA`)
- lpPrefixString: LPCSTR – up to 3 characters for the start of the name
- uUnique: UINT – 0: Windows chooses the number and creates the empty file; else this number in hexadecimal, without creating
- lpTempFileName: LPSTR – buffer of at least 260 characters

**Result:** eax = the number used; 0 on error

## MoveFileA, MoveFileW – move or rename a file

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `MoveFileA(lpExistingFileName, lpNewFileName)`

- lpExistingFileName: LPCSTR – the existing file or folder
- lpNewFileName: LPCSTR – the new name (must not exist yet)

**Result:** eax = 1 on success, 0 on error

Between drives Windows copies and deletes by itself.

## CopyFileA, CopyFileW – copy a file

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `CopyFileA(lpExistingFileName, lpNewFileName, bFailIfExists)`

- lpExistingFileName: LPCSTR – the source
- lpNewFileName: LPCSTR – the destination
- bFailIfExists: BOOL – 1: fails if the destination exists already; 0: overwrites

**Result:** eax = 1 on success, 0 on error

## SearchPathA, SearchPathW – search a file in directories

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `SearchPathA(lpPath, lpFileName, lpExtension, nBufferLength, lpBuffer, lpFilePart)`

- lpPath: LPCSTR – list of folders separated by `;`, or 0 (program folder, current folder, system, `PATH`)
- lpFileName: LPCSTR – the file name
- lpExtension: LPCSTR – extension appended if the name has none (with a dot), or 0
- nBufferLength: DWORD – size of the buffer in characters
- lpBuffer: LPSTR – the buffer for the full path
- lpFilePart: LPSTR* – address of a pointer to the file name in the buffer or 0

**Result:** eax = length of the path without 0; 0 if the file is not found

## SetConsoleCtrlHandler – catch Ctrl+C and closing

kernel32.dll · stdcall · 2 parameters (8 bytes)

**Call:** `SetConsoleCtrlHandler(HandlerRoutine, Add)`

- HandlerRoutine: PHANDLER_ROUTINE – own function (stdcall, 1 parameter: `0` CTRL_C_EVENT, `1` CTRL_BREAK_EVENT, `2` CTRL_CLOSE_EVENT, `5` CTRL_LOGOFF_EVENT, `6` CTRL_SHUTDOWN_EVENT); result 1 = handled, 0 = next handler. 0 as function with Add = 1: Ctrl+C is ignored
- Add: BOOL – 1 add, 0 remove

**Result:** eax = 1 on success, 0 on error

The function runs in a thread of its own in the process.

## GlobalMemoryStatus – memory configuration (old)

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `GlobalMemoryStatus(lpBuffer)`

- lpBuffer: LPMEMORYSTATUS – structure of 32 bytes: dwLength (set to 32 before), memory load in percent, physical memory total and free, page file total and free, virtual address space total and free (all in bytes, limited to 4 GB if there is more)

**Result:** none

## LocalReAlloc, GlobalReAlloc – change memory (old)

kernel32.dll · stdcall · 3 parameters (12 bytes)

**Call:** `LocalReAlloc(hMem, uBytes, uFlags)`

- hMem: HLOCAL – a block from `LocalAlloc`
- uBytes: SIZE_T – the new size
- uFlags: UINT – `0x2` LMEM_MOVEABLE (may be moved), `0x40` LMEM_ZEROINIT (new part with zeros), `0x80` LMEM_MODIFY (change only the properties)

**Result:** eax = address (or handle) of the block; 0 on error

## SetHandleCount – number of handles (obsolete)

kernel32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `SetHandleCount(uNumber)`

- uNumber: UINT – wanted number of file handles

**Result:** eax = uNumber

Without effect since Windows NT; older runtime libraries call it at startup.

## GetStringTypeW – character classes of a UTF-16 text

kernel32.dll · stdcall · 4 parameters (16 bytes)

**Call:** `GetStringTypeW(dwInfoType, lpSrcStr, cchSrc, lpCharType)`

- dwInfoType: DWORD – `1` CT_CTYPE1 (letter, digit, ...), `2` CT_CTYPE2 (writing direction), `4` CT_CTYPE3
- lpSrcStr: LPCWSTR – the text
- cchSrc: int – its length in characters; `-1`: up to the 0
- lpCharType: LPWORD – one word per character (bits as for `GetStringTypeExA`)

**Result:** eax = 1 on success, 0 on error

No language needed: the classes apply to Unicode.

## IsCharAlphaA, IsCharAlphaW, IsCharAlphaNumericA, IsCharAlphaNumericW – letter or digit?

user32.dll · stdcall · 1 parameter (4 bytes)

**Call:** `IsCharAlphaNumericA(ch)`

- ch: CHAR – the character (A form: the lowest byte; W form: a UTF-16 character)

**Result:** eax = not 0 if it is a letter or a digit (`IsCharAlpha...`: letter only), else 0

Knows the umlauts of the language of the user.

## IsDBCSLeadByte, IsDBCSLeadByteEx – first byte of a double-byte character?

kernel32.dll · stdcall · 1 parameter (4 bytes); `IsDBCSLeadByteEx` 2

**Call:** `IsDBCSLeadByteEx(CodePage, TestChar)`

- CodePage: UINT – the code page (`0` the one of Windows); not with `IsDBCSLeadByte`
- TestChar: BYTE – the byte

**Result:** eax = 1 if the byte is the start of a character of 2 bytes (e.g. in Japanese), else 0

Always 0 in Western European code pages. Delphi builds its table `LeadBytes` with it.

## LCMapStringA, LCMapStringW – convert text by language

kernel32.dll · stdcall · 6 parameters (24 bytes)

**Call:** `LCMapStringA(Locale, dwMapFlags, lpSrcStr, cchSrc, lpDestStr, cchDest)`

- Locale: LCID – the language (`0x400` LOCALE_USER_DEFAULT)
- dwMapFlags: DWORD – `0x100` LCMAP_LOWERCASE, `0x200` LCMAP_UPPERCASE, `0x400` LCMAP_SORTKEY (sort key), plus `0x1` NORM_IGNORECASE
- lpSrcStr: LPCSTR – the text
- cchSrc: int – its length; `-1`: up to the 0
- lpDestStr: LPSTR – the buffer
- cchDest: int – its size; 0: only determine the needed size

**Result:** eax = number of characters written (or needed); 0 on error

Converts umlauts correctly (`ä` to `Ä`), unlike `and 0xDF`.
