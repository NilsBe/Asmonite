# ARM and Thumb instructions (ARMv7, UAL)

The instruction info of Dismonite (F1) for ARM (A32, 4 bytes per instruction) and Thumb (T32, 2 or 4 bytes). Both are written in the same language (UAL); an instruction like `add` exists in both.

Each section starts with `## ` and the names it explains; long lists stand in a line `<!-- names: ... -->`. Dismonite finds `addeq`, `adds.w` or `vmoveq.f64` under `add` or `vmov` and shows the condition (`eq`) with it.

## cond – conditions
<!-- names: eq, ne, cs, hs, cc, lo, mi, pl, vs, vc, hi, ls, ge, lt, gt, le, al -->

Almost every ARM instruction can carry a condition: it is executed only if the flags match, else skipped. The condition stands behind the name: `addeq`, `bne`, `ldrlt`. In Thumb it applies to the instructions of an `it` block (and to `b`).

- `eq` equal (Z = 1), `ne` not equal (Z = 0)
- unsigned: `hs`/`cs` >=, `lo`/`cc` <, `hi` >, `ls` <=
- signed: `ge` >=, `lt` <, `gt` >, `le` <=
- `mi` negative (N = 1), `pl` not negative
- `vs` overflow (V = 1), `vc` no overflow
- `al` always (is not written)

The flags are set by `cmp`, `tst` or an instruction with `s` (`adds`, `subs`, ...).

```asm
cmp r0, #10
movge r0, #10    ; at most 10
addlt r1, r1, #1
```

Related: `cmp`, `it`, `b`

## mov, movs – copy a value

Copies a value into a register: from another register (also shifted, see `lsl`) or a number. `movs` also sets the flags N and Z (and C when shifting).

**Syntax:** `mov rd, rm` or `mov rd, #number`

Not every number fits into the instruction (ARM: 8 bits, rotated by an even number); larger ones are loaded with `movw`/`movt` or `ldr rd, [pc, #...]` from a literal pool.

**Flags:** `movs`: N, Z, (C)

```asm
mov r0, #0       ; r0 = 0
mov r1, r2       ; r1 = r2
mov pc, lr       ; return (old)
```

Related: `mvn`, `movw`, `movt`, `ldr`

## mvn, mvns – copy a value inverted

Copies the source with inverted bits (`not`): `rd = ~src`. This loads numbers like 0xFFFFFF00.

**Syntax:** `mvn rd, #number` or `mvn rd, rm`

**Flags:** `mvns`: N, Z, (C)

```asm
mvn r0, #0       ; r0 = 0xFFFFFFFF
```

Related: `mov`, `bic`

## movw, movt – load 16 bits

- `movw rd, #number`: loads a 16-bit number, the upper 16 bits become 0
- `movt rd, #number`: sets only the upper 16 bits, the lower ones stay

Together they load any 32-bit number or address.

**Flags:** none

```asm
movw r0, #0x5678
movt r0, #0x1234 ; r0 = 0x12345678
```

Related: `mov`, `ldr`, `adr`

## adr – address relative to pc

Calculates an address relative to the instruction itself (really `add rd, pc, #number` or `sub`). Dismonite shows in the comment where it points (`=GetStdHandle`, a label).

**Syntax:** `adr rd, target`

`pc` reads as the address of the instruction + 8 (ARM) or + 4 (Thumb, rounded down to 4).

**Flags:** none

Related: `ldr`, `add`

## add, adds, addw – add

Adds: `rd = rn + operand`. The operand is a register (also shifted: `r2, lsl #2`) or a number. `adds` sets the flags; `addw` (Thumb) takes a 12-bit number 0..4095.

**Syntax:** `add rd, rn, operand` (with only two operands: `rd = rd + operand`)

**Flags:** `adds`: N, Z, C, V

```asm
add r0, r0, #1   ; r0 + 1
add r0, r1, r2, lsl #2 ; r1+r2*4
add sp, sp, #16  ; free the stack
```

Related: `adc`, `sub`, `adr`

## adc, adcs – add with carry

Adds with the carry flag: `rd = rn + operand + C`. For numbers beyond 32 bits: first `adds` for the lower words, then `adc`.

**Flags:** `adcs`: N, Z, C, V

```asm
adds r0, r0, r2  ; lower 32 bits
adc r1, r1, r3   ; upper + C
```

Related: `add`, `sbc`

## sub, subs, subw – subtract

Subtracts: `rd = rn - operand`. `subs` sets the flags (C = 1 means: no borrow); `subw` (Thumb) with a 12-bit number.

**Syntax:** `sub rd, rn, operand`

**Flags:** `subs`: N, Z, C, V

```asm
sub sp, sp, #8   ; local space
subs r2, r2, #1  ; counter - 1
bne again
```

