# Direktiven des Assemblers

Direktiven sind keine Befehle des Prozessors: Sie sagen dem Assembler, wie er arbeiten soll, oder legen
Daten in die Datei. F1 auf so einer Zeile zeigt den Abschnitt hier (und bei `db`, `dw`, `dd`, `rva`, `org`,
`align` die Abschnitte der Befehlsliste). Jeder Abschnitt beginnt mit `## ` und den Namen, die er erklärt.

## .arch – Prozessormodus

Wählt, für welchen Prozessor die folgenden Zeilen geschrieben sind. Es gilt von dieser Zeile bis zum
nächsten `.arch`.

**Syntax:** `.arch i386`, `.arch x86_real`, `.arch x64`, `.arch arm64`, `.arch thumb`

| Modus | Bedeutung |
| --- | --- |
| `i386` | 32-Bit-x86: Windows-Programme, 32-Bit-Code |
| `x86_real` | 16-Bit-x86: DOS-Programme, Bootsektoren (Real Mode) |
| `x64` | 64-Bit-x86 (AMD64): Windows-Programme, PE32+ (r8..r15, rip-relativ) |
| `arm64` | ARM64 (A64, AArch64): Windows on ARM64, PE32+ |
| `thumb` | ARM Thumb-2: Windows on ARM, Raspberry Pi |

```asm
.arch x86_real
mov ax, 0x4C00   ; 16 Bit: ax
int 0x21
```

Der Editor färbt die Zeilen nach `.arch thumb` als ARM, und F1 zeigt für sie die ARM-Hilfe.

Nach `.arch x64` ist jede Zeile, die keine Daten- oder Steuerdirektive ist, ein x64-Befehl (ein Label
braucht einen Doppelpunkt, oder es steht vor `db`, `dw`, `dd`, `dq`, `du`). Adressen sind 64 Bit: Ein
Label als Operand ist seine Adresse (`jmp schleife`, `lea rcx, [text]`); als Adresse eines
Speicheroperanden ohne Register ist es rip-relativ (`[rel text]` sagt dasselbe ausdrücklich). Ein
Sprung nach vorn ist die lange Form (`jmp short` wählt die kurze); die Größe eines Speicheroperanden
steht, wo kein Register sie bestimmt (`add dword [rax], 1`). Mit `.format pe` entsteht eine
PE32+-Datei (Image Base `0x140000000`):

```asm
.format pe console
.arch x64
.import msvcrt.dll printf, exit
.code
start:
    sub rsp, 40            ; Schattenraum, Stack auf 16 ausgerichtet
    lea rcx, [text]
    mov edx, 42
    call [printf]
    xor ecx, ecx
    call [exit]
.data
text db 'Antwort: %d', 10, 0
```

Nicht übersetzt wird AVX (VEX/EVEX).

Für Kodierungen, die der Befehlstext nicht sagt, schreibt der Export von Dismonite Präfixwörter:
`enc.load` (von zwei Kodierungen einer Registerkopie die mit dem Register im `reg`-Feld: `mov rcx,
rbx` als 48 8B CB statt 48 89 D9), `rex` und `rex.w` (ein REX-Präfix, das nichts ändert: `rex.w call
[rax]` = 48 FF 10), `enc.alt` (von gleich langen Kodierungen nicht die erste). Nach `short` oder
`near` ist eine Zahl mit Vorzeichen eine Verschiebung vom Ende des Befehls (`jz short +18`), und
`[0+rax+rax]` behält sein Verschiebungsbyte 0.

Nach `.arch arm64` ist jede Zeile, die keine Daten- oder Steuerdirektive ist, ein A64-Befehl (Syntax
wie die Ausgabe des Disassemblers, `#` darf fehlen). Sprünge, `adr` und `ldr` (literal) nehmen ein
Label; für Adressen in `.data` ein Paar `adrp` und `add` mit `:lo12:`. Windows on ARM64 lädt nur Images,
die an jede Adresse passen: Der Code muss positionsunabhängig sein (`adr`/`adrp`, keine absoluten
Adressen im Code). `.format pe` schreibt Machine `0xAA64`:

```asm
.format pe console
.arch arm64
.import msvcrt.dll printf, exit
.code
start:
    stp x29, x30, [sp, #-16]!
    adrp x0, text
    add x0, x0, :lo12:text
    mov x1, #42
    adrp x16, printf
    ldr x16, [x16, :lo12:printf]   ; die Adresse in der Importtabelle
    blr x16
    mov x0, #0
    adrp x16, exit
    ldr x16, [x16, :lo12:exit]
    blr x16
.data
text db 'Antwort: %d', 10, 0
```

Ohne `.arch` und ohne `.format` nimmt Asmonite ein 32-Bit-Windows-Programm an: `.arch i386` und
`.format pe console`.

Verwandt: `.format`, `err-arch`

## .format – Art der Ausgabedatei

Wählt, was der Assembler schreibt. Es steht einmal, vor dem ersten Befehl oder den ersten Daten.

**Syntax:** `.format pe`, `.format pe console`, `.format pe gui`, `.format binary`

- `pe` schreibt ein Windows-Programm: DOS-Stub, PE-Header, Abschnitte und Importtabelle macht der
  Assembler. Dein Quelltext hat dann nur Code (`.code`), Daten (`.data`) und Importe (`.import`).
  `console` (Standard) oder `gui` ist die Art des Fensters. Es braucht `.arch i386`, `x64`, `thumb`
  oder `arm64`: so entstehen Windows-Programme für alle vier Arten (Intel und ARM, 32 und 64 Bit).
  Für `thumb` und `arm64` darf der Code keine absoluten Adressen benutzen (Windows on ARM setzt das
  Image an eine beliebige Stelle): Labels werden pc-relativ geladen, `adr r0, text` und
  `ldr r3, printf` in Thumb, `adrp`/`add` und `adrp`/`ldr` in A64. Bei `thumb` liegen Code, Daten und
  Importe in einem Abschnitt, weil `adr` und `ldr` nur etwa 4 KB weit reichen.
- `binary` schreibt die Bytes so, wie sie stehen: für Bootsektoren, DOS-`.COM`-Programme oder eine
  PE-Datei, deren Header du selbst mit `db`, `dw`, `dd` schreibst.

```asm
.format pe console
.import kernel32.dll ExitProcess
.code
start:
    push 0
    call [ExitProcess]
```

Bei `.format pe` sind `org`, `section`, `segment` und `codeend` nicht erlaubt: Die Abschnitte legt der
Assembler selbst an.

Verwandt: `.import`, `.code`, `.entry`, `.arch`

## .output – Name der Ausgabedatei

Nennt die Datei, die der Assembler schreibt. Ohne `.output` entsteht der Name aus der Quelle: ihr Name mit
der Endung `.exe` (bei `.format binary`: ohne Endung, oder `.exe`, wenn die Ausgabe mit `MZ` beginnt).
`.output` sagt es direkt, zum Beispiel für ein DOS-`.COM`-Programm, dessen Name auf `.com` enden soll.

Sie steht einmal, vor dem ersten Befehl oder den ersten Daten. Die Datei wird im Ordner der Quelle
geschrieben; der Name hat keinen Ordneranteil. Asmonite startet und debuggt die hier genannte Datei.

**Syntax:** `.output name`

```asm
.format binary
.output hello.com
.arch x86_real
```

Verwandt: `.format`

## .include – eine Datei einfügen

Setzt den Text einer anderen Datei an diese Stelle, als stünde er hier. So lassen sich Konstanten (`equ`),
Funktionen und Daten auf mehrere Dateien verteilen.

