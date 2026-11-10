# Instructions from the instruction reference (generated)

Made by tools/gen_help_ref.py from the tables of the assembler (tools/instr), do not edit. F1 shows a section from here when the help of the architecture has none of its own.

## abs – Absolute value

**Syntax:** `abs ar, at`

**Operation:** `ar = |at|`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## abs.s – Floating point absolute value

**Syntax:** `abs.s fr, fs`

**Operation:** `fr = |fs|`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## add – Addition of two registers

**Syntax:** `add ar, as, at`

**Operation:** `ar = as + at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## add.n – Addition of two registers (16 bit)

**Syntax:** `add.n ar, as, at`

**Operation:** `ar = as + at`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## add.s – Floating point addition

**Syntax:** `add.s fr, fs, ft`

**Operation:** `fr = fs + ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## addexp.s – Add the exponents

**Syntax:** `addexp.s fr, fs`

Add the exponents (step of division and square root).

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## addexpm.s – Add the exponents

**Syntax:** `addexpm.s fr, fs`

Add the exponents, from the mantissa (step of division and square root).

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## addi – Addition of a constant

**Syntax:** `addi at, as, imm8`

Addition of a constant (8 bit, signed); with -1 or 1..15 the assembler writes addi.n, with 0 mov.n.

**Operation:** `at = as + sext(imm8)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addi.n – Addition of a constant -1 or 1..15

**Syntax:** `addi.n ar, as, imm`

Addition of a constant -1 or 1..15 (16 bit; the field 0 is -1).

**Operation:** `ar = as + imm`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## addmi – Addition of a constant times 256 (-32768..32512)

**Syntax:** `addmi at, as, imm`

**Operation:** `at = as + (sext(imm8) << 8)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addx2 – Addition, the first register times 2

**Syntax:** `addx2 ar, as, at`

Addition, the first register times 2 (the address of a halfword).

**Operation:** `ar = (as << 1) + at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addx4 – Addition, the first register times 4

**Syntax:** `addx4 ar, as, at`

Addition, the first register times 4 (the address of a word).

**Operation:** `ar = (as << 2) + at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addx8 – Addition, the first register times 8

**Syntax:** `addx8 ar, as, at`

**Operation:** `ar = (as << 3) + at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## all4 – 1 if all 4 boolean registers are 1

**Syntax:** `all4 bt, bs`

**Operation:** `bt = bs & bs+1 & bs+2 & bs+3`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## all8 – 1 if all 8 boolean registers are 1

**Syntax:** `all8 bt, bs`

**Operation:** `bt = bs & ... & bs+7`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## and – AND

**Syntax:** `and ar, as, at`

**Operation:** `ar = as & at`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## andb – AND of boolean registers

**Syntax:** `andb br, bs, bt`

**Operation:** `br = bs & bt`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## andbc – AND with the complement of the second

**Syntax:** `andbc br, bs, bt`

**Operation:** `br = bs & ~bt`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## any4 – 1 if any of 4 boolean registers is 1

**Syntax:** `any4 bt, bs`

1 if any of 4 boolean registers is 1 (the group from b0, b4, b8, b12).

**Operation:** `bt = bs | bs+1 | bs+2 | bs+3`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## any8 – 1 if any of 8 boolean registers is 1

**Syntax:** `any8 bt, bs`

1 if any of 8 boolean registers is 1 (from b0 or b8).

**Operation:** `bt = bs | ... | bs+7`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## ball – Branch if all bits of the mask are set

**Syntax:** `ball as, at, label`

**Operation:** `if (~as & at) == 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bany – Branch if any bit of the mask is set

**Syntax:** `bany as, at, label`

**Operation:** `if (as & at) != 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bbc – Branch if the bit (its number in a register) is 0

**Syntax:** `bbc as, at, label`

**Operation:** `if as[at & 31] == 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bbci – Branch if the bit (a constant 0..31) is 0

**Syntax:** `bbci as, bit, label`

**Operation:** `if as[bit] == 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bbs – Branch if the bit (its number in a register) is 1

**Syntax:** `bbs as, at, label`

**Operation:** `if as[at & 31] == 1: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bbsi – Branch if the bit (a constant 0..31) is 1

**Syntax:** `bbsi as, bit, label`

**Operation:** `if as[bit] == 1: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## beq – Branch if equal (-128..127 bytes away)

**Syntax:** `beq as, at, label`

**Operation:** `if as == at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## beqi – Branch if equal to a constant

