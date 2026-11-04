# Error messages

Press **F1** on a line of the output window (or in the editor on the line marked as faulty) and the
help panel explains the message: what it means, what usually causes it and how to fix it. The sections
named `err-...` belong to the assembler, `pe-...` to the check of the finished program.

## err-unknown-instruction – unknown instruction

**Message:** `unknown instruction: "movv"`

The assembler does not know the word at the start of the line (the mnemonic).

**Usual causes:**

- typo in the instruction (`movv`, `pussh`)
- an instruction of another processor: after `.arch thumb` the ARM names count, otherwise the x86 names
- the instruction exists but is not supported by this assembler yet (rare FPU, SSE or system instructions)
- the word is a name of your own (a macro, a data name) written without a colon where an instruction is expected

```asm
mov eax, 1      ; right
movv eax, 1     ; unknown instruction: "movv"
```

Related: `err-label-colon`, `err-no-encoding`

## err-label-colon – a label needs a colon

**Message:** `unsupported instruction: "start" (a label needs a colon)`

A word at the start of a line that is not an instruction is taken as a label, and a label ends with a colon.

```asm
start:          ; right
    mov eax, 1
start           ; wrong: no colon
```

Related: `err-unknown-instruction`

## err-undefined-label – undefined label

**Message:** `undefined label: "loop2"`

A jump, a call or an address names a label that does not exist anywhere in the program.

**Usual causes:**

- typo in the name of the label
- the label line is missing or is commented out
- a Windows function that is not declared with `.import`
- a name from a data line (`db`, `dd`) that was never written

```asm
    jmp done        ; undefined label: "done" ...
done:               ; ... until this line exists
```

Related: `err-redefined-label`, `err-import`

## err-redefined-label – label defined twice

**Message:** `redefinition of Label: "start"`

The same name stands in front of two different places. A label names exactly one address, so every
label may be defined only once in the whole program.

Rename one of them (inside a long program it helps to give local jump marks a prefix: `main_loop`,
`copy_loop`).

Related: `err-undefined-label`

## err-number – invalid or too large number

**Message:** `invalid number: "0x12G4"`, `number too large: "0x1FFFFFFFF"`

A number is written in a form the assembler cannot read, or it does not fit in 32 bit.

- decimal: `123`; hexadecimal with the prefix `0x`: `0x7B`
- letters directly behind the digits are an error: `0FFh` or `12ab` is not accepted, write `0xFF`
- a hexadecimal digit after `0x` is required: `0x` alone or `0xZ` is invalid

Related: `err-value-range`

## err-value-range – value out of range

**Message:** `value out of range for db: 300`

A number does not fit into the data item it was written for.

| Directive | Size | Allowed |
| --- | --- | --- |
| `db` | 8 bit | -128 to 255 |
| `dw` | 16 bit | -32768 to 65535 |
| `dd` | 32 bit | -2147483648 to 4294967295 |

```asm
db 300          ; too large: use dw
dw 300          ; right
```

Related: `err-number`

## err-short-jump – short jump out of range

**Message:** `short jump out of range`

A jump with `short` (or `loop`, `jcxz`, a conditional jump in 16 bit code) can reach only 128 bytes back and
127 bytes forward. The target is farther away.

- remove `short`: the assembler then chooses a long jump itself
- `loop`, `jcxz` have only the short form: replace them with `dec ecx` and `jnz`
- in 16 bit code a conditional jump is always short: jump over a `jmp` with the opposite condition

```asm
    jz  far_away     ; too far in 16 bit code
; instead:
    jnz skip
    jmp far_away
skip:
```

Related: `jmp`, `jcc`, `loop`

## err-branch-reach – the branch does not reach (ARM)

**Message:** `the branch does not reach its target in this form (write the instruction with ".w")`

In Thumb mode a conditional branch has a short form with a range of about 256 bytes. The target is
farther away. Write the 32 bit form: `beq.w target` instead of `beq target`. An unconditional `b` reaches
about 2 KB in the short form and 16 MB as `b.w`.

