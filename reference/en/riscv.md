# RISC-V instructions (RV32, Hazard3)

The instruction info of Asmonite (F1) for RISC-V (`.arch riscv32`), as the two RISC-V cores (Hazard3) of the Raspberry Pi Pico 2 have it: the base set RV32I, the extensions M (multiply and divide), A (atomic), Zicsr (control registers), Zifencei, C and Zcb (short 16-bit forms) and the bit manipulation sets Zba, Zbb, Zbs, Zbc and Zbkb.

Each section starts with `## ` and the names it explains; long lists stand in a line `<!-- names: ... -->`. Atomic instructions with `.aq`, `.rl` or `.aqrl` (`amoadd.w.aq`) are found under their name without that ending.

New to RISC-V? Read `riscv` (the processor in short), `registers`, `pseudo` and `encoding` first.

## riscv, rv32 – the processor in short
<!-- names: riscv, rv32, hazard3 -->

RISC-V is an open instruction set. A RV32 core has:

- **32 general registers** `x0` to `x31`, each 32 bits wide. `x0` always reads as 0 and ignores writes. The pc is not one of them.
- **No flags.** Comparing and branching is one instruction: `beq a0, a1, label` jumps if the two registers are equal. There is no carry or zero flag, no `cmp`.
- **Load and store.** Only `lw`, `sw` and their relatives touch memory; everything else works on registers.
- **Instructions of 4 bytes** (aligned to 2); with the C extension many have a short form of 2 bytes. Little endian.
- **No push and pop.** The stack is an ordinary memory area; `sp` points to it and you move it yourself (`addi sp, sp, -16`, `sw ra, 12(sp)`).
- **Calls** put the return address into a register: `jal ra, function` sets `ra`, `ret` jumps back. A function that calls another one must save `ra` first.

The names of the registers and what the usual program does with them are in `registers`. The instruction forms are in `encoding`, the short names the assembler adds are in `pseudo`.

Related: `registers`, `encoding`, `pseudo`, `csr`

## registers – x0 to x31 and their names
<!-- names: registers, abi, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, t0, t1, t2, t3, t4, t5, t6, s0, fp, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, a0, a1, a2, a3, a4, a5, a6, a7 -->

Every register has a number (`x5`) and a name that says what a program usually does with it (the "ABI"). Both can be written; the debugger shows the names.

| Register | Name | Use | Kept by a call? |
|---|---|---|---|
| `x0` | `zero` | always 0 | – |
| `x1` | `ra` | return address | no |
| `x2` | `sp` | stack pointer | yes |
| `x3` | `gp` | global pointer | – |
| `x4` | `tp` | thread pointer | – |
| `x5`–`x7` | `t0`–`t2` | temporaries | no |
| `x8` | `s0`, `fp` | saved register, frame pointer | yes |
| `x9` | `s1` | saved register | yes |
| `x10`–`x11` | `a0`–`a1` | arguments and return values | no |
| `x12`–`x17` | `a2`–`a7` | arguments | no |
| `x18`–`x27` | `s2`–`s11` | saved registers | yes |
| `x28`–`x31` | `t3`–`t6` | temporaries | no |

"Kept by a call" means: a function that uses `s0` must give it back unchanged; it may change `t0` and `a0` as it likes. A function gets its first arguments in `a0` to `a7` and returns its result in `a0` (and `a1`).

In a small program for the Pico 2 you can use all registers as you like; the table matters when you call code of others (the SDK, the boot ROM).

Related: `zero`, `ra`, `sp`, `pseudo`

## zero – the register that is always 0
<!-- names: zero -->

`x0` (`zero`) reads as 0 and discards what is written to it. That replaces several instructions other processors have: `mv a0, zero` clears a register, `beq a0, zero, label` tests for 0, and `jal zero, label` is a jump that does not save a return address (`j`). The assembler uses it for `nop` (`addi zero, zero, 0`).

Related: `mv`, `j`, `beqz`

## ra – return address
<!-- names: ra -->

`x1` (`ra`) holds the address to which a function returns. `jal ra, function` (or `call`) puts the address of the next instruction there; `ret` is `jalr zero, 0(ra)`. A function that calls others must save `ra` on the stack first and restore it before `ret`:

```asm
function:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call helper
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
```

Related: `jal`, `ret`, `sp`

## sp – stack pointer
<!-- names: sp -->

`x2` (`sp`) points to the end of the stack, which grows downwards. There is no `push` or `pop`: make room with `addi sp, sp, -16`, store with `sw reg, 12(sp)`, and give the room back at the end. The ABI wants `sp` to be a multiple of 16 when you call code of others. The program must set `sp` itself at the start; on the Pico 2 the end of the RAM is `0x20082000`.

