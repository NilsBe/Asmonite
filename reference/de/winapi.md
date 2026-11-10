# Windows-Funktionen (Importe)

Die Befehlsinfo von Dismonite (F1) zeigt zu einer Zeile, die eine importierte Funktion
benutzt (`call [ExitProcess]`, der Eintrag der Importtabelle, ARM: `ldr r3, =ExitProcess`),
den Abschnitt der Funktion: DLL, Aufrufkonvention, Parameter in der Reihenfolge der
C-Deklaration, Ergebnis und eine kurze Erklärung. Jeder Abschnitt beginnt mit `## ` und
den Namen (die A- und W-Form zusammen).

## !calling

**Aufrufkonvention.** Fast alle Windows-Funktionen sind `stdcall`: Die Parameter werden
mit `push` von rechts nach links auf den Stack gelegt (der erste Parameter zuletzt), die
Funktion räumt sie selbst wieder ab (`ret 16` bei 4 Parametern). Das Ergebnis steht in
`eax` (64 Bit: `edx:eax`). `eax`, `ecx` und `edx` dürfen verändert sein, `ebx`, `esi`,
`edi`, `ebp` und `esp` sind danach wie vorher.

Die C-Laufzeit (`msvcrt.dll`, `api-ms-win-crt-*.dll`) ist `cdecl`: gleiche Reihenfolge,
aber der Aufrufer räumt den Stack ab (`add esp, 8` nach zwei Parametern). Nur so geht
`printf` mit beliebig vielen Parametern.

ARM (Thumb): die ersten vier Parameter in `r0` bis `r3`, weitere auf dem Stack, Ergebnis
in `r0`; aufgerufen mit `blx` über die Adresse aus der Importtabelle.

Alle Parameter sind 4 Bytes groß (Zahlen, Handles, Zeiger); `LARGE_INTEGER` und
`FILETIME` sind 8 Bytes. Ein Fehler meldet sich meist als Ergebnis 0, `-1`
(`INVALID_HANDLE_VALUE`) oder `FALSE`; `GetLastError` sagt dann, welcher.

## !import

**Importierte Funktion** `{name}` aus `{dll}`.

Zu dieser Funktion gibt es noch keinen Abschnitt in `help\de\winapi.md`.

## ExitProcess – Prozess beenden

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `ExitProcess(uExitCode)`

- uExitCode: UINT – der Rückgabewert des Programms (`%ERRORLEVEL%`, 0 = gut)

**Ergebnis:** kehrt nicht zurück

Beendet den Prozess mit allen Threads; offene Handles schließt Windows. Der übliche
letzte Aufruf eines Assemblerprogramms.

```asm
push 0
call [ExitProcess]
```

## GetStdHandle – Standard-Handle holen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetStdHandle(nStdHandle)`

- nStdHandle: DWORD – `-10` Eingabe (STD_INPUT_HANDLE), `-11` Ausgabe (STD_OUTPUT_HANDLE), `-12` Fehlerausgabe (STD_ERROR_HANDLE)

**Ergebnis:** eax = Handle der Konsole oder Umleitung; `-1` bei Fehler, 0 ohne Konsole

Das Handle für `WriteFile`, `ReadFile`, `WriteConsoleA`. Es muss nicht geschlossen werden.

```asm
push -11
call [GetStdHandle]
mov [hOut], eax
```

## WriteFile – in Datei oder Konsole schreiben

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `WriteFile(hFile, lpBuffer, nBytes, lpWritten, lpOverlapped)`

- hFile: HANDLE – Datei, Pipe oder Konsole (`GetStdHandle`, `CreateFileA`)
- lpBuffer: LPCVOID – die Bytes
- nBytes: DWORD – wie viele
- lpWritten: LPDWORD – Adresse eines Doppelworts für die geschriebene Anzahl (darf 0 sein, wenn lpOverlapped gesetzt ist)
- lpOverlapped: LPOVERLAPPED – 0 (synchron)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler (`GetLastError`)

Schreibt rohe Bytes, auch Text ohne Umwandlung. Für die Konsole gilt die OEM-Codepage.

```asm
push 0
push written
push 13
push text
push [hOut]
call [WriteFile]
```

## ReadFile – aus Datei oder Konsole lesen

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `ReadFile(hFile, lpBuffer, nBytes, lpRead, lpOverlapped)`

- hFile: HANDLE – Datei, Pipe oder Konsoleneingabe
- lpBuffer: LPVOID – der Puffer
- nBytes: DWORD – höchstens so viele Bytes
- lpRead: LPDWORD – die gelesene Anzahl (0 am Dateiende)
- lpOverlapped: LPOVERLAPPED – 0 (synchron)

**Ergebnis:** eax = 1 bei Erfolg (auch am Dateiende mit 0 Bytes), 0 bei Fehler

Von der Konsole liest es eine Zeile samt `0x0D 0x0A`, wenn die Eingabe-Taste gedrückt wird.

## CreateFileA, CreateFileW – Datei öffnen oder anlegen

kernel32.dll · stdcall · 7 Parameter (28 Bytes)

**Aufruf:** `CreateFileA(lpFileName, dwAccess, dwShareMode, lpSecurity, dwCreation, dwFlags, hTemplate)`

- lpFileName: LPCSTR – Pfad, 0-terminiert
- dwAccess: DWORD – `0x80000000` GENERIC_READ, `0x40000000` GENERIC_WRITE (auch beide)
- dwShareMode: DWORD – `1` FILE_SHARE_READ, `2` FILE_SHARE_WRITE, 0 exklusiv
- lpSecurity: LPSECURITY_ATTRIBUTES – 0
- dwCreation: DWORD – `1` CREATE_NEW, `2` CREATE_ALWAYS, `3` OPEN_EXISTING, `4` OPEN_ALWAYS, `5` TRUNCATE_EXISTING
- dwFlags: DWORD – `0x80` FILE_ATTRIBUTE_NORMAL
- hTemplate: HANDLE – 0

**Ergebnis:** eax = Handle; `-1` (INVALID_HANDLE_VALUE) bei Fehler

Öffnet auch Geräte wie `CONOUT$` und `COM1`. Schließen mit `CloseHandle`.

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

## CloseHandle – Handle schließen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `CloseHandle(hObject)`

- hObject: HANDLE – Datei, Ereignis, Thread, Prozess, ... (nicht die Standard-Handles)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Gibt das Objekt frei; eine Datei wird dabei geschrieben und freigegeben.

## GetFileSize – Dateigröße

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetFileSize(hFile, lpSizeHigh)`

- hFile: HANDLE – offene Datei
- lpSizeHigh: LPDWORD – Adresse für die oberen 32 Bit oder 0

**Ergebnis:** eax = untere 32 Bit der Größe; `0xFFFFFFFF` bei Fehler (dann `GetLastError` prüfen, wenn lpSizeHigh gesetzt war)

## SetFilePointer – Dateiposition setzen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `SetFilePointer(hFile, lDistance, lpDistanceHigh, dwMoveMethod)`

- hFile: HANDLE – offene Datei
- lDistance: LONG – Verschiebung in Bytes (mit Vorzeichen)
- lpDistanceHigh: PLONG – obere 32 Bit oder 0
- dwMoveMethod: DWORD – `0` FILE_BEGIN, `1` FILE_CURRENT, `2` FILE_END

**Ergebnis:** eax = neue Position (untere 32 Bit); `0xFFFFFFFF` bei Fehler

## SetEndOfFile – Datei hier abschneiden

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetEndOfFile(hFile)`

- hFile: HANDLE – offene Datei mit Schreibrecht

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Macht die aktuelle Dateiposition (`SetFilePointer`) zum Dateiende: kürzt oder verlängert.

## FlushFileBuffers – Puffer auf die Platte schreiben

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `FlushFileBuffers(hFile)`

- hFile: HANDLE – offene Datei

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetFileType – Art eines Handles

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetFileType(hFile)`

- hFile: HANDLE – ein Handle von `CreateFileA` oder `GetStdHandle`

**Ergebnis:** eax = `1` Datei (FILE_TYPE_DISK), `2` Konsole oder Gerät (FILE_TYPE_CHAR), `3` Pipe (FILE_TYPE_PIPE), `0` unbekannt oder Fehler

So erkennt ein Programm, ob seine Ausgabe in eine Datei umgeleitet ist.

## GetFileAttributesA, GetFileAttributesW – Dateiattribute lesen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetFileAttributesA(lpFileName)`

- lpFileName: LPCSTR – Pfad

**Ergebnis:** eax = Attribute (`0x10` Verzeichnis, `0x01` schreibgeschützt, `0x02` versteckt, `0x80` normal); `0xFFFFFFFF`, wenn es die Datei nicht gibt

Der einfachste Test, ob eine Datei existiert.

## DeleteFileA, DeleteFileW – Datei löschen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `DeleteFileA(lpFileName)`

- lpFileName: LPCSTR – Pfad

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetFullPathNameA, GetFullPathNameW – vollständiger Pfad

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `GetFullPathNameA(lpFileName, nBufferLength, lpBuffer, lpFilePart)`

- lpFileName: LPCSTR – ein (relativer) Pfad
- nBufferLength: DWORD – Größe des Puffers in Zeichen
- lpBuffer: LPSTR – der Puffer für den vollständigen Pfad
- lpFilePart: LPSTR* – Adresse eines Zeigers, der auf den Dateinamen im Puffer gesetzt wird, oder 0

**Ergebnis:** eax = Länge des Pfads ohne 0; 0 bei Fehler; größer als nBufferLength: der Puffer war zu klein

## GetTempPathA, GetTempPathW – Ordner für temporäre Dateien

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetTempPathA(nBufferLength, lpBuffer)`

- nBufferLength: DWORD – Größe des Puffers in Zeichen
- lpBuffer: LPSTR – der Puffer

**Ergebnis:** eax = Länge des Pfads (endet mit `\`); 0 bei Fehler

## GetDiskFreeSpaceA, GetDiskFreeSpaceW – freier Platz eines Laufwerks

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `GetDiskFreeSpaceA(lpRootPath, lpSectorsPerCluster, lpBytesPerSector, lpFreeClusters, lpTotalClusters)`

- lpRootPath: LPCSTR – `C:\` oder 0 für das aktuelle Laufwerk
- lpSectorsPerCluster, lpBytesPerSector, lpFreeClusters, lpTotalClusters: LPDWORD – Adressen für die vier Werte

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Freier Platz = freie Cluster mal Sektoren je Cluster mal Bytes je Sektor.

## FindFirstFileA, FindFirstFileW – Dateisuche beginnen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `FindFirstFileA(lpFileName, lpFindFileData)`

- lpFileName: LPCSTR – Muster mit `*` und `?`, z. B. `*.asm`
- lpFindFileData: LPWIN32_FIND_DATAA – Struktur von 320 Bytes: Attribute, drei Zeiten, Größe (hoch, niedrig), Name ab Offset 44

**Ergebnis:** eax = Such-Handle für `FindNextFileA` und `FindClose`; `-1`, wenn nichts passt

## FindNextFileA, FindNextFileW – nächste Datei der Suche

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `FindNextFileA(hFindFile, lpFindFileData)`

- hFindFile: HANDLE – von `FindFirstFileA`
- lpFindFileData: LPWIN32_FIND_DATAA – die Struktur wie dort

**Ergebnis:** eax = 1 gefunden, 0 keine weitere (`GetLastError` = 18, ERROR_NO_MORE_FILES)

## FindClose – Dateisuche beenden

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `FindClose(hFindFile)`

- hFindFile: HANDLE – von `FindFirstFileA`

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## WriteConsoleA, WriteConsoleW – Text auf die Konsole

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `WriteConsoleA(hConsoleOutput, lpBuffer, nChars, lpWritten, lpReserved)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- lpBuffer: LPCVOID – der Text
- nChars: DWORD – Anzahl Zeichen
- lpWritten: LPDWORD – die geschriebene Anzahl (darf 0 sein)
- lpReserved: LPVOID – 0

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Wie `WriteFile`, aber nur für eine echte Konsole: Bei einer Umleitung in eine Datei scheitert es.

## ReadConsoleA, ReadConsoleW – Zeile von der Konsole

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `ReadConsoleA(hConsoleInput, lpBuffer, nChars, lpRead, pInputControl)`

- hConsoleInput: HANDLE – `GetStdHandle(-10)`
- lpBuffer: LPVOID – der Puffer
- nChars: DWORD – höchstens so viele Zeichen
- lpRead: LPDWORD – die gelesene Anzahl, samt `0x0D 0x0A` am Ende
- pInputControl: PCONSOLE_READCONSOLE_CONTROL – 0

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## SetConsoleTextAttribute – Farben der Konsole

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetConsoleTextAttribute(hConsoleOutput, wAttributes)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- wAttributes: WORD – Vordergrund Bits 0..3 (1 blau, 2 grün, 4 rot, 8 hell), Hintergrund Bits 4..7; `0x07` ist hellgrau auf schwarz

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## SetConsoleCursorPosition – Cursor der Konsole setzen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetConsoleCursorPosition(hConsoleOutput, dwCursorPosition)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- dwCursorPosition: COORD – Spalte in den unteren 16 Bit, Zeile in den oberen (eine Struktur von 4 Bytes, als Wert übergeben)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetConsoleScreenBufferInfo – Größe und Cursor der Konsole

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetConsoleScreenBufferInfo(hConsoleOutput, lpInfo)`

- hConsoleOutput: HANDLE – `GetStdHandle(-11)`
- lpInfo: PCONSOLE_SCREEN_BUFFER_INFO – Struktur von 22 Bytes: Größe (Spalten, Zeilen), Cursorposition, Attribute, sichtbares Fenster, größte Größe

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## SetConsoleTitleA, SetConsoleTitleW – Titel des Konsolenfensters

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetConsoleTitleA(lpConsoleTitle)`

- lpConsoleTitle: LPCSTR – der Titel

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## AllocConsole, FreeConsole – Konsole anlegen und abgeben

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `AllocConsole()`, `FreeConsole()`

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Ein Fensterprogramm (Subsystem GUI) bekommt mit `AllocConsole` ein Konsolenfenster; danach gelten `GetStdHandle` und `WriteConsoleA`.

## GetCommandLineA, GetCommandLineW – die Befehlszeile

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetCommandLineA()`

**Ergebnis:** eax = Zeiger auf die ganze Befehlszeile, 0-terminiert, mit dem Programmnamen vorn

Die Zeile muss das Programm selbst zerlegen (Anführungszeichen beachten).

## GetEnvironmentVariableA, GetEnvironmentVariableW – Umgebungsvariable lesen

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `GetEnvironmentVariableA(lpName, lpBuffer, nSize)`

- lpName: LPCSTR – der Name, z. B. `PATH`
- lpBuffer: LPSTR – der Puffer
- nSize: DWORD – seine Größe in Zeichen

**Ergebnis:** eax = Länge des Werts; 0, wenn es die Variable nicht gibt; größer als nSize: nötige Größe

## GetModuleHandleA, GetModuleHandleW – Basisadresse eines Moduls

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetModuleHandleA(lpModuleName)`

- lpModuleName: LPCSTR – Name einer geladenen DLL oder 0 für das Programm selbst

**Ergebnis:** eax = HMODULE = die Adresse, an der das Modul im Speicher liegt (`.imagebase`, meist `0x400000`); 0, wenn es nicht geladen ist

Fensterprogramme brauchen das Handle für `RegisterClassExA` und `CreateWindowExA`.

## GetModuleFileNameA, GetModuleFileNameW – Pfad eines Moduls

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `GetModuleFileNameA(hModule, lpFilename, nSize)`

- hModule: HMODULE – 0 für das Programm selbst
- lpFilename: LPSTR – der Puffer
- nSize: DWORD – seine Größe in Zeichen

