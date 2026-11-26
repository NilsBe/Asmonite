# The Raspberry Pi Pico and Pico 2 with Asmonite

How to write a program in Arm assembler or in aBelle, run it on a Raspberry Pi Pico or Pico 2 and look at it while
it runs. All you need is the USB cable of the board: Asmonite puts its console onto the board once, then it loads
your programs over that cable, runs them and lets you step through them. The instruction reference is the F1 help
of Asmonite.

> **New here?** Plug the board in (a Pico the first time with its BOOTSEL button held), open **Board > Board Manager** and click **Prepare Board...**: then the
> Asmonite console is on the board, and F9 runs your programs there. All about the Board Manager:
> [board-manager.md](board-manager.md).

> **The examples of this page:** the examples in assembly (`examples/<board>/…`) and some in aBelle that this page names
> are being gone through again and come into the folder `examples/` one by one; until then they are not in the ZIP and
> not in the public repository. What is released already is in [examples/README.md](../../examples/README.md).

## What you need

- a **Raspberry Pi Pico**, **Pico W**, **Pico 2** or **Pico 2 W**
- its **USB cable** (one that carries data, not a charging cable only)
- Windows 10 or 11 with Asmonite. No driver to install: Windows takes the board as a COM port of its own.

## The first start: the console onto the board

1. Hold the **BOOTSEL** button of the board while you plug it in (a new, empty board needs no button). Windows shows
   a drive, `RPI-RP2` or `RP2350`.
2. **Board > Board Manager**: the board is on the left, in its USB boot. Click **Prepare Board...**: Asmonite
   copies its console as a UF2 file onto the drive, the boot ROM writes it into the flash and starts it.
3. The Board Manager now shows "Pico (USB console)" or "Pico 2 (USB console)" with its files. The console is a COM
   port of its own on the PC ("USB Serial Device", VID/PID 1209:0001, the driver of Windows); each board gets its own,
   also two of the same kind at one PC.

From now on everything goes over this cable: files, programs, the debugger. The console stays in the flash and is
there again after every reset. A newer Asmonite brings a newer console: the line *Console* of the Board Manager says
so, and **Prepare Board...** writes it without the button (Asmonite sets the port to 1200 baud, the console restarts
the chip into its USB boot, as the boards of Arduino do, then the UF2 file); the files stay.

## Running and debugging

Programs for the console run in the RAM of the board: `.imagebase 0x20000000`.

```asm
.target pico2           ; for the Raspberry Pi Pico 2 (the Pico: .target pico)
.arch thumb             ; Arm instructions (Thumb)
.imagebase 0x20000000   ; in the RAM, started by the console

_start:
    push {r4, lr}
    ...
    movs r0, #0         ; the code of the end
    pop  {r4, pc}       ; back to the console
```

- **F9** without a breakpoint: Asmonite assembles the program, loads it over the cable and the console runs it; the
  tab **Serial** shows what it writes.
- **F7** (step into), or F9 with a breakpoint: the same, but the **debug monitor** of the console stops it at
  `_start` (or at the breakpoint). **F7** steps one instruction, **F8** steps over a call (`bl`, `blx`), **F4** runs
  to the cursor, **F5** sets or removes a breakpoint, **F9** runs on, *Debug > Pause* stops a running program,
  **Ctrl+F2** (Stop) ends it. The output window says "over the debug monitor of its console".
- The right-hand side shows `r0` to `r12`, `sp`, `lr`, `pc`, `xpsr` and its flags `N Z C V`; a double click changes
  a value. The stack shows the words from `sp`; where a value points into your program, the note names the label and
  the line (so you see saved return addresses). The memory view has a switch **Bytes / Code**: *Code* lists the
  instructions from the address (`pc` is the default), with `=>` at the next one and your labels.
- The program runs as the console starts it: on a stack of its own, with the text of its arguments in `r0`. `bx lr`
  (or `pop {..., pc}`) at the end goes back to the console: "Program ended (code n)", `n` is `r0`. A fault in the
  program (a read where nothing is) and Ctrl+C end it too; the console says how and goes on.

`examples/pico2/instructions_arm.asm` (Pico 2) and `examples/pico/instructions_arm.asm` (Pico) are made for this: the
important instructions one after the other, each with a comment on what it does and which value comes out. Open one,
press F7 and keep pressing it.