Related: `rsb`, `sbc`, `cmp`, `add`

## sbc, sbcs – subtract with borrow

`rd = rn - operand - (1 - C)`. For numbers beyond 32 bits after `subs`.

**Flags:** `sbcs`: N, Z, C, V

Related: `sub`, `adc`, `rsc`

## rsb, rsbs – reverse subtract

Subtracts the other way round: `rd = operand - rn`. With 0 as operand it negates (like `neg`).

**Syntax:** `rsb rd, rn, operand`

**Flags:** `rsbs`: N, Z, C, V

```asm
rsb r0, r0, #0   ; r0 = -r0
```

Related: `sub`, `rsc`

## rsc, rscs – reverse subtract with borrow

`rd = operand - rn - (1 - C)` (ARM only, not Thumb).

**Flags:** `rscs`: N, Z, C, V

Related: `rsb`, `sbc`

## cmp – compare

Calculates `rn - operand` and sets only the flags. A conditional instruction follows (`bne`, `movge`, ...) or an `it` block.

**Syntax:** `cmp rn, operand`

**Flags:** N, Z, C, V

```asm
cmp r0, #0
beq zero         ; if r0 = 0
```

Related: `cmn`, `tst`, conditions (`cond`)

## cmn – compare negative

Calculates `rn + operand` and sets only the flags; so it compares with the negative operand (`cmn r0, #1` tests for -1).

**Flags:** N, Z, C, V

Related: `cmp`

## tst – test bits

Calculates `rn and operand` and sets only the flags N and Z.

**Syntax:** `tst rn, operand`

```asm
tst r0, #1
bne odd          ; bit 0 set
```

Related: `teq`, `and`, `cmp`

## teq – test equality

Calculates `rn xor operand` and sets only the flags N and Z: Z = 1 if both are equal (without changing C and V).

Related: `tst`, `eor`, `cmp`

## and, ands – and

Bitwise and: `rd = rn and operand`. A bit stays only if it is set in both; used to clear bits.

**Flags:** `ands`: N, Z, (C)

```asm
and r0, r0, #0xFF ; lowest byte
```

Related: `orr`, `eor`, `bic`, `tst`

## orr, orrs – or

Bitwise or: `rd = rn or operand`. Used to set bits.

**Flags:** `orrs`: N, Z, (C)

```asm
orr r0, r0, #0x80 ; set bit 7
```

Related: `and`, `eor`, `orn`

## orn, orns – or with inverted operand

`rd = rn or not operand` (Thumb only).

**Flags:** `orns`: N, Z, (C)

Related: `orr`, `mvn`

## eor, eors – exclusive or

Bitwise exclusive or: `rd = rn xor operand`. A bit becomes 1 if exactly one of the two is 1; used to flip bits.

**Flags:** `eors`: N, Z, (C)

```asm
eor r0, r0, r0   ; r0 = 0
eor r1, r1, #1   ; flip bit 0
```

Related: `and`, `orr`, `teq`

## bic, bics – clear bits

`rd = rn and not operand`: the bits that are set in the operand are cleared.

**Flags:** `bics`: N, Z, (C)

```asm
bic r0, r0, #3   ; round down to 4
```

Related: `and`, `orr`

## lsl, lsls – shift left

Shifts the bits to the left, zeros come in on the right: each place doubles. As an instruction of its own or as an addition to an operand (`add r0, r1, r2, lsl #2`).

**Syntax:** `lsl rd, rm, #number` or `lsl rd, rm, rs`

**Flags:** `lsls`: N, Z, C (the bit shifted out last)

```asm
lsl r0, r1, #2   ; r1 * 4
```

Related: `lsr`, `asr`, `ror`

## lsr, lsrs – shift right (unsigned)

Shifts to the right, zeros come in on the left: divides unsigned by 2 per place.

**Flags:** `lsrs`: N, Z, C

```asm
lsr r0, r0, #4   ; r0 / 16
```

Related: `asr`, `lsl`, `ubfx`

## asr, asrs – shift right (signed)

Shifts to the right, the sign bit is repeated on the left: divides signed by 2 per place (rounded down).

**Flags:** `asrs`: N, Z, C

```asm
asr r1, r0, #31  ; 0 or -1
```

Related: `lsr`, `sbfx`

## ror, rors – rotate

Turns the bits to the right: what goes out on the right comes back in on the left.

**Flags:** `rors`: N, Z, C

Related: `rrx`, `lsr`

## rrx, rrxs – rotate by 1 through carry

Shifts one place to the right; the carry flag comes in on the left, the bit shifted out becomes (with `rrxs`) the new C.

**Flags:** `rrxs`: N, Z, C

Related: `ror`, `adc`

## clz – count leading zeros

