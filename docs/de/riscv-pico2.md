# Der Raspberry Pi Pico und Pico 2 mit Asmonite

Wie du ein Programm in Arm-Assembler oder in aBelle schreibst, auf einem Raspberry Pi Pico oder Pico 2 laufen lässt
und ansiehst, während es läuft. Du brauchst nur das USB-Kabel des Boards: Asmonite bringt einmal seine Konsole auf
das Board, danach lädt es deine Programme über dieses Kabel, startet sie und lässt dich Schritt für Schritt
hindurchgehen. Die Befehlsreferenz ist die F1-Hilfe von Asmonite.

> **Neu hier?** Board einstecken (einen Pico beim ersten Mal mit gedrückter Taste BOOTSEL), **Board > Board Manager** öffnen und **Prepare Board...** klicken: Dann
> ist die Konsole von Asmonite auf dem Board, und F9 startet deine Programme dort. Alles über den Board Manager:
> [board-manager.md](board-manager.md).

> **Die Beispiele dieser Seite:** Die Beispiele in Assembler (`examples/<board>/…`) und einige in aBelle, die diese
> Seite nennt, werden gerade noch einmal durchgesehen und kommen nach und nach in den Ordner `examples/`; bis dahin
> fehlen sie in der ZIP-Datei und im öffentlichen Repository. Was schon freigegeben ist, steht in
> [examples/README.de.md](../../examples/README.de.md).

## Was du brauchst

- einen **Raspberry Pi Pico**, **Pico W**, **Pico 2** oder **Pico 2 W**
- sein **USB-Kabel** (eines, das Daten überträgt, nicht nur ein Ladekabel)
- Windows 10 oder 11 mit Asmonite. Kein Treiber nötig: Windows nimmt das Board als eigenen COM-Port.

## Der erste Start: die Konsole auf das Board

1. Halte den Knopf **BOOTSEL** des Boards gedrückt, während du es einsteckst (ein neues, leeres Board braucht den
   Knopf nicht). Windows zeigt ein Laufwerk, `RPI-RP2` oder `RP2350`.
2. **Board > Board Manager**: Links steht das Board in seinem USB-Boot. Klicke auf **Prepare Board...**: Asmonite
   kopiert seine Konsole als UF2-Datei auf das Laufwerk, der Boot-ROM schreibt sie in den Flash und startet sie.
3. Der Board Manager zeigt jetzt „Pico (USB console)“ oder „Pico 2 (USB console)“ mit seinen Dateien. Die Konsole ist
   ein eigener COM-Port am PC („USB Serial Device“, VID/PID 1209:0001, der Treiber von Windows); jedes Board bekommt
   seinen eigenen, auch zwei gleiche an einem PC.

Von da an geht alles über dieses Kabel: Dateien, Programme, der Debugger. Die Konsole bleibt im Flash und ist nach
jedem Reset wieder da. Ein neueres Asmonite bringt eine neuere Konsole mit: Die Zeile *Console* im Board Manager sagt
es, und **Prepare Board...** schreibt sie ohne den Knopf (Asmonite setzt den Port auf 1200 Baud, die Konsole startet
den Chip in seinen USB-Boot neu, wie es die Boards von Arduino tun, dann die UF2-Datei); die Dateien bleiben.

## Laufen lassen und Debuggen

Programme für die Konsole laufen im RAM des Boards: `.imagebase 0x20000000`.

```asm
.target pico2           ; für den Raspberry Pi Pico 2 (der Pico: .target pico)
.arch thumb             ; Arm-Befehle (Thumb)
.imagebase 0x20000000   ; im RAM, von der Konsole gestartet

_start:
    push {r4, lr}
    ...
    movs r0, #0         ; der Code am Ende
    pop  {r4, pc}       ; zurück zur Konsole
```

- **F9** ohne Breakpoint: Asmonite assembliert das Programm, lädt es über das Kabel, und die Konsole startet es; der
  Tab **Serial** zeigt, was es schreibt.
- **F7** (Step into) oder F9 mit einem Breakpoint: dasselbe, aber der **Debug-Monitor** der Konsole hält es bei
  `_start` an (oder am Breakpoint). **F7** geht einen Befehl weiter, **F8** über einen Aufruf hinweg (`bl`, `blx`),
  **F4** läuft bis zum Cursor, **F5** setzt oder entfernt einen Breakpoint, **F9** läuft weiter, *Debug > Pause* hält
  ein laufendes Programm an, **Strg+F2** (Stop) beendet es. Im Ausgabefenster steht „over the debug monitor of its
  console“.