**Ergebnis:** eax = Länge des Pfads; 0 bei Fehler

## LoadLibraryA, LoadLibraryW – DLL laden

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `LoadLibraryA(lpLibFileName)`

- lpLibFileName: LPCSTR – Dateiname der DLL, mit oder ohne Pfad

**Ergebnis:** eax = HMODULE der DLL; 0 bei Fehler

Lädt eine DLL erst zur Laufzeit; ihre Funktionen holt `GetProcAddress`. Zurückgeben mit `FreeLibrary`.

## LoadLibraryExA, LoadLibraryExW – DLL laden mit Optionen

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `LoadLibraryExA(lpLibFileName, hFile, dwFlags)`

- lpLibFileName: LPCSTR – Dateiname der DLL
- hFile: HANDLE – 0 (reserviert)
- dwFlags: DWORD – 0 wie `LoadLibraryA`; `2` LOAD_LIBRARY_AS_DATAFILE (nur Ressourcen, kein Code); `8` LOAD_WITH_ALTERED_SEARCH_PATH

**Ergebnis:** eax = HMODULE; 0 bei Fehler

## FreeLibrary – DLL zurückgeben

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `FreeLibrary(hLibModule)`

- hLibModule: HMODULE – von `LoadLibraryA`

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetProcAddress – Adresse einer DLL-Funktion

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetProcAddress(hModule, lpProcName)`

- hModule: HMODULE – von `LoadLibraryA` oder `GetModuleHandleA`
- lpProcName: LPCSTR – der Name der Funktion (Groß-/Kleinschreibung zählt) oder eine Ordinalzahl in den unteren 16 Bit

**Ergebnis:** eax = Adresse der Funktion, zum Aufruf mit `call eax`; 0, wenn es sie nicht gibt

So ruft man Funktionen, die nicht in der Importtabelle stehen.

```asm
push name
push [hDll]
call [GetProcAddress]
mov [pFunc], eax
```

## GetLastError – letzter Fehlercode

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetLastError()`

**Ergebnis:** eax = der Fehlercode des letzten gescheiterten Aufrufs in diesem Thread: `2` Datei nicht gefunden, `5` Zugriff verweigert, `6` ungültiges Handle, `32` von einem anderen Prozess benutzt, `87` falscher Parameter, `183` existiert schon

Sofort nach dem gescheiterten Aufruf lesen; ein weiterer Aufruf kann ihn überschreiben. `FormatMessageA` macht Text daraus.

## SetLastError – Fehlercode setzen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetLastError(dwErrCode)`

- dwErrCode: DWORD – der Code

**Ergebnis:** keins

## FormatMessageA, FormatMessageW – Text zu einem Fehlercode

kernel32.dll · stdcall · 7 Parameter (28 Bytes)

**Aufruf:** `FormatMessageA(dwFlags, lpSource, dwMessageId, dwLanguageId, lpBuffer, nSize, Arguments)`

- dwFlags: DWORD – `0x1000` FORMAT_MESSAGE_FROM_SYSTEM (Windows-Fehler), dazu `0x200` IGNORE_INSERTS; `0x100` ALLOCATE_BUFFER legt den Puffer selbst an (dann lpBuffer = Adresse eines Zeigers, Freigabe mit `LocalFree`)
- lpSource: LPCVOID – 0 bei FROM_SYSTEM
- dwMessageId: DWORD – der Code von `GetLastError`
- dwLanguageId: DWORD – 0 (Sprache des Benutzers)
- lpBuffer: LPSTR – der Puffer
- nSize: DWORD – Größe in Zeichen
- Arguments: va_list* – 0

**Ergebnis:** eax = Länge des Texts; 0 bei Fehler

## GetVersion – Windows-Version (alt)

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetVersion()`

**Ergebnis:** eax = Hauptversion im niedrigsten Byte, Nebenversion im zweiten, Build in den oberen 16 Bit (Bit 31 = 0 bei Windows NT)

Seit Windows 8.1 meldet sie für Programme ohne Manifest 6.2. Delphi-Programme rufen sie beim Start.

## GetVersionExA, GetVersionExW – Windows-Version (Struktur)

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetVersionExA(lpVersionInfo)`

- lpVersionInfo: LPOSVERSIONINFOA – Struktur von 148 Bytes, das erste Doppelwort vorher auf 148 setzen; danach Haupt-, Nebenversion, Build, Plattform (`2` = NT), Service-Pack-Text

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetNativeSystemInfo, GetSystemInfo – Prozessor und Speicher

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetNativeSystemInfo(lpSystemInfo)`

- lpSystemInfo: LPSYSTEM_INFO – Struktur von 36 Bytes: Architektur (Wort am Anfang: `0` x86, `5` ARM, `9` x64, `12` ARM64), Seitengröße, kleinste und größte Adresse, Anzahl Prozessoren

**Ergebnis:** keins

`GetNativeSystemInfo` sagt die echte Architektur auch unter Emulation (x86-Programm auf ARM64); `GetSystemInfo` die emulierte.

## GetStartupInfoA, GetStartupInfoW – Startinformationen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetStartupInfoA(lpStartupInfo)`

- lpStartupInfo: LPSTARTUPINFOA – Struktur von 68 Bytes: Fenstertitel, Position, Größe, `wShowWindow` (Offset 48), Standard-Handles, wie der Elternprozess sie übergab

**Ergebnis:** keins

Delphi-Programme rufen sie beim Start, um `ShowWindow` zu bestimmen.

## GetCurrentProcess, GetCurrentProcessId – der eigene Prozess

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetCurrentProcess()`, `GetCurrentProcessId()`

**Ergebnis:** eax = Pseudo-Handle `-1` für den eigenen Prozess (nicht schließen) bzw. die Prozessnummer (PID)

## GetCurrentThread, GetCurrentThreadId – der eigene Thread

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetCurrentThread()`, `GetCurrentThreadId()`

**Ergebnis:** eax = Pseudo-Handle `-2` für den eigenen Thread bzw. die Threadnummer (TID)

## TerminateProcess – Prozess abbrechen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `TerminateProcess(hProcess, uExitCode)`

- hProcess: HANDLE – der Prozess (`GetCurrentProcess` für den eigenen)
- uExitCode: UINT – der Rückgabewert

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler (kehrt für den eigenen Prozess nicht zurück)

Härter als `ExitProcess`: keine DLL wird benachrichtigt.

## CreateProcessA, CreateProcessW – Programm starten

kernel32.dll · stdcall · 10 Parameter (40 Bytes)

**Aufruf:** `CreateProcessA(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation)`

- lpApplicationName: LPCSTR – Pfad der EXE oder 0 (dann steht sie vorn in lpCommandLine)
- lpCommandLine: LPSTR – die Befehlszeile (veränderbarer Puffer)
- lpProcessAttributes, lpThreadAttributes: LPSECURITY_ATTRIBUTES – 0
- bInheritHandles: BOOL – 1: der neue Prozess erbt die Handles
- dwCreationFlags: DWORD – 0; `0x10` CREATE_NEW_CONSOLE; `0x8000000` CREATE_NO_WINDOW
- lpEnvironment: LPVOID – 0 (die eigene Umgebung)
- lpCurrentDirectory: LPCSTR – 0 (das eigene Verzeichnis)
- lpStartupInfo: LPSTARTUPINFOA – Struktur von 68 Bytes, das erste Doppelwort = 68, der Rest 0
- lpProcessInformation: LPPROCESS_INFORMATION – 16 Bytes: Prozess-Handle, Thread-Handle, PID, TID

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Beide Handles mit `CloseHandle` schließen; `WaitForSingleObject` auf das Prozess-Handle wartet auf das Ende.

## Sleep – warten

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `Sleep(dwMilliseconds)`

- dwMilliseconds: DWORD – Wartezeit in Millisekunden; 0 gibt nur den Prozessor ab

**Ergebnis:** keins

## GetTickCount – Millisekunden seit dem Start von Windows

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetTickCount()`

**Ergebnis:** eax = Millisekunden seit dem Systemstart (läuft nach 49,7 Tagen über)

Für Zeitmessungen die Differenz zweier Aufrufe; die Auflösung ist etwa 16 ms.

## QueryPerformanceCounter, QueryPerformanceFrequency – feiner Zähler

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `QueryPerformanceCounter(lpCount)`, `QueryPerformanceFrequency(lpFrequency)`

- lpCount, lpFrequency: LARGE_INTEGER* – Adresse von 8 Bytes für den Zählerstand bzw. die Schritte pro Sekunde

**Ergebnis:** eax = 1 bei Erfolg

Zeit in Sekunden = Differenz der Zählerstände geteilt durch die Frequenz.

## GetLocalTime, GetSystemTime – Datum und Uhrzeit

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetLocalTime(lpSystemTime)`

- lpSystemTime: LPSYSTEMTIME – Struktur von 16 Bytes, je ein Wort: Jahr, Monat, Wochentag (0 = Sonntag), Tag, Stunde, Minute, Sekunde, Millisekunde

**Ergebnis:** keins

`GetLocalTime` in der Zeitzone des Rechners, `GetSystemTime` in UTC.

## GetDateFormatA, GetDateFormatW – Datum als Text

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `GetDateFormatA(Locale, dwFlags, lpDate, lpFormat, lpDateStr, cchDate)`

- Locale: LCID – `0x400` LOCALE_USER_DEFAULT
- dwFlags: DWORD – `1` DATE_SHORTDATE, `2` DATE_LONGDATE; 0 mit eigenem Format
- lpDate: SYSTEMTIME* – das Datum oder 0 für heute
- lpFormat: LPCSTR – Muster wie `dd.MM.yyyy` oder 0
- lpDateStr: LPSTR – der Puffer
- cchDate: int – seine Größe in Zeichen (0: nur die nötige Größe ermitteln)

**Ergebnis:** eax = Anzahl Zeichen samt 0; 0 bei Fehler

## GetThreadLocale – Sprache des Threads

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetThreadLocale()`

**Ergebnis:** eax = LCID (`0x407` Deutsch, `0x409` Englisch USA)

## GetLocaleInfoA, GetLocaleInfoW – Einstellung einer Sprache

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `GetLocaleInfoA(Locale, LCType, lpLCData, cchData)`

- Locale: LCID – von `GetThreadLocale` oder `0x400`
- LCType: LCTYPE – was: `0x0E` LOCALE_SDECIMAL (Dezimaltrenner), `0x0F` LOCALE_STHOUSAND, `0x1D` LOCALE_SDATE, `0x1E` LOCALE_STIME, `0x1F` LOCALE_SSHORTDATE, `0x20` LOCALE_SLONGDATE
- lpLCData: LPSTR – der Puffer
- cchData: int – seine Größe in Zeichen

**Ergebnis:** eax = Anzahl Zeichen samt 0; 0 bei Fehler

Delphi liest so die Formate für `DateToStr` und `FloatToStr`.

## EnumCalendarInfoA, EnumCalendarInfoW – Kalendernamen aufzählen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `EnumCalendarInfoA(lpCalInfoEnumProc, Locale, Calendar, CalType)`

- lpCalInfoEnumProc: CALINFO_ENUMPROCA – eine eigene Funktion, die je Eintrag mit dem Text aufgerufen wird (stdcall, 1 Parameter; Ergebnis 1 = weiter)
- Locale: LCID – die Sprache
- Calendar: CALID – `1` CAL_GREGORIAN, `0xFFFFFFFF` alle
- CalType: CALTYPE – `0x15` CAL_SMONTHNAME1 (Monatsnamen ab Januar), `0x07` CAL_SDAYNAME1 (Wochentage), ...

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Delphi füllt so die Monats- und Tagesnamen.

## GetACP, GetOEMCP – Codepage von Windows und Konsole

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetACP()`, `GetOEMCP()`

**Ergebnis:** eax = Codepage (`1252` Westeuropa Windows, `850` oder `437` DOS/Konsole, `65001` UTF-8)

## GetCPInfo – Eigenschaften einer Codepage

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetCPInfo(CodePage, lpCPInfo)`

- CodePage: UINT – die Codepage (`0` CP_ACP = die von Windows)
- lpCPInfo: LPCPINFO – Struktur von 20 Bytes: größte Zeichenlänge in Bytes, Ersatzzeichen, Lead-Byte-Bereiche

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## MultiByteToWideChar – Text nach UTF-16 wandeln

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `MultiByteToWideChar(CodePage, dwFlags, lpMultiByteStr, cbMultiByte, lpWideCharStr, cchWideChar)`

- CodePage: UINT – Codepage des Quelltexts (`0` CP_ACP, `65001` CP_UTF8)
- dwFlags: DWORD – 0 oder `1` MB_PRECOMPOSED
- lpMultiByteStr: LPCSTR – der Quelltext
- cbMultiByte: int – seine Länge in Bytes; `-1`: bis zur 0 samt 0
- lpWideCharStr: LPWSTR – der Puffer für UTF-16 (je 2 Bytes)
- cchWideChar: int – seine Größe in Zeichen; 0: nur die nötige Größe ermitteln

**Ergebnis:** eax = Anzahl geschriebener (oder nötiger) Zeichen; 0 bei Fehler

## WideCharToMultiByte – UTF-16 nach Text wandeln

kernel32.dll · stdcall · 8 Parameter (32 Bytes)

**Aufruf:** `WideCharToMultiByte(CodePage, dwFlags, lpWideCharStr, cchWideChar, lpMultiByteStr, cbMultiByte, lpDefaultChar, lpUsedDefaultChar)`

- CodePage: UINT – Codepage des Ziels
- dwFlags: DWORD – 0
- lpWideCharStr: LPCWSTR – der UTF-16-Text
- cchWideChar: int – seine Länge in Zeichen; `-1`: bis zur 0 samt 0
- lpMultiByteStr: LPSTR – der Puffer
- cbMultiByte: int – seine Größe in Bytes; 0: nur die nötige Größe ermitteln
- lpDefaultChar: LPCSTR – Ersatz für nicht darstellbare Zeichen oder 0 (`?`)
- lpUsedDefaultChar: LPBOOL – Adresse eines Flags, ob der Ersatz gebraucht wurde, oder 0

**Ergebnis:** eax = Anzahl geschriebener (oder nötiger) Bytes; 0 bei Fehler

## CompareStringA, CompareStringW – Texte nach Sprache vergleichen

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `CompareStringA(Locale, dwCmpFlags, lpString1, cchCount1, lpString2, cchCount2)`

- Locale: LCID – die Sprache (`0x400` LOCALE_USER_DEFAULT)
- dwCmpFlags: DWORD – 0; `1` NORM_IGNORECASE
- lpString1, lpString2: LPCSTR – die Texte
- cchCount1, cchCount2: int – ihre Längen; `-1`: bis zur 0

**Ergebnis:** eax = `1` kleiner (CSTR_LESS_THAN), `2` gleich, `3` größer; 0 bei Fehler

Sortiert wie ein Wörterbuch (Umlaute bei ihren Grundbuchstaben), anders als ein Bytevergleich.

## GetStringTypeExA, GetStringTypeExW – Zeichenklassen eines Texts

kernel32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `GetStringTypeExA(Locale, dwInfoType, lpSrcStr, cchSrc, lpCharType)`

- Locale: LCID – die Sprache
- dwInfoType: DWORD – `1` CT_CTYPE1 (Buchstabe, Ziffer, Leerzeichen, ...)
- lpSrcStr: LPCSTR – der Text
- cchSrc: int – seine Länge; `-1`: bis zur 0
- lpCharType: LPWORD – ein Wort je Zeichen: Bit 0 Großbuchstabe (C1_UPPER), Bit 1 Kleinbuchstabe, Bit 2 Ziffer, Bit 3 Leerraum, Bit 4 Satzzeichen, Bit 8 Buchstabe (C1_ALPHA)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Delphi baut so seine Tabellen für `UpperCase` und `IsCharAlpha`.

## lstrlenA, lstrlenW – Länge eines Texts

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `lstrlenA(lpString)`

- lpString: LPCSTR – 0-terminierter Text (0 erlaubt: Ergebnis 0)

**Ergebnis:** eax = Anzahl Zeichen ohne die 0

Wie `strlen`, aber ohne C-Laufzeit.

## lstrcpyA, lstrcpyW – Text kopieren

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `lstrcpyA(lpString1, lpString2)`

- lpString1: LPSTR – das Ziel (groß genug)
- lpString2: LPCSTR – die Quelle, 0-terminiert

**Ergebnis:** eax = lpString1; 0 bei Fehler

## lstrcpynA, lstrcpynW – Text kopieren, begrenzt

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `lstrcpynA(lpString1, lpString2, iMaxLength)`

- lpString1: LPSTR – das Ziel
- lpString2: LPCSTR – die Quelle
- iMaxLength: int – Größe des Ziels in Zeichen samt der 0

**Ergebnis:** eax = lpString1; 0 bei Fehler

Kopiert höchstens iMaxLength - 1 Zeichen und schreibt immer eine 0 ans Ende.

## lstrcatA, lstrcatW – Text anhängen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `lstrcatA(lpString1, lpString2)`

- lpString1: LPSTR – der Text, an den angehängt wird (groß genug)
- lpString2: LPCSTR – was angehängt wird

**Ergebnis:** eax = lpString1; 0 bei Fehler

## lstrcmpA, lstrcmpW, lstrcmpiA, lstrcmpiW – Texte vergleichen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `lstrcmpA(lpString1, lpString2)`

- lpString1, lpString2: LPCSTR – die Texte

**Ergebnis:** eax = negativ, 0 oder positiv, wenn der erste kleiner, gleich oder größer ist; `lstrcmpi` ohne Groß-/Kleinschreibung

Vergleicht nach der Sprache des Benutzers wie `CompareStringA`.

## HeapAlloc – Speicher vom Heap

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `HeapAlloc(hHeap, dwFlags, dwBytes)`

- hHeap: HANDLE – von `GetProcessHeap` oder `HeapCreate`
- dwFlags: DWORD – 0; `8` HEAP_ZERO_MEMORY (mit Nullen gefüllt)
- dwBytes: SIZE_T – Anzahl Bytes

**Ergebnis:** eax = Adresse des Blocks; 0, wenn kein Speicher da ist

Freigeben mit `HeapFree`. Der Block ist auf 8 Bytes ausgerichtet.

```asm
push 100
push 8
push [hHeap]
call [HeapAlloc]
```

## HeapReAlloc – Heap-Block vergrößern oder verkleinern

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `HeapReAlloc(hHeap, dwFlags, lpMem, dwBytes)`

- hHeap: HANDLE – der Heap
- dwFlags: DWORD – 0; `8` HEAP_ZERO_MEMORY für den neuen Teil; `0x10` HEAP_REALLOC_IN_PLACE_ONLY
- lpMem: LPVOID – der Block von `HeapAlloc`
- dwBytes: SIZE_T – die neue Größe

**Ergebnis:** eax = Adresse des Blocks (kann eine andere sein, der Inhalt ist kopiert); 0 bei Fehler

## HeapFree – Heap-Block freigeben

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `HeapFree(hHeap, dwFlags, lpMem)`

- hHeap: HANDLE – der Heap, aus dem der Block kam
- dwFlags: DWORD – 0
- lpMem: LPVOID – der Block

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## GetProcessHeap – der Standard-Heap

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetProcessHeap()`

