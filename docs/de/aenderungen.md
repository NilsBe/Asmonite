# Änderungen

Was sich von Version zu Version geändert hat. Englisch: [CHANGELOG.md](../../CHANGELOG.md).

Versionsnummern: MAJOR.MINOR.PATCH. Solange MAJOR 0 ist, darf ein MINOR-Schritt ändern, was
vorhandene Quelltexte bedeuten; solche Änderungen stehen unter „Geändert“ und sind mit
**(Quelltexte)** markiert.

## 0.8.0 – 2026-11-04

### Neu
- **Raspberry Pi Pico und Pico 2: assemblieren, flashen und debuggen, ohne OpenOCD.** Asmonite steuert eine CMSIS-DAP-Debug-Probe (die Raspberry Pi Debug Probe) selbst über USB an (`CmsisDap`): F7 lädt ein Programm ins RAM (`.imagebase 0x20000000`) oder **schreibt es in den Flash** (`.imagebase 0x10000000`: über die Funktionen des Boot-ROM, nur die Sektoren, die sich unterscheiden, zurückgelesen) und hält bei `_start`; Schritte, Step over, Run to cursor, Pause, Breakpoints, Register (änderbar), Stack mit Notizen, Speicher als **Bytes oder als Code** (der neue Umschalter *Bytes / Code*). *Project > Save as UF2 file (Raspberry Pi Pico)* schreibt die Datei für das BOOTSEL-Laufwerk mit der Familie des Chips. *Debug > Debug targets* hat die Einträge *Raspberry Pi Pico (RP2040)* und *Raspberry Pi Pico 2 (RP2350)*, jeder mit *Test the connection*. Die Anleitung `docs/de/riscv-pico2.md` erklärt es Schritt für Schritt.
- **Der Raspberry Pi Pico (RP2040, Cortex-M0+).** `.target pico` (auch `rp2040`) erlaubt nur die Befehle des ARMv6-M (von den 32-Bit-Befehlen `bl`, `msr`, `mrs`, die Barrieren; kein `cbz`, `cbnz`, `it`); adr/ldr mit einer Marke weiter unten nehmen zuerst die 16-Bit-Form. Der Debugger erreicht Kern 0 auf dem Multidrop-SWD-Bus (TARGETSEL) über den MEM-AP von ADIv5: 4 Hardware-Breakpoints im Flash, Software-Breakpoints (`bkpt`) im RAM, die die Speicheransicht nicht zeigt. Kerne, die nicht mehr antworten, holt der Rescue-Port des Chips zurück.
  - **`.boot2`** setzt den boot2-Block des Pico-SDK an den Anfang eines Flash-Programms (die Datei `boot2/boot2_w25q080.bin`, BSD-3-Clause, oder dieselben Bytes eingebaut); `.boot2 datei.bin` einen eigenen (252 Bytes, dann wird die CRC-32 angehängt, oder 256, dann wird sie geprüft).
- **Die RISC-V-Kerne des Pico 2 (Hazard3).** `.arch riscv32`: RV32I, M, A, Zicsr, Zifencei, die Pseudobefehle `li`, `la`, `mv`, `j`, `ret`, `call` ... und die Bit-Manipulations-Sätze Zba, Zbb, Zbs, Zbc, Zbkb. Der Debugger arbeitet über das Debug-Modul des Chips (`RvDebugModule`, `RvLink`): Register `x0`..`x31` und `pc`, 4 Hardware-Breakpoints. OpenOCD (Host und Port seines GDB-Servers) bleibt für diese Kerne als Ersatzweg; die Verbindung weckt den Debug-Port auf, den OpenOCD im Ruhezustand zurücklässt.
  - Der Disassembler `dis_riscv` liest auch die komprimierten Befehle (C, Zcb); gegen capstone geprüft (alle 16-Bit-Codes und 200.000 Zufallswörter: kein Unterschied, `tools/riscv_check.py`).
  - Editor: Syntaxfarben für `.arch riscv32`; F1-Hilfe `help\<Sprache>\riscv.md` (jeder Befehl, die Register, die Pseudobefehle, die Befehlsformen).
- **Die Arm-Kerne des Pico 2 (Cortex-M33).** `.arch thumb` mit `.target pico2`; F7/F9 debuggen über die USB-Probe (`CmCore`, `CmLink`, `CmFlash`): Register `R0`..`R12`, `SP`, `LR`, `PC`, `XPSR` und die Flags `N Z C V` (änderbar), 8 Hardware-Breakpoints, Step over bei `bl` und `blx`, die Speicheransicht zeigt Thumb-Code; der Stackzeiger kommt aus der Vektortabelle.
  - Der Chip läuft immer nur mit einer Sorte von Kernen. Läuft die andere Sorte, schreibt sie ein Flash-Programm in den Flash, und der Chip wird zurückgesetzt (das Boot-ROM startet die Kerne, für die das Programm ist); ein RAM-Programm bekommt eine Meldung, was zu tun ist. *Test the connection* sagt, welche Kerne laufen.
- **`.target pico`** (auch `rp2040`) und **`.target pico2`** (auch `rp2350`) sagen, für welches Board ein Programm ist: Die Ausgabe ist eine reine Binärdatei, und nach dem Assemblieren wird das Programm geprüft (Fehler mit der Zeile, F1 `err-target`): die `.arch`, `.imagebase` im RAM oder im Flash, und das Programm passt hinein; beim Pico 2 ein IMAGE_DEF-Block in den ersten 4 KB, dessen IMAGE_TYPE zu `.arch` passt, beim Pico der boot2-Block mit seiner CRC-32; ein Arm-Programm im Flash beginnt mit seiner Vektortabelle (Thumb-Bit). Ohne `.target` gibt `.arch thumb` mit `.format binary` eine Warnung. Bevor der Debugger etwas schreibt, liest er die Chip-ID und lehnt ein Programm für das andere Board mit dessen Namen ab.
- Beispiele: `examples/pico/` (`blink_ram.asm`, `blink_flash.asm`) und `examples/pico2/` (`blink_arm_ram.asm`, `blink_arm_flash.asm` für Arm; `blink_ram.asm`, `blink_flash.asm` für RISC-V; `stack_demo.asm`). Die Flash-Programme starten nach dem Aus- und Einschalten von selbst.
- Tests: `rvtest` (Assembler, Disassembler, UF2, Highlighter), `regedittest` (Cortex-M-Register), Fälle `riscv_*` und `target_*`, `anatest` (Hilfe); mit einem Board: `rvdbgtest` (31 Prüfungen, `usb` für den direkten Weg), `rvdmtest`, `rvflashtest`, `cmdbgtest` (37 Prüfungen am Pico 2, beide Umschaltungen der Kerne; `cmdbgtest pico` 38 Prüfungen am Pico).
- Die Debug-Ansichten (Register, Stack, Speicher) ändern ihre Zeilen an Ort und Stelle und flackern weniger.
- Dismonite: **PE-Dateien für das alte ARM** (Machine 0x01C0: der ARM-Befehlssatz aus der Zeit vor Thumb-2, wie ihn Windows CE benutzte) lassen sich öffnen und werden zerlegt: der Code ab dem Einsprung ist ARM (A32, der Zerleger der ARM-ELF-Dateien), der Export schreibt den Code als Bytes mit dem Befehl als Kommentar (als Befehle lässt er sich nicht übersetzen: Asmonite hat keinen A32-Assembler). Vorher zeigte so eine Datei gar keinen Code. Die Statuszeile sagt „old ARM (Windows CE): ... no Windows PC runs it“, und die Prüfung vor dem Start nennt das alte ARM ($1C0 / $1C2) als einen Typ, den kein Windows-PC ausführt. Die Seite `winarm.html` hat eine Tabelle der ARM-Dateitypen (ARM64, ARM32 mit Thumb-2, das alte ARM, ARM64EC/X) und sagt, was Asmonite und Dismonite damit tun. Fall in `anatest` (`pe_oldarm_example.exe`, mit fasmarm gemacht). Werkzeuge: `tools/pe_scan.c` (natives Programm, das die PE-Dateien eines Laufwerks erfasst) und `tools/pe_stats.py` (Statistik der Maschinentypen).

## 0.7.6 – 2026-10-30

### Neu
- Beispiele: `examples/windows_intel/if_x64.asm`, `examples/windows_arm/if_arm64.asm` und `if_arm32.asm` benutzen `if` / `else` mit mehreren Arten von Bedingungen; jedes endet mit dem Exit-Code 31 (die ARM-Beispiele sind auf einem echten Windows-on-ARM-Rechner gelaufen).
- Assembler, Thumb (`.arch thumb`): **`if` / `else` / `endif` und `do` ... `while`** gehen wie bei arm64 (`bne`, `blt` ..., `tst`, eine Zahl bekommt ihr `#`, keine Speicheroperanden). Fälle `thumb_*`, auch mit Blöcken aus 130 Befehlen.
- Assembler, arm64: **`if` / `else` / `endif` und `do` ... `while`** gehen in `.arch arm64`-Quelltext mit denselben Wörtern und Regeln (`if w0 == 5`, `if signed x1 < x2`, `if zero`, `if x3 & x4`, `do ... while not zero`, verschachtelt): die Sprünge sind `b.cond`, `if a & b` ist `tst`, eine Zahl bekommt ihr `#`; es gibt keine Speicheroperanden und kein `parity`; Thumb / ARM 32 bleibt ein Fehler. Fälle `a64_*`; der Editor färbt die Wörter in arm64-Quelltext. Noch nicht auf einem Gerät gelaufen.
- Assembler, x64: **`if` / `else` / `endif` und `do` ... `while`** gehen jetzt in `.arch x64`-Quelltext mit denselben Wörtern und Regeln wie bei i386 (`if rax == rbx`, `if signed eax < r8d`, `if zero`, `if eax & ebx`, `do ... while not zero`, verschachtelt); `func` und `call Name(args)` bleiben nur für i386, in ARM-Quelltext meldet `if` weiterhin einen Fehler. Die Sprünge vorwärts haben die lange Form (rel32). Fälle `x64_if_*`, `x64_do_while_*`, `x64_compare_default`, `x64_error_*`.

### Behoben
- Assembler, Thumb: ein **Sprung vorwärts, der in der kurzen Form nicht reicht, wird von selbst die lange Form** (ein weiterer Durchgang läuft); vorher musste der Befehl mit `.w` geschrieben werden („the branch does not reach its target in this form“).
- Assembler, x64 und Thumb: die Größen der Zeilen (aus Durchgang 1 für Durchgang 2 gemerkt) wurden mit der Quelltextzeile indiziert; bei erzeugten Zeilen (`if`, `else`, `do`, `func`) teilen sich mehrere Zeilen eine Quelltextzeile, und die Größen kamen durcheinander (Fehler „the instruction does not have the size it had in pass 1“). Jetzt zählt die erzeugte Zeile.

## 0.7.5 – 2026-10-28

### Neu
- Dismonite: **Export mit `call Name(Argumente)`** (Menü Datei, *Export with call Name(args)*, gespeichert in `Dismonite.ini`; `DismoniteC --calls`). In einem 32-Bit-Windows-Programm werden die `push`-Befehle direkt vor einem Aufruf als dessen Argumente geschrieben: `push 3` / `push eax` / `call near Fatal` / `add esp,8` wird zu `call cdecl Fatal(eax, 3)`. Welche Pushes zum Aufruf gehören: ein `add esp, 4*m` dahinter sagt cdecl und m Argumente; ein direkter Aufruf eines Labels, dessen Code mit `ret 4*n` endet, ist stdcall mit n Argumenten; ein `call [Import]` einer Windows-Funktion, die `help\<Sprache>\winapi.md` mit ihrer Parameterzahl kennt, ist stdcall mit so vielen. Alles andere bleibt (die Pushes könnten zu etwas anderem gehören); eine Folge von Pushes endet an einem Label, einer Kommentarzeile oder einem Push, der keine Zahl, kein Register, kein Label und kein Dword ist. Nur wo der Assembler dieselben Bytes macht: die Datei wird assembliert und verglichen, sonst ohne geschrieben (der Dialog sagt es). Es lässt sich zusammen mit dem `if`-Export benutzen. Im 32-Bit-dcc32 1.832 Aufrufe (die Datei kommt zusammen mit den 10.224 Ifs und Schleifen Byte für Byte zurück), in Dism.exe 542 von 4.091, in OpenWith.exe 205, in PkgMgr.exe 304. Unit `DisCallExport`; Fälle in `anatest` (`CallExportText`) und der Round Trip von `wste1.exe` mit `--if --calls`.

