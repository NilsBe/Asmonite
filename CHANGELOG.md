# Changelog

What changed from version to version. German: [docs/de/aenderungen.md](docs/de/aenderungen.md).

Version numbers: MAJOR.MINOR.PATCH. While MAJOR is 0, a MINOR step may change what
existing sources mean; such changes are listed under "Changed" and marked **(sources)**.

## 0.8.0 – 2026-11-04

### New
- **Raspberry Pi Pico 2 and Pico: assemble, flash and debug, without OpenOCD.** Asmonite drives a CMSIS-DAP debug probe (the Raspberry Pi Debug Probe) itself over USB (`CmsisDap`): F7 loads a program into the RAM (`.imagebase 0x20000000`) or **writes it into the flash** (`.imagebase 0x10000000`: through the functions of the boot ROM, only the sectors that differ, read back) and stops at `_start`; steps, step over, run to cursor, pause, breakpoints, registers (editable), stack with notes, memory as **bytes or as code** (the new switch *Bytes / Code*). *Project > Save as UF2 file (Raspberry Pi Pico)* writes the file for the BOOTSEL drive with the family of the chip. *Debug > Debug targets* has the entries *Raspberry Pi Pico 2 (RP2350)* and *Raspberry Pi Pico (RP2040)*, each with *Test the connection*. The guide `docs/en/riscv-pico2.md` explains it step by step.
- **The RISC-V cores of the Pico 2 (Hazard3).** `.arch riscv32`: RV32I, M, A, Zicsr, Zifencei, the pseudo instructions `li`, `la`, `mv`, `j`, `ret`, `call` ... and the bit manipulation sets Zba, Zbb, Zbs, Zbc, Zbkb. The debugger works through the debug module of the chip (`RvDebugModule`, `RvLink`): registers `x0`..`x31` and `pc`, 4 hardware breakpoints. OpenOCD (host and port of its GDB server) stays as a backup for these cores; the connection wakes up the debug port that OpenOCD leaves dormant.
  - The disassembler `dis_riscv` also reads the compressed instructions (C, Zcb); checked against capstone (all 16-bit codes and 200,000 random words: no difference, `tools/riscv_check.py`).
  - Editor: syntax colours for `.arch riscv32`; F1 help `help\<lang>\riscv.md` (every instruction, the registers, the pseudo instructions, the instruction forms).
- **The Arm cores of the Pico 2 (Cortex-M33).** `.arch thumb` with `.target pico2`; F7/F9 debug over the USB probe (`CmCore`, `CmLink`, `CmFlash`): registers `R0`..`R12`, `SP`, `LR`, `PC`, `XPSR` and the flags `N Z C V` (editable), 8 hardware breakpoints, step over `bl` and `blx`, the memory view shows Thumb code; the stack pointer comes from the vector table.
  - The chip runs one kind of cores at a time. If the other kind runs, it writes a flash program into the flash and the chip is reset (the boot ROM starts the cores the program is for); a RAM program gets a message what to do. *Test the connection* says which cores run.
- **The Raspberry Pi Pico (RP2040, Cortex-M0+).** `.target pico` (also `rp2040`) allows the instructions of the ARMv6-M only (of the 32-bit ones `bl`, `msr`, `mrs`, the barriers; no `cbz`, `cbnz`, `it`); adr/ldr with a label further down take the 16-bit form first. The debugger reaches core 0 on the multidrop SWD bus (TARGETSEL) through the MEM-AP of ADIv5: 4 hardware breakpoints in the flash, software breakpoints (`bkpt`) in the RAM, which the memory view does not show. Cores that no longer answer are brought back through the rescue port of the chip.
  - **`.boot2`** puts the boot2 block of the Pico SDK at the start of a flash program (the file `boot2/boot2_w25q080.bin`, BSD-3-Clause, or the same bytes built in); `.boot2 file.bin` a block of your own (252 bytes and the CRC-32 is added, or 256 and it is checked).
- **`.target pico2`** (also `rp2350`) and **`.target pico`** say which board a program is for: the output is a flat binary, and after assembling the program is checked (errors with the line, F1 `err-target`): the `.arch`, `.imagebase` in the RAM or the flash and the program fits; on the Pico 2 an IMAGE_DEF block in the first 4 KB whose IMAGE_TYPE fits the `.arch`, on the Pico the boot2 block with its CRC-32; an Arm flash program starts with its vector table (Thumb bit). Without `.target`, `.arch thumb` with `.format binary` gives a warning. Before it writes anything, the debugger reads the chip id and refuses a program for the other board with its name.
- Examples: `examples/pico2/` (`blink_ram.asm`, `blink_flash.asm` for RISC-V; `blink_arm_ram.asm`, `blink_arm_flash.asm` for Arm; `stack_demo.asm`) and `examples/pico/` (`blink_ram.asm`, `blink_flash.asm`). The flash programs start by themselves after a power cycle.
- Tests: `rvtest` (assembler, disassembler, UF2, highlighter), `regedittest` (Cortex-M registers), cases `riscv_*` and `target_*`, `anatest` (help); with a board: `rvdbgtest` (31 checks, `usb` for the direct way), `rvdmtest`, `rvflashtest`, `cmdbgtest` (37 checks on the Pico 2, both switches of the cores; `cmdbgtest pico` 38 checks on the Pico).
- The debug views (registers, stack, memory) change their rows in place and flicker less.
- Dismonite: **PE files for the old ARM** (Machine 0x01C0: the ARM instruction set of before Thumb-2, as Windows CE used it) open and are decoded: the code from the entry point is ARM (A32, the decoder of the ARM ELF files), the export writes the code as bytes with the instruction as comment (it cannot be assembled as instructions: Asmonite has no A32 assembler). Before, such a file showed no code at all. The status line says "old ARM (Windows CE): ... no Windows PC runs it", and the check before running names the old ARM ($1C0 / $1C2) as a type no Windows PC runs. The page `winarm.html` has a table of the ARM file types (ARM64, ARM32 Thumb-2, the old ARM, ARM64EC/X) and what Asmonite and Dismonite do with each. Case in `anatest` (`pe_oldarm_example.exe`, made with fasmarm). Tools: `tools/pe_scan.c` (native scanner for the PE files of a drive) and `tools/pe_stats.py` (statistics of the machine types).

## 0.7.6 – 2026-10-30

### New
- Examples: `examples/windows_intel/if_x64.asm`, `examples/windows_arm/if_arm64.asm` and `if_arm32.asm` use `if` / `else` for several kinds of conditions; each ends with the exit code 31 (run on a real Windows on ARM machine for the ARM ones).
- Assembler, Thumb (`.arch thumb`): **`if` / `else` / `endif` and `do` ... `while`** work like in arm64 (`bne`, `blt` ..., `tst`, a number gets its `#`, no memory operands). Cases `thumb_*`, also with blocks of 130 instructions.
- Assembler, arm64: **`if` / `else` / `endif` and `do` ... `while`** work in `.arch arm64` source with the same words and rules (`if w0 == 5`, `if signed x1 < x2`, `if zero`, `if x3 & x4`, `do ... while not zero`, nested): the jumps are `b.cond`, `if a & b` is `tst`, a number gets its `#`; there are no memory operands and no `parity`; Thumb / ARM 32 is still an error. Cases `a64_*`; the editor colours the words in arm64 source. Not run on a device yet.
- Assembler, x64: **`if` / `else` / `endif` and `do` ... `while`** now work in `.arch x64` source with the same words and rules as in i386 (`if rax == rbx`, `if signed eax < r8d`, `if zero`, `if eax & ebx`, `do ... while not zero`, nested); `func` and `call Name(args)` stay i386 only, in ARM source `if` still reports an error. The jumps forward use the long form (rel32). Cases `x64_if_*`, `x64_do_while_*`, `x64_compare_default`, `x64_error_*`.

### Fixed
- Assembler, Thumb: a **forward branch that does not reach in the short form becomes the wide form by itself** (another pass runs); before, the instruction had to be written with `.w` ("the branch does not reach its target in this form").
- Assembler, x64 and Thumb: the sizes of the lines (kept from pass 1 for pass 2) were indexed by the source line; with generated lines (`if`, `else`, `do`, `func`) several lines share a source line and the sizes got mixed up (error "the instruction does not have the size it had in pass 1"). They are indexed by the generated line now.

## 0.7.5 – 2026-10-28

### New
- Dismonite: **export with `call Name(args)`** (File menu, *Export with call Name(args)*, saved in `Dismonite.ini`; `DismoniteC --calls`). In a 32-bit Windows program the `push` instructions right in front of a call are written as the arguments of the call: `push 3` / `push eax` / `call near Fatal` / `add esp,8` becomes `call cdecl Fatal(eax, 3)`. Which pushes belong to the call: an `add esp, 4*m` behind it says cdecl and m arguments; a direct call of a label whose code ends in `ret 4*n` is stdcall with n arguments; a `call [Import]` of a Windows function that `help\<lang>\winapi.md` knows with its number of parameters is stdcall with that many. Anything else stays (the pushes could belong to something else); a run of pushes ends at a label, a comment line or a push that is no number, register, label or dword. Only where the assembler makes the same bytes: the file is assembled and compared, else it is written without (the dialog says so). It can be used together with the `if` export. In the 32-bit dcc32 1,832 calls (the file comes back byte for byte together with the 10,224 ifs and loops), in Dism.exe 542 of 4,091, in OpenWith.exe 205, in PkgMgr.exe 304. Unit `DisCallExport`; cases in `anatest` (`CallExportText`) and the round trip of `wste1.exe` with `--if --calls`.

