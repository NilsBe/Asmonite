# Die Boards von Asmonite: Debuggen und serielle Ausgabe

Auf welchen Boards Asmonite Programme laufen lässt, wie es sie über ihr USB-Kabel debuggt und wie das, was ein Programm schreibt, zum PC kommt. Die Einzelheiten stehen in der Anleitung jedes Boards.

> **Die Beispiele dieser Seite:** Die Beispiele in Assembler (`examples/<board>/…`) und einige in aBelle, die diese
> Seite nennt, werden gerade noch einmal durchgesehen und kommen nach und nach in den Ordner `examples/`; bis dahin
> fehlen sie in der ZIP-Datei und im öffentlichen Repository. Was schon freigegeben ist, steht in
> [examples/README.de.md](../../examples/README.de.md).

| Board | Chip, Kerne | Debuggen über das USB-Kabel | Serielle Ausgabe zum PC | Anleitung |
|---|---|---|---|---|
| Raspberry Pi Pico 2 | RP2350: Arm Cortex-M33, RISC-V Hazard3 | ja, die Arm-Kerne über den Debug-Monitor der Konsole von Asmonite: RAM, Pause; Programme im Flash und für die RISC-V-Kerne laufen als UF2-Datei | ja, die Konsole über das USB-Kabel | [riscv-pico2.md](riscv-pico2.md) |
| Raspberry Pi Pico | RP2040: Arm Cortex-M0+ | ja, über den Debug-Monitor der Konsole von Asmonite: RAM, Pause; Programme im Flash laufen als UF2-Datei | ja, die Konsole über das USB-Kabel | [riscv-pico2.md](riscv-pico2.md) |
| LilyGO T-PicoC3 | RP2040 und ESP32-C3 (RISC-V) | ja, beide Chips (der RP2040 über seinen USB-Boot, der C3 über seinen USB-JTAG) | der C3 über seinen USB-Anschluss; der RP2040 keine | [t-picoc3.md](t-picoc3.md) |
| STM32F103 „Blue Pill“ | Arm Cortex-M3 | nein: nur über eine Debug-Probe an seinen SWD-Pins (RAM, Flash, Pause) | über den UART der Probe | [stm32.md](stm32.md) |
| ESP32 | Xtensa LX6 | ja, über den USB-Seriell-Chip des Boards (ein Debug-Monitor von Asmonite): RAM, Flash, Pause | ja, UART0 über denselben Chip: auch unter dem Debugger | [esp32.md](esp32.md) |
| ESP32-S3 | Xtensa LX7 | ja, über den USB-JTAG des Chips: RAM, Flash, Pause | ja, der COM-Port des USB-Anschlusses des Chips | [esp32s3.md](esp32s3.md) |
| ESP32-C3 | RISC-V | ja, über den USB-JTAG des Chips: RAM, Flash, Pause | ja, der COM-Port des USB-Anschlusses des Chips | [esp32c3.md](esp32c3.md) |
| ESP32-S31 | RISC-V (zwei HP-Kerne, ein LP-Kern) | ja, Kern 0 über den USB-JTAG des Chips: RAM (die Konsole von Asmonite startet das Programm), Pause | ja, der COM-Port des USB-Anschlusses des Chips | (diese Seite) |
| MangoPi MQ-Pro | Allwinner D1: RISC-V, 64 Bit | ja, über den FEL-Modus des Boot-ROMs: RAM, keine Pause | nur mit einem USB-Seriell-Adapter an UART0 | [d1.md](d1.md) |

Jedes Board hier außer der Blue Pill braucht nur sein USB-Kabel: keine Debug-Probe, keine Drähte zum Anlöten.

## Der Board Manager

**Board > Board Manager** zeigt die angesteckten Boards und bei jedem nur das, was mit ihm geht. Links stehen die
Boards (**Scan** sucht neu) und darunter ein Foto des gewählten Boards. Rechts steht, was Asmonite über das Board
weiß, bei einem Board mit der Konsole von Asmonite darunter die Dateien der Konsole, unten
die Knöpfe für das Board.

