# Examples

The examples of Asmonite. Each one here has been gone through again and tested on the boards it is for; more follow
one by one. Most are in aBelle; of the examples in assembly the first three are here (see the end), the others come
board by board.

`common/` holds programs that run on every board (ESP32, ESP32-S3, ESP32-C3, ESP32-S31, Raspberry Pi Pico and
Pico 2, also with WiFi); Asmonite translates them for the board you use. What they take in with `include`
(`console.abel`, `net.abel`) is the library of aBelle in [`abelle/lib`](../abelle/lib): `common/` for every board,
`<board>/` for one; in the ZIP it lies next to the compilers. `<board>/` holds programs for one board only, because
they use its hardware (pins, sensors, its display).

How to start one: F9 translates it for the board in the tab Serial and runs it. Or upload it in the Board Manager (or
Project > Compile and Upload) and type its name in the console of the board; arguments can only be given there, after
the name: `ping 192.168.1.20`, not `run ping 192.168.1.20`.

<!-- EXAMPLES_BEGIN: made from catalog.txt by tools/examples_build.py, change it there -->

## First steps

- `common/hello.abel`: **Hello, world.** Writes "Hello, world!" over the serial output of the board.
- `common/blink.abel`: **Blink.** Blinks the LED of the board; set `LED_PIN` for your board at its top first.
- `common/runs.abel`: **A number that stays.** Counts how often it has run, in the file `runs.txt` on the board
  (`file_size`, `file_read`, `file_write`); the number stays when the power is off. `cat runs.txt` in the console
  shows it, `rm runs.txt` starts again.

## The network, from the bottom up

For the boards with WiFi. Except for `scan`, they need a network: `wlan set` in the console once.

- `common/scan.abel`: **WiFi networks nearby.** The signal, channel, protection, BSSID and name of each network the
  board hears; a scan only listens and needs no network.
- `common/arpscan.abel`: **Who is in the network?** Asks every address of its /24 network by ARP and lists the
  devices that answer with their MAC.
- `common/ping.abel`: **Ping.** Pings the router and a server in the internet (four echo requests each, ICMP) and
  shows the times as the ping of a PC does; with an argument (`ping 192.168.1.20` or `ping example.com`) that host.
- `common/pingled.abel`: **The LED flashes at each ping.** The board answers the pings, and its LED flashes at each
  one; ping the address it shows from a PC or a phone. Set `LED_PIN` for your board at its top first.
- `common/wol.abel`: **Wake-on-LAN.** Sends the magic packet (a UDP broadcast) that starts a PC from sleep or from
  off (set the MAC of the PC in `pc_mac()` at its top, or `wol 02:00:00:12:34:56`); with the address of the PC after
  the MAC it then waits until the PC answers a ping. The board and the PC have to be in the same network.
- `common/udpecho.abel`: **UDP echo.** Sends every UDP packet to port 7777 back to its sender as it came and shows
  it; from a PC with one line of Python or PowerShell (at the top of the file). The board and the PC have to be in
  the same network.
- `common/dhcp.abel`: **The address from the router (DHCP).** Gets an address by DHCP and shows what the router
  gives: the address, the mask, the address of the network and its broadcast address, how many devices fit into it,
  the router, the DNS and DHCP servers, the lease and the name of the board.
- `common/dns.abel`: **Names into addresses (DNS).** Asks the DNS server of the router for the addresses of some
  names and shows each with the time of its answer, then once more (from its cache, faster); `dns asmonite.com` in
  the console asks for that name only.
- `common/ntp.abel`: **The time from the internet (NTP).** Asks the time server of the PTB (or `ntp pool.ntp.org`
  another one) and shows the date and the time in UTC and in CET or CEST (summer time by the rule of the EU) and how
  long the answer took.
- `common/webserver.abel`, `common/index.html`: **A web server for the files of the board.** Serves the files of the
  board to a browser: `http://<address>/` gives `index.html` (next to it a small one to upload), `/hello.txt` the
  file hello.txt; the type comes from the ending (html, txt, css, js, png, jpg ...), an unknown name gives 404. Also
  at `http://<name>.local/` (mDNS). Large files come slowly (about 14 KB/s).
