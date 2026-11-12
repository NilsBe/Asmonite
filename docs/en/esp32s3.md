# The ESP32-S3 with Asmonite

The ESP32-S3 from Espressif has two Xtensa LX7 cores (240 MHz) and a USB port that is a serial port and a JTAG debugger
at the same time, as the ESP32-C3. Asmonite assembles Xtensa code (`.arch xtensa`), debugs a program in the RAM of
core 0 and writes it into the flash, **with one USB cable, without a debug probe, without OpenOCD and without ESP-IDF**.

Tested with a board with two USB-C ports and an RGB LED WS2812 at GPIO 48 (one port goes to the chip, the other one to
UART0 over a CH343). Other boards whose USB port goes straight to the chip (GPIO 19 and 20) should work the same way;
the port of a USB-serial chip (CP2102, CH340, CH343) gives no USB JTAG.

## What you need

- A board with an ESP32-S3, plugged in at the USB port of the chip. In the Device Manager it shows as
  "USB JTAG/serial debug unit" and as a COM port.
- Windows 10 or 11.

## Setting up once: the USB JTAG

As for the ESP32-C3: **Debug > Debug targets > ESP32-S3 > Set up the USB JTAG**. Windows asks for administrator rights
once; then **Test the connection** should say that the board answers. Windows keeps this for each board (it knows the
board by its serial number, the MAC address of the chip), at every USB port of the computer.

If the board is not "USB JTAG/serial debug unit" but some other Espressif device (its firmware uses the USB port itself,
for example an Arduino sketch with USB CDC or MicroPython), hold **BOOT**, press **RST** and let go of BOOT once: the
chip then waits in its boot ROM and shows its USB JTAG. Asmonite says so when it finds such a board. After the first
program of Asmonite in the flash this is not needed any more.

## A program in the RAM

```asm
.target esp32s3
.arch xtensa
.imagebase 0x40378000

_start:
    ...
```

When the console of Asmonite is on the board (Board > Prepare Board) and the program has no breakpoint, F9 puts it into
the RAM over the console and starts it, without the download mode and without a reset; the tab Serial shows its output
(see [boards.md](boards.md)). F9 first replaces a console of an older version of Asmonite by itself (about 2 seconds;
the files and the network of the board stay), and another WiFi package as well.

With a breakpoint, F7 or F8 the debugger starts. When the console is there, it needs no reset either: Asmonite
connects to the USB JTAG as it is, the console calls its host `dbg_host` as a program, and the core halts there; the
debugger loads the program over JTAG and starts it from there. After the end of the program (also by `exit()` or an
exception that the console catches) or Stop the console is there again; the next session begins after half a second.
Without a console on the board, and for a program for the flash, the way over the boot ROM holds:

Press F9 (run) or F7 (step into). The debugger resets the chip into the download mode of its boot ROM over the USB
serial port (the lines DTR and RTS, as esptool does), stops core 0 there, loads the program to `0x40378000` and runs it
or stops at `_start`. Every session starts on the same clean chip this way: the core at 40 MHz, the watchdogs off, the
peripherals as after a reset. Then: steps (F7, F8), breakpoints (F5), registers `a0` .. `a15`, `pc`, `ps`, `sar`,
`windowbase`, `windowstart` and the loop registers, memory (also as code). The stack pointer `a1` starts at
`0x3FCAFFE0`, the top of the data window of the programs (32 bytes below `0x3FCB0000`, where the WiFi service
begins). If `_start` begins with `entry`, the program comes as from the console (`callx8`, with register windows) and
`retw` ends the session with its `a2`; without `entry` it comes as with call0 and `ret` ends it. Either way `a0`
points to an end mark (`0x403D8000`, a `break` in free RAM). After RST the firmware of the flash runs again.

