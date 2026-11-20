# The ESP32-C3 with Asmonite

The ESP32-C3 from Espressif has one RISC-V core (RV32IMC, 160 MHz) and a USB port that is a serial port and a JTAG
debugger at the same time. Asmonite uses both: it debugs a program in the RAM of the chip and writes it into the
flash, **with one USB cable, without a debug probe, without OpenOCD and without ESP-IDF**.

Tested with the LuatOS ESP32C3-CORE (the simple version with one USB-C port at the chip; 4 MB flash, run in DIO mode;
LEDs at GPIO 12 and 13) and with a board with two USB-C ports and an RGB LED WS2812 at GPIO 8 (one port goes to the
chip, the other one to UART0 over a CH340). Other boards whose USB port goes straight to the chip (GPIO 18 and 19) should work the same way;
boards with a USB-serial chip of their own (CP2102, CH340, CH343) give no USB JTAG.

## What you need

- A board with an ESP32-C3 whose USB port is the one of the chip. In the Device Manager it shows as
  "USB JTAG/serial debug unit" and as a COM port.
- Windows 10 or 11.

## Setting up once: the USB JTAG

Windows gives the JTAG part of the USB port the driver WinUSB by itself, but not the entry that programs need to open it.
In Asmonite: **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG**. Windows asks for administrator rights once; then
**Test the connection** should say that the board answers. Windows keeps this for each board (it knows the board by its
serial number, the MAC address of the chip), at every USB port of the computer: a second board needs the button once
more.

## A program in the RAM

```asm
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
    ...
```

Press F9 (run) or F7 (step into). The debugger resets the chip and halts it at once, before the firmware in the flash
starts, loads the program to `0x40380000` and stops at `_start`. Then: steps (F7, F8), breakpoints (F5, the core has
hardware breakpoints for them), registers `x0` .. `x31` and `pc`, memory. After a reset (the RESET button) the firmware
of the flash runs again.

Why the reset: firmware such as LuatOS or ESP-IDF switches on the memory protection of the chip; then nothing can be
written into the RAM of the code until the next reset. Halted before the firmware starts, the whole RAM from
`0x40380000` to `0x403BFFFF` (256 KB) is free for the program.

## A program in the flash

```asm
.target esp32c3 flash
.arch riscv32
.imagebase 0x40380000
```

F9 or F7 now write the program into the flash at address 0, as an image of the boot ROM: the boot ROM loads it into
the RAM at `0x40380000` at every start. The writing goes over the **serial port** of the chip (the COM port of the
board), with the protocol of its boot ROM; no terminal program (PuTTY or similar) may have that port open at that
moment (the tab Serial of Asmonite lets it go by itself). Then the debugger lets the boot ROM start the program and stops at `_start`, so you see the program exactly as
it starts without the debugger. It also starts by itself after every reset.

This replaces the firmware that was in the flash before (on the LuatOS board: LuatOS; it can be downloaded again
from the maker).

A program in the flash must switch the **watchdogs** off itself: the boot ROM leaves two of them on, and they would
reset the chip after a few seconds. `examples/esp32c3/blink_flash.asm` shows how (a few lines at `_start`).

## The examples

| File | What it does |
|---|---|
| `examples/esp32c3/blink_ram.asm` | The LEDs at GPIO 12 and 13 blink in turn; every change is a line on the USB serial port (COM port): `LED 12 on`, `LED 13 on` |
| `examples/esp32c3/blink_flash.asm` | The same in the flash, with the watchdogs switched off at the start |
| `examples/esp32c3/rgb_ws2812_ram.asm` | For boards with an RGB LED WS2812 at GPIO 8: red, green and blue in turn, and a line for each on the USB serial port. The 24 bits of colour are timed with the cycle counter of the core; the program sets the clock of the core from 20 to 40 MHz |
| `examples/esp32c3/rgb_ws2812_flash.asm` | The same in the flash, with the watchdogs switched off at the start |
| `examples/esp32c3/hello_uart_ram.asm` | "Hello, world!" on UART0 (the pin GPIO 21, not the USB port: a USB-serial adapter there shows it; on boards with a second USB port with a CH340 that port) |

The registers they use are written in their comments, with the source: the headers of ESP-IDF and the ESP32-C3
Technical Reference Manual.

## The output on the USB serial port

The USB port of the chip is a serial port as well (COM port); a program writes a byte into the register
`0x60043000` (`USB_SERIAL_JTAG_EP1`) and sends what is there with bit 0 of `0x60043004` (`EP1_CONF`, `WR_DONE`).
Bit 1 of `EP1_CONF` says that the buffer takes data. If no program on the PC reads the port, the buffer fills; the
examples then drop the line instead of waiting forever. Any terminal shows the lines (the speed does not matter on this
port).

Under the debugger the tab **Serial** next to the output window shows them: it connects to that COM port by itself
when the debugger has loaded the program. The debugger has the JTAG of the same USB port, the serial port stays
free; only the reset into the boot ROM and the writing of the flash go over it, so the tab lets it go at the start
of the session. Connect and Disconnect stay usable. (A terminal of another program has to be closed before F9.)

The RISC-V core of the C3 reads and writes bytes at the IRAM address of the program too (`lbu`, `sb`): the texts of
the examples stand next to their code.

## The console of Asmonite

