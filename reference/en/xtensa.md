# Xtensa instructions (ESP32 LX6, ESP32-S3 LX7)

The instruction info of Asmonite (F1) for Xtensa (`.arch xtensa`): the cores of the ESP32 (LX6) and the ESP32-S3
(LX7). The sections here explain the ideas of the processor and its important instructions; every other
instruction has a short section made from the instruction reference (help/en/xtensa_ref.md).

New to Xtensa? Read `xtensa` (the processor in short), `registers`, `window` and `l32r` first.

## xtensa, lx6, lx7 – the processor in short

Xtensa is a 32-bit RISC processor of Cadence that every chip maker configures for its own needs; the ESP32 has an
LX6, the ESP32-S3 an LX7 (with `salt` and `saltu`, which the LX6 lacks). What is special:

- **24-bit instructions**, and 16-bit short forms with `.n` (`add.n`, `l32i.n`, `mov.n`, `ret.n` …): the code
  density option. The assembler picks no short form by itself: write `.n` where you want it.
- **Register windows:** 16 registers `a0` to `a15` are a window onto 64 physical ones; a call turns the window, so
  a function gets fresh registers without saving any (see `window`).
- **Literals:** a constant of more than 12 bits comes from a word before the code with `l32r` (see `l32r`).
- **Zero-overhead loops** with `loop` (see `loop`).
- **Shifts by a register** go through the special register `SAR` (see `sar`).
- Memory is little-endian; a word load must be at an address divisible by 4.

```asm
.target esp32
.arch xtensa
.imagebase 0x40080000
lit_value: dd 100000           ; a literal: before the code
_start:
  l32r  a2, lit_value          ; a2 = 100000
  movi  a3, 5                  ; small numbers directly (-2048 .. 2047)
  add   a2, a2, a3
  ret
```

Related: `registers`, `window`, `l32r`, `call0`

## registers, a0, a1, sp – the address registers

`a0` to `a15`, 32 bits each, are the registers of the current window. By convention:

| Register | Use |
|---|---|
| `a0` | the return address (written by `call0`, `call8` …) |
| `a1` (`sp`) | the stack pointer, divisible by 16 |
| `a2` to `a7` | arguments and the result (`a2`) of a function |
| `a8` to `a15` | free; with `call8` the arguments of the called function go into `a10` .. `a15` |

Special registers (`SAR`, `PS`, `CCOUNT`, `LBEG` …) are read with `rsr` and written with `wsr` (see `rsr`). There
is no register that is always 0 and no flags register: a comparison is part of the branch (`beq`, `blt` …).

Related: `window`, `rsr`, `sar`

## window, call4, call8, call12, callx4, callx8, callx12, entry, retw, retw.n – calls with a register window

The 16 registers `a0` .. `a15` are a window onto 64 physical registers (`WINDOWBASE` says where it starts).
`call8 func` saves the return address in `a8` and remembers the step (8) in `PS.CALLINC`; `entry a1, 32` at the
start of `func` turns the window by 8 registers and makes the stack frame: the `a8` of the caller is now the `a0`
of `func`, its `a10` .. `a15` are the `a2` .. `a7` of `func` (the arguments), and the new `a1` is the old one less
32. `retw` turns the window back and returns: the caller has its registers `a0` .. `a7` as before, the result is
in its `a10` (the `a2` of `func`).

```asm
_start:
  movi  a10, 3            ; the argument
  call8 seven             ; a8 = return address
  ; a10 = 10 here
  align 4
seven:
  entry a1, 32            ; the window turns: a2 = 3 (the a10 of the caller)
  addi  a2, a2, 7         ; the result in a2
  retw                    ; back: the caller sees it in a10
```

- A function called with `call4`/`call8`/`call12` starts with `entry` and ends with `retw` (or `retw.n`); the
  target of a call must be divisible by 4 (`align 4`).
- When the 64 registers are used up (calls deeper than about 7 levels with `call8`), the processor saves the oldest
  window to the stack and loads it back later: the handlers of the window overflow and underflow do it (on the
  ESP32 they are in the debug monitor of Asmonite).
- `callx8 a8`: the same with the target in a register.

Related: `call0`, `entry`, `registers`

## call0, callx0, ret, ret.n – calls without a window

