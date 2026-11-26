# Changelog

What changed from version to version. German: [docs/de/aenderungen.md](docs/de/aenderungen.md).

Version numbers: MAJOR.MINOR.PATCH. While MAJOR is 0, a MINOR step may change what
existing sources mean; such changes are listed under "Changed" and marked **(sources)**.

## Unreleased

### New
- **Examples that go through the important instructions, step by step**: `examples/esp32/instructions_xtensa.asm`
  (ESP32, Xtensa), `examples/pico2/instructions_arm.asm` (Pico 2, Cortex-M33), `examples/pico/instructions_arm.asm`
  (Pico, Cortex-M0+, Thumb-1) and `examples/esp32c3/instructions_riscv.asm` (ESP32-C3, RISC-V): each instruction with
  a comment on what it does and the value it gives (values, arithmetic, bits, memory and stack, conditional
  branches, loops, subroutines, a factorial that calls itself). No pin: made for F7 and watching the registers.
- **The clock of the core in the Board Manager**: right-click (or double-click) the line *CPU clock*, choose *Set the
  Clock...* and pick a clock from the list of the board (ESP32, ESP32-S3, ESP32-C3, ESP32-S31, Pico, Pico 2). The
  board keeps it until the next reset. Asmonite sets it with the program `setclock`; if it is not on the board,
  Asmonite compiles `examples/<board>/setclock.abel` and uploads it first. A clock at which the WiFi does not run
  switches the WiFi off first (asked).
- **A page of its own for the Board Manager**: `docs/en/board-manager.md` and the page *Board Manager* on the website
  (its own menu item): a new board in three steps, the window, the info lines, files and programs, the buttons of each
  board, what to do when something does not work. The guides of the boards start with a short "New here?" pointing
  to it; the old button names on the website (Upload This Program, This Program Autostarts, Install WiFi Again, Reset
  Board, Read Chip) are the current ones now.

### Changed
- **The Pico and the Pico 2 over their USB cable only**: the guide (`docs/en/riscv-pico2.md`), the overview of the
  boards, the website and the messages of Asmonite describe the way over the USB cable and the console of Asmonite
  (BOOTSEL once, Prepare Board, then files, F9 and the debugger over that cable); the debug probe is no longer part
  of them. Programs in the flash and for the RISC-V cores of the Pico 2 run as a UF2 file. Debug > Debug targets
  shows no settings for the probe and OpenOCD for now; a probe that is plugged in is still used. The probe gets
  a chapter of its own later.
- **The message when no Pico is found** says what to do over USB: plug the board in, or BOOTSEL and Prepare Board
  when it has no console yet; for a program for the flash it says to give it `.imagebase 0x20000000` or to run it
  as a UF2 file.

### Fixed
- **Prepare Board started from Asmonite with a Pico at its USB cable** showed the hint "behind the debug probe"
  instead of preparing the board.

## 0.16.0 – 2026-11-25

### In short
- **The clock of the core in a program, on every board**: `cpu_clock(mhz)` on the ESP32, the ESP32-S3, the ESP32-C3,
  the ESP32-S31, the Pico and the Pico 2, from 320 MHz (ESP32-S31) down to a few kHz; the console keeps the clock a
  program leaves, `info` and the Board Manager show it.
- **Examples for the network** on every board with WiFi: udpecho, dns, ntp, dhcp, webserver (the files of the board
  in the browser), httpget, wol and httpsget (HTTPS with TLS 1.3, written in aBelle); telnetd, a small shell over
  telnet, on the ESP32, the ESP32-S3, the Pico W and the Pico 2 W.
- **The Board Manager**: a context menu for the files, Examples..., files dragged onto it from the Explorer; the tab
  Serial works like a terminal (Ctrl+C stops the program).
- **Cryptography in aBelle** for every board and for Windows: SHA-256, ChaCha20-Poly1305, X25519; and a compiler of
  aBelle for RISC-V that optimizes (about 27 % less code).

### New
- **aBelle: the clock of the core in a program (ESP32, Pico, Pico 2)**: `cpu_clock(mhz)` of the new `cpuclock.abel`
  (`include "cpuclock.abel"`): on the ESP32 80, 160 or 240 MHz from the PLL and 40, 20, 10, 8, 5, 4, 2 or 1 MHz from the
  crystal (not while the WiFi runs), on the Pico each whole MHz from 48 to 133, on the Pico 2 from 48 to 150; 0 only
  asks. `millis()` and the terminal go on right, on the ESP32 the WiFi too. The console keeps the clock a program leaves
  (also after Ctrl+C): `info` and the line "CPU clock" of the Board Manager show it, a reset brings the default back;
  only clocks at which it could not be reached it does not keep (the ESP32 below 1 MHz: back to 40 MHz; the Pico and the
  Pico 2 from the crystal: back to 48 MHz, Windows cannot open the port anew there). Measured: the same work takes
  12900, 322, 161, 80 and 54 ms at 1, 40, 80, 160 and 240 MHz on the ESP32, 269, 129 and 97 ms at 48, 100 and 133 MHz on
  the Pico, 200, 96 and 64 ms at 48, 100 and 150 MHz on the Pico 2. The consoles of the ESP32, the Pico and the Pico 2
  are new for it (Prepare Board), the WiFi service of the ESP32 too (version 12: it keeps the clock a program set;
  Install WiFi). The UART of the consoles of the Picos now runs from the USB PLL, not from the clock of the core. Down
  to a few kHz with `cpu_clock_khz(khz)`: on the ESP32 from the crystal down to 39 kHz, from its RC_FAST oscillator down
  to about 5 kHz (the terminal silent and `millis()` wrong below 1 MHz); on the Pico and the Pico 2 1 to 12000 kHz from
  the crystal (the terminal goes on, `millis()` is right down to about 1 MHz). In detail: `docs/en/clock.md`.
- **aBelle: the clock of the core on the ESP32-S3**: `cpu_clock(mhz)` of `abelle/lib/esp32s3/cpuclock.abel`: 80, 160 or
  240 MHz from the PLL, 40, 20 or 10 MHz from the crystal (not while the WiFi runs). Not below 10 MHz: the chip's USB
  port, which the console uses, stops working there (characters twice at 8 to 4 MHz, a dead port at 2 and 1 MHz).
  For 240 MHz `cpu_clock` raises the voltage of the core a step and lowers it again afterwards; while the WiFi runs,
  the WiFi service does that on core 1 (the radio uses the same bus inside the chip), otherwise the library writes the
  registers itself (the way through the ROM crashed right after `wlan on`). The console keeps the clock a program
  leaves, `info` shows it. Measured: the same work takes 370, 93, 46, 24 and 15 ms at 10, 40, 80, 160 and 240 MHz; with
  the WiFi connected, pings and DNS work at 80, 160 and 240 MHz. New console (Prepare Board) and WiFi service
  version 13 (Install WiFi; it keeps a clock from the PLL when the WiFi restarts, on the ESP32 too). Examples
  `examples/esp32s3/clockspeed.abel` and `setclock.abel`.
- **aBelle: the clock of the core on the ESP32-C3**: `cpu_clock(mhz)` of `abelle/lib/esp32c3/cpuclock.abel`: 80 or
  160 MHz from the PLL, 40, 20 or 10 MHz from the crystal (not while the WiFi runs), not lower (the chip's USB port, as
  on the S3). No voltage to change on the C3. `millis()` and the terminal go on right, the WiFi too at 80 and 160 MHz;
  the console keeps the clock a program leaves, `info` shows it. Measured: the same work takes 350, 87, 44 and 22 ms at
  10, 40, 80 and 160 MHz. New console (Prepare Board) and WiFi service version 7 (Install WiFi; it can say whether the
  WiFi runs, and its first start keeps a clock from the PLL). Examples `examples/esp32c3/clockspeed.abel` and
  `setclock.abel`.
- **aBelle: the clock of the core on the ESP32-S31**: `cpu_clock(mhz)` of `abelle/lib/esp32s31/cpuclock.abel`: 320, 160,
  80 or 53 MHz from the PLL, 40 MHz divided by a whole number from the crystal down to 1 MHz (not while the WiFi runs),
  with `cpu_clock_khz` down to 156 kHz. The USB port of the S31 keeps working at every clock, so the console keeps
  every clock too; for 320 MHz the voltage of the core goes up one step. `info` shows the real clock, below 1 MHz in
  kHz (the Board Manager too). Measured: the same work takes 3101, 310, 77, 19 and 10 ms at 1, 10, 40, 160 and 320 MHz;
  with the WiFi connected, pings and DNS work at 320, 160, 80 and 53 MHz. New console (Prepare Board). Examples
  `examples/esp32s31/clockspeed.abel` and `setclock.abel`.
- **Board Manager: a context menu for the files, Examples...**: a right click on a file gives Run for a program, Open in
  Editor for a text file (a copy; both also Enter or a double click), Autostart, Download and Delete (also Del), instead
  of their buttons; Upload File and Refresh (F5) stay as buttons and are in the menu too. Files dragged from the
  Explorer onto the window go onto the board. **Examples...** opens an example for the board chosen (`examples\common`,
  the folder of the board when it has one, or the overview of the examples) in the editor; for aBelle, Project > aBelle
  for becomes the board of the tab Serial, so F9 runs it there.
- **Tab Serial like a terminal**: Ctrl+C in the tab always sends Ctrl+C to the board (it stops a program); copying is
  Ctrl+Shift+C, Ctrl+Insert or the new context menu (Copy, Paste to the Board, Select All, Stop); Ctrl+V sends the
  clipboard to the board. Connecting shows the prompt of the console (one Enter when the board has said nothing for
  half a second). A click on the tab, Connect, Reset and Clear put the cursor there, so typing goes to the board at
  once.
- **A Pico without WiFi has no network commands**: on a Pico and a Pico 2 without the W, `wlan`, `name` and `passwd`
  are unknown commands in the console, and `help` and `info` do not mention them (Prepare Board writes help.txt
  without those lines; after Install WiFi on the clone "Pico W-2023" it is the whole text again).
- **Erase Flash on the Pico with a progress bar**: in its USB boot and behind the debug probe the bar counts the 64 KB
  blocks (the STM32 and the ESP32-C3 erase all at once: the bar runs round meanwhile, as on the ESP32).
- **The first examples in assembly in `examples/`**: `windows_intel/demo.asm` (counts from 1 to 5, the program of the
  first steps), `windows_arm/hello_arm32.asm` (Hello, World for Windows on ARM) and `dos/hello_exe.asm` (Hello, World
  as a DOS .EXE with its header by hand). The README of the ZIP names them in place of the examples that are not
  released yet (and no longer `examples\dos\HELLO.EXE` and `examples\winarm\pe_arm32_hello_world.asm`); `examples/README`
  in three parts and a section "In assembly".
- **Deep sleep on the ESP32**: woken from deep sleep by the timer of the RTC, the console starts its autostart
  program at once, without the WiFi and without the second for a key (each costs current at every wake); woken
  another way (a pin, as the button BOOT) it starts no program this time, the way out of a program that sleeps again
  and again. After a deep sleep on the crystal it also sets the cycles per microsecond of the boot ROM right (they
  were wrong, millis() ran three times too fast). Examples `examples/esp32/bme280_sleep.abel` (light sleep between the
  readings, awake 9 ms of each 10 s) and `examples/esp32/bme280_deep.abel` (deep sleep for a minute, what it keeps in
  the slow memory of the RTC; awake about 150 ms per wake, 127 of them for the start of the boot ROM and the console).
- **Examples for the ESP32**: `examples/esp32/bme280.abel` (temperature, pressure and humidity of a BME280 at I2C,
  by hand over the pins) and `examples/esp32/tdisplay.abel` (the colour display of the LilyGO TTGO T-Display: colours,
  a 5 x 7 font, the buttons; SPI by hand), `examples/esp32/tdisplay_spi.abel` (the same through VSPI at 40 MHz: the
  whole screen in 14 ms instead of 350 ms).
- **Wake-on-LAN for every board with WiFi**: `examples/common/wol.abel` sends the magic packet that starts a PC (its
  MAC at the top or as an argument); with the address of the PC it then waits until the PC answers a ping.
- **HTTP for every board with WiFi**: `examples/common/httpget.abel` asks a server for a page (example.com, or the
  address of the argument) and shows the status line, the header lines, the title, the bytes and the time.
- **SHA-256, HMAC and HKDF in aBelle** (`abelle/lib/common/sha256.abel`, the first step towards HTTPS): for every board
  and for Windows, tested with the values of FIPS 180, RFC 4231, RFC 5869 and RFC 8448 (`abelle/tests/lib/sha256_test.abel`).
- **ChaCha20-Poly1305 in aBelle** (`abelle/lib/common/chacha20.abel`, RFC 8439, the cipher for HTTPS): for every board
  and for Windows, tested with the cases of the RFC and random ones (`abelle/tests/lib/chacha20_test.abel`); on the
  ESP32 16 KB in 177 ms.
- **X25519 in aBelle** (`abelle/lib/common/x25519.abel`, RFC 7748, the key exchange for HTTPS): for every board and for
  Windows, tested with the cases of the RFC, edge cases and random ones (`abelle/tests/lib/x25519_test.abel`); on the
  ESP32 one key in 0.8 s.
- **HTTPS for the boards with WiFi**: `examples/common/httpsget.abel` asks a server for a page over TLS 1.3, with a TLS
  client written in aBelle (`abelle/lib/common/tls.abel`: TLS_CHACHA20_POLY1305_SHA256 with X25519). On the ESP32
  the handshake takes about 2 s; tried with example.com, Google, GitHub, Wikipedia and Amazon (1.1 MB in 24 s). The
  certificate of the server is not checked yet. Its parts without the network (`tls_core.abel`) are tested with the
  handshake of RFC 8448 (`abelle/tests/lib/tls_core_test.abel`). Not on the ESP32-C3 yet: too large for its RAM.
- **A compiler of aBelle for RISC-V that optimizes** (`abelle/compiler/abelle_riscv_opt.abel`, `bin\abelle_riscv_opt.exe`;
  the ESP32-C3 and the ESP32-S31): a simple right operand straight into the second register or as an immediate, a
  comparison as one branch. About 27 % less code and up to a quarter fewer instructions; with it `httpsget` fits the
  RAM of the ESP32-C3 (84 KB of code instead of 118 KB). `abelle_riscv` stays as it is; Asmonite does not use the new
  one yet.
- **The library of aBelle in the public repository**: `abelle/lib`, which the examples take in with `include`, is
  there too now (in the ZIP it always was).
- **More examples for the network, for every board with WiFi** (in `examples/common`): `udpecho.abel` sends every UDP
  packet to port 7777 back to its sender; `dns.abel` asks the DNS server of the router for some names, with the time
  of each answer; `ntp.abel` shows the date and the time from a time server, in UTC and in CET or CEST; `dhcp.abel`
  shows what the router gives by DHCP (address, mask, router, DNS server, lease ...); `webserver.abel` serves the
  files of the board to a browser (`http://<address>/` gives `index.html`, the type from the ending, 404 for an
  unknown name; a small `index.html` to upload is next to it).
- **telnetd, a small shell over the network** (`examples/esp32/telnetd.abel`, `esp32s3`, `pico`, `pico2`; the ESP32,
  the ESP32-S3, the Pico W and the Pico 2 W): `telnet esp32.local` or PuTTY with Telnet, commands for the files
  (`ls`, `cat`, `hex`, `df`), the memory (`mem`), the network (`ip`, `ping`, `dns`), the LED (the RGB LED of the S3),
  `uptime` and `reset`; with a password from `passwd set` in the console it asks for it.

### Fixed
- **Pico W, Pico 2 W: name.local stopped working after about two minutes**: the WiFi chip of the Picos dropped the
  mDNS questions (its multicast filter did not let the address of mDNS through), so the PC only found the board while
  it still remembered the announcement. The console now lets them through; the board answers for `name.local` at any
  time (new console: Prepare Board).
- **The message for a program of the Pico on a Pico 2** (and the other way round) named a file that is not in the
  ZIP; it now says to change the line `target` or to choose the board under Project > aBelle for. Three messages of
  the Board Manager named `inc/wifi.abel` instead of `net.abel` or `wifi.abel`.
- **ESP32-C3, ESP32-S31: wlan off without a saved network**: when the board kept no network, or when a program had
  started the WiFi itself, `wlan off` did nothing and the WiFi stayed on. It now switches the WiFi off in any case.
- **Serial tab: "Integer overflow" messages right after connecting**: in the first half second after the tab Serial
  connected to a board, a timer could report an integer overflow, several times in a row.
- **File > Open starts in the folder of the file opened last**: also when it was opened from Open Recent or from
  Examples... of the Board Manager (before, Windows only knew the folder last chosen in the dialog itself); at the start
  of Asmonite the folder of the newest file of Open Recent. A copy of a board file (Open in Editor) leaves it as it was.
- **ESP32: millis() three times too fast without the WiFi**: after a reset the boot ROM may leave its cycles per
  microsecond at 13 while the core runs at 40 MHz (seen after the command reset); the console took 40 MHz only after a
  deep sleep, now at every start.
- **Tab Serial: a selection no longer holds the text back**: while text was selected, new lines from the board scrolled
  the view only as far as the selection could stay in it; now they scroll to the end as without a selection, and the
  selection stays (to copy it).
- **Errors of the compiler and the assembler hidden behind the tab Serial**: the tab Output now comes to the front for
  them.
- **The name of Asmonite.exe** (in the taskbar and the Task Manager) said "x86, x64, ARM and ARM64"; now "multi-target
  assembler, editor and debugger (x86, x64, ARM, ARM64, RISC-V, Xtensa)".
- **The clone "Pico W-2023" after a new console**: when only the RP2040 restarted (a console update over USB, the
  ESP8285 stays powered and talks at 460800 baud) and the ESP sent its frames just then, the console did not find
  it: "The ESP8285 does not answer", or it took the board for a Pico without WiFi and showed what the ESP sent as
  garbage until the board was plugged in again. Bytes with an error between its pings now make the console look for
  it at 460800 (20 of 20 console updates found it; before 2 of 4).

## 0.15.0 – 2026-11-20

### In short
- **One console on every board**: the ESP32, the ESP32-S3, the ESP32-C3, the ESP32-S31 and the Raspberry Pi Pico and
  Pico 2 (W) have a console of Asmonite with the same commands (`ls`, `cat`, `rm`, `df`, `format`, `run`, `boot`,
  `noboot`, `info`, `reset`, `help`, `wlan`, `name`); `load`, `put` and `mem` are gone. `wlan scan` now on every
  board with WiFi, also on the ESP32 and the ESP32-S3.
- **New boards**: the ESP32-C3 and the ESP32-S31 (RISC-V) with console, WiFi, aBelle and the debugger; the Pico and
  the Pico 2 with a console over their USB cable, without a debug probe.
- **WiFi on every board with WiFi**, now also the Pico W, the Pico 2 W, the clone "Pico W-2023" (ESP8285), the C3 and
  the S31: the board keeps its network, answers ping, gets its address by DHCP and answers for `name.local` (mDNS),
  also while a program runs.
- **The Board Manager**: the WiFi of the board from a context menu (the networks the PC sees, the password from
  Windows; WiFi on and off, the mDNS name), the versions of console and WiFi service, plugging in and out followed.
- **One aBelle program for every board** (no `target` line: Project > aBelle for), and the examples in
  `examples/common`: hello, blink, runs, scan, arpscan, ping, pingled.
- **Compile and Upload, Upload and Run**: a program into the flash of the board, started from there; compiling takes
  the text of the editor, also when it is not saved.
- **Plainer English** in Asmonite and Dismonite: the progress, the messages and the dialogs.

### New
- **Compile and Upload, Upload and Run**: Project > Compile and Upload (Ctrl+Shift+F9; Assemble and Upload for
  assembler) puts the program in the editor over the console as a file into the flash of the board of the tab Serial
  (ESP32, ESP32-S3, ESP32-C3, Pico and Pico 2 over their USB cable), under the name of its source without the
  extension; Debug > Upload and Run (Shift+F9) then lets the console start it from there. The program stays on the
  board after a reset (`run name`, Autostart in the Board Manager). A program that runs is stopped with Ctrl+C first,
  a console of another version is brought up to date first (as at F9). For a program for a board F9 is called Run in
  RAM / Continue now. The buttons Upload This Program and This Program Autostarts of the Board Manager are gone (it
  was not clear that they meant the program in the editor).