- Assembler, i386 (auch `.arch x86_real`): **ein Zeichen in Anführungszeichen ist in einem Befehl eine Zahl**: `mov al, '0'`, `cmp al, '9'`, `add al, "A"`, `push 'x'`, `mov eax, 'abcd'` (bis zu vier Zeichen, das erste im niedrigsten Byte, wie bei NASM); beide Anführungszeichen gehen, `db` behält seine Zeichenketten. Fall `char_immediate`.
- Assembler, i386: **`loop`, `loope`, `loopne`, `jecxz` und `jcxz` nehmen ein Label ohne `short`** (sie haben keine andere Form; ein Label außer Reichweite ist ein Fehler wie bei `short`). Fälle `loop_label`, `loop_label_far`.
- Beispiele: `examples/dos/tick.asm` zählt in `ebx` und gibt es jede Sekunde aus einem Haken im Zeitgeber-Interrupt 08h aus (der Handler sieht die Register der Zählschleife); `examples/windows_intel/tick_i386.asm` macht dasselbe für Windows mit einem zweiten Thread, der `ebx` mit `GetThreadContext` liest; `examples/func/func_fact.asm` ist die Fakultät.

### Behoben
- Assembler: **`call Name(0x1B)`**: eine hexadezimale Zahl, die auf `B` endet, als einziges Argument (`(0x1B)`, `(0xB)`) wurde als Zahl mit dem Binär-Suffix gelesen und abgelehnt (*unexpected token*).

## 0.7.4 – 2026-10-26

### Neu
- Dismonite: **`if` auf den Flags und `do ... while` im Listing und im Export** (dieselben Regeln wie in Asmonite seit 0.7.3). Ein bedingter Sprung vorwärts zu einem Label, das nur er benutzt, ohne ein `cmp` / `test` davor, aus dem sich eine Bedingung lesen lässt, wird als `if zero`, `if not below` ... geschrieben (`dec ecx` + `jnz` über den Block ist `if zero`); ein bedingter Sprung **zurück** zu einem Label, das nur er benutzt, ist eine Schleife: das Label wird zu `do`, der Sprung zu `while <Bedingung>` (cmp + `jnz` ist `while a != b`, `dec ecx` + `jnz` ist `while not zero`). Schleifen und Ifs verschachteln sich; das Listing zeigt `; do` am Label, `while ...` / `back to do` am Ende und rückt den Körper ein. Im 32-Bit-dcc32: 9.090 `if` (davon 1.035 auf den Flags) und 1.134 `do ... while`; der Export kommt Byte für Byte zurück. Der Export versucht zuerst alles, dann nur die Ifs mit Flags, dann nur die Ifs mit `cmp` / `test` und behält den ersten, der dieselben Bytes ergibt. `DismoniteC --if-dump <Vorsilbe>` speichert jeden Versuch als Datei (eine Testhilfe).

### Behoben
- Assembler, i386: **Sprünge ohne `short` / `near` beginnen kurz und werden nur dort lang, wo sie nicht reichen** (vorher begannen sie lang und wurden kurz, wo sie passten; so bleiben Sprünge lang, die nur zusammen kurz sein können: zwei Sprünge, die übereinander hinweggehen, eine Schleife und der Sprung darüber). Das Ergebnis ist die kürzeste Anordnung, wie sie ein Compiler hat. Fälle `jump_short_together`, `jump_short_back_edge`.

## 0.7.3 – 2026-10-26

### Neu
- Asmonite, i386: **`if` auf den Flags** und **`do ... while`**. `if zero`, `if not carry`, `if below or equal` und so weiter brauchen keinen Vergleich: die Flags des Befehls davor zählen, und nur der Sprung um den Block wird geschrieben (`dec ecx` / `if zero` ist ein `jnz` über den Block). Die Wörter: `zero` (`equal`), `carry`, `sign`, `overflow`, `parity`, `above` / `below` (ohne Vorzeichen), `less` / `greater` (mit Vorzeichen), `not` davor, `or equal` hinter den letzten vier. **`do` ... `while <Bedingung>`** lässt den Block einmal und dann so lange laufen, wie die Bedingung gilt: die Bedingung hat die Formen des `if` (ein Vergleich mit `signed` / `unsigned` oder `.compare`, `a & b`, ein Flag-Wort), und der Sprung zurück zum `do` ist die Bedingung selbst (`while not zero` ist `jnz`, `while signed eax < 10` ist `cmp` und `jl`). Das Label am `do` macht der Assembler (`asmogen_do<Zeile>s`). Schleifen und Ifs verschachteln sich; eine am falschen Ort geschlossene ist ein Fehler (`endif without if (the open block is the do in line 3, while is missing)`). `do` und `while` dürfen keine func, keinen Parameter und kein Lokales benennen; sie haben die Farbe der Syntax. Beispiel `examples/func/func_loop.asm`, Fälle `func_if_flag_*` und `func_do_*`; die Seite `if.html` hat Abschnitte zu beidem.
- Asmonite, i386: **`if a & b`** prüft Bits: `if eax & ebx` ist `test eax, ebx` und der Sprung um den Block, wenn in beiden kein Bit gesetzt ist, `if eax & ebx == 0` lässt den Block laufen, wenn keines gesetzt ist, `if eax & ebx != 0` ist dasselbe wie `if eax & ebx`. Ein Register, eine Zahl oder Speicher (`if byte [ebx] & 1`, `if al & 0x80`); `test` kennt nicht „Register gegen Speicher“, die Operanden werden vertauscht. Kein `signed` / `unsigned` dabei, dahinter nur `== 0` / `!= 0`. Fälle `func_if_test*.asm`; die Seite `if.html` hat einen Abschnitt dazu.- Dismonite: **Export mit `if` / `else` / `endif`** (Menü Datei, *Export with if / else / endif*, gemerkt in `Dismonite.ini`; `DismoniteC --if`). In einem 32-Bit-Windows-Programm wird ein `cmp` oder `test` mit dem bedingten Sprung dahinter, der vorwärts zu einem Label geht, das nur dieser Sprung benutzt, als `if a == b` ... `endif` geschrieben (der Sprung der Gegenbedingung: `jne` ist `==`, `jl` ist `if signed a >= b`, `jbe` ist `if unsigned a > b`, `test` + `jz` ist `if a & b`); ein `jmp` zu einem Label, das nur er benutzt, am Ende des Blocks ergibt `else`; Blöcke sind um zwei Leerzeichen eingerückt. Nur wo der Assembler dieselben Bytes daraus macht: die Datei wird assembliert und verglichen, sonst wird sie ohne geschrieben (der Dialog sagt es); Sprünge, die das Programm als `near` hat, bleiben wie sie sind. Im 32-Bit-dcc32 (19.663 bedingte Sprünge) werden 8.055 zu einem `if`, und die Datei kommt Byte für Byte zurück. Unit `DisIfExport`.
- Dismonite: **Export mit `if` / `else` / `endif`** (Menü Datei, *Export with if / else / endif*, gemerkt in `Dismonite.ini`; `DismoniteC --if`). In einem 32-Bit-Windows-Programm wird ein `cmp` oder `test` mit dem bedingten Sprung dahinter, der vorwärts zu einem Label geht, das nur dieser Sprung benutzt, als `if a == b` ... `endif` geschrieben (der Sprung der Gegenbedingung: `jne` ist `==`, `jl` ist `if signed a >= b`, `jbe` ist `if unsigned a > b`, `test` + `jz` ist `if a & b`); ein `jmp` zu einem Label, das nur er benutzt, am Ende des Blocks ergibt `else`; Blöcke sind um zwei Leerzeichen eingerückt. Nur wo der Assembler dieselben Bytes daraus macht: die Datei wird assembliert und verglichen, sonst wird sie ohne geschrieben (der Dialog sagt es); Sprünge, die das Programm als `near` hat, bleiben wie sie sind. Im 32-Bit-dcc32 (19.663 bedingte Sprünge) werden 8.055 zu einem `if`, und die Datei kommt Byte für Byte zurück. Unit `DisIfExport`.
- Dismonite: **if / else / endif im Listing** (Menü Analyze, *Show if / else / endif in the listing*, beim Start an, gemerkt in `Dismonite.ini`). Die Stellen, die der Export als `if` schreiben würde, bekommen einen Kommentar: die Zeile mit `cmp` / `test` sagt `if eax == 0x10`, der Sprung `if not: to endif` (oder `to else`), der Sprung am Ende des Then-Teils `then part done: to endif`, das Label `; else` / `; endif`; der Code eines Blocks steht je Ebene zwei Zeichen weiter rechts. Nur eine Ansicht: jeder Befehl behält seine Zeile, Adresse, Bytes und seinen Haltepunkt, der Debugger geht wie vorher; Listing, Suche und Export sind dieselben. Die Regel ist die des Exports (ein Label, das nur dieser Sprung benutzt, verschachtelte Blöcke), gefunden je Funktion; der Einsprungcode vor der ersten Funktion auch. Rund 1,4 s mehr für alle 338.000 Zeilen des 32-Bit-dcc32; wo ein Sprung im Export `near` geschrieben ist, zeigt das Listing den Block trotzdem.

### Geändert
- Dismonite, Debugger: die beiden Fenster unten haben die Plätze getauscht: links die Ausgabe des Programms, rechts der Speicher (feste Breite, genug für eine Zeile mit 16 Bytes und dem Text; der Trenner verschiebt sie).

### Geändert
- Assembler, i386: Sprünge ohne `short` / `near` werden in **Runden** gekürzt, bis sich nichts mehr ändert. Vorher fiel eine Entscheidung aus den Abständen des ersten Durchlaufs, ein Sprung über andere Sprünge, die erst kurz werden, blieb lang (`jmp x` über zwanzig `jne`: 5 statt 2 Bytes). Jetzt kommt das kürzeste Ergebnis heraus, wie bei anderen Assemblern; eine Datei mit vielen solchen Sprüngen wird einige Male assembliert (rund 16 s statt 7 s für die 231.000 Zeilen eines disassemblierten dcc32). Fall `jump_relax_rounds`.

### Behoben
- Assembler, i386, zwei Fehler bei Sprüngen, die automatisch kurz werden (`jmp x` / `jne x` ohne `short`): (1) ein Befehl, den asm_x86 an den anderen Kodierer abgibt (x87 wie `fld tword [label]` und andere), nahm die Adresse eines Labels weiter unten aus dem ersten Durchlauf, vor dem Kürzen der Sprünge: falsche Adresse im Code; (2) ein `jmp short` über Sprünge, die erst später kurz werden, bekam den Fehler „error with bdo“, obwohl er am Ende reicht. Gefunden beim Zurückbauen des 32-Bit-dcc32 aus seiner `if`-Form. Fälle `jump_short_fpu_label`, `jump_short_over_shortened`.

## 0.7.2 – 2026-10-23

### Geändert
- `conwatch.exe` (das Hilfsprogramm, das die Konsole des debuggten Programms spiegelt) hat jetzt eine Versionsinformation und importiert `AttachConsole` normal: weniger Fehlalarme von Virenscannern (Urteile von maschinellem Lernen).

## 0.7.1 – 2026-10-23

### Geändert
- Die ZIP-Datei enthält die Beispielprogramme (`.exe`) von `examples\windows_intel`, `windows_arm`, `func`, `x64`, `arm64` und `winarm` nicht mehr: Virenscanner meldeten winzige, von Hand gebaute Programme fälschlich. Die Quelltexte sind da; F9 in Asmonite baut die Programme. `examples\dos\HELLO.EXE` (für Dismonite) bleibt.

## 0.7.0 – 2026-10-23