`call0 label` puts the return address into `a0` and jumps; `ret` jumps back to `a0`. The window does not turn:
the called function shares the registers with the caller (the "call0 ABI"). A function that calls another one
must save its `a0` first. `_start` of a program on the ESP32 is called this way by the debugger: `ret` at its end
ends the session.

```asm
  call0 wait              ; a0 = return address
  ...
  align 4
wait:
  rsr   a9, ccount
  ret                     ; back to a0
```

Related: `window`

## l32r – a word from a literal

`l32r at, label` loads the word at `label`, which must stand **before** the instruction (up to 256 KB back) and be
divisible by 4. This is how a program gets constants of more than 12 bits and addresses: the literals stand in a
row before the code (`lit_x: dd 0x3FF44000`). The address is counted from the instruction (pc-relative), so the
literal moves with the program.

```asm
lit_gpio: dd 0x3FF44000
lit_text: dd text
_start:
  l32r a2, lit_gpio       ; a2 = 0x3FF44000
  l32r a3, lit_text       ; a3 = the address of text
```

`movi` takes -2048 .. 2047 directly, `movi.n` -32 .. 95.

Related: `movi`, `l32i`

## movi, movi.n, mov, mov.n – a number or a register into a register

`movi at, n` loads a number of -2048 .. 2047, `movi.n` one of -32 .. 95 (2 bytes). `mov ar, as` copies a register
(`mov.n`: 2 bytes). Larger numbers come with `l32r` from a literal.

Related: `l32r`

## l8ui, l16ui, l16si, l32i, l32i.n, s8i, s16i, s32i, s32i.n – loads and stores

`l32i at, as, offset` loads the word at `as + offset` (offset 0 .. 1020, divisible by 4); `s32i` stores one.
`l8ui` loads a byte (zero-extended), `l16ui`/`l16si` a halfword (zero- or sign-extended), `s8i`/`s16i` store them.
The `.n` forms take an offset 0 .. 60 and 2 bytes.

The memory matters: the **IRAM** of the ESP32 and of the ESP32-S3 takes words only; a byte or halfword access there
stops with a LoadStoreError. On the ESP32 put data after `.data` (the DRAM); on the ESP32-S3 read it through the
data bus, 0x6F0000 below its IRAM address. The ESP32-C3 is RISC-V. Peripheral registers are words: `l32i`, `s32i`,
and `memw` after writes that must arrive in order.

```asm
  l32i  a4, a3, 0          ; a word
  l8ui  a5, a3, 1          ; a byte (not in the IRAM)
  s32i  a5, a2, 0x08       ; a word into a register of a peripheral
  memw
```

Related: `memw`, `l32r`

## add, add.n, addi, addi.n, addmi, sub, neg, abs – arithmetic

`add ar, as, at` (`ar = as + at`), `sub ar, as, at`, `addi at, as, n` (n = -128 .. 127), `addmi at, as, n` (n a
multiple of 256 up to ±32768), `neg`, `abs`. The `.n` forms are 2 bytes (`addi.n`: n = -1, 1 .. 15). There are no
flags: an overflow is not seen; compare with a branch.

Related: `branches`, `mull`

## branches, beq, bne, blt, bge, bltu, bgeu, beqz, bnez, bltz, bgez, beqi, bnei, blti, bgei, bltui, bgeui, beqz.n, bnez.n, bbs, bbc, bbsi, bbci, bany, ball, bnone, bnall, j, jx – branches and jumps

A branch compares and jumps in one instruction (there are no flags): `beq as, at, label` jumps if `as = at`, `blt`
if `as < at` (signed), `bltu` (unsigned); `beqz`, `bnez`, `bltz`, `bgez` compare with 0; `beqi`, `blti` … with a
small number. `bbsi as, 5, label` jumps if bit 5 of `as` is set, `bbci` if it is clear; `bany`, `ball`, `bnone`,
`bnall` test the bits of a mask. The target of a branch is near (about ±128 bytes; `beqz`/`bnez` ±2 KB); `j label`
jumps far (±128 KB), `jx as` to the address in a register.

```asm
count:
  addi  a2, a2, 1
  bne   a2, a3, count      ; until a2 = a3
  bbsi  a11, 1, ready      ; bit 1 set?
```

Related: `loop`

## loop, loopnez, loopgtz – loops without overhead