Counts the zero bits from the top up to the first set bit (0 to 32).

**Syntax:** `clz rd, rm`

**Flags:** none

```asm
clz r1, r0       ; 32 if r0 = 0
```

Related: `rbit`

## rbit – reverse the bit order

Reverses the 32 bits: bit 0 becomes bit 31 etc. Together with `clz` this counts zeros from below.

**Flags:** none

Related: `clz`, `rev`

## rev, rev16, revsh – reverse the byte order

- `rev`: reverse the 4 bytes (little endian <-> big endian)
- `rev16`: swap the 2 bytes in each half
- `revsh`: swap the lower 2 bytes and sign-extend

**Flags:** none

```asm
rev r0, r0       ; 0x11223344 ->
                 ; 0x44332211
```

Related: `rbit`

## bfc – clear a bit field

Sets `width` bits from bit `lsb` to 0.

**Syntax:** `bfc rd, #lsb, #width`

**Flags:** none

Related: `bfi`, `bic`

## bfi – insert a bit field

Copies the lower `width` bits of `rn` to `rd` from bit `lsb`; the other bits of `rd` stay.

**Syntax:** `bfi rd, rn, #lsb, #width`

**Flags:** none

```asm
bfi r0, r1, #8, #4 ; bits 8..11
```

Related: `bfc`, `ubfx`

## sbfx, ubfx – extract a bit field

Takes `width` bits from bit `lsb` of `rn` to `rd` (at bit 0): `ubfx` zero-extended, `sbfx` sign-extended.

**Syntax:** `ubfx rd, rn, #lsb, #width`

**Flags:** none

```asm
ubfx r0, r1, #4, #4 ; bits 4..7
```

Related: `bfi`, `lsr`, `and`

## sxtb, sxth, uxtb, uxth, sxtb16, uxtb16 – extend

Extends a byte (`b`) or half word (`h`) to 32 bits: `sxt` with sign, `uxt` with zeros. The source can be rotated by 8, 16 or 24 bits first (`, ror #8`). `sxtb16`/`uxtb16` extend two bytes to two half words.

**Syntax:** `uxtb rd, rm`

**Flags:** none

```asm
uxtb r0, r0      ; r0 and 0xFF
sxth r1, r2      ; -32768..32767
```

Related: `sxtab`, `and`, `ldrb`

## sxtab, sxtah, uxtab, uxtah, sxtab16, uxtab16 – extend and add

Like `sxtb` etc., the result is added to `rn`: `rd = rn + extended(rm)`.

**Syntax:** `uxtab rd, rn, rm`

**Flags:** none

Related: `sxtb`, `add`

## pkhbt, pkhtb – pack half words

Builds a word from two half words: `pkhbt` bottom from `rn`, top from `rm` (after `lsl`); `pkhtb` top from `rn`, bottom from `rm` (after `asr`).

**Flags:** none

Related: `bfi`

## ssat, usat, ssat16, usat16 – saturate

Limits a value to a range instead of overflowing: `ssat rd, #n, rm` to -2^(n-1) .. 2^(n-1)-1, `usat` to 0 .. 2^n-1. The variants with 16 do this for both half words.

**Flags:** Q = 1 if limited

```asm
usat r0, #8, r0  ; to 0..255
```

Related: `qadd`

## sel – select bytes by the GE flags

Selects each byte from `rn` or `rm`, depending on the GE flags that a parallel instruction (`uadd8`, `usub8`, ...) has set.

**Flags:** none

Related: `uadd8`

## usad8, usada8 – sum of differences

Forms the absolute differences of the four bytes of `rn` and `rm` and adds them (`usada8`: also adds `ra`). For image and video comparisons.

**Flags:** none

Related: `uadd8`, `sel`

## mul, muls – multiply

`rd = rn * rm`, the lower 32 bits of the product (the same signed and unsigned).

**Syntax:** `mul rd, rn, rm`

**Flags:** `muls`: N, Z

```asm
mul r0, r1, r2   ; r0 = r1 * r2
```

Related: `mla`, `umull`, `smull`

## mla, mlas – multiply and add

`rd = rn * rm + ra`.

**Syntax:** `mla rd, rn, rm, ra`

**Flags:** `mlas`: N, Z

Related: `mul`, `mls`

## mls – multiply and subtract

`rd = ra - rn * rm`. Together with `udiv`/`sdiv` this gives the remainder of a division.

**Syntax:** `mls rd, rn, rm, ra`

**Flags:** none

```asm
udiv r2, r0, r1  ; r2 = r0 / r1
mls r3, r2, r1, r0 ; r3 = remainder
```

Related: `mla`, `udiv`

## umull, umulls, smull, smulls – multiply, 64 bit

The whole 64-bit product in two registers: `rdhi:rdlo = rn * rm`; `umull` unsigned, `smull` signed.