Related: `ra`, `sw`, `lw`

## gp, tp – global pointer and thread pointer
<!-- names: gp, tp -->

`x3` (`gp`) and `x4` (`tp`) have a meaning only for compiled programs: the linker can point `gp` into the data area so that variables are reached with short offsets, and `tp` points to the data of the current thread. In an assembler program they are two more registers.

## pseudo – the short names of the assembler
<!-- names: pseudo, pseudo-instructions -->

The assembler knows names for common combinations; they are no instructions of the processor, and the disassembler shows them again.

| Written | Is | Does |
|---|---|---|
| `nop` | `addi zero, zero, 0` | nothing |
| `li rd, n` | `addi rd, zero, n` or `lui` + `addi` | load a number |
| `la rd, label` | `auipc` + `addi` | load an address (pc relative) |
| `mv rd, rs` | `addi rd, rs, 0` | copy |
| `not rd, rs` | `xori rd, rs, -1` | invert |
| `neg rd, rs` | `sub rd, zero, rs` | negate |
| `seqz`, `snez` | `sltiu rd, rs, 1`, `sltu rd, zero, rs` | 1 if rs is 0 / not 0 |
| `j label` | `jal zero, label` | jump |
| `jr rs` | `jalr zero, 0(rs)` | jump to a register |
| `call label` | `auipc ra` + `jalr ra` | call a function |
| `ret` | `jalr zero, 0(ra)` | return |
| `beqz`, `bnez`, `blez`, `bgez`, `bltz`, `bgtz` | `beq`/`bne`/`bge`/`blt` against `zero` | compare with 0 and branch |
| `bgt`, `ble`, `bgtu`, `bleu` | `blt`/`bge`/`bltu`/`bgeu` with the registers swapped | the other comparisons |
| `csrr`, `csrw`, `csrs`, `csrc` | `csrrs`, `csrrw` ... with `zero` | read, write, set, clear a control register |

Related: `li`, `la`, `mv`, `j`, `ret`, `call`

## encoding – the instruction forms
<!-- names: encoding, formats -->

Every instruction has 32 bits (the short forms 16, see `compressed`). Six forms put the registers and numbers in the same places, so the processor decodes them quickly:

- **R** – three registers: `add rd, rs1, rs2`
- **I** – two registers and a 12-bit number (-2048 to 2047): `addi rd, rs1, imm`, `lw rd, imm(rs1)`, `jalr`
- **S** – stores, a 12-bit offset: `sw rs2, imm(rs1)`
- **B** – branches, a 13-bit offset in steps of 2 (±4 KB): `beq rs1, rs2, target`
- **U** – a 20-bit number for the upper bits of a register: `lui rd, imm20`, `auipc`
- **J** – jump, a 21-bit offset in steps of 2 (±1 MB): `jal rd, target`

That is why a 32-bit constant takes two instructions: `lui` loads the upper 20 bits and `addi` the lower 12 (`li` does that for you). Branch targets are written as labels; the assembler computes the distance. A branch to a place more than 4 KB away is an error: turn it around (`bne` over a `j`).

Related: `li`, `lui`, `beq`, `jal`

## compressed – the 16-bit forms (C)
<!-- names: compressed, c.extension -->

With the C extension (and Zcb) the core also runs instructions of 2 bytes. They are the most common instructions with fewer choices: only 8 of the registers (`s0`, `s1`, `a0` to `a5`), small numbers, the target register often the same as a source. Compiled code (the Pico SDK) uses them a lot, so you meet them in the disassembly of other code, written with a `c.` in front: `c.addi sp, -16`, `c.lw a0, 4(a1)`, `c.jr ra`.

The assembler of Asmonite writes the normal 4-byte form of every instruction you type; it does not shorten them. Do not write `c.` instructions yourself, they are for reading. The meaning is that of the long instruction.

| Short form | Is |
|---|---|
| `c.li`, `c.lui`, `c.addi`, `c.addi16sp`, `c.addi4spn` | `addi` (or `lui`) with small numbers or on `sp` |
| `c.mv`, `c.add`, `c.sub`, `c.and`, `c.or`, `c.xor` | arithmetic on two registers |
| `c.andi`, `c.slli`, `c.srli`, `c.srai` | `andi`, `slli`, `srli`, `srai` |
| `c.lw`, `c.sw`, `c.lwsp`, `c.swsp` | `lw`, `sw`, also relative to `sp` |
| `c.lbu`, `c.lhu`, `c.lh`, `c.sb`, `c.sh` (Zcb) | byte and halfword loads and stores |
| `c.zext.b`, `c.sext.b`, `c.zext.h`, `c.sext.h`, `c.not`, `c.mul` (Zcb) | one-register forms |
| `c.j`, `c.jal`, `c.jr`, `c.jalr`, `c.beqz`, `c.bnez` | jumps and branches |
| `c.nop`, `c.ebreak`, `c.unimp` | `nop`, `ebreak`, an illegal instruction (all bits 0) |