- Der Name steht in Anführungszeichen und gilt vom Ordner der Datei aus, in der das `.include` steht (`/` und
  `\` gehen beide). Ein Name mit Laufwerk oder ab der Wurzel gilt so, wie er ist.
- Jede Datei wird einmal gelesen: Ein zweites `.include` derselben Datei, auch aus einer anderen eingebundenen
  Datei, lässt der Assembler weg.
- Eine eingebundene Datei darf selbst `.include` benutzen.
- Fehlermeldungen nennen die Datei und ihre Zeile: `inc\uart.asm(12): ...`.
- Im Debugger: Hält das Programm in einer eingebundenen Datei, zeigt Asmonite diese Datei an Stelle der
  Quelle, schreibgeschützt. Breakpoints und Einzelschritte gehen dort wie in der Quelle.

**Syntax:** `.include "name"`

```asm
.include "uart.asm"
.include "../common/board.inc"
```

Verwandt: `equ`

## .target – das Gerät

Sagt, für welches Gerät das Programm ist. Die Ausgabe ist dann eine reine Binärdatei (wie `.format binary`,
das deshalb wegfallen kann), und nach dem Assemblieren prüft Asmonite das Programm für dieses Gerät: Was nicht
passt, ist ein Fehler mit der Zeile, bevor etwas auf das Gerät geschrieben wird. Beim Debuggen prüft
Asmonite außerdem, ob das angeschlossene Gerät das richtige ist (die Chip-ID), bevor es etwas schreibt.

**Syntax:** `.target pico2` (der Raspberry Pi Pico 2; `rp2350` geht auch) oder `.target pico` (der Raspberry Pi
Pico; `rp2040` geht auch)

Was `.target pico2` prüft:
- `.arch riscv32` (die RISC-V-Kerne) oder `.arch thumb` (die Arm-Kerne)
- `.imagebase` im RAM (`0x20000000`, 520 KB) oder im Flash (`0x10000000`, 4 MB), und das Programm passt hinein
- ein Programm für den Flash hat in seinen ersten 4 KB einen IMAGE_DEF-Block, dessen IMAGE_TYPE zu `.arch`
  passt: `0x1101` für RISC-V, `0x1021` für Arm (sonst startet das Boot-ROM es nicht oder startet die anderen Kerne)
- ein Arm-Programm für den Flash beginnt mit seiner Vektortabelle: Stackzeiger im RAM, dann die Startadresse
  mit gesetztem Bit 0 (`dd _start + 1`)

Was `.target pico` prüft:
- `.arch thumb`, und nur die Befehle des Cortex-M0+ (ARMv6-M): von den 32-Bit-Befehlen nur `bl`, `msr`, `mrs`,
  `dmb`, `dsb`, `isb`; kein `movw`/`movt`, keine `.w`-Formen, kein `cbz`, `cbnz`, `it`
- `.imagebase` im RAM (`0x20000000`, 264 KB) oder im Flash (`0x10000000`, 2 MB), und das Programm passt hinein
- ein Programm für den Flash beginnt mit dem boot2-Block (256 Bytes: 252 Bytes Code, dann ihre CRC-32), dahinter
  bei `0x10000100` die Vektortabelle

```asm
.target pico2
.arch riscv32
.imagebase 0x20000000
```

Ohne `.target` gilt `.arch thumb` mit `.format binary` als Programm für die Arm-Kerne des Pico 2; das gibt
eine Warnung.

Verwandt: `.arch`, `.imagebase`, `err-target`

## .boot2 – der boot2-Block des Pico

Bei `.target pico`: Setzt an dieser Stelle die 256 Bytes ein, mit denen der RP2040 ein Programm aus dem Flash
startet. Das ist ein kleines Programm, das den Flash-Chip einrichtet, mit seiner CRC-32 am Ende. Es steht
am Anfang eines Flash-Programms; danach folgt bei `0x10000100` die Vektortabelle.

**Syntax:** `.boot2` (der Block des Pico-SDK für den Flash des Pico: die Datei `boot2\boot2_w25q080.bin`
neben Asmonite, und fehlt sie, dieselben Bytes, die Asmonite eingebaut hat) oder `.boot2 datei.bin` (eine
eigene Datei neben der Quelle, für ein Board mit anderem Flash-Chip: 252 Bytes, dann hängt Asmonite die
CRC-32 an, oder 256 Bytes, dann prüft es sie)

```asm
.target pico
.arch thumb
.imagebase 0x10000000
    .boot2
    dd 0x20042000       ; Vektortabelle bei 0x10000100: Stackzeiger
    dd _start + 1       ; und Startadresse
```

Verwandt: `.target`, `err-target`

## .code, .data – Abschnitte eines PE-Programms

Bei `.format pe` sagen sie, wohin die folgenden Zeilen kommen: `.code` ist das Programm, `.data` die
Daten, die das Programm liest und schreibt. Ohne eines von beiden ist alles Code.

```asm
.format pe console
.import kernel32.dll ExitProcess WriteFile GetStdHandle

.data
text:   db 'Hallo', 13, 10
done:   dd 0

.code
start:
    ; ...
```

Du kannst beliebig oft wechseln; die Zeilen jedes Abschnitts werden zusammengefasst.

Verwandt: `.format`, `.import`, `.entry`

## .import – importierte Funktionen

Bei `.format pe`: Listet die Funktionen einer DLL auf, die das Programm aufruft. Der Assembler schreibt
die Importtabelle; jeder Name ist ein Label seines Eintrags, der Aufruf ist also `call [name]`.

**Syntax:** `.import dll funktion, funktion ...` (Namen durch Leerzeichen oder Kommas getrennt)

```asm
.import kernel32.dll ExitProcess WriteFile
.import msvcrt.dll printf

    push 0
    call [ExitProcess]
```

Die Namen unterscheiden Groß- und Kleinschreibung (`MessageBoxA`, nicht `messageboxa`) und dürfen nicht
zugleich Label sein. Mit **F1** auf so einem Aufruf siehst du, was die Funktion will.

Verwandt: `.format`, `err-import`

## .entry – Einsprungpunkt

Bei `.format pe`: Nennt das Label, an dem das Programm beginnt. Ohne `.entry` beginnt es beim ersten
Befehl von `.code`.

**Syntax:** `.entry label`

```asm
.entry main
```

Verwandt: `.format`, `.code`

## .imagebase – Ladeadresse

Die Adresse, an die Windows das Programm in den Speicher legt (PE: die „Image Base“). Sie ist `0x400000`,
wenn nichts anderes steht. Labels, die als Adressen benutzt werden (`push text`, `mov eax, text`), bekommen
diese Basis addiert; `rva` zieht sie ab.

**Syntax:** `.imagebase zahl` (ein Vielfaches von 64 KB; nach `.arch x64` bis 64 Bit, Standard
`0x140000000`)

```asm
.imagebase 0x10000000   ; üblich für DLLs
```

Verwandt: `rva`, `org`

## du – Text als UTF-16

Wie `db`, aber jedes Zeichen ist ein 16-Bit-Wert (2 Bytes, niederwertiges Byte zuerst): das Format der
Texte von Windows (`...W`-Funktionen, Wide Strings).

**Syntax:** `du wert, ...`

```asm
du 'Hi', 0     ; 48 00 69 00 00 00
```

Zahlen müssen in 16 Bit passen.

Verwandt: `db`, `dw`

## equ – eine Konstante

`name equ ausdruck` gibt einer Zahl einen Namen. Die Zeile selbst erzeugt keine Bytes; jede Verwendung des Namens
(davor oder dahinter) wird durch den Wert ersetzt.

**Syntax:** `name equ ausdruck`

```asm
size    equ 4*16          ; 64
        mov eax, size+1   ; mov eax, 65
msg:    db 'hello', 0
len     equ $-msg         ; 6: die Länge des Textes
```

- Der Ausdruck wird dort ausgewertet, wo der Name benutzt wird. Eine Konstante darf daher hinter ihrer Verwendung
  stehen und andere Konstanten benutzen (eine Konstante, die auf sich selbst verweist, ist ein Fehler).
- `$` im Ausdruck ist die Adresse der `equ`-Zeile; `len equ $-msg` direkt hinter den Daten ist also deren Länge.
- Nicht für Text: `name equ 'abc'` geht nicht (ein Zeichen in Anführungszeichen zählt nur als Zahl).

### Ausdrücke – Rechnen im Quelltext

Überall, wo eine Zahl steht (Operanden, `db`, `dw`, `dd`, `dq`, `resb`, `align`, `org`), rechnet der Assembler.

| Operator | Bedeutung |
| --- | --- |
| `( )` | Klammern |
| `-`, `+`, `~` (vor einem Wert) | Vorzeichen, bitweises Nicht |
| `*`, `/`, `%` | Mal, geteilt, Rest |
| `+`, `-` | plus, minus |
| `<<`, `>>` | Verschieben nach links, rechts |
| `&`, `^`, `\|` | bitweise und, xor, oder (in dieser Rangfolge, das schwächste zuletzt) |

Zahlen: dezimal, `0x1F`, `1Fh`, `101b`, ein Zeichen `'A'`. Ein Label ist seine Adresse; `label+4` und `label-4` sind
Adressen, und die **Differenz zweier Labels** ist eine Zahl (die Größe eines Code- oder Datenstücks):

```asm
start:  mov ecx, end-start        ; die Größe des Blocks
        ...
end:
        mov eax, [ebx+2*4]        ; mov eax, [ebx+8]: der konstante Teil wird gerechnet
        db 1+2, 3<<2, 'A'+1       ; 3, 12, 66
```

- Eine Differenz von Labels braucht die Adressen; der Assembler läuft deshalb mehrmals, bis sie gleich bleiben.
  Vor dem ersten Lauf gilt der Wert 1, ein Befehl mit kurzer und langer Form kann deshalb einmal seine Länge ändern.
- Nicht möglich: eine Zahl hinter einem Label bei Sprung oder Aufruf (`jmp start+4`), Division durch null
  (ein Fehler mit Zeilennummer) und mit der Adresse eines Labels anderes zu rechnen als eine Zahl zu addieren oder
  zu subtrahieren oder ein anderes Label abzuziehen.
- Register und Namen, die keine Labels sind, bleiben stehen: `[ebx*2+8-3]` wird `[ebx*2+5]`.

## $, $$ – die aktuelle Adresse

`$` ist die Adresse der Zeile, in der es steht; `$$` ist die Adresse vom Anfang des Abschnitts (die erste Zeile
hinter `org`, `section`, `segment`, `.code`, `.data` oder der Anfang der Datei).

```asm
msg:    db 'hello'
        dd $-msg          ; 5: die Bytes seit msg
        dd $-$$           ; die Bytes seit dem Anfang des Abschnitts
```

`$` und `$$` sind Labels mit einem versteckten Namen: `dd $` schreibt die Adresse der Zeile wie `dd label`.

## rel32 – relative 32-Bit-Adresse

Schreibt den Abstand vom Ende dieser 4 Bytes bis zu einem Label als 32-Bit-Zahl: den Operanden eines
nahen `call` oder `jmp`, wenn du die Bytes selbst zusammensetzt.

**Syntax:** `rel32 label`

```asm
db 0xE8           ; call
rel32 funktion    ; der Abstand zu funktion
```

Normalerweise schreibst du `call funktion`, und der Assembler erledigt den Rest.

Verwandt: `rva`, `call`, `jmp`

## codeend – Code abschließen (von Hand geschriebenes PE)

Für einen PE-Header, den du selbst geschrieben hast: Schreibt die Länge des Codes (von der Dateiposition
`0x200` bis hierher) in den Header, in die Größe des ersten Abschnitts (Offset `0x180`). Davor müssen
mindestens 0x200 Bytes stehen.

Bei `.format pe` brauchst du es nicht: Der Assembler füllt den Header.

Verwandt: `.format`, `err-codeend`

## section – ein Abschnitt der Datei (von Hand geschriebenes PE)

Merkt, dass die Bytes ab hier zu einem Abschnitt gehören, der im Speicher an der angegebenen virtuellen
Adresse (RVA) liegt. Labels darin bekommen dann die richtige Adresse im Speicher, nicht nur die Position
in der Datei.

**Syntax:** `section rva`

```asm
section 0x1000    ; .text bei 0x1000
; ... Code ...
section 0x2000    ; .idata bei 0x2000
```

Bei `.format pe` nicht erlaubt (nimm `.code`/`.data`). Es ist nicht das `section .text` von NASM.

Verwandt: `org`, `segment`, `.format`

## segment – ein Segment eines DOS-Programms

Für DOS-Programme mit mehreren Segmenten (MZ-Dateien): Die Bytes ab hier liegen im Segment mit dieser
Nummer. Labels darin bekommen das Segment und den Offset, die ferne Aufrufe und Sprünge brauchen.
`segment 0` markiert außerdem den Anfang des DOS-Headers.

**Syntax:** `segment nummer`

Verwandt: `section`, `org`, `.arch`
