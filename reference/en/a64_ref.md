# Instructions from the instruction reference (generated)

Made by tools/gen_help_ref.py from the tables of the assembler (tools/instr), do not edit. F1 shows a section from here when the help of the architecture has none of its own.

## abs – Absolute value

**Syntax:** `abs Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = abs(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## adc – Addition with carry (C)

**Syntax:** `adc Rd, Rn, Rm`

**Operation:** `Rd = Rn + Rm + C`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adcs – Addition with carry, sets the flags

**Syntax:** `adcs Rd, Rn, Rm`

**Operation:** `Rd = Rn + Rm + C`

**Flags:** N Z C V

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## add – Addition of a constant

**Syntax:** `add Rd, Rn, #imm12{, lsl #12}` &nbsp; `add Rd, Rn, Rm{, shift #imm6}` &nbsp; `add Rd, Rn, Rm{, extend #imm3}` &nbsp; `add Vd.T, Vn.T, Vm.T`

Addition of a constant (12 bit, optionally shifted left by 12).

**Operation:** `Rd = Rn + (imm12 << (sh * 12)) (Rd and Rn may be SP)`

Also shown as: `mov`, `cmn`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addg – Addition to an address with a change of the tag

**Syntax:** `addg Xd|SP, Xn|SP, #uimm6, #uimm4`

**Operation:** `Xd = Xn + uimm6 * 16, tag = (tag of Xn + uimm4) modulo 16`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## addhn – Addition with narrowing

**Syntax:** `addhn Vd.Tb, Vn.Ta, Vm.Ta`

