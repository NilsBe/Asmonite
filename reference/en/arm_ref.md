# Instructions from the instruction reference (generated)

Made by tools/gen_help_ref.py from the tables of the assembler (tools/instr), do not edit. F1 shows a section from here when the help of the architecture has none of its own.

## adc – Addition with carry

**Syntax:** `adc Rd, Rn, #const` &nbsp; `adc Rd, Rn, Rm{, shift #imm}`

Addition with carry: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn + const + C; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adcs – Addition with carry (C)

**Syntax:** `adcs Rdn, Rm`

**Operation:** `Rdn = Rdn + Rm + C`

**Flags:** N Z C V

Also shown as: `adc`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## add – Addition of two registers

**Syntax:** `add Rdn, Rm` &nbsp; `add Rd, sp, #imm8*4` &nbsp; `add sp, sp, #imm7*4` &nbsp; `add Rd, Rn, #const` &nbsp; `add Rd, Rn, Rm{, shift #imm}`

Addition of two registers (also r8 to r15, sets no flags).

**Operation:** `Rdn = Rdn + Rm`

Also shown as: `cmn`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adds – Addition of two registers

**Syntax:** `adds Rd, Rn, Rm` &nbsp; `adds Rd, Rn, #imm3` &nbsp; `adds Rdn, #imm8`

**Operation:** `Rd = Rn + Rm`

**Flags:** N Z C V

Also shown as: `add`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addw – Addition of a constant (12 bit)

**Syntax:** `addw Rd, Rn, #imm12`

**Operation:** `Rd = Rn + imm12 (i:imm3:imm8)`

Also shown as: `add`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adr – Address relative to the program counter

**Syntax:** `adr Rd, label`

**Operation:** `Rd = align(pc, 4) + imm8 * 4`

Also shown as: `add`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## and – Bitwise AND

**Syntax:** `and Rd, Rn, #const` &nbsp; `and Rd, Rn, Rm{, shift #imm}`

Bitwise AND: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn & const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Also shown as: `tst`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## ands – Bitwise AND

**Syntax:** `ands Rdn, Rm`

**Operation:** `Rdn = Rdn & Rm`

**Flags:** N Z

Also shown as: `and`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## asr – Shift right signed by a register (32-bit form)

**Syntax:** `asr Rd, Rn, Rm`

**Operation:** `Rd = Rn >>s Rm[7:0]`

**Flags:** N Z C (if S)

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## asrs – Shift right signed by a constant

**Syntax:** `asrs Rd, Rm, #imm5` &nbsp; `asrs Rdn, Rm`

**Operation:** `Rd = Rm >>s imm5 (imm5 = 0 means 32)`

**Flags:** N Z C

Also shown as: `asr`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## b – Jump (relative, +-2 KB)

**Syntax:** `b label`

**Operation:** `pc = pc + (sext(imm11) << 1)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## b.cond – Conditional jump (relative, +-256 bytes)

**Syntax:** `b.cond label`

**Operation:** `if cond then pc = pc + (sext(imm8) << 1)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bfi – Insertion of a bitfield from Rn into Rd

**Syntax:** `bfi Rd, Rn, #lsb, #width`

Insertion of a bitfield from Rn into Rd (bfc: zeros).

**Operation:** `Rd[msb : lsb] = Rn[msb - lsb : 0]`

Also shown as: `bfc`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## bic – Bitwise AND with an inverted constant

**Syntax:** `bic Rd, Rn, #const` &nbsp; `bic Rd, Rn, Rm{, shift #imm}`

Bitwise AND with an inverted constant: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn & ~const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bics – Bitwise AND with an inverted operand (bit clear)

**Syntax:** `bics Rdn, Rm`

**Operation:** `Rdn = Rdn & ~Rm`

**Flags:** N Z

Also shown as: `bic`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bkpt – Breakpoint

**Syntax:** `bkpt #imm8`

**Operation:** `raise a breakpoint exception`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## bl – Call of a function

**Syntax:** `bl label`

Call of a function (relative, +-16 MB, lr = return address).

