# Directives of the assembler

Directives are not instructions of the processor: they tell the assembler how to work or put data
into the file. F1 on such a line shows the section here (and, for `db`, `dw`, `dd`, `rva`, `org`,
`align`, the sections of the instruction list). Each section starts with `## ` and the names it explains.

## .arch – processor mode

Chooses which processor the following lines are written for. It is valid from this line to the next `.arch`.

**Syntax:** `.arch i386`, `.arch x86_real`, `.arch x64`, `.arch arm64`, `.arch thumb`

| Mode | Meaning |
| --- | --- |
| `i386` | 32 bit x86: Windows programs, 32-bit code |
| `x86_real` | 16 bit x86: DOS programs, boot sectors (real mode) |
| `x64` | 64 bit x86 (AMD64): Windows programs, PE32+ (r8..r15, rip relative) |
| `arm64` | ARM64 (A64, AArch64): Windows on ARM64, PE32+ |
| `thumb` | ARM Thumb-2: Windows on ARM, Raspberry Pi |

```asm
.arch x86_real
mov ax, 0x4C00   ; 16 bit: ax
int 0x21
```

The editor colours the lines after `.arch thumb` as ARM, and F1 shows the ARM help for them.

After `.arch x64` every line that is not a data or control directive is an x64 instruction (a label
needs a colon, or it stands in front of `db`, `dw`, `dd`, `dq`, `du`). Addresses have 64 bits: a label
as an operand is its address (`jmp loop`, `lea rcx, [text]`); as the address of a memory operand
without a register it is rip relative (`[rel text]` says the same explicitly). A jump forward is the
long form (`jmp short` chooses the short one); the size of a memory operand is written where no
register decides it (`add dword [rax], 1`). With `.format pe` the result is a PE32+ file (image base
`0x140000000`):

```asm
.format pe console
.arch x64
.import msvcrt.dll printf, exit
.code
start:
    sub rsp, 40            ; shadow space, stack aligned to 16
    lea rcx, [text]
    mov edx, 42
    call [printf]
    xor ecx, ecx
    call [exit]
.data
text db 'Answer: %d', 10, 0
```

AVX (VEX/EVEX) is not assembled.

For encodings that the text of an instruction does not say, the export of Dismonite writes prefix
words: `enc.load` (of two encodings of a register copy the one with the register as `reg` field:
`mov rcx, rbx` as 48 8B CB instead of 48 89 D9), `rex` and `rex.w` (a REX prefix that changes
nothing: `rex.w call [rax]` = 48 FF 10), `enc.alt` (of equal long encodings not the first). After
`short` or `near` a signed number is a displacement from the end of the instruction (`jz short +18`),
and `[0+rax+rax]` keeps its displacement byte of 0.

After `.arch arm64` every line that is not a data or control directive is an A64 instruction (syntax
as the output of the disassembler, `#` may be left out). Branches, `adr` and `ldr` (literal) take a
label; for addresses in `.data` a pair `adrp` and `add` with `:lo12:`. Windows on ARM64 loads only
images that fit any address: the code has to be position independent (`adr`/`adrp`, no absolute
addresses in the code). `.format pe` writes machine `0xAA64`:

```asm
.format pe console
.arch arm64
.import msvcrt.dll printf, exit
.code
start:
    stp x29, x30, [sp, #-16]!
    adrp x0, text
    add x0, x0, :lo12:text
    mov x1, #42
    adrp x16, printf
    ldr x16, [x16, :lo12:printf]   ; the address in the import table
    blr x16
    mov x0, #0
    adrp x16, exit
    ldr x16, [x16, :lo12:exit]
    blr x16
.data
text db 'Answer: %d', 10, 0
```

Without `.arch` and without `.format` Asmonite assumes a 32-bit Windows program: `.arch i386` and
`.format pe console`.

Related: `.format`, `err-arch`

## .format – kind of the output file

Chooses what the assembler writes. It stands once, before the first instruction or data.

**Syntax:** `.format pe`, `.format pe console`, `.format pe gui`, `.format binary`