How it works: on the Pico 2 the Cortex-M33 sends the breakpoints of its FPB (7 for Asmonite) and the single steps
into its exception DebugMonitor, which runs below the priority of the USB interrupt: the connection stays open while
the program stands. The Cortex-M0+ of the Pico has no such exception; Asmonite writes a `bkpt` into the program for
each breakpoint and each step (only while it runs), the HardFault of the `bkpt` leads into the monitor. A program that
keeps all interrupts off cannot be paused meanwhile.

**The console at the prompt** (the tab Serial on the COM port of the board, Enter): `ls`, `cat name`, `rm name`,
`df`, `format`, `run name [args]` (or the name alone), `boot name`, `boot`, `noboot`, `info`, `reset`, `help`, and on
a W `wlan`, `name`, `passwd`. Ctrl+C (Stop in the tab Serial) stops a program that runs. After a reset with a program
for the autostart the console waits a second: a key keeps it at the prompt. The Board Manager shows the files with
buttons: upload, download, delete, run, autostart, format. **Project > Compile and Upload** (for assembler: Assemble and
Upload) puts a program into the files of the board, to start it later with `run`.

## The Pico (RP2040)

The first Pico has an RP2040 with two Arm Cortex-M0+. Programs: `.target pico`, `.arch thumb`, `.imagebase
0x20000000` (up to `0x2002FFFF`).

| What | Address |
|---|---|
| Flash (2 MB) | `0x10000000`: the console, then from 1 MB the files |
| RAM (264 KB) | `0x20000000` to `0x2002FFFF` the programs, from `0x20030000` the console |
| Peripherals, SIO | `0x40000000`, `0xD0000000` (the same as on the Pico 2) |

- **Fewer instructions.** The Cortex-M0+ knows the ARMv6-M: Thumb with the 16-bit instructions, of the 32-bit ones
  only `bl`, `msr`, `mrs` and the barriers. There is no `movw`/`movt`, no `cbz`, `cbnz`, `it`, no division; most
  instructions work on `r0` to `r7` only. A 32-bit constant comes from a word behind the code (`ldr r0, label`). With
  `.target pico` the assembler reports every other instruction as an error with its line.
- The functions of the console are a table at `0x20038140`; `examples/pico/hello_console.asm` shows it, with a
  division of its own.
- A fault in a program shows only the exception and the pc (the M0+ has no registers that say more).

## The Pico 2 (RP2350)