**Syntax:** `umull rdlo, rdhi, rn, rm`

**Flags:** with `s`: N, Z

Related: `umlal`, `mul`

## umlal, umlals, smlal, smlals – multiply and add, 64 bit

`rdhi:rdlo = rdhi:rdlo + rn * rm`; `umlal` unsigned, `smlal` signed.

**Flags:** with `s`: N, Z

Related: `umull`, `umaal`

## umaal – multiply, two addends

`rdhi:rdlo = rn * rm + rdlo + rdhi` (unsigned), for long-number arithmetic.

**Flags:** none

Related: `umlal`

## sdiv, udiv – divide

`rd = rn / rm`, rounded toward 0; `udiv` unsigned, `sdiv` signed. Dividing by 0 gives 0 (or an exception if the system is set up that way). Older ARM processors have no division; then the compiler calls a function (Windows: `__rt_udiv`).

**Syntax:** `udiv rd, rn, rm`

**Flags:** none

Related: `mls`, `mul`

## smlabb, smlabt, smlatb, smlatt – 16 x 16 + 32

Multiplies one signed half word each (b = bottom, t = top; first of `rn`, then of `rm`) and adds `ra`.

**Flags:** Q on overflow of the addition

Related: `smulbb`, `smlawb`

## smulbb, smulbt, smultb, smultt – 16 x 16

Multiplies one signed half word each (b = bottom, t = top): `rd = rn.x * rm.y`.

**Flags:** none

Related: `smlabb`, `smulwb`

## smlawb, smlawt, smulwb, smulwt – 32 x 16

Multiplies `rn` (32 bits) by a half word of `rm` and takes the upper 32 bits of the 48-bit product; `smlaw` adds `ra` to it.

**Flags:** `smlaw`: Q on overflow

Related: `smulbb`

## smlalbb, smlalbt, smlaltb, smlaltt – 16 x 16 + 64

Multiplies one signed half word each and adds to the 64-bit value in `rdhi:rdlo`.

**Flags:** none

Related: `smlal`, `smlabb`

## smlad, smladx, smlsd, smlsdx, smuad, smuadx, smusd, smusdx – two products

Multiplies both half-word pairs and adds (`smuad`, `smlad`) or subtracts (`smusd`, `smlsd`) the products; `smla...`/`smls...` add `ra` to it. With `x` the half words of `rm` are swapped first.

**Flags:** Q on overflow

Related: `smlald`, `smulbb`

## smlald, smlaldx, smlsld, smlsldx – two products, 64 bit

Like `smlad`/`smlsd`, but the result is added to `rdhi:rdlo`.

**Flags:** none

Related: `smlad`, `smlal`

## smmul, smmulr, smmla, smmlar, smmls, smmlsr – upper 32 bits

Multiplies signed and takes the upper 32 bits of the product; `smmla`/`smmls` add or subtract it with `ra`. With `r` it is rounded instead of truncated.

**Flags:** none

Related: `smull`

## qadd, qsub, qdadd, qdsub – calculate with saturation

Add or subtract signed; instead of overflowing the result stays at the largest or smallest value. `qdadd`/`qdsub` double `rn` first (also saturated).

**Flags:** Q = 1 if saturated

Related: `ssat`, `qadd8`

## sadd16, uadd8 – calculate in parallel (and relatives)
<!-- names: sadd16, sadd8, sasx, ssax, ssub16, ssub8, uadd16, uadd8, uasx, usax, usub16, usub8, qadd16, qadd8, qasx, qsax, qsub16, qsub8, uqadd16, uqadd8, uqasx, uqsax, uqsub16, uqsub8, shadd16, shadd8, shasx, shsax, shsub16, shsub8, uhadd16, uhadd8, uhasx, uhsax, uhsub16, uhsub8 -->

Calculate with two half words (`16`) or four bytes (`8`) in one register at the same time (SIMD). The name is put together:

- Start: `s` signed, `u` unsigned; `q`/`uq` with saturation; `sh`/`uh` with halving of the result
- `add`, `sub`; `asx` = add at the top, subtract at the bottom (after a swap); `sax` the other way
- End: `16` or `8`

The forms without `q`/`h` set the GE flags for `sel`.

```asm
uadd8 r0, r1, r2 ; 4 bytes
```

Related: `sel`, `qadd`, `usad8`

## ldr – load a word

Loads 4 bytes from memory into a register. ARM calculates only with registers; memory is read and written only with `ldr`/`str` (and their relatives).

**Syntax:** `ldr rt, [rn, #offset]`

