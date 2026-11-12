# The ESP32 with Asmonite

The original ESP32 from Espressif has two Xtensa LX6 cores (240 MHz). Asmonite assembles its code (`.arch xtensa`,
`.target esp32`) and compiles programs in the language aBelle for it, loads a program into its RAM or writes it into
its flash, and debugs it, **over the USB cable of the board, without a JTAG probe, without esptool and without
ESP-IDF**: breakpoints, steps, the registers, the memory. A small debug monitor of Asmonite runs next to the program
and speaks with Asmonite over the serial port. On top come a console with files in the flash and the **WiFi**: an
aBelle program connects to a network, gets an address by DHCP and speaks UDP and TCP, also while the debugger holds it
at a breakpoint.

Tested with an ESP32 DevKit V1 (ESP32-D0WD, a CP2102 as USB serial chip, 4 MB of flash, the blue LED at GPIO 2) and
a board with an ESP32-WROVER (CH9102, 8 MB of flash).

## What you need

- A board with an ESP32 and a USB serial chip: CP2102 or CP2104, CH340, CH9102, CH343 or an FTDI chip. In the Device
  Manager it shows as a COM port, for example "Silicon Labs CP210x USB to UART Bridge (COM14)". Windows brings the
  driver of most of these chips, else it comes from the maker of the chip.
- Windows 10 or 11.
- For the WiFi: a network on 2.4 GHz, open or with WPA2.

**Debug > Debug targets > ESP32 > Test the connection** shows whether the board answers: its COM port, its MAC
address and its flash, for example "flash 4 MB (Boya, JEDEC id 68 40 16)". The flash chip tells its size itself (the
command 0x9F, as `esptool flash_id`); the eFuses do not hold it.

## How the program gets onto the chip

The ESP32 has no USB port of its own. Its boot ROM waits for commands on the serial port (UART0) when the pin GPIO 0
is low at a reset. The boards do that with two transistors on the lines DTR and RTS of the USB serial chip: RTS pulls
EN (the reset), DTR pulls GPIO 0. Asmonite does it as esptool does and checks the first line of the boot ROM after
each reset: "boot:0x3 (DOWNLOAD_BOOT …)" means download mode.

On many boards that takes many attempts (on the DevKit V1 of the tests 2 to 125 resets, 1 to 7 seconds): the two
lines change one after the other, and in between the chip may start before GPIO 0 is low. esptool counts on a
capacitor at EN that keeps the chip in its reset for that moment; on some boards it is too small. If the board does
not get there within 10 seconds, Asmonite asks you to **hold BOOT down**: then every reset goes into the download
mode. (A capacitor of about 10 µF between EN and GND fixes it for good.)

Big transfers go at **921600 baud** instead of 115200: the flash over the boot ROM, a program of 16 KB or more under
the debugger, files of 16 KB or more in the window Board > Files. Asmonite changes the rate, checks it with a short
exchange and falls back to 115200 if the board does not manage it; if the check passes and the transfer fails, Asmonite writes the
whole once more at 115200. Before the program runs, the rate is 115200 again, as the program expects it. The
environment variable `ASMONITE_ESP_BAUD` sets another rate (`115200`: never faster).

## A program in the RAM

```asm
.target esp32
.arch xtensa
.imagebase 0x40080000

_start:
    ...
```

When the console of Asmonite is on the board (Board > Prepare Board) and the program has no breakpoint, F9 puts it into
the RAM over the console and starts it, without the download mode and without a reset; the tab Serial shows its output
(see [boards.md](boards.md)). First Asmonite compares the console in the flash with its own: when it is another one (of
an older version of Asmonite), it writes its own over the boot ROM (about 11 seconds; the files and the network of the
board stay), the WiFi package too when the board has another one, and then starts the program.