### Neu
- Assembler: **Ausdrücke, `equ`, `$` und `$$`**. Überall, wo eine Zahl steht, rechnet der Assembler: `* / % + - << >> & ^ | ~` und Klammern, Zahlen als `0x1F`, `1Fh`, `101b`, `'A'`. `name equ ausdruck` definiert eine Konstante (auch hinter ihrer Verwendung), `$` ist die Adresse der Zeile, `$$` der Anfang des Abschnitts, und die **Differenz zweier Labels** ist eine Zahl: `mov ecx, end-start`, `len equ $-msg`. Der konstante Teil eines Speicheroperanden wird ebenfalls gerechnet (`[ebx+2*4]`). Eine Differenz von Labels braucht die Adressen, der Assembler läuft deshalb erneut, bis sie gleich bleiben. Gemacht von einem Durchlauf über den Quelltext (`src/cpu/asm_expr.pas`) vor dem Kern, für alle Architekturen; was kein Ausdruck ist, bleibt wie es war. Neu auch im Kern: eine Zahl hinter einem Label als Wert, `mov eax, table+4`, `push table-4`, `dd table+4` (Sprung und Aufruf: Fehler).
- Asmonite, i386: die Wörter der `func`- und `if`-Syntax (`func begin end var uses cdecl stdcall if else endif signed unsigned`) dürfen nicht der Name einer func, eines Parameters oder eines Lokalen sein (ein Fehler, wie es die Hilfe für Register, Befehle und Schlüsselwörter schon immer sagte); Labels und Datennamen sind nicht betroffen. Fälle `func_error_keyword_*`.
- Asmonite, i386: **`if` / `else` / `endif`** mit direktem Vergleich: `if ebx == [0x04+eax]` ... `endif` ist `cmp` und der Sprung der Gegenbedingung um den Block (ohne eigenes Label); `else` geht, Ifs lassen sich verschachteln, es gilt überall im i386-Code und in einer func (ihre Namen gehen im Vergleich). Ein Vergleich, keine Ausdrücke: `==`, `!=`, `<`, `<=`, `>`, `>=`; die vier Ordnungsvergleiche sagen **`signed`** oder **`unsigned`** (`if unsigned eax < ebx` ist `jae`, `if signed eax < ebx` ist `jge`), ohne das Wort ist es ein Fehler, außer davor steht **`.compare signed`** / **`.compare unsigned`** (für alle Ifs dahinter, bis zum nächsten `.compare`; `.compare none` nimmt es zurück; ein Wort in der `if`-Zeile gilt immer). Der Debugger führt die `if`-Zeile (`cmp` und Sprung) als einen Schritt aus. Beispiel `examples/func/func_if.asm`, Fälle `func_if_*.asm`.
- Asmonite und Dismonite, Debugger: **Register und Flags ändern** beim angehaltenen Programm, für x86 (Windows, DOS), x64, ARM / Thumb und ARM64. **Doppelklick** (oder **F2**, **Enter**) auf ein Register öffnet einen kleinen Dialog mit seinem Wert; ein **Flag** (CF, ZF, N, Z, T ...) schaltet der Doppelklick oder **Leertaste** um; das Kontextmenü hat *Change value...*, *Toggle flag*, *Set to 0* und *Copy value*. Der Wert ist hex (`1F`, `0x1F`, `$1F`, `1Fh`), dezimal mit `#` (`#31`), ein Zeichen (`'A'`) oder ein Ausdruck aus Werten und Registernamen mit `+` und `-` (`esp+8`, `r0-#1`); ein Wert, der nicht ins Register passt, oder ein unbekanntes Wort bleibt mit der Begründung im Dialog. Ein neues `EIP` / `RIP` / `PC` versetzt das Programm: Editor und Ansicht zeigen die neue Stelle wie einen Halt („nächste Anweisung setzen“). In Dismonite führt ein Doppelklick auf ein Register, das ins Programm zeigt, weiter dorthin; ändern mit F2 oder über das Menü. Die Änderungen gehen an das Programm, wenn es weiterläuft (Windows: `SetThreadContext`; die Debug-Server und QEMU: das `G`-Paket). Beide Programme benutzen denselben Code (`DbgRegEdit`, `DbgRegDlg`).
- Dismonite: **Argumente und Lokale in mehr Funktionen gefunden**, und mehr dazu gesagt. Die Funktionen der Microsoft-Compiler, die mit `mov edi,edi` beginnen (Hotpatch-Präfix), 16-Bit-Funktionen (`push bp / mov bp,sp`: die Argumente sind 2-Byte-Plätze ab `[bp+4]`, ab `[bp+6]` in einer Far-Funktion, die mit `retf` endet; `[word 0xFE7E+bp]` ist eine negative Verschiebung) und Funktionen, die nur angesprungen werden (ein Label am `push ebp`), bekommen jetzt die Hinweise `arg1` / `loc1`. Lokale, die sich überlappen (ein `byte [ebp-7]` im `dword [ebp-8]`), sind eine Variable (`loc2+1`), die Rahmengröße wird aus `sub esp,N` / `add esp,-N` / `push ecx` gelesen. Die Zusammenfassung am `push ebp` sagt mehr: `stdcall, 2 args, 3 locals, frame 0x10`; die Konvention (`stdcall`, `cdecl`, `pascal`, `far`, `register`) kommt aus `ret N` und den Argumenten, **Register als Argumente** (`eax`, `edx`, `ecx`, gelesen bevor sie geschrieben werden: Delphi `register`, fastcall, thiscall) werden genannt (`register, regs eax edx ecx, 1 stack args, ...`), und das Sichern eines solchen Registers in einem Lokalen steht als `loc2 = ecx`. Nur Kommentare: der Export ergibt dieselben Bytes. Im 32-Bit-Notepad hatten vorher 0 von 6894 `[ebp+x]`-Operanden einen Hinweis, jetzt 94 %; in einem DOS-Compiler (TPC) 0 von 1060, jetzt 71 %.

## 0.6.0 – 2026-10-22

### Neu
- Asmonite: **neue Fensteraufteilung**: Register, Stack und Memory stehen untereinander in einer Spalte rechts über die ganze Höhe (nur beim Debuggen; jeder Block ist im Menü View schaltbar, die Spalte entfällt, wenn alle drei aus sind), links Code und Ausgabefenster. Größen und Blöcke stehen in `Asmonite.ini`. Memory zeigt in einer schmalen Spalte 8 Bytes je Zeile, in einer breiten 16, und den Stack (`esp`), solange nichts eingegeben ist.
- Asmonite, Debugger: **Step Over auf `call Name(args)` und `call [printf](args)`** führt die ganze Zeile in einem Schritt aus (den Aufruf und das Aufräumen dahinter) und geht nicht in eine func hinein, wenn die Zeile Argumente ablegt.
- Asmonite: **die Konvention eines Imports** in `call [name](...)`: die `.import`-Zeile sagt sie für ihre Namen: `.import msvcrt.dll cdecl printf`, dann räumt `call [printf](fmt, 42)` den Stack auf (`add esp, 8`); ohne das Wort ist ein Import stdcall. Bei einer DLL der C-Laufzeit (`msvcrt.dll`, `ucrtbase.dll`, `api-ms-win-crt-*`) ist das Wort Pflicht: ein Aufruf mit Argumenten ohne es ist ein Fehler. `call cdecl [name](...)` oder `call stdcall [name](...)` entscheidet für einen Aufruf. Beispiel `examples/func/func_printf.asm`.
- Dismonite, DOS-Programme (MZ): **Konstanten und Displacements im Code** lassen sich als Offsets bezeichnen, mit denselben Tasten wie die Wörter einer Tabelle: auf einem Befehl **L** (Offset auf Code), **Umschalt+L** (Offset auf Daten), **X** (eine Zahl). Das Label des Ziels steht im Operanden (`mov bx,C0000_9C2A`, `jmp [cs: word L0000_085A+bx]`), der Code hinter einem Code-Offset ist sicher und wird verfolgt, und der Export schreibt das Label ebenfalls (vom Assembler geprüft, Bytes identisch). Daten, die eine Konstante nennt, liegen im **Datensegment**: dem Paragraphen, den DS enthält, aus dem Einstiegscode erkannt (`mov ax,0x10D0 / mov ds,ax`) oder in DOS > Data segment gesetzt (als `dataseg` gespeichert); mit `cs:` liegt das Ziel im Codesegment. Ein Befehl mit zwei Feldern: das Displacement (außer es ist ein einfaches `[0x1788]`), sonst die Konstante. Gespeichert als `ref <Offset> operand <Rolle>`; Entf nimmt zuerst die Entscheidung des Befehls zurück.
- Dismonite: **die Markierungen des Benutzers im Gutter**: ein Balken vor der Adresse (blau: ein Eintrag, grün: der Anfang eines Laufs, lila: eine Entscheidung über eine Adresse). Die Maus im Gutter sagt, was die Markierung ist (Art und Größe, der Lauf mit seinen Grenzen, die Entscheidung und ihr Ziel, dein Name für das Label) und was Entf zurücknimmt.
- Dismonite: **strenge Markierungen über mehrere Bytes** (was du eingibst; das Lesen einer .dmon-Datei wird nicht geprüft): Ein Word, Dword oder Qword wird abgelehnt (mit Ton und dem Grund in der Statuszeile), wenn ein Label darin läge (ein Label am ersten Byte ist in Ordnung), wenn eine andere Markierung von dir überdeckt würde oder wenn ein Feld des Dateiformats darin liegt; ascii und UTF-16 enden vor dem nächsten Label oder der nächsten Markierung von dir. Der Eintrag, den du neu markierst, darf ersetzt werden; ein Lauf aus B/W/D/Q endet vor einer Markierung von dir, die er nicht selbst macht.
- Dismonite: Ein Klick in den Gutter (die Spalte mit den Adressen) setzt einen Haltepunkt auf diesen Eintrag oder nimmt ihn weg, wie F5.
- Dismonite, DOS-Programme (MZ): **manuelles Markieren**. Menü DOS > Manual marking (im `.dmon` als `manual` gespeichert): Das Programm markiert den Code, der *sicher* ist, selbst - alles, wohin Ablauf, Calls und Jumps vom Einstiegspunkt, von deinem markierten Code und von den Wörtern führen, die du als Offset auf Code bezeichnet hast - und macht das nach jeder Entscheidung von dir neu (was du zurücknimmst, geht wieder weg). Sonst wird nichts analysiert; was übrig bleibt (was nur über eine Tabelle oder einen indirekten Sprung erreichbar ist, Daten, der Rest), ist deine Sache: **Strg+F5** / **Strg+Umschalt+F5** springen zur nächsten / vorigen Stelle, an der du entscheiden musst, die Statusleiste zählt sie. **C** markiert Code (seine Calls und Jumps werden sofort verfolgt), **L** / **Umschalt+L** / **X** sagen, dass das Wort am Cursor ein Offset auf Code / auf Daten / eine Zahl ist (gespeichert als `ref <Offset> word code|data|number`; ein Byte wird dabei zum Wort); die Statuszeile sagt sofort, was am Ziel steht: Anfang eines Befehls, Anfang von Daten, noch nicht markiert, mitten in einem Befehl oder Datenfeld (dort kann kein Label stehen), außerhalb des Segments oder der Datei. **Entf** nimmt zuerst die Entscheidung zurück, dann die Markierung des Wortes. Was die Befehle des Analyze-Menüs markieren (Tabellen, Strings), sind nur Vorschläge mit orangen Bytes, bis du sie annimmst (**Strg+Y** den am Cursor, DOS > Accept all suggestions). DismoniteC folgt dem sicheren Code eines Dokuments mit `manual` genauso.
- Dismonite: **Strg+F4** / **Strg+Umschalt+F4** (Menü Go) springen zur nächsten / vorigen Stelle, an der Code und Daten wechseln: vorwärts zum Anfang des nächsten Abschnitts aus Einträgen der anderen Art (Code: Befehle, Daten: alles andere), rückwärts zum Anfang des Abschnitts, in dem du stehst, oder - an dessen Anfang - des Abschnitts davor.
- Dismonite: **Entf** nimmt die Markierung des Eintrags unter dem Cursor zurück (Menü Data > Unmark this item): die eigene oder die der Analyse; die Bytes sind wieder einzelne, unmarkierte Bytes, Namen und Kommentare bleiben. Ein Lauf, zu dem der Eintrag gehört, wird aufgelöst, seine übrigen Einträge bleiben. Der Cursor geht danach zum nächsten Eintrag, so dass sich mehrere Markierungen hintereinander zurücknehmen lassen (nach dem Zurücknehmen einer Entscheidung über eine Adresse bleibt er stehen: das nächste Entf nimmt die Markierung des Wortes zurück).
- Dismonite, DOS-Programme (MZ): Die Analyse weiß, wie ein DOS-Programm endet. Nach `mov ah,4Ch` / `int 21h` (auch AH = 00 und 31,
  `int 20h`, `int 27h`) folgt kein Code mehr - was dort steht (die Optionstabelle eines Compilers), wird nicht mehr als Code
  gelesen, auch nicht vom Code-Lauf des Benutzers (C). `mov dx,offset` / `mov ax,25xxh` / `int 21h` (Interruptvektor setzen)
  macht den Handler zu Code.