- **The ESP32-S31** (RISC-V, chip id 32 of the boot ROM): Read Chip names the chip, its package and revision, the
  MAC, the PSRAM in the chip, the crystal and the flash. **A console for it** (`boards/esp32s31`, the one of the
  ESP32-C3 with the addresses of the S31; in the flash at 0x2000, where its boot ROM looks): the files, programs,
  autostart, the packets of the Board Manager, Ctrl+C for a program that runs (Stop in the tab Serial: the interrupt
  of the USB port over the interrupt matrix, source 2, to interrupt 36 of the CLIC of the S31; a race in get_char of
  a program, which lost a key when two came at once, fixed on the way); the core at 160 MHz (the ROM leaves it at
  40 MHz from the crystal: the console switches it to the CPLL, 320 MHz / 2, as the bootloader of ESP-IDF does;
  `info` shows it, `rgb` times its pulses by it); WiFi: see below. In Asmonite: `.target esp32s31` (the RAM 0x2F000000 .. 0x2F07AFBF), the Board
  Manager (Prepare Board, the files, Run, Autostart, Erase Flash), F9 without a breakpoint over the console, Compile
  and Upload, Upload and Run. Found on the chip: the super watchdog takes the key of the other
  watchdogs, and the USB Serial/JTAG does not send a FIFO that filled before the PC opened the port. "ESP32-S31" is no
  longer taken for an ESP32-S3 where Asmonite looks for the name. Test: src/tests/s31contest (21 checks, also with
  the whole flash erased); `boards/esp32s31/s31rom.py` is the test bed over the boot ROM. Tested on an ESP32-S31
  board: revision v0.0, 16 MB PSRAM, 16 MB flash. **aBelle for the S31**: `target "esp32s31"` (or Project > aBelle
  for > the board of the tab Serial), translated by `abelle_riscv.exe` for the RAM of the programs of its console (the
  code from 0x2F000000, 304 KB and 16 KB of stack); `abelle\lib\esp32s31\console.abel`: the functions of the console
  (from 0x2F060200) and `gpio_output`, `gpio_write` (GPIO 0 .. 61, the USB pins 33 and 34 left alone). F9 runs it over
  the console, Compile and Upload and Upload and Run put it into the files. Tested on the board: `hello.abel`, the
  pins, `millis`, `file_size`, `exit`. **The RGB LED** of the S31 board (a WS2812 at GPIO 60): `rgb(pin, colour)`
  (0xRRGGBB, 0 off), a function of its console (version 4, at 0x2F06023C; the pulses timed by mcycle, the core at
  40 MHz) and of `console.abel`; Prepare Board puts the new console on the board. **The debugger for the S31**: F9
  with a breakpoint, F7 and F8 debug a program of aBelle or of assembly (`.target esp32s31`) over the USB JTAG of the
  chip, core 0: its console starts the program (`dbg_run`, as on the C3; an assembler program ends with `ret` or
  `exit`), breakpoints (4), steps, pause, the registers and the variables; the end of the program ends the session.
  Found on the chip: its JTAG chain has two TAPs (the LP core at TDO, IDCODE 0x00003C25, in BYPASS; the HP cores
  0x00020C25), its USB JTAG brings the interface GUID of its own (no setup in Debug targets), the reset with the hart
  halted is ndmreset. Fix for the C3 too: after Stop the program goes on, and at its end the hart halted in the debug
  mode for ever at the ebreak behind `dbg_run` (the console was gone until a reset): the debugger puts a nop there
  when it leaves, and ebreak is an exception again. Test: src/tests/s31dbgtest (27 checks; with the argument c3 the
  same over the console of the ESP32-C3).
- **WiFi on the ESP32-S31**: the WiFi libraries of Espressif for the S31 (WiFi 6) linked by `ablink --chip esp32s31`
  (the same bytes as GNU ld), the OS layer and the service of the ESP32-C3 brought over (one source for both,
  `wlan/wlanradio_s31.asm` for the clocks of the modem, the CLIC and the analog I2C of the S31), as a WiFi package in
  the flash (Install WiFi in the Board Manager). In its console as on the C3: `wlan set`, `wlan on`, `wlan off`,
  `wlan clear`, `wlan scan`; the board connects in the background, gets its address by DHCP, answers ARP and ping and
  starts the WiFi by itself after a reset. Found on the chip: without the bootloader of ESP-IDF the access filters
  of the S31 (APM) let only the CPU into the memory, so the WiFi could send but never received a frame (the WiFi
  service turns them off now, as that bootloader does); and the clock of the WiFi baseband must not stay forced on
  (then the radio takes no frame of 11n/11ax, ESP-IDF too): the PMU must gate the clocks in the active state
  (ICG_SYS_CLOCK_EN), the forcing stays for the calibration only. Tests: `wlan/wlantest2_s31` .. `wlantest5_s31`
  (calibration, scan, frames, a connection with DHCP and 4 pings to the router), src/tests/s31contest (28 checks with
  the network of the board). Not on the S31 yet: telnet.
- **aBelle programs in the network on the ESP32-S31**: `abelle/lib/esp32s31/wifi.abel`, the one of the ESP32-C3 at
  the places of the S31 (its WiFi service at 0x2F03A000, its TRNG), so `net.abel` and `tcp.abel` run there as on the
  other boards (the tests translate them for the S31 too). On the C3 and the S31 a program starts the WiFi itself
  now, as on the other boards: the first `wifi_` call asks the console (`wifi_up`, a new function of the console at
  +64, `console_version()` 5) when no `wlan on` has loaded the WiFi service since the reset.
- **The examples `examples/common/scan.abel`, `arpscan.abel` and `ping.abel`**: the WiFi networks near the board,
  who is in the network (ARP), and the ping of the router, of a server or of a host given; one source each for
  every board with WiFi.
- **`wifi_scan` on the Pico W and the Pico 2 W**: operation 11 of `wl_call` of their console (`console_version()` 4)
  scans as `wlan scan` does and gives the networks as on the ESP32 (48 bytes each: BSSID, channel, RSSI, protection,
  name), so a program that scans runs on every board with WiFi. The protection comes from the IEs of each network
  (open, WEP, WPA, WPA2, WPA/WPA2, WPA2 Enterprise, WPA3, WPA2/WPA3); the clone "Pico W-2023" gives the one of its
  ESP8285. Prepare Board brings the console of a Pico up to date.
- **`wifi_pings()` on every board with WiFi**: how many pings to the board were answered; the program does not see
  them, the WiFi service (ESP32 and ESP32-S3: version 11, a word at +104; ESP32-C3 and ESP32-S31: version 5, an entry
  at +0x50) or the console of the Pico W and the Pico 2 W (operation 12 of `wl_call`, `console_version()` 5) answers
  and counts them. Install WiFi or Prepare Board in the Board Manager brings a board up to date.