The assembler takes a program in the RAM from `0x40378000` to `0x403BFFFF` (288 KB); above it lies the console. The
normal window, which aBelle uses and with which the WiFi runs: code `0x40378000 .. 0x4038FFFF` (96 KB), data
`0x3FCA0000 .. 0x3FCAFFFF` (64 KB, the stack in its top 4 KB), see [The WiFi](#the-wifi).

## Xtensa in short

- **Register windows.** `a0` .. `a15` are a window onto 64 registers. `call8 f` calls `f`; its first instruction
  `entry a1, 32` turns the window by 8 and makes its stack frame: `a10` .. `a15` of the caller are `a2` .. `a7` of the
  function (the arguments, `a2` also the result), `a1` is the stack pointer, `a0` the return address. `retw` turns the
  window back. A function that is called needs `align 4` before its label.
- **Constants.** `movi` loads -2048 .. 2047; larger constants and addresses come with `l32r` from a literal: a word
  (`dd`) that stands before the instruction.
- **16-bit instructions.** As GNU as does, Asmonite writes the 16-bit form when the operands fit (`add.n`, `l32i.n`,
  `movi.n`, `mov.n`, `ret.n` ...).
- The instruction reference on the website lists every instruction with its encoding:
  [asmonite.com/en/instr-xtensa.html](https://asmonite.com/en/instr-xtensa.html).

## A program in the flash

```asm
.target esp32s3 flash
.arch xtensa
.imagebase 0x40378000
```

F9 or F7 now write the program into the flash at address 0, as an image of the boot ROM (one segment at
`.imagebase`); the boot ROM loads it into the RAM at every start. The writing goes over the **serial port** of the chip
(the COM port of the board); no terminal program may have that port open at that moment. Then the debugger puts the
program into the RAM as the boot ROM does and runs it there, so breakpoints work as for a program in the RAM. After RST
(or when the board is plugged in again) the boot ROM starts it from the flash by itself.

This replaces the firmware that was in the flash before.

A program that the boot ROM starts from the flash must do two things itself (`examples/esp32s3/rgb_ws2812_flash.asm`
shows how, a few lines at `_start`):

- switch the **watchdogs** off (timer group 0 and 1, the RTC watchdog, and the super watchdog, which is told to feed
  itself): else the chip resets after a few seconds. The debugger switches them off as well, so under the debugger a
  program without them still runs.
- set the **clock** if it counts time: from the flash the boot ROM leaves the core at 20 MHz, in its download mode at
  40 MHz (`SYSTEM_SYSCLK_CONF` at `0x600C0060`, `PRE_DIV_CNT` = 0 gives 40 MHz).

## The serial output and bytes in the RAM

The USB port of the chip has two parts: the JTAG of the debugger and a serial port (CDC; in the Device Manager
"USB Serial Device (COM13)"). What a program writes to the peripheral USB Serial/JTAG (`0x60038000`: a byte into
`EP1`, then `WR_DONE` in `EP1_CONF`) comes out on that COM port, also while the debugger has the JTAG. The tab
**Serial** next to the output window connects to it by itself when the debugger has loaded the program: the reset
into the boot ROM and the writing of the flash go over that port, so the tab lets it go at the start of the session
and opens it again afterwards. At the first output of the program the tab comes to the front, as on the ESP32.
Connect and Disconnect stay usable. `examples/esp32s3/hello_usb_ram.asm` writes
"Hello, world!" once a second there.

The RAM of the program is one memory on two buses. At its IRAM address (`0x40378000` ..) the core fetches
instructions and reads and writes words only: `l8ui`, `l16ui`, `s8i` there stop with a LoadStoreError, as on the
ESP32. On the data bus the same byte is `0x6F0000` lower (`0x3FC88000` for `0x40378000`), and bytes work there:
the example takes `0x6F0000` off the address of its text before it reads it.

## aBelle on the ESP32-S3

`abelle_esp32.exe` (the same compiler as for the ESP32) compiles a program in aBelle with `target "esp32s3"` into the
code for the RAM from `0x40378000` on (up to 96 KB) and the data from `0x3FCA0000` on (up to 60 KB, the same RAM over
the data bus, behind the code; bytes work there; above it the stack and the WiFi). F9 loads it over the USB JTAG and debugs it **in its source**: breakpoints, F7/F8 line by
line, variables under the mouse and in the window Watch. Functions of the boot ROM are made known with `at` and their
address as on the ESP32; on the S3 they are elsewhere (`ets_delay_us` at `0x40000600`, on the ESP32 at
`0x40008534`; `esp32s3.rom.ld` of ESP-IDF). Example: `examples/abelle/esp32s3/hello_usb.abel` writes "Hello, world!"
and a counter over the USB port of the chip; `examples/abelle/esp32s3/rgb.abel` lights the RGB LED of the board
(GPIO 48) red, green, blue and around the colour wheel, the RMT makes the pulses of the WS2812;
`examples/abelle/esp32s3/scan.abel` shows the WiFi networks nearby (see [The WiFi](#the-wifi)).

## The console and its files

`examples/esp32s3/console.asm` is the console of the ESP32 (see [esp32.md](esp32.md)) for the S3: the same commands
(`ls`, `cat`, `put`, `rm`, `df`, `format`, `run`, `load`, `boot`, `help`), the same file system in the flash from 2 MB
to its end (a little over 14 MB on 16 MB) and the same packets for Asmonite. It speaks over the USB port of the chip:
any terminal program on the COM port of the chip, the baud rate does not matter.

The menu **Board** works with the S3 as with the ESP32 (Asmonite takes the S3 when no board with a USB serial chip is
plugged in):

- **Board > Prepare Board** writes the console into the flash over the boot ROM (on the S3 at the address 0) and makes
  the file system when there is none.
- **Board > Files** opens the window **ESP32-S3 Board Files**: **Upload File**, **Download**, **Delete**, **Run**,
  **Autostart**, **Reset Board** and **Format** as on the ESP32; **Board > Set This Program as Autostart** and
  **Board > Advanced > Erase Flash** as well. **Upload This Program** takes a program with `.target esp32s3` or
  `target "esp32s3"` and refuses one for the ESP32.
- A program from the console may use all of the RAM of the programs: code `0x40378000 .. 0x403BFFFF`, data in the
  same RAM over the data bus `0x3FC88000 .. 0x3FCCFFFF`; a program for F9 fits as it is. The console itself lies
  above it (code from `0x403C0000`, data from `0x3FCD8000`). With the WiFi the upper part of it belongs to the WiFi.
- **Board > Advanced > Install WiFi Again** writes the WiFi package anew (seldom needed, see [The WiFi](#the-wifi)).
- **When a program ends, the console is back**, as on the ESP32: `retw` (it says `Program ended (code n)`),
  `exit(code)` by `callx8` to `0x403C0800`, an exception or a `break` (`Program stopped: …`), or **Ctrl+C** (the
  button Stop in the tab Serial; a packet over the USB port raises the NMI, also with the interrupts off). The program runs on
  its own stack (`0x3FCAFFE0`).
- **Functions of the console for programs** as on the ESP32, from `0x403C0800` on (`exit`, `version`, `put_char`,
  `get_char`, `poll_char`, `print`, `millis`, `file_size`, `file_read`, `file_write`, `flash_read`, `args`, 4 bytes
  each; the table is on the page of the ESP32). Programs as commands too, as there: `name args` starts `name` or
  `name.bin` of the files. In aBelle: `include "inc/console.abel"`, example `runs.abel`. Under the
  debugger and without the console `inc/usb.abel` stays.
- After a reset the console waits **3 seconds** before an autostart (on the ESP32 one): with the reset the USB port
  goes away for a moment and comes back, only then can a terminal send a key.

A reset over RTS (as Reset Board) resets the chip only, the USB port stays: a terminal may stay open. Some terminal
programs switch RTS when they open the port and so reset the chip; the console then starts again.

## The WiFi

The WiFi of the S3 comes from the libraries of Espressif (`wlan/`, linked with `python wlan/make_wlan.py --chip
esp32s3`), with an OS layer of its own in assembler in place of FreeRTOS, as on the ESP32 ([esp32.md](esp32.md)). A
service (`wlan/wlansvc_s3.asm`) runs on **core 1** while a program or the console runs on core 0; the debugger stops
core 0 only, the WiFi goes on.

1. The **WiFi package** lies in the flash from `0x100000` to `0x1FFFFF`, as on the ESP32: the library, a head at
   `0x1F0000`, behind it the parts of `wlan.rom` for the RAM and `wlansvc`. When you start a program with
   `inc/wifi.abel` with F9, Asmonite writes the package over the console if it is missing or does not match (about
   300 KB, about 8 seconds). Prepare Board puts it there as well, **Board > Advanced > Install WiFi Again** does it by
   hand.
2. A program in aBelle with `include "inc/wifi.abel"` (from `examples/abelle/esp32s3/inc/`) loads the service itself
   from the package, by `run` in the console as under the debugger. `examples/abelle/esp32s3/scan.abel` shows the
   networks nearby. While the console uses the flash, it parks core 1 as on the ESP32 ([esp32.md](esp32.md)): files
   can be written while the WiFi runs, a connection stays up.
3. To connect to a network (open or WPA2): `wlan set` once in the tab Serial, then its name and password, as on the
   ESP32 ([esp32.md](esp32.md)). The console keeps the name and the key, not the password (about 2.3 seconds), in the
   sectors `0xFE000` and `0xFF000`. The examples are the ones of the ESP32 ([esp32.md](esp32.md)): `dhcp.abel`,
   `ping.abel`, `dns.abel`, `ntp.abel`, `httpget.abel`, `webserver.abel`, `udpecho.abel`, `wol.abel`, `arpscan.abel`,
   `telnetd.abel` (the files of the board through the MMU of the S3, `led` switches the RGB LED WS2812 at GPIO 48);
   they connect to the network of the board with `wifi_connect_saved()`; they write their text over the USB
   port of the chip (`inc/usb.abel` in place of `inc/uart.abel`), the tab Serial shows it. `net.abel` and `tcp.abel`
   are the ones of the ESP32. For WPA2 the service unwraps the group key itself (AES key unwrap of RFC 3394): the ROM
   of the S3 has no function for it, unlike the one of the ESP32.

The RAM with the WiFi (the code bus and the data bus are the same RAM, `0x6F0000` apart):

| Part | Addresses |
|---|---|
| code of the program | `0x40378000 .. 0x4038FFFF` |
| data of the program, stack | `0x3FCA0000 .. 0x3FCAFFFF` |
| the service (`wlansvc`) | `0x403A0000 ..` (entries), data from `0x3FCB6000` |
| `wlan.rom` | `0x403A8000 ..` and `0x3FCBC000 ..` |
| heap of the WiFi | `0x3FCC1000 .. 0x3FCCFFFF` |
| buffers of the WiFi, stack of core 1 | `0x3FCDF000 .. 0x3FCE7FFF`, above the data of the console |

**A large program without the WiFi:** when an aBelle program needs more than 96 KB of code or 60 KB of data,
`abelle_esp32` takes the **large window** and says so when it translates ("Note: … it runs without the WiFi"): the
code may then reach up to `0x4039EFFF` (156 KB, over the window of the data up to the stack), the data lie from
`0x3FCB0000` (up to 128 KB, the room of the service, of `wlan.rom` and of the heap). The console sees from the
addresses that the program reaches into the room of the WiFi, stops the WiFi first and starts it again in the
background when the program has ended; with F9, `run` and the debugger. A program with `inc/wifi.abel` is refused in
the large window.

## The examples

| File | What it does |
|---|---|
| `examples/esp32s3/rgb_ws2812_ram.asm` | The RGB LED WS2812 at GPIO 48: red, green and blue in turn, half a second each. The 24 bits of colour are timed with the cycle counter `ccount`; windowed calls with `call8`, `entry`, `retw` |
| `examples/esp32s3/rgb_ws2812_flash.asm` | The same in the flash, with the watchdogs switched off and the clock set at the start |
| `examples/esp32s3/hello_usb_ram.asm` | "Hello, world!" once a second over the USB port of the chip: the tab Serial shows it |

The registers they use are written in their comments, with the source: the headers of ESP-IDF and the ESP32-S3
Technical Reference Manual.

## If something does not work

| Message or sign | What to do |
|---|---|
| "an Espressif chip is plugged in, but its firmware uses the USB port itself" | Hold BOOT, press RST, let go of BOOT; then F9 again |
| "No ESP32-S3 with its USB JTAG (303A:1001) is plugged in" | The other USB port of the board (the one at the chip), or Debug targets > ESP32-S3 > Set up the USB JTAG |
| "COM13 is open in another program" | Close the terminal, then F9 again |
| The colours of the RGB example are wrong or white | The times of the WS2812 are in cycles: the program must run at 40 MHz (see above) |
| The board restarts every few seconds | A program in the flash that does not switch the watchdogs off; F9 with a program that does (the debugger gets the chip out of the loop) |

## Limits

- Core 0 only is debugged; only the WiFi service starts the second core.
- Not yet: the MAC16 and vector instructions (`ee.*`) of the ESP32-S3, programs in the external flash or PSRAM (only
  the internal RAM), Bluetooth.
- The original ESP32 (Xtensa LX6) has the same instructions (without `salt`, `saltu`), but no USB JTAG: Asmonite
  debugs it over the serial port of the board with a monitor of its own ([esp32.md](esp32.md)).
- How the chip does the debugging: the protocol of `esp_usb_jtag.c` and the Xtensa debug module of OpenOCD
  (`src/target/xtensa`).