Beim Öffnen liest der Board Manager nur, was das Board nicht stört: was Windows über das USB-Gerät sagt (Kennung,
Hersteller, Port), den Gruß der Konsole von Asmonite (Chip, Version der Konsole, Flash; „Console: v5 (current: v5)“:
die Zahl, die `console_version()` liefert, und die der Konsole dieses Asmonite; eine andere Konsole: Prepare Board
schreibt die aktuelle), beim ESP32, S3, C3 und S31 die Version des WLAN-Dienstes in seinem Paket („WiFi service: v10
(current: v11)“: Install WiFi schreibt den aktuellen; ein Rechtsklick kopiert eine Zeile oder alle; auf der Zeile
WiFi setzt er das Netz des Boards, schaltet WLAN ein oder aus, vergisst das Netz und setzt den Namen des Boards, auf
der Zeile telnet sein Passwort:
Set Network... listet die Netze, die dieser PC sieht, beim C3, S31 und Pico W auch die, die das Board sieht, und From
Windows trägt das Passwort ein, das Windows gespeichert hat), und beim Pico im USB-Boot den Chip und den Flash über
PICOBOOT. Mehr über einen ESP32 ohne Konsole erfährt nur das Boot-ROM: **Chip Details** liest
Chip, Revision, MAC, Quarz und Flash und startet das Board dafür neu. Beim ESP32-S3 nennt es auch den PSRAM im Chip
(Module wie N16R8: 8 MB), den Espressif in die eFuses schreibt; den PSRAM eines ESP32-WROVER, ein eigener Chip neben
dem ESP32, kennen die eFuses nicht.

Die Dateien: Ein Rechtsklick auf eine Datei zeigt, was mit ihr geht: bei einem Programm **Run**, bei einer Textdatei
**Open in Editor** (beides auch Enter oder ein Doppelklick; der Editor bekommt eine Kopie, eine Änderung bleibt auf dem
PC), **Autostart**, **Download**, **Delete** (auch Entf); dazu, auch auf der leeren Liste, **Upload File** und
**Refresh** (F5). Dateien aus dem Explorer, auf das Fenster gezogen, lädt der Board Manager auf das Board.
**Examples...** öffnet ein Beispiel für das gewählte Board: aus `examples\common` (für jedes Board), aus dem Ordner des
Boards, wenn es einen hat (`examples\esp32` ...), oder die Übersicht der Beispiele. Asmonite öffnet es im Editor und
stellt bei aBelle **Project > aBelle for** auf das Board des Reiters Serial: F9 startet es dann dort.

| Board | Knöpfe |
|---|---|
| ESP32, ESP32-S3 | die Dateien: **Upload File**, **Refresh**, im Kontextmenü einer Datei **Run**, **Autostart**, **Download**, **Delete**; das Board: **Reset**, **Chip Details**, **Prepare Board**, **Install WiFi**, **Format**, **Erase Flash** |
| ESP32-S31 (RISC-V) am USB-Port des Chips | wie beim ESP32-C3 (die Konsole von `boards/esp32s31`, im Flash bei 0x2000), mit seinem WLAN (Install WiFi); **Chip Details** nennt Chip, Revision, MAC, PSRAM, Quarz und Flash. Hinter einem USB-Seriell-Chip hält Asmonite ihn für einen ESP32, bis Chip Details ihn erkennt |
| ESP32-S3 oder ESP32-C3, noch nicht erkannt (beide haben dieselbe USB-Kennung, keine Konsole antwortet) | **Chip Details**, **Prepare Board** |
| ESP32-C3 | wie beim ESP32 und ESP32-S3, sobald seine Konsole läuft (sie meldet sich als C3: Paket H); ohne sie **Reset**, **Chip Details**, **Prepare Board**, **Erase Flash** (über sein Boot-ROM); mehr in [esp32c3.md](esp32c3.md) |
| Pico 2 und Pico mit der Konsole am USB-Kabel | die Dateien der Konsole wie beim ESP32 (**Upload File**, **Refresh**, im Kontextmenü **Run**, **Autostart**, **Download**, **Delete**); das Board: **Reset**, **Prepare Board** (eine neue Konsole, ohne den Knopf BOOTSEL), **Format**; mehr in [riscv-pico2.md](riscv-pico2.md) |
| Blue Pill hinter einer Debug-Probe | **Reset**, **Erase Flash**; siehe [stm32.md](stm32.md) |
| Klon „Pico W-2023“ (ein RP2040 mit einem ESP8285 statt des CYW43439), Konsole am USB-Kabel | die Dateien der Konsole wie beim Pico; das Board: **Prepare Board**, **Install WiFi (ESP8285)** (die Firmware von Asmonite in den ESP8285, etwa 40 s; das Board dafür mit gehaltener BOOT-Taste einstecken, die Rückfrage sagt wie) |
| Pico im USB-Boot (BOOTSEL) | **Prepare Board** (die Konsole als UF2-Datei auf sein Laufwerk), **Start Program** (verlässt den USB-Boot, das Programm im Flash startet), **Erase Flash** |
| Pico 2 im USB-Boot (BOOTSEL) | **Prepare Board** (wie beim Pico), **Arm Cores**, **RISC-V Cores** (über sein Laufwerk RP2350) |
| ein Board, das Asmonite nicht kennt | keine Knöpfe; nur, was Windows über es sagt |