- `[rn]`, `[rn, #4]`, `[rn, -r2]`, `[rn, r2, lsl #2]`: the address
- `[rn, #4]!`: add first and change `rn` (pre-indexed)
- `[rn], #4`: read at `rn`, then increase `rn` by 4 (post-indexed)
- `[pc, #offset]`: a value from the literal pool behind the code (Dismonite shows it in the comment)

With `pc` as destination `ldr` is a jump.

**Flags:** none

```asm
ldr r0, [r1]     ; r0 = word at r1
ldr r2, [r1, #4]!
ldr r3, [pc, #0x10] ; constant
```

Related: `str`, `ldrb`, `ldrh`, `ldm`, `adr`

## str – store a word

Writes a register (4 bytes) to memory. Address forms as for `ldr`.

**Syntax:** `str rt, [rn, #offset]`

**Flags:** none

```asm
str r0, [sp, #4] ; local variable
str r1, [r2], #4 ; and r2 + 4
```

Related: `ldr`, `strb`, `strh`, `stm`, `push`

## ldrb, strb – load and store a byte

`ldrb` loads a byte and fills the upper 24 bits with 0; `strb` writes the lower 8 bits of a register.

**Flags:** none

```asm
ldrb r0, [r1], #1 ; character
cmp r0, #0
bne next
```

Related: `ldr`, `ldrsb`, `uxtb`

## ldrh, strh – load and store a half word

`ldrh` loads 2 bytes and fills the upper 16 bits with 0; `strh` writes the lower 16 bits.

**Flags:** none

Related: `ldr`, `ldrsh`, `uxth`

## ldrsb, ldrsh – load with sign

Load a byte (`ldrsb`) or half word (`ldrsh`) and sign-extend it to 32 bits.

**Flags:** none

Related: `ldrb`, `ldrh`, `sxtb`

## ldrt, ldrbt, ldrht, ldrsbt, ldrsht, strt, strbt, strht – access as in user mode

Like `ldr`, `ldrb`, ... `str`, but with the rights of user mode, even if the kernel executes them. Useful only in the operating system.

**Flags:** none

Related: `ldr`, `str`

## ldrd, strd – load and store two words

Load or store two registers at once (8 bytes) at consecutive addresses.

**Syntax:** `ldrd rt, rt2, [rn, #offset]`

**Flags:** none

```asm
ldrd r0, r1, [sp, #8] ; 64 bit
```

Related: `ldr`, `ldm`

## ldm, ldmia, ldmib, ldmda, ldmdb – load several registers

Loads the registers of the list one after another from the address in `rn`. The lowest register comes from the lowest address.

- `ia` (or none): from `rn` upward; `ib`: from `rn + 4`
- `db`: below `rn`; `da`: up to `rn`
- `rn!`: set `rn` to the end afterwards

With `pc` in the list it is a return.

**Flags:** none

```asm
ldm r0!, {r1, r2, r3}
```

Related: `stm`, `pop`, `ldr`

## stm, stmia, stmib, stmda, stmdb – store several registers

Stores the registers of the list; addressing as for `ldm`. `stmdb sp!, {...}` is `push`.

**Flags:** none

```asm
stmia r0!, {r4, r5} ; 8 bytes
```

Related: `ldm`, `push`, `str`

## push – registers onto the stack

Puts the registers of the list on the stack (`stmdb sp!, {...}`): `sp` becomes 4 smaller per register. At the start of a function it saves the registers it changes and `lr` (the return address).

**Syntax:** `push {r4, r5, lr}`

**Flags:** none

```asm
push {r4, lr}    ; function start
; ...
pop {r4, pc}     ; return
```

Related: `pop`, `stm`, `bl`

## pop – registers from the stack

Takes the registers of the list from the stack (`ldmia sp!, {...}`). With `pc` in the list the function returns: the saved value of `lr` becomes the new `pc`.

**Syntax:** `pop {r4, pc}`

**Flags:** none

Related: `push`, `ldm`, `bx`

## ldrex, ldrexb, ldrexh, ldrexd, strex, strexb, strexh, strexd – exclusive access

For atomic operations between threads and processors: `ldrex` loads and remembers the address; `strex` stores only if nobody else has written there since, and writes 0 (worked) or 1 (again) to the status register.

**Syntax:** `strex rd, rt, [rn]` (rd: status)

**Flags:** none

```asm
again:
    ldrex r1, [r0]
    add r1, r1, #1
    strex r2, r1, [r0]
    cmp r2, #0
    bne again    ; atomic + 1
```

Related: `clrex`, `dmb`

## clrex – clear the exclusive mark

Clears the mark of `ldrex`; a following `strex` fails.

**Flags:** none

Related: `ldrex`

## swp, swpb – swap (old)

Loads a word (`swpb`: byte) from memory and writes a register there at the same time, atomically. Obsolete, replaced by `ldrex`/`strex`.

**Flags:** none

Related: `ldrex`

## pld, pldw, pli – preload