Related: `encoding`, `addi`, `lw`, `jal`

## c.addi, c.li, c.lui, c.addi16sp, c.addi4spn – compressed addition and loading a number
<!-- names: c.addi, c.li, c.lui, c.addi16sp, c.addi4spn, c.nop -->

- `c.addi rd, n` adds a number (-32 to 31) to `rd`; with `rd` = `zero` and 0 it is `c.nop`
- `c.li rd, n` loads a number from -32 to 31
- `c.lui rd, n` loads `n` into the upper 20 bits
- `c.addi16sp sp, n` adds a multiple of 16 to `sp` (making and freeing stack room)
- `c.addi4spn rd, sp, n` puts `sp` + a multiple of 4 into one of the 8 short registers (the address of a local variable)

Related: `compressed`, `addi`, `li`, `lui`

## c.mv, c.add, c.sub, c.and, c.or, c.xor, c.andi, c.slli, c.srli, c.srai, c.mul, c.not, c.zext.b, c.sext.b, c.zext.h, c.sext.h – compressed arithmetic
<!-- names: c.mv, c.add, c.sub, c.and, c.or, c.xor, c.andi, c.slli, c.srli, c.srai, c.mul, c.not, c.zext.b, c.sext.b, c.zext.h, c.sext.h -->

The 16-bit forms of `mv`, `add`, `sub`, `and`, `or`, `xor`, `andi`, `slli`, `srli`, `srai`; `c.mul`, `c.not` (invert), `c.zext.b`/`c.zext.h` (clear the upper bits) and `c.sext.b`/`c.sext.h` (copy the sign) belong to Zcb. In most of them the first register is also the source and the result: `c.sub a0, a1` is `sub a0, a0, a1`.

Related: `compressed`, `add`, `and`, `slli`, `mul`

## c.lw, c.sw, c.lwsp, c.swsp, c.lbu, c.lhu, c.lh, c.sb, c.sh – compressed loads and stores
<!-- names: c.lw, c.sw, c.lwsp, c.swsp, c.lbu, c.lhu, c.lh, c.sb, c.sh -->

The 16-bit forms of `lw`, `sw`, `lb`/`lbu`, `lh`/`lhu`, `sb`, `sh`. `c.lwsp` and `c.swsp` address relative to `sp` and are what a compiler uses to save and restore registers (`c.swsp ra, 12(sp)`). The offset is small and a multiple of the size.

Related: `compressed`, `lw`, `sw`, `sp`

## c.j, c.jal, c.jr, c.jalr, c.beqz, c.bnez, c.ebreak, c.unimp – compressed jumps
<!-- names: c.j, c.jal, c.jr, c.jalr, c.beqz, c.bnez, c.ebreak, c.unimp -->

`c.j` and `c.jal` jump (±2 KB), `c.jr ra` is `ret`, `c.jalr` calls the address in a register, `c.beqz`/`c.bnez` branch (±256 bytes) on a register that is 0 or not. `c.ebreak` is `ebreak`. `c.unimp` is the code 0x0000, which is no instruction: a core that runs into empty memory ends here.

Related: `compressed`, `jal`, `jalr`, `ret`, `beqz`

## lui – load the upper 20 bits
<!-- names: lui -->

`lui rd, n` puts `n` (0 to 0xFFFFF) shifted left by 12 into `rd`; the lower 12 bits become 0. With `addi` it builds any 32-bit number: `lui t0, 0x40028` and `addi t0, t0, 0xcc` give 0x400280cc. `li` does this for you.

```asm
lui t0, 0xd0000       ; t0 = 0xd0000000
```

Related: `li`, `addi`, `auipc`

## auipc – add the upper 20 bits to the pc
<!-- names: auipc -->

`auipc rd, n` puts the address of this instruction + `n` shifted left by 12 into `rd`. With `addi` or a load it reaches any address relative to the pc, whatever the program is loaded to (`la` and `call` use it).

Related: `la`, `call`, `lui`

## li – load a number
<!-- names: li -->

**Syntax:** `li rd, number`

Loads any 32-bit number. A pseudo instruction: one `addi` for numbers from -2048 to 2047, `lui` alone if the lower 12 bits are 0, else `lui` + `addi`. If the number is a label or only known later, it is always two instructions.

```asm
li   t0, 1000000      ; lui t0, 0xf4 ; addi t0, t0, 0x240
li   a0, -1
li   sp, 0x20082000
```

