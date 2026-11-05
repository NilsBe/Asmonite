# Der ESP32-C3 mit Asmonite

Der ESP32-C3 von Espressif hat einen RISC-V-Kern (RV32IMC, 160 MHz) und einen USB-Anschluss, der zugleich serieller
Port und JTAG-Debugger ist. Asmonite nutzt beides: Es debuggt ein Programm im RAM des Chips und schreibt es in den
Flash, **mit einem USB-Kabel, ohne Debug-Probe, ohne OpenOCD und ohne ESP-IDF**.

Getestet mit dem LuatOS ESP32C3-CORE (die einfache Version mit einem USB-C-Anschluss direkt am Chip; 4 MB Flash im
DIO-Modus; LEDs an GPIO 12 und 13) und mit einem Board mit zwei USB-C-Anschlüssen und einer RGB-LED WS2812 an GPIO 8
(ein Anschluss geht an den Chip, der andere über einen CH340 an UART0). Andere Boards, deren USB-Anschluss direkt zum Chip geht (GPIO 18 und 19), sollten
genauso gehen; Boards mit eigenem USB-Seriell-Chip (CP2102, CH340, CH343) haben keinen USB-JTAG.

## Was du brauchst

- Ein Board mit ESP32-C3, dessen USB-Anschluss der des Chips ist. Im Geräte-Manager erscheint es als
  „USB JTAG/serial debug unit“ und als COM-Port.
- Windows 10 oder 11.

## Einmal einrichten: der USB-JTAG

Windows gibt dem JTAG-Teil des USB-Anschlusses von selbst den Treiber WinUSB, aber nicht den Eintrag, den Programme
zum Öffnen brauchen. In Asmonite: **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG**. Windows fragt einmal nach
Administratorrechten; danach sollte **Test the connection** melden, dass das Board antwortet. Windows merkt sich das
für jedes Board (es erkennt das Board an seiner Seriennummer, der MAC-Adresse des Chips), an jedem USB-Anschluss
des Rechners: Ein zweites Board braucht den Knopf noch einmal.

## Ein Programm im RAM

```asm
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
    ...
```

Drück F9 (Ausführen) oder F7 (Einzelschritt). Der Debugger setzt den Chip zurück und hält ihn sofort an, bevor die
Firmware im Flash startet, lädt das Programm nach `0x40380000` und hält bei `_start`. Dann gehen: Schritte (F7, F8),
Haltepunkte (F5; der Kern hat Hardware-Haltepunkte dafür), die Register `x0` .. `x31` und `pc`, der Speicher. Nach
einem Reset (die RESET-Taste) läuft wieder die Firmware des Flash.

Warum der Reset: Firmware wie LuatOS oder ESP-IDF schaltet den Speicherschutz des Chips ein; dann lässt sich bis zum
nächsten Reset nichts mehr ins RAM des Codes schreiben. Angehalten, bevor die Firmware startet, ist das ganze RAM von
`0x40380000` bis `0x403BFFFF` (256 KB) frei für das Programm.

## Ein Programm im Flash

```asm
.target esp32c3 flash
.arch riscv32
.imagebase 0x40380000
```

F9 oder F7 schreiben das Programm jetzt in den Flash an Adresse 0, als Image des Boot-ROM: Das Boot-ROM lädt es bei
jedem Start ins RAM nach `0x40380000`. Geschrieben wird über den **seriellen Port** des Chips (den COM-Port des Boards),
mit dem Protokoll seines Boot-ROM; in diesem Moment darf kein Terminalprogramm (PuTTY o. ä.) den Port offen haben.
Danach lässt der Debugger das Boot-ROM das Programm starten und hält bei `_start` – du siehst das Programm also genau
so, wie es auch ohne Debugger startet. Es startet außerdem nach jedem Reset von selbst.

Das ersetzt die Firmware, die vorher im Flash war (beim LuatOS-Board: LuatOS; sie lässt sich beim Hersteller wieder
herunterladen).

Ein Programm im Flash muss die **Watchdogs** selbst abschalten: Das Boot-ROM lässt zwei davon an, und sie würden den
Chip nach einigen Sekunden zurücksetzen. `examples/esp32c3/blink_flash.asm` zeigt, wie (ein paar Zeilen bei `_start`).

## Die Beispiele

| Datei | Was es tut |
|---|---|
| `examples/esp32c3/blink_ram.asm` | Die LEDs an GPIO 12 und 13 blinken abwechselnd; jeder Wechsel ist eine Zeile auf dem USB-Seriell-Port (COM-Port): `LED 12 on`, `LED 13 on` |
| `examples/esp32c3/blink_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs am Anfang |
| `examples/esp32c3/rgb_ws2812_ram.asm` | Für Boards mit einer RGB-LED WS2812 an GPIO 8: abwechselnd rot, grün und blau, und für jede Farbe eine Zeile auf dem USB-Seriell-Port. Die 24 Bit der Farbe misst der Zykluszähler des Kerns; das Programm stellt den Takt des Kerns von 20 auf 40 MHz |
| `examples/esp32c3/rgb_ws2812_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs am Anfang |
| `examples/esp32c3/hello_uart_ram.asm` | „Hello, world!“ auf UART0 (der Pin GPIO 21, nicht der USB-Anschluss: ein USB-Seriell-Adapter dort zeigt es; bei Boards mit einem zweiten USB-Anschluss mit CH340 dieser Anschluss) |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: die Header von ESP-IDF und das
ESP32-C3 Technical Reference Manual.

## Die Ausgabe auf dem USB-Seriell-Port

Der USB-Anschluss des Chips ist auch ein serieller Port (COM-Port); ein Programm schreibt ein Byte in das Register
`0x60043000` (`USB_SERIAL_JTAG_EP1`) und schickt ab, was dort steht, mit Bit 0 von `0x60043004` (`EP1_CONF`,
`WR_DONE`). Bit 1 von `EP1_CONF` sagt, dass der Puffer Daten nimmt. Liest kein Programm auf dem PC den Port, läuft der
Puffer voll; die Beispiele lassen die Zeile dann fallen, statt ewig zu warten. Jedes Terminal zeigt die Zeilen (die
Geschwindigkeit ist auf diesem Port egal).

## Wenn etwas nicht geht

| Meldung oder Zeichen | Was tun |
|---|---|
| „the ESP32-C3 is plugged in, but ... has not given its USB JTAG an interface“ | Debug targets > ESP32-C3 > Set up the USB JTAG (einmal je Board) |
| „COM8 is open in another program“ | Das Terminal (PuTTY …) schließen, dann noch einmal F9 |
| „the core of the ESP32-C3 hangs“ | RESET am Board drücken, dann noch einmal |
| Das Board antwortet gar nicht | BOOT halten, RESET drücken, BOOT loslassen: Der Chip wartet in seinem Boot-ROM; dann F9 |
| Nichts auf dem COM-Port | Ist das Programm für den USB-Port (`blink_ram.asm`) oder für UART0 (`hello_uart_ram.asm`)? |

## Grenzen

- Ein Kern (der ESP32-C3 hat einen), das RAM von `0x40380000` bis `0x403BFFFF`.
- Der Assembler kennt die komprimierten Befehle (C) noch nicht; der Disassembler liest sie.
- Das Flash-Image ist für 4 MB Flash im DIO-Modus mit 40 MHz; WLAN und Bluetooth brauchen die Firmware von Espressif.
- Wie der Chip den USB-JTAG macht: das Protokoll aus `esp_usb_jtag.c` von OpenOCD und die RISC-V-Debug-Spec 0.13.