**Ergebnis:** eax = Handle des Heaps, den jeder Prozess von Anfang an hat (nicht schließen)

## HeapCreate, HeapDestroy – eigener Heap

kernel32.dll · stdcall · 3 Parameter (12 Bytes) / 1 Parameter

**Aufruf:** `HeapCreate(flOptions, dwInitialSize, dwMaximumSize)`, `HeapDestroy(hHeap)`

- flOptions: DWORD – 0; `1` HEAP_NO_SERIALIZE (nur ein Thread); `4` HEAP_GENERATE_EXCEPTIONS
- dwInitialSize: SIZE_T – Anfangsgröße in Bytes (0: eine Seite)
- dwMaximumSize: SIZE_T – Höchstgröße; 0: wächst nach Bedarf

**Ergebnis:** eax = Handle des Heaps; 0 bei Fehler. `HeapDestroy` gibt ihn mit allen Blöcken frei.

## LocalAlloc, GlobalAlloc – Speicher (alt)

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `LocalAlloc(uFlags, uBytes)`

- uFlags: UINT – `0` LMEM_FIXED (Adresse), `0x40` LMEM_ZEROINIT (mit Nullen); `GlobalAlloc`: `0x42` GMEM_MOVEABLE|ZEROINIT für die Zwischenablage
- uBytes: SIZE_T – Anzahl Bytes

**Ergebnis:** eax = Adresse (fixed) oder Handle (moveable); 0 bei Fehler

Aus 16-Bit-Zeiten; heute derselbe Heap wie `HeapAlloc`. Freigeben mit `LocalFree` / `GlobalFree`.

## LocalFree, GlobalFree – Speicher (alt) freigeben

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `LocalFree(hMem)`

- hMem: HLOCAL – von `LocalAlloc` oder von Windows (z. B. `FormatMessageA` mit ALLOCATE_BUFFER, `CommandLineToArgvW`)

**Ergebnis:** eax = 0 bei Erfolg, sonst hMem

## VirtualAlloc – Seiten reservieren und belegen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)`

- lpAddress: LPVOID – gewünschte Adresse oder 0 (Windows wählt)
- dwSize: SIZE_T – Anzahl Bytes (auf 4 KB aufgerundet)
- flAllocationType: DWORD – `0x1000` MEM_COMMIT, `0x2000` MEM_RESERVE (meist `0x3000` beide)
- flProtect: DWORD – `4` PAGE_READWRITE, `0x40` PAGE_EXECUTE_READWRITE, `2` PAGE_READONLY

**Ergebnis:** eax = Anfangsadresse (mit Nullen gefüllt); 0 bei Fehler

Für große Blöcke und für Speicher, in dem Code ausgeführt werden soll. Freigeben mit `VirtualFree`.

## VirtualFree – Seiten freigeben

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `VirtualFree(lpAddress, dwSize, dwFreeType)`

- lpAddress: LPVOID – von `VirtualAlloc`
- dwSize: SIZE_T – 0 bei MEM_RELEASE
- dwFreeType: DWORD – `0x8000` MEM_RELEASE (alles zurück), `0x4000` MEM_DECOMMIT (nur den Inhalt)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## VirtualProtect – Seitenschutz ändern

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect)`

- lpAddress: LPVOID – Anfang des Bereichs
- dwSize: SIZE_T – seine Größe
- flNewProtect: DWORD – `4` PAGE_READWRITE, `0x20` PAGE_EXECUTE_READ, `0x40` PAGE_EXECUTE_READWRITE
- lpflOldProtect: PDWORD – Adresse für den alten Schutz (Pflicht)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Nötig, um Code zur Laufzeit zu schreiben oder Daten ausführbar zu machen.

## VirtualQuery – Zustand eines Speicherbereichs

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `VirtualQuery(lpAddress, lpBuffer, dwLength)`

- lpAddress: LPCVOID – eine Adresse
- lpBuffer: PMEMORY_BASIC_INFORMATION – Struktur von 28 Bytes: Basisadresse, Basis der Reservierung, ihr Schutz, Größe des Bereichs, Zustand (`0x1000` MEM_COMMIT, `0x2000` MEM_RESERVE, `0x10000` MEM_FREE), Schutz, Art (`0x1000000` MEM_IMAGE)
- dwLength: SIZE_T – 28

**Ergebnis:** eax = Anzahl geschriebener Bytes; 0 bei Fehler

Damit prüft die Laufzeit, ob ein Zeiger auf lesbaren Speicher zeigt.

## IsBadReadPtr, IsBadWritePtr – Zeiger prüfen (veraltet)

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `IsBadReadPtr(lp, ucb)`

- lp: const void* – die Adresse
- ucb: UINT_PTR – Anzahl Bytes

**Ergebnis:** eax = 0, wenn der Bereich lesbar (schreibbar) ist, sonst 1

## CreateThread – Thread starten

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `CreateThread(lpThreadAttributes, dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId)`

- lpThreadAttributes: LPSECURITY_ATTRIBUTES – 0
- dwStackSize: SIZE_T – 0 (Standard, 1 MB)
- lpStartAddress: LPTHREAD_START_ROUTINE – die Funktion des Threads (stdcall, 1 Parameter, Ergebnis = Exitcode)
- lpParameter: LPVOID – ihr Parameter
- dwCreationFlags: DWORD – 0 sofort; `4` CREATE_SUSPENDED (erst `ResumeThread`)
- lpThreadId: LPDWORD – Adresse für die Threadnummer oder 0

**Ergebnis:** eax = Handle des Threads (schließen mit `CloseHandle`); 0 bei Fehler

## ExitThread – eigenen Thread beenden

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `ExitThread(dwExitCode)`

- dwExitCode: DWORD – der Exitcode des Threads

**Ergebnis:** kehrt nicht zurück

Endet der letzte Thread, endet der Prozess. Ein `ret` aus der Threadfunktion tut dasselbe.

## WaitForSingleObject – auf ein Objekt warten

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `WaitForSingleObject(hHandle, dwMilliseconds)`

- hHandle: HANDLE – Thread, Prozess, Ereignis, Mutex, Semaphor
- dwMilliseconds: DWORD – Wartezeit; `0xFFFFFFFF` INFINITE

**Ergebnis:** eax = `0` WAIT_OBJECT_0 (signalisiert: Thread oder Prozess beendet, Ereignis gesetzt), `0x102` WAIT_TIMEOUT, `0xFFFFFFFF` WAIT_FAILED

## CreateEventA, CreateEventW – Ereignis anlegen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `CreateEventA(lpEventAttributes, bManualReset, bInitialState, lpName)`

- lpEventAttributes: LPSECURITY_ATTRIBUTES – 0
- bManualReset: BOOL – 1: bleibt gesetzt bis `ResetEvent`; 0: setzt sich nach einem Warten zurück
- bInitialState: BOOL – 1: anfangs gesetzt
- lpName: LPCSTR – Name (für andere Prozesse) oder 0

**Ergebnis:** eax = Handle; 0 bei Fehler

## SetEvent, ResetEvent – Ereignis setzen und zurücksetzen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetEvent(hEvent)`, `ResetEvent(hEvent)`

- hEvent: HANDLE – von `CreateEventA`

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

`SetEvent` weckt die Threads, die mit `WaitForSingleObject` darauf warten.

## InitializeCriticalSection, DeleteCriticalSection – Sperre anlegen und löschen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `InitializeCriticalSection(lpCriticalSection)`, `DeleteCriticalSection(lpCriticalSection)`

- lpCriticalSection: LPCRITICAL_SECTION – Adresse von 24 Bytes im eigenen Speicher

**Ergebnis:** keins

Eine kritische Sektion lässt immer nur einen Thread in den Bereich zwischen `EnterCriticalSection` und `LeaveCriticalSection`.

## EnterCriticalSection, LeaveCriticalSection – Sperre nehmen und geben

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `EnterCriticalSection(lpCriticalSection)`, `LeaveCriticalSection(lpCriticalSection)`

- lpCriticalSection: LPCRITICAL_SECTION – die Sektion von `InitializeCriticalSection`

**Ergebnis:** keins

`Enter` wartet, bis kein anderer Thread die Sektion hält; derselbe Thread darf sie mehrfach nehmen und muss sie ebenso oft geben.

## InterlockedIncrement, InterlockedDecrement – Zähler atomar ändern

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `InterlockedIncrement(lpAddend)`, `InterlockedDecrement(lpAddend)`

- lpAddend: LONG* – Adresse des Zählers (4 Bytes, ausgerichtet)

**Ergebnis:** eax = der neue Wert

Erhöht oder verringert um 1, ohne dass ein anderer Thread dazwischenkommt (wie `lock inc`). Delphi zählt so die Referenzen von Strings und Interfaces.

## InterlockedExchange, InterlockedCompareExchange – Wert atomar tauschen

kernel32.dll · stdcall · 2 Parameter (8 Bytes) / 3 Parameter

**Aufruf:** `InterlockedExchange(Target, Value)`, `InterlockedCompareExchange(Destination, Exchange, Comparand)`

- Target, Destination: LONG* – Adresse des Werts
- Value, Exchange: LONG – der neue Wert
- Comparand: LONG – nur tauschen, wenn der alte Wert gleich diesem ist

**Ergebnis:** eax = der alte Wert

## TlsAlloc, TlsFree – Platz je Thread anlegen

kernel32.dll · stdcall · keine Parameter / 1 Parameter

**Aufruf:** `TlsAlloc()`, `TlsFree(dwTlsIndex)`

**Ergebnis:** eax = Index eines Doppelworts, das jeder Thread für sich hat; `0xFFFFFFFF` bei Fehler

## TlsGetValue, TlsSetValue – Wert je Thread lesen und setzen

kernel32.dll · stdcall · 1 Parameter (4 Bytes) / 2 Parameter

**Aufruf:** `TlsGetValue(dwTlsIndex)`, `TlsSetValue(dwTlsIndex, lpTlsValue)`

- dwTlsIndex: DWORD – von `TlsAlloc`
- lpTlsValue: LPVOID – der Wert für den aktuellen Thread

**Ergebnis:** `TlsGetValue`: eax = der Wert dieses Threads (0, wenn nie gesetzt); `TlsSetValue`: 1 bei Erfolg

Delphi legt so `threadvar`-Variablen ab.

## RaiseException – Ausnahme auslösen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments, lpArguments)`

- dwExceptionCode: DWORD – eigener Code (Delphi: `0x0EEDFADE`)
- dwExceptionFlags: DWORD – 0 fortsetzbar; `1` EXCEPTION_NONCONTINUABLE
- nNumberOfArguments: DWORD – Anzahl Werte in lpArguments (höchstens 15)
- lpArguments: const ULONG_PTR* – zusätzliche Werte (Delphi: Adresse und Objekt der Exception)

**Ergebnis:** kehrt nur zurück, wenn ein Handler die Ausführung fortsetzt

Die Ausnahme läuft die SEH-Kette durch (`fs:[0]`); so wirft Delphi `raise`.

## RtlUnwind – SEH-Kette abbauen

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `RtlUnwind(TargetFrame, TargetIp, ExceptionRecord, ReturnValue)`

- TargetFrame: PVOID – bis zu welchem Handler (Rahmen) abgebaut wird
- TargetIp: PVOID – wo es weitergeht (ungenutzt auf x86)
- ExceptionRecord: PEXCEPTION_RECORD – die Ausnahme oder 0
- ReturnValue: PVOID – Wert für `eax`

**Ergebnis:** keins

Ruft die Handler der inneren Rahmen mit `EXCEPTION_UNWINDING` auf (`finally`-Blöcke) und entfernt sie aus der Kette. Teil der Delphi-Ausnahmebehandlung.

