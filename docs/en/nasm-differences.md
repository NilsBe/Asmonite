# The Asmonite assembler compared to NASM

The source looks like NASM (Intel syntax, `;` for comments, `mov eax,[ebx+ecx*4+8]`), and
the disassembler writes NASM syntax. The assembler is, however, **not NASM compatible**.
This page lists where it differs. Every statement was tried with `asmoc` (state of
2026-10-06); the bytes are given where they help.

The basic idea: Asmonite rebuilds programs **byte by byte from the source** (every byte of the
EXE is in the source, the PE header too). So many things a programmer's assembler like NASM
offers do not exist (macros, linker directives), and a few that NASM does not
have do (choosing the encoding, `section <address>`, `.format pe`).

## 1. Structure and directives

| NASM | Asmonite |
|---|---|
| `bits 16` / `bits 32` | `.arch x86_real` / `.arch i386` (default: 32 bit). `bits 32` is an error (`unexpected "32"`), so is `use32` (`unsupported instruction`). |
| `org 0x100` sets the load address, writes no bytes | `org 0x100` fills the output with `00` up to the **file position** 0x100 (after a `nop` the file is 257 bytes long). If the position is already past it, that is an **error** (`org 0x1: the output is already at 0x3`), since 2026-10-07; before, it was set back silently and later bytes overwrote. `align 0x200` fills up to the next multiple. |
| `section .text`, `.data`, `.bss` | `section <number>`: starts a section at the current file position with this virtual address (RVA), e.g. `section 0x1000`. The name is not evaluated. See `src/tests/cases/section_three.asm`. |
| – | `segment <number>` (DOS programs): starts a segment with this segment value; `segment 0` also marks the start of the load module (what comes before it, the MZ header, does not count for segment addresses). |
| `align 4` fills code with `nop` | `align 4` always fills with `00`. |
| `global`, `extern` | do not exist (`unknown instruction: "global"`). Imports: `.import` (only with `.format pe`). |
| `resb 4`, `resw`, `resd`, `resq` | with `.format pe` only at the end of a section (`.code`/`.data`): the space is not in the file (VirtualSize > RawSize). Only labels and more `resX` may follow. Without `.format pe` zero bytes. |
| `x equ 5` | as NASM: `name equ expression`, also behind its use; the line writes no bytes. See [expressions](#2-numbers-and-expressions). |
| `times 4 db 0`, `incbin` | do not exist (error `unknown instruction` or `unexpected …`). |
| macros, `%define`, `%include` | do not exist, there is no preprocessor. |
| `$`, `$$` | as NASM: `$` is the address of the line, `$$` the start of the section (after `org`, `section`, `segment`, `.code`, `.data`, or the start of the file): `len equ $-msg`, `dd $-start`. |
| `db 'AB', 0, 10` | as NASM. **Single** quotes only: `db "AB"` is an error. |
| `dw`, `dd` | as NASM. There is no `dq`. |
| `dw __utf16__('AB')` | `du 'AB', 0`: every character as a 16-bit word (UTF-16, little endian), a number as well (`du 'Gr', 0x00E4, 'n', 0`). Only in Asmonite. |
| `dd label` | gives the **virtual address** (ImageBase + RVA, default ImageBase 0x400000, changed with `.imagebase 0x10000000`), not the distance from the start. The same for a label as address in an instruction (`mov eax,[label]`, `push dword label`). |
| – | `rva label` writes the RVA (32 bit), `rel32 label` the 32-bit distance from its end to the label. Asmonite only. |
| – | `codeend` writes the size of the code into a hand-written PE header (offset 0x180): output length − 0x200. Asmonite only. |
| – | `.format binary` / `pe [console\|gui]`, `.import dll name`, `.code`, `.data`, `.entry label`: create the PE header and import table themselves, see [src/assembler/README.md](../../src/assembler/README.md). Asmonite only. |

## 2. Numbers and expressions

| NASM | Asmonite |
|---|---|
| `0x1F`, decimal, `-1` | as NASM. `017` is decimal 17, as in NASM. |
| `1Fh`, `0b101`, `101b` | work (the assembler writes them as `0x1F` and decimal before the core sees them). |
| `0o17`, `1_000` | do not exist (`invalid number`). |
| `'A'` | as NASM (one character); `db 'AB'` writes two bytes. |
| `db 256` | error (`value out of range for db`); NASM warns and truncates. |
| `1+2`, `'A'+1`, `end-start`, `msg_len equ $-msg` | **as NASM**: `* / % + - << >> & ^ \| ~` and brackets, wherever a number stands (operands, `db`, `dw`, `dd`, `dq`, `resb`, `align`, `org`); the difference of two labels is a number; `label+4` and `label-4` are addresses (`mov eax, table+4`, `dd table+4`; not in a jump or call). `/` is a signed division (NASM: `/` unsigned, `//` signed); `%` is the remainder; there is no `%%`. A difference of labels makes the assembler run more than once (until the addresses stay the same). |

## 3. Names, case, comments

| NASM | Asmonite |
|---|---|
| labels are case sensitive | **labels are not**: `L1` and `l1` are the same label. |
| `label:` with a colon | the colon is **optional**: `l1` alone on a line or `l1 nop` is a label. Exception: an x86 instruction the assembler does not know (`cpuid`, `pause`, `str`, …) alone on a line is an error (`unsupported instruction`); as a label it needs the colon (`str:`) or a statement behind it (`str db 'x'`). Any other name alone (also a typo like `nopp`) is a label. |
| `.local` is a local label (valid until the next global one) | `.l` is an ordinary label **without scope**: two `.l` in a file are an error (`redefinition of Label`). |
| instructions: case does not matter | it does not matter, **but**: if an instruction starts with an **upper-case letter**, the assembler chooses the **second encoding** where there are two: `mov eax,ebx` = `8B C3`, `MOV eax,ebx` = `89 D8`. This allows rebuilding a program byte by byte. Registers in upper case change nothing (`mov EAX,EBX` = `8B C3`). |
| comments `;` | only `;`. `#` and `//` are errors. |
| label and instruction on one line (`l: db 1`) | works. Two instructions on one line do not (`nop nop` is an error), as in NASM. |

## 4. Jumps and calls

| NASM | Asmonite |
|---|---|
| `jmp label`, `jmp short label`, `jmp near label` | as NASM. Without a size the assembler picks the shortest form. |
| `jmp 0x401000` jumps to the **address** | a number is the **displacement**: `jmp 5` = `EB 05`, `call 0x10` = `E8 10 00 00 00`, `jz 0x10` = `74 10`. |
| – | `jmp short -2`, `jz near +300`, `call near -5`: size and displacement **with a sign**, counted from the end of the instruction. This is how the Dismonite export writes jumps (`jmp +5` = displacement only, shortest form). `jmp short +200` is an error. |
| `jmp far 0x1234:0x5678` | as NASM; `jmp 0x1234:0x5678` works too (`EA 78 56 34 12` in `.arch x86_real`). |
| `loop label`, `jecxz label`, `jcxz label` | with a label only **with `short`**: `loop short l` works, `loop l` is an error (`cmd not found`). `loop short -2` works. |
| `ret`, `retn`, `retf`, `ret 4` | as NASM. |
| `jmp [eax]`, `call [eax]`, `jmp eax` | as NASM (`FF 20`, `FF 10`, `FF E0`). |

## 5. Operands and addressing

| NASM | Asmonite |
|---|---|
| `mov byte [ebx], 1` | as NASM; also `byte ptr [ebx]` (MASM spelling). Sizes: `byte`, `word`, `dword`; `mov word [ebx],0` = `66 C7 03 00 00`. If a register decides the size already, the register counts (`les bx,dword [x]` in 16 bit without `66`). |
| `[ebx+ecx*4+8]`, `[es:ebx]`, `es mov eax,[ebx]` | as NASM. |
| `mov eax, label` / `mov eax, [label]` | as NASM: the address as a number / memory at the label. `mov eax, offset label` (MASM) does not exist. |
| `mov eax,[label+4]`, `[tab+ebx*4+8]`, `[ebp-4]`, `[0x401000+4]` | as NASM: labels, numbers and registers can be mixed in an address, numbers are added, a minus continues the address. A label in the address is the 32-bit displacement (16 bit with 16-bit addressing). Expressions like `[tab+2*4]` or `[a-b]` do not work. |
| `[eax+0x80]` is `[eax+128]` (32-bit displacement `8B 80 80 00 00 00`) | **Careful, see section 7:** a number from 0 to 255 is written as an 8-bit displacement, `[eax+0x80]` and `[eax+128]` give `8B 40 80`, which is `[eax-128]`. From 256 the displacement is 32 bit, small negative numbers (-128 to -1) are 8 bit. With `dword` in the brackets it is 32 bit: `[dword eax+0x80]` = `8B 80 80 00 00 00`. |
| `push word 5` gives `66 6A 05` (32 bit) | as NASM. `push byte 5` = `6A 05`. |
| `mul ebx`, `div ebx`, `idiv ebx` | the accumulator is written: `mul eax,ebx` (`F7 E3`), `div al,bl` (`F6 F3`). `mul ebx` is an error (`cmd not found`). |
| `imul ebx`, `imul eax,ebx`, `imul eax,[ebx],10`, `imul eax,10` | as NASM (since 2026-10-06): one operand `F7 EB`, two `0F AF C3`, three `6B 03 0A`, `imul eax,10` = `imul eax,eax,10`. Before, `imul eax,ebx` was the one-operand form `F7 EB`; the older spelling `imul al,bl` (= `imul bl`) still works. |
| operand size from `.arch` | Without `.arch` it is 32 bit: `mov ax,5` = `66 B8 05 00`. In `.arch x86_real` it is `B8 05 00` and `mov eax,5` has `66`. |
| `movsd`, `stosd`, `pushad` … | names with a size as in NASM, see [src/assembler/README.md](../../src/assembler/README.md). |

## 6. Instruction set

The assembler knows **177 mnemonics** (393 encodings). Everything a 386 program normally needs is
there; these are **missing**, among others:

- the whole **x87 FPU** (`fld`, `fstp`, `fadd`, …), **MMX/SSE** (`movaps`, …)
- `cmovcc`, `bswap`, `cmpxchg`, `xadd`, `shld`, `cpuid`, `rdtsc`, `pause`
- `lgdt`, `lidt`, `lmsw`, `lar`, `lsl`, `bound` and other system instructions
- `int3` (use `int 3`)

The current list of instructions the disassembler writes that cannot be assembled yet is in
`src/tests/instr_known.txt` (179 families).

Supported are: `aaa aad aam aas adc add and bsf bsr bt btc btr bts call cbw cdq clc cld cli clts
cmc cmp cmpsb cmpsd cmpsw cwd cwde daa das dec div enter hlt idiv imul in inc insb insd insw int into
iret iretd ja jae jb jbe jc jcxz je jecxz jg jge jl jle jmp jna jnae jnb jnbe jnc jne jng jnge jnl jnle
jno jnp jns jnz jo jp jpe jpo js jz lahf lds lea leave les lock lodsb lodsd lodsw loop loope loopne
loopnz loopz mov movsb movsd movsw movsx movzx mul neg nop not or out outsb outsd outsw pop popa popad
popf popfd push pusha pushad pushf pushfd rcl rcr rep repne ret retf retn rol ror sahf sal sar sbb scasb
scasd scasw seta setae setb setbe setc sete setg setge setl setle setna setnae setnb setnbe setnc setne
setng setnge setnl setnle setno setnp setns setnz seto setp setpe setpo sets setz shl shr shrd stc std
sti stosb stosd stosw sub test wait xchg xlatb xor`
(plus the prefixes `rep`, `repe`, `repz`, `repne`, `repnz`, `lock` and segment prefixes).

## 7. Known problems (bugs, not intended)

These are bugs that are to be fixed. Avoid them until then:

1. **Displacements from 128 to 255 are negative.** `mov eax,[eax+0x80]` and `mov eax,[eax+128]` are assembled
   as `8B 40 80`, which is `[eax-128]`, **without a message**. The reason: older sources (e.g. `tpc.asm` with 944
   places) contain 8-bit displacements as an unsigned number (`[0xEC+ebp]`) and have to give the same bytes. The
   disassembler now writes them with a sign (`[ebp-0x14]`). Workaround: `[dword eax+0x80]`. Once these sources are
   generated again, the assembler can take 128 to 255 as a 32-bit value, as NASM does.
2. **Constants from 128 to 255 are negative** where the instruction sign-extends an 8-bit constant
   (`83 /x ib`, `6A`, `6B`): `add ebx,0xF0` gives `83 C3 F0`, which is `add ebx,-16`; `push 0x80` is
   `push -128`; `or word [ebx],0x80` ors with `0xFF80`, **without a message**. NASM takes the long form
   (`81 C3 F0 00 00 00`). The reason is the same as in point 1: the disassembler writes `83 C0 F0` as
   `add eax,0xF0`. Workaround: `dword` before the number (`add ebx,dword 0xF0`). The other way round,
   `add ebx,-16` gets the long form (`81 C3 F0 FF FF FF`) instead of the short one.
3. **`section .text`** is accepted, but the name is not evaluated; the section gets no address.
4. **An absolute 32-bit address in 16-bit code** (`mov al,[0x12345678]` in `.arch x86_real`): the address is
   cut to 16 bit, the `67` prefix is missing.

Further limits of the assembler are in [src/assembler/README.md](../../src/assembler/README.md),
the tests for it in [src/tests/README.md](../../src/tests/README.md).