- Assembler, i386 (also `.arch x86_real`): **a character in quotes is a number in an instruction**: `mov al, '0'`, `cmp al, '9'`, `add al, "A"`, `push 'x'`, `mov eax, 'abcd'` (up to four characters, the first one in the lowest byte, as NASM does); both quotes work, `db` keeps its strings. Case `char_immediate`.
- Assembler, i386: **`loop`, `loope`, `loopne`, `jecxz` and `jcxz` take a label without `short`** (they have no other form; a label out of reach is an error as with `short`). Cases `loop_label`, `loop_label_far`.
- Examples: `examples/dos/tick.asm` counts in `ebx` and prints it every second from a hook of the timer interrupt 08h (the handler sees the registers of the counting loop); `examples/windows_intel/tick_i386.asm` does the same for Windows with a second thread that reads `ebx` with `GetThreadContext`; `examples/func/func_fact.asm` is the factorial.

### Fixed
- Assembler: **`call Name(0x1B)`**: a hexadecimal number that ends in `B` as the only argument (`(0x1B)`, `(0xB)`) was read as a number with the binary suffix and refused (*unexpected token*).

## 0.7.4 – 2026-10-26

### New
- Dismonite: **`if` on the flags and `do ... while` in the listing and in the export** (the same rules as in Asmonite since 0.7.3). A conditional jump forward to a label that only it uses, with no `cmp` / `test` in front that gives a condition, is written as `if zero`, `if not below` ... (`dec ecx` + `jnz` over the block is `if zero`); a conditional jump **back** to a label that only it uses is a loop: the label becomes `do`, the jump `while <condition>` (cmp + `jnz` is `while a != b`, `dec ecx` + `jnz` is `while not zero`). Loops and ifs nest; the listing shows `; do` at the label, `while ...` / `back to do` at the end and indents the body. In the 32-bit dcc32: 9,090 `if` (1,035 of them on the flags) and 1,134 `do ... while`; the export comes back byte for byte. The export tries all of it first, then only the ifs with flags, then only the ifs with `cmp` / `test`, and keeps the first that gives the same bytes. `DismoniteC --if-dump <prefix>` saves each try as a file (a test aid).

### Fixed
- Assembler, i386: **jumps without `short` / `near` start short and become long only where they do not reach** (before: they started long and became short where they fit, which leaves jumps long that can only be short together: two jumps that go over each other, a loop and the jump over it). The result is the shortest layout, as a compiler has it. Cases `jump_short_together`, `jump_short_back_edge`.

## 0.7.3 – 2026-10-26

### New
- Asmonite, i386: **`if` on the flags** and **`do ... while`**. `if zero`, `if not carry`, `if below or equal` and so on need no comparison: the flags of the instruction in front count and only the jump around the block is written (`dec ecx` / `if zero` is `jnz` over the block). The words: `zero` (`equal`), `carry`, `sign`, `overflow`, `parity`, `above` / `below` (unsigned), `less` / `greater` (signed), `not` in front, `or equal` behind the last four. **`do` ... `while <condition>`** runs the block once and then as long as the condition holds: the condition has the forms of the `if` (a comparison with `signed` / `unsigned` or `.compare`, `a & b`, a flag word) and the jump back to the `do` is the condition itself (`while not zero` is `jnz`, `while signed eax < 10` is `cmp` and `jl`). The label at the `do` is made by the assembler (`asmogen_do<line>s`). Loops and ifs nest; one that is closed in the wrong place is an error (`endif without if (the open block is the do in line 3, while is missing)`). `do` and `while` cannot name a func, a parameter or a local; they have the colour of the syntax. Example `examples/func/func_loop.asm`, cases `func_if_flag_*` and `func_do_*`; the page `if.html` has sections for both.
- Asmonite, i386: **`if a & b`** tests bits: `if eax & ebx` is `test eax, ebx` and the jump around the block when no bit is set in both, `if eax & ebx == 0` runs the block when none is, `if eax & ebx != 0` is the same as `if eax & ebx`. A register, a number or memory (`if byte [ebx] & 1`, `if al & 0x80`); `test` has no register-against-memory form, the operands are swapped. No `signed` / `unsigned` with it, nothing but `== 0` / `!= 0` behind it. Cases `func_if_test*.asm`; the page `if.html` has a section for it.- Dismonite: **export with `if` / `else` / `endif`** (File menu, *Export with if / else / endif*, saved in `Dismonite.ini`; `DismoniteC --if`). In a 32-bit Windows program a `cmp` or `test` with the conditional jump behind it that goes forward to a label that only this jump uses is written as `if a == b` ... `endif` (the jump of the opposite condition: `jne` is `==`, `jl` is `if signed a >= b`, `jbe` is `if unsigned a > b`, `test` + `jz` is `if a & b`); a `jmp` to a label that only it uses at the end of the block gives `else`; blocks are indented by two blanks. Only where the assembler makes the same bytes of it: the file is assembled and compared, else it is written without (the dialog says so); jumps that the program has as `near` stay as they are. In the 32-bit dcc32 (19,663 conditional jumps) 8,055 become an `if` and the file comes back byte for byte. Unit `DisIfExport`.
- Dismonite: **export with `if` / `else` / `endif`** (File menu, *Export with if / else / endif*, saved in `Dismonite.ini`; `DismoniteC --if`). In a 32-bit Windows program a `cmp` or `test` with the conditional jump behind it that goes forward to a label that only this jump uses is written as `if a == b` ... `endif` (the jump of the opposite condition: `jne` is `==`, `jl` is `if signed a >= b`, `jbe` is `if unsigned a > b`, `test` + `jz` is `if a & b`); a `jmp` to a label that only it uses at the end of the block gives `else`; blocks are indented by two blanks. Only where the assembler makes the same bytes of it: the file is assembled and compared, else it is written without (the dialog says so); jumps that the program has as `near` stay as they are. In the 32-bit dcc32 (19,663 conditional jumps) 8,055 become an `if` and the file comes back byte for byte. Unit `DisIfExport`.
- Dismonite: **if / else / endif in the listing** (menu Analyze, *Show if / else / endif in the listing*, on at the start, saved in `Dismonite.ini`). The places the export would write as `if` get a comment: the `cmp` / `test` row says `if eax == 0x10`, the jump `if not: to endif` (or `to else`), the jump that ends the then part `then part done: to endif`, the label `; else` / `; endif`; the code of a block stands two characters further to the right per level. Only a view: every instruction keeps its row, its address, its bytes and its breakpoint, the debugger steps as before; the listing, the search and the export are the same. The rule is the one of the export (a label that only this jump uses, nested blocks), found per function; the entry code in front of the first function too. About 1.4 s more for all 338,000 rows of the 32-bit dcc32; where a jump is written `near` in the export the listing shows the block too.

### Changed
- Dismonite, debugger: the two windows at the bottom changed places: the output of the program is on the left, the memory on the right (fixed width, enough for a row of 16 bytes and the text; the splitter moves it).

### Changed
- Assembler, i386: jumps without `short` / `near` are made short in **rounds** until nothing changes. Before, one decision was made from the distances of the first pass, so a jump over other jumps that only become short stayed long (`jmp x` over twenty `jne`: 5 bytes instead of 2). Now the result is the shortest one, as with other assemblers; a file with many such jumps is assembled a few times (about 16 s instead of 7 s for the 231,000 lines of a disassembled dcc32). Case `jump_relax_rounds`.

### Fixed
- Assembler, i386, two errors with jumps that are made short automatically (`jmp x` / `jne x` without `short`): (1) an instruction that asm_x86 hands to the other encoder (x87 such as `fld tword [label]`, and others) took the address of a label further down from the first pass, before the jumps were shortened: wrong address in the code; (2) a `jmp short` over jumps that are made short later got the error "error with bdo" although it reaches in the end. Found when rebuilding the 32-bit dcc32 from its `if` form. Cases `jump_short_fpu_label`, `jump_short_over_shortened`.

## 0.7.2 – 2026-10-23

### Changed
- `conwatch.exe` (the helper that mirrors the console of the debugged program) has version information now and imports `AttachConsole` normally: fewer false alarms of virus scanners (machine-learning verdicts).

## 0.7.1 – 2026-10-23

### Changed
- The ZIP no longer holds the example programs (`.exe`) of `examples\windows_intel`, `windows_arm`, `func`, `x64`, `arm64` and `winarm`: virus scanners reported tiny hand-made programs falsely. The sources are there; F9 in Asmonite builds the programs. `examples\dos\HELLO.EXE` (for Dismonite) stays.

## 0.7.0 – 2026-10-23