**Syntax:** `beqi as, b4const, label`

Branch if equal to a constant (-1, 1..8, 10, 12, 16, 32, 64, 128, 256).

**Operation:** `if as == b4const: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## beqz – Branch if zero (up to 2 KB away)

**Syntax:** `beqz as, label`

**Operation:** `if as == 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## beqz.n – Branch if zero, forward only, 0..63 bytes (16 bit)

**Syntax:** `beqz.n as, label`

**Operation:** `if as == 0: pc = label`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## bf – Branch if the boolean register is 0

**Syntax:** `bf bs, label`

**Operation:** `if not bs: pc = label`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## bge – Branch if greater or equal (signed)

**Syntax:** `bge as, at, label`

**Operation:** `if as >=s at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bgei – Branch if greater than or equal to a constant

**Syntax:** `bgei as, b4const, label`

Branch if greater than or equal to a constant (signed).

**Operation:** `if as >=s b4const: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bgeu – Branch if greater or equal (unsigned)

**Syntax:** `bgeu as, at, label`

**Operation:** `if as >=u at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bgeui – Branch if greater than or equal to an unsigned constant

**Syntax:** `bgeui as, b4constu, label`

**Operation:** `if as >=u b4constu: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bgez – Branch if not negative

**Syntax:** `bgez as, label`

**Operation:** `if as >=s 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blt – Branch if less (signed)

**Syntax:** `blt as, at, label`

**Operation:** `if as <s at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blti – Branch if less than a constant (signed)

**Syntax:** `blti as, b4const, label`

**Operation:** `if as <s b4const: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bltu – Branch if less (unsigned)

**Syntax:** `bltu as, at, label`

**Operation:** `if as <u at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bltui – Branch if less than an unsigned constant

**Syntax:** `bltui as, b4constu, label`

Branch if less than an unsigned constant (2..8, 10, 12, 16, 32, 64, 128, 256, 32768, 65536).

**Operation:** `if as <u b4constu: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bltz – Branch if negative

**Syntax:** `bltz as, label`

**Operation:** `if as <s 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bnall – Branch if not all bits of the mask are set

**Syntax:** `bnall as, at, label`

**Operation:** `if (~as & at) != 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bne – Branch if not equal

**Syntax:** `bne as, at, label`

**Operation:** `if as != at: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bnei – Branch if not equal to a constant

**Syntax:** `bnei as, b4const, label`

**Operation:** `if as != b4const: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bnez – Branch if not zero

**Syntax:** `bnez as, label`

**Operation:** `if as != 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bnez.n – Branch if not zero

**Syntax:** `bnez.n as, label`

Branch if not zero, forward only, 0..63 bytes (16 bit).

**Operation:** `if as != 0: pc = label`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## bnone – Branch if no bit of the mask is set

**Syntax:** `bnone as, at, label`

**Operation:** `if (as & at) == 0: pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## break – Breakpoint

**Syntax:** `break imm4, imm4`

Breakpoint: stops in the debugger (debug exception), the numbers tell the handler the reason.

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## break.n – Breakpoint

**Syntax:** `break.n imm4`

Breakpoint (16 bit); Asmonite puts it for breakpoints on 16-bit instructions.

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## bt – Branch if the boolean register is 1

**Syntax:** `bt bs, label`

**Operation:** `if bs: pc = label`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## call0 – Call without register window

**Syntax:** `call0 label`

Call without register window: the return address in a0 (the target a multiple of 4).

**Operation:** `a0 = pc + 3; pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## call12 – Call that turns the register window by 12

**Syntax:** `call12 label`

**Operation:** `a12 = return address (top bits: 3); PS.CALLINC = 3; pc = label`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## call4 – Call that turns the register window by 4

**Syntax:** `call4 label`

Call that turns the register window by 4 (when the function runs entry): a4..a7 of the caller are its a0..a3.

**Operation:** `a4 = return address (top bits: 1); PS.CALLINC = 1; pc = label`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## call8 – Call that turns the register window by 8

**Syntax:** `call8 label`

Call that turns the register window by 8: a10..a15 of the caller are the arguments a2..a7 of the function.

**Operation:** `a8 = return address (top bits: 2); PS.CALLINC = 2; pc = label`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## callx0 – Call of the address in the register

**Syntax:** `callx0 as`

Call of the address in the register, without register window.

**Operation:** `a0 = pc + 3; pc = as`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## callx12 – call12 to the address in the register

**Syntax:** `callx12 as`