## SetUnhandledExceptionFilter – letzter Ausnahmefilter

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetUnhandledExceptionFilter(lpTopLevelExceptionFilter)`

- lpTopLevelExceptionFilter: LPTOP_LEVEL_EXCEPTION_FILTER – eigene Funktion (stdcall, 1 Parameter: Zeiger auf EXCEPTION_POINTERS; Ergebnis `1` EXCEPTION_EXECUTE_HANDLER beendet, `0` zeigt den Windows-Dialog, `-1` setzt fort) oder 0

**Ergebnis:** eax = der vorherige Filter

Wird gerufen, wenn kein Handler eine Ausnahme nimmt; die C-Laufzeit setzt ihn beim Start.

## UnhandledExceptionFilter – Standardbehandlung einer Ausnahme

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `UnhandledExceptionFilter(ExceptionInfo)`

- ExceptionInfo: struct _EXCEPTION_POINTERS* – Ausnahme und Registerinhalt

**Ergebnis:** eax = `1` EXCEPTION_EXECUTE_HANDLER oder `0` EXCEPTION_CONTINUE_SEARCH (ein Debugger übernimmt)

Zeigt den Dialog „Das Programm funktioniert nicht mehr“ oder übergibt an den Debugger.

## IsDebuggerPresent – läuft ein Debugger?

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `IsDebuggerPresent()`

**Ergebnis:** eax = 1, wenn ein Debugger (auch Dismonite) den Prozess hält, sonst 0

## OutputDebugStringA, OutputDebugStringW – Text an den Debugger

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `OutputDebugStringA(lpOutputString)`

- lpOutputString: LPCSTR – der Text

**Ergebnis:** keins

Der Debugger zeigt den Text in seiner Ausgabe; ohne Debugger passiert nichts.

## DebugBreak – Breakpoint auslösen

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `DebugBreak()`

**Ergebnis:** keins

Wie `int 3`: der Debugger hält an; ohne Debugger ist es eine Ausnahme.

## MessageBoxA, MessageBoxW – Meldungsfenster

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `MessageBoxA(hWnd, lpText, lpCaption, uType)`

- hWnd: HWND – Besitzerfenster oder 0
- lpText: LPCSTR – der Text (Zeilenumbruch mit `0x0A`)
- lpCaption: LPCSTR – der Titel oder 0 („Fehler“)
- uType: UINT – Knöpfe `0` MB_OK, `1` MB_OKCANCEL, `3` MB_YESNOCANCEL, `4` MB_YESNO; Symbol `0x10` MB_ICONERROR, `0x20` MB_ICONQUESTION, `0x30` MB_ICONWARNING, `0x40` MB_ICONINFORMATION

**Ergebnis:** eax = gedrückter Knopf: `1` IDOK, `2` IDCANCEL, `6` IDYES, `7` IDNO; 0 bei Fehler

Das einfachste Fenster: wartet, bis der Benutzer klickt.

```asm
push 0            ; uType
push titel        ; lpCaption
push text         ; lpText
push 0            ; hWnd
call [MessageBoxA]
```

## MessageBeep – Systemton

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `MessageBeep(uType)`

- uType: UINT – `0xFFFFFFFF` einfacher Piepton; `0` MB_OK, `0x10` MB_ICONERROR, ... wie bei `MessageBoxA`

**Ergebnis:** eax = 1 bei Erfolg

## RegisterClassA, RegisterClassW – Fensterklasse anmelden

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `RegisterClassA(lpWndClass)`

- lpWndClass: const WNDCLASSA* – Struktur von 40 Bytes: style, lpfnWndProc (die Fensterfunktion), cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName

**Ergebnis:** eax = Atom der Klasse (16 Bit); 0 bei Fehler

Eine Klasse beschreibt, wie Fenster aussehen und welche Funktion ihre Nachrichten bekommt. Danach `CreateWindowExA` mit dem Klassennamen.

## RegisterClassExA, RegisterClassExW – Fensterklasse anmelden (mit kleinem Symbol)

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `RegisterClassExA(lpWndClassEx)`

- lpWndClassEx: const WNDCLASSEXA* – Struktur von 48 Bytes: cbSize (= 48), dann wie WNDCLASSA, zuletzt hIconSm

**Ergebnis:** eax = Atom der Klasse; 0 bei Fehler

## CreateWindowExA, CreateWindowExW – Fenster anlegen

user32.dll · stdcall · 12 Parameter (48 Bytes)

**Aufruf:** `CreateWindowExA(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)`

- dwExStyle: DWORD – 0 oder `0x200` WS_EX_CLIENTEDGE, `0x8` WS_EX_TOPMOST
- lpClassName: LPCSTR – eigene Klasse (`RegisterClassExA`) oder eine von Windows: `BUTTON`, `EDIT`, `STATIC`, `LISTBOX`, `COMBOBOX`
- lpWindowName: LPCSTR – Titel oder Text des Steuerelements
- dwStyle: DWORD – `0xCF0000` WS_OVERLAPPEDWINDOW, `0x10000000` WS_VISIBLE, `0x40000000` WS_CHILD, `0x800000` WS_BORDER; Knopf: `1` BS_DEFPUSHBUTTON; Edit: `4` ES_MULTILINE
- X, Y, nWidth, nHeight: int – Lage und Größe; `0x80000000` CW_USEDEFAULT
- hWndParent: HWND – Elternfenster (Pflicht bei WS_CHILD) oder 0
- hMenu: HMENU – Menü, bei WS_CHILD die Nummer des Steuerelements (ID)
- hInstance: HINSTANCE – `GetModuleHandleA(0)`
- lpParam: LPVOID – 0 (kommt in WM_CREATE an)

**Ergebnis:** eax = HWND; 0 bei Fehler

Sendet WM_CREATE an die Fensterfunktion, bevor es zurückkehrt.

## DestroyWindow – Fenster zerstören

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `DestroyWindow(hWnd)`

- hWnd: HWND – das Fenster (mit allen Kindfenstern)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Sendet WM_DESTROY; dort ruft das Hauptfenster meist `PostQuitMessage`.

## ShowWindow – Fenster zeigen oder verstecken

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `ShowWindow(hWnd, nCmdShow)`

- hWnd: HWND – das Fenster
- nCmdShow: int – `0` SW_HIDE, `1` SW_SHOWNORMAL, `3` SW_MAXIMIZE, `5` SW_SHOW, `6` SW_MINIMIZE

**Ergebnis:** eax = 1, wenn das Fenster vorher sichtbar war, sonst 0

## UpdateWindow – sofort zeichnen lassen

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `UpdateWindow(hWnd)`

- hWnd: HWND – das Fenster

**Ergebnis:** eax = 1 bei Erfolg

Sendet WM_PAINT sofort, wenn ein Teil des Fensters ungültig ist (`InvalidateRect`).

## InvalidateRect – Bereich neu zeichnen lassen

user32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `InvalidateRect(hWnd, lpRect, bErase)`

- hWnd: HWND – das Fenster
- lpRect: const RECT* – Rechteck (links, oben, rechts, unten) oder 0 für alles
- bErase: BOOL – 1: Hintergrund vorher löschen

**Ergebnis:** eax = 1 bei Erfolg

Das Fenster bekommt beim nächsten Durchlauf der Nachrichtenschleife WM_PAINT.

## GetMessageA, GetMessageW – nächste Nachricht holen

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `GetMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax)`

- lpMsg: LPMSG – Struktur von 28 Bytes: hwnd, message, wParam, lParam, time, pt (x, y)
- hWnd: HWND – nur Nachrichten dieses Fensters oder 0 für alle des Threads
- wMsgFilterMin, wMsgFilterMax: UINT – 0, 0 (alle)

**Ergebnis:** eax = 0 bei WM_QUIT (die Schleife endet), `-1` bei Fehler, sonst 1

Wartet, bis eine Nachricht da ist. Der Kern jeder Nachrichtenschleife:

```asm
L: push 0
   push 0
   push 0
   push msg
   call [GetMessageA]
   test eax, eax
   jz ende
   ; Translate, Dispatch
   jmp L
```

## PeekMessageA, PeekMessageW – Nachricht nachsehen, ohne zu warten

user32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `PeekMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg)`

- lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax: wie `GetMessageA`
- wRemoveMsg: UINT – `1` PM_REMOVE (aus der Warteschlange nehmen), `0` PM_NOREMOVE

**Ergebnis:** eax = 1, wenn eine Nachricht da ist, sonst 0

Für Programme, die zwischen den Nachrichten weiterrechnen (Spiele).

## TranslateMessage – Tastendruck in Zeichen übersetzen

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `TranslateMessage(lpMsg)`

- lpMsg: const MSG* – die Nachricht von `GetMessageA`

**Ergebnis:** eax = 1, wenn eine Zeichen-Nachricht erzeugt wurde

Macht aus WM_KEYDOWN ein WM_CHAR mit dem Zeichen der Tastatur. Steht vor `DispatchMessageA`.

## DispatchMessageA, DispatchMessageW – Nachricht an die Fensterfunktion

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `DispatchMessageA(lpMsg)`

- lpMsg: const MSG* – die Nachricht

**Ergebnis:** eax = was die Fensterfunktion zurückgab

Ruft die Fensterfunktion des Fensters, an das die Nachricht geht (`lpfnWndProc` der Klasse).

## DefWindowProcA, DefWindowProcW – Standardbehandlung einer Nachricht

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `DefWindowProcA(hWnd, Msg, wParam, lParam)`

- hWnd, Msg, wParam, lParam: die vier Parameter der Fensterfunktion

**Ergebnis:** eax = das Ergebnis der Standardbehandlung

Die eigene Fensterfunktion ruft es für alle Nachrichten, die sie nicht selbst behandelt (Rahmen, Verschieben, Schließen, Größe ändern).

## PostQuitMessage – Nachrichtenschleife beenden

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `PostQuitMessage(nExitCode)`

- nExitCode: int – der Wert, den `GetMessageA` in wParam von WM_QUIT liefert

**Ergebnis:** keins

Legt WM_QUIT in die Warteschlange; `GetMessageA` gibt dann 0 zurück. Üblich in WM_DESTROY.

## SendMessageA, SendMessageW – Nachricht senden und warten

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `SendMessageA(hWnd, Msg, wParam, lParam)`

- hWnd: HWND – das Zielfenster
- Msg: UINT – die Nachricht: `0x0C` WM_SETTEXT, `0x0D` WM_GETTEXT, `0x0E` WM_GETTEXTLENGTH, `0x30` WM_SETFONT, `0x10` WM_CLOSE, Steuerelemente ab `0x100` (z. B. `0x180` LB_ADDSTRING, `0xB1` EM_SETSEL)
- wParam, lParam: WPARAM, LPARAM – je nach Nachricht

**Ergebnis:** eax = die Antwort der Fensterfunktion

Ruft die Fensterfunktion direkt und kehrt mit deren Ergebnis zurück. `PostMessageA` legt die Nachricht nur ab.

## PostMessageA, PostMessageW – Nachricht ablegen

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `PostMessageA(hWnd, Msg, wParam, lParam)`

- hWnd, Msg, wParam, lParam: wie `SendMessageA`

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Kehrt sofort zurück; die Nachricht wird von der Schleife des Zielthreads geholt.

## GetClientRect – Innenmaß eines Fensters

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetClientRect(hWnd, lpRect)`

- hWnd: HWND – das Fenster
- lpRect: LPRECT – Struktur von 16 Bytes: links, oben (immer 0), rechts, unten = Breite, Höhe

**Ergebnis:** eax = 1 bei Erfolg

## GetWindowRect – Lage eines Fensters auf dem Bildschirm

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetWindowRect(hWnd, lpRect)`

- hWnd: HWND – das Fenster
- lpRect: LPRECT – links, oben, rechts, unten in Bildschirmkoordinaten, mit Rahmen

**Ergebnis:** eax = 1 bei Erfolg

## MoveWindow – Fenster verschieben und vergrößern

user32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `MoveWindow(hWnd, X, Y, nWidth, nHeight, bRepaint)`

- hWnd: HWND – das Fenster
- X, Y: int – neue Lage (Kindfenster: im Elternfenster)
- nWidth, nHeight: int – neue Größe
- bRepaint: BOOL – 1: neu zeichnen

**Ergebnis:** eax = 1 bei Erfolg

Typisch in WM_SIZE, um die Steuerelemente der Fenstergröße anzupassen.

## SetWindowPos – Lage, Größe und Reihenfolge eines Fensters

user32.dll · stdcall · 7 Parameter (28 Bytes)

**Aufruf:** `SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags)`

- hWnd: HWND – das Fenster
- hWndInsertAfter: HWND – wohin in der Z-Reihenfolge: `0` HWND_TOP, `-1` HWND_TOPMOST, `1` HWND_BOTTOM
- X, Y, cx, cy: int – Lage und Größe
- uFlags: UINT – `1` SWP_NOSIZE, `2` SWP_NOMOVE, `4` SWP_NOZORDER, `0x40` SWP_SHOWWINDOW

**Ergebnis:** eax = 1 bei Erfolg

## SetWindowTextA, SetWindowTextW – Titel oder Text setzen

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetWindowTextA(hWnd, lpString)`

- hWnd: HWND – Fenster oder Steuerelement (Edit, Static, Button)
- lpString: LPCSTR – der neue Text

**Ergebnis:** eax = 1 bei Erfolg

Dasselbe wie `SendMessageA` mit WM_SETTEXT.

## GetWindowTextA, GetWindowTextW – Titel oder Text lesen

user32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `GetWindowTextA(hWnd, lpString, nMaxCount)`

- hWnd: HWND – Fenster oder Steuerelement
- lpString: LPSTR – der Puffer
- nMaxCount: int – seine Größe in Zeichen samt 0

**Ergebnis:** eax = Anzahl kopierter Zeichen; 0 bei leerem Text oder Fehler

So liest man, was in ein Edit-Feld getippt wurde.

## GetWindowTextLengthA, GetWindowTextLengthW – Länge des Texts

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetWindowTextLengthA(hWnd)`

- hWnd: HWND – Fenster oder Steuerelement

**Ergebnis:** eax = Anzahl Zeichen ohne 0

Damit bestimmt man die Puffergröße für `GetWindowTextA` (plus 1).

## SetFocus – Tastatureingabe auf ein Fenster lenken

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetFocus(hWnd)`

- hWnd: HWND – das Fenster, das die Tastatur bekommt (z. B. ein Edit-Feld)

**Ergebnis:** eax = das Fenster, das den Fokus vorher hatte; 0 bei Fehler