Related: `lui`, `addi`, `la`, `mv`

## la – load an address
<!-- names: la -->

**Syntax:** `la rd, label`

Loads the address of a label with `auipc` + `addi`, relative to the pc. Use it for data and functions. Unlike `li rd, label` it also works if the program sits at another address than assembled.

Related: `li`, `auipc`, `call`

## mv, not, neg, seqz, snez, sltz, sgtz, nop – short names for common moves
<!-- names: mv, not, neg, seqz, snez, sltz, sgtz, nop -->

- `mv rd, rs` copies a register (`addi rd, rs, 0`)
- `not rd, rs` inverts all bits (`xori rd, rs, -1`)
- `neg rd, rs` negates (`sub rd, zero, rs`)
- `seqz rd, rs` sets `rd` to 1 if `rs` is 0, else 0
- `snez rd, rs` sets `rd` to 1 if `rs` is not 0
- `sltz rd, rs` sets `rd` to 1 if `rs` is negative, `sgtz` if it is greater than 0
- `nop` does nothing

Related: `pseudo`, `addi`, `slt`

## add, sub – addition and subtraction
<!-- names: add, sub -->

**Syntax:** `add rd, rs1, rs2` &nbsp; `sub rd, rs1, rs2`

`rd = rs1 + rs2` or `rs1 - rs2`. The upper bits of the result are lost; there is no carry. The sum of two numbers with a carry has to be built with `sltu`: `sltu t0, a0, a1` after `add a0, a0, a1` tells whether it wrapped around.

```asm
add a0, a1, a2     ; a0 = a1 + a2
sub t0, t0, t1
```

Related: `addi`, `sltu`, `neg`

## addi – add a number
<!-- names: addi -->

**Syntax:** `addi rd, rs1, n` (n from -2048 to 2047)

`rd = rs1 + n`. There is no `subi`: use a negative number. `addi` with `zero` loads a small number, with 0 it copies a register, and with `sp` it moves the stack.

```asm
addi t2, t2, -1      ; count down
addi sp, sp, -16     ; make room on the stack
```

Related: `add`, `li`, `mv`

## and, or, xor, andi, ori, xori – bit operations
<!-- names: and, or, xor, andi, ori, xori -->

**Syntax:** `and rd, rs1, rs2` &nbsp; `andi rd, rs1, n`

Bit by bit. The immediate forms take a number from -2048 to 2047 (sign extended: `andi a0, a0, -1` keeps everything, `xori a0, a0, -1` is `not`).

```asm
andi t0, t0, 0xff    ; keep the low byte
ori  a0, a0, 1       ; set bit 0
```

Related: `sll`, `not`, `bset`, `andn`

## sll, srl, sra, slli, srli, srai – shifts
<!-- names: sll, srl, sra, slli, srli, srai -->

**Syntax:** `sll rd, rs1, rs2` &nbsp; `slli rd, rs1, n` (n from 0 to 31)

- `sll`/`slli` shift left, new bits are 0 (multiply by a power of 2)
- `srl`/`srli` shift right, new bits are 0 (unsigned division)
- `sra`/`srai` shift right and keep the sign (signed division by a power of 2, rounding down)

With a register only the low 5 bits count (0 to 31).

```asm
slli t0, t0, 2      ; t0 = t0 * 4
srai a0, a0, 1      ; a0 = a0 / 2, signed
```

Related: `rol`, `ror`, `and`

## slt, sltu, slti, sltiu – compare and set
<!-- names: slt, sltu, slti, sltiu -->

**Syntax:** `slt rd, rs1, rs2` &nbsp; `sltiu rd, rs1, n`

`rd` becomes 1 if `rs1` is less than `rs2` (or the number), else 0. `slt` and `slti` compare as signed numbers, `sltu` and `sltiu` as unsigned. This is what RISC-V has in place of flags: you get the result of a comparison in a register.

```asm
slt   t0, a0, a1     ; t0 = 1 if a0 < a1 (signed)
sltiu t0, a0, 1      ; t0 = 1 if a0 == 0 (that is seqz)
```

Related: `seqz`, `blt`, `bltu`

## mul, mulh, mulhsu, mulhu, div, divu, rem, remu – multiply and divide (M)
<!-- names: mul, mulh, mulhsu, mulhu, div, divu, rem, remu -->

**Syntax:** `mul rd, rs1, rs2`

- `mul` the lower 32 bits of the product
- `mulh`, `mulhu`, `mulhsu` the upper 32 bits (signed × signed, unsigned × unsigned, signed × unsigned) – together with `mul` the 64-bit product
- `div`, `divu` quotient (signed, unsigned); `rem`, `remu` remainder

