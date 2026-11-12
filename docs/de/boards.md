# Die Boards von Asmonite: Debuggen und serielle Ausgabe

Auf welchen Boards Asmonite Programme laufen lässt, wie es sie debuggt (über eine Debug-Probe oder mit dem USB-Kabel
allein) und wie das, was ein Programm schreibt, zum PC kommt. Die Einzelheiten stehen in der Anleitung jedes Boards.

| Board | Chip, Kerne | Debuggen über eine Probe | Debuggen ohne Probe | Serielle Ausgabe zum PC | Anleitung |
|---|---|---|---|---|---|
| Raspberry Pi Pico 2 | RP2350: Arm Cortex-M33, RISC-V Hazard3 | ja: RAM, Flash, Pause | nein (sein USB-Boot kann keinen Debugger ausführen) | über den UART der Debug Probe | [riscv-pico2.md](riscv-pico2.md) |
| Raspberry Pi Pico | RP2040: Arm Cortex-M0+ | ja: RAM, Flash, Pause | ja, über den USB-Boot: RAM, keine Pause | über den UART der Debug Probe; über den USB-Boot keine | [riscv-pico2.md](riscv-pico2.md), [picoboot.md](picoboot.md) |
| LilyGO T-PicoC3 | RP2040 und ESP32-C3 (RISC-V) | – | ja, beide Chips (der RP2040 über seinen USB-Boot, der C3 über seinen USB-JTAG) | der C3 über seinen USB-Anschluss; der RP2040 keine | [t-picoc3.md](t-picoc3.md) |
| STM32F103 „Blue Pill“ | Arm Cortex-M3 | ja: RAM, Flash, Pause | nein | über den UART der Debug Probe | [stm32.md](stm32.md) |
| ESP32 | Xtensa LX6 | – | ja, über den USB-Seriell-Chip des Boards (ein Debug-Monitor von Asmonite): RAM, Flash, Pause | ja, UART0 über denselben Chip: auch unter dem Debugger | [esp32.md](esp32.md) |
| ESP32-S3 | Xtensa LX7 | – | ja, über den USB-JTAG des Chips: RAM, Flash, Pause | ja, der COM-Port des USB-Anschlusses des Chips | [esp32s3.md](esp32s3.md) |
| ESP32-C3 | RISC-V | – | ja, über den USB-JTAG des Chips: RAM, Flash, Pause | ja, der COM-Port des USB-Anschlusses des Chips | [esp32c3.md](esp32c3.md) |
| MangoPi MQ-Pro | Allwinner D1: RISC-V, 64 Bit | – | ja, über den FEL-Modus des Boot-ROMs: RAM, keine Pause | nur mit einem USB-Seriell-Adapter an UART0 | [d1.md](d1.md) |

Die Debug-Probe ist eine CMSIS-DAP-Probe an den SWD-Pins: die Raspberry Pi Debug Probe oder ein Pico mit der Firmware
`debugprobe`. „–“: Das Board braucht keine, sein USB-Anschluss erledigt das.

## Der Reiter Serial

Der Reiter **Serial** neben dem Ausgabefenster ist ein kleines Terminal für die COM-Ports. Unter dem Debugger zeigt er
von selbst, was das Programm schreibt:

- **ESP32:** Der Debug-Monitor von Asmonite hat den COM-Port des Boards; der Reiter zeigt die Ausgabe des Programms,
  Connect ist gesperrt, solange die Sitzung dauert.
- **ESP32-S3, ESP32-C3:** Der Reiter verbindet sich mit dem COM-Port des Chips, wenn das Programm geladen ist (der
  Reset ins Boot-ROM und der Flash brauchen den Port vorher); Connect bleibt benutzbar.
- **Pico 2, Pico, Blue Pill über die Raspberry Pi Debug Probe:** Der Reiter verbindet sich mit dem COM-Port der Probe
  (ihr Stecker „U“, ein UART), wenn das Programm geladen ist. Das Kabel: RX der Probe an den TX-Pin des Boards (GP0 des
  Pico, PA9 der Blue Pill), GND an GND.
- **Der Pico über seinen USB-Boot, der D1:** keine eigene serielle Ausgabe; mit einem USB-Seriell-Adapter an ihrem
  UART zeigt sie der Reiter nach Connect.
- **Der RP2040 des T-PicoC3:** keine (sein UART geht zum ESP32-C3 des Boards).

**Ohne Debugger verbindet sich der Reiter von selbst** mit einem Board von Espressif (ein ESP32 hinter seinem
USB-Seriell-Chip zuerst, sonst der USB-Anschluss eines ESP32-S3 oder ESP32-C3): beim Start von Asmonite und sobald du
es einsteckst. Er hält den Port; das Menü Board, der Debugger und das Boot-ROM bekommen ihn, solange sie ihn brauchen,
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
Breakpoint startet F9 den Debugger wie bisher; ein Programm für den Flash (`.target esp32 flash`) ebenso.

**Updates von selbst:** Vor dem Start vergleicht Asmonite die Konsole im Flash mit seiner eigenen (über ihre CRC-32,
in wenigen Millisekunden). Stammt sie von einer anderen Version von Asmonite, schreibt es seine eigene über das
Boot-ROM (ESP32 etwa 11 Sekunden, S3 etwa 2), danach ein anderes WLAN-Paket, und startet dann das Programm. Die
Dateien und das Netz des Boards bleiben.

**Keine Konsole:** Der Kopf des Reiters sagt es, wenn das Boot-ROM kein Programm im Flash findet (ein leeres Board)
oder nach dem Start drei Sekunden lang keine Konsole grüßt (eine andere Firmware wie MicroPython, ein Programm von
Write to Flash and Run), und zeigt den Knopf **Prepare Board**. Antwortet bei F9 keine Konsole, fragt Asmonite nach:
Prepare Board, oder das Programm wie bisher mit dem Debugger starten. Prepare Board (auch im Menü Board) schreibt die
Konsole über das Boot-ROM in den Flash und legt ihr Dateisystem an, wenn noch keins da ist; Dateien der Konsole
bleiben.

Die Boards mit serieller Ausgabe haben ein Beispiel, das auf diesem Weg „Hello, world!“ schreibt: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (eine Zeile bei jedem Wechsel der LEDs),
`examples/pico2/hello_uart_ram.asm` und `hello_uart_arm_ram.asm`, `examples/pico/hello_uart_ram.asm`,
`examples/stm32/hello_uart_ram.asm`.