- Dismonite, DOS-Programme: Zeigertabellen. Folgen von mindestens 6 Wörtern (Sätze von 2 bis 6 Bytes: ein Zeiger und ein Schlüssel oder
  Flags) in den Bytes, die kein Code sind, deren Werte auf den Anfang von Code im selben Segment zeigen - 90 % davon hinter einem
  `ret`/`jmp` oder bei bekanntem Code, und sauber decodierbar -, werden zu Wort-Einträgen, die Adressen sind: `dw J0000_01F5`, mit Labels
  an den Zielen, deren Code verfolgt wird; 4 und 5 Einträge, wenn alle auf bekannten Code hinter einem `ret`/`jmp` zeigen. Auch von dir
  markierte Wörter (W), die auf so eine Stelle zeigen, sind Adressen (eine Tabelle mit 3 Einträgen). Tabellen, die der Code benutzt
  (`jmp [cs: 0x2355+bx]`, auch `call`), findet die Analyse an diesem Befehl: ihre Wörter sind Adressen, solange sie auf sauber decodierbaren
  Code zeigen und nahe bei den anderen bleiben (Case-Labels); ungenutzte Plätze (0) davor oder dazwischen werden übersprungen. Teil von „Analysieren“ (Menüpunkt
  *Find tables of pointers to code (DOS)*) und „Neu analysieren“ (nicht gespeichert). TPC.EXE: Von den Code-Labels seiner Quelle sind
  nach der automatischen Analyse 85 % (vorher 37 %) Code, mit einer `.dmon` des Benutzers 90 % (vorher 63 %). Der Export schreibt `dw Label`.
- Asmonite: `dw Label` in einem Quelltext mit `segment`-Zeilen (MZ) ist der Offset des Labels in seinem Segment (vorher: der Dateioffset).
- Asmonite: `call Name(Arg, ...)` (auch `call cdecl name(...)`, `call [Import](...)`) legt die Argumente von rechts nach links ab,
  ruft auf und räumt bei `cdecl` auf; eine `func` gibt Konvention und Argumentzahl vor. Argumente: Register, Zahl, Label,
  Parameter oder Local (Byte/Word aufgefüllt, Feld = Adresse), `&local`, `[ebx+4]`; für eine Adresse oder ein Byte/Word dient das
  erste von eax/ecx/edx, das die Argumentliste nicht nennt, als Register. Beispiele `examples/func/func_call*.asm`.
- Dismonite: Solange das Programm angehalten ist (Win32), zeigt die Maus über einem `[ebp+x]`-Operanden (oder seinem
  Kommentar `arg1` / `loc1`) den Wert: `loc1: dword 0x0000000A  10`; die Größe kommt vom Größenwort oder vom Register, ein
  Operand mit Indexregister zeigt die ersten Bytes des Feldes; ein Zeiger auf einen Text ergänzt `-> "Text"`.
- Asmonite: Solange das Programm angehalten ist, zeigt die Maus über einem Wort im Quelltext den Wert: Parameter und
  Locals einer `func` (mit Größe und Feldgröße) und Labels von Daten (`db`, `dw`, `dd`, `resb` ...): `byte`, `word`, `dword`
  (hex und dezimal), `qword`, Text als `pchar "..."`, sonst die ersten Bytes; ein Dword, das auf einen Text zeigt, ergänzt `-> "Text"`.
- Asmonite: Im Debugger sind `begin` und `end` einer `func` je ein Schritt (Einzelschritt und Prozedurschritt führen den
  ganzen Prolog bzw. Epilog aus); allgemein sind aufeinanderfolgende Befehle einer Quellzeile ein Schritt.
- Dismonite: In einer Funktion, die mit `push ebp / mov ebp,esp` beginnt (ein Call-Label, Ende beim nächsten), benennt der
  Kommentar eines Befehls mit `[ebp+x]` den Platz: `arg1` ([ebp+8], [ebp+0xC] = `arg2` ...) und `loc1`, `loc2` ...
  (die benutzten Plätze unter ebp, der nächste zuerst; `[]` wenn ein Indexregister dazukommt); der erste Befehl zeigt die
  Zusammenfassung (`2 args, 3 locals`, die Argumente auch aus `ret N`). Nur Kommentare: der Export ergibt dieselben Bytes.
- Asmonite: `func Name(Parameter) [cdecl|stdcall] [uses Register]` / `var` / `begin` / `end` schreibt den Stackframe:
  Namen für Parameter (`[ebp+8]` ...) und Lokale (`[ebp-4]`, Felder `buf:16`), Prolog und Epilog (auch bei jedem `ret`),
  `uses` rettet Register. Nur `.arch i386`; Beispiele in `examples/func/`, Hilfethema `func`.
- Dismonite: Ein Code-Lauf (C) übernimmt einzelne Bytes, die der Benutzer als Byte markiert hat (vorher hielt ein solches Byte den
  Lauf sofort an); andere Elemente des Benutzers (Word, Dword, Text ...) und die Dateistrukturen halten ihn weiter an.
- Dismonite: Alt+E exportiert die `.asm`, Alt+X beendet das Programm.
- Dismonite: die Taste **F** folgt dem Label der Zeile zu seinem Ziel (wie Strg+Klick; Alt+Links kommt zurück).
- Dismonite: Suchen (Strg+F) schlägt den Namen des Labels vor, wenn der Cursor auf einer Labelzeile oder auf einem Befehl mit Label (`call C00401234`) steht.
- Dismonite: Beim Öffnen läuft jetzt die Standardanalyse automatisch (nach dem Anwenden der `.dmon`; Fortschrittsfenster mit
  Abbrechen): Entry Point und Exporte, Relokationen, Konstanten, Call- und Sprungziele bis nichts Neues kommt, Strings.
  Menü Analyze: **Re-analyze** (die Marken der Analyse neu, die des Benutzers bleiben), **Analyze automatically when a file
  is opened** (an) und **Follow new targets automatically after marking code** (aus; die Rückfrage nach einem Code-Lauf hat
  einen Knopf „Yes to All“). Die `.dmon` merkt sich auch die Stelle des Cursors (`cursor <Offset>`).
- Dismonite: Die Analyse ist dort viel schneller, wo Startpunkte scheitern: asmoc.exe 40 s -> 5 s (ein gescheiterter
  Relokationspunkt verfolgt die wartenden Stränge nicht mehr weiter), und die Zeilenzahlen des Dokuments werden einmal je
  Analyseschritt gezählt.
- Dismonite: Ein Befehl, dessen letzter Operand eine Zahl von 0x20 bis 0x7E ist, zeigt das Zeichen im Kommentar
  (`cmp al,0x41   ; 'A'`); nicht bei `add`/`sub` des Stackpointers, Schiebebefehlen, `ret`, `int`, `in`/`out`.
- Dismonite: Ist das Programm im Debugger angehalten, zeigt die Maus über einem Namen (Label im Code oder seine
  eigene Zeile) den Wert der Variablen in einer Zeile: `byte`, `word`, `dword` (hex und dezimal), `qword`,
  `pchar "..."`, `pwchar "..."`, nicht markierte Daten als 8 Bytes; ein Zeiger auf einen String des Programms
  ergänzt `-> "Text"`.
- Dismonite: Code, der ein Label auf einen ASCII- oder UTF-16-String benutzt, zeigt dessen ersten 20 Zeichen im
  Kommentar (`push msg   ; "Hello, this is a lon..."`); auch bei ARM-Literalen und bei einer Konstante, die die
  Adresse eines Strings ist.
- Dismonite: die automatischen Sprunglabels (`J00401234:`, meist lokale Sprünge) stehen im Fenster und im
  `.asm`-Export zwei Zeichen links vom Code (zwei Leerzeichen vor dem Label); so fallen Calls und Datenlabels auf.
- Dismonite: Speicher ohne Dateibytes (`.bss`, das Ende einer Section mit größerer virtueller Größe) folgt der Datei als
  Nullbytes: Er hat Adressen, Labels `V00xxxxxx`, Zeilen `resb 8` / `resd 1` (eine je Abschnitt zwischen zwei Labels)
  und die Typen B, W, D, Q gehen dort. Namen und Typen des Anwenders stehen wie überall nach Offset im `.dmon`.
  Der `.asm`-Export schreibt ihn als `section 0x... nobits` mit `resb`-Zeilen und Labels, der Export ergibt also
  weiter die Datei; Statuszeile und die Prüfung der `.dmon`-Datei zählen die Bytes der Datei.
- Asmonite: `section <rva> nobits` (flache Quelltexte): `resb` darin schreibt am Ende der Ausgabe keine Dateibytes;
  seine Labels haben Adressen.
- Asmonite: `resb`, `resw`, `resd`, `resq` reservieren nicht initialisierte Daten. Mit `.format pe` dürfen sie am
  Ende einer Section stehen (`.code`, `.data`); der Platz steht nicht in der Datei (VirtualSize größer als
  RawSize), die Labels davor sind normale Adressen. Ohne `.format pe` schreiben sie Nullbytes.
- Dismonite: Nach einem Code-Lauf (C) können die Calls und Sprünge darin zu Stellen führen, die noch kein Code
  sind. Dismonite fragt, ob dem Code von dort aus gefolgt werden soll (dieselbe Analyse wie „Follow code from the
  entry point“, mit den C- und J-Labels als Startpunkten); auch im Menü Analyze > Follow code from the call and
  jump targets.
- Dismonite: Die Tasten C, B, W, D, Q markieren einen **Lauf**: Code ab dem Cursor, Befehl für Befehl (keinem
  Sprung wird gefolgt), bis `ret`, einem unbedingten `jmp`, einem Befehl, der nicht decodiert (oder den kein
  Compiler schreibt) oder einem Element des Dateiformats; bei B, W, D, Q Byte, Word, Dword oder Qword bis zum
  nächsten Label. Die `.dmon`-Datei bekommt dafür eine Zeile `run <Adresse> <Art> [<Ende>]`; beim Lesen werden
  die Elemente neu gebildet. Umschalt+C, B, W, D, Q setzen nur ein Element (eine Zeile `item`, wie früher C, B,
  W, D, Q). Ein von Hand gesetztes Element in einem Lauf löst den Lauf auf: seine Elemente werden einzeln
  gespeichert.
- Dismonite decodiert 32-Bit-Code mit dem x64-Decoder in seinem 32-Bit-Modus: `cmovcc`, `bswap`, `cpuid`,
  `rdtsc`, x87, MMX und SSE sind jetzt Befehle (vorher Bytes). notepad_32bit.exe: 3.705 -> 40.264 Befehle
  gefunden.
- Asmonite (`.arch i386`) assembliert `cmovcc`, `bswap`, `cpuid`, `rdtsc`, `ud2`, `pause`, `int3`, `fwait`,
  `nop dword [eax]`, `lock cmpxchg`, `xadd`, x87, MMX und SSE; `add eax,12` nimmt die kurze Form `83 C0 0C`.

### Geändert
- Dismonite: Die automatischen Labelnamen zeigen, was auf ein Label zeigt: `C00401234` (ein `call`),
  `J00401234` (ein Sprung: `jmp`, `jcc`, Einträge einer Sprungtabelle), `L00401234` (nur Daten: Zeiger,
  Speicheroperanden, Konstanten). Ein Aufruf geht vor einem Sprung. Die Adresse bleibt, der Buchstabe kann
  sich ändern, wenn die Analyse mehr findet. Der Export (`.asm`) benutzt dieselben Namen.

### Behoben
- Dismonite: Beim Markieren von ascii (oder Word, Dword, Qword) konnte ein Label überdeckt werden, das ein Zeiger hinter dem Eintrag erzeugte: Die Labels der Einträge in einem Fenster von 4 KB wurden vor der Prüfung freigegeben. Die Regeln sehen die Labels jetzt so, wie sie sind.
- Dismonite, DOS-Programme: Die Analyse folgte einem `call` oder `jmp`, der im Segment überläuft, zur falschen Stelle (`call -0x85E7` wird als `+0x7A19` geschrieben; das Label zeigte das richtige Ziel, der Code wurde 64 KB weiter markiert). Sie folgt jetzt dem richtigen Ziel, auch einem Sprung vorwärts um mehr als 32 KB (als negative Zahl geschrieben). Manuelles Markieren: ein bis drei Nops (0x90) zwischen anderen Dingen sind keine Stelle, an der du entscheiden musst.
- Disassembler (16-Bit-Code): `ror` mit Zähler 1 oder CL (`D0`..`D3 /1`) wurde als `ror ax,imm8` gelesen und nahm ein Byte zu viel: `D1 C8` wurde `ror ax,0xAB`, der Befehl danach ging verloren. Gefunden beim Vergleich von TPC.EXE mit dem TASM-Listing.
- Asmonite (i386): Eine als 0x80..0xFF geschriebene Zahl wurde als vorzeichenerweitertes Byte codiert, das ist ein anderer
  Wert: `push 0x80` wurde `6A 80` (= 0xFFFFFF80), `cmp ebx,0xC8` wurde `83 FB C8`, ebenso `or edx,0x80`, `sub ecx,0x90`,
  `imul eax,ebx,0x80`. Jetzt gilt der 32-Bit- (bzw. 16-Bit-)Wert (`push 0x80` = `68 80 00 00 00`); die kurzen Formen bleiben
  für 0..127 und die negativen Bytes. (Aufgefallen bei `CreateFileA(..., 0x80, ...)`: Flags 0xFFFFFF80.)
