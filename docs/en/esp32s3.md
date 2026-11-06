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

Press F9 (run) or F7 (step into). The debugger resets the chip into the download mode of its boot ROM over the USB
serial port (the lines DTR and RTS, as esptool does), stops core 0 there, loads the program to `0x40378000` and runs it
or stops at `_start`. Every session starts on the same clean chip this way: the core at 40 MHz, the watchdogs off, the
peripherals as after a reset. Then: steps (F7, F8), breakpoints (F5), registers `a0` .. `a15`, `pc`, `ps`, `sar`,
`windowbase`, `windowstart` and the loop registers, memory (also as code). The stack pointer `a1` starts at
`0x3FCD0000`. After RST the firmware of the flash runs again.

The RAM from `0x40378000` to `0x403BFFFF` (288 KB) is free for the program; above it the boot ROM keeps its data.

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

## The examples

| File | What it does |
|---|---|
| `examples/esp32s3/rgb_ws2812_ram.asm` | The RGB LED WS2812 at GPIO 48: red, green and blue in turn, half a second each. The 24 bits of colour are timed with the cycle counter `ccount`; windowed calls with `call8`, `entry`, `retw` |
| `examples/esp32s3/rgb_ws2812_flash.asm` | The same in the flash, with the watchdogs switched off and the clock set at the start |

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

- Core 0 only; the second core is not started and not debugged.
- Not yet: the MAC16 and vector instructions (`ee.*`) of the ESP32-S3, programs in the external flash or PSRAM (only
  the internal RAM), WiFi and Bluetooth.
- The original ESP32 (Xtensa LX6) has the same instructions (without `salt`, `saltu`), but no USB JTAG: Asmonite
  runs and flashes it over the serial port of the board, without a debugger ([esp32.md](esp32.md)).
- How the chip does the debugging: the protocol of `esp_usb_jtag.c` and the Xtensa debug module of OpenOCD
  (`src/target/xtensa`).
