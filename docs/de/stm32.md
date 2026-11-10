# Die STM32F103 „Blue Pill“ mit Asmonite

Die Blue Pill ist ein kleines Board mit einem STM32F103C8 von ST: ein Arm Cortex-M3 (höchstens 72 MHz, nach einem
Reset 8 MHz), 20 KB RAM und 64 oder 128 KB Flash. Asmonite assembliert seinen Code (`.arch thumb`,
`.target stm32f103`), lädt ein Programm in sein RAM oder schreibt es in seinen Flash und debuggt es über eine
Debug-Probe: Breakpoints, Schritte, Pause, die Register, der Speicher. Was das Programm über USART1 sendet, erscheint
im Reiter Serial, über dieselbe Probe.

Getestet mit einer Blue Pill mit einem originalen STM32F103C8 (Geräte-ID 0x410, 128 KB Flash) und der Raspberry Pi
Debug Probe.

## Was du brauchst

- Eine Blue Pill (oder ein anderes Board mit dem STM32F103).
- Eine **Debug-Probe** mit CMSIS-DAP: die Raspberry Pi Debug Probe oder einen Pico mit der Firmware `debugprobe`. Die
  Blue Pill hat keinen eigenen Debugger, und Asmonite hat für sie keinen Weg ohne Probe (das Boot-ROM des STM32F103
  lädt Programme nur über seinen UART, den Asmonite nicht benutzt).
- Ein USB-Kabel für den Strom des Boards (an seinem eigenen USB-Anschluss), Windows 10 oder 11.

## Anschließen

Die vier Pins am Ende des Boards (3V3, SWDIO oder IO, SWCLK oder CLK, GND) nehmen das SWD-Kabel der Probe, ihr
Stecker „D“:

| Probe, Stecker „D“ | Blue Pill |
|---|---|
| SWCLK (orange) | CLK |
| SWDIO (gelb) | IO |
| GND (schwarz) | GND |

**3V3 bleibt frei**: Das Board bekommt seinen Strom über seinen eigenen USB-Anschluss. **Debug > Debug targets >
STM32F103 (Blue Pill) > Test the connection** zeigt, ob der Chip antwortet: seine Geräte-ID und die Größe seines
Flash.

## Ein Programm im RAM

```asm
.target stm32f103
.arch thumb
.imagebase 0x20000000

_start:
    ...
```

F7 (Einzelschritt) oder F9 (ausführen) lädt das Programm ins RAM bei `0x20000000` und hält bei `_start` (ohne
`_start`: beim ersten Byte). Dann gehen F7 und F8 Zeile für Zeile (*Step over* kennt `bl` und `blx`), F5 setzt einen
Breakpoint, F9 läuft bis zum nächsten, **Debug > Pause** hält ein laufendes Programm an, wo es gerade ist, Stop
beendet die Sitzung. Rechts stehen die Register `R0` bis `R12`, `SP`, `LR`, `PC`, `XPSR` mit seinen Flags. Der
Stackzeiger beginnt am Ende des RAM (`0x20005000`). Im RAM setzt der Debugger Breakpoints als `bkpt`-Befehle (die
Speicheransicht zeigt sie nicht); nach einem Reset läuft wieder das Programm aus dem Flash.

Der Kern läuft nach einem Reset von seinem internen 8-MHz-Oszillator (HSI).

## Ein Programm im Flash

```asm
.target stm32f103
.arch thumb
.imagebase 0x08000000

vectors:
    dd 0x20005000           ; der Stackzeiger beim Start: das Ende des RAM
    dd _start + 1           ; die Startadresse (+1: Thumb-Code)
_start:
    ...
```

Ein Programm für den Flash beginnt mit der Vektortabelle des Cortex-M3. F7 oder F9 schreiben es über die Probe, mit
dem Flash-Controller des Chips, nur die Seiten zu 1 KB, die sich unterscheiden; dann wird der Chip zurückgesetzt, und
der Debugger hält bei `_start` (F7) oder lässt es laufen (F9). Im Flash hat er 6 Hardware-Breakpoints. Nach einem
Reset oder dem Wiedereinschalten startet das Board das Programm von selbst.

Bevor es etwas schreibt, liest Asmonite die Geräte-ID des Chips: Auf einem Board, das kein STM32F103 ist (oder einem
Nachbau, der mit einer anderen ID antwortet), schreibt es nichts und sagt, warum.

## Die serielle Ausgabe über die Debug Probe

Die Raspberry Pi Debug Probe hat auch einen seriellen Port: Ihr Stecker **„U“** ist ein UART mit einem eigenen
COM-Port am PC.

| Probe, Stecker „U“ | Blue Pill |
|---|---|
| RX (Eingang der Probe; gelb) | PA9 (TX von USART1) |
| TX (Ausgang der Probe; orange) | PA10 (RX von USART1) |
| GND (schwarz) | G |

Hat eine Sitzung über die Probe das Programm geladen, verbindet sich der Reiter **Serial** neben dem Ausgabefenster
von selbst mit diesem COM-Port und zeigt, was das Board sendet (mit der Baudrate aus dem Reiter, 115200 von Haus
aus). Debugger und Terminal kommen sich nicht in die Quere: Connect und Disconnect bleiben benutzbar.
`examples/stm32/hello_uart_ram.asm` schreibt etwa einmal pro Sekunde „Hello, world!“ mit 115200 Baud: Es schaltet die
Takte von Port A und USART1 ein, macht PA9 zu einem Ausgang von USART1 und stellt die Baudrate für die 8 MHz des HSI
ein.

Die Probe schickt, was sie empfängt, nur an ein Terminal mit eingeschalteter Leitung DTR; der Reiter Serial tut das.
In einem anderen Terminalprogramm: DTR an. Ohne Probe tut ein USB-Seriell-Adapter an PA9 und GND dasselbe.

## Die Beispiele

| Datei | Was es tut |
|---|---|
| `examples/stm32/blink_ram.asm` | Die LED an PC13 an und aus, im RAM |
| `examples/stm32/blink_flash.asm` | Dasselbe im Flash, mit der Vektortabelle |
| `examples/stm32/hello_uart_ram.asm` | „Hello, world!“ einmal pro Sekunde über USART1 (PA9): der Reiter Serial zeigt es über die Probe |

Das ARM-Assembler-Tutorial auf asmonite.com hat auch Kästen für die Blue Pill, mit seinen Beispielen in
`tutorial/arm/bluepill/`.

## Wenn etwas nicht geht

| Meldung oder Anzeichen | Was zu tun ist |
|---|---|
| „The board does not answer over SWD“ | Die drei Drähte (sie lockern sich leicht an den Pins), der Strom des Boards über seinen USB-Anschluss |
| „The board is no STM32F103 …“ | Ein anderes Board an der Probe, oder ein Nachbau des Chips mit einer anderen ID: Es wurde nichts geschrieben |
| Der Reiter Serial zeigt nichts | Das Kabel am Stecker „U“: RX der Probe an PA9; in einem anderen Terminal DTR an |
| „COM6 is open in another program“ (im Reiter Serial) | Ein anderes Programm hat den COM-Port der Probe (ein Terminal): schließen |

## Grenzen

- Debuggen braucht die Probe: Der STM32F103 hat keinen USB-Boot, den Asmonite nutzen könnte.
- Der Kern läuft mit 8 MHz (HSI); ein Programm, das 72 MHz will, schaltet die PLL selbst ein.
- Nur ein Board an der Probe; nur der STM32F103 (kein anderer STM32).