- Dismonite / der Disassembler: Das Byte von `83 /x`, `6A` und `6B` ist eine vorzeichenerweiterte Zahl und wird jetzt so
  geschrieben: `and cx,0xFFFE`, `push 0xFFFFFF80`, `cmp eax,0xFFFFFFFF` (vorher `and cx,0xFE`, das der Assembler als 0x00FE
  liest, also ein anderer Wert). Der Assembler führt so eine Zahl (auch `-2`) wieder auf die kurze Form zurück, Exporte ergeben
  also dieselben Bytes.

## 0.5.0 – 2026-10-14

### Neu
- **F1-Hilfe für x64-Code** (Deutsch und Englisch): `movsxd`, `cdqe`/`cqo`, `syscall`/`sysret` und zwei Übersichten,
  die von selbst erscheinen: `rip` (Adressieren relativ zu rip, `[rip+...]` oder `[rel label]`) und `x64` (der
  64-Bit-Modus in Kürze: Register und ihre Teile, REX, was weggefallen ist, die Aufrufkonventionen von Windows und
  Linux) bei jedem Befehl mit einem 64-Bit-Register.
- **F1-Hilfe für weitere x86-Befehle** (Deutsch und Englisch): `cmovcc`, `bswap`, `xadd`, `cmpxchg`/`cmpxchg8b`,
  `cpuid`, `rdtsc`, `pause`, `ud2`, `int3`, `sysenter`/`sysexit`, `popcnt`/`lzcnt`/`tzcnt` (86 -> 97 Abschnitte).
- Beispiel `window_i386.asm` (i386, `.format pe gui`): ein Fenster mit Menüleiste (File > Exit), einer Eingabezeile,
  einem Button und einem Label; der Button zeigt den Text der Eingabezeile auf dem Label. Fensterklasse,
  Fensterprozedur (WM_CREATE, WM_COMMAND, WM_DESTROY) und Nachrichtenschleife sind ausgeschrieben und
  kommentiert. Test: `guitest.ps1` (in `run_tests.bat`) benutzt es auf einem eigenen Desktop: Steuerelemente,
  Button, File > Exit.
- **Fenster "Debug targets"** (Debug > Debug targets..., in Asmonite und Dismonite): alle Ziele an einer Stelle -
  Windows i386, Windows x64, Windows on ARM (ARM32 und ARM64), DOS (QEMU), ARM Linux (QEMU). Beim Öffnen ist der
  Eintrag gewählt, der zum Programm passt (aus seinem `.arch`, in Dismonite aus der Datei); die Liste zeigt, wie
  jedes Ziel erreicht wird (dieser Computer, Host und Port, ssh). Es ersetzt die Menüpunkte "Debug target Windows
  on ARM", "Debug target x64 computer" und "DOS Boot Floppy" (die Boot-Diskette wählt man dort). Die
  Einstellungen in den ini-Dateien bleiben. Test: `targettest.ps1` (in `run_tests.bat`, beide Programme,
  eigener Desktop).
- Asmonite schreibt beim Start einer Debug-Sitzung die Zeile `Target: ...` (z. B. `Target: Windows x64 on this
  computer`) in das Ausgabefenster; Help > Asmonite on Discord öffnet in beiden Programmen den Discord-Kanal.
- Beispiel `window_x64.asm`: dasselbe Fenster für x64 (Shadow Space, rcx/rdx/r8/r9, WNDCLASS mit 72 Bytes), gleich getestet.
- Die Beispiele sind nach System sortiert: `examples/dos`, `examples/windows_intel`, `examples/windows_arm` (vorher `examples/asmonite`).
- F1-Hilfe für ARM64 (`help/de|en/a64.md`): die häufigen Befehle, Register (xzr, sp, lr, x18) und Bedingungen.
- Beispiele `messagebox_i386.asm`, `messagebox_x64.asm`, `messagebox_arm32.asm`, `messagebox_arm64.asm` in
  `examples/windows_intel` und `examples/windows_arm`: eine Message Box (`.format pe gui`, Importe aus zwei DLLs), um zu sehen, wo die Fenster
  eines debuggten Programms erscheinen (auf dem Desktop des Rechners, auf dem das Programm läuft).
- **x64-Programme auf einem anderen Rechner**: Asmonite und Dismonite debuggen x64-Programme an
  `asmodbgx64.exe --listen` auf einem Intel/AMD-Windows-Rechner (z. B. von einem Windows-on-ARM-Rechner aus):
  Debug > Debug target x64 computer... (dieser Rechner oder direkt: Host, Port, Code; „Search LAN“ und „Test
  connection“ wie bei ARM). Das Programm wird über die Verbindung kopiert und dort gestartet, seine Ausgabe
  kommt zurück. Die Firewall dieses Rechners muss TCP-Port 23457 durchlassen. Test: `x64dbgtest` (Remote-Teil
  auf diesem Rechner).
- **Das Ziel Windows on ARM wählt sich selbst**: auf einem Windows-on-ARM-Rechner nehmen Asmonite und Dismonite
  „Dieser Computer“ (asmodbg.exe als Kindprozess, ohne ssh, ohne Code), wenn noch kein Ziel gewählt war, und auch,
  wenn der Host in den Einstellungen dieser Rechner ist. Antwortet der gewählte Server nicht, sagen sie warum und
  bieten an, direkt hier zu debuggen und das zu merken.
- **`.format pe` mit `.arch thumb`**: Windows-Programme für ARM 32 Bit (PE32, Machine ARMNT, Einsprungpunkt mit
  Thumb-Bit); `.format pe` geht damit für alle vier Arten: i386, x64, thumb und arm64. Code, Daten und Importe
  liegen in einem Abschnitt, der Code ist pc-relativ.
- Thumb: `adr rd, label` und `ldr rt, label` (der Abstand zum pc wird ausgerechnet, schmale oder breite Form);
  `rva label + zahl`; ein Label vor `db`/`dw`/`dd` braucht keinen Doppelpunkt.
- Beispiele `hello_i386.asm`, `hello_x64.asm`, `hello_arm32.asm`, `hello_arm64.asm` in `examples/windows_intel` und `examples/windows_arm`.
- **Asmonite debuggt ARM32-Programme (Thumb-2)** auf einem Windows-on-ARM-Rechner (asmodbg.exe, dieselben Ziele
  wie bei ARM64: ssh, direkt oder dieser Rechner): F9 und F8/F7 nach Quelltextzeilen, Haltepunkte, Ausführen bis
  zur Zeile, Register, Stack und Speicher. Test: `run_tests.bat thumbdbgtest` (nur wenn genannt; ssh zum Host winarm).
- Die PE-Prüfung kennt ARM32 (Machine 0x1C4): die Importe werden auf diesem Rechner nicht nachgeschlagen, und eine
  Warnung kommt, wenn der Einsprungpunkt das Thumb-Bit nicht hat.

### Behoben
- **Asmonite und Dismonite froren bei einem Halt eines Programms mit Fenster ein** (z. B. `window_i386.asm`
  bei `CreateWindowExA`): Das IDE-Fenster nach vorn zu holen wartete im Hauptthread auf das angehaltene Programm
  (`SetForegroundWindow`, `AttachThreadInput`). Das macht jetzt ein eigener Thread (`IdeFront.pas`). Auch die
  Meldungen des Win32-Debugger-Threads werden in eine Warteschlange gelegt und warten nicht mehr auf den
  Hauptthread.
- `.format pe` für x64 und ARM64 mit mehr als einer DLL: die Import-Adresstabellen lagen nicht immer auf
  8 Byte ausgerichtet (das Verzeichnis hat 20-Byte-Einträge); `ldr x16, [x16, :lo12:name]` ließ sich dann nicht
  kodieren. Sie sind jetzt auf 8 ausgerichtet.

## 0.4.0 – 2026-10-13

### Behoben
- Eine von Hand geschriebene PE-Datei (`org`, `db`, keine `section`-Zeilen) hatte Dateioffsets als
  Adressen in Zeilenkarte und Labels, der Debugger fand deshalb keine Quelltextzeile: Sie kommen
  jetzt aus der Sektionstabelle der Datei. Haltepunkte auf `db`-Zeilen in ausführbaren Sektionen
  gehen auch in den x64- und ARM64-Debuggern.

### Neu
- **Ressourcen von PE-Dateien in Dismonite**: Das Ressourcenverzeichnis (Data Directory 2) wird
  gelesen: Der Baum aus Typen, Namen und Sprachen bekommt seine Felder und Überschriften,
  Ressourcennamen (gezählte UTF-16-Texte) werden als Texte markiert. Die RT_STRING-Blöcke (16
  gezählte Zeichenketten: Längenwort, Zeichen, kein Abschluss) werden Zeichenkette für
  Zeichenkette markiert: `dw` Länge und `du` Text, jede mit dem Label `str_<id>` (id = (Block - 1) *
  16 + Index; dcc32.exe: 477 Zeichenketten, die Compilermeldungen). Andere Ressourcen bekommen
  eine Überschrift und ein Label `res_<Typ>_<Name>`. Eine Konstante vor einem Aufruf, der eine
  Meldung lädt (`push 0x82` / `mov eax, 0x20` vor einer Funktion, die `LoadStringA` erreicht;
  durch Zählen gefunden: mindestens 4 Aufrufe, davon 3 von 5 mit einer solchen Konstante), bekommt in
  der Codezeile den Hinweis `=str_130 "Internal error: %s%d"`. Test: `exptest` (dcc32.exe: Export
  gibt die Datei wieder, 477 Zeichenketten, Hinweise).
- **Sprunghinweis im Debugger von Dismonite**: Steht das Programm vor einem Sprung, den es gleich
  ausführt, sagt die Zeile die Richtung ("jump up to L00401520", "jump down to 0x401580", am rechten
  Rand der Zeile und in der Statuszeile). Ein bedingter Sprung zeigt es nur, wenn die Bedingung
  erfüllt ist (Flags, ecx/rcx bei `loop`/`jecxz`, cpsr, Register bei `cbz`/`tbz`), ein
  unbedingter immer; ein nicht genommener Sprung, Aufrufe und indirekte Sprünge zeigen nichts. Für
  x86, x64, ARM, Thumb und ARM64. Tests: `dbgtest`, `x64dbgtest`, `a64dbgtest`.
- **Export von x64- und ARM64-Programmen in Dismonite**: Der Code wird als Befehle geschrieben (mit
  Labels bei Sprüngen, Aufrufen und rip-relativen oder `adrp`-Adressen), nicht als `db`-Bytes; jeder
  Befehl wird wieder übersetzt und mit den Bytes der Datei verglichen, und was nicht dieselben Bytes
  gibt, bleibt `db` mit dem Befehl als Kommentar (kernel32: 49 von 200000 Zeilen).
  - Für Kodierungen, die der Text nicht sagen kann, hat der x64-Assembler Präfixwörter, die der Export
    schreibt: `enc.load` / `enc.store` (von den beiden Kodierungen einer Registerkopie die mit dem
    Register im `reg`- / im `rm`-Feld, `mov rcx, rbx` = 48 8B CB / 48 89 D9), `rex` und `rex.w` (ein REX-Präfix, das nichts ändert,
    `48 FF 15`), `enc.alt` (von gleich langen nicht die erste: `66 83 E8 2D` für `sub ax, 0x2d`);
    `short +18` und `near -7` (eine Zahl mit Vorzeichen nach `short`/`near`) sind Verschiebungen vom
    Ende des Befehls; `[0+rax+rax]` behält sein Verschiebungsbyte 0 (das lange `nop`).
  - Test: `exptest` (hello64, find, where, ipconfig, kernel32 von x64 und msvcrt von ARM64 werden
    wieder zur selben Datei; die letzten drei aus dem Ordner sandbox nur, wo die Dateien liegen).
