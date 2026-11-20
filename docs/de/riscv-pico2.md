# Der Raspberry Pi Pico und Pico 2 mit Asmonite

Wie du ein Programm in RISC-V- oder Arm-Assembler schreibst, auf einem Raspberry Pi Pico oder Pico 2 laufen lässt und ansiehst, während es läuft. Du brauchst kein anderes Werkzeug: Asmonite assembliert das Programm, schreibt es über die Debug-Probe auf das Board und lässt dich Schritt für Schritt hindurchgehen. Die Befehlsreferenz ist die F1-Hilfe von Asmonite (`help\de\riscv.md`). Zuerst kommt der Pico (RP2040); der größere Teil handelt dann vom Pico 2 (RP2350) und seinen RISC-V-Kernen, und die Schritte unter [Laufen lassen und Debuggen](#laufen-lassen-und-debuggen) sind für beide Boards dieselben.

## Was du brauchst

- einen **Raspberry Pi Pico** oder einen **Raspberry Pi Pico 2** (nicht die W-Modelle: dort sitzt die LED am Funkchip)
- eine **Debug-Probe** mit CMSIS-DAP: die Raspberry Pi Debug Probe oder ein zweiter Pico mit der Firmware `debugprobe`. Drei Drähte gehen an die Debug-Pins des Boards (SWCLK, GND, SWDIO); das Board bekommt seinen Strom über sein eigenes USB-Kabel.
- Windows mit Asmonite. Die Probe braucht keinen Treiber; Windows nimmt sie als WinUSB-Gerät.

Nur ein Programm kann die Probe zur Zeit benutzen: Läuft OpenOCD oder ein anderer Debugger, schließe ihn (oder wähle OpenOCD unter *Debug > Debug targets*, als Ausweichweg für die RISC-V-Kerne).

## Der Raspberry Pi Pico (RP2040)

Der erste Pico hat einen RP2040 mit zwei Arm Cortex-M0+ und ohne RISC-V. Asmonite debuggt seinen Kern 0 über dieselbe Probe und dieselben drei Drähte. Die Beispiele liegen in `examples\pico\`: `blink_ram.asm` (im RAM) und `blink_flash.asm` (im Flash; es startet nach dem Aus- und Einschalten von selbst).

**Ohne Probe:** Der Pico lässt sich auch mit seinem USB-Kabel allein debuggen, über seinen USB-Boot (BOOTSEL): ein Programm im RAM, mit Breakpoints und Schritten, ohne Pause. Das steht in [picoboot.md](picoboot.md). Der Pico 2 kann das nicht (sein USB-Boot hat keinen Befehl, mit dem ein Debugger laufen könnte): Er braucht die Probe.

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

Der RP2350 auf dem Pico 2 hat zwei Prozessoren von zwei Sorten: zwei Arm Cortex-M33 und zwei RISC-V-Kerne (Hazard3). Beim Start wählt das Boot-ROM nach dem Programm im Flash, welches Paar läuft. Asmonite schreibt Programme für beide: für die RISC-V-Kerne (`.arch riscv32`, RV32IMAC mit den Bit-Manipulations-Erweiterungen) und für die Arm-Kerne (`.arch thumb`, siehe [Die Arm-Kerne](#die-arm-kerne)); es benutzt jeweils Kern 0. Umschalten ohne eigenes Programm:
**RISC-V Cores** bzw. **Arm Cores** im Board Manager (Menü Board) schreibt das Beispiel `blink` der anderen Kerne in
den Flash.

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
Mit `.option rvc` schreibt der Assembler die 2-Byte-Formen, wo sie passen (etwa ein Fünftel weniger Code; die
Hazard3-Kerne haben C): siehe das Thema `compressed`.

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

Ein Programm mit `.imagebase 0x10000000` wird beim Start in den Flash geschrieben. Das Boot-ROM startet ein Programm aus dem Flash nur, wenn in seinen ersten 4 KB ein kleiner Block steht, der sagt, was das Programm ist (IMAGE_DEF); `boards\pico2\blink_flash.asm` hat ihn:

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

Dasselbe geht mit den Arm-Kernen: `.target pico2` und `.arch thumb` (der Cortex-M33 kennt nur Thumb-Code). `boards\pico2\blink_arm_flash.asm` ist das Blink-Programm für sie. Die Unterschiede zu RISC-V:

- Eine Konstante mit 32 Bit lädt `movw` (untere Hälfte) und `movt` (obere Hälfte) statt `li`.
- Es gibt Flags: `cmp` setzt sie, `bne` verzweigt danach.
- Ein Programm im Flash beginnt mit der **Vektortabelle** des Cortex-M: dem Stackzeiger und der Startadresse (+1: Thumb-Code); dahinter der IMAGE_DEF-Block mit `0x1021` (Arm, Secure) statt `0x1101`.

Debuggen geht wie bei RISC-V (F7, F8, F9, F4, F5) über die USB-Probe (nicht über OpenOCD). Rechts stehen `R0` bis `R12`, `SP`, `LR`, `PC`, `XPSR` und seine Flags `N Z C V`; der Kern hat **8 Hardware-Breakpoints**. Beginnt das Programm mit einer Vektortabelle, setzt der Debugger beim Start den Stackzeiger aus ihr. *Step over* kennt `bl` und `blx`.

**Der Chip läuft immer nur mit einer Sorte von Kernen.** Läuft gerade die andere Sorte, schreibt der Debugger ein Flash-Programm mit ihr in den Flash, setzt den Chip zurück und macht mit den Kernen des Programms weiter (das dauert etwa zwei Sekunden; das Ausgabefenster sagt es). Ein Programm im RAM kann nicht umschalten: Das Boot-ROM startet nach einem Reset die Kerne, für die das Programm im Flash ist. Dann sagt Asmonite, was zu tun ist: zuerst ein Flash-Programm der passenden Sorte starten, zum Beispiel `blink_arm_flash.asm` oder `blink_flash.asm`. *Test the connection* zeigt, welche Kerne gerade laufen.

## Die serielle Ausgabe über die Debug Probe

Die Raspberry Pi Debug Probe hat auch einen seriellen Port: Ihr zweiter Stecker, **„U“**, ist ein UART mit einem
eigenen COM-Port am PC (neben dem SWD an „D“, über dasselbe USB-Kabel). Sein Kabel geht so an das Board:

| Probe, Stecker „U“ | Pico 2, Pico | Blue Pill |
|---|---|---|
| RX (Eingang der Probe; gelb am Kabel der Probe) | GP0, Pin 1 (TX von UART0) | PA9 (TX von USART1) |
| TX (Ausgang der Probe; orange) | GP1, Pin 2 (RX von UART0) | PA10 (RX von USART1) |
| GND (schwarz) | GND, Pin 3 | G |

Hat eine Sitzung über die Probe das Programm geladen, verbindet sich der Reiter **Serial** neben dem Ausgabefenster
von selbst mit diesem COM-Port und zeigt, was das Board sendet (mit der Baudrate aus dem Reiter, 115200 von
Haus aus); Debugger und Terminal kommen sich nicht in die Quere, Connect und Disconnect bleiben benutzbar. Die
Beispiele `examples/pico2/hello_uart_ram.asm` (RISC-V), `hello_uart_arm_ram.asm` (Arm),
`examples/pico/hello_uart_ram.asm` und `examples/stm32/hello_uart_ram.asm` schreiben etwa einmal pro Sekunde „Hello,
world!“ mit 115200 Baud: RP2040 und RP2350 starten dafür zuerst ihren 12-MHz-Quarz (nach einem Reset laufen sie von
einem Ringoszillator, der für eine Baudrate nicht genau genug ist), der STM32 läuft von seinem 8-MHz-HSI.

Die Probe schickt, was sie empfängt, nur an ein Terminal, das die Leitung DTR eingeschaltet hat; der Reiter Serial
tut das für sie (und lässt DTR bei den Boards von Espressif aus, wo es den Chip zurücksetzen würde). In einem anderen
Terminalprogramm: DTR an.

**Ohne Probe gibt es keinen seriellen Port.** Der USB-Anschluss des Pico und des Pico 2 ist ein USB-Controller ohne
eigenen seriellen Port: Der COM-Port von Programmen aus dem Pico SDK kommt von einem USB-Stack im Programm (TinyUSB),
den ein Assembler-Programm nicht hat. Ein USB-Seriell-Adapter an GP0 und GND tut, was der UART der Probe tut.

## Die Konsole von Asmonite auf dem Pico 2 und dem Pico

Wie beim ESP32 gibt es für die Arm-Kerne des Pico 2 eine Konsole: `boards/pico2/console.asm`. Sie steht im Flash,
kopiert sich beim Start ins RAM und spricht über UART0 (GP0, GP1) mit 115200 Baud, also über den Stecker „U“ der
Debug Probe (verkabelt wie oben).

**Einrichten:** Board > Board Manager, links den Pico 2 (Debug Probe) wählen, dann **Prepare Board**. Asmonite
schreibt die Konsole über die Probe in den Flash, an die Stelle des Programms dort, und legt ein Dateisystem an, wenn
noch keins da ist. Danach zeigt der Board Manager die Dateien mit denselben Knöpfen wie beim ESP32: eine Datei
hochladen, herunterladen, löschen, starten (*Run*: der Reiter Serial
zeigt, was das Programm schreibt), Autostart, formatieren. Ist die Konsole im Flash nicht die dieser
Asmonite-Version, sagt das die Zeile *Console*; Prepare Board schreibt die neue, die Dateien bleiben.

**Am Prompt** (Reiter Serial auf dem COM-Port der Probe, Enter): `ls`, `cat name`, `rm name`, `df`, `format`,
`run name [args]` (oder nur der Name), `boot name`, `boot`, `noboot`, `info`, `reset`, `wlan`,
`help`.
Ctrl+C (Stop im Reiter Serial) hält ein Programm an, das läuft. Nach einem Reset mit einem Programm für den Autostart
wartet die Konsole eine Sekunde: Eine Taste hält sie am Prompt.

**Pico W und Pico 2 W:** Der Chip unterscheidet sie nicht vom Pico und vom Pico 2, deshalb fragt die Konsole beim
Start einmal den WiFi-Chip des Boards (CYW43439, an GPIO 23, 24, 25 und 29): Antwortet er, ist das Board ein W. Der
Gruß der Konsole, `info` (die Zeile *board*) und der Board Manager (sein Titel, sein Foto, die Zeile *Board*) nennen
es. Auf einem Board ohne WiFi leuchtet dabei die LED eine Viertelsekunde. Danach schaltet die Konsole den WiFi-Chip
aus; die LED eines W hängt an diesem Chip, deshalb blinken die Beispiele `blink` sie nicht.

`wlan on` startet den WiFi-Chip eines W mit seiner Firmware: Die Konsole liest sie aus den Dateien `43439A0.bin` und
`nvram_rp2040.bin` im Flash und schickt sie über das SPI des Chips in seinen RAM (etwa 226 KB in 0,6 s), dann läuft
sein Arm-Kern; danach spricht die Konsole in Paketen mit der Firmware (SDPCM, ihre Kommandos: ioctl und iovar) und
gibt ihr die CLM-Daten (`43439A0_clm.bin`, die Kanäle und die Sendeleistung je Land). Prepare Board legt die drei
Dateien auf einen W (aus `wlan\infineon` neben `Asmonite.exe`, unverändert von Infineon, mit ihrer Lizenz).
`wlan off` schaltet den Chip aus, `wlan` sagt, ob er läuft, `wlan scan` zeigt die Netzwerke in der Nähe (das Signal
in dBm, den Kanal, offen oder geschützt, den Namen). `led()` der Programme schaltet die LED eines W am Chip.

`wlan set` fragt nach dem Namen eines Netzwerks und seinem Passwort (ohne Anzeige; nur Enter: ein offenes Netz) und
verbindet sich (WPA2 mit AES). Wie beim ESP32 behält die Konsole den Namen und den daraus gemachten Schlüssel von
WPA2 (PBKDF2, etwa 2 s), nicht das Passwort, in den letzten zwei Sektoren des Flash hinter den Dateien; `wlan on`
startet den Chip und verbindet sich wieder (auch nach einem Reset), `wlan` zeigt das Netz, `wlan clear` vergisst
es.

**aBelle-Programme im Netz:** `include "inc/net.abel"` (in `abelle/examples/pico2`, nach `inc/console.abel`) gibt
ihnen ARP, IPv4, Ping, UDP, DHCP, DNS und mDNS, `inc/tcp.abel` dazu TCP, mit denselben Funktionen wie beim ESP32;
`wifi_connect_saved()` startet den Chip und verbindet sich mit dem Netz von `wlan set`. Die Beispiele `dhcp`, `ping`,
`dns`, `ntp`, `arpscan` und `httpget` zeigen es: `run ping` in der Konsole oder F9 in Asmonite. Dafür hat die Konsole
eine Funktion mehr, `wl_call` (+52, siehe unten; `console_version()` 3): Frames senden und empfangen, die MAC,
verbinden; ab `console_version()` 4 auch die Netze in der Nähe suchen (`wifi_scan`), ab 5 die Zahl der Pings, die
die Konsole beantwortet hat (`wifi_pings`). Chip und Netz bleiben nach einem Programm für das nächste. `telnetd` ist die kleine Shell über telnet des
ESP32 (Dateien, Speicher, Ping, LED; mit `passwd set` fragt sie nach einem Passwort).

**Die Konsole im Netz:** Nach einer Verbindung holt sie sich eine Adresse per DHCP und erneuert sie nach der Hälfte
der Lease; `wlan` zeigt Adresse, Maske, Router und DNS-Server. Hat das Board ein Netz gespeichert, verbindet sie sich
nach ihrem Start von selbst damit, sobald sie 3 Sekunden ruhig am Prompt gewartet hat („WiFi: connected, address …“;
in den 2 bis 5 Sekunden dafür antwortet sie nicht, was getippt wird, wartet). SysTick schaut alle 10 ms beim Chip
nach und beantwortet ARP und Ping für das Board: am Prompt, während ein Programm läuft und während es an einem
Breakpoint steht; andere Frames hebt er für das Programm auf. `name set <name>` gibt dem Board einen Namen für den
Router (sonst `pico2w-` und das Ende der MAC), `passwd set` das Passwort für telnet; beide bleiben im Datensatz des
Netzes, auch über `wlan set` und `wlan clear`.

**Programme für die Konsole** laufen im RAM: `.target pico2`, `.arch thumb`, `.imagebase 0x20000000` (bis
0x2006FFFF). Die Konsole ruft `_start` mit dem Text der Argumente in `r0` auf, auf einem eigenen Stack; `bx lr`
beendet das Programm mit dem Code in `r0` („Program ended (code n).“), ebenso `exit` aus beliebiger Tiefe. Ein Fehler
im Programm (ein Lesen, wo nichts ist) und Ctrl+C beenden es auch, die Konsole sagt wie und macht weiter. Ihre
Funktionen stehen als Tabelle von Adressen bei `0x20078140`, in der Reihenfolge des ESP32: +0 `exit`, +4 `version`,
+8 `put_char`, +12 `get_char`, +16 `poll_char`, +20 `print`, +24 `millis`, +28 `file_size`, +32 `file_read`,
+44 `args`, +48 `led` (die LED des Boards, GPIO 25), +52 `wl_call` (das WLAN eines W, für `inc/wifi.abel`;
`boards/pico/console_wifi.asm`). Ein Aufruf lädt die Adresse aus der Tabelle und springt mit `blx`
hinein; `r0` bis `r3` sind die Argumente, `r0` das Ergebnis. `examples/pico2/hello_console.asm` zeigt es. Dieselben
Funktionen gibt es auch als aufrufbaren Code bei `0x20079E00` (je 16 Bytes, in derselben Reihenfolge; der Pico:
`0x20039E00`).

**Programme in aBelle** für die Konsole: `target "pico2"` (der Pico: `target "pico"`) und
`include "inc/console.abel"`; `abelle_pico.exe` übersetzt sie, F9 führt sie über die Konsole aus, mit Breakpoint
debuggen F9, F7 und F8 sie (über das USB-Kabel oder die Probe), mit den Variablen. Beispiele in
`examples/abelle/pico2` und `examples/abelle/pico`: `hello.abel`, `blink.abel`. Pico W und Pico 2 W haben ihre LED am
WiFi-Chip: `led()` schaltet sie dort (der erste Aufruf startet den Chip, wie `wlan on`).

**F9** debuggt den Pico 2 über die Probe (SWD), oder über das USB-Kabel (siehe unten: Debuggen über USB). Die
Konsole bleibt im Flash und meldet sich nach dem nächsten Reset wieder.

**Wo was liegt:** die Konsole im Flash ab `0x10000000`, die Dateien von 1 MB bis 4 MB weniger 8 KB (`0x10100000` bis
`0x103FE000`, dahinter das WiFi-Netz); im RAM die Programme von `0x20000000` bis `0x2006FFFF`, die Konsole ab `0x20070000`.

**Auf dem Pico (RP2040)** gibt es dieselbe Konsole: `boards/pico/console.asm`, mit denselben Befehlen, Dateien
und Knöpfen im Board Manager (links „Pico (Debug Probe)“, dann **Prepare Board**). Die Unterschiede:

- Programme: `.target pico`, `.arch thumb` (nur Thumb-1, der Cortex-M0+ hat kein Thumb-2), `.imagebase 0x20000000`
  (bis 0x2002FFFF); die Tabelle der Funktionen liegt bei `0x20038140`. `examples/pico/hello_console.asm` zeigt es,
  mit einer eigenen Division (der M0+ hat keine).
- Die Konsole im RAM ab `0x20030000`, im Flash nach den 256 Bytes von boot2; die Dateien von 1 MB bis 2 MB
  weniger 8 KB (`0x10100000` bis `0x101FE000`, der Pico hat 2 MB Flash; dahinter das WiFi-Netz).
- Ein Fehler im Programm meldet nur die Exception und den pc (der M0+ hat keine Register, die mehr sagen).
- `reset` startet den Chip über den Watchdog neu.

**Über das USB-Kabel:** Steckt auch das USB-Kabel des Boards am PC, meldet sich die Konsole dort als eigener COM-Port
(„USB Serial Device“, VID/PID 1209:0001, der Treiber von Windows). Seine Seriennummer ist der Chip und die Kennung
des Boards (beim Pico 2 aus dem OTP des Chips, beim Pico die des Flash-Chips): Jedes Board bekommt einen eigenen
COM-Port, auch zwei gleiche an einem PC. Sie spricht über beide Wege zugleich: Was sie
schreibt, geht an den UART und über USB, und sie nimmt, was von einem der beiden kommt. Über USB gehen Dateien rund
zehnmal so schnell. Ctrl+C hält auch über USB ein Programm an.

**Ganz ohne Probe:** Steck den Pico mit gedrückter BOOTSEL-Taste ein (oder einen neuen, leeren). Der Board Manager
zeigt ihn im USB-Boot; **Prepare Board** legt die Konsole als UF2-Datei auf sein Laufwerk, das Boot-ROM schreibt sie in
den Flash und startet sie, und der Board Manager wählt dann „Pico (USB console)“ bzw. „Pico 2 (USB console)“ mit den
Dateien. Ab da gehen Dateien, Run und F9 (ein Programm im RAM, ohne Breakpoint, der Reiter Serial an diesem Port) über
das USB-Kabel. **Prepare Board** an der USB-Konsole schreibt eine neue Konsole ohne Taste: Asmonite stellt den Port auf
1200 Baud, die Konsole startet den Chip in seinen USB-Boot (wie bei den Boards von Arduino), dann die UF2-Datei; die
Dateien bleiben. **Reset** startet ihn neu.

**Debuggen über USB, ohne Probe:** In beiden Konsolen steckt ein Debug-Monitor. Ist der Reiter Serial mit der
USB-Konsole verbunden, oder steckt keine Probe und das Board mit seiner Konsole am USB, und ist das Programm eins für
das RAM der Programme (`.imagebase 0x20000000`), dann geht F9 mit
Breakpoints (oder F7) über diesen Monitor: Das Log sagt „over the debug monitor of its console“. Breakpoints, F7, F8,
Run to Cursor, Pause, Stop, die Register und der Speicher gehen wie über die Probe; der Reiter Serial zeigt, was das
Programm schreibt, und nach der Sitzung wartet die Konsole wieder am Prompt (Stop beendet das Programm). Ohne
Breakpoint läuft F9 wie bisher einfach über die Konsole.

- Pico 2: Der Cortex-M33 schickt die Breakpoints seiner FPB (7 für Asmonite) und die Einzelschritte in die Exception
  DebugMonitor. Sie läuft unter der Priorität des USB-Interrupts, so bleibt die Verbindung offen, während das Programm
  steht.
- Pico: Der Cortex-M0+ kennt diese Exception nicht. Asmonite schreibt für jeden Breakpoint und jeden Schritt einen
  `bkpt` ins Programm (nur solange es läuft); der HardFault eines `bkpt` führt in den Monitor (über PendSV, mit der
  niedrigsten Priorität).
- Das Programm läuft so, wie die Konsole es startet: auf ihrem Stack, mit ihren Funktionen; `bx lr` am Ende meldet
  „The program ended: code n“.
- Ein Programm, das alle Interrupts sperrt, lässt sich in der Zeit nicht anhalten. Programme für das Flash und die
  RISC-V-Kerne des Pico 2 debuggt Asmonite weiter über die Probe; ebenso alles, wenn die Probe steckt und der Reiter
  Serial nicht an der Konsole hängt. Ohne Probe und ohne eine Konsole, die zum Programm passt, sagt F9, was zu stecken
  ist (auch wenn das Programm für den Pico ist und das Board ein Pico 2, oder umgekehrt).
- Hat die Probe den Kern noch als Debugger (nach einer Sitzung über SWD, die nicht sauber endete), lehnt der Monitor
  des Pico 2 ab und sagt es: einmal ab- und anstecken hilft.

**Grenzen:** über den UART nur 115200 Baud; beim Pico 2 nur die Arm-Kerne. Öffnet ein Terminal den COM-Port der Probe, während das
Board ohne Pause sendet, kommen die Zeichen verstümmelt an, bis zur ersten Pause: eine Eigenheit der Probe.

## Ein USB-Gerät ohne SDK

`examples/pico/usb_echo_ram.asm` (Pico) und `examples/pico2/usb_echo_ram.asm` (Pico 2, Arm-Kerne) machen das Board über
sein eigenes USB-Kabel zu einem COM-Port am PC (USB CDC-ACM), ganz in Assembler, ohne Pico-SDK und ohne TinyUSB. Der
Code für beide steht in `examples/pico/usb_cdc.asm`; die beiden Dateien setzen nur `CHIP` und holen ihn mit
`.include`.

So geht es: Die Debug Probe an SWD, **dazu** das USB-Kabel des Boards an den PC, dann F9. Windows 10 und 11 zeigen
einen neuen COM-Port (Geräte-Manager, „Anschlüsse (COM & LPT)“; Treiber `usbser.sys`, nichts zu installieren). Öffne
ihn im Reiter Serial oder einem anderen Terminal, die Baudrate ist egal: Das Board grüßt, und was du tippst, kommt
zurück, Enter als neue Zeile.

Die Kennung 0x1209/0x0001 ist die Testnummer von pid.codes: nur für Versuche am eigenen Tisch. Ein Gerät, das andere
bekommen, braucht eine eigene.

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
- Die W-Modelle (Pico W, Pico 2 W): Ihre LED hängt am Funkchip, den die Beispiele nicht ansteuern (die Konsole fragt
  den Chip nur, ob er da ist).
- Variablen eines C- oder Pascal-Programms werden nicht angezeigt: Der Debugger arbeitet mit Assembler-Quelltext.

## Zum Weiterlesen

- Die RISC-V-Spezifikation (unprivilegiert und privilegiert): riscv.org/specifications
- Datenblatt des RP2350 (die Speicher-Map, die Peripherie, das Boot-ROM): datasheets.raspberrypi.com
- Dokumentation des Hazard3 (der Kern: Befehle, Debug-Modul, CSRs): github.com/Wren6991/Hazard3