**Operation:** `a12 = return address; PS.CALLINC = 3; pc = as`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## callx4 – call4 to the address in the register

**Syntax:** `callx4 as`

**Operation:** `a4 = return address; PS.CALLINC = 1; pc = as`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## callx8 – call8 to the address in the register

**Syntax:** `callx8 as`

**Operation:** `a8 = return address; PS.CALLINC = 2; pc = as`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## ceil.s – Convert to an integer, rounded up

**Syntax:** `ceil.s ar, fs, imm4`

**Operation:** `ar = ceil(fs * 2^imm4)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## clamps – Clamp to the range of a signed number of b+1 bits

**Syntax:** `clamps ar, as, bits`

Clamp to the range of a signed number of b+1 bits (7..22).

**Operation:** `ar = min(max(as, -2^b), 2^b - 1)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## const.s – Load a float constant (0, 1, 2, 0.5 ... by imm4)

**Syntax:** `const.s fr, imm4`

**Operation:** `fr = constant[imm4]`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## div0.s – Start value for a division

**Syntax:** `div0.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## divn.s – Last step of a division

**Syntax:** `divn.s fr, fs, ft`

Last step of a division (after div0.s, nexp01.s ...).

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## dsync – Wait until written special registers apply to memory accesses

**Syntax:** `dsync`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## entry – The first instruction of a function with register window

**Syntax:** `entry as, framesize`

The first instruction of a function with register window: turns the window by PS.CALLINC * 4 and makes its stack frame (framesize 0..32760, a multiple of 8; the address a multiple of 4).

**Operation:** `WINDOWBASE += PS.CALLINC; as = as(old window) - framesize`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## esync – Wait until written special registers apply to the execution

**Syntax:** `esync`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## excw – Wait until the exceptions of the instructions before are raised

**Syntax:** `excw`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## extui – Extract an unsigned bit field

**Syntax:** `extui ar, at, shift, width`

Extract an unsigned bit field: width bits from bit shift (shift + width up to 32).

**Operation:** `ar = (at >> shift) & ((1 << width) - 1)`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## extw – Wait until all earlier accesses have reached the outside

**Syntax:** `extw`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## float.s – Convert a signed integer to float

**Syntax:** `float.s fr, as, imm4`

Convert a signed integer to float, divided by 2^imm4.

**Operation:** `fr = float(as) / 2^imm4`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## floor.s – Convert to an integer, rounded down

**Syntax:** `floor.s ar, fs, imm4`

**Operation:** `ar = floor(fs * 2^imm4)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## idtlb – Invalidate an entry of the data TLB

**Syntax:** `idtlb as`

**Operation:** `invalidate DTLB[as]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## iitlb – Invalidate an entry of the instruction TLB

**Syntax:** `iitlb as`

**Operation:** `invalidate ITLB[as]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ill – Illegal instruction: raises an exception

**Syntax:** `ill`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ill.n – Illegal instruction (16 bit)

**Syntax:** `ill.n`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## isync – Fetch the instructions again

**Syntax:** `isync`

Fetch the instructions again (after changed code or special registers).

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## j – Jump (up to 128 KB away)

**Syntax:** `j label`

**Operation:** `pc = label`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## jx – Jump to the address in the register

**Syntax:** `jx as`

**Operation:** `pc = as`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## l16si – Load of a halfword, signed

**Syntax:** `l16si at, as, offset`

**Operation:** `at = sext(mem16[as + (imm8 << 1)])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## l16ui – Load of a halfword, unsigned (offset 0..510, even)

**Syntax:** `l16ui at, as, offset`

**Operation:** `at = zext(mem16[as + (imm8 << 1)])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## l32ai – Load of a word with acquire ordering

**Syntax:** `l32ai at, as, offset`

Load of a word with acquire ordering (later accesses only after it).

**Operation:** `at = mem32[as + (imm8 << 2)]; acquire`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## l32e – Load for the handlers of the window exceptions

**Syntax:** `l32e at, as, offset`

Load for the handlers of the window exceptions (offset -64..-4).

**Operation:** `at = mem32[as + ((imm4 << 2) - 64)]`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## l32i – Load of a word

**Syntax:** `l32i at, as, offset`

Load of a word (offset 0..1020, a multiple of 4); with a small offset the assembler writes l32i.n.

