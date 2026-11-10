# The LilyGO T-PicoC3 with Asmonite

The T-PicoC3 of LilyGO has two chips on one board: an **RP2040** (the chip of the Raspberry Pi Pico, two Arm
Cortex-M0+), which drives the display (1.14 inch, ST7789, 135 x 240 pixels), and an **ESP32-C3** (one RISC-V core).
Both hang on the same USB-C port: **the way the plug is turned picks the chip**. The LED next to the port says which
one answers: blue for the RP2040, green for the ESP32-C3.

Asmonite debugs both, each with the one USB cable, without a debug probe. This page says what works on which side;
the details are in the guides of the two chips: [picoboot.md](picoboot.md) for the RP2040 over its USB boot,
[esp32c3.md](esp32c3.md) for the ESP32-C3.

## At a glance

| | RP2040 (LED blue) | ESP32-C3 (LED green) |
|---|---|---|
| Debugging without a probe | yes, over the USB boot (BOOTSEL, PICOBOOT): programs in the RAM | yes, over the USB JTAG of the chip: RAM and flash |
| Breakpoints, steps, registers, memory | yes | yes |
| Pause of a running program | **no** (the boot ROM waits for the program) | yes |
| Program in the flash | not over the USB boot (a UF2 file onto the drive `RPI-RP2` does it) | yes (`.target esp32c3 flash`) |
| Serial output to the PC | **no** (see below) | yes, the COM port of the chip: the tab Serial |
| Setting up once | *Debug targets > Raspberry Pi Pico (RP2040) > Set up the USB boot* | *Debug targets > ESP32-C3 > Set up the USB JTAG* |
| `.target` | `pico` | `esp32c3` |

## The RP2040 side

Turn the plug until the LED is blue. For a session the RP2040 must be in its **USB boot**: hold **BOOT**, press
**RUN**, let BOOT go; Windows shows the drive `RPI-RP2`. Then F9 or F7 as on a Pico without a probe
([picoboot.md](picoboot.md)): Asmonite loads the program into the RAM at `0x20000000` and debugs it over the boot
ROM. A running program cannot be paused that way: set a breakpoint before it runs into a loop. A program that
returns (`bx lr`) ends the session, and the board is ready for the next F9.

The pins of the board (from the documentation of LilyGO, checked with the examples):

| What | GPIO of the RP2040 |
|---|---|
| Display ST7789: SCLK, MOSI, CS, DC, RST, backlight | 2, 3, 5, 1, 0, 4 |
| Power of the display (PWR_ON) | 22 |
| The two keys (pressed = low, pull-up on) | 6, 7 |
| Red LED | 25 |

The examples in `examples/t-picoc3/`:

| File | What it does |
|---|---|
| `display_ram.asm` | Fills the display with one colour (the setup of the SPI and of the ST7789, step by step with F7) |
| `lines_ram.asm` | A white frame and coloured lines on black; returns |
| `text_ram.asm` | Text in a font of its own and a counter that counts up; a key ends it |

The RP2040 has no serial port of its own over USB: in the USB boot its USB port is the drive and PICOBOOT of the
boot ROM, nothing more, and a program would need a USB stack of its own for a COM port. Its UART is wired to the
ESP32-C3 on this board, not to the USB port. So nothing the program writes reaches the PC; show it on the display
instead, or look at it in the memory window at a breakpoint.

## The ESP32-C3 side

Turn the plug until the LED is green. Set up its USB JTAG once (*Debug targets > ESP32-C3 > Set up the USB JTAG*);
then everything works as in [esp32c3.md](esp32c3.md): F7 and F9, breakpoints, steps, pause, a program in the RAM
or the flash. The tab Serial shows what the program writes to the USB port of the chip (the peripheral USB
Serial/JTAG); it connects to the COM port by itself when the debugger has loaded the program.

Only three GPIOs of the ESP32-C3 reach the pin header, and it talks to the RP2040 over a UART: the examples of
`examples/esp32c3/` that drive pins (the LEDs at GPIO 12 and 13, the RGB LED at GPIO 8) are for other boards.
`examples/esp32c3/sum_ram.asm` uses no pin and runs here.

## Limits

- Only one chip at a time: the turn of the plug decides, a session on the other chip needs the plug turned.
- The RP2040 over the USB boot: RAM only, no pause, no serial output (see above).
- The pin map of the ESP32-C3 on this board is not checked: drive its pins only after a look at the documentation
  of LilyGO (github.com/Xinyuan-LilyGO/T-PicoC3).