- **The Board Manager shows the versions**: "Console: v2 (current: v2)" (the number `console_version()` gives, from
  the new packet V of every console, and the one of the console of this Asmonite), on an ESP32, S3, C3 and S31 "WiFi
  service: v10 (current: v11; "Install WiFi..." to update)" (read out of the WiFi package in the flash). Fewer
  lines: the WiFi state, the network, the address and the name in one ("connected to <network>, <address>
  (<name>)"), the serial port only when the name of the device does not end with it, the maker of the driver behind
  the USB id, no USB serial number (on an ESP32-S3/C3 it is the MAC), on a
  Pico the board and telnet in short. A right click copies one line (Copy Line) or all of them (Copy All).
- **The WiFi of the board from the Board Manager**: a right click on the line WiFi (or a double click) offers Set
  Network..., WiFi On / WiFi Off, Forget Network... and Set mDNS Name... (name.local, the router shows it too; not on
  the C3 and S31); on the line telnet Set Password... and Clear Password.... Set Network... lists the networks this PC sees (signal, 2.4 or 5 GHz: the boards use 2.4 GHz
  only) and, on the ESP32-C3, ESP32-S31, Pico W and Pico 2 W, the ones the board sees (Scan with Board); From Windows
  fills in the password Windows has saved for the network chosen. The Board Manager types the commands of the console
  (`wlan set`, `wlan on`, `wlan off`, `wlan clear`, `name set`, `passwd set`, `passwd clear`) and answers its questions; no
  password is written anywhere.
- **mDNS on the Pico W, the Pico 2 W and the clone "Pico W-2023"**: the console answers questions for
  `name.local` (the name of `name set`, else the one of the MAC: `picow-1a2b.local`), in the background as it answers
  ARP and ping: at the prompt and while a program runs (the ESP32 and the S3 at the prompt). As on the ESP32: to all
  (224.0.0.251) when the question came from port 5353, else to the one who asked. A question the console answered
  does not go to the program (it would answer it once more). About 500 bytes in each console.
- **The command `load` is gone** from the consoles of the ESP32, ESP32-S3, ESP32-C3 and ESP32-S31 (the Picos never
  had it): the WiFi does not need it (the console takes its parts from the WiFi package in the flash), `run name`
  starts a program as before. The tests of the WiFi stages put the parts of wlan.rom into the RAM over the packet R,
  which may now also write the room between the programs and the console (ESP32, S3). "Prepare Board..." brings a
  board to the new console.
- **The consoles alike**: `reset` on the ESP32 and the ESP32-S3 too (the board starts again as with its reset button;
  the USB port of the S3 goes away for a moment). `put` (a file typed in) is gone from the consoles of the ESP32, S3,
  C3 and S31 (the Picos never had it): files go onto the board with the Board Manager (Upload File...) or Compile and
  Upload. `mem` (a look into the memory) is gone from the consoles of the Pico, Pico 2, C3 and S31: the debugger shows
  the memory. So all consoles have the same commands for files and programs. The help of the Pico and the Pico 2 is
  the file `help.txt` now, as on the ESP boards (Prepare Board and Format write it, from `boards/pico/help.txt` and
  `boards/pico2/help.txt`; without it `help` shows a short list): about 700 bytes more room in their consoles.
  `file_write` for programs on the Pico and the Pico 2 too (it answered -1 there): a file written as Upload File
  writes it, with the same answers as on the ESP boards (0, or -1 the directory is full .. -5 no file system).
  **`name` and mDNS on the ESP32-C3 and the ESP32-S31** too: `name`, `name set keller`, `name clear` as on the other
  boards (kept in the record of the network; `wlan set` and `wlan clear` keep it); their WiFi service (version 6)
  gives it to the router (DHCP) and answers mDNS for `keller.local`, also while a program runs. The Board Manager
  offers Set mDNS Name... for them and shows `.local`. **Ctrl+C** (Stop in the tab Serial) stops a program on the C3
  and the S31 also when it waits in the WiFi service nearly all the time (pingled: it did not stop).
- **Compile: the text of the editor** (Project > Save before compile off): the compilers of aBelle, C and Pascal read
  the text in the editor too, unsaved changes included (as the assembler always did), from a hidden copy `~name` next
  to the source (its includes are found there), removed afterwards; the messages and the map name the source. Before,
  they read the file on disk.
- **Debug > Stop (Ctrl+F2) without a debug session**: when the tab Serial is connected to a board, it sends Ctrl+C as
  the button Stop of the tab does: a program of F9 or of the autostart stops.
- **A console for the ESP32-C3** (`boards/esp32c3/console.asm`, RISC-V), as on the ESP32 and the ESP32-S3: over
  the USB port of the chip (a terminal, such as the tab Serial), in the flash at 0. The files in the flash from 2 MB
  on (`ls`, `cat`, `rm`, `df`, `format`), programs from the files (`run`, `boot`, `noboot`, the name
  alone with arguments; a program ends with its code, by exit(), by an exception or by Ctrl+C), `info`,
  `reset`, `help` (help.txt). The Board Manager knows it: Prepare Board writes the console, help.txt, a file system
  and the WiFi package; the files, Compile and Upload (`.target esp32c3`, `.arch riscv32`, `.imagebase
  0x40380000`), Run, Autostart, Format, Reset, Erase Flash. The C3 tells who it is by the new packet H (its USB
  port looks like the one of the S3).
- **WiFi on the ESP32-C3**: the WiFi libraries of Espressif for the C3 linked by `ablink --chip esp32c3` (the same
  bytes as GNU ld), the OS layer, WPA2-PSK and a WiFi service with entries at fixed addresses, all in RISC-V
  assembler (`wlan/*_c3.asm`), as a WiFi package in the flash as on the ESP32 (Install WiFi in the Board
  Manager). In the console: `wlan set` (the name and the password of the network; the board keeps the key, not the
  password), `wlan on`, `wlan off` (they stay over a reset), `wlan clear`, `wlan scan`; the board connects in the
  background, gets its address by DHCP, answers ARP and ping and starts the WiFi by itself after a reset. The C3 has
  one core: a timer (every 10 ms) gives the tasks of the WiFi a turn, also while a program computes; a task of the
  service (`wlan/wlannet_c3.asm`) keeps the connection, answers ARP and ping and renews the address, whatever runs
  (on the ESP32 and the S3 DHCP is in the console, only because their service has no room for it). A program calls
  the service itself; `wifi_get_ip` gives the address, the mask, the router and the name server. Tested on the C3 of
  the LilyGO T-PicoC3, pinged by an ESP32 in the same network, also while a program computes for 60 s. Not on the C3
  yet: telnet, the bridge for the RP2040 of the T-PicoC3.
- **aBelle on the ESP32-C3**: the compiler `abelle_riscv.exe` (RISC-V, RV32IM; `target "esp32c3"`), the program in
  the RAM of the programs of the console from `0x40380000`, `inc/console.abel` with the functions of the console of
  the C3, the example `hello.abel`. In Asmonite F9, F7, F8 and the variables over the USB JTAG: the console starts the
  program (its new entry `dbg_run`, console version 3) and is at its prompt again afterwards. Checked without a board
  against the x86 programs (`abelle/tests/riscv_tests.py`, an emulator of RV32IM: 1000 random programs, the same
  numbers). The network: `inc/wifi.abel` over the WiFi service of the C3 (it keeps the connection and the address),
  `inc/net.abel` and `inc/tcp.abel` as on the ESP32, the examples `dhcp`, `ping`, `dns`, `ntp`, `arpscan`, `httpget`.
- **`info` in the consoles of the ESP32 and the ESP32-S3**, as on the ESP32-C3: the chip and the clock of its core,
  the flash (its size, its JEDEC id), the MAC of the station, the version of the console. Their `.data` grew from
  4 KB to 5 KB (buffers moved up), so that each console keeps at least 1 KB of code and 256 bytes of data free.
- **RISC-V: the compressed instructions of 2 bytes (C)** with `.option rvc` (as GNU as; `.option norvc` switches it
  off): the assembler writes the short form wherever one fits, about a fifth less code (the console of the ESP32-C3:
  29.7 KB -> 22.3 KB). `addi`, `li`, `mv`, `add`, `lw`/`sw` (also on `sp`), `ret`, `jr`, the shifts and bit
  operations; jumps and branches to a label when it is near (`j`, `beqz`, `bnez`; `call` and `tail` as `c.jal`/`c.j`
  within 2 KB, as `jal` within 1 MB, else auipc + jalr as before). The `c.` instructions (C and Zcb, RV32 and RV64)
  can also be written by hand. Without the line every program stays byte for byte as it was. Checked: every 16-bit
  instruction the disassembler reads assembles back to the same 2 bytes; random instructions give the same bytes as
  GNU as (`tools/rvc_gnu_check.py`); the debugger of the ESP32-C3 steps over a call of 2 bytes. Watch: data words
  read by `lw` need `align 4` in front, a table of jumps of 4 bytes each `.option norvc` around it.
- **`pins.abel`** (ESP32): finds out on which GPIO an LED hangs, without a meter. `pins` in the console reads each
  pin with its pull-up and with its pull-down (an LED to GND or to 3.3 V holds the pin, a free pin follows the pull),
  then lets the candidates blink with the weakest drive; `pins 2` lets GPIO 2 blink until a key comes.
- **The Board Manager follows plugging in and out** while it is open: a board plugged in shows in the list (the board
  chosen stays chosen); the board chosen unplugged: no board chosen and a line that says so, and the next board
  plugged in is chosen (the same one again, or another one; also when one board is changed for another at once).
  Two DevKits with the same serial number count by their port. A reset of the board by the window itself (the USB port of an ESP32-S3 goes for a moment) does
  not count.
- **`fm.abel`** (ESP32, ESP32-S3): the files of the board in the browser, a first version that only reads. `run fm` in
  the console, then `http://name.local/fm`: the facts of the board (chip, name, addresses, flash, free room, autostart)
  and its files, each to view (as text or in hex) or to download. `/` shows `index.html` of the board, and files with
  an ending of the web (`.html`, `.css`, `.js`, `.png` ...) are there under their names: your own pages from the
  board. With a password (`passwd set`, the one of telnetd) the browser asks for it at `/fm` (any user name); your own
  pages stay open. A file `fm.html` on the board takes the place of the page built in (`/fm?builtin` shows that one
  always); the page gets its data as JSON from `/api/info` and `/api/files`.
- **A console for the Raspberry Pi Pico 2** (`boards/pico2/console.asm`, its Arm cores), on the way to a console
  as on the ESP32: in the flash, it copies itself into the RAM (0x20070000) and runs there; UART0 at GPIO 0 and 1
  with 115200 baud, through the UART of the Raspberry Pi Debug Probe (its connector "U") in the tab Serial. The
  prompt `> `, `help`, `info` (the chip, its revision, the cores, the boot ROM), `mem addr [n]`, `reset`; a read
  where nothing is shows the exception and the prompt comes again. The files in the flash from 1 MB to 4 MB, as on
  the ESP32 (`ls`, `df`, `cat`, `rm`, `format`), written by the functions of the boot ROM, and the packets of
  Asmonite for them (up, down, list, delete, the program for boot). Programs from the files: `run name [args]` or
  the name alone, `boot name` (after a reset, a key within a second stays in the console), `noboot`; a program
  ends with its code, by exit, by a fault or by Ctrl+C (Stop in the tab Serial), and the prompt comes again. The
  functions of the console for programs (put_char, get_char, print, millis, file_size, file_read, args ...) are a
  table at 0x20078140; `examples/pico2/hello_console.asm` uses them. In the Board Manager the Pico 2 behind the
  Debug Probe shows its files with the buttons of the ESP32 (upload a file or the program in the editor, download,
  delete, run, autostart, format); Prepare Board writes the console into its flash over the probe. F9 debugs over
  the probe as before.
- **The same console for the Raspberry Pi Pico** (RP2040, `boards/pico/console.asm`): the commands, the files and
  the packets as on the Pico 2, in Thumb-1 for its Cortex-M0+. The console runs in the RAM at 0x20030000, the
  programs at 0x20000000 .. 0x2002FFFF (`.target pico`), the table of the functions at 0x20038140
  (`examples/pico/hello_console.asm`); the files in the flash from 1 MB to 2 MB; `reset` through the watchdog. The
  Board Manager shows the Pico behind the Debug Probe with its files and Prepare Board as for the Pico 2.
- **A USB device of its own on the Pico and the Pico 2** (`examples/pico/usb_echo_ram.asm`,
  `examples/pico2/usb_echo_ram.asm`, the code in `examples/pico/usb_cdc.asm`), without the SDK: over the USB cable of
  the board a COM port on the PC (USB CDC-ACM, the driver of Windows), a greeting when a terminal opens it, an echo of
  what comes (Enter as a new line). F9 loads it into the RAM over the debug probe. Tested on the Pico and the Pico
  2.
- **The consoles of the Pico and the Pico 2 over the USB cable of the board as well** (`boards/pico/console_usb.asm`,
  driven by the interrupt of the USB controller): a COM port of its own on the PC (1209:0001), the prompt, the
  packets of Asmonite (files about ten times as fast as over the UART), programs, Ctrl+C, reset; the UART of the probe
  goes on as before. The consoles run at 48 MHz from PLL_USB now.
- **The Pico and the Pico 2 without the probe:** the Board Manager knows the console at USB ("Pico (USB console)",
  "Pico 2 (USB console)": the serial number of the device is the chip) with its files, Run, Reset Board; F9 runs a
  program in the RAM over it (no breakpoint, the tab Serial at its port). Prepare Board for a Pico in its USB boot
  (BOOTSEL): the console as a UF2 file onto its drive. Prepare Board at the USB console: an update without the button
  (1200 baud: the console restarts the chip into its USB boot, then the UF2 file; the files stay). Tested on both.
  The serial number of the console at USB is the chip and the id of the board (the OTP of the RP2350, the unique id
  of the flash chip on the Pico): each board gets a COM port of its own.
- **Pico W and Pico 2 W known:** the consoles ask the WiFi chip of the board (CYW43439) at their start
  (`boards/pico/console_wifi.asm`); the hello, `info` (the line *board*), the new packet H and the Board Manager (the
  title "Pico W", "Pico 2 W", the photo, the line *Board* with a word on the LED) name the board. Tested on a Pico, a
  Pico W, a Pico 2 and a Pico 2 W.
- **aBelle on the Pico and the Pico 2:** a fourth compiler, `abelle_pico.exe`, translates programs with
  `target "pico"` or `target "pico2"` into Thumb-1 for the console of the board (in its RAM from `0x20000000`). F9 runs
  them over the console; with a breakpoint F9, F7 and F8 debug them, over the USB cable or the Debug Probe, with the
  variables. `include "inc/console.abel"` gives the functions of the console (text, `millis()`, the files, `args()`,
  `led(on)`); examples `hello.abel` and `blink.abel` in `examples/abelle/pico` and `pico2`. The consoles put their
  functions also as code to call at a fixed place (from `0x20039E00` / `0x20079E00`) and have `led(on)`: the LED of the
  board (GPIO 25; on a Pico W or Pico 2 W at the WiFi chip, see below).
- **The WiFi chip of the Pico W and the Pico 2 W starts** (the first step of the WiFi there): `wlan on` in the console
  sends the firmware of the CYW43439 (Infineon, 7.95.61) from the files `43439A0.bin` and `nvram_rp2040.bin` over the
  SPI of the chip into its RAM (about 226 KB in 0.6 s), and its Arm core runs; then the console talks to the firmware
  in packets (SDPCM, ioctl and iovar) and gives it its CLM data (`43439A0_clm.bin`); `wlan off`, `wlan`. `led()` of
  the programs switches the LED of a W at the chip (its first call starts the chip): `blink.abel` blinks it
  unchanged. Prepare Board puts the three files onto a W, only those that are not there as they are; the ZIP has
  them in `wlan\infineon`, unchanged, with the license of Infineon. `wlan scan` lists the networks around (the
  signal, the channel, open or secured, the name). `wlan set` asks for a network and its password and joins it
  (WPA2 with AES, or open); as on the ESP32 the console keeps the name and the key of WPA2 (PBKDF2), not the
  password, in the last two sectors of the flash (the files end 8 KB earlier now); `wlan on` joins it again,
  `wlan clear` forgets it. Tested on a Pico 2 W (a WPA2 network, a wrong password, a reset, clear) and on a Pico W
  (the firmware, the scan, wlan set, wlan on after cold starts, `blink.abel` lights its LED).
- **aBelle programs on the network on the Pico W and the Pico 2 W:** the consoles give programs the frames of the
  network (`wl_call`, a new function of the console; `console_version()` 3); `inc/wifi.abel` in
  `abelle/examples/pico` and `pico2` builds the functions of the ESP32 on it (`wifi_connect_saved`, `wifi_send`,
  `wifi_recv`, `wifi_mac` ...), so `inc/net.abel` (ARP, IPv4, ping, UDP, DHCP, DNS, mDNS) and `inc/tcp.abel` run as
  on the ESP32. Examples `dhcp`, `ping`, `dns`, `ntp`, `arpscan` and `httpget` for both boards. When a program asks
  for it, the console starts the chip and joins the network the board keeps (`wlan set`); the chip and the network
  stay after the program. Tested on a Pico W (all six; Ctrl+C in the middle of one; no network kept) and on a
  Pico 2 W (all six, cold starts).
- **The console of a Pico W and a Pico 2 W in the network:** after a join it gets an address by DHCP and renews it
  at half the lease (`wlan on` and `wlan` show it with the mask, the router and the DNS server); once after its start,
  after 3 quiet seconds at the prompt, it joins the network it keeps by itself ("WiFi: connected, address ...").
  SysTick looks at the WiFi chip every 10 ms: it answers ARP and ping for the board at the prompt, while a program runs
  (also one that does not use the network) and while it stands at a breakpoint; `wlan` counts the answers. `name`,
  `name set`, `name clear` (the name for the router) and `passwd`, `passwd set`, `passwd clear` (the password for
  telnet, kept as a key) as on the ESP32. `telnetd.abel` for both boards (the shell over telnet of the ESP32). A join
  that fails says the answers of the access point ("(events; ... PSK_SUP status 8 reason 15)": a wrong password).
  The Board Manager shows for a W the WiFi, the address, the MAC, the name, the network kept and whether telnet asks
  for a password (the packet N, as on the ESP32, with two fields more). Tested on a Pico 2 W, also from a PC: ping
  (also by the mDNS name while telnetd runs) and telnet with its commands; on a Pico W the start, name, passwd, the
  packet N, the examples and telnetd. `ping.abel` (ESP32, ESP32-S3, Pico W,
  Pico 2 W) pings the host of its argument: `ping 192.168.178.20` or `ping example.com` in the console.
- **Debugging the Pico and the Pico 2 without the probe:** the consoles have a debug monitor
  (`boards/pico2/console_mon.asm`, `boards/pico/console_mon.asm`). When the tab Serial is at the USB console of
  the board (or no probe is plugged in and the board is there with its console) and the program is for the RAM, F9 with a breakpoint, F8 and F7 debug over the USB cable: breakpoints,
  steps, Pause, the registers and the memory; USB and the console go on while the program stands. The Pico 2 takes
  the breakpoints and steps in its Cortex-M33 (the exception DebugMonitor); the Pico, whose Cortex-M0+ has none, stops
  at BKPT instructions that Asmonite writes. Write to Flash and the RISC-V cores of the Pico 2 still need the probe.
- **One aBelle program for every board:** a program without a line `target` is translated for the target of
  **Project > aBelle for** (Windows x86, Windows x64 or the board in the tab Serial; Asmonite keeps the chip of each
  board). The compilers take `--target <board>` for it, and an `include` that is not next to the file comes from the
  library `abelle\lib\<board>\`, then `abelle\lib\common\`: `console.abel` (the same functions of the console on
  every board and on Windows; `println` and the like in `console_text.abel`), `wifi.abel` per board, `net.abel` and
  `tcp.abel` for all. `def main():` works on Windows too (exit code 0). Tested: the same `examples/common/hello.abel`,
  the first example for every board (`include "console.abel"`, `println("Hello, world!")`), writes "Hello, world!"
  over the serial output on six boards. Pins: `gpio_output(pin)` and `gpio_write(pin, on)` in `console.abel` of
  every board (the registers of the chip are inside); the Pico W and the Pico 2 W know `WL_GPIO0` too, the pin of
  their WiFi chip with the LED. The second example, `examples/common/blink.abel`, blinks the LED with them: set
  `LED_PIN` for your board at its top (the known boards are in its comment).
- **WiFi on the clone "Pico W-2023"** (an RP2040 with an ESP8285 at UART0 instead of the CYW43439 of a Pico W): a
  firmware of our own for the ESP8285 (`wlan/esp8285_fw.asm`, Xtensa LX106, with the libraries of the ESP8266 NONOS
  SDK of Espressif, linked by `ablink --chip esp8266`) that passes the frames over UART0 (SLIP, 460800 baud) to the
  console. Board Manager > **Install WiFi (ESP8285)** writes it into the ESP8285 through the console of the Pico (the
  board plugged in with its BOOT button held; about 40 s, with a progress bar). The console finds the ESP8285 at its
  start ("Raspberry Pi Pico (WiFi: ESP8285)", with a photo in the Board Manager) and uses it as the WiFi chip of a
  Pico W: `wlan set`, `wlan on`, `wlan off`, `wlan scan`, the WiFi at the start by itself, ARP and ping in the
  background, DHCP, `inc/wifi.abel` for programs. UART0 belongs to the ESP8285 then, the console talks over USB only.
  Tested with `ping` (the router and the internet), a wrong password and a network that is not there.

### Changed
- **The consoles of the boards are in `boards\` now**, next to the photos of the Board Manager:
  `boards/esp32/console.asm` (with `help.txt` and the DHCP part), `boards/esp32s3`, `boards/esp32c3`,
  `boards/pico`, `boards/pico2` (also the two blink programs with which the Board Manager switches the cores of
  the Pico 2). Asmonite looks for them in `boards\` next to Asmonite.exe; `examples\` is for the examples.
- **The examples are gone through again, one by one.** `examples/` has only those that are tested anew (at
  first none; aBelle programs for every board will be in `examples/common/`); the ZIP and the public repository
  take only these. The older examples (in assembly and in aBelle, before in `examples/` and `abelle/examples/`)
  are in `examples_internal/` of the source repository until then.
- Board Manager: the button Look Again is called **Scan** now (Alt+N).
- Board Manager: the button Reset Board is called **Reset** now (Alt+S); as before it restarts the board and keeps it
  in the console (an autostart program does not run), its tooltip says so. Reset in the tab Serial restarts it as its
  reset button does (an autostart program runs).
- Board Manager: the button Install WiFi Again is called **Install WiFi...** now (Alt+W).
- An empty flash: Erase Flash writes a small park program into the erased flash (`boards/<chip>/park.asm`, ESP32,
  S3, C3, S31): the board starts quietly and says every 3 s that it is empty, instead of restarting again and again;
  then the Board Manager asks whether to run Prepare Board right away. A board that restarts again and again with an empty
  flash ("invalid header: 0xffffffff", "flash read err") is shown as "Console: none (the flash is empty; ...)" in
  the Board Manager, and the tab Serial says so. While Erase Flash works, its progress bar moves.
- Plainer English in Asmonite and Dismonite: the progress steps ("Writing the WiFi library"), the messages after a
  job ("WiFi package installed (352 KB in 9.8 s)") and all dialogs say what happens in plain words.
- Board Manager: the button Read Chip is called **Chip Details** now (Alt+C); its tooltip names what it reads (chip
  and revision, MAC, flash, PSRAM, crystal) and that the board restarts.

### Fixed
- ESP32-C3: an aBelle program that uses `millis()` (a blink with pauses, say) hung under F9 at its first wait. The
  USB JTAG reset the chip before the load; the console stayed in the RAM but was not set up (its timer stood). Now
  it only halts the console where it runs, without a reset (it starts the program as `run` does, the WiFi stays);
  when it is not set up, the console starts from the flash after the reset first.
- The console of the Pico W would have taken itself for a board with an ESP8285 after its first DHCP: the word for
  that lay in the same memory as the address of the router (never released, found with the clone).
- The consoles of the Pico and the Pico 2 changed r7 of a program in their fault handler: on the Pico every step under
  the debug monitor without the probe goes through it, so a program that keeps something in r7 lost it after a step.
- The Debug Probe after a program that ended between a command and its answer (a crash): Asmonite said "the probe
  answers another command" until the probe was plugged in again, as the old answer waited in the probe. It reads the
  old answers away now when it opens the probe, and drops an answer to another command.
- The Thumb assembler wrote `adds r0, r0, #39`, `subs r2, r2, #200`, `sub sp, sp, #12` in the 32-bit form of
  Thumb-2: on the Pico (Cortex-M0+, Thumb-1 only) such a line was refused, on the Pico 2 and the Blue Pill it took 4
  bytes instead of 2. It takes the 16-bit form now when the constant fits.
- Buttons, check boxes and radio buttons of Asmonite (the Board Manager, the bar of the tab Serial and the other
  windows) were invisible after Alt or Alt+Tab until the mouse went over them (found by the user): a fault of Delphi 7
  with the themes of Windows; they paint themselves again now when Windows shows or hides the underlines of the keys.
- telnetd (ESP32, ESP32-S3) took the first of the two copies of the directory also when the second one was newer (it
  compared their marks, not their numbers): `ls` could show the files as they were before the last write of the
  console.

## 0.14.0 – 2026-11-14

### New
- **The name of the board** (ESP32, ESP32-S3): `name set keller` in the console gives the board a name, `name` shows
  it, `name clear` takes the one of the MAC again (`esp32-789a`, the S3 `esp32s3-789a`). The router learns it by DHCP,
  the console answers mDNS for `name.local` at its prompt and says the name with the address; telnetd, webserver and
  the other network programs take the same name (`inc/net.abel` reads it; the fixed `esp32` / `esp32s3` are gone).
- **A password for telnet** (ESP32, ESP32-S3): `passwd set` in the console (8 to 63 characters; the board keeps 12
  bytes of a PBKDF2-SHA1 key of it, not the password), `passwd`, `passwd clear`. telnetd asks for it and ends the
  connection after the third wrong one; without one it lets everyone in and says so. `inc/wifi.abel`:
  `wifi_login_set`, `wifi_login_check`.
- **Ping without a program** (ESP32, ESP32-S3): once the WiFi of the console is connected, the console gets an
  address by DHCP and says it ("WiFi: connected, address ..."), and the WiFi service on the second core answers ARP
  and ping for it itself, also while a program runs that reads no frames. So the board answers ping after a restart
  or a power cut. The console asks again at half the lease time and says "WiFi: no connection." when it is gone.
  `dhcp_run` of `inc/net.abel` gives its address to the service the same way (new: `wifi_set_ip`, `wifi_get_ip`).
- **The Board Manager** (Board > Board Manager) takes the place of the window Board Files. It shows the boards plugged
  in, a photo of the board chosen, what Asmonite finds out about it without disturbing it (chip and revision, flash,
  the console, the cores that run; MAC, crystal and, on the S3, the PSRAM in the chip with Read Chip; the network of
  an ESP32 or ESP32-S3: WiFi off, connecting or connected, its address, MAC and name) and only the buttons that fit
  the board:
  - ESP32, ESP32-S3: the files of the console as before; Reset Board, Read Chip (over the boot ROM: the board
    restarts), Prepare Board, This Program Autostarts, Install WiFi Again, Format, Erase Flash.
  - ESP32-C3: Reset Board, Read Chip, Erase Flash, over its boot ROM.
  - Pico, Pico 2 and the STM32F103 Blue Pill behind the debug probe: Reset Board, Erase Flash; the Pico 2 also
    RISC-V Cores / Arm Cores (the example `blink` of the other cores goes into the flash).
  - The Pico in its USB boot (BOOTSEL): Start Program, Erase Flash. The Pico 2 in its USB boot: Arm Cores, RISC-V
    Cores, over its drive.
  - A board Asmonite does not know: what Windows tells about it, no buttons.
- The Board Manager **opens by itself** when a board is plugged in for the first time, also when Asmonite starts with
  such a board plugged in (remembered in the section `[Boards]` of `Asmonite.ini`).
- With several boards plugged in, the Board Manager and the tab Serial keep to the same board: the Board Manager opens
  with the board of the tab Serial, and when it closes, the tab Serial connects to the board chosen last in it.
- **telnetd tries again** (ESP32, ESP32-S3): without its network or an address by DHCP it says so and tries again every
  10 seconds instead of ending (after a power cut the router may start slower than the board); after a loss of the
  WiFi it ends the session and gets an address again. It ends only when the board keeps no network.
- The ZIP has the photos of the boards in `boards\`.

### Changed
- **The tab Serial is a terminal you type into**: the keys go to the board at once, as in PuTTY (Enter, Backspace,
  Ctrl+C without a selection stops the program, Ctrl+V pastes); a program that reads single keys gets them without
  Enter. The box **Line** in its header shows the line below as before, for a program that writes nothing back.
- **The help of the console is a file** on the board, `help.txt` (ESP32, ESP32-S3): Prepare Board, Format and each
  update of the console write it; `help` shows it, without it a short list. The console has about 600 bytes more of
  room for its data.
- **Programs for the boards have no extension**: `blink.abel` becomes `blink` (abelle_esp32 without a name for the
  program, Asmonite next to the source and on the board). Upload This Program and This Program Autostarts remove a
  `blink.bin` of an older Asmonite and move an autostart that named it to `blink`. The console still finds `name.bin`.
  Sources keep `.abel`.
- **The menu Board** has only **Board Manager...** now. **Write to Flash and Run (ESP32)** is in the menu Project.
  Set This Program as Autostart is the button **This Program Autostarts**; Prepare Board, Erase Flash and Install
  WiFi Again are buttons of the Board Manager.

### Fixed
- telnetd on the ESP32 could stop the board with "IllegalInstruction" when it started while the WiFi of the console
  was connecting (as an autostart after a power cut, when the router is not there yet): it set up the MMU of the first
  core for the files while the second core ran the WiFi from the flash. The console maps the files at its start now,
  before its WiFi, and telnetd leaves the MMU as it is once the WiFi runs; it also takes the size of the flash the
  console knows instead of asking the flash (`wifi_flash_size` of `inc/wifi.abel`).
- After a program that F9 (or Run of the Board Manager) started over the console had ended, the console showed no
  prompt until Enter (ESP32, ESP32-S3); it writes `> ` again now.

### Known
- Two ESP32 DevKits with the USB serial chip CP2102 have the same serial number ("0001"); the second one counts as
  seen already and does not open the Board Manager by itself.

## 0.13.0 – 2026-11-12

### New
- **The ESP32-S3 as a second board for aBelle, the console and the WiFi.** Everything the original ESP32 has since
  0.12.0 now works on the ESP32-S3 too, over the USB port of the chip (no USB serial chip needed):
  - aBelle with `target "esp32s3"` (the compiler `abelle_esp32.exe`): F9 runs a program, breakpoints, steps and
    variables in the source. Examples in `examples/abelle/esp32s3/`, among them `hello_usb.abel` and `rgb.abel` (the
    RGB LED of the board, a WS2812 at GPIO 48, driven by the RMT).
  - The console with its file system (`examples/esp32s3/console.asm`, the file system up to the end of the flash).
  - The WiFi: scan, open networks and WPA2, DHCP, DNS, ping, TCP. The WiFi examples of the ESP32 (`dhcp`, `ping`,
    `dns`, `ntp`, `httpget`, `webserver`, `udpecho`, `wol`, `arpscan`, `telnetd` and others) are there for the S3 as
    well. The WiFi libraries of Espressif are linked by `ablink --chip esp32s3`; the S3 has no `aes_unwrap` in its
    ROM, so the WPA2 code of Asmonite brings its own (AES-128 key unwrap, RFC 3394).
- **The console is the home of the programs** (ESP32 and ESP32-S3):
  - **F9 runs a program over the console:** into the RAM, started there, its output in the tab **Serial**. No
    download mode, no BOOT button, no reset, nothing of the output lost. **Stop** (or Ctrl+C) ends it, also an
    endless loop with the interrupts off; then the console is back.
  - **Debugging over the console:** with a breakpoint F9 starts the debugger without a reset of the board; after the
    session the console is there again.
  - A program returns to the console when `main` ends, by `exit(code)` from any depth, or after an exception (the
    console says why).
  - **Functions of the console for programs:** a table at a fixed place (ESP32 `0x4009C800`, S3 `0x403C0800`):
    `exit`, `version`, `put_char`, `get_char`, `poll_char`, `print`, `millis`, `args`, `file_size`, `file_read`,
    `file_write`, `flash_read`. aBelle: `include "inc/console.abel"`, example `runs.abel`.
  - **Programs as commands:** a word the console does not know starts the file of that name; the rest of the line
    are its arguments.
  - The tab **Serial** connects by itself when Asmonite starts or the board is plugged in, and shows the chip and the
    console in its header.
- **The WiFi as a service of the console** (ESP32 and ESP32-S3):
  - `wlan set` stores the network on the board (the password is asked without echo; the board keeps only the WPA2
    key derived from it), `wlan`, `wlan on`, `wlan off`, `wlan clear`.
  - With a stored network the console connects at its start in the background. Programs use that connection at once
    (`wifi_connect_saved()` in `inc/wifi.abel`) and leave it for the next program (`wifi_done()`). The WiFi examples
    end and return to the console; the servers run until Stop.
  - The WiFi library and the service lie in a fixed part of the flash (the WiFi package). F9 puts it there when a
    program needs it.
  - The flash can be written while the WiFi runs (the console parks core 1 for it).
  - A program too large for the space beside the WiFi gets that space too (ESP32: 112 KB of code instead of 76;
    S3: 156 KB of code and 128 KB of data); the console stops the WiFi for it and starts it again afterwards.
    `abelle_esp32` says so ("it runs without the WiFi").
- **The menu Board** (between Debug and Help): **Files...** (the window Board Files), **Set This Program as
  Autostart**, **Prepare Board...** and **Advanced**: **Write to Flash and Run...** (with a warning: it takes the place
  of the console), **Erase Flash...**, **Install WiFi Again...**.
- **Prepare Board:** a board without the console of Asmonite (new, erased, MicroPython) is recognised; Prepare Board
  writes the console and makes the file system. Asmonite offers it at F9.
- **Updates by themselves:** before F9 and before debugging, Asmonite compares the console on the board with its own
  and writes its own when they differ (the files and the network of the board stay), then the WiFi package if needed.
- **`.if`, `.elif`, `.else`, `.endif`** in the assembler: conditions on constants (`equ`, numbers, comparisons, `&&`,
  `||`, `!`, `defined(name)`); one source for several chips. A constant may now stand before `.format`, `.target`
  and `.output`.

### Fixed
- **ESP32-S3 boards that reset at the start of the WiFi:** on some boards (chip v0.2) the clock glitch detector reset
  the chip about 0.3 s after the radio started, and the USB port went away. The WiFi service and the console switch
  that reset off before the radio starts; Asmonite brings the new WiFi package onto a board by itself.
- **The window Debug targets** cut the last lines of longer texts; it measures its texts now and grows with them.
- ESP32: UART0 with the WiFi running: the console counts the bytes in the FIFO as ESP-IDF does and switches the clock
  before its hello, so packets of Asmonite no longer come garbled. The examples `hello_uart_ram.asm`,
  `hello_uart_flash.asm` and `clock_ram.asm` write UART0 over `0x60000000`, as the console does.
- Pause while a program waits in a function of the boot ROM (for example `ets_delay_us`) stops in the source after
  the return (Xtensa).

### Changed
- **(sources)** Fixed windows of memory for programs, the same on every way (F9, the console, with or without the
  WiFi):
  - ESP32: aBelle code up to 76 KB (`0x40080000 .. 0x40092FFF`); the assembler and the debugger take a program up to
    `0x4009BFFF` (above it lies the console).
  - ESP32-S3: aBelle code up to 96 KB (`0x40378000 .. 0x4038FFFF`), the data from `0x3FCA0000` up to 60 KB, above
    them 4 KB of stack. `.data` of the assembler without an address starts at `0x3FCA0000` (before `0x3FCA8000`).
- **Write to Flash and Run** is in the menu Board under Advanced; Shift+F9 is gone. The window Board Files keeps only
  the files, Reset Board and Format.
- The debug monitor of the ESP32 lies in the RTC FAST memory (`0x400C0000`), so the IRAM stays for the programs and the
  console.
- ESP32-S3: the debugger sets the data cache as a start from the flash does (32 KB).
- Known: on the ESP32 DevKit, while the station is connected, about one byte in 500 000 over UART0 comes wrong;
  packets have a CRC and are sent again.

## 0.12.0 – 2026-11-10

### New
- **aBelle**, a small programming language with the look of Python, close to the hardware (`.abel`). Its compiler is
  written in aBelle and compiles itself; it writes the machine code itself, with a map for the debugger. Three
  compilers in the ZIP next to Asmonite: `abelle.exe` (Windows, x86), `abelle64.exe` (Windows, x64; Project > aBelle
  for x64) and `abelle_esp32.exe` (the ESP32, `target "esp32"`). In Asmonite F9 compiles and debugs an `.abel` file in
  its source: breakpoints, F7/F8 line by line, variables under the mouse and in the window Watch by their type, F1
  help on the words of the language. On the ESP32: registers as arrays at a fixed address
  (`gpio: u32[0x140] at 0x3FF44000`), functions of the ROM (`def ets_delay_us(us: u32) at 0x40008534`), F9 into the
  RAM, Shift+F9 into the flash. Examples in `examples/abelle/` and `examples/abelle/esp32/` (blink, timer, chipinfo,
  clock, dice, reaction, sieve, temperature ...). Page: asmonite.com/en/abelle.html.
- **WiFi on the original ESP32**, without ESP-IDF: **Debug > ESP32 Board Files > Install WiFi** puts the WiFi onto
  the board (its part in the flash at 0x100000, `wlan.rom` and the service `wlansvc` into the files of the console;
  `wlan.rom` holds the WiFi libraries of Espressif, linked once by Asmonite's own linker, Apache License 2.0, see
  `wlan/`). An aBelle program loads the service itself (`inc/wifi.abel`), by `run` in the console as under F9. The
  WiFi runs on the second core: the debugger stops the program on the first core at a breakpoint while the station
  stays connected. Scan, open networks and WPA2, frames in and out; a small IP stack in aBelle (`inc/net.abel`: ARP,
  IPv4, ping both ways, UDP, DHCP with the name of the board, DNS, mDNS: the board answers to `esp32.local`) and TCP
  (`inc/tcp.abel`, one connection at a time, as a client or a server). Examples: scan, dhcp, dns, ping, wol (Wake on
  LAN), arpscan, ntp, udpecho, httpget, webserver (`http://esp32.local/`), telnetd (a small shell over telnet: the
  files, memory, ping, the LED). An error of the WiFi comes as a sentence (`wifi_error_text`). Page:
  asmonite.com/en/esp32.html.