**RISC-V Cores** und **Arm Cores** schalten einen Pico 2 im USB-Boot um: Das Boot-ROM startet die Kerne, für die das
Programm im Flash ist, also schreibt der Board Manager das Beispiel `blink` der anderen Kerne als UF2-Datei auf sein
Laufwerk (die LED blinkt). Die Konsole ist ein Arm-Programm: **Prepare Board** bringt sie und die Arm-Kerne zurück.

**Von selbst** öffnet sich der Board Manager, wenn du ein Board zum ersten Mal einsteckst, und beim Start von
Asmonite, wenn ein Board angesteckt ist, das Asmonite noch nicht gesehen hat. Danach öffnest du ihn über das Menü.
Asmonite merkt sich die Boards im Abschnitt `[Boards]` der Datei `Asmonite.ini` (an ihrer USB-Seriennummer, ohne
eine an der USB-Buchse des PCs). Liegt Asmonite im Hintergrund, blinkt es in der Taskleiste. Grenze: Zwei ESP32-DevKits mit dem
USB-Seriell-Chip CP2102 haben dieselbe Seriennummer („0001“); das zweite gilt darum schon als gesehen.

## Der Reiter Serial

Der Reiter **Serial** neben dem Ausgabefenster ist ein kleines Terminal für die COM-Ports. Unter dem Debugger zeigt er
von selbst, was das Programm schreibt:

- **ESP32:** Der Debug-Monitor von Asmonite hat den COM-Port des Boards; der Reiter zeigt die Ausgabe des Programms,
  Connect ist gesperrt, solange die Sitzung dauert.
- **ESP32-S3, ESP32-C3:** Der Reiter verbindet sich mit dem COM-Port des Chips, wenn das Programm geladen ist (der
  Reset ins Boot-ROM und der Flash brauchen den Port vorher); Connect bleibt benutzbar.
- **Pico 2, Pico:** Der Reiter ist am COM-Port der Konsole am USB-Kabel; unter dem Debugger hat ihn der Monitor der
  Konsole, und der Reiter zeigt, was das Programm schreibt.
- **Blue Pill über eine Debug-Probe:** Der Reiter verbindet sich mit dem COM-Port der Probe (ihr Stecker „U“, ein
  UART), wenn das Programm geladen ist (siehe [stm32.md](stm32.md)).
- **Der Pico über seinen USB-Boot, der D1:** keine eigene serielle Ausgabe; mit einem USB-Seriell-Adapter an ihrem
  UART zeigt sie der Reiter nach Connect.
- **Der RP2040 des T-PicoC3:** keine (sein UART geht zum ESP32-C3 des Boards).

**Ohne Debugger verbindet sich der Reiter von selbst** mit einem Board von Espressif (ein ESP32 hinter seinem
USB-Seriell-Chip zuerst, sonst der USB-Anschluss eines ESP32-S3 oder ESP32-C3): beim Start von Asmonite und sobald du
es einsteckst. Er hält den Port; der Board Manager, der Debugger und das Boot-ROM bekommen ihn, solange sie ihn brauchen,
danach verbindet sich der Reiter wieder. **Disconnect** gibt den Port frei, etwa für ein anderes Terminal; dann bleibt
der Reiter weg, bis du das Board abziehst oder Connect drückst. Meldet sich die Konsole von Asmonite nach einem Reset
(„Asmonite console 2 for the ESP32 …“), zeigt der Kopf des Reiters den Chip, die Konsole und die Uhrzeit des Starts. Bis dahin zeigt er, was die
USB-Angaben sagen („ESP32 at COM14 (Silicon Labs CP210x …)“, „ESP32-S3 or ESP32-C3 at COM21“: beide haben dieselbe
USB-Kennung); um mehr zu erfahren, sendet der Reiter nichts, ein laufendes Programm bekäme es sonst als Eingabe.
Ging eine Debug-Sitzung auf dem ESP32 über das Boot-ROM (ohne Konsole auf dem Board), setzt der Reiter das Board
danach zurück; über die Konsole ist sie ohnehin wieder da. **Stop**
schickt Ctrl+C: Die Konsole beendet das Programm, das sie gestartet hat.