A hint to the processor to load the data (`pld`, `pldw` for writing) or instructions (`pli`) at the address into the cache already. Changes nothing in the program.

**Flags:** none

Related: `ldr`

## b – jump

Jumps to the target. With a condition (`beq`, `bne`, `blt`, ...) only if the flags match; otherwise execution goes on with the next instruction.

**Syntax:** `b target`, `bne target`

Range: ARM ±32 MB; Thumb 16 bit ±2 KB (conditional ±256 bytes), 32 bit (`b.w`) ±16 MB.

**Flags:** none changed

```asm
    cmp r0, #0
    beq finished
    b again
```

Related: `bl`, `bx`, `cbz`, conditions (`cond`)

## bl – call a subroutine

Saves the return address (the next instruction) in `lr` and jumps. The function returns with `bx lr` or `pop {..., pc}`. Unlike x86 the address does not go on the stack; a function that calls others saves `lr` with `push`.

**Syntax:** `bl target`

**Flags:** none

```asm
bl printf        ; lr = return
```

Related: `blx`, `bx`, `push`

## blx – call, with switch ARM/Thumb

Like `bl`, but the target can be in the other instruction set:

- `blx target`: always switches (ARM to Thumb and back)
- `blx rm`: jumps to the address in `rm`; bit 0 = 1 means Thumb

`blx r4` is the usual call through a function pointer, e.g. a Windows function from the import table.

**Flags:** none

```asm
ldr r4, [pc, #0x10] ; address
blx r4           ; call
```

Related: `bl`, `bx`

## bx – jump to the address in a register

Jumps to the address in `rm`; bit 0 selects Thumb (1) or ARM (0). `bx lr` is the normal return from a function.

**Syntax:** `bx rm`

**Flags:** none

```asm
bx lr            ; return
```

Related: `blx`, `pop`, `bl`

## bxj – switch to Jazelle

Like `bx`; on processors with Jazelle (Java bytecode) it would switch there. Today like `bx`.

Related: `bx`

## cbz, cbnz – compare and jump (Thumb)

Jumps if the register is 0 (`cbz`) or not 0 (`cbnz`), only forward up to 126 bytes. Does not change the flags.

**Syntax:** `cbz rn, target`

```asm
cbz r0, error    ; if r0 = 0
```

Related: `cmp`, `b`

## tbb, tbh – jump table (Thumb)

Jumps through a table directly behind the instruction: `tbb [rn, rm]` reads the byte at `rn + rm`, `tbh [rn, rm, lsl #1]` the half word; the jump goes forward by twice this value. This is how the compiler translates `switch`.

```asm
cmp r0, #3
bhi other
tbb [pc, r0]     ; table follows
```

Related: `b`, `ldr`

## it – conditional block (Thumb)
<!-- names: it, itt, ite, ittt, itte, itet, itee, itttt, ittte, ittet, ittee, itett, itete, iteet, iteee -->

Makes the next 1 to 4 instructions conditional. The letters after `it` say for the second to fourth instruction: `t` (then) with the condition, `e` (else) with the opposite one. Dismonite writes the condition on every instruction of the block.

**Syntax:** `ite eq` (two instructions: the first for eq, the second for ne)

**Flags:** none changed

```asm
cmp r0, #0
ite eq
moveq r1, #1     ; if r0 = 0
movne r1, #2     ; else
```

Related: conditions (`cond`), `cmp`

## svc – system call

Calls the operating system (supervisor call; formerly `swi`). Linux: number of the function in `r7`, parameters in `r0`...; result in `r0`.

**Syntax:** `svc #number`

```asm
mov r7, #4       ; write
svc #0
```

Related: `bkpt`, `bl`

## bkpt – breakpoint

Stops the program in the debugger (breakpoint). Only the debugger evaluates the number.

**Syntax:** `bkpt #number`

Related: `udf`, `svc`

## udf, trap – undefined instruction

Raises an exception on purpose (undefined). Windows uses this for errors: `udf #0xfe` reports an error like `int3`, `udf #0xf9` is `__brkdiv0` (division by 0).

Related: `bkpt`

## smc, hvc, eret – monitor and hypervisor

- `smc`: calls the secure monitor (TrustZone)
- `hvc`: calls the hypervisor
- `eret`: return from hypervisor mode

Only for system software.

Related: `svc`

## mrs – read the status register

Reads the status register (`apsr`: the flags N, Z, C, V, Q, GE; in the system also `cpsr`/`spsr`) into a register.

**Syntax:** `mrs rd, apsr`

Related: `msr`

## msr – write the status register

Writes flags (`apsr_nzcvq`, `apsr_g`) or, in the system, parts of `cpsr`/`spsr` from a register or a number.

**Syntax:** `msr apsr_nzcvq, rn`