- `esp32/telnetd.abel`, `esp32s3/telnetd.abel`, `pico/telnetd.abel`, `pico2/telnetd.abel`: **A small shell over the
  network (telnet).** Waits on port 23 for a telnet client (`telnet esp32.local` or PuTTY with Telnet) and has
  commands for the files (`ls`, `cat`, `hex`, `df`), the memory (`mem`), the network (`ip`, `ping`, `dns`), the LED
  (the RGB LED of the S3: `led 0 0 32`), `uptime` and `reset`; with `passwd set` in the console it asks for the
  password, with `boot telnetd` it starts after every reset.
- `common/httpget.abel`: **Fetch a web page.** Over TCP, as a browser asks for it: the status line and the header
  lines of the answer, the title of the page, its bytes and the time (`httpget` asks example.com, `httpget
  neverssl.com/` or `httpget http://192.168.1.20:8080/status` another address); only http.
- `common/httpsget.abel`: **A web page over HTTPS.** As `httpget`, but encrypted, with the TLS 1.3 of aBelle
  (ChaCha20-Poly1305, X25519; the handshake takes about 2 s on an ESP32): `httpsget` asks example.com, `httpsget
  www.wikipedia.org/` another server. The certificate of the server is not checked yet: encrypted, but not safe
  against someone posing as the server. Not on the ESP32-C3 yet (too large for its RAM).

## Clock and speed

How fast the board computes, and the clock of its core, set by a program. What is behind it: [Changing the clock of
the core](../docs/en/clock.md).

- `common/bench.abel`: **How fast is the board?** Four small tasks (the sieve of Eratosthenes, CRC-32, divisions,
  calls of a function), the same work on every board, with the time of each and the sum; it runs on Windows too, as a
  yardstick.
- `esp32/clockspeed.abel`, `esp32s3/clockspeed.abel`, `esp32c3/clockspeed.abel`, `esp32s31/clockspeed.abel`,
  `pico/clockspeed.abel`, `pico2/clockspeed.abel`: **The same work at each clock.** Measures the time of a loop at
  each clock of the core; `cpu_clock` of `cpuclock.abel` sets the clock (ESP32 1 to 240 MHz, ESP32-S3 10 to 240 MHz,
  ESP32-C3 10 to 160 MHz, ESP32-S31 1 to 320 MHz, Pico 48 to 133 MHz, Pico 2 48 to 150 MHz). At the end it sets the
  clock it found again.
- `esp32/slowclock.abel`, `pico/slowclock.abel`, `pico2/slowclock.abel`: **Blinking at a few kHz.** The LED blinks
  once a second, also when `cpu_clock_khz` takes the core down to about 5 kHz (ESP32) or 1 kHz (Pico, Pico 2); for
  that the program counts cycles instead of milliseconds. On the ESP32 `wlan off` first.
- `esp32/setclock.abel`, `esp32s3/setclock.abel`, `esp32c3/setclock.abel`, `esp32s31/setclock.abel`,
  `pico/setclock.abel`, `pico2/setclock.abel`: **Set the clock of the console.** The clock then holds for the console
  and every program after it, until a reset: upload it, then `setclock 240` (ESP32, ESP32-S3), `setclock 160`
  (ESP32-C3), `setclock 320` (ESP32-S31), `setclock 133` (Pico) or `setclock 150` (Pico 2) in the console; `setclock`
  alone shows the clock, `info` and the Board Manager show it too.

## For one board

Programs for one board, because they use its hardware: pins, sensors, its display.

- `esp32/bme280.abel`: **The BME280 sensor.** The temperature, the air pressure and the humidity of a BME280 sensor
  (or a BMP280, without humidity) at the I2C bus, every two seconds (SDA at GPIO 21, SCL at GPIO 22; I2C by hand over
  the pins); `bme280 5` in the console reads five times.
- `esp32/bme280_sleep.abel`: **Readings in light sleep.** The same readings every ten seconds, and in between the
  ESP32 in light sleep (awake about 10 ms of the ten seconds; the RTC timer wakes it, a key ends it). It switches the
  WiFi off first: it does not survive the sleep.
- `esp32/bme280_deep.abel`: **Readings in deep sleep.** A reading, then a minute of deep sleep, again and again; the
  chip is awake about 150 ms per reading, what it has to remember (count, time, lowest and highest temperature) is in
  the slow memory of the RTC. Upload it and make it the autostart program first (`boot bme280_deep`); to end it hold
  BOOT (or open the COM port again, or press EN and then a key), then `noboot`.