Division by 0 does not trap: the quotient is all ones (-1) and the remainder is the dividend. `div` of the most negative number by -1 gives that number, remainder 0.

```asm
mul  a0, a0, a1
divu t0, a0, t1
remu t1, a0, t1
```

Related: `slli`, `sll`

## lw, lh, lhu, lb, lbu – load from memory
<!-- names: lw, lh, lhu, lb, lbu -->

**Syntax:** `lw rd, offset(rs1)` (offset from -2048 to 2047)

Loads from the address `rs1 + offset`: `lw` a word (4 bytes), `lh`/`lhu` a halfword (2), `lb`/`lbu` a byte. The ones without `u` copy the sign into the upper bits, the ones with `u` fill with 0. The address of a word must be a multiple of 4, of a halfword a multiple of 2; otherwise the core raises an exception.

```asm
lw  t2, 8(t0)        ; t2 = the word at t0 + 8
lbu a0, 0(a1)        ; one byte, unsigned
```

To load from a label, put its address into a register first (`la`).

Related: `sw`, `la`, `lui`

## sw, sh, sb – store to memory
<!-- names: sw, sh, sb -->

**Syntax:** `sw rs2, offset(rs1)`

Stores the register `rs2` (the value comes first, then the address `rs1 + offset`): `sw` 4 bytes, `sh` the low 2 bytes, `sb` the low byte. The peripheral registers of the Pico 2 are written with `sw`.

```asm
sw t1, 0(t0)         ; write t1 to the address in t0
sw ra, 12(sp)        ; save the return address
```

Related: `lw`, `sp`

## beq, bne, blt, bge, bltu, bgeu – conditional branches
<!-- names: beq, bne, blt, bge, bltu, bgeu -->

**Syntax:** `beq rs1, rs2, label`

Compare two registers and jump to the label if the condition holds, else go on: equal, not equal, less than (signed), greater or equal (signed), less than and greater or equal as unsigned numbers. The target may be up to 4 KB before or after. For the other comparisons swap the registers: `bgt a, b, l` is `blt b, a, l`.

```asm
wait:
    lw   t2, 8(t0)
    bne  t2, t1, wait    ; until both bits are set
```

Related: `beqz`, `bnez`, `j`, `slt`

## beqz, bnez, blez, bgez, bltz, bgtz, bgt, ble, bgtu, bleu – branches against 0 and the other comparisons
<!-- names: beqz, bnez, blez, bgez, bltz, bgtz, bgt, ble, bgtu, bleu -->

Short names of the assembler: `beqz rs, label` is `beq rs, zero, label`, `bnez` is `bne`, `bltz` `blt`, `bgez` `bge`, `blez` `bge zero, rs`, `bgtz` `blt zero, rs`. `bgt`, `ble`, `bgtu`, `bleu` swap the two registers of `blt`, `bge`, `bltu`, `bgeu`.

```asm
delay:
    addi t2, t2, -1
    bnez t2, delay
```

Related: `beq`, `pseudo`

## jal, j – jump and link
<!-- names: jal, j -->

**Syntax:** `jal rd, label` &nbsp; `jal label` &nbsp; `j label`

Jumps to the label (±1 MB) and puts the address of the next instruction into `rd`. `jal label` uses `ra`: that is a call. `j label` (`jal zero, label`) jumps without saving anything.

```asm
    jal  ra, function    ; call
    j    loop            ; jump
```

Related: `jalr`, `call`, `ret`

## jalr, jr, ret, call, tail – jump to a register, call, return
<!-- names: jalr, jr, ret, call, tail -->

**Syntax:** `jalr rd, offset(rs1)` &nbsp; `jr rs` &nbsp; `ret` &nbsp; `call label` &nbsp; `tail label`

`jalr` jumps to `rs1 + offset` and puts the return address into `rd`. `jr rs` jumps to a register; `ret` is `jr ra`. `call label` reaches any address (`auipc` + `jalr`); `tail label` is the same as a jump (it keeps `ra`) and is used for the last call of a function.

```asm
    la   t0, handler
    jalr t0              ; call the address in t0
    ret
```

Related: `jal`, `ra`, `la`

## ecall, ebreak, mret, sret, wfi – system instructions
<!-- names: ecall, ebreak, mret, sret, wfi -->

- `ebreak` stops the core in the debugger (when the debugger is attached), else it raises an exception. Put it where you want a stop without a breakpoint.
- `ecall` calls the environment: an exception for the system software; a small program does not use it.
- `mret` returns from an exception handler (see `csr`): the pc becomes `mepc`. `sret` does the same for the supervisor mode, which the Hazard3 does not have.
- `wfi` waits for an interrupt; the core sleeps until one comes.

Related: `csr`, `fence`