### New
- Assembler: **expressions, `equ`, `$` and `$$`**. Wherever a number stands the assembler calculates: `* / % + - << >> & ^ | ~` and brackets, numbers as `0x1F`, `1Fh`, `101b`, `'A'`. `name equ expression` defines a constant (also behind its use), `$` is the address of the line, `$$` the start of the section, and the **difference of two labels** is a number: `mov ecx, end-start`, `len equ $-msg`. The constant part of a memory operand is calculated too (`[ebx+2*4]`). A difference of labels needs the addresses, so the assembler runs again until they stay the same. Done by a pass over the source (`src/cpu/asm_expr.pas`) before the core, for all architectures; everything that is not an expression stays as it was. Also new in the core: a number behind a label as a value, `mov eax, table+4`, `push table-4`, `dd table+4` (jump and call: error).
- Asmonite, i386: the words of the `func` and `if` syntax (`func begin end var uses cdecl stdcall if else endif signed unsigned`) cannot be the name of a func, a parameter or a local (an error, as the help always said for registers, instructions and keywords); labels and data names are not affected. Cases `func_error_keyword_*`.
- Asmonite, i386: **`if` / `else` / `endif`** with a direct comparison: `if ebx == [0x04+eax]` ... `endif` is `cmp` and the jump of the opposite condition around the block (no label of your own); `else` is supported, ifs nest, it works anywhere in i386 code and in a func (its names work in the comparison). One comparison, no expressions: `==`, `!=`, `<`, `<=`, `>`, `>=`; the four ordered ones say **`signed`** or **`unsigned`** (`if unsigned eax < ebx` is `jae`, `if signed eax < ebx` is `jge`), without the word it is an error, unless **`.compare signed`** / **`.compare unsigned`** stands in front of it (for all ifs behind it, until the next `.compare`; `.compare none` takes it back; a word in the `if` line wins). The debugger runs the `if` line (`cmp` and the jump) as one step. Example `examples/func/func_if.asm`, cases `func_if_*.asm`.
- Asmonite and Dismonite, debugger: **change registers and flags** of the paused program, for x86 (Windows, DOS), x64, ARM / Thumb and ARM64. **Double click** (or **F2**, **Enter**) on a register opens a small dialog with its value; a **flag** (CF, ZF, N, Z, T ...) is toggled by double click or **Space**; the context menu has *Change value...*, *Toggle flag*, *Set to 0* and *Copy value*. The value is hex (`1F`, `0x1F`, `$1F`, `1Fh`), decimal with `#` (`#31`), a character (`'A'`) or an expression of values and register names with `+` and `-` (`esp+8`, `r0-#1`); a value that does not fit the register, or an unknown word, stays in the dialog with the reason. A new `EIP` / `RIP` / `PC` moves the program: the editor and the view show the new place like a stop ("set next instruction"). In Dismonite a double click on a register that points into the program still goes there; change it with F2 or the menu. The changes go to the program when it goes on (Windows: `SetThreadContext`; the debug servers and QEMU: the `G` packet). The same code serves both programs (`DbgRegEdit`, `DbgRegDlg`).
- Dismonite: **arguments and locals found in more functions**, and told more. The functions of Microsoft compilers that start with `mov edi,edi` (hot-patch prefix), 16-bit functions (`push bp / mov bp,sp`: the arguments are 2-byte slots from `[bp+4]`, from `[bp+6]` in a far function that ends with `retf`; `[word 0xFE7E+bp]` is a negative displacement), and functions that are only jumped to (a label at the `push ebp`) now get the hints `arg1` / `loc1`. Locals that overlap (a `byte [ebp-7]` inside the `dword [ebp-8]`) are one variable (`loc2+1`), the frame size is read from `sub esp,N` / `add esp,-N` / `push ecx`. The summary at the `push ebp` says more: `stdcall, 2 args, 3 locals, frame 0x10`; the convention (`stdcall`, `cdecl`, `pascal`, `far`, `register`) comes from `ret N` and the arguments, **registers that are arguments** (`eax`, `edx`, `ecx` read before they are written, Delphi `register`, fastcall, thiscall) are named (`register, regs eax edx ecx, 1 stack args, ...`), and the store of such a register in a local reads `loc2 = ecx`. Only comments: the export gives the same bytes. In the 32-bit Notepad 0 of 6894 `[ebp+x]` operands had a hint before, now 94 %; in a DOS compiler (TPC) 0 of 1060, now 71 %.

## 0.6.0 – 2026-10-22

### New
- Asmonite: **new window layout**: registers, stack and memory stand one below the other in a column on the right over the whole height (only while a program is debugged; each block can be switched in the View menu, the column goes when all three are off), the code and the output window on the left. Sizes and blocks are saved in `Asmonite.ini`. Memory shows 8 bytes per row in a narrow column, 16 in a wide one, and the stack (`esp`) when nothing is entered.
- Asmonite, debugger: **Step Over on `call Name(args)` and `call [printf](args)`** runs the whole line in one step (the call and the clean-up behind it), and does not step into a func when the line has arguments to push.
- Asmonite: **the convention of an import** in `call [name](...)`: the `.import` line says it for its names: `.import msvcrt.dll cdecl printf`, then `call [printf](fmt, 42)` cleans up the stack (`add esp, 8`); without the word an import is stdcall. For a C runtime dll (`msvcrt.dll`, `ucrtbase.dll`, `api-ms-win-crt-*`) the word is required: a call with arguments without it is an error. `call cdecl [name](...)` or `call stdcall [name](...)` decides for one call. Example `examples/func/func_printf.asm`.
- Dismonite, DOS programs (MZ): **constants and displacements in the code** can be said to be offsets, with the same keys as the words of a table: on an instruction **L** (offset of code), **Shift+L** (offset of data), **X** (a number). The label of the target shows in the operand (`mov bx,C0000_9C2A`, `jmp [cs: word L0000_085A+bx]`), the code behind a code offset is certain and followed, and the export writes the label too (checked by the assembler, bytes identical). Data named by a constant is in the **data segment**: the paragraph that DS holds, found from the entry code (`mov ax,0x10D0 / mov ds,ax`) or set in DOS > Data segment (saved as `dataseg`); with `cs:` the target is in the code segment. An instruction with two fields: the displacement (unless it is a plain `[0x1788]`), else the constant. Saved as `ref <offset> operand <role>`; Del takes the decision of the instruction back first.
- Dismonite: **the marks of the user in the gutter**: a bar in front of the address (blue: an item, green: the start of a run, purple: a decision about an address). The mouse in the gutter tells what the mark is (the kind and size, the run with its limits, the decision and its target, your name for the label) and what Del will take back.
- Dismonite: **strict marks over several bytes** (what you type; reading a .dmon file is not checked): a word, dword or qword is refused (with a beep and the reason in the status line) if a label would be inside it (a label at its first byte is fine), if another mark of yours would be covered, or if a field of the file format is inside; ascii and UTF-16 end in front of the next label or the next mark of yours. The item you re-mark itself may be replaced, a run of B/W/D/Q ends in front of a mark of yours that it does not make itself.
- Dismonite: a click in the gutter (the column with the addresses) sets a breakpoint on that item or takes it away, like F5.
- Dismonite, DOS programs (MZ): **manual marking**. Menu DOS > Manual marking (saved as `manual` in the .dmon file): the program marks the code that is *certain* by itself - everything that the flow, calls and jumps lead to from the entry point, from the code you marked and from the words you said are offsets of code - and does it again after every decision of yours (what you took back goes again). Nothing else is analyzed; what is left (what only a table or an indirect jump leads to, data, the rest) is yours: **Ctrl+F5** / **Ctrl+Shift+F5** jump to the next / previous place to decide, the status bar counts them. **C** marks code (its calls and jumps are followed at once), **L** / **Shift+L** / **X** say that the word at the cursor is an offset of code / of data / a number (saved as `ref <offset> word code|data|number`; a byte becomes a word), and the status line tells at once what the target is: start of an instruction, start of data, not marked yet, in the middle of an instruction or data item (no label possible), outside of the segment or the file. **Del** takes the decision back first, then the mark of the word. What the commands of the Analyze menu mark (tables, strings) are only suggestions with orange bytes until you accept them (**Ctrl+Y** the one at the cursor, DOS > Accept all suggestions). DismoniteC follows the certain code of a document with `manual` the same way.
- Dismonite: **Ctrl+F4** / **Ctrl+Shift+F4** (menu Go) jump to the next / previous place where code and data change: forward to the start of the next run of items of the other kind (code: instructions, data: everything else), backward to the start of the run you are in, or - at its start - of the run before.
- Dismonite: **Del** takes the mark of the item under the cursor back (menu Data > Unmark this item): your own or the analysis'; the bytes are single, unmarked bytes again, names and comments stay. A run the item belongs to is dissolved, its other items stay. The cursor goes on to the next item, so that several marks can be taken back one after the other (after taking back the decision about an address it stays: the next Del takes the mark of the word).
- Dismonite, DOS programs (MZ): the analysis knows how a DOS program ends. After `mov ah,4Ch` / `int 21h` (also AH = 00 and 31,
  `int 20h`, `int 27h`) no code follows - what stands there (the option table of a compiler) is no longer decoded as code,
  also not by the code run of the user (C). `mov dx,offset` / `mov ax,25xxh` / `int 21h` (set interrupt vector) makes the
  handler code.