- `esp32/tdisplay.abel`: **The display of the T-Display.** The colour display of the LilyGO TTGO T-Display (ST7789V,
  240 x 135): colour bars, "Hello, world!" in a 5 x 7 font (1 to 3 times bigger), the two buttons (GPIO 0 and 35)
  with their counts; SPI by hand over the pins.
- `esp32/tdisplay_spi.abel`: **The display over SPI.** The same picture through VSPI, the SPI unit of the ESP32, at
  40 MHz: the whole screen in 14 ms instead of 350 ms by hand.
- `pico/lcd28.abel`: **The Pico-ResTouch-LCD-2.8 display.** The plug-on colour display by Waveshare (ST7789VW, 320 x
  240) through SPI1, the SPI unit of the RP2040, at 24 MHz: colour bars, "Hello, world!" in a 5 x 7 font, the seconds
  since the start; the whole screen in 56 ms (at 133 MHz, at 48 MHz 127 ms).
- `pico/touch28.abel`: **Painting on the touch display.** The touch screen (XPT2046) of the same display on the same
  SPI1: tap three crosses first (the calibration), then paint with a finger or a pen, pick the colour at the top;
  readings with too little pressure or too much scatter do not count, so no stray points appear.
- `esp32s31/rgbblink.abel`: **The RGB LED.** Blinks the RGB LED of the ESP32-S31 board (a WS2812 at GPIO 60) by
  `rgb()` of its console; set `COLOUR` at its top.

## In assembly

Ctrl+F9 assembles a file into the program next to it, F9 runs it in the debugger (F5 sets a breakpoint, F8/F7 step).

- `windows_intel/demo.asm`: **Count from 1 to 5.** Counts from 1 to 5 and writes a line for each number (i386, a
  console program for Windows, `printf` of `msvcrt.dll`).
- `windows_arm/hello_arm32.asm`: **Hello, World on Windows on ARM.** "Hello, World!" for Windows on ARM (Thumb-2, PE,
  machine ARMNT); Dismonite debugs it on a Windows on ARM computer (the debug server `asmodbg`, see the README of the
  ZIP).
- `dos/hello_exe.asm`: **A DOS .EXE by hand.** "Hello, World!" as a DOS program (.EXE): the header of the file
  written by hand and explained, and how an .EXE differs from a .COM; F9 runs it in QEMU with FreeDOS
  (`qemu\run_freedos.bat` once first).
- `esp32/instructions_xtensa.asm`: **The important instructions, step by step.** The important instructions of the
  Xtensa core one after the other, each with a comment on what it does and the value it gives: values, arithmetic,
  bits, memory and stack, conditional branches, loops (`loop` too), subroutines with `call0`, `call8` and `callx8`
  and a factorial that calls itself. No pin: step through it with F7 and watch the registers; at the end the output
  window shows 120.
- `pico2/instructions_arm.asm`: **The important instructions of the Arm core, step by step.** The important
  instructions of the Cortex-M33 (Thumb-2) one after the other, each with a comment on what it does, the value it
  gives and the flags (N Z C V) it sets: values (`movw`/`movt`), arithmetic (`udiv`, `mls` too), bits, memory and
  stack, conditional branches (`cbz`, `tst` too), IT blocks, a loop, subroutines with `bl`, `bx lr` and `blx` and a
  factorial that calls itself. No pin: step through it with F7 over the USB cable; at the end it goes back to the
  console, "Program ended (code 120)".
- `pico/instructions_arm.asm`: **The important instructions of the Cortex-M0+, step by step.** The important
  instructions of the Pico (Thumb-1) one after the other, each with a comment on what it does, the value it gives and
  the flags it sets; and how to do without the instructions of the Pico 2: large constants from a word behind the
  code, the division as a subroutine, branches instead of IT blocks. No pin: step through it with F7 over the USB
  cable; at the end "Program ended (code 120)".
- `esp32c3/instructions_riscv.asm`: **The important instructions of RISC-V, step by step.** The important
  instructions of the ESP32-C3 (RV32IMC) one after the other, each with a comment on what it does and the value it
  gives: values (`li`, `lui`, `auipc`), arithmetic (`div`, `rem` too), bits and comparisons without flags (`slt`,
  `sltu`), memory and stack, branches that compare by themselves, a loop, subroutines with `call`, `jal` and `jalr`
  and a factorial that keeps `ra` on the stack. No pin: step through it with F7 over the USB cable; at the end it
  waits, Debug > Pause shows a0 = 120.

<!-- EXAMPLES_END -->

German: [README.de.md](README.de.md).