Related: `mrs`, `cps`

## cps, cpsie, cpsid – interrupts and mode

`cpsie` allows, `cpsid` blocks interrupts: `i` (IRQ), `f` (FIQ), `a` (asynchronous errors). `cps #mode` changes the processor mode. Only in the operating system.

```asm
cpsid i          ; IRQ off
```

Related: `msr`, `mrs`

## setend – byte order

`setend be` switches memory accesses to big endian, `setend le` back to little endian.

Related: `rev`

## nop, yield, wfe, wfi, sev, hint, dbg – hints

- `nop`: does nothing (filler)
- `yield`: a hint that another thread may run (in wait loops)
- `wfi`: sleep until the next interrupt
- `wfe`: sleep until an event; `sev` sends an event to all processors
- `hint #n`, `dbg #n`: further hints (no effect on the program)

Related: `dmb`

## dmb, dsb, isb – memory barriers

Ensure the order of memory accesses, important between processors and for devices:

- `dmb`: accesses before the barrier become visible before those after it
- `dsb`: waits until all accesses before it are finished
- `isb`: reloads the following instructions (after changes to code or system registers)

The option says for whom: `sy` (all), `ish` (within the processors), `st` (writes only), ...

```asm
dmb ish
```

Related: `ldrex`, `strex`

## rfeia, rfeib, rfeda, rfedb, srsia, srsib, srsda, srsdb – return from exception

`srs` stores `lr` and `spsr` of a mode on its stack, `rfe` loads `pc` and `cpsr` back from there. For exception routines in the operating system.

Related: `cps`

## tt, ttt, tta, ttat – check security (ARMv8-M)

On microcontrollers with TrustZone they ask whether an address is secure and which rights apply. Not used in Windows programs (Dismonite finds them at most in data).

Related: `bxns`

## bxns, blxns – into the non-secure area (ARMv8-M)

Jump or call from the secure part (TrustZone) into the non-secure one. Only on microcontrollers.

Related: `bx`, `blx`

## mcr, mrc, mcr2, mrc2 – coprocessor registers

`mrc` reads a register of a coprocessor into an ARM register, `mcr` writes it. Coprocessor 15 is the system control (cache, MMU, ...).

Windows reads the thread block (TEB) with it, Linux the thread pointer:

```asm
mrc p15, #0, r0, c13, c0, #2
```

Related: `mcrr`, `vmrs`

## mcrr, mrrc, mcrr2, mrrc2 – coprocessor, two registers

Like `mcr`/`mrc`, with two ARM registers (64 bits), e.g. for counters.

Related: `mcr`

## ldc, ldcl, ldc2, ldc2l, stc, stcl, stc2, stc2l – coprocessor and memory

Load or store registers of a coprocessor directly from or to memory. For general coprocessors; they do not occur in Windows programs (Dismonite sees them only in data).

Related: `vldr`, `mcr`

## cdp, cdp2 – coprocessor operation

Makes a coprocessor calculate. For general coprocessors; hardly used today.

Related: `mcr`

## vldr, vstr – load and store floating-point registers

Load or store a register of the floating-point unit (VFP): `s0`..`s31` (32 bit, float) or `d0`..`d31` (64 bit, double; `d0` consists of `s0` and `s1`).

**Syntax:** `vldr d0, [rn, #offset]`

**Flags:** none

```asm
vldr d0, [r0]    ; load a double
vstr s2, [sp, #4] ; float
```

Related: `vldmia`, `vmov`, `ldr`

## vpush, vpop – floating-point registers onto the stack

Like `push`/`pop` for floating-point registers: `vpush {d8, d9}` saves them, `vpop` gets them back. This is how functions save the `d8`..`d15` they change.

**Flags:** none

Related: `push`, `vstmdb`

## vldmia, vldmdb, vstmia, vstmdb – several floating-point registers

Load or store a list of floating-point registers from `rn` (`ia` upward, `db` below `rn`); `rn!` changes `rn`.

**Flags:** none

Related: `ldm`, `vpush`

## fldmiax, fldmdbx, fstmiax, fstmdbx – several registers (old form)

The old spelling of `vldm`/`vstm` for double registers (with an odd word count, VFPv1). Effect like `vldmia` etc.

Related: `vldmia`

## vmov – copy floating-point values

Copies between floating-point registers, between ARM and floating-point registers, or loads a constant:

- `vmov.f64 d0, d1`: copy a register
- `vmov s0, r0` / `vmov r0, s0`: 32 bits back and forth (without conversion)
- `vmov d0, r0, r1`: two ARM registers into a double register
- `vmov.f64 d0, #1.0`: simple constants (`#1.000000e+00`)
- `vmov.32 d0[1], r0`: one half of a double register

**Flags:** none