**Operation:** `at = mem32[as + (imm8 << 2)]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## l32i.n – Load of a word, offset 0..60 (16 bit)

**Syntax:** `l32i.n at, as, offset`

**Operation:** `at = mem32[as + (imm4 << 2)]`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## l32r – Load of a word from the literal pool

**Syntax:** `l32r at, label`

Load of a word from the literal pool: a constant up to 256 KB before the instruction (its address a multiple of 4); the way of 32-bit constants into a register.

**Operation:** `at = mem32[((pc + 3) & ~3) + (0xFFFF0000 | imm16) * 4]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## l8ui – Load of a byte, unsigned

**Syntax:** `l8ui at, as, imm8`

**Operation:** `at = zext(mem8[as + imm8])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lddr32.p – Debug mode

**Syntax:** `lddr32.p as`

Debug mode: load a word into DDR and add 4 to the address (fast memory reads of the debugger).

**Operation:** `DDR = mem32[as]; as += 4`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## loop – Zero-overhead loop

**Syntax:** `loop as, label`

Zero-overhead loop: the part up to label runs as times (as = 0: 2^32 times); LBEG, LEND, LCOUNT.

**Operation:** `LCOUNT = as - 1; LBEG = pc + 3; LEND = label`

*Group: Zero-overhead loops (loop). Short description from the instruction reference; there is no longer explanation for it yet.*

## loopgtz – Loop as loop, skipped if as is not greater than 0

**Syntax:** `loopgtz as, label`

**Operation:** `if as <=s 0: pc = label else loop`

*Group: Zero-overhead loops (loop). Short description from the instruction reference; there is no longer explanation for it yet.*

## loopnez – Loop as loop, skipped if as = 0

**Syntax:** `loopnez as, label`

**Operation:** `if as == 0: pc = label else loop`

*Group: Zero-overhead loops (loop). Short description from the instruction reference; there is no longer explanation for it yet.*

## lsi – Load of a float

**Syntax:** `lsi ft, as, offset`

**Operation:** `ft = mem32[as + (imm8 << 2)]`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## lsip – Load of a float, then add to the address

**Syntax:** `lsip ft, as, offset`

**Operation:** `ft = mem32[as]; as += imm8 << 2`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## lsx – Load of a float, the address from two registers

**Syntax:** `lsx fr, as, at`

**Operation:** `fr = mem32[as + at]`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## lsxp – Load of a float, then add to the address

**Syntax:** `lsxp fr, as, at`

**Operation:** `fr = mem32[as]; as += at`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## madd.s – Multiply and add

**Syntax:** `madd.s fr, fs, ft`

**Operation:** `fr = fr + fs * ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## maddn.s – Multiply and add

**Syntax:** `maddn.s fr, fs, ft`

Multiply and add, rounded to nearest (a step of division and square root).

**Operation:** `fr = round(fr + fs * ft)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## max – Maximum, signed

**Syntax:** `max ar, as, at`

**Operation:** `ar = (as >s at) ? as : at`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## maxu – Maximum, unsigned

**Syntax:** `maxu ar, as, at`

**Operation:** `ar = (as >u at) ? as : at`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## memw – Memory barrier

**Syntax:** `memw`

Memory barrier: earlier accesses before later ones (for peripheral registers).

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## min – Minimum, signed

**Syntax:** `min ar, as, at`

**Operation:** `ar = (as <s at) ? as : at`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## minu – Minimum, unsigned

**Syntax:** `minu ar, as, at`

**Operation:** `ar = (as <u at) ? as : at`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## mkdadj.s – Make the exponent adjustment for a division

**Syntax:** `mkdadj.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## mksadj.s – Make the exponent adjustment for a square root

**Syntax:** `mksadj.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## mov.n – Copy of a register (16 bit)

**Syntax:** `mov.n at, as`

**Operation:** `at = as`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## mov.s – Copy a float register

**Syntax:** `mov.s fr, fs`

**Operation:** `fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## moveqz – Copy if the third register is 0

**Syntax:** `moveqz ar, as, at`

**Operation:** `if at == 0: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## moveqz.s – Copy a float register if at is 0

**Syntax:** `moveqz.s fr, fs, at`

**Operation:** `if at == 0: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## movf – Copy if the boolean register is 0

**Syntax:** `movf ar, as, bt`

**Operation:** `if not bt: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## movf.s – Copy a float register if the boolean register is 0

**Syntax:** `movf.s fr, fs, bt`

**Operation:** `if not bt: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## movgez – Copy if the third register is not negative

**Syntax:** `movgez ar, as, at`

