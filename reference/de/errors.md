# Fehlermeldungen

Mit **F1** auf einer Zeile des Ausgabefensters (oder im Editor auf der als fehlerhaft markierten Zeile)
erklärt die Hilfe die Meldung: was sie bedeutet, was sie meistens verursacht und wie man sie behebt.
Die Abschnitte `err-...` gehören zum Assembler, `pe-...` zur Prüfung des fertigen Programms.

## err-unknown-instruction – unbekannter Befehl

**Meldung:** `unknown instruction: "movv"`

Der Assembler kennt das Wort am Zeilenanfang (das Mnemonic) nicht.

**Häufige Ursachen:**

- Tippfehler im Befehl (`movv`, `pussh`)
- ein Befehl eines anderen Prozessors: nach `.arch thumb` gelten die ARM-Namen, sonst die x86-Namen
- der Befehl existiert, wird vom Assembler aber noch nicht unterstützt (seltene FPU-, SSE- oder Systembefehle)
- ein eigener Name (Makro, Datenname), der ohne Doppelpunkt dort steht, wo ein Befehl erwartet wird

```asm
mov eax, 1      ; richtig
movv eax, 1     ; unknown instruction: "movv"
```

Verwandt: `err-label-colon`, `err-no-encoding`

## err-label-colon – ein Label braucht einen Doppelpunkt

**Meldung:** `unsupported instruction: "start" (a label needs a colon)`

Ein Wort am Zeilenanfang, das kein Befehl ist, gilt als Label, und ein Label endet mit einem Doppelpunkt.

```asm
start:          ; richtig
    mov eax, 1
start           ; falsch: kein Doppelpunkt
```

Verwandt: `err-unknown-instruction`

## err-undefined-label – Label nicht definiert

**Meldung:** `undefined label: "loop2"`

Ein Sprung, ein Aufruf oder eine Adresse nennt ein Label, das es im Programm nirgends gibt.

**Häufige Ursachen:**

- Tippfehler im Namen des Labels
- die Zeile mit dem Label fehlt oder ist auskommentiert
- eine Windows-Funktion, die nicht mit `.import` angegeben wurde
- ein Name aus einer Datenzeile (`db`, `dd`), die nie geschrieben wurde

```asm
    jmp done        ; undefined label: "done" ...
done:               ; ... bis diese Zeile existiert
```

Verwandt: `err-redefined-label`, `err-import`

## err-redefined-label – Label doppelt definiert

**Meldung:** `redefinition of Label: "start"`

Derselbe Name steht vor zwei verschiedenen Stellen. Ein Label bezeichnet genau eine Adresse, deshalb darf
jedes Label im ganzen Programm nur einmal definiert werden.

Benenne eines um (in langen Programmen hilft es, lokale Sprungmarken mit einem Präfix zu versehen:
`main_loop`, `copy_loop`).

Verwandt: `err-undefined-label`

## err-number – ungültige oder zu große Zahl

**Meldung:** `invalid number: "0x12G4"`, `number too large: "0x1FFFFFFFF"`

Eine Zahl ist in einer Form geschrieben, die der Assembler nicht lesen kann, oder sie passt nicht in 32 Bit.

- dezimal: `123`; hexadezimal mit dem Präfix `0x`: `0x7B`
- Buchstaben direkt hinter den Ziffern sind ein Fehler: `0FFh` oder `12ab` wird nicht akzeptiert, schreibe `0xFF`
- nach `0x` muss eine Hexziffer folgen: `0x` allein oder `0xZ` ist ungültig

Verwandt: `err-value-range`

## err-value-range – Wert außerhalb des Bereichs

**Meldung:** `value out of range for db: 300`

Eine Zahl passt nicht in das Datenelement, für das sie geschrieben wurde.

| Direktive | Größe | Erlaubt |
| --- | --- | --- |
| `db` | 8 Bit | -128 bis 255 |
| `dw` | 16 Bit | -32768 bis 65535 |
| `dd` | 32 Bit | -2147483648 bis 4294967295 |

```asm
db 300          ; zu groß: nimm dw
dw 300          ; richtig
```

Verwandt: `err-number`

## err-short-jump – kurzer Sprung außerhalb der Reichweite

**Meldung:** `short jump out of range`

Ein Sprung mit `short` (oder `loop`, `jcxz`, ein bedingter Sprung in 16-Bit-Code) erreicht nur 128 Bytes
zurück und 127 Bytes vor. Das Ziel ist weiter weg.

- `short` weglassen: der Assembler wählt dann selbst einen langen Sprung
- `loop` und `jcxz` gibt es nur kurz: ersetze sie durch `dec ecx` und `jnz`
- in 16-Bit-Code ist ein bedingter Sprung immer kurz: springe mit der umgekehrten Bedingung über ein `jmp`