Related: `b`, `bl`

## err-no-encoding – no encoding (ARM)

**Message:** `no encoding for "add r0, r1, #100000"`

The instruction is known, but not with these operands: Thumb has fixed limits for numbers and registers.

**Usual causes:**

- the immediate number is too large (many instructions accept 8 bit, some 12 bit or a rotated number)
- a high register (r8 to r15) where only r0 to r7 are allowed
- the form needs a `s` (sets flags) or has none: `adds` against `add`
- the number can be built with `movw`/`movt` or loaded with `ldr r0, =value`

```asm
ldr r0, =0x12345678   ; right: the number goes to the literal pool
mov r0, #0x12345678   ; no encoding
```

Related: `err-unknown-instruction`, `movw, movt`, `ldr`

## err-prefix – several instruction prefixes

**Message:** `multiple instruction prefixes not allowed`

A line may have only one of `rep`, `repe`, `repne`, `lock`. Write the second one on its own line is not
possible either, because a prefix belongs to the instruction behind it.

Related: `rep`

## err-address – wrong memory operand

**Messages:** `colon expected`, `closing square bracket expected`, `no basereg and no displacement`,
`Scale must be 1,2,4 or 8`, `either bx or bp required in two reg-Argument`,
`8-bit register not allowed in address`, `mult only allowed with number or register`

The part in `[ ... ]` is not a valid address. What is allowed:

- 32 bit: `[base + index*scale + displacement]`, every part optional; the scale is 1, 2, 4 or 8
- 16 bit: only `bx`, `bp`, `si`, `di` as `[bx+si]`, `[bp+di]`, one base and one index at most
- registers in an address have the size of the address (no `al`, `ah` ...)
- a segment prefix goes in front of the bracket: `es:[di]` or `[es:di]`

```asm
mov eax, [ebx + esi*4 + 8]   ; right
mov eax, [ebx + esi*3]       ; scale must be 1, 2, 4 or 8
mov ax,  [bx + cx]           ; 16 bit: bx or bp with si or di
```

Related: `mov`, `lea`

## err-syntax – unexpected text

**Messages:** `unexpected token`, `unexpected "..."`, `label or number expected`, `number expected after "+"`

The assembler understood the instruction up to a point and found something it did not expect behind it.

- a second comma or a missing comma between operands
- text after the last operand that is not a comment (comments start with `;`)
- an operand that is neither a register, a number nor a label
- operators in the wrong place (`+` or `-` without a number behind)

```asm
mov eax ebx      ; missing comma
mov eax, 5 6     ; unexpected "6"
```

## err-org – org moves backwards

**Message:** `org 0x100: the output is already at 0x120 (org would overwrite 32 bytes)`

`org` sets the address of the next byte. It may only move forward (the gap is filled with zero bytes).
The output is already beyond that address.

- put `org` at the beginning of the program or before the code that needs the address
- boot sectors: `org 0x7C00` at the top

Related: `org`

## err-codeend – codeend needs the header

**Message:** `codeend needs the PE header (at least 0x200 bytes) before it`

`codeend` closes the code of a hand written PE file; it is only meaningful when the PE header was
written before it. For programs it is simpler to use `.format pe`, which writes the header for you.

Related: `err-format`

## err-imagebase – number expected

**Message:** `number expected after .imagebase`

`.imagebase` needs the load address as a number: `.imagebase 0x00400000`. The value must be a multiple of 64 KB.

## err-arch – unknown .arch

**Message:** `unknown .arch: "arm7"`

`.arch` knows the processor modes the assembler can write: `i386` (32 bit x86), `x86_real` (16 bit,
DOS) and `thumb` (ARM Thumb-2). It is valid from this line down to the next `.arch`.

```asm
.arch thumb
```

## err-format – .format

