# The Raspberry Pi Debug Probe (not linked yet)

> **Kept for a chapter of its own later.** For now the guides describe the Pico and the Pico 2 over their USB cable
> only (the console of Asmonite and its debug monitor, see [riscv-pico2.md](riscv-pico2.md)); the Debug targets dialog
> does not show the probe settings. Asmonite still uses a probe that is plugged in. This page keeps what was written
> about the probe, from the guide of version 0.16.0.

## What you need

- a **debug probe** with CMSIS-DAP: the Raspberry Pi Debug Probe, or a second Pico with the `debugprobe` firmware.
  Three wires go to the debug pins of the board (SWCLK, GND, SWDIO); the board gets its power over its own USB cable.
- The probe needs no driver; Windows takes it as a WinUSB device.

Only one program can use the probe at a time: if OpenOCD or another debugger runs, close it (or choose OpenOCD in
*Debug > Debug targets*, a backup for the RISC-V cores).

## What the probe adds to the USB cable

- **Programs in the flash** (`.imagebase 0x10000000`): F7 / F9 erase and write only the 4 KB sectors that differ,
  check what was written, and debug the program in the flash. The first start of a new program takes about a second;
  an unchanged program is not written again. Through OpenOCD the flash cannot be written.
- **The RISC-V cores of the Pico 2** (`.arch riscv32`): the debugger halts core 0, writes the program into the RAM at
  `.imagebase`, sets the pc to `_start` and stops there. The registers `x0` to `x31` (by their names) and `pc`; 4
  hardware breakpoints, which also work in the flash.
- **Switching the cores of the Pico 2:** the chip runs one kind of cores at a time. If the other kind runs, the
  debugger writes a flash program of the right kind, resets the chip and goes on with the cores of the program (about
  two seconds). A program in the RAM cannot switch: after a reset the boot ROM starts the cores that the program in
  the flash is for; Asmonite then says to start a flash program of the right kind first (`blink_arm_flash.asm` or
  `blink_flash.asm`). **RISC-V Cores** or **Arm Cores** in the Board Manager (menu Board) writes the example `blink`
  of the other cores into the flash.
- **The Arm cores over SWD:** 8 hardware breakpoints on the Cortex-M33; if the program starts with a vector table,
  the debugger sets the stack pointer from it. The Pico (RP2040): 4 hardware breakpoints in the flash only, in the RAM
  `bkpt` instructions.
- A program for the Pico at a Pico 2 (or the other way round) is refused with the name of the board before anything is
  written. If the cores of the RP2040 do not answer after such an attempt, Asmonite resets them through the rescue
  port of the chip.

## Debug targets

*Debug > Debug targets > Raspberry Pi Pico 2*: **The USB debug probe** (RISC-V and Arm cores) or **OpenOCD as a
backup** (RISC-V cores only, its GDB server at host and port; the host is `127.0.0.1` and the port `3333`). *Test the
connection* says whether the board answers, whether the core runs or is halted, and which cores run. For the Pico:
*Test the connection* (its USB boot if a board is in it, else the probe) and *Set up the USB boot* (see
[picoboot.md](picoboot.md)). These controls are hidden in the dialog for now.

When both are there, the console at USB and a probe: the debugger takes the console when the tab Serial is at the USB
console, else the probe. If the probe still holds the core as a debugger (after an SWD session that did not end
cleanly), the monitor of the Pico 2 refuses and says so: unplug the board once and plug it in again.

## The serial output over the probe

The Raspberry Pi Debug Probe has a serial port as well: its second connector, **"U"**, is a UART with a COM port of
its own on the PC (next to the SWD at "D", over the same USB cable). Its cable goes to the board like this:

| Probe, connector "U" | Pico 2, Pico | Blue Pill |
|---|---|---|
| RX (input of the probe; yellow on the cable of the probe) | GP0, pin 1 (TX of UART0) | PA9 (TX of USART1) |
| TX (output of the probe; orange) | GP1, pin 2 (RX of UART0) | PA10 (RX of USART1) |
| GND (black) | GND, pin 3 | G |

When a session over the probe has loaded the program, the tab **Serial** connects to that COM port by itself and shows
what the board sends (115200 baud by default). The examples `examples/pico2/hello_uart_ram.asm` (RISC-V),
`hello_uart_arm_ram.asm` (Arm), `examples/pico/hello_uart_ram.asm` and `examples/stm32/hello_uart_ram.asm` write
"Hello, world!" about once a second at 115200 baud: the RP2040 and the RP2350 start their 12 MHz crystal for it first,
the STM32 runs from its 8 MHz HSI. The probe sends what it receives only to a terminal that has the line DTR on; the
tab Serial does that for it. When a terminal opens the COM port of the probe while the board sends without a pause,
the characters come garbled until the first pause: a quirk of the probe.

The console of Asmonite talks over UART0 (GP0, GP1) too, so also over the connector "U". **Prepare Board** with the
Pico 2 (Debug Probe) or the Pico (Debug Probe) on the left writes the console into the flash over the probe.

## A USB device without the SDK

`examples/pico/usb_echo_ram.asm` (Pico) and `examples/pico2/usb_echo_ram.asm` (Pico 2, Arm cores) make the board a
COM port on the PC over its own USB cable (USB CDC-ACM), all in assembler, without the Pico SDK and without TinyUSB.
The code for both is in `examples/pico/usb_cdc.asm`. Such a program takes the USB port of the board itself, so it
needs the probe: the probe at SWD, **and** the USB cable of the board to the PC, then F9. Windows shows a new COM port
(driver `usbser.sys`); the board greets you, and what you type comes back. The id 0x1209/0x0001 is the test number
of pid.codes: for tests on your own desk only.

## When it does not connect

- *No debug probe ... only one program at a time*: another program has the probe (OpenOCD, another instance of
  Asmonite). Close it.
- *The board does not answer over SWD*: the board has no power, the three wires are wrong or loose, or the probe is not
  the Debug Probe. The wires: SWCLK, SWDIO, GND.
- *The board is an RP2040 ...* (or *not an RP2350*, *no RP2040*): the board at the probe is not the one of `.target`.

## The STM32F103 ("Blue Pill")

It has no console of Asmonite: it is debugged over the probe only, see [stm32.md](stm32.md).