## fence, fence.i – memory order
<!-- names: fence, fence.i -->

`fence` makes sure that the memory accesses before it are done (seen by other cores and devices) before those after it. `fence.i` makes the core read the instructions again after code was written to memory. Simple programs for one core need neither.

## csr – control and status registers
<!-- names: csr, mstatus, misa, mie, mtvec, mscratch, mepc, mcause, mtval, mip, mcycle, minstret, mhartid, mvendorid, marchid, mimpid, cycle, time, instret, dcsr, dpc, tselect, tdata1, tdata2 -->

Besides the 32 registers a core has control and status registers (CSR), reached with `csrr`, `csrw` and the instructions below. The common ones:

- `mstatus` – global state; bit 3 (`MIE`) switches interrupts on or off
- `mie`, `mip` – which interrupts are allowed / are waiting
- `mtvec` – where the pc goes on an exception or interrupt
- `mepc` – the pc when it happened (`mret` goes back there); `mcause` – why; `mtval` – the bad address or instruction
- `mscratch` – one free register for the handler
- `mhartid` – the number of the core (0 or 1 on the Pico 2)
- `mcycle`, `minstret` – counters of cycles and of finished instructions
- `dcsr`, `dpc`, `tselect`, `tdata1`, `tdata2` – the registers of the debugger (breakpoints are triggers)

```asm
csrr  a0, mhartid       ; which core am I?
csrw  mtvec, t0         ; where the exceptions go
csrsi mstatus, 8        ; allow interrupts
```

Related: `csrrw`, `mret`

## csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci, csrr, csrw, csrs, csrc, csrwi, csrsi, csrci – access a control register
<!-- names: csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci, csrr, csrw, csrs, csrc, csrwi, csrsi, csrci -->

**Syntax:** `csrrw rd, csr, rs1` &nbsp; `csrr rd, csr` &nbsp; `csrw csr, rs1`

One instruction reads the old value of the register into `rd` and writes a new one:

- `csrrw` writes `rs1`
- `csrrs` sets the bits that are 1 in `rs1` (`rs1` = `zero` only reads)
- `csrrc` clears the bits that are 1 in `rs1`
- the `i` forms take a number from 0 to 31 instead of `rs1`

`csrr rd, csr` reads, `csrw csr, rs` writes, `csrs`/`csrc` set/clear bits, `csrwi`/`csrsi`/`csrci` the same with a number (they use `zero` as `rd`). The register is given by name (`mstatus`) or number (`0x300`).

Related: `csr`, `mret`

## lr.w, sc.w – load reserved, store conditional (A)
<!-- names: lr.w, sc.w -->

**Syntax:** `lr.w rd, (rs1)` &nbsp; `sc.w rd, rs2, (rs1)`

`lr.w` reads the word at the address and marks it. `sc.w` writes `rs2` there only if nobody changed the word since; `rd` is 0 if it worked, else not 0 (try again). Together they make an atomic update (a lock, a counter). Add `.aq` and `.rl` for the memory order (`lr.w.aq`).

```asm
retry:
    lr.w t0, (a0)
    addi t0, t0, 1
    sc.w t1, t0, (a0)
    bnez t1, retry
```

Related: `amoadd.w`, `fence`

## amoswap.w, amoadd.w, amoxor.w, amoand.w, amoor.w, amomin.w, amomax.w, amominu.w, amomaxu.w – atomic memory operations (A)
<!-- names: amoswap.w, amoadd.w, amoxor.w, amoand.w, amoor.w, amomin.w, amomax.w, amominu.w, amomaxu.w -->

**Syntax:** `amoadd.w rd, rs2, (rs1)`

Reads the word at the address `rs1` into `rd` and writes the result of the operation (swap, add, xor, and, or, minimum, maximum; `u`: unsigned) with `rs2` back, as one step that no other core can interrupt. `.aq` and `.rl` order the memory accesses.

```asm
li        t0, 1
amoadd.w  zero, t0, (a0)    ; add 1 to the word at a0
```

Related: `lr.w`, `fence`

## sh1add, sh2add, sh3add – add with a shift (Zba)
<!-- names: sh1add, sh2add, sh3add -->

**Syntax:** `sh2add rd, rs1, rs2`

`rd = (rs1 << n) + rs2` with n = 1, 2 or 3: the address of an element of an array of halfwords, words or doublewords in one instruction (`sh2add t0, index, base`).

Related: `slli`, `add`

## andn, orn, xnor – bit operations with an inverted operand (Zbb)
<!-- names: andn, orn, xnor -->

**Syntax:** `andn rd, rs1, rs2`

`andn` is `rs1 & ~rs2` (clears bits), `orn` is `rs1 | ~rs2`, `xnor` is `~(rs1 ^ rs2)`.