```asm
    jz  far_away     ; in 16-Bit-Code zu weit
; stattdessen:
    jnz skip
    jmp far_away
skip:
```

Verwandt: `jmp`, `jcc`, `loop`

## err-branch-reach – der Sprung reicht nicht (ARM)

**Meldung:** `the branch does not reach its target in this form (write the instruction with ".w")`

Im Thumb-Modus hat ein bedingter Sprung eine kurze Form mit etwa 256 Bytes Reichweite. Das Ziel ist weiter
weg. Schreibe die 32-Bit-Form: `beq.w ziel` statt `beq ziel`. Ein unbedingtes `b` erreicht kurz etwa 2 KB,
als `b.w` 16 MB.

Verwandt: `b`, `bl`

## err-no-encoding – keine Kodierung (ARM)

**Meldung:** `no encoding for "add r0, r1, #100000"`

Der Befehl ist bekannt, aber nicht mit diesen Operanden: Thumb hat feste Grenzen für Zahlen und Register.

**Häufige Ursachen:**

- die Zahl (immediate) ist zu groß (viele Befehle nehmen 8 Bit, manche 12 Bit oder eine rotierte Zahl)
- ein hohes Register (r8 bis r15), wo nur r0 bis r7 erlaubt sind
- die Form braucht ein `s` (setzt Flags) oder hat keins: `adds` gegen `add`
- die Zahl lässt sich mit `movw`/`movt` bilden oder mit `ldr r0, =wert` laden

```asm
ldr r0, =0x12345678   ; richtig: die Zahl kommt in den Literal-Pool
mov r0, #0x12345678   ; no encoding
```

Verwandt: `err-unknown-instruction`, `movw, movt`, `ldr`

## err-prefix – mehrere Befehlspräfixe

**Meldung:** `multiple instruction prefixes not allowed`

Eine Zeile darf nur eines von `rep`, `repe`, `repne`, `lock` haben. Das zweite in eine eigene Zeile zu
schreiben geht auch nicht, weil ein Präfix zum Befehl dahinter gehört.

Verwandt: `rep`

## err-address – falscher Speicheroperand

**Meldungen:** `colon expected`, `closing square bracket expected`, `no basereg and no displacement`,
`Scale must be 1,2,4 or 8`, `either bx or bp required in two reg-Argument`,
`8-bit register not allowed in address`, `mult only allowed with number or register`

Der Teil in `[ ... ]` ist keine gültige Adresse. Erlaubt ist:

- 32 Bit: `[Basis + Index*Faktor + Verschiebung]`, jeder Teil optional; der Faktor ist 1, 2, 4 oder 8
- 16 Bit: nur `bx`, `bp`, `si`, `di` als `[bx+si]`, `[bp+di]`, höchstens eine Basis und ein Index
- Register in einer Adresse haben die Größe der Adresse (kein `al`, `ah` ...)
- ein Segmentpräfix steht vor der Klammer: `es:[di]` oder `[es:di]`

```asm
mov eax, [ebx + esi*4 + 8]   ; richtig
mov eax, [ebx + esi*3]       ; Faktor muss 1, 2, 4 oder 8 sein
mov ax,  [bx + cx]           ; 16 Bit: bx oder bp mit si oder di
```

Verwandt: `mov`, `lea`

## err-syntax – unerwarteter Text

**Meldungen:** `unexpected token`, `unexpected "..."`, `label or number expected`, `number expected after "+"`

Der Assembler hat den Befehl bis zu einer Stelle verstanden und dahinter etwas Unerwartetes gefunden.

- ein zweites Komma oder ein fehlendes Komma zwischen den Operanden
- Text nach dem letzten Operanden, der kein Kommentar ist (Kommentare beginnen mit `;`)
- ein Operand, der weder Register noch Zahl noch Label ist
- Operatoren an der falschen Stelle (`+` oder `-` ohne Zahl dahinter)

```asm
mov eax ebx      ; Komma fehlt
mov eax, 5 6     ; unexpected "6"
```

## err-org – org geht rückwärts

**Meldung:** `org 0x100: the output is already at 0x120 (org would overwrite 32 bytes)`

`org` setzt die Adresse des nächsten Bytes. Es darf nur vorwärts gehen (die Lücke wird mit Nullbytes
gefüllt). Die Ausgabe ist schon hinter dieser Adresse.

- `org` an den Anfang des Programms oder vor den Code, der die Adresse braucht
- Bootsektoren: `org 0x7C00` ganz oben

Verwandt: `org`

## err-codeend – codeend braucht den Header

