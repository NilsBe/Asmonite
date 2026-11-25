# The boards of Asmonite: debugging and serial output

Which boards Asmonite runs programs on, how it debugs them (over a debug probe, or with the USB cable alone), and how
what a program writes reaches the PC. The details are in the guide of each board.

> **The examples of this page:** the examples in assembly (`examples/<board>/…`) and some in aBelle that this page names
> are being gone through again and come into the folder `examples/` one by one; until then they are not in the ZIP and
> not in the public repository. What is released already is in [examples/README.md](../../examples/README.md).

| Board | Chip, cores | Debugging over a probe | Debugging without a probe | Serial output to the PC | Guide |
|---|---|---|---|---|---|
| Raspberry Pi Pico 2 | RP2350: Arm Cortex-M33, RISC-V Hazard3 | yes: RAM, flash, pause | yes, the Arm cores over the debug monitor of the console of Asmonite at the USB cable: RAM, pause | over the UART of the Debug Probe; with the console also over the USB cable | [riscv-pico2.md](riscv-pico2.md) |
| Raspberry Pi Pico | RP2040: Arm Cortex-M0+ | yes: RAM, flash, pause | yes, over the debug monitor of the console at the USB cable: RAM, pause; or over the USB boot: RAM, no pause | over the UART of the Debug Probe; with the console also over the USB cable | [riscv-pico2.md](riscv-pico2.md), [picoboot.md](picoboot.md) |
| LilyGO T-PicoC3 | RP2040 and ESP32-C3 (RISC-V) | – | yes, both chips (the RP2040 over its USB boot, the C3 over its USB JTAG) | the C3 over its USB port; the RP2040 none | [t-picoc3.md](t-picoc3.md) |
| STM32F103 "Blue Pill" | Arm Cortex-M3 | yes: RAM, flash, pause | no | over the UART of the Debug Probe | [stm32.md](stm32.md) |
| ESP32 | Xtensa LX6 | – | yes, over the USB serial chip of the board (a debug monitor of Asmonite): RAM, flash, pause | yes, UART0 over the same chip: under the debugger too | [esp32.md](esp32.md) |
| ESP32-S3 | Xtensa LX7 | – | yes, over the USB JTAG of the chip: RAM, flash, pause | yes, the COM port of the USB port of the chip | [esp32s3.md](esp32s3.md) |
| ESP32-C3 | RISC-V | – | yes, over the USB JTAG of the chip: RAM, flash, pause | yes, the COM port of the USB port of the chip | [esp32c3.md](esp32c3.md) |
| ESP32-S31 | RISC-V (two HP cores, an LP core) | – | yes, core 0 over the USB JTAG of the chip: RAM (the console of Asmonite starts the program), pause | yes, the COM port of the USB port of the chip | (this page) |
| MangoPi MQ-Pro | Allwinner D1: RISC-V, 64 bits | – | yes, over the FEL mode of the boot ROM: RAM, no pause | only with a USB serial adapter at UART0 | [d1.md](d1.md) |

The debug probe is a CMSIS-DAP probe at the SWD pins: the Raspberry Pi Debug Probe, or a Pico with the `debugprobe`
firmware. "–": the board needs none, its USB port does it.

## The Board Manager

**Board > Board Manager** shows the boards plugged in and, for each, only what can be done with it. On the left are
the boards (**Scan** looks for them anew) and under them a photo of the board chosen. On the right is what Asmonite knows
about the board, for an ESP32, an ESP32-S3 and the Pico 2 or the Pico behind the debug probe the files of the console under it,
at the bottom the buttons for the board.

When it opens, the Board Manager reads only what does not disturb the board: what Windows tells about the USB device
(id, maker, port), the hello of the console of Asmonite (chip, version of the console, flash; "Console: v5 (current:
v5)": the number `console_version()` gives, and the one of the console of this Asmonite; another console: Prepare
Board writes the current one), on an ESP32, S3, C3 and S31 the version of the WiFi service in its package ("WiFi
service: v10 (current: v11)": Install WiFi writes the current one; a right click copies one line or all of
them; on the line WiFi it sets the network of the board, switches WiFi on or off, forgets the network and sets the
name of the board, on the line telnet its password: Set Network... lists the networks this PC sees, on the C3, S31 and the Pico W also the ones the
board sees, and From Windows fills in the password Windows has saved), over the debug probe
the chip, its revision, the flash and the cores that run, without halting the program, and for the Pico in its USB
boot the chip and the flash over PICOBOOT. More about an ESP32 without a console only its boot ROM tells: **Read
Chip** reads the chip, revision, MAC, crystal and flash, and restarts the board for it. On the ESP32-S3 it also names
the PSRAM in the chip (modules such as N16R8: 8 MB), which Espressif writes into the eFuses; the PSRAM of an ESP32
WROVER, a chip of its own next to the ESP32, the eFuses do not know.

