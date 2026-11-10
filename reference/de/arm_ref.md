# Befehle aus der Befehlsreferenz (erzeugt)

Erzeugt von tools/gen_help_ref.py aus den Tabellen des Assemblers (tools/instr), nicht von Hand ändern. F1 zeigt einen Abschnitt von hier, wenn die Hilfe der Architektur keinen eigenen hat.

## adc – Addition mit Übertrag

**Syntax:** `adc Rd, Rn, #const` &nbsp; `adc Rd, Rn, Rm{, shift #imm}`

Addition mit Übertrag: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn + const + C; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adcs – Addition mit Übertrag (C)

**Syntax:** `adcs Rdn, Rm`

**Wirkung:** `Rdn = Rdn + Rm + C`

**Flags:** N Z C V

Auch angezeigt als: `adc`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add – Addition zweier Register

**Syntax:** `add Rdn, Rm` &nbsp; `add Rd, sp, #imm8*4` &nbsp; `add sp, sp, #imm7*4` &nbsp; `add Rd, Rn, #const` &nbsp; `add Rd, Rn, Rm{, shift #imm}`

Addition zweier Register (auch r8 bis r15, setzt keine Flags).

**Wirkung:** `Rdn = Rdn + Rm`

Auch angezeigt als: `cmn`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adds – Addition zweier Register

**Syntax:** `adds Rd, Rn, Rm` &nbsp; `adds Rd, Rn, #imm3` &nbsp; `adds Rdn, #imm8`

**Wirkung:** `Rd = Rn + Rm`

**Flags:** N Z C V

Auch angezeigt als: `add`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addw – Addition einer Konstanten (12 Bit)

**Syntax:** `addw Rd, Rn, #imm12`

**Wirkung:** `Rd = Rn + imm12 (i:imm3:imm8)`

Auch angezeigt als: `add`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adr – Adresse relativ zum Befehlszeiger

**Syntax:** `adr Rd, label`

**Wirkung:** `Rd = align(pc, 4) + imm8 * 4`

Auch angezeigt als: `add`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## and – Bitweises UND

**Syntax:** `and Rd, Rn, #const` &nbsp; `and Rd, Rn, Rm{, shift #imm}`

Bitweises UND: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn & const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Auch angezeigt als: `tst`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ands – Bitweises UND

**Syntax:** `ands Rdn, Rm`

**Wirkung:** `Rdn = Rdn & Rm`

**Flags:** N Z

Auch angezeigt als: `and`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## asr – Schieben rechts mit Vorzeichen um ein Register

**Syntax:** `asr Rd, Rn, Rm`

Schieben rechts mit Vorzeichen um ein Register (32-Bit-Form).

**Wirkung:** `Rd = Rn >>s Rm[7:0]`

**Flags:** N Z C (if S)

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## asrs – Schieben nach rechts mit Vorzeichen um eine Konstante

**Syntax:** `asrs Rd, Rm, #imm5` &nbsp; `asrs Rdn, Rm`

**Wirkung:** `Rd = Rm >>s imm5 (imm5 = 0 means 32)`

**Flags:** N Z C

Auch angezeigt als: `asr`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## b – Sprung (relativ, +-2 KB)

**Syntax:** `b label`

**Wirkung:** `pc = pc + (sext(imm11) << 1)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## b.cond – Bedingter Sprung (relativ, +-256 Byte)

**Syntax:** `b.cond label`

**Wirkung:** `if cond then pc = pc + (sext(imm8) << 1)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bfi – Einfügen eines Bitfeldes aus Rn in Rd

**Syntax:** `bfi Rd, Rn, #lsb, #width`

Einfügen eines Bitfeldes aus Rn in Rd (bfc: Nullen).

**Wirkung:** `Rd[msb : lsb] = Rn[msb - lsb : 0]`

Auch angezeigt als: `bfc`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bic – Bitweises UND mit invertierter Konstante

**Syntax:** `bic Rd, Rn, #const` &nbsp; `bic Rd, Rn, Rm{, shift #imm}`

Bitweises UND mit invertierter Konstante: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn & ~const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bics – Bitweises UND mit invertiertem Operanden

**Syntax:** `bics Rdn, Rm`

Bitweises UND mit invertiertem Operanden (Bit löschen).

**Wirkung:** `Rdn = Rdn & ~Rm`

**Flags:** N Z

Auch angezeigt als: `bic`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bkpt – Haltepunkt

**Syntax:** `bkpt #imm8`

**Wirkung:** `raise a breakpoint exception`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bl – Aufruf einer Funktion

**Syntax:** `bl label`

Aufruf einer Funktion (relativ, +-16 MB, lr = Rücksprung).