## GetDlgItem – Steuerelement eines Dialogs

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetDlgItem(hDlg, nIDDlgItem)`

- hDlg: HWND – der Dialog oder das Elternfenster
- nIDDlgItem: int – die Nummer des Steuerelements (hMenu bei `CreateWindowExA`)

**Ergebnis:** eax = HWND des Steuerelements; 0, wenn es keins gibt

## DialogBoxParamA, DialogBoxParamW – Dialog aus der Ressource zeigen

user32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `DialogBoxParamA(hInstance, lpTemplateName, hWndParent, lpDialogFunc, dwInitParam)`

- hInstance: HINSTANCE – das Modul mit der Ressource
- lpTemplateName: LPCSTR – Name oder Nummer der Dialogvorlage (Nummer in den unteren 16 Bit)
- hWndParent: HWND – Besitzer oder 0
- lpDialogFunc: DLGPROC – die Dialogfunktion (wie eine Fensterfunktion; Ergebnis 1 = behandelt)
- dwInitParam: LPARAM – Wert für WM_INITDIALOG

**Ergebnis:** eax = der Wert von `EndDialog`; `-1` bei Fehler

Modal: kehrt erst zurück, wenn der Dialog mit `EndDialog` geschlossen wurde.

## EndDialog – modalen Dialog schließen

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `EndDialog(hDlg, nResult)`

- hDlg: HWND – der Dialog
- nResult: INT_PTR – der Wert, den `DialogBoxParamA` zurückgibt

**Ergebnis:** eax = 1 bei Erfolg

## LoadCursorA, LoadCursorW – Mauszeiger laden

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `LoadCursorA(hInstance, lpCursorName)`

- hInstance: HINSTANCE – 0 für die Zeiger von Windows
- lpCursorName: LPCSTR – `32512` IDC_ARROW, `32513` IDC_IBEAM, `32514` IDC_WAIT, `32515` IDC_CROSS, `32649` IDC_HAND (als Zahl)

**Ergebnis:** eax = HCURSOR; 0 bei Fehler

Für `hCursor` der Fensterklasse.

## LoadIconA, LoadIconW – Symbol laden

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `LoadIconA(hInstance, lpIconName)`

- hInstance: HINSTANCE – 0 für die Symbole von Windows, sonst das Modul
- lpIconName: LPCSTR – `32512` IDI_APPLICATION, `32513` IDI_ERROR, `32514` IDI_QUESTION, `32516` IDI_INFORMATION; eigene: Name oder Nummer der Ressource

**Ergebnis:** eax = HICON; 0 bei Fehler

## LoadStringA, LoadStringW – Text aus der Ressource

user32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `LoadStringA(hInstance, uID, lpBuffer, cchBufferMax)`

- hInstance: HINSTANCE – das Modul mit der Stringtabelle
- uID: UINT – die Nummer des Texts
- lpBuffer: LPSTR – der Puffer
- cchBufferMax: int – seine Größe in Zeichen

**Ergebnis:** eax = Anzahl kopierter Zeichen; 0, wenn es den Text nicht gibt

Delphi holt so seine `resourcestring`-Texte.

## BeginPaint, EndPaint – Zeichnen in WM_PAINT

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `BeginPaint(hWnd, lpPaint)`, `EndPaint(hWnd, lpPaint)`

- hWnd: HWND – das Fenster
- lpPaint: LPPAINTSTRUCT – Struktur von 64 Bytes: hdc, fErase, rcPaint (der ungültige Bereich), ...

**Ergebnis:** `BeginPaint`: eax = HDC zum Zeichnen (nur innerhalb von WM_PAINT); `EndPaint`: 1

Zwischen beiden zeichnet die Fensterfunktion mit GDI (`TextOutA`, `Rectangle`); `EndPaint` macht den Bereich wieder gültig.

## GetDC, ReleaseDC – Gerätekontext außerhalb von WM_PAINT

user32.dll · stdcall · 1 Parameter (4 Bytes) / 2 Parameter

**Aufruf:** `GetDC(hWnd)`, `ReleaseDC(hWnd, hDC)`

- hWnd: HWND – das Fenster oder 0 für den ganzen Bildschirm
- hDC: HDC – von `GetDC`

**Ergebnis:** `GetDC`: eax = HDC; 0 bei Fehler. `ReleaseDC`: 1 bei Erfolg

Immer wieder freigeben, sonst gehen die Kontexte aus.

## FillRect – Rechteck füllen

user32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `FillRect(hDC, lprc, hbr)`

- hDC: HDC – der Gerätekontext
- lprc: const RECT* – das Rechteck
- hbr: HBRUSH – ein Pinsel (`CreateSolidBrush`, `GetStockObject`) oder eine Systemfarbe + 1 (`COLOR_WINDOW + 1` = 6)

**Ergebnis:** eax = 1 bei Erfolg

## SetTimer, KillTimer – Zeitgeber

user32.dll · stdcall · 4 Parameter (16 Bytes) / 2 Parameter

**Aufruf:** `SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc)`, `KillTimer(hWnd, uIDEvent)`

- hWnd: HWND – das Fenster, das WM_TIMER (`0x113`) bekommt
- nIDEvent: UINT_PTR – eine eigene Nummer des Zeitgebers
- uElapse: UINT – Abstand in Millisekunden
- lpTimerFunc: TIMERPROC – 0 (Nachricht) oder eine Funktion

**Ergebnis:** `SetTimer`: eax = die Nummer; 0 bei Fehler. `KillTimer`: 1

## GetKeyState, GetAsyncKeyState – Zustand einer Taste

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetKeyState(nVirtKey)`, `GetAsyncKeyState(vKey)`

- nVirtKey: int – virtueller Tastencode: `0x10` VK_SHIFT, `0x11` VK_CONTROL, `0x12` VK_MENU (Alt), `0x0D` VK_RETURN, `0x1B` VK_ESCAPE, `0x41` bis `0x5A` A bis Z

**Ergebnis:** eax = Bit 15 (negativ): gedrückt; `GetKeyState` Bit 0: Umschalttaste aktiv (Feststelltaste)

`GetKeyState` gilt zum Zeitpunkt der aktuellen Nachricht, `GetAsyncKeyState` jetzt.

## GetKeyboardType – Art der Tastatur

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetKeyboardType(nTypeFlag)`

- nTypeFlag: int – `0` Typ (4 = erweiterte 101/102-Tasten-Tastatur), `1` Untertyp, `2` Anzahl Funktionstasten

**Ergebnis:** eax = der Wert; 0 bei Fehler

Delphi prüft damit beim Start, ob es sich um eine japanische Tastatur handelt.

## GetSystemMetrics – Maße des Systems

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetSystemMetrics(nIndex)`

- nIndex: int – `0` SM_CXSCREEN Bildschirmbreite, `1` SM_CYSCREEN Höhe, `4` SM_CYCAPTION Titelhöhe, `43` SM_CMOUSEBUTTONS Maustasten, `80` SM_CMONITORS Anzahl Monitore

**Ergebnis:** eax = der Wert in Pixeln bzw. die Anzahl; 0 bei Fehler

## CharNextA, CharNextW – zum nächsten Zeichen

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `CharNextA(lpsz)`

- lpsz: LPCSTR – Zeiger in einen Text

**Ergebnis:** eax = Zeiger auf das nächste Zeichen (bei Doppelbyte-Zeichen 2 weiter; am Ende derselbe Zeiger)

Delphi läuft so durch Strings, die Multibyte-Zeichen enthalten könnten.

## CharToOemA, OemToCharA – Windows- und DOS-Zeichensatz

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `CharToOemA(pSrc, pDst)`

- pSrc: LPCSTR – Text im Windows-Zeichensatz (1252)
- pDst: LPSTR – Puffer für die OEM-Codepage (850/437), darf pSrc sein

**Ergebnis:** eax = 1

Nötig, damit Umlaute auf der Konsole richtig erscheinen, wenn man mit `WriteFile` schreibt.

## CharUpperA, CharLowerA – Groß- und Kleinbuchstaben

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `CharUpperA(lpsz)`

- lpsz: LPSTR – ein Text (wird an der Stelle geändert) oder ein einzelnes Zeichen in den unteren 16 Bit (obere 16 Bit 0)

**Ergebnis:** eax = der Zeiger bzw. das gewandelte Zeichen

Kennt auch Umlaute, anders als `and 0xDF`.

## wsprintfA, wsprintfW – Text formatieren (ohne C-Laufzeit)

user32.dll · cdecl · 2 Parameter und mehr (der Aufrufer räumt den Stack)

**Aufruf:** `wsprintfA(lpOut, lpFmt, ...)`

- lpOut: LPSTR – der Puffer (höchstens 1024 Zeichen)
- lpFmt: LPCSTR – das Format: `%d`, `%u`, `%x`, `%08X`, `%s`, `%c`, `%%` (keine Gleitkommazahlen)
- ...: die Werte in der Reihenfolge des Formats

**Ergebnis:** eax = Anzahl geschriebener Zeichen

Die einzige cdecl-Funktion in user32: nach dem Aufruf `add esp, 4 * anzahl`.

```asm
push [wert]
push fmt
push buf
call [wsprintfA]
add esp, 12
```

## CreateFontA, CreateFontW – Schrift anlegen

gdi32.dll · stdcall · 14 Parameter (56 Bytes)

**Aufruf:** `CreateFontA(cHeight, cWidth, cEscapement, cOrientation, cWeight, bItalic, bUnderline, bStrikeOut, iCharSet, iOutPrecision, iClipPrecision, iQuality, iPitchAndFamily, pszFaceName)`

- cHeight: int – Höhe in Pixeln (negativ: Zeichenhöhe ohne innere Abstände, üblich)
- cWidth: int – 0 (passend)
- cEscapement, cOrientation: int – Drehung in Zehntelgrad, 0
- cWeight: int – `400` FW_NORMAL, `700` FW_BOLD
- bItalic, bUnderline, bStrikeOut: DWORD – 0 oder 1
- iCharSet: DWORD – `0` ANSI_CHARSET, `1` DEFAULT_CHARSET, `255` OEM_CHARSET
- iOutPrecision, iClipPrecision: DWORD – 0
- iQuality: DWORD – `0` DEFAULT_QUALITY, `5` CLEARTYPE_QUALITY
- iPitchAndFamily: DWORD – `0` DEFAULT_PITCH, `1` FIXED_PITCH (dicktengleich) | `0x30` FF_MODERN
- pszFaceName: LPCSTR – `Courier New`, `Segoe UI`, ... oder 0

**Ergebnis:** eax = HFONT; 0 bei Fehler

Einem Steuerelement mit `SendMessageA(hWnd, WM_SETFONT, hFont, 1)` zuweisen; am Ende `DeleteObject`.

## GetStockObject – Standardobjekt von Windows

gdi32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetStockObject(i)`

- i: int – `0` WHITE_BRUSH, `4` BLACK_BRUSH, `5` NULL_BRUSH, `6` WHITE_PEN, `7` BLACK_PEN, `13` SYSTEM_FONT, `17` DEFAULT_GUI_FONT

**Ergebnis:** eax = Handle des Objekts (nicht löschen)

## CreateSolidBrush – Pinsel einer Farbe

gdi32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `CreateSolidBrush(color)`

- color: COLORREF – `0x00BBGGRR`: Rot im niedrigsten Byte, dann Grün, Blau (`0xFF0000` ist Blau)

**Ergebnis:** eax = HBRUSH; 0 bei Fehler

Für `hbrBackground` der Fensterklasse oder `FillRect`; am Ende `DeleteObject`.

## CreatePen – Stift für Linien

gdi32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `CreatePen(iStyle, cWidth, color)`

- iStyle: int – `0` PS_SOLID, `1` PS_DASH, `2` PS_DOT, `5` PS_NULL
- cWidth: int – Breite in Pixeln (0 = 1)
- color: COLORREF – die Farbe

**Ergebnis:** eax = HPEN; 0 bei Fehler

## SelectObject – Objekt in den Kontext wählen

gdi32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SelectObject(hdc, h)`

- hdc: HDC – der Gerätekontext
- h: HGDIOBJ – Stift, Pinsel, Schrift oder Bitmap

**Ergebnis:** eax = das vorher gewählte Objekt derselben Art (am Ende zurückwählen); 0 bei Fehler

Zeichenbefehle benutzen den aktuellen Stift, Pinsel und die aktuelle Schrift des Kontexts.

## DeleteObject – GDI-Objekt löschen

gdi32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `DeleteObject(ho)`

- ho: HGDIOBJ – Stift, Pinsel, Schrift, Bitmap (nicht die Stock-Objekte, nicht ein gerade gewähltes)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## TextOutA, TextOutW – Text zeichnen

gdi32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `TextOutA(hdc, x, y, lpString, c)`

- hdc: HDC – der Gerätekontext (`BeginPaint`, `GetDC`)
- x, y: int – die linke obere Ecke des Texts
- lpString: LPCSTR – der Text (keine 0 nötig)
- c: int – Anzahl Zeichen

**Ergebnis:** eax = 1 bei Erfolg

Schrift, Textfarbe (`SetTextColor`) und Hintergrund (`SetBkColor`, `SetBkMode`) kommen aus dem Kontext.

## SetTextColor, SetBkColor – Text- und Hintergrundfarbe

gdi32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetTextColor(hdc, color)`, `SetBkColor(hdc, color)`

- hdc: HDC – der Gerätekontext
- color: COLORREF – `0x00BBGGRR`

**Ergebnis:** eax = die vorherige Farbe; `0xFFFFFFFF` CLR_INVALID bei Fehler

## SetBkMode – Hintergrund des Texts

gdi32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetBkMode(hdc, mode)`

- hdc: HDC – der Gerätekontext
- mode: int – `1` TRANSPARENT (nur die Zeichen), `2` OPAQUE (Hintergrund in `SetBkColor` füllen)

**Ergebnis:** eax = der vorherige Modus; 0 bei Fehler

## MoveToEx, LineTo – Linie zeichnen

gdi32.dll · stdcall · 4 Parameter (16 Bytes) / 3 Parameter

**Aufruf:** `MoveToEx(hdc, x, y, lppt)`, `LineTo(hdc, x, y)`

- hdc: HDC – der Gerätekontext
- x, y: int – der Punkt
- lppt: LPPOINT – Adresse für den alten Punkt oder 0

**Ergebnis:** eax = 1 bei Erfolg

`MoveToEx` setzt den Anfang, `LineTo` zieht mit dem aktuellen Stift bis zum Punkt (ausschließlich) und setzt den Anfang dorthin.

## Rectangle, Ellipse – Rechteck und Ellipse zeichnen

gdi32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `Rectangle(hdc, left, top, right, bottom)`

- hdc: HDC – der Gerätekontext
- left, top, right, bottom: int – die Ecken (rechts und unten ausschließlich)

**Ergebnis:** eax = 1 bei Erfolg

Rand mit dem aktuellen Stift, Fläche mit dem aktuellen Pinsel (`NULL_BRUSH`: nur der Rand).

## CreateCompatibleDC, DeleteDC – Kontext im Speicher

gdi32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `CreateCompatibleDC(hdc)`, `DeleteDC(hdc)`

- hdc: HDC – ein Kontext als Vorbild (0: der Bildschirm); bei `DeleteDC` der zu löschende

**Ergebnis:** `CreateCompatibleDC`: eax = HDC; 0 bei Fehler. `DeleteDC`: 1

Für das Zeichnen in eine Bitmap (`SelectObject` mit einem HBITMAP), die `BitBlt` dann ins Fenster kopiert (flackerfrei).

## CreateCompatibleBitmap – Bitmap für einen Kontext

gdi32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `CreateCompatibleBitmap(hdc, cx, cy)`

- hdc: HDC – der Kontext, zu dem die Bitmap passen soll
- cx, cy: int – Breite und Höhe

**Ergebnis:** eax = HBITMAP; 0 bei Fehler. Am Ende `DeleteObject`.

## BitBlt – Pixelblock kopieren

gdi32.dll · stdcall · 9 Parameter (36 Bytes)

**Aufruf:** `BitBlt(hdc, x, y, cx, cy, hdcSrc, x1, y1, rop)`

- hdc: HDC – das Ziel
- x, y: int – Zielecke
- cx, cy: int – Breite und Höhe
- hdcSrc: HDC – die Quelle
- x1, y1: int – Quellecke
- rop: DWORD – `0xCC0020` SRCCOPY, `0xEE0086` SRCPAINT (Oder), `0x660046` SRCINVERT (Xor)

**Ergebnis:** eax = 1 bei Erfolg

## GetOpenFileNameA, GetOpenFileNameW – Dialog „Öffnen“

comdlg32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetOpenFileNameA(lpofn)`

- lpofn: LPOPENFILENAMEA – Struktur OPENFILENAME von 76 Bytes (mit den Feldern für Windows 2000: 88): lStructSize, hwndOwner, hInstance, lpstrFilter (`Text\0*.txt\0Alle\0*.*\0\0`), lpstrCustomFilter, nMaxCustFilter, nFilterIndex, lpstrFile (Puffer, erhält den Pfad), nMaxFile, lpstrFileTitle, nMaxFileTitle, lpstrInitialDir, lpstrTitle, Flags (`0x1000` OFN_FILEMUSTEXIST, `0x800` OFN_PATHMUSTEXIST, `0x4` OFN_HIDEREADONLY), nFileOffset, nFileExtension, lpstrDefExt, ...

**Ergebnis:** eax = 1, wenn der Benutzer eine Datei wählte (Pfad in lpstrFile); 0 bei Abbruch oder Fehler (`CommDlgExtendedError`)

## GetSaveFileNameA, GetSaveFileNameW – Dialog „Speichern unter“

comdlg32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetSaveFileNameA(lpofn)`

