# Befehle aus der Befehlsreferenz (erzeugt)

Erzeugt von tools/gen_help_ref.py aus den Tabellen des Assemblers (tools/instr), nicht von Hand ändern. F1 zeigt einen Abschnitt von hier, wenn die Hilfe der Architektur keinen eigenen hat.

## add – Addition zweier Register

**Syntax:** `add rd, rs1, rs2`

**Wirkung:** `rd = rs1 + rs2`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add.uw – Addition des unteren Worts ohne Vorzeichen

**Syntax:** `add.uw rd, rs1, rs2`

Addition des unteren Worts ohne Vorzeichen (Zba, RV64).

**Wirkung:** `rd = rs2 + zext(rs1[31:0])`

Auch angezeigt als: `zext.w`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addi – Addition einer Konstanten (12 Bit mit Vorzeichen)

**Syntax:** `addi rd, rs1, imm12`

**Wirkung:** `rd = rs1 + sext(imm12)`

Auch angezeigt als: `li`, `mv`, `nop`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addiw – Addition einer Konstanten mit 32 Bit

**Syntax:** `addiw rd, rs1, imm12`

Addition einer Konstanten mit 32 Bit, Ergebnis mit Vorzeichen auf 64 Bit (RV64).

**Wirkung:** `rd = sext((rs1 + sext(imm12))[31:0])`

Auch angezeigt als: `sext.w`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addw – Addition mit 32 Bit

**Syntax:** `addw rd, rs1, rs2`

Addition mit 32 Bit, Ergebnis mit Vorzeichen auf 64 Bit (RV64).

**Wirkung:** `rd = sext((rs1 + rs2)[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoadd.d – Atomare Addition auf einem Doppelwort (A, RV64)

**Syntax:** `amoadd.d rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]64; [rs1]64 = rd + rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoadd.w – Atomare Addition (A)

**Syntax:** `amoadd.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = rd + rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoand.d – Atomares UND auf einem Doppelwort (A, RV64)

**Syntax:** `amoand.d rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]64; [rs1]64 = rd & rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoand.w – Atomares UND (A)