- Assembler: **`.include "name"`** puts the text of another file in this place (the name counts from the folder of
  the file the line is in; each file is read once, an included file may include others). Error messages and warnings
  name the included file and its line (`inc\uart.asm(12): ...`), in Asmonite and in `asmoc`. When the debugger
  stops in an included file, the editor shows it in place of the source, read only; breakpoints, single steps, F4
  and the values under the mouse work there as in the source. F1 help: directives.
- ESP32: **`.data`** puts texts, tables and buffers into the DRAM (from `0x3FFB0000`, or `.data 0x3FFC0100`), where
  bytes can be read and written: the IRAM of the program takes words only, so `l8ui` on a text there stopped with a
  LoadStoreError. `.code` goes back to the code. The debugger loads the data after the code; a program for the flash
  gets them as a second segment of the image, which the boot ROM copies at every start. Data that runs into the stack
  (`0x3FFBF000..0x3FFC000F`) or out of the DRAM is an error. `examples/esp32/hello_uart_ram.asm` reads its text byte
  by byte now, new: `hello_uart_flash.asm`.
- Website: the original documentation of each instruction reference has one link per line.
- Docs: `docs/en/boards.md`, which board is debugged how (over a debug probe, or with the USB cable alone) and how its
  serial output reaches the PC, also as a table on the page of the targets; new guides for the Blue Pill
  (`stm32.md`) and the LilyGO T-PicoC3 (`t-picoc3.md`); riscv-pico2.md, picoboot.md and d1.md say what there is
  without a probe and for the serial output.
- ESP32: what the program writes to UART0 under the debugger shows in the tab **Serial** (as it comes, the tab
  comes to the front), no longer as "UART0: ..." lines in the output window. While the session lasts Connect, the
  port, the baud rate and the input are off and the header says that the debugger has the port; a port connected in
  the tab is let go at the start (F9 said "COM14 is open in another program" before).
- Raspberry Pi Pico 2, Pico and Blue Pill: the tab Serial connects by itself to the UART of the Raspberry Pi Debug
  Probe (its connector "U") when a session over the probe has loaded the program; it switches DTR on for it (the
  probe sends only then), and leaves it off for the boards of Espressif. New examples `hello_uart_ram.asm` for the
  Pico 2 (RISC-V; `hello_uart_arm_ram.asm` for Arm), the Pico and the Blue Pill: "Hello, world!" at 115200 baud
  (the RP2040 and the RP2350 start their crystal for it). The guide riscv-pico2.md says how the cable goes.
- ESP32-S3 and ESP32-C3: the tab Serial connects by itself to the serial port of the USB port of the chip when the debugger has
  loaded the program (it lets it go at the start: the reset into the boot ROM and the flash use it); the debugger
  keeps the JTAG of the same port. New `examples/esp32s3/hello_usb_ram.asm` (USB Serial/JTAG). The guide says how
  bytes are read in the RAM: the IRAM address takes words only, the same byte on the data bus is 0x6F0000 lower.
- ESP32: **Debug > Pause** stops a running program, also in an endless loop, and Stop ends the session at once (it
  had to wait for a breakpoint before). The debug monitor of Asmonite takes a byte on UART0 as an NMI while the
  program runs. Tested on the board with the flash too (`.target esp32 flash` under the debugger).
- The tab Serial: the list of the ports shows the port first (`COM14 - Silicon Labs CP210x USB to UART Bridge`), so a
  narrow box still shows it; the list that drops down is as wide as its longest entry, and the whole entry is the
  hint of the box.

- Instruction info (F1): every instruction of the assembler has a section now. Where the help has no explanation of
  its own (most of SSE, x87, the floating point and Neon of ARM64, the instructions of Xtensa), F1 shows the short
  section from the instruction reference: syntax, operation, flags (help/<language>/<arch>_ref.md, made by
  tools/gen_help_ref.py from the tables of the assembler). New: a help for Xtensa (register windows, `l32r`, `loop`,
  the shifts through `SAR`, loads and stores and the IRAM, special registers), the overviews `x87` and `sse` for
  x86 (F1 on an x87 or SSE instruction shows them after its own section).
- **File > Open Recent**: the last five files, opened or saved under a new name (kept in the ini file); a file that
  is not there any more leaves the list.
- Asmonite and Dismonite: the mouse wheel scrolls the part of the window under the pointer (editor, registers, stack,
  memory, output), not the one with the focus.
- ESP32: new example `examples/esp32/clock_ram.asm`: the core from the crystal (40 MHz) and from the PLL at 80, 160
  and 240 MHz, as the bootloader of ESP-IDF sets it up (the PLL over the I2C bus inside the chip with the function
  `rom_i2c_writeReg` of the ROM, called with `callx8`; the voltage of the core for 240 MHz); UART0 and the timer
  follow every change of the clock of the peripherals. It writes how fast a loop goes at each clock: on a DevKit V1
  6664, 13333, 26666 and 40000 turns per millisecond.
- ESP32: new example `examples/esp32/console.asm`, a **console over UART0 with a small file system** in the flash,
  for any terminal program (115200 baud): `ls`, `cat`, `put` (type or paste a text, up to 64 KB, then a line with
  only a dot), `rm`, `df`, `format`, `help`. Backspace, Ctrl+C, and CR, LF or CR LF at the end of a line work. The
  file system takes the upper 2 MB of a flash of 4 MB: a directory of 64 files, kept twice, so a reset while it is
  written leaves the old one; each file with its CRC-32. The flash is written with the functions of the ROM. What
  comes in is kept in a ring of 4 KB while the console sends, so a pasted text of 62 KB arrives whole. Write it with
  Debug > Write to Flash and Run, stop the session, then use the tab Serial (Connect, Reset) or another terminal. It
  does not run under the debugger: the debug monitor takes every byte on UART0 as its pause.
  A program on the PC talks to it in packets (STX, the command, the length, the data, CRC-32): files of any kind
  and size up and down (about 10 KB/s), the list, the room, remove; a damaged piece is sent again. Asmonite has the
  other side in `src/debugger/EspConsole.pas`.
  `run name` starts a program from a file (the image that Asmonite writes into the flash: code and `.data`), `boot
  name` starts it after every reset (a second to stay in the console: BOOT or a key), `noboot` ends that. A program
  for F9 fits as it is: the console lies above it (code from `0x4009C000`, data from `0x3FFD0000`); its file is
  checked by its CRC-32, its segments by their addresses. `load name` puts the parts of a program for the RAM into
  their place without starting it, also into the room between the programs and the console (IRAM `0x40098000` ..
  `0x4009BFFF`, DRAM `0x3FFD8000` .. `0x3FFDFFFF`); segments for the flash it leaves out. A part put there by
  `load` may bring commands of its own (at `0x40094000` the word `CMDS` and the address of a table of names,
  functions and lines for `help`); the console forgets them after a reset. Its waiting times follow the clock of the
  core (`g_ticks_per_us_pro` of the ROM), also when a program has changed it.
- ESP32: **Debug > ESP32 Board Files**, a window for the files of the console: the list (with the program that
  starts after a reset), Upload File, Upload This Program (the program in the editor as an image), Download, Delete,
  Run (then the tab Serial shows what it writes), Autostart, Reset Board, Format, Write Console to Flash. The work
  goes on in the background with its steps and a bar; Cancel stops it. Docs: esp32.md has a part on the console and
  says how Write to Flash and Run works.
- ESP32: **Debug > Write to Flash and Run** (Shift+F9) writes a program for the RAM (`.target esp32`) into the flash
  first, as `.target esp32 flash` does, then debugs it as F9: the board runs it at every start. So the same source goes
  into the RAM or into the flash without a change (`.target esp32 flash` stays as it was).
- Boards: a **start window** in the middle of Asmonite while a session starts (from half a second on): the steps
  (connect, the resets into the download mode with the attempt, the debug monitor, the program, the flash, the run to
  the line), a bar for the bytes, the time so far, and **Cancel**. It goes when the program runs or has stopped. All
  steps on the ESP32; the other boards show connect, program or flash, and the run to the line.
- ESP32: a step over a line that takes long (a loop in one line, `for: pass` in a compiled program) runs on at full
  speed after 100 single steps, with breakpoints at the starts of the lines.
- ESP32: the flash is written at 921600 baud (Write to Flash and Run, Write Console to Flash): the boot ROM changes
  its rate (CHANGE_BAUDRATE) and a read at the new rate checks it; if the board does not manage it, Asmonite starts
  the boot ROM again and writes at 115200. 334 KB took 14.6 s instead of 44 s.
- ESP32 debugger: a program of 16 KB or more is loaded at 921600 baud (98 KB in 6.3 s instead of 21 s). The debug
  monitor changes the rate of UART0 on the command `b` and goes back by itself if no answer comes at the new rate;
  each piece of 8 KB is read back and written again if it differs. Before the program runs or steps, the rate is
  115200 again, as the program expects it.
- ESP32 Board Files: an upload or a download of 16 KB or more goes at 921600 baud (100 KB up in 3.7 s instead of
  11.5 s, down in 1.8 s instead of 9.6 s). The console changes the rate of UART0 on the packet `S` and goes back if
  the next packet does not come right; at its end each transfer goes back to 115200, the rate of a terminal.
- ESP32: the size of the flash of the board, from its JEDEC id (the command 0x9F through SPI1, as esptool
  flash_id): Test the connection and Board Files show it ("flash 4 MB (Boya, JEDEC id 68 40 16)"), Write to Flash
  refuses an image that does not fit, Erase Flash erases the whole of it, and with less than 4 MB Board Files warns
  and does not format (the file system of the console lies at 2 to 4 MB). The console answers the packet `I` with
  the id. The example chipinfo shows it too.
- ESP32 console: the file system reaches from 2 MB to the end of the flash (2 MB on a flash of 4 MB as before, 6 MB on
  one of 8 MB such as a WROVER; up to 16 MB). A board formatted before keeps its size until Format.
- ESP32: when writing the flash at the faster rate fails although the rate passed its check (a USB serial chip that
  takes 3 MBaud), Asmonite starts the boot ROM again and writes the whole image at 115200: no half written image is
  left.
- ESP32 Board Files: **Erase Flash...** erases the whole flash (4 MB on the DevKit) over the boot ROM, as a new board: no console,
  no files (8 to 17 s). Write Console to Flash and Format make it a board for Asmonite again.

### Fixed
- ESP32: the debugger could not load a program of more than about 34 KB ("Cannot write the program to 40080000"):
  it sent it in one piece, which took longer than the serial port may take for one write. It goes in pieces of 8 KB
  now. The message of such an error says why (and no longer points to `.imagebase 0x20000000` of the Pico).
- Boards: Pause and Stop did nothing while a step went on instruction by instruction (a long line): the session
  stayed "running". A Stop that the board does not answer within 3 seconds ends the session all the same.
- ESP32: a reset of the board while the program ran (the button EN, the power) left Asmonite "running", and neither
  Pause nor Stop ended it. The boot ROM's line `rst:0x...,boot:0x...` on the port now ends the session with a note.
- Instruction info (F1): with `.arch riscv64` and with `.arch xtensa` it showed the help of x86.
- ESP32: a program whose calls go deeper than the 64 registers of the windows hold (more than about seven `call8`)
  stopped with a double exception in the overflow handler: the monitor now puts a frame below the first `sp` for the
  caller of `_start`, as ESP-IDF does.
- ESP32: while a program kept the second core (the APP CPU) busy, `examples/esp32/console.asm` now and then got a
  byte from UART0 twice. The console and the debug monitor read and write UART0 now as ESP-IDF does (the RX FIFO at
  `0x3FF40000`, the TX FIFO at `0x60000000`), the monitor empties the RX FIFO at a stop, and both look at UART0 less
  often while they wait: a core that keeps the APB busy can make the reads of DPORT registers of the other core go
  wrong (an errata of the ESP32).
- x86 assembler: a displacement of 128 to 255 in 32-bit code (`mov eax, [esp+200]`, `[ebx+200]`) was written as one
  byte, which the processor reads as -128 to -1; it takes 32 bits now. 16-bit code keeps 0 to 255 as one byte, as
  written.
- `.format pe`: a section whose size is a multiple of 0x200 (code of exactly 0x200, 0x400, 0xC00 ... bytes) got the
  size 0x1000 in the headers: Windows did not load the program, or it crashed. A label at the end of such a section
  (`data_end:`) had the address of the start of the next one.

## 0.11.0 – 2026-11-06

### Fixed
- A character as an immediate works outside x86 too: `movs r0, #'0'` (Thumb), `li a0, 'A'` (RISC-V), `movi a2, '1'`
  (Xtensa). Thumb also takes the short spellings of GAS: `lsrs r1, r1, r3` and `ands r2, r2, r4` give the 16-bit
  form, `muls r1, r0` works, `dsb`, `dmb`, `isb` need no option, and `mrs`/`msr` know the special registers of the
  Cortex-M (`primask`, `control`, `msp`, `psp`, `basepri`, `faultmask` ...). With `.target pico` a load or store
  whose offset is too large for the Cortex-M0+ (`ldrb r0, [r2, #40]`) says the ranges it has.
- A word with a colon is a label in every mode but x86, also when it is the name of an x86 instruction: `loop:` was
  refused under `.arch riscv32` (and thumb, x64, arm64).
- Pico 2: switching from the Arm cores back to the RISC-V cores works again when the chip is in its USB boot
  (BOOTSEL), for example because the flash holds no program the boot ROM can start. The Arm core stopped there in
  the HardFault of the boot ROM ("stopped for another reason (DFSR 03, pc 000002F8)"): the USB boot runs in the
  Non-secure state, with a stack limit and the RAM marked Non-secure. The debugger now makes the core Secure for the
  flash functions of the boot ROM. A program for the other cores without an IMAGE_DEF block is no longer written
  (the boot ROM could not start it, the chip would stay in its USB boot): the debugger says so instead.

### New
- **The Raspberry Pi Pico (RP2040) without a debug probe:** when the board is in its USB boot (hold BOOT, press RUN:
  the drive RPI-RP2), F9 and F7 on a program with `.target pico` for the RAM debug it over the USB cable alone:
  breakpoints, steps line by line, step over a call, the registers, the RAM; when the program returns, the output
  window shows r0 and r1. A small stub of Asmonite at 0x2003F000 is called by the boot ROM (PICOBOOT, the interface
  of picotool) and comes back at each breakpoint. No pause of a running program; programs in the RAM only (below
  0x2003F000). Once for each board: the driver WinUsb Device for "RP2 Boot", then Debug > Debug targets >
  Raspberry Pi Pico > "Set up the USB boot". Tried on a LilyGO T-PicoC3. Guide: `docs/en/picoboot.md`.
- Examples: `examples\esp32c3\sum_ram.asm` (the sum of 1 to 100 by a function, without any pin: for every C3
  board) and `examples\t-picoc3\display_ram.asm` for the LilyGO T-PicoC3 (an RP2040 and an ESP32-C3 on one
  board): the RP2040 fills its display (ST7789 over SPI0) and turns the red LED on; as a UF2 for the RAM
  (Project > UF2, then onto the drive RPI-RP2), the flash stays as it is. Both tried on the board.
  `examples\t-picoc3\lines_ram.asm`: a white frame and lines in the colours of the rainbow on the display (a routine
  that fills a rectangle), made for the debugger over the USB boot: it returns, the next F9 draws again.
  `examples\t-picoc3\text_ram.asm`: text with a font of its own (5 x 7 dots, digits and capitals) and a counter that
  counts up on the display while the red LED blinks; a key of the board ends it.
- **ESP32 (the original, Xtensa LX6): run and flash** with `.target esp32` and `.target esp32 flash` (`.arch xtensa`,
  the IRAM at `0x40080000..0x4009FFFF`): F9 resets the chip into the download mode of its boot ROM over the lines DTR
  and RTS of the USB serial chip of the board (CP210x, CH340, CH9102, CH343, FTDI), as esptool does, and puts the
  program into the RAM and runs it, or writes it into the flash at `0x1000` (an image of the boot ROM, chip id 0) and
  resets the chip. A reset is checked by the first line of the boot ROM and tried again until it says "DOWNLOAD"; a
  board that does not get there in 10 seconds is told to the user ("hold BOOT"). **Debugged** over the same serial
  port: a small debug monitor of Asmonite (`esp32mon.asm`, 2 KB at the top of the IRAM) takes the vectors of break,
  ICOUNT and the exceptions and speaks with Asmonite over UART0 (registers, memory, run, step): breakpoints, steps into
  and over windowed calls, the registers; what the program writes to UART0 shows in the log. No pause yet.
  `salt`, `saltu` are refused for the LX6. Debug targets: the entry ESP32 with Test the connection (the
  COM port and the MAC address). Examples `examples/esp32/` (`blink_ram.asm`, `blink_flash.asm`: the LED at GPIO 2;
  `hello_uart_ram.asm`: text on the COM port of the board). Guide: `docs/en/esp32.md`.