**Operation:** `lr = (pc + 4) | 1; pc = pc + sext(S:J1:J2:imm10:imm11 << 1)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blx – Call of the function at the address in the register

**Syntax:** `blx Rm` &nbsp; `blx label`

Call of the function at the address in the register (lr = return address).

**Operation:** `lr = (pc + 2) | 1; pc = Rm & ~1`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blxns – Call of a register with a change to the non-secure state

**Syntax:** `blxns Rm`

Call of a register with a change to the non-secure state (TrustZone, ARMv8-M).

**Operation:** `lr = next; pc = Rm; state = non-secure`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bx – Jump to the address in the register

**Syntax:** `bx Rm`

Jump to the address in the register (bit 0 selects Thumb, ARM if bit 0 = 0).

**Operation:** `pc = Rm & ~1; instruction set = Rm[0]`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bxns – Jump to a register with a change to the non-secure state

**Syntax:** `bxns Rm`

Jump to a register with a change to the non-secure state (TrustZone, ARMv8-M).

**Operation:** `pc = Rm; state = non-secure`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## cbnz – Jump forward if the register is not 0

**Syntax:** `cbnz Rn, label`

**Operation:** `if Rn != 0 then pc = pc + (i:imm5 << 1)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## cbz – Jump forward if the register is 0

**Syntax:** `cbz Rn, label`

**Operation:** `if Rn == 0 then pc = pc + (i:imm5 << 1)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## clz – Count of the leading zero bits

**Syntax:** `clz Rd, Rm`

**Operation:** `Rd = count_leading_zeros(Rm)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmn – Comparison by addition

**Syntax:** `cmn Rn, Rm`

Comparison by addition (Rn plus Rm), only the flags change.

**Operation:** `flags = Rn + Rm`

**Flags:** N Z C V

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmp – Comparison with a constant (8 bit)

**Syntax:** `cmp Rn, #imm8` &nbsp; `cmp Rn, Rm`

**Operation:** `flags = Rn - imm8`

**Flags:** N Z C V

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpsid – Disabling (cpsid) or enabling

**Syntax:** `cpsid i`

Disabling (cpsid) or enabling (cpsie) of interrupts (privileged).

**Operation:** `PRIMASK = im`

Also shown as: `cpsie`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## dmb – Memory barrier for the order of the accesses

**Syntax:** `dmb option`

**Operation:** `earlier memory accesses are observed before later ones`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## dsb – Memory barrier

**Syntax:** `dsb option`

Memory barrier: waits until all accesses are complete.

**Operation:** `wait until all earlier memory accesses are complete`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## eor – Bitwise exclusive OR

**Syntax:** `eor Rd, Rn, #const` &nbsp; `eor Rd, Rn, Rm{, shift #imm}`

Bitwise exclusive OR: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn ^ const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Also shown as: `teq`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## eors – Bitwise exclusive OR

**Syntax:** `eors Rdn, Rm`

**Operation:** `Rdn = Rdn ^ Rm`

**Flags:** N Z

Also shown as: `eor`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## hint – Hint instruction with a number from 0 to 15

**Syntax:** `hint #imm`

Hint instruction with a number from 0 to 15 (nop, yield, wfe, wfi, sev have their own names; the others do nothing).

**Operation:** `no change`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## isb – Instruction barrier: flushes the pipeline

**Syntax:** `isb option`

**Operation:** `all instructions after it are fetched anew`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## it – IT block: makes the following 1 to 4 instructions conditional

**Syntax:** `it {x{y{z}}} cond`

**Operation:** `the next instructions run only if the condition holds (or its opposite for else)`

Also shown as: `ite`, `itt`, `itee`, `itet`, `itte`, `ittt`, `iteee`, `iteet`, `itete`, `itett`, `ittee`, `ittet`, `ittte`, `itttt`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldm – Load of several registers (increasing)

**Syntax:** `ldm Rn{!}, {registers}`

**Operation:** `for each register in the list: reg = [Rn]; Rn = Rn + 4`

Also shown as: `ldmia`, `pop`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldmdb – Load of several registers (decreasing)

**Syntax:** `ldmdb Rn{!}, {registers}`

