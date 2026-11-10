# The Raspberry Pi Pico (RP2040) without a debug probe

Asmonite debugs a program in the RAM of an RP2040 **with one USB cable, without a debug probe and without
soldering**: over the USB boot of its boot ROM (BOOTSEL, the interface PICOBOOT that `picotool` uses too).
Breakpoints, steps line by line, step over a call, the registers, the memory. When the program returns, Asmonite
shows `r0` and `r1`.

This works for the Raspberry Pi Pico and for other boards with the RP2040. Tested with a LilyGO T-PicoC3 (an RP2040
and an ESP32-C3 on one board, see [t-picoc3.md](t-picoc3.md)).

With the Raspberry Pi Debug Probe (or another CMSIS-DAP probe) at the SWD pins Asmonite debugs the Pico as before,
also programs in the flash and with pause. The USB boot is the way without a probe.

## What you need

- A board with the RP2040 and a USB cable that carries data.
- The board in its **USB boot**: hold **BOOT** (or BOOTSEL), then plug the board in, or press **RUN** (reset) while
  you hold BOOT; then let BOOT go. Windows shows the drive `RPI-RP2`.
- Windows 10 or 11.

## Setting up once

The USB boot has two interfaces: the drive, which Windows knows, and "RP2 Boot", for which Windows needs a driver.

1. Device Manager: **RP2 Boot** (under "Other devices"), right-click, **Update driver**.
2. **Browse my computer for drivers**, then **Let me pick from a list of available drivers on my computer**.
3. **Universal Serial Bus devices**, Next.
4. Manufacturer **WinUsb Device**, model **WinUsb Device**, Next, and confirm the warning.
5. In Asmonite: **Debug > Debug targets > Raspberry Pi Pico (RP2040) > Set up the USB boot**. Windows asks for
   administrator rights: Asmonite gives the interface a name (a device interface GUID) by which programs find it.

Both are needed once for each board. Then **Test the connection** says "an RP2040 (boot ROM version 3) in its USB boot
(BOOTSEL), no debug probe" (version 3 is the RP2040 B2, version 1 and 2 the older B0 and B1).

## A program

```asm
.target pico
.arch thumb
.imagebase 0x20000000

_start:
    movs r0, #42
    bx   lr
```

When the board is in its USB boot, F9 (run) and F7 (step into) take that way by themselves; the output window says
"in its USB boot (BOOTSEL), over the USB cable without a debug probe". The program goes into the RAM at `.imagebase`
(from `0x20000000` up to `0x2003F000`, 252 KB), is read back and starts at `_start`; F7 stops there. Then as on the
other boards: F7 and F8 step line by line, F8 steps over `bl`, F5 sets a breakpoint, F9 runs to the next one, the
registers `r0` to `r15` and `xPSR` show the state, and the memory window reads the RAM and the ROM.

The program starts with `sp` at `0x2003F000` (its stack grows down from there) and `lr` at the end mark of the
debugger: it is called like a function. When it returns (`bx lr`, or `pop {..., pc}` after a `push {..., lr}`), the
session ends and the output window shows

```
The program returned: r0 = 42 (0x2A), r1 = 0 (0x0)
```

and the board is ready for the next F9, still in its USB boot.

**No pause.** The program runs while the boot ROM waits for it: a running program cannot be paused, and Stop lets it
run on. Set a breakpoint before the program runs into a loop. A program that never stops runs until RUN (or until the
board is unplugged); then put it into the USB boot again.

**A fault** (a load from an address without memory, an unaligned access, an undefined instruction) stops the program
at the instruction: "a HardFault at ...". A `bkpt` in the program stops there too.

## How it works

A small stub of Asmonite (268 bytes at `0x2003F000`, `src/debugger/picobootstub.asm`) is called by the boot ROM
(the command EXEC of PICOBOOT). It keeps the registers of the boot ROM, turns the interrupts off, puts its own vector
table in place, loads the registers of the program and jumps to its pc. Without a debug probe the Cortex-M0+ turns a
`bkpt` into a HardFault: the stub takes it, keeps the registers of the program, puts back everything of the boot ROM
and returns to it. Then the USB boot answers again, and Asmonite reads the registers and the memory over USB.

A breakpoint is a `bkpt` that Asmonite writes into the RAM only while the program runs; at the stop the instruction is
back. A step puts a `bkpt` at every address the instruction can go to (the next one, the target of a branch, `bl`,
`bx`, `pop` with the pc).

## The examples

The examples of the Pico 1 in `examples/pico` that run in the RAM run this way too; a program that ends in a loop
(`blink_ram.asm`) can only be stopped by a breakpoint or by RUN. `examples/t-picoc3/display_ram.asm` fills the display
of the LilyGO T-PicoC3 (step through its setup of the SPI with F7).

## No serial output

Over the USB boot a program has no way to send text to the PC: the USB port is the drive and PICOBOOT of the boot
ROM, nothing more (a COM port would need a USB stack in the program, and the program would take the USB port away
from the debugger). What a program wants to show: in the RAM, where the memory window shows it at a breakpoint, or on
a display. With the debug probe the UART of the probe shows what the Pico sends on GP0
([riscv-pico2.md](riscv-pico2.md), "The serial output over the debug probe"); without it a USB serial adapter at GP0
and GND does that, also next to a session over the USB boot.

## If something does not work

| Message | What to do |
|---|---|
| "No RP2040 in its USB boot is plugged in" | Hold BOOT, press RUN (or plug in), let BOOT go: the drive RPI-RP2 appears |
| "... Windows has no driver for its interface RP2 Boot" | The driver as above (once) |
| "The USB boot of this board is not set up for Asmonite yet" | Debug targets: "Set up the USB boot" (once) |
| "... cannot be opened (another program ...?)" | Close picotool or another program that has it |
| "a program goes into the RAM only" | A program for the flash needs the debug probe, or Project > UF2 and the drive RPI-RP2 |

## Limits

- Programs in the RAM only, below `0x2003F000` (above it the stub, at the top the stack of the boot ROM). A program
  for the flash: with the debug probe, or as a UF2 file (Project > UF2) copied to the drive `RPI-RP2`.
- No pause of a running program (see above).
- The memory window reads the RAM and the ROM; not the flash (the USB boot reads it only after a setup of the flash
  that Asmonite does not do yet) and not the peripherals (the program itself can use them).
- The program runs with the clocks that the boot ROM has set up for USB (48 MHz).
- **The Pico 2 (RP2350) cannot be debugged this way**; use the debug probe for it (there everything works, also pause
  and the flash). Its USB boot has PICOBOOT too, and Windows takes it without any setup, but two things are missing
  (tried on a Pico 2): it has no command EXEC any more (it answers "unknown command"), so the boot ROM cannot call
  the stub and get control back; and a stop by a restart into the USB boot is no way out either, because the boot
  ROM of the RP2350 clears the whole RAM before it enters the USB boot: the program, its stack and its data would
  be gone. Over its USB boot a program could only be loaded and started, without stops: that is what the UF2 file
  on the drive `RP2350` already does.