- **RISC-V with 64 bits (RV64)**: `.arch riscv64` in the assembler and the disassembler: RV64I, M, A, the RV64 forms
  of Zba, Zbb, Zbs, Zbc, Zbkb, the 16-bit forms of RV64 (`c.ld`, `c.sd`, `c.addiw` ...); `li` takes any 64-bit
  number, with a label 4 instructions that keep an address from `0x80000000` on positive. Checked against capstone;
  F1 help for the new instructions.
- **MangoPi MQ-Pro (Allwinner D1, RV64)** with `.target d1`: F9 loads the program over USB into the SRAM of the chip
  (the FEL mode of its boot ROM, one cable, no sunxi-fel, no JTAG) and **debugs it**: breakpoints, steps line by
  line, the registers with 64 bits, the memory; when `_start` returns with `ret`, the log shows `a0` and `a1`. A small
  stub of Asmonite at `0x27800` runs the program between two calls of the boot ROM and comes back at a breakpoint
  (`ebreak`) or an exception; a running program cannot be paused. Debug targets: the entry MangoPi MQ-Pro with Test
  the connection. Examples `examples/d1/` (`sum_ram.asm`, `fibonacci_ram.asm`). Guide: `docs/en/d1.md`.
- **The tab Serial** next to the output window: a small terminal for the serial port of a board. After F9 on an ESP32
  it shows what the program writes to UART0 and sends a typed line to it; Disconnect lets the port go, Connect opens
  any serial port by hand (the list of Windows with the names of the devices, the baud rate; kept in the ini file),
  Reset pulses RTS (EN) on the boards of the ESP32. Light grey on black. DTR and RTS stay off, so opening the port
  does not reset the chip.

## 0.10.0 – 2026-11-06

### New
- **Xtensa: assembler and disassembler** (`.arch xtensa`), for the ESP32-S3 (Xtensa LX7; the ESP32, LX6, has the same
  instructions without `salt`, `saltu`): the core instructions, the 16-bit instructions of the code density option
  (written by themselves when the operands fit, as GNU as does: `add.n`, `l32i.n`, `movi.n`, `mov.n` ...), windowed
  calls (`call4/8/12`, `entry`, `retw`), zero-overhead loops, multiplication and division, minimum and maximum, the
  boolean registers, single precision floating point, the special and user registers by name (`rsr.ps a3` or
  `rsr a3, ps`), constants from a literal pool with `l32r` and `dd`. Checked against GNU as and objdump of Espressif
  (more than a million instruction words without a difference). The editor colours the lines after `.arch xtensa`. Not
  yet: MAC16 and the vector instructions of the ESP32-S3 (`ee.*`).
- **ESP32-S3 over its USB JTAG, with one cable.** `.target esp32s3` (the RAM at `0x40378000..0x403BFFFF`) and
  `.target esp32s3 flash`: F9/F7 reset the chip into the download mode of its boot ROM over its USB serial port (no
  button needed, unless a firmware uses the USB port itself), stop core 0 there, load the program and run it or stop at
  `_start`; steps (also into and out of windowed calls), breakpoints, step over, pause, the registers `a0`..`a15`, `pc`,
  `ps`, `sar`, `windowbase`, `windowstart`, `lbeg`, `lend`, `lcount` (editable), the memory also as Xtensa code. With
  `flash` the program goes into the flash as an image of the boot ROM, then runs in the RAM as the boot ROM puts it
  there. The debugger switches the watchdogs off at every stop. Debug targets: *ESP32-S3* with *Test the connection* and
  *Set up the USB JTAG*. Examples `examples/esp32s3/` (`rgb_ws2812_ram.asm`, `rgb_ws2812_flash.asm`: the RGB LED at
  GPIO 48). Guide: `docs/en/esp32s3.md`.
- Website: the Xtensa instruction reference (224 instructions with encoding, ESP32-S3 and ESP32), and the ARM assembly
  tutorial for the Raspberry Pi Pico 2 (after the ARM-ASM-Tutorial of Niklas Gürtler, with his kind permission).

### Fixed
- ESP32-C3: a debug access that the debug module answered with "busy" or "failed" left the connection stuck (both
  stay until the debugger clears them); now it is cleared and repeated, without doing a write twice.

## 0.9.3 – 2026-11-05

### New
- **STM32F103 ("Blue Pill", Cortex-M3) over the USB debug probe.** `.target stm32f103` (also `bluepill`) with
  `.arch thumb`: the assembler checks the program (RAM 20 KB at `0x20000000`, flash at `0x08000000` with the vector table
  at its start). F7/F9 reset the core and halt it, load a program into the RAM, or write it into the flash through the
  flash controller of the chip (only the pages of 1 KB that differ) and reset the chip; steps, breakpoints (in the RAM
  software breakpoints), registers, memory. The device id (`DBGMCU_IDCODE` 0x410) is checked: on another chip nothing is
  written. A program that sleeps in `wfi` stays reachable (`DBGMCU_CR`). Debug targets: *STM32F103 (Blue Pill)* with
  *Test the connection*. Wiring: SWCLK, SWDIO and GND of the probe to the four pins of the board, 3V3 stays free.
  Examples `examples/stm32/` (`blink_ram.asm`, `blink_flash.asm`: the LED at PC13). Tested with an original STM32F103C8.

### Fixed
- Raspberry Pi Pico and Pico 2 (Arm cores): a program in the RAM started on the core as the program before had left it:
  its SysTick ran on, and an exception it was in kept the interrupts of the new program from being taken. Now the core
  is reset and halted before it starts (the peripherals keep their state). A program in the RAM without a vector table
  gets the end of the RAM as its stack pointer (before it was right only by chance).
- Pico 2: writing the flash right after a program in the RAM failed ("the boot ROM function ... stopped") until the board
  had been unplugged; now the chip is reset first, so that its boot ROM is ready.
- Thumb assembler: `str r0, [r1, #0]` (an offset of 0, also from an `equ` constant), `mov r2, #0xab00ab00` (constants
  from `0x80000000` up) and `ldreq r2, label` (`ldr` and `adr` with a label in an IT block) found no encoding.

## 0.9.2 – 2026-11-05

### Fixed
- ESP32-C3, writing the flash: the boot ROM refused a block with "the boot ROM refuses command 03 (error 05)" when the
  program contained the byte `$C0` or `$DB` (as `rgb_ws2812_flash.asm`). The serial protocol must escape these two
  bytes, and Asmonite did not: the replace function of Delphi stops at the first zero byte, and every packet starts with
  one. Now each byte is escaped by itself. A failed try left the flash erased; the board then started again and again
  ("invalid header: 0xffffffff").
- ESP32-C3: after writing, some boards started the boot ROM in the download mode again instead of the program
  (`boot:0x4 (DOWNLOAD(USB/UART0/1))`). The chip is now reset by its RTC watchdog, as esptool does; the reset over RTS
  stays when the boot ROM does not answer.

## 0.9.1 – 2026-11-05

### New
- ESP32-C3 examples for boards with an RGB LED WS2812 at GPIO 8: `rgb_ws2812_ram.asm` (in the RAM) and
  `rgb_ws2812_flash.asm` (in the flash): the LED is red, green and blue in turn, with a line for each on the USB serial
  port. The 24 bits of colour are timed with the cycle counter of the core; the programs set the clock of the core from
  20 to 40 MHz. Tested on a second board (two USB-C ports, one at the chip, one with a CH340 at UART0).

### Fixed
- ESP32-C3, Set up the USB JTAG: the button said "The setup did not work" although it had worked. It checked the value
  while the interface was still restarting; now it waits up to 10 seconds for the interface.
- The setup is needed once for each board, not for each USB port: Windows knows the board by its serial number (the MAC
  address of the chip), at every port. The guide, the info text in Debug targets and the messages said otherwise.

## 0.9.0 – 2026-11-05

### New
- **ESP32-C3: debug and flash with one USB cable, without a debug probe and without OpenOCD.** The chip has a USB port
  that is a serial port and a JTAG debugger at the same time; Asmonite drives both itself (`EspUsbJtag`: the USB JTAG
  protocol of the chip, `EspRvDmi`: the RISC-V debug transport over JTAG; the debug module of the Pico 2 is used again).
  `.target esp32c3` with `.arch riscv32`: F7/F9 reset the chip and halt it before the firmware of the flash starts (that
  firmware locks the memory protection, after which writes into the RAM are lost without an error), switch the
  interrupts and the watchdogs off, load the program to `0x40380000` and stop at `_start`; steps, breakpoints,
  registers, memory.
  - **`.target esp32c3 flash`** writes the program into the flash as an image of the boot ROM, over the serial port of
    the chip with the protocol of its boot ROM (`EspRomFlash`; the port is found by the USB id 303A:1001); then the
    debugger lets the boot ROM load it and stops at `_start`. A block that the boot ROM refuses is sent again.
  - **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG:** Windows gives the USB JTAG the driver WinUSB but no
    device interface, so programs cannot open it; the button adds it (administrator rights, once for each board).
  - Examples `examples/esp32c3/` (`blink_ram.asm`, `blink_flash.asm`: the LEDs at GPIO 12 and 13 and lines on the USB
    serial port; `hello_uart_ram.asm`: UART0), guide `docs/en/esp32c3.md`, cases `target_esp32c3_*`. Tested with the
    LuatOS ESP32C3-CORE.

### Fixed
- Assembler: a name that is both a label and an `equ` constant (the case of the letters does not count: `count:` and
  `COUNT equ 5`) is an error now. Before, the value of the constant took the place of the label: on x86 `jmp count`
  jumped to the address 5 without a message, on RISC-V it said "the target is out of reach".

## 0.8.0 – 2026-11-04

### New
- **Raspberry Pi Pico and Pico 2: assemble, flash and debug, without OpenOCD.** Asmonite drives a CMSIS-DAP debug probe (the Raspberry Pi Debug Probe) itself over USB (`CmsisDap`): F7 loads a program into the RAM (`.imagebase 0x20000000`) or **writes it into the flash** (`.imagebase 0x10000000`: through the functions of the boot ROM, only the sectors that differ, read back) and stops at `_start`; steps, step over, run to cursor, pause, breakpoints, registers (editable), stack with notes, memory as **bytes or as code** (the new switch *Bytes / Code*). *Project > Save as UF2 file (Raspberry Pi Pico)* writes the file for the BOOTSEL drive with the family of the chip. *Debug > Debug targets* has the entries *Raspberry Pi Pico (RP2040)* and *Raspberry Pi Pico 2 (RP2350)*, each with *Test the connection*. The guide `docs/en/riscv-pico2.md` explains it step by step.
- **The Raspberry Pi Pico (RP2040, Cortex-M0+).** `.target pico` (also `rp2040`) allows the instructions of the ARMv6-M only (of the 32-bit ones `bl`, `msr`, `mrs`, the barriers; no `cbz`, `cbnz`, `it`); adr/ldr with a label further down take the 16-bit form first. The debugger reaches core 0 on the multidrop SWD bus (TARGETSEL) through the MEM-AP of ADIv5: 4 hardware breakpoints in the flash, software breakpoints (`bkpt`) in the RAM, which the memory view does not show. Cores that no longer answer are brought back through the rescue port of the chip.
  - **`.boot2`** puts the boot2 block of the Pico SDK at the start of a flash program (the file `boot2/boot2_w25q080.bin`, BSD-3-Clause, or the same bytes built in); `.boot2 file.bin` a block of your own (252 bytes and the CRC-32 is added, or 256 and it is checked).
- **The RISC-V cores of the Pico 2 (Hazard3).** `.arch riscv32`: RV32I, M, A, Zicsr, Zifencei, the pseudo instructions `li`, `la`, `mv`, `j`, `ret`, `call` ... and the bit manipulation sets Zba, Zbb, Zbs, Zbc, Zbkb. The debugger works through the debug module of the chip (`RvDebugModule`, `RvLink`): registers `x0`..`x31` and `pc`, 4 hardware breakpoints. OpenOCD (host and port of its GDB server) stays as a backup for these cores; the connection wakes up the debug port that OpenOCD leaves dormant.
  - The disassembler `dis_riscv` also reads the compressed instructions (C, Zcb); checked against capstone (all 16-bit codes and 200,000 random words: no difference, `tools/riscv_check.py`).
  - Editor: syntax colours for `.arch riscv32`; F1 help `help\<lang>\riscv.md` (every instruction, the registers, the pseudo instructions, the instruction forms).
- **The Arm cores of the Pico 2 (Cortex-M33).** `.arch thumb` with `.target pico2`; F7/F9 debug over the USB probe (`CmCore`, `CmLink`, `CmFlash`): registers `R0`..`R12`, `SP`, `LR`, `PC`, `XPSR` and the flags `N Z C V` (editable), 8 hardware breakpoints, step over `bl` and `blx`, the memory view shows Thumb code; the stack pointer comes from the vector table.
  - The chip runs one kind of cores at a time. If the other kind runs, it writes a flash program into the flash and the chip is reset (the boot ROM starts the cores the program is for); a RAM program gets a message what to do. *Test the connection* says which cores run.
- **`.target pico`** (also `rp2040`) and **`.target pico2`** (also `rp2350`) say which board a program is for: the output is a flat binary, and after assembling the program is checked (errors with the line, F1 `err-target`): the `.arch`, `.imagebase` in the RAM or the flash and the program fits; on the Pico 2 an IMAGE_DEF block in the first 4 KB whose IMAGE_TYPE fits the `.arch`, on the Pico the boot2 block with its CRC-32; an Arm flash program starts with its vector table (Thumb bit). Without `.target`, `.arch thumb` with `.format binary` gives a warning. Before it writes anything, the debugger reads the chip id and refuses a program for the other board with its name.
- Examples: `examples/pico/` (`blink_ram.asm`, `blink_flash.asm`) and `examples/pico2/` (`blink_arm_ram.asm`, `blink_arm_flash.asm` for Arm; `blink_ram.asm`, `blink_flash.asm` for RISC-V; `stack_demo.asm`). The flash programs start by themselves after a power cycle.
- Tests: `rvtest` (assembler, disassembler, UF2, highlighter), `regedittest` (Cortex-M registers), cases `riscv_*` and `target_*`, `anatest` (help); with a board: `rvdbgtest` (31 checks, `usb` for the direct way), `rvdmtest`, `rvflashtest`, `cmdbgtest` (37 checks on the Pico 2, both switches of the cores; `cmdbgtest pico` 38 checks on the Pico).
- The debug views (registers, stack, memory) change their rows in place and flicker less.
- Dismonite: **PE files for the old ARM** (Machine 0x01C0: the ARM instruction set of before Thumb-2, as Windows CE used it) open and are decoded: the code from the entry point is ARM (A32, the decoder of the ARM ELF files), the export writes the code as bytes with the instruction as comment (it cannot be assembled as instructions: Asmonite has no A32 assembler). Before, such a file showed no code at all. The status line says "old ARM (Windows CE): ... no Windows PC runs it", and the check before running names the old ARM ($1C0 / $1C2) as a type no Windows PC runs. The page `winarm.html` has a table of the ARM file types (ARM64, ARM32 Thumb-2, the old ARM, ARM64EC/X) and what Asmonite and Dismonite do with each. Case in `anatest` (`pe_oldarm_example.exe`, made with fasmarm). Tools: `tools/pe_scan.c` (native scanner for the PE files of a drive) and `tools/pe_stats.py` (statistics of the machine types).

## 0.7.6 – 2026-10-30

### New
- Examples: `examples/windows_intel/if_x64.asm`, `examples/windows_arm/if_arm64.asm` and `if_arm32.asm` use `if` / `else` for several kinds of conditions; each ends with the exit code 31 (run on a real Windows on ARM machine for the ARM ones).
- Assembler, Thumb (`.arch thumb`): **`if` / `else` / `endif` and `do` ... `while`** work like in arm64 (`bne`, `blt` ..., `tst`, a number gets its `#`, no memory operands). Cases `thumb_*`, also with blocks of 130 instructions.
- Assembler, arm64: **`if` / `else` / `endif` and `do` ... `while`** work in `.arch arm64` source with the same words and rules (`if w0 == 5`, `if signed x1 < x2`, `if zero`, `if x3 & x4`, `do ... while not zero`, nested): the jumps are `b.cond`, `if a & b` is `tst`, a number gets its `#`; there are no memory operands and no `parity`; Thumb / ARM 32 is still an error. Cases `a64_*`; the editor colours the words in arm64 source. Not run on a device yet.
- Assembler, x64: **`if` / `else` / `endif` and `do` ... `while`** now work in `.arch x64` source with the same words and rules as in i386 (`if rax == rbx`, `if signed eax < r8d`, `if zero`, `if eax & ebx`, `do ... while not zero`, nested); `func` and `call Name(args)` stay i386 only, in ARM source `if` still reports an error. The jumps forward use the long form (rel32). Cases `x64_if_*`, `x64_do_while_*`, `x64_compare_default`, `x64_error_*`.

### Fixed
- Assembler, Thumb: a **forward branch that does not reach in the short form becomes the wide form by itself** (another pass runs); before, the instruction had to be written with `.w` ("the branch does not reach its target in this form").
- Assembler, x64 and Thumb: the sizes of the lines (kept from pass 1 for pass 2) were indexed by the source line; with generated lines (`if`, `else`, `do`, `func`) several lines share a source line and the sizes got mixed up (error "the instruction does not have the size it had in pass 1"). They are indexed by the generated line now.

## 0.7.5 – 2026-10-28

### New
- Dismonite: **export with `call Name(args)`** (File menu, *Export with call Name(args)*, saved in `Dismonite.ini`; `DismoniteC --calls`). In a 32-bit Windows program the `push` instructions right in front of a call are written as the arguments of the call: `push 3` / `push eax` / `call near Fatal` / `add esp,8` becomes `call cdecl Fatal(eax, 3)`. Which pushes belong to the call: an `add esp, 4*m` behind it says cdecl and m arguments; a direct call of a label whose code ends in `ret 4*n` is stdcall with n arguments; a `call [Import]` of a Windows function that `help\<lang>\winapi.md` knows with its number of parameters is stdcall with that many. Anything else stays (the pushes could belong to something else); a run of pushes ends at a label, a comment line or a push that is no number, register, label or dword. Only where the assembler makes the same bytes: the file is assembled and compared, else it is written without (the dialog says so). It can be used together with the `if` export. In the 32-bit dcc32 1,832 calls (the file comes back byte for byte together with the 10,224 ifs and loops), in Dism.exe 542 of 4,091, in OpenWith.exe 205, in PkgMgr.exe 304. Unit `DisCallExport`; cases in `anatest` (`CallExportText`) and the round trip of `wste1.exe` with `--if --calls`.

- Assembler, i386 (also `.arch x86_real`): **a character in quotes is a number in an instruction**: `mov al, '0'`, `cmp al, '9'`, `add al, "A"`, `push 'x'`, `mov eax, 'abcd'` (up to four characters, the first one in the lowest byte, as NASM does); both quotes work, `db` keeps its strings. Case `char_immediate`.
- Assembler, i386: **`loop`, `loope`, `loopne`, `jecxz` and `jcxz` take a label without `short`** (they have no other form; a label out of reach is an error as with `short`). Cases `loop_label`, `loop_label_far`.
- Examples: `examples/dos/tick.asm` counts in `ebx` and prints it every second from a hook of the timer interrupt 08h (the handler sees the registers of the counting loop); `examples/windows_intel/tick_i386.asm` does the same for Windows with a second thread that reads `ebx` with `GetThreadContext`; `examples/func/func_fact.asm` is the factorial.

### Fixed
- Assembler: **`call Name(0x1B)`**: a hexadecimal number that ends in `B` as the only argument (`(0x1B)`, `(0xB)`) was read as a number with the binary suffix and refused (*unexpected token*).

## 0.7.4 – 2026-10-26

### New
- Dismonite: **`if` on the flags and `do ... while` in the listing and in the export** (the same rules as in Asmonite since 0.7.3). A conditional jump forward to a label that only it uses, with no `cmp` / `test` in front that gives a condition, is written as `if zero`, `if not below` ... (`dec ecx` + `jnz` over the block is `if zero`); a conditional jump **back** to a label that only it uses is a loop: the label becomes `do`, the jump `while <condition>` (cmp + `jnz` is `while a != b`, `dec ecx` + `jnz` is `while not zero`). Loops and ifs nest; the listing shows `; do` at the label, `while ...` / `back to do` at the end and indents the body. In the 32-bit dcc32: 9,090 `if` (1,035 of them on the flags) and 1,134 `do ... while`; the export comes back byte for byte. The export tries all of it first, then only the ifs with flags, then only the ifs with `cmp` / `test`, and keeps the first that gives the same bytes. `DismoniteC --if-dump <prefix>` saves each try as a file (a test aid).