**Operation:** `for each register in the list, last first: Rn = Rn - 4; reg = [Rn]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldr – Load of a word relative to the program counter

**Syntax:** `ldr Rt, label` &nbsp; `ldr Rt, [Rn, Rm]` &nbsp; `ldr Rt, [Rn{, #imm5*4}]` &nbsp; `ldr Rt, [sp{, #imm8*4}]` &nbsp; `ldr Rt, [Rn, #imm12]` &nbsp; `ldr Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldr Rt, [Rn, Rm{, lsl #imm2}]`

Load of a word relative to the program counter (literal pool, up to 1020 bytes).

**Operation:** `Rt = [align(pc, 4) + imm8 * 4]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrb – Load of a byte (register address)

**Syntax:** `ldrb Rt, [Rn, Rm]` &nbsp; `ldrb Rt, [Rn{, #imm5}]` &nbsp; `ldrb Rt, [Rn, #imm12]` &nbsp; `ldrb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrb Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `Rt = zext([Rn + Rm])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrbt – Load of a byte with the rights of user mode

**Syntax:** `ldrbt Rt, [Rn{, #imm8}]`

**Operation:** `Rt = zext([Rn + imm8])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrd – Load of a register pair (two words)

**Syntax:** `ldrd Rt, Rt2, [Rn, #+/-imm8*4]{!}  /  [Rn], #+/-imm8*4`

**Operation:** `Rt = [addr]; Rt2 = [addr + 4]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrex – Load-exclusive: sets the exclusive monitor

**Syntax:** `ldrex Rt, [Rn{, #imm8*4}]`

**Operation:** `Rt = [Rn + imm8 * 4]; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrexb – Load of a byte (exclusive)

**Syntax:** `ldrexb Rt, [Rn]`

**Operation:** `Rt = zext([Rn]); set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrexd – Load of a double word

**Syntax:** `ldrexd Rt, Rt2, [Rn]`

Load of a double word (exclusive): sets the exclusive monitor.

**Operation:** `Rt:Rt2 = [Rn]; mark exclusive`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrexh – Load of a half word (exclusive)

**Syntax:** `ldrexh Rt, [Rn]`

**Operation:** `Rt = zext([Rn]); set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrh – Load of a half word (register address)

**Syntax:** `ldrh Rt, [Rn, Rm]` &nbsp; `ldrh Rt, [Rn{, #imm5*2}]` &nbsp; `ldrh Rt, [Rn, #imm12]` &nbsp; `ldrh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrh Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `Rt = zext([Rn + Rm])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrht – Load of a half word with the rights of user mode

**Syntax:** `ldrht Rt, [Rn{, #imm8}]`

**Operation:** `Rt = zext([Rn + imm8])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsb – Load of a signed byte (register address)

**Syntax:** `ldrsb Rt, [Rn, Rm]` &nbsp; `ldrsb Rt, [Rn, #imm12]` &nbsp; `ldrsb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrsb Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `Rt = sext([Rn + Rm])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsbt – Load of a byte with sign extension with the rights of user mode

**Syntax:** `ldrsbt Rt, [Rn{, #imm8}]`

**Operation:** `Rt = sext([Rn + imm8])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsh – Load of a signed half word (register address)

**Syntax:** `ldrsh Rt, [Rn, Rm]` &nbsp; `ldrsh Rt, [Rn, #imm12]` &nbsp; `ldrsh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrsh Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `Rt = sext([Rn + Rm])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsht – Load of a half word with sign extension with the rights of user mode

**Syntax:** `ldrsht Rt, [Rn{, #imm8}]`

**Operation:** `Rt = sext([Rn + imm8])`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrt – Load of a word with the rights of user mode

**Syntax:** `ldrt Rt, [Rn{, #imm8}]`

**Operation:** `Rt = [Rn + imm8]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsl – Shift left by a register (32-bit form)

**Syntax:** `lsl Rd, Rn, Rm`

**Operation:** `Rd = Rn << Rm[7:0]`

**Flags:** N Z C (if S)

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsls – Shift left by a constant

**Syntax:** `lsls Rd, Rm, #imm5` &nbsp; `lsls Rdn, Rm`

**Operation:** `Rd = Rm << imm5`

**Flags:** N Z C

Also shown as: `lsl`, `movs`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsr – Shift right unsigned by a register (32-bit form)

**Syntax:** `lsr Rd, Rn, Rm`

**Operation:** `Rd = Rn >> Rm[7:0]`

**Flags:** N Z C (if S)

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsrs – Shift right unsigned by a constant

**Syntax:** `lsrs Rd, Rm, #imm5` &nbsp; `lsrs Rdn, Rm`

**Operation:** `Rd = Rm >> imm5 (imm5 = 0 means 32)`

**Flags:** N Z C

Also shown as: `lsr`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## mcr – Coprocessor access

**Syntax:** `mcr coproc, #opc1, Rt, CRn, CRm{, #opc2}`

Coprocessor access: write of a register to a coprocessor (mcr) or read (mrc, L = 1).

**Operation:** `coprocessor register = Rt or Rt = coprocessor register`

Also shown as: `mrc`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## mla – Multiply and add

**Syntax:** `mla Rd, Rn, Rm, Ra`

**Operation:** `Rd = Ra + Rn * Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mls – Multiply and subtract

**Syntax:** `mls Rd, Rn, Rm, Ra`

**Operation:** `Rd = Ra - Rn * Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mov – Copy of a register (also r8 to r15, sets no flags)

**Syntax:** `mov Rd, Rm`

**Operation:** `Rd = Rm`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movs – Load of a constant (8 bit)

**Syntax:** `movs Rd, #imm8`

**Operation:** `Rd = imm8`

**Flags:** N Z

Also shown as: `mov`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movt – Load of the upper half of a register

**Syntax:** `movt Rd, #imm16`

Load of the upper half of a register (the lower half stays).

**Operation:** `Rd[31:16] = imm4:i:imm3:imm8`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movw – Load of a 16-bit constant (the upper half 0)

**Syntax:** `movw Rd, #imm16`

**Operation:** `Rd = zext(imm4:i:imm3:imm8)`

Also shown as: `mov`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## mrs – Read of a system register

**Syntax:** `mrs Rd, sysreg`

Read of a system register (apsr, ipsr, msp, psp, primask ...).

**Operation:** `Rd = sysreg`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## msr – Write of a system register

**Syntax:** `msr sysreg, Rn`

**Operation:** `sysreg = Rn`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## mul – Multiplication (low 32 bits)

**Syntax:** `mul Rd, Rn, Rm`

**Operation:** `Rd = Rn * Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## muls – Multiplication (low 32 bits)

**Syntax:** `muls Rdm, Rn, Rdm`

**Operation:** `Rdm = Rn * Rdm`

**Flags:** N Z

Also shown as: `mul`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mvns – Bitwise inversion

**Syntax:** `mvns Rd, Rm`

**Operation:** `Rd = ~Rm`

**Flags:** N Z

Also shown as: `mvn`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## nop – No operation

**Syntax:** `nop`

**Operation:** `no change`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## orn – Bitwise OR with an inverted constant

**Syntax:** `orn Rd, Rn, #const` &nbsp; `orn Rd, Rn, Rm{, shift #imm}`

Bitwise OR with an inverted constant: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn OR ~const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Also shown as: `mvn`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orr – Bitwise OR

**Syntax:** `orr Rd, Rn, #const` &nbsp; `orr Rd, Rn, Rm{, shift #imm}`

Bitwise OR: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn OR const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Also shown as: `mov`, `lsl`, `lsr`, `asr`, `ror`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orrs – Bitwise OR

**Syntax:** `orrs Rdn, Rm`

**Operation:** `Rdn = Rdn OR Rm`

**Flags:** N Z

Also shown as: `orr`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## pld – Prefetch of a cache line for reading (hint)

**Syntax:** `pld [Rn, #imm12]`

**Operation:** `prefetch the cache line at Rn + imm12 (a hint)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## pldw – Prefetch of a cache line for writing (hint)

**Syntax:** `pldw [Rn, #imm12]`

**Operation:** `prefetch the cache line at Rn + imm12 (a hint)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## pli – Prefetch of a cache line for instructions (hint)

**Syntax:** `pli [Rn, #imm12]`

**Operation:** `prefetch the cache line at Rn + imm12 (a hint)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## pop – Pop of registers

**Syntax:** `pop {registers{, pc}}`

Pop of registers (P: also pc, a return) from the stack.

**Operation:** `load the registers upward from sp; sp = sp + 4 * count`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## push – Push of registers (M: also lr) onto the stack

**Syntax:** `push {registers{, lr}}`

**Operation:** `sp = sp - 4 * count; store the registers upward from sp`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## rbit – Reversal of the bit order

**Syntax:** `rbit Rd, Rm`

**Operation:** `Rd = reverse_bits(Rm)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev – Reversal of the bytes (little/big endian)

**Syntax:** `rev Rd, Rm`

**Operation:** `Rd = reverse_bytes(Rm)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev16 – Reversal of the bytes in each half word

**Syntax:** `rev16 Rd, Rm`

**Operation:** `Rd = reverse_bytes_in_each_16_bits(Rm)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## revsh – Reversal of the low two bytes, sign-extended

**Syntax:** `revsh Rd, Rm`

**Operation:** `Rd = sext(reverse_bytes(Rm[15:0]))`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## ror – Shift right (rotation) by a register (32-bit form)

**Syntax:** `ror Rd, Rn, Rm`

**Operation:** `Rd = rotate_right(Rn, Rm[7:0])`

**Flags:** N Z C (if S)

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## rors – Rotate right by a register

**Syntax:** `rors Rdn, Rm`

**Operation:** `Rdn = rotate_right(Rdn, Rm[7:0])`

**Flags:** N Z C

Also shown as: `ror`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsb – Reverse subtraction

**Syntax:** `rsb Rd, Rn, #const` &nbsp; `rsb Rd, Rn, Rm{, shift #imm}`

Reverse subtraction: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = const - Rn; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsbs – Reverse subtraction from 0 (negation)

**Syntax:** `rsbs Rd, Rn, #0`

**Operation:** `Rd = 0 - Rn`

**Flags:** N Z C V

Also shown as: `neg`, `rsb`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbc – Subtraction with borrow

**Syntax:** `sbc Rd, Rn, #const` &nbsp; `sbc Rd, Rn, Rm{, shift #imm}`

Subtraction with borrow: constant as the second operand (8 bit, rotated or repeated).

**Operation:** `Rd = Rn - const - (1 - C); the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbcs – Subtraction with borrow (C)

**Syntax:** `sbcs Rdn, Rm`

**Operation:** `Rdn = Rdn - Rm - (1 - C)`

**Flags:** N Z C V

Also shown as: `sbc`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbfx – Extraction of a bitfield with sign extension

**Syntax:** `sbfx Rd, Rn, #lsb, #width`

**Operation:** `Rd = sext(Rn[lsb + width - 1 : lsb])`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## sdiv – Signed division (division by 0 gives 0)

**Syntax:** `sdiv Rd, Rn, Rm`

**Operation:** `Rd = Rn / Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## setend – Selection of the byte order for data accesses

**Syntax:** `setend le|be`

Selection of the byte order for data accesses (E = 0: little endian, 1: big endian; deprecated in ARMv8).

**Operation:** `data endianness = E`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sev – Send of an event to all processors

**Syntax:** `sev`

**Operation:** `set the event register of all processors`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## smlal – Signed multiplication to 64 bits with addition

**Syntax:** `smlal RdLo, RdHi, Rn, Rm`

**Operation:** `RdHi:RdLo = RdHi:RdLo + sext(Rn) * sext(Rm)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## smull – Signed multiplication to 64 bits

**Syntax:** `smull RdLo, RdHi, Rn, Rm`

**Operation:** `RdHi:RdLo = sext(Rn) * sext(Rm)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## stm – Store of several registers

**Syntax:** `stm Rn!, {registers}` &nbsp; `stm Rn{!}, {registers}`

Store of several registers (increasing, Rn is written back).

**Operation:** `for each register in the list: [Rn] = reg; Rn = Rn + 4`

Also shown as: `stmia`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stmdb – Store of several registers

**Syntax:** `stmdb Rn{!}, {registers}`

Store of several registers (decreasing; push is stmdb sp!).

**Operation:** `for each register in the list, last first: Rn = Rn - 4; [Rn] = reg`

Also shown as: `push`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## str – Store of a word (register address)

**Syntax:** `str Rt, [Rn, Rm]` &nbsp; `str Rt, [Rn{, #imm5*4}]` &nbsp; `str Rt, [sp{, #imm8*4}]` &nbsp; `str Rt, [Rn, #imm12]` &nbsp; `str Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `str Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `[Rn + Rm] = Rt`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strb – Store of a byte (register address)

**Syntax:** `strb Rt, [Rn, Rm]` &nbsp; `strb Rt, [Rn{, #imm5}]` &nbsp; `strb Rt, [Rn, #imm12]` &nbsp; `strb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `strb Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `[Rn + Rm] = Rt[7:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strbt – Store of a byte with the rights of user mode

**Syntax:** `strbt Rt, [Rn{, #imm8}]`

**Operation:** `[Rn + imm8] = Rt[7:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strd – Store of a register pair (two words)

**Syntax:** `strd Rt, Rt2, [Rn, #+/-imm8*4]{!}  /  [Rn], #+/-imm8*4`

**Operation:** `[addr] = Rt; [addr + 4] = Rt2`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strex – Store-exclusive: Rd = 0 on success

**Syntax:** `strex Rd, Rt, [Rn{, #imm8*4}]`

**Operation:** `if the exclusive monitor is set then { [Rn + imm8 * 4] = Rt; Rd = 0 } else Rd = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strexb – Store-exclusive of a byte

**Syntax:** `strexb Rd, Rt, [Rn]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt[7:0]; Rd = 0 } else Rd = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strexd – Store of a double word

**Syntax:** `strexd Rd, Rt, Rt2, [Rn]`

Store of a double word (exclusive): only if the monitor is still set.

**Operation:** `if exclusive then [Rn] = Rt:Rt2; Rd = 0 else Rd = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strexh – Store-exclusive of a half word

**Syntax:** `strexh Rd, Rt, [Rn]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt[15:0]; Rd = 0 } else Rd = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strh – Store of a half word (register address)

**Syntax:** `strh Rt, [Rn, Rm]` &nbsp; `strh Rt, [Rn{, #imm5*2}]` &nbsp; `strh Rt, [Rn, #imm12]` &nbsp; `strh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `strh Rt, [Rn, Rm{, lsl #imm2}]`

**Operation:** `[Rn + Rm] = Rt[15:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strht – Store of a half word with the rights of user mode

**Syntax:** `strht Rt, [Rn{, #imm8}]`

**Operation:** `[Rn + imm8] = Rt[15:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strt – Store of a word with the rights of user mode

**Syntax:** `strt Rt, [Rn{, #imm8}]`

**Operation:** `[Rn + imm8] = Rt`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sub – Decrease of the stack pointer

**Syntax:** `sub sp, sp, #imm7*4` &nbsp; `sub Rd, Rn, #const` &nbsp; `sub Rd, Rn, Rm{, shift #imm}`

**Operation:** `sp = sp - imm7 * 4`

Also shown as: `cmp`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subs – Subtraction of two registers

**Syntax:** `subs Rd, Rn, Rm` &nbsp; `subs Rd, Rn, #imm3` &nbsp; `subs Rdn, #imm8`

**Operation:** `Rd = Rn - Rm`

**Flags:** N Z C V

Also shown as: `sub`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subw – Subtraction of a constant (12 bit)

**Syntax:** `subw Rd, Rn, #imm12`

**Operation:** `Rd = Rn - imm12 (i:imm3:imm8)`

Also shown as: `sub`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## svc – Supervisor call to the operating system

**Syntax:** `svc #imm8`

**Operation:** `raise a supervisor call exception with imm8`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sxtab – Extension of a byte or half word

**Syntax:** `sxtab Rd, Rn, Rm{, ror #rot}`

Extension of a byte or half word (sxt: signed, uxt: zero) and addition of Rn; ...16: two half words from two bytes; Rm rotated by 0/8/16/24 first.

**Operation:** `Rd = Rn + extend(ror(Rm, rot))`

Also shown as: `sxtah`, `sxtab16`, `uxtab`, `uxtah`, `uxtab16`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## sxtb – Sign extension of a byte

**Syntax:** `sxtb Rd, Rm` &nbsp; `sxtb Rd, Rm{, ror #rot}`

**Operation:** `Rd = sext(Rm[7:0])`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## sxtb16 – Extension of two bytes to two half words

**Syntax:** `sxtb16 Rd, Rm{, ror #rot}`

Extension of two bytes to two half words (sxt: signed, uxt: zero); Rm rotated by 0/8/16/24 first.

**Operation:** `Rd = extend(ror(Rm, rot)) per half word`

Also shown as: `uxtb16`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## sxth – Sign extension of a half word

**Syntax:** `sxth Rd, Rm` &nbsp; `sxth Rd, Rm{, ror #rot}`

**Operation:** `Rd = sext(Rm[15:0])`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## tbb – Jump through a table of byte offsets

**Syntax:** `tbb [Rn, Rm]`

**Operation:** `pc = pc + 2 * zext([Rn + Rm])`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## tbh – Jump through a table of half word offsets

**Syntax:** `tbh [Rn, Rm, lsl #1]`

**Operation:** `pc = pc + 2 * zext([Rn + 2 * Rm])`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## tst – Bitwise test (AND), only the flags change

**Syntax:** `tst Rn, Rm`

**Operation:** `flags = Rn & Rm`

**Flags:** N Z

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## tt – Test of the target of an address

**Syntax:** `tt Rd, Rn`

Test of the target of an address (TrustZone: security state and access rights; A: alternate, T: unprivileged).

**Operation:** `Rd = security attributes of the address Rn`

Also shown as: `tta`, `ttt`, `ttat`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ubfx – Extraction of a bitfield with zero extension

**Syntax:** `ubfx Rd, Rn, #lsb, #width`

**Operation:** `Rd = zext(Rn[lsb + width - 1 : lsb])`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## udf – Deliberately undefined instruction

**Syntax:** `udf #imm8` &nbsp; `udf #imm16`

Deliberately undefined instruction (raises an exception).

**Operation:** `raise an undefined instruction exception`

Also shown as: `trap`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## udiv – Unsigned division (division by 0 gives 0)

**Syntax:** `udiv Rd, Rn, Rm`

**Operation:** `Rd = Rn / Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## umlal – Unsigned multiplication to 64 bits with addition

**Syntax:** `umlal RdLo, RdHi, Rn, Rm`

**Operation:** `RdHi:RdLo = RdHi:RdLo + zext(Rn) * zext(Rm)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## umull – Unsigned multiplication to 64 bits

**Syntax:** `umull RdLo, RdHi, Rn, Rm`

**Operation:** `RdHi:RdLo = zext(Rn) * zext(Rm)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## uxtb – Zero extension of a byte

**Syntax:** `uxtb Rd, Rm` &nbsp; `uxtb Rd, Rm{, ror #rot}`

**Operation:** `Rd = zext(Rm[7:0])`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## uxth – Zero extension of a half word

**Syntax:** `uxth Rd, Rm` &nbsp; `uxth Rd, Rm{, ror #rot}`

**Operation:** `Rd = zext(Rm[15:0])`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## vabs – Floating point

**Syntax:** `vabs Vd, Vm`

Floating point: absolute value (sz: 0 = single, 1 = double).

**Operation:** `Vd = abs(Vm)`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vadd – Floating point

**Syntax:** `vadd Vd, Vn, Vm`

Floating point: addition (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vn + Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vcmp – Floating point

**Syntax:** `vcmp Vd, Vm` &nbsp; `vcmp Vd, #0.0`

Floating point: comparison of two registers, sets the FPSCR flags (vcmpe: raises an exception on NaN; then vmrs apsr_nzcv, fpscr).

**Operation:** `fpscr flags = compare(Vd, Vm)`

**Flags:** N Z C V (FPSCR)

Also shown as: `vcmpe`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vcvt – Floating point

**Syntax:** `vcvt Sd, Sm  /  Dd, Sm` &nbsp; `vcvt Sd, Sm  /  Sd, Dm` &nbsp; `vcvt Dd, Sm  /  Sd, Dm`

Floating point: conversion of an integer to floating point (op = 1: signed, 0: unsigned).

**Operation:** `Vd = (float) Vm`

Also shown as: `vcvtr`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vdiv – Floating point

**Syntax:** `vdiv Vd, Vn, Vm`

Floating point: division (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vn / Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vfma – Floating point

**Syntax:** `vfma Vd, Vn, Vm`

Floating point: fused multiplication with addition (no intermediate rounding) (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vd + Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vfms – Floating point

**Syntax:** `vfms Vd, Vn, Vm`

Floating point: fused multiplication with subtraction (no intermediate rounding) (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vd - Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vfnma – Floating point

**Syntax:** `vfnma Vd, Vn, Vm`

Floating point: negated fused multiplication with addition (no intermediate rounding) (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = -Vd - Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vfnms – Floating point

**Syntax:** `vfnms Vd, Vn, Vm`

Floating point: negated fused multiplication with subtraction (no intermediate rounding) (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = -Vd + Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vldm – Floating point

**Syntax:** `vldm Rn{!}, {Sd | Dd list}`

Floating point: load of several registers ascending from the address (vldmia; vpop = vldmia sp!; fldmx with an odd count).

**Operation:** `registers = [Rn ...]; optionally Rn = Rn + size`

Also shown as: `vldmia`, `vpop`, `fldmiax`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vldmdb – Floating point

**Syntax:** `vldmdb Rn!, {Sd | Dd list}`

Floating point: load of several registers descending below the address, Rn is decreased (vldmdb).

**Operation:** `Rn = Rn - size; registers = [Rn ...]`

Also shown as: `fldmdbx`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vldr – Floating point

**Syntax:** `vldr Sd|Dd, [Rn{, #+/-imm8*4}]`

Floating point: load of a register from memory (sz: 0 = single, 1 = double).

**Operation:** `Vd = [Rn +/- imm8 * 4]`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmla – Floating point

**Syntax:** `vmla Vd, Vn, Vm`

Floating point: multiplication with addition to the destination (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vd + Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmls – Floating point

**Syntax:** `vmls Vd, Vn, Vm`

Floating point: multiplication with subtraction from the destination (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vd - Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmov – Floating point

**Syntax:** `vmov Vd, Vm` &nbsp; `vmov Sd|Dd, #imm` &nbsp; `vmov Sn, Rt  /  Rt, Sn` &nbsp; `vmov Sm, Sm1, Rt, Rt2  /  Dm, Rt, Rt2` &nbsp; `vmov Dd[x], Rt  /  Rt, Dn[x]`

Floating point: copy of a floating point register (sz: 0 = single, 1 = double).

**Operation:** `Vd = Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmrs – Copy of a floating point system register to an integer register

**Syntax:** `vmrs Rt, FPSID|FPSCR`

Copy of a floating point system register to an integer register (with Rt = pc: to the APSR flags).

**Operation:** `Rt = system register`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmsr – Copy of an integer register to a floating point system register

**Syntax:** `vmsr FPSID|FPSCR, Rt`

**Operation:** `system register = Rt`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vmul – Floating point

**Syntax:** `vmul Vd, Vn, Vm`

Floating point: multiplication (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vneg – Floating point

**Syntax:** `vneg Vd, Vm`

Floating point: sign change (sz: 0 = single, 1 = double).

**Operation:** `Vd = -Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vnmla – Floating point

**Syntax:** `vnmla Vd, Vn, Vm`

Floating point: negated multiplication with addition (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = -Vd - Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vnmls – Floating point

**Syntax:** `vnmls Vd, Vn, Vm`

Floating point: negated multiplication with subtraction (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = -Vd + Vn * Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vnmul – Floating point

**Syntax:** `vnmul Vd, Vn, Vm`

Floating point: negated multiplication (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = -(Vn * Vm)`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vsqrt – Floating point

**Syntax:** `vsqrt Vd, Vm`

Floating point: square root (sz: 0 = single, 1 = double).

**Operation:** `Vd = sqrt(Vm)`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vstm – Floating point

**Syntax:** `vstm Rn{!}, {Sd | Dd list}`

Floating point: store of several registers ascending from the address (vstmia; fstmx with an odd count).

**Operation:** `[Rn ...] = registers; optionally Rn = Rn + size`

Also shown as: `vstmia`, `fstmiax`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vstmdb – Floating point

**Syntax:** `vstmdb Rn!, {Sd | Dd list}`

Floating point: store of several registers descending below the address, Rn is decreased (vstmdb; vpush = vstmdb sp!).

**Operation:** `Rn = Rn - size; [Rn ...] = registers`

Also shown as: `vpush`, `fstmdbx`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vstr – Floating point

**Syntax:** `vstr Sd|Dd, [Rn{, #+/-imm8*4}]`

Floating point: store of a register to memory (sz: 0 = single, 1 = double).

**Operation:** `[Rn +/- imm8 * 4] = Vd`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## vsub – Floating point

**Syntax:** `vsub Vd, Vn, Vm`

Floating point: subtraction (sz = 0: single, Sd/Sn/Sm; sz = 1: double, Dd/Dn/Dm).

**Operation:** `Vd = Vn - Vm`

*Group: Floating point (VFP). Short description from the instruction reference; there is no longer explanation for it yet.*

## wfe – Wait for event

**Syntax:** `wfe`

**Operation:** `sleep until an event`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wfi – Wait for interrupt

**Syntax:** `wfi`

**Operation:** `sleep until an interrupt`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## yield – Hint: spin loop

**Syntax:** `yield`

Hint: spin loop, the processor may switch to another thread.

**Operation:** `no change (a hint)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*