`loop as, label` runs the instructions up to `label` (without it) `as` times, with no instruction of its own per
round: the processor counts in `LCOUNT` and jumps back from `LEND` to `LBEG` by itself. `loopnez` skips the loop if
`as` is 0 (`loop` would run it 2^32 times), `loopgtz` if `as` is 0 or less. The registers `LBEG`, `LEND`, `LCOUNT`
show in the register window.

```asm
  movi    a3, 10
  loopnez a3, done
  addi    a2, a2, 1        ; 10 times
done:
```

Related: `branches`

## sar, ssl, ssr, ssai, ssa8l, sll, srl, sra, src, slli, srli, srai – shifts

Shifts by a number are direct: `slli ar, as, 4`, `srli ar, at, 4` (logical), `srai ar, at, 4` (arithmetic). Shifts
by a register go through the special register `SAR`: `ssl as` sets it for a left shift by `as`, then `sll ar, as`
shifts; `ssr as` for a right shift, then `srl ar, at` or `sra ar, at`. `src ar, as, at` shifts the 64 bits of `as`
and `at` right by `SAR` (a funnel shift); `ssai n` sets `SAR` to a number.

```asm
  ssl  a4                  ; SAR for a left shift by a4
  sll  a5, a5              ; a5 = a5 << a4
```

Related: `extui`

## extui – bits out of a register

`extui ar, at, shift, bits` takes `bits` bits (1 .. 16) of `at` from bit `shift` on, as an unsigned number:
`extui a5, a4, 8, 8` is the second byte of `a4`. With `slli` and `or` it builds and takes apart bytes and fields of
registers.

Related: `sar`

## mull, muluh, mulsh, mul16u, mul16s, quos, quou, rems, remu – multiply and divide

`mull ar, as, at` is the low 32 bits of the product, `muluh`/`mulsh` the high 32 (unsigned / signed),
`mul16u`/`mul16s` multiply the low halfwords. `quos`/`quou` divide (signed / unsigned), `rems`/`remu` give the
remainder; a division by 0 is an exception. The MAC16 unit of the ESP32 (`mula.dd.ll` …) is not in the assembler.

Related: `add`

## rsr, wsr, xsr, ccount, ps, vecbase – special registers

`rsr ar, ccount` (or `rsr.ccount ar`) reads a special register, `wsr` writes one, `xsr` swaps. Some of them:

| Register | What |
|---|---|
| `CCOUNT` | the cycle counter: counts every clock (40 MHz after the boot ROM of the ESP32) |
| `SAR` | the shift amount (see `sar`) |
| `PS` | the state: interrupt level, `EXCM`, `CALLINC`, `WOE` (windows on) |
| `LBEG`, `LEND`, `LCOUNT` | the loop (see `loop`) |
| `WINDOWBASE`, `WINDOWSTART` | the register windows |
| `VECBASE` | the address of the vectors of the exceptions (the debug monitor of Asmonite sets its own) |
| `EPC1`, `EXCCAUSE`, `EXCVADDR` | where and why an exception came |

After a `wsr` that changes how the processor runs (`PS`, `VECBASE`, …) an `rsync` or `isync` makes it valid.

```asm
  rsr   a9, ccount         ; time
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait      ; a7 cycles
```

Related: `memw`

## memw, isync, rsync, esync, dsync, extw – barriers

`memw` waits until the loads and stores before it are done: after writes to the registers of a peripheral, before
the next one that depends on them. `isync` makes changed instructions and special registers valid for the fetch,
`rsync` for the registers, `esync` and `dsync` for exceptions and data.

Related: `l32i`, `rsr`

## break, break.n, ill, ill.n, nop, nop.n, waiti, rfe, rfi, rfwo, rfwu – system

`break 1, 15` (and `break.n 1`) stops at the debugger: the debug monitor of Asmonite writes these as breakpoints.
`ill` is an illegal instruction (an exception). `waiti n` waits for an interrupt above level `n`. `rfe`, `rfi n`,
`rfwo`, `rfwu` return from an exception, an interrupt of level `n`, a window overflow, an underflow. `nop` does
nothing.

Related: `window`, `rsr`

## salt, saltu – set if less than (LX7 only)

`salt ar, as, at` sets `ar` to 1 if `as < at` (signed), else to 0; `saltu` unsigned. Only the LX7 of the ESP32-S3
has them; with `.target esp32` (LX6) the assembler refuses them.

Related: `branches`

## !missing

There is no explanation for `{name}` yet.