### Fixed
- Assembler, i386: **jumps without `short` / `near` start short and become long only where they do not reach** (before: they started long and became short where they fit, which leaves jumps long that can only be short together: two jumps that go over each other, a loop and the jump over it). The result is the shortest layout, as a compiler has it. Cases `jump_short_together`, `jump_short_back_edge`.

## 0.7.3 – 2026-10-26

### New
- Asmonite, i386: **`if` on the flags** and **`do ... while`**. `if zero`, `if not carry`, `if below or equal` and so on need no comparison: the flags of the instruction in front count and only the jump around the block is written (`dec ecx` / `if zero` is `jnz` over the block). The words: `zero` (`equal`), `carry`, `sign`, `overflow`, `parity`, `above` / `below` (unsigned), `less` / `greater` (signed), `not` in front, `or equal` behind the last four. **`do` ... `while <condition>`** runs the block once and then as long as the condition holds: the condition has the forms of the `if` (a comparison with `signed` / `unsigned` or `.compare`, `a & b`, a flag word) and the jump back to the `do` is the condition itself (`while not zero` is `jnz`, `while signed eax < 10` is `cmp` and `jl`). The label at the `do` is made by the assembler (`asmogen_do<line>s`). Loops and ifs nest; one that is closed in the wrong place is an error (`endif without if (the open block is the do in line 3, while is missing)`). `do` and `while` cannot name a func, a parameter or a local; they have the colour of the syntax. Example `examples/func/func_loop.asm`, cases `func_if_flag_*` and `func_do_*`; the page `if.html` has sections for both.
- Asmonite, i386: **`if a & b`** tests bits: `if eax & ebx` is `test eax, ebx` and the jump around the block when no bit is set in both, `if eax & ebx == 0` runs the block when none is, `if eax & ebx != 0` is the same as `if eax & ebx`. A register, a number or memory (`if byte [ebx] & 1`, `if al & 0x80`); `test` has no register-against-memory form, the operands are swapped. No `signed` / `unsigned` with it, nothing but `== 0` / `!= 0` behind it. Cases `func_if_test*.asm`; the page `if.html` has a section for it.- Dismonite: **export with `if` / `else` / `endif`** (File menu, *Export with if / else / endif*, saved in `Dismonite.ini`; `DismoniteC --if`). In a 32-bit Windows program a `cmp` or `test` with the conditional jump behind it that goes forward to a label that only this jump uses is written as `if a == b` ... `endif` (the jump of the opposite condition: `jne` is `==`, `jl` is `if signed a >= b`, `jbe` is `if unsigned a > b`, `test` + `jz` is `if a & b`); a `jmp` to a label that only it uses at the end of the block gives `else`; blocks are indented by two blanks. Only where the assembler makes the same bytes of it: the file is assembled and compared, else it is written without (the dialog says so); jumps that the program has as `near` stay as they are. In the 32-bit dcc32 (19,663 conditional jumps) 8,055 become an `if` and the file comes back byte for byte. Unit `DisIfExport`.
- Dismonite: **export with `if` / `else` / `endif`** (File menu, *Export with if / else / endif*, saved in `Dismonite.ini`; `DismoniteC --if`). In a 32-bit Windows program a `cmp` or `test` with the conditional jump behind it that goes forward to a label that only this jump uses is written as `if a == b` ... `endif` (the jump of the opposite condition: `jne` is `==`, `jl` is `if signed a >= b`, `jbe` is `if unsigned a > b`, `test` + `jz` is `if a & b`); a `jmp` to a label that only it uses at the end of the block gives `else`; blocks are indented by two blanks. Only where the assembler makes the same bytes of it: the file is assembled and compared, else it is written without (the dialog says so); jumps that the program has as `near` stay as they are. In the 32-bit dcc32 (19,663 conditional jumps) 8,055 become an `if` and the file comes back byte for byte. Unit `DisIfExport`.
- Dismonite: **if / else / endif in the listing** (menu Analyze, *Show if / else / endif in the listing*, on at the start, saved in `Dismonite.ini`). The places the export would write as `if` get a comment: the `cmp` / `test` row says `if eax == 0x10`, the jump `if not: to endif` (or `to else`), the jump that ends the then part `then part done: to endif`, the label `; else` / `; endif`; the code of a block stands two characters further to the right per level. Only a view: every instruction keeps its row, its address, its bytes and its breakpoint, the debugger steps as before; the listing, the search and the export are the same. The rule is the one of the export (a label that only this jump uses, nested blocks), found per function; the entry code in front of the first function too. About 1.4 s more for all 338,000 rows of the 32-bit dcc32; where a jump is written `near` in the export the listing shows the block too.

### Changed
- Dismonite, debugger: the two windows at the bottom changed places: the output of the program is on the left, the memory on the right (fixed width, enough for a row of 16 bytes and the text; the splitter moves it).

### Changed
- Assembler, i386: jumps without `short` / `near` are made short in **rounds** until nothing changes. Before, one decision was made from the distances of the first pass, so a jump over other jumps that only become short stayed long (`jmp x` over twenty `jne`: 5 bytes instead of 2). Now the result is the shortest one, as with other assemblers; a file with many such jumps is assembled a few times (about 16 s instead of 7 s for the 231,000 lines of a disassembled dcc32). Case `jump_relax_rounds`.

### Fixed
- Assembler, i386, two errors with jumps that are made short automatically (`jmp x` / `jne x` without `short`): (1) an instruction that asm_x86 hands to the other encoder (x87 such as `fld tword [label]`, and others) took the address of a label further down from the first pass, before the jumps were shortened: wrong address in the code; (2) a `jmp short` over jumps that are made short later got the error "error with bdo" although it reaches in the end. Found when rebuilding the 32-bit dcc32 from its `if` form. Cases `jump_short_fpu_label`, `jump_short_over_shortened`.

## 0.7.2 – 2026-10-23

### Changed
- `conwatch.exe` (the helper that mirrors the console of the debugged program) has version information now and imports `AttachConsole` normally: fewer false alarms of virus scanners (machine-learning verdicts).

## 0.7.1 – 2026-10-23

### Changed
- The ZIP no longer holds the example programs (`.exe`) of `examples\windows_intel`, `windows_arm`, `func`, `x64`, `arm64` and `winarm`: virus scanners reported tiny hand-made programs falsely. The sources are there; F9 in Asmonite builds the programs. `examples\dos\HELLO.EXE` (for Dismonite) stays.

## 0.7.0 – 2026-10-23

### New
- Assembler: **expressions, `equ`, `$` and `$$`**. Wherever a number stands the assembler calculates: `* / % + - << >> & ^ | ~` and brackets, numbers as `0x1F`, `1Fh`, `101b`, `'A'`. `name equ expression` defines a constant (also behind its use), `$` is the address of the line, `$$` the start of the section, and the **difference of two labels** is a number: `mov ecx, end-start`, `len equ $-msg`. The constant part of a memory operand is calculated too (`[ebx+2*4]`). A difference of labels needs the addresses, so the assembler runs again until they stay the same. Done by a pass over the source (`src/cpu/asm_expr.pas`) before the core, for all architectures; everything that is not an expression stays as it was. Also new in the core: a number behind a label as a value, `mov eax, table+4`, `push table-4`, `dd table+4` (jump and call: error).
- Asmonite, i386: the words of the `func` and `if` syntax (`func begin end var uses cdecl stdcall if else endif signed unsigned`) cannot be the name of a func, a parameter or a local (an error, as the help always said for registers, instructions and keywords); labels and data names are not affected. Cases `func_error_keyword_*`.
- Asmonite, i386: **`if` / `else` / `endif`** with a direct comparison: `if ebx == [0x04+eax]` ... `endif` is `cmp` and the jump of the opposite condition around the block (no label of your own); `else` is supported, ifs nest, it works anywhere in i386 code and in a func (its names work in the comparison). One comparison, no expressions: `==`, `!=`, `<`, `<=`, `>`, `>=`; the four ordered ones say **`signed`** or **`unsigned`** (`if unsigned eax < ebx` is `jae`, `if signed eax < ebx` is `jge`), without the word it is an error, unless **`.compare signed`** / **`.compare unsigned`** stands in front of it (for all ifs behind it, until the next `.compare`; `.compare none` takes it back; a word in the `if` line wins). The debugger runs the `if` line (`cmp` and the jump) as one step. Example `examples/func/func_if.asm`, cases `func_if_*.asm`.
- Asmonite and Dismonite, debugger: **change registers and flags** of the paused program, for x86 (Windows, DOS), x64, ARM / Thumb and ARM64. **Double click** (or **F2**, **Enter**) on a register opens a small dialog with its value; a **flag** (CF, ZF, N, Z, T ...) is toggled by double click or **Space**; the context menu has *Change value...*, *Toggle flag*, *Set to 0* and *Copy value*. The value is hex (`1F`, `0x1F`, `$1F`, `1Fh`), decimal with `#` (`#31`), a character (`'A'`) or an expression of values and register names with `+` and `-` (`esp+8`, `r0-#1`); a value that does not fit the register, or an unknown word, stays in the dialog with the reason. A new `EIP` / `RIP` / `PC` moves the program: the editor and the view show the new place like a stop ("set next instruction"). In Dismonite a double click on a register that points into the program still goes there; change it with F2 or the menu. The changes go to the program when it goes on (Windows: `SetThreadContext`; the debug servers and QEMU: the `G` packet). The same code serves both programs (`DbgRegEdit`, `DbgRegDlg`).
- Dismonite: **arguments and locals found in more functions**, and told more. The functions of Microsoft compilers that start with `mov edi,edi` (hot-patch prefix), 16-bit functions (`push bp / mov bp,sp`: the arguments are 2-byte slots from `[bp+4]`, from `[bp+6]` in a far function that ends with `retf`; `[word 0xFE7E+bp]` is a negative displacement), and functions that are only jumped to (a label at the `push ebp`) now get the hints `arg1` / `loc1`. Locals that overlap (a `byte [ebp-7]` inside the `dword [ebp-8]`) are one variable (`loc2+1`), the frame size is read from `sub esp,N` / `add esp,-N` / `push ecx`. The summary at the `push ebp` says more: `stdcall, 2 args, 3 locals, frame 0x10`; the convention (`stdcall`, `cdecl`, `pascal`, `far`, `register`) comes from `ret N` and the arguments, **registers that are arguments** (`eax`, `edx`, `ecx` read before they are written, Delphi `register`, fastcall, thiscall) are named (`register, regs eax edx ecx, 1 stack args, ...`), and the store of such a register in a local reads `loc2 = ecx`. Only comments: the export gives the same bytes. In the 32-bit Notepad 0 of 6894 `[ebp+x]` operands had a hint before, now 94 %; in a DOS compiler (TPC) 0 of 1060, now 71 %.

## 0.6.0 – 2026-10-22

### New
- Asmonite: **new window layout**: registers, stack and memory stand one below the other in a column on the right over the whole height (only while a program is debugged; each block can be switched in the View menu, the column goes when all three are off), the code and the output window on the left. Sizes and blocks are saved in `Asmonite.ini`. Memory shows 8 bytes per row in a narrow column, 16 in a wide one, and the stack (`esp`) when nothing is entered.
- Asmonite, debugger: **Step Over on `call Name(args)` and `call [printf](args)`** runs the whole line in one step (the call and the clean-up behind it), and does not step into a func when the line has arguments to push.
- Asmonite: **the convention of an import** in `call [name](...)`: the `.import` line says it for its names: `.import msvcrt.dll cdecl printf`, then `call [printf](fmt, 42)` cleans up the stack (`add esp, 8`); without the word an import is stdcall. For a C runtime dll (`msvcrt.dll`, `ucrtbase.dll`, `api-ms-win-crt-*`) the word is required: a call with arguments without it is an error. `call cdecl [name](...)` or `call stdcall [name](...)` decides for one call. Example `examples/func/func_printf.asm`.
- Dismonite, DOS programs (MZ): **constants and displacements in the code** can be said to be offsets, with the same keys as the words of a table: on an instruction **L** (offset of code), **Shift+L** (offset of data), **X** (a number). The label of the target shows in the operand (`mov bx,C0000_9C2A`, `jmp [cs: word L0000_085A+bx]`), the code behind a code offset is certain and followed, and the export writes the label too (checked by the assembler, bytes identical). Data named by a constant is in the **data segment**: the paragraph that DS holds, found from the entry code (`mov ax,0x10D0 / mov ds,ax`) or set in DOS > Data segment (saved as `dataseg`); with `cs:` the target is in the code segment. An instruction with two fields: the displacement (unless it is a plain `[0x1788]`), else the constant. Saved as `ref <offset> operand <role>`; Del takes the decision of the instruction back first.
- Dismonite: **the marks of the user in the gutter**: a bar in front of the address (blue: an item, green: the start of a run, purple: a decision about an address). The mouse in the gutter tells what the mark is (the kind and size, the run with its limits, the decision and its target, your name for the label) and what Del will take back.
- Dismonite: **strict marks over several bytes** (what you type; reading a .dmon file is not checked): a word, dword or qword is refused (with a beep and the reason in the status line) if a label would be inside it (a label at its first byte is fine), if another mark of yours would be covered, or if a field of the file format is inside; ascii and UTF-16 end in front of the next label or the next mark of yours. The item you re-mark itself may be replaced, a run of B/W/D/Q ends in front of a mark of yours that it does not make itself.
- Dismonite: a click in the gutter (the column with the addresses) sets a breakpoint on that item or takes it away, like F5.
- Dismonite, DOS programs (MZ): **manual marking**. Menu DOS > Manual marking (saved as `manual` in the .dmon file): the program marks the code that is *certain* by itself - everything that the flow, calls and jumps lead to from the entry point, from the code you marked and from the words you said are offsets of code - and does it again after every decision of yours (what you took back goes again). Nothing else is analyzed; what is left (what only a table or an indirect jump leads to, data, the rest) is yours: **Ctrl+F5** / **Ctrl+Shift+F5** jump to the next / previous place to decide, the status bar counts them. **C** marks code (its calls and jumps are followed at once), **L** / **Shift+L** / **X** say that the word at the cursor is an offset of code / of data / a number (saved as `ref <offset> word code|data|number`; a byte becomes a word), and the status line tells at once what the target is: start of an instruction, start of data, not marked yet, in the middle of an instruction or data item (no label possible), outside of the segment or the file. **Del** takes the decision back first, then the mark of the word. What the commands of the Analyze menu mark (tables, strings) are only suggestions with orange bytes until you accept them (**Ctrl+Y** the one at the cursor, DOS > Accept all suggestions). DismoniteC follows the certain code of a document with `manual` the same way.
- Dismonite: **Ctrl+F4** / **Ctrl+Shift+F4** (menu Go) jump to the next / previous place where code and data change: forward to the start of the next run of items of the other kind (code: instructions, data: everything else), backward to the start of the run you are in, or - at its start - of the run before.
- Dismonite: **Del** takes the mark of the item under the cursor back (menu Data > Unmark this item): your own or the analysis'; the bytes are single, unmarked bytes again, names and comments stay. A run the item belongs to is dissolved, its other items stay. The cursor goes on to the next item, so that several marks can be taken back one after the other (after taking back the decision about an address it stays: the next Del takes the mark of the word).
- Dismonite, DOS programs (MZ): the analysis knows how a DOS program ends. After `mov ah,4Ch` / `int 21h` (also AH = 00 and 31,
  `int 20h`, `int 27h`) no code follows - what stands there (the option table of a compiler) is no longer decoded as code,
  also not by the code run of the user (C). `mov dx,offset` / `mov ax,25xxh` / `int 21h` (set interrupt vector) makes the
  handler code.
- Dismonite, DOS programs: tables of pointers. Runs of at least 6 words (records of 2 to 6 bytes: a pointer and a key or flags) in the
  bytes that are no code, whose values lead to the start of code in the same segment - 90% of them behind a `ret`/`jmp` or at known
  code, and decoding cleanly - become word items that are addresses: `dw J0000_01F5`, with labels at the targets whose code is
  followed; 4 and 5 entries if all of them lead to known code behind a `ret`/`jmp`. Words you have marked (W) that lead to such a
  place are addresses, too (a table of 3 entries). Tables that the code uses (`jmp [cs: 0x2355+bx]`, also `call`) are found by that
  instruction: their words are addresses as long as they lead to code that decodes cleanly and stay near the others (case labels),
  unused slots (0) in front or between are skipped. Part of "Analyze" (menu item *Find tables of pointers to code (DOS)*) and
  "Re-analyze" (not saved). TPC.EXE: of the code labels of its source 85% (before 37%) are code after the automatic analysis, with
  a `.dmon` of the user 90% (before 63%). The export writes `dw label`.
- Asmonite: `dw label` in a source with `segment` lines (MZ) is the offset of the label in its segment (before: the file offset).
- Asmonite: `call Name(arg, ...)` (also `call cdecl name(...)`, `call [Import](...)`) pushes the arguments from right to left,
  calls and cleans up for `cdecl`; a `func` gives its convention and checks the number of arguments. Arguments: register, number,
  label, parameter or local (byte/word zero extended, array = address), `&local`, `[ebx+4]`; for an address or a byte/word the
  first of eax/ecx/edx that the argument list does not name serves as the register. Examples `examples/func/func_call*.asm`.
- Dismonite: while the program is paused (Win32), the mouse over an `[ebp+x]` operand (or its `arg1` / `loc1` comment) shows
  the value: `loc1: dword 0x0000000A  10`; the size comes from the size word or the register, an operand with an index
  register shows the first bytes of the array; a pointer to a string adds `-> "text"`.
- Asmonite: while the program is paused, the mouse over a word in the source shows its value: parameters and locals of a
  `func` (with their size and the array size), and labels of data (`db`, `dw`, `dd`, `resb` ...): `byte`, `word`, `dword`
  (hex and decimal), `qword`, text as `pchar "..."`, else the first bytes; a dword that points to a text adds `-> "text"`.
- Asmonite: in the debugger, `begin` and `end` of a `func` are one step each (step into / step over run the whole prolog or
  epilog); more generally, the instructions of one source line that follow each other are one step.
- Dismonite: in a function that starts with `push ebp / mov ebp,esp` (a call label, the function ends at the next one) the
  comment of an instruction with `[ebp+x]` names the slot: `arg1` ([ebp+8], [ebp+0xC] = `arg2` ...) and `loc1`, `loc2` ...
  (the used places below ebp, closest first; `[]` when an index register is added); the first instruction shows the summary
  (`2 args, 3 locals`, arguments also from `ret N`). Only comments: the export still assembles to the same bytes.
- Asmonite: `func Name(params) [cdecl|stdcall] [uses regs]` / `var` / `begin` / `end` writes the stack frame: names for
  parameters (`[ebp+8]` ...) and locals (`[ebp-4]`, arrays `buf:16`), prolog and epilog (also at every `ret`), `uses`
  saves registers. `.arch i386` only; examples in `examples/func/`, help topic `func`.
- Dismonite: a code run (C) takes single bytes that the user marked as bytes (before, such a byte stopped the run at once);
  other items of the user (word, dword, text, ...) and the file structures still stop it.