- lpofn: LPOPENFILENAMEA – dieselbe Struktur wie bei `GetOpenFileNameA`; Flags `0x2` OFN_OVERWRITEPROMPT fragt vor dem Überschreiben

**Ergebnis:** eax = 1 bei Auswahl, 0 bei Abbruch

## RegOpenKeyExA, RegOpenKeyExW – Registrierungsschlüssel öffnen

advapi32.dll · stdcall · 5 Parameter (20 Bytes)

**Aufruf:** `RegOpenKeyExA(hKey, lpSubKey, ulOptions, samDesired, phkResult)`

- hKey: HKEY – `0x80000001` HKEY_CURRENT_USER, `0x80000002` HKEY_LOCAL_MACHINE, `0x80000000` HKEY_CLASSES_ROOT oder ein offener Schlüssel
- lpSubKey: LPCSTR – der Pfad darunter, z. B. `Software\Microsoft\Windows\CurrentVersion`
- ulOptions: DWORD – 0
- samDesired: REGSAM – `0x20019` KEY_READ, `0x20006` KEY_WRITE, `0xF003F` KEY_ALL_ACCESS
- phkResult: PHKEY – Adresse für das Handle

**Ergebnis:** eax = 0 ERROR_SUCCESS; sonst der Fehlercode (`2` nicht gefunden, `5` Zugriff verweigert); nicht `GetLastError`

Schließen mit `RegCloseKey`.

## RegCreateKeyExA, RegCreateKeyExW – Schlüssel anlegen oder öffnen

advapi32.dll · stdcall · 9 Parameter (36 Bytes)

**Aufruf:** `RegCreateKeyExA(hKey, lpSubKey, Reserved, lpClass, dwOptions, samDesired, lpSecurityAttributes, phkResult, lpdwDisposition)`

- hKey, lpSubKey, samDesired, phkResult: wie `RegOpenKeyExA`
- Reserved: DWORD – 0
- lpClass: LPSTR – 0
- dwOptions: DWORD – 0 (REG_OPTION_NON_VOLATILE)
- lpSecurityAttributes: LPSECURITY_ATTRIBUTES – 0
- lpdwDisposition: LPDWORD – Adresse für `1` REG_CREATED_NEW_KEY oder `2` REG_OPENED_EXISTING_KEY, oder 0

**Ergebnis:** eax = 0 bei Erfolg, sonst der Fehlercode

## RegQueryValueExA, RegQueryValueExW – Wert lesen

advapi32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `RegQueryValueExA(hKey, lpValueName, lpReserved, lpType, lpData, lpcbData)`

- hKey: HKEY – offener Schlüssel
- lpValueName: LPCSTR – Name des Werts (leer oder 0: der Standardwert)
- lpReserved: LPDWORD – 0
- lpType: LPDWORD – Adresse für den Typ: `1` REG_SZ, `2` REG_EXPAND_SZ, `3` REG_BINARY, `4` REG_DWORD, `7` REG_MULTI_SZ; oder 0
- lpData: LPBYTE – der Puffer oder 0 (nur die Größe ermitteln)
- lpcbData: LPDWORD – Adresse der Puffergröße in Bytes; danach die Größe der Daten

**Ergebnis:** eax = 0 bei Erfolg; `234` ERROR_MORE_DATA, wenn der Puffer zu klein ist; `2`, wenn es den Wert nicht gibt

## RegSetValueExA, RegSetValueExW – Wert schreiben

advapi32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `RegSetValueExA(hKey, lpValueName, Reserved, dwType, lpData, cbData)`

- hKey: HKEY – offener Schlüssel mit Schreibrecht
- lpValueName: LPCSTR – Name des Werts
- Reserved: DWORD – 0
- dwType: DWORD – `1` REG_SZ, `4` REG_DWORD, `3` REG_BINARY
- lpData: const BYTE* – die Daten (REG_SZ samt der 0)
- cbData: DWORD – ihre Größe in Bytes

**Ergebnis:** eax = 0 bei Erfolg, sonst der Fehlercode

## RegCloseKey – Schlüssel schließen

advapi32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `RegCloseKey(hKey)`

- hKey: HKEY – von `RegOpenKeyExA` oder `RegCreateKeyExA` (nicht die HKEY_-Konstanten)

**Ergebnis:** eax = 0 bei Erfolg

## ShellExecuteA, ShellExecuteW – Datei öffnen wie im Explorer

shell32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `ShellExecuteA(hwnd, lpOperation, lpFile, lpParameters, lpDirectory, nShowCmd)`

- hwnd: HWND – Elternfenster oder 0
- lpOperation: LPCSTR – `open`, `print`, `explore` oder 0 (= open)
- lpFile: LPCSTR – Datei, Programm, Ordner oder URL (`https://...`)
- lpParameters: LPCSTR – Befehlszeile für ein Programm oder 0
- lpDirectory: LPCSTR – Arbeitsverzeichnis oder 0
- nShowCmd: int – `1` SW_SHOWNORMAL, `0` SW_HIDE

**Ergebnis:** eax = größer als 32 bei Erfolg; sonst ein Fehlercode (`2` nicht gefunden, `31` keine Verknüpfung)

## CommandLineToArgvW – Befehlszeile zerlegen

shell32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `CommandLineToArgvW(lpCmdLine, pNumArgs)`

- lpCmdLine: LPCWSTR – die Befehlszeile als UTF-16 (`GetCommandLineW`)
- pNumArgs: int* – Adresse für die Anzahl der Teile

**Ergebnis:** eax = Zeiger auf eine Tabelle von Zeigern auf die Teile (UTF-16); 0 bei Fehler. Freigeben mit `LocalFree`.

Nur die W-Form gibt es; Anführungszeichen werden wie bei C-Programmen behandelt.

## SysAllocString, SysAllocStringLen – BSTR anlegen

oleaut32.dll · stdcall · 1 Parameter (4 Bytes) / 2 Parameter

**Aufruf:** `SysAllocString(psz)`, `SysAllocStringLen(strIn, ui)`

- psz, strIn: const OLECHAR* – UTF-16-Text (0 erlaubt bei `SysAllocStringLen`: nur Platz)
- ui: UINT – Anzahl Zeichen

**Ergebnis:** eax = BSTR: Zeiger auf den UTF-16-Text, davor (Offset -4) seine Länge in Bytes; 0 bei Fehler

Der String-Typ von COM und Automation; Delphi benutzt ihn für `WideString`. Freigeben mit `SysFreeString`.

## SysReAllocString, SysReAllocStringLen – BSTR neu belegen

oleaut32.dll · stdcall · 2 Parameter (8 Bytes) / 3 Parameter

**Aufruf:** `SysReAllocStringLen(pbstr, psz, len)`

- pbstr: BSTR* – Adresse der Variablen mit dem alten BSTR (darf 0 enthalten)
- psz: const OLECHAR* – der neue Text oder 0
- len: UINT – Anzahl Zeichen

**Ergebnis:** eax = 1 bei Erfolg, 0 wenn kein Speicher

Delphi ruft es bei jeder Zuweisung an einen `WideString`.

## SysFreeString – BSTR freigeben

oleaut32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SysFreeString(bstrString)`

- bstrString: BSTR – der String (0 erlaubt)

**Ergebnis:** keins

## SysStringLen – Länge eines BSTR

oleaut32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SysStringLen(pbstr)`

- pbstr: BSTR – der String (0 erlaubt: Ergebnis 0)

**Ergebnis:** eax = Anzahl Zeichen (das Doppelwort vor dem Text geteilt durch 2)

## VariantInit, VariantClear – Variant anlegen und leeren

oleaut32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `VariantInit(pvarg)`, `VariantClear(pvarg)`

- pvarg: VARIANTARG* – Adresse einer VARIANT von 16 Bytes: Typ im ersten Wort (`0` VT_EMPTY, `2` VT_I2, `3` VT_I4, `5` VT_R8, `8` VT_BSTR, `11` VT_BOOL, `12` VT_VARIANT, `0x2000` VT_ARRAY, `0x4000` VT_BYREF), der Wert ab Offset 8

**Ergebnis:** `VariantInit`: keins (setzt VT_EMPTY). `VariantClear`: eax = 0 bei Erfolg; gibt BSTR, Interface oder SafeArray im Variant frei

Delphi: der Typ `Variant`/`OleVariant`.

## VariantCopy – Variant kopieren

oleaut32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `VariantCopy(pvargDest, pvargSrc)`

- pvargDest: VARIANTARG* – das Ziel (wird vorher mit `VariantClear` geleert)
- pvargSrc: const VARIANTARG* – die Quelle

**Ergebnis:** eax = HRESULT: 0 S_OK, negativ bei Fehler

Ein BSTR oder SafeArray wird dabei kopiert, ein Interface bekommt `AddRef`.

## VariantChangeType – Typ eines Variants wandeln

oleaut32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `VariantChangeType(pvargDest, pvarSrc, wFlags, vt)`

- pvargDest: VARIANTARG* – das Ziel (darf pvarSrc sein)
- pvarSrc: const VARIANTARG* – die Quelle
- wFlags: USHORT – 0; `2` VARIANT_ALPHABOOL (True/False statt -1/0)
- vt: VARTYPE – der gewünschte Typ (`3` VT_I4, `5` VT_R8, `8` VT_BSTR, ...)

**Ergebnis:** eax = HRESULT: 0 S_OK; `0x80020005` DISP_E_TYPEMISMATCH; `0x8002000A` DISP_E_OVERFLOW

So wird aus `'42'` die Zahl 42 und umgekehrt (Delphi `VarAsType`, implizite Variant-Umwandlungen).

## SafeArrayCreate – Feld für Variants anlegen

oleaut32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `SafeArrayCreate(vt, cDims, rgsabound)`

- vt: VARTYPE – Typ der Elemente (`12` VT_VARIANT, `3` VT_I4, `8` VT_BSTR, `17` VT_UI1 für Bytes)
- cDims: UINT – Anzahl Dimensionen
- rgsabound: SAFEARRAYBOUND* – je Dimension 8 Bytes: cElements, lLbound (unterer Index)

**Ergebnis:** eax = SAFEARRAY*; 0 bei Fehler. Freigeben mit `SafeArrayDestroy` oder über `VariantClear`.

Delphi: `VarArrayCreate`.

## SafeArrayGetLBound, SafeArrayGetUBound – Grenzen eines SafeArrays

oleaut32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `SafeArrayGetLBound(psa, nDim, plLbound)`, `SafeArrayGetUBound(psa, nDim, plUbound)`

- psa: SAFEARRAY* – das Feld
- nDim: UINT – die Dimension, ab 1
- plLbound, plUbound: LONG* – Adresse für die untere bzw. obere Grenze (einschließlich)

**Ergebnis:** eax = HRESULT: 0 S_OK; `0x8002000B` DISP_E_BADINDEX

Delphi: `VarArrayLowBound`, `VarArrayHighBound`.

## SafeArrayPtrOfIndex – Adresse eines Elements

oleaut32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `SafeArrayPtrOfIndex(psa, rgIndices, ppvData)`

- psa: SAFEARRAY* – das Feld
- rgIndices: LONG* – ein Index je Dimension (die letzte Dimension zuerst)
- ppvData: void** – Adresse für den Zeiger auf das Element

**Ergebnis:** eax = HRESULT: 0 S_OK; `0x8002000B` DISP_E_BADINDEX

Delphi liest und schreibt so `V[i]` eines Variant-Arrays.

## SafeArrayAccessData, SafeArrayUnaccessData – Daten sperren

oleaut32.dll · stdcall · 2 Parameter (8 Bytes) / 1 Parameter

**Aufruf:** `SafeArrayAccessData(psa, ppvData)`, `SafeArrayUnaccessData(psa)`

- psa: SAFEARRAY* – das Feld
- ppvData: void** – Adresse für den Zeiger auf das erste Element

**Ergebnis:** eax = HRESULT: 0 S_OK

Zwischen beiden darf man die Elemente direkt im Speicher lesen und schreiben (Delphi `VarArrayLock`, `VarArrayUnlock`).

## printf – formatiert ausgeben

msvcrt.dll · cdecl · 1 Parameter und mehr (der Aufrufer räumt den Stack)

**Aufruf:** `printf(format, ...)`

- format: const char* – der Text mit Platzhaltern: `%d` Zahl mit Vorzeichen, `%u` ohne, `%x`/`%X` hexadezimal, `%08X` mit 8 Stellen und Nullen, `%s` Text, `%c` Zeichen, `%f` Gleitkomma (8 Bytes), `%%` Prozent, `\n` ist das Byte `0x0A`
- ...: die Werte in der Reihenfolge der Platzhalter, je 4 Bytes (`%f`: 8)

**Ergebnis:** eax = Anzahl geschriebener Zeichen; negativ bei Fehler

Schreibt auf die Standardausgabe (gepuffert: bis zum Zeilenende oder zum Programmende). Nach dem Aufruf den Stack selbst abräumen.

```asm
push 42
push fmt       ; "x = %d", 10, 0
call [printf]
add esp, 8
```

## sprintf – formatiert in einen Puffer

msvcrt.dll · cdecl · 2 Parameter und mehr (der Aufrufer räumt den Stack)

**Aufruf:** `sprintf(buffer, format, ...)`

- buffer: char* – der Puffer (groß genug; `_snprintf` begrenzt)
- format, ...: wie `printf`

**Ergebnis:** eax = Anzahl geschriebener Zeichen ohne die 0

## puts, putchar – Text und Zeichen ausgeben

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `puts(str)`, `putchar(c)`

- str: const char* – 0-terminierter Text; `puts` hängt einen Zeilenumbruch an
- c: int – das Zeichen

**Ergebnis:** eax = nicht negativ bei Erfolg bzw. das Zeichen; `-1` EOF bei Fehler

## getchar, _getch – Zeichen lesen

msvcrt.dll · cdecl · keine Parameter

**Aufruf:** `getchar()`, `_getch()`

**Ergebnis:** eax = das Zeichen; `-1` EOF am Ende der Eingabe

`getchar` liest aus der gepufferten Standardeingabe (erst nach der Eingabe-Taste); `_getch` wartet auf eine einzelne Taste ohne Echo, typisch für „Taste drücken“ am Programmende.

## scanf – formatiert einlesen

msvcrt.dll · cdecl · 1 Parameter und mehr (der Aufrufer räumt den Stack)

**Aufruf:** `scanf(format, ...)`

- format: const char* – Platzhalter wie bei `printf` (`%d`, `%s`, `%c`, `%f` erwartet `float*`, `%lf` `double*`)
- ...: Adressen der Variablen, in die gelesen wird

**Ergebnis:** eax = Anzahl zugewiesener Werte; `-1` EOF

## strlen – Länge eines Texts

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `strlen(str)`

- str: const char* – 0-terminierter Text

**Ergebnis:** eax = Anzahl Bytes ohne die 0

Auch in `api-ms-win-crt-string-l1-1-0.dll` (clang, Visual C++ ab 2015).

## strcpy, strncpy, strcat – Text kopieren und anhängen

msvcrt.dll · cdecl · 2 Parameter (der Aufrufer räumt den Stack); `strncpy` 3

**Aufruf:** `strcpy(dest, src)`, `strcat(dest, src)`, `strncpy(dest, src, count)`

- dest: char* – das Ziel (groß genug)
- src: const char* – die Quelle, 0-terminiert
- count: size_t – höchstens so viele Bytes (`strncpy` füllt mit Nullen auf, setzt aber keine 0, wenn src länger ist)

**Ergebnis:** eax = dest

## strcmp, strncmp, _stricmp – Texte vergleichen

msvcrt.dll · cdecl · 2 Parameter (der Aufrufer räumt den Stack); `strncmp` 3

**Aufruf:** `strcmp(str1, str2)`