Addition with narrowing (high half; raddhn with rounding) (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = high half of (Vn[i] + Vm[i])`

Also shown as: `addhn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## addp – Addition of adjacent element pairs

**Syntax:** `addp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = sum of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## adds – Addition of a constant, sets the flags

**Syntax:** `adds Rd, Rn, #imm12{, lsl #12}` &nbsp; `adds Rd, Rn, Rm{, shift #imm6}` &nbsp; `adds Rd, Rn, Rm{, extend #imm3}`

**Operation:** `Rd = Rn + (imm12 << (sh * 12))`

**Flags:** N Z C V

Also shown as: `cmn`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addv – Sum of all elements

**Syntax:** `addv Vd, Vn.T`

**Operation:** `Vd = sum of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## adr – Address relative to the program counter (+-1 MB)

**Syntax:** `adr Xd, label`

**Operation:** `Xd = pc + sext(immhi:immlo)`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## adrp – Address of the 4 KB page relative to the program counter

**Syntax:** `adrp Xd, label`

Address of the 4 KB page relative to the program counter (+-4 GB).

**Operation:** `Xd = (pc & ~0xFFF) + (sext(immhi:immlo) << 12)`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## aese – AES encryption

**Syntax:** `aese Vd.16B, Vn.16B`

AES encryption: one round (aese, aesmc) or decryption (aesd, aesimc: the counterparts).

**Operation:** `aese: Vd = SubBytes(ShiftRows(Vd ^ Vn)); aesmc: Vd = MixColumns(Vn)`

Also shown as: `aesd`, `aesmc`, `aesimc`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## and – Bitwise AND with a bit pattern as constant

**Syntax:** `and Rd, Rn, #imm (bit pattern)` &nbsp; `and Rd, Rn, Rm{, shift #imm6}` &nbsp; `and Vd.T, Vn.T, Vm.T`

**Operation:** `Rd = Rn & decode_bitmask(N, imms, immr) (Rd may be SP)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## ands – Bitwise AND with a bit pattern, sets the flags

**Syntax:** `ands Rd, Rn, #imm (bit pattern)` &nbsp; `ands Rd, Rn, Rm{, shift #imm6}`

**Operation:** `Rd = Rn & decode_bitmask(N, imms, immr); C = V = 0`

**Flags:** N Z C V

Also shown as: `tst`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## asrv – Shift right signed by a register

**Syntax:** `asrv Rd, Rn, Rm`

**Operation:** `Rd = Rn >>s (Rm mod width)`

Also shown as: `asr`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## b – Jump (relative, +-128 MB)

**Syntax:** `b label`

**Operation:** `pc = pc + sext(imm26 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## b.cond – Conditional jump (relative, +-1 MB)

**Syntax:** `b.cond label`

**Operation:** `if cond then pc = pc + sext(imm19 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bc – Conditional branch with the hint that it is consistent

**Syntax:** `bc label`

Conditional branch with the hint that it is consistent (FEAT_HBC).

**Operation:** `if cond then pc = pc + imm19 * 4`

Also shown as: `bc.eq`, `bc.ne`, `bc.hs`, `bc.lo`, `bc.mi`, `bc.pl`, `bc.vs`, `bc.vc`, `bc.hi`, `bc.ls`, `bc.ge`, `bc.lt`, `bc.gt`, `bc.le`, `bc.al`, `bc.nv`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## bcax – Bit clear and exclusive OR (SHA-3)

**Syntax:** `bcax Vd.16B, Vn.16B, Vm.16B, Va.16B`

**Operation:** `Vd = Vn ^ (Vm & ~Va)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## bfm – Bitfield move

**Syntax:** `bfm Rd, Rn, #immr, #imms`

Bitfield move, the other bits of Rd stay (base form of bfi, bfxil).

**Operation:** `Rd = (Rd with the field replaced by the field of Rn)`

Also shown as: `bfc`, `bfi`, `bfxil`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## bic – Bitwise AND with an inverted operand (bit clear)

**Syntax:** `bic Rd, Rn, Rm{, shift #imm6}` &nbsp; `bic Vd.T, Vn.T, Vm.T` &nbsp; `bic Vd.T, #imm8{, lsl #amount}`

**Operation:** `Rd = Rn & ~shift(Rm, imm6)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bics – Bitwise AND with an inverted operand

**Syntax:** `bics Rd, Rn, Rm{, shift #imm6}`

Bitwise AND with an inverted operand, sets the flags.

**Operation:** `Rd = Rn & ~shift(Rm, imm6); C = V = 0`

**Flags:** N Z C V

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bif – Bitwise insert if the bit in Vm is clear

**Syntax:** `bif Vd.T, Vn.T, Vm.T`

**Operation:** `Vd = (Vn & ~Vm) | (Vd & Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## bit – Bitwise insert if the bit in Vm is set

**Syntax:** `bit Vd.T, Vn.T, Vm.T`

**Operation:** `Vd = (Vn & Vm) | (Vd & ~Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## bl – Call of a function

**Syntax:** `bl label`

Call of a function (relative, return address to x30).

**Operation:** `x30 = pc + 4; pc = pc + sext(imm26 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blr – Call of the function at the address in the register

**Syntax:** `blr Xn`

**Operation:** `x30 = pc + 4; pc = Xn`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## blraa – Call of an authenticated address

**Syntax:** `blraa Xn, Xm|SP`

Call of an authenticated address (a = key A, b = key B, z = modifier 0).

**Operation:** `x30 = pc + 4; pc = aut(Xn, key, Xm)`

Also shown as: `blrab`, `blraaz`, `blrabz`

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## br – Jump to the address in the register

**Syntax:** `br Xn`

**Operation:** `pc = Xn`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## braa – Jump to an authenticated address

**Syntax:** `braa Xn, Xm|SP`

Jump to an authenticated address (a = key A, b = key B, z = modifier 0).

**Operation:** `pc = aut(Xn, key, Xm); jump`

Also shown as: `brab`, `braaz`, `brabz`

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## brk – Breakpoint (debug exception)

**Syntax:** `brk #imm16`

**Operation:** `raise a breakpoint exception with imm16`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## bsl – Bitwise select: the destination itself is the mask

**Syntax:** `bsl Vd.T, Vn.T, Vm.T`

**Operation:** `Vd = (Vd & Vn) | (~Vd & Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cas – Atomic compare and swap

**Syntax:** `cas Ws, Wt, [Xn|SP]`

Atomic compare and swap: if the memory value equals Ws, Wt is stored; Ws receives the old value (variants: b, h, a, l).

**Operation:** `t = [Rn]; if t == Ws then [Rn] = Wt; Ws = t`

Also shown as: `casa`, `casal`, `casl`, `casb`, `casab`, `casalb`, `caslb`, `cash`, `casah`, `casalh`, `caslh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## casp – Atomic compare and swap of a register pair

**Syntax:** `casp Ws, Ws+1, Wt, Wt+1, [Xn|SP]`

Atomic compare and swap of a register pair (variants: a = acquire, l = release).

**Operation:** `t = [Rn] (pair); if t == Ws:Ws+1 then [Rn] = Wt:Wt+1; Ws:Ws+1 = t`

Also shown as: `caspa`, `caspal`, `caspl`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## cbnz – Jump if the register is not 0

**Syntax:** `cbnz Rt, label`

**Operation:** `if Rt != 0 then pc = pc + sext(imm19 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## cbz – Jump if the register is 0

**Syntax:** `cbz Rt, label`

**Operation:** `if Rt == 0 then pc = pc + sext(imm19 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## ccmn – Conditional compare

**Syntax:** `ccmn Rn, Rm, #nzcv, cond` &nbsp; `ccmn Rn, #imm5, #nzcv, cond`

Conditional compare (addition): flags from Rn + Rm, else from nzcv.

**Operation:** `if cond then flags = compare(Rn + Rm) else flags = nzcv`

**Flags:** N Z C V

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## ccmp – Conditional compare

**Syntax:** `ccmp Rn, Rm, #nzcv, cond` &nbsp; `ccmp Rn, #imm5, #nzcv, cond`

Conditional compare (subtraction): flags from Rn - Rm, else from nzcv.

**Operation:** `if cond then flags = compare(Rn - Rm) else flags = nzcv`

**Flags:** N Z C V

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## clrex – Clearing of the exclusive monitor

**Syntax:** `clrex {#imm4}`

**Operation:** `clear the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## cls – Count of the leading bits equal to the sign bit

**Syntax:** `cls Rd, Rn` &nbsp; `cls Vd.T, Vn.T`

**Operation:** `Rd = count_leading_sign_bits(Rn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## clz – Count of the leading zero bits

**Syntax:** `clz Rd, Rn` &nbsp; `clz Vd.T, Vn.T`

**Operation:** `Rd = count_leading_zeros(Rn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmeq – Comparison for equal, the result is a mask

**Syntax:** `cmeq Vd.T, Vn.T, Vm.T` &nbsp; `cmeq Vd.T, Vn.T, #0`

**Operation:** `for every element: Vd[i] = (Vn[i] == Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmge – Comparison for greater or equal

**Syntax:** `cmge Vd.T, Vn.T, Vm.T` &nbsp; `cmge Vd.T, Vn.T, #0`

Comparison for greater or equal (signed), the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmgt – Comparison for greater

**Syntax:** `cmgt Vd.T, Vn.T, Vm.T` &nbsp; `cmgt Vd.T, Vn.T, #0`

Comparison for greater (signed), the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmhi – Comparison for higher

**Syntax:** `cmhi Vd.T, Vn.T, Vm.T`

Comparison for higher (unsigned), the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmhs – Comparison for higher or same

**Syntax:** `cmhs Vd.T, Vn.T, Vm.T`

Comparison for higher or same (unsigned), the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmle – Comparison for less than or equal to zero

**Syntax:** `cmle Vd.T, Vn.T, #0`

Comparison for less than or equal to zero, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] <= 0) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmlt – Comparison for less than zero

**Syntax:** `cmlt Vd.T, Vn.T, #0`

Comparison for less than zero, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] < 0) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cmtst – Test for common set bits, the result is a mask

**Syntax:** `cmtst Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = ((Vn[i] & Vm[i]) != 0) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cnt – Count of the set bits in every byte

**Syntax:** `cnt Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = popcount(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## cpye – Copy of a memory block

**Syntax:** `cpye [Xd]!, [Xs]!, Xn!`

Copy of a memory block, epilogue (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpyewn`, `cpyern`, `cpyen`, `cpyewt`, `cpyewtwn`, `cpyewtrn`, `cpyewtn`, `cpyert`, `cpyertwn`, `cpyertrn`, `cpyertn`, `cpyet`, `cpyetwn`, `cpyetrn`, `cpyetn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpyfe – Copy of a memory block

**Syntax:** `cpyfe [Xd]!, [Xs]!, Xn!`

Copy of a memory block, epilogue, forward only (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpyfewn`, `cpyfern`, `cpyfen`, `cpyfewt`, `cpyfewtwn`, `cpyfewtrn`, `cpyfewtn`, `cpyfert`, `cpyfertwn`, `cpyfertrn`, `cpyfertn`, `cpyfet`, `cpyfetwn`, `cpyfetrn`, `cpyfetn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpyfm – Copy of a memory block

**Syntax:** `cpyfm [Xd]!, [Xs]!, Xn!`

Copy of a memory block, main part, forward only (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpyfmwn`, `cpyfmrn`, `cpyfmn`, `cpyfmwt`, `cpyfmwtwn`, `cpyfmwtrn`, `cpyfmwtn`, `cpyfmrt`, `cpyfmrtwn`, `cpyfmrtrn`, `cpyfmrtn`, `cpyfmt`, `cpyfmtwn`, `cpyfmtrn`, `cpyfmtn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpyfp – Copy of a memory block

**Syntax:** `cpyfp [Xd]!, [Xs]!, Xn!`

Copy of a memory block, prologue, forward only (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpyfpwn`, `cpyfprn`, `cpyfpn`, `cpyfpwt`, `cpyfpwtwn`, `cpyfpwtrn`, `cpyfpwtn`, `cpyfprt`, `cpyfprtwn`, `cpyfprtrn`, `cpyfprtn`, `cpyfpt`, `cpyfptwn`, `cpyfptrn`, `cpyfptn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpym – Copy of a memory block

**Syntax:** `cpym [Xd]!, [Xs]!, Xn!`

Copy of a memory block, main part (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpymwn`, `cpymrn`, `cpymn`, `cpymwt`, `cpymwtwn`, `cpymwtrn`, `cpymwtn`, `cpymrt`, `cpymrtwn`, `cpymrtrn`, `cpymrtn`, `cpymt`, `cpymtwn`, `cpymtrn`, `cpymtn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpyp – Copy of a memory block

**Syntax:** `cpyp [Xd]!, [Xs]!, Xn!`

Copy of a memory block, prologue (the three instructions p, m, e are executed in sequence).

**Operation:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Also shown as: `cpypwn`, `cpyprn`, `cpypn`, `cpypwt`, `cpypwtwn`, `cpypwtrn`, `cpypwtn`, `cpyprt`, `cpyprtwn`, `cpyprtrn`, `cpyprtn`, `cpypt`, `cpyptwn`, `cpyptrn`, `cpyptn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32b – CRC-32 checksum (polynomial 0x04C11DB7) of a byte

**Syntax:** `crc32b Wd, Wn, Wm`

**Operation:** `Wd = crc32(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32cb – CRC-32C checksum

**Syntax:** `crc32cb Wd, Wn, Wm`

CRC-32C checksum (Castagnoli, polynomial 0x1EDC6F41) of a byte.

**Operation:** `Wd = crc32c(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32ch – CRC-32C checksum

**Syntax:** `crc32ch Wd, Wn, Wm`

CRC-32C checksum (Castagnoli, polynomial 0x1EDC6F41) of a half word.

**Operation:** `Wd = crc32c(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32cw – CRC-32C checksum

**Syntax:** `crc32cw Wd, Wn, Wm`

CRC-32C checksum (Castagnoli, polynomial 0x1EDC6F41) of a word.

**Operation:** `Wd = crc32c(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32cx – CRC-32C checksum

**Syntax:** `crc32cx Wd, Wn, Xm`

CRC-32C checksum (Castagnoli, polynomial 0x1EDC6F41) of a double word.

**Operation:** `Wd = crc32c(Wn, Xm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32h – CRC-32 checksum

**Syntax:** `crc32h Wd, Wn, Wm`

CRC-32 checksum (polynomial 0x04C11DB7) of a half word.

**Operation:** `Wd = crc32(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32w – CRC-32 checksum (polynomial 0x04C11DB7) of a word

**Syntax:** `crc32w Wd, Wn, Wm`

**Operation:** `Wd = crc32(Wn, Wm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32x – CRC-32 checksum

**Syntax:** `crc32x Wd, Wn, Xm`

CRC-32 checksum (polynomial 0x04C11DB7) of a double word.

**Operation:** `Wd = crc32(Wn, Xm)`

*Group: CRC checksums. Short description from the instruction reference; there is no longer explanation for it yet.*

## csel – Conditional select

**Syntax:** `csel Rd, Rn, Rm, cond`

Conditional select (Rn if the condition holds, else Rm).

**Operation:** `Rd = cond ? Rn : Rm`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## csinc – Conditional select, else Rm + 1 (cset, cinc)

**Syntax:** `csinc Rd, Rn, Rm, cond`

**Operation:** `Rd = cond ? Rn : Rm + 1`

Also shown as: `cinc`, `cset`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## csinv – Conditional select, else the inverted Rm

**Syntax:** `csinv Rd, Rn, Rm, cond`

**Operation:** `Rd = cond ? Rn : ~Rm`

Also shown as: `cinv`, `csetm`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## csneg – Conditional select, else the negated Rm

**Syntax:** `csneg Rd, Rn, Rm, cond`

**Operation:** `Rd = cond ? Rn : -Rm`

Also shown as: `cneg`

*Group: Conditional select. Short description from the instruction reference; there is no longer explanation for it yet.*

## dcps1 – Switch to the debug state at exception level 1

**Syntax:** `dcps1 {#imm16}`

Switch to the debug state at exception level 1, 2 or 3 (only in debug state).

**Operation:** `enter debug state at EL1, EL2 or EL3`

Also shown as: `dcps2`, `dcps3`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## dmb – Memory barrier for the order of the accesses

**Syntax:** `dmb option`

**Operation:** `earlier memory accesses are observed before later ones`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## dsb – Memory barrier

**Syntax:** `dsb option`

Memory barrier: waits until all accesses are complete.

**Operation:** `wait until all earlier memory accesses are complete`

Also shown as: `ssbb`, `pssbb`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## dup – Copy of an integer register into all elements

**Syntax:** `dup Vd.T, Rn` &nbsp; `dup Vd.T, Vn.Ts[index]`

**Operation:** `for every element: Vd[i] = Rn`

Also shown as: `mov`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## eon – Bitwise exclusive OR with an inverted operand

**Syntax:** `eon Rd, Rn, Rm{, shift #imm6}`

**Operation:** `Rd = Rn ^ ~shift(Rm, imm6)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## eor – Bitwise exclusive OR with a bit pattern as constant

**Syntax:** `eor Rd, Rn, #imm (bit pattern)` &nbsp; `eor Rd, Rn, Rm{, shift #imm6}` &nbsp; `eor Vd.T, Vn.T, Vm.T`

**Operation:** `Rd = Rn ^ decode_bitmask(N, imms, immr) (Rd may be SP)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## eor3 – Exclusive OR of three vectors (SHA-3)

**Syntax:** `eor3 Vd.16B, Vn.16B, Vm.16B, Va.16B`

**Operation:** `Vd = Vn ^ Vm ^ Va`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## eret – Return from an exception (privileged)

**Syntax:** `eret`

**Operation:** `pc = ELR; PSTATE = SPSR`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## ext – Extraction of a byte range from two concatenated vectors

**Syntax:** `ext Vd.T, Vn.T, Vm.T, #index`

**Operation:** `Vd = bytes index ... index + 15 of (Vm:Vn)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## extr – Extract from the register pair Rn:Rm from bit lsb

**Syntax:** `extr Rd, Rn, Rm, #lsb`

Extract from the register pair Rn:Rm from bit lsb (ror if Rn = Rm).

**Operation:** `Rd = (Rn:Rm >> imms) low half`

Also shown as: `ror`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## fabd – Absolute difference of floating point elements

**Syntax:** `fabd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fabs – Absolute value

**Syntax:** `fabs Fd, Fn` &nbsp; `fabs Vd.T, Vn.T`

**Operation:** `Fd = abs(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## facge – Comparison of the absolute values for greater or equal

**Syntax:** `facge Vd.T, Vn.T, Vm.T`

Comparison of the absolute values for greater or equal, the result is a mask.

**Operation:** `for every element: Vd[i] = (abs(Vn[i]) >= abs(Vm[i])) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## facgt – Comparison of the absolute values for greater

**Syntax:** `facgt Vd.T, Vn.T, Vm.T`

Comparison of the absolute values for greater, the result is a mask.

**Operation:** `for every element: Vd[i] = (abs(Vn[i]) > abs(Vm[i])) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fadd – Addition

**Syntax:** `fadd Fd, Fn, Fm` &nbsp; `fadd Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = Fn + Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## faddp – Addition of adjacent floating point pairs

**Syntax:** `faddp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = sum of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcadd – Addition of complex numbers with a rotation by 90 or 270 degrees

**Syntax:** `fcadd Vd.T, Vn.T, Vm.T, #rot`

**Operation:** `Vd = Vn + rotate(Vm, rot)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fccmp – Conditional compare

**Syntax:** `fccmp Fn, Fm, #nzcv, cond`

Conditional compare: flags from Fn, Fm, else from nzcv.

**Operation:** `if cond then flags = compare(Fn, Fm) else flags = nzcv`

**Flags:** N Z C V

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fccmpe – Conditional floating point comparison

**Syntax:** `fccmpe Fn, Fm, #nzcv, cond`

Conditional floating point comparison (with an exception on NaN).

**Operation:** `if cond then flags = compare(Fn, Fm) else flags = nzcv`

**Flags:** N Z C V

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmeq – Floating point comparison for equal

**Syntax:** `fcmeq Vd.T, Vn.T, Vm.T` &nbsp; `fcmeq Vd.T, Vn.T, #0`

Floating point comparison for equal, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] == Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmge – Floating point comparison for greater or equal

**Syntax:** `fcmge Vd.T, Vn.T, Vm.T` &nbsp; `fcmge Vd.T, Vn.T, #0`

Floating point comparison for greater or equal, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmgt – Floating point comparison for greater

**Syntax:** `fcmgt Vd.T, Vn.T, Vm.T` &nbsp; `fcmgt Vd.T, Vn.T, #0`

Floating point comparison for greater, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmla – Multiplication of complex numbers

**Syntax:** `fcmla Vd.T, Vn.T, Vm.T, #rot`

Multiplication of complex numbers (one partial step, rotation 0, 90, 180 or 270 degrees), added to the destination.

**Operation:** `Vd = Vd + partial_product(Vn, Vm, rot)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmle – Floating point comparison with zero for less or equal

**Syntax:** `fcmle Vd.T, Vn.T, #0`

Floating point comparison with zero for less or equal, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] <= 0) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmlt – Floating point comparison with zero for less

**Syntax:** `fcmlt Vd.T, Vn.T, #0`

Floating point comparison with zero for less, the result is a mask.

**Operation:** `for every element: Vd[i] = (Vn[i] < 0) ? all 1 bits : 0`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmp – Comparison of two floating point values

**Syntax:** `fcmp Fn, Fm` &nbsp; `fcmp Fn, #0.0`

Comparison of two floating point values, sets the flags.

**Operation:** `flags = compare(Fn, Fm) (unordered: N Z C V = 0 0 1 1)`

**Flags:** N Z C V

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmpe – Comparison raising an exception on NaN

**Syntax:** `fcmpe Fn, Fm`

Comparison raising an exception on NaN (signalling), sets the flags.

**Operation:** `flags = compare(Fn, Fm)`

**Flags:** N Z C V

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcsel – Conditional select

**Syntax:** `fcsel Fd, Fn, Fm, cond`

Conditional select (Fn if the condition holds, else Fm).

**Operation:** `Fd = cond ? Fn : Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvt – Conversion between precisions

**Syntax:** `fcvt Fd, Fn`

Conversion between precisions (half, single, double).

**Operation:** `Fd = convert(Fn) to the precision of Fd`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtas – Conversion to a signed integer

**Syntax:** `fcvtas Rd, Fn` &nbsp; `fcvtas Vd.T, Vn.T`

Conversion to a signed integer (to nearest, ties away from zero).

**Operation:** `Rd = (int) round_half_away(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtau – Conversion to an unsigned integer

**Syntax:** `fcvtau Rd, Fn` &nbsp; `fcvtau Vd.T, Vn.T`

Conversion to an unsigned integer (to nearest, ties away from zero).

**Operation:** `Rd = (uint) round_half_away(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtl – Conversion to twice the precision

**Syntax:** `fcvtl Vd.Ta, Vn.Tb`

**Operation:** `for every element: Vd[i] = convert(Vn[i]) wider`

Also shown as: `fcvtl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtms – Conversion to a signed integer

**Syntax:** `fcvtms Rd, Fn` &nbsp; `fcvtms Vd.T, Vn.T`

Conversion to a signed integer (toward minus infinity).

**Operation:** `Rd = (int) floor(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtmu – Conversion to an unsigned integer

**Syntax:** `fcvtmu Rd, Fn` &nbsp; `fcvtmu Vd.T, Vn.T`

Conversion to an unsigned integer (toward minus infinity).

**Operation:** `Rd = (uint) floor(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtn – Conversion to half the precision

**Syntax:** `fcvtn Vd.Tb, Vn.Ta`

**Operation:** `for every element: Vd[i] = convert(Vn[i]) narrower`

Also shown as: `fcvtn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtns – Conversion to a signed integer

**Syntax:** `fcvtns Rd, Fn` &nbsp; `fcvtns Vd.T, Vn.T`

Conversion to a signed integer (to nearest, even on a tie).

**Operation:** `Rd = (int) round_to_nearest_even(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtnu – Conversion to an unsigned integer

**Syntax:** `fcvtnu Rd, Fn` &nbsp; `fcvtnu Vd.T, Vn.T`

Conversion to an unsigned integer (to nearest, even on a tie).

**Operation:** `Rd = (uint) round_to_nearest_even(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtps – Conversion to a signed integer

**Syntax:** `fcvtps Rd, Fn` &nbsp; `fcvtps Vd.T, Vn.T`

Conversion to a signed integer (toward plus infinity).

**Operation:** `Rd = (int) ceil(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtpu – Conversion to an unsigned integer

**Syntax:** `fcvtpu Rd, Fn` &nbsp; `fcvtpu Vd.T, Vn.T`

Conversion to an unsigned integer (toward plus infinity).

**Operation:** `Rd = (uint) ceil(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtxn – Conversion to half the precision (round to odd)

**Syntax:** `fcvtxn Vd.Tb, Vn.Ta`

**Operation:** `for every element: Vd[i] = convert_round_to_odd(Vn[i])`

Also shown as: `fcvtxn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtzs – Conversion to a signed integer

**Syntax:** `fcvtzs Rd, Fn` &nbsp; `fcvtzs Vd.T, Vn.T`

Conversion to a signed integer (truncated, toward zero).

**Operation:** `Rd = (int) trunc(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcvtzu – Conversion to an unsigned integer

**Syntax:** `fcvtzu Rd, Fn` &nbsp; `fcvtzu Vd.T, Vn.T`

Conversion to an unsigned integer (truncated, toward zero).

**Operation:** `Rd = (uint) trunc(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdiv – Division

**Syntax:** `fdiv Fd, Fn, Fm` &nbsp; `fdiv Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = Fn / Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fjcvtzs – Conversion to an integer by JavaScript rules

**Syntax:** `fjcvtzs Wd, Dn`

Conversion to an integer by JavaScript rules (result modulo 2^32).

**Operation:** `Wd = javascript_to_int32(Dn)`

**Flags:** N Z C V

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmadd – Multiply and add (fused, Fa + Fn * Fm)

**Syntax:** `fmadd Fd, Fn, Fm, Fa`

**Operation:** `Fd = Fa + Fn * Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmax – Maximum (NaN propagates)

**Syntax:** `fmax Fd, Fn, Fm` &nbsp; `fmax Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = max(Fn, Fm)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmaxnm – Maximum (a number wins against NaN)

**Syntax:** `fmaxnm Fd, Fn, Fm` &nbsp; `fmaxnm Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = maxnum(Fn, Fm)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmaxnmp – Maximum of adjacent floating point pairs

**Syntax:** `fmaxnmp Vd.T, Vn.T, Vm.T`

Maximum of adjacent floating point pairs (a number wins against NaN).

**Operation:** `for every element: Vd[i] = maxnum of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmaxnmv – Maximum of all floating point elements

**Syntax:** `fmaxnmv Sd, Vn.4S`

Maximum of all floating point elements (a number wins against NaN).

**Operation:** `Sd = maxnum of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmaxp – Maximum of adjacent floating point pairs

**Syntax:** `fmaxp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = max of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmaxv – Maximum of all floating point elements

**Syntax:** `fmaxv Sd, Vn.4S`

**Operation:** `Sd = max of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmin – Minimum (NaN propagates)

**Syntax:** `fmin Fd, Fn, Fm` &nbsp; `fmin Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = min(Fn, Fm)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fminnm – Minimum (a number wins against NaN)

**Syntax:** `fminnm Fd, Fn, Fm` &nbsp; `fminnm Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = minnum(Fn, Fm)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fminnmp – Minimum of adjacent floating point pairs

**Syntax:** `fminnmp Vd.T, Vn.T, Vm.T`

Minimum of adjacent floating point pairs (a number wins against NaN).

**Operation:** `for every element: Vd[i] = minnum of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fminnmv – Minimum of all floating point elements

**Syntax:** `fminnmv Sd, Vn.4S`

Minimum of all floating point elements (a number wins against NaN).

**Operation:** `Sd = minnum of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fminp – Minimum of adjacent floating point pairs

**Syntax:** `fminp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = min of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fminv – Minimum of all floating point elements

**Syntax:** `fminv Sd, Vn.4S`

**Operation:** `Sd = min of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmla – Multiplication with addition to the destination

**Syntax:** `fmla Vd.T, Vn.T, Vm.T` &nbsp; `fmla Vd.T, Vn.T, Vm.Ts[index]`

Multiplication with addition to the destination (floating point).

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmlal – Multiplication of half-precision numbers with widening to single

**Syntax:** `fmlal Vd.2S, Vn.2H, Vm.2H`

Multiplication of half-precision numbers with widening to single, added to the destination (low half).

**Operation:** `for every element: Vd[i] = Vd[i] + float(Vn[i]) * float(Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmlal2 – Like fmlal, but with the high half of the sources

**Syntax:** `fmlal2 Vd.2S, Vn.2H, Vm.2H`

**Operation:** `for every element: Vd[i] = Vd[i] + float(Vn[i + n]) * float(Vm[i + n])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmls – Multiplication with subtraction from the destination

**Syntax:** `fmls Vd.T, Vn.T, Vm.T` &nbsp; `fmls Vd.T, Vn.T, Vm.Ts[index]`

Multiplication with subtraction from the destination (floating point).

**Operation:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmlsl – Multiplication of half-precision numbers with widening to single

**Syntax:** `fmlsl Vd.2S, Vn.2H, Vm.2H`

Multiplication of half-precision numbers with widening to single, subtracted from the destination (low half).

**Operation:** `for every element: Vd[i] = Vd[i] - float(Vn[i]) * float(Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmlsl2 – Like fmlsl, but with the high half of the sources

**Syntax:** `fmlsl2 Vd.2S, Vn.2H, Vm.2H`

**Operation:** `for every element: Vd[i] = Vd[i] - float(Vn[i + n]) * float(Vm[i + n])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmov – Copy of a floating point register

**Syntax:** `fmov Fd, Fn` &nbsp; `fmov Fd, #imm` &nbsp; `fmov Wd, Sn` &nbsp; `fmov Sd, Wn` &nbsp; `fmov Xd, Dn` &nbsp; `fmov Dd, Xn` &nbsp; `fmov Vd.T, #imm8{, lsl #amount}`

**Operation:** `Fd = Fn`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmsub – Multiply and subtract (fused, Fa - Fn * Fm)

**Syntax:** `fmsub Fd, Fn, Fm, Fa`

**Operation:** `Fd = Fa - Fn * Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmul – Multiplication

**Syntax:** `fmul Fd, Fn, Fm` &nbsp; `fmul Vd.T, Vn.T, Vm.T` &nbsp; `fmul Vd.T, Vn.T, Vm.Ts[index]`

**Operation:** `Fd = Fn * Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmulx – Multiplication of floating point elements

**Syntax:** `fmulx Vd.T, Vn.T, Vm.T` &nbsp; `fmulx Vd.T, Vn.T, Vm.Ts[index]`

Multiplication of floating point elements (0 times infinity gives 2).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fneg – Sign change

**Syntax:** `fneg Fd, Fn` &nbsp; `fneg Vd.T, Vn.T`

**Operation:** `Fd = -Fn`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnmadd – Negated multiply and add (fused)

**Syntax:** `fnmadd Fd, Fn, Fm, Fa`

**Operation:** `Fd = -Fa - Fn * Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnmsub – Negated multiply and subtract (fused)

**Syntax:** `fnmsub Fd, Fn, Fm, Fa`

**Operation:** `Fd = -Fa + Fn * Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnmul – Multiplication with sign change

**Syntax:** `fnmul Fd, Fn, Fm`

**Operation:** `Fd = -(Fn * Fm)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frecpe – Estimate of the reciprocal

**Syntax:** `frecpe Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = estimate(1 / Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frecps – Step of the Newton-Raphson iteration for the reciprocal

**Syntax:** `frecps Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = 2 - Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frecpx – Estimate of the reciprocal of an exponent (scalar)

**Syntax:** `frecpx Fd, Fn`

**Operation:** `Fd = reciprocal_exponent(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frint32x – Rounding to an integer value that fits 32 bits

**Syntax:** `frint32x Vd.T, Vn.T`

Rounding to an integer value that fits 32 bits (by the current rounding mode).

**Operation:** `for every element: Vd[i] = round32(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frint32z – Rounding to an integer value that fits 32 bits

**Syntax:** `frint32z Vd.T, Vn.T`

Rounding to an integer value that fits 32 bits (toward zero).

**Operation:** `for every element: Vd[i] = trunc32(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frint64x – Rounding to an integer value that fits 64 bits

**Syntax:** `frint64x Vd.T, Vn.T`

Rounding to an integer value that fits 64 bits (by the current rounding mode).

**Operation:** `for every element: Vd[i] = round64(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frint64z – Rounding to an integer value that fits 64 bits

**Syntax:** `frint64z Vd.T, Vn.T`

Rounding to an integer value that fits 64 bits (toward zero).

**Operation:** `for every element: Vd[i] = trunc64(Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frinta – Rounding to an integer value

**Syntax:** `frinta Fd, Fn` &nbsp; `frinta Vd.T, Vn.T`

Rounding to an integer value (to nearest, ties away from zero).

**Operation:** `Fd = round_half_away(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frinti – Rounding to an integer value

**Syntax:** `frinti Fd, Fn` &nbsp; `frinti Vd.T, Vn.T`

Rounding to an integer value (mode of the control register).

**Operation:** `Fd = round(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frintm – Rounding to an integer value

**Syntax:** `frintm Fd, Fn` &nbsp; `frintm Vd.T, Vn.T`

Rounding to an integer value (toward minus infinity).

**Operation:** `Fd = floor(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frintn – Rounding to an integer value

**Syntax:** `frintn Fd, Fn` &nbsp; `frintn Vd.T, Vn.T`

Rounding to an integer value (to nearest, even on a tie).

**Operation:** `Fd = round_to_nearest_even(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frintp – Rounding to an integer value

**Syntax:** `frintp Fd, Fn` &nbsp; `frintp Vd.T, Vn.T`

Rounding to an integer value (toward plus infinity).

**Operation:** `Fd = ceil(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frintx – Rounding to an integer value

**Syntax:** `frintx Fd, Fn` &nbsp; `frintx Vd.T, Vn.T`

Rounding to an integer value (mode of the control register, signals inexact).

**Operation:** `Fd = round(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frintz – Rounding to an integer value (toward zero)

**Syntax:** `frintz Fd, Fn` &nbsp; `frintz Vd.T, Vn.T`

**Operation:** `Fd = trunc(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## frsqrte – Estimate of the reciprocal square root

**Syntax:** `frsqrte Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = estimate(1 / sqrt(Vn[i]))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## frsqrts – Step of the Newton-Raphson iteration for the reciprocal square root

**Syntax:** `frsqrts Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (3 - Vn[i] * Vm[i]) / 2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsqrt – Square root

**Syntax:** `fsqrt Fd, Fn` &nbsp; `fsqrt Vd.T, Vn.T`

**Operation:** `Fd = sqrt(Fn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsub – Subtraction

**Syntax:** `fsub Fd, Fn, Fm` &nbsp; `fsub Vd.T, Vn.T, Vm.T`

**Operation:** `Fd = Fn - Fm`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## gmi – Insertion of a tag into an exclude mask

**Syntax:** `gmi Xd, Xn|SP, Xm`

**Operation:** `Xd = Xm | (1 << tag of Xn)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## hint – Hint to the processor

**Syntax:** `hint #imm7`

Hint to the processor (nop, yield, wfe, wfi, sev, bti ...).

**Operation:** `no change of the program (a hint)`

Also shown as: `nop`, `yield`, `wfe`, `wfi`, `sev`, `sevl`, `bti`, `csdb`, `esb`, `psb`, `tsb`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## hlt – Halt for a debugger

**Syntax:** `hlt #imm16`

**Operation:** `enter debug state`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## hvc – Hypervisor call (exception level 2)

**Syntax:** `hvc #imm16`

**Operation:** `raise a hypervisor call exception`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ins – Insertion of an integer register into one element

**Syntax:** `ins Vd.Ts[index], Rn`

**Operation:** `Vd[index] = Rn`

Also shown as: `mov`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## irg – Insertion of a random tag into an address

**Syntax:** `irg Xd|SP, Xn|SP{, Xm}`

**Operation:** `Xd = Xn with a random tag (not in the exclude mask Xm)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## isb – Instruction barrier: flushes the pipeline

**Syntax:** `isb {#imm4}`

**Operation:** `all instructions after it are fetched anew`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ld1 – Load of one vector register from memory

**Syntax:** `ld1 {Vt.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `ld1 {Vt.Ts}[index], [Xn|SP]`

**Operation:** `Vt = [Rn]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld1r – Load of one element from memory into all elements of 1 registers

**Syntax:** `ld1r {Vt.T}, [Xn|SP]`

Load of one element from memory into all elements of 1 registers (replicate).

**Operation:** `every element of every register = [Rn]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld2 – Load of 2 registers

**Syntax:** `ld2 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `ld2 {Vt.T, Vt2.T}, [Xn|SP], Xm|#imm` &nbsp; `ld2 {Vt.Ts, Vt2.Ts}[index], [Xn|SP]`

Load of 2 registers (elements interleaved) from memory.

**Operation:** `registers = [Rn] (2 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld2r – Load of one element from memory into all elements of 2 registers

**Syntax:** `ld2r {Vt.T, Vt2.T}, [Xn|SP]`

Load of one element from memory into all elements of 2 registers (replicate).

**Operation:** `every element of every register = [Rn]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld3 – Load of 3 registers

**Syntax:** `ld3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `ld3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP], Xm|#imm` &nbsp; `ld3 {Vt.Ts, Vt2.Ts, Vt3.Ts}[index], [Xn|SP]`

Load of 3 registers (elements interleaved) from memory.

**Operation:** `registers = [Rn] (3 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld3r – Load of one element from memory into all elements of 3 registers

**Syntax:** `ld3r {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]`

Load of one element from memory into all elements of 3 registers (replicate).

**Operation:** `every element of every register = [Rn]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld4 – Load of 4 registers

**Syntax:** `ld4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `ld4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP], Xm|#imm` &nbsp; `ld4 {Vt.Ts, Vt2.Ts, Vt3.Ts, Vt4.Ts}[index], [Xn|SP]`

Load of 4 registers (elements interleaved) from memory.

**Operation:** `registers = [Rn] (4 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ld4r – Load of one element from memory into all elements of 4 registers

**Syntax:** `ld4r {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]`

Load of one element from memory into all elements of 4 registers (replicate).

**Operation:** `every element of every register = [Rn]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldadd – Atomic memory operation

**Syntax:** `ldadd Ws, Wt, [Xn|SP]`

Atomic memory operation: Addition of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = t + Ws; Wt = t`

Also shown as: `ldadda`, `ldaddal`, `ldaddl`, `ldaddb`, `ldaddab`, `ldaddalb`, `ldaddlb`, `ldaddh`, `ldaddah`, `ldaddalh`, `ldaddlh`, `staddb`, `staddh`, `stadd`, `staddl`, `staddlb`, `staddlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldapr – Load with release consistency

**Syntax:** `ldapr Wt, [Xn|SP]`

Load with release consistency (acquire for earlier accesses only, RCpc variant; b = byte, h = half word).

**Operation:** `Wt = [Rn]`

Also shown as: `ldaprb`, `ldaprh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldapur – Load with acquire

**Syntax:** `ldapur Wt, [Xn|SP{, #imm9}]`

Load with acquire (RCpc, unscaled, address: Rn + imm9; b = byte, h = half word).

**Operation:** `Wt = [Rn + imm9]`

Also shown as: `ldapurb`, `ldapurh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldapursb – Load with acquire

**Syntax:** `ldapursb Xt, [Xn|SP{, #imm9}]`

Load with acquire (RCpc), sign-extended to 64 bit (b = byte, h = half word, w = word).

**Operation:** `Xt = sext([Rn + imm9])`

Also shown as: `ldapursh`, `ldapursw`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldar – Load with acquire (word)

**Syntax:** `ldar Wt, [Xn|SP]` &nbsp; `ldar Xt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldarb – Load with acquire (byte)

**Syntax:** `ldarb Wt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldarh – Load with acquire (half word)

**Syntax:** `ldarh Wt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldaxp – Load of a register pair (exclusive) with acquire

**Syntax:** `ldaxp Rt, Rt2, [Xn|SP]`

**Operation:** `Rt = [Rn]; Rt2 = [Rn + size]; acquire; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldaxr – Load-exclusive with acquire (word)

**Syntax:** `ldaxr Wt, [Xn|SP]` &nbsp; `ldaxr Xt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldaxrb – Load-exclusive with acquire (byte)

**Syntax:** `ldaxrb Wt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldaxrh – Load-exclusive with acquire (half word)

**Syntax:** `ldaxrh Wt, [Xn|SP]`

**Operation:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldclr – Atomic memory operation

**Syntax:** `ldclr Ws, Wt, [Xn|SP]`

Atomic memory operation: Clearing of bits (AND with the inverted operand) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = t & ~Ws; Wt = t`

Also shown as: `ldclra`, `ldclral`, `ldclrl`, `ldclrb`, `ldclrab`, `ldclralb`, `ldclrlb`, `ldclrh`, `ldclrah`, `ldclralh`, `ldclrlh`, `stclrb`, `stclrh`, `stclr`, `stclrl`, `stclrlb`, `stclrlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldeor – Atomic memory operation

**Syntax:** `ldeor Ws, Wt, [Xn|SP]`

Atomic memory operation: exclusive OR of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = t ^ Ws; Wt = t`

Also shown as: `ldeora`, `ldeoral`, `ldeorl`, `ldeorb`, `ldeorab`, `ldeoralb`, `ldeorlb`, `ldeorh`, `ldeorah`, `ldeoralh`, `ldeorlh`, `steorb`, `steorh`, `steor`, `steorl`, `steorlb`, `steorlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldg – Load of the tag from memory into an address

**Syntax:** `ldg Xt, [Xn|SP{, #imm9}]`

**Operation:** `Xt = Xt with tag of [Rn + imm9 * 16]`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldlar – Load with acquire for an ordered memory region

**Syntax:** `ldlar Wt, [Xn|SP]`

Load with acquire for an ordered memory region (LORegion; b = byte, h = half word).

**Operation:** `Wt = [Rn]`

Also shown as: `ldlarb`, `ldlarh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldnp – Load of a register pair with a non-temporal hint

**Syntax:** `ldnp Rt, Rt2, [Xn|SP{, #imm7}]`

**Operation:** `Rt = [addr]; Rt2 = [addr + size]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldp – Load of a register pair (post-indexed)

**Syntax:** `ldp Rt, Rt2, [Xn|SP], #imm7` &nbsp; `ldp Rt, Rt2, [Xn|SP{, #imm7}]` &nbsp; `ldp Rt, Rt2, [Xn|SP, #imm7]!` &nbsp; `ldp Ft, Ft2, [Xn|SP{, #imm7}]`

**Operation:** `Rt = [addr]; Rt2 = [addr + size]; addr = Rn; Rn = Rn + imm7 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldpsw – Load of a pair of signed words (post-indexed)

**Syntax:** `ldpsw Xt, Xt2, [Xn|SP], #imm7` &nbsp; `ldpsw Xt, Xt2, [Xn|SP{, #imm7}]` &nbsp; `ldpsw Xt, Xt2, [Xn|SP, #imm7]!`

**Operation:** `Xt = sext([addr]); Xt2 = sext([addr + 4]); addr = Rn; Rn = Rn + imm7 * 4`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldr – Load of a word

**Syntax:** `ldr Wt, [Xn|SP{, #imm12}]` &nbsp; `ldr Wt, [Xn|SP, #imm9]!` &nbsp; `ldr Wt, [Xn|SP], #imm9` &nbsp; `ldr Wt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldr Xt, [Xn|SP{, #imm12}]` &nbsp; `ldr Xt, [Xn|SP, #imm9]!` &nbsp; `ldr Xt, [Xn|SP], #imm9` &nbsp; `ldr Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; …

Load of a word (32 bit) (address: Rn + imm12 * size).

**Operation:** `Wt = [addr]; addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldraa – Load with an authenticated base address

**Syntax:** `ldraa Xt, [Xn|SP{, #simm10}]`

Load with an authenticated base address (a = key A, b = key B; optionally pre-indexed).

**Operation:** `Xt = [aut(Xn, key, 0) + simm10 * 8]`

Also shown as: `ldrab`

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrb – Load of a byte

**Syntax:** `ldrb Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrb Wt, [Xn|SP, #imm9]!` &nbsp; `ldrb Wt, [Xn|SP], #imm9` &nbsp; `ldrb Wt, [Xn|SP, Rm{, extend {#amount}}]`

Load of a byte (zero-extended) (address: Rn + imm12 * size).

**Operation:** `Wt = zext([addr]); addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrh – Load of a half word

**Syntax:** `ldrh Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrh Wt, [Xn|SP, #imm9]!` &nbsp; `ldrh Wt, [Xn|SP], #imm9` &nbsp; `ldrh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Load of a half word (zero-extended) (address: Rn + imm12 * size).

**Operation:** `Wt = zext([addr]); addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsb – Load of a byte

**Syntax:** `ldrsb Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsb Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsb Xt, [Xn|SP], #imm9` &nbsp; `ldrsb Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsb Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrsb Wt, [Xn|SP, #imm9]!` &nbsp; `ldrsb Wt, [Xn|SP], #imm9` &nbsp; `ldrsb Wt, [Xn|SP, Rm{, extend {#amount}}]`

Load of a byte (sign-extended to 64 bit) (address: Rn + imm12 * size).

**Operation:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsh – Load of a half word

**Syntax:** `ldrsh Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsh Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsh Xt, [Xn|SP], #imm9` &nbsp; `ldrsh Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsh Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrsh Wt, [Xn|SP, #imm9]!` &nbsp; `ldrsh Wt, [Xn|SP], #imm9` &nbsp; `ldrsh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Load of a half word (sign-extended to 64 bit) (address: Rn + imm12 * size).

**Operation:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldrsw – Load of a word

**Syntax:** `ldrsw Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsw Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsw Xt, [Xn|SP], #imm9` &nbsp; `ldrsw Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsw Xt, label`

Load of a word (sign-extended to 64 bit) (address: Rn + imm12 * size).

**Operation:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldset – Atomic memory operation

**Syntax:** `ldset Ws, Wt, [Xn|SP]`

Atomic memory operation: Setting of bits (OR) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = t | Ws; Wt = t`

Also shown as: `ldseta`, `ldsetal`, `ldsetl`, `ldsetb`, `ldsetab`, `ldsetalb`, `ldsetlb`, `ldseth`, `ldsetah`, `ldsetalh`, `ldsetlh`, `stsetb`, `stseth`, `stset`, `stsetl`, `stsetlb`, `stsetlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldsmax – Atomic memory operation

**Syntax:** `ldsmax Ws, Wt, [Xn|SP]`

Atomic memory operation: Maximum (signed) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = max_signed(t, Ws); Wt = t`

Also shown as: `ldsmaxa`, `ldsmaxal`, `ldsmaxl`, `ldsmaxb`, `ldsmaxab`, `ldsmaxalb`, `ldsmaxlb`, `ldsmaxh`, `ldsmaxah`, `ldsmaxalh`, `ldsmaxlh`, `stsmaxb`, `stsmaxh`, `stsmax`, `stsmaxl`, `stsmaxlb`, `stsmaxlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldsmin – Atomic memory operation

**Syntax:** `ldsmin Ws, Wt, [Xn|SP]`

Atomic memory operation: Minimum (signed) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = min_signed(t, Ws); Wt = t`

Also shown as: `ldsmina`, `ldsminal`, `ldsminl`, `ldsminb`, `ldsminab`, `ldsminalb`, `ldsminlb`, `ldsminh`, `ldsminah`, `ldsminalh`, `ldsminlh`, `stsminb`, `stsminh`, `stsmin`, `stsminl`, `stsminlb`, `stsminlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldtr – Load with the rights of user mode

**Syntax:** `ldtr Wt, [Xn|SP{, #imm9}]`

Load with the rights of user mode (unprivileged; b = byte, h = half word).

**Operation:** `Wt = [Rn + imm9]`

Also shown as: `ldtrb`, `ldtrh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldtrsb – Load with the rights of user mode

**Syntax:** `ldtrsb Xt, [Xn|SP{, #imm9}]`

Load with the rights of user mode, sign-extended to 64 bit (b = byte, h = half word, w = word).

**Operation:** `Xt = sext([Rn + imm9])`

Also shown as: `ldtrsh`, `ldtrsw`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldumax – Atomic memory operation

**Syntax:** `ldumax Ws, Wt, [Xn|SP]`

Atomic memory operation: Maximum (unsigned) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = max_unsigned(t, Ws); Wt = t`

Also shown as: `ldumaxa`, `ldumaxal`, `ldumaxl`, `ldumaxb`, `ldumaxab`, `ldumaxalb`, `ldumaxlb`, `ldumaxh`, `ldumaxah`, `ldumaxalh`, `ldumaxlh`, `stumaxb`, `stumaxh`, `stumax`, `stumaxl`, `stumaxlb`, `stumaxlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldumin – Atomic memory operation

**Syntax:** `ldumin Ws, Wt, [Xn|SP]`

Atomic memory operation: Minimum (unsigned) of the memory value and a register, the old value goes to the destination register (variants: b = byte, h = half word, a = acquire, l = release, st... without a destination register).

**Operation:** `t = [Rn]; [Rn] = min_unsigned(t, Ws); Wt = t`

Also shown as: `ldumina`, `lduminal`, `lduminl`, `lduminb`, `lduminab`, `lduminalb`, `lduminlb`, `lduminh`, `lduminah`, `lduminalh`, `lduminlh`, `stuminb`, `stuminh`, `stumin`, `stuminl`, `stuminlb`, `stuminlh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## ldur – Load of a word

**Syntax:** `ldur Wt, [Xn|SP{, #imm9}]` &nbsp; `ldur Xt, [Xn|SP{, #imm9}]`

Load of a word (32 bit) (unscaled, address: Rn + imm9).

**Operation:** `Wt = [addr]; addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldurb – Load of a byte

**Syntax:** `ldurb Wt, [Xn|SP{, #imm9}]`

Load of a byte (zero-extended) (unscaled, address: Rn + imm9).

**Operation:** `Wt = zext([addr]); addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldurh – Load of a half word

**Syntax:** `ldurh Wt, [Xn|SP{, #imm9}]`

Load of a half word (zero-extended) (unscaled, address: Rn + imm9).

**Operation:** `Wt = zext([addr]); addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldursb – Load of a byte

**Syntax:** `ldursb Xt, [Xn|SP{, #imm9}]` &nbsp; `ldursb Wt, [Xn|SP{, #imm9}]`

Load of a byte (sign-extended to 64 bit) (unscaled, address: Rn + imm9).

**Operation:** `Xt = sext([addr]); addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldursh – Load of a half word

**Syntax:** `ldursh Xt, [Xn|SP{, #imm9}]` &nbsp; `ldursh Wt, [Xn|SP{, #imm9}]`

Load of a half word (sign-extended to 64 bit) (unscaled, address: Rn + imm9).

**Operation:** `Xt = sext([addr]); addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldursw – Load of a word

**Syntax:** `ldursw Xt, [Xn|SP{, #imm9}]`

Load of a word (sign-extended to 64 bit) (unscaled, address: Rn + imm9).

**Operation:** `Xt = sext([addr]); addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldxp – Load of a register pair (exclusive)

**Syntax:** `ldxp Rt, Rt2, [Xn|SP]`

**Operation:** `Rt = [Rn]; Rt2 = [Rn + size]; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldxr – Load-exclusive: sets the exclusive monitor (word)

**Syntax:** `ldxr Wt, [Xn|SP]` &nbsp; `ldxr Xt, [Xn|SP]`

**Operation:** `Rt = [Rn]; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldxrb – Load-exclusive: sets the exclusive monitor (byte)

**Syntax:** `ldxrb Wt, [Xn|SP]`

**Operation:** `Rt = [Rn]; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldxrh – Load-exclusive

**Syntax:** `ldxrh Wt, [Xn|SP]`

Load-exclusive: sets the exclusive monitor (half word).

**Operation:** `Rt = [Rn]; set the exclusive monitor`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lslv – Shift left by a register (amount modulo width)

**Syntax:** `lslv Rd, Rn, Rm`

**Operation:** `Rd = Rn << (Rm mod width)`

Also shown as: `lsl`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsrv – Shift right unsigned by a register

**Syntax:** `lsrv Rd, Rn, Rm`

**Operation:** `Rd = Rn >> (Rm mod width)`

Also shown as: `lsr`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## madd – Multiply and add (Ra + Rn * Rm)

**Syntax:** `madd Rd, Rn, Rm, Ra`

**Operation:** `Rd = Ra + Rn * Rm`

Also shown as: `mul`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mla – Multiplication with addition to the destination

**Syntax:** `mla Vd.T, Vn.T, Vm.T` &nbsp; `mla Vd.T, Vn.T, Vm.Ts[index]`

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## mls – Multiplication with subtraction from the destination

**Syntax:** `mls Vd.T, Vn.T, Vm.T` &nbsp; `mls Vd.T, Vn.T, Vm.Ts[index]`

**Operation:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## movi – Load of a 32-bit constant

**Syntax:** `movi Vd.T, #imm8{, lsl #amount}`

Load of a 32-bit constant (one byte, shifted) into all elements.

**Operation:** `Vd = imm8 << (8 * cm) in every 32 bits`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## movk – Insertion of 16 bits of a constant into a register

**Syntax:** `movk Rd, #imm16{, lsl #shift}`

Insertion of 16 bits of a constant into a register, the other bits stay.

**Operation:** `Rd[hw*16 + 15 : hw*16] = imm16`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movn – Load of an inverted constant into a register

**Syntax:** `movn Rd, #imm16{, lsl #shift}`

Load of an inverted constant into a register (16 bit, shifted by 0/16/32/48).

**Operation:** `Rd = ~(imm16 << (hw * 16))`

Also shown as: `mov`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## movz – Load of a constant into a register

**Syntax:** `movz Rd, #imm16{, lsl #shift}`

Load of a constant into a register (16 bit, shifted by 0/16/32/48, the rest 0).

**Operation:** `Rd = imm16 << (hw * 16)`

Also shown as: `mov`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## mrs – Read of a system register

**Syntax:** `mrs Xt, sysreg`

**Operation:** `Xt = sysreg`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## msr – Write of a system register

**Syntax:** `msr sysreg, Xt`

**Operation:** `sysreg = Xt`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## msub – Multiply and subtract (Ra - Rn * Rm)

**Syntax:** `msub Rd, Rn, Rm, Ra`

**Operation:** `Rd = Ra - Rn * Rm`

Also shown as: `mneg`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mul – Multiplication of the elements

**Syntax:** `mul Vd.T, Vn.T, Vm.T` &nbsp; `mul Vd.T, Vn.T, Vm.Ts[index]`

Multiplication of the elements (the low half of the result).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## mvni – Load of the negation of a 32-bit constant into all elements

**Syntax:** `mvni Vd.T, #imm8{, lsl #amount}`

**Operation:** `Vd = ~(imm8 << (8 * cm))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## neg – Negation

**Syntax:** `neg Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = -Vn[i]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## not – Bitwise NOT

**Syntax:** `not Vd.T, Vn.T`

**Operation:** `Vd = ~Vn`

Also shown as: `mvn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## orn – Bitwise OR with an inverted operand

**Syntax:** `orn Rd, Rn, Rm{, shift #imm6}` &nbsp; `orn Vd.T, Vn.T, Vm.T`

**Operation:** `Rd = Rn OR ~shift(Rm, imm6)`

Also shown as: `mvn`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orr – Bitwise OR with a bit pattern as constant

**Syntax:** `orr Rd, Rn, #imm (bit pattern)` &nbsp; `orr Rd, Rn, Rm{, shift #imm6}` &nbsp; `orr Vd.T, Vn.T, Vm.T` &nbsp; `orr Vd.T, #imm8{, lsl #amount}`

**Operation:** `Rd = Rn OR decode_bitmask(N, imms, immr) (Rd may be SP)`

Also shown as: `mov`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## pacga – Computation of a generic authentication code

**Syntax:** `pacga Xd, Xn, Xm|SP`

**Operation:** `Xd[63:32] = pac_code(Xn, Xm); Xd[31:0] = 0`

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## pacia – Signing (pac...) or authenticating

**Syntax:** `pacia Xd, Xn|SP`

Signing (pac...) or authenticating (aut...) of a pointer with a key (ia, ib for instructions, da, db for data) and a modifier (Xn).

**Operation:** `Xd = pac(Xd, key, Xn) or Xd = aut(Xd, key, Xn)`

Also shown as: `pacib`, `pacda`, `pacdb`, `autia`, `autib`, `autda`, `autdb`

*Group: Pointer authentication (PAC). Short description from the instruction reference; there is no longer explanation for it yet.*

## pmul – Polynomial multiplication of the elements

**Syntax:** `pmul Vd.T, Vn.T, Vm.T`

Polynomial multiplication of the elements (byte, carry-less).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i] over GF(2)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## pmull – Polynomial multiplication with widening

**Syntax:** `pmull Vd.Tb, Vn.Ta, Vm.Ta`

Polynomial multiplication with widening (carry-less; the 1Q form needs the crypto extension).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i] over GF(2)`

Also shown as: `pmull2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## prfm – Prefetch of a cache line (hint)

**Syntax:** `prfm prfop, [Xn|SP{, #imm12}]` &nbsp; `prfm prfop, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `prfm prfop, label`

**Operation:** `prefetch the cache line at addr (a hint)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## prfum – Prefetch of a cache line (hint) (unscaled)

**Syntax:** `prfum prfop, [Xn|SP{, #imm9}]`

**Operation:** `prefetch the cache line at addr (a hint)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## raddhn – Addition with narrowing

**Syntax:** `raddhn Vd.Tb, Vn.Ta, Vm.Ta`

Addition with narrowing (high half; raddhn with rounding) (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = high half of (Vn[i] + Vm[i])`

Also shown as: `raddhn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## rbit – Reversal of the bit order

**Syntax:** `rbit Rd, Rn` &nbsp; `rbit Vd.T, Vn.T`

**Operation:** `Rd = reverse_bits(Rn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## ret – Return from the function

**Syntax:** `ret {Xn}`

Return from the function (address in x30 if no register is given).

**Operation:** `pc = Xn (default x30)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev – Reversal of the bytes of a 32-bit value

**Syntax:** `rev Wd, Wn` &nbsp; `rev Xd, Xn`

Reversal of the bytes of a 32-bit value (little/big endian).

**Operation:** `Wd = reverse_bytes(Wn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev16 – Reversal of the bytes in each half word

**Syntax:** `rev16 Rd, Rn` &nbsp; `rev16 Vd.T, Vn.T`

**Operation:** `Rd = reverse_bytes_in_each_16_bits(Rn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev32 – Reversal of the bytes in each 32-bit half of a 64-bit register

**Syntax:** `rev32 Xd, Xn` &nbsp; `rev32 Vd.T, Vn.T`

**Operation:** `Xd = reverse_bytes_in_each_32_bits(Xn)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev64 – Reversal of the order of the elements in every 64-bit block

**Syntax:** `rev64 Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = reverse(Vn) per 64 bits`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## rmif – Rotation of a register into the flags (masked)

**Syntax:** `rmif Xn, #imm6, #nzcv`

**Operation:** `flags = bits of (Xn rotated right by imm6) where the mask nzcv is set`

**Flags:** N Z C V

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rorv – Rotate right by a register

**Syntax:** `rorv Rd, Rn, Rm`

**Operation:** `Rd = rotate_right(Rn, Rm mod width)`

Also shown as: `ror`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## rshrn – Shift right with narrowing and rounding

**Syntax:** `rshrn Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing and rounding (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = round(Vn[i] >> shift)`

Also shown as: `rshrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## rsubhn – Subtraction with narrowing

**Syntax:** `rsubhn Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction with narrowing (high half; rsubhn with rounding) (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = high half of (Vn[i] - Vm[i])`

Also shown as: `rsubhn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## saba – Addition of the absolute difference to the destination

**Syntax:** `saba Vd.T, Vn.T, Vm.T`

Addition of the absolute difference to the destination (signed).

**Operation:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sabal – Addition of the absolute difference with widening

**Syntax:** `sabal Vd.Tb, Vn.Ta, Vm.Ta`

Addition of the absolute difference with widening (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

Also shown as: `sabal2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sabd – Absolute difference (signed)

**Syntax:** `sabd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sabdl – Absolute difference with widening

**Syntax:** `sabdl Vd.Tb, Vn.Ta, Vm.Ta`

Absolute difference with widening (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = abs(Vn[i] - Vm[i]) (wide result)`

Also shown as: `sabdl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sadalp – Pairwise addition with widening

**Syntax:** `sadalp Vd.T, Vn.T`

Pairwise addition with widening, added to the destination (signed).

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[2i] + Vn[2i+1]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## saddl – Addition with widening

**Syntax:** `saddl Vd.Tb, Vn.Ta, Vm.Ta`

Addition with widening (both operands become twice as wide) (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] + Vm[i] (wide result)`

Also shown as: `saddl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## saddlp – Pairwise addition of adjacent elements with widening

**Syntax:** `saddlp Vd.T, Vn.T`

Pairwise addition of adjacent elements with widening (signed).

**Operation:** `for every element: Vd[i] = Vn[2i] + Vn[2i+1]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## saddlv – Sum of all elements with widening (signed)

**Syntax:** `saddlv Vd, Vn.T`

**Operation:** `Vd = sum of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## saddw – Addition of a wide and a narrow operand

**Syntax:** `saddw Vd.Tb, Vn.Ta, Vm.Ta`

Addition of a wide and a narrow operand (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] + Vm[i] (Vn is wide)`

Also shown as: `saddw2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sbc – Subtraction with borrow (C)

**Syntax:** `sbc Rd, Rn, Rm`

**Operation:** `Rd = Rn - Rm - (1 - C)`

Also shown as: `ngc`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbcs – Subtraction with borrow, sets the flags

**Syntax:** `sbcs Rd, Rn, Rm`

**Operation:** `Rd = Rn - Rm - (1 - C)`

**Flags:** N Z C V

Also shown as: `ngcs`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbfm – Bitfield move with sign extension

**Syntax:** `sbfm Rd, Rn, #immr, #imms`

Bitfield move with sign extension (base form of asr, sbfx, sxtb ...).

**Operation:** `Rd = sign-extended field of Rn selected by immr, imms`

Also shown as: `asr`, `sbfiz`, `sbfx`, `sxtb`, `sxth`, `sxtw`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## scvtf – Conversion of a signed integer to floating point

**Syntax:** `scvtf Fd, Rn` &nbsp; `scvtf Vd.T, Vn.T`

**Operation:** `Fd = (float) sext(Rn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## sdiv – Signed division (division by 0 gives 0)

**Syntax:** `sdiv Rd, Rn, Rm`

**Operation:** `Rd = Rn / Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sdot – Dot product of four bytes each

**Syntax:** `sdot Vd.4S, Vn.16B, Vm.16B`

Dot product of four bytes each (signed), added to the 32-bit destination.

**Operation:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sete – Fill of a memory block with a byte

**Syntax:** `sete [Xd]!, Xn!, Xs`

Fill of a memory block with a byte, epilogue (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `seten`, `setet`, `setetn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## setge – Fill of a memory block with a byte with tags

**Syntax:** `setge [Xd]!, Xn!, Xs`

Fill of a memory block with a byte with tags, epilogue (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `setgen`, `setget`, `setgetn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## setgm – Fill of a memory block with a byte with tags

**Syntax:** `setgm [Xd]!, Xn!, Xs`

Fill of a memory block with a byte with tags, main part (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `setgmn`, `setgmt`, `setgmtn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## setgp – Fill of a memory block with a byte with tags

**Syntax:** `setgp [Xd]!, Xn!, Xs`

Fill of a memory block with a byte with tags, prologue (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `setgpn`, `setgpt`, `setgptn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## setm – Fill of a memory block with a byte

**Syntax:** `setm [Xd]!, Xn!, Xs`

Fill of a memory block with a byte, main part (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `setmn`, `setmt`, `setmtn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## setp – Fill of a memory block with a byte

**Syntax:** `setp [Xd]!, Xn!, Xs`

Fill of a memory block with a byte, prologue (the three instructions p, m, e are executed in sequence).

**Operation:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Also shown as: `setpn`, `setpt`, `setptn`

*Group: Memory copy and set. Short description from the instruction reference; there is no longer explanation for it yet.*

## sha1c – SHA-1 and SHA-256 hash update

**Syntax:** `sha1c Qd, Sn, Vm.4S`

SHA-1 and SHA-256 hash update (sha1c: choose, sha1p: parity, sha1m: majority, sha256h, sha256h2: hash update, ...su: message schedule).

**Operation:** `Vd = hash_update(Vd, Vn, Vm)`

Also shown as: `sha1p`, `sha1m`, `sha1su0`, `sha256h`, `sha256h2`, `sha256su1`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## sha1h – SHA-1 rotation

**Syntax:** `sha1h Sd, Sn`

SHA-1 rotation (sha1h) and message schedule (sha1su1, sha256su0).

**Operation:** `Sd = rotate_left(Sn, 30)`

Also shown as: `sha1su1`, `sha256su0`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## sha512h – SHA-512 hash update

**Syntax:** `sha512h Qd, Qn, Vm.2D`

SHA-512 hash update (sha512h, sha512h2), message schedule (sha512su1) and rotation (rax1: rotate and exclusive OR, also for SHA-3).

**Operation:** `Vd = hash_update(Vd, Vn, Vm)`

Also shown as: `sha512h2`, `sha512su1`, `rax1`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## sha512su0 – SHA-512 message schedule

**Syntax:** `sha512su0 Vd.2D, Vn.2D`

SHA-512 message schedule (sha512su0) and SM4 encryption of four rounds (sm4e).

**Operation:** `Vd = message_schedule(Vd, Vn)`

Also shown as: `sm4e`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## shadd – Halving addition (signed)

**Syntax:** `shadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] + Vm[i]) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## shl – Shift left

**Syntax:** `shl Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = Vn[i] << shift`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## shll – Widening with a left shift by the element size

**Syntax:** `shll Vd.Ta, Vn.Tb, #shift`

**Operation:** `for every element: Vd[i] = Vn[i] << esize`

Also shown as: `shll2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## shrn – Shift right with narrowing (Q = 1: name with 2)

**Syntax:** `shrn Vd.Tb, Vn.Ta, #shift`

**Operation:** `for every element: Vd[i] = Vn[i] >> shift`

Also shown as: `shrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## shsub – Halving subtraction (signed)

**Syntax:** `shsub Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] - Vm[i]) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sli – Shift left and insert

**Syntax:** `sli Vd.T, Vn.T, #shift`

Shift left and insert (the low bits of the destination stay).

**Operation:** `for every element: Vd[i] = (Vd[i] & low_mask) | (Vn[i] << shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sm3partw1 – SM3 message expansion

**Syntax:** `sm3partw1 Vd.4S, Vn.4S, Vm.4S`

SM3 message expansion (sm3partw1, sm3partw2) and SM4 key schedule (sm4ekey).

**Operation:** `Vd = expand(Vn, Vm)`

Also shown as: `sm3partw2`, `sm4ekey`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## sm3ss1 – SM3 helper value

**Syntax:** `sm3ss1 Vd.4S, Vn.4S, Vm.4S, Va.4S`

**Operation:** `Vd = SM3SS1(Vn, Vm, Va)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## sm3tt1a – SM3 compression function (four variants)

**Syntax:** `sm3tt1a Vd.4S, Vn.4S, Vm.S[imm2]`

**Operation:** `Vd = SM3TT(Vd, Vn, Vm[imm2])`

Also shown as: `sm3tt1b`, `sm3tt2a`, `sm3tt2b`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## smaddl – Signed multiply 32 x 32 bit, added to 64 bit

**Syntax:** `smaddl Xd, Wn, Wm, Xa`

**Operation:** `Xd = Xa + sext(Wn) * sext(Wm)`

Also shown as: `smull`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## smax – Maximum of the elements (signed)

**Syntax:** `smax Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = max_signed(Vn[i], Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smaxp – Maximum of adjacent element pairs (signed)

**Syntax:** `smaxp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = max_signed of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smaxv – Maximum of all elements (signed)

**Syntax:** `smaxv Vd, Vn.T`

**Operation:** `Vd = max_signed of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smc – Secure monitor call (exception level 3)

**Syntax:** `smc #imm16`

**Operation:** `raise a secure monitor call exception`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## smin – Minimum of the elements (signed)

**Syntax:** `smin Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = min_signed(Vn[i], Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sminp – Minimum of adjacent element pairs (signed)

**Syntax:** `sminp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = min_signed of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sminv – Minimum of all elements (signed)

**Syntax:** `sminv Vd, Vn.T`

**Operation:** `Vd = min_signed of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smlal – Multiplication with widening

**Syntax:** `smlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening, added to the destination (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

Also shown as: `smlal2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smlsl – Multiplication with widening

**Syntax:** `smlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening, subtracted from the destination (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

Also shown as: `smlsl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smmla – Matrix multiplication 2x8 times 8x2

**Syntax:** `smmla Vd.4S, Vn.16B, Vm.16B`

Matrix multiplication 2x8 times 8x2 (signed), added to the destination.

**Operation:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smov – Copy of an element into an integer register

**Syntax:** `smov Rd, Vn.Ts[index]`

Copy of an element into an integer register (signed).

**Operation:** `Rd = sext(Vn[index])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## smsubl – Signed multiply 32 x 32 bit

**Syntax:** `smsubl Xd, Wn, Wm, Xa`

Signed multiply 32 x 32 bit, subtracted from 64 bit.

**Operation:** `Xd = Xa - sext(Wn) * sext(Wm)`

Also shown as: `smnegl`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## smulh – Signed multiply, the high 64 bits of the result

**Syntax:** `smulh Xd, Xn, Xm`

**Operation:** `Xd = (sext(Xn) * sext(Xm)) >> 64`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## smull – Multiplication with widening

**Syntax:** `smull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smull Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i] (wide result)`

Also shown as: `smull2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqabs – Absolute value with saturation

**Syntax:** `sqabs Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = saturate(abs(Vn[i]))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqadd – Addition with saturation (signed)

**Syntax:** `sqadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = saturate_signed(Vn[i] + Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqdmlal – Doubling multiplication with widening and saturation

**Syntax:** `sqdmlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Doubling multiplication with widening and saturation, added to the destination.

**Operation:** `for every element: Vd[i] = saturate(Vd[i] + 2 * Vn[i] * Vm[i])`

Also shown as: `sqdmlal2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqdmlsl – Doubling multiplication with widening and saturation

**Syntax:** `sqdmlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Doubling multiplication with widening and saturation, subtracted from the destination.

**Operation:** `for every element: Vd[i] = saturate(Vd[i] - 2 * Vn[i] * Vm[i])`

Also shown as: `sqdmlsl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqdmulh – Doubling multiplication

**Syntax:** `sqdmulh Vd.T, Vn.T, Vm.T` &nbsp; `sqdmulh Vd.T, Vn.T, Vm.Ts[index]`

Doubling multiplication, high half, with saturation.

**Operation:** `for every element: Vd[i] = saturate((2 * Vn[i] * Vm[i]) >> esize)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqdmull – Doubling multiplication with widening and saturation

**Syntax:** `sqdmull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmull Vd.Ta, Vn.Tb, Vm.Ts[index]`

**Operation:** `for every element: Vd[i] = saturate(2 * Vn[i] * Vm[i])`

Also shown as: `sqdmull2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqneg – Negation with saturation

**Syntax:** `sqneg Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = saturate(-Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrdmlah – Doubling multiplication

**Syntax:** `sqrdmlah Vd.T, Vn.T, Vm.T`

Doubling multiplication, high half, with rounding and saturation, added to the destination.

**Operation:** `for every element: Vd[i] = saturate(Vd[i] + round((2 * Vn[i] * Vm[i]) >> esize))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrdmlsh – Doubling multiplication

**Syntax:** `sqrdmlsh Vd.T, Vn.T, Vm.T`

Doubling multiplication, high half, with rounding and saturation, subtracted from the destination.

**Operation:** `for every element: Vd[i] = saturate(Vd[i] - round((2 * Vn[i] * Vm[i]) >> esize))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrdmulh – Doubling multiplication

**Syntax:** `sqrdmulh Vd.T, Vn.T, Vm.T` &nbsp; `sqrdmulh Vd.T, Vn.T, Vm.Ts[index]`

Doubling multiplication, high half, with rounding and saturation.

**Operation:** `for every element: Vd[i] = saturate(round((2 * Vn[i] * Vm[i]) >> esize))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrshl – Shift per element with rounding and saturation

**Syntax:** `sqrshl Vd.T, Vn.T, Vm.T`

Shift per element with rounding and saturation (signed).

**Operation:** `for every element: Vd[i] = saturate_signed(round(Vn[i] << Vm[i]))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrshrn – Shift right with narrowing

**Syntax:** `sqrshrn Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing, rounding and saturation (signed) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_signed(round(Vn[i] >> shift))`

Also shown as: `sqrshrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrshrun – Shift right with narrowing

**Syntax:** `sqrshrun Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing, rounding and saturation (signed source, unsigned result) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] >> shift))`

Also shown as: `sqrshrun2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqshl – Shift per element with saturation (signed)

**Syntax:** `sqshl Vd.T, Vn.T, Vm.T` &nbsp; `sqshl Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = saturate_signed(Vn[i] << Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqshlu – Shift left with saturation

**Syntax:** `sqshlu Vd.T, Vn.T, #shift`

Shift left with saturation (signed source, unsigned result).

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] << shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqshrn – Shift right with narrowing and saturation

**Syntax:** `sqshrn Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing and saturation (signed) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_signed(Vn[i] >> shift)`

Also shown as: `sqshrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqshrun – Shift right with narrowing and saturation

**Syntax:** `sqshrun Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing and saturation (signed source, unsigned result) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] >> shift)`

Also shown as: `sqshrun2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqsub – Subtraction with saturation (signed)

**Syntax:** `sqsub Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = saturate_signed(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqxtn – Narrowing with saturation (signed)

**Syntax:** `sqxtn Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = saturate_signed(Vn[i])`

Also shown as: `sqxtn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sqxtun – Narrowing with saturation

**Syntax:** `sqxtun Vd.T, Vn.T`

Narrowing with saturation (signed source, unsigned result).

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i])`

Also shown as: `sqxtun2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## srhadd – Halving addition with rounding (signed)

**Syntax:** `srhadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] + Vm[i] + 1) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sri – Shift right and insert

**Syntax:** `sri Vd.T, Vn.T, #shift`

Shift right and insert (the high bits of the destination stay).

**Operation:** `for every element: Vd[i] = (Vd[i] & high_mask) | (Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## srshl – Shift per element with rounding (signed)

**Syntax:** `srshl Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = round(Vn[i] << Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## srshr – Shift right with rounding (signed)

**Syntax:** `srshr Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = round(Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## srsra – Shift right with rounding and addition to the destination

**Syntax:** `srsra Vd.T, Vn.T, #shift`

Shift right with rounding and addition to the destination (signed).

**Operation:** `for every element: Vd[i] = Vd[i] + round(Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sshl – Shift left or right per element (signed)

**Syntax:** `sshl Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = Vn[i] << Vm[i] (a negative count shifts right)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sshll – Widening with a left shift

**Syntax:** `sshll Vd.Ta, Vn.Tb, #shift`

Widening with a left shift (signed; sxtl is a shift by 0).

**Operation:** `for every element: Vd[i] = sext(Vn[i]) << shift`

Also shown as: `sshll2`, `sxtl`, `sxtl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## sshr – Shift right, signed (arithmetic) (signed)

**Syntax:** `sshr Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = Vn[i] >> shift`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssra – Shift right and addition to the destination

**Syntax:** `ssra Vd.T, Vn.T, #shift`

Shift right and addition to the destination (signed).

**Operation:** `for every element: Vd[i] = Vd[i] + (Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssubl – Subtraction with widening

**Syntax:** `ssubl Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction with widening (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] - Vm[i] (wide result)`

Also shown as: `ssubl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ssubw – Subtraction of a narrow operand from a wide one

**Syntax:** `ssubw Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction of a narrow operand from a wide one (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] - Vm[i] (Vn is wide)`

Also shown as: `ssubw2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## st1 – Store of one vector register to memory

**Syntax:** `st1 {Vt.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `st1 {Vt.Ts}[index], [Xn|SP]`

**Operation:** `[Rn] = Vt`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## st2 – Store of 2 registers

**Syntax:** `st2 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `st2 {Vt.T, Vt2.T}, [Xn|SP], Xm|#imm` &nbsp; `st2 {Vt.Ts, Vt2.Ts}[index], [Xn|SP]`

Store of 2 registers (elements interleaved) to memory.

**Operation:** `[Rn] = registers (2 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## st2g – Store of the tag for 32 bytes (post-indexed)

**Syntax:** `st2g Xt|SP, [Xn|SP], #imm9` &nbsp; `st2g Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `st2g Xt|SP, [Xn|SP, #imm9]!`

**Operation:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## st3 – Store of 3 registers

**Syntax:** `st3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `st3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP], Xm|#imm` &nbsp; `st3 {Vt.Ts, Vt2.Ts, Vt3.Ts}[index], [Xn|SP]`

Store of 3 registers (elements interleaved) to memory.

**Operation:** `[Rn] = registers (3 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## st4 – Store of 4 registers

**Syntax:** `st4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `st4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP], Xm|#imm` &nbsp; `st4 {Vt.Ts, Vt2.Ts, Vt3.Ts, Vt4.Ts}[index], [Xn|SP]`

Store of 4 registers (elements interleaved) to memory.

**Operation:** `[Rn] = registers (4 registers (elements interleaved))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## stg – Store of the tag of an address for 16 bytes

**Syntax:** `stg Xt|SP, [Xn|SP], #imm9` &nbsp; `stg Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stg Xt|SP, [Xn|SP, #imm9]!`

Store of the tag of an address for 16 bytes (post-indexed).

**Operation:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## stgp – Store of a register pair and the tag

**Syntax:** `stgp Xt, Xt2, [Xn|SP], #imm7` &nbsp; `stgp Xt, Xt2, [Xn|SP{, #imm7}]` &nbsp; `stgp Xt, Xt2, [Xn|SP, #imm7]!`

Store of a register pair and the tag (post-indexed).

**Operation:** `[addr] = Xt, Xt2; tag of [addr] = tag of Rn`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## stllr – Store with release for an ordered memory region

**Syntax:** `stllr Wt, [Xn|SP]`

Store with release for an ordered memory region (LORegion; b = byte, h = half word).

**Operation:** `[Rn] = Wt`

Also shown as: `stllrb`, `stllrh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlr – Store with release (word)

**Syntax:** `stlr Wt, [Xn|SP]` &nbsp; `stlr Xt, [Xn|SP]`

**Operation:** `release; [Rn] = Rt`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlrb – Store with release (byte)

**Syntax:** `stlrb Wt, [Xn|SP]`

**Operation:** `release; [Rn] = Rt`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlrh – Store with release (half word)

**Syntax:** `stlrh Wt, [Xn|SP]`

**Operation:** `release; [Rn] = Rt`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlur – Store with release

**Syntax:** `stlur Wt, [Xn|SP{, #imm9}]`

Store with release (unscaled, address: Rn + imm9; b = byte, h = half word).

**Operation:** `[Rn + imm9] = Wt`

Also shown as: `stlurb`, `stlurh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlxp – Store-exclusive of a register pair with release

**Syntax:** `stlxp Ws, Rt, Rt2, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { release; [Rn] = Rt; [Rn + size] = Rt2; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlxr – Store-exclusive with release (word)

**Syntax:** `stlxr Ws, Wt, [Xn|SP]` &nbsp; `stlxr Ws, Xt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlxrb – Store-exclusive with release (byte)

**Syntax:** `stlxrb Ws, Wt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stlxrh – Store-exclusive with release (half word)

**Syntax:** `stlxrh Ws, Wt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stnp – Store of a register pair with a non-temporal hint

**Syntax:** `stnp Rt, Rt2, [Xn|SP{, #imm7}]`

**Operation:** `[addr] = Rt; [addr + size] = Rt2`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stp – Store of a register pair (post-indexed)

**Syntax:** `stp Rt, Rt2, [Xn|SP], #imm7` &nbsp; `stp Rt, Rt2, [Xn|SP{, #imm7}]` &nbsp; `stp Rt, Rt2, [Xn|SP, #imm7]!` &nbsp; `stp Ft, Ft2, [Xn|SP{, #imm7}]`

**Operation:** `[addr] = Rt; [addr + size] = Rt2; addr = Rn; Rn = Rn + imm7 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## str – Store of a word

**Syntax:** `str Wt, [Xn|SP{, #imm12}]` &nbsp; `str Wt, [Xn|SP, #imm9]!` &nbsp; `str Wt, [Xn|SP], #imm9` &nbsp; `str Wt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `str Xt, [Xn|SP{, #imm12}]` &nbsp; `str Xt, [Xn|SP, #imm9]!` &nbsp; `str Xt, [Xn|SP], #imm9` &nbsp; `str Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; …

Store of a word (32 bit) (address: Rn + imm12 * size).

**Operation:** `[addr] = Wt; addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strb – Store of a byte (address: Rn + imm12 * size)

**Syntax:** `strb Wt, [Xn|SP{, #imm12}]` &nbsp; `strb Wt, [Xn|SP, #imm9]!` &nbsp; `strb Wt, [Xn|SP], #imm9` &nbsp; `strb Wt, [Xn|SP, Rm{, extend {#amount}}]`

**Operation:** `[addr] = Wt[7:0]; addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## strh – Store of a half word

**Syntax:** `strh Wt, [Xn|SP{, #imm12}]` &nbsp; `strh Wt, [Xn|SP, #imm9]!` &nbsp; `strh Wt, [Xn|SP], #imm9` &nbsp; `strh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Store of a half word (16 bit) (address: Rn + imm12 * size).

**Operation:** `[addr] = Wt[15:0]; addr = Rn + imm12 * size`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sttr – Store with the rights of user mode

**Syntax:** `sttr Wt, [Xn|SP{, #imm9}]`

Store with the rights of user mode (unprivileged; b = byte, h = half word).

**Operation:** `[Rn + imm9] = Wt`

Also shown as: `sttrb`, `sttrh`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stur – Store of a word

**Syntax:** `stur Wt, [Xn|SP{, #imm9}]` &nbsp; `stur Xt, [Xn|SP{, #imm9}]`

Store of a word (32 bit) (unscaled, address: Rn + imm9).

**Operation:** `[addr] = Wt; addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sturb – Store of a byte (unscaled, address: Rn + imm9)

**Syntax:** `sturb Wt, [Xn|SP{, #imm9}]`

**Operation:** `[addr] = Wt[7:0]; addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sturh – Store of a half word

**Syntax:** `sturh Wt, [Xn|SP{, #imm9}]`

Store of a half word (16 bit) (unscaled, address: Rn + imm9).

**Operation:** `[addr] = Wt[15:0]; addr = Rn + imm9`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stxp – Store-exclusive of a register pair

**Syntax:** `stxp Ws, Rt, Rt2, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt; [Rn + size] = Rt2; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stxr – Store-exclusive: Ws = 0 on success (word)

**Syntax:** `stxr Ws, Wt, [Xn|SP]` &nbsp; `stxr Ws, Xt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stxrb – Store-exclusive: Ws = 0 on success (byte)

**Syntax:** `stxrb Ws, Wt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stxrh – Store-exclusive: Ws = 0 on success (half word)

**Syntax:** `stxrh Ws, Wt, [Xn|SP]`

**Operation:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## stz2g – Store of the tag and zeroing of 32 bytes

**Syntax:** `stz2g Xt|SP, [Xn|SP], #imm9` &nbsp; `stz2g Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stz2g Xt|SP, [Xn|SP, #imm9]!`

Store of the tag and zeroing of 32 bytes (post-indexed).

**Operation:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## stzg – Store of the tag and zeroing of 16 bytes

**Syntax:** `stzg Xt|SP, [Xn|SP], #imm9` &nbsp; `stzg Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stzg Xt|SP, [Xn|SP, #imm9]!`

Store of the tag and zeroing of 16 bytes (post-indexed).

**Operation:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## stzgm – Store of several tags and zeroing of the memory

**Syntax:** `stzgm Xt, [Xn|SP]`

Store of several tags and zeroing of the memory (size from the system).

**Operation:** `tags and memory of the block at Rn = Xt`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## sub – Subtraction of a constant

**Syntax:** `sub Rd, Rn, #imm12{, lsl #12}` &nbsp; `sub Rd, Rn, Rm{, shift #imm6}` &nbsp; `sub Rd, Rn, Rm{, extend #imm3}` &nbsp; `sub Vd.T, Vn.T, Vm.T`

Subtraction of a constant (12 bit, optionally shifted left by 12).

**Operation:** `Rd = Rn - (imm12 << (sh * 12)) (Rd and Rn may be SP)`

Also shown as: `neg`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subg – Subtraction from an address with a change of the tag

**Syntax:** `subg Xd|SP, Xn|SP, #uimm6, #uimm4`

**Operation:** `Xd = Xn - uimm6 * 16, tag = (tag of Xn - uimm4) modulo 16`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## subhn – Subtraction with narrowing

**Syntax:** `subhn Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction with narrowing (high half; rsubhn with rounding) (signed; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = high half of (Vn[i] - Vm[i])`

Also shown as: `subhn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## subp – Difference of two addresses without tags

**Syntax:** `subp Xd, Xn|SP, Xm|SP`

Difference of two addresses without tags (56 bit, signed).

**Operation:** `Xd = sext(Xn[55:0]) - sext(Xm[55:0])`

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## subps – Difference of two addresses without tags

**Syntax:** `subps Xd, Xn|SP, Xm|SP`

Difference of two addresses without tags, sets the flags.

**Operation:** `Xd = sext(Xn[55:0]) - sext(Xm[55:0])`

**Flags:** N Z C V

*Group: Memory tagging (MTE). Short description from the instruction reference; there is no longer explanation for it yet.*

## subs – Subtraction of a constant, sets the flags

**Syntax:** `subs Rd, Rn, #imm12{, lsl #12}` &nbsp; `subs Rd, Rn, Rm{, shift #imm6}` &nbsp; `subs Rd, Rn, Rm{, extend #imm3}`

**Operation:** `Rd = Rn - (imm12 << (sh * 12))`

**Flags:** N Z C V

Also shown as: `cmp`, `negs`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sudot – Dot product of four bytes each with an element

**Syntax:** `sudot Vd.4S, Vn.16B, Vm.4B[index]`

Dot product of four bytes each with an element (Vn signed, Vm unsigned), added to the 32-bit destination.

**Operation:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[index][k]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## suqadd – Addition of an unsigned value to a signed one

**Syntax:** `suqadd Vd.T, Vn.T`

Addition of an unsigned value to a signed one, with saturation.

**Operation:** `for every element: Vd[i] = saturate_signed(Vd[i] + Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## svc – Supervisor call to the operating system

**Syntax:** `svc #imm16`

Supervisor call to the operating system (exception level 1).

**Operation:** `raise a supervisor call exception with imm16`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## swp – Atomic exchange of a register with memory

**Syntax:** `swp Ws, Wt, [Xn|SP]`

Atomic exchange of a register with memory (variants: b = byte, h = half word, a = acquire, l = release).

**Operation:** `t = [Rn]; [Rn] = Ws; Wt = t`

Also shown as: `swpa`, `swpal`, `swpl`, `swpb`, `swpab`, `swpalb`, `swplb`, `swph`, `swpah`, `swpalh`, `swplh`

*Group: Atomic memory operations (LSE). Short description from the instruction reference; there is no longer explanation for it yet.*

## sys – System instruction

**Syntax:** `sys #op1, Cn, Cm, #op2{, Xt}`

System instruction (cache, TLB and address translation operations, also written as dc, ic, at, tlbi; sysl reads a result).

**Operation:** `execute the system operation (op1, Cn, Cm, op2) with Xt`

Also shown as: `sysl`, `tlbi`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## tbl – Lookup of bytes in a table of 1 to 4 vectors

**Syntax:** `tbl Vd.T, {Vn.16B ...}, Vm.T`

Lookup of bytes in a table of 1 to 4 vectors (tbx leaves bytes out of range unchanged, tbl sets them to 0).

**Operation:** `for every element: Vd[i] = table[Vm[i]]`

Also shown as: `tbx`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## tbnz – Jump if one bit of the register is 1

**Syntax:** `tbnz Rt, #bit, label`

**Operation:** `if bit(b5:b40) of Rt == 1 then pc = pc + sext(imm14 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## tbz – Jump if one bit of the register is 0

**Syntax:** `tbz Rt, #bit, label`

**Operation:** `if bit(b5:b40) of Rt == 0 then pc = pc + sext(imm14 << 2)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## tcancel – Cancel of a transaction (TME)

**Syntax:** `tcancel #imm16`

**Operation:** `abort the transaction with the reason imm16`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## trn1 – Transposition

**Syntax:** `trn1 Vd.T, Vn.T, Vm.T`

Transposition: even-numbered elements alternately from two vectors.

**Operation:** `Vd = Vn[0], Vm[0], Vn[2], Vm[2] ...`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## trn2 – Transposition

**Syntax:** `trn2 Vd.T, Vn.T, Vm.T`

Transposition: odd-numbered elements alternately from two vectors.

**Operation:** `Vd = Vn[1], Vm[1], Vn[3], Vm[3] ...`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uaba – Addition of the absolute difference to the destination

**Syntax:** `uaba Vd.T, Vn.T, Vm.T`

Addition of the absolute difference to the destination (unsigned).

**Operation:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uabal – Addition of the absolute difference with widening

**Syntax:** `uabal Vd.Tb, Vn.Ta, Vm.Ta`

Addition of the absolute difference with widening (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

Also shown as: `uabal2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uabd – Absolute difference (unsigned)

**Syntax:** `uabd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uabdl – Absolute difference with widening

**Syntax:** `uabdl Vd.Tb, Vn.Ta, Vm.Ta`

Absolute difference with widening (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = abs(Vn[i] - Vm[i]) (wide result)`

Also shown as: `uabdl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uadalp – Pairwise addition with widening

**Syntax:** `uadalp Vd.T, Vn.T`

Pairwise addition with widening, added to the destination (unsigned).

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[2i] + Vn[2i+1]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uaddl – Addition with widening

**Syntax:** `uaddl Vd.Tb, Vn.Ta, Vm.Ta`

Addition with widening (both operands become twice as wide) (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] + Vm[i] (wide result)`

Also shown as: `uaddl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uaddlp – Pairwise addition of adjacent elements with widening

**Syntax:** `uaddlp Vd.T, Vn.T`

Pairwise addition of adjacent elements with widening (unsigned).

**Operation:** `for every element: Vd[i] = Vn[2i] + Vn[2i+1]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uaddlv – Sum of all elements with widening (unsigned)

**Syntax:** `uaddlv Vd, Vn.T`

**Operation:** `Vd = sum of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uaddw – Addition of a wide and a narrow operand

**Syntax:** `uaddw Vd.Tb, Vn.Ta, Vm.Ta`

Addition of a wide and a narrow operand (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] + Vm[i] (Vn is wide)`

Also shown as: `uaddw2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ubfm – Bitfield move with zeros

**Syntax:** `ubfm Rd, Rn, #immr, #imms`

Bitfield move with zeros (base form of lsl, lsr, ubfx, uxtb ...).

**Operation:** `Rd = zero-extended field of Rn selected by immr, imms`

Also shown as: `lsl`, `lsr`, `ubfiz`, `ubfx`, `uxtb`, `uxth`

*Group: Bitfields. Short description from the instruction reference; there is no longer explanation for it yet.*

## ucvtf – Conversion of an unsigned integer to floating point

**Syntax:** `ucvtf Fd, Rn` &nbsp; `ucvtf Vd.T, Vn.T`

**Operation:** `Fd = (float) zext(Rn)`

*Group: Floating point (scalar). Short description from the instruction reference; there is no longer explanation for it yet.*

## udf – Permanently undefined instruction

**Syntax:** `udf #imm16`

Permanently undefined instruction (always raises an exception).

**Operation:** `raise undefined-instruction exception`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## udiv – Unsigned division (division by 0 gives 0)

**Syntax:** `udiv Rd, Rn, Rm`

**Operation:** `Rd = Rn / Rm`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## udot – Dot product of four bytes each

**Syntax:** `udot Vd.4S, Vn.16B, Vm.16B`

Dot product of four bytes each (unsigned), added to the 32-bit destination.

**Operation:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uhadd – Halving addition (unsigned)

**Syntax:** `uhadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] + Vm[i]) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uhsub – Halving subtraction (unsigned)

**Syntax:** `uhsub Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] - Vm[i]) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umaddl – Unsigned multiply 32 x 32 bit, added to 64 bit

**Syntax:** `umaddl Xd, Wn, Wm, Xa`

**Operation:** `Xd = Xa + zext(Wn) * zext(Wm)`

Also shown as: `umull`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## umax – Maximum of the elements (unsigned)

**Syntax:** `umax Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = max_unsigned(Vn[i], Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umaxp – Maximum of adjacent element pairs (unsigned)

**Syntax:** `umaxp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = max_unsigned of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umaxv – Maximum of all elements (unsigned)

**Syntax:** `umaxv Vd, Vn.T`

**Operation:** `Vd = max_unsigned of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umin – Minimum of the elements (unsigned)

**Syntax:** `umin Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = min_unsigned(Vn[i], Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uminp – Minimum of adjacent element pairs (unsigned)

**Syntax:** `uminp Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = min_unsigned of each pair of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uminv – Minimum of all elements (unsigned)

**Syntax:** `uminv Vd, Vn.T`

**Operation:** `Vd = min_unsigned of all elements of Vn`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umlal – Multiplication with widening

**Syntax:** `umlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening, added to the destination (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

Also shown as: `umlal2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umlsl – Multiplication with widening

**Syntax:** `umlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening, subtracted from the destination (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

Also shown as: `umlsl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ummla – Matrix multiplication 2x8 times 8x2

**Syntax:** `ummla Vd.4S, Vn.16B, Vm.16B`

Matrix multiplication 2x8 times 8x2 (unsigned), added to the destination.

**Operation:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umov – Copy of an element into an integer register

**Syntax:** `umov Rd, Vn.Ts[index]`

Copy of an element into an integer register (unsigned).

**Operation:** `Rd = zext(Vn[index])`

Also shown as: `mov`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## umsubl – Unsigned multiply 32 x 32 bit

**Syntax:** `umsubl Xd, Wn, Wm, Xa`

Unsigned multiply 32 x 32 bit, subtracted from 64 bit.

**Operation:** `Xd = Xa - zext(Wn) * zext(Wm)`

Also shown as: `umnegl`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## umulh – Unsigned multiply, the high 64 bits of the result

**Syntax:** `umulh Xd, Xn, Xm`

**Operation:** `Xd = (zext(Xn) * zext(Xm)) >> 64`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## umull – Multiplication with widening

**Syntax:** `umull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umull Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplication with widening (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] * Vm[i] (wide result)`

Also shown as: `umull2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqadd – Addition with saturation (unsigned)

**Syntax:** `uqadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] + Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqrshl – Shift per element with rounding and saturation

**Syntax:** `uqrshl Vd.T, Vn.T, Vm.T`

Shift per element with rounding and saturation (unsigned).

**Operation:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] << Vm[i]))`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqrshrn – Shift right with narrowing

**Syntax:** `uqrshrn Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing, rounding and saturation (unsigned) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] >> shift))`

Also shown as: `uqrshrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqshl – Shift per element with saturation (unsigned)

**Syntax:** `uqshl Vd.T, Vn.T, Vm.T` &nbsp; `uqshl Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] << Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqshrn – Shift right with narrowing and saturation

**Syntax:** `uqshrn Vd.Tb, Vn.Ta, #shift`

Shift right with narrowing and saturation (unsigned) (Q = 1: name with 2).

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] >> shift)`

Also shown as: `uqshrn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqsub – Subtraction with saturation (unsigned)

**Syntax:** `uqsub Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i] - Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uqxtn – Narrowing with saturation (unsigned)

**Syntax:** `uqxtn Vd.T, Vn.T`

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vn[i])`

Also shown as: `uqxtn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## urhadd – Halving addition with rounding (unsigned)

**Syntax:** `urhadd Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = (Vn[i] + Vm[i] + 1) >> 1`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## urshl – Shift per element with rounding (unsigned)

**Syntax:** `urshl Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = round(Vn[i] << Vm[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## urshr – Shift right with rounding (unsigned)

**Syntax:** `urshr Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = round(Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ursra – Shift right with rounding and addition to the destination

**Syntax:** `ursra Vd.T, Vn.T, #shift`

Shift right with rounding and addition to the destination (unsigned).

**Operation:** `for every element: Vd[i] = Vd[i] + round(Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usdot – Dot product of four bytes each

**Syntax:** `usdot Vd.4S, Vn.16B, Vm.16B`

Dot product of four bytes each (Vn unsigned, Vm signed), added to the 32-bit destination.

**Operation:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ushl – Shift left or right per element (unsigned)

**Syntax:** `ushl Vd.T, Vn.T, Vm.T`

**Operation:** `for every element: Vd[i] = Vn[i] << Vm[i] (a negative count shifts right)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ushll – Widening with a left shift

**Syntax:** `ushll Vd.Ta, Vn.Tb, #shift`

Widening with a left shift (unsigned; uxtl is a shift by 0).

**Operation:** `for every element: Vd[i] = zext(Vn[i]) << shift`

Also shown as: `ushll2`, `uxtl`, `uxtl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## ushr – Shift right, signed (arithmetic) (unsigned)

**Syntax:** `ushr Vd.T, Vn.T, #shift`

**Operation:** `for every element: Vd[i] = Vn[i] >> shift`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usmmla – Matrix multiplication 2x8 times 8x2

**Syntax:** `usmmla Vd.4S, Vn.16B, Vm.16B`

Matrix multiplication 2x8 times 8x2 (Vn unsigned, Vm signed), added to the destination.

**Operation:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usqadd – Addition of a signed value to an unsigned one

**Syntax:** `usqadd Vd.T, Vn.T`

Addition of a signed value to an unsigned one, with saturation.

**Operation:** `for every element: Vd[i] = saturate_unsigned(Vd[i] + Vn[i])`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usra – Shift right and addition to the destination

**Syntax:** `usra Vd.T, Vn.T, #shift`

Shift right and addition to the destination (unsigned).

**Operation:** `for every element: Vd[i] = Vd[i] + (Vn[i] >> shift)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usubl – Subtraction with widening

**Syntax:** `usubl Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction with widening (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] - Vm[i] (wide result)`

Also shown as: `usubl2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## usubw – Subtraction of a narrow operand from a wide one

**Syntax:** `usubw Vd.Tb, Vn.Ta, Vm.Ta`

Subtraction of a narrow operand from a wide one (unsigned; Q = 1: high half of the sources, name with 2).

**Operation:** `for every element: Vd[i] = Vn[i] - Vm[i] (Vn is wide)`

Also shown as: `usubw2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uzp1 – Extraction of the even-numbered elements of two vectors

**Syntax:** `uzp1 Vd.T, Vn.T, Vm.T`

**Operation:** `Vd = even elements of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## uzp2 – Extraction of the odd-numbered elements of two vectors

**Syntax:** `uzp2 Vd.T, Vn.T, Vm.T`

**Operation:** `Vd = odd elements of (Vn:Vm)`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## xar – Exclusive OR and rotation to the right (SHA-3)

**Syntax:** `xar Vd.2D, Vn.2D, Vm.2D, #imm6`

**Operation:** `Vd = rotate_right(Vn ^ Vm, imm6)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## xtn – Narrowing of the elements

**Syntax:** `xtn Vd.T, Vn.T`

Narrowing of the elements (the high half is cut off).

**Operation:** `for every element: Vd[i] = low half of Vn[i]`

Also shown as: `xtn2`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## zip1 – Interleaving of the low halves of two vectors

**Syntax:** `zip1 Vd.T, Vn.T, Vm.T`

Interleaving of the low halves of two vectors, alternately.

**Operation:** `Vd = Vn[0], Vm[0], Vn[1], Vm[1] ...`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*

## zip2 – Interleaving of the high halves of two vectors

**Syntax:** `zip2 Vd.T, Vn.T, Vm.T`

Interleaving of the high halves of two vectors, alternately.

**Operation:** `Vd = Vn[n/2], Vm[n/2], Vn[n/2+1] ...`

*Group: Vector (SIMD). Short description from the instruction reference; there is no longer explanation for it yet.*