**Meldung:** `codeend needs the PE header (at least 0x200 bytes) before it`

`codeend` schließt den Code einer von Hand geschriebenen PE-Datei ab; es ergibt nur Sinn, wenn davor der
PE-Header geschrieben wurde. Für Programme ist `.format pe` einfacher, das schreibt den Header selbst.

Verwandt: `err-format`

## err-imagebase – Zahl erwartet

**Meldung:** `number expected after .imagebase`

`.imagebase` braucht die Ladeadresse als Zahl: `.imagebase 0x00400000`. Der Wert muss ein Vielfaches von
64 KB sein.

## err-arch – unbekanntes .arch

**Meldung:** `unknown .arch: "arm7"`

`.arch` kennt die Prozessormodi, die der Assembler schreiben kann: `i386` (32-Bit-x86), `x86_real`
(16 Bit, DOS) und `thumb` (ARM Thumb-2). Es gilt ab dieser Zeile bis zum nächsten `.arch`.

```asm
.arch thumb
```

## err-format – .format

**Meldungen:** `second .format`, `.format must come before the first instruction or data`,
`unknown .format: "elf"`, `unknown option of .format pe`, `.format pe needs .arch i386`,
`.format pe: no code`

`.format` wählt die Art der Datei, die der Assembler schreibt.

- einmal pro Programm, vor dem ersten Befehl oder den ersten Daten
- `.format pe` schreibt ein Windows-Programm (als Option folgt `console` oder `gui`); es braucht
  `.arch i386` und einen `.code`-Abschnitt
- `.format binary` schreibt die Bytes unverändert (Bootsektor, DOS-`.COM`)

```asm
.format pe console
.arch i386
.import kernel32.dll ExitProcess
.code
```

Verwandt: `err-format-ops`, `err-import`

## err-format-ops – bei .format pe nicht erlaubt

**Meldungen:** `"org"`, `"section"`, `"segment"` oder `"codeend"` ... `is not allowed with .format pe (the sections are placed by the assembler)`

Mit `.format pe` legt der Assembler Header und Abschnitte selbst an. `org`, `section`, `segment` und
`codeend` setzen Adressen oder Größen von Hand und würden dagegen arbeiten. Entferne sie, oder schreibe das
Programm ohne `.format pe`, wenn du die Header selbst bauen willst.

Verwandt: `err-format`

## err-import – .import

**Meldungen:** `.import needs a dll and function names`, `.import kernel32.dll: no function names`,
`.import: "xyz" is not a valid name`, `.import: ExitProcess is imported twice`,
`label ExitProcess is also an imported function`

`.import` listet die Funktionen einer DLL auf, die das Programm aufruft: erst die DLL, dann die Namen.

```asm
.import kernel32.dll ExitProcess WriteFile GetStdHandle
.import msvcrt.dll printf
```

- jede Funktion einmal; der Name darf nicht auch als Label verwendet werden
- der Aufruf ist dann `call [ExitProcess]`

Verwandt: `err-undefined-label`, `pe-function-missing`

## err-entry – .entry

**Meldung:** `.entry needs a label`

`.entry start` nennt das Label, an dem das Programm beginnt. Ohne `.entry` beginnt es beim ersten Befehl
des `.code`-Abschnitts.

## err-output – .output

**Meldung:** `.output needs a file name`, `second .output ...`, `.output must come before the first instruction or data`, `.output: the name must not have a folder ...`

`.output name` gibt der Ausgabedatei ihren Namen (zum Beispiel `.output hello.com`). Es darf einmal stehen,
vor dem ersten Befehl oder den ersten Daten, mit einem reinen Dateinamen: Die Datei wird neben der Quelle
geschrieben, also ohne Ordner und Laufwerk.

## err-internal – interner Fehler

**Meldung:** `internal error: ...`

Der Assembler ist an etwas Unerwartetem gescheitert. Das ist ein Fehler von Asmonite, nicht deines
Programms. Sieh dir die genannte Zeile an: vielleicht eine seltene Kombination von Operanden. Ein kurzes
Beispiel, das ihn zeigt, ist im Issue-Tracker willkommen.

## err-file – Datei kann nicht gelesen oder geschrieben werden

**Meldungen:** `cannot read file: ...`, `cannot write file: ...`

- Lesen: die Datei fehlt oder ist von einem anderen Programm gesperrt
- Schreiben: das Zielprogramm läuft noch (eine laufende `.exe` kann nicht überschrieben werden; beende sie
  oder die Debug-Sitzung), der Ordner ist schreibgeschützt oder liegt auf einem Laufwerk, das nicht da ist

## pe-file – Datei nicht gefunden