- Rechts stehen `r0` bis `r12`, `sp`, `lr`, `pc`, `xpsr` und seine Flags `N Z C V`; ein Doppelklick ändert einen
  Wert. Der Stack zeigt die Wörter ab `sp`; wo ein Wert in dein Programm zeigt, nennt die Notiz das Label und die
  Zeile (so siehst du gesicherte Rücksprungadressen). Die Speicheransicht hat einen Schalter **Bytes / Code**: *Code*
  listet die Befehle ab der Adresse (`pc` ist voreingestellt), mit `=>` beim nächsten und deinen Labels.
- Das Programm läuft so, wie die Konsole es startet: auf einem eigenen Stack, mit dem Text seiner Argumente in `r0`.
  `bx lr` (oder `pop {..., pc}`) am Ende geht zur Konsole zurück: „Program ended (code n)“, `n` ist `r0`. Ein Fehler
  im Programm (ein Lesen, wo nichts ist) und Strg+C beenden es auch; die Konsole sagt, wie, und macht weiter.

`examples/pico2/instructions_arm.asm` (Pico 2) und `examples/pico/instructions_arm.asm` (Pico) sind genau dafür
gemacht: die wichtigen Befehle nacheinander, jeder mit einem Kommentar, was er tut und welcher Wert herauskommt.
Öffne eines, drücke F7 und dann immer wieder F7.

Wie es geht: Auf dem Pico 2 schickt der Cortex-M33 die Breakpoints seiner FPB (7 für Asmonite) und die Einzelschritte
in seine Exception DebugMonitor; sie läuft unter der Priorität des USB-Interrupts, so bleibt die Verbindung offen,
während das Programm steht. Der Cortex-M0+ des Pico hat diese Exception nicht; Asmonite schreibt für jeden Breakpoint
und jeden Schritt ein `bkpt` ins Programm (nur solange es läuft), der HardFault des `bkpt` führt in den Monitor. Ein
Programm, das alle Interrupts abschaltet, lässt sich solange nicht anhalten.

**Die Konsole am Prompt** (der Tab Serial am COM-Port des Boards, Enter): `ls`, `cat name`, `rm name`, `df`,
`format`, `run name [args]` (oder nur der Name), `boot name`, `boot`, `noboot`, `info`, `reset`, `help`, und auf
einem W `wlan`, `name`, `passwd`. Strg+C (Stop im Tab Serial) hält ein laufendes Programm an. Nach einem Reset mit
einem Programm für den Autostart wartet die Konsole eine Sekunde: Eine Taste hält sie am Prompt. Der Board Manager
zeigt die Dateien mit Buttons: hochladen, herunterladen, löschen, starten, Autostart, formatieren. **Project >
Compile and Upload** (bei Assembler: Assemble and Upload) legt ein Programm in die Dateien des Boards, um es später
mit `run` zu starten.

## Der Pico (RP2040)

Der erste Pico hat einen RP2040 mit zwei Arm Cortex-M0+. Programme: `.target pico`, `.arch thumb`, `.imagebase
0x20000000` (bis `0x2002FFFF`).

| Was | Adresse |
|---|---|
| Flash (2 MB) | `0x10000000`: die Konsole, ab 1 MB die Dateien |
| RAM (264 KB) | `0x20000000` bis `0x2002FFFF` die Programme, ab `0x20030000` die Konsole |
| Peripherie, SIO | `0x40000000`, `0xD0000000` (dieselben wie beim Pico 2) |

- **Weniger Befehle.** Der Cortex-M0+ kennt ARMv6-M: Thumb mit den 16-Bit-Befehlen, von den 32-Bit-Befehlen nur
  `bl`, `msr`, `mrs` und die Barrieren. Es gibt kein `movw`/`movt`, kein `cbz`, `cbnz`, `it`, keine Division; die
  meisten Befehle arbeiten nur mit `r0` bis `r7`. Eine 32-Bit-Konstante kommt aus einem Wort hinter dem Code (`ldr
  r0, label`). Mit `.target pico` meldet der Assembler jeden anderen Befehl als Fehler mit seiner Zeile.
- Die Funktionen der Konsole sind eine Tabelle bei `0x20038140`; `examples/pico/hello_console.asm` zeigt sie, mit
  einer eigenen Division.
- Ein Fehler in einem Programm zeigt nur die Exception und den pc (der M0+ hat keine Register, die mehr sagen).

## Der Pico 2 (RP2350)