Related: `vldr`, `vcvt`, `mov`

## vmrs, vmsr – status of the floating-point unit

`vmrs` reads a system register of the floating-point unit (usually `fpscr`), `vmsr` writes it. `vmrs apsr_nzcv, fpscr` copies the result of `vcmp` into the normal flags so that a conditional jump can follow.

```asm
vcmpe.f64 d0, #0
vmrs apsr_nzcv, fpscr
blt negative
```

Related: `vcmp`, `mrs`

## vadd, vsub, vmul, vdiv – floating-point arithmetic

Calculate with floating-point numbers: `.f32` (float, s registers) or `.f64` (double, d registers).

**Syntax:** `vadd.f64 d0, d1, d2` (d0 = d1 + d2)

**Flags:** none (exceptions in `fpscr`)

```asm
vmul.f64 d0, d0, d1
vdiv.f32 s0, s0, s1
```

Related: `vmla`, `vcvt`, `vmov`

## vmla, vmls, vnmla, vnmls, vnmul – multiply and add

- `vmla`: `d = d + n * m`; `vmls`: `d = d - n * m`
- `vnmla`: `d = -d - n * m`; `vnmls`: `d = -d + n * m`
- `vnmul`: `d = -(n * m)`

The product is rounded before adding (unlike `vfma`).

Related: `vfma`, `vmul`

## vfma, vfms, vfnma, vfnms – fused multiply-add

Like `vmla`/`vmls`/`vnmla`/`vnmls`, but without intermediate rounding: more exact (VFPv4).

Related: `vmla`

## vabs, vneg, vsqrt – absolute value, sign, root

- `vabs`: absolute value
- `vneg`: invert the sign
- `vsqrt`: square root

**Syntax:** `vsqrt.f64 d0, d1`

Related: `vmul`

## vcmp, vcmpe – compare floating-point

Compares two values (or with `#0`) and sets the flags in `fpscr`; only `vmrs apsr_nzcv, fpscr` brings them to the normal flags. `vcmpe` also reports an error for quiet NaN.

Related: `vmrs`, `cmp`

## vcvt, vcvtr – convert

Converts between kinds of numbers:

- `vcvt.f64.f32 d0, s0`: float to double, `vcvt.f32.f64` back
- `vcvt.f64.s32 d0, s0`: integer (signed; `u32` unsigned) to double
- `vcvt.s32.f64 s0, d0`: double to integer, truncated toward 0; `vcvtr` rounds according to `fpscr`

The integer is held in an s register; with `vmov r0, s0` it gets into an ARM register.

Related: `vmov`

## db, dw, dd, dq – data

Bytes in the file: `db` one byte each, `dw` 2 bytes, `dd` 4 bytes (one ARM word), `dq` 8 bytes. With `db` also text in quotes.

Dismonite still writes ARM code of ELF files in the export as `db` with the instruction as a comment, until Asmonite has an A32 assembler; Thumb code of PE files is written as instructions (`.arch thumb`). In the structures of the file (PE or ELF header) the comment holds the name of the field.

```asm
db 0x10,0xB5     ; push {r4, lr}
dd 0x00401000
```

Related: `org`, `align`, `rva`

## resb, resw, resd, resq – reserve space

Reserves memory without file bytes (uninitialised data, `.bss`): `resb` bytes, `resw` words, `resd` dwords, `resq` qwords; the number says how many. The Windows loader fills the space with zeros at start, nothing of it is in the file. In the assembler (`.format pe`) `resb` may stand at the end of a section.

**Syntax:** `resb count`

```asm
buffer: resb 4096   ; 4096 bytes
count:  resd 1      ; one dword
```

In Dismonite these are the rows in the memory behind the file (labels `V...`); B, W, D, Q set how large a variable is.

Related: `db`, `align`

## rva – relative address

The address of a label minus the base address of the program, 4 bytes (in PE files). With Thumb code an entry point has bit 0 set (`start + 1`).

Related: `dd`

## org – set the position

The following bytes start at this file offset; before it is filled with zeros.

Related: `align`

## align – fill up to a boundary

Fills with zeros until the position is divisible by the number (e.g. `FileAlignment` of a section).

Related: `org`

## !label

**Label** (jump mark): a name for an address. Jumps, calls and data refer to it.

Dismonite gives automatic names like `C00401020` (a `call` points to it), `J00401020` (a jump) or `L00401020` (data only); with **N** you give a label a name of your own, Ctrl+click on a name (or the key **F** in the row) jumps there.

## !comment

**Comment line**: a comment of your own in front of the line below (Enter key). It is saved in the `.dmon` file.

## !info

**Info line**: a note from Dismonite about the file or the area below, e.g. which processor or which structure.

## !missing

There is no explanation for `{name}` yet.