**Syntax:** `amoand.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = rd & rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomax.d – Atomares Maximum mit Vorzeichen auf einem Doppelwort

**Syntax:** `amomax.d rd, rs2, (rs1)`

Atomares Maximum mit Vorzeichen auf einem Doppelwort (A, RV64).

**Wirkung:** `rd = [rs1]64; [rs1]64 = max_s(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomax.w – Atomares Maximum mit Vorzeichen (A)

**Syntax:** `amomax.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = max_s(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomaxu.d – Atomares Maximum ohne Vorzeichen auf einem Doppelwort

**Syntax:** `amomaxu.d rd, rs2, (rs1)`

Atomares Maximum ohne Vorzeichen auf einem Doppelwort (A, RV64).

**Wirkung:** `rd = [rs1]64; [rs1]64 = max_u(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomaxu.w – Atomares Maximum ohne Vorzeichen (A)

**Syntax:** `amomaxu.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = max_u(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomin.d – Atomares Minimum mit Vorzeichen auf einem Doppelwort

**Syntax:** `amomin.d rd, rs2, (rs1)`

Atomares Minimum mit Vorzeichen auf einem Doppelwort (A, RV64).

**Wirkung:** `rd = [rs1]64; [rs1]64 = min_s(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amomin.w – Atomares Minimum mit Vorzeichen (A)

**Syntax:** `amomin.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = min_s(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amominu.d – Atomares Minimum ohne Vorzeichen auf einem Doppelwort

**Syntax:** `amominu.d rd, rs2, (rs1)`

Atomares Minimum ohne Vorzeichen auf einem Doppelwort (A, RV64).

**Wirkung:** `rd = [rs1]64; [rs1]64 = min_u(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amominu.w – Atomares Minimum ohne Vorzeichen (A)

**Syntax:** `amominu.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = min_u(rd, rs2)`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoor.d – Atomares ODER auf einem Doppelwort (A, RV64)

**Syntax:** `amoor.d rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]64; [rs1]64 = rd | rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoor.w – Atomares ODER (A)

**Syntax:** `amoor.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = rd | rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoswap.d – Atomarer Tausch eines Doppelworts (A, RV64)

**Syntax:** `amoswap.d rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]64; [rs1]64 = rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoswap.w – Atomarer Austausch (A)

**Syntax:** `amoswap.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoxor.d – Atomares exklusives ODER auf einem Doppelwort

**Syntax:** `amoxor.d rd, rs2, (rs1)`

Atomares exklusives ODER auf einem Doppelwort (A, RV64).

**Wirkung:** `rd = [rs1]64; [rs1]64 = rd ^ rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## amoxor.w – Atomares exklusives ODER (A)

**Syntax:** `amoxor.w rd, rs2, (rs1)`

**Wirkung:** `rd = [rs1]; [rs1] = rd ^ rs2`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## and – UND

**Syntax:** `and rd, rs1, rs2`

**Wirkung:** `rd = rs1 & rs2`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andi – UND mit einer Konstanten

**Syntax:** `andi rd, rs1, imm12`

**Wirkung:** `rd = rs1 & sext(imm12)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andn – UND mit invertiertem Operanden (Zbb, Zbkb)

**Syntax:** `andn rd, rs1, rs2`

**Wirkung:** `rd = rs1 & ~rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## auipc – Addition der oberen 20 Bit zum pc

**Syntax:** `auipc rd, imm20`

Addition der oberen 20 Bit zum pc (Adresse relativ zum Befehl).

**Wirkung:** `rd = pc + (imm20 << 12)`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bclr – Löschen eines Bits (Zbs)

**Syntax:** `bclr rd, rs1, rs2`

**Wirkung:** `rd = rs1 & ~(1 << rs2[4:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bclri – Löschen eines Bits, Nummer als Konstante (Zbs)

**Syntax:** `bclri rd, rs1, shamt`

**Wirkung:** `rd = rs1 & ~(1 << shamt)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## beq – Verzweigung, wenn gleich

**Syntax:** `beq rs1, rs2, label`

**Wirkung:** `if rs1 == rs2 then pc = pc + sext(imm13)`

Auch angezeigt als: `beqz`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bext – Auslesen eines Bits (Zbs)

**Syntax:** `bext rd, rs1, rs2`

**Wirkung:** `rd = (rs1 >> rs2[4:0]) & 1`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bexti – Auslesen eines Bits, Nummer als Konstante (Zbs)

**Syntax:** `bexti rd, rs1, shamt`

**Wirkung:** `rd = (rs1 >> shamt) & 1`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bge – Verzweigung

**Syntax:** `bge rs1, rs2, label`

Verzweigung, wenn größer oder gleich (mit Vorzeichen).

**Wirkung:** `if rs1 >=s rs2 then pc = pc + sext(imm13)`

Auch angezeigt als: `bgez`, `blez`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bgeu – Verzweigung

**Syntax:** `bgeu rs1, rs2, label`

Verzweigung, wenn größer oder gleich (ohne Vorzeichen).

**Wirkung:** `if rs1 >=u rs2 then pc = pc + sext(imm13)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## binv – Umkehren eines Bits (Zbs)

**Syntax:** `binv rd, rs1, rs2`

**Wirkung:** `rd = rs1 ^ (1 << rs2[4:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## binvi – Umkehren eines Bits, Nummer als Konstante (Zbs)

**Syntax:** `binvi rd, rs1, shamt`

**Wirkung:** `rd = rs1 ^ (1 << shamt)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blt – Verzweigung, wenn kleiner (mit Vorzeichen)

**Syntax:** `blt rs1, rs2, label`

**Wirkung:** `if rs1 <s rs2 then pc = pc + sext(imm13)`

Auch angezeigt als: `bltz`, `bgtz`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bltu – Verzweigung, wenn kleiner (ohne Vorzeichen)

**Syntax:** `bltu rs1, rs2, label`

**Wirkung:** `if rs1 <u rs2 then pc = pc + sext(imm13)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bne – Verzweigung, wenn ungleich

**Syntax:** `bne rs1, rs2, label`

**Wirkung:** `if rs1 != rs2 then pc = pc + sext(imm13)`

Auch angezeigt als: `bnez`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## brev8 – Umkehrung der Bits in jedem Byte (Zbkb)

**Syntax:** `brev8 rd, rs1`

**Wirkung:** `for every byte: rd.byte = bit_reverse(rs1.byte)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bset – Setzen eines Bits (Zbs)

**Syntax:** `bset rd, rs1, rs2`

**Wirkung:** `rd = rs1 | (1 << rs2[4:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bseti – Setzen eines Bits, Nummer als Konstante (Zbs)

**Syntax:** `bseti rd, rs1, shamt`

**Wirkung:** `rd = rs1 | (1 << shamt)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.add – Addition zweier Register

**Syntax:** `c.add rd, rs2`

**Wirkung:** `rd = rd + rs2 (rs2 != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.addi – Addition einer Konstanten (6 Bit mit Vorzeichen)

**Syntax:** `c.addi rd, imm6`

**Wirkung:** `rd = rd + sext(imm6)`

Auch angezeigt als: `c.nop`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.addi16sp – Addition eines Vielfachen von 16 zum sp

**Syntax:** `c.addi16sp sp, imm`

**Wirkung:** `sp = sp + sext(imm10) (imm != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.addi4spn – Addition einer Konstanten zum sp

**Syntax:** `c.addi4spn rd', sp, uimm`

Addition einer Konstanten zum sp (Adresse auf dem Stack).

**Wirkung:** `rd' = sp + zext(uimm) (uimm != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.addiw – Addition einer Konstanten mit 32 Bit (RV64)

**Syntax:** `c.addiw rd, imm6`

**Wirkung:** `rd = sext((rd + sext(imm6))[31:0]) (rd != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.addw – Addition mit 32 Bit (RV64)

**Syntax:** `c.addw rd', rs2'`

**Wirkung:** `rd' = sext((rd' + rs2')[31:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.and – UND

**Syntax:** `c.and rd', rs2'`

**Wirkung:** `rd' = rd' & rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.andi – UND mit einer Konstanten (6 Bit mit Vorzeichen)

**Syntax:** `c.andi rd', imm6`

**Wirkung:** `rd' = rd' & sext(imm6)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.beqz – Verzweigung, wenn 0

**Syntax:** `c.beqz rs1', label`

**Wirkung:** `if rs1' == 0 then pc = pc + sext(imm9)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.bnez – Verzweigung, wenn nicht 0

**Syntax:** `c.bnez rs1', label`

**Wirkung:** `if rs1' != 0 then pc = pc + sext(imm9)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.ebreak – Haltepunkt für den Debugger

**Syntax:** `c.ebreak`

**Wirkung:** `raise breakpoint exception (or enter debug mode)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.j – Sprung (±2 KB)

**Syntax:** `c.j label`

**Wirkung:** `pc = pc + sext(imm12)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.jal – Sprung mit Rücksprungadresse in ra (±2 KB)

**Syntax:** `c.jal label`

**Wirkung:** `ra = pc + 2; pc = pc + sext(imm12)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.jalr – Sprung an die Adresse in einem Register

**Syntax:** `c.jalr rs1`

Sprung an die Adresse in einem Register, mit Rücksprungadresse in ra.

**Wirkung:** `t = rs1; ra = pc + 2; pc = t`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.jr – Sprung an die Adresse in einem Register

**Syntax:** `c.jr rs1`

**Wirkung:** `pc = rs1 (rs1 != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lbu – Laden eines Bytes ohne Vorzeichen (Zcb)

**Syntax:** `c.lbu rd', uimm(rs1')`

**Wirkung:** `rd' = zext([rs1' + uimm]8)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.ld – Laden eines Doppelworts (RV64)

**Syntax:** `c.ld rd', uimm(rs1')`

**Wirkung:** `rd' = [rs1' + zext(uimm)]64`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.ldsp – Laden eines Doppelworts vom Stack (RV64)

**Syntax:** `c.ldsp rd, uimm(sp)`

**Wirkung:** `rd = [sp + zext(uimm)]64 (rd != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lh – Laden eines Halbworts mit Vorzeichen (Zcb)

**Syntax:** `c.lh rd', uimm(rs1')`

**Wirkung:** `rd' = sext([rs1' + uimm]16)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lhu – Laden eines Halbworts ohne Vorzeichen (Zcb)

**Syntax:** `c.lhu rd', uimm(rs1')`

**Wirkung:** `rd' = zext([rs1' + uimm]16)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.li – Laden einer Konstanten (6 Bit mit Vorzeichen)

**Syntax:** `c.li rd, imm6`

**Wirkung:** `rd = sext(imm6)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lui – Laden der Bits 17 bis 12 einer Konstanten

**Syntax:** `c.lui rd, imm6`

**Wirkung:** `rd = sext(imm6 << 12) (rd != 0, 2)`

Auch angezeigt als: `c.addi16sp`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lw – Laden eines Worts

**Syntax:** `c.lw rd', uimm(rs1')`

**Wirkung:** `rd' = [rs1' + zext(uimm)]32`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.lwsp – Laden eines Worts vom Stack

**Syntax:** `c.lwsp rd, uimm(sp)`

**Wirkung:** `rd = [sp + zext(uimm)]32 (rd != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.mul – Multiplikation, untere 32 Bit (Zcb)

**Syntax:** `c.mul rd', rs2'`

**Wirkung:** `rd' = (rd' * rs2')[31:0]`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.mv – Kopieren eines Registers

**Syntax:** `c.mv rd, rs2`

**Wirkung:** `rd = rs2 (rs2 != 0)`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.not – Bitweise Umkehrung (Zcb)

**Syntax:** `c.not rd'`

**Wirkung:** `rd' = ~rd'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.or – ODER

**Syntax:** `c.or rd', rs2'`

**Wirkung:** `rd' = rd' | rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sb – Speichern eines Bytes (Zcb)

**Syntax:** `c.sb rs2', uimm(rs1')`

**Wirkung:** `[rs1' + uimm]8 = rs2'[7:0]`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sd – Speichern eines Doppelworts (RV64)

**Syntax:** `c.sd rs2', uimm(rs1')`

**Wirkung:** `[rs1' + zext(uimm)]64 = rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sdsp – Speichern eines Doppelworts auf dem Stack (RV64)

**Syntax:** `c.sdsp rs2, uimm(sp)`

**Wirkung:** `[sp + zext(uimm)]64 = rs2`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sext.b – Erweiterung eines Bytes mit Vorzeichen (Zcb)

**Syntax:** `c.sext.b rd'`

**Wirkung:** `rd' = sext(rd'[7:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sext.h – Erweiterung eines Halbworts mit Vorzeichen (Zcb)

**Syntax:** `c.sext.h rd'`

**Wirkung:** `rd' = sext(rd'[15:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sh – Speichern eines Halbworts (Zcb)

**Syntax:** `c.sh rs2', uimm(rs1')`

**Wirkung:** `[rs1' + uimm]16 = rs2'[15:0]`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.slli – Schieben nach links um eine Konstante

**Syntax:** `c.slli rd, shamt`

**Wirkung:** `rd = rd << shamt`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.srai – Schieben nach rechts mit Vorzeichen um eine Konstante

**Syntax:** `c.srai rd', shamt`

**Wirkung:** `rd' = rd' >>s shamt`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.srli – Schieben nach rechts ohne Vorzeichen um eine Konstante

**Syntax:** `c.srli rd', shamt`

**Wirkung:** `rd' = rd' >>u shamt`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sub – Subtraktion

**Syntax:** `c.sub rd', rs2'`

**Wirkung:** `rd' = rd' - rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.subw – Subtraktion mit 32 Bit (RV64)

**Syntax:** `c.subw rd', rs2'`

**Wirkung:** `rd' = sext((rd' - rs2')[31:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.sw – Speichern eines Worts

**Syntax:** `c.sw rs2', uimm(rs1')`

**Wirkung:** `[rs1' + zext(uimm)]32 = rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.swsp – Speichern eines Worts auf dem Stack

**Syntax:** `c.swsp rs2, uimm(sp)`

**Wirkung:** `[sp + zext(uimm)]32 = rs2`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.xor – Exklusives ODER

**Syntax:** `c.xor rd', rs2'`

**Wirkung:** `rd' = rd' ^ rs2'`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.zext.b – Erweiterung eines Bytes mit Nullen (Zcb)

**Syntax:** `c.zext.b rd'`

**Wirkung:** `rd' = zext(rd'[7:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.zext.h – Erweiterung eines Halbworts mit Nullen (Zcb)

**Syntax:** `c.zext.h rd'`

**Wirkung:** `rd' = zext(rd'[15:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## c.zext.w – Unteres Wort ohne Vorzeichen auf 64 Bit

**Syntax:** `c.zext.w rd'`

Unteres Wort ohne Vorzeichen auf 64 Bit (Zcb, RV64).

**Wirkung:** `rd' = zext(rd'[31:0])`

*Gruppe: Komprimierte Befehle (C, Zcb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clmul – Multiplikation ohne Übertrag, untere 32 Bit (Zbc)

**Syntax:** `clmul rd, rs1, rs2`

**Wirkung:** `rd = clmul(rs1, rs2)[31:0]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clmulh – Multiplikation ohne Übertrag, obere 32 Bit (Zbc)

**Syntax:** `clmulh rd, rs1, rs2`

**Wirkung:** `rd = clmul(rs1, rs2)[63:32]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clmulr – Multiplikation ohne Übertrag, Bits 62 bis 31 (Zbc)

**Syntax:** `clmulr rd, rs1, rs2`

**Wirkung:** `rd = clmul(rs1, rs2)[62:31]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clz – Zählen der führenden Nullbits (Zbb)

**Syntax:** `clz rd, rs1`

**Wirkung:** `rd = number of 0 bits above the highest 1 bit (32 for 0)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clzw – Zählen der führenden Nullbits des unteren Worts

**Syntax:** `clzw rd, rs1`

Zählen der führenden Nullbits des unteren Worts (Zbb, RV64).

**Wirkung:** `rd = leading zeros of rs1[31:0] (32 for 0)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpop – Zählen der gesetzten Bits (Zbb)

**Syntax:** `cpop rd, rs1`

**Wirkung:** `rd = number of 1 bits in rs1`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpopw – Zählen der gesetzten Bits im unteren Wort

**Syntax:** `cpopw rd, rs1`

Zählen der gesetzten Bits im unteren Wort (Zbb, RV64).

**Wirkung:** `rd = number of 1 bits of rs1[31:0]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrc – Lesen eines Steuerregisters und Löschen von Bits

**Syntax:** `csrrc rd, csr, rs1`

**Wirkung:** `t = csr; csr = t & ~rs1; rd = t`

Auch angezeigt als: `csrc`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrci – Lesen eines Steuerregisters und Löschen von Bits einer Konstanten

**Syntax:** `csrrci rd, csr, uimm5`

**Wirkung:** `t = csr; csr = t & ~uimm5; rd = t`

Auch angezeigt als: `csrci`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrs – Lesen eines Steuerregisters und Setzen von Bits

**Syntax:** `csrrs rd, csr, rs1`

**Wirkung:** `t = csr; csr = t | rs1; rd = t`

Auch angezeigt als: `csrr`, `csrs`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrsi – Lesen eines Steuerregisters und Setzen von Bits einer Konstanten

**Syntax:** `csrrsi rd, csr, uimm5`

**Wirkung:** `t = csr; csr = t | uimm5; rd = t`

Auch angezeigt als: `csrsi`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrw – Austausch eines Steuerregisters mit einem Register

**Syntax:** `csrrw rd, csr, rs1`

**Wirkung:** `t = csr; csr = rs1; rd = t`

Auch angezeigt als: `csrw`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csrrwi – Austausch eines Steuerregisters mit einer Konstanten

**Syntax:** `csrrwi rd, csr, uimm5`

Austausch eines Steuerregisters mit einer Konstanten (5 Bit).

**Wirkung:** `rd = csr; csr = uimm5`

Auch angezeigt als: `csrwi`

*Gruppe: Steuer- und Statusregister (Zicsr). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ctz – Zählen der Nullbits am Ende (Zbb)

**Syntax:** `ctz rd, rs1`

**Wirkung:** `rd = number of 0 bits below the lowest 1 bit (32 for 0)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ctzw – Zählen der Nullbits unten im unteren Wort

**Syntax:** `ctzw rd, rs1`

Zählen der Nullbits unten im unteren Wort (Zbb, RV64).

**Wirkung:** `rd = trailing zeros of rs1[31:0] (32 for 0)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## div – Division mit Vorzeichen (M)

**Syntax:** `div rd, rs1, rs2`

**Wirkung:** `rd = rs1 /s rs2 (by 0: -1)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divu – Division ohne Vorzeichen (M)

**Syntax:** `divu rd, rs1, rs2`

**Wirkung:** `rd = rs1 /u rs2 (by 0: all ones)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divuw – Division ohne Vorzeichen mit 32 Bit (M, RV64)

**Syntax:** `divuw rd, rs1, rs2`

**Wirkung:** `rd = sext(rs1[31:0] /u rs2[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divw – Division mit Vorzeichen mit 32 Bit (M, RV64)

**Syntax:** `divw rd, rs1, rs2`

**Wirkung:** `rd = sext(rs1[31:0] /s rs2[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ebreak – Haltepunkt für den Debugger

**Syntax:** `ebreak`

**Wirkung:** `raise breakpoint exception (or enter debug mode)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ecall – Aufruf der Umgebung (Ausnahme)

**Syntax:** `ecall`

**Wirkung:** `raise environment call exception`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fence – Speicherbarriere

**Syntax:** `fence pred, succ`

Speicherbarriere: Zugriffe der Art pred vor denen der Art succ.

**Wirkung:** `order memory accesses (i, o, r, w)`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fence.i – Synchronisation des Befehlsstroms mit geschriebenem Code

**Syntax:** `fence.i`

Synchronisation des Befehlsstroms mit geschriebenem Code (Zifencei).

**Wirkung:** `later instruction fetches see earlier stores`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jal – Sprung mit Rücksprungadresse (±1 MB)

**Syntax:** `jal rd, label`

**Wirkung:** `rd = pc + 4; pc = pc + sext(imm21)`

Auch angezeigt als: `j`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jalr – Sprung an die Adresse in einem Register

**Syntax:** `jalr rd, imm12(rs1)`

Sprung an die Adresse in einem Register, mit Rücksprungadresse.

**Wirkung:** `t = rs1 + sext(imm12); rd = pc + 4; pc = t & ~1`

Auch angezeigt als: `jr`, `ret`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lb – Laden eines Bytes mit Vorzeichen

**Syntax:** `lb rd, imm12(rs1)`

**Wirkung:** `rd = sext([rs1 + sext(imm12)]8)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lbu – Laden eines Bytes ohne Vorzeichen

**Syntax:** `lbu rd, imm12(rs1)`

**Wirkung:** `rd = zext([rs1 + sext(imm12)]8)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld – Laden eines Doppelworts (64 Bit; RV64)

**Syntax:** `ld rd, imm12(rs1)`

**Wirkung:** `rd = [rs1 + sext(imm12)]64`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lh – Laden eines Halbworts mit Vorzeichen

**Syntax:** `lh rd, imm12(rs1)`

**Wirkung:** `rd = sext([rs1 + sext(imm12)]16)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lhu – Laden eines Halbworts ohne Vorzeichen

**Syntax:** `lhu rd, imm12(rs1)`

**Wirkung:** `rd = zext([rs1 + sext(imm12)]16)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lr.d – Laden eines Doppelworts mit Reservierung (A, RV64)

**Syntax:** `lr.d rd, (rs1)`

**Wirkung:** `rd = [rs1]64; reserve [rs1]`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lr.w – Laden mit Reservierung (A)

**Syntax:** `lr.w rd, (rs1)`

**Wirkung:** `rd = [rs1]32; reserve the address`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lui – Laden der oberen 20 Bit einer Konstanten

**Syntax:** `lui rd, imm20`

**Wirkung:** `rd = imm20 << 12`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lw – Laden eines Worts (32 Bit)

**Syntax:** `lw rd, imm12(rs1)`

**Wirkung:** `rd = [rs1 + sext(imm12)]32`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lwu – Laden eines Worts ohne Vorzeichen (RV64)

**Syntax:** `lwu rd, imm12(rs1)`

**Wirkung:** `rd = zext([rs1 + sext(imm12)]32)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## max – Maximum mit Vorzeichen (Zbb)

**Syntax:** `max rd, rs1, rs2`

**Wirkung:** `rd = (rs1 >s rs2) ? rs1 : rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxu – Maximum ohne Vorzeichen (Zbb)

**Syntax:** `maxu rd, rs1, rs2`

**Wirkung:** `rd = (rs1 >u rs2) ? rs1 : rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## min – Minimum mit Vorzeichen (Zbb)

**Syntax:** `min rd, rs1, rs2`

**Wirkung:** `rd = (rs1 <s rs2) ? rs1 : rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minu – Minimum ohne Vorzeichen (Zbb)

**Syntax:** `minu rd, rs1, rs2`

**Wirkung:** `rd = (rs1 <u rs2) ? rs1 : rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mret – Rückkehr aus einer Ausnahme im Machine Mode

**Syntax:** `mret`

**Wirkung:** `pc = mepc; restore the mode from mstatus`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul – Multiplikation, untere 32 Bit (M)

**Syntax:** `mul rd, rs1, rs2`

**Wirkung:** `rd = (rs1 * rs2)[31:0]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulh – Multiplikation mit Vorzeichen, obere 32 Bit (M)

**Syntax:** `mulh rd, rs1, rs2`

**Wirkung:** `rd = (sext(rs1) * sext(rs2))[63:32]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulhsu – Multiplikation mit und ohne Vorzeichen

**Syntax:** `mulhsu rd, rs1, rs2`

Multiplikation mit und ohne Vorzeichen, obere 32 Bit (M).

**Wirkung:** `rd = (sext(rs1) * zext(rs2))[63:32]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulhu – Multiplikation ohne Vorzeichen, obere 32 Bit (M)

**Syntax:** `mulhu rd, rs1, rs2`

**Wirkung:** `rd = (zext(rs1) * zext(rs2))[63:32]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulw – Multiplikation mit 32 Bit (M, RV64)

**Syntax:** `mulw rd, rs1, rs2`

**Wirkung:** `rd = sext((rs1 * rs2)[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## or – ODER

**Syntax:** `or rd, rs1, rs2`

**Wirkung:** `rd = rs1 | rs2`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orc.b – Bytes auf 0x00 oder 0xFF setzen

**Syntax:** `orc.b rd, rs1`

Bytes auf 0x00 oder 0xFF setzen, je nachdem, ob ein Bit gesetzt ist (Zbb).

**Wirkung:** `for every byte: rd.byte = (rs1.byte != 0) ? 0xFF : 0`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ori – ODER mit einer Konstanten

**Syntax:** `ori rd, rs1, imm12`

**Wirkung:** `rd = rs1 | sext(imm12)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orn – ODER mit invertiertem Operanden (Zbb, Zbkb)

**Syntax:** `orn rd, rs1, rs2`

**Wirkung:** `rd = rs1 | ~rs2`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pack – Zusammensetzen der unteren Halbwörter zweier Register

**Syntax:** `pack rd, rs1, rs2`

Zusammensetzen der unteren Halbwörter zweier Register (Zbkb).

**Wirkung:** `rd = (rs2[15:0] << 16) | rs1[15:0]`

Auch angezeigt als: `zext.h`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packh – Zusammensetzen der unteren Bytes zweier Register

**Syntax:** `packh rd, rs1, rs2`

Zusammensetzen der unteren Bytes zweier Register (Zbkb).

**Wirkung:** `rd = (rs2[7:0] << 8) | rs1[7:0]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packw – Zwei Halbwörter zu einem Wort zusammensetzen

**Syntax:** `packw rd, rs1, rs2`

Zwei Halbwörter zu einem Wort zusammensetzen (Zbkb, RV64).

**Wirkung:** `rd = sext(rs2[15:0] << 16 | rs1[15:0])`

Auch angezeigt als: `zext.h`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rem – Rest der Division mit Vorzeichen (M)

**Syntax:** `rem rd, rs1, rs2`

**Wirkung:** `rd = rs1 %s rs2 (by 0: rs1)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## remu – Rest der Division ohne Vorzeichen (M)

**Syntax:** `remu rd, rs1, rs2`

**Wirkung:** `rd = rs1 %u rs2 (by 0: rs1)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## remuw – Rest der Division ohne Vorzeichen mit 32 Bit

**Syntax:** `remuw rd, rs1, rs2`

Rest der Division ohne Vorzeichen mit 32 Bit (M, RV64).

**Wirkung:** `rd = sext(rs1[31:0] %u rs2[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## remw – Rest der Division mit Vorzeichen mit 32 Bit

**Syntax:** `remw rd, rs1, rs2`

Rest der Division mit Vorzeichen mit 32 Bit (M, RV64).

**Wirkung:** `rd = sext(rs1[31:0] %s rs2[31:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev8 – Umkehrung der Reihenfolge der Bytes (Zbb, Zbkb)

**Syntax:** `rev8 rd, rs1`

**Wirkung:** `rd = byte_reverse(rs1)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rol – Rotation nach links um ein Register (Zbb, Zbkb)

**Syntax:** `rol rd, rs1, rs2`

**Wirkung:** `rd = rotate_left(rs1, rs2[4:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rolw – Rotation des unteren Worts nach links (Zbb, RV64)

**Syntax:** `rolw rd, rs1, rs2`

**Wirkung:** `rd = sext(rotate_left(rs1[31:0], rs2[4:0]))`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ror – Rotation nach rechts um ein Register (Zbb, Zbkb)

**Syntax:** `ror rd, rs1, rs2`

**Wirkung:** `rd = rotate_right(rs1, rs2[4:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rori – Rotation nach rechts um eine Konstante (Zbb, Zbkb)

**Syntax:** `rori rd, rs1, shamt`

**Wirkung:** `rd = rotate_right(rs1, shamt)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## roriw – Rotation des unteren Worts nach rechts um eine Konstante

**Syntax:** `roriw rd, rs1, shamt`

Rotation des unteren Worts nach rechts um eine Konstante (Zbb, RV64).

**Wirkung:** `rd = sext(rotate_right(rs1[31:0], shamt))`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rorw – Rotation des unteren Worts nach rechts (Zbb, RV64)

**Syntax:** `rorw rd, rs1, rs2`

**Wirkung:** `rd = sext(rotate_right(rs1[31:0], rs2[4:0]))`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sb – Speichern eines Bytes

**Syntax:** `sb rs2, imm12(rs1)`

**Wirkung:** `[rs1 + sext(imm12)]8 = rs2[7:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sc.d – Speichern eines Doppelworts

**Syntax:** `sc.d rd, rs2, (rs1)`

Speichern eines Doppelworts, wenn die Reservierung noch gilt (A, RV64).

**Wirkung:** `if reserved: [rs1]64 = rs2, rd = 0; else rd = 1`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sc.w – Bedingtes Speichern nach lr.w (A)

**Syntax:** `sc.w rd, rs2, (rs1)`

**Wirkung:** `if reserved then [rs1]32 = rs2; rd = 0 else rd = 1`

*Gruppe: Atomare Speicherbefehle (A). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sd – Speichern eines Doppelworts (64 Bit; RV64)

**Syntax:** `sd rs2, imm12(rs1)`

**Wirkung:** `[rs1 + sext(imm12)]64 = rs2`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sext.b – Erweiterung eines Bytes mit Vorzeichen (Zbb)

**Syntax:** `sext.b rd, rs1`

**Wirkung:** `rd = sext(rs1[7:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sext.h – Erweiterung eines Halbworts mit Vorzeichen (Zbb)

**Syntax:** `sext.h rd, rs1`

**Wirkung:** `rd = sext(rs1[15:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh – Speichern eines Halbworts

**Syntax:** `sh rs2, imm12(rs1)`

**Wirkung:** `[rs1 + sext(imm12)]16 = rs2[15:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh1add – Addition mit um 1 verschobenem Register (Zba)

**Syntax:** `sh1add rd, rs1, rs2`

**Wirkung:** `rd = rs2 + (rs1 << 1)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh1add.uw – Addition des um 1 verschobenen unteren Worts

**Syntax:** `sh1add.uw rd, rs1, rs2`

Addition des um 1 verschobenen unteren Worts (Zba, RV64).

**Wirkung:** `rd = rs2 + (zext(rs1[31:0]) << 1)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh2add – Addition mit um 2 verschobenem Register (Zba)

**Syntax:** `sh2add rd, rs1, rs2`

**Wirkung:** `rd = rs2 + (rs1 << 2)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh2add.uw – Addition des um 2 verschobenen unteren Worts

**Syntax:** `sh2add.uw rd, rs1, rs2`

Addition des um 2 verschobenen unteren Worts (Zba, RV64).

**Wirkung:** `rd = rs2 + (zext(rs1[31:0]) << 2)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh3add – Addition mit um 3 verschobenem Register (Zba)

**Syntax:** `sh3add rd, rs1, rs2`

**Wirkung:** `rd = rs2 + (rs1 << 3)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sh3add.uw – Addition des um 3 verschobenen unteren Worts

**Syntax:** `sh3add.uw rd, rs1, rs2`

Addition des um 3 verschobenen unteren Worts (Zba, RV64).

**Wirkung:** `rd = rs2 + (zext(rs1[31:0]) << 3)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sll – Schieben nach links um ein Register

**Syntax:** `sll rd, rs1, rs2`

**Wirkung:** `rd = rs1 << rs2[4:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slli – Schieben nach links um eine Konstante

**Syntax:** `slli rd, rs1, shamt` &nbsp; `slli rd, rs1, shamt6`

**Wirkung:** `rd = rs1 << shamt`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slli.uw – Schieben des unteren Worts ohne Vorzeichen nach links

**Syntax:** `slli.uw rd, rs1, shamt6`

Schieben des unteren Worts ohne Vorzeichen nach links (Zba, RV64).

**Wirkung:** `rd = zext(rs1[31:0]) << shamt6`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slliw – Schieben nach links mit 32 Bit (RV64)

**Syntax:** `slliw rd, rs1, shamt`

**Wirkung:** `rd = sext((rs1 << shamt)[31:0])`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sllw – Schieben nach links um ein Register

**Syntax:** `sllw rd, rs1, rs2`

Schieben nach links um ein Register, mit 32 Bit (RV64).

**Wirkung:** `rd = sext((rs1 << rs2[4:0])[31:0])`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slt – Vergleich mit Vorzeichen: 1, wenn kleiner

**Syntax:** `slt rd, rs1, rs2`

**Wirkung:** `rd = (rs1 <s rs2) ? 1 : 0`

Auch angezeigt als: `sltz`, `sgtz`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slti – Vergleich mit einer Konstanten mit Vorzeichen

**Syntax:** `slti rd, rs1, imm12`

Vergleich mit einer Konstanten mit Vorzeichen: 1, wenn kleiner.

**Wirkung:** `rd = (rs1 <s sext(imm12)) ? 1 : 0`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sltiu – Vergleich mit einer Konstanten ohne Vorzeichen

**Syntax:** `sltiu rd, rs1, imm12`

Vergleich mit einer Konstanten ohne Vorzeichen: 1, wenn kleiner.

**Wirkung:** `rd = (rs1 <u sext(imm12)) ? 1 : 0`

Auch angezeigt als: `seqz`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sltu – Vergleich ohne Vorzeichen: 1, wenn kleiner

**Syntax:** `sltu rd, rs1, rs2`

**Wirkung:** `rd = (rs1 <u rs2) ? 1 : 0`

Auch angezeigt als: `snez`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sra – Schieben nach rechts mit Vorzeichen um ein Register

**Syntax:** `sra rd, rs1, rs2`

**Wirkung:** `rd = rs1 >>s rs2[4:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srai – Schieben nach rechts mit Vorzeichen um eine Konstante

**Syntax:** `srai rd, rs1, shamt` &nbsp; `srai rd, rs1, shamt6`

**Wirkung:** `rd = rs1 >>s shamt`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sraiw – Schieben nach rechts mit Vorzeichen mit 32 Bit

**Syntax:** `sraiw rd, rs1, shamt`

Schieben nach rechts mit Vorzeichen mit 32 Bit (RV64).

**Wirkung:** `rd = sext(rs1[31:0] >>s shamt)`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sraw – Schieben nach rechts mit Vorzeichen um ein Register

**Syntax:** `sraw rd, rs1, rs2`

Schieben nach rechts mit Vorzeichen um ein Register, mit 32 Bit (RV64).

**Wirkung:** `rd = sext(rs1[31:0] >>s rs2[4:0])`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sret – Rückkehr aus einer Ausnahme im Supervisor Mode

**Syntax:** `sret`

**Wirkung:** `pc = sepc; restore the mode from sstatus`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srl – Schieben nach rechts ohne Vorzeichen um ein Register

**Syntax:** `srl rd, rs1, rs2`

**Wirkung:** `rd = rs1 >>u rs2[4:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srli – Schieben nach rechts ohne Vorzeichen um eine Konstante

**Syntax:** `srli rd, rs1, shamt` &nbsp; `srli rd, rs1, shamt6`

**Wirkung:** `rd = rs1 >>u shamt`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srliw – Schieben nach rechts ohne Vorzeichen mit 32 Bit

**Syntax:** `srliw rd, rs1, shamt`

Schieben nach rechts ohne Vorzeichen mit 32 Bit (RV64).

**Wirkung:** `rd = sext(rs1[31:0] >>u shamt)`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srlw – Schieben nach rechts ohne Vorzeichen um ein Register

**Syntax:** `srlw rd, rs1, rs2`

Schieben nach rechts ohne Vorzeichen um ein Register, mit 32 Bit (RV64).

**Wirkung:** `rd = sext(rs1[31:0] >>u rs2[4:0])`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub – Subtraktion zweier Register

**Syntax:** `sub rd, rs1, rs2`

**Wirkung:** `rd = rs1 - rs2`

Auch angezeigt als: `neg`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subw – Subtraktion mit 32 Bit (RV64)

**Syntax:** `subw rd, rs1, rs2`

**Wirkung:** `rd = sext((rs1 - rs2)[31:0])`

Auch angezeigt als: `negw`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sw – Speichern eines Worts

**Syntax:** `sw rs2, imm12(rs1)`

**Wirkung:** `[rs1 + sext(imm12)]32 = rs2`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## unzip – Entflechten in gerade und ungerade Bits (Zbkb)

**Syntax:** `unzip rd, rs1`

**Wirkung:** `rd[i] = rs1[2i]; rd[i+16] = rs1[2i+1]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wfi – Warten auf einen Interrupt

**Syntax:** `wfi`

**Wirkung:** `pause until an interrupt is pending`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xnor – Invertiertes exklusives ODER (Zbb, Zbkb)

**Syntax:** `xnor rd, rs1, rs2`

**Wirkung:** `rd = ~(rs1 ^ rs2)`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xor – Exklusives ODER

**Syntax:** `xor rd, rs1, rs2`

**Wirkung:** `rd = rs1 ^ rs2`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xori – Exklusives ODER mit einer Konstanten

**Syntax:** `xori rd, rs1, imm12`

**Wirkung:** `rd = rs1 ^ sext(imm12)`

Auch angezeigt als: `not`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## zext.h – Erweiterung eines Halbworts mit Nullen (Zbb)

**Syntax:** `zext.h rd, rs1`

**Wirkung:** `rd = zext(rs1[15:0])`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## zip – Verschränken der Bits der beiden Halbwörter (Zbkb)

**Syntax:** `zip rd, rs1`

**Wirkung:** `rd[2i] = rs1[i]; rd[2i+1] = rs1[i+16]`

*Gruppe: Bit-Manipulation (Zba, Zbb, Zbs, Zbc, Zbkb). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*
