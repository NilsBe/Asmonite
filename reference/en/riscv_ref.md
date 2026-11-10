# Instructions from the instruction reference (generated)

Made by tools/gen_help_ref.py from the tables of the assembler (tools/instr), do not edit. F1 shows a section from here when the help of the architecture has none of its own.

## add – Addition of two registers

**Syntax:** `add rd, rs1, rs2`

**Operation:** `rd = rs1 + rs2`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## add.uw – Addition of the low word, unsigned (Zba, RV64)

**Syntax:** `add.uw rd, rs1, rs2`

**Operation:** `rd = rs2 + zext(rs1[31:0])`

Also shown as: `zext.w`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## addi – Addition of a constant (12 bit, signed)

**Syntax:** `addi rd, rs1, imm12`

**Operation:** `rd = rs1 + sext(imm12)`

Also shown as: `li`, `mv`, `nop`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addiw – Addition of a constant in 32 bits

**Syntax:** `addiw rd, rs1, imm12`

Addition of a constant in 32 bits, the result sign-extended to 64 (RV64).

**Operation:** `rd = sext((rs1 + sext(imm12))[31:0])`

Also shown as: `sext.w`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addw – Addition in 32 bits

**Syntax:** `addw rd, rs1, rs2`

Addition in 32 bits, the result sign-extended to 64 (RV64).

**Operation:** `rd = sext((rs1 + rs2)[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## amoadd.d – Atomic addition on a doubleword (A, RV64)

**Syntax:** `amoadd.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = rd + rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoadd.w – Atomic addition (A)

**Syntax:** `amoadd.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = rd + rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoand.d – Atomic AND on a doubleword (A, RV64)

**Syntax:** `amoand.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = rd & rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoand.w – Atomic AND (A)

