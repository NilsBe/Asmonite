# Der LilyGO T-PicoC3 mit Asmonite

Der T-PicoC3 von LilyGO hat zwei Chips auf einem Board: einen **RP2040** (den Chip des Raspberry Pi Pico, zwei Arm
Cortex-M0+), der das Display ansteuert (1,14 Zoll, ST7789, 135 x 240 Pixel), und einen **ESP32-C3** (ein RISC-V-Kern).
Beide hängen am selben USB-C-Anschluss: **Wie herum der Stecker steckt, wählt den Chip.** Die LED neben dem Anschluss
zeigt, welcher antwortet: blau für den RP2040, grün für den ESP32-C3.

Asmonite debuggt beide, jeweils mit dem einen USB-Kabel, ohne Debug-Probe. Diese Seite sagt, was auf welcher Seite
geht; die Einzelheiten stehen in den Anleitungen der beiden Chips: [picoboot.md](picoboot.md) für den RP2040 über
seinen USB-Boot, [esp32c3.md](esp32c3.md) für den ESP32-C3.

## Auf einen Blick

| | RP2040 (LED blau) | ESP32-C3 (LED grün) |
|---|---|---|
| Debuggen ohne Probe | ja, über den USB-Boot (BOOTSEL, PICOBOOT): Programme im RAM | ja, über den USB-JTAG des Chips: RAM und Flash |
| Breakpoints, Schritte, Register, Speicher | ja | ja |
| Pause eines laufenden Programms | **nein** (das Boot-ROM wartet auf das Programm) | ja |
| Programm im Flash | nicht über den USB-Boot (eine UF2-Datei auf das Laufwerk `RPI-RP2` tut es) | ja (`.target esp32c3 flash`) |
| Serielle Ausgabe zum PC | **nein** (siehe unten) | ja, der COM-Port des Chips: der Reiter Serial |
| Einmal einrichten | *Debug targets > Raspberry Pi Pico (RP2040) > Set up the USB boot* | *Debug targets > ESP32-C3 > Set up the USB JTAG* |
| `.target` | `pico` | `esp32c3` |

## Die Seite des RP2040

Drehe den Stecker, bis die LED blau ist. Für eine Sitzung muss der RP2040 in seinem **USB-Boot** sein: **BOOT**
halten, **RUN** drücken, BOOT loslassen; Windows zeigt das Laufwerk `RPI-RP2`. Dann F9 oder F7 wie bei einem Pico ohne
Probe ([picoboot.md](picoboot.md)): Asmonite lädt das Programm ins RAM bei `0x20000000` und debuggt es über das
Boot-ROM. Ein laufendes Programm lässt sich so nicht anhalten: Setze einen Breakpoint, bevor es in eine Schleife
läuft. Ein Programm, das zurückkehrt (`bx lr`), beendet die Sitzung, und das Board ist bereit für das nächste F9.

Die Pins des Boards (aus der Dokumentation von LilyGO, mit den Beispielen geprüft):

| Was | GPIO des RP2040 |
|---|---|
| Display ST7789: SCLK, MOSI, CS, DC, RST, Hintergrundlicht | 2, 3, 5, 1, 0, 4 |
| Strom des Displays (PWR_ON) | 22 |
| Die zwei Tasten (gedrückt = low, Pull-up an) | 6, 7 |
| Rote LED | 25 |

Die Beispiele in `examples/t-picoc3/`:

| Datei | Was es tut |
|---|---|
| `display_ram.asm` | Füllt das Display mit einer Farbe (das Einrichten von SPI und ST7789, Schritt für Schritt mit F7) |
| `lines_ram.asm` | Ein weißer Rahmen und bunte Linien auf Schwarz; kehrt zurück |
| `text_ram.asm` | Text in einer eigenen Schrift und ein Zähler, der hochzählt; eine Taste beendet es |

Der RP2040 hat über USB keinen eigenen seriellen Port: Im USB-Boot ist sein USB-Anschluss das Laufwerk und PICOBOOT
des Boot-ROMs, sonst nichts, und ein Programm bräuchte für einen COM-Port einen eigenen USB-Stack. Sein UART ist auf
diesem Board mit dem ESP32-C3 verbunden, nicht mit dem USB-Anschluss. Was das Programm schreibt, erreicht den PC also
nicht; zeige es auf dem Display an oder sieh es dir an einem Breakpoint im Speicherfenster an.

## Die Seite des ESP32-C3

Drehe den Stecker, bis die LED grün ist. Richte seinen USB-JTAG einmal ein (*Debug targets > ESP32-C3 > Set up the
USB JTAG*); dann geht alles wie in [esp32c3.md](esp32c3.md): F7 und F9, Breakpoints, Schritte, Pause, ein Programm im
RAM oder im Flash. Der Reiter Serial zeigt, was das Programm über den USB-Anschluss des Chips schreibt (das Peripheral
USB Serial/JTAG); er verbindet sich von selbst mit dem COM-Port, wenn der Debugger das Programm geladen hat.

Nur drei GPIOs des ESP32-C3 kommen an die Stiftleiste, und er spricht über einen UART mit dem RP2040: Die Beispiele
in `examples/esp32c3/`, die Pins ansteuern (die LEDs an GPIO 12 und 13, die RGB-LED an GPIO 8), sind für andere
Boards. `examples/esp32c3/sum_ram.asm` benutzt keinen Pin und läuft hier.

## Grenzen

- Immer nur ein Chip: Die Steckrichtung entscheidet, eine Sitzung auf dem anderen Chip braucht den gedrehten Stecker.
- Der RP2040 über den USB-Boot: nur RAM, keine Pause, keine serielle Ausgabe (siehe oben).
- Die Belegung der Pins des ESP32-C3 auf diesem Board ist nicht geprüft: Steuere seine Pins erst nach einem Blick in
  die Dokumentation von LilyGO an (github.com/Xinyuan-LilyGO/T-PicoC3).