- `pe` writes a Windows program: DOS stub, PE header, sections and import table are made by the assembler.
  Your source then has only code (`.code`), data (`.data`) and imports (`.import`). `console` (default) or `gui`
  is the kind of the window. It needs `.arch i386`, `x64`, `thumb` or `arm64`: this makes Windows programs
  for all four kinds (Intel and ARM, 32 and 64 bit). For `thumb` and `arm64` the code must not use absolute
  addresses (Windows on ARM places the image anywhere): labels are loaded pc-relative, `adr r0, text` and
  `ldr r3, printf` in Thumb, `adrp`/`add` and `adrp`/`ldr` in A64. With `thumb` code, data and imports are
  in one section, because `adr` and `ldr` reach only about 4 KB.
- `binary` writes the bytes as they stand: for boot sectors, DOS `.COM` programs, or a PE file whose
  headers you write yourself with `db`, `dw`, `dd`.

```asm
.format pe console
.import kernel32.dll ExitProcess
.code
start:
    push 0
    call [ExitProcess]
```

With `.format pe`, `org`, `section`, `segment` and `codeend` are not allowed: the assembler places the
sections itself.

Related: `.import`, `.code`, `.entry`, `.arch`

## .output – name of the output file

Names the file the assembler writes. Without `.output` the name is made from the source: its name with the
extension `.exe` (with `.format binary`: without extension, or `.exe` if the output starts with `MZ`).
`.output` says it directly, for example for a DOS `.COM` program, whose name should end in `.com`.

It stands once, before the first instruction or data. The file is written in the folder of the source; the
name has no folder part. Asmonite runs and debugs the file named here.

**Syntax:** `.output name`

```asm
.format binary
.output hello.com
.arch x86_real
```

Related: `.format`

## .code, .data – sections of a PE program

With `.format pe` they say where the following lines go: `.code` is the program, `.data` the data that
the program reads and writes. Without any of them everything is code.

```asm
.format pe console
.import kernel32.dll ExitProcess WriteFile GetStdHandle

.data
text:   db 'Hello', 13, 10
done:   dd 0

.code
start:
    ; ...
```

You can switch between them as often as you like; the lines of each are put together.

Related: `.format`, `.import`, `.entry`

## .import – imported functions

With `.format pe`: lists the functions of a DLL that the program calls. The assembler writes the import
table; each name is a label of its entry, so the call is `call [name]`.

**Syntax:** `.import dll function, function ...` (names separated by blanks or commas)

```asm
.import kernel32.dll ExitProcess WriteFile
.import msvcrt.dll printf

    push 0
    call [ExitProcess]
```

The names are case sensitive (`MessageBoxA`, not `messageboxa`) and must not be used as labels as well.
Press **F1** on such a call to see what the function wants.

Related: `.format`, `err-import`

## .entry – entry point

With `.format pe`: names the label where the program starts. Without `.entry` it starts at the first
instruction of `.code`.

**Syntax:** `.entry label`

```asm
.entry main
```

Related: `.format`, `.code`

## .imagebase – load address

The address at which Windows puts the program in memory (PE: the "image base"). It is `0x400000` unless
stated. Labels used as addresses (`push text`, `mov eax, text`) get this base added; `rva` subtracts it.

**Syntax:** `.imagebase number` (a multiple of 64 KB; after `.arch x64` up to 64 bits, default
`0x140000000`)

```asm
.imagebase 0x10000000   ; usual for DLLs
```

Related: `rva`, `org`

## du – text as UTF-16

Like `db`, but every character is a 16 bit value (2 bytes, low byte first): the format of the text of
Windows (`...W` functions, wide strings).

**Syntax:** `du value, ...`

```asm
du 'Hi', 0     ; 48 00 69 00 00 00
```

Numbers must fit in 16 bits.

Related: `db`, `dw`

## equ – a constant

`name equ expression` gives a number a name. The line itself produces no bytes; every later (or earlier) use of
the name is replaced by the value.

