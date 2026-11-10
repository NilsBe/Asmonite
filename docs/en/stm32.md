# The STM32F103 "Blue Pill" with Asmonite

The Blue Pill is a small board with an STM32F103C8 from ST: one Arm Cortex-M3 (72 MHz at most, 8 MHz after a
reset), 20 KB of RAM and 64 or 128 KB of flash. Asmonite assembles its code (`.arch thumb`, `.target stm32f103`),
loads a program into its RAM or writes it into its flash, and debugs it over a debug probe: breakpoints, steps,
pause, the registers, the memory. What the program sends on USART1 shows in the tab Serial, over the same probe.

Tested with a Blue Pill with an original STM32F103C8 (device id 0x410, 128 KB of flash) and the Raspberry Pi Debug
Probe.

## What you need

- A Blue Pill (or another board with the STM32F103).
- A **debug probe** with CMSIS-DAP: the Raspberry Pi Debug Probe, or a Pico with the `debugprobe` firmware. The
  Blue Pill has no debugger of its own, and Asmonite has no way without a probe for it (the boot ROM of the STM32F103
  loads programs over its UART only, which Asmonite does not use).
- A USB cable for the power of the board (its own USB port), Windows 10 or 11.

## Connecting

The four pins at the end of the board (3V3, SWDIO or IO, SWCLK or CLK, GND) take the SWD cable of the probe, its
connector "D":

| Probe, connector "D" | Blue Pill |
|---|---|
| SWCLK (orange) | CLK |
| SWDIO (yellow) | IO |
| GND (black) | GND |

**3V3 stays free**: the board gets its power over its own USB port. **Debug > Debug targets > STM32F103 (Blue Pill)
> Test the connection** shows whether the chip answers: its device id and the size of its flash.

## A program in the RAM

```asm
.target stm32f103
.arch thumb
.imagebase 0x20000000

_start:
    ...
```

F7 (step into) or F9 (run) loads the program into the RAM at `0x20000000` and stops at `_start` (without
`_start`: at the first byte). Then F7 and F8 step line by line (*step over* knows `bl` and `blx`), F5 sets a
breakpoint, F9 runs to the next one, **Debug > Pause** stops a running program where it is, Stop ends the session.
The registers `R0` to `R12`, `SP`, `LR`, `PC`, `XPSR` with its flags show on the right. The stack pointer starts at
the end of the RAM (`0x20005000`). In the RAM the debugger sets breakpoints as `bkpt` instructions (the memory view
does not show them); after a reset the board runs the program of its flash again.

The core runs from its internal 8 MHz oscillator (HSI) after a reset.

## A program in the flash

```asm
.target stm32f103
.arch thumb
.imagebase 0x08000000

vectors:
    dd 0x20005000           ; the stack pointer at the start: the end of the RAM
    dd _start + 1           ; the start address (+1: Thumb code)
_start:
    ...
```

A program for the flash starts with the vector table of the Cortex-M3. F7 or F9 write it over the probe, through the
flash controller of the chip, only the pages of 1 KB that differ; then the chip is reset and the debugger stops at
`_start` (F7) or lets it run (F9). In the flash it has 6 hardware breakpoints. After a reset or a power cycle the
board starts the program by itself.

Before it writes anything, Asmonite reads the device id of the chip: on a board that is no STM32F103 (or a copy that
answers with another id) it writes nothing and says why.

## The serial output over the debug probe

The Raspberry Pi Debug Probe has a serial port as well: its connector **"U"** is a UART with a COM port of its own on
the PC.

| Probe, connector "U" | Blue Pill |
|---|---|
| RX (input of the probe; yellow) | PA9 (TX of USART1) |
| TX (output of the probe; orange) | PA10 (RX of USART1) |
| GND (black) | G |

When a session over the probe has loaded the program, the tab **Serial** next to the output window connects to that
COM port by itself and shows what the board sends (at the baud rate chosen in the tab, 115200 by default). The
debugger and the terminal do not get in each other's way: Connect and Disconnect stay usable.
`examples/stm32/hello_uart_ram.asm` writes "Hello, world!" about once a second at 115200 baud: it switches the
clocks of port A and USART1 on, makes PA9 an output of USART1 and sets the baud rate for the 8 MHz of the HSI.

The probe sends what it receives only to a terminal with the line DTR on; the tab Serial does that. In another
terminal program: DTR on. Without the probe, a USB serial adapter at PA9 and GND does the same.

## The examples

| File | What it does |
|---|---|
| `examples/stm32/blink_ram.asm` | The LED at PC13 on and off, in the RAM |
| `examples/stm32/blink_flash.asm` | The same in the flash, with the vector table |
| `examples/stm32/hello_uart_ram.asm` | "Hello, world!" once a second on USART1 (PA9): the tab Serial shows it over the probe |

The ARM assembly tutorial on asmonite.com has boxes for the Blue Pill too, with its examples in
`tutorial/arm/bluepill/`.

## If something does not work

| Message or sign | What to do |
|---|---|
| "The board does not answer over SWD" | The three wires (they come loose easily on the pins), the power of the board over its USB port |
| "The board is no STM32F103 ..." | Another board at the probe, or a copy of the chip with another id: nothing was written |
| The tab Serial shows nothing | The cable of the connector "U": RX of the probe at PA9; in another terminal DTR on |
| "COM6 is open in another program" (in the tab Serial) | Another program has the COM port of the probe (a terminal): close it |

## Limits

- Debugging needs the probe: the STM32F103 has no USB boot that Asmonite could use.
- The core runs at 8 MHz (HSI); a program that wants 72 MHz switches the PLL on itself.
- Only one board at the probe at a time; only the STM32F103 (no other STM32).
