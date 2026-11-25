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

<!-- EXAMPLES_END -->

German: [README.de.md](README.de.md).
