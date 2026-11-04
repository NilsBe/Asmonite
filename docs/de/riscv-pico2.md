# Der Raspberry Pi Pico und Pico 2 mit Asmonite

Wie du ein Programm in RISC-V- oder Arm-Assembler schreibst, auf einem Raspberry Pi Pico oder Pico 2 laufen lässt und ansiehst, während es läuft. Du brauchst kein anderes Werkzeug: Asmonite assembliert das Programm, schreibt es über die Debug-Probe auf das Board und lässt dich Schritt für Schritt hindurchgehen. Die Befehlsreferenz ist die F1-Hilfe von Asmonite (`help\de\riscv.md`). Zuerst kommt der Pico (RP2040); der größere Teil handelt dann vom Pico 2 (RP2350) und seinen RISC-V-Kernen, und die Schritte unter [Laufen lassen und Debuggen](#laufen-lassen-und-debuggen) sind für beide Boards dieselben.

## Was du brauchst

- einen **Raspberry Pi Pico** oder einen **Raspberry Pi Pico 2** (nicht die W-Modelle: dort sitzt die LED am Funkchip)
- eine **Debug-Probe** mit CMSIS-DAP: die Raspberry Pi Debug Probe oder ein zweiter Pico mit der Firmware `debugprobe`. Drei Drähte gehen an die Debug-Pins des Boards (SWCLK, GND, SWDIO); das Board bekommt seinen Strom über sein eigenes USB-Kabel.
- Windows mit Asmonite. Die Probe braucht keinen Treiber; Windows nimmt sie als WinUSB-Gerät.

Nur ein Programm kann die Probe zur Zeit benutzen: Läuft OpenOCD oder ein anderer Debugger, schließe ihn (oder wähle OpenOCD unter *Debug > Debug targets*, als Ausweichweg für die RISC-V-Kerne).

## Der Raspberry Pi Pico (RP2040)

Der erste Pico hat einen RP2040 mit zwei Arm Cortex-M0+ und ohne RISC-V. Asmonite debuggt seinen Kern 0 über dieselbe Probe und dieselben drei Drähte. Die Beispiele liegen in `examples\pico\`: `blink_ram.asm` (im RAM) und `blink_flash.asm` (im Flash; es startet nach dem Aus- und Einschalten von selbst).

```asm
.target pico            ; für den Raspberry Pi Pico (RP2040)
.arch thumb
.imagebase 0x10000000   ; der Flash
    .boot2              ; der boot2-Block des Pico-SDK
vectors:
    dd 0x20042000       ; Vektortabelle bei 0x10000100: Stackzeiger
    dd _start + 1       ; und Startadresse (+1: Thumb-Code)
_start:
    ...
```

| Was | Adresse |
|---|---|
| Flash (2 MB) | `0x10000000` |
| RAM (264 KB) | `0x20000000` bis `0x20041FFF` |
| Peripherie, SIO | `0x40000000`, `0xD0000000` (dieselben wie beim Pico 2) |

Was ihn ausmacht (der Pico 2 folgt weiter unten):

- **Weniger Befehle.** Der Cortex-M0+ kennt das ARMv6-M: Thumb mit den 16-Bit-Befehlen, von den 32-Bit-Befehlen nur `bl`, `msr`, `mrs` und die Barrieren. Es gibt kein `movw`/`movt`, kein `cbz`, `cbnz`, `it`; die meisten Befehle arbeiten nur mit `r0` bis `r7`. Eine Konstante mit 32 Bit kommt aus einem Wort hinter dem Code (`ldr r0, marke`). Mit `.target pico` meldet der Assembler jeden anderen Befehl als Fehler mit seiner Zeile.
- **boot2 statt IMAGE_DEF.** Das Boot-ROM des RP2040 startet ein Flash-Programm nur, wenn seine ersten 256 Bytes ein kleines Programm sind, das den Flash-Chip einrichtet, mit seiner CRC-32 am Ende. **`.boot2`** setzt den Block des Pico-SDK dorthin (die Datei `boot2\boot2_w25q080.bin` oder dieselben Bytes, die Asmonite eingebaut hat); `.boot2 datei.bin` nimmt einen eigenen Block (252 Bytes: die CRC wird angehängt; 256 Bytes: sie wird geprüft). Die Vektortabelle folgt bei `0x10000100`.
- **Die Pads sind nach einem Reset nicht isoliert**: Das Programm braucht kein `ISO`-Bit.
- **Breakpoints:** 4 Hardware-Breakpoints, nur im Flash; im RAM schreibt der Debugger stattdessen `bkpt`-Befehle, die die Speicheransicht nicht zeigt.
- *Debug > Debug targets > Raspberry Pi Pico (RP2040)* und *Test the connection*, dann F7 wie unter [Laufen lassen und Debuggen](#laufen-lassen-und-debuggen); *Save as UF2 file* schreibt die Familie des RP2040.

Ein Programm für den Pico an einem Pico 2 (oder umgekehrt) wird mit dem Namen des Boards abgelehnt, bevor etwas geschrieben wird. Antworten die Kerne des RP2040 nach so einem Versuch nicht mehr, setzt Asmonite sie über den Rescue-Port des Chips zurück.

## Der Pico 2 (RP2350) in Kürze

Der RP2350 auf dem Pico 2 hat zwei Prozessoren von zwei Sorten: zwei Arm Cortex-M33 und zwei RISC-V-Kerne (Hazard3). Beim Start wählt das Boot-ROM nach dem Programm im Flash, welches Paar läuft. Asmonite schreibt Programme für beide: für die RISC-V-Kerne (`.arch riscv32`, RV32IMAC mit den Bit-Manipulations-Erweiterungen) und für die Arm-Kerne (`.arch thumb`, siehe [Die Arm-Kerne](#die-arm-kerne)); es benutzt jeweils Kern 0.

| Was | Adresse |
|---|---|
| Boot-ROM | `0x00000000` |
| Flash (4 MB, gelesen über den XIP-Cache) | `0x10000000` |
| RAM (520 KB) | `0x20000000` bis `0x20081FFF` |
| Peripherie (UART, GPIO, Timer, ...) | `0x40000000` |
| SIO (schnelles GPIO, Spinlocks) | `0xD0000000` |

Peripherie sind Register an festen Adressen: Du steuerst sie mit `lw` und `sw`. Ihre Adressen stehen im Datenblatt des RP2350. Jedes Register antwortet außerdem an drei weiteren Adressen: +`0x1000` kippt die Bits, die du schreibst (xor), +`0x2000` setzt sie, +`0x3000` löscht sie; so brauchst du kein Lesen-Ändern-Schreiben.

## RISC-V in zehn Minuten

Kennst du x86 oder ARM, sind das die Unterschiede, die zählen:

| | x86 | ARM | RISC-V |
|---|---|---|---|
| Register | 8 (32 Bit) | 16 | 32, `x0` ist immer 0 |
| Flags | ja | ja | **keine**: `beq`, `blt` vergleichen und verzweigen in einem |
| Speicher | viele Befehle | `ldr`/`str` | nur `lw`/`sw` (und `lb`, `lh` ...) |
| Konstante mit 32 Bit | im Befehl | Literal-Pool | `lui` + `addi` (`li` macht es) |
| Aufruf | `call` legt die Adresse auf den Stack | `bl` setzt `lr` | `jal ra, ...` setzt `ra` |
| Rücksprung | `ret` holt sie | `bx lr` | `ret` = `jalr zero, 0(ra)` |
| Stack | `push`, `pop` | `push`, `pop` | keiner: `addi sp, sp, -16` und `sw` |
| Befehlslänge | 1 bis 15 Bytes | 2 oder 4 | 4 (2 bei den kurzen Formen) |

Die F1-Hilfe von Asmonite hat die Themen `riscv`, `registers`, `pseudo` (die Kurznamen des Assemblers: `li`, `mv`, `j`, `ret` ...), `encoding` und `compressed`; lies sie mit dem Cursor in einer beliebigen Zeile eines `.arch riscv32`-Quelltexts.

## Das erste Programm

`examples\pico2\blink_ram.asm` lässt die LED (GPIO 25) blinken. Kurz:

```asm
.target pico2           ; für den Raspberry Pi Pico 2: die Bytes des Programms, keine Windows-Datei
.arch riscv32           ; ab hier RISC-V-Befehle
.imagebase 0x20000000   ; das Programm soll im RAM liegen

_start:
    li   sp, SRAM_END       ; der Stack am Ende des RAM
    ...                     ; Pads und GPIO aus dem Reset holen, Pad 25 auf SIO schalten
blink_loop:
    sw   t1, SIO_GPIO_OUT_XOR(t0)   ; die LED umschalten
    li   t2, DELAY_COUNT
delay:
    addi t2, t2, -1
    bnez t2, delay                  ; herunterzählen: warten
    j    blink_loop
```

`.target pico2` sagt, für welches Gerät das Programm ist. Asmonite prüft es dann nach dem Assemblieren: `.arch riscv32` oder `.arch thumb`, ein `.imagebase` im RAM oder im Flash, ob das Programm hineinpasst, und bei einem Flash-Programm den IMAGE_DEF-Block (siehe unten). Was nicht passt, ist ein Fehler mit der Zeile (F1 erklärt ihn), bevor etwas auf das Board geschrieben wird. Beim Debuggen prüft Asmonite außerdem die Chip-ID: Hängt an der Probe kein RP2350, schreibt es nichts.

Konstanten definierst du mit `name equ wert` (und rechnest mit `+`, `<<`, `|`); eine Marke ist ein Name mit Doppelpunkt. Ein `;` beginnt einen Kommentar. Beachte: Markennamen unterscheiden Groß- und Kleinschreibung nicht, und die Namen von x86-Befehlen (`loop`, `and` ...) können keine Marken sein.

Beim RP2350 ist gegenüber seinem Vorgänger eines neu: Nach einem Reset sind die **Pads isoliert**; das Programm löscht das Bit `ISO` des Pad-Registers (`PADS_BANK0 + 0x68`), sonst bleibt die LED dunkel.

## Laufen lassen und Debuggen

1. *Debug > Debug targets > Raspberry Pi Pico 2*: Wähle **The USB debug probe** und drücke *Test the connection*. Es sollte sagen, dass das Board antwortet (und ob der Kern läuft oder angehalten ist).
2. Öffne das Programm, **F7** (Step into): Asmonite assembliert es, hält den Kern an, schreibt das Programm bei `.imagebase` ins RAM, setzt den pc auf `_start` (oder auf das erste Byte) und hält dort. **F8** geht über einen Aufruf hinweg, **F9** lässt weiterlaufen, **F4** läuft bis zum Cursor, **F5** setzt oder entfernt einen Breakpoint, *Debug > Pause* hält ein laufendes Programm an.
3. Rechts siehst du die Register `x0` bis `x31` (mit ihren Namen) und `pc`; ein Doppelklick ändert einen Wert. Der Stack zeigt die Wörter ab `sp`; wo ein Wert in dein Programm zeigt, nennt die Notiz die Marke und die Zeile (so erkennst du gesicherte Rücksprungadressen). Die Speicheransicht hat einen Umschalter **Bytes / Code**: *Code* listet die Befehle ab der Adresse (voreingestellt `pc`), mit `=>` am nächsten und mit deinen Marken; sie liest auch Code, den du nicht geschrieben hast, mit Befehlen von 2 und 4 Bytes.
4. **Strg+F2** (Stop) beendet die Sitzung; der Kern läuft mit dem Programm weiter.

Das Blink-Programm schreibt nur in die Peripherie: Stack und Speicher bleiben dabei gleich. `examples\pico2\stack_demo.asm` füllt eine Tabelle im RAM und ruft eine Funktion auf, die `ra` und `s0` auf den Stack legt; gib im Speicher `table` als Adresse ein und gehe mit F7 hindurch.

Ein Programm im RAM ist weg, wenn der Strom weg ist. Das RAM-Programm hat keinen IMAGE_DEF-Block; das Boot-ROM würde es nicht von selbst starten.

### Breakpoints

Der Kern hat **4 Hardware-Breakpoints**; jeder Breakpoint im Editor belegt einen (und *Step over* und *Run to cursor* für einen Moment ebenso). Sie halten vor dem Befehl an. Mehr als 4 ergeben eine Meldung. Sie funktionieren auch im Flash, wo Software-Breakpoints nicht geschrieben werden könnten.

## Ein Programm im Flash

Ein Programm mit `.imagebase 0x10000000` wird beim Start in den Flash geschrieben. Das Boot-ROM startet ein Programm aus dem Flash nur, wenn in seinen ersten 4 KB ein kleiner Block steht, der sagt, was das Programm ist (IMAGE_DEF); `examples\pico2\blink_flash.asm` hat ihn:

```asm
image_def:
    dd 0xffffded3            ; Startmarke
    db 0x42, 1               ; Eintrag IMAGE_TYPE, 1 Wort
    dw 0x1101                ; ausführbar | RISC-V | RP2350
    db 0x44, 3               ; Eintrag ENTRY_POINT, 3 Wörter
    dw 0
    dd _start                ; pc beim Start
    dd SRAM_END              ; Stackzeiger beim Start
    db 0xff
    dw 4                     ; die bisherigen Einträge, in Wörtern
    db 0
    dd 0                     ; kein weiterer Block
    dd 0xab123579            ; Endemarke
_start:
    ...
```

- Mit `.target pico2` prüft der Assembler den Block: Er muss in den ersten 4 KB stehen, und sein IMAGE_TYPE muss zu `.arch` passen (`0x1101` RISC-V, `0x1021` Arm).
- **F7 / F9 mit so einem Programm** löscht und schreibt nur die 4-KB-Sektoren, die sich unterscheiden, prüft, was es geschrieben hat, und debuggt es im Flash. Der erste Start eines neuen Programms dauert etwa eine Sekunde; ein unverändertes Programm wird nicht noch einmal geschrieben. Das braucht die USB-Probe; über OpenOCD lässt sich der Flash nicht schreiben.
- **Project > Save as UF2 file** macht eine Datei für das BOOTSEL-Laufwerk: Halte die Taste BOOTSEL gedrückt, während du den Pico 2 einsteckst, und ziehe die Datei auf das Laufwerk, das erscheint. Der Pico startet mit dem Programm neu.

## Die Arm-Kerne

Dasselbe geht mit den Arm-Kernen: `.target pico2` und `.arch thumb` (der Cortex-M33 kennt nur Thumb-Code). `examples\pico2\blink_arm_flash.asm` ist das Blink-Programm für sie. Die Unterschiede zu RISC-V:

- Eine Konstante mit 32 Bit lädt `movw` (untere Hälfte) und `movt` (obere Hälfte) statt `li`.
- Es gibt Flags: `cmp` setzt sie, `bne` verzweigt danach.
- Ein Programm im Flash beginnt mit der **Vektortabelle** des Cortex-M: dem Stackzeiger und der Startadresse (+1: Thumb-Code); dahinter der IMAGE_DEF-Block mit `0x1021` (Arm, Secure) statt `0x1101`.

Debuggen geht wie bei RISC-V (F7, F8, F9, F4, F5) über die USB-Probe (nicht über OpenOCD). Rechts stehen `R0` bis `R12`, `SP`, `LR`, `PC`, `XPSR` und seine Flags `N Z C V`; der Kern hat **8 Hardware-Breakpoints**. Beginnt das Programm mit einer Vektortabelle, setzt der Debugger beim Start den Stackzeiger aus ihr. *Step over* kennt `bl` und `blx`.

**Der Chip läuft immer nur mit einer Sorte von Kernen.** Läuft gerade die andere Sorte, schreibt der Debugger ein Flash-Programm mit ihr in den Flash, setzt den Chip zurück und macht mit den Kernen des Programms weiter (das dauert etwa zwei Sekunden; das Ausgabefenster sagt es). Ein Programm im RAM kann nicht umschalten: Das Boot-ROM startet nach einem Reset die Kerne, für die das Programm im Flash ist. Dann sagt Asmonite, was zu tun ist: zuerst ein Flash-Programm der passenden Sorte starten, zum Beispiel `blink_arm_flash.asm` oder `blink_flash.asm`. *Test the connection* zeigt, welche Kerne gerade laufen.

## Wenn es sich nicht verbindet

*Test the connection* sagt in klaren Worten, warum:

- *No debug probe ... only one program at a time*: Ein anderes Programm hat die Probe (OpenOCD, eine andere Asmonite-Instanz). Schließe es.
- *The board does not answer over SWD*: Das Board hat keinen Strom, die drei Drähte sind falsch oder lose, oder die Probe ist nicht die Debug Probe. Die Drähte: SWCLK, SWDIO, GND.
- Mit **OpenOCD** gewählt: Starte OpenOCD zuerst; der Host ist `127.0.0.1` und der Port `3333`.
- *The board is an RP2040 ...* (oder *not an RP2350*, *no RP2040*): An der Probe hängt nicht das Board von `.target`. Asmonite hat nichts geschrieben; wähle den passenden Eintrag unter *Debug targets* oder das passende `.target`.
- *Cannot write the program ... the board needs the program in RAM*: Das Programm hat ein `.imagebase`, das weder RAM (`0x20000000`) noch Flash (`0x10000000`) ist.

## Was es (noch) nicht gibt

- Der Assembler schreibt nur Befehle mit 4 Bytes. Die kurzen Befehle (`c.addi` ...) werden gelesen und angezeigt, nicht geschrieben.
- Kein Gleitkomma, und die atomaren Befehle `lr.w`/`amo*` gibt es nur auf der Assemblerseite (der Assembler schreibt sie, der Kern führt sie aus).
- Nur Kern 0; kein zweiter Kern, kein Mehrkern-Debuggen.
- Die W-Modelle (Pico W, Pico 2 W): Ihre LED hängt am Funkchip, den die Beispiele nicht ansteuern.
- Variablen eines C- oder Pascal-Programms werden nicht angezeigt: Der Debugger arbeitet mit Assembler-Quelltext.

## Zum Weiterlesen

- Die RISC-V-Spezifikation (unprivilegiert und privilegiert): riscv.org/specifications
- Datenblatt des RP2350 (die Speicher-Map, die Peripherie, das Boot-ROM): datasheets.raspberrypi.com
- Dokumentation des Hazard3 (der Kern: Befehle, Debug-Modul, CSRs): github.com/Wren6991/Hazard3