**Meldung:** `file not found: ...`

Die Prüfung des fertigen Programms hat die Datei nicht gefunden. Sieh dir den Pfad in der Zeile davor an.

## pe-not-exe – keine ausführbare Datei

**Meldung:** `no MZ signature: not an executable file`

Die Datei beginnt nicht mit `MZ`. Sie ist kein Programm für Windows oder DOS (eine `.COM`-Datei oder ein
Bootsektor sieht so aus und ist für DOS in Ordnung). Für ein Windows-Programm nimm `.format pe`.

## pe-dos-program – DOS-Programm

**Meldung:** `no PE signature at offset $...: a DOS program, ...`

Die Datei ist ein `MZ`-Programm ohne PE-Header: ein DOS-Programm. Das stimmt, wenn du ein DOS-Programm
geschrieben hast (F9 startet es in QEMU mit FreeDOS). Wolltest du ein Windows-Programm, ergänze
`.format pe`.

## pe-machine – falsche Maschine

**Meldungen:** `machine $... is not i386 ($14C)`, `64-bit (x64) image: only 32-bit programs are supported`

Windows lädt das Programm nur, wenn der Maschinentyp im Header passt. Asmonite schreibt 32-Bit-x86-Programme
(`.arch i386`). 64-Bit-Programme werden noch nicht unterstützt.

## pe-header – Felder des Headers

**Meldungen:** `image base ... is not a multiple of 64 KB`, `section alignment ... is not a power of two`,
`file alignment ...`, `optional header ...`, `characteristics ...`, `size of image ...`,
`number of sections is ...`, `subsystem ...`

Ein Wert im PE-Header liegt außerhalb dessen, was der Windows-Lader akzeptiert. Das passiert bei von Hand
geschriebenen Headern (`dd`-, `dw`-Zeilen). Vergleiche das Feld mit der Beschreibung des PE-Formats; mit
`.format pe` füllt der Assembler alle richtig.

Übliche Werte: Image Base `0x00400000`, Section Alignment `0x1000`, File Alignment `0x200`, Subsystem 2
(GUI) oder 3 (Konsole).

## pe-sections – Abschnittstabelle

**Meldungen:** `section .text: virtual address ... is not aligned`, `... overlaps the headers or the previous
section`, `... raw data ... beyond the end of the file`, `section table runs past the end of the file`

Ein Abschnitt ist falsch angelegt: die virtuelle Adresse muss ein Vielfaches des Section Alignment sein,
hinter dem vorigen Abschnitt liegen, und die Daten, die er in der Datei nennt, müssen existieren.
Vergleiche die Größen in der Abschnittstabelle mit der wirklichen Größe der Datei.

## pe-entry – Einsprungpunkt

**Meldungen:** `entry point $... is not inside a section`, `no entry point`,
`entry point ... is in section ..., which is not marked executable`

Die Adresse, an der das Programm startet, muss in einem Abschnitt liegen, der Code enthält und als
ausführbar markiert ist. Bei `.format pe` ist der Einsprung das Label aus `.entry` oder der Anfang von
`.code`.

## pe-imports – Importtabelle

**Meldungen:** `import directory ...`, `import 1: DLL name at RVA ... is not inside the image`,
`... import table runs past the end of the file`, `function name at RVA ...`

Die Importtabelle (die Liste der DLLs und Funktionen, die das Programm braucht) ist beschädigt oder zeigt
außerhalb des Images. Mit `.format pe` und `.import` wird sie richtig geschrieben; prüfe bei von Hand
geschriebenen Tabellen die RVAs (relative Adressen ab der Image Base) und die Null-Abschlüsse der Listen.

## pe-dll-missing – DLL nicht gefunden

**Meldung:** `DLL xyz.dll not found`

Das Programm importiert eine DLL, die weder im Windows-Ordner noch im Programmordner noch im Suchpfad
liegt. Prüfe die Schreibweise in `.import`. Ist es eine eigene DLL, lege sie neben das Programm.

## pe-function-missing – Funktion in der DLL nicht gefunden

**Meldung:** `function GetFoo not found in kernel32.dll`

Die DLL gibt es, sie exportiert aber keine Funktion mit diesem Namen. Typische Ursachen:

- Tippfehler oder falsche Groß-/Kleinschreibung (exportierte Namen unterscheiden Groß und Klein)
- die ANSI-/Unicode-Endung fehlt: viele Windows-Funktionen heißen `MessageBoxA` und `MessageBoxW`, ein
  einfaches `MessageBox` gibt es nicht
- die Funktion liegt in einer anderen DLL (`msvcrt.dll`, `user32.dll`, ...)

Verwandt: `err-import`