**F9 über die Konsole (ESP32, ESP32-S3):** Ist der Reiter mit dem Board des Programms verbunden (`target "esp32"` bzw.
`.target esp32`, für das S3 `esp32s3`) und hat das Programm keinen Breakpoint, bringt F9 es über die Konsole ins RAM
und startet es dort: ohne Download-Modus, ohne BOOT-Taste, ohne Reset. Was es schreibt, erscheint im Reiter, Stop
beendet es, und die Konsole meldet sein Ende. Läuft gerade ein Programm, beendet F9 es zuerst mit Ctrl+C. Mit einem
Breakpoint startet F9 den Debugger wie bisher; ein Programm für den Flash (`.target esp32 flash`) ebenso. Ist das
Programm für ein Board, heißt F9 im Menü Debug darum **Run in RAM / Continue**: Nach einem Reset ist das Programm weg.

**Als Datei auf das Board (ESP32, ESP32-S3, ESP32-C3, Pico, Pico 2):** **Project > Compile and Upload**
(Ctrl+Shift+F9; bei Assembler **Assemble and Upload**) übersetzt das Programm im Editor und legt es über die Konsole
als Datei in den Flash des Boards im Reiter Serial, unter dem Namen der Quelle ohne Endung (`blink.abel` wird
`blink`; eine Datei dieses Namens wird ersetzt). **Debug > Upload and Run** (Shift+F9) tut dasselbe und lässt die
Konsole das Programm danach aus der Datei starten. Es bleibt nach einem Reset auf dem Board: `run blink` in der
Konsole startet es wieder, **Autostart** im Board Manager nach jedem Reset. Wie bei F9 beendet Asmonite ein laufendes
Programm vorher mit Ctrl+C und bringt eine Konsole einer anderen Version zuerst auf den Stand.

**Updates von selbst:** Vor dem Start vergleicht Asmonite die Konsole im Flash mit seiner eigenen (über ihre CRC-32,
in wenigen Millisekunden). Stammt sie von einer anderen Version von Asmonite, schreibt es seine eigene über das
Boot-ROM (ESP32 etwa 11 Sekunden, S3 etwa 2), danach ein anderes WLAN-Paket, und startet dann das Programm. Die
Dateien und das Netz des Boards bleiben.

**Keine Konsole:** Der Kopf des Reiters sagt es, wenn das Boot-ROM kein Programm im Flash findet (ein leeres Board)
oder nach dem Start drei Sekunden lang keine Konsole grüßt (eine andere Firmware wie MicroPython, ein Programm von
Write to Flash and Run), und zeigt den Knopf **Prepare Board**. Antwortet bei F9 keine Konsole, fragt Asmonite nach:
Prepare Board, oder das Programm wie bisher mit dem Debugger starten. Prepare Board (auch im Board Manager) schreibt die
Konsole über das Boot-ROM in den Flash und legt ihr Dateisystem an, wenn noch keins da ist; Dateien der Konsole
bleiben.

Die Boards mit serieller Ausgabe haben ein Beispiel, das auf diesem Weg „Hello, world!“ schreibt: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (eine Zeile bei jedem Wechsel der LEDs),
`examples/pico2/hello_console.asm`, `examples/pico/hello_console.asm` (über die Konsole), `examples/stm32/hello_uart_ram.asm`.

## Was die Konsolen können

Die Konsole von Asmonite auf jedem Board, ihr WLAN (beim Pico das W) und die aBelle-Programme dafür, wie der Code sie
jetzt hat. „–“ fehlt noch; das Ziel ist auf jedem Board dasselbe, soweit seine Hardware es hergibt.