- **ARM64-Assembler in Asmonite**: `.arch arm64` übersetzt A64-Befehle (Ganzzahl, Laden und Speichern,
  Sprünge, FP, NEON, Atomics, Crypto, System); `.format pe` schreibt damit eine PE32+-Datei für
  Windows on ARM64 (Machine 0xAA64; läuft auf Windows 10 ARM64).
  - `src/assembler/asm_a64.pas` hat keine eigene Tabelle: `dis_a64` ist von Hand geschrieben, also dient
    er als Orakel. Eine Liste von Seed-Wörtern (`asm_a64_seed.inc`, eines je Form eines Befehls, gemacht
    von `tests/a64seedgen.dpr` aus echtem Code, Zufallswörtern und ihren Nachbarn) wird durch Kippen
    jedes der 32 Bits untersucht: Registerfelder, die übrigen Bits nach den Operanden gruppiert, die sie
    ändern, und der Opcode. Der Text wird genauso in Tokens zerlegt, die Register kommen in ihre Felder,
    jede Gruppe der übrigen Bits wird gelöst (alle Werte, oder als lineare Funktion bei Sprungweiten
    und `mov`-Immediates, mit den Kontext-Bits) und das Ergebnis wird wieder dekodiert und muss
    denselben Text geben. Aliase (lsl, ubfx, cmp, cset, mov ...) brauchen nichts Eigenes.
  - Syntax wie der Decoder sie schreibt (capstone), `#` darf fehlen, `lr`/`fp`, ein Label als Ziel von
    Sprung, `adr`, `ldr` (literal); `adrp x0, name` mit `add x0, x0, :lo12:name`; `dq`.
  - Test: `a64asmtest` (die 1656 Fälle von `a64test`, die ganze ntdll von Windows 10 ARM64: 280000
    Befehle, Zufallswörter) und `exptest` (Quelltexte; `tests/pe_arm/a64asm_hello.asm` ist ein Programm,
    das Windows on ARM64 ausführt).
- **x64-Assembler in Asmonite**: `.arch x64` übersetzt x64-Befehle (REX, 64-Bit-Operanden, r8..r15,
  rip-relative Adressen, SSE bis SSE4.2, x87); `.format pe` schreibt damit eine PE32+-Datei (Machine
  0x8664, Image Base 0x140000000, Importeinträge mit 8 Bytes), die Windows ausführt.
  - `src/assembler/asm_x64.pas` ist die andere Richtung von `dis_x64`: Seine Tabelle der Kodierungen
    (`asm_x64_tab.inc`, geschrieben von `tests/x64tabgen.dpr`) wird dem Decoder durch Ausprobieren
    abgelesen (jeder Opcode mit jedem Präfix und REX.W), und jedes Ergebnis wird wieder dekodiert und
    muss derselbe Befehl sein. Die kürzeste Kodierung gewinnt. Syntax wie der Decoder sie schreibt
    (NASM-artig: `mov rax, [rbx+rcx*4+0x10]`, `call [printf]`, `dword [rax]`, `lock xadd`,
    `rep movsb`, `jmp short`); ein Label als Adresse eines Speicheroperanden ist rip-relativ, `[rel
    adresse]` auch; `dq` schreibt 64-Bit-Zahlen und -Adressen, `.imagebase` nimmt 64 Bit. Nicht
    übersetzt: AVX.
  - Die PE-Prüfung von Asmonite liest auch PE32+-Dateien (Header, Abschnitte, Importtabelle); die
    Funktionen der DLLs werden dafür nicht nachgeschlagen. `tests/pe_x64/hello64.asm` ist ein Programm,
    das Windows ausführt.
  - Debugger: F9 auf einem x64-Programm führt es mit Quelltextzeilen unter dem Debugger aus
    (Haltepunkte, Einzelschritt, Schritt über, bis Cursor, Pause, Register rax..r15, rip und die
    Flags, 64-Bit-Stack und -Speicher). Er nutzt dasselbe Hilfsprogramm wie Dismonite:
    `asmodbgx64.exe` (Ordner `armserver` neben dem Programm) als Kindprozess. ARM64-Programme
    (`.arch arm64`) werden ebenso auf einem Windows-on-ARM-Rechner debuggt (`asmodbg64.exe`: ssh,
    direkt oder, auf einem solchen Rechner, lokal); das Ziel stellt *Debug > Debug target Windows on
    ARM...* ein (der Dialog von Dismonite, Einstellungen in `Asmonite.ini`, beim ersten ARM64-Lauf
    gefragt). Register x0..x30, sp, pc, cpsr und N Z C V. Noch nicht: Tastatureingabe für das
    Programm. Tests: `x64dbgtest` und `a64dbgtest` (Zeilenmodus).
  - Test: `x64asmtest` (jeder Text der 1124 Fälle von `x64test` wird wieder derselbe Befehl; mit einer
    DLL als drittem Parameter alle ihre Befehle: kernel32, ntdll, user32, ucrtbase, msvcrt, combase:
    2,8 Millionen, alle zurück) und die Quelltexte in `exptest`.
- **ARM64-Programme in Dismonite**: eine PE-Datei für ARM64 (Machine 0xAA64) wird disassembliert und debuggt.
  - Decoder `src/assembler/dis_a64.pas` (A64): Ganzzahlbefehle mit den üblichen Aliasen (mov, cmp, cset,
    ubfx, ...), Sprünge, Laden und Speichern (Paare, exklusiv, Atomics LSE, Speicher kopieren/setzen,
    Memory Tagging), skalare Gleitkommabefehle, Advanced SIMD (NEON, auch Skalarprodukt, komplexe und
    Elementformen) und die Crypto-Erweiterungen (AES, SHA-1/256/512, SHA-3, SM3, SM4); SVE und SME
    bleiben Daten. Der Text ist der von capstone: `tools/a64_check.py` vergleicht ganze Dateien (ntdll,
    kernel32, ucrtbase, msvcrt von Windows auf ARM64: 710000 Befehle, alle gleich) und Zufallsworte; der Test
    `a64test` hat 1700 Fälle (`tools/gen_a64_cases.py`). Die Namen der Systemregister kommen aus
    `tools/gen_a64_sysregs.py`.
  - Adressen wie bei x64: 16 Stellen, `L0000000140001000`, das Dokument behält die unteren 32 Bit. Die
    Analyse folgt `b`, `bl`, `b.cond`, `cbz`, `tbz`; `adr` zeigt das Label dessen, worauf es zeigt, als
    Hinweis, ein `ldr` (literal) macht sein Wort zu Daten. Der Export schreibt den Code als Befehle (siehe
    oben), `.imagebase` eines 64-Bit-Images mit allen Bits.
  - Debugger: Back-End `DbgGdbA64.pas` (wie `DbgGdbArm` für ARM32): `asmodbg64.exe` auf einem Windows-auf-
    ARM64-Rechner über ssh, direkt (`asmodbg64.exe --listen`, gleicher Anmeldecode) oder, wenn Dismonite
    auf so einem Rechner läuft, als Kindprozess; die Einstellungen von *Debug > Debug-Ziel Windows on ARM*
    gelten für beide. Register X0..X28, FP, LR, SP, PC, CPSR und die Flags, Stack aus Qwords, Speicher
    mit 64-Bit-Adressen; Step Over führt ein `bl`/`blr` bis zum Befehl dahinter aus. Test: `a64dbgtest`
    (nur wenn genannt; `src/armserver/build64.bat`, ssh-Host `winarm`).
- **x64-Programme in Dismonite**: eine PE-Datei für x64 (Machine 0x8664) wird disassembliert und debuggt.
  - Decoder `src/assembler/dis_x64.pas`: REX, 64-Bit-Operanden, rip-relative Adressen, r8..r15,
    Ganzzahlbefehle, x87, SSE bis SSE4.2 und AES; VEX/EVEX (AVX) werden noch nicht decodiert und bleiben
    Daten. Geprüft gegen capstone mit `tools/x64_check.py` (ntdll, ucrtbase, mshtml, libclang: alle
    Befehle gleich bis auf einige Schreibweisen von capstone) und durch den Test `x64test` (1124 Fälle).
  - Adressen: das Dokument behält die unteren 32 Bit einer Adresse (ein Image ist kleiner als 4 GB);
    `ImageBase64`, `AddrText` und die `*64`-Funktionen geben die ganze. Adressspalte, Labels
    (`L0000000140001000`), Register, Stack und Speicheransicht zeigen 16 Stellen. Ein relozierter
    64-Bit-Zeiger (`dq`) zeigt sein Label.
  - Debugger: `asmodbgx64.exe` (neu, `src/armserver/asmodbgx64.c`, `buildx64.bat`, llvm-mingw
    `x86_64-w64-mingw32`) wird als Kindprozess auf diesem Rechner gestartet, wie `asmodbg` auf dem
    ARM-Rechner: ein 32-Bit-Programm kann einen 64-Bit-Prozess nicht mit der Win32-Debug-API debuggen.
    GDB-Protokoll mit den amd64-Registern, Haltepunkt `int3`, Einzelschritt über das Trap-Flag.
    Back-End `DbgGdbX64.pas`; Register RAX..R15, RIP, EFLAGS, Stack aus Qwords und Speicheransicht mit
    64-Bit-Adressen. Tests: `python tools/asmodbgx64_test.py` (Server), `x64dbgtest` (Debugger von
    Dismonite, 29 Prüfungen).
  - `asmodbg` und `asmodbg64` nennen `asmodbgx64`, wenn sie ein x64-Programm bekommen.
- `asmodbg64.exe`: der Debug-Server für native ARM64-PE-Programme (Windows on ARM64), eine Portierung von
  `asmodbg` (Quelltext `src/armserver/asmodbg64.c`, `build64.bat` mit llvm-mingw `aarch64-w64-mingw32`).
  Register in der Reihenfolge des aarch64-Ziels von GDB (x0..x30, sp, pc, cpsr, v0..v31, fpsr, fpcr),
  Einzelschritt über PSTATE.SS, Haltepunkt `BRK #0xF000`. Test: `tools/asmodbg64_test.py` (Sitzung mit
  einem C-Programm und mit dem ARM64-Hello-World `tests/pe_arm/pe_arm64_hello_world.asm`, dessen Code als
  `db` geschrieben ist). Dismonite kann ihn noch nicht benutzen (kein A64-Disassembler, keine 64-Bit-Register).