**Syntax:** `amoand.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = rd & rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomax.d – Atomic signed maximum on a doubleword (A, RV64)

**Syntax:** `amomax.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = max_s(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomax.w – Atomic signed maximum (A)

**Syntax:** `amomax.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = max_s(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomaxu.d – Atomic unsigned maximum on a doubleword (A, RV64)

**Syntax:** `amomaxu.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = max_u(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomaxu.w – Atomic unsigned maximum (A)

**Syntax:** `amomaxu.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = max_u(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomin.d – Atomic signed minimum on a doubleword (A, RV64)

**Syntax:** `amomin.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = min_s(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amomin.w – Atomic signed minimum (A)

**Syntax:** `amomin.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = min_s(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amominu.d – Atomic unsigned minimum on a doubleword (A, RV64)

**Syntax:** `amominu.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = min_u(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amominu.w – Atomic unsigned minimum (A)

**Syntax:** `amominu.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = min_u(rd, rs2)`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoor.d – Atomic OR on a doubleword (A, RV64)

**Syntax:** `amoor.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = rd | rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoor.w – Atomic OR (A)

**Syntax:** `amoor.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = rd | rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoswap.d – Atomic swap of a doubleword (A, RV64)

**Syntax:** `amoswap.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoswap.w – Atomic swap (A)

**Syntax:** `amoswap.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoxor.d – Atomic exclusive OR on a doubleword (A, RV64)

**Syntax:** `amoxor.d rd, rs2, (rs1)`

**Operation:** `rd = [rs1]64; [rs1]64 = rd ^ rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## amoxor.w – Atomic exclusive OR (A)

**Syntax:** `amoxor.w rd, rs2, (rs1)`

**Operation:** `rd = [rs1]; [rs1] = rd ^ rs2`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## and – AND

**Syntax:** `and rd, rs1, rs2`

**Operation:** `rd = rs1 & rs2`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## andi – AND with a constant

**Syntax:** `andi rd, rs1, imm12`

**Operation:** `rd = rs1 & sext(imm12)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## andn – AND with an inverted operand (Zbb, Zbkb)

**Syntax:** `andn rd, rs1, rs2`

**Operation:** `rd = rs1 & ~rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## auipc – Addition of the upper 20 bits to the pc

**Syntax:** `auipc rd, imm20`

Addition of the upper 20 bits to the pc (address relative to the instruction).

**Operation:** `rd = pc + (imm20 << 12)`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## bclr – Clearing of one bit (Zbs)

**Syntax:** `bclr rd, rs1, rs2`

**Operation:** `rd = rs1 & ~(1 << rs2[4:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## bclri – Clearing of one bit

**Syntax:** `bclri rd, rs1, shamt`

Clearing of one bit, its number as a constant (Zbs).

**Operation:** `rd = rs1 & ~(1 << shamt)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## beq – Branch if equal

**Syntax:** `beq rs1, rs2, label`

**Operation:** `if rs1 == rs2 then pc = pc + sext(imm13)`

Also shown as: `beqz`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bext – Extraction of one bit (Zbs)

**Syntax:** `bext rd, rs1, rs2`

**Operation:** `rd = (rs1 >> rs2[4:0]) & 1`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## bexti – Extraction of one bit

**Syntax:** `bexti rd, rs1, shamt`

Extraction of one bit, its number as a constant (Zbs).

**Operation:** `rd = (rs1 >> shamt) & 1`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## bge – Branch if greater or equal (signed)

**Syntax:** `bge rs1, rs2, label`

**Operation:** `if rs1 >=s rs2 then pc = pc + sext(imm13)`

Also shown as: `bgez`, `blez`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bgeu – Branch if greater or equal (unsigned)

**Syntax:** `bgeu rs1, rs2, label`

**Operation:** `if rs1 >=u rs2 then pc = pc + sext(imm13)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## binv – Inversion of one bit (Zbs)

**Syntax:** `binv rd, rs1, rs2`

**Operation:** `rd = rs1 ^ (1 << rs2[4:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## binvi – Inversion of one bit

**Syntax:** `binvi rd, rs1, shamt`

Inversion of one bit, its number as a constant (Zbs).

**Operation:** `rd = rs1 ^ (1 << shamt)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## blt – Branch if less (signed)

**Syntax:** `blt rs1, rs2, label`

**Operation:** `if rs1 <s rs2 then pc = pc + sext(imm13)`

Also shown as: `bltz`, `bgtz`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bltu – Branch if less (unsigned)

**Syntax:** `bltu rs1, rs2, label`

**Operation:** `if rs1 <u rs2 then pc = pc + sext(imm13)`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## bne – Branch if not equal

**Syntax:** `bne rs1, rs2, label`

**Operation:** `if rs1 != rs2 then pc = pc + sext(imm13)`

Also shown as: `bnez`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## brev8 – Reversal of the bits in every byte (Zbkb)

**Syntax:** `brev8 rd, rs1`

**Operation:** `for every byte: rd.byte = bit_reverse(rs1.byte)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## bset – Setting of one bit (Zbs)

**Syntax:** `bset rd, rs1, rs2`

**Operation:** `rd = rs1 | (1 << rs2[4:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## bseti – Setting of one bit, its number as a constant (Zbs)

**Syntax:** `bseti rd, rs1, shamt`

**Operation:** `rd = rs1 | (1 << shamt)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.add – Addition of two registers

**Syntax:** `c.add rd, rs2`

**Operation:** `rd = rd + rs2 (rs2 != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.addi – Addition of a constant (6 bit, signed)

**Syntax:** `c.addi rd, imm6`

**Operation:** `rd = rd + sext(imm6)`

Also shown as: `c.nop`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.addi16sp – Addition of a multiple of 16 to sp

**Syntax:** `c.addi16sp sp, imm`

**Operation:** `sp = sp + sext(imm10) (imm != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.addi4spn – Addition of a constant to sp

**Syntax:** `c.addi4spn rd', sp, uimm`

Addition of a constant to sp (an address on the stack).

**Operation:** `rd' = sp + zext(uimm) (uimm != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.addiw – Addition of a constant in 32 bits (RV64)

**Syntax:** `c.addiw rd, imm6`

**Operation:** `rd = sext((rd + sext(imm6))[31:0]) (rd != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.addw – Addition in 32 bits (RV64)

**Syntax:** `c.addw rd', rs2'`

**Operation:** `rd' = sext((rd' + rs2')[31:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.and – AND

**Syntax:** `c.and rd', rs2'`

**Operation:** `rd' = rd' & rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.andi – AND with a constant (6 bit, signed)

**Syntax:** `c.andi rd', imm6`

**Operation:** `rd' = rd' & sext(imm6)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.beqz – Branch if zero

**Syntax:** `c.beqz rs1', label`

**Operation:** `if rs1' == 0 then pc = pc + sext(imm9)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.bnez – Branch if not zero

**Syntax:** `c.bnez rs1', label`

**Operation:** `if rs1' != 0 then pc = pc + sext(imm9)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.ebreak – Breakpoint for the debugger

**Syntax:** `c.ebreak`

**Operation:** `raise breakpoint exception (or enter debug mode)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.j – Jump (±2 KB)

**Syntax:** `c.j label`

**Operation:** `pc = pc + sext(imm12)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.jal – Jump and link to ra (±2 KB)

**Syntax:** `c.jal label`

**Operation:** `ra = pc + 2; pc = pc + sext(imm12)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.jalr – Jump to the address in a register, and link to ra

**Syntax:** `c.jalr rs1`

**Operation:** `t = rs1; ra = pc + 2; pc = t`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.jr – Jump to the address in a register

**Syntax:** `c.jr rs1`

**Operation:** `pc = rs1 (rs1 != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lbu – Load of a byte, unsigned (Zcb)

**Syntax:** `c.lbu rd', uimm(rs1')`

**Operation:** `rd' = zext([rs1' + uimm]8)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.ld – Load of a doubleword (RV64)

**Syntax:** `c.ld rd', uimm(rs1')`

**Operation:** `rd' = [rs1' + zext(uimm)]64`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.ldsp – Load of a doubleword from the stack (RV64)

**Syntax:** `c.ldsp rd, uimm(sp)`

**Operation:** `rd = [sp + zext(uimm)]64 (rd != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lh – Load of a half word, signed (Zcb)

**Syntax:** `c.lh rd', uimm(rs1')`

**Operation:** `rd' = sext([rs1' + uimm]16)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lhu – Load of a half word, unsigned (Zcb)

**Syntax:** `c.lhu rd', uimm(rs1')`

**Operation:** `rd' = zext([rs1' + uimm]16)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.li – Load of a constant (6 bit, signed)

**Syntax:** `c.li rd, imm6`

**Operation:** `rd = sext(imm6)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lui – Load of the bits 17 to 12 of a constant

**Syntax:** `c.lui rd, imm6`

**Operation:** `rd = sext(imm6 << 12) (rd != 0, 2)`

Also shown as: `c.addi16sp`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lw – Load of a word

**Syntax:** `c.lw rd', uimm(rs1')`

**Operation:** `rd' = [rs1' + zext(uimm)]32`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.lwsp – Load of a word from the stack

**Syntax:** `c.lwsp rd, uimm(sp)`

**Operation:** `rd = [sp + zext(uimm)]32 (rd != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.mul – Multiplication, low 32 bits (Zcb)

**Syntax:** `c.mul rd', rs2'`

**Operation:** `rd' = (rd' * rs2')[31:0]`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.mv – Copy of a register

**Syntax:** `c.mv rd, rs2`

**Operation:** `rd = rs2 (rs2 != 0)`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.not – Bitwise inversion (Zcb)

**Syntax:** `c.not rd'`

**Operation:** `rd' = ~rd'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.or – OR

**Syntax:** `c.or rd', rs2'`

**Operation:** `rd' = rd' | rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sb – Store of a byte (Zcb)

**Syntax:** `c.sb rs2', uimm(rs1')`

**Operation:** `[rs1' + uimm]8 = rs2'[7:0]`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sd – Store of a doubleword (RV64)

**Syntax:** `c.sd rs2', uimm(rs1')`

**Operation:** `[rs1' + zext(uimm)]64 = rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sdsp – Store of a doubleword on the stack (RV64)

**Syntax:** `c.sdsp rs2, uimm(sp)`

**Operation:** `[sp + zext(uimm)]64 = rs2`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sext.b – Sign extension of a byte (Zcb)

**Syntax:** `c.sext.b rd'`

**Operation:** `rd' = sext(rd'[7:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sext.h – Sign extension of a half word (Zcb)

**Syntax:** `c.sext.h rd'`

**Operation:** `rd' = sext(rd'[15:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sh – Store of a half word (Zcb)

**Syntax:** `c.sh rs2', uimm(rs1')`

**Operation:** `[rs1' + uimm]16 = rs2'[15:0]`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.slli – Shift left by a constant

**Syntax:** `c.slli rd, shamt`

**Operation:** `rd = rd << shamt`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.srai – Shift right signed by a constant

**Syntax:** `c.srai rd', shamt`

**Operation:** `rd' = rd' >>s shamt`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.srli – Shift right unsigned by a constant

**Syntax:** `c.srli rd', shamt`

**Operation:** `rd' = rd' >>u shamt`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sub – Subtraction

**Syntax:** `c.sub rd', rs2'`

**Operation:** `rd' = rd' - rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.subw – Subtraction in 32 bits (RV64)

**Syntax:** `c.subw rd', rs2'`

**Operation:** `rd' = sext((rd' - rs2')[31:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.sw – Store of a word

**Syntax:** `c.sw rs2', uimm(rs1')`

**Operation:** `[rs1' + zext(uimm)]32 = rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.swsp – Store of a word on the stack

**Syntax:** `c.swsp rs2, uimm(sp)`

**Operation:** `[sp + zext(uimm)]32 = rs2`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.xor – Exclusive OR

**Syntax:** `c.xor rd', rs2'`

**Operation:** `rd' = rd' ^ rs2'`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.zext.b – Zero extension of a byte (Zcb)

**Syntax:** `c.zext.b rd'`

**Operation:** `rd' = zext(rd'[7:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.zext.h – Zero extension of a half word (Zcb)

**Syntax:** `c.zext.h rd'`

**Operation:** `rd' = zext(rd'[15:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## c.zext.w – The low word zero-extended to 64 bits (Zcb, RV64)

**Syntax:** `c.zext.w rd'`

**Operation:** `rd' = zext(rd'[31:0])`

*Group: Compressed instructions (C, Zcb). Short description from the instruction reference; there is no longer explanation for it yet.*

## clmul – Carry-less multiplication, low 32 bits (Zbc)

**Syntax:** `clmul rd, rs1, rs2`

**Operation:** `rd = clmul(rs1, rs2)[31:0]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## clmulh – Carry-less multiplication, high 32 bits (Zbc)

**Syntax:** `clmulh rd, rs1, rs2`

**Operation:** `rd = clmul(rs1, rs2)[63:32]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## clmulr – Carry-less multiplication, bits 62 to 31 (Zbc)

**Syntax:** `clmulr rd, rs1, rs2`

**Operation:** `rd = clmul(rs1, rs2)[62:31]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## clz – Count of the leading zero bits (Zbb)

**Syntax:** `clz rd, rs1`

**Operation:** `rd = number of 0 bits above the highest 1 bit (32 for 0)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## clzw – Count of the leading zero bits of the low word

**Syntax:** `clzw rd, rs1`

Count of the leading zero bits of the low word (Zbb, RV64).

**Operation:** `rd = leading zeros of rs1[31:0] (32 for 0)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## cpop – Count of the set bits (Zbb)

**Syntax:** `cpop rd, rs1`

**Operation:** `rd = number of 1 bits in rs1`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## cpopw – Count of the set bits of the low word (Zbb, RV64)

**Syntax:** `cpopw rd, rs1`

**Operation:** `rd = number of 1 bits of rs1[31:0]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrc – Read of a control register and clearing of bits

**Syntax:** `csrrc rd, csr, rs1`

**Operation:** `t = csr; csr = t & ~rs1; rd = t`

Also shown as: `csrc`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrci – Read of a control register and clearing of the bits of a constant

**Syntax:** `csrrci rd, csr, uimm5`

**Operation:** `t = csr; csr = t & ~uimm5; rd = t`

Also shown as: `csrci`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrs – Read of a control register and setting of bits

**Syntax:** `csrrs rd, csr, rs1`

**Operation:** `t = csr; csr = t | rs1; rd = t`

Also shown as: `csrr`, `csrs`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrsi – Read of a control register and setting of the bits of a constant

**Syntax:** `csrrsi rd, csr, uimm5`

**Operation:** `t = csr; csr = t | uimm5; rd = t`

Also shown as: `csrsi`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrw – Exchange of a control register with a register

**Syntax:** `csrrw rd, csr, rs1`

**Operation:** `t = csr; csr = rs1; rd = t`

Also shown as: `csrw`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## csrrwi – Exchange of a control register with a constant

**Syntax:** `csrrwi rd, csr, uimm5`

Exchange of a control register with a constant (5 bit).

**Operation:** `rd = csr; csr = uimm5`

Also shown as: `csrwi`

*Group: Control and status registers (Zicsr). Short description from the instruction reference; there is no longer explanation for it yet.*

## ctz – Count of the trailing zero bits (Zbb)

**Syntax:** `ctz rd, rs1`

**Operation:** `rd = number of 0 bits below the lowest 1 bit (32 for 0)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## ctzw – Count of the trailing zero bits of the low word

**Syntax:** `ctzw rd, rs1`

Count of the trailing zero bits of the low word (Zbb, RV64).

**Operation:** `rd = trailing zeros of rs1[31:0] (32 for 0)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## div – Signed division (M)

**Syntax:** `div rd, rs1, rs2`

**Operation:** `rd = rs1 /s rs2 (by 0: -1)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## divu – Unsigned division (M)

**Syntax:** `divu rd, rs1, rs2`

**Operation:** `rd = rs1 /u rs2 (by 0: all ones)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## divuw – Unsigned division in 32 bits (M, RV64)

**Syntax:** `divuw rd, rs1, rs2`

**Operation:** `rd = sext(rs1[31:0] /u rs2[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## divw – Signed division in 32 bits (M, RV64)

**Syntax:** `divw rd, rs1, rs2`

**Operation:** `rd = sext(rs1[31:0] /s rs2[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## ebreak – Breakpoint for the debugger

**Syntax:** `ebreak`

**Operation:** `raise breakpoint exception (or enter debug mode)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ecall – Call of the environment (exception)

**Syntax:** `ecall`

**Operation:** `raise environment call exception`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## fence – Memory barrier

**Syntax:** `fence pred, succ`

Memory barrier: accesses of the kind pred before those of the kind succ.

**Operation:** `order memory accesses (i, o, r, w)`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## fence.i – Synchronisation of the instruction stream with code written before

**Syntax:** `fence.i`

Synchronisation of the instruction stream with code written before (Zifencei).

**Operation:** `later instruction fetches see earlier stores`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## jal – Jump and link (±1 MB)

**Syntax:** `jal rd, label`

**Operation:** `rd = pc + 4; pc = pc + sext(imm21)`

Also shown as: `j`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## jalr – Jump to the address in a register, and link

**Syntax:** `jalr rd, imm12(rs1)`

**Operation:** `t = rs1 + sext(imm12); rd = pc + 4; pc = t & ~1`

Also shown as: `jr`, `ret`

*Group: Branches and calls. Short description from the instruction reference; there is no longer explanation for it yet.*

## lb – Load of a byte, signed

**Syntax:** `lb rd, imm12(rs1)`

**Operation:** `rd = sext([rs1 + sext(imm12)]8)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lbu – Load of a byte, unsigned

**Syntax:** `lbu rd, imm12(rs1)`

**Operation:** `rd = zext([rs1 + sext(imm12)]8)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## ld – Load of a doubleword (64 bits; RV64)

**Syntax:** `ld rd, imm12(rs1)`

**Operation:** `rd = [rs1 + sext(imm12)]64`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lh – Load of a half word, signed

**Syntax:** `lh rd, imm12(rs1)`

**Operation:** `rd = sext([rs1 + sext(imm12)]16)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lhu – Load of a half word, unsigned

**Syntax:** `lhu rd, imm12(rs1)`

**Operation:** `rd = zext([rs1 + sext(imm12)]16)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lr.d – Load of a doubleword with a reservation (A, RV64)

**Syntax:** `lr.d rd, (rs1)`

**Operation:** `rd = [rs1]64; reserve [rs1]`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## lr.w – Load reserved (A)

**Syntax:** `lr.w rd, (rs1)`

**Operation:** `rd = [rs1]32; reserve the address`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## lui – Load of the upper 20 bits of a constant

**Syntax:** `lui rd, imm20`

**Operation:** `rd = imm20 << 12`

*Group: Constants and addresses. Short description from the instruction reference; there is no longer explanation for it yet.*

## lw – Load of a word (32 bit)

**Syntax:** `lw rd, imm12(rs1)`

**Operation:** `rd = [rs1 + sext(imm12)]32`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## lwu – Load of a word, unsigned (RV64)

**Syntax:** `lwu rd, imm12(rs1)`

**Operation:** `rd = zext([rs1 + sext(imm12)]32)`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## max – Signed maximum (Zbb)

**Syntax:** `max rd, rs1, rs2`

**Operation:** `rd = (rs1 >s rs2) ? rs1 : rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## maxu – Unsigned maximum (Zbb)

**Syntax:** `maxu rd, rs1, rs2`

**Operation:** `rd = (rs1 >u rs2) ? rs1 : rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## min – Signed minimum (Zbb)

**Syntax:** `min rd, rs1, rs2`

**Operation:** `rd = (rs1 <s rs2) ? rs1 : rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## minu – Unsigned minimum (Zbb)

**Syntax:** `minu rd, rs1, rs2`

**Operation:** `rd = (rs1 <u rs2) ? rs1 : rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## mret – Return from an exception in machine mode

**Syntax:** `mret`

**Operation:** `pc = mepc; restore the mode from mstatus`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## mul – Multiplication, low 32 bits (M)

**Syntax:** `mul rd, rs1, rs2`

**Operation:** `rd = (rs1 * rs2)[31:0]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulh – Signed multiplication, high 32 bits (M)

**Syntax:** `mulh rd, rs1, rs2`

**Operation:** `rd = (sext(rs1) * sext(rs2))[63:32]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulhsu – Signed by unsigned multiplication

**Syntax:** `mulhsu rd, rs1, rs2`

Signed by unsigned multiplication, high 32 bits (M).

**Operation:** `rd = (sext(rs1) * zext(rs2))[63:32]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulhu – Unsigned multiplication, high 32 bits (M)

**Syntax:** `mulhu rd, rs1, rs2`

**Operation:** `rd = (zext(rs1) * zext(rs2))[63:32]`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulw – Multiplication in 32 bits (M, RV64)

**Syntax:** `mulw rd, rs1, rs2`

**Operation:** `rd = sext((rs1 * rs2)[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## or – OR

**Syntax:** `or rd, rs1, rs2`

**Operation:** `rd = rs1 | rs2`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orc.b – Setting of every byte to 0x00 or 0xFF by whether one of its bits is set

**Syntax:** `orc.b rd, rs1`

Setting of every byte to 0x00 or 0xFF by whether one of its bits is set (Zbb).

**Operation:** `for every byte: rd.byte = (rs1.byte != 0) ? 0xFF : 0`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## ori – OR with a constant

**Syntax:** `ori rd, rs1, imm12`

**Operation:** `rd = rs1 | sext(imm12)`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orn – OR with an inverted operand (Zbb, Zbkb)

**Syntax:** `orn rd, rs1, rs2`

**Operation:** `rd = rs1 | ~rs2`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## pack – Packing of the low half words of two registers

**Syntax:** `pack rd, rs1, rs2`

Packing of the low half words of two registers (Zbkb).

**Operation:** `rd = (rs2[15:0] << 16) | rs1[15:0]`

Also shown as: `zext.h`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## packh – Packing of the low bytes of two registers (Zbkb)

**Syntax:** `packh rd, rs1, rs2`

**Operation:** `rd = (rs2[7:0] << 8) | rs1[7:0]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## packw – Two half words packed into a word (Zbkb, RV64)

**Syntax:** `packw rd, rs1, rs2`

**Operation:** `rd = sext(rs2[15:0] << 16 | rs1[15:0])`

Also shown as: `zext.h`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## rem – Remainder of the signed division (M)

**Syntax:** `rem rd, rs1, rs2`

**Operation:** `rd = rs1 %s rs2 (by 0: rs1)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## remu – Remainder of the unsigned division (M)

**Syntax:** `remu rd, rs1, rs2`

**Operation:** `rd = rs1 %u rs2 (by 0: rs1)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## remuw – Remainder of the unsigned division in 32 bits

**Syntax:** `remuw rd, rs1, rs2`

Remainder of the unsigned division in 32 bits (M, RV64).

**Operation:** `rd = sext(rs1[31:0] %u rs2[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## remw – Remainder of the signed division in 32 bits

**Syntax:** `remw rd, rs1, rs2`

Remainder of the signed division in 32 bits (M, RV64).

**Operation:** `rd = sext(rs1[31:0] %s rs2[31:0])`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## rev8 – Reversal of the order of the bytes (Zbb, Zbkb)

**Syntax:** `rev8 rd, rs1`

**Operation:** `rd = byte_reverse(rs1)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## rol – Rotate left by a register (Zbb, Zbkb)

**Syntax:** `rol rd, rs1, rs2`

**Operation:** `rd = rotate_left(rs1, rs2[4:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## rolw – Rotate left of the low word (Zbb, RV64)

**Syntax:** `rolw rd, rs1, rs2`

**Operation:** `rd = sext(rotate_left(rs1[31:0], rs2[4:0]))`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## ror – Rotate right by a register (Zbb, Zbkb)

**Syntax:** `ror rd, rs1, rs2`

**Operation:** `rd = rotate_right(rs1, rs2[4:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## rori – Rotate right by a constant (Zbb, Zbkb)

**Syntax:** `rori rd, rs1, shamt`

**Operation:** `rd = rotate_right(rs1, shamt)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## roriw – Rotate right of the low word by a constant

**Syntax:** `roriw rd, rs1, shamt`

Rotate right of the low word by a constant (Zbb, RV64).

**Operation:** `rd = sext(rotate_right(rs1[31:0], shamt))`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## rorw – Rotate right of the low word (Zbb, RV64)

**Syntax:** `rorw rd, rs1, rs2`

**Operation:** `rd = sext(rotate_right(rs1[31:0], rs2[4:0]))`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sb – Store of a byte

**Syntax:** `sb rs2, imm12(rs1)`

**Operation:** `[rs1 + sext(imm12)]8 = rs2[7:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sc.d – Store of a doubleword if the reservation still holds

**Syntax:** `sc.d rd, rs2, (rs1)`

Store of a doubleword if the reservation still holds (A, RV64).

**Operation:** `if reserved: [rs1]64 = rs2, rd = 0; else rd = 1`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## sc.w – Store conditional after lr.w (A)

**Syntax:** `sc.w rd, rs2, (rs1)`

**Operation:** `if reserved then [rs1]32 = rs2; rd = 0 else rd = 1`

*Group: Atomic memory operations (A). Short description from the instruction reference; there is no longer explanation for it yet.*

## sd – Store of a doubleword (64 bits; RV64)

**Syntax:** `sd rs2, imm12(rs1)`

**Operation:** `[rs1 + sext(imm12)]64 = rs2`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sext.b – Sign extension of a byte (Zbb)

**Syntax:** `sext.b rd, rs1`

**Operation:** `rd = sext(rs1[7:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sext.h – Sign extension of a half word (Zbb)

**Syntax:** `sext.h rd, rs1`

**Operation:** `rd = sext(rs1[15:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh – Store of a half word

**Syntax:** `sh rs2, imm12(rs1)`

**Operation:** `[rs1 + sext(imm12)]16 = rs2[15:0]`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## sh1add – Addition with a register shifted by 1 (Zba)

**Syntax:** `sh1add rd, rs1, rs2`

**Operation:** `rd = rs2 + (rs1 << 1)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh1add.uw – Addition of the low word shifted by 1 (Zba, RV64)

**Syntax:** `sh1add.uw rd, rs1, rs2`

**Operation:** `rd = rs2 + (zext(rs1[31:0]) << 1)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh2add – Addition with a register shifted by 2 (Zba)

**Syntax:** `sh2add rd, rs1, rs2`

**Operation:** `rd = rs2 + (rs1 << 2)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh2add.uw – Addition of the low word shifted by 2 (Zba, RV64)

**Syntax:** `sh2add.uw rd, rs1, rs2`

**Operation:** `rd = rs2 + (zext(rs1[31:0]) << 2)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh3add – Addition with a register shifted by 3 (Zba)

**Syntax:** `sh3add rd, rs1, rs2`

**Operation:** `rd = rs2 + (rs1 << 3)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sh3add.uw – Addition of the low word shifted by 3 (Zba, RV64)

**Syntax:** `sh3add.uw rd, rs1, rs2`

**Operation:** `rd = rs2 + (zext(rs1[31:0]) << 3)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## sll – Shift left by a register

**Syntax:** `sll rd, rs1, rs2`

**Operation:** `rd = rs1 << rs2[4:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## slli – Shift left by a constant

**Syntax:** `slli rd, rs1, shamt` &nbsp; `slli rd, rs1, shamt6`

**Operation:** `rd = rs1 << shamt`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## slli.uw – Shift left of the low word, unsigned (Zba, RV64)

**Syntax:** `slli.uw rd, rs1, shamt6`

**Operation:** `rd = zext(rs1[31:0]) << shamt6`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## slliw – Shift left in 32 bits (RV64)

**Syntax:** `slliw rd, rs1, shamt`

**Operation:** `rd = sext((rs1 << shamt)[31:0])`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sllw – Shift left by a register in 32 bits (RV64)

**Syntax:** `sllw rd, rs1, rs2`

**Operation:** `rd = sext((rs1 << rs2[4:0])[31:0])`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## slt – Signed comparison: 1 if less

**Syntax:** `slt rd, rs1, rs2`

**Operation:** `rd = (rs1 <s rs2) ? 1 : 0`

Also shown as: `sltz`, `sgtz`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## slti – Signed comparison with a constant: 1 if less

**Syntax:** `slti rd, rs1, imm12`

**Operation:** `rd = (rs1 <s sext(imm12)) ? 1 : 0`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## sltiu – Unsigned comparison with a constant: 1 if less

**Syntax:** `sltiu rd, rs1, imm12`

**Operation:** `rd = (rs1 <u sext(imm12)) ? 1 : 0`

Also shown as: `seqz`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## sltu – Unsigned comparison: 1 if less

**Syntax:** `sltu rd, rs1, rs2`

**Operation:** `rd = (rs1 <u rs2) ? 1 : 0`

Also shown as: `snez`

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## sra – Shift right signed by a register

**Syntax:** `sra rd, rs1, rs2`

**Operation:** `rd = rs1 >>s rs2[4:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srai – Shift right signed by a constant

**Syntax:** `srai rd, rs1, shamt` &nbsp; `srai rd, rs1, shamt6`

**Operation:** `rd = rs1 >>s shamt`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sraiw – Shift right signed in 32 bits (RV64)

**Syntax:** `sraiw rd, rs1, shamt`

**Operation:** `rd = sext(rs1[31:0] >>s shamt)`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sraw – Shift right signed by a register in 32 bits (RV64)

**Syntax:** `sraw rd, rs1, rs2`

**Operation:** `rd = sext(rs1[31:0] >>s rs2[4:0])`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sret – Return from an exception in supervisor mode

**Syntax:** `sret`

**Operation:** `pc = sepc; restore the mode from sstatus`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## srl – Shift right unsigned by a register

**Syntax:** `srl rd, rs1, rs2`

**Operation:** `rd = rs1 >>u rs2[4:0]`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srli – Shift right unsigned by a constant

**Syntax:** `srli rd, rs1, shamt` &nbsp; `srli rd, rs1, shamt6`

**Operation:** `rd = rs1 >>u shamt`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srliw – Shift right unsigned in 32 bits (RV64)

**Syntax:** `srliw rd, rs1, shamt`

**Operation:** `rd = sext(rs1[31:0] >>u shamt)`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## srlw – Shift right unsigned by a register in 32 bits

**Syntax:** `srlw rd, rs1, rs2`

Shift right unsigned by a register in 32 bits (RV64).

**Operation:** `rd = sext(rs1[31:0] >>u rs2[4:0])`

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sub – Subtraction of two registers

**Syntax:** `sub rd, rs1, rs2`

**Operation:** `rd = rs1 - rs2`

Also shown as: `neg`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subw – Subtraction in 32 bits (RV64)

**Syntax:** `subw rd, rs1, rs2`

**Operation:** `rd = sext((rs1 - rs2)[31:0])`

Also shown as: `negw`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sw – Store of a word

**Syntax:** `sw rs2, imm12(rs1)`

**Operation:** `[rs1 + sext(imm12)]32 = rs2`

*Group: Loads and stores. Short description from the instruction reference; there is no longer explanation for it yet.*

## unzip – Deinterleaving into even and odd bits (Zbkb)

**Syntax:** `unzip rd, rs1`

**Operation:** `rd[i] = rs1[2i]; rd[i+16] = rs1[2i+1]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## wfi – Wait for an interrupt

**Syntax:** `wfi`

**Operation:** `pause until an interrupt is pending`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xnor – Inverted exclusive OR (Zbb, Zbkb)

**Syntax:** `xnor rd, rs1, rs2`

**Operation:** `rd = ~(rs1 ^ rs2)`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## xor – Exclusive OR

**Syntax:** `xor rd, rs1, rs2`

**Operation:** `rd = rs1 ^ rs2`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## xori – Exclusive OR with a constant

**Syntax:** `xori rd, rs1, imm12`

**Operation:** `rd = rs1 ^ sext(imm12)`

Also shown as: `not`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## zext.h – Zero extension of a half word (Zbb)

**Syntax:** `zext.h rd, rs1`

**Operation:** `rd = zext(rs1[15:0])`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*

## zip – Interleaving of the bits of the two half words

**Syntax:** `zip rd, rs1`

Interleaving of the bits of the two half words (Zbkb).

**Operation:** `rd[2i] = rs1[i]; rd[2i+1] = rs1[i+16]`

*Group: Bit manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Short description from the instruction reference; there is no longer explanation for it yet.*