**Operation:** `if at >=s 0: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## movgez.s – Copy a float register if at is not negative

**Syntax:** `movgez.s fr, fs, at`

**Operation:** `if at >=s 0: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## movi – Load of a constant

**Syntax:** `movi at, imm12`

Load of a constant (12 bit, signed, -2048..2047); larger ones come with l32r.

**Operation:** `at = sext(imm12)`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movi.n – Load of a constant -32..95 (16 bit)

**Syntax:** `movi.n as, imm7`

**Operation:** `as = imm7`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## movltz – Copy if the third register is negative

**Syntax:** `movltz ar, as, at`

**Operation:** `if at <s 0: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## movltz.s – Copy a float register if at is negative

**Syntax:** `movltz.s fr, fs, at`

**Operation:** `if at <s 0: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## movnez – Copy if the third register is not 0

**Syntax:** `movnez ar, as, at`

**Operation:** `if at != 0: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## movnez.s – Copy a float register if at is not 0

**Syntax:** `movnez.s fr, fs, at`

**Operation:** `if at != 0: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## movsp – Set the stack pointer so that the register windows of the callers are saved first

**Syntax:** `movsp at, as`

**Operation:** `at = as (after spilling the windows when needed)`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## movt – Copy if the boolean register is 1

**Syntax:** `movt ar, as, bt`

**Operation:** `if bt: ar = as`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## movt.s – Copy a float register if the boolean register is 1

**Syntax:** `movt.s fr, fs, bt`

**Operation:** `if bt: fr = fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## msub.s – Multiply and subtract

**Syntax:** `msub.s fr, fs, ft`

**Operation:** `fr = fr - fs * ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## mul.s – Floating point multiplication

**Syntax:** `mul.s fr, fs, ft`