As on the ESP32 and the ESP32-S3, the C3 can run the console of Asmonite (`boards/esp32c3/console.asm`): a prompt
on the USB serial port, files in the flash, programs from the files, the WiFi. **Board > Board Manager**, choose the
board, **Prepare Board**: Asmonite writes the console into the flash at 0 (in the place of the program there),
`help.txt`, an empty file system (from 2 MB of the flash on; files that are there stay) and the WiFi package. Then a
terminal on the COM port of the board (the tab Serial):

| Command | What it does |
|---|---|
| `ls`, `cat name`, `rm name`, `df`, `format` | the files in the flash |
| `run name`, `name [args]` | starts a program from the files (a program as Compile and Upload writes it) |
| `boot name`, `noboot` | the program that starts after every reset (a key within 3 seconds stays in the console) |
| `wlan`, `wlan set`, `wlan on`, `wlan off`, `wlan clear`, `wlan scan` | the WiFi network of the board |
| `name`, `name set name`, `name clear` | the name of the board in the network (DHCP, mDNS: `name.local`) |
| `info`, `reset`, `help` | the chip, a reset, the commands |

A program for the console runs in the RAM from `0x40380000` (up to `0x403A7FFF`; above it lie the WiFi and the
console): `.target esp32c3`, `.arch riscv32`, `.imagebase 0x40380000`, then **Debug > Upload and Run** (or
**Project > Compile and Upload** and `run name` in the terminal later). It gets the text of its arguments in `a0` and ends with `ret` (its code in
`a0`), with `exit(code)` from any depth, by an exception (the console says which one and where) or by Ctrl+C. The
functions of the console for programs are at `0x403CC200`, a jump of 4 bytes each, in the order of the ESP32: exit,
version, put_char, get_char, poll_char, print, millis, file_size, file_read, file_write, flash_read, args.
`boards/esp32c3/contest.asm` uses some of them.

The WiFi: `wlan set` asks for the name of the network and its password (without echo; the board keeps the key of
WPA2, not the password). The board connects in the background, gets an address by DHCP (`WiFi: connected, address
a.b.c.d (esp32c3-xxxx.local).`), answers ARP, ping and mDNS for its name, and starts the WiFi by itself after a
reset; `wlan off` keeps it off, also after a reset. `name set keller` gives the board another name (for the router
and `keller.local`; `name clear`: the one of the MAC again); `wlan set` and `wlan clear` keep it. The C3 has one
core: the WiFi service at `0x403A8000` gives the tasks of the WiFi a turn every 10 ms by a timer, also while a
program computes, and its own task keeps the connection, answers ARP, ping and mDNS and renews the address
(`wlan/wlannet_c3.asm`). A program that needs the WiFi calls the service itself (see
`wlan/wlansvc_c3.asm`; `wifi_get_ip` gives the address, the mask, the router and the name server). On the ESP32 and
the ESP32-S3 DHCP is in the console instead, only because their service has no room for it; there the address is
renewed only while the console runs.

aBelle: a program with `target "esp32c3"` (`include "inc/console.abel"` of `abelle/examples/esp32c3`: the functions of
the console) is translated by `abelle_riscv.exe`; F9, F7 and F8 load it over the USB JTAG, the console starts it (the
stack of the programs, Ctrl+C, `exit`; its output and "Program ended" in the tab Serial) and is at its prompt again
afterwards, the variables show under the mouse. Compile and Upload puts it onto the board as a file. The network
programs of `abelle/examples/esp32c3` (`ping`, `dns`, `ntp`, `arpscan`, `httpget`, `dhcp`) use `inc/net.abel` and
`inc/tcp.abel` as on the ESP32; the address comes from the WiFi service.

F9 still runs an assembler program over the USB JTAG as above: a program in the RAM stops the console until the next reset; a
program for the flash (`.target esp32c3 flash`) takes its place (Prepare Board puts it back; the files stay).

## If something does not work

| Message or sign | What to do |
|---|---|
| "the ESP32-C3 is plugged in, but ... has not given its USB JTAG an interface" | Debug targets > ESP32-C3 > Set up the USB JTAG (once for each board) |
| "COM8 is open in another program" | Close the terminal (PuTTY ...), then F9 again |
| "the core of the ESP32-C3 hangs" | Press RESET on the board, then try again |
| The board restarts every few seconds, the COM port comes and goes, a terminal shows `invalid header: 0xffffffff`; F9 says "does not answer over USB JTAG: … (error 31)" | The flash is empty (Erase Flash in the Board Manager, or a write did not finish): hold BOOT, press RESET (or plug the board in), let go of BOOT, then F9; a program for the flash ends it |
| The board does not answer at all | Hold BOOT, press RESET, let go of BOOT: the chip waits in its boot ROM; then F9 |
| Nothing on the COM port | Is the program for the USB port (`blink_ram.asm`) or for UART0 (`hello_uart_ram.asm`)? |

## Limits

- One core (the ESP32-C3 has one), the RAM from `0x40380000` to `0x403BFFFF`.
- The compressed instructions (C) of 2 bytes with `.option rvc` (F1 on that line: the topic `compressed`); without it
  every instruction is 4 bytes. The console of Asmonite uses it.
- The flash image is for 4 MB of flash in DIO mode at 40 MHz. WiFi: with the console of Asmonite (above); no
  Bluetooth. Not on the C3 yet: telnet. The answer to a ping takes longer while a program computes
  (up to the 10 ms of the timer, measured 30 to 130 ms instead of 20 to 35 ms).
- How the chip does the USB JTAG: the protocol of `esp_usb_jtag.c` of OpenOCD and the RISC-V debug spec 0.13.