**Messages:** `second .format`, `.format must come before the first instruction or data`,
`unknown .format: "elf"`, `unknown option of .format pe`, `.format pe needs .arch i386`,
`.format pe: no code`

`.format` chooses the kind of file the assembler writes.

- once per program, before the first instruction or data
- `.format pe` writes a Windows program (`console` or `gui` follows as option); it needs `.arch i386`
  and a `.code` section
- `.format binary` writes the bytes as they are (boot sector, DOS `.COM`)

```asm
.format pe console
.arch i386
.import kernel32.dll ExitProcess
.code
```

Related: `err-format-ops`, `err-import`

## err-format-ops – not allowed with .format pe

**Messages:** `"org"`, `"section"`, `"segment"` or `"codeend"` ... `is not allowed with .format pe (the sections are placed by the assembler)`

With `.format pe` the assembler places the headers and sections itself. `org`, `section`, `segment` and
`codeend` set addresses or sizes by hand and would fight with that. Remove them, or write the program
without `.format pe` if you want to build the headers yourself.

Related: `err-format`

## err-import – .import

**Messages:** `.import needs a dll and function names`, `.import kernel32.dll: no function names`,
`.import: "xyz" is not a valid name`, `.import: ExitProcess is imported twice`,
`label ExitProcess is also an imported function`

`.import` lists the functions of a DLL the program calls: first the DLL, then the names.

```asm
.import kernel32.dll ExitProcess WriteFile GetStdHandle
.import msvcrt.dll printf
```

- every function once; the name must not be used as a label too
- the call is then `call [ExitProcess]`

Related: `err-undefined-label`, `pe-function-missing`

## err-entry – .entry

**Message:** `.entry needs a label`

`.entry start` names the label where the program begins. Without `.entry` it starts at the first
instruction of the `.code` section.

## err-output – .output

**Message:** `.output needs a file name`, `second .output ...`, `.output must come before the first instruction or data`, `.output: the name must not have a folder ...`

`.output name` gives the output file its name (for example `.output hello.com`). It may stand once, before
the first instruction or data, with a plain file name: the file is written next to the source, so no
folder and no drive.

## err-target – .target

**Message:** `.target pico2: ...`, `unknown .target`, `second .target ...`, the warning `.arch thumb with .format binary is taken as a program for the Arm cores ...`

`.target pico2` checks the program for the Raspberry Pi Pico 2 (see `.target`). The message says what does
not fit:
- **IMAGE_DEF missing:** a program for the flash needs the block in its first 4 KB, else the boot ROM does not
  start it. Templates: `examples\pico2\blink_flash.asm` (RISC-V), `blink_arm_flash.asm` (Arm).
- **IMAGE_TYPE does not fit:** `0x1101` is RISC-V, `0x1021` Arm; with the wrong value the boot ROM starts the
  other cores.
- **Vector table:** an Arm program in the flash starts with the stack pointer (an address in the RAM) and the
  start address with bit 0 (`dd _start + 1`: Thumb code).
- **`.imagebase`:** in the RAM (`0x20000000`) or in the flash (`0x10000000`), and the program must fit.

With `.target pico` (RP2040) also:
- **An instruction the Cortex-M0+ does not have:** it knows Thumb-1 only, and of the 32-bit instructions only
  `bl`, `msr`, `mrs` and the barriers. A constant is loaded there by `ldr r0, value` from a word behind the code
  instead of `movw`/`movt`.
- **boot2 block:** the first 256 bytes of a flash program are a small program that sets up the flash chip, with
  its CRC-32 at the end. If the CRC is wrong, the boot ROM starts nothing. `.boot2` puts the block of the
  Pico SDK there; `.boot2 file.bin` a file of your own with 252 or 256 bytes.

The warning without `.target`: Asmonite takes `.arch thumb` with `.format binary` as a program for the Pico 2.
Write `.target pico2`, then it is said and checked.

## err-internal – internal error