Related: `and`, `bclr`

## clz, ctz, cpop – count bits (Zbb)
<!-- names: clz, ctz, cpop -->

**Syntax:** `clz rd, rs`

`clz` counts the zero bits from the top (32 for 0), `ctz` from the bottom, `cpop` counts the bits that are 1. `ctz` finds the lowest set bit, `31 - clz` the highest.

Related: `rev8`, `bext`

## min, minu, max, maxu – smaller and larger (Zbb)
<!-- names: min, minu, max, maxu -->

**Syntax:** `max rd, rs1, rs2`

The smaller or larger of two registers, signed (`min`, `max`) or unsigned (`minu`, `maxu`) – no branch needed.

Related: `slt`

## sext.b, sext.h, zext.h – extend a byte or halfword (Zbb)
<!-- names: sext.b, sext.h, zext.h -->

**Syntax:** `sext.b rd, rs`

`sext.b`/`sext.h` copy bit 7 / 15 into the upper bits (a signed byte or halfword becomes a signed word); `zext.h` clears the upper 16 bits. For an unsigned byte use `andi rd, rs, 0xff`.

Related: `andi`, `lb`

## rol, ror, rori – rotate (Zbb)
<!-- names: rol, ror, rori -->

**Syntax:** `ror rd, rs1, rs2` &nbsp; `rori rd, rs1, n`

Shifts, but the bits that fall out on one side come back on the other (rotate left or right).

Related: `slli`, `srli`

## rev8, orc.b, brev8, zip, unzip – move bits and bytes (Zbb, Zbkb)
<!-- names: rev8, orc.b, brev8, zip, unzip -->

**Syntax:** `rev8 rd, rs`

- `rev8` reverses the order of the 4 bytes (little endian to big endian)
- `orc.b` sets every byte to 0xFF if it was not 0, else 0 (a fast search for a zero byte)
- `brev8` reverses the bits inside each byte
- `zip` and `unzip` interleave / separate the bits of the two halves

Related: `ror`

## bset, bclr, binv, bext, bseti, bclri, binvi, bexti – single bits (Zbs)
<!-- names: bset, bclr, binv, bext, bseti, bclri, binvi, bexti -->

**Syntax:** `bseti rd, rs1, n` &nbsp; `bset rd, rs1, rs2`

Set (`bset`), clear (`bclr`), invert (`binv`) or read (`bext`: the bit as 0 or 1) bit number `n` (0 to 31) of a register. Without them: `ori`/`andi` with a mask.

```asm
bseti t1, zero, 25      ; t1 = 1 << 25 (the LED pin)
```

Related: `ori`, `andi`, `slli`

## pack, packh – put halves together (Zbkb)
<!-- names: pack, packh -->

**Syntax:** `pack rd, rs1, rs2`

`pack` joins the lower half of `rs1` (low) and of `rs2` (high) into a word; `packh` joins the low bytes into a halfword.

Related: `zext.h`

## clmul, clmulh, clmulr – carry-less multiplication (Zbc)
<!-- names: clmul, clmulh, clmulr -->

**Syntax:** `clmul rd, rs1, rs2`

Multiplication in which the partial products are combined with xor and not added: used for checksums (CRC) and error-correcting codes. `clmul` gives the low half, `clmulh` the high half, `clmulr` the reversed form.

Related: `xor`, `mul`

## riscv64, rv64 – the 64-bit RISC-V
<!-- names: riscv64, rv64, xlen -->

With `.arch riscv64` the registers `x0` to `x31` are 64 bits wide (the T-Head C906 of the Milk-V Duo and the MangoPi MQ-Pro, QEMU `virt`). The instructions of RV32 stay and work on all 64 bits (`add`, `slli` up to 63, `lw` extends the sign of the word to 64 bits); new are the loads and stores of 64 bits (`ld`, `sd`, `lwu`), the W instructions that compute with the lower 32 bits and extend the sign of the result to 64 (`addw`, `addiw`, `sllw` …), the atomic `.d` forms and some forms of the bit manipulation sets. The 16-bit forms change too: `c.jal` is gone, `c.addiw`, `c.ld`, `c.sd` take its place.

`li` takes any 64-bit number (up to 8 instructions). `lui` extends the sign of its 32 bits to 64: `lui a0, 0x80000` is `0xFFFFFFFF80000000`; `li` takes care of it, and `li` with a label gives 4 instructions that leave the upper 32 bits 0, so that addresses from `0x80000000` on (the RAM of QEMU `virt` and of the boards) stay positive.

Related: `ld`, `addw`, `li`

## ld, lwu, sd – load and store 64 bits (RV64)
<!-- names: ld, lwu, sd -->

