# The ESP32 with Asmonite

The original ESP32 from Espressif has two Xtensa LX6 cores (240 MHz). Asmonite assembles its code (`.arch xtensa`,
`.target esp32`), loads a program into its RAM or writes it into its flash, and debugs it, **over the USB cable of
the board, without a JTAG probe, without esptool and without ESP-IDF**: breakpoints, steps, the registers, the
memory. A small debug monitor of Asmonite runs next to the program and speaks with Asmonite over the serial port.

Tested with an ESP32 DevKit V1 (ESP32-D0WD, a CP2102 as USB serial chip, the blue LED at GPIO 2).

## What you need

- A board with an ESP32 and a USB serial chip: CP2102 or CP2104, CH340, CH9102, CH343 or an FTDI chip. In the Device
  Manager it shows as a COM port, for example "Silicon Labs CP210x USB to UART Bridge (COM14)". Windows brings the
  driver of most of these chips along; else it comes from the maker of the chip.
- Windows 10 or 11.

**Debug > Debug targets > ESP32 > Test the connection** shows whether the board answers: its COM port and its MAC
address.

## How the program gets onto the chip

The ESP32 has no USB port of its own. Its boot ROM waits for commands on the serial port (UART0) when the pin GPIO 0
is low at a reset. The boards do this with two transistors at the lines DTR and RTS of the USB serial chip: RTS
pulls EN (the reset), DTR pulls GPIO 0. Asmonite does the same as esptool and checks the first line of the boot ROM
after each reset: "boot:0x3 (DOWNLOAD_BOOT ...)" means the download mode.

On many boards this needs many tries (on the DevKit V1 of the test from 2 to 125 resets, 1 to 7 seconds): the
two lines change one after the other, and in between the chip may start before GPIO 0 is low. esptool counts on a
capacitor at EN that keeps the chip in its reset for that moment; on some boards it is too small. If the board does
not get there within 10 seconds, Asmonite asks you to **hold BOOT**: then every reset goes into the download mode.
(A capacitor of about 10 µF between EN and GND fixes it for good.)

## A program in the RAM

```asm
.target esp32
.arch xtensa
.imagebase 0x40080000

_start:
    ...
```

F9 (run) or F7 (step into) resets the chip into the download mode, the boot ROM loads the debug monitor of
Asmonite into the top of the IRAM and starts it, and the monitor loads the program at `.imagebase` and starts it at
`_start` (without `_start`: the first byte); F7 stops there. Then as on the other boards: F7 and F8 step line by line
(also into and over `call8` and the other windowed calls), F5 sets a breakpoint, F9 runs to the next one; the
registers `a0` to `a15` of the window, `pc`, `ps`, `sar`, `windowbase`, `windowstart` and the loop registers show in
the register window, the memory window reads the memory of the chip. A program that returns with `ret` (the call0
way: `_start` gets the end of the monitor in `a0`) ends the session; the output window shows `a2` and `a3`.

**No pause yet:** the monitor listens only while the program is stopped. Set a breakpoint before the program runs
into a loop. A program that runs is no obstacle for the next F9: it resets the chip anyway.

The program starts with `sp` (`a1`) at `0x3FFC0000` in the DRAM and `ps` = `0x00040025` (windowed calls, interrupt
level 5: only the debug exception and NMI come through). An exception of the program (an illegal instruction, a
load from an address without memory, a byte store into the IRAM) stops it at the instruction, with its cause in the
output window. After a reset (EN) the firmware of the flash runs again.

How it works: the monitor (`src/debugger/esp32mon.asm`, 2 KB at `0x4009E000`) points `VECBASE` at its own vector
table: `break 1,15` (a breakpoint), the step of `ICOUNT` and every exception end there; it keeps the registers and
answers the commands of Asmonite on UART0 (registers, memory in words, run, step). It has the handlers of the
register windows (overflow and underflow of `call4`, `call8`, `call12`) as every Xtensa program needs them.