- Dismonite: Alt+E exports the `.asm`, Alt+X exits.
- Dismonite: the key **F** follows the label of the row to its target (like Ctrl+click; Alt+Left comes back).
- Dismonite: Find (Ctrl+F) proposes the name of the label when the cursor is on a label row or on an instruction with a label (`call C00401234`).
- Dismonite: opening a file now runs the standard analysis automatically (after the `.dmon` is applied; progress window
  with Cancel): entry point and exports, relocations, constants, the call and jump targets until nothing new comes,
  strings. Menu Analyze: **Re-analyze** (the marks of the analysis anew, the user's stay), **Analyze automatically when a
  file is opened** (on) and **Follow new targets automatically after marking code** (off; the question after a code run has
  a "Yes to All" button). The `.dmon` also keeps the place of the cursor (`cursor <offset>`).
- Dismonite: the analysis is much faster where starting points fail: asmoc.exe 40 s -> 5 s (a failed relocation target no
  longer follows the strands still waiting), and the row counts of the document are made once per analysis step.
- Dismonite: an instruction whose last operand is a number from 0x20 to 0x7E shows the character in the comment
  (`cmp al,0x41   ; 'A'`); not for `add`/`sub` of the stack pointer, shifts, `ret`, `int`, `in`/`out`.
- Dismonite: while the program is paused in the debugger, the mouse over a name (a label in the code or its own row)
  shows the value of the variable in one line: `byte`, `word`, `dword` (hex and decimal), `qword`, `pchar "..."`,
  `pwchar "..."`, unmarked data as 8 bytes; a pointer to a string of the program adds `-> "text"`.
- Dismonite: the code that uses a label on an ASCII or UTF-16 string shows its first 20 characters in the comment
  (`push msg   ; "Hello, this is a lon..."`); also for ARM literals and a constant that is the address of a string.
- Dismonite: the automatic jump labels (`J00401234:`, mostly local jumps) stand two characters left of the code in the
  window and in the `.asm` export (two spaces before the label), so that the calls and data labels stand out.
- Dismonite: memory without file bytes (`.bss`, the end of a section with a larger virtual size) follows the file as
  zero bytes: it has addresses, labels `V00xxxxxx`, rows `resb 8` / `resd 1` (one per stretch between two labels) and
  the types B, W, D, Q work there. Names and types of the user are saved in the `.dmon` by offset like everywhere.
  The `.asm` export writes it as `section 0x... nobits` with `resb` rows and labels, so the export still assembles to
  the file; the status bar and the `.dmon` check count the bytes of the file.
- Asmonite: `section <rva> nobits` (flat sources): `resb` in it writes no file bytes at the end of the output; its
  labels have addresses.
- Asmonite: `resb`, `resw`, `resd`, `resq` reserve uninitialised data. With `.format pe` they may stand at the
  end of a section (`.code`, `.data`); the space is not in the file (virtual size larger than the raw size), the
  labels in front of it are normal addresses. Without `.format pe` they write zero bytes.
- Dismonite: after a code run (C) the calls and jumps in it may lead to places that are no code yet. Dismonite asks
  whether to follow the code from there (the same analysis as "Follow code from the entry point", with the C and J
  labels as starting points); also in the menu Analyze > Follow code from the call and jump targets.
- Dismonite: the keys C, B, W, D, Q mark a **run**: code from the cursor on, instruction after instruction (no
  branch is followed), up to `ret`, an unconditional `jmp`, an instruction that does not decode (or that no
  compiler writes) or an item of the file format; for B, W, D, Q byte, word, dword or qword up to the next
  label. The `.dmon` file gets one line `run <address> <kind> [<end>]` for it; reading the file makes the items
  again. Shift+C, B, W, D, Q set one item only (a line `item`, as C, B, W, D, Q did before). A hand-set item
  inside a run dissolves the run: its items are saved one by one.
- Dismonite decodes 32-bit code with the x64 decoder in its 32-bit mode: `cmovcc`, `bswap`, `cpuid`, `rdtsc`, x87,
  MMX and SSE are instructions now (before: bytes). notepad_32bit.exe: 3,705 -> 40,264 instructions found.
- Asmonite (`.arch i386`) assembles `cmovcc`, `bswap`, `cpuid`, `rdtsc`, `ud2`, `pause`, `int3`, `fwait`,
  `nop dword [eax]`, `lock cmpxchg`, `xadd`, x87, MMX and SSE; `add eax,12` uses the short form `83 C0 0C`.

### Changed
- Dismonite: the automatic label names show what points to a label: `C00401234` (a call), `J00401234` (a jump:
  `jmp`, `jcc`, entries of a jump table), `L00401234` (data only: pointers, memory operands, constants). A call
  wins over a jump. The address stays the same, the letter can change when the analysis finds more. The
  export (`.asm`) uses the same names.

### Fixed
- Dismonite: marking ascii (or a word, dword, qword) could cover a label that a pointer behind the item made: the labels of the items in a window of 4 KB were released before the check. The rules now look at the labels as they are.
- Dismonite, DOS programs: the analysis followed a `call` or `jmp` that wraps around in the segment to the wrong place (`call -0x85E7` is written `+0x7A19`; the label showed the right target, the code was marked 64 KB further on). It follows the right target now, also a jump forward by more than 32 KB (written as a negative number). Manual marking: one to three nops (0x90) between other things are no place to decide.
- Disassembler (16-bit code): `ror` with a count of 1 or CL (`D0`..`D3 /1`) was read as `ror ax,imm8` and took a byte too many: `D1 C8` became `ror ax,0xAB`, and the instruction after it was lost. Found by comparing TPC.EXE with its TASM listing.
- Asmonite (i386): a number written 0x80..0xFF was encoded as the sign extended byte, which means a different value:
  `push 0x80` became `6A 80` (= 0xFFFFFF80), `cmp ebx,0xC8` became `83 FB C8`, `or edx,0x80`, `sub ecx,0x90`,
  `imul eax,ebx,0x80` likewise. These now use the 32-bit (or 16-bit) immediate (`push 0x80` = `68 80 00 00 00`); the short
  forms stay for 0..127 and the negative bytes. (It showed with `CreateFileA(..., 0x80, ...)`: flags 0xFFFFFF80.)
- Dismonite / the disassembler: the byte of `83 /x`, `6A` and `6B` is a sign extended number and is now written like
  that: `and cx,0xFFFE`, `push 0xFFFFFF80`, `cmp eax,0xFFFFFFFF` (before: `and cx,0xFE`, which the assembler reads as 0x00FE,
  another value). The assembler takes such a number (also `-2`) back to the short form, so exports still assemble to the same bytes.

## 0.5.0 – 2026-10-14

### New
- **F1 help for x64 code** (German and English): `movsxd`, `cdqe`/`cqo`, `syscall`/`sysret`, and two overviews
  that appear by themselves: `rip` (addressing relative to rip, `[rip+...]` or `[rel label]`) and `x64` (the
  64-bit mode in short: registers and their parts, REX, what is gone, the calling conventions of Windows and
  Linux) for every instruction with a 64-bit register.
- **F1 help for more x86 instructions** (German and English): `cmovcc`, `bswap`, `xadd`, `cmpxchg`/`cmpxchg8b`,
  `cpuid`, `rdtsc`, `pause`, `ud2`, `int3`, `sysenter`/`sysexit`, `popcnt`/`lzcnt`/`tzcnt` (86 -> 97 sections).
- Example `window_i386.asm` (i386, `.format pe gui`): a window with a menu bar (File > Exit), an input line, a
  button and a label; the button copies the text of the input line to the label. Window class, window
  procedure (WM_CREATE, WM_COMMAND, WM_DESTROY) and message loop are written out and commented. Test:
  `guitest.ps1` (in `run_tests.bat`) uses it on a desktop of its own: controls, button, File > Exit.
- **Window "Debug targets"** (Debug > Debug targets..., in Asmonite and Dismonite): all targets in one place -
  Windows i386, Windows x64, Windows on ARM (ARM32 and ARM64), DOS (QEMU), ARM Linux (QEMU). The entry that fits
  the program (from its `.arch`, in Dismonite from the file) is chosen when the window opens; the list shows how
  each target is reached (this computer, host and port, ssh). It replaces the menu items "Debug target Windows on
  ARM", "Debug target x64 computer" and "DOS Boot Floppy" (the boot floppy is chosen there). The settings in
  the ini files stay as they were. Test: `targettest.ps1` (in `run_tests.bat`, both programs, desktop of its own).
- Asmonite writes the line `Target: ...` (for example `Target: Windows x64 on this computer`) to the output
  window when a debug session starts; Help > Asmonite on Discord opens the Discord channel in both programs.
- Example `window_x64.asm`: the same window for x64 (shadow space, rcx/rdx/r8/r9, 72-byte WNDCLASS), tested the same way.
- The examples are sorted by system: `examples/dos`, `examples/windows_intel`, `examples/windows_arm` (was `examples/asmonite`).
- F1 help for ARM64 (`help/de|en/a64.md`): the common instructions, registers (xzr, sp, lr, x18) and conditions.
- Examples `messagebox_i386.asm`, `messagebox_x64.asm`, `messagebox_arm32.asm`, `messagebox_arm64.asm` in
  `examples/windows_intel` and `examples/windows_arm`: a message box (`.format pe gui`, imports from two DLLs), to see where the windows of a
  debugged program appear (the desktop of the computer where the program runs).
- **x64 programs on another computer**: Asmonite and Dismonite debug x64 programs at `asmodbgx64.exe --listen`
  on an Intel/AMD Windows computer (e.g. from a Windows on ARM computer): Debug > Debug target x64 computer...
  (this computer or direct: host, port, code; "Search LAN" and "Test connection" like for ARM). The program is
  copied over the connection and started there, its output comes back. The firewall of that computer must let
  TCP port 23457 through. Test: `x64dbgtest` (remote part on this computer).
- **The Windows on ARM target chooses itself**: on a Windows on ARM computer, Asmonite and Dismonite use "this
  computer" (asmodbg.exe as a child process, no ssh, no code) when no target was chosen yet, and also when the
  host in the settings is this computer. If the chosen server does not answer, they say why and offer to debug
  here and to remember that.
- **`.format pe` with `.arch thumb`**: Windows programs for ARM 32 bit (PE32, Machine ARMNT, entry point with the
  Thumb bit), so `.format pe` now works for all four kinds: i386, x64, thumb and arm64. Code, data and imports
  are in one section; the code is pc-relative.
- Thumb: `adr rd, label` and `ldr rt, label` (the distance to the pc is worked out, narrow or wide form);
  `rva label + number`; a label before `db`/`dw`/`dd` needs no colon.
- Examples `hello_i386.asm`, `hello_x64.asm`, `hello_arm32.asm`, `hello_arm64.asm` in `examples/windows_intel` and `examples/windows_arm`.
- **Asmonite debugs ARM32 (Thumb-2) programs** on a Windows on ARM computer (asmodbg.exe, the same targets as
  for ARM64: ssh, direct or this computer): F9 and F8/F7 by source line, breakpoints, run to line, registers,
  stack and memory. Test: `run_tests.bat thumbdbgtest` (only when named; ssh to the host winarm).
- The PE check knows ARM32 (machine 0x1C4): no look-up of the imports on this computer, and a warning if the
  entry point has no Thumb bit.

### Fixed
- **Asmonite and Dismonite froze at a stop of a program with a window** (e.g. `window_i386.asm` at
  `CreateWindowExA`): bringing the IDE to the front waited for the stopped program in the main thread
  (`SetForegroundWindow`, `AttachThreadInput`). It is done by a thread of its own now (`IdeFront.pas`). The
  messages of the Win32 debugger thread are queued and no longer wait for the main thread either.
- `.format pe` for x64 and ARM64 with more than one DLL: the import address tables were not always 8 byte
  aligned (the directory has 20 byte entries); `ldr x16, [x16, :lo12:name]` then could not be encoded. They are
  aligned to 8 now.

## 0.4.0 – 2026-10-13

### Fixed
- A PE file written by hand (`org`, `db`, no `section` lines) had file offsets as addresses in the
  line map and the labels, so the debugger found no source line: they now come from the section
  table in the file. Breakpoints on `db` lines in executable sections work in the x64 and ARM64
  debuggers too.

### New
- **Resources of PE files in Dismonite**: the resource directory (data directory 2) is read: the
  tree of types, names and languages gets its fields and headings, resource names (counted UTF-16
  texts) are marked as texts. The RT_STRING blocks (16 counted strings: a length word, the
  characters, no terminator) are marked string by string: `dw` length and `du` text, each with the
  label `str_<id>` (id = (block - 1) * 16 + index; dcc32.exe: 477 strings, the compiler messages).
  Other resources get a heading and a label `res_<type>_<name>`. A constant before a call that
  loads a message (`push 0x82` / `mov eax, 0x20` before a function that reaches `LoadStringA`,
  found by counting: at least 4 calls, 3 of 5 with such a constant) gets the hint
  `=str_130 "Internal error: %s%d"` in the code row. Test: `exptest` (dcc32.exe: export gives the
  file again, 477 strings, hints).
- **Jump note in the debugger of Dismonite**: where the program stands at a jump that it is about
  to take, the row says in which direction ("jump up to L00401520", "jump down to 0x401580", at
  the right edge of the row and in the status bar). A conditional jump shows it only when the
  condition holds (flags, ecx/rcx for `loop`/`jecxz`, cpsr, registers for `cbz`/`tbz`), an
  unconditional one always; a jump that is not taken, calls and indirect jumps show nothing. For
  x86, x64, ARM, Thumb and ARM64. Tests: `dbgtest`, `x64dbgtest`, `a64dbgtest`.
- **Export of x64 and ARM64 programs in Dismonite**: the code is written as instructions (with labels
  for jumps, calls and rip-relative or `adrp` addresses), not as `db` bytes; every instruction is
  assembled again and compared with the bytes of the file, and what does not give the same bytes
  stays `db` with the instruction as comment (kernel32: 49 of 200000 lines).
  - For the encodings that the text cannot say, the x64 assembler has prefix words that the export
    writes: `enc.load` / `enc.store` (of the two encodings of a register copy the one with the register
    as `reg` / as `rm` field, `mov rcx, rbx` = 48 8B CB / 48 89 D9), `rex` and `rex.w` (a REX prefix that changes nothing, `48 FF 15`),
    `enc.alt` (of equal long ones not the first: `66 83 E8 2D` for `sub ax, 0x2d`); `short +18` and
    `near -7` (a signed number after `short`/`near`) are displacements from the end of the
    instruction; `[0+rax+rax]` keeps its displacement byte of 0 (the long `nop`).
  - Test: `exptest` (hello64, find, where, ipconfig, kernel32 of x64 and msvcrt of ARM64 assemble back
    to the same file; the last three of the sandbox folder only where the files are).
- **ARM64 assembler in Asmonite**: `.arch arm64` assembles A64 instructions (integer, loads and
  stores, branches, FP, NEON, atomics, crypto, system); `.format pe` with it writes a PE32+ file for
  Windows on ARM64 (Machine 0xAA64; it runs on Windows 10 ARM64).
  - `src/assembler/asm_a64.pas` has no table of its own: `dis_a64` is hand written, so it is the
    oracle. A list of seed words (`asm_a64_seed.inc`, one of every shape of instruction, made by
    `tests/a64seedgen.dpr` from real code, random words and their neighbours) is analysed by
    flipping each of the 32 bits: register fields, the other bits grouped by the operands they
    change, the opcode. The text is split into tokens the same way, the registers go into their
    fields, each group of other bits is solved (all values, or as a linear function for branch
    offsets and `mov` immediates, with the context bits tried), and the result is decoded again and
    must give the same text. Aliases (lsl, ubfx, cmp, cset, mov ...) need nothing of their own.
  - Syntax as the decoder writes it (capstone's), `#` optional, `lr`/`fp`, a label as target of
    branch, `adr`, `ldr` literal; `adrp x0, name` with `add x0, x0, :lo12:name`; `dq`.
  - Test: `a64asmtest` (the 1656 cases of `a64test`, all of ntdll of Windows 10 ARM64: 280000
    instructions, random words) and `exptest` (sources; `tests/pe_arm/a64asm_hello.asm` is a
    program that Windows on ARM64 runs).
- **x64 assembler in Asmonite**: `.arch x64` assembles x64 instructions (REX, 64-bit operands, r8..r15,
  rip-relative addresses, SSE up to SSE4.2, x87); `.format pe` with it writes a PE32+ file (Machine
  0x8664, image base 0x140000000, 8-byte import entries) that Windows runs.
  - `src/assembler/asm_x64.pas` is the other direction of `dis_x64`: its table of encodings
    (`asm_x64_tab.inc`, written by `tests/x64tabgen.dpr`) is read out of the decoder by probing every
    opcode with every prefix and REX.W, and each result is decoded again and must read as the same
    instruction. The shortest encoding wins. Syntax as the decoder writes it (NASM like: `mov rax,
    [rbx+rcx*4+0x10]`, `call [printf]`, `dword [rax]`, `lock xadd`, `rep movsb`, `jmp short`); a label
    as the address of a memory operand is rip relative, `[rel address]` too; `dq` writes 64-bit numbers
    and addresses, `.imagebase` takes 64 bits. Not assembled: AVX.
  - The PE check of Asmonite reads PE32+ files too (headers, sections, import table); the functions of
    the DLLs are not looked up for them. `tests/pe_x64/hello64.asm` is a program that Windows runs.
  - Debugger: F9 on an x64 program runs it under the debugger with source lines (breakpoints, step
    into/over, run to cursor, pause, registers rax..r15, rip and the flags, 64-bit stack and memory).
    It uses the same helper as Dismonite: `asmodbgx64.exe` (folder `armserver` next to the program)
    as a child process. ARM64 programs (`.arch arm64`) are debugged the same way on a Windows on ARM
    computer (`asmodbg64.exe`: ssh, direct or, on such a computer, local); the target is set in
    *Debug > Debug target Windows on ARM...* (the dialog of Dismonite, settings in `Asmonite.ini`,
    asked at the first ARM64 run). Registers x0..x30, sp, pc, cpsr and N Z C V. Not yet: keyboard
    input for the program. Tests: `x64dbgtest` and `a64dbgtest` (line mode).
  - Test: `x64asmtest` (every text of the 1124 cases of `x64test` assembles back to the same
    instruction; with a DLL as third parameter all its instructions: kernel32, ntdll, user32, ucrtbase,
    msvcrt, combase: 2.8 million, all back), and the sources in `exptest`.
- **ARM64 programs in Dismonite**: a PE file for ARM64 (Machine 0xAA64) is disassembled and debugged.
  - Decoder `src/assembler/dis_a64.pas` (A64): integer instructions with the usual aliases (mov, cmp,
    cset, ubfx, ...), branches, loads and stores (pairs, exclusive, atomics LSE, memory copy/set,
    memory tagging), scalar floating point, Advanced SIMD (NEON, also the dot product, complex and
    by-element forms) and the crypto extensions (AES, SHA-1/256/512, SHA-3, SM3, SM4); SVE and SME stay
    data. The text is the one of capstone: `tools/a64_check.py` compares whole files (ntdll, kernel32,
    ucrtbase, msvcrt of Windows on ARM64: 710000 instructions, all the same) and random words; the
    test `a64test` has 1700
    cases (`tools/gen_a64_cases.py`). The system register names come from `tools/gen_a64_sysregs.py`.
  - Addresses as for x64: 16 digits, `L0000000140001000`, the document keeps the low 32 bits. The
    analysis follows `b`, `bl`, `b.cond`, `cbz`, `tbz`; `adr` shows the label of what it points to as
    hint, an `ldr` (literal) marks its word as data. The export writes the code as instructions (see
    above), `.imagebase` of a 64-bit image with all its bits.
  - Debugger: back end `DbgGdbA64.pas` (like `DbgGdbArm` for ARM32): `asmodbg64.exe` on a Windows on
    ARM64 machine over ssh, direct (`asmodbg64.exe --listen`, same login code) or, when Dismonite runs
    on such a computer, as a child process; the settings of *Debug > Debug target Windows on ARM* are
    shared. Registers X0..X28, FP, LR, SP, PC, CPSR and the flags, stack of qwords, memory at 64-bit
    addresses; step over runs a `bl`/`blr` to the instruction behind it. Test: `a64dbgtest` (named
    only; `src/armserver/build64.bat`, ssh host `winarm`).
- **x64 programs in Dismonite**: a PE file for x64 (Machine 0x8664) is disassembled and debugged.
  - Decoder `src/assembler/dis_x64.pas`: REX, 64-bit operands, rip-relative addresses, r8..r15, integer
    instructions, x87, SSE up to SSE4.2 and AES; VEX/EVEX (AVX) are not decoded yet and stay data.
    Checked against capstone with `tools/x64_check.py` (ntdll, ucrtbase, mshtml, libclang: all
    instructions the same except a few spellings of capstone) and by the test `x64test` (1124 cases).
  - Addresses: the document keeps the low 32 bits of an address (an image is smaller than 4 GB);
    `ImageBase64`, `AddrText` and the `*64` functions give the whole one. Address column, labels
    (`L0000000140001000`), the registers, the stack and the memory view show 16 digits. A relocated
    64-bit pointer (`dq`) shows its label.
  - Debugger: `asmodbgx64.exe` (new, `src/armserver/asmodbgx64.c`, `buildx64.bat`, llvm-mingw
    `x86_64-w64-mingw32`) is started as a child process on this computer, like `asmodbg` on the ARM
    machine: a 32-bit program cannot debug a 64-bit process with the Win32 debug API. GDB protocol with the
    amd64 registers, breakpoint `int3`, single step through the trap flag. Back end `DbgGdbX64.pas`;
    registers RAX..R15, RIP, EFLAGS, stack of qwords and memory view at 64-bit addresses. Tests:
    `python tools/asmodbgx64_test.py` (server), `x64dbgtest` (Dismonite debugger, 29 checks).
  - `asmodbg` and `asmodbg64` name `asmodbgx64` when they are given an x64 program.
- `asmodbg64.exe`: the debug server for native ARM64 PE programs (Windows on ARM64), a port of
  `asmodbg` (source `src/armserver/asmodbg64.c`, `build64.bat` with llvm-mingw `aarch64-w64-mingw32`).
  Registers in the order of GDB's aarch64 target (x0..x30, sp, pc, cpsr, v0..v31, fpsr, fpcr),
  single step through PSTATE.SS, breakpoint `BRK #0xF000`. Test: `tools/asmodbg64_test.py` (session
  with a C program and with the ARM64 Hello World `tests/pe_arm/pe_arm64_hello_world.asm`, whose code
  is written as `db`). Dismonite uses it for ARM64 programs (see above); the release ZIP has it in
  `armserver\`.

- Dismonite on Windows on ARM: the target "This computer is the Windows on ARM machine" (*Debug > Debug
  target Windows on ARM*, `[WinArm] Mode=local`). Dismonite itself runs there (as an emulated x86 program)
  and starts `asmodbg.exe` (folder `armserver\`) as its own child process, `--once 127.0.0.1:<free port>`,
  with the folder of the program as working folder: no ssh, no copy, no login code, no firewall rule, no
  open port beyond the loopback address. A server that ends at once says why ("this is an ARM64 program:
  use asmodbg64", "the program was not found") instead of a failed connection. Test:
  `python tools/winarm_local_test.py` builds `winarmdbgtest.exe`, copies it with the server to the ARM
  machine and runs it there over ssh (`winarmdbgtest <dir> <work> local`: 18 checks, entry stop, steps,
  breakpoint, output, exit codes).

### Changed
- `asmodbg` and `asmodbg64` look at the Machine field of the program before they start it and say what
  is wrong: "this is an ARM64 program: use asmodbg64", "this is a 32-bit ARM program: use asmodbg",
  x86/x64 programs are refused, a missing file or a file that is no PE file gets its own text (before:
  "cannot start the program (error 50)", or the program ran on without a stop). Dismonite shows the text
  as "The program did not start: ...".

## 0.3.0 – 2026-10-12

### New
- `qemu\install_qemu.bat`: `run_freedos.bat` and `run_buster.bat` call it when QEMU is missing.
  On x64 Windows it installs the tested QEMU (9.2.0) with winget as before, now silently; on
  Windows on ARM, where winget has no ARM64 QEMU and its x64 build does not run (Windows 10 on
  ARM emulates only 32-bit x86), it loads the newest native ARM64 build of
  qemu.weilnetz.de/aarch64, checks it against its `.sha512` file and installs it silently to
  `C:\Program Files\qemu`. Other Windows (32-bit): a hint, nothing is installed. Tested on
  Windows 10 on ARM (QEMU 11.1.0).
- Windows on ARM without 32-bit ARM support (Windows 11 24H2 and later, no `SysArm32`): the
  one-line installer of asmodbg and Dismonite's ssh target say so clearly, instead of a server
  that does not start.
- "Search LAN" in the dialog "Debug target Windows on ARM": Dismonite asks the local network
  (UDP broadcast to the port) which `asmodbg --listen` are there and fills in address and port
  of the answer (several: a list to pick from). The server answers only this one request, with
  version, port and computer name, never with the code; `--no-discover` turns it off. The
  firewall of the ARM computer must let UDP 23457 through (a `netsh` rule by hand needs a second
  line with `protocol=UDP`).
- Thumb assembler `asm_thumb.pas` (the first part of the ARM assembler): the tables of the Thumb
  disassembler backwards. A text as the disassembler writes it (plus upper case, decimal numbers,
  `sb sl fp ip`, ranges in register lists, `cs`/`cc`) is matched against the operand template of
  every row with the mnemonic, the placeholders give the bits of their fields back, and the code
  is disassembled again as a check. 16 bit before 32 bit as GAS (`add.w` wide, `add` wide only when
  no narrow form fits); IT blocks as the disassembler. Test part `thumbasmtest`: all 16-bit codes,
  the 586 32-bit words and 6 sequences of `thumbtest`, random codes of every row; everything comes
  back, alias encodings (don't-care bits, `cmp r0, r0` in the high-register form) counted apart.
- `.arch thumb` in Asmonite: behind it every line that is no data or control directive is a Thumb
  instruction for `asm_thumb`; a label needs its colon; branch targets may be labels (`b loop`,
  `bl func`, `cbz r0, done`), resolved over the two passes of the assembler; the address of an
  instruction is `.imagebase` plus the RVA of the `section` lines. Dismonite's export writes PE
  programs for Windows on ARM with `.arch thumb` and their code as instructions: each line is
  assembled first at its address with its IT state and must give the bytes of the file, else it
  stays `db` with the instruction as comment (alias encodings); the whole-file check with the
  assembler works as for x86. `exptest` round-trips the two `tests\pe_arm` programs.
- Asmonite's editor colours the lines after `.arch thumb` as ARM/Thumb (registers `r0`..`pc`,
  `s0`..`d31`, instructions with condition and `.w`, `#` immediates, `@` comments) and the lines
  after `.arch i386` or `.arch x86_real` as x86 again: the processor is the lexer state the editor
  carries from line to line, as the assembler does it, so it follows every edit at once and needs
  no file extension or guess. The syntax menu entry "Assembler (x86)" is now "Assembler".
- Instruction info (F1) for imported functions: a row that uses an import (`call [ExitProcess]`,
  `jmp [X]`, the entry of the import table, its label, Thumb `ldr r3, =ExitProcess`) shows, under the
  instruction, the function from the new `help\de\winapi.md`: DLL, calling convention, number and
  bytes of the parameters, the call in C order, each parameter with type and meaning, the result, a
  short explanation and for the common ones an example. 205 sections (A and W forms together) for
  kernel32, user32, gdi32, comdlg32, advapi32, shell32, oleaut32, msvcrt and the `api-ms-win-crt-*`
  parts of the universal C runtime: every import of the programs in the repository and the usual
  ones beside them. A function without a section shows name and DLL and that there is no section yet.
  Checked against `dcc32.exe` (Delphi compiler), the Delphi program `asmoc.exe`, the clang program and
  the examples: 33 sections more for what `dcc32.exe` imports and was missing (resources, drives,
  environment, time zone, console control, GUIDs, ...), 238 sections now.
- Instruction info (F1) in Asmonite's editor: the line of the cursor explained in a new tab "Help"
  in the right column beside the registers, from the same help files as Dismonite (x86 or, after `.arch thumb`,
  `arm.md`; imported functions from `winapi.md`: every name in the line that has a section, e.g.
  `call [ExitProcess]`). The text changes when you press F1; *Help > Help language*
  switches Deutsch/English (`Asmonite.ini`, `[Help] Language`). The help code moved from `DisHelp.pas`
  to the shared unit `src/HelpText.pas` (help books, Markdown to RTF); `DisHelp` keeps what needs the
  disassembler's rows.
- Asmonite: a source with neither `.format` nor `.arch` (and without `org`, `section`, `segment`,
  `codeend`) is assembled as `.arch i386` + `.format pe console`: a single line `mov eax, 1` gives a
  32-bit Windows program (the Output says so). Everything that states `.arch` or `.format` or sets
  `org`/`section` is unchanged (DOS `.COM`, boot sectors, hand written PE, Thumb). The rule is the
  property `DefaultPe` of `TAsmoAssembler` / `TAsmFormatter`, switched on by Asmonite only; asmoc and the
  tests of the core keep assembling the source as it stands. For Windows on ARM the default is to come.
- Asmonite: the help changes only on F1 (it no longer follows the cursor and the text); F1 also explains
  the directives: new `help\de\directives.md` / `help\en\directives.md` with `.arch`, `.format`,
  `.code`/`.data`, `.import`, `.entry`, `.imagebase`, `du`, `rel32`, `codeend`, `section`, `segment`.
- Examples for DOS in assembler: `examples\dos\hello.com.asm` ("Hello, World!" as a .COM program, no
  header, `section 0x100`) and `examples\dos\hello_exe.asm` (as an .EXE with a header written by hand,
  one segment); both run with F9 in QEMU with FreeDOS. The comments explain the difference .COM / .EXE.
- Asmonite: the help is in the right column beside the register list (tabs Registers and Help, like
  Dismonite), no longer under the editor; the button x closes it, F1 shows it again.
- F1 explains error messages: on a line of the output window, or in the editor on the line marked as
  faulty, the help shows what the message of the assembler or of the PE check means, the usual causes
  and a fix (`help\de\errors.md`, `help\en\errors.md`, 32 sections: unknown instruction, undefined
  label, number, value range, jumps, address operands, `.format`, `.import`, DLL or function not
  found, ...). The help follows a click or a cursor key in the output window.
- Instruction info (F1) for DOS and BIOS interrupts, in Dismonite and Asmonite: for an `int` the function
  it calls is shown below the instruction, from the new `help\de\dos.md` / `help\en\dos.md` (154 sections
  each): `int 21h` (about 70 functions: characters, files, directories, memory, programs, vectors, time),
  `int 10h` video, `int 13h` disks (CHS and LBA), `int 16h` keyboard, `int 1Ah` clock, `int 33h` mouse,
  `int 2Fh`, `int 15h`, `int 14h`, `int 17h`, `int 20h`, `25h`, `26h`, `27h`, `29h`, `11h`, `12h`, `24h`,
  `28h`. The function number is found in the instructions before the `int` (`mov ah, 0x09`, `mov ax, 0x4C00`,
  `xor ah, ah`, `mov al, ...`; over labels, up to a jump, call, return or another `int`; an instruction
  that changes `ah` in another way gives up). If it is not known the overview of the interrupt with the list of
  its functions is shown. Each section has input registers, output registers (with the carry flag and the
  error codes) and often an example. `int 21h` of `TPC.EXE` and `HELLO.EXE`: 23 of 24 find the section of their
  function. The mouse functions are selected by `ax`, not `ah`.
- Help texts in English: `help\en\x86.md`, `arm.md` and `winapi.md` are the translations of the German
  files with the same sections under the same names (a test compares them). Dismonite: *Help > Help
  language* switches between Deutsch and English at once; the choice is saved in `Dismonite.ini`
  (`[Info] Language=de|en`); without a choice a German Windows gets German and every other one English;
  a language without the file falls back to German.

### Changed
- Asmonite: the register list on the right is shown only while a program is debugged (running or
  paused; *View > Registers* still decides whether it may be shown); an assembler error shows the
  Output tab (also when the Help tab or the Stack was shown, or the output area was hidden); every new
  line in the output scrolls the output to its end.
- The language of the help texts: English unless the user interface language of Windows is German
  (before: the regional format setting).

### Fixed
- `asmodbg.exe` started with a double click (no arguments) only printed its usage and ended,
  although the readme promised the window; without arguments it now runs like `--listen`.
- Dismonite, Windows on ARM over ssh: the tunnel used port 23456 of this computer too and failed
  when that port was taken; it now takes a free port here (asmodbg on the ARM machine stays on
  23456).

## 0.2.0 – 2026-10-11

### New
- Dismonite debugs 32-bit programs for Windows on ARM (PE, Machine 0x1C4) on a real Windows on
  ARM machine, like ARM Linux programs in the QEMU guest: entry stop, breakpoints, step into,
  step over, run to cursor, pause, stop, registers, memory, program output, exit code, exceptions.
  New server `asmodbg.exe` (C, ARM32/Thumb-2, built with llvm-mingw by `src/armserver/build.bat`):
  it runs the program with the Win32 debug API and speaks the GDB protocol like gdbserver, so the
  ARM debugger of Dismonite (`TArmGdbDebugger`, now with the target `atWinArm`) is used almost
  unchanged. Dismonite copies the program (and the server, if its version differs) with scp,
  starts the server by ssh and connects through an ssh tunnel (`-L`): no firewall rule on the ARM
  machine. Host (default `winarm`) and folder (default `asmodbg`, relative to the home folder) are
  `[WinArm] Host=` and `Dir=` in Dismonite.ini. Single steps use the SS bit of the ARM CPSR (found
  by experiment: Windows on ARM32 supports it, the server needs no instruction decoder). Tests:
  `tools/asmodbg_test.py` (server alone, 27 checks) and test part `winarmdbgtest`.
- `asmodbg --listen` (server version `asmodbg-3`, first step of the direct connection without
  ssh): the server stays open and serves one session after the other. A session uploads the
  program into its own folder (`vFile`), starts it only from there (`vRun`) and receives the
  program output as `O` packets. File names are restricted to plain names. The listen mode needs
  a login: a 12-character code (generated by the server, stored with DPAPI next to the EXE,
  shown by `asmodbg --show-code`), challenge-response with HMAC-SHA256 (Windows CNG) in both
  directions, then a MAC on every packet (integrity, no encryption); nothing else is answered
  before the login and 3 wrong proofs lock the server for 10 s. It listens on all addresses
  (default port 23457); winarm needs one firewall rule. The listen mode shows a small window
  (version, ARM32 check, IP addresses, port, code, status, a warning when run as administrator;
  `--port N`, `--no-window`, `--info`). `tools/asmodbg_test.py` now has 77
  checks, including the direct connection without ssh.
- Dismonite connects directly to `asmodbg --listen` (no ssh for debugging): login with the
  code (HMAC-SHA256 through the Windows CryptoAPI), version check, upload of the program with
  `vFile`, start with `vRun`, program output from the `O` packets. ini `[WinArm]`:
  `Mode=direct|ssh`, `Port`, `Code` (protected with DPAPI). `winarmdbgtest` now runs
  every test also directly and checks the message for a wrong code (39 checks).
- Dismonite: Debug > "Debug target Windows on ARM..." chooses Direct or ssh (host, port, code,
  folder) and has "Test connection" (connect, login, version; for ssh: does ssh answer), with
  clear error messages. The dialog opens by itself the first time a Windows on ARM program is
  started and no target is set up yet. The settings go to the ini `[WinArm]`.
- Release ZIP: `armserver\asmodbg.exe` (built by `tools/release.py`); the README of the ZIP
  explains the first setup on fresh computers (start the server, firewall, the dialog).
- One-line installer for the ARM computer: `powershell -NoProfile -Command "irm
  https://asmonite.com/downloads/install-asmodbg.ps1 | iex"` (`tools/install-asmodbg.ps1`;
  `tools/release.py` puts it and `asmodbg.exe` into `html/downloads/`, with the SHA-256 of the
  EXE inside the script). It refuses to run as administrator, checks the hash, replaces an older
  server and starts it. The dialog "Debug target Windows on ARM" shows the line with a
  "Copy the line" button.
- Dismonite: the debugger shows the stack and the memory of the program and its output, all at
  once with the registers: registers and stack right of the code, memory and output below it.
  The stack: 32 entries from the stack pointer, with the label a value points to (double click
  goes there). The memory: 16 rows from an address, a label, a register or (DOS) segment:offset;
  changed values are red. The output: what the program wrote in this run (Windows: its console,
  DOS: the screen, ARM: stdout). Each view can be switched off in the Debug menu; they appear
  with the first debug session.
- Dismonite reads 32-bit programs for Windows on ARM (Machine 0x1C4): headers, imports and
  exports as for i386, the entry point without the Thumb bit (label `start` at 0x401000 for
  `AddressOfEntryPoint` 0x1001), and the Thumb-2 code: the analysis follows it from the entry
  point and the exports, IT blocks are shown with their conditions, `adr`/`ldr [pc]` get the
  import or label they point to as hint. The export writes Thumb code as bytes with the
  instruction as comment, so it assembles to the same file. Floating point instructions (VFP:
  `vldr`, `vmov`, `vadd.f64`, `vpush`, `vmrs`, ...) are decoded, NEON instructions not yet. New
  table-driven decoder `dis_thumb` (all 16-bit codes and the Thumb-2
  instructions as capstone writes them; `tools/thumb_check.py`, test part `thumbtest`).
- Dismonite: ARM Linux programs may mix ARM and Thumb code (as GCC makes them): each place has its
  kind (new kind "thumb", key T). The analysis follows the entry point and the functions of the
  symbol tables in their kind (bit 0), changes the kind with blx and uses the mapping symbols
  ($a, $t, $d) and .plt; the debugger knows Thumb code by the T bit (breakpoints, step over).
  ARM programs can be exported as .asm now (code as bytes with the instruction as comment).
  New test program hallo-thumb.
- Dismonite: ARM and Thumb code has colours of its own: registers r0..pc, s0..s31, d0..d31, numbers
  after #, instructions also with a condition (addeq, vmoveq.f64).
- Dismonite: instruction info (F1): on the right, the instruction of the current row explained
  (syntax, flags, an example), from the help file `help\de\x86.md` (German for now); it follows
  the cursor (Help > Info follows the cursor). While debugging it is a second tab beside the
  registers. All instructions the disassembler decodes (x87: one section); ARM and Thumb in
  `help\de\arm.md` (`addeq`, `bne`, `vmoveq.f64` find their instruction and show the condition).
- Dismonite: zero bytes before a structure are one row too (`org`/`align`), not only before the PE
  header, a section and the end of the file: e.g. up to `e_lfanew` in a DOS header without stub, or
  between the code and the imports of the same section.
- Release ZIP: `examples\winarm\pe_arm32_hello_world.exe` (with its `.asm`), a Windows on ARM
  program to try the ARM debugger of Dismonite with asmodbg.

### Fixed
- Dismonite: File > Open promised programs without an extension (ARM Linux) under "Programs", but
  today's Windows dialog finds none with the filter `*.`. They are now under "All files (also
  programs without extension)", and Dismonite keeps the file type chosen last (`Dismonite.ini`).
- Dismonite: the last instruction of a section was not recognized as code when it ended with
  the 00 byte of an address (`call [ExitProcess]` at the end of `demo.exe`).
- Dismonite: the register list kept the values of the last debug session when another file
  was opened; its header showed "Regi..." instead of "Register".
- Dismonite: the last line a program wrote was replaced by "Program exited with code 0" at
  once (ARM programs write their output only at the end); the output view keeps all lines.
- The DOS example `HELLO.EXE` did not match its source `HELLO.PAS` (an older program compiled
  with Turbo Pascal 6). Both are now in `examples/dos`: `HELLO.PAS` counts up, `HELLO.EXE` is
  its translation by Turbo Pascal 7, checked by the tests.

## 0.1.0 – 2026-10-09 (test package, git tag v0.1.0)

The first version.

### Asmonite (editor, assembler, debugger)
- Editor with syntax highlighting for x86 assembly, C and Pascal; undo/redo, find and
  replace (Ctrl+F, F3, Ctrl+H), go to line (Ctrl+G).
- Assembler for the i386: `.format pe` (header and import table are generated) or every
  byte in the source; labels, `.imagebase`, `org`, `align`, `rva`.
- Check of the generated PE file before it is started (header, sections, imports).
- Win32 debugger: breakpoints (they also take effect while the program runs), step over/into,
  run to cursor, pause, show execution point;
  registers, stack and memory; the output of the program in the output window.
- DOS programs in QEMU with FreeDOS (not included: `qemu\run_freedos.bat` loads the FreeDOS
  floppy and offers to install QEMU); the same program starts again in the running QEMU.

### Dismonite (disassembler and debugger)
- Windows (PE), DOS (MZ) and ARM Linux (ELF) programs; the structures of the file format
  (headers, sections, imports, exports, ELF program headers and symbols) with the names of
  their fields.
- Analysis from the entry point, the exports and the relocation targets.
- Labels instead of addresses; Ctrl+click goes to the target, Alt+Left back.
- Marks and comments are saved in `<program>.dmon`.
- Export as `.asm` with labels, which the assembler of Asmonite turns into the same file again.
- Debugger: breakpoints, step over/into, run to cursor, pause, registers; command line
  parameters (Debug > Parameters, saved in the `.dmon`). Where the program stops becomes code.
  Windows programs directly, DOS programs in QEMU with FreeDOS, ARM Linux programs through
  gdbserver in Raspberry Pi OS under QEMU (Dismonite starts the guest on request).

### QEMU guests (folder qemu)
- `run_freedos.bat`: FreeDOS; loads the boot floppy (720 KB).
- `run_buster.bat`: Raspberry Pi OS (ARM) for debugging ARM programs; loads about 440 MB
  and sets the guest up (ssh, gdbserver, keyboard of Windows).
- Both offer to install QEMU with winget; `-h` shows the options.

### asmoc
- The assembler on the command line.

### Known limits
- No x87 floating point instructions in the assembler; the disassembler shows them without names.
- The differences to NASM are listed in docs/en/nasm-differences.md.