**Wirkung:** `lr = (pc + 4) | 1; pc = pc + sext(S:J1:J2:imm10:imm11 << 1)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blx – Aufruf der Funktion an der Adresse im Register

**Syntax:** `blx Rm` &nbsp; `blx label`

Aufruf der Funktion an der Adresse im Register (lr = Rücksprung).

**Wirkung:** `lr = (pc + 2) | 1; pc = Rm & ~1`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blxns – Aufruf eines Registers mit Wechsel in den nicht sicheren Zustand

**Syntax:** `blxns Rm`

Aufruf eines Registers mit Wechsel in den nicht sicheren Zustand (TrustZone, ARMv8-M).

**Wirkung:** `lr = next; pc = Rm; state = non-secure`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bx – Sprung zur Adresse im Register

**Syntax:** `bx Rm`

Sprung zur Adresse im Register (Bit 0 wählt Thumb, bei Bit 0 = 0 ARM).

**Wirkung:** `pc = Rm & ~1; instruction set = Rm[0]`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bxns – Sprung zu einem Register mit Wechsel in den nicht sicheren Zustand

**Syntax:** `bxns Rm`

Sprung zu einem Register mit Wechsel in den nicht sicheren Zustand (TrustZone, ARMv8-M).

**Wirkung:** `pc = Rm; state = non-secure`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cbnz – Sprung vorwärts, wenn das Register nicht 0 ist

**Syntax:** `cbnz Rn, label`

**Wirkung:** `if Rn != 0 then pc = pc + (i:imm5 << 1)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cbz – Sprung vorwärts, wenn das Register 0 ist

**Syntax:** `cbz Rn, label`

**Wirkung:** `if Rn == 0 then pc = pc + (i:imm5 << 1)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clz – Zählen der führenden Nullbits

**Syntax:** `clz Rd, Rm`

**Wirkung:** `Rd = count_leading_zeros(Rm)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmn – Vergleich durch Addition

**Syntax:** `cmn Rn, Rm`

Vergleich durch Addition (Rn plus Rm), nur die Flags ändern sich.

**Wirkung:** `flags = Rn + Rm`

**Flags:** N Z C V

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmp – Vergleich mit einer Konstanten (8 Bit)

**Syntax:** `cmp Rn, #imm8` &nbsp; `cmp Rn, Rm`

**Wirkung:** `flags = Rn - imm8`

**Flags:** N Z C V

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpsid – Sperren (cpsid) oder Erlauben

**Syntax:** `cpsid i`

Sperren (cpsid) oder Erlauben (cpsie) der Interrupts (privilegiert).

**Wirkung:** `PRIMASK = im`

Auch angezeigt als: `cpsie`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dmb – Speicherschranke für die Reihenfolge der Zugriffe

**Syntax:** `dmb option`

**Wirkung:** `earlier memory accesses are observed before later ones`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dsb – Speicherschranke

**Syntax:** `dsb option`

Speicherschranke: wartet, bis alle Zugriffe fertig sind.

**Wirkung:** `wait until all earlier memory accesses are complete`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eor – Bitweises exklusives ODER

**Syntax:** `eor Rd, Rn, #const` &nbsp; `eor Rd, Rn, Rm{, shift #imm}`

Bitweises exklusives ODER: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn ^ const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Auch angezeigt als: `teq`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eors – Bitweises exklusives ODER

**Syntax:** `eors Rdn, Rm`

**Wirkung:** `Rdn = Rdn ^ Rm`

**Flags:** N Z

Auch angezeigt als: `eor`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hint – Hinweis-Befehl mit einer Nummer von 0 bis 15

**Syntax:** `hint #imm`

Hinweis-Befehl mit einer Nummer von 0 bis 15 (nop, yield, wfe, wfi, sev haben eigene Namen; die übrigen tun nichts).

**Wirkung:** `no change`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## isb – Befehlsschranke: leert die Pipeline

**Syntax:** `isb option`

**Wirkung:** `all instructions after it are fetched anew`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## it – IT-Block: macht die folgenden 1 bis 4 Befehle bedingt

**Syntax:** `it {x{y{z}}} cond`

**Wirkung:** `the next instructions run only if the condition holds (or its opposite for else)`

Auch angezeigt als: `ite`, `itt`, `itee`, `itet`, `itte`, `ittt`, `iteee`, `iteet`, `itete`, `itett`, `ittee`, `ittet`, `ittte`, `itttt`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldm – Laden mehrerer Register (aufwärts)

**Syntax:** `ldm Rn{!}, {registers}`

**Wirkung:** `for each register in the list: reg = [Rn]; Rn = Rn + 4`

Auch angezeigt als: `ldmia`, `pop`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldmdb – Laden mehrerer Register (abwärts)

**Syntax:** `ldmdb Rn{!}, {registers}`