The files: a right click on a file shows what can be done with it: for a program **Run**, for a text file **Open in
Editor** (both also Enter or a double click; the editor gets a copy, a change stays on the PC), **Autostart**,
**Download**, **Delete** (also Del); and, on the empty list too, **Upload File** and **Refresh** (F5). Files dragged
from the Explorer onto the window go onto the board. **Examples...** opens an example for the board chosen: from
`examples\common` (for every board), from the folder of the board when it has one (`examples\esp32` ...), or the
overview of the examples. Asmonite opens it in the editor and, for aBelle, sets **Project > aBelle for** to the board of
the tab Serial: F9 then runs it there.

| Board | Buttons |
|---|---|
| ESP32, ESP32-S3 | the files: **Upload File**, **Refresh**, in the context menu of a file **Run**, **Autostart**, **Download**, **Delete**; the board: **Reset**, **Chip Details**, **Prepare Board**, **Install WiFi**, **Format**, **Erase Flash** |
| ESP32-S31 (RISC-V) at the USB port of the chip | as on the ESP32-C3 (the console of `boards/esp32s31`, in the flash at 0x2000), with its WiFi (Install WiFi); **Chip Details** names the chip, revision, MAC, PSRAM, crystal and flash. Behind a USB serial chip Asmonite takes it for an ESP32 until Chip Details finds it |
| ESP32-S3 or ESP32-C3, not known yet (both have the same USB id, no console answers) | **Chip Details**, **Prepare Board** |
| ESP32-C3 | as the ESP32 and the ESP32-S3 once its console runs (its console says it is a C3: packet H); without it **Reset**, **Chip Details**, **Prepare Board**, **Erase Flash** (over its boot ROM); more in [esp32c3.md](esp32c3.md) |
| Pico 2 (Arm cores) and Pico behind the debug probe | the files of the console as for the ESP32 (**Upload File**, **Refresh**, in the context menu **Run**, **Autostart**, **Download**, **Delete**); the board: **Reset**, **Prepare Board** (the console into the flash over the probe), **Format**, **Erase Flash**, the Pico 2 also **RISC-V Cores**; more in [riscv-pico2.md](riscv-pico2.md) |
| Pico 2 (RISC-V cores), Blue Pill behind the debug probe | **Reset**, **Erase Flash**; the Pico 2 also **Arm Cores** |
| the clone "Pico W-2023" (an RP2040 with an ESP8285 instead of the CYW43439), the console over the USB cable | the files of the console as on the Pico; the board: **Prepare Board**, **Install WiFi (ESP8285)** (the firmware of Asmonite into the ESP8285, about 40 s; the board plugged in with its BOOT button held, the question says how) |
| Pico in its USB boot (BOOTSEL) | **Start Program** (leaves the USB boot, the program in the flash starts), **Erase Flash** |
| Pico 2 in its USB boot (BOOTSEL) | **Arm Cores**, **RISC-V Cores** (over its drive RP2350) |
| a board Asmonite does not know | no buttons; only what Windows tells about it |

**RISC-V Cores** and **Arm Cores** switch the Pico 2: the boot ROM starts the cores the program in the flash is for,
so the Board Manager writes the example `blink` of the other cores into the flash (the LED blinks). An empty Pico 2
stays in its USB boot, and there its flash cannot be written over the debug probe; the Board Manager then writes the
program as a UF2 file onto its drive.

**By itself** the Board Manager opens when you plug a board in for the first time, and when Asmonite starts with a
board plugged in that it has not seen before. After that you open it from the menu. Asmonite remembers the boards in
the section `[Boards]` of the file `Asmonite.ini` (by their USB serial number, without one by the USB socket of the PC). When
Asmonite is in the background, it flashes in the taskbar. A limit: two ESP32 DevKits with the USB serial chip CP2102
have the same serial number ("0001"); so the second one counts as seen already.

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
holds the port; the Board Manager, the debugger and the boot ROM get it while they need it, then the tab connects again.
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
debugger as before; so does a program for the flash (`.target esp32 flash`). For a program for a board F9 is
therefore called **Run in RAM / Continue** in the menu Debug: after a reset the program is gone.

**As a file on the board (ESP32, ESP32-S3, ESP32-C3, Pico, Pico 2):** **Project > Compile and Upload** (Ctrl+Shift+F9;
for assembler **Assemble and Upload**) compiles the program in the editor and puts it over the console as a file into
the flash of the board of the tab Serial, under the name of its source without the extension (`blink.abel` becomes
`blink`; a file of that name is replaced). **Debug > Upload and Run** (Shift+F9) does the same and then lets the
console start the program from the file. It stays on the board after a reset: `run blink` in the console starts it
again, **Autostart** in the Board Manager after every reset. As with F9, Asmonite stops a program that runs with
Ctrl+C first and brings a console of another version up to date first.

**Updates by themselves:** before the start Asmonite compares the console in the flash with its own (by its CRC-32,
within milliseconds). When it comes from another version of Asmonite, Asmonite writes its own over the boot ROM
(ESP32 about 11 seconds, S3 about 2), then another WiFi package, and then starts the program. The files and the
network of the board stay.

