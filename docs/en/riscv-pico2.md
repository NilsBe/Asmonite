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

The F1 help of Asmonite has the topics `riscv`, `registers`, `pseudo` (the short names of the assembler: `li`, `mv`, `j`, `ret` ...), `encoding` and `compressed`; read them with the cursor on any line of a `.arch riscv32` source.

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

A program with `.imagebase 0x10000000` is written to the flash when you start it. The boot ROM starts a program from the flash only if its first 4 KB hold a small block that says what the program is (IMAGE_DEF); `examples\pico2\blink_flash.asm` has it:

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

The same works with the Arm cores: `.target pico2` and `.arch thumb` (the Cortex-M33 knows Thumb code only). `examples\pico2\blink_arm_flash.asm` is the blink program for them. The differences to RISC-V:

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
- The W models (Pico W, Pico 2 W): their LED is on the wireless chip, which the examples do not drive.
- Variables of a C or Pascal program are not shown: the debugger works with assembler source.

## Further reading

- The RISC-V specification (unprivileged and privileged): riscv.org/specifications
- RP2350 data sheet (the memory map, the peripherals, the boot ROM): datasheets.raspberrypi.com
- Hazard3 documentation (the core: instructions, debug module, CSRs): github.com/Wren6991/Hazard3