| | ESP32 | ESP32-S3 | Pico, Pico 2 (W) | ESP32-C3 | ESP32-S31 |
|---|---|---|---|---|---|
| `ls`, `cat`, `rm`, `df`, `format`, `run`, `boot`, `noboot`, `info`, `help`, ein Programm über seinen Namen | ✓ | ✓ | ✓ | ✓ | ✓ |
| `reset` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `name` (der Name des Boards: DHCP, mDNS) | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `passwd` (das Passwort für telnet) | ✓ | ✓ | ✓ (W) | – | – |
| `wlan`, `wlan set`, `wlan on`, `wlan off`, `wlan clear` | ✓ | ✓ | ✓ (W, Klon) | ✓ | ✓ |
| `wlan scan` | ✓ | ✓ | ✓ (W, Klon) | ✓ | ✓ |
| antwortet auf Ping, auch während ein Programm läuft | ✓ (der WLAN-Dienst auf Kern 1) | ✓ | ✓ (W, Klon: die Konsole im Hintergrund, alle 10 ms) | ✓ (der WLAN-Dienst, alle 10 ms) | ✓ (wie beim C3) |
| die Adresse per DHCP: auch während eines Programms erneuert | – (am Prompt) | – | – (am Prompt) | ✓ | ✓ |
| `name.local` (mDNS) | ✓ (am Prompt) | ✓ (am Prompt) | ✓ (W, Klon: auch während ein Programm läuft) | ✓ (der WLAN-Dienst: auch während ein Programm läuft) | ✓ (wie beim C3) |
| `led(an)` für Programme (die Konsole) | – (Programme schalten GPIO 2) | – (Programme: die RGB-LED an GPIO 48) | ✓ | – | – (`rgb(60, farbe)`: die RGB-LED) |
| aBelle: F9 (über die Konsole), `gpio_output`, `gpio_write` | ✓ | ✓ | ✓ | ✓ | ✓ |
| aBelle: F9 mit Breakpoint, F7, F8, die Variablen | ✓ | ✓ | ✓ | ✓ | ✓ |
| aBelle: Netzwerkprogramme (`ping`, `dns`, `ntp`, `httpget` …) | ✓ | ✓ | ✓ (W, Klon) | ✓ | `scan`, `arpscan`, `ping` ✓, die anderen noch nicht ausprobiert |
| aBelle: der Takt des Kerns (`cpu_clock`, `cpu_clock_khz`; [takt.md](takt.md)) | ✓ (5 kHz … 240 MHz) | ✓ (10 … 240 MHz) | ✓ (1 kHz … 133 bzw. 150 MHz) | ✓ (10 … 160 MHz) | ✓ (156 kHz … 320 MHz) |
| aBelle: `telnetd` | ✓ | ✓ | ✓ (W) | – | – |
| aBelle: `fm`, `webserver` (das Board als Webserver) | ✓ | ✓ | – | – | – |

Ein Pico und ein Pico 2 ohne WLAN-Chip (ohne W) haben keine Befehle für das Netz: `wlan`, `name` und `passwd` sind
dort unbekannt wie jeder Tippfehler, `help` und `info` nennen sie nicht (Prepare Board schreibt die `help.txt` ohne
diese Zeilen).

**Der Klon „Pico W-2023“** hat statt des CYW43439 eines Pico W einen ESP8285 an UART0 (GPIO 0 und 1). Mit der
Firmware von Asmonite darauf (Board Manager > **Install WiFi (ESP8285)**) ist er das WLAN der Konsole wie beim Pico W:
Die Konsole meldet das Board als „Raspberry Pi Pico (WiFi: ESP8285)“, und `wlan`, die Netzwerkprogramme und
`wifi.abel` laufen unverändert. UART0 gehört dann dem ESP8285: Die Konsole spricht nur über das USB-Kabel. Die
Firmware (`wlan/esp8285_fw.asm`) bindet die Bibliotheken des ESP8266 NONOS SDK von Espressif mit `ablink`; sie reicht
die Frames über UART0 (460800 Baud) an die Konsole weiter, ARP, Ping und DHCP macht die Konsole wie beim Pico W.
Die Firmware, mit der der ESP8285 kam (eine AT-Firmware), wird dabei überschrieben.

Dateien kommen auf jedes Board über die Pakete seiner Konsole (Board Manager: Upload File...; Compile and Upload);
keine Konsole hat einen Befehl, um eine Datei einzutippen. Die
Funktionen der Konsole für Programme: ESP32, S3, C3 und S31 haben dieselben zwölf (exit … args), C3 und S31 dazu `wifi_up` (das WLAN an), der S31 `rgb` (die RGB-LED), Pico und Pico 2 dazu `led`
und `wl_call` (ihr WLAN); `file_write` schreibt auch dort eine Datei (wie bei den ESP-Boards), nur `flash_read`
antwortet dort noch mit -1 (ein Programm liest den Flash bei 0x10000000 selbst).