**Syntax:** `ld rd, offset(rs1)`, `sd rs2, offset(rs1)` (offset from -2048 to 2047)

`ld` loads a doubleword (8 bytes), `sd` stores one. `lwu` loads a word and fills the upper 32 bits with 0 (`lw` copies the sign into them). The stack of RV64 code holds 8 bytes per register (`sd ra, 8(sp)`).

```asm
addi sp, sp, -16
sd   ra, 8(sp)       ; save the return address (64 bits)
ld   ra, 8(sp)
addi sp, sp, 16
```

Related: `lw`, `sw`, `sp`

## addw, subw, addiw, sllw, srlw, sraw, slliw, srliw, sraiw, sext.w, negw – 32-bit arithmetic (RV64)
<!-- names: addw, subw, addiw, sllw, srlw, sraw, slliw, srliw, sraiw, sext.w, negw -->

**Syntax:** `addw rd, rs1, rs2`, `addiw rd, rs1, imm`, `slliw rd, rs1, shamt` (0 to 31)

Compute with the lower 32 bits as on RV32 and extend the sign of the 32-bit result into the upper half: the arithmetic of `int` in C. `sext.w rd, rs` is `addiw rd, rs, 0` (extend the sign of a word), `negw rd, rs` is `subw rd, zero, rs`.

```asm
addw  a0, a0, a1     ; a 32-bit sum, as a 64-bit number
sext.w a2, a3        ; the low word of a3 with its sign
```

Related: `add`, `slli`, `riscv64`

## mulw, divw, divuw, remw, remuw – multiply and divide with 32 bits (RV64)
<!-- names: mulw, divw, divuw, remw, remuw -->

**Syntax:** `mulw rd, rs1, rs2`

As `mul`, `div`, `divu`, `rem`, `remu` with the lower 32 bits; the 32-bit result gets its sign extended to 64 bits.

Related: `mul`, `addw`

## lr.d, sc.d, amoswap.d, amoadd.d, amoxor.d, amoand.d, amoor.d, amomin.d, amomax.d, amominu.d, amomaxu.d – atomic doublewords (RV64)
<!-- names: lr.d, sc.d, amoswap.d, amoadd.d, amoxor.d, amoand.d, amoor.d, amomin.d, amomax.d, amominu.d, amomaxu.d -->

**Syntax:** `amoadd.d rd, rs2, (rs1)`, `lr.d rd, (rs1)`, `sc.d rd, rs2, (rs1)`

The atomic instructions of `lr.w`, `sc.w` and `amoadd.w` on 8 bytes; the address is a multiple of 8.

Related: `lr.w`, `amoadd.w`

## add.uw, sh1add.uw, sh2add.uw, sh3add.uw, slli.uw, zext.w – addresses from 32-bit indices (Zba, RV64)
<!-- names: add.uw, sh1add.uw, sh2add.uw, sh3add.uw, slli.uw, zext.w -->

**Syntax:** `sh2add.uw rd, rs1, rs2`, `slli.uw rd, rs1, shamt`

Take the lower 32 bits of `rs1` without their sign (as `unsigned int`), shift them and add `rs2`: the address of an array element from a 32-bit index. `zext.w rd, rs` is `add.uw rd, rs, zero`: the low word with the upper 32 bits 0.

Related: `sh1add`, `lwu`

## clzw, ctzw, cpopw, rolw, rorw, roriw, packw – the W forms of Zbb and Zbkb (RV64)
<!-- names: clzw, ctzw, cpopw, rolw, rorw, roriw, packw -->

**Syntax:** `clzw rd, rs`, `rolw rd, rs1, rs2`, `roriw rd, rs1, shamt` (0 to 31)

`clz`, `ctz`, `cpop`, `rol`, `ror`, `rori` and `pack` on the lower 32 bits; the 32-bit result gets its sign extended. On RV64 `clz` and the others without `w` count and rotate all 64 bits.

Related: `clz`, `rol`, `pack`

## c.ld, c.sd, c.ldsp, c.sdsp, c.addiw, c.addw, c.subw, c.zext.w – the 16-bit forms of RV64
<!-- names: c.ld, c.sd, c.ldsp, c.sdsp, c.addiw, c.addw, c.subw, c.zext.w -->

The short forms of `ld`, `sd` (registers `s0`, `s1`, `a0` to `a5`, offsets 0 to 248 in steps of 8), `ld`/`sd` relative to `sp` (0 to 504), `addiw` (-32 to 31), `addw`, `subw` and `zext.w`. They take the places of `c.jal` and of the floating point loads and stores of RV32. `c.slli`, `c.srli`, `c.srai` shift up to 63 on RV64.

Related: `compressed`, `ld`, `addw`
