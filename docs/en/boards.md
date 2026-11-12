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

**Without the debugger the tab connects by itself** to a board of Espressif (an ESP32 behind its USB serial chip
first, else the USB port of an ESP32-S3 or ESP32-C3): when Asmonite starts and as soon as you plug the board in. It
holds the port; the menu Board, the debugger and the boot ROM get it while they need it, then the tab connects again.
**Disconnect** lets the port go, for another terminal say; then the tab stays off until you unplug the board or press
Connect. When the console of Asmonite says hello after a reset ("Asmonite console 2 for the ESP32 …"), the header of
the tab shows the chip, the console and the time of the start. Until then it shows what the USB tells ("ESP32 at
COM14 (Silicon Labs CP210x …)", "ESP32-S3 or ESP32-C3 at COM21": both have the same USB id); the tab sends nothing to
find out more, a program that runs would take it as its input. When a debug session on the ESP32 went over the boot
ROM (no console on the board), the tab resets the board afterwards; over the console it is there anyway. **Stop**
sends Ctrl+C: the console ends the program it started.

**F9 over the console (ESP32, ESP32-S3):** when the tab is connected to the board of the program (`target "esp32"` or
`.target esp32`, `esp32s3` for the S3) and the program has no breakpoint, F9 puts it into the RAM over the console and
starts it there: no download mode, no BOOT button, no reset. What it writes shows in the tab, Stop ends it, and the
console says when it has ended. If a program runs, F9 stops it with Ctrl+C first. With a breakpoint F9 starts the
debugger as before; so does a program for the flash (`.target esp32 flash`).

**Updates by themselves:** before the start Asmonite compares the console in the flash with its own (by its CRC-32,
within milliseconds). When it comes from another version of Asmonite, Asmonite writes its own over the boot ROM
(ESP32 about 11 seconds, S3 about 2), then another WiFi package, and then starts the program. The files and the
network of the board stay.

**No console:** the header of the tab says so when the boot ROM finds no program in the flash (an empty board) or no
console says hello within three seconds after a start (another firmware such as MicroPython, a program of Write to
Flash and Run), and shows the button **Prepare Board**. When no console answers at F9, Asmonite asks: Prepare Board,
or start the program with the debugger as before. Prepare Board (also in the menu Board) writes the console into the
flash over the boot ROM and makes its file system when there is none; files of the console stay.

The boards with serial output have an example that writes "Hello, world!" this way: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (a line at each change of the LEDs),
`examples/pico2/hello_uart_ram.asm` and `hello_uart_arm_ram.asm`, `examples/pico/hello_uart_ram.asm`,
`examples/stm32/hello_uart_ram.asm`.