- Dismonite, DOS programs: tables of pointers. Runs of at least 6 words (records of 2 to 6 bytes: a pointer and a key or flags) in the
  bytes that are no code, whose values lead to the start of code in the same segment - 90% of them behind a `ret`/`jmp` or at known
  code, and decoding cleanly - become word items that are addresses: `dw J0000_01F5`, with labels at the targets whose code is
  followed; 4 and 5 entries if all of them lead to known code behind a `ret`/`jmp`. Words you have marked (W) that lead to such a
  place are addresses, too (a table of 3 entries). Tables that the code uses (`jmp [cs: 0x2355+bx]`, also `call`) are found by that
  instruction: their words are addresses as long as they lead to code that decodes cleanly and stay near the others (case labels),
  unused slots (0) in front or between are skipped. Part of "Analyze" (menu item *Find tables of pointers to code (DOS)*) and
  "Re-analyze" (not saved). TPC.EXE: of the code labels of its source 85% (before 37%) are code after the automatic analysis, with
  a `.dmon` of the user 90% (before 63%). The export writes `dw label`.
- Asmonite: `dw label` in a source with `segment` lines (MZ) is the offset of the label in its segment (before: the file offset).
- Asmonite: `call Name(arg, ...)` (also `call cdecl name(...)`, `call [Import](...)`) pushes the arguments from right to left,
  calls and cleans up for `cdecl`; a `func` gives its convention and checks the number of arguments. Arguments: register, number,
  label, parameter or local (byte/word zero extended, array = address), `&local`, `[ebx+4]`; for an address or a byte/word the
  first of eax/ecx/edx that the argument list does not name serves as the register. Examples `examples/func/func_call*.asm`.
- Dismonite: while the program is paused (Win32), the mouse over an `[ebp+x]` operand (or its `arg1` / `loc1` comment) shows
  the value: `loc1: dword 0x0000000A  10`; the size comes from the size word or the register, an operand with an index
  register shows the first bytes of the array; a pointer to a string adds `-> "text"`.
- Asmonite: while the program is paused, the mouse over a word in the source shows its value: parameters and locals of a
  `func` (with their size and the array size), and labels of data (`db`, `dw`, `dd`, `resb` ...): `byte`, `word`, `dword`
  (hex and decimal), `qword`, text as `pchar "..."`, else the first bytes; a dword that points to a text adds `-> "text"`.
- Asmonite: in the debugger, `begin` and `end` of a `func` are one step each (step into / step over run the whole prolog or
  epilog); more generally, the instructions of one source line that follow each other are one step.
- Dismonite: in a function that starts with `push ebp / mov ebp,esp` (a call label, the function ends at the next one) the
  comment of an instruction with `[ebp+x]` names the slot: `arg1` ([ebp+8], [ebp+0xC] = `arg2` ...) and `loc1`, `loc2` ...
  (the used places below ebp, closest first; `[]` when an index register is added); the first instruction shows the summary
  (`2 args, 3 locals`, arguments also from `ret N`). Only comments: the export still assembles to the same bytes.
- Asmonite: `func Name(params) [cdecl|stdcall] [uses regs]` / `var` / `begin` / `end` writes the stack frame: names for
  parameters (`[ebp+8]` ...) and locals (`[ebp-4]`, arrays `buf:16`), prolog and epilog (also at every `ret`), `uses`
  saves registers. `.arch i386` only; examples in `examples/func/`, help topic `func`.
- Dismonite: a code run (C) takes single bytes that the user marked as bytes (before, such a byte stopped the run at once);
  other items of the user (word, dword, text, ...) and the file structures still stop it.
