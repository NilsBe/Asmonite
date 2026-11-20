# The Raspberry Pi Pico and Pico 2 with Asmonite

How to write a program in RISC-V or Arm assembler, run it on a Raspberry Pi Pico or Pico 2 and look at it while it runs. You need no other tool: Asmonite assembles the program, writes it to the board over the debug probe and lets you step through it. The instruction reference is the F1 help of Asmonite (`help\en\riscv.md`). The Pico (RP2040) comes first; most of the guide is then about the Pico 2 (RP2350) and its RISC-V cores, and the steps of [Running and debugging](#running-and-debugging) are the same for both boards.

## What you need

- a **Raspberry Pi Pico** or a **Raspberry Pi Pico 2** (not the W models: there the LED sits on the wireless chip)
- a **debug probe** with CMSIS-DAP: the Raspberry Pi Debug Probe, or a second Pico with the `debugprobe` firmware. Three wires go to the debug pins of the board (SWCLK, GND, SWDIO); the board gets its power over its own USB cable.
- Windows with Asmonite. The probe needs no driver; Windows takes it as a WinUSB device.

Only one program can use the probe at a time: if OpenOCD or another debugger runs, close it (or choose OpenOCD in *Debug > Debug targets*, a backup for the RISC-V cores).

## The Raspberry Pi Pico (RP2040)

The first Pico has an RP2040 with two Arm Cortex-M0+ and no RISC-V. Asmonite debugs its core 0 over the same probe and the same three wires. The examples are in `examples\pico\`: `blink_ram.asm` (in the RAM) and `blink_flash.asm` (in the flash; it starts by itself after a power cycle).

**Without a probe:** the Pico can also be debugged with its USB cable alone, over its USB boot (BOOTSEL): a program in the RAM, with breakpoints and steps, without pause. That is in [picoboot.md](picoboot.md). The Pico 2 cannot do this (its USB boot has no command to run a debugger): it needs the probe.

```asm
.target pico            ; for the Raspberry Pi Pico (RP2040)
.arch thumb
.imagebase 0x10000000   ; the flash
    .boot2              ; the boot2 block of the Pico SDK
vectors:
    dd 0x20042000       ; vector table at 0x10000100: stack pointer
    dd _start + 1       ; and start address (+1: Thumb code)
_start:
    ...
```

| What | Address |
|---|---|
| Flash (2 MB) | `0x10000000` |
| RAM (264 KB) | `0x20000000` to `0x20041FFF` |
| Peripherals, SIO | `0x40000000`, `0xD0000000` (the same as on the Pico 2) |

What is special about it (the Pico 2 follows below):

- **Fewer instructions.** The Cortex-M0+ knows the ARMv6-M: Thumb with the 16-bit instructions, of the 32-bit ones only `bl`, `msr`, `mrs` and the barriers. There is no `movw`/`movt`, no `cbz`, `cbnz`, `it`; most instructions work on `r0` to `r7` only. A 32-bit constant comes from a word behind the code (`ldr r0, label`). With `.target pico` the assembler reports every other instruction as an error with its line.
- **boot2 instead of IMAGE_DEF.** The boot ROM of the RP2040 starts a flash program only if its first 256 bytes are a small program that sets up the flash chip, with its CRC-32 at the end. **`.boot2`** puts the block of the Pico SDK there (the file `boot2\boot2_w25q080.bin`, or the same bytes built into Asmonite); `.boot2 file.bin` takes a block of your own (252 bytes: the CRC is added; 256 bytes: it is checked). The vector table follows at `0x10000100`.
- **The pads are not isolated** after a reset: the program needs no `ISO` bit.
- **Breakpoints:** 4 hardware breakpoints, in the flash only; in the RAM the debugger writes `bkpt` instructions instead, which the memory view does not show.
- *Debug > Debug targets > Raspberry Pi Pico (RP2040)* and *Test the connection*, then F7 as in [Running and debugging](#running-and-debugging); *Save as UF2 file* writes the family of the RP2040.

A program for the Pico at a Pico 2 (or the other way round) is refused with the name of the board before anything is written. If the cores of the RP2040 do not answer after such an attempt, Asmonite resets them through the rescue port of the chip.

## The Pico 2 (RP2350) in short

The RP2350 on the Pico 2 has two processors of each of two kinds: two Arm Cortex-M33 and two RISC-V cores (Hazard3). At start-up the boot ROM chooses which pair runs, from the program in the flash. Asmonite writes programs for both: for the RISC-V cores (`.arch riscv32`, RV32IMAC with the bit manipulation extensions) and for the Arm cores (`.arch thumb`, see [The Arm cores](#the-arm-cores)); it uses core 0 of either. To switch without a program of your
own: **RISC-V Cores** or **Arm Cores** in the Board Manager (menu Board) writes the example `blink` of the other cores
into the flash.

| What | Address |
|---|---|
| Boot ROM | `0x00000000` |
| Flash (4 MB, read through the XIP cache) | `0x10000000` |
| RAM (520 KB) | `0x20000000` to `0x20081FFF` |
| Peripherals (UART, GPIO, timers, ...) | `0x40000000` |
| SIO (fast GPIO, spinlocks) | `0xD0000000` |

Peripherals are registers at fixed addresses: you control them with `lw` and `sw`. Their addresses are in the RP2350 data sheet. Each register also answers at three more addresses: +`0x1000` flips the bits you write (xor), +`0x2000` sets them, +`0x3000` clears them, so you need no read-modify-write.

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

The F1 help of Asmonite has the topics `riscv`, `registers`, `pseudo` (the short names of the assembler: `li`, `mv`, `j`, `ret` ...), `encoding` and `compressed`; read them with the cursor on any line of a `.arch riscv32` source. With `.option rvc`
the assembler writes the 2-byte forms where they fit (about a fifth less code; the Hazard3 cores have C): see the
topic `compressed`.

## The first program

`examples\pico2\blink_ram.asm` lets the LED (GPIO 25) blink. In short:

```asm
.target pico2           ; for the Raspberry Pi Pico 2: the bytes of the program, no Windows file
.arch riscv32           ; RISC-V instructions from here on
.imagebase 0x20000000   ; the program is meant to sit in the RAM

_start:
    li   sp, SRAM_END       ; the stack at the end of the RAM
    ...                     ; take the pads and GPIO out of reset, switch pad 25 to the SIO
blink_loop:
    sw   t1, SIO_GPIO_OUT_XOR(t0)   ; toggle the LED
    li   t2, DELAY_COUNT
delay:
    addi t2, t2, -1
    bnez t2, delay                  ; count down: wait
    j    blink_loop
```

`.target pico2` says which device the program is for. Asmonite then checks it after assembling: `.arch riscv32` or `.arch thumb`, an `.imagebase` in the RAM or in the flash, whether the program fits, and for a flash program the IMAGE_DEF block (see below). What does not fit is an error with its line (F1 explains it), before anything is written to the board. When debugging, Asmonite also checks the chip id: if the probe is not connected to an RP2350, it writes nothing.

Constants are defined with `name equ value` (and calculated with `+`, `<<`, `|`); a label is a name with a colon. A `;` starts a comment. Note: label names are not case-sensitive, and the names of x86 instructions (`loop`, `and` ...) cannot be labels.

On the RP2350 one thing is new compared with its predecessor: after a reset the **pads are isolated**; the program clears the bit `ISO` of the pad register (`PADS_BANK0 + 0x68`), else the LED stays dark.

## Running and debugging

1. *Debug > Debug targets > Raspberry Pi Pico 2*: choose **The USB debug probe** and press *Test the connection*. It should say that the board answers (and whether the core is running or halted).
2. Open the program, **F7** (step into): Asmonite assembles it, halts the core, writes the program into the RAM at `.imagebase`, sets the pc to `_start` (or to the first byte) and stops there. **F8** steps over a call, **F9** runs on, **F4** runs to the cursor, **F5** sets or removes a breakpoint, *Debug > Pause* stops a running program.
3. The right-hand side shows the registers `x0` to `x31` (by their names) and `pc`; a double click changes a value. The stack shows the words from `sp`; where a value points into your program, the note names the label and the line (so you see saved return addresses). The memory view has a switch **Bytes / Code**: *Code* lists the instructions from the address (`pc` is the default), with `=>` at the next one and your labels; it also reads code you did not write, in 2- and 4-byte instructions.
4. **Ctrl+F2** (Stop) ends the session; the core runs on with the program.

The blink program only writes to the peripherals: the stack and the memory stay the same. `examples\pico2\stack_demo.asm` fills a table in the RAM and calls a function that puts `ra` and `s0` on the stack; enter `table` as the address of the memory view and step through it with F7.

A program in the RAM is gone when the power goes. The RAM program has no IMAGE_DEF block; the boot ROM would not start it by itself.

### Breakpoints

The core has **4 hardware breakpoints**; each breakpoint in the editor uses one (and so do *Step over* and *Run to cursor* for a moment). They stop before the instruction runs. More than 4 give a message. They also work in the flash, where software breakpoints could not be written.

## A program in the flash

A program with `.imagebase 0x10000000` is written to the flash when you start it. The boot ROM starts a program from the flash only if its first 4 KB hold a small block that says what the program is (IMAGE_DEF); `boards\pico2\blink_flash.asm` has it:

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

- With `.target pico2` the assembler checks the block: it must be in the first 4 KB, and its IMAGE_TYPE must fit `.arch` (`0x1101` RISC-V, `0x1021` Arm).
- **F7 / F9 with such a program** erases and writes only the 4 KB sectors that differ, checks what it wrote, and debugs it in the flash. The first start of a new program takes about a second; an unchanged program is not written again. This needs the USB probe; through OpenOCD the flash cannot be written.
- **Project > Save as UF2 file** makes a file for the BOOTSEL drive: hold the BOOTSEL button while you plug the Pico 2 in, and drag the file onto the drive that appears. The Pico restarts with the program.

## The Arm cores

The same works with the Arm cores: `.target pico2` and `.arch thumb` (the Cortex-M33 knows Thumb code only). `boards\pico2\blink_arm_flash.asm` is the blink program for them. The differences to RISC-V:

- A 32-bit constant is loaded by `movw` (low half) and `movt` (high half) instead of `li`.
- There are flags: `cmp` sets them, `bne` branches on them.
- A program in the flash starts with the **vector table** of the Cortex-M: the stack pointer and the start address (+1: Thumb code); behind it the IMAGE_DEF block with `0x1021` (Arm, Secure) instead of `0x1101`.

Debugging works as with RISC-V (F7, F8, F9, F4, F5) over the USB probe (not through OpenOCD). The right-hand side shows `R0` to `R12`, `SP`, `LR`, `PC`, `XPSR` and its flags `N Z C V`; the core has **8 hardware breakpoints**. If the program starts with a vector table, the debugger sets the stack pointer from it at the start. *Step over* knows `bl` and `blx`.

**The chip runs one kind of cores at a time.** If the other kind runs, the debugger has it write a flash program into the flash, resets the chip and goes on with the cores of the program (this takes about two seconds; the output window says so). A program in the RAM cannot switch: after a reset the boot ROM starts the cores that the program in the flash is for. Asmonite then says what to do: first start a flash program of the right kind, e.g. `blink_arm_flash.asm` or `blink_flash.asm`. *Test the connection* shows which cores run.

## The serial output over the debug probe

The Raspberry Pi Debug Probe has a serial port as well: its second connector, **"U"**, is a UART with a COM port of
its own on the PC (next to the SWD at "D", over the same USB cable). Its cable goes to the board like this:

| Probe, connector "U" | Pico 2, Pico | Blue Pill |
|---|---|---|
| RX (input of the probe; yellow on the cable of the probe) | GP0, pin 1 (TX of UART0) | PA9 (TX of USART1) |
| TX (output of the probe; orange) | GP1, pin 2 (RX of UART0) | PA10 (RX of USART1) |
| GND (black) | GND, pin 3 | G |

When a session over the probe has loaded the program, the tab **Serial** next to the output window connects to that
COM port by itself and shows what the board sends (at the baud rate chosen in the tab, 115200 by default); the
debugger and the terminal do not get in each other's way, Connect and Disconnect stay usable. The examples
`examples/pico2/hello_uart_ram.asm` (RISC-V), `hello_uart_arm_ram.asm` (Arm), `examples/pico/hello_uart_ram.asm`
and `examples/stm32/hello_uart_ram.asm` write "Hello, world!" about once a second at 115200 baud: the RP2040 and
the RP2350 start their 12 MHz crystal for it first (after a reset they run from a ring oscillator, which is not
exact enough for a baud rate), the STM32 runs from its 8 MHz HSI.

The probe sends what it receives only to a terminal that has the line DTR on; the tab Serial does that for it (and
leaves DTR off for the boards of Espressif, where it would reset the chip). In another terminal program: DTR on.

**Without the probe there is no serial port.** The USB port of the Pico and the Pico 2 is a USB controller without a
serial port of its own: the COM port of programs from the Pico SDK comes from a USB stack in the program (TinyUSB),
which an assembler program does not have. A USB serial adapter at GP0 and GND does what the UART of the probe does.

## The console of Asmonite on the Pico 2 and the Pico

As on the ESP32 there is a console for the Arm cores of the Pico 2: `boards/pico2/console.asm`. It is in the
flash, copies itself into the RAM at its start and talks over UART0 (GP0, GP1) at 115200 baud, so over the connector
"U" of the Debug Probe (wired as above).

**Setting it up:** Board > Board Manager, choose the Pico 2 (Debug Probe) on the left, then **Prepare Board**.
Asmonite writes the console into the flash over the probe, in the place of the program there, and makes a file
system when there is none. Then the Board Manager shows the files with the same buttons as for the ESP32: upload a
file, download, delete, run (*Run*: the tab Serial shows what
the program writes), autostart, format. When the console in the flash is not the one of this Asmonite, the line
*Console* says so; Prepare Board writes the new one, the files stay.

**At the prompt** (the tab Serial on the COM port of the probe, Enter): `ls`, `cat name`, `rm name`, `df`,
`format`, `run name [args]` (or the name alone), `boot name`, `boot`, `noboot`, `info`, `reset`,
`wlan`, `help`. Ctrl+C (Stop in the tab Serial) stops a program that runs. After a reset with a program for the autostart
the console waits a second: a key keeps it at the prompt.

**Pico W and Pico 2 W:** the chip does not tell them from the Pico and the Pico 2, so the console asks the WiFi chip
of the board (CYW43439, at GPIO 23, 24, 25 and 29) once at its start: when it answers, the board is a W. The hello
of the console, `info` (the line *board*) and the Board Manager (its title, its photo, the line *Board*) name it. On
a board without WiFi the LED lights for a quarter of a second meanwhile. The console then switches the WiFi chip off;
the LED of a W hangs at that chip, so the examples `blink` do not blink it.

`wlan on` starts the WiFi chip of a W with its firmware: the console reads it from the files `43439A0.bin` and
`nvram_rp2040.bin` in the flash and sends it over the SPI of the chip into its RAM (about 226 KB in 0.6 s), then its
Arm core runs; then the console talks to the firmware in packets (SDPCM, its commands: ioctl and iovar) and gives it
its CLM data (`43439A0_clm.bin`, the channels and the power per country). Prepare Board puts the three files onto a
W (from `wlan\infineon` next to `Asmonite.exe`, unchanged from Infineon, with their license). `wlan off` switches
the chip off, `wlan` tells whether it runs, `wlan scan` lists the networks around (the signal in dBm, the channel,
open or secured, the name). `led()` of the programs switches the LED of a W at the chip.

`wlan set` asks for the name of a network and its password (not shown; Enter alone: an open network) and joins it
(WPA2 with AES). As on the ESP32 the console keeps the name and the key of WPA2 made of the password (PBKDF2, about
2 s), not the password, in the last two sectors of the flash, behind the files; `wlan on` starts the chip and joins
the network again (also after a reset), `wlan` shows it, `wlan clear` forgets it.

**aBelle programs on the network:** `include "inc/net.abel"` (in `abelle/examples/pico2`, after `inc/console.abel`)
gives them ARP, IPv4, ping, UDP, DHCP, DNS and mDNS, `inc/tcp.abel` adds TCP, with the same functions as on the
ESP32; `wifi_connect_saved()` starts the chip and joins the network of `wlan set`. The examples `dhcp`, `ping`, `dns`,
`ntp`, `arpscan` and `httpget` show it: `run ping` in the console or F9 in Asmonite. For this the console has one
function more, `wl_call` (+52, see below; `console_version()` 3): frames sent and received, the MAC, the join;
from `console_version()` 4 also the networks around (`wifi_scan`), from 5 the count of the pings the console
answered (`wifi_pings`). The
chip and the network stay after a program for the next one. `telnetd` is the small shell over telnet of the ESP32
(files, memory, ping, LED; with `passwd set` it asks for a password).

**The console on the network:** after a join it gets an address by DHCP and renews it at half the lease; `wlan` shows
the address, the mask, the router and the DNS server. When the board keeps a network, the console joins it by itself
after its start, once it has waited 3 quiet seconds at the prompt ("WiFi: connected, address ..."; during the 2 to 5
seconds of it the console does not answer, what is typed waits). SysTick looks at the chip every 10 ms and answers
ARP and ping for the board: at the prompt, while a program runs and while it stands at a breakpoint; other frames it
keeps for the program. `name set <name>` gives the board a name for the router (else `pico2w-` and the end of the
MAC), `passwd set` the password for telnet; both stay in the record of the network, also through `wlan set` and `wlan
clear`.

**Programs for the console** run in the RAM: `.target pico2`, `.arch thumb`, `.imagebase 0x20000000` (up to
0x2006FFFF). The console calls `_start` with the text of the arguments in `r0`, on a stack of its own; `bx lr` ends
the program with the code in `r0` ("Program ended (code n)."), and so does `exit` from any depth. A fault in the
program (a read where nothing is) and Ctrl+C end it too; the console says how and goes on. Its functions are a table
of addresses at `0x20078140`, in the order of the ESP32: +0 `exit`, +4 `version`, +8 `put_char`, +12 `get_char`,
+16 `poll_char`, +20 `print`, +24 `millis`, +28 `file_size`, +32 `file_read`, +44 `args`, +48 `led` (the LED of the
board, GPIO 25), +52 `wl_call` (the WiFi of a W, for `inc/wifi.abel`; `boards/pico/console_wifi.asm`). A call loads the address from the table and jumps there with `blx`; `r0` to `r3` are the arguments,
`r0` the result. `examples/pico2/hello_console.asm` shows it. The same functions are also code to call at `0x20079E00`
(16 bytes each, in the same order; the Pico: `0x20039E00`).

**Programs in aBelle** for the console: `target "pico2"` (the Pico: `target "pico"`) and `include "inc/console.abel"`;
`abelle_pico.exe` translates them, F9 runs them over the console, with a breakpoint F9, F7 and F8 debug them (over the
USB cable or the probe), with the variables. Examples in `examples/abelle/pico2` and `examples/abelle/pico`:
`hello.abel`, `blink.abel`. The Pico W and the Pico 2 W have their LED at the WiFi chip: `led()` switches it there
(its first call starts the chip, as `wlan on`).

**F9** debugs the Pico 2 over the probe (SWD), or over the USB cable (see below: debugging over USB). The console
stays in the flash and is there again after the next reset.

**Where things are:** the console in the flash from `0x10000000`, the files from 1 MB to 4 MB less 8 KB (`0x10100000` to
`0x103FE000`, behind them the WiFi network); in the RAM the programs from `0x20000000` to `0x2006FFFF`, the console from `0x20070000`.

**On the Pico (RP2040)** there is the same console: `boards/pico/console.asm`, with the same commands, files and
buttons in the Board Manager (on the left "Pico (Debug Probe)", then **Prepare Board**). The differences:

- Programs: `.target pico`, `.arch thumb` (Thumb-1 only, the Cortex-M0+ has no Thumb-2), `.imagebase 0x20000000`
  (up to 0x2002FFFF); the table of the functions is at `0x20038140`. `examples/pico/hello_console.asm` shows it,
  with a division of its own (the M0+ has none).
- The console in the RAM from `0x20030000`, in the flash behind the 256 bytes of boot2; the files from 1 MB to 2 MB
  less 8 KB (`0x10100000` to `0x101FE000`, the Pico has 2 MB of flash; behind them the WiFi network).
- A fault in a program shows only the exception and the pc (the M0+ has no registers that say more).
- `reset` starts the chip again through the watchdog.

**Over the USB cable:** when the USB cable of the board is at the PC too, the console is a COM port of its own there
("USB Serial Device", VID/PID 1209:0001, the driver of Windows). Its serial number is the chip and the id of the
board (on the Pico 2 from the OTP of the chip, on the Pico the one of the flash chip): each board gets a COM port of
its own, also two of the same kind at one PC. It talks over both at once: what it writes goes to
the UART and over USB, and it takes what comes from either. Files go about ten times as fast over USB. Ctrl+C stops a
program over USB too.

**Without the probe at all:** plug in the Pico with the BOOTSEL button held (or a new, empty one). The Board Manager
shows it in its USB boot; **Prepare Board** puts the console as a UF2 file onto its drive, the boot ROM writes it into
the flash and starts it, and the Board Manager then chooses "Pico (USB console)" or "Pico 2 (USB console)" with its
files. From then on files, Run and F9 (a program in the RAM, without a breakpoint, the tab Serial at that port) go over
the USB cable. **Prepare Board** at the USB console writes a new console without the button: Asmonite sets the port to
1200 baud, the console restarts the chip into its USB boot (as the boards of Arduino), then the UF2 file; the files
stay. **Reset** starts it again.

**Debugging over USB, without the probe:** both consoles hold a debug monitor. When the tab Serial is at the USB
console, or no probe is plugged in and the board is there with its console at USB, and the program is one for the RAM
of the programs (`.imagebase 0x20000000`), F9 with breakpoints (or F7) goes over this monitor: the log says "over the debug monitor of its console". Breakpoints, F7, F8, Run to Cursor, Pause,
Stop, the registers and the memory work as over the probe; the tab Serial shows what the program writes, and after
the session the console waits at its prompt again (Stop ends the program). Without a breakpoint F9 simply runs the
program over the console, as before.

- Pico 2: the Cortex-M33 sends the breakpoints of its FPB (7 for Asmonite) and the single steps into the exception
  DebugMonitor. It runs below the priority of the USB interrupt, so the connection stays open while the program
  stands.
- Pico: the Cortex-M0+ has no such exception. Asmonite writes a `bkpt` into the program for each breakpoint and each
  step (only while it runs); the HardFault of a `bkpt` leads into the monitor (through PendSV, at the lowest
  priority).
- The program runs as the console starts it: on its stack, with its functions; `bx lr` at the end reports "The
  program ended: code n".
- A program that keeps all interrupts off cannot be paused meanwhile. Programs for the flash and the RISC-V cores of
  the Pico 2 are still debugged over the probe; so is everything when the probe is plugged in and the tab Serial is
  not at the console. Without the probe and without a console that fits the program, F9 says what to plug in (also
  when the program is for the Pico and the board is a Pico 2, or the other way round).
- If the probe still holds the core as a debugger (after an SWD session that did not end cleanly), the monitor of the
  Pico 2 refuses and says so: unplug the board once and plug it in again.

**Limits:** 115200 baud only over the UART; on the Pico 2 the Arm cores only. When a terminal opens the COM port of the probe while
the board sends without a pause, the characters come garbled until the first pause: a quirk of the probe.

## A USB device without the SDK

`examples/pico/usb_echo_ram.asm` (Pico) and `examples/pico2/usb_echo_ram.asm` (Pico 2, Arm cores) make the board a
COM port on the PC over its own USB cable (USB CDC-ACM), all in assembler, without the Pico SDK and without TinyUSB.
The code for both is in `examples/pico/usb_cdc.asm`; the two files only set `CHIP` and take it with `.include`.

How it goes: the debug probe at SWD, **and** the USB cable of the board to the PC, then F9. Windows 10 and 11 show a
new COM port (Device Manager, "Ports (COM & LPT)"; driver `usbser.sys`, nothing to install). Open it in the tab
Serial or any other terminal, the baud rate does not matter: the board greets you, and what you type comes back,
Enter as a new line.

The id 0x1209/0x0001 is the test number of pid.codes: for tests on your own desk only. A device that others get needs
one of its own.

## When it does not connect

*Test the connection* says why, in clear words:

- *No debug probe ... only one program at a time*: another program has the probe (OpenOCD, another instance of Asmonite). Close it.
- *The board does not answer over SWD*: the board has no power, the three wires are wrong or loose, or the probe is not the Debug Probe. The wires: SWCLK, SWDIO, GND.
- With **OpenOCD** chosen: start OpenOCD first; the host is `127.0.0.1` and the port `3333`.
- *The board is an RP2040 ...* (or *not an RP2350*, *no RP2040*): the board at the probe is not the one of `.target`. Asmonite wrote nothing; choose the right entry in *Debug targets* or the right `.target`.
- *Cannot write the program ... the board needs the program in RAM*: the program has an `.imagebase` that is neither RAM (`0x20000000`) nor flash (`0x10000000`).

## What is not (yet) there

- The assembler writes only 4-byte instructions. The short instructions (`c.addi` ...) are read and shown, not written.
- No floating point, no atomic instructions `lr.w`/`amo*` on the debugger side (the assembler writes them, the core runs them).
- Core 0 only; no second core, no multi-core debugging.
- The W models (Pico W, Pico 2 W): their LED is on the wireless chip, which the examples do not drive (the console
  only asks the chip whether it is there).
- Variables of a C or Pascal program are not shown: the debugger works with assembler source.

## Further reading

- The RISC-V specification (unprivileged and privileged): riscv.org/specifications
- RP2350 data sheet (the memory map, the peripherals, the boot ROM): datasheets.raspberrypi.com
- Hazard3 documentation (the core: instructions, debug module, CSRs): github.com/Wren6991/Hazard3