- str1, str2: const char* – die Texte
- count: size_t – `strncmp`: höchstens so viele Bytes

**Ergebnis:** eax = 0 gleich, negativ wenn str1 kleiner, positiv wenn größer (Bytevergleich; `_stricmp` ohne Groß-/Kleinschreibung)

## memcpy, memmove, memset – Speicher kopieren und füllen

msvcrt.dll · cdecl · 3 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `memcpy(dest, src, count)`, `memmove(dest, src, count)`, `memset(dest, c, count)`

- dest: void* – das Ziel
- src: const void* – die Quelle (`memmove` darf sich mit dest überlappen)
- c: int – das Füllbyte (`memset`)
- count: size_t – Anzahl Bytes

**Ergebnis:** eax = dest

Auch in `api-ms-win-crt-private-l1-1-0.dll` (clang). Entspricht `rep movsb` / `rep stosb`.

## malloc, calloc, realloc, free – Speicher der C-Laufzeit

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack); `calloc`, `realloc` 2

**Aufruf:** `malloc(size)`, `calloc(num, size)`, `realloc(ptr, size)`, `free(ptr)`

- size: size_t – Anzahl Bytes (`calloc`: je Element, mit Nullen gefüllt)
- num: size_t – Anzahl Elemente
- ptr: void* – ein Block von `malloc` (`free(0)` ist erlaubt)

**Ergebnis:** eax = Adresse des Blocks; 0, wenn kein Speicher da ist. `free`: keins

Auch in `api-ms-win-crt-heap-l1-1-0.dll`. Intern ein Heap wie `HeapAlloc`.

## atoi, atol, strtol – Text in Zahl

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack); `strtol` 3

**Aufruf:** `atoi(str)`, `strtol(str, endptr, base)`

- str: const char* – Ziffern, davor Leerzeichen und Vorzeichen erlaubt
- endptr: char** – Adresse für den Zeiger hinter die Zahl oder 0
- base: int – Basis 2 bis 36; 0: `0x` hexadezimal, `0` oktal, sonst dezimal

**Ergebnis:** eax = die Zahl; 0, wenn keine Ziffer da ist

## exit, _exit – Programm beenden (C-Laufzeit)

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `exit(status)`, `_exit(status)`

- status: int – der Rückgabewert des Programms

**Ergebnis:** kehrt nicht zurück

`exit` ruft erst die `atexit`-Funktionen, schließt die Dateien und leert die Puffer (`_cexit`), dann `ExitProcess`; `_exit` beendet sofort. Auch in `api-ms-win-crt-runtime-l1-1-0.dll`.

## abort – Programm abbrechen

msvcrt.dll · cdecl · keine Parameter

**Aufruf:** `abort()`

**Ergebnis:** kehrt nicht zurück

Löst SIGABRT aus und beendet mit Code 3; unter Windows meist mit dem Dialog „abnormal program termination“. Der Compiler setzt es hinter Code, der nicht zurückkehren darf.

## system – Befehl ausführen

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `system(command)`

- command: const char* – eine Befehlszeile für `cmd.exe` (`pause`, `cls`, `dir`); 0: prüft, ob es einen Befehlsinterpreter gibt

**Ergebnis:** eax = Rückgabewert des Befehls; `-1` bei Fehler

## rand, srand – Zufallszahlen

msvcrt.dll · cdecl · keine Parameter / 1 Parameter

**Aufruf:** `rand()`, `srand(seed)`

- seed: unsigned int – Startwert, oft `time(0)`

**Ergebnis:** `rand`: eax = Zahl von 0 bis 32767; ohne `srand` jedes Mal dieselbe Folge

## time – Sekunden seit 1970

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `time(destTime)`

- destTime: time_t* – Adresse für den Wert oder 0

**Ergebnis:** edx:eax = Sekunden seit dem 1.1.1970 UTC (64 Bit; `_time32`: 32 Bit in eax)

## fopen, fclose – Datei öffnen und schließen (C-Laufzeit)

msvcrt.dll · cdecl · 2 Parameter (der Aufrufer räumt den Stack); `fclose` 1

**Aufruf:** `fopen(filename, mode)`, `fclose(stream)`

- filename: const char* – der Pfad
- mode: const char* – `r` lesen, `w` schreiben (neu), `a` anhängen, dazu `b` binär (`rb`, `wb`), `+` lesen und schreiben
- stream: FILE* – von `fopen`

**Ergebnis:** `fopen`: eax = FILE* oder 0 bei Fehler. `fclose`: 0 bei Erfolg, `-1` EOF

## fread, fwrite – Blöcke lesen und schreiben (C-Laufzeit)

msvcrt.dll · cdecl · 4 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `fread(buffer, size, count, stream)`, `fwrite(buffer, size, count, stream)`

- buffer: void* – der Puffer
- size: size_t – Größe eines Elements in Bytes
- count: size_t – Anzahl Elemente
- stream: FILE* – von `fopen`, oder `stdin`/`stdout`/`stderr` (`__acrt_iob_func(0..2)`)

**Ergebnis:** eax = Anzahl vollständig gelesener oder geschriebener Elemente (kleiner als count: Dateiende oder Fehler)

## fprintf – formatiert in eine Datei

msvcrt.dll · cdecl · 2 Parameter und mehr (der Aufrufer räumt den Stack)

**Aufruf:** `fprintf(stream, format, ...)`

- stream: FILE* – die Datei oder `stderr` für Fehlermeldungen
- format, ...: wie `printf`

**Ergebnis:** eax = Anzahl geschriebener Zeichen; negativ bei Fehler

## fflush – Puffer einer Datei leeren

msvcrt.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `fflush(stream)`

- stream: FILE* – die Datei oder `stdout`; 0: alle offenen Dateien

**Ergebnis:** eax = 0 bei Erfolg; `-1` EOF bei Fehler

Auch in `api-ms-win-crt-stdio-l1-1-0.dll`. Nötig, wenn die Ausgabe sofort erscheinen soll (`printf` ohne Zeilenende vor `_getch`).

## setvbuf – Pufferung einer Datei

msvcrt.dll · cdecl · 4 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `setvbuf(stream, buffer, mode, size)`

- stream: FILE* – die Datei oder `stdout`
- buffer: char* – eigener Puffer oder 0
- mode: int – `0` _IOFBF voll gepuffert, `0x40` _IOLBF zeilenweise, `4` _IONBF ungepuffert
- size: size_t – Puffergröße

**Ergebnis:** eax = 0 bei Erfolg

Die Startroutine von clang/MinGW schaltet damit die Pufferung von stdout und stderr um.

## __acrt_iob_func – stdin, stdout, stderr

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `__acrt_iob_func(index)`

- index: unsigned – `0` stdin, `1` stdout, `2` stderr

**Ergebnis:** eax = FILE* des Standardstroms

Die universelle C-Laufzeit (ucrt, Visual C++ ab 2015, clang) hat keine Variablen `stdin`/`stdout` mehr; `printf(...)` ist bei ihr `__stdio_common_vfprintf(..., __acrt_iob_func(1), ...)`.

## __stdio_common_vfprintf – das printf der ucrt

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · 5 Parameter, 24 Bytes (der Aufrufer räumt den Stack)

**Aufruf:** `__stdio_common_vfprintf(options, stream, format, locale, arglist)`

- options: unsigned __int64 – Optionen (8 Bytes), meist `1` (_CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION) oder 0
- stream: FILE* – `__acrt_iob_func(1)` für stdout
- format: const char* – das Format wie bei `printf`
- locale: _locale_t – 0
- arglist: va_list – Zeiger auf die Werte auf dem Stack

**Ergebnis:** eax = Anzahl geschriebener Zeichen; negativ bei Fehler

Alle `printf`-Varianten der ucrt (`printf`, `fprintf`, `vprintf`) sind in der Header-Datei als Inline-Funktionen auf diesen Aufruf zurückgeführt; so sieht man im Programm nie `printf` selbst.

## __p__commode, __p__fmode – Modus-Variablen der ucrt

api-ms-win-crt-stdio-l1-1-0.dll · cdecl · keine Parameter

**Aufruf:** `__p__commode()`, `__p__fmode()`

**Ergebnis:** eax = Adresse der Variablen `_commode` (Commit-Modus beim Schreiben) bzw. `_fmode` (`0x4000` Text, `0x8000` binär für neue Dateien)

Die Startroutine schreibt ihre Vorgaben hinein.

## __p___argc, __p___argv, __p__environ – argc, argv, environ der ucrt

api-ms-win-crt-runtime-l1-1-0.dll, api-ms-win-crt-environment-l1-1-0.dll · cdecl · keine Parameter

**Aufruf:** `__p___argc()`, `__p___argv()`, `__p__environ()`

**Ergebnis:** eax = Adresse der Variablen: `int argc`, `char** argv`, `char** environ`

Nach `_configure_narrow_argv` stehen dort die zerlegte Befehlszeile und die Umgebung; `main(argc, argv)` bekommt die Werte von hier.

## _configure_narrow_argv, _initialize_narrow_environment – Befehlszeile und Umgebung einrichten

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 Parameter / keine (der Aufrufer räumt den Stack)

**Aufruf:** `_configure_narrow_argv(mode)`, `_initialize_narrow_environment()`

- mode: int – `0` keine Platzhalter, `1` `*` und `?` in Argumenten auflösen (_crt_argv_expanded_arguments)

**Ergebnis:** eax = 0 bei Erfolg (errno-Wert)

Teil der Startroutine vor `main`: zerlegt `GetCommandLineA` in argc/argv und kopiert die Umgebung.

## _initterm, _initterm_e – Initialisierungsfunktionen aufrufen

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 2 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `_initterm(first, last)`, `_initterm_e(first, last)`

- first, last: _PVFV* – Anfang und Ende einer Tabelle von Funktionszeigern (Section `.CRT$XCA` bis `.CRT$XCZ`); Einträge 0 werden übersprungen

**Ergebnis:** `_initterm`: keins. `_initterm_e`: eax = 0, oder der erste Fehlercode, den eine Funktion zurückgab (sie geben `int`)

So laufen die Konstruktoren globaler C++-Objekte und die Initialisierung der Laufzeit vor `main`.

## _crt_atexit, _cexit – Aufräumen am Ende

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 Parameter / keine (der Aufrufer räumt den Stack)

**Aufruf:** `_crt_atexit(function)`, `_cexit()`

- function: _PVFV – eine Funktion ohne Parameter, die `exit` später aufruft (das `atexit` der ucrt)

**Ergebnis:** `_crt_atexit`: eax = 0 bei Erfolg. `_cexit`: keins

`_cexit` ruft die `atexit`-Funktionen und leert die Puffer, beendet aber den Prozess nicht; die Startroutine ruft es, wenn `main` zurückkehrt, und danach `ExitProcess`.

## _set_app_type – Konsole oder Fenster

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `_set_app_type(type)`

- type: int – `1` _crt_console_app, `2` _crt_gui_app

**Ergebnis:** keins

Bestimmt, ob Fehlermeldungen der Laufzeit auf stderr oder in einem Meldungsfenster erscheinen.

## _set_invalid_parameter_handler, _set_new_mode, __setusermatherr – Verhalten der Laufzeit

api-ms-win-crt-runtime-l1-1-0.dll, api-ms-win-crt-heap-l1-1-0.dll, api-ms-win-crt-math-l1-1-0.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `_set_invalid_parameter_handler(handler)`, `_set_new_mode(mode)`, `__setusermatherr(handler)`

- handler: Funktionszeiger – wird bei ungültigen Parametern (z. B. `strcpy_s` mit 0) bzw. bei Mathematikfehlern gerufen; 0: die Vorgabe
- mode: int – `1`: `malloc` ruft bei Speichermangel den `new`-Handler

**Ergebnis:** eax = der vorherige Handler bzw. Modus

Die Startroutine von MinGW/clang setzt alle drei einmal.

## _configthreadlocale – Locale je Thread

api-ms-win-crt-locale-l1-1-0.dll · cdecl · 1 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `_configthreadlocale(type)`

- type: int – `1` _ENABLE_PER_THREAD_LOCALE, `2` _DISABLE_PER_THREAD_LOCALE, `0` nur lesen

**Ergebnis:** eax = die vorherige Einstellung; `-1` bei Fehler

## _fpreset – Gleitkommaeinheit zurücksetzen

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · keine Parameter

**Aufruf:** `_fpreset()`

**Ergebnis:** keins

Setzt das Steuerwort der FPU auf die Vorgabe der Laufzeit (`fninit` und Rundung); nach Ausnahmen und beim Start.

## _seh_filter_exe – Ausnahmefilter der Laufzeit

api-ms-win-crt-runtime-l1-1-0.dll · cdecl · 2 Parameter (der Aufrufer räumt den Stack)

**Aufruf:** `_seh_filter_exe(exceptionNum, exceptionPtr)`

- exceptionNum: unsigned long – der Ausnahmecode (`0xC0000005` Zugriffsverletzung, `0xC0000094` Division durch 0)
- exceptionPtr: struct _EXCEPTION_POINTERS* – Ausnahme und Register

**Ergebnis:** eax = `1` EXCEPTION_EXECUTE_HANDLER, `0` CONTINUE_SEARCH, `-1` CONTINUE_EXECUTION

Macht aus Hardware-Ausnahmen die Signale SIGSEGV und SIGFPE für `signal()`; die Startroutine umschließt `main` damit.

## CLSIDFromString – Text in eine GUID wandeln

ole32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `CLSIDFromString(lpsz, pclsid)`

- lpsz: LPCOLESTR – UTF-16-Text der Form `{00000000-0000-0000-0000-000000000000}`
- pclsid: LPCLSID – Adresse von 16 Bytes für die GUID

**Ergebnis:** eax = HRESULT: 0 S_OK; `0x800401F3` CO_E_CLASSSTRING bei falschem Text

Umkehrung von `StringFromGUID2`. Delphi: `StringToGUID`.

## StringFromGUID2 – GUID in Text wandeln

ole32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `StringFromGUID2(rguid, lpsz, cchMax)`

- rguid: REFGUID – Adresse der 16 Bytes
- lpsz: LPOLESTR – der Puffer für UTF-16-Text
- cchMax: int – seine Größe in Zeichen (mindestens 39)

**Ergebnis:** eax = Anzahl geschriebener Zeichen samt 0 (39); 0, wenn der Puffer zu klein ist

Schreibt die GUID als `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`. Delphi: `GUIDToString`.

## CharToOemBuffA, OemToCharBuffA – Windows- und DOS-Zeichensatz (mit Länge)

user32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `CharToOemBuffA(lpszSrc, lpszDst, cchDstLength)`

- lpszSrc: LPCSTR – der Text (keine 0 nötig)
- lpszDst: LPSTR – der Puffer, darf lpszSrc sein
- cchDstLength: DWORD – Anzahl Zeichen

**Ergebnis:** eax = 1

Wie `CharToOemA`, aber für einen Text mit bekannter Länge.

## CharUpperBuffA, CharLowerBuffA – Groß- und Kleinbuchstaben (mit Länge)

user32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `CharUpperBuffA(lpsz, cchLength)`

- lpsz: LPSTR – der Text, wird an der Stelle geändert
- cchLength: DWORD – Anzahl Zeichen (keine 0 nötig)

**Ergebnis:** eax = Anzahl bearbeiteter Zeichen

## EnumThreadWindows – Fenster eines Threads aufzählen

user32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `EnumThreadWindows(dwThreadId, lpfn, lParam)`

- dwThreadId: DWORD – die Threadnummer
- lpfn: WNDENUMPROC – eigene Funktion (stdcall, 2 Parameter: hwnd, lParam), die je Fenster gerufen wird; Ergebnis 1 = weiter, 0 = Ende
- lParam: LPARAM – wird an die Funktion durchgereicht