The RAM from `0x40080000` to `0x4009DFFF` (120 KB) is free for the program; above it the monitor. It is
**instruction RAM**: the core
reads and writes it only in words of 32 bits. `l32i` and `s32i` work, `l8ui`, `l16ui`, `s8i` stop with an exception
(LoadStoreError); `examples/esp32/hello_uart_ram.asm` reads its text word by word for this reason.

The core runs at 40 MHz (the crystal), in the download mode and after a start from the flash.

## A program in the flash

```asm
.target esp32 flash
.arch xtensa
.imagebase 0x40080000
```

F9 or F7 write the program into the flash at the address `0x1000`, as an image of the boot ROM (chip id 0, one
segment at `.imagebase`), over the boot ROM; then the debugger starts the monitor again and loads the program into
the IRAM as the boot ROM does at every start, and debugs it there. After a reset (EN) the boot ROM starts it from the
flash by itself. It replaces the firmware that was in the flash (its bootloader stands at `0x1000`). No terminal
may have the COM port open while the flash is written.

A program that the boot ROM starts from the flash must switch the **watchdogs** off itself (timer group 0 and 1 and
the RTC watchdog), else the chip resets after a few seconds; `examples/esp32/blink_flash.asm` shows how, a few lines
at `_start`.

## The serial output

UART0 is the serial port of the board: what the program writes to `UART_FIFO_REG` (`0x3FF40000`) comes out on the
COM port, at 115200 baud (the boot ROM has set it up). Under the debugger the monitor shares the port with the
program: what the program writes shows in the output window, a line at a time (`UART0: Hello, world!`).

Without the debugger (a program in the flash after a reset) the tab **Serial** next to the output window is a small
terminal: the characters as they come; a line typed below goes to the board with Enter (with CR and LF).
**Connect** opens a port with the port and the baud rate chosen in the header, **Disconnect** lets it go for another
terminal (PuTTY ...); **Reset** (only on the USB serial chips of the boards of the ESP32) resets the chip over RTS
without closing the port, so the first lines of the boot ROM and of the program in the flash show. The terminal of
Asmonite leaves the lines DTR and RTS off: some terminal programs switch them when they open the port, which resets
the chip, and a program in the RAM is gone.

## The examples

| File | What it does |
|---|---|
| `examples/esp32/blink_ram.asm` | The LED at GPIO 2 on and off, half a second each, timed with the cycle counter `ccount` |
| `examples/esp32/blink_flash.asm` | The same in the flash, with the watchdogs switched off at the start |
| `examples/esp32/hello_uart_ram.asm` | "Hello, world!" once a second on UART0 (the COM port of the board) |

The registers they use are written in their comments, with the source: the headers of ESP-IDF and the ESP32
Technical Reference Manual.

## If something does not work

| Message or sign | What to do |
|---|---|
| "No board with an ESP32 is plugged in" | The USB cable (some carry power only), the driver of the USB serial chip |
| "... does not go into the download mode by itself: hold the BOOT button" | Hold BOOT until the program runs |
| "COM14 is open in another program" | Close the terminal, then F9 again |
| The board restarts every few seconds | A program in the flash that does not switch the watchdogs off |
| "Stopped: exception at ...: load/store error" | A byte access to the IRAM (see above), or an address without memory |
| "Guru Meditation Error" on the COM port (a program from the flash, without the debugger) | The same, or a jump to an address without code |

## Limits

- No pause of a running program yet (see above). The original ESP32 has no USB JTAG: the debugger is the monitor
  of Asmonite in the IRAM (2 KB) over the serial port.
- The program must not change `VECBASE`, use UART0 for input, or switch interrupts above level 5 on: the monitor
  needs them.
- Core 0 only; the second core is not started.
- The instructions of the ESP32-S3 without `salt` and `saltu` (the LX6 does not have them: Asmonite says so).
- Not yet: the DRAM as a second segment, programs in the external flash (cache) or PSRAM, WiFi and Bluetooth.
- How the boot ROM is spoken to: the serial protocol of esptool (`esptool/targets/esp32.py`).