With a breakpoint, F7 or F8 the debugger starts. When the console is there, it goes over the console too: Asmonite
loads the debug monitor into the RTC FAST memory over the console, the console calls the program as `run` does, and
the monitor stops it at its entry. After the end of the program or Stop the console is there again ("Program ended
(code n)", "Program stopped by the debugger."), without a reset and without the BOOT button; the next session begins
after half a second. Without a console on the board, and for Write to Flash and Run, the way over the boot ROM holds:

F9 (run) or F7 (single step) puts the chip into the download mode, the boot ROM loads Asmonite's debug monitor into
its RTC FAST memory and starts it, and the monitor loads the program at `.imagebase` and starts it at `_start`
(without `_start`: at its first byte); F7 stops there. Then as with the other boards: F7 and F8 go line by line (also
into and over `call8` and the other calls with register windows), F5 sets a breakpoint, F9 runs to the next one; the
registers `a0` to `a15` of the window, `pc`, `ps`, `sar`, `windowbase`, `windowstart` and the loop registers are in the
register window, the memory window reads the memory of the chip. When the program returns, the session ends and the
output window shows its value. There are two ways:

- **If `_start` begins with `entry`**, the program comes as the console calls it (`callx8`, with register windows).
  `retw` ends it, its value is `a2`. This is the way for programs that run over the console too and go back to it,
  aBelle as well.
- **Without `entry`** it comes as with call0: `a0` points to the end of the monitor, `ret` ends it, the output window
  shows `a2` and `a3`.

**Debug > Pause** stops a running program where it is, also in an endless loop; **Stop** (Ctrl+F2) ends the session
at once. For that Asmonite sends a byte over UART0: while the program runs, it raises an NMI in the monitor (see
below). A running program does not disturb the next F9: it resets the chip anyway.

The program starts with `sp` (`a1`) at `0x3FFC0000` in the DRAM and `ps` = `0x00040025` (calls with register windows,
interrupt level 5: only the debug exception and the NMI get through). An exception of the program (an illegal
instruction, a load from an address without memory, a byte store into the IRAM) stops it at the instruction, with the
cause in the output window. After a reset (EN) the firmware of the flash runs again.

How it works: the monitor (`src/debugger/esp32mon.asm`, a little over 2 KB at `0x400C0000` in the RTC FAST memory,
which has 8 KB and belongs to core 0 only) points `VECBASE` at its
own vector table: `break 1,15` (a breakpoint), the step of `ICOUNT` and every exception land there; it saves the
registers and answers Asmonite's commands over UART0 (registers, memory in words, run, step, the rate). It has the
handlers of the register windows (overflow and underflow of `call4`, `call8`, `call12`) that every Xtensa program
needs, and puts a frame below the first `sp` for a caller of `_start` that does not exist: so a chain of calls deeper
than the 64 registers hold works too. For the pause it routes the interrupt of UART0 (a byte in the receive buffer)
through the interrupt matrix to the CPU interrupt 14, the NMI (level 7, above the level 5 of the program); it is on
only while the program runs.

The debugger takes a program in the RAM from `0x40080000` to `0x4009BFFF` (112 KB); above it lies the console, the
monitor is not in the IRAM. The normal window, which aBelle uses and with which the WiFi runs, ends at `0x40092FFF`
(76 KB); from `0x40093000` lie the service of the WiFi and `wlan.rom`. A larger program runs in the **large window**
up to `0x4009BFFF`, then without the WiFi (see "The WiFi"). It is
**instruction RAM**: the core reads and writes it in words of 32 bits only. `l32i` and `s32i` work, `l8ui`, `l16ui`,
`s8i` stop with an exception (LoadStoreError). A big program (63 KB) loads in a little under 6 seconds.

### Data in the DRAM: `.data`

Texts, tables and buffers go behind `.data`: these lines land in the **DRAM** from `0x3FFB0000` on, where the core
reads and writes bytes, halfwords and words. `.code` switches back to the code (into the IRAM).

```asm
lit_text: dd text            ; the address in the DRAM, for l32r (the literals stay in the IRAM)

_start:
  l32r  a3, lit_text
  l8ui  a2, a3, 0            ; a byte of the text
  ...

.data
text:   db 'Hello, world!', 13, 10, 0
buffer: resb 64              ; room, filled with zeros when it is loaded
```

The labels in `.data` have their addresses in the DRAM; `align 4` before a `dd` puts it on a word, as everywhere. In
the file the bytes of `.data` follow the code; the debugger writes them into the DRAM after the code, a program for
the flash has them as a second segment of the image, which the boot ROM copies at every start. `.data 0x3FFC0100` puts
them at another address. Free for `.data` is the DRAM from `0x3FFB0000` to `0x3FFDFFFF` without the stack: it starts
at `0x3FFC0000` and grows down, and Asmonite keeps `0x3FFBF000` to `0x3FFC000F` free for it (the 4 KB below and the
frame of the monitor above); data that reach into it are an error. From `0x3FFE0000` on the boot ROM keeps its own
data. `examples/esp32/hello_uart_ram.asm` and `hello_uart_flash.asm` read their text from `.data`.

The core runs at 40 MHz (the crystal), in the download mode and after a start from the flash.

## A program in the flash

```asm
.target esp32 flash
.arch xtensa
.imagebase 0x40080000
```

F9 or F7 write the program into the flash at the address `0x1000`, as an image of the boot ROM (chip id 0, a segment
at `.imagebase` and one for `.data` if the program has it), over the boot ROM; then the debugger starts the monitor
again, loads the program into the IRAM as the boot ROM does at every start, and debugs it there. After a reset (EN)
the boot ROM starts it from the flash by itself. It replaces the firmware that was in the flash before (its bootloader
is at `0x1000`). While the flash is written, no terminal may have the COM port open. An image that does not fit into
the flash of the board Asmonite refuses.

**Board > Advanced > Write to Flash and Run** does the same for a program with `.target esp32` (without `flash`): so
the same source goes into the RAM (F9) or into the flash without a change. As the program takes the place of the
console, Asmonite asks first; Board > Prepare Board is the way back.

A program that the boot ROM starts from the flash has to switch off the **watchdogs** itself (timer group 0 and 1 and
the RTC watchdog), else the chip resets after a few seconds; `examples/esp32/blink_flash.asm` shows how, with a few
lines at `_start`.

## The serial output

UART0 is the serial port of the board: what the program writes into `UART_FIFO_REG` (`0x3FF40000`, or as ESP-IDF does
over the AHB bus at `0x60000000`) comes out at the COM port, at 115200 baud (the boot ROM has set it up). Under the
debugger the monitor shares the port with the program: what the program writes shows in the tab **Serial** next to the
output window, as it comes (the tab comes to the front at the first output of a session). Connect, port, baud rate and
the input line are off while the session lasts, the header says that the debugger has the port; a port connected in
the tab is let go at the start of the session. The output window keeps the messages of the debugger.

Without the debugger (a program from the flash after a reset) the tab **Serial** next to the output window is a small
terminal: the characters as they come; a line typed below goes to the board with Enter (with CR and LF). **Connect**
opens the port with the port and the baud rate of the header, **Disconnect** lets it go for another terminal (PuTTY
…); **Reset** (only with the USB serial chips of the ESP32 boards) resets the chip over RTS without closing the port,
so the first lines of the boot ROM and of the program in the flash show. Asmonite's terminal leaves the lines DTR and
RTS off: some terminal programs switch them when they open the port, which resets the chip, and a program in the RAM
is gone.

## The console and its files

`examples/esp32/console.asm` makes the board a small computer with a file system in the flash: it reaches from 2 MB to
the end of the flash (2 MB on a flash of 4 MB, 6 MB on one of 8 MB such as a WROVER; the console reads the size from
the flash chip when it starts). Any terminal program works with it (`ls`, `cat`, `put`, `rm`, `df`, `format`, `run`,
`load`, `boot`, `wlan`, `help`), and the menu **Board** of Asmonite works with it:

- **Board > Prepare Board** writes the console into the flash (over the boot ROM), makes its file system when there
  is none, and brings the WiFi package. F9 replaces a console of an older version of Asmonite by itself (see above).
- **Board > Set This Program as Autostart** compiles the program in the editor, uploads it to the board and starts it
  after every reset.
- **Board > Files** shows the files in a window; its head line names the flash of the board.
- **Upload File** and **Download** move files of any kind between the PC and the board (100 KB up in a little under
  4 seconds, down in 2), each checked by its CRC-32; **Delete** removes one.
- **Upload This Program** compiles the program in the editor (assembler with `.target esp32`, or aBelle) and uploads
  it as the image that the boot ROM would start from the flash; **Run** starts it (the window closes, the tab Serial
  shows what it writes), **Autostart** starts it after every reset. After a reset the console waits a short moment
  first: BOOT or a key in the terminal keeps it in the console; **Reset Board** in the window does that too.
- **Board > Advanced > Erase Flash** erases the whole flash over the boot ROM, as on a new board: no console, no
  files (8 to 17 seconds on 4 MB). The boot ROM then says "flash read err, 1000" at every start. Board > Prepare Board
  makes it a board for Asmonite again.
- **Board > Advanced > Install WiFi Again** writes the WiFi package anew (seldom needed, see below).
- A program for F9 fits as it is: its code may take `0x40080000..0x40092FFF` (76 KB; a larger one up to `0x4009BFFF`,
  then without the WiFi), its data `0x3FFB0000..0x3FFCFFFF`; the console lies above them.

**When a program ends, the console is back.** It calls the program with `callx8`, as the ROM calls a function, on
the program's own stack (`sp` = `0x3FFC0000`, as under the debugger). A program that begins with `entry` ends in one
of three ways:

- with `retw`: the console says `Program ended (code n)`, n is its `a2`. aBelle programs end like this with the code
  0 when `main` returns.
- with `exit(code)` from any depth of calls: `callx8` to `0x4009C800` (the first of the functions below).
- by an exception or a `break`: `Program stopped: exception c at pc p, address v` (c is `EXCCAUSE`; `0x106` a
  `break`).
- with **Ctrl+C** from the terminal: `Program stopped (Ctrl+C).` In the tab Serial of Asmonite the button **Stop**
  sends it (or Ctrl+C in the input line when nothing is selected there). This works in an endless loop with the
  interrupts off too: while a program runs, each byte on UART0 raises the NMI. The console puts the bytes into its
  buffer for `get_char`; Ctrl+C it does not pass on. While the ROM writes the flash, the program stops after that
  command. What the program did not read, the console drops. Only a program that changes `VECBASE` or `INTENABLE`
  itself cannot be stopped this way; then the reset stays.

Then the console restores its stack, `ps`, `VECBASE` and `INTENABLE`. The peripherals and the WiFi service on core 1
stay as the program leaves them. Interrupts of level 1 go on to the vectors of the boot ROM, so that its interrupt
functions work as without the console. A program without `entry`, such as the old examples, runs until the next
reset as before.

**Functions of the console for programs.** From `0x4009C800` on lies a table with 4 bytes for each function. A
program calls them with `callx8`, as a function of the ROM: the arguments in `a10` to `a15`, the result in `a10`.

| Address | Function |
|---|---|
| `0x4009C800` | `exit(code)`: the program ends at once. |
| `0x4009C804` | `version()`: 2 (the functions of this table; 1: without `args`) |
| `0x4009C808` | `put_char(c)`: a byte to the terminal |
| `0x4009C80C` | `get_char()`: the next byte from the terminal; waits for it |
| `0x4009C810` | `poll_char()`: the next byte, -1 if none came |
| `0x4009C814` | `print(text)`: a text up to its 0 |
| `0x4009C818` | `millis()`: milliseconds |
| `0x4009C81C` | `file_size(name)`: the length of a file, -1 if there is none |
| `0x4009C820` | `file_read(name, buffer, offset, count)`: the bytes read, -1 if there is no such file |
| `0x4009C824` | `file_write(name, buffer, count)`: 0, or an error: -1 directory full, -2 no room, -3 flash error, -4 invalid name, -5 no file system |
| `0x4009C828` | `flash_read(address, buffer, count)`: 0, -1 if the flash cannot be read there |
| `0x4009C82C` | `args()`: the text of the arguments (see below), empty for `run` |

**Programs as commands.** A word the console does not know it looks for as a file: first `name`, then `name.bin`
(the name Upload This Program gives a program). If there is one, the console starts the program; the rest of the line
is its arguments, in `a2` and by `args()`. So `echo hello world` starts `echo.bin` with `hello world`. As a command
the console says no `Running` before it and no `Program ended (code 0)` after it, only another code, an exception
or Ctrl+C. So commands used rarely can lie in the file system as programs instead of making the console bigger.

A program writes into the flash only through files, so it cannot damage the console or the file system.
`file_write` puts the new content into a free place first and only then into the directory, as `put` does.
`millis()` counts the cycles of the core: a program has to call it at least every 100 seconds (at 40 MHz).

In aBelle, `include "inc/console.abel"` brings these functions, with `println`, `print_int` and the other output
functions of `inc/uart.abel`. The example `runs.abel` counts in the file `runs.txt` how often it ran and shows the keys
from the terminal. The functions exist when the console starts the program: F9 without a breakpoint, `run` or a
command. With a breakpoint it runs under the debugger; only `exit` is tried there so far. A program that starts from
the flash by itself has no console; there `inc/uart.abel` stays.

The window has the serial port while it is open (the tab Serial lets it go). The console does not run under the
debugger: the debug monitor takes every byte on UART0 as its pause. A board formatted before 0.12.0 keeps its file
system of 2 MB until the next Format.

## aBelle on the ESP32

aBelle is a small language with the look of Python (page: asmonite.com/en/abelle.html). `abelle_esp32.exe` compiles a
program with `target "esp32"` into the code for the IRAM and the data for the DRAM, as an assembler program with
`.target esp32`; F9 loads it and debugs it **in its source** (breakpoints, F7/F8 line by line, variables under the
mouse and in the window Watch), Board > Advanced > Write to Flash and Run writes it into the flash.

```python
target "esp32"

gpio:  u32[0x140] at 0x3FF44000     # the registers as an array at their address
iomux: u32[64]    at 0x3FF49000
def ets_delay_us(us: u32) at 0x40008534     # a function of the ROM

def main():
    iomux[0x40 / 4] = 0x2800        # the pin of GPIO 2 as a GPIO
    gpio[0x538 / 4] = 0x100         # a simple output
    gpio[0x24 / 4] = 1 << 2         # GPIO 2 is an output
    while True:
        gpio[0x08 / 4] = 1 << 2     # on
        ets_delay_us(500000)
        gpio[0x0C / 4] = 1 << 2     # off
        ets_delay_us(500000)
```

The examples are in `examples/abelle/esp32/` (in the sources `abelle/examples/esp32/`); `inc/` has the parts they
include: `uart.abel` (text and numbers over UART0), `wifi.abel`, `net.abel`, `tcp.abel` (the WiFi) and `network.abel`
(for a program that names its network itself; the examples take the network of the board, `wlan set`).

## The WiFi

The WiFi of the ESP32 is in libraries of Espressif (without source). Asmonite links them once with its own linker into
a fixed file, `wlan.rom`, and brings a small service, `wlansvc`, which starts them and offers simple functions to
programs. **No ESP-IDF is needed for it.**

**The WiFi package:** the library, the parts of `wlan.rom` for the RAM and `wlansvc` lie together in a fixed room of
the flash, `0x100000` to `0x1FFFFF`, below the file system. At `0x1F0000` there is a head with a mark and, for each
part, its place, length and CRC-32. **You do not have to do anything for it:** when you start a program that uses
`inc/wifi.abel` with F9, Asmonite checks the head on the board and writes the package over the console when it is
missing or another one than the one of this version of Asmonite (about 370 KB, about 13 seconds); F9 replaces another
package also for programs without the WiFi. Prepare Board puts it there as well, **Board > Advanced > Install WiFi
Again** does the same by hand. When the WiFi runs on the second core,
the console switches it off first itself; it starts again at the next start of the console or with `wlan on`.

**The network of the board:** type `wlan set` once in the tab Serial (or another terminal), then the name of your
network and its password (empty for an open network, else WPA2, 2.4 GHz). The console does not show the password, and
the tab Serial shows stars while you type it. The board keeps **not the password** but the key that WPA2 makes of it
(PBKDF2-SHA1 of the password and the name, about 2.5 seconds), in two sectors of its own below the WiFi package.
Whoever reads the flash gets into this one network with it, but does not learn the password. `wlan` shows the name and
whether the WiFi is connected, `wlan clear` forgets the network.

**The WiFi as a service of the console:** when the board keeps a network, the console starts the WiFi itself at each
start and connects in the background ("WiFi: connecting to … in the background") while its prompt is there already.
When the connection goes, the service connects again after a second, after a failed attempt every 5 seconds. After a
reset this may take 30 to 40 seconds, because the router holds the station that went away for a while. `wlan off`
switches the WiFi off, frees its RAM and power and stays off after a reset too; `wlan on` switches it on again. A
program that calls `wifi_connect_saved()` then only waits for that connection (up to 60 seconds) and is in the network
at once when it is there already.

**A program with WiFi:** open for example `ntp.abel` and press F9. The examples connect to the network of the board
with `wifi_connect_saved()`, end with `wifi_done()` and return to the console: the connection of the console stays,
the next example is in the network at once. The servers (`udpecho`, `webserver`, `telnetd`) run until you press Stop
in the tab Serial (Ctrl+C). The program loads the service from the WiFi package itself at its first WiFi call
(`inc/wifi.abel`), with F9 as with `run ntp` in the console or as the autostart. A program that wants to name its
network itself calls `wifi_connect(name, password)` (`inc/network.abel`).

**Writing files while the WiFi runs:** the code of the library and its interrupts run on the second core from the
flash, through the cache. While the console erases, writes or reads the flash, the cache must not fetch from it. So
the console parks the second core before each such access: it rings an interrupt between the cores, and the service
waits with its interrupts off in a loop in the IRAM until the console is done. This happens by itself for uploads,
for `put` and for `file_write` of a program; a connection stays up. If the second core does not answer within
200 ms, the console does not write and reports an error of the flash.

**A large program without the WiFi:** beside the WiFi a program has 76 KB for its code. When it needs more,
`abelle_esp32` takes the **large window** up to `0x4009BFFF` (112 KB) and says so when it translates ("Note: … it runs
without the WiFi"). The console sees from the addresses of the program that it reaches into the room of the WiFi,
stops the WiFi first and starts it again in the background when the program has ended. This holds for F9, `run` and
the debugger. A program that includes `inc/wifi.abel` is refused in the large window, as it would need the very room
it takes.

**Debugging while the WiFi runs:** the service and the WiFi run on the **second core** of the ESP32, the program on the
first. The debugger stops the first one only: while the program stands at a breakpoint, the station stays connected,
and what comes in waits in a buffer of the service (6 frames).

**What a program can do with it** (`inc/wifi.abel`, `inc/net.abel`, `inc/tcp.abel`):

| Function | What it does |
|---|---|
| `wifi_scan`, `wifi_connect`, `wifi_status` | find networks, connect (open or WPA2), read the state |
| `wifi_connect_saved`, `wifi_saved_name` | connect to the network of the board (`wlan set`), read its name |
| `wifi_wait_connected` | wait until the console is connected in the background |
| `wifi_done` | at the end of a program: when the console keeps the connection, it stays for the next program; else the WiFi off |
| `wifi_send`, `wifi_recv` | Ethernet frames out and in |
| `dhcp_run` | get an address, the mask, the router and the DNS server from the router |
| `dns_lookup` | turn a name into an address |
| `ping_send` | send a ping (the board answers pings to it by itself) |
| `udp_send`, `net_recv` | UDP |
| `tcp_connect`, `tcp_listen`, `tcp_accept`, `tcp_send`, `tcp_recv`, `tcp_close` | TCP, one connection at a time, as a client or a server |
| `net_set_name`, `mdns_start` | the name of the board: the router learns it by DHCP, mDNS answers `name.local` (`ping esp32.local`) |
| `wifi_error_text` | an error as a sentence, for example the hint when the WiFi package is missing |

## The examples

| File | What it does |
|---|---|
| `examples/esp32/blink_ram.asm` | The LED at GPIO 2 on and off, half a second each, counted with the cycle counter `ccount` |
| `examples/esp32/blink_flash.asm` | The same in the flash, with the watchdogs switched off at the start |
| `examples/esp32/hello_uart_ram.asm` | "Hello, world!" once a second over UART0 (the COM port of the board), the text in `.data` |
| `examples/esp32/hello_uart_flash.asm` | The same in the flash, at every start of the board (the tab Serial shows it) |
| `examples/esp32/clock_ram.asm` | The core from the crystal and from the PLL at 80, 160 and 240 MHz, and how fast a loop goes at each clock |
| `examples/esp32/console.asm` | The console with the file system in the flash (see above) |
| `examples/abelle/esp32/` | aBelle: blink, hello_uart, chipinfo (MAC, chip, flash), clock, timer, dice, reaction, sieve, temperature |
| `examples/abelle/esp32/` (WiFi) | scan, dhcp, dns, ping, wol (Wake on LAN), arpscan, ntp, udpecho (with `udpecho.py` on the PC), httpget, webserver (`http://esp32.local/`), telnetd (`telnet esp32.local`: files, memory, ping, the LED) |

The registers they use are in their comments, with the source: the headers of ESP-IDF and the ESP32 Technical
Reference Manual. A page with all examples: asmonite.com/en/esp32-examples.html.

## How the memory is used

| Area | What is there |
|---|---|
| flash `0x001000` | the console (or the program of Write to Flash and Run) |
| flash `0x0FE000`, `0x0FF000` | the network of the board (`wlan set`): its name and key, written in turn |
| flash `0x100000` .. `0x152000` | the library of the WiFi (code and constants, through the cache) |
| flash `0x1F0000` .. `0x1FFFFF` | the head of the WiFi package, the parts of `wlan.rom` for the RAM, `wlansvc` |
| flash `0x200000` .. end | the file system of the console: two directories, then the files |
| IRAM `0x40080000` .. `0x40092FFF` | the program (in the large window up to `0x4009BFFF`, then without the WiFi) |
| IRAM `0x40093000` | the service `wlansvc`, from `0x40098000` `wlan.rom` |
| IRAM `0x4009C000` | the console |
| RTC FAST `0x400C0000` | the debug monitor (only under the debugger) |
| DRAM `0x3FFB0000` .. | the data of the program (with WiFi: up to `0x3FFD8000`), the stack from `0x3FFC0000` down |
| DRAM `0x3FFD0000` | the data of the console |
| DRAM `0x3FFD8000` .. `0x3FFDFFFF`, `0x3FFE8000` .. | the data of the WiFi and its heap |

## When something does not work

| Message or sign | What to do |
|---|---|
| "No board with an ESP32 is plugged in" | The USB cable (some carry power only), the driver of the USB serial chip |
| "… does not go into the download mode by itself: hold the BOOT button" | Hold BOOT down until the program runs |
| "COM14 is open in another program" | Close the terminal, then F9 again |
| "The console does not answer" (Board > Files) | A program runs (Reset Board), or the console is not in the flash (Board > Prepare Board) |
| "flash read err, 1000" at the COM port | The flash is empty (a new or erased board): Board > Prepare Board |
| "wifi_connect: error 2041 (the WiFi package is not on the board …)" | Start the program with F9 (Asmonite writes the package), or Board > Advanced > Install WiFi Again |
| "the board keeps no WiFi network" | `wlan set` in the console (in the tab Serial) |
| "… the access point said no" / "no answer of the access point" | The password (`wlan set` again), the name of the network, a network on 2.4 GHz in reach |
| The board starts again every few seconds | A program in the flash that does not switch the watchdogs off |
| "Stopped: exception at …: load/store error" | A byte access to the IRAM (see above), or an address without memory |
| "Guru Meditation Error" at the COM port (a program from the flash, without the debugger) | The same, or a jump to an address without code |

## Limits

- The original ESP32 has no USB JTAG: the debugger is Asmonite's monitor in the IRAM (a little over 2 KB) over the
  serial port; it stops the first core only.
- The program must not change `VECBASE`, use UART0 for input, switch on interrupts above level 5 or switch off the CPU
  interrupt 14 (`INTENABLE` bit 14): the monitor needs them.
- The WiFi uses the second core; own programs run on the first.
- The WiFi: only as a station (no access point of its own), open networks and WPA2 (no WPA3, no Enterprise), one TCP
  connection at a time, no HTTPS, no Bluetooth.
- While the station is connected, a byte over UART0 comes wrong now and then on the DevKit (measured about one in
  500000; so already before the WiFi service, once a program connected). Packets check their CRC-32 and are sent
  again, so uploads and the debugger are safe. So upload a big text with Board > Files rather than pasting it into
  `put`, or `wlan off` first.
- While the console starts the WiFi (at its start, with `wlan on`, after a program in the large window), the first
  byte that comes in over UART0 within these 100 ms or so may be lost. Asmonite sends a packet without an answer
  again; typed text rarely comes in at that moment.
- The instructions of the ESP32-S3 without `salt` and `saltu` (the LX6 does not have them: Asmonite says so).
- Not yet: own programs in the external flash (through the cache) or in the PSRAM.
- How it speaks with the boot ROM: the serial protocol of esptool (`esptool/targets/esp32.py`).