**Ergebnis:** eax = 0, wenn die Funktion 0 zurückgab oder es keine Fenster gibt, sonst 1

Delphi deaktiviert so beim Modalfenster alle Fenster des Programms.

## FileTimeToDosDateTime – Dateizeit in DOS-Datum und -Zeit

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `FileTimeToDosDateTime(lpFileTime, lpFatDate, lpFatTime)`

- lpFileTime: const FILETIME* – 8 Bytes, 100-ns-Schritte seit 1601
- lpFatDate: LPWORD – Datum: Bits 0..4 Tag, 5..8 Monat, 9..15 Jahr minus 1980
- lpFatTime: LPWORD – Zeit: Bits 0..4 Sekunden / 2, 5..10 Minute, 11..15 Stunde

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Das Format der Dateizeit in FAT-Verzeichnissen und im Delphi-`FileAge`. Umkehrung: `DosDateTimeToFileTime`.

## FileTimeToLocalFileTime, LocalFileTimeToFileTime – UTC und Ortszeit

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `FileTimeToLocalFileTime(lpFileTime, lpLocalFileTime)`

- lpFileTime: const FILETIME* – die Zeit in UTC
- lpLocalFileTime: LPFILETIME – Adresse für die Ortszeit (darf lpFileTime sein)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Verschiebt um die aktuelle Zeitzone (`GetTimeZoneInformation`).

## SystemTimeToFileTime, FileTimeToSystemTime – Zeitformate umwandeln

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SystemTimeToFileTime(lpSystemTime, lpFileTime)`

- lpSystemTime: const SYSTEMTIME* – 16 Bytes (Jahr, Monat, Wochentag, Tag, Stunde, Minute, Sekunde, Millisekunde)
- lpFileTime: LPFILETIME – Adresse für 8 Bytes (100-ns-Schritte seit 1601)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler (z. B. Monat 13)

`FileTimeToSystemTime` rechnet zurück, Parameter in umgekehrter Rolle.

## GetTimeZoneInformation – Zeitzone

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetTimeZoneInformation(lpTimeZoneInformation)`

- lpTimeZoneInformation: LPTIME_ZONE_INFORMATION – Struktur von 172 Bytes: Bias (Minuten, UTC = Ortszeit + Bias; Deutschland im Winter -60), Name der Normalzeit, Beginn, Bias der Normalzeit, Name der Sommerzeit, Beginn, Bias der Sommerzeit

**Ergebnis:** eax = `0` unbekannt, `1` es gilt Normalzeit, `2` es gilt Sommerzeit; `0xFFFFFFFF` bei Fehler

## FindResourceA, FindResourceW – Ressource suchen

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `FindResourceA(hModule, lpName, lpType)`

- hModule: HMODULE – das Modul mit der Ressource, 0 für das Programm
- lpName: LPCSTR – Name oder Nummer (Nummer in den unteren 16 Bit, obere 0)
- lpType: LPCSTR – Typ: `3` RT_ICON, `6` RT_STRING, `10` RT_RCDATA, `14` RT_GROUP_ICON, `16` RT_VERSION, `24` RT_MANIFEST oder ein Name

**Ergebnis:** eax = HRSRC; 0 bei Fehler

Danach `LoadResource`, `LockResource` und `SizeofResource`.

## FindResourceExA, FindResourceExW – Ressource suchen (mit Sprache)

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `FindResourceExA(hModule, lpType, lpName, wLanguage)`

- hModule: HMODULE – das Modul mit der Ressource
- lpType: LPCSTR – Typ (Achtung: vor dem Namen, anders als bei `FindResourceA`)
- lpName: LPCSTR – Name oder Nummer
- wLanguage: WORD – Sprache (`0` neutral, `0x407` Deutsch, `0x409` Englisch USA)

**Ergebnis:** eax = HRSRC; 0 bei Fehler

## LoadResource – Ressource laden

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `LoadResource(hModule, hResInfo)`

- hModule: HMODULE – das Modul
- hResInfo: HRSRC – von `FindResourceA`

**Ergebnis:** eax = HGLOBAL; 0 bei Fehler

Unter Win32 steht die Ressource schon im Speicher: `LockResource` macht daraus den Zeiger.

## LockResource, FreeResource – Ressource sperren und freigeben

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `LockResource(hResData)`

- hResData: HGLOBAL – von `LoadResource`

**Ergebnis:** eax = Zeiger auf die Daten; 0 bei Fehler. `FreeResource`: 0 bei Erfolg

## SizeofResource – Größe einer Ressource

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SizeofResource(hModule, hResInfo)`

- hModule: HMODULE – das Modul
- hResInfo: HRSRC – von `FindResourceA`

**Ergebnis:** eax = Größe in Bytes; 0 bei Fehler

## GetCurrentDirectoryA, GetCurrentDirectoryW – aktuelles Verzeichnis

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetCurrentDirectoryA(nBufferLength, lpBuffer)`

- nBufferLength: DWORD – Größe des Puffers in Zeichen samt 0
- lpBuffer: LPSTR – der Puffer

**Ergebnis:** eax = Länge des Pfads ohne 0; größer als nBufferLength: nötige Größe samt 0; 0 bei Fehler

## SetCurrentDirectoryA, SetCurrentDirectoryW – aktuelles Verzeichnis setzen

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetCurrentDirectoryA(lpPathName)`

- lpPathName: LPCSTR – der Pfad

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Gilt für den ganzen Prozess, nicht nur für einen Thread.

## GetDriveTypeA, GetDriveTypeW – Art eines Laufwerks

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GetDriveTypeA(lpRootPathName)`

- lpRootPathName: LPCSTR – `C:\` oder 0 für das aktuelle Laufwerk

**Ergebnis:** eax = `0` unbekannt, `1` es gibt kein Laufwerk, `2` Wechseldatenträger, `3` Festplatte, `4` Netzlaufwerk, `5` CD/DVD, `6` RAM-Disk

## GetLogicalDrives – vorhandene Laufwerke

kernel32.dll · stdcall · keine Parameter

**Aufruf:** `GetLogicalDrives()`

**Ergebnis:** eax = Bitmaske: Bit 0 Laufwerk A, Bit 1 B, Bit 2 C, ...; 0 bei Fehler

## GetEnvironmentStrings, GetEnvironmentStringsA, GetEnvironmentStringsW, FreeEnvironmentStringsA, FreeEnvironmentStringsW – ganze Umgebung

kernel32.dll · stdcall · keine Parameter / 1 Parameter

**Aufruf:** `GetEnvironmentStrings()`, `FreeEnvironmentStringsA(lpszEnvironmentBlock)`

- lpszEnvironmentBlock: LPSTR – der Zeiger von `GetEnvironmentStrings`

**Ergebnis:** eax = Zeiger auf einen Block von Texten `NAME=Wert`, je mit 0 beendet, am Ende eine zusätzliche 0

Zum Durchlaufen: bis zur 0 lesen, dann gleich weiter; ein leerer Text beendet den Block. Freigeben mit `FreeEnvironmentStringsA`.

## SetEnvironmentVariableA, SetEnvironmentVariableW – Umgebungsvariable setzen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetEnvironmentVariableA(lpName, lpValue)`

- lpName: LPCSTR – der Name
- lpValue: LPCSTR – der Wert; 0 löscht die Variable

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Gilt nur für den eigenen Prozess und die Programme, die er danach startet.

## GetFileInformationByHandle – Angaben zu einer Datei

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `GetFileInformationByHandle(hFile, lpFileInformation)`

- hFile: HANDLE – offene Datei
- lpFileInformation: LPBY_HANDLE_FILE_INFORMATION – Struktur von 52 Bytes: Attribute, Erstellungszeit, letzter Zugriff, letzte Änderung (je 8 Bytes), Seriennummer des Laufwerks, Größe (hoch, niedrig), Anzahl Verknüpfungen, Index der Datei (hoch, niedrig)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Zwei Handles sind dieselbe Datei, wenn Seriennummer und Index gleich sind.

## GetTempFileNameA, GetTempFileNameW – Namen für eine temporäre Datei

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `GetTempFileNameA(lpPathName, lpPrefixString, uUnique, lpTempFileName)`

- lpPathName: LPCSTR – der Ordner (`GetTempPathA`)
- lpPrefixString: LPCSTR – bis zu 3 Zeichen für den Anfang des Namens
- uUnique: UINT – 0: Windows wählt die Zahl und legt die leere Datei an; sonst diese Zahl in hexadezimal, ohne Anlegen
- lpTempFileName: LPSTR – Puffer von mindestens 260 Zeichen

**Ergebnis:** eax = die benutzte Zahl; 0 bei Fehler

## MoveFileA, MoveFileW – Datei verschieben oder umbenennen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `MoveFileA(lpExistingFileName, lpNewFileName)`

- lpExistingFileName: LPCSTR – die vorhandene Datei oder der Ordner
- lpNewFileName: LPCSTR – der neue Name (darf noch nicht existieren)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Zwischen Laufwerken kopiert und löscht Windows selbst.

## CopyFileA, CopyFileW – Datei kopieren

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `CopyFileA(lpExistingFileName, lpNewFileName, bFailIfExists)`

- lpExistingFileName: LPCSTR – die Quelle
- lpNewFileName: LPCSTR – das Ziel
- bFailIfExists: BOOL – 1: scheitert, wenn das Ziel schon da ist; 0: überschreibt

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

## SearchPathA, SearchPathW – Datei in Verzeichnissen suchen

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `SearchPathA(lpPath, lpFileName, lpExtension, nBufferLength, lpBuffer, lpFilePart)`

- lpPath: LPCSTR – Liste von Ordnern, durch `;` getrennt, oder 0 (Programmordner, aktueller Ordner, System, `PATH`)
- lpFileName: LPCSTR – der Dateiname
- lpExtension: LPCSTR – Endung, die angehängt wird, wenn der Name keine hat (mit Punkt), oder 0
- nBufferLength: DWORD – Größe des Puffers in Zeichen
- lpBuffer: LPSTR – der Puffer für den vollständigen Pfad
- lpFilePart: LPSTR* – Adresse eines Zeigers auf den Dateinamen im Puffer oder 0

**Ergebnis:** eax = Länge des Pfads ohne 0; 0, wenn die Datei nicht gefunden wird

## SetConsoleCtrlHandler – Strg+C und Schließen abfangen

kernel32.dll · stdcall · 2 Parameter (8 Bytes)

**Aufruf:** `SetConsoleCtrlHandler(HandlerRoutine, Add)`

- HandlerRoutine: PHANDLER_ROUTINE – eigene Funktion (stdcall, 1 Parameter: `0` CTRL_C_EVENT, `1` CTRL_BREAK_EVENT, `2` CTRL_CLOSE_EVENT, `5` CTRL_LOGOFF_EVENT, `6` CTRL_SHUTDOWN_EVENT); Ergebnis 1 = behandelt, 0 = nächster Handler. 0 als Funktion mit Add = 1: Strg+C wird ignoriert
- Add: BOOL – 1 hinzufügen, 0 entfernen

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Die Funktion läuft in einem eigenen Thread des Prozesses.

## GlobalMemoryStatus – Speicherausbau (alt)

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `GlobalMemoryStatus(lpBuffer)`

- lpBuffer: LPMEMORYSTATUS – Struktur von 32 Bytes: dwLength (vorher auf 32 setzen), Speicherlast in Prozent, physischer Speicher gesamt und frei, Auslagerungsdatei gesamt und frei, virtueller Adressraum gesamt und frei (alle in Bytes, bei mehr als 4 GB auf 4 GB begrenzt)

**Ergebnis:** keins

## LocalReAlloc, GlobalReAlloc – Speicher (alt) ändern

kernel32.dll · stdcall · 3 Parameter (12 Bytes)

**Aufruf:** `LocalReAlloc(hMem, uBytes, uFlags)`

- hMem: HLOCAL – ein Block von `LocalAlloc`
- uBytes: SIZE_T – die neue Größe
- uFlags: UINT – `0x2` LMEM_MOVEABLE (darf verschoben werden), `0x40` LMEM_ZEROINIT (neuer Teil mit Nullen), `0x80` LMEM_MODIFY (nur Eigenschaften ändern)

**Ergebnis:** eax = Adresse (oder Handle) des Blocks; 0 bei Fehler

## SetHandleCount – Anzahl Handles (veraltet)

kernel32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `SetHandleCount(uNumber)`

- uNumber: UINT – gewünschte Anzahl Datei-Handles

**Ergebnis:** eax = uNumber

Ohne Wirkung seit Windows NT; ältere Laufzeitbibliotheken rufen es beim Start.

## GetStringTypeW – Zeichenklassen eines UTF-16-Texts

kernel32.dll · stdcall · 4 Parameter (16 Bytes)

**Aufruf:** `GetStringTypeW(dwInfoType, lpSrcStr, cchSrc, lpCharType)`

- dwInfoType: DWORD – `1` CT_CTYPE1 (Buchstabe, Ziffer, ...), `2` CT_CTYPE2 (Schreibrichtung), `4` CT_CTYPE3
- lpSrcStr: LPCWSTR – der Text
- cchSrc: int – seine Länge in Zeichen; `-1`: bis zur 0
- lpCharType: LPWORD – ein Wort je Zeichen (Bits wie bei `GetStringTypeExA`)

**Ergebnis:** eax = 1 bei Erfolg, 0 bei Fehler

Keine Sprache nötig: die Klassen gelten für Unicode.

## IsCharAlphaA, IsCharAlphaW, IsCharAlphaNumericA, IsCharAlphaNumericW – Buchstabe oder Ziffer?

user32.dll · stdcall · 1 Parameter (4 Bytes)

**Aufruf:** `IsCharAlphaNumericA(ch)`

- ch: CHAR – das Zeichen (A-Form: das niedrigste Byte; W-Form: ein UTF-16-Zeichen)

**Ergebnis:** eax = ungleich 0, wenn es ein Buchstabe oder eine Ziffer ist (`IsCharAlpha...`: nur Buchstabe), sonst 0

Kennt die Umlaute der Sprache des Benutzers.

## IsDBCSLeadByte, IsDBCSLeadByteEx – erstes Byte eines Doppelbyte-Zeichens?

kernel32.dll · stdcall · 1 Parameter (4 Bytes); `IsDBCSLeadByteEx` 2

**Aufruf:** `IsDBCSLeadByteEx(CodePage, TestChar)`

- CodePage: UINT – die Codepage (`0` die von Windows); entfällt bei `IsDBCSLeadByte`
- TestChar: BYTE – das Byte

**Ergebnis:** eax = 1, wenn das Byte den Anfang eines Zeichens aus 2 Bytes bildet (z. B. in Japanisch), sonst 0

In westeuropäischen Codepages immer 0. Delphi baut damit seine Tabelle `LeadBytes`.

## LCMapStringA, LCMapStringW – Text nach Sprache umwandeln

kernel32.dll · stdcall · 6 Parameter (24 Bytes)

**Aufruf:** `LCMapStringA(Locale, dwMapFlags, lpSrcStr, cchSrc, lpDestStr, cchDest)`

- Locale: LCID – die Sprache (`0x400` LOCALE_USER_DEFAULT)
- dwMapFlags: DWORD – `0x100` LCMAP_LOWERCASE, `0x200` LCMAP_UPPERCASE, `0x400` LCMAP_SORTKEY (Sortierschlüssel), dazu `0x1` NORM_IGNORECASE
- lpSrcStr: LPCSTR – der Text
- cchSrc: int – seine Länge; `-1`: bis zur 0
- lpDestStr: LPSTR – der Puffer
- cchDest: int – seine Größe; 0: nur die nötige Größe ermitteln

**Ergebnis:** eax = Anzahl geschriebener (oder nötiger) Zeichen; 0 bei Fehler

Wandelt Umlaute richtig (`ä` nach `Ä`), anders als `and 0xDF`.