- Dismonite auf Windows on ARM: das Ziel „Dieser Rechner ist der Windows-on-ARM-Rechner“ (*Debug > Debug
  target Windows on ARM*, `[WinArm] Mode=local`). Dismonite läuft dort selbst (als emuliertes x86-Programm)
  und startet `asmodbg.exe` (Ordner `armserver\`) als eigenen Kindprozess, `--once 127.0.0.1:<freier Port>`,
  mit dem Ordner des Programms als Arbeitsordner: kein ssh, kein Kopieren, kein Anmeldecode, keine
  Firewallregel, kein offener Port außer der Loopback-Adresse. Ein Server, der sofort endet, sagt warum
  („this is an ARM64 program: use asmodbg64“, „the program was not found“) statt einer gescheiterten
  Verbindung. Test: `python tools/winarm_local_test.py` baut `winarmdbgtest.exe`, kopiert es mit dem Server
  auf den ARM-Rechner und startet es dort per ssh (`winarmdbgtest <dir> <work> local`: 18 Prüfungen,
  Entry-Stopp, Schritte, Haltepunkt, Ausgabe, Exit-Codes).

### Geändert
- `asmodbg` und `asmodbg64` sehen vor dem Start in das Feld Machine des Programms und sagen, was nicht
  stimmt: „this is an ARM64 program: use asmodbg64“, „this is a 32-bit ARM program: use asmodbg“;
  x86-/x64-Programme werden abgelehnt, eine fehlende Datei und eine Datei ohne PE-Format haben je einen
  eigenen Text (vorher „cannot start the program (error 50)“, oder das Programm lief ohne Halt
  durch). Dismonite zeigt den Text als „The program did not start: ...“.

## 0.3.0 – 2026-10-12

### Neu
- `qemu\install_qemu.bat`: `run_freedos.bat` und `run_buster.bat` rufen es auf, wenn QEMU fehlt.
  Auf x64-Windows installiert es wie bisher das getestete QEMU (9.2.0) mit winget, jetzt ohne
  Rückfragen; auf Windows on ARM, wo winget kein ARM64-QEMU hat und dessen x64-Version nicht läuft
  (Windows 10 on ARM emuliert nur 32-Bit-x86), lädt es die neueste native ARM64-Version von
  qemu.weilnetz.de/aarch64, prüft sie gegen ihre `.sha512`-Datei und installiert sie ohne
  Rückfragen nach `C:\Program Files\qemu`. Anderes Windows (32 Bit): ein Hinweis, keine
  Installation. Getestet auf Windows 10 on ARM (QEMU 11.1.0).
- Windows on ARM ohne 32-Bit-ARM (Windows 11 24H2 und neuer, kein `SysArm32`): Der Ein-Zeilen-
  Installer von asmodbg und das ssh-Ziel von Dismonite sagen das deutlich, statt eines Servers,
  der nicht startet.
- „Search LAN“ im Dialog „Debug-Ziel Windows on ARM“: Dismonite fragt das lokale Netz (UDP-
  Broadcast an den Port), welche `asmodbg --listen` es gibt, und trägt Adresse und Port der
  Antwort ein (mehrere: eine Liste zur Auswahl). Der Server beantwortet nur diese eine Anfrage,
  mit Version, Port und Rechnername, nie mit dem Code; `--no-discover` schaltet es ab. Die
  Firewall des ARM-Rechners muss UDP 23457 durchlassen (eine `netsh`-Regel von Hand braucht eine
  zweite Zeile mit `protocol=UDP`).
- Thumb-Assembler `asm_thumb.pas` (der erste Teil des ARM-Assemblers): die Tabellen des
  Thumb-Disassemblers rückwärts. Ein Text, wie der Disassembler ihn schreibt (dazu Großschreibung,
  Dezimalzahlen, `sb sl fp ip`, Bereiche in Registerlisten, `cs`/`cc`), wird gegen die Operanden-Vorlage
  jeder Zeile mit der Mnemonik gehalten, die Platzhalter geben die Bits ihrer Felder zurück, und der Code
  wird zur Kontrolle wieder disassembliert. 16 Bit vor 32 Bit wie GAS (`add.w` lang, `add` nur dann
  lang, wenn keine kurze Form passt); IT-Blöcke wie der Disassembler. Testteil `thumbasmtest`: alle
  16-Bit-Codes, die 586 32-Bit-Wörter und 6 Folgen von `thumbtest`, Zufallscodes jeder Zeile; alles
  kommt zurück, Alias-Codierungen (Don't-care-Bits, `cmp r0, r0` in der High-Register-Form) werden
  getrennt gezählt.
- `.arch thumb` in Asmonite: Dahinter ist jede Zeile, die keine Daten- oder Steuerdirektive ist, ein
  Thumb-Befehl für `asm_thumb`; ein Label braucht seinen Doppelpunkt; Sprungziele dürfen Labels sein
  (`b loop`, `bl func`, `cbz r0, done`), aufgelöst über die zwei Durchgänge des Assemblers; die Adresse
  eines Befehls ist `.imagebase` plus die RVA der `section`-Zeilen. Der Export von Dismonite schreibt
  PE-Programme für Windows on ARM mit `.arch thumb` und ihren Code als Befehle: Jede Zeile wird vorher
  an ihrer Adresse mit ihrem IT-Zustand assembliert und muss die Bytes der Datei ergeben, sonst bleibt
  sie `db` mit dem Befehl als Kommentar (Alias-Codierungen); die Prüfung der ganzen Datei mit dem
  Assembler läuft wie bei x86. `exptest` übersetzt den Export der beiden `tests\pe_arm`-Programme zurück.
- Der Editor von Asmonite färbt die Zeilen nach `.arch thumb` als ARM/Thumb (Register `r0`..`pc`,
  `s0`..`d31`, Befehle mit Bedingung und `.w`, `#`-Konstanten, `@`-Kommentare) und die Zeilen nach
  `.arch i386` oder `.arch x86_real` wieder als x86: Der Prozessor ist der Zeilenzustand, den der
  Editor von Zeile zu Zeile weiterreicht, genau wie im Assembler; die Farben folgen also jeder
  Änderung sofort und brauchen weder Dateiendung noch Raten. Der Menüeintrag „Assembler (x86)“
  unter Syntax heißt jetzt „Assembler“.
- Befehlsinfo (F1) für importierte Funktionen: Eine Zeile, die einen Import benutzt (`call [ExitProcess]`,
  `jmp [X]`, der Eintrag der Importtabelle, sein Label, Thumb `ldr r3, =ExitProcess`), zeigt unter dem
  Befehl die Funktion aus der neuen Datei `help\de\winapi.md`: DLL, Aufrufkonvention, Anzahl und Bytes
  der Parameter, der Aufruf in C-Reihenfolge, jeder Parameter mit Typ und Bedeutung, das Ergebnis, eine
  kurze Erklärung und bei den häufigen ein Beispiel. 205 Abschnitte (A- und W-Form zusammen) für
  kernel32, user32, gdi32, comdlg32, advapi32, shell32, oleaut32, msvcrt und die `api-ms-win-crt-*`-Teile
  der universellen C-Laufzeit: alle Importe der Programme im Repository und die üblichen daneben. Eine
  Funktion ohne Abschnitt zeigt Name und DLL und dass es noch keinen Abschnitt gibt. Geprüft gegen
  `dcc32.exe` (Delphi-Compiler), das Delphi-Programm `asmoc.exe`, das clang-Programm und die Beispiele:
  33 Abschnitte mehr für das, was `dcc32.exe` importiert und noch fehlte (Ressourcen, Laufwerke, Umgebung,
  Zeitzone, Konsolen-Steuerung, GUIDs, ...), jetzt 238 Abschnitte.
- Befehlsinfo (F1) im Editor von Asmonite: Die Zeile des Cursors wird in einem neuen Reiter „Help“ in der Spalte
  rechts neben den Registern erklärt, aus denselben Hilfedateien wie in Dismonite (x86 oder, nach
  `.arch thumb`, `arm.md`; importierte Funktionen aus `winapi.md`: jeder Name der Zeile, der einen Abschnitt
  hat, z. B. `call [ExitProcess]`). Der Text ändert sich auf F1; *Help > Help
  language* schaltet Deutsch/English um (`Asmonite.ini`, `[Help] Language`). Der Hilfe-Code zog von
  `DisHelp.pas` in die gemeinsame Unit `src/HelpText.pas` (Hilfebücher, Markdown nach RTF); `DisHelp` behält,
  was die Zeilen des Disassemblers braucht.
- Asmonite: Ein Quelltext ohne `.format` und ohne `.arch` (und ohne `org`, `section`, `segment`, `codeend`)
  wird als `.arch i386` + `.format pe console` übersetzt: Schon die eine Zeile `mov eax, 1` ergibt ein
  32-Bit-Windows-Programm (das Ausgabefenster sagt es). Was `.arch` oder `.format` nennt oder `org`/`section`
  setzt, bleibt unverändert (DOS-`.COM`, Bootsektoren, von Hand geschriebenes PE, Thumb). Die Regel ist die
  Eigenschaft `DefaultPe` von `TAsmoAssembler` / `TAsmFormatter`, nur Asmonite schaltet sie ein; asmoc und
  die Tests des Kerns übersetzen den Text wie er steht. Für Windows auf ARM folgt der Standard noch.
- Asmonite: Die Hilfe ändert sich nur noch auf F1 (sie folgt weder dem Cursor noch dem Text); F1 erklärt
  auch die Direktiven: neue `help\de\directives.md` / `help\en\directives.md` mit `.arch`, `.format`,
  `.code`/`.data`, `.import`, `.entry`, `.imagebase`, `du`, `rel32`, `codeend`, `section`, `segment`.
- Beispiele für DOS in Assembler: `examples\dos\hello.com.asm` („Hello, World!“ als .COM-Programm, ohne
  Header, `section 0x100`) und `examples\dos\hello_exe.asm` (als .EXE mit von Hand geschriebenem Header,
  ein Segment); beide laufen mit F9 in QEMU mit FreeDOS. Die Kommentare erklären den Unterschied .COM / .EXE.
- Asmonite: Die Hilfe steht in der rechten Spalte neben der Registerliste (Reiter Registers und Help, wie
  bei Dismonite), nicht mehr unter dem Editor; die Schaltfläche x schließt sie, F1 zeigt sie wieder.
- F1 erklärt Fehlermeldungen: auf einer Zeile des Ausgabefensters oder im Editor auf der als fehlerhaft
  markierten Zeile zeigt die Hilfe, was die Meldung des Assemblers oder der PE-Prüfung bedeutet, die
  üblichen Ursachen und eine Lösung (`help\de\errors.md`, `help\en\errors.md`, 32 Abschnitte). Die
  Hilfe folgt einem Klick oder einer Cursortaste im Ausgabefenster.
- Befehlsinfo (F1) für DOS- und BIOS-Interrupts, in Dismonite und Asmonite: Zu einem `int` steht unter dem
  Befehl die Funktion, die er aufruft, aus der neuen Datei `help\de\dos.md` / `help\en\dos.md` (je 154
  Abschnitte): `int 21h` (rund 70 Funktionen: Zeichen, Dateien, Verzeichnisse, Speicher, Programme, Vektoren,
  Zeit), `int 10h` Video, `int 13h` Laufwerke (CHS und LBA), `int 16h` Tastatur, `int 1Ah` Uhr, `int 33h`
  Maus, `int 2Fh`, `int 15h`, `int 14h`, `int 17h`, `int 20h`, `25h`, `26h`, `27h`, `29h`, `11h`, `12h`,
  `24h`, `28h`. Die Funktionsnummer wird in den Befehlen vor dem `int` gefunden (`mov ah, 0x09`,
  `mov ax, 0x4C00`, `xor ah, ah`, `mov al, ...`; über Labels hinweg, bis zu einem Sprung, Aufruf, Rücksprung
  oder einem anderen `int`; ein Befehl, der `ah` anders ändert, gibt auf). Ist sie nicht bekannt, steht die
  Übersicht des Interrupts mit der Liste seiner Funktionen da. Jeder Abschnitt hat Eingabe- und
  Ausgaberegister (mit Carry-Flag und Fehlercodes) und oft ein Beispiel. Bei `int 21h` in `TPC.EXE` und
  `HELLO.EXE` finden 23 von 24 den Abschnitt ihrer Funktion. Die Mausfunktionen wählt `ax`, nicht `ah`.
- Hilfetexte auf Englisch: `help\en\x86.md`, `arm.md` und `winapi.md` sind die Übersetzungen der deutschen
  Dateien mit denselben Abschnitten unter denselben Namen (ein Test vergleicht sie). Dismonite: *Help > Help
  language* schaltet sofort zwischen Deutsch und English um; die Wahl steht in `Dismonite.ini`
  (`[Info] Language=de|en`); ohne Wahl bekommt ein deutsches Windows Deutsch und jedes andere English; fehlt
  die Datei einer Sprache, gilt Deutsch.

### Geändert
- Asmonite: Die Registerliste rechts erscheint nur, solange ein Programm debuggt wird (läuft oder hält an;
  *View > Registers* entscheidet weiter, ob sie gezeigt werden darf); ein Assembler-Fehler zeigt den Reiter
  Output (auch wenn der Reiter Help oder Stack gezeigt wurde oder der Ausgabebereich verborgen war); jede
  neue Zeile in der Ausgabe scrollt sie ans Ende.
- Sprache der Hilfetexte: English, außer die Oberflächensprache von Windows ist Deutsch (vorher: die
  Einstellung für regionale Formate).

### Behoben
- `asmodbg.exe` per Doppelklick (ohne Argumente) gestartet zeigte nur seine Aufrufhilfe und endete,
  obwohl die Readme das Fenster versprach; ohne Argumente läuft es jetzt wie `--listen`.
- Dismonite, Windows on ARM über ssh: Der Tunnel benutzte auch auf diesem Rechner den Port 23456
  und scheiterte, wenn der belegt war; jetzt nimmt er hier einen freien Port (asmodbg auf dem
  ARM-Rechner bleibt bei 23456).

## 0.2.0 – 2026-10-11

### Neu
- Dismonite debuggt 32-Bit-Programme für Windows on ARM (PE, Machine 0x1C4) auf einem echten
  Windows-on-ARM-Rechner, wie ARM-Linux-Programme im QEMU-Gast: Halt am Einsprungpunkt,
  Haltepunkte, Einzelschritt, Step over, Run to cursor, Pause, Stopp, Register, Speicher,
  Programmausgabe, Exit-Code, Exceptions. Neuer Server `asmodbg.exe` (C, ARM32/Thumb-2, mit
  llvm-mingw durch `src/armserver/build.bat` gebaut): Er führt das Programm mit der Win32-Debug-API
  aus und spricht das GDB-Protokoll wie gdbserver; deshalb dient der ARM-Debugger von Dismonite
  (`TArmGdbDebugger`, neu mit dem Ziel `atWinArm`) fast unverändert. Dismonite kopiert das
  Programm (und den Server, wenn seine Version abweicht) per scp, startet den Server per ssh und
  verbindet sich über einen ssh-Tunnel (`-L`): keine Firewall-Regel auf dem ARM-Rechner. Host
  (Vorgabe `winarm`) und Ordner (Vorgabe `asmodbg`, relativ zum Home-Ordner) stehen in
  Dismonite.ini unter `[WinArm]` als `Host=` und `Dir=`. Einzelschritte nutzen das SS-Bit im
  CPSR (per Experiment gefunden: Windows on ARM32 unterstützt es, der Server braucht keinen
  Befehlsdecoder). Tests: `tools/asmodbg_test.py` (Server allein, 27 Prüfungen) und Testteil
  `winarmdbgtest`. `asmodbg --listen` (Server `asmodbg-3`, erster Schritt der Direktverbindung
  ohne ssh): der Server bleibt offen und bedient die Sitzungen nacheinander; eine Sitzung lädt das
  Programm in einen eigenen Ordner hoch (`vFile`), startet es nur von dort (`vRun`) und bekommt
  die Programmausgabe als `O`-Pakete. Nur schlichte Dateinamen. Der Listen-Modus verlangt eine
  Anmeldung: ein 12-stelliger Code (vom Server erzeugt, mit DPAPI neben der EXE gespeichert,
  `asmodbg --show-code` zeigt ihn), Challenge-Response mit HMAC-SHA256 (Windows CNG) in beide
  Richtungen, danach ein MAC an jedem Paket (Integrität, keine Verschlüsselung); vorher wird
  nichts beantwortet, 3 falsche Beweise sperren den Server 10 s. Er lauscht auf allen Adressen
  (Port 23457); winarm braucht eine Firewall-Regel. Der Listen-Modus zeigt ein kleines Fenster
  (Version, ARM32-Prüfung, IP-Adressen, Port, Code, Status, Warnung bei Administratorrechten;
  `--port N`, `--no-window`, `--info`). `asmodbg_test.py` hat jetzt 77 Prüfungen,
  auch die Direktverbindung ohne ssh.
- Dismonite verbindet sich direkt mit `asmodbg --listen` (ohne ssh zum Debuggen): Anmeldung mit
  dem Code (HMAC-SHA256 über die Windows-CryptoAPI), Versionsprüfung, Upload mit `vFile`, Start
  mit `vRun`, Programmausgabe aus den `O`-Paketen. Neu: *Debug → Debug target Windows on ARM…*
  (Direkt oder ssh, Host, Port, Code, Ordner, „Test connection“ mit klaren Fehlermeldungen); der
  Dialog öffnet sich selbst beim ersten Start eines Windows-on-ARM-Programms. ini `[WinArm]`
  `Mode`, `Port`, `Code` (mit DPAPI geschützt). `winarmdbgtest` führt alle Tests auch direkt aus
  (39 Prüfungen). `asmodbg.exe` liegt im Release-ZIP unter `armserver\`; die Einrichtung auf
  frischen Rechnern (Server starten, Firewall, Dialog) steht in der README des ZIPs.
  Einzeiler für den ARM-Rechner: `powershell -NoProfile -Command "irm
  https://asmonite.com/downloads/install-asmodbg.ps1 | iex"` (`tools/install-asmodbg.ps1`, von
  `tools/release.py` mit `asmodbg.exe` nach `html/downloads/` gelegt, Prüfsumme der EXE im Skript;
  läuft nicht als Administrator, ersetzt einen älteren Server und startet ihn). Der Dialog zeigt
  die Zeile mit der Schaltfläche „Copy the line“.