Der RP2350 hat zwei Prozessoren von jeder von zwei Sorten: zwei Arm Cortex-M33 und zwei RISC-V-Kerne (Hazard3). Die
Konsole läuft auf den Arm-Kernen, Programme für die Konsole sind also Arm-Programme: `.target pico2`, `.arch thumb`,
`.imagebase 0x20000000` (bis `0x2006FFFF`). Der Cortex-M33 kennt Thumb-2: auch `movw`/`movt`, `cbz`, `it`, `udiv`,
`sdiv`. Zu den RISC-V-Kernen siehe [Ein Programm im Flash](#ein-programm-im-flash-und-die-risc-v-kerne).

| Was | Adresse |
|---|---|
| Boot-ROM | `0x00000000` |
| Flash (4 MB) | `0x10000000`: die Konsole, ab 1 MB die Dateien |
| RAM (520 KB) | `0x20000000` bis `0x2006FFFF` die Programme, ab `0x20070000` die Konsole |
| Peripherie (UART, GPIO, Timer, ...) | `0x40000000` |
| SIO (schnelles GPIO, Spinlocks) | `0xD0000000` |

Peripherie sind Register an festen Adressen, gelesen und geschrieben mit `ldr` und `str`; ihre Adressen stehen im
Datenblatt des Chips. Jedes Register antwortet noch unter drei weiteren Adressen: +`0x1000` kippt die geschriebenen
Bits (xor), +`0x2000` setzt sie, +`0x3000` löscht sie, so brauchst du kein Lesen-Ändern-Schreiben. Nach einem Reset
sind beim RP2350 die **Pads isoliert**: Ein Programm, das einen Pin treibt, löscht zuerst das Bit `ISO` seines
Pad-Registers.

## Programme für die Konsole

Die Konsole ruft `_start` mit dem Text der Argumente in `r0` auf; `bx lr` beendet das Programm mit dem Code in `r0`,
ebenso `exit` aus beliebiger Tiefe. Ihre Funktionen sind eine Tabelle von Adressen bei `0x20078140` (der Pico:
`0x20038140`), in der Reihenfolge des ESP32: +0 `exit`, +4 `version`, +8 `put_char`, +12 `get_char`, +16
`poll_char`, +20 `print`, +24 `millis`, +28 `file_size`, +32 `file_read`, +44 `args`, +48 `led` (die LED des
Boards), +52 `wl_call` (das WLAN eines W, für `wifi.abel`). Ein Aufruf lädt die Adresse aus der Tabelle und springt
mit `blx` dorthin; `r0` bis `r3` sind die Argumente, `r0` das Ergebnis, `r0` bis `r3` und `r12` dürfen sich ändern.
`examples/pico2/hello_console.asm` zeigt es. Dieselben Funktionen gibt es auch als Code zum Aufrufen bei
`0x20079E00` (je 16 Bytes, in derselben Reihenfolge; der Pico: `0x20039E00`).

**Programme in aBelle:** `target "pico2"` (der Pico: `target "pico"`) und `include "console.abel"`; F9 startet sie
über die Konsole, mit einem Breakpoint debuggen F9, F7 und F8 sie, mit den Variablen. Ein Programm ohne Zeile
`target` übersetzt Asmonite für das Board unter **Project > aBelle for**; so laufen auch die Beispiele in
`examples/common/` hier, zum Beispiel `hello.abel` und `blink.abel`. Pico W und Pico 2 W haben ihre LED am WLAN-Chip:
`led()` schaltet sie dort (der erste Aufruf startet den Chip, wie `wlan on`).

## Das WLAN von Pico W und Pico 2 W

Der Chip unterscheidet einen W nicht vom Pico und Pico 2, darum fragt die Konsole bei ihrem Start einmal den
WLAN-Chip des Boards (CYW43439, an GPIO 23, 24, 25 und 29): Antwortet er, ist das Board ein W. Der Gruß der Konsole,
`info` und der Board Manager nennen es. Auf einem Board ohne WLAN leuchtet dabei die LED eine Viertelsekunde.

`wlan on` startet den WLAN-Chip mit seiner Firmware: Die Konsole liest sie aus den Dateien `43439A0.bin` und
`nvram_rp2040.bin` im Flash und schickt sie über das SPI des Chips in seinen RAM (etwa 226 KB in 0,6 s), dann gibt
sie ihm seine CLM-Daten (`43439A0_clm.bin`, die Kanäle und die Leistung je Land). Prepare Board legt die drei Dateien
auf einen W (aus `wlan\infineon` neben `Asmonite.exe`, unverändert von Infineon, mit ihrer Lizenz). `wlan off`
schaltet den Chip ab, `wlan` sagt, ob er läuft, `wlan scan` listet die Netze in der Nähe.

`wlan set` fragt nach dem Namen eines Netzes und seinem Passwort (nicht angezeigt; nur Enter: ein offenes Netz) und
verbindet sich (WPA2 mit AES). Die Konsole behält den Namen und den aus dem Passwort berechneten Schlüssel von WPA2
(PBKDF2, etwa 2 s), nicht das Passwort, in den letzten beiden Sektoren des Flash, hinter den Dateien; `wlan on`
startet den Chip und verbindet sich wieder (auch nach einem Reset), `wlan clear` vergisst das Netz. Der Board Manager
kann dasselbe über sein Kontextmenü, mit den Netzen, die dein PC sieht, und dem Passwort aus Windows.

Nach dem Verbinden holt die Konsole eine Adresse per DHCP und erneuert sie zur halben Lease-Zeit; `wlan` zeigt die
Adresse, die Maske, den Router und den DNS-Server. Behält das Board ein Netz, verbindet sich die Konsole nach ihrem
Start von selbst, sobald sie 3 ruhige Sekunden am Prompt gewartet hat. Sie antwortet für das Board auf ARP, Ping und
mDNS (`name.local`): am Prompt, während ein Programm läuft und während es an einem Breakpoint steht. `name set <name>`
gibt dem Board einen Namen für den Router und für mDNS (sonst `picow-` oder `pico2w-` und das Ende der MAC),
`passwd set` das Passwort für telnet.

**aBelle-Programme im Netz:** `include "net.abel"` (nach `console.abel`) gibt ihnen ARP, IPv4, Ping, UDP, DHCP, DNS
und mDNS, `tcp.abel` dazu TCP, mit denselben Funktionen wie auf dem ESP32; `wifi_connect_saved()` startet den Chip
und verbindet sich mit dem Netz von `wlan set`. Die Beispiele in `examples/common/` (`scan`, `ping`, `dns`, `ntp`,
`webserver`, `httpget`, `httpsget` ...) zeigen es, `examples/pico/telnetd.abel` und `examples/pico2/telnetd.abel` sind
eine kleine Shell über telnet.

## Ein Programm im Flash, und die RISC-V-Kerne

Die Konsole startet Programme im RAM. Ein eigenes Programm im Flash (`.imagebase 0x10000000`) und ein Programm für
die RISC-V-Kerne des Pico 2 (`.arch riscv32`) kommen als **UF2-Datei** auf das Board: **Project > Save as UF2 file
(Raspberry Pi Pico)...** schreibt sie, dann hältst du BOOTSEL beim Einstecken gedrückt und ziehst die Datei auf das
Laufwerk, das erscheint. Das Board startet neu mit dem Programm. Ein solches Programm tritt im Flash an die Stelle der
Konsole (die Dateien bleiben); die Konsole kommt mit BOOTSEL und **Prepare Board...** wieder.

Der Boot-ROM startet ein Programm aus dem Flash nur, wenn er erkennen kann, was es ist:

- **Pico 2:** Ein kleiner Block in den ersten 4 KB sagt es (IMAGE_DEF). Mit `.target pico2` prüft der Assembler ihn:
  Er muss in den ersten 4 KB stehen, und sein IMAGE_TYPE muss zu `.arch` passen (`0x1101` RISC-V, `0x1021` Arm). Der
  Boot-ROM startet die Kerne, die der Block nennt: Ein RISC-V-Programm schaltet den Chip also auf seine RISC-V-Kerne,
  die Konsole (ein Arm-Programm) zurück auf die Arm-Kerne.

  ```asm
  image_def:
      dd 0xffffded3            ; Startmarke
      db 0x42, 1               ; Eintrag IMAGE_TYPE, 1 Wort
      dw 0x1101                ; ausführbar | RISC-V | RP2350
      db 0x44, 3               ; Eintrag ENTRY_POINT, 3 Wörter
      dw 0
      dd _start                ; pc beim Start
      dd SRAM_END              ; Stackpointer beim Start
      db 0xff
      dw 4                     ; die bisherigen Einträge, in Wörtern
      db 0
      dd 0                     ; kein weiterer Block
      dd 0xab123579            ; Endmarke
  _start:
      ...
  ```

  Ein Arm-Programm im Flash beginnt mit der **Vektortabelle** des Cortex-M (der Stackpointer und die Startadresse +1
  für Thumb-Code), dahinter der IMAGE_DEF-Block mit `0x1021`.
- **Pico:** Seine ersten 256 Bytes sind ein kleines Programm, das den Flash-Chip einrichtet (boot2), mit seiner CRC-32
  am Ende. **`.boot2`** setzt den Block des Pico SDK dorthin; `.boot2 datei.bin` nimmt einen eigenen (252 Bytes: die
  CRC wird angehängt; 256 Bytes: sie wird geprüft). Die Vektortabelle folgt bei `0x10000100`.

Ein Programm im Flash oder eines auf den RISC-V-Kernen lässt sich über das USB-Kabel noch nicht debuggen; um
RISC-V-Code Schritt für Schritt anzusehen, nimm den ESP32-C3 oder den ESP32-S31
(`examples/esp32c3/instructions_riscv.asm`).

## RISC-V in zehn Minuten

Wenn du x86 oder ARM kennst, sind das die Unterschiede, auf die es ankommt:

| | x86 | ARM | RISC-V |
|---|---|---|---|
| Register | 8 (32 Bit) | 16 | 32, `x0` ist immer 0 |
| Flags | ja | ja | **keine**: `beq`, `blt` vergleichen und springen in einem |
| Speicher | viele Befehle | `ldr`/`str` | nur `lw`/`sw` (und `lb`, `lh` ...) |
| Konstante mit 32 Bit | im Befehl | Literal-Pool | `lui` + `addi` (`li` macht das) |
| Aufruf | `call` legt die Adresse auf den Stack | `bl` setzt `lr` | `jal ra, ...` setzt `ra` |
| Rücksprung | `ret` holt sie | `bx lr` | `ret` = `jalr zero, 0(ra)` |
| Stack | `push`, `pop` | `push`, `pop` | keine: `addi sp, sp, -16` und `sw` |
| Befehlslänge | 1 bis 15 Bytes | 2 oder 4 | 4 (2 bei den kurzen Formen) |

Die F1-Hilfe von Asmonite hat die Themen `riscv`, `registers`, `pseudo` (die Kurznamen des Assemblers: `li`, `mv`,
`j`, `ret` ...), `encoding` und `compressed`; du liest sie mit dem Cursor auf einer beliebigen Zeile einer Quelle mit
`.arch riscv32`. Mit `.option rvc` schreibt der Assembler die 2-Byte-Formen, wo sie passen (etwa ein Fünftel weniger
Code; die Hazard3-Kerne haben C).

## Wenn es nicht klappt

- *No Pico 2 with the Asmonite console is connected over USB* (oder Pico): Das Board steckt nicht, oder es hat noch
  keine Konsole: BOOTSEL beim Einstecken gedrückt halten, dann **Prepare Board...** im Board Manager.
- *This program is for the Pico, but the board ... is a Pico 2* (oder umgekehrt): `.target` ändern (aBelle: die
  Zeile `target`, oder sie entfernen und das Board unter Project > aBelle for wählen).
- *This program is for the flash*: Über USB debuggt Asmonite Programme im RAM; gib ihm `.imagebase 0x20000000` oder
  starte es als UF2-Datei (siehe oben).
- Windows zeigt keinen neuen COM-Port und kein Laufwerk: Das Kabel ist vielleicht nur ein Ladekabel; versuche ein
  anderes.
- Die Zeile *Console* im Board Manager sagt „older version“: **Prepare Board...** schreibt die Konsole dieses
  Asmonite, die Dateien bleiben.

## Was (noch) nicht geht

- Debuggen über USB: nur Programme im RAM, auf Kern 0 der Arm-Kerne. Programme im Flash und auf den RISC-V-Kernen des
  Pico 2 laufen als UF2-Dateien.
- Die Beispiele in Assembler, die die LED treiben (`blink`), nehmen GPIO 25: Pico W und Pico 2 W haben ihre LED am
  WLAN-Chip, den nur die Konsole bedient (`led()` in aBelle).
- Variablen eines C- oder Pascal-Programms werden nicht gezeigt: Der Debugger arbeitet mit Assembler- und
  aBelle-Quelltext.

## Zum Weiterlesen

- Datenblätter des RP2040 und des RP2350 (die Speicheraufteilung, die Peripherie, der Boot-ROM):
  datasheets.raspberrypi.com
- Die RISC-V-Spezifikation (unprivileged und privileged): riscv.org/specifications
- Dokumentation des Hazard3 (der RISC-V-Kern des RP2350): github.com/Wren6991/Hazard3
