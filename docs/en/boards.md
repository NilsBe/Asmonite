# The boards of Asmonite: debugging and serial output

Which boards Asmonite runs programs on, how it debugs them (over a debug probe, or with the USB cable alone), and how
what a program writes reaches the PC. The details are in the guide of each board.

| Board | Chip, cores | Debugging over a probe | Debugging without a probe | Serial output to the PC | Guide |
|---|---|---|---|---|---|
| Raspberry Pi Pico 2 | RP2350: Arm Cortex-M33, RISC-V Hazard3 | yes: RAM, flash, pause | no (its USB boot cannot run a debugger) | over the UART of the Debug Probe | [riscv-pico2.md](riscv-pico2.md) |
| Raspberry Pi Pico | RP2040: Arm Cortex-M0+ | yes: RAM, flash, pause | yes, over the USB boot: RAM, no pause | over the UART of the Debug Probe; none over the USB boot | [riscv-pico2.md](riscv-pico2.md), [picoboot.md](picoboot.md) |
| LilyGO T-PicoC3 | RP2040 and ESP32-C3 (RISC-V) | – | yes, both chips (the RP2040 over its USB boot, the C3 over its USB JTAG) | the C3 over its USB port; the RP2040 none | [t-picoc3.md](t-picoc3.md) |
| STM32F103 "Blue Pill" | Arm Cortex-M3 | yes: RAM, flash, pause | no | over the UART of the Debug Probe | [stm32.md](stm32.md) |
| ESP32 | Xtensa LX6 | – | yes, over the USB serial chip of the board (a debug monitor of Asmonite): RAM, flash, pause | yes, UART0 over the same chip: under the debugger too | [esp32.md](esp32.md) |
| ESP32-S3 | Xtensa LX7 | – | yes, over the USB JTAG of the chip: RAM, flash, pause | yes, the COM port of the USB port of the chip | [esp32s3.md](esp32s3.md) |
| ESP32-C3 | RISC-V | – | yes, over the USB JTAG of the chip: RAM, flash, pause | yes, the COM port of the USB port of the chip | [esp32c3.md](esp32c3.md) |
| MangoPi MQ-Pro | Allwinner D1: RISC-V, 64 bits | – | yes, over the FEL mode of the boot ROM: RAM, no pause | only with a USB serial adapter at UART0 | [d1.md](d1.md) |

The debug probe is a CMSIS-DAP probe at the SWD pins: the Raspberry Pi Debug Probe, or a Pico with the `debugprobe`
firmware. "–": the board needs none, its USB port does it.

## The tab Serial

The tab **Serial** next to the output window is a small terminal for the COM ports. Under the debugger it shows what
the program writes by itself:

- **ESP32:** the debug monitor of Asmonite has the COM port of the board; the tab shows the output of the program,
  Connect is off while the session lasts.
- **ESP32-S3, ESP32-C3:** the tab connects to the COM port of the chip when the program is loaded (the reset into
  the boot ROM and the flash use that port before); Connect stays usable.
- **Pico 2, Pico, Blue Pill over the Raspberry Pi Debug Probe:** the tab connects to the COM port of the probe (its
  connector "U", a UART) when the program is loaded. The cable: RX of the probe at the TX pin of the board (GP0 of the
  Pico, PA9 of the Blue Pill), GND at GND.
- **The Pico over its USB boot, the D1:** no serial output of their own; with a USB serial adapter at their UART
  the tab shows it after Connect.
- **The RP2040 of the T-PicoC3:** none (its UART goes to the ESP32-C3 of the board).

The boards with serial output have an example that writes "Hello, world!" this way: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (a line at each change of the LEDs),
`examples/pico2/hello_uart_ram.asm` and `hello_uart_arm_ram.asm`, `examples/pico/hello_uart_ram.asm`,
`examples/stm32/hello_uart_ram.asm`.