- Dismonite: Der Debugger zeigt Stack, Speicher und die Ausgabe des Programms, alles zugleich mit
  den Registern: Register und Stack rechts neben dem Code, Speicher und Ausgabe darunter. Der
  Stack: 32 Einträge ab dem Stackzeiger, mit dem Label, auf das ein Wert zeigt (Doppelklick springt
  hin). Der Speicher: 16 Zeilen ab einer Adresse, einem Label, einem Register oder (DOS)
  Segment:Offset; geänderte Werte sind rot. Die Ausgabe: was das Programm in diesem Lauf
  geschrieben hat (Windows: seine Konsole, DOS: der Bildschirm, ARM: stdout). Jede Anzeige lässt
  sich im Debug-Menü abschalten; sie erscheinen mit der ersten Debug-Sitzung.
- Dismonite liest 32-Bit-Programme für Windows on ARM (Machine 0x1C4): Header, Imports und
  Exporte wie bei i386, den Einsprungpunkt ohne das Thumb-Bit (Label `start` bei 0x401000 für
  `AddressOfEntryPoint` 0x1001) und den Thumb-2-Code: Die Analyse folgt ihm ab Einsprungpunkt und
  Exporten, IT-Blöcke erscheinen mit ihren Bedingungen, `adr`/`ldr [pc]` bekommen den Import oder
  das Label, auf das sie zeigen, als Hinweis. Der Export schreibt Thumb-Code als Bytes mit dem
  Befehl als Kommentar und ergibt so wieder dieselbe Datei. Gleitkommabefehle (VFP: `vldr`, `vmov`,
  `vadd.f64`, `vpush`, `vmrs`, ...) dekodiert es, NEON-Befehle noch nicht. Neuer tabellengetriebener
  Decoder `dis_thumb` (alle 16-Bit-Codes und die
  Thumb-2-Befehle so, wie capstone sie schreibt; `tools/thumb_check.py`, Testteil `thumbtest`).
- Dismonite: ARM-Linux-Programme dürfen ARM- und Thumb-Code mischen (wie GCC sie erzeugt): jede Stelle
  hat ihre Art (neue Art „thumb“, Taste T). Die Analyse folgt dem Einsprungpunkt und den Funktionen der
  Symboltabellen in ihrer Art (Bit 0), wechselt sie bei blx und nutzt die Mapping-Symbole ($a, $t, $d)
  und .plt; der Debugger erkennt Thumb-Code am T-Bit (Haltepunkte, Step Over). ARM-Programme lassen
  sich jetzt als .asm exportieren (Code als Bytes mit dem Befehl als Kommentar). Neues Testprogramm
  hallo-thumb.
- Dismonite: ARM- und Thumb-Code hat eigene Farben: Register r0..pc, s0..s31, d0..d31, Zahlen nach #,
  Befehle auch mit Bedingung (addeq, vmoveq.f64).
- Dismonite: Befehlsinfo (F1): rechts der Befehl der aktuellen Zeile erklärt (Syntax, Flags, ein
  Beispiel), aus der Hilfedatei `help\de\x86.md` (vorerst Deutsch); sie folgt dem Cursor (Help > Info
  follows the cursor). Beim Debuggen ist sie ein zweiter Reiter neben den Registern. Alle Befehle, die
  der Disassembler dekodiert (x87: ein Abschnitt); ARM und Thumb in `help\de\arm.md` (`addeq`, `bne`,
  `vmoveq.f64` finden ihren Befehl und zeigen die Bedingung dazu).
- Dismonite: Nullbytes vor einer Struktur sind ebenfalls eine Zeile (`org`/`align`), nicht nur vor dem
  PE-Header, einer Section und am Dateiende: z. B. bis `e_lfanew` bei einem DOS-Header ohne Stub oder
  zwischen dem Code und den Imports derselben Section.
- Release-ZIP: `examples\winarm\pe_arm32_hello_world.exe` (mit ihrer `.asm`), ein Programm für
  Windows on ARM zum Ausprobieren des ARM-Debuggers von Dismonite mit asmodbg.

### Behoben
- Dismonite: Datei > Öffnen versprach Programme ohne Endung (ARM-Linux) unter „Programs", aber der
  Dialog des heutigen Windows findet mit dem Filter `*.` keine. Sie stehen jetzt unter „All files (also
  programs without extension)", und Dismonite merkt sich den zuletzt gewählten Dateityp
  (`Dismonite.ini`).
- Dismonite: Der letzte Befehl einer Section wurde nicht als Code erkannt, wenn er mit dem Byte 00
  einer Adresse endete (`call [ExitProcess]` am Ende von `demo.exe`).
- Dismonite: Die Registerliste behielt nach dem Öffnen einer anderen Datei die Werte der letzten
  Debug-Sitzung; ihre Kopfzeile zeigte „Regi…“ statt „Register“.
- Dismonite: Die letzte Zeile, die ein Programm schrieb, wurde sofort durch „Program exited with
  code 0“ ersetzt (ARM-Programme schreiben ihre Ausgabe erst am Ende); die Ausgabe-Anzeige behält
  alle Zeilen.
- Das DOS-Beispiel `HELLO.EXE` passte nicht zu seinem Quelltext `HELLO.PAS` (ein älteres, mit
  Turbo Pascal 6 übersetztes Programm). Beide liegen jetzt in `examples/dos`: `HELLO.PAS` zählt
  hoch, `HELLO.EXE` ist ihre Übersetzung mit Turbo Pascal 7, von den Tests geprüft.

## 0.1.0 – 2026-10-09 (Testpaket, Git-Tag v0.1.0)

Die erste Version.

### Asmonite (Editor, Assembler, Debugger)
- Editor mit Syntax-Hervorhebung für x86-Assembler, C und Pascal; Rückgängig/Wiederholen,
  Suchen und Ersetzen (Strg+F, F3, Strg+H), Gehe zu Zeile (Strg+G).
- Assembler für den i386: `.format pe` (Header und Importtabelle werden erzeugt) oder jedes
  Byte im Quelltext; Labels, `.imagebase`, `org`, `align`, `rva`.
- Prüfung der erzeugten PE-Datei vor dem Start (Header, Sections, Importe).
- Win32-Debugger: Haltepunkte (sie wirken auch, während das Programm läuft), Step Over/Into,
  Run to Cursor, Pause, Ausführungsstelle zeigen;
  Register, Stack und Speicher; die Ausgabe des Programms im Ausgabefenster.
- DOS-Programme in QEMU mit FreeDOS (nicht mitgeliefert: `qemu\run_freedos.bat` lädt die
  FreeDOS-Diskette und bietet die Installation von QEMU an); dasselbe Programm startet im
  laufenden QEMU erneut.

### Dismonite (Disassembler und Debugger)
- Windows- (PE), DOS- (MZ) und ARM-Linux-Programme (ELF); die Strukturen des Dateiformats
  (Header, Sections, Importe, Exporte, ELF-Program-Header und -Symbole) mit den Namen
  ihrer Felder.
- Analyse ab Einsprungpunkt, Exporten und Relokationszielen.
- Labels statt Adressen; Strg+Klick springt zum Ziel, Alt+Links zurück.
- Markierungen und Kommentare werden in `<programm>.dmon` gespeichert.
- Export als `.asm` mit Labels, den der Asmonite-Assembler wieder zur selben Datei übersetzt.
- Debugger: Haltepunkte, Step Over/Into, Run to Cursor, Pause, Register; Parameter für das
  Programm (Debug > Parameters, in der `.dmon` gespeichert). Wo das Programm anhält, wird Code.
  Windows-Programme direkt, DOS-Programme in QEMU mit FreeDOS, ARM-Linux-Programme über
  gdbserver in Raspberry Pi OS unter QEMU (Dismonite startet den Gast auf Wunsch).

### QEMU-Gäste (Ordner qemu)
- `run_freedos.bat`: FreeDOS; lädt die Bootdiskette (720 KB).
- `run_buster.bat`: Raspberry Pi OS (ARM) zum Debuggen von ARM-Programmen; lädt etwa 440 MB
  und richtet den Gast ein (ssh, gdbserver, Tastatur wie in Windows).
- Beide bieten an, QEMU mit winget zu installieren; `-h` zeigt die Optionen.

### asmoc
- Der Assembler auf der Kommandozeile.

### Bekannte Grenzen
- Keine x87-Gleitkommabefehle im Assembler; der Disassembler zeigt sie ohne Namen.
- Die Unterschiede zu NASM stehen in docs/de/nasm-unterschiede.md.