- Dismonite: Alt+E exports the `.asm`, Alt+X exits.
- Dismonite: the key **F** follows the label of the row to its target (like Ctrl+click; Alt+Left comes back).
- Dismonite: Find (Ctrl+F) proposes the name of the label when the cursor is on a label row or on an instruction with a label (`call C00401234`).
- Dismonite: opening a file now runs the standard analysis automatically (after the `.dmon` is applied; progress window
  with Cancel): entry point and exports, relocations, constants, the call and jump targets until nothing new comes,
  strings. Menu Analyze: **Re-analyze** (the marks of the analysis anew, the user's stay), **Analyze automatically when a
  file is opened** (on) and **Follow new targets automatically after marking code** (off; the question after a code run has
  a "Yes to All" button). The `.dmon` also keeps the place of the cursor (`cursor <offset>`).
- Dismonite: the analysis is much faster where starting points fail: asmoc.exe 40 s -> 5 s (a failed relocation target no
  longer follows the strands still waiting), and the row counts of the document are made once per analysis step.
- Dismonite: an instruction whose last operand is a number from 0x20 to 0x7E shows the character in the comment
  (`cmp al,0x41   ; 'A'`); not for `add`/`sub` of the stack pointer, shifts, `ret`, `int`, `in`/`out`.
- Dismonite: while the program is paused in the debugger, the mouse over a name (a label in the code or its own row)
  shows the value of the variable in one line: `byte`, `word`, `dword` (hex and decimal), `qword`, `pchar "..."`,
  `pwchar "..."`, unmarked data as 8 bytes; a pointer to a string of the program adds `-> "text"`.
- Dismonite: the code that uses a label on an ASCII or UTF-16 string shows its first 20 characters in the comment
  (`push msg   ; "Hello, this is a lon..."`); also for ARM literals and a constant that is the address of a string.
- Dismonite: the automatic jump labels (`J00401234:`, mostly local jumps) stand two characters left of the code in the
  window and in the `.asm` export (two spaces before the label), so that the calls and data labels stand out.
- Dismonite: memory without file bytes (`.bss`, the end of a section with a larger virtual size) follows the file as
  zero bytes: it has addresses, labels `V00xxxxxx`, rows `resb 8` / `resd 1` (one per stretch between two labels) and
  the types B, W, D, Q work there. Names and types of the user are saved in the `.dmon` by offset like everywhere.
  The `.asm` export writes it as `section 0x... nobits` with `resb` rows and labels, so the export still assembles to
  the file; the status bar and the `.dmon` check count the bytes of the file.
- Asmonite: `section <rva> nobits` (flat sources): `resb` in it writes no file bytes at the end of the output; its
  labels have addresses.
- Asmonite: `resb`, `resw`, `resd`, `resq` reserve uninitialised data. With `.format pe` they may stand at the
  end of a section (`.code`, `.data`); the space is not in the file (virtual size larger than the raw size), the
  labels in front of it are normal addresses. Without `.format pe` they write zero bytes.
- Dismonite: after a code run (C) the calls and jumps in it may lead to places that are no code yet. Dismonite asks
  whether to follow the code from there (the same analysis as "Follow code from the entry point", with the C and J
  labels as starting points); also in the menu Analyze > Follow code from the call and jump targets.
- Dismonite: the keys C, B, W, D, Q mark a **run**: code from the cursor on, instruction after instruction (no
  branch is followed), up to `ret`, an unconditional `jmp`, an instruction that does not decode (or that no
  compiler writes) or an item of the file format; for B, W, D, Q byte, word, dword or qword up to the next
  label. The `.dmon` file gets one line `run <address> <kind> [<end>]` for it; reading the file makes the items
  again. Shift+C, B, W, D, Q set one item only (a line `item`, as C, B, W, D, Q did before). A hand-set item
  inside a run dissolves the run: its items are saved one by one.
- Dismonite decodes 32-bit code with the x64 decoder in its 32-bit mode: `cmovcc`, `bswap`, `cpuid`, `rdtsc`, x87,
  MMX and SSE are instructions now (before: bytes). notepad_32bit.exe: 3,705 -> 40,264 instructions found.
- Asmonite (`.arch i386`) assembles `cmovcc`, `bswap`, `cpuid`, `rdtsc`, `ud2`, `pause`, `int3`, `fwait`,
  `nop dword [eax]`, `lock cmpxchg`, `xadd`, x87, MMX and SSE; `add eax,12` uses the short form `83 C0 0C`.

### Changed
- Dismonite: the automatic label names show what points to a label: `C00401234` (a call), `J00401234` (a jump:
  `jmp`, `jcc`, entries of a jump table), `L00401234` (data only: pointers, memory operands, constants). A call
  wins over a jump. The address stays the same, the letter can change when the analysis finds more. The
  export (`.asm`) uses the same names.

### Fixed
- Dismonite: marking ascii (or a word, dword, qword) could cover a label that a pointer behind the item made: the labels of the items in a window of 4 KB were released before the check. The rules now look at the labels as they are.
- Dismonite, DOS programs: the analysis followed a `call` or `jmp` that wraps around in the segment to the wrong place (`call -0x85E7` is written `+0x7A19`; the label showed the right target, the code was marked 64 KB further on). It follows the right target now, also a jump forward by more than 32 KB (written as a negative number). Manual marking: one to three nops (0x90) between other things are no place to decide.
- Disassembler (16-bit code): `ror` with a count of 1 or CL (`D0`..`D3 /1`) was read as `ror ax,imm8` and took a byte too many: `D1 C8` became `ror ax,0xAB`, and the instruction after it was lost. Found by comparing TPC.EXE with its TASM listing.
- Asmonite (i386): a number written 0x80..0xFF was encoded as the sign extended byte, which means a different value:
  `push 0x80` became `6A 80` (= 0xFFFFFF80), `cmp ebx,0xC8` became `83 FB C8`, `or edx,0x80`, `sub ecx,0x90`,
  `imul eax,ebx,0x80` likewise. These now use the 32-bit (or 16-bit) immediate (`push 0x80` = `68 80 00 00 00`); the short
  forms stay for 0..127 and the negative bytes. (It showed with `CreateFileA(..., 0x80, ...)`: flags 0xFFFFFF80.)
- Dismonite / the disassembler: the byte of `83 /x`, `6A` and `6B` is a sign extended number and is now written like
  that: `and cx,0xFFFE`, `push 0xFFFFFF80`, `cmp eax,0xFFFFFFFF` (before: `and cx,0xFE`, which the assembler reads as 0x00FE,
  another value). The assembler takes such a number (also `-2`) back to the short form, so exports still assemble to the same bytes.

## 0.5.0 – 2026-10-14

### New
- **F1 help for x64 code** (German and English): `movsxd`, `cdqe`/`cqo`, `syscall`/`sysret`, and two overviews
  that appear by themselves: `rip` (addressing relative to rip, `[rip+...]` or `[rel label]`) and `x64` (the
  64-bit mode in short: registers and their parts, REX, what is gone, the calling conventions of Windows and
  Linux) for every instruction with a 64-bit register.
- **F1 help for more x86 instructions** (German and English): `cmovcc`, `bswap`, `xadd`, `cmpxchg`/`cmpxchg8b`,
  `cpuid`, `rdtsc`, `pause`, `ud2`, `int3`, `sysenter`/`sysexit`, `popcnt`/`lzcnt`/`tzcnt` (86 -> 97 sections).
- Example `window_i386.asm` (i386, `.format pe gui`): a window with a menu bar (File > Exit), an input line, a
  button and a label; the button copies the text of the input line to the label. Window class, window
  procedure (WM_CREATE, WM_COMMAND, WM_DESTROY) and message loop are written out and commented. Test:
  `guitest.ps1` (in `run_tests.bat`) uses it on a desktop of its own: controls, button, File > Exit.
- **Window "Debug targets"** (Debug > Debug targets..., in Asmonite and Dismonite): all targets in one place -
  Windows i386, Windows x64, Windows on ARM (ARM32 and ARM64), DOS (QEMU), ARM Linux (QEMU). The entry that fits
  the program (from its `.arch`, in Dismonite from the file) is chosen when the window opens; the list shows how
  each target is reached (this computer, host and port, ssh). It replaces the menu items "Debug target Windows on
  ARM", "Debug target x64 computer" and "DOS Boot Floppy" (the boot floppy is chosen there). The settings in
  the ini files stay as they were. Test: `targettest.ps1` (in `run_tests.bat`, both programs, desktop of its own).
- Asmonite writes the line `Target: ...` (for example `Target: Windows x64 on this computer`) to the output
  window when a debug session starts; Help > Asmonite on Discord opens the Discord channel in both programs.
- Example `window_x64.asm`: the same window for x64 (shadow space, rcx/rdx/r8/r9, 72-byte WNDCLASS), tested the same way.
- The examples are sorted by system: `examples/dos`, `examples/windows_intel`, `examples/windows_arm` (was `examples/asmonite`).
- F1 help for ARM64 (`help/de|en/a64.md`): the common instructions, registers (xzr, sp, lr, x18) and conditions.
- Examples `messagebox_i386.asm`, `messagebox_x64.asm`, `messagebox_arm32.asm`, `messagebox_arm64.asm` in
  `examples/windows_intel` and `examples/windows_arm`: a message box (`.format pe gui`, imports from two DLLs), to see where the windows of a
  debugged program appear (the desktop of the computer where the program runs).
- **x64 programs on another computer**: Asmonite and Dismonite debug x64 programs at `asmodbgx64.exe --listen`
  on an Intel/AMD Windows computer (e.g. from a Windows on ARM computer): Debug > Debug target x64 computer...
  (this computer or direct: host, port, code; "Search LAN" and "Test connection" like for ARM). The program is
  copied over the connection and started there, its output comes back. The firewall of that computer must let
  TCP port 23457 through. Test: `x64dbgtest` (remote part on this computer).
- **The Windows on ARM target chooses itself**: on a Windows on ARM computer, Asmonite and Dismonite use "this
  computer" (asmodbg.exe as a child process, no ssh, no code) when no target was chosen yet, and also when the
  host in the settings is this computer. If the chosen server does not answer, they say why and offer to debug
  here and to remember that.
- **`.format pe` with `.arch thumb`**: Windows programs for ARM 32 bit (PE32, Machine ARMNT, entry point with the
  Thumb bit), so `.format pe` now works for all four kinds: i386, x64, thumb and arm64. Code, data and imports
  are in one section; the code is pc-relative.
- Thumb: `adr rd, label` and `ldr rt, label` (the distance to the pc is worked out, narrow or wide form);
  `rva label + number`; a label before `db`/`dw`/`dd` needs no colon.
- Examples `hello_i386.asm`, `hello_x64.asm`, `hello_arm32.asm`, `hello_arm64.asm` in `examples/windows_intel` and `examples/windows_arm`.
- **Asmonite debugs ARM32 (Thumb-2) programs** on a Windows on ARM computer (asmodbg.exe, the same targets as
  for ARM64: ssh, direct or this computer): F9 and F8/F7 by source line, breakpoints, run to line, registers,
  stack and memory. Test: `run_tests.bat thumbdbgtest` (only when named; ssh to the host winarm).
- The PE check knows ARM32 (machine 0x1C4): no look-up of the imports on this computer, and a warning if the
  entry point has no Thumb bit.

### Fixed
- **Asmonite and Dismonite froze at a stop of a program with a window** (e.g. `window_i386.asm` at
  `CreateWindowExA`): bringing the IDE to the front waited for the stopped program in the main thread
  (`SetForegroundWindow`, `AttachThreadInput`). It is done by a thread of its own now (`IdeFront.pas`). The
  messages of the Win32 debugger thread are queued and no longer wait for the main thread either.
- `.format pe` for x64 and ARM64 with more than one DLL: the import address tables were not always 8 byte
  aligned (the directory has 20 byte entries); `ldr x16, [x16, :lo12:name]` then could not be encoded. They are
  aligned to 8 now.

## 0.4.0 – 2026-10-13

### Fixed
- A PE file written by hand (`org`, `db`, no `section` lines) had file offsets as addresses in the
  line map and the labels, so the debugger found no source line: they now come from the section
  table in the file. Breakpoints on `db` lines in executable sections work in the x64 and ARM64
  debuggers too.

### New
- **Resources of PE files in Dismonite**: the resource directory (data directory 2) is read: the
  tree of types, names and languages gets its fields and headings, resource names (counted UTF-16
  texts) are marked as texts. The RT_STRING blocks (16 counted strings: a length word, the
  characters, no terminator) are marked string by string: `dw` length and `du` text, each with the
  label `str_<id>` (id = (block - 1) * 16 + index; dcc32.exe: 477 strings, the compiler messages).
  Other resources get a heading and a label `res_<type>_<name>`. A constant before a call that
  loads a message (`push 0x82` / `mov eax, 0x20` before a function that reaches `LoadStringA`,
  found by counting: at least 4 calls, 3 of 5 with such a constant) gets the hint
  `=str_130 "Internal error: %s%d"` in the code row. Test: `exptest` (dcc32.exe: export gives the
  file again, 477 strings, hints).
- **Jump note in the debugger of Dismonite**: where the program stands at a jump that it is about
  to take, the row says in which direction ("jump up to L00401520", "jump down to 0x401580", at
  the right edge of the row and in the status bar). A conditional jump shows it only when the
  condition holds (flags, ecx/rcx for `loop`/`jecxz`, cpsr, registers for `cbz`/`tbz`), an
  unconditional one always; a jump that is not taken, calls and indirect jumps show nothing. For
  x86, x64, ARM, Thumb and ARM64. Tests: `dbgtest`, `x64dbgtest`, `a64dbgtest`.
- **Export of x64 and ARM64 programs in Dismonite**: the code is written as instructions (with labels
  for jumps, calls and rip-relative or `adrp` addresses), not as `db` bytes; every instruction is
  assembled again and compared with the bytes of the file, and what does not give the same bytes
  stays `db` with the instruction as comment (kernel32: 49 of 200000 lines).
  - For the encodings that the text cannot say, the x64 assembler has prefix words that the export
    writes: `enc.load` / `enc.store` (of the two encodings of a register copy the one with the register
    as `reg` / as `rm` field, `mov rcx, rbx` = 48 8B CB / 48 89 D9), `rex` and `rex.w` (a REX prefix that changes nothing, `48 FF 15`),
    `enc.alt` (of equal long ones not the first: `66 83 E8 2D` for `sub ax, 0x2d`); `short +18` and
    `near -7` (a signed number after `short`/`near`) are displacements from the end of the
    instruction; `[0+rax+rax]` keeps its displacement byte of 0 (the long `nop`).
  - Test: `exptest` (hello64, find, where, ipconfig, kernel32 of x64 and msvcrt of ARM64 assemble back
    to the same file; the last three of the sandbox folder only where the files are).
- **ARM64 assembler in Asmonite**: `.arch arm64` assembles A64 instructions (integer, loads and
  stores, branches, FP, NEON, atomics, crypto, system); `.format pe` with it writes a PE32+ file for
  Windows on ARM64 (Machine 0xAA64; it runs on Windows 10 ARM64).
  - `src/assembler/asm_a64.pas` has no table of its own: `dis_a64` is hand written, so it is the
    oracle. A list of seed words (`asm_a64_seed.inc`, one of every shape of instruction, made by
    `tests/a64seedgen.dpr` from real code, random words and their neighbours) is analysed by
    flipping each of the 32 bits: register fields, the other bits grouped by the operands they
    change, the opcode. The text is split into tokens the same way, the registers go into their
    fields, each group of other bits is solved (all values, or as a linear function for branch
    offsets and `mov` immediates, with the context bits tried), and the result is decoded again and
    must give the same text. Aliases (lsl, ubfx, cmp, cset, mov ...) need nothing of their own.
  - Syntax as the decoder writes it (capstone's), `#` optional, `lr`/`fp`, a label as target of
    branch, `adr`, `ldr` literal; `adrp x0, name` with `add x0, x0, :lo12:name`; `dq`.
  - Test: `a64asmtest` (the 1656 cases of `a64test`, all of ntdll of Windows 10 ARM64: 280000
    instructions, random words) and `exptest` (sources; `tests/pe_arm/a64asm_hello.asm` is a
    program that Windows on ARM64 runs).
- **x64 assembler in Asmonite**: `.arch x64` assembles x64 instructions (REX, 64-bit operands, r8..r15,
  rip-relative addresses, SSE up to SSE4.2, x87); `.format pe` with it writes a PE32+ file (Machine
  0x8664, image base 0x140000000, 8-byte import entries) that Windows runs.
  - `src/assembler/asm_x64.pas` is the other direction of `dis_x64`: its table of encodings
    (`asm_x64_tab.inc`, written by `tests/x64tabgen.dpr`) is read out of the decoder by probing every
    opcode with every prefix and REX.W, and each result is decoded again and must read as the same
    instruction. The shortest encoding wins. Syntax as the decoder writes it (NASM like: `mov rax,
    [rbx+rcx*4+0x10]`, `call [printf]`, `dword [rax]`, `lock xadd`, `rep movsb`, `jmp short`); a label
    as the address of a memory operand is rip relative, `[rel address]` too; `dq` writes 64-bit numbers
    and addresses, `.imagebase` takes 64 bits. Not assembled: AVX.
  - The PE check of Asmonite reads PE32+ files too (headers, sections, import table); the functions of
    the DLLs are not looked up for them. `tests/pe_x64/hello64.asm` is a program that Windows runs.
  - Debugger: F9 on an x64 program runs it under the debugger with source lines (breakpoints, step
    into/over, run to cursor, pause, registers rax..r15, rip and the flags, 64-bit stack and memory).
    It uses the same helper as Dismonite: `asmodbgx64.exe` (folder `armserver` next to the program)
    as a child process. ARM64 programs (`.arch arm64`) are debugged the same way on a Windows on ARM
    computer (`asmodbg64.exe`: ssh, direct or, on such a computer, local); the target is set in
    *Debug > Debug target Windows on ARM...* (the dialog of Dismonite, settings in `Asmonite.ini`,
    asked at the first ARM64 run). Registers x0..x30, sp, pc, cpsr and N Z C V. Not yet: keyboard
    input for the program. Tests: `x64dbgtest` and `a64dbgtest` (line mode).
  - Test: `x64asmtest` (every text of the 1124 cases of `x64test` assembles back to the same
    instruction; with a DLL as third parameter all its instructions: kernel32, ntdll, user32, ucrtbase,
    msvcrt, combase: 2.8 million, all back), and the sources in `exptest`.
- **ARM64 programs in Dismonite**: a PE file for ARM64 (Machine 0xAA64) is disassembled and debugged.
  - Decoder `src/assembler/dis_a64.pas` (A64): integer instructions with the usual aliases (mov, cmp,
    cset, ubfx, ...), branches, loads and stores (pairs, exclusive, atomics LSE, memory copy/set,
    memory tagging), scalar floating point, Advanced SIMD (NEON, also the dot product, complex and
    by-element forms) and the crypto extensions (AES, SHA-1/256/512, SHA-3, SM3, SM4); SVE and SME stay
    data. The text is the one of capstone: `tools/a64_check.py` compares whole files (ntdll, kernel32,
    ucrtbase, msvcrt of Windows on ARM64: 710000 instructions, all the same) and random words; the
    test `a64test` has 1700
    cases (`tools/gen_a64_cases.py`). The system register names come from `tools/gen_a64_sysregs.py`.
  - Addresses as for x64: 16 digits, `L0000000140001000`, the document keeps the low 32 bits. The
    analysis follows `b`, `bl`, `b.cond`, `cbz`, `tbz`; `adr` shows the label of what it points to as
    hint, an `ldr` (literal) marks its word as data. The export writes the code as instructions (see
    above), `.imagebase` of a 64-bit image with all its bits.
  - Debugger: back end `DbgGdbA64.pas` (like `DbgGdbArm` for ARM32): `asmodbg64.exe` on a Windows on
    ARM64 machine over ssh, direct (`asmodbg64.exe --listen`, same login code) or, when Dismonite runs
    on such a computer, as a child process; the settings of *Debug > Debug target Windows on ARM* are
    shared. Registers X0..X28, FP, LR, SP, PC, CPSR and the flags, stack of qwords, memory at 64-bit
    addresses; step over runs a `bl`/`blr` to the instruction behind it. Test: `a64dbgtest` (named
    only; `src/armserver/build64.bat`, ssh host `winarm`).
- **x64 programs in Dismonite**: a PE file for x64 (Machine 0x8664) is disassembled and debugged.
  - Decoder `src/assembler/dis_x64.pas`: REX, 64-bit operands, rip-relative addresses, r8..r15, integer
    instructions, x87, SSE up to SSE4.2 and AES; VEX/EVEX (AVX) are not decoded yet and stay data.
    Checked against capstone with `tools/x64_check.py` (ntdll, ucrtbase, mshtml, libclang: all
    instructions the same except a few spellings of capstone) and by the test `x64test` (1124 cases).
  - Addresses: the document keeps the low 32 bits of an address (an image is smaller than 4 GB);
    `ImageBase64`, `AddrText` and the `*64` functions give the whole one. Address column, labels
    (`L0000000140001000`), the registers, the stack and the memory view show 16 digits. A relocated
    64-bit pointer (`dq`) shows its label.
  - Debugger: `asmodbgx64.exe` (new, `src/armserver/asmodbgx64.c`, `buildx64.bat`, llvm-mingw
    `x86_64-w64-mingw32`) is started as a child process on this computer, like `asmodbg` on the ARM
    machine: a 32-bit program cannot debug a 64-bit process with the Win32 debug API. GDB protocol with the
    amd64 registers, breakpoint `int3`, single step through the trap flag. Back end `DbgGdbX64.pas`;
    registers RAX..R15, RIP, EFLAGS, stack of qwords and memory view at 64-bit addresses. Tests:
    `python tools/asmodbgx64_test.py` (server), `x64dbgtest` (Dismonite debugger, 29 checks).
  - `asmodbg` and `asmodbg64` name `asmodbgx64` when they are given an x64 program.
- `asmodbg64.exe`: the debug server for native ARM64 PE programs (Windows on ARM64), a port of
  `asmodbg` (source `src/armserver/asmodbg64.c`, `build64.bat` with llvm-mingw `aarch64-w64-mingw32`).
  Registers in the order of GDB's aarch64 target (x0..x30, sp, pc, cpsr, v0..v31, fpsr, fpcr),
  single step through PSTATE.SS, breakpoint `BRK #0xF000`. Test: `tools/asmodbg64_test.py` (session
  with a C program and with the ARM64 Hello World `tests/pe_arm/pe_arm64_hello_world.asm`, whose code
  is written as `db`). Dismonite uses it for ARM64 programs (see above); the release ZIP has it in
  `armserver\`.

- Dismonite on Windows on ARM: the target "This computer is the Windows on ARM machine" (*Debug > Debug
  target Windows on ARM*, `[WinArm] Mode=local`). Dismonite itself runs there (as an emulated x86 program)
  and starts `asmodbg.exe` (folder `armserver\`) as its own child process, `--once 127.0.0.1:<free port>`,
  with the folder of the program as working folder: no ssh, no copy, no login code, no firewall rule, no
  open port beyond the loopback address. A server that ends at once says why ("this is an ARM64 program:
  use asmodbg64", "the program was not found") instead of a failed connection. Test:
  `python tools/winarm_local_test.py` builds `winarmdbgtest.exe`, copies it with the server to the ARM
  machine and runs it there over ssh (`winarmdbgtest <dir> <work> local`: 18 checks, entry stop, steps,
  breakpoint, output, exit codes).

### Changed
- `asmodbg` and `asmodbg64` look at the Machine field of the program before they start it and say what
  is wrong: "this is an ARM64 program: use asmodbg64", "this is a 32-bit ARM program: use asmodbg",
  x86/x64 programs are refused, a missing file or a file that is no PE file gets its own text (before:
  "cannot start the program (error 50)", or the program ran on without a stop). Dismonite shows the text
  as "The program did not start: ...".

## 0.3.0 – 2026-10-12

### New
- `qemu\install_qemu.bat`: `run_freedos.bat` and `run_buster.bat` call it when QEMU is missing.
  On x64 Windows it installs the tested QEMU (9.2.0) with winget as before, now silently; on
  Windows on ARM, where winget has no ARM64 QEMU and its x64 build does not run (Windows 10 on
  ARM emulates only 32-bit x86), it loads the newest native ARM64 build of
  qemu.weilnetz.de/aarch64, checks it against its `.sha512` file and installs it silently to
  `C:\Program Files\qemu`. Other Windows (32-bit): a hint, nothing is installed. Tested on
  Windows 10 on ARM (QEMU 11.1.0).
- Windows on ARM without 32-bit ARM support (Windows 11 24H2 and later, no `SysArm32`): the
  one-line installer of asmodbg and Dismonite's ssh target say so clearly, instead of a server
  that does not start.
- "Search LAN" in the dialog "Debug target Windows on ARM": Dismonite asks the local network
  (UDP broadcast to the port) which `asmodbg --listen` are there and fills in address and port
  of the answer (several: a list to pick from). The server answers only this one request, with
  version, port and computer name, never with the code; `--no-discover` turns it off. The
  firewall of the ARM computer must let UDP 23457 through (a `netsh` rule by hand needs a second
  line with `protocol=UDP`).
- Thumb assembler `asm_thumb.pas` (the first part of the ARM assembler): the tables of the Thumb
  disassembler backwards. A text as the disassembler writes it (plus upper case, decimal numbers,
  `sb sl fp ip`, ranges in register lists, `cs`/`cc`) is matched against the operand template of
  every row with the mnemonic, the placeholders give the bits of their fields back, and the code
  is disassembled again as a check. 16 bit before 32 bit as GAS (`add.w` wide, `add` wide only when
  no narrow form fits); IT blocks as the disassembler. Test part `thumbasmtest`: all 16-bit codes,
  the 586 32-bit words and 6 sequences of `thumbtest`, random codes of every row; everything comes
  back, alias encodings (don't-care bits, `cmp r0, r0` in the high-register form) counted apart.
- `.arch thumb` in Asmonite: behind it every line that is no data or control directive is a Thumb
  instruction for `asm_thumb`; a label needs its colon; branch targets may be labels (`b loop`,
  `bl func`, `cbz r0, done`), resolved over the two passes of the assembler; the address of an
  instruction is `.imagebase` plus the RVA of the `section` lines. Dismonite's export writes PE
  programs for Windows on ARM with `.arch thumb` and their code as instructions: each line is
  assembled first at its address with its IT state and must give the bytes of the file, else it
  stays `db` with the instruction as comment (alias encodings); the whole-file check with the
  assembler works as for x86. `exptest` round-trips the two `tests\pe_arm` programs.
- Asmonite's editor colours the lines after `.arch thumb` as ARM/Thumb (registers `r0`..`pc`,
  `s0`..`d31`, instructions with condition and `.w`, `#` immediates, `@` comments) and the lines
  after `.arch i386` or `.arch x86_real` as x86 again: the processor is the lexer state the editor
  carries from line to line, as the assembler does it, so it follows every edit at once and needs
  no file extension or guess. The syntax menu entry "Assembler (x86)" is now "Assembler".
- Instruction info (F1) for imported functions: a row that uses an import (`call [ExitProcess]`,
  `jmp [X]`, the entry of the import table, its label, Thumb `ldr r3, =ExitProcess`) shows, under the
  instruction, the function from the new `help\de\winapi.md`: DLL, calling convention, number and
  bytes of the parameters, the call in C order, each parameter with type and meaning, the result, a
  short explanation and for the common ones an example. 205 sections (A and W forms together) for
  kernel32, user32, gdi32, comdlg32, advapi32, shell32, oleaut32, msvcrt and the `api-ms-win-crt-*`
  parts of the universal C runtime: every import of the programs in the repository and the usual
  ones beside them. A function without a section shows name and DLL and that there is no section yet.
  Checked against `dcc32.exe` (Delphi compiler), the Delphi program `asmoc.exe`, the clang program and
  the examples: 33 sections more for what `dcc32.exe` imports and was missing (resources, drives,
  environment, time zone, console control, GUIDs, ...), 238 sections now.
- Instruction info (F1) in Asmonite's editor: the line of the cursor explained in a new tab "Help"
  in the right column beside the registers, from the same help files as Dismonite (x86 or, after `.arch thumb`,
  `arm.md`; imported functions from `winapi.md`: every name in the line that has a section, e.g.
  `call [ExitProcess]`). The text changes when you press F1; *Help > Help language*
  switches Deutsch/English (`Asmonite.ini`, `[Help] Language`). The help code moved from `DisHelp.pas`
  to the shared unit `src/HelpText.pas` (help books, Markdown to RTF); `DisHelp` keeps what needs the
  disassembler's rows.
- Asmonite: a source with neither `.format` nor `.arch` (and without `org`, `section`, `segment`,
  `codeend`) is assembled as `.arch i386` + `.format pe console`: a single line `mov eax, 1` gives a
  32-bit Windows program (the Output says so). Everything that states `.arch` or `.format` or sets
  `org`/`section` is unchanged (DOS `.COM`, boot sectors, hand written PE, Thumb). The rule is the
  property `DefaultPe` of `TAsmoAssembler` / `TAsmFormatter`, switched on by Asmonite only; asmoc and the
  tests of the core keep assembling the source as it stands. For Windows on ARM the default is to come.
- Asmonite: the help changes only on F1 (it no longer follows the cursor and the text); F1 also explains
  the directives: new `help\de\directives.md` / `help\en\directives.md` with `.arch`, `.format`,
  `.code`/`.data`, `.import`, `.entry`, `.imagebase`, `du`, `rel32`, `codeend`, `section`, `segment`.
- Examples for DOS in assembler: `examples\dos\hello.com.asm` ("Hello, World!" as a .COM program, no
  header, `section 0x100`) and `examples\dos\hello_exe.asm` (as an .EXE with a header written by hand,
  one segment); both run with F9 in QEMU with FreeDOS. The comments explain the difference .COM / .EXE.
- Asmonite: the help is in the right column beside the register list (tabs Registers and Help, like
  Dismonite), no longer under the editor; the button x closes it, F1 shows it again.
- F1 explains error messages: on a line of the output window, or in the editor on the line marked as
  faulty, the help shows what the message of the assembler or of the PE check means, the usual causes
  and a fix (`help\de\errors.md`, `help\en\errors.md`, 32 sections: unknown instruction, undefined
  label, number, value range, jumps, address operands, `.format`, `.import`, DLL or function not
  found, ...). The help follows a click or a cursor key in the output window.
- Instruction info (F1) for DOS and BIOS interrupts, in Dismonite and Asmonite: for an `int` the function
  it calls is shown below the instruction, from the new `help\de\dos.md` / `help\en\dos.md` (154 sections
  each): `int 21h` (about 70 functions: characters, files, directories, memory, programs, vectors, time),
  `int 10h` video, `int 13h` disks (CHS and LBA), `int 16h` keyboard, `int 1Ah` clock, `int 33h` mouse,
  `int 2Fh`, `int 15h`, `int 14h`, `int 17h`, `int 20h`, `25h`, `26h`, `27h`, `29h`, `11h`, `12h`, `24h`,
  `28h`. The function number is found in the instructions before the `int` (`mov ah, 0x09`, `mov ax, 0x4C00`,
  `xor ah, ah`, `mov al, ...`; over labels, up to a jump, call, return or another `int`; an instruction
  that changes `ah` in another way gives up). If it is not known the overview of the interrupt with the list of
  its functions is shown. Each section has input registers, output registers (with the carry flag and the
  error codes) and often an example. `int 21h` of `TPC.EXE` and `HELLO.EXE`: 23 of 24 find the section of their
  function. The mouse functions are selected by `ax`, not `ah`.
- Help texts in English: `help\en\x86.md`, `arm.md` and `winapi.md` are the translations of the German
  files with the same sections under the same names (a test compares them). Dismonite: *Help > Help
  language* switches between Deutsch and English at once; the choice is saved in `Dismonite.ini`
  (`[Info] Language=de|en`); without a choice a German Windows gets German and every other one English;
  a language without the file falls back to German.

### Changed
- Asmonite: the register list on the right is shown only while a program is debugged (running or
  paused; *View > Registers* still decides whether it may be shown); an assembler error shows the
  Output tab (also when the Help tab or the Stack was shown, or the output area was hidden); every new
  line in the output scrolls the output to its end.
- The language of the help texts: English unless the user interface language of Windows is German
  (before: the regional format setting).

### Fixed
- `asmodbg.exe` started with a double click (no arguments) only printed its usage and ended,
  although the readme promised the window; without arguments it now runs like `--listen`.
- Dismonite, Windows on ARM over ssh: the tunnel used port 23456 of this computer too and failed
  when that port was taken; it now takes a free port here (asmodbg on the ARM machine stays on
  23456).

## 0.2.0 – 2026-10-11

### New
- Dismonite debugs 32-bit programs for Windows on ARM (PE, Machine 0x1C4) on a real Windows on
  ARM machine, like ARM Linux programs in the QEMU guest: entry stop, breakpoints, step into,
  step over, run to cursor, pause, stop, registers, memory, program output, exit code, exceptions.
  New server `asmodbg.exe` (C, ARM32/Thumb-2, built with llvm-mingw by `src/armserver/build.bat`):
  it runs the program with the Win32 debug API and speaks the GDB protocol like gdbserver, so the
  ARM debugger of Dismonite (`TArmGdbDebugger`, now with the target `atWinArm`) is used almost
  unchanged. Dismonite copies the program (and the server, if its version differs) with scp,
  starts the server by ssh and connects through an ssh tunnel (`-L`): no firewall rule on the ARM
  machine. Host (default `winarm`) and folder (default `asmodbg`, relative to the home folder) are
  `[WinArm] Host=` and `Dir=` in Dismonite.ini. Single steps use the SS bit of the ARM CPSR (found
  by experiment: Windows on ARM32 supports it, the server needs no instruction decoder). Tests:
  `tools/asmodbg_test.py` (server alone, 27 checks) and test part `winarmdbgtest`.
- `asmodbg --listen` (server version `asmodbg-3`, first step of the direct connection without
  ssh): the server stays open and serves one session after the other. A session uploads the
  program into its own folder (`vFile`), starts it only from there (`vRun`) and receives the
  program output as `O` packets. File names are restricted to plain names. The listen mode needs
  a login: a 12-character code (generated by the server, stored with DPAPI next to the EXE,
  shown by `asmodbg --show-code`), challenge-response with HMAC-SHA256 (Windows CNG) in both
  directions, then a MAC on every packet (integrity, no encryption); nothing else is answered
  before the login and 3 wrong proofs lock the server for 10 s. It listens on all addresses
  (default port 23457); winarm needs one firewall rule. The listen mode shows a small window
  (version, ARM32 check, IP addresses, port, code, status, a warning when run as administrator;
  `--port N`, `--no-window`, `--info`). `tools/asmodbg_test.py` now has 77
  checks, including the direct connection without ssh.
- Dismonite connects directly to `asmodbg --listen` (no ssh for debugging): login with the
  code (HMAC-SHA256 through the Windows CryptoAPI), version check, upload of the program with
  `vFile`, start with `vRun`, program output from the `O` packets. ini `[WinArm]`:
  `Mode=direct|ssh`, `Port`, `Code` (protected with DPAPI). `winarmdbgtest` now runs
  every test also directly and checks the message for a wrong code (39 checks).
- Dismonite: Debug > "Debug target Windows on ARM..." chooses Direct or ssh (host, port, code,
  folder) and has "Test connection" (connect, login, version; for ssh: does ssh answer), with
  clear error messages. The dialog opens by itself the first time a Windows on ARM program is
  started and no target is set up yet. The settings go to the ini `[WinArm]`.
- Release ZIP: `armserver\asmodbg.exe` (built by `tools/release.py`); the README of the ZIP
  explains the first setup on fresh computers (start the server, firewall, the dialog).
- One-line installer for the ARM computer: `powershell -NoProfile -Command "irm
  https://asmonite.com/downloads/install-asmodbg.ps1 | iex"` (`tools/install-asmodbg.ps1`;
  `tools/release.py` puts it and `asmodbg.exe` into `html/downloads/`, with the SHA-256 of the
  EXE inside the script). It refuses to run as administrator, checks the hash, replaces an older
  server and starts it. The dialog "Debug target Windows on ARM" shows the line with a
  "Copy the line" button.
- Dismonite: the debugger shows the stack and the memory of the program and its output, all at
  once with the registers: registers and stack right of the code, memory and output below it.
  The stack: 32 entries from the stack pointer, with the label a value points to (double click
  goes there). The memory: 16 rows from an address, a label, a register or (DOS) segment:offset;
  changed values are red. The output: what the program wrote in this run (Windows: its console,
  DOS: the screen, ARM: stdout). Each view can be switched off in the Debug menu; they appear
  with the first debug session.
- Dismonite reads 32-bit programs for Windows on ARM (Machine 0x1C4): headers, imports and
  exports as for i386, the entry point without the Thumb bit (label `start` at 0x401000 for
  `AddressOfEntryPoint` 0x1001), and the Thumb-2 code: the analysis follows it from the entry
  point and the exports, IT blocks are shown with their conditions, `adr`/`ldr [pc]` get the
  import or label they point to as hint. The export writes Thumb code as bytes with the
  instruction as comment, so it assembles to the same file. Floating point instructions (VFP:
  `vldr`, `vmov`, `vadd.f64`, `vpush`, `vmrs`, ...) are decoded, NEON instructions not yet. New
  table-driven decoder `dis_thumb` (all 16-bit codes and the Thumb-2
  instructions as capstone writes them; `tools/thumb_check.py`, test part `thumbtest`).
- Dismonite: ARM Linux programs may mix ARM and Thumb code (as GCC makes them): each place has its
  kind (new kind "thumb", key T). The analysis follows the entry point and the functions of the
  symbol tables in their kind (bit 0), changes the kind with blx and uses the mapping symbols
  ($a, $t, $d) and .plt; the debugger knows Thumb code by the T bit (breakpoints, step over).
  ARM programs can be exported as .asm now (code as bytes with the instruction as comment).
  New test program hallo-thumb.
- Dismonite: ARM and Thumb code has colours of its own: registers r0..pc, s0..s31, d0..d31, numbers
  after #, instructions also with a condition (addeq, vmoveq.f64).
- Dismonite: instruction info (F1): on the right, the instruction of the current row explained
  (syntax, flags, an example), from the help file `help\de\x86.md` (German for now); it follows
  the cursor (Help > Info follows the cursor). While debugging it is a second tab beside the
  registers. All instructions the disassembler decodes (x87: one section); ARM and Thumb in
  `help\de\arm.md` (`addeq`, `bne`, `vmoveq.f64` find their instruction and show the condition).
- Dismonite: zero bytes before a structure are one row too (`org`/`align`), not only before the PE
  header, a section and the end of the file: e.g. up to `e_lfanew` in a DOS header without stub, or
  between the code and the imports of the same section.
- Release ZIP: `examples\winarm\pe_arm32_hello_world.exe` (with its `.asm`), a Windows on ARM
  program to try the ARM debugger of Dismonite with asmodbg.

### Fixed
- Dismonite: File > Open promised programs without an extension (ARM Linux) under "Programs", but
  today's Windows dialog finds none with the filter `*.`. They are now under "All files (also
  programs without extension)", and Dismonite keeps the file type chosen last (`Dismonite.ini`).
- Dismonite: the last instruction of a section was not recognized as code when it ended with
  the 00 byte of an address (`call [ExitProcess]` at the end of `demo.exe`).
- Dismonite: the register list kept the values of the last debug session when another file
  was opened; its header showed "Regi..." instead of "Register".
- Dismonite: the last line a program wrote was replaced by "Program exited with code 0" at
  once (ARM programs write their output only at the end); the output view keeps all lines.
- The DOS example `HELLO.EXE` did not match its source `HELLO.PAS` (an older program compiled
  with Turbo Pascal 6). Both are now in `examples/dos`: `HELLO.PAS` counts up, `HELLO.EXE` is
  its translation by Turbo Pascal 7, checked by the tests.

## 0.1.0 – 2026-10-09 (test package, git tag v0.1.0)

The first version.

### Asmonite (editor, assembler, debugger)
- Editor with syntax highlighting for x86 assembly, C and Pascal; undo/redo, find and
  replace (Ctrl+F, F3, Ctrl+H), go to line (Ctrl+G).
- Assembler for the i386: `.format pe` (header and import table are generated) or every
  byte in the source; labels, `.imagebase`, `org`, `align`, `rva`.
- Check of the generated PE file before it is started (header, sections, imports).
- Win32 debugger: breakpoints (they also take effect while the program runs), step over/into,
  run to cursor, pause, show execution point;
  registers, stack and memory; the output of the program in the output window.
- DOS programs in QEMU with FreeDOS (not included: `qemu\run_freedos.bat` loads the FreeDOS
  floppy and offers to install QEMU); the same program starts again in the running QEMU.

### Dismonite (disassembler and debugger)
- Windows (PE), DOS (MZ) and ARM Linux (ELF) programs; the structures of the file format
  (headers, sections, imports, exports, ELF program headers and symbols) with the names of
  their fields.
- Analysis from the entry point, the exports and the relocation targets.
- Labels instead of addresses; Ctrl+click goes to the target, Alt+Left back.
- Marks and comments are saved in `<program>.dmon`.
- Export as `.asm` with labels, which the assembler of Asmonite turns into the same file again.
- Debugger: breakpoints, step over/into, run to cursor, pause, registers; command line
  parameters (Debug > Parameters, saved in the `.dmon`). Where the program stops becomes code.
  Windows programs directly, DOS programs in QEMU with FreeDOS, ARM Linux programs through
  gdbserver in Raspberry Pi OS under QEMU (Dismonite starts the guest on request).

### QEMU guests (folder qemu)
- `run_freedos.bat`: FreeDOS; loads the boot floppy (720 KB).
- `run_buster.bat`: Raspberry Pi OS (ARM) for debugging ARM programs; loads about 440 MB
  and sets the guest up (ssh, gdbserver, keyboard of Windows).
- Both offer to install QEMU with winget; `-h` shows the options.

### asmoc
- The assembler on the command line.

### Known limits
- No x87 floating point instructions in the assembler; the disassembler shows them without names.
- The differences to NASM are listed in docs/en/nasm-differences.md.