**Wirkung:** `for each register in the list, last first: Rn = Rn - 4; reg = [Rn]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldr – Laden eines Wortes relativ zum Befehlszeiger

**Syntax:** `ldr Rt, label` &nbsp; `ldr Rt, [Rn, Rm]` &nbsp; `ldr Rt, [Rn{, #imm5*4}]` &nbsp; `ldr Rt, [sp{, #imm8*4}]` &nbsp; `ldr Rt, [Rn, #imm12]` &nbsp; `ldr Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldr Rt, [Rn, Rm{, lsl #imm2}]`

Laden eines Wortes relativ zum Befehlszeiger (Konstantenpool, bis 1020 Byte).

**Wirkung:** `Rt = [align(pc, 4) + imm8 * 4]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrb – Laden eines Bytes (Register-Adresse)

**Syntax:** `ldrb Rt, [Rn, Rm]` &nbsp; `ldrb Rt, [Rn{, #imm5}]` &nbsp; `ldrb Rt, [Rn, #imm12]` &nbsp; `ldrb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrb Rt, [Rn, Rm{, lsl #imm2}]`

**Wirkung:** `Rt = zext([Rn + Rm])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrbt – Laden eines Bytes mit den Rechten des Anwendungs-Modus

**Syntax:** `ldrbt Rt, [Rn{, #imm8}]`

**Wirkung:** `Rt = zext([Rn + imm8])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrd – Laden eines Registerpaares (zwei Wörter)

**Syntax:** `ldrd Rt, Rt2, [Rn, #+/-imm8*4]{!}  /  [Rn], #+/-imm8*4`

**Wirkung:** `Rt = [addr]; Rt2 = [addr + 4]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrex – Laden (exklusiv): setzt den Exklusiv-Monitor

**Syntax:** `ldrex Rt, [Rn{, #imm8*4}]`

**Wirkung:** `Rt = [Rn + imm8 * 4]; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrexb – Laden eines Bytes (exklusiv)

**Syntax:** `ldrexb Rt, [Rn]`

**Wirkung:** `Rt = zext([Rn]); set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrexd – Laden eines Doppelwortes

**Syntax:** `ldrexd Rt, Rt2, [Rn]`

Laden eines Doppelwortes (exklusiv): setzt den Exklusiv-Monitor.

**Wirkung:** `Rt:Rt2 = [Rn]; mark exclusive`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrexh – Laden eines Halbwortes (exklusiv)

**Syntax:** `ldrexh Rt, [Rn]`

**Wirkung:** `Rt = zext([Rn]); set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrh – Laden eines Halbwortes (Register-Adresse)

**Syntax:** `ldrh Rt, [Rn, Rm]` &nbsp; `ldrh Rt, [Rn{, #imm5*2}]` &nbsp; `ldrh Rt, [Rn, #imm12]` &nbsp; `ldrh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrh Rt, [Rn, Rm{, lsl #imm2}]`

**Wirkung:** `Rt = zext([Rn + Rm])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrht – Laden eines Halbwortes mit den Rechten des Anwendungs-Modus

**Syntax:** `ldrht Rt, [Rn{, #imm8}]`

**Wirkung:** `Rt = zext([Rn + imm8])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsb – Laden eines Bytes mit Vorzeichen

**Syntax:** `ldrsb Rt, [Rn, Rm]` &nbsp; `ldrsb Rt, [Rn, #imm12]` &nbsp; `ldrsb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrsb Rt, [Rn, Rm{, lsl #imm2}]`

Laden eines Bytes mit Vorzeichen (Register-Adresse).

**Wirkung:** `Rt = sext([Rn + Rm])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsbt – Laden eines Bytes mit Vorzeichenerweiterung mit den Rechten des Anwendungs-Modus

**Syntax:** `ldrsbt Rt, [Rn{, #imm8}]`

**Wirkung:** `Rt = sext([Rn + imm8])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsh – Laden eines Halbwortes mit Vorzeichen

**Syntax:** `ldrsh Rt, [Rn, Rm]` &nbsp; `ldrsh Rt, [Rn, #imm12]` &nbsp; `ldrsh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `ldrsh Rt, [Rn, Rm{, lsl #imm2}]`

Laden eines Halbwortes mit Vorzeichen (Register-Adresse).

**Wirkung:** `Rt = sext([Rn + Rm])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsht – Laden eines Halbwortes mit Vorzeichenerweiterung mit den Rechten des Anwendungs-Modus

**Syntax:** `ldrsht Rt, [Rn{, #imm8}]`

**Wirkung:** `Rt = sext([Rn + imm8])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrt – Laden eines Wortes mit den Rechten des Anwendungs-Modus

**Syntax:** `ldrt Rt, [Rn{, #imm8}]`

**Wirkung:** `Rt = [Rn + imm8]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsl – Schieben links um ein Register (32-Bit-Form)

**Syntax:** `lsl Rd, Rn, Rm`

**Wirkung:** `Rd = Rn << Rm[7:0]`

**Flags:** N Z C (if S)

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsls – Schieben nach links um eine Konstante

**Syntax:** `lsls Rd, Rm, #imm5` &nbsp; `lsls Rdn, Rm`

**Wirkung:** `Rd = Rm << imm5`

**Flags:** N Z C

Auch angezeigt als: `lsl`, `movs`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsr – Schieben rechts ohne Vorzeichen um ein Register

**Syntax:** `lsr Rd, Rn, Rm`

Schieben rechts ohne Vorzeichen um ein Register (32-Bit-Form).

**Wirkung:** `Rd = Rn >> Rm[7:0]`

**Flags:** N Z C (if S)

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsrs – Schieben nach rechts ohne Vorzeichen um eine Konstante

**Syntax:** `lsrs Rd, Rm, #imm5` &nbsp; `lsrs Rdn, Rm`

**Wirkung:** `Rd = Rm >> imm5 (imm5 = 0 means 32)`

**Flags:** N Z C

Auch angezeigt als: `lsr`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mcr – Koprozessor-Zugriff

**Syntax:** `mcr coproc, #opc1, Rt, CRn, CRm{, #opc2}`

Koprozessor-Zugriff: Schreiben eines Registers in einen Koprozessor (mcr) oder Lesen (mrc, L = 1).

**Wirkung:** `coprocessor register = Rt or Rt = coprocessor register`

Auch angezeigt als: `mrc`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mla – Multiplikation mit Addition

**Syntax:** `mla Rd, Rn, Rm, Ra`

**Wirkung:** `Rd = Ra + Rn * Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mls – Multiplikation mit Subtraktion

**Syntax:** `mls Rd, Rn, Rm, Ra`

**Wirkung:** `Rd = Ra - Rn * Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mov – Kopieren eines Registers

**Syntax:** `mov Rd, Rm`

Kopieren eines Registers (auch r8 bis r15, setzt keine Flags).

**Wirkung:** `Rd = Rm`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movs – Laden einer Konstanten (8 Bit)

**Syntax:** `movs Rd, #imm8`

**Wirkung:** `Rd = imm8`

**Flags:** N Z

Auch angezeigt als: `mov`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movt – Laden der oberen Hälfte eines Registers

**Syntax:** `movt Rd, #imm16`

Laden der oberen Hälfte eines Registers (untere Hälfte bleibt).

**Wirkung:** `Rd[31:16] = imm4:i:imm3:imm8`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movw – Laden einer 16-Bit-Konstante (obere Hälfte 0)

**Syntax:** `movw Rd, #imm16`

**Wirkung:** `Rd = zext(imm4:i:imm3:imm8)`

Auch angezeigt als: `mov`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mrs – Lesen eines Systemregisters

**Syntax:** `mrs Rd, sysreg`

Lesen eines Systemregisters (apsr, ipsr, msp, psp, primask ...).

**Wirkung:** `Rd = sysreg`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## msr – Schreiben eines Systemregisters

**Syntax:** `msr sysreg, Rn`

**Wirkung:** `sysreg = Rn`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul – Multiplikation (untere 32 Bit)

**Syntax:** `mul Rd, Rn, Rm`

**Wirkung:** `Rd = Rn * Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## muls – Multiplikation (untere 32 Bit)

**Syntax:** `muls Rdm, Rn, Rdm`

**Wirkung:** `Rdm = Rn * Rdm`

**Flags:** N Z

Auch angezeigt als: `mul`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mvns – Bitweise Umkehrung

**Syntax:** `mvns Rd, Rm`

**Wirkung:** `Rd = ~Rm`

**Flags:** N Z

Auch angezeigt als: `mvn`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nop – Keine Operation

**Syntax:** `nop`

**Wirkung:** `no change`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orn – Bitweises ODER mit invertierter Konstante

**Syntax:** `orn Rd, Rn, #const` &nbsp; `orn Rd, Rn, Rm{, shift #imm}`

Bitweises ODER mit invertierter Konstante: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn OR ~const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Auch angezeigt als: `mvn`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orr – Bitweises ODER

**Syntax:** `orr Rd, Rn, #const` &nbsp; `orr Rd, Rn, Rm{, shift #imm}`

Bitweises ODER: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn OR const; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

Auch angezeigt als: `mov`, `lsl`, `lsr`, `asr`, `ror`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orrs – Bitweises ODER

**Syntax:** `orrs Rdn, Rm`

**Wirkung:** `Rdn = Rdn OR Rm`

**Flags:** N Z

Auch angezeigt als: `orr`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pld – Vorab-Laden einer Cache-Zeile zum Lesen (Hinweis)

**Syntax:** `pld [Rn, #imm12]`

**Wirkung:** `prefetch the cache line at Rn + imm12 (a hint)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pldw – Vorab-Laden einer Cache-Zeile zum Schreiben

**Syntax:** `pldw [Rn, #imm12]`

Vorab-Laden einer Cache-Zeile zum Schreiben (Hinweis).

**Wirkung:** `prefetch the cache line at Rn + imm12 (a hint)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pli – Vorab-Laden einer Cache-Zeile für Befehle

**Syntax:** `pli [Rn, #imm12]`

Vorab-Laden einer Cache-Zeile für Befehle (Hinweis).

**Wirkung:** `prefetch the cache line at Rn + imm12 (a hint)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pop – Holen von Registern

**Syntax:** `pop {registers{, pc}}`

Holen von Registern (P: auch pc, Rücksprung) vom Stack.

**Wirkung:** `load the registers upward from sp; sp = sp + 4 * count`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## push – Ablegen von Registern (M: auch lr) auf dem Stack

**Syntax:** `push {registers{, lr}}`

**Wirkung:** `sp = sp - 4 * count; store the registers upward from sp`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rbit – Umkehren der Bitreihenfolge

**Syntax:** `rbit Rd, Rm`

**Wirkung:** `Rd = reverse_bits(Rm)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev – Umkehren der Bytes (Little/Big Endian)

**Syntax:** `rev Rd, Rm`

**Wirkung:** `Rd = reverse_bytes(Rm)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev16 – Umkehren der Bytes in jedem Halbwort

**Syntax:** `rev16 Rd, Rm`

**Wirkung:** `Rd = reverse_bytes_in_each_16_bits(Rm)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## revsh – Umkehren der unteren zwei Bytes

**Syntax:** `revsh Rd, Rm`

Umkehren der unteren zwei Bytes, mit Vorzeichenerweiterung.

**Wirkung:** `Rd = sext(reverse_bytes(Rm[15:0]))`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ror – Schieben rechts

**Syntax:** `ror Rd, Rn, Rm`

Schieben rechts (Rotation) um ein Register (32-Bit-Form).

**Wirkung:** `Rd = rotate_right(Rn, Rm[7:0])`

**Flags:** N Z C (if S)

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rors – Rotation nach rechts um ein Register

**Syntax:** `rors Rdn, Rm`

**Wirkung:** `Rdn = rotate_right(Rdn, Rm[7:0])`

**Flags:** N Z C

Auch angezeigt als: `ror`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsb – Umgekehrte Subtraktion

**Syntax:** `rsb Rd, Rn, #const` &nbsp; `rsb Rd, Rn, Rm{, shift #imm}`

Umgekehrte Subtraktion: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = const - Rn; the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsbs – Umgekehrte Subtraktion von 0 (Negation)

**Syntax:** `rsbs Rd, Rn, #0`

**Wirkung:** `Rd = 0 - Rn`

**Flags:** N Z C V

Auch angezeigt als: `neg`, `rsb`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbc – Subtraktion mit Borgen

**Syntax:** `sbc Rd, Rn, #const` &nbsp; `sbc Rd, Rn, Rm{, shift #imm}`

Subtraktion mit Borgen: Konstante als zweiter Operand (8 Bit, gedreht oder wiederholt).

**Wirkung:** `Rd = Rn - const - (1 - C); the constant is expanded from i:imm3:imm8`

**Flags:** N Z C V (if S)

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbcs – Subtraktion mit Borgen (C)

**Syntax:** `sbcs Rdn, Rm`

**Wirkung:** `Rdn = Rdn - Rm - (1 - C)`

**Flags:** N Z C V

Auch angezeigt als: `sbc`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbfx – Herausholen eines Bitfeldes mit Vorzeichenerweiterung

**Syntax:** `sbfx Rd, Rn, #lsb, #width`

**Wirkung:** `Rd = sext(Rn[lsb + width - 1 : lsb])`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sdiv – Division mit Vorzeichen

**Syntax:** `sdiv Rd, Rn, Rm`

Division mit Vorzeichen (Division durch 0 ergibt 0).

**Wirkung:** `Rd = Rn / Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setend – Einstellen der Byte-Reihenfolge für Datenzugriffe

**Syntax:** `setend le|be`

Einstellen der Byte-Reihenfolge für Datenzugriffe (E = 0: little endian, 1: big endian; in ARMv8 veraltet).

**Wirkung:** `data endianness = E`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sev – Senden eines Ereignisses an alle Prozessoren

**Syntax:** `sev`

**Wirkung:** `set the event register of all processors`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smlal – Multiplikation mit Vorzeichen zu 64 Bit mit Addition

**Syntax:** `smlal RdLo, RdHi, Rn, Rm`

**Wirkung:** `RdHi:RdLo = RdHi:RdLo + sext(Rn) * sext(Rm)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smull – Multiplikation mit Vorzeichen zu 64 Bit

**Syntax:** `smull RdLo, RdHi, Rn, Rm`

**Wirkung:** `RdHi:RdLo = sext(Rn) * sext(Rm)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stm – Speichern mehrerer Register

**Syntax:** `stm Rn!, {registers}` &nbsp; `stm Rn{!}, {registers}`

Speichern mehrerer Register (aufwärts, Rn wird weitergezählt).

**Wirkung:** `for each register in the list: [Rn] = reg; Rn = Rn + 4`

Auch angezeigt als: `stmia`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stmdb – Speichern mehrerer Register

**Syntax:** `stmdb Rn{!}, {registers}`

Speichern mehrerer Register (abwärts; push ist stmdb sp!).

**Wirkung:** `for each register in the list, last first: Rn = Rn - 4; [Rn] = reg`

Auch angezeigt als: `push`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## str – Speichern eines Wortes (Register-Adresse)

**Syntax:** `str Rt, [Rn, Rm]` &nbsp; `str Rt, [Rn{, #imm5*4}]` &nbsp; `str Rt, [sp{, #imm8*4}]` &nbsp; `str Rt, [Rn, #imm12]` &nbsp; `str Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `str Rt, [Rn, Rm{, lsl #imm2}]`

**Wirkung:** `[Rn + Rm] = Rt`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strb – Speichern eines Bytes (Register-Adresse)

**Syntax:** `strb Rt, [Rn, Rm]` &nbsp; `strb Rt, [Rn{, #imm5}]` &nbsp; `strb Rt, [Rn, #imm12]` &nbsp; `strb Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `strb Rt, [Rn, Rm{, lsl #imm2}]`

**Wirkung:** `[Rn + Rm] = Rt[7:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strbt – Speichern eines Bytes mit den Rechten des Anwendungs-Modus

**Syntax:** `strbt Rt, [Rn{, #imm8}]`

**Wirkung:** `[Rn + imm8] = Rt[7:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strd – Speichern eines Registerpaares (zwei Wörter)

**Syntax:** `strd Rt, Rt2, [Rn, #+/-imm8*4]{!}  /  [Rn], #+/-imm8*4`

**Wirkung:** `[addr] = Rt; [addr + 4] = Rt2`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strex – Bedingtes Speichern (exklusiv): Rd = 0 bei Erfolg

**Syntax:** `strex Rd, Rt, [Rn{, #imm8*4}]`

**Wirkung:** `if the exclusive monitor is set then { [Rn + imm8 * 4] = Rt; Rd = 0 } else Rd = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strexb – Bedingtes Speichern eines Bytes (exklusiv)

**Syntax:** `strexb Rd, Rt, [Rn]`

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt[7:0]; Rd = 0 } else Rd = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strexd – Speichern eines Doppelwortes

**Syntax:** `strexd Rd, Rt, Rt2, [Rn]`

Speichern eines Doppelwortes (exklusiv): nur wenn der Monitor noch gesetzt ist.

**Wirkung:** `if exclusive then [Rn] = Rt:Rt2; Rd = 0 else Rd = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strexh – Bedingtes Speichern eines Halbwortes (exklusiv)

**Syntax:** `strexh Rd, Rt, [Rn]`

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt[15:0]; Rd = 0 } else Rd = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strh – Speichern eines Halbwortes (Register-Adresse)

**Syntax:** `strh Rt, [Rn, Rm]` &nbsp; `strh Rt, [Rn{, #imm5*2}]` &nbsp; `strh Rt, [Rn, #imm12]` &nbsp; `strh Rt, [Rn, #+/-imm8]{!}  /  [Rn], #+/-imm8` &nbsp; `strh Rt, [Rn, Rm{, lsl #imm2}]`

**Wirkung:** `[Rn + Rm] = Rt[15:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strht – Speichern eines Halbwortes mit den Rechten des Anwendungs-Modus

**Syntax:** `strht Rt, [Rn{, #imm8}]`

**Wirkung:** `[Rn + imm8] = Rt[15:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strt – Speichern eines Wortes mit den Rechten des Anwendungs-Modus

**Syntax:** `strt Rt, [Rn{, #imm8}]`

**Wirkung:** `[Rn + imm8] = Rt`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub – Verringerung des Stackzeigers

**Syntax:** `sub sp, sp, #imm7*4` &nbsp; `sub Rd, Rn, #const` &nbsp; `sub Rd, Rn, Rm{, shift #imm}`

**Wirkung:** `sp = sp - imm7 * 4`

Auch angezeigt als: `cmp`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subs – Subtraktion zweier Register

**Syntax:** `subs Rd, Rn, Rm` &nbsp; `subs Rd, Rn, #imm3` &nbsp; `subs Rdn, #imm8`

**Wirkung:** `Rd = Rn - Rm`

**Flags:** N Z C V

Auch angezeigt als: `sub`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subw – Subtraktion einer Konstanten (12 Bit)

**Syntax:** `subw Rd, Rn, #imm12`

**Wirkung:** `Rd = Rn - imm12 (i:imm3:imm8)`

Auch angezeigt als: `sub`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## svc – Systemaufruf an das Betriebssystem

**Syntax:** `svc #imm8`

**Wirkung:** `raise a supervisor call exception with imm8`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sxtab – Erweiterung eines Bytes oder Halbwortes

**Syntax:** `sxtab Rd, Rn, Rm{, ror #rot}`

Erweiterung eines Bytes oder Halbwortes (sxt: mit Vorzeichen, uxt: mit Nullen) und Addition von Rn; ...16: zwei Halbwörter aus zwei Bytes; Rm vorher um 0/8/16/24 gedreht.

**Wirkung:** `Rd = Rn + extend(ror(Rm, rot))`

Auch angezeigt als: `sxtah`, `sxtab16`, `uxtab`, `uxtah`, `uxtab16`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sxtb – Vorzeichenerweiterung eines Bytes

**Syntax:** `sxtb Rd, Rm` &nbsp; `sxtb Rd, Rm{, ror #rot}`

**Wirkung:** `Rd = sext(Rm[7:0])`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sxtb16 – Erweiterung zweier Bytes zu zwei Halbwörtern

**Syntax:** `sxtb16 Rd, Rm{, ror #rot}`

Erweiterung zweier Bytes zu zwei Halbwörtern (sxt: mit Vorzeichen, uxt: mit Nullen); Rm vorher um 0/8/16/24 gedreht.

**Wirkung:** `Rd = extend(ror(Rm, rot)) per half word`

Auch angezeigt als: `uxtb16`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sxth – Vorzeichenerweiterung eines Halbwortes

**Syntax:** `sxth Rd, Rm` &nbsp; `sxth Rd, Rm{, ror #rot}`

**Wirkung:** `Rd = sext(Rm[15:0])`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tbb – Sprung über eine Tabelle von Byte-Abständen

**Syntax:** `tbb [Rn, Rm]`

**Wirkung:** `pc = pc + 2 * zext([Rn + Rm])`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tbh – Sprung über eine Tabelle von Halbwort-Abständen

**Syntax:** `tbh [Rn, Rm, lsl #1]`

**Wirkung:** `pc = pc + 2 * zext([Rn + 2 * Rm])`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tst – Bitweiser Test (UND), nur die Flags ändern sich

**Syntax:** `tst Rn, Rm`

**Wirkung:** `flags = Rn & Rm`

**Flags:** N Z

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tt – Test des Zieles einer Adresse

**Syntax:** `tt Rd, Rn`

Test des Zieles einer Adresse (TrustZone: Sicherheitszustand und Zugriffsrechte; A: alternativ, T: unprivilegiert).

**Wirkung:** `Rd = security attributes of the address Rn`

Auch angezeigt als: `tta`, `ttt`, `ttat`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ubfx – Herausholen eines Bitfeldes mit Nullen

**Syntax:** `ubfx Rd, Rn, #lsb, #width`

**Wirkung:** `Rd = zext(Rn[lsb + width - 1 : lsb])`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## udf – Absichtlich ungültiger Befehl

**Syntax:** `udf #imm8` &nbsp; `udf #imm16`

Absichtlich ungültiger Befehl (löst eine Ausnahme aus).

**Wirkung:** `raise an undefined instruction exception`

Auch angezeigt als: `trap`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## udiv – Division ohne Vorzeichen

**Syntax:** `udiv Rd, Rn, Rm`

Division ohne Vorzeichen (Division durch 0 ergibt 0).

**Wirkung:** `Rd = Rn / Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umlal – Multiplikation ohne Vorzeichen zu 64 Bit mit Addition

**Syntax:** `umlal RdLo, RdHi, Rn, Rm`

**Wirkung:** `RdHi:RdLo = RdHi:RdLo + zext(Rn) * zext(Rm)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umull – Multiplikation ohne Vorzeichen zu 64 Bit

**Syntax:** `umull RdLo, RdHi, Rn, Rm`

**Wirkung:** `RdHi:RdLo = zext(Rn) * zext(Rm)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uxtb – Erweiterung eines Bytes mit Nullen

**Syntax:** `uxtb Rd, Rm` &nbsp; `uxtb Rd, Rm{, ror #rot}`

**Wirkung:** `Rd = zext(Rm[7:0])`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uxth – Erweiterung eines Halbwortes mit Nullen

**Syntax:** `uxth Rd, Rm` &nbsp; `uxth Rd, Rm{, ror #rot}`

**Wirkung:** `Rd = zext(Rm[15:0])`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vabs – Gleitkomma: Betrag (sz: 0 = Single, 1 = Double)

**Syntax:** `vabs Vd, Vm`

**Wirkung:** `Vd = abs(Vm)`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vadd – Gleitkomma

**Syntax:** `vadd Vd, Vn, Vm`

Gleitkomma: Addition (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vn + Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vcmp – Gleitkomma

**Syntax:** `vcmp Vd, Vm` &nbsp; `vcmp Vd, #0.0`

Gleitkomma: Vergleich zweier Register, setzt die FPSCR-Flags (vcmpe: mit Ausnahme bei NaN; danach vmrs apsr_nzcv, fpscr).

**Wirkung:** `fpscr flags = compare(Vd, Vm)`

**Flags:** N Z C V (FPSCR)

Auch angezeigt als: `vcmpe`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vcvt – Gleitkomma

**Syntax:** `vcvt Sd, Sm  /  Dd, Sm` &nbsp; `vcvt Sd, Sm  /  Sd, Dm` &nbsp; `vcvt Dd, Sm  /  Sd, Dm`

Gleitkomma: Umwandlung einer Ganzzahl in Gleitkomma (op = 1: mit Vorzeichen, 0: ohne).

**Wirkung:** `Vd = (float) Vm`

Auch angezeigt als: `vcvtr`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vdiv – Gleitkomma

**Syntax:** `vdiv Vd, Vn, Vm`

Gleitkomma: Division (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vn / Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vfma – Gleitkomma

**Syntax:** `vfma Vd, Vn, Vm`

Gleitkomma: Verschmolzene Multiplikation mit Addition (ohne Zwischenrundung) (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vd + Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vfms – Gleitkomma

**Syntax:** `vfms Vd, Vn, Vm`

Gleitkomma: Verschmolzene Multiplikation mit Subtraktion (ohne Zwischenrundung) (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vd - Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vfnma – Gleitkomma

**Syntax:** `vfnma Vd, Vn, Vm`

Gleitkomma: Negierte verschmolzene Multiplikation mit Addition (ohne Zwischenrundung) (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = -Vd - Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vfnms – Gleitkomma

**Syntax:** `vfnms Vd, Vn, Vm`

Gleitkomma: Negierte verschmolzene Multiplikation mit Subtraktion (ohne Zwischenrundung) (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = -Vd + Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vldm – Gleitkomma

**Syntax:** `vldm Rn{!}, {Sd | Dd list}`

Gleitkomma: Laden mehrerer Register ab der Adresse aufsteigend (vldmia; vpop = vldmia sp!; fldmx bei ungerader Zahl).

**Wirkung:** `registers = [Rn ...]; optionally Rn = Rn + size`

Auch angezeigt als: `vldmia`, `vpop`, `fldmiax`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vldmdb – Gleitkomma

**Syntax:** `vldmdb Rn!, {Sd | Dd list}`

Gleitkomma: Laden mehrerer Register absteigend unterhalb der Adresse, Rn wird verkleinert (vldmdb).

**Wirkung:** `Rn = Rn - size; registers = [Rn ...]`

Auch angezeigt als: `fldmdbx`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vldr – Gleitkomma

**Syntax:** `vldr Sd|Dd, [Rn{, #+/-imm8*4}]`

Gleitkomma: Laden eines Registers aus dem Speicher (sz: 0 = Single, 1 = Double).

**Wirkung:** `Vd = [Rn +/- imm8 * 4]`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmla – Gleitkomma

**Syntax:** `vmla Vd, Vn, Vm`

Gleitkomma: Multiplikation mit Addition zum Ziel (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vd + Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmls – Gleitkomma

**Syntax:** `vmls Vd, Vn, Vm`

Gleitkomma: Multiplikation mit Subtraktion vom Ziel (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vd - Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmov – Gleitkomma

**Syntax:** `vmov Vd, Vm` &nbsp; `vmov Sd|Dd, #imm` &nbsp; `vmov Sn, Rt  /  Rt, Sn` &nbsp; `vmov Sm, Sm1, Rt, Rt2  /  Dm, Rt, Rt2` &nbsp; `vmov Dd[x], Rt  /  Rt, Dn[x]`

Gleitkomma: Kopieren eines Gleitkomma-Registers (sz: 0 = Single, 1 = Double).

**Wirkung:** `Vd = Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmrs – Kopieren eines Gleitkomma-Systemregisters in ein Ganzzahl-Register

**Syntax:** `vmrs Rt, FPSID|FPSCR`

Kopieren eines Gleitkomma-Systemregisters in ein Ganzzahl-Register (mit Rt = pc: in die APSR-Flags).

**Wirkung:** `Rt = system register`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmsr – Kopieren eines Ganzzahl-Registers in ein Gleitkomma-Systemregister

**Syntax:** `vmsr FPSID|FPSCR, Rt`

**Wirkung:** `system register = Rt`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vmul – Gleitkomma

**Syntax:** `vmul Vd, Vn, Vm`

Gleitkomma: Multiplikation (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vneg – Gleitkomma

**Syntax:** `vneg Vd, Vm`

Gleitkomma: Vorzeichenwechsel (sz: 0 = Single, 1 = Double).

**Wirkung:** `Vd = -Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vnmla – Gleitkomma

**Syntax:** `vnmla Vd, Vn, Vm`

Gleitkomma: Negierte Multiplikation mit Addition (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = -Vd - Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vnmls – Gleitkomma

**Syntax:** `vnmls Vd, Vn, Vm`

Gleitkomma: Negierte Multiplikation mit Subtraktion (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = -Vd + Vn * Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vnmul – Gleitkomma

**Syntax:** `vnmul Vd, Vn, Vm`

Gleitkomma: Negierte Multiplikation (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = -(Vn * Vm)`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vsqrt – Gleitkomma

**Syntax:** `vsqrt Vd, Vm`

Gleitkomma: Quadratwurzel (sz: 0 = Single, 1 = Double).

**Wirkung:** `Vd = sqrt(Vm)`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vstm – Gleitkomma

**Syntax:** `vstm Rn{!}, {Sd | Dd list}`

Gleitkomma: Speichern mehrerer Register ab der Adresse aufsteigend (vstmia; fstmx bei ungerader Zahl).

**Wirkung:** `[Rn ...] = registers; optionally Rn = Rn + size`

Auch angezeigt als: `vstmia`, `fstmiax`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vstmdb – Gleitkomma

**Syntax:** `vstmdb Rn!, {Sd | Dd list}`

Gleitkomma: Speichern mehrerer Register absteigend unterhalb der Adresse, Rn wird verkleinert (vstmdb; vpush = vstmdb sp!).

**Wirkung:** `Rn = Rn - size; [Rn ...] = registers`

Auch angezeigt als: `vpush`, `fstmdbx`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vstr – Gleitkomma

**Syntax:** `vstr Sd|Dd, [Rn{, #+/-imm8*4}]`

Gleitkomma: Speichern eines Registers in den Speicher (sz: 0 = Single, 1 = Double).

**Wirkung:** `[Rn +/- imm8 * 4] = Vd`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## vsub – Gleitkomma

**Syntax:** `vsub Vd, Vn, Vm`

Gleitkomma: Subtraktion (sz = 0: Single, Sd/Sn/Sm; sz = 1: Double, Dd/Dn/Dm).

**Wirkung:** `Vd = Vn - Vm`

*Gruppe: Gleitkomma (VFP). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wfe – Warten auf ein Ereignis

**Syntax:** `wfe`

**Wirkung:** `sleep until an event`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wfi – Warten auf einen Interrupt

**Syntax:** `wfi`

**Wirkung:** `sleep until an interrupt`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## yield – Hinweis: Warteschleife

**Syntax:** `yield`

Hinweis: Warteschleife, der Prozessor darf zu einem anderen Thread wechseln.

**Wirkung:** `no change (a hint)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*