**No console:** the header of the tab says so when the boot ROM finds no program in the flash (an empty board) or no
console says hello within three seconds after a start (another firmware such as MicroPython, a program of Write to
Flash and Run), and shows the button **Prepare Board**. When no console answers at F9, Asmonite asks: Prepare Board,
or start the program with the debugger as before. Prepare Board (also in the Board Manager) writes the console into the
flash over the boot ROM and makes its file system when there is none; files of the console stay.

The boards with serial output have an example that writes "Hello, world!" this way: `examples/esp32/hello_uart_ram.asm`,
`examples/esp32s3/hello_usb_ram.asm`, `examples/esp32c3/blink_ram.asm` (a line at each change of the LEDs),
`examples/pico2/hello_uart_ram.asm` and `hello_uart_arm_ram.asm`, `examples/pico/hello_uart_ram.asm`,
`examples/stm32/hello_uart_ram.asm`.

## What the consoles can do

The console of Asmonite on each board, its WiFi (the W of the Pico) and the aBelle programs for it, as the code has
them now. "–" is missing yet; the aim is the same on every board, as far as its hardware allows.

| | ESP32 | ESP32-S3 | Pico, Pico 2 (W) | ESP32-C3 | ESP32-S31 |
|---|---|---|---|---|---|
| `ls`, `cat`, `rm`, `df`, `format`, `run`, `boot`, `noboot`, `info`, `help`, a program by its name | ✓ | ✓ | ✓ | ✓ | ✓ |
| `reset` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `name` (the name of the board: DHCP, mDNS) | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `passwd` (the password of telnet) | ✓ | ✓ | ✓ (W) | – | – |
| `wlan`, `wlan set`, `wlan on`, `wlan off`, `wlan clear` | ✓ | ✓ | ✓ (W, clone) | ✓ | ✓ |
| `wlan scan` | ✓ | ✓ | ✓ (W, clone) | ✓ | ✓ |
| answers ping, also while a program runs | ✓ (the WiFi service on core 1) | ✓ | ✓ (W, clone: the console in the background, every 10 ms) | ✓ (the WiFi service, every 10 ms) | ✓ (as on the C3) |
| the address by DHCP: renewed also while a program runs | – (at the prompt) | – | – (at the prompt) | ✓ | ✓ |
| `name.local` (mDNS) | ✓ (at the prompt) | ✓ (at the prompt) | ✓ (W, clone: also while a program runs) | ✓ (the WiFi service: also while a program runs) | ✓ (as on the C3) |
| `led(on)` for programs (the console) | – (programs switch GPIO 2) | – (programs: the RGB LED at GPIO 48) | ✓ | – | – (`rgb(60, colour)`: the RGB LED) |
| aBelle: F9 (over the console), `gpio_output`, `gpio_write` | ✓ | ✓ | ✓ | ✓ | ✓ |
| aBelle: F9 with a breakpoint, F7, F8, the variables | ✓ | ✓ | ✓ | ✓ | ✓ |
| aBelle: network programs (`ping`, `dns`, `ntp`, `httpget` …) | ✓ | ✓ | ✓ (W, clone) | ✓ | `scan`, `arpscan`, `ping` ✓, the others not tried yet |
| aBelle: the clock of the core (`cpu_clock`, `cpu_clock_khz`; [clock.md](clock.md)) | ✓ (5 kHz … 240 MHz) | ✓ (10 … 240 MHz) | ✓ (1 kHz … 133 or 150 MHz) | ✓ (10 … 160 MHz) | – |
| aBelle: `telnetd` | ✓ | ✓ | ✓ (W) | – | – |
| aBelle: `fm`, `webserver` (the board as a web server) | ✓ | ✓ | – | – | – |

A Pico and a Pico 2 without a WiFi chip (without the W) have no network commands: `wlan`, `name` and `passwd` are
unknown there like any typo, and `help` and `info` do not list them (Prepare Board writes help.txt without those
lines).

**The clone "Pico W-2023"** has an ESP8285 at UART0 (GPIO 0 and 1) instead of the CYW43439 of a Pico W. With the
firmware of Asmonite on it (Board Manager > **Install WiFi (ESP8285)**) it is the WiFi of the console as on the Pico W:
the console names the board "Raspberry Pi Pico (WiFi: ESP8285)", and `wlan`, the network programs and
`wifi.abel` run unchanged. UART0 belongs to the ESP8285 then: the console talks over the USB cable only. The
firmware (`wlan/esp8285_fw.asm`) links the libraries of the ESP8266 NONOS SDK of Espressif with `ablink`; it passes
the frames over UART0 (460800 baud) to the console, which does ARP, ping and DHCP as on the Pico W. The firmware the
ESP8285 came with (an AT firmware) is overwritten.

Files go onto every board over the packets of its console (Board Manager: Upload File...; Compile and Upload); no
console has a command to type a file in. The functions of the console for programs: the ESP32, the S3, the C3 and the S31 have the same twelve
(exit … args), the C3 and the S31 also `wifi_up` (the WiFi on), the S31 `rgb` (the RGB LED); the Pico and the Pico 2 also `led` and `wl_call` (their WiFi);
`file_write` writes a file there too (as on the ESP boards), only `flash_read` answers -1 there yet (a program reads
the flash at 0x10000000 itself).