The RP2350 has two processors of each of two kinds: two Arm Cortex-M33 and two RISC-V cores (Hazard3). The console
runs on the Arm cores, so programs for the console are Arm programs: `.target pico2`, `.arch thumb`, `.imagebase
0x20000000` (up to `0x2006FFFF`). The Cortex-M33 knows Thumb-2: also `movw`/`movt`, `cbz`, `it`, `udiv`, `sdiv`.
For the RISC-V cores see [A program in the flash](#a-program-in-the-flash-and-the-risc-v-cores).

| What | Address |
|---|---|
| Boot ROM | `0x00000000` |
| Flash (4 MB) | `0x10000000`: the console, then from 1 MB the files |
| RAM (520 KB) | `0x20000000` to `0x2006FFFF` the programs, from `0x20070000` the console |
| Peripherals (UART, GPIO, timers, ...) | `0x40000000` |
| SIO (fast GPIO, spinlocks) | `0xD0000000` |

Peripherals are registers at fixed addresses, read and written with `ldr` and `str`; their addresses are in the data
sheet of the chip. Each register also answers at three more addresses: +`0x1000` flips the bits you write (xor),
+`0x2000` sets them, +`0x3000` clears them, so you need no read-modify-write. After a reset the **pads are isolated**
on the RP2350: a program that drives a pin clears the bit `ISO` of its pad register first.

## Programs for the console

The console calls `_start` with the text of the arguments in `r0`; `bx lr` ends the program with the code in `r0`,
and so does `exit` from any depth. Its functions are a table of addresses at `0x20078140` (the Pico: `0x20038140`),
in the order of the ESP32: +0 `exit`, +4 `version`, +8 `put_char`, +12 `get_char`, +16 `poll_char`, +20 `print`,
+24 `millis`, +28 `file_size`, +32 `file_read`, +44 `args`, +48 `led` (the LED of the board), +52 `wl_call` (the WiFi
of a W, for `wifi.abel`). A call loads the address from the table and jumps there with `blx`; `r0` to `r3` are the
arguments, `r0` the result, `r0` to `r3` and `r12` may change. `examples/pico2/hello_console.asm` shows it. The same
functions are also code to call at `0x20079E00` (16 bytes each, in the same order; the Pico: `0x20039E00`).

**Programs in aBelle:** `target "pico2"` (the Pico: `target "pico"`) and `include "console.abel"`; F9 runs them over
the console, with a breakpoint F9, F7 and F8 debug them, with the variables. A program without a line `target` is
translated by Asmonite for the board of **Project > aBelle for**; so the examples in `examples/common/` run here too,
for example `hello.abel` and `blink.abel`. The Pico W and the Pico 2 W have their LED at the WiFi chip: `led()`
switches it there (its first call starts the chip, as `wlan on`).

## The WiFi of the Pico W and the Pico 2 W

The chip does not tell a W from the Pico and the Pico 2, so the console asks the WiFi chip of the board (CYW43439,
at GPIO 23, 24, 25 and 29) once at its start: when it answers, the board is a W. The hello of the console, `info`
and the Board Manager name it. On a board without WiFi the LED lights for a quarter of a second meanwhile.

`wlan on` starts the WiFi chip with its firmware: the console reads it from the files `43439A0.bin` and
`nvram_rp2040.bin` in the flash and sends it over the SPI of the chip into its RAM (about 226 KB in 0.6 s), then
gives it its CLM data (`43439A0_clm.bin`, the channels and the power per country). Prepare Board puts the three files
onto a W (from `wlan\infineon` next to `Asmonite.exe`, unchanged from Infineon, with their license). `wlan off`
switches the chip off, `wlan` tells whether it runs, `wlan scan` lists the networks around.

`wlan set` asks for the name of a network and its password (not shown; Enter alone: an open network) and joins it
(WPA2 with AES). The console keeps the name and the key of WPA2 made of the password (PBKDF2, about 2 s), not the
password, in the last two sectors of the flash, behind the files; `wlan on` starts the chip and joins the network
again (also after a reset), `wlan clear` forgets it. The Board Manager does the same from its context menu, with the
networks your PC sees and the password from Windows.

After a join the console gets an address by DHCP and renews it at half the lease; `wlan` shows the address, the mask,
the router and the DNS server. When the board keeps a network, the console joins it by itself after its start, once
it has waited 3 quiet seconds at the prompt. It answers ARP, ping and mDNS for the board (`name.local`): at the
prompt, while a program runs and while it stands at a breakpoint. `name set <name>` gives the board a name for the
router and for mDNS (else `picow-` or `pico2w-` and the end of the MAC), `passwd set` the password for telnet.

**aBelle programs on the network:** `include "net.abel"` (after `console.abel`) gives them ARP, IPv4, ping, UDP, DHCP,
DNS and mDNS, `tcp.abel` adds TCP, with the same functions as on the ESP32; `wifi_connect_saved()` starts the chip and
joins the network of `wlan set`. The examples in `examples/common/` (`scan`, `ping`, `dns`, `ntp`, `webserver`,
`httpget`, `httpsget` ...) show it, `examples/pico/telnetd.abel` and `examples/pico2/telnetd.abel` are a small shell
over telnet.

## A program in the flash, and the RISC-V cores

The console runs programs in the RAM. A program of your own in the flash (`.imagebase 0x10000000`), and a program for
the RISC-V cores of the Pico 2 (`.arch riscv32`), go onto the board as a **UF2 file**: **Project > Save as UF2 file
(Raspberry Pi Pico)...** writes it, then hold BOOTSEL while you plug the board in and drag the file onto the drive that
appears. The board restarts with the program. Such a program takes the place of the console in the flash (the files
stay); to have the console back, BOOTSEL and **Prepare Board...** again.

The boot ROM starts a program from the flash only when it can tell what it is:

- **Pico 2:** a small block in the first 4 KB says it (IMAGE_DEF). With `.target pico2` the assembler checks it: it
  must be in the first 4 KB, and its IMAGE_TYPE must fit `.arch` (`0x1101` RISC-V, `0x1021` Arm). The boot ROM starts
  the cores the block names: so a RISC-V program switches the chip to its RISC-V cores, the console (an Arm program)
  back to the Arm cores.

  ```asm
  image_def:
      dd 0xffffded3            ; start marker
      db 0x42, 1               ; item IMAGE_TYPE, 1 word
      dw 0x1101                ; executable | RISC-V | RP2350
      db 0x44, 3               ; item ENTRY_POINT, 3 words
      dw 0
      dd _start                ; pc at the start
      dd SRAM_END              ; stack pointer at the start
      db 0xff
      dw 4                     ; the items so far, in words
      db 0
      dd 0                     ; no further block
      dd 0xab123579            ; end marker
  _start:
      ...
  ```

  An Arm program in the flash starts with the **vector table** of the Cortex-M (the stack pointer and the start address
  +1 for Thumb code), behind it the IMAGE_DEF block with `0x1021`.
- **Pico:** its first 256 bytes are a small program that sets up the flash chip (boot2), with its CRC-32 at the end.
  **`.boot2`** puts the block of the Pico SDK there; `.boot2 file.bin` takes one of your own (252 bytes: the CRC is
  added; 256 bytes: it is checked). The vector table follows at `0x10000100`.

Debugging a program in the flash, or one on the RISC-V cores, does not go over the USB cable yet; to step through
RISC-V code, take the ESP32-C3 or the ESP32-S31 (`examples/esp32c3/instructions_riscv.asm`).

## RISC-V in ten minutes

If you know x86 or ARM, these are the differences that matter:

| | x86 | ARM | RISC-V |
|---|---|---|---|
| Registers | 8 (32 bit) | 16 | 32, `x0` is always 0 |
| Flags | yes | yes | **none**: `beq`, `blt` compare and branch in one |
| Memory | many instructions | `ldr`/`str` | `lw`/`sw` (and `lb`, `lh` ...) only |
| Constant of 32 bit | in the instruction | literal pool | `lui` + `addi` (`li` does it) |
| Call | `call` pushes the address | `bl` sets `lr` | `jal ra, ...` sets `ra` |
| Return | `ret` pops | `bx lr` | `ret` = `jalr zero, 0(ra)` |
| Stack | `push`, `pop` | `push`, `pop` | none: `addi sp, sp, -16` and `sw` |
| Instruction length | 1 to 15 bytes | 2 or 4 | 4 (2 for the short forms) |

The F1 help of Asmonite has the topics `riscv`, `registers`, `pseudo` (the short names of the assembler: `li`, `mv`,
`j`, `ret` ...), `encoding` and `compressed`; read them with the cursor on any line of a `.arch riscv32` source. With
`.option rvc` the assembler writes the 2-byte forms where they fit (about a fifth less code; the Hazard3 cores have
C).

## When it does not work

- *No Pico 2 with the Asmonite console is connected over USB* (or Pico): the board is not plugged in, or it has no
  console yet: hold BOOTSEL while you plug it in, then **Prepare Board...** in the Board Manager.
- *This program is for the Pico, but the board ... is a Pico 2* (or the other way round): change `.target` (aBelle:
  the line `target`, or remove it and choose the board under Project > aBelle for).
- *This program is for the flash*: over USB Asmonite debugs programs in the RAM; give it `.imagebase 0x20000000`, or
  run it as a UF2 file (see above).
- Windows shows no new COM port and no drive: the cable may be a charging cable only; try another one.
- The line *Console* of the Board Manager says "older version": **Prepare Board...** writes the console of this
  Asmonite, the files stay.

## What is not (yet) there

- Debugging over USB: programs in the RAM only, on core 0 of the Arm cores. Programs in the flash and on the RISC-V
  cores of the Pico 2 run as UF2 files.
- The examples in assembly that drive the LED (`blink`) use GPIO 25: the Pico W and the Pico 2 W have their LED at the
  WiFi chip, which only the console drives (`led()` in aBelle).
- Variables of a C or Pascal program are not shown: the debugger works with assembler and aBelle source.

## Further reading

- RP2040 and RP2350 data sheets (the memory map, the peripherals, the boot ROM): datasheets.raspberrypi.com
- The RISC-V specification (unprivileged and privileged): riscv.org/specifications
- Hazard3 documentation (the RISC-V core of the RP2350): github.com/Wren6991/Hazard3
