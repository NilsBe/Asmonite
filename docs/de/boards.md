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

Die Boards mit serieller Ausgabe haben ein Beispiel, das auf diesem Weg „Hello, world!“ schreibt: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (eine Zeile bei jedem Wechsel der LEDs),
`examples/pico2/hello_uart_ram.asm` und `hello_uart_arm_ram.asm`, `examples/pico/hello_uart_ram.asm`,
`examples/stm32/hello_uart_ram.asm`.