**Syntax:** `name equ expression`

```asm
size    equ 4*16          ; 64
        mov eax, size+1   ; mov eax, 65
msg:    db 'hello', 0
len     equ $-msg         ; 6: the length of the text
```

- The expression is evaluated where the name is used, so a constant may be defined behind its use and may
  use other constants (a constant that refers to itself is an error).
- `$` in the expression is the address of the `equ` line, so `len equ $-msg` right behind the data is the length
  of the data.
- Not for text: `name equ 'abc'` is not possible (a character in quotes counts as a number only).

### Expressions – calculating in the source

Wherever a number stands (operands, `db`, `dw`, `dd`, `dq`, `resb`, `align`, `org`), the assembler calculates.

| Operator | Meaning |
| --- | --- |
| `( )` | brackets |
| `-`, `+`, `~` (before a value) | sign, bitwise not |
| `*`, `/`, `%` | multiply, divide, remainder |
| `+`, `-` | add, subtract |
| `<<`, `>>` | shift left, right |
| `&`, `^`, `\|` | bitwise and, xor, or (in this order of precedence, weakest last) |

Numbers: decimal, `0x1F`, `1Fh`, `101b`, a character `'A'`. A label is its address; `label+4` and `label-4` are
addresses, and the **difference of two labels** is a number (the size of a piece of code or data):

```asm
start:  mov ecx, end-start        ; the size of the block
        ...
end:
        mov eax, [ebx+2*4]        ; mov eax, [ebx+8]: the constant part is calculated
        db 1+2, 3<<2, 'A'+1       ; 3, 12, 66
```

- A difference of labels needs the addresses; the assembler therefore runs more than once until they stay the
  same. Before the first run the value 1 is used, so an instruction that has a short and a long form may change its
  length once.
- Not possible: a number behind a label in a jump or call (`jmp start+4`), division by zero (an error with the line),
  and calculating with the address of a label other than adding or subtracting a number or subtracting another label.
- Registers and names that are no labels are left as they are: `[ebx*2+8-3]` becomes `[ebx*2+5]`.

## $, $$ – the current address

`$` is the address of the line it stands in; `$$` is the address of the start of the section (the first line after
`org`, `section`, `segment`, `.code`, `.data`, or the start of the file).

```asm
msg:    db 'hello'
        dd $-msg          ; 5: the bytes since msg
        dd $-$$           ; the bytes since the start of the section
```

`$` and `$$` are labels with a hidden name: `dd $` writes the address of the line like `dd label` does.

## rel32 – relative 32 bit address

Writes the distance from the end of these 4 bytes to a label as a 32 bit number: the operand of a near
`call` or `jmp`, when you put the bytes together yourself.

**Syntax:** `rel32 label`

```asm
db 0xE8           ; call
rel32 function    ; the distance to function
```

Normally you write `call function` and the assembler does the rest.

Related: `rva`, `call`, `jmp`

## codeend – close the code (hand written PE)

For a PE header that you wrote yourself: writes the length of the code (from the file position `0x200`
to here) into the header, in the size of the first section (offset `0x180`). It needs at least 0x200 bytes
before it.

With `.format pe` you do not need it: the assembler fills the header.

Related: `.format`, `err-codeend`

## section – a section of the file (hand written PE)

Notes that the bytes from here on belong to a section that is at the given virtual address (RVA) in
memory. Labels in it then get the right address in memory, not just the position in the file.

**Syntax:** `section rva`

```asm
section 0x1000    ; .text at 0x1000
; ... code ...
section 0x2000    ; .idata at 0x2000
```

Not allowed with `.format pe` (use `.code`/`.data`). It is not the NASM `section .text`.

Related: `org`, `segment`, `.format`

## segment – a segment of a DOS program

For DOS programs with several segments (MZ files): the bytes from here on are in the segment with this
number. Labels in it get the segment and offset the far calls and jumps need. `segment 0` also marks the
start of the DOS header.

**Syntax:** `segment number`

Related: `section`, `org`, `.arch`