**Message:** `internal error: ...`

The assembler broke on something it did not expect. This is a bug of Asmonite, not of your program.
Look at the line named: maybe a rare combination of operands. A short example that shows it is
welcome in the issue tracker.

## err-file – file cannot be read or written

**Messages:** `cannot read file: ...`, `cannot write file: ...`

- reading: the file is missing, or locked by another program
- writing: the target program is still running (a running `.exe` cannot be overwritten; end it first or
  stop the debug session), the folder is read-only or on a drive that is not there

## pe-file – file not found

**Message:** `file not found: ...`

The check of the finished program did not find the file. Look at the path in the line above.

## pe-not-exe – not an executable file

**Message:** `no MZ signature: not an executable file`

The file does not start with `MZ`. It is not a program for Windows or DOS (a `.COM` file or a boot sector
looks like this and is fine for DOS). For a Windows program use `.format pe`.

## pe-dos-program – DOS program

**Message:** `no PE signature at offset $...: a DOS program, ...`

The file is an `MZ` program without a PE header: a DOS program. It is correct if you wrote a DOS program
(F9 starts it in QEMU with FreeDOS). If you wanted a Windows program, add `.format pe`.

## pe-machine – wrong machine

**Messages:** `machine $... is not i386 ($14C)`, `64-bit (x64) image: only 32-bit programs are supported`

Windows loads the program only if the machine type of the header fits. Asmonite writes 32 bit x86
programs (`.arch i386`). 64 bit programs are not supported yet.

## pe-header – header fields

**Messages:** `image base ... is not a multiple of 64 KB`, `section alignment ... is not a power of two`,
`file alignment ...`, `optional header ...`, `characteristics ...`, `size of image ...`,
`number of sections is ...`, `subsystem ...`

A value in the PE header is out of what the Windows loader accepts. This happens with headers that
were written by hand (`dd`, `dw` lines). Compare the field with the description of the PE format; with
`.format pe` the assembler fills all of them correctly.

Typical values: image base `0x00400000`, section alignment `0x1000`, file alignment `0x200`,
subsystem 2 (GUI) or 3 (console).

## pe-sections – section table

**Messages:** `section .text: virtual address ... is not aligned`, `... overlaps the headers or the previous
section`, `... raw data ... beyond the end of the file`, `section table runs past the end of the file`

A section is laid out wrongly: the virtual address must be a multiple of the section alignment, must
come after the previous section, and the data it names in the file must exist. Check the sizes in the
section table with the real size of the file.

## pe-entry – entry point

**Messages:** `entry point $... is not inside a section`, `no entry point`,
`entry point ... is in section ..., which is not marked executable`

The address where the program starts must lie in a section that contains code and is marked executable.
With `.format pe` the entry is the label named by `.entry` or the start of `.code`.

## pe-imports – import table

**Messages:** `import directory ...`, `import 1: DLL name at RVA ... is not inside the image`,
`... import table runs past the end of the file`, `function name at RVA ...`

The import table (the list of DLLs and functions the program needs) is damaged or points outside
of the image. With `.format pe` and `.import` it is written correctly; with hand written tables
check the RVAs (relative addresses, from the image base) and the zero terminators of the lists.

## pe-dll-missing – DLL not found

**Message:** `DLL xyz.dll not found`

The program imports a DLL that is not in the Windows folder, the program folder or on the path.
Look at the spelling in `.import`. If it is a DLL of your own, put it next to the program.

## pe-function-missing – function not found in the DLL

**Message:** `function GetFoo not found in kernel32.dll`

The DLL exists, but does not export a function of this name. Typical causes:

- typo, or wrong case (exported names are case sensitive)
- the ANSI/Unicode ending is missing: many Windows functions are `MessageBoxA` and `MessageBoxW`,
  there is no plain `MessageBox`
- the function is in another DLL (`msvcrt.dll`, `user32.dll`, ...)

Related: `err-import`