**Operation:** `fr = fs * ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## mul16s – Multiplication of the low 16 bits, signed

**Syntax:** `mul16s ar, as, at`

**Operation:** `ar = sext(as[15:0]) * sext(at[15:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mul16u – Multiplication of the low 16 bits, unsigned

**Syntax:** `mul16u ar, as, at`

**Operation:** `ar = zext(as[15:0]) * zext(at[15:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mull – Multiplication, the low 32 bits

**Syntax:** `mull ar, as, at`

**Operation:** `ar = (as * at)[31:0]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulsh – Multiplication, signed, the high 32 bits

**Syntax:** `mulsh ar, as, at`

**Operation:** `ar = (as *s at)[63:32]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## muluh – Multiplication, unsigned, the high 32 bits

**Syntax:** `muluh ar, as, at`

**Operation:** `ar = (as *u at)[63:32]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## neg – Negation

**Syntax:** `neg ar, at`

**Operation:** `ar = -at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## neg.s – Floating point negation

**Syntax:** `neg.s fr, fs`

**Operation:** `fr = -fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## nexp01.s – Bring the mantissa to 1..2 and negate the exponent

**Syntax:** `nexp01.s fr, fs`

Bring the mantissa to 1..2 and negate the exponent (step of division and square root).

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## nop – No effect; written as nop.n

**Syntax:** `nop`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## nop.n – No effect (16 bit)

**Syntax:** `nop.n`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## nsa – Number of the sign bits less 1 (normalize, signed)

**Syntax:** `nsa at, as`

**Operation:** `at = count of the leading bits equal to as[31], less 1`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## nsau – Number of the leading zero bits (32 for 0)

**Syntax:** `nsau at, as`

**Operation:** `at = clz(as)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## oeq.s – Comparison: 1 if equal (no NaN)

**Syntax:** `oeq.s br, fs, ft`

**Operation:** `br = fs == ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ole.s – Comparison: 1 if less or equal (no NaN)

**Syntax:** `ole.s br, fs, ft`

**Operation:** `br = fs <= ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## olt.s – Comparison: 1 if less (no NaN)

**Syntax:** `olt.s br, fs, ft`

**Operation:** `br = fs < ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## or – OR; with the same source twice the copy of a register

**Syntax:** `or ar, as, at`

OR; with the same source twice the copy of a register (mov, as mov.n).

**Operation:** `ar = as | at`

Also shown as: `mov`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orb – OR of boolean registers

**Syntax:** `orb br, bs, bt`

**Operation:** `br = bs | bt`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## orbc – OR with the complement of the second

**Syntax:** `orbc br, bs, bt`

**Operation:** `br = bs | ~bt`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pdtlb – Probe the data TLB for an address

**Syntax:** `pdtlb at, as`

**Operation:** `at = probe DTLB(as)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## pitlb – Probe the instruction TLB for an address

**Syntax:** `pitlb at, as`

**Operation:** `at = probe ITLB(as)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## quos – Division, signed

**Syntax:** `quos ar, as, at`

**Operation:** `ar = as /s at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## quou – Division, unsigned (by 0: an exception)

**Syntax:** `quou ar, as, at`

**Operation:** `ar = as /u at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdtlb0 – Read an entry of the data TLB (virtual address)

**Syntax:** `rdtlb0 at, as`

**Operation:** `at = DTLB[as].vaddr`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdtlb1 – Read an entry of the data TLB (translation)

**Syntax:** `rdtlb1 at, as`

**Operation:** `at = DTLB[as].paddr`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## recip0.s – Start value for a reciprocal

**Syntax:** `recip0.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## rems – Remainder of the division, signed

**Syntax:** `rems ar, as, at`

**Operation:** `ar = as %s at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## remu – Remainder of the division, unsigned

**Syntax:** `remu ar, as, at`

**Operation:** `ar = as %u at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## rer – Read an external register

**Syntax:** `rer at, as`

**Operation:** `at = ER[as]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ret – Return after call0 (to a0); written as ret.n

**Syntax:** `ret`

**Operation:** `pc = a0`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## ret.n – Return after call0 (16 bit)

**Syntax:** `ret.n`

**Operation:** `pc = a0`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## retw – Return from a function with register window

**Syntax:** `retw`

Return from a function with register window: turns the window back; written as retw.n.

**Operation:** `pc = a0 (top bits from pc); WINDOWBASE -= a0[31:30]`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## retw.n – Return with register window (16 bit)

**Syntax:** `retw.n`

**Operation:** `pc = a0; WINDOWBASE -= a0[31:30]`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## rfdd – Return from a debug exception in the debug mode

**Syntax:** `rfdd`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rfde – Return from a double exception

**Syntax:** `rfde`

**Operation:** `pc = DEPC`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rfdo – Return from the debug mode

**Syntax:** `rfdo imm4`

Return from the debug mode (OCD: the debugger lets the core run).

**Operation:** `pc = EPC6; PS = EPS6`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rfe – Return from an exception of level 1

**Syntax:** `rfe`

**Operation:** `pc = EPC1; PS.EXCM = 0`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rfi – Return from an interrupt of level imm4

**Syntax:** `rfi imm4`

**Operation:** `pc = EPC[imm4]; PS = EPS[imm4]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rfr – Copy a float register to an address register

**Syntax:** `rfr ar, fs`

Copy a float register to an address register (the bits).

**Operation:** `ar = bits(fs)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## rfwo – Return from the handler of a window overflow

**Syntax:** `rfwo`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## rfwu – Return from the handler of a window underflow

**Syntax:** `rfwu`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## ritlb0 – Read an entry of the instruction TLB

**Syntax:** `ritlb0 at, as`

Read an entry of the instruction TLB (virtual address).

**Operation:** `at = ITLB[as].vaddr`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ritlb1 – Read an entry of the instruction TLB (translation)

**Syntax:** `ritlb1 at, as`

**Operation:** `at = ITLB[as].paddr`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rotw – Turn the register window

**Syntax:** `rotw imm4`

Turn the register window (in the handlers of the window exceptions).

**Operation:** `WINDOWBASE += imm4`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## round.s – Convert to an integer, rounded (times 2^imm4)

**Syntax:** `round.s ar, fs, imm4`

**Operation:** `ar = round(fs * 2^imm4)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## rsil – Read PS and set the interrupt level

**Syntax:** `rsil at, imm4`

Read PS and set the interrupt level (interrupts up to imm4 off).

**Operation:** `at = PS; PS.INTLEVEL = imm4`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsqrt0.s – Start value for a reciprocal square root

**Syntax:** `rsqrt0.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## rsr – Read a special register

**Syntax:** `rsr sr, at`

Read a special register; also written rsr.name at (rsr.ps a3).

**Operation:** `at = SR[sr]`

*Group: Special and user registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsync – Wait until written special registers apply to register reads

**Syntax:** `rsync`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## rur – Read a user register

**Syntax:** `rur ar, ur`

Read a user register (threadptr, fcr, fsr ...); also rur.name ar.

**Operation:** `ar = UR[ur]`

*Group: Special and user registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## s16i – Store of a halfword

**Syntax:** `s16i at, as, offset`

**Operation:** `mem16[as + (imm8 << 1)] = at[15:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## s32c1i – Conditional store

**Syntax:** `s32c1i at, as, offset`

Conditional store (compare and swap): stores at if the word equals SCOMPARE1; at gets the old value.

**Operation:** `old = mem32[a]; if old == SCOMPARE1: mem32[a] = at; at = old`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## s32e – Store for the handlers of the window exceptions

**Syntax:** `s32e at, as, offset`

Store for the handlers of the window exceptions (offset -64..-4).

**Operation:** `mem32[as + ((imm4 << 2) - 64)] = at`

*Group: Windowed registers (call4/8/12, entry, retw). Short description from the instruction reference; there is no longer explanation for it yet.*

## s32i – Store of a word

**Syntax:** `s32i at, as, offset`

Store of a word; with a small offset the assembler writes s32i.n.

**Operation:** `mem32[as + (imm8 << 2)] = at`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## s32i.n – Store of a word, offset 0..60 (16 bit)

**Syntax:** `s32i.n at, as, offset`

**Operation:** `mem32[as + (imm4 << 2)] = at`

*Group: 16-bit instructions (code density). Short description from the instruction reference; there is no longer explanation for it yet.*

## s32nb – Store of a word that bypasses the write buffer

**Syntax:** `s32nb at, as, offset`

Store of a word that bypasses the write buffer (offset 0..60).

**Operation:** `mem32[as + (imm4 << 2)] = at`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## s32ri – Store of a word with release ordering

**Syntax:** `s32ri at, as, offset`

Store of a word with release ordering (earlier accesses first).

**Operation:** `release; mem32[as + (imm8 << 2)] = at`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## s8i – Store of a byte

**Syntax:** `s8i at, as, imm8`

**Operation:** `mem8[as + imm8] = at[7:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## salt – Signed comparison

**Syntax:** `salt ar, as, at`

Signed comparison: 1 if less (ESP32-S3 only, not the ESP32).

**Operation:** `ar = (as <s at) ? 1 : 0`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## saltu – Unsigned comparison

**Syntax:** `saltu ar, as, at`

Unsigned comparison: 1 if less (ESP32-S3 only, not the ESP32).

**Operation:** `ar = (as <u at) ? 1 : 0`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## sddr32.p – Debug mode: store DDR and add 4 to the address

**Syntax:** `sddr32.p as`

**Operation:** `mem32[as] = DDR; as += 4`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sext – Sign extension from bit b (7..22)

**Syntax:** `sext ar, as, bits`

**Operation:** `ar = sext(as[b:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## simcall – Call of a simulator (no effect on the chip)

**Syntax:** `simcall`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sll – Shift left by 32 less SAR (SAR set by ssl)

**Syntax:** `sll ar, as`

**Operation:** `ar = as << (32 - SAR)`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## slli – Shift left by a constant

**Syntax:** `slli ar, as, sa`

Shift left by a constant (1..31; the fields hold 32 less sa).

**Operation:** `ar = as << sa`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrt0.s – Start value for a square root

**Syntax:** `sqrt0.s fr, fs`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## sra – Shift right signed by SAR

**Syntax:** `sra ar, at`

**Operation:** `ar = at >>s SAR`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srai – Shift right signed by a constant (0..31)

**Syntax:** `srai ar, at, sa`

**Operation:** `ar = at >>s sa`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## src – Shift right across two registers

**Syntax:** `src ar, as, at`

Shift right across two registers (64 bit) by SAR; with the same register twice a rotation.

**Operation:** `ar = ((as : at) >> SAR)[31:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srl – Shift right unsigned by SAR

**Syntax:** `srl ar, at`

**Operation:** `ar = at >>u SAR`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srli – Shift right unsigned by a constant

**Syntax:** `srli ar, at, imm4`

Shift right unsigned by a constant (0..15; more with extui).

**Operation:** `ar = at >>u imm4`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssa8b – Set SAR for a shift by whole bytes (big endian)

**Syntax:** `ssa8b as`

**Operation:** `SAR = 32 - as[1:0] * 8`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssa8l – Set SAR for a shift by whole bytes (little endian)

**Syntax:** `ssa8l as`

**Operation:** `SAR = as[1:0] * 8`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssai – Set SAR to a constant

**Syntax:** `ssai sa`

**Operation:** `SAR = sa`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssi – Store of a float

**Syntax:** `ssi ft, as, offset`

**Operation:** `mem32[as + (imm8 << 2)] = ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssip – Store of a float, then add to the address

**Syntax:** `ssip ft, as, offset`

**Operation:** `mem32[as] = ft; as += imm8 << 2`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssl – Set SAR for a shift left

**Syntax:** `ssl as`

**Operation:** `SAR = 32 - as[4:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssr – Set SAR for a shift right (from the low 5 bits)

**Syntax:** `ssr as`

**Operation:** `SAR = as[4:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ssx – Store of a float, the address from two registers

**Syntax:** `ssx fr, as, at`

**Operation:** `mem32[as + at] = fr`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssxp – Store of a float, then add to the address

**Syntax:** `ssxp fr, as, at`

**Operation:** `mem32[as] = fr; as += at`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## sub – Subtraction of two registers

**Syntax:** `sub ar, as, at`

**Operation:** `ar = as - at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sub.s – Floating point subtraction

**Syntax:** `sub.s fr, fs, ft`

**Operation:** `fr = fs - ft`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## subx2 – Subtraction, the first register times 2

**Syntax:** `subx2 ar, as, at`

**Operation:** `ar = (as << 1) - at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subx4 – Subtraction, the first register times 4

**Syntax:** `subx4 ar, as, at`

**Operation:** `ar = (as << 2) - at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subx8 – Subtraction, the first register times 8

**Syntax:** `subx8 ar, as, at`

**Operation:** `ar = (as << 3) - at`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## syscall – System call: raises the exception SYSCALL

**Syntax:** `syscall`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## trunc.s – Convert to an integer, truncated

**Syntax:** `trunc.s ar, fs, imm4`

**Operation:** `ar = trunc(fs * 2^imm4)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ueq.s – Comparison: 1 if equal or NaN

**Syntax:** `ueq.s br, fs, ft`

**Operation:** `br = fs == ft or unordered`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ufloat.s – Convert an unsigned integer to float

**Syntax:** `ufloat.s fr, as, imm4`

Convert an unsigned integer to float, divided by 2^imm4.

**Operation:** `fr = ufloat(as) / 2^imm4`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ule.s – Comparison: 1 if less or equal or NaN

**Syntax:** `ule.s br, fs, ft`

**Operation:** `br = fs <= ft or unordered`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## ult.s – Comparison: 1 if less or NaN

**Syntax:** `ult.s br, fs, ft`

**Operation:** `br = fs < ft or unordered`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## un.s – Comparison: 1 if one of the numbers is NaN

**Syntax:** `un.s br, fs, ft`

**Operation:** `br = isnan(fs) or isnan(ft)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## utrunc.s – Convert to an unsigned integer, truncated

**Syntax:** `utrunc.s ar, fs, imm4`

**Operation:** `ar = utrunc(fs * 2^imm4)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## waiti – Set the interrupt level and wait for an interrupt

**Syntax:** `waiti imm4`

Set the interrupt level and wait for an interrupt (saves power).

**Operation:** `PS.INTLEVEL = imm4; wait`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wdtlb – Write an entry of the data TLB

**Syntax:** `wdtlb at, as`

**Operation:** `DTLB[as] = at`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wer – Write an external register

**Syntax:** `wer at, as`

**Operation:** `ER[as] = at`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wfr – Copy an address register to a float register

**Syntax:** `wfr fr, as`

Copy an address register to a float register (the bits).

**Operation:** `fr = bits(as)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## witlb – Write an entry of the instruction TLB

**Syntax:** `witlb at, as`

**Operation:** `ITLB[as] = at`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wsr – Write a special register; also wsr.name at

**Syntax:** `wsr sr, at`

**Operation:** `SR[sr] = at`

*Group: Special and user registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## wur – Write a user register; also wur.name at

**Syntax:** `wur ur, at`

**Operation:** `UR[ur] = at`

*Group: Special and user registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## xor – Exclusive OR

**Syntax:** `xor ar, as, at`

**Operation:** `ar = as ^ at`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## xorb – Exclusive OR of boolean registers

**Syntax:** `xorb br, bs, bt`

**Operation:** `br = bs ^ bt`

*Group: Boolean registers. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsr – Exchange a special register and a register

**Syntax:** `xsr sr, at`

Exchange a special register and a register; also xsr.name at.

**Operation:** `t = SR[sr]; SR[sr] = at; at = t`

*Group: Special and user registers. Short description from the instruction reference; there is no longer explanation for it yet.*
