# Befehle aus der Befehlsreferenz (erzeugt)

Erzeugt von tools/gen_help_ref.py aus den Tabellen des Assemblers (tools/instr), nicht von Hand ändern. F1 zeigt einen Abschnitt von hier, wenn die Hilfe der Architektur keinen eigenen hat.

## abs – Betrag

**Syntax:** `abs Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = abs(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adc – Addition mit Übertrag (C)

**Syntax:** `adc Rd, Rn, Rm`

**Wirkung:** `Rd = Rn + Rm + C`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adcs – Addition mit Übertrag, setzt die Flags

**Syntax:** `adcs Rd, Rn, Rm`

**Wirkung:** `Rd = Rn + Rm + C`

**Flags:** N Z C V

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add – Addition einer Konstanten

**Syntax:** `add Rd, Rn, #imm12{, lsl #12}` &nbsp; `add Rd, Rn, Rm{, shift #imm6}` &nbsp; `add Rd, Rn, Rm{, extend #imm3}` &nbsp; `add Vd.T, Vn.T, Vm.T`

Addition einer Konstanten (12 Bit, optional um 12 verschoben).

**Wirkung:** `Rd = Rn + (imm12 << (sh * 12)) (Rd and Rn may be SP)`

Auch angezeigt als: `mov`, `cmn`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addg – Addition zu einer Adresse mit Änderung des Tags

**Syntax:** `addg Xd|SP, Xn|SP, #uimm6, #uimm4`

**Wirkung:** `Xd = Xn + uimm6 * 16, tag = (tag of Xn + uimm4) modulo 16`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addhn – Addition mit Verschmälerung

**Syntax:** `addhn Vd.Tb, Vn.Ta, Vm.Ta`

Addition mit Verschmälerung (obere Hälfte; raddhn mit Runden) (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = high half of (Vn[i] + Vm[i])`

Auch angezeigt als: `addhn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addp – Addition benachbarter Elementpaare

**Syntax:** `addp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = sum of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adds – Addition einer Konstanten, setzt die Flags

**Syntax:** `adds Rd, Rn, #imm12{, lsl #12}` &nbsp; `adds Rd, Rn, Rm{, shift #imm6}` &nbsp; `adds Rd, Rn, Rm{, extend #imm3}`

**Wirkung:** `Rd = Rn + (imm12 << (sh * 12))`

**Flags:** N Z C V

Auch angezeigt als: `cmn`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addv – Summe aller Elemente

**Syntax:** `addv Vd, Vn.T`

**Wirkung:** `Vd = sum of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adr – Adresse relativ zum Befehlszeiger (+-1 MB)

**Syntax:** `adr Xd, label`

**Wirkung:** `Xd = pc + sext(immhi:immlo)`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adrp – Adresse der 4-KB-Seite relativ zum Befehlszeiger

**Syntax:** `adrp Xd, label`

Adresse der 4-KB-Seite relativ zum Befehlszeiger (+-4 GB).

**Wirkung:** `Xd = (pc & ~0xFFF) + (sext(immhi:immlo) << 12)`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aese – AES-Verschlüsselung

**Syntax:** `aese Vd.16B, Vn.16B`

AES-Verschlüsselung: eine Runde (aese, aesmc) oder Entschlüsselung (aesd, aesimc: Gegenstücke).

**Wirkung:** `aese: Vd = SubBytes(ShiftRows(Vd ^ Vn)); aesmc: Vd = MixColumns(Vn)`

Auch angezeigt als: `aesd`, `aesmc`, `aesimc`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## and – Bitweises UND mit einem Bitmuster als Konstante

**Syntax:** `and Rd, Rn, #imm (bit pattern)` &nbsp; `and Rd, Rn, Rm{, shift #imm6}` &nbsp; `and Vd.T, Vn.T, Vm.T`

**Wirkung:** `Rd = Rn & decode_bitmask(N, imms, immr) (Rd may be SP)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ands – Bitweises UND mit Bitmuster, setzt die Flags

**Syntax:** `ands Rd, Rn, #imm (bit pattern)` &nbsp; `ands Rd, Rn, Rm{, shift #imm6}`

**Wirkung:** `Rd = Rn & decode_bitmask(N, imms, immr); C = V = 0`

**Flags:** N Z C V

Auch angezeigt als: `tst`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## asrv – Schieben nach rechts mit Vorzeichen um ein Register

**Syntax:** `asrv Rd, Rn, Rm`

**Wirkung:** `Rd = Rn >>s (Rm mod width)`

Auch angezeigt als: `asr`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## b – Sprung (relativ, +-128 MB)

**Syntax:** `b label`

**Wirkung:** `pc = pc + sext(imm26 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## b.cond – Bedingter Sprung (relativ, +-1 MB)

**Syntax:** `b.cond label`

**Wirkung:** `if cond then pc = pc + sext(imm19 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bc – Bedingter Sprung mit Hinweis

**Syntax:** `bc label`

Bedingter Sprung mit Hinweis, dass er stets gleich verläuft (Konsistenz, FEAT_HBC).

**Wirkung:** `if cond then pc = pc + imm19 * 4`

Auch angezeigt als: `bc.eq`, `bc.ne`, `bc.hs`, `bc.lo`, `bc.mi`, `bc.pl`, `bc.vs`, `bc.vc`, `bc.hi`, `bc.ls`, `bc.ge`, `bc.lt`, `bc.gt`, `bc.le`, `bc.al`, `bc.nv`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bcax – Bitweises Löschen und exklusives ODER (SHA-3)

**Syntax:** `bcax Vd.16B, Vn.16B, Vm.16B, Va.16B`

**Wirkung:** `Vd = Vn ^ (Vm & ~Va)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bfm – Bitfeld verschieben

**Syntax:** `bfm Rd, Rn, #immr, #imms`

Bitfeld verschieben, übrige Bits von Rd bleiben (Grundform von bfi, bfxil).

**Wirkung:** `Rd = (Rd with the field replaced by the field of Rn)`

Auch angezeigt als: `bfc`, `bfi`, `bfxil`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bic – Bitweises UND mit invertiertem Operanden

**Syntax:** `bic Rd, Rn, Rm{, shift #imm6}` &nbsp; `bic Vd.T, Vn.T, Vm.T` &nbsp; `bic Vd.T, #imm8{, lsl #amount}`

Bitweises UND mit invertiertem Operanden (Bit löschen).

**Wirkung:** `Rd = Rn & ~shift(Rm, imm6)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bics – Bitweises UND mit invertiertem Operanden

**Syntax:** `bics Rd, Rn, Rm{, shift #imm6}`

Bitweises UND mit invertiertem Operanden, setzt die Flags.

**Wirkung:** `Rd = Rn & ~shift(Rm, imm6); C = V = 0`

**Flags:** N Z C V

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bif – Bitweises Einfügen

**Syntax:** `bif Vd.T, Vn.T, Vm.T`

Bitweises Einfügen, wenn das Bit in Vm gelöscht ist.

**Wirkung:** `Vd = (Vn & ~Vm) | (Vd & Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bit – Bitweises Einfügen, wenn das Bit in Vm gesetzt ist

**Syntax:** `bit Vd.T, Vn.T, Vm.T`

**Wirkung:** `Vd = (Vn & Vm) | (Vd & ~Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bl – Aufruf einer Funktion

**Syntax:** `bl label`

Aufruf einer Funktion (relativ, Rücksprungadresse nach x30).

**Wirkung:** `x30 = pc + 4; pc = pc + sext(imm26 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blr – Aufruf der Funktion an der Adresse im Register

**Syntax:** `blr Xn`

**Wirkung:** `x30 = pc + 4; pc = Xn`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blraa – Aufruf einer geprüften Adresse

**Syntax:** `blraa Xn, Xm|SP`

Aufruf einer geprüften Adresse (a = Schlüssel A, b = Schlüssel B, z = Modifizierer 0).

**Wirkung:** `x30 = pc + 4; pc = aut(Xn, key, Xm)`

Auch angezeigt als: `blrab`, `blraaz`, `blrabz`

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## br – Sprung zu der Adresse im Register

**Syntax:** `br Xn`

**Wirkung:** `pc = Xn`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## braa – Sprung zu einer geprüften Adresse

**Syntax:** `braa Xn, Xm|SP`

Sprung zu einer geprüften Adresse (a = Schlüssel A, b = Schlüssel B, z = Modifizierer 0).

**Wirkung:** `pc = aut(Xn, key, Xm); jump`

Auch angezeigt als: `brab`, `braaz`, `brabz`

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## brk – Haltepunkt (Debug-Ausnahme)

**Syntax:** `brk #imm16`

**Wirkung:** `raise a breakpoint exception with imm16`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bsl – Bitweise Auswahl: Das Ziel selbst ist die Maske

**Syntax:** `bsl Vd.T, Vn.T, Vm.T`

**Wirkung:** `Vd = (Vd & Vn) | (~Vd & Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cas – Atomares Vergleichen und Austauschen

**Syntax:** `cas Ws, Wt, [Xn|SP]`

Atomares Vergleichen und Austauschen (Compare and Swap): Ist der Speicherwert gleich Ws, wird Wt gespeichert; Ws erhält den alten Wert (Varianten: b, h, a, l).

**Wirkung:** `t = [Rn]; if t == Ws then [Rn] = Wt; Ws = t`

Auch angezeigt als: `casa`, `casal`, `casl`, `casb`, `casab`, `casalb`, `caslb`, `cash`, `casah`, `casalh`, `caslh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## casp – Atomares Vergleichen und Austauschen eines Registerpaares

**Syntax:** `casp Ws, Ws+1, Wt, Wt+1, [Xn|SP]`

Atomares Vergleichen und Austauschen eines Registerpaares (Varianten: a = Acquire, l = Release).

**Wirkung:** `t = [Rn] (pair); if t == Ws:Ws+1 then [Rn] = Wt:Wt+1; Ws:Ws+1 = t`

Auch angezeigt als: `caspa`, `caspal`, `caspl`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cbnz – Sprung, wenn das Register nicht 0 ist

**Syntax:** `cbnz Rt, label`

**Wirkung:** `if Rt != 0 then pc = pc + sext(imm19 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cbz – Sprung, wenn das Register 0 ist

**Syntax:** `cbz Rt, label`

**Wirkung:** `if Rt == 0 then pc = pc + sext(imm19 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ccmn – Bedingter Vergleich

**Syntax:** `ccmn Rn, Rm, #nzcv, cond` &nbsp; `ccmn Rn, #imm5, #nzcv, cond`

Bedingter Vergleich (Addition): Flags aus Rn + Rm, sonst aus nzcv.

**Wirkung:** `if cond then flags = compare(Rn + Rm) else flags = nzcv`

**Flags:** N Z C V

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ccmp – Bedingter Vergleich

**Syntax:** `ccmp Rn, Rm, #nzcv, cond` &nbsp; `ccmp Rn, #imm5, #nzcv, cond`

Bedingter Vergleich (Subtraktion): Flags aus Rn - Rm, sonst aus nzcv.

**Wirkung:** `if cond then flags = compare(Rn - Rm) else flags = nzcv`

**Flags:** N Z C V

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clrex – Löschen des Exklusiv-Monitors

**Syntax:** `clrex {#imm4}`

**Wirkung:** `clear the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cls – Zählen der führenden Bits gleich dem Vorzeichenbit

**Syntax:** `cls Rd, Rn` &nbsp; `cls Vd.T, Vn.T`

**Wirkung:** `Rd = count_leading_sign_bits(Rn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clz – Zählen der führenden Nullbits

**Syntax:** `clz Rd, Rn` &nbsp; `clz Vd.T, Vn.T`

**Wirkung:** `Rd = count_leading_zeros(Rn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmeq – Vergleich auf gleich, Ergebnis ist eine Maske

**Syntax:** `cmeq Vd.T, Vn.T, Vm.T` &nbsp; `cmeq Vd.T, Vn.T, #0`

**Wirkung:** `for every element: Vd[i] = (Vn[i] == Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmge – Vergleich auf größer oder gleich

**Syntax:** `cmge Vd.T, Vn.T, Vm.T` &nbsp; `cmge Vd.T, Vn.T, #0`

Vergleich auf größer oder gleich (mit Vorzeichen), Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmgt – Vergleich auf größer

**Syntax:** `cmgt Vd.T, Vn.T, Vm.T` &nbsp; `cmgt Vd.T, Vn.T, #0`

Vergleich auf größer (mit Vorzeichen), Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmhi – Vergleich auf größer

**Syntax:** `cmhi Vd.T, Vn.T, Vm.T`

Vergleich auf größer (ohne Vorzeichen), Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmhs – Vergleich auf größer oder gleich

**Syntax:** `cmhs Vd.T, Vn.T, Vm.T`

Vergleich auf größer oder gleich (ohne Vorzeichen), Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmle – Vergleich auf kleiner oder gleich null

**Syntax:** `cmle Vd.T, Vn.T, #0`

Vergleich auf kleiner oder gleich null, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] <= 0) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmlt – Vergleich auf kleiner als null

**Syntax:** `cmlt Vd.T, Vn.T, #0`

Vergleich auf kleiner als null, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] < 0) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmtst – Test auf gemeinsame gesetzte Bits

**Syntax:** `cmtst Vd.T, Vn.T, Vm.T`

Test auf gemeinsame gesetzte Bits, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = ((Vn[i] & Vm[i]) != 0) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cnt – Zählen der gesetzten Bits in jedem Byte

**Syntax:** `cnt Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = popcount(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpye – Kopieren eines Speicherblocks

**Syntax:** `cpye [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Abschluss (epilogue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpyewn`, `cpyern`, `cpyen`, `cpyewt`, `cpyewtwn`, `cpyewtrn`, `cpyewtn`, `cpyert`, `cpyertwn`, `cpyertrn`, `cpyertn`, `cpyet`, `cpyetwn`, `cpyetrn`, `cpyetn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpyfe – Kopieren eines Speicherblocks

**Syntax:** `cpyfe [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Abschluss (epilogue), nur vorwärts (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpyfewn`, `cpyfern`, `cpyfen`, `cpyfewt`, `cpyfewtwn`, `cpyfewtrn`, `cpyfewtn`, `cpyfert`, `cpyfertwn`, `cpyfertrn`, `cpyfertn`, `cpyfet`, `cpyfetwn`, `cpyfetrn`, `cpyfetn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpyfm – Kopieren eines Speicherblocks

**Syntax:** `cpyfm [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Hauptteil (main), nur vorwärts (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpyfmwn`, `cpyfmrn`, `cpyfmn`, `cpyfmwt`, `cpyfmwtwn`, `cpyfmwtrn`, `cpyfmwtn`, `cpyfmrt`, `cpyfmrtwn`, `cpyfmrtrn`, `cpyfmrtn`, `cpyfmt`, `cpyfmtwn`, `cpyfmtrn`, `cpyfmtn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpyfp – Kopieren eines Speicherblocks

**Syntax:** `cpyfp [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Vorbereitung (prologue), nur vorwärts (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpyfpwn`, `cpyfprn`, `cpyfpn`, `cpyfpwt`, `cpyfpwtwn`, `cpyfpwtrn`, `cpyfpwtn`, `cpyfprt`, `cpyfprtwn`, `cpyfprtrn`, `cpyfprtn`, `cpyfpt`, `cpyfptwn`, `cpyfptrn`, `cpyfptn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpym – Kopieren eines Speicherblocks

**Syntax:** `cpym [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Hauptteil (main) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpymwn`, `cpymrn`, `cpymn`, `cpymwt`, `cpymwtwn`, `cpymwtrn`, `cpymwtn`, `cpymrt`, `cpymrtwn`, `cpymrtrn`, `cpymrtn`, `cpymt`, `cpymtwn`, `cpymtrn`, `cpymtn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpyp – Kopieren eines Speicherblocks

**Syntax:** `cpyp [Xd]!, [Xs]!, Xn!`

Kopieren eines Speicherblocks, Vorbereitung (prologue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `copy Xn bytes from [Xs] to [Xd]; Xd, Xs, Xn are updated`

Auch angezeigt als: `cpypwn`, `cpyprn`, `cpypn`, `cpypwt`, `cpypwtwn`, `cpypwtrn`, `cpypwtn`, `cpyprt`, `cpyprtwn`, `cpyprtrn`, `cpyprtn`, `cpypt`, `cpyptwn`, `cpyptrn`, `cpyptn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32b – CRC-32-Prüfsumme

**Syntax:** `crc32b Wd, Wn, Wm`

CRC-32-Prüfsumme (Polynom 0x04C11DB7) über ein Byte.

**Wirkung:** `Wd = crc32(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32cb – CRC-32C-Prüfsumme

**Syntax:** `crc32cb Wd, Wn, Wm`

CRC-32C-Prüfsumme (Castagnoli, Polynom 0x1EDC6F41) über ein Byte.

**Wirkung:** `Wd = crc32c(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32ch – CRC-32C-Prüfsumme

**Syntax:** `crc32ch Wd, Wn, Wm`

CRC-32C-Prüfsumme (Castagnoli, Polynom 0x1EDC6F41) über ein Halbwort.

**Wirkung:** `Wd = crc32c(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32cw – CRC-32C-Prüfsumme

**Syntax:** `crc32cw Wd, Wn, Wm`

CRC-32C-Prüfsumme (Castagnoli, Polynom 0x1EDC6F41) über ein Wort.

**Wirkung:** `Wd = crc32c(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32cx – CRC-32C-Prüfsumme

**Syntax:** `crc32cx Wd, Wn, Xm`

CRC-32C-Prüfsumme (Castagnoli, Polynom 0x1EDC6F41) über ein Doppelwort.

**Wirkung:** `Wd = crc32c(Wn, Xm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32h – CRC-32-Prüfsumme

**Syntax:** `crc32h Wd, Wn, Wm`

CRC-32-Prüfsumme (Polynom 0x04C11DB7) über ein Halbwort.

**Wirkung:** `Wd = crc32(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32w – CRC-32-Prüfsumme

**Syntax:** `crc32w Wd, Wn, Wm`

CRC-32-Prüfsumme (Polynom 0x04C11DB7) über ein Wort.

**Wirkung:** `Wd = crc32(Wn, Wm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32x – CRC-32-Prüfsumme

**Syntax:** `crc32x Wd, Wn, Xm`

CRC-32-Prüfsumme (Polynom 0x04C11DB7) über ein Doppelwort.

**Wirkung:** `Wd = crc32(Wn, Xm)`

*Gruppe: CRC-Prüfsummen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csel – Bedingte Auswahl (Rn, wenn Bedingung, sonst Rm)

**Syntax:** `csel Rd, Rn, Rm, cond`

**Wirkung:** `Rd = cond ? Rn : Rm`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csinc – Bedingte Auswahl, sonst Rm + 1 (cset, cinc)

**Syntax:** `csinc Rd, Rn, Rm, cond`

**Wirkung:** `Rd = cond ? Rn : Rm + 1`

Auch angezeigt als: `cinc`, `cset`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csinv – Bedingte Auswahl, sonst invertiertes Rm

**Syntax:** `csinv Rd, Rn, Rm, cond`

**Wirkung:** `Rd = cond ? Rn : ~Rm`

Auch angezeigt als: `cinv`, `csetm`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## csneg – Bedingte Auswahl, sonst negiertes Rm

**Syntax:** `csneg Rd, Rn, Rm, cond`

**Wirkung:** `Rd = cond ? Rn : -Rm`

Auch angezeigt als: `cneg`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dcps1 – Wechsel in den Debug-Zustand auf der Ausnahmestufe 1

**Syntax:** `dcps1 {#imm16}`

Wechsel in den Debug-Zustand auf der Ausnahmestufe 1, 2 oder 3 (nur im Debug-Zustand).

**Wirkung:** `enter debug state at EL1, EL2 or EL3`

Auch angezeigt als: `dcps2`, `dcps3`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dmb – Speicherschranke für die Reihenfolge der Zugriffe

**Syntax:** `dmb option`

**Wirkung:** `earlier memory accesses are observed before later ones`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dsb – Speicherschranke

**Syntax:** `dsb option`

Speicherschranke: wartet, bis alle Zugriffe fertig sind.

**Wirkung:** `wait until all earlier memory accesses are complete`

Auch angezeigt als: `ssbb`, `pssbb`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dup – Kopieren eines Ganzzahl-Registers in alle Elemente

**Syntax:** `dup Vd.T, Rn` &nbsp; `dup Vd.T, Vn.Ts[index]`

**Wirkung:** `for every element: Vd[i] = Rn`

Auch angezeigt als: `mov`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eon – Bitweises exklusives ODER mit invertiertem Operanden

**Syntax:** `eon Rd, Rn, Rm{, shift #imm6}`

**Wirkung:** `Rd = Rn ^ ~shift(Rm, imm6)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eor – Bitweises exklusives ODER mit einem Bitmuster als Konstante

**Syntax:** `eor Rd, Rn, #imm (bit pattern)` &nbsp; `eor Rd, Rn, Rm{, shift #imm6}` &nbsp; `eor Vd.T, Vn.T, Vm.T`

**Wirkung:** `Rd = Rn ^ decode_bitmask(N, imms, immr) (Rd may be SP)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eor3 – Exklusiv-ODER dreier Vektoren (SHA-3)

**Syntax:** `eor3 Vd.16B, Vn.16B, Vm.16B, Va.16B`

**Wirkung:** `Vd = Vn ^ Vm ^ Va`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## eret – Rückkehr aus einer Ausnahme (privilegiert)

**Syntax:** `eret`

**Wirkung:** `pc = ELR; PSTATE = SPSR`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ext – Herausziehen eines Bytebereichs aus zwei aneinandergehängten Vektoren

**Syntax:** `ext Vd.T, Vn.T, Vm.T, #index`

**Wirkung:** `Vd = bytes index ... index + 15 of (Vm:Vn)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## extr – Auszug aus dem Registerpaar Rn:Rm ab Bit lsb

**Syntax:** `extr Rd, Rn, Rm, #lsb`

Auszug aus dem Registerpaar Rn:Rm ab Bit lsb (ror bei Rn = Rm).

**Wirkung:** `Rd = (Rn:Rm >> imms) low half`

Auch angezeigt als: `ror`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fabd – Absoluter Unterschied von Gleitkomma-Elementen

**Syntax:** `fabd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fabs – Betrag

**Syntax:** `fabs Fd, Fn` &nbsp; `fabs Vd.T, Vn.T`

**Wirkung:** `Fd = abs(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## facge – Vergleich der Beträge auf größer oder gleich

**Syntax:** `facge Vd.T, Vn.T, Vm.T`

Vergleich der Beträge auf größer oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (abs(Vn[i]) >= abs(Vm[i])) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## facgt – Vergleich der Beträge auf größer

**Syntax:** `facgt Vd.T, Vn.T, Vm.T`

Vergleich der Beträge auf größer, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (abs(Vn[i]) > abs(Vm[i])) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fadd – Addition

**Syntax:** `fadd Fd, Fn, Fm` &nbsp; `fadd Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = Fn + Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## faddp – Addition benachbarter Gleitkomma-Paare

**Syntax:** `faddp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = sum of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcadd – Addition komplexer Zahlen mit einer Drehung um 90 oder 270 Grad

**Syntax:** `fcadd Vd.T, Vn.T, Vm.T, #rot`

**Wirkung:** `Vd = Vn + rotate(Vm, rot)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fccmp – Bedingter Vergleich

**Syntax:** `fccmp Fn, Fm, #nzcv, cond`

Bedingter Vergleich: Flags aus Fn, Fm, sonst aus nzcv.

**Wirkung:** `if cond then flags = compare(Fn, Fm) else flags = nzcv`

**Flags:** N Z C V

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fccmpe – Bedingter Gleitkomma-Vergleich

**Syntax:** `fccmpe Fn, Fm, #nzcv, cond`

Bedingter Gleitkomma-Vergleich (mit Ausnahme bei NaN).

**Wirkung:** `if cond then flags = compare(Fn, Fm) else flags = nzcv`

**Flags:** N Z C V

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmeq – Gleitkomma-Vergleich auf gleich

**Syntax:** `fcmeq Vd.T, Vn.T, Vm.T` &nbsp; `fcmeq Vd.T, Vn.T, #0`

Gleitkomma-Vergleich auf gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] == Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmge – Gleitkomma-Vergleich auf größer oder gleich

**Syntax:** `fcmge Vd.T, Vn.T, Vm.T` &nbsp; `fcmge Vd.T, Vn.T, #0`

Gleitkomma-Vergleich auf größer oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] >= Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmgt – Gleitkomma-Vergleich auf größer

**Syntax:** `fcmgt Vd.T, Vn.T, Vm.T` &nbsp; `fcmgt Vd.T, Vn.T, #0`

Gleitkomma-Vergleich auf größer, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] > Vm[i]) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmla – Multiplikation komplexer Zahlen

**Syntax:** `fcmla Vd.T, Vn.T, Vm.T, #rot`

Multiplikation komplexer Zahlen (ein Teilschritt, Drehung 0, 90, 180 oder 270 Grad), addiert zum Ziel.

**Wirkung:** `Vd = Vd + partial_product(Vn, Vm, rot)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmle – Gleitkomma-Vergleich mit null auf kleiner oder gleich

**Syntax:** `fcmle Vd.T, Vn.T, #0`

Gleitkomma-Vergleich mit null auf kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] <= 0) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmlt – Gleitkomma-Vergleich mit null auf kleiner

**Syntax:** `fcmlt Vd.T, Vn.T, #0`

Gleitkomma-Vergleich mit null auf kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: Vd[i] = (Vn[i] < 0) ? all 1 bits : 0`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmp – Vergleich zweier Gleichkomma-Werte

**Syntax:** `fcmp Fn, Fm` &nbsp; `fcmp Fn, #0.0`

Vergleich zweier Gleichkomma-Werte, setzt die Flags.

**Wirkung:** `flags = compare(Fn, Fm) (unordered: N Z C V = 0 0 1 1)`

**Flags:** N Z C V

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmpe – Vergleich mit Ausnahme bei NaN

**Syntax:** `fcmpe Fn, Fm`

Vergleich mit Ausnahme bei NaN (signalisierend), setzt die Flags.

**Wirkung:** `flags = compare(Fn, Fm)`

**Flags:** N Z C V

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcsel – Bedingte Auswahl (Fn, wenn Bedingung, sonst Fm)

**Syntax:** `fcsel Fd, Fn, Fm, cond`

**Wirkung:** `Fd = cond ? Fn : Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvt – Umwandlung zwischen Genauigkeiten

**Syntax:** `fcvt Fd, Fn`

Umwandlung zwischen Genauigkeiten (half, single, double).

**Wirkung:** `Fd = convert(Fn) to the precision of Fd`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtas – Umwandlung in eine Ganzzahl mit Vorzeichen

**Syntax:** `fcvtas Rd, Fn` &nbsp; `fcvtas Vd.T, Vn.T`

Umwandlung in eine Ganzzahl mit Vorzeichen (zur nächsten, bei Gleichstand weg von null).

**Wirkung:** `Rd = (int) round_half_away(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtau – Umwandlung in eine Ganzzahl ohne Vorzeichen

**Syntax:** `fcvtau Rd, Fn` &nbsp; `fcvtau Vd.T, Vn.T`

Umwandlung in eine Ganzzahl ohne Vorzeichen (zur nächsten, bei Gleichstand weg von null).

**Wirkung:** `Rd = (uint) round_half_away(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtl – Umwandlung in die doppelte Genauigkeit

**Syntax:** `fcvtl Vd.Ta, Vn.Tb`

**Wirkung:** `for every element: Vd[i] = convert(Vn[i]) wider`

Auch angezeigt als: `fcvtl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtms – Umwandlung in eine Ganzzahl mit Vorzeichen

**Syntax:** `fcvtms Rd, Fn` &nbsp; `fcvtms Vd.T, Vn.T`

Umwandlung in eine Ganzzahl mit Vorzeichen (Richtung minus unendlich).

**Wirkung:** `Rd = (int) floor(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtmu – Umwandlung in eine Ganzzahl ohne Vorzeichen

**Syntax:** `fcvtmu Rd, Fn` &nbsp; `fcvtmu Vd.T, Vn.T`

Umwandlung in eine Ganzzahl ohne Vorzeichen (Richtung minus unendlich).

**Wirkung:** `Rd = (uint) floor(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtn – Umwandlung in die halbe Genauigkeit

**Syntax:** `fcvtn Vd.Tb, Vn.Ta`

**Wirkung:** `for every element: Vd[i] = convert(Vn[i]) narrower`

Auch angezeigt als: `fcvtn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtns – Umwandlung in eine Ganzzahl mit Vorzeichen

**Syntax:** `fcvtns Rd, Fn` &nbsp; `fcvtns Vd.T, Vn.T`

Umwandlung in eine Ganzzahl mit Vorzeichen (zur nächsten, gerade bei Gleichstand).

**Wirkung:** `Rd = (int) round_to_nearest_even(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtnu – Umwandlung in eine Ganzzahl ohne Vorzeichen

**Syntax:** `fcvtnu Rd, Fn` &nbsp; `fcvtnu Vd.T, Vn.T`

Umwandlung in eine Ganzzahl ohne Vorzeichen (zur nächsten, gerade bei Gleichstand).

**Wirkung:** `Rd = (uint) round_to_nearest_even(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtps – Umwandlung in eine Ganzzahl mit Vorzeichen

**Syntax:** `fcvtps Rd, Fn` &nbsp; `fcvtps Vd.T, Vn.T`

Umwandlung in eine Ganzzahl mit Vorzeichen (Richtung plus unendlich).

**Wirkung:** `Rd = (int) ceil(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtpu – Umwandlung in eine Ganzzahl ohne Vorzeichen

**Syntax:** `fcvtpu Rd, Fn` &nbsp; `fcvtpu Vd.T, Vn.T`

Umwandlung in eine Ganzzahl ohne Vorzeichen (Richtung plus unendlich).

**Wirkung:** `Rd = (uint) ceil(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtxn – Umwandlung in die halbe Genauigkeit

**Syntax:** `fcvtxn Vd.Tb, Vn.Ta`

Umwandlung in die halbe Genauigkeit (Runden zur ungeraden Zahl).

**Wirkung:** `for every element: Vd[i] = convert_round_to_odd(Vn[i])`

Auch angezeigt als: `fcvtxn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtzs – Umwandlung in eine Ganzzahl mit Vorzeichen

**Syntax:** `fcvtzs Rd, Fn` &nbsp; `fcvtzs Vd.T, Vn.T`

Umwandlung in eine Ganzzahl mit Vorzeichen (abgeschnitten, Richtung null).

**Wirkung:** `Rd = (int) trunc(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcvtzu – Umwandlung in eine Ganzzahl ohne Vorzeichen

**Syntax:** `fcvtzu Rd, Fn` &nbsp; `fcvtzu Vd.T, Vn.T`

Umwandlung in eine Ganzzahl ohne Vorzeichen (abgeschnitten, Richtung null).

**Wirkung:** `Rd = (uint) trunc(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdiv – Division

**Syntax:** `fdiv Fd, Fn, Fm` &nbsp; `fdiv Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = Fn / Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fjcvtzs – Umwandlung in eine Ganzzahl nach JavaScript-Regeln

**Syntax:** `fjcvtzs Wd, Dn`

Umwandlung in eine Ganzzahl nach JavaScript-Regeln (Ergebnis modulo 2^32).

**Wirkung:** `Wd = javascript_to_int32(Dn)`

**Flags:** N Z C V

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmadd – Multiplikation mit Addition

**Syntax:** `fmadd Fd, Fn, Fm, Fa`

Multiplikation mit Addition (verschmolzen, Fa + Fn * Fm).

**Wirkung:** `Fd = Fa + Fn * Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmax – Maximum (NaN breitet sich aus)

**Syntax:** `fmax Fd, Fn, Fm` &nbsp; `fmax Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = max(Fn, Fm)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmaxnm – Maximum (eine Zahl gewinnt gegen NaN)

**Syntax:** `fmaxnm Fd, Fn, Fm` &nbsp; `fmaxnm Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = maxnum(Fn, Fm)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmaxnmp – Maximum benachbarter Gleitkomma-Paare

**Syntax:** `fmaxnmp Vd.T, Vn.T, Vm.T`

Maximum benachbarter Gleitkomma-Paare (eine Zahl gewinnt gegen NaN).

**Wirkung:** `for every element: Vd[i] = maxnum of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmaxnmv – Maximum aller Gleitkomma-Elemente

**Syntax:** `fmaxnmv Sd, Vn.4S`

Maximum aller Gleitkomma-Elemente (eine Zahl gewinnt gegen NaN).

**Wirkung:** `Sd = maxnum of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmaxp – Maximum benachbarter Gleitkomma-Paare

**Syntax:** `fmaxp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = max of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmaxv – Maximum aller Gleitkomma-Elemente

**Syntax:** `fmaxv Sd, Vn.4S`

**Wirkung:** `Sd = max of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmin – Minimum (NaN breitet sich aus)

**Syntax:** `fmin Fd, Fn, Fm` &nbsp; `fmin Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = min(Fn, Fm)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fminnm – Minimum (eine Zahl gewinnt gegen NaN)

**Syntax:** `fminnm Fd, Fn, Fm` &nbsp; `fminnm Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = minnum(Fn, Fm)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fminnmp – Minimum benachbarter Gleitkomma-Paare

**Syntax:** `fminnmp Vd.T, Vn.T, Vm.T`

Minimum benachbarter Gleitkomma-Paare (eine Zahl gewinnt gegen NaN).

**Wirkung:** `for every element: Vd[i] = minnum of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fminnmv – Minimum aller Gleitkomma-Elemente

**Syntax:** `fminnmv Sd, Vn.4S`

Minimum aller Gleitkomma-Elemente (eine Zahl gewinnt gegen NaN).

**Wirkung:** `Sd = minnum of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fminp – Minimum benachbarter Gleitkomma-Paare

**Syntax:** `fminp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = min of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fminv – Minimum aller Gleitkomma-Elemente

**Syntax:** `fminv Sd, Vn.4S`

**Wirkung:** `Sd = min of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmla – Multiplikation mit Addition zum Ziel (Gleitkomma)

**Syntax:** `fmla Vd.T, Vn.T, Vm.T` &nbsp; `fmla Vd.T, Vn.T, Vm.Ts[index]`

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmlal – Multiplikation von Halbwert-Zahlen mit Verbreiterung auf Single

**Syntax:** `fmlal Vd.2S, Vn.2H, Vm.2H`

Multiplikation von Halbwert-Zahlen mit Verbreiterung auf Single, addiert zum Ziel (untere Hälfte).

**Wirkung:** `for every element: Vd[i] = Vd[i] + float(Vn[i]) * float(Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmlal2 – Wie fmlal, aber mit der oberen Hälfte der Quellen

**Syntax:** `fmlal2 Vd.2S, Vn.2H, Vm.2H`

**Wirkung:** `for every element: Vd[i] = Vd[i] + float(Vn[i + n]) * float(Vm[i + n])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmls – Multiplikation mit Subtraktion vom Ziel

**Syntax:** `fmls Vd.T, Vn.T, Vm.T` &nbsp; `fmls Vd.T, Vn.T, Vm.Ts[index]`

Multiplikation mit Subtraktion vom Ziel (Gleitkomma).

**Wirkung:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmlsl – Multiplikation von Halbwert-Zahlen mit Verbreiterung auf Single

**Syntax:** `fmlsl Vd.2S, Vn.2H, Vm.2H`

Multiplikation von Halbwert-Zahlen mit Verbreiterung auf Single, subtrahiert vom Ziel (untere Hälfte).

**Wirkung:** `for every element: Vd[i] = Vd[i] - float(Vn[i]) * float(Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmlsl2 – Wie fmlsl, aber mit der oberen Hälfte der Quellen

**Syntax:** `fmlsl2 Vd.2S, Vn.2H, Vm.2H`

**Wirkung:** `for every element: Vd[i] = Vd[i] - float(Vn[i + n]) * float(Vm[i + n])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmov – Kopieren eines Gleitkomma-Registers

**Syntax:** `fmov Fd, Fn` &nbsp; `fmov Fd, #imm` &nbsp; `fmov Wd, Sn` &nbsp; `fmov Sd, Wn` &nbsp; `fmov Xd, Dn` &nbsp; `fmov Dd, Xn` &nbsp; `fmov Vd.T, #imm8{, lsl #amount}`

**Wirkung:** `Fd = Fn`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmsub – Multiplikation mit Subtraktion

**Syntax:** `fmsub Fd, Fn, Fm, Fa`

Multiplikation mit Subtraktion (verschmolzen, Fa - Fn * Fm).

**Wirkung:** `Fd = Fa - Fn * Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmul – Multiplikation

**Syntax:** `fmul Fd, Fn, Fm` &nbsp; `fmul Vd.T, Vn.T, Vm.T` &nbsp; `fmul Vd.T, Vn.T, Vm.Ts[index]`

**Wirkung:** `Fd = Fn * Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmulx – Multiplikation von Gleitkomma-Elementen

**Syntax:** `fmulx Vd.T, Vn.T, Vm.T` &nbsp; `fmulx Vd.T, Vn.T, Vm.Ts[index]`

Multiplikation von Gleitkomma-Elementen (0 mal unendlich ergibt 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fneg – Vorzeichenwechsel

**Syntax:** `fneg Fd, Fn` &nbsp; `fneg Vd.T, Vn.T`

**Wirkung:** `Fd = -Fn`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnmadd – Negierte Multiplikation mit Addition

**Syntax:** `fnmadd Fd, Fn, Fm, Fa`

Negierte Multiplikation mit Addition (verschmolzen).

**Wirkung:** `Fd = -Fa - Fn * Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnmsub – Negierte Multiplikation mit Subtraktion

**Syntax:** `fnmsub Fd, Fn, Fm, Fa`

Negierte Multiplikation mit Subtraktion (verschmolzen).

**Wirkung:** `Fd = -Fa + Fn * Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnmul – Multiplikation mit Vorzeichenwechsel

**Syntax:** `fnmul Fd, Fn, Fm`

**Wirkung:** `Fd = -(Fn * Fm)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frecpe – Schätzung des Kehrwertes

**Syntax:** `frecpe Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = estimate(1 / Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frecps – Schritt der Newton-Raphson-Iteration für den Kehrwert

**Syntax:** `frecps Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = 2 - Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frecpx – Schätzung des Kehrwertes eines Exponenten (skalar)

**Syntax:** `frecpx Fd, Fn`

**Wirkung:** `Fd = reciprocal_exponent(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frint32x – Runden auf eine ganze Zahl

**Syntax:** `frint32x Vd.T, Vn.T`

Runden auf eine ganze Zahl, die in 32 Bit passt (nach dem aktuellen Rundungsmodus).

**Wirkung:** `for every element: Vd[i] = round32(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frint32z – Runden auf eine ganze Zahl

**Syntax:** `frint32z Vd.T, Vn.T`

Runden auf eine ganze Zahl, die in 32 Bit passt (Richtung null).

**Wirkung:** `for every element: Vd[i] = trunc32(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frint64x – Runden auf eine ganze Zahl

**Syntax:** `frint64x Vd.T, Vn.T`

Runden auf eine ganze Zahl, die in 64 Bit passt (nach dem aktuellen Rundungsmodus).

**Wirkung:** `for every element: Vd[i] = round64(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frint64z – Runden auf eine ganze Zahl

**Syntax:** `frint64z Vd.T, Vn.T`

Runden auf eine ganze Zahl, die in 64 Bit passt (Richtung null).

**Wirkung:** `for every element: Vd[i] = trunc64(Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frinta – Runden auf eine ganze Zahl

**Syntax:** `frinta Fd, Fn` &nbsp; `frinta Vd.T, Vn.T`

Runden auf eine ganze Zahl (zur nächsten, bei Gleichstand weg von null).

**Wirkung:** `Fd = round_half_away(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frinti – Runden auf eine ganze Zahl

**Syntax:** `frinti Fd, Fn` &nbsp; `frinti Vd.T, Vn.T`

Runden auf eine ganze Zahl (Modus des Steuerregisters).

**Wirkung:** `Fd = round(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frintm – Runden auf eine ganze Zahl

**Syntax:** `frintm Fd, Fn` &nbsp; `frintm Vd.T, Vn.T`

Runden auf eine ganze Zahl (Richtung minus unendlich).

**Wirkung:** `Fd = floor(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frintn – Runden auf eine ganze Zahl

**Syntax:** `frintn Fd, Fn` &nbsp; `frintn Vd.T, Vn.T`

Runden auf eine ganze Zahl (zur nächsten, gerade bei Gleichstand).

**Wirkung:** `Fd = round_to_nearest_even(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frintp – Runden auf eine ganze Zahl

**Syntax:** `frintp Fd, Fn` &nbsp; `frintp Vd.T, Vn.T`

Runden auf eine ganze Zahl (Richtung plus unendlich).

**Wirkung:** `Fd = ceil(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frintx – Runden auf eine ganze Zahl

**Syntax:** `frintx Fd, Fn` &nbsp; `frintx Vd.T, Vn.T`

Runden auf eine ganze Zahl (Modus des Steuerregisters, meldet Ungenauigkeit).

**Wirkung:** `Fd = round(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frintz – Runden auf eine ganze Zahl (Richtung null)

**Syntax:** `frintz Fd, Fn` &nbsp; `frintz Vd.T, Vn.T`

**Wirkung:** `Fd = trunc(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frsqrte – Schätzung des reziproken Wurzelwertes

**Syntax:** `frsqrte Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = estimate(1 / sqrt(Vn[i]))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frsqrts – Schritt der Newton-Raphson-Iteration für den reziproken Wurzelwert

**Syntax:** `frsqrts Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = (3 - Vn[i] * Vm[i]) / 2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsqrt – Quadratwurzel

**Syntax:** `fsqrt Fd, Fn` &nbsp; `fsqrt Vd.T, Vn.T`

**Wirkung:** `Fd = sqrt(Fn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsub – Subtraktion

**Syntax:** `fsub Fd, Fn, Fm` &nbsp; `fsub Vd.T, Vn.T, Vm.T`

**Wirkung:** `Fd = Fn - Fm`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## gmi – Aufnahme eines Tags in eine Ausschlussmaske

**Syntax:** `gmi Xd, Xn|SP, Xm`

**Wirkung:** `Xd = Xm | (1 << tag of Xn)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hint – Hinweis an den Prozessor

**Syntax:** `hint #imm7`

Hinweis an den Prozessor (nop, yield, wfe, wfi, sev, bti ...).

**Wirkung:** `no change of the program (a hint)`

Auch angezeigt als: `nop`, `yield`, `wfe`, `wfi`, `sev`, `sevl`, `bti`, `csdb`, `esb`, `psb`, `tsb`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hlt – Anhalten für einen Debugger

**Syntax:** `hlt #imm16`

**Wirkung:** `enter debug state`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hvc – Aufruf des Hypervisors (Ausnahmestufe 2)

**Syntax:** `hvc #imm16`

**Wirkung:** `raise a hypervisor call exception`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ins – Einfügen eines Ganzzahl-Registers in ein Element

**Syntax:** `ins Vd.Ts[index], Rn`

**Wirkung:** `Vd[index] = Rn`

Auch angezeigt als: `mov`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## irg – Einfügen eines zufälligen Tags in eine Adresse

**Syntax:** `irg Xd|SP, Xn|SP{, Xm}`

**Wirkung:** `Xd = Xn with a random tag (not in the exclude mask Xm)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## isb – Befehlsschranke: leert die Pipeline

**Syntax:** `isb {#imm4}`

**Wirkung:** `all instructions after it are fetched anew`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld1 – Laden eines Vektor-Registers aus dem Speicher

**Syntax:** `ld1 {Vt.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `ld1 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `ld1 {Vt.Ts}[index], [Xn|SP]`

Laden eines Vektor-Registers aus dem Speicher (ein Register).

**Wirkung:** `Vt = [Rn]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld1r – Laden eines Elements aus dem Speicher in alle Elemente von 1 Registern

**Syntax:** `ld1r {Vt.T}, [Xn|SP]`

Laden eines Elements aus dem Speicher in alle Elemente von 1 Registern (Replizieren).

**Wirkung:** `every element of every register = [Rn]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld2 – Laden von 2 Register

**Syntax:** `ld2 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `ld2 {Vt.T, Vt2.T}, [Xn|SP], Xm|#imm` &nbsp; `ld2 {Vt.Ts, Vt2.Ts}[index], [Xn|SP]`

Laden von 2 Register (Elemente abwechselnd) aus dem Speicher.

**Wirkung:** `registers = [Rn] (2 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld2r – Laden eines Elements aus dem Speicher in alle Elemente von 2 Registern

**Syntax:** `ld2r {Vt.T, Vt2.T}, [Xn|SP]`

Laden eines Elements aus dem Speicher in alle Elemente von 2 Registern (Replizieren).

**Wirkung:** `every element of every register = [Rn]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld3 – Laden von 3 Register

**Syntax:** `ld3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `ld3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP], Xm|#imm` &nbsp; `ld3 {Vt.Ts, Vt2.Ts, Vt3.Ts}[index], [Xn|SP]`

Laden von 3 Register (Elemente abwechselnd) aus dem Speicher.

**Wirkung:** `registers = [Rn] (3 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld3r – Laden eines Elements aus dem Speicher in alle Elemente von 3 Registern

**Syntax:** `ld3r {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]`

Laden eines Elements aus dem Speicher in alle Elemente von 3 Registern (Replizieren).

**Wirkung:** `every element of every register = [Rn]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld4 – Laden von 4 Register

**Syntax:** `ld4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `ld4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP], Xm|#imm` &nbsp; `ld4 {Vt.Ts, Vt2.Ts, Vt3.Ts, Vt4.Ts}[index], [Xn|SP]`

Laden von 4 Register (Elemente abwechselnd) aus dem Speicher.

**Wirkung:** `registers = [Rn] (4 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ld4r – Laden eines Elements aus dem Speicher in alle Elemente von 4 Registern

**Syntax:** `ld4r {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]`

Laden eines Elements aus dem Speicher in alle Elemente von 4 Registern (Replizieren).

**Wirkung:** `every element of every register = [Rn]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldadd – Atomare Operation im Speicher

**Syntax:** `ldadd Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Addition des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = t + Ws; Wt = t`

Auch angezeigt als: `ldadda`, `ldaddal`, `ldaddl`, `ldaddb`, `ldaddab`, `ldaddalb`, `ldaddlb`, `ldaddh`, `ldaddah`, `ldaddalh`, `ldaddlh`, `staddb`, `staddh`, `stadd`, `staddl`, `staddlb`, `staddlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldapr – Laden mit Release-Consistency

**Syntax:** `ldapr Wt, [Xn|SP]`

Laden mit Release-Consistency (Acquire nur für frühere Speicherzugriffe, Variante RCpc; b = Byte, h = Halbwort).

**Wirkung:** `Wt = [Rn]`

Auch angezeigt als: `ldaprb`, `ldaprh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldapur – Laden mit Acquire

**Syntax:** `ldapur Wt, [Xn|SP{, #imm9}]`

Laden mit Acquire (RCpc, ohne Skalierung, Adresse: Rn + imm9; b = Byte, h = Halbwort).

**Wirkung:** `Wt = [Rn + imm9]`

Auch angezeigt als: `ldapurb`, `ldapurh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldapursb – Laden mit Acquire

**Syntax:** `ldapursb Xt, [Xn|SP{, #imm9}]`

Laden mit Acquire (RCpc), mit Vorzeichen auf 64 Bit erweitert (b = Byte, h = Halbwort, w = Wort).

**Wirkung:** `Xt = sext([Rn + imm9])`

Auch angezeigt als: `ldapursh`, `ldapursw`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldar – Laden mit Erwerb (acquire) (Wort)

**Syntax:** `ldar Wt, [Xn|SP]` &nbsp; `ldar Xt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldarb – Laden mit Erwerb (acquire) (Byte)

**Syntax:** `ldarb Wt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldarh – Laden mit Erwerb (acquire) (Halbwort)

**Syntax:** `ldarh Wt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldaxp – Laden eines Registerpaares (exklusiv) mit Erwerb

**Syntax:** `ldaxp Rt, Rt2, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; Rt2 = [Rn + size]; acquire; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldaxr – Laden (exklusiv) mit Erwerb (acquire) (Wort)

**Syntax:** `ldaxr Wt, [Xn|SP]` &nbsp; `ldaxr Xt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldaxrb – Laden (exklusiv) mit Erwerb (acquire) (Byte)

**Syntax:** `ldaxrb Wt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldaxrh – Laden (exklusiv) mit Erwerb (acquire) (Halbwort)

**Syntax:** `ldaxrh Wt, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; acquire; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldclr – Atomare Operation im Speicher

**Syntax:** `ldclr Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Löschen von Bits (UND mit dem invertierten Operanden) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = t & ~Ws; Wt = t`

Auch angezeigt als: `ldclra`, `ldclral`, `ldclrl`, `ldclrb`, `ldclrab`, `ldclralb`, `ldclrlb`, `ldclrh`, `ldclrah`, `ldclralh`, `ldclrlh`, `stclrb`, `stclrh`, `stclr`, `stclrl`, `stclrlb`, `stclrlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldeor – Atomare Operation im Speicher

**Syntax:** `ldeor Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: exklusives ODER des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = t ^ Ws; Wt = t`

Auch angezeigt als: `ldeora`, `ldeoral`, `ldeorl`, `ldeorb`, `ldeorab`, `ldeoralb`, `ldeorlb`, `ldeorh`, `ldeorah`, `ldeoralh`, `ldeorlh`, `steorb`, `steorh`, `steor`, `steorl`, `steorlb`, `steorlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldg – Laden des Tags aus dem Speicher in eine Adresse

**Syntax:** `ldg Xt, [Xn|SP{, #imm9}]`

**Wirkung:** `Xt = Xt with tag of [Rn + imm9 * 16]`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldlar – Laden mit Acquire für eine Speicher-Region mit Ordnung

**Syntax:** `ldlar Wt, [Xn|SP]`

Laden mit Acquire für eine Speicher-Region mit Ordnung (LORegion; b = Byte, h = Halbwort).

**Wirkung:** `Wt = [Rn]`

Auch angezeigt als: `ldlarb`, `ldlarh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldnp – Laden eines Registerpaares ohne Cache-Hinweis

**Syntax:** `ldnp Rt, Rt2, [Xn|SP{, #imm7}]`

**Wirkung:** `Rt = [addr]; Rt2 = [addr + size]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldp – Laden eines Registerpaares (Nach-Indizierung)

**Syntax:** `ldp Rt, Rt2, [Xn|SP], #imm7` &nbsp; `ldp Rt, Rt2, [Xn|SP{, #imm7}]` &nbsp; `ldp Rt, Rt2, [Xn|SP, #imm7]!` &nbsp; `ldp Ft, Ft2, [Xn|SP{, #imm7}]`

**Wirkung:** `Rt = [addr]; Rt2 = [addr + size]; addr = Rn; Rn = Rn + imm7 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldpsw – Laden eines Paares von Wörtern mit Vorzeichen

**Syntax:** `ldpsw Xt, Xt2, [Xn|SP], #imm7` &nbsp; `ldpsw Xt, Xt2, [Xn|SP{, #imm7}]` &nbsp; `ldpsw Xt, Xt2, [Xn|SP, #imm7]!`

Laden eines Paares von Wörtern mit Vorzeichen (Nach-Indizierung).

**Wirkung:** `Xt = sext([addr]); Xt2 = sext([addr + 4]); addr = Rn; Rn = Rn + imm7 * 4`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldr – Laden eines Wortes

**Syntax:** `ldr Wt, [Xn|SP{, #imm12}]` &nbsp; `ldr Wt, [Xn|SP, #imm9]!` &nbsp; `ldr Wt, [Xn|SP], #imm9` &nbsp; `ldr Wt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldr Xt, [Xn|SP{, #imm12}]` &nbsp; `ldr Xt, [Xn|SP, #imm9]!` &nbsp; `ldr Xt, [Xn|SP], #imm9` &nbsp; `ldr Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; …

Laden eines Wortes (32 Bit) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Wt = [addr]; addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldraa – Laden mit geprüfter Basisadresse

**Syntax:** `ldraa Xt, [Xn|SP{, #simm10}]`

Laden mit geprüfter Basisadresse (a = Schlüssel A, b = Schlüssel B; optional mit Vor-Indizierung).

**Wirkung:** `Xt = [aut(Xn, key, 0) + simm10 * 8]`

Auch angezeigt als: `ldrab`

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrb – Laden eines Bytes

**Syntax:** `ldrb Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrb Wt, [Xn|SP, #imm9]!` &nbsp; `ldrb Wt, [Xn|SP], #imm9` &nbsp; `ldrb Wt, [Xn|SP, Rm{, extend {#amount}}]`

Laden eines Bytes (mit Nullen erweitert) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Wt = zext([addr]); addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrh – Laden eines Halbwortes

**Syntax:** `ldrh Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrh Wt, [Xn|SP, #imm9]!` &nbsp; `ldrh Wt, [Xn|SP], #imm9` &nbsp; `ldrh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Laden eines Halbwortes (mit Nullen erweitert) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Wt = zext([addr]); addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsb – Laden eines Bytes

**Syntax:** `ldrsb Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsb Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsb Xt, [Xn|SP], #imm9` &nbsp; `ldrsb Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsb Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrsb Wt, [Xn|SP, #imm9]!` &nbsp; `ldrsb Wt, [Xn|SP], #imm9` &nbsp; `ldrsb Wt, [Xn|SP, Rm{, extend {#amount}}]`

Laden eines Bytes (mit Vorzeichen auf 64 Bit erweitert) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsh – Laden eines Halbwortes

**Syntax:** `ldrsh Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsh Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsh Xt, [Xn|SP], #imm9` &nbsp; `ldrsh Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsh Wt, [Xn|SP{, #imm12}]` &nbsp; `ldrsh Wt, [Xn|SP, #imm9]!` &nbsp; `ldrsh Wt, [Xn|SP], #imm9` &nbsp; `ldrsh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Laden eines Halbwortes (mit Vorzeichen auf 64 Bit erweitert) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldrsw – Laden eines Wortes

**Syntax:** `ldrsw Xt, [Xn|SP{, #imm12}]` &nbsp; `ldrsw Xt, [Xn|SP, #imm9]!` &nbsp; `ldrsw Xt, [Xn|SP], #imm9` &nbsp; `ldrsw Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `ldrsw Xt, label`

Laden eines Wortes (mit Vorzeichen auf 64 Bit erweitert) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldset – Atomare Operation im Speicher

**Syntax:** `ldset Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Setzen von Bits (ODER) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = t | Ws; Wt = t`

Auch angezeigt als: `ldseta`, `ldsetal`, `ldsetl`, `ldsetb`, `ldsetab`, `ldsetalb`, `ldsetlb`, `ldseth`, `ldsetah`, `ldsetalh`, `ldsetlh`, `stsetb`, `stseth`, `stset`, `stsetl`, `stsetlb`, `stsetlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldsmax – Atomare Operation im Speicher

**Syntax:** `ldsmax Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Maximum (mit Vorzeichen) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = max_signed(t, Ws); Wt = t`

Auch angezeigt als: `ldsmaxa`, `ldsmaxal`, `ldsmaxl`, `ldsmaxb`, `ldsmaxab`, `ldsmaxalb`, `ldsmaxlb`, `ldsmaxh`, `ldsmaxah`, `ldsmaxalh`, `ldsmaxlh`, `stsmaxb`, `stsmaxh`, `stsmax`, `stsmaxl`, `stsmaxlb`, `stsmaxlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldsmin – Atomare Operation im Speicher

**Syntax:** `ldsmin Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Minimum (mit Vorzeichen) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = min_signed(t, Ws); Wt = t`

Auch angezeigt als: `ldsmina`, `ldsminal`, `ldsminl`, `ldsminb`, `ldsminab`, `ldsminalb`, `ldsminlb`, `ldsminh`, `ldsminah`, `ldsminalh`, `ldsminlh`, `stsminb`, `stsminh`, `stsmin`, `stsminl`, `stsminlb`, `stsminlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldtr – Laden mit den Rechten des Anwendungs-Modus

**Syntax:** `ldtr Wt, [Xn|SP{, #imm9}]`

Laden mit den Rechten des Anwendungs-Modus (unprivilegiert; b = Byte, h = Halbwort).

**Wirkung:** `Wt = [Rn + imm9]`

Auch angezeigt als: `ldtrb`, `ldtrh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldtrsb – Laden mit den Rechten des Anwendungs-Modus

**Syntax:** `ldtrsb Xt, [Xn|SP{, #imm9}]`

Laden mit den Rechten des Anwendungs-Modus, mit Vorzeichen auf 64 Bit erweitert (b = Byte, h = Halbwort, w = Wort).

**Wirkung:** `Xt = sext([Rn + imm9])`

Auch angezeigt als: `ldtrsh`, `ldtrsw`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldumax – Atomare Operation im Speicher

**Syntax:** `ldumax Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Maximum (ohne Vorzeichen) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = max_unsigned(t, Ws); Wt = t`

Auch angezeigt als: `ldumaxa`, `ldumaxal`, `ldumaxl`, `ldumaxb`, `ldumaxab`, `ldumaxalb`, `ldumaxlb`, `ldumaxh`, `ldumaxah`, `ldumaxalh`, `ldumaxlh`, `stumaxb`, `stumaxh`, `stumax`, `stumaxl`, `stumaxlb`, `stumaxlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldumin – Atomare Operation im Speicher

**Syntax:** `ldumin Ws, Wt, [Xn|SP]`

Atomare Operation im Speicher: Minimum (ohne Vorzeichen) des Speicherwertes und eines Registers, der alte Wert kommt ins Zielregister (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release, st... ohne Zielregister).

**Wirkung:** `t = [Rn]; [Rn] = min_unsigned(t, Ws); Wt = t`

Auch angezeigt als: `ldumina`, `lduminal`, `lduminl`, `lduminb`, `lduminab`, `lduminalb`, `lduminlb`, `lduminh`, `lduminah`, `lduminalh`, `lduminlh`, `stuminb`, `stuminh`, `stumin`, `stuminl`, `stuminlb`, `stuminlh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldur – Laden eines Wortes

**Syntax:** `ldur Wt, [Xn|SP{, #imm9}]` &nbsp; `ldur Xt, [Xn|SP{, #imm9}]`

Laden eines Wortes (32 Bit) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Wt = [addr]; addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldurb – Laden eines Bytes

**Syntax:** `ldurb Wt, [Xn|SP{, #imm9}]`

Laden eines Bytes (mit Nullen erweitert) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Wt = zext([addr]); addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldurh – Laden eines Halbwortes

**Syntax:** `ldurh Wt, [Xn|SP{, #imm9}]`

Laden eines Halbwortes (mit Nullen erweitert) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Wt = zext([addr]); addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldursb – Laden eines Bytes

**Syntax:** `ldursb Xt, [Xn|SP{, #imm9}]` &nbsp; `ldursb Wt, [Xn|SP{, #imm9}]`

Laden eines Bytes (mit Vorzeichen auf 64 Bit erweitert) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldursh – Laden eines Halbwortes

**Syntax:** `ldursh Xt, [Xn|SP{, #imm9}]` &nbsp; `ldursh Wt, [Xn|SP{, #imm9}]`

Laden eines Halbwortes (mit Vorzeichen auf 64 Bit erweitert) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldursw – Laden eines Wortes

**Syntax:** `ldursw Xt, [Xn|SP{, #imm9}]`

Laden eines Wortes (mit Vorzeichen auf 64 Bit erweitert) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `Xt = sext([addr]); addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldxp – Laden eines Registerpaares (exklusiv)

**Syntax:** `ldxp Rt, Rt2, [Xn|SP]`

**Wirkung:** `Rt = [Rn]; Rt2 = [Rn + size]; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldxr – Laden (exklusiv)

**Syntax:** `ldxr Wt, [Xn|SP]` &nbsp; `ldxr Xt, [Xn|SP]`

Laden (exklusiv): setzt den Exklusiv-Monitor (Wort).

**Wirkung:** `Rt = [Rn]; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldxrb – Laden (exklusiv)

**Syntax:** `ldxrb Wt, [Xn|SP]`

Laden (exklusiv): setzt den Exklusiv-Monitor (Byte).

**Wirkung:** `Rt = [Rn]; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldxrh – Laden (exklusiv)

**Syntax:** `ldxrh Wt, [Xn|SP]`

Laden (exklusiv): setzt den Exklusiv-Monitor (Halbwort).

**Wirkung:** `Rt = [Rn]; set the exclusive monitor`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lslv – Schieben nach links um ein Register

**Syntax:** `lslv Rd, Rn, Rm`

Schieben nach links um ein Register (Betrag modulo Breite).

**Wirkung:** `Rd = Rn << (Rm mod width)`

Auch angezeigt als: `lsl`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsrv – Schieben nach rechts ohne Vorzeichen um ein Register

**Syntax:** `lsrv Rd, Rn, Rm`

**Wirkung:** `Rd = Rn >> (Rm mod width)`

Auch angezeigt als: `lsr`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## madd – Multiplikation mit Addition (Ra + Rn * Rm)

**Syntax:** `madd Rd, Rn, Rm, Ra`

**Wirkung:** `Rd = Ra + Rn * Rm`

Auch angezeigt als: `mul`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mla – Multiplikation mit Addition zum Ziel

**Syntax:** `mla Vd.T, Vn.T, Vm.T` &nbsp; `mla Vd.T, Vn.T, Vm.Ts[index]`

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mls – Multiplikation mit Subtraktion vom Ziel

**Syntax:** `mls Vd.T, Vn.T, Vm.T` &nbsp; `mls Vd.T, Vn.T, Vm.Ts[index]`

**Wirkung:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movi – Laden einer 32-Bit-Konstante

**Syntax:** `movi Vd.T, #imm8{, lsl #amount}`

Laden einer 32-Bit-Konstante (ein Byte, geschoben) in alle Elemente.

**Wirkung:** `Vd = imm8 << (8 * cm) in every 32 bits`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movk – 16 Bit einer Konstante in ein Register einfügen

**Syntax:** `movk Rd, #imm16{, lsl #shift}`

16 Bit einer Konstante in ein Register einfügen, übrige Bits bleiben.

**Wirkung:** `Rd[hw*16 + 15 : hw*16] = imm16`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movn – Konstante invertiert in ein Register laden

**Syntax:** `movn Rd, #imm16{, lsl #shift}`

Konstante invertiert in ein Register laden (16 Bit, um 0/16/32/48 verschoben).

**Wirkung:** `Rd = ~(imm16 << (hw * 16))`

Auch angezeigt als: `mov`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movz – Konstante in ein Register laden

**Syntax:** `movz Rd, #imm16{, lsl #shift}`

Konstante in ein Register laden (16 Bit, um 0/16/32/48 verschoben, Rest 0).

**Wirkung:** `Rd = imm16 << (hw * 16)`

Auch angezeigt als: `mov`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mrs – Lesen eines Systemregisters

**Syntax:** `mrs Xt, sysreg`

**Wirkung:** `Xt = sysreg`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## msr – Schreiben eines Systemregisters

**Syntax:** `msr sysreg, Xt`

**Wirkung:** `sysreg = Xt`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## msub – Multiplikation mit Subtraktion (Ra - Rn * Rm)

**Syntax:** `msub Rd, Rn, Rm, Ra`

**Wirkung:** `Rd = Ra - Rn * Rm`

Auch angezeigt als: `mneg`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul – Multiplikation der Elemente

**Syntax:** `mul Vd.T, Vn.T, Vm.T` &nbsp; `mul Vd.T, Vn.T, Vm.Ts[index]`

Multiplikation der Elemente (untere Hälfte des Ergebnisses).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mvni – Laden der Negation einer 32-Bit-Konstante in alle Elemente

**Syntax:** `mvni Vd.T, #imm8{, lsl #amount}`

**Wirkung:** `Vd = ~(imm8 << (8 * cm))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## neg – Negation

**Syntax:** `neg Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = -Vn[i]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## not – Bitweise Negation

**Syntax:** `not Vd.T, Vn.T`

**Wirkung:** `Vd = ~Vn`

Auch angezeigt als: `mvn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orn – Bitweises ODER mit invertiertem Operanden

**Syntax:** `orn Rd, Rn, Rm{, shift #imm6}` &nbsp; `orn Vd.T, Vn.T, Vm.T`

**Wirkung:** `Rd = Rn OR ~shift(Rm, imm6)`

Auch angezeigt als: `mvn`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orr – Bitweises ODER mit einem Bitmuster als Konstante

**Syntax:** `orr Rd, Rn, #imm (bit pattern)` &nbsp; `orr Rd, Rn, Rm{, shift #imm6}` &nbsp; `orr Vd.T, Vn.T, Vm.T` &nbsp; `orr Vd.T, #imm8{, lsl #amount}`

**Wirkung:** `Rd = Rn OR decode_bitmask(N, imms, immr) (Rd may be SP)`

Auch angezeigt als: `mov`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pacga – Berechnung eines allgemeinen Authentifizierungscodes

**Syntax:** `pacga Xd, Xn, Xm|SP`

**Wirkung:** `Xd[63:32] = pac_code(Xn, Xm); Xd[31:0] = 0`

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pacia – Signieren (pac...) oder Prüfen

**Syntax:** `pacia Xd, Xn|SP`

Signieren (pac...) oder Prüfen (aut...) eines Zeigers mit einem Schlüssel (ia, ib für Befehle, da, db für Daten) und einem Modifizierer (Xn).

**Wirkung:** `Xd = pac(Xd, key, Xn) or Xd = aut(Xd, key, Xn)`

Auch angezeigt als: `pacib`, `pacda`, `pacdb`, `autia`, `autib`, `autda`, `autdb`

*Gruppe: Zeigerauthentifizierung (PAC). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmul – Polynom-Multiplikation der Elemente

**Syntax:** `pmul Vd.T, Vn.T, Vm.T`

Polynom-Multiplikation der Elemente (Byte, ohne Übertrag).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i] over GF(2)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmull – Polynom-Multiplikation mit Verbreiterung

**Syntax:** `pmull Vd.Tb, Vn.Ta, Vm.Ta`

Polynom-Multiplikation mit Verbreiterung (ohne Übertrag; 1Q-Form braucht Krypto-Erweiterung).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i] over GF(2)`

Auch angezeigt als: `pmull2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prfm – Vorab-Laden einer Cache-Zeile (Hinweis)

**Syntax:** `prfm prfop, [Xn|SP{, #imm12}]` &nbsp; `prfm prfop, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `prfm prfop, label`

**Wirkung:** `prefetch the cache line at addr (a hint)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prfum – Vorab-Laden einer Cache-Zeile

**Syntax:** `prfum prfop, [Xn|SP{, #imm9}]`

Vorab-Laden einer Cache-Zeile (Hinweis) (ohne Skalierung).

**Wirkung:** `prefetch the cache line at addr (a hint)`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## raddhn – Addition mit Verschmälerung

**Syntax:** `raddhn Vd.Tb, Vn.Ta, Vm.Ta`

Addition mit Verschmälerung (obere Hälfte; raddhn mit Runden) (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = high half of (Vn[i] + Vm[i])`

Auch angezeigt als: `raddhn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rbit – Umkehren der Bitreihenfolge

**Syntax:** `rbit Rd, Rn` &nbsp; `rbit Vd.T, Vn.T`

**Wirkung:** `Rd = reverse_bits(Rn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ret – Rückkehr aus der Funktion

**Syntax:** `ret {Xn}`

Rückkehr aus der Funktion (Adresse in x30, wenn kein Register steht).

**Wirkung:** `pc = Xn (default x30)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev – Umkehren der Bytes eines 32-Bit-Wertes

**Syntax:** `rev Wd, Wn` &nbsp; `rev Xd, Xn`

Umkehren der Bytes eines 32-Bit-Wertes (Little/Big Endian).

**Wirkung:** `Wd = reverse_bytes(Wn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev16 – Umkehren der Bytes in jedem Halbwort

**Syntax:** `rev16 Rd, Rn` &nbsp; `rev16 Vd.T, Vn.T`

**Wirkung:** `Rd = reverse_bytes_in_each_16_bits(Rn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev32 – Umkehren der Bytes in jedem 32-Bit-Teil eines 64-Bit-Registers

**Syntax:** `rev32 Xd, Xn` &nbsp; `rev32 Vd.T, Vn.T`

**Wirkung:** `Xd = reverse_bytes_in_each_32_bits(Xn)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rev64 – Umkehren der Reihenfolge der Elemente in jedem 64-Bit-Block

**Syntax:** `rev64 Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = reverse(Vn) per 64 bits`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rmif – Drehen eines Registers in die Flags (maskiert)

**Syntax:** `rmif Xn, #imm6, #nzcv`

**Wirkung:** `flags = bits of (Xn rotated right by imm6) where the mask nzcv is set`

**Flags:** N Z C V

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rorv – Rotation nach rechts um ein Register

**Syntax:** `rorv Rd, Rn, Rm`

**Wirkung:** `Rd = rotate_right(Rn, Rm mod width)`

Auch angezeigt als: `ror`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rshrn – Schieben nach rechts mit Verschmälern und Runden

**Syntax:** `rshrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern und Runden (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = round(Vn[i] >> shift)`

Auch angezeigt als: `rshrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsubhn – Subtraktion mit Verschmälerung

**Syntax:** `rsubhn Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion mit Verschmälerung (obere Hälfte; rsubhn mit Runden) (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = high half of (Vn[i] - Vm[i])`

Auch angezeigt als: `rsubhn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saba – Addition des absoluten Unterschieds zum Ziel

**Syntax:** `saba Vd.T, Vn.T, Vm.T`

Addition des absoluten Unterschieds zum Ziel (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sabal – Addition des absoluten Unterschieds mit Verbreiterung

**Syntax:** `sabal Vd.Tb, Vn.Ta, Vm.Ta`

Addition des absoluten Unterschieds mit Verbreiterung (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

Auch angezeigt als: `sabal2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sabd – Absoluter Unterschied (mit Vorzeichen)

**Syntax:** `sabd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sabdl – Absoluter Unterschied mit Verbreiterung

**Syntax:** `sabdl Vd.Tb, Vn.Ta, Vm.Ta`

Absoluter Unterschied mit Verbreiterung (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = abs(Vn[i] - Vm[i]) (wide result)`

Auch angezeigt als: `sabdl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sadalp – Paarweise Addition mit Verbreiterung

**Syntax:** `sadalp Vd.T, Vn.T`

Paarweise Addition mit Verbreiterung, addiert zum Ziel (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[2i] + Vn[2i+1]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saddl – Addition mit Verbreiterung

**Syntax:** `saddl Vd.Tb, Vn.Ta, Vm.Ta`

Addition mit Verbreiterung (beide Operanden werden doppelt so breit) (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] + Vm[i] (wide result)`

Auch angezeigt als: `saddl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saddlp – Paarweise Addition benachbarter Elemente mit Verbreiterung

**Syntax:** `saddlp Vd.T, Vn.T`

Paarweise Addition benachbarter Elemente mit Verbreiterung (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[2i] + Vn[2i+1]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saddlv – Summe aller Elemente mit Verbreiterung

**Syntax:** `saddlv Vd, Vn.T`

Summe aller Elemente mit Verbreiterung (mit Vorzeichen).

**Wirkung:** `Vd = sum of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saddw – Addition eines breiten und eines schmalen Operanden

**Syntax:** `saddw Vd.Tb, Vn.Ta, Vm.Ta`

Addition eines breiten und eines schmalen Operanden (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] + Vm[i] (Vn is wide)`

Auch angezeigt als: `saddw2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbc – Subtraktion mit Borgen (C)

**Syntax:** `sbc Rd, Rn, Rm`

**Wirkung:** `Rd = Rn - Rm - (1 - C)`

Auch angezeigt als: `ngc`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbcs – Subtraktion mit Borgen, setzt die Flags

**Syntax:** `sbcs Rd, Rn, Rm`

**Wirkung:** `Rd = Rn - Rm - (1 - C)`

**Flags:** N Z C V

Auch angezeigt als: `ngcs`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbfm – Bitfeld verschieben mit Vorzeichenerweiterung

**Syntax:** `sbfm Rd, Rn, #immr, #imms`

Bitfeld verschieben mit Vorzeichenerweiterung (Grundform von asr, sbfx, sxtb ...).

**Wirkung:** `Rd = sign-extended field of Rn selected by immr, imms`

Auch angezeigt als: `asr`, `sbfiz`, `sbfx`, `sxtb`, `sxth`, `sxtw`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## scvtf – Umwandlung einer Ganzzahl mit Vorzeichen in Gleitkomma

**Syntax:** `scvtf Fd, Rn` &nbsp; `scvtf Vd.T, Vn.T`

**Wirkung:** `Fd = (float) sext(Rn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sdiv – Division mit Vorzeichen

**Syntax:** `sdiv Rd, Rn, Rm`

Division mit Vorzeichen (Division durch 0 ergibt 0).

**Wirkung:** `Rd = Rn / Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sdot – Skalarprodukt von je vier Bytes

**Syntax:** `sdot Vd.4S, Vn.16B, Vm.16B`

Skalarprodukt von je vier Bytes (mit Vorzeichen), addiert zum 32-Bit-Ziel.

**Wirkung:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sete – Füllen eines Speicherblocks mit einem Byte

**Syntax:** `sete [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte, Abschluss (epilogue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `seten`, `setet`, `setetn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setge – Füllen eines Speicherblocks mit einem Byte mit Tags

**Syntax:** `setge [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte mit Tags, Abschluss (epilogue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `setgen`, `setget`, `setgetn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setgm – Füllen eines Speicherblocks mit einem Byte mit Tags

**Syntax:** `setgm [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte mit Tags, Hauptteil (main) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `setgmn`, `setgmt`, `setgmtn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setgp – Füllen eines Speicherblocks mit einem Byte mit Tags

**Syntax:** `setgp [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte mit Tags, Vorbereitung (prologue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `setgpn`, `setgpt`, `setgptn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setm – Füllen eines Speicherblocks mit einem Byte

**Syntax:** `setm [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte, Hauptteil (main) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `setmn`, `setmt`, `setmtn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setp – Füllen eines Speicherblocks mit einem Byte

**Syntax:** `setp [Xd]!, Xn!, Xs`

Füllen eines Speicherblocks mit einem Byte, Vorbereitung (prologue) (die drei Befehle p, m, e werden nacheinander ausgeführt).

**Wirkung:** `fill Xn bytes at [Xd] with Xs[7:0]; Xd and Xn are updated`

Auch angezeigt als: `setpn`, `setpt`, `setptn`

*Gruppe: Speicher kopieren und füllen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sha1c – SHA-1- und SHA-256-Hashwert-Update

**Syntax:** `sha1c Qd, Sn, Vm.4S`

SHA-1- und SHA-256-Hashwert-Update (sha1c: Auswahl, sha1p: Parität, sha1m: Mehrheit, sha256h, sha256h2: Hash-Update, ...su: Nachrichtenplan).

**Wirkung:** `Vd = hash_update(Vd, Vn, Vm)`

Auch angezeigt als: `sha1p`, `sha1m`, `sha1su0`, `sha256h`, `sha256h2`, `sha256su1`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sha1h – SHA-1-Rotation

**Syntax:** `sha1h Sd, Sn`

SHA-1-Rotation (sha1h) und Nachrichtenplan (sha1su1, sha256su0).

**Wirkung:** `Sd = rotate_left(Sn, 30)`

Auch angezeigt als: `sha1su1`, `sha256su0`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sha512h – SHA-512-Hashwert-Update

**Syntax:** `sha512h Qd, Qn, Vm.2D`

SHA-512-Hashwert-Update (sha512h, sha512h2), Nachrichtenplan (sha512su1) und Rotation (rax1: rotieren und exklusiv-oder, auch für SHA-3).

**Wirkung:** `Vd = hash_update(Vd, Vn, Vm)`

Auch angezeigt als: `sha512h2`, `sha512su1`, `rax1`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sha512su0 – SHA-512-Nachrichtenplan

**Syntax:** `sha512su0 Vd.2D, Vn.2D`

SHA-512-Nachrichtenplan (sha512su0) und SM4-Verschlüsselung von vier Runden (sm4e).

**Wirkung:** `Vd = message_schedule(Vd, Vn)`

Auch angezeigt als: `sm4e`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shadd – Halbierende Addition (mit Vorzeichen)

**Syntax:** `shadd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = (Vn[i] + Vm[i]) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shl – Schieben nach links

**Syntax:** `shl Vd.T, Vn.T, #shift`

**Wirkung:** `for every element: Vd[i] = Vn[i] << shift`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shll – Verbreitern mit Linksschieben um die Elementbreite

**Syntax:** `shll Vd.Ta, Vn.Tb, #shift`

**Wirkung:** `for every element: Vd[i] = Vn[i] << esize`

Auch angezeigt als: `shll2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shrn – Schieben nach rechts mit Verschmälern

**Syntax:** `shrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] >> shift`

Auch angezeigt als: `shrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shsub – Halbierende Subtraktion (mit Vorzeichen)

**Syntax:** `shsub Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = (Vn[i] - Vm[i]) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sli – Schieben nach links und Einfügen

**Syntax:** `sli Vd.T, Vn.T, #shift`

Schieben nach links und Einfügen (die unteren Bits des Ziels bleiben).

**Wirkung:** `for every element: Vd[i] = (Vd[i] & low_mask) | (Vn[i] << shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sm3partw1 – SM3-Nachrichtenerweiterung

**Syntax:** `sm3partw1 Vd.4S, Vn.4S, Vm.4S`

SM3-Nachrichtenerweiterung (sm3partw1, sm3partw2) und SM4-Schlüsselerzeugung (sm4ekey).

**Wirkung:** `Vd = expand(Vn, Vm)`

Auch angezeigt als: `sm3partw2`, `sm4ekey`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sm3ss1 – SM3-Hilfswert

**Syntax:** `sm3ss1 Vd.4S, Vn.4S, Vm.4S, Va.4S`

**Wirkung:** `Vd = SM3SS1(Vn, Vm, Va)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sm3tt1a – SM3-Kompressionsfunktion (vier Varianten)

**Syntax:** `sm3tt1a Vd.4S, Vn.4S, Vm.S[imm2]`

**Wirkung:** `Vd = SM3TT(Vd, Vn, Vm[imm2])`

Auch angezeigt als: `sm3tt1b`, `sm3tt2a`, `sm3tt2b`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smaddl – Multiplikation 32 x 32 Bit mit Vorzeichen

**Syntax:** `smaddl Xd, Wn, Wm, Xa`

Multiplikation 32 x 32 Bit mit Vorzeichen, Addition zu 64 Bit.

**Wirkung:** `Xd = Xa + sext(Wn) * sext(Wm)`

Auch angezeigt als: `smull`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smax – Maximum der Elemente (mit Vorzeichen)

**Syntax:** `smax Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = max_signed(Vn[i], Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smaxp – Maximum benachbarter Elementpaare (mit Vorzeichen)

**Syntax:** `smaxp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = max_signed of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smaxv – Maximum aller Elemente (mit Vorzeichen)

**Syntax:** `smaxv Vd, Vn.T`

**Wirkung:** `Vd = max_signed of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smc – Aufruf des sicheren Monitors (Ausnahmestufe 3)

**Syntax:** `smc #imm16`

**Wirkung:** `raise a secure monitor call exception`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smin – Minimum der Elemente (mit Vorzeichen)

**Syntax:** `smin Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = min_signed(Vn[i], Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sminp – Minimum benachbarter Elementpaare (mit Vorzeichen)

**Syntax:** `sminp Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = min_signed of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sminv – Minimum aller Elemente (mit Vorzeichen)

**Syntax:** `sminv Vd, Vn.T`

**Wirkung:** `Vd = min_signed of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smlal – Multiplikation mit Verbreiterung

**Syntax:** `smlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung, addiert zum Ziel (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

Auch angezeigt als: `smlal2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smlsl – Multiplikation mit Verbreiterung

**Syntax:** `smlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung, subtrahiert vom Ziel (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

Auch angezeigt als: `smlsl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smmla – Matrix-Multiplikation 2x8 mal 8x2

**Syntax:** `smmla Vd.4S, Vn.16B, Vm.16B`

Matrix-Multiplikation 2x8 mal 8x2 (mit Vorzeichen), addiert zum Ziel.

**Wirkung:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smov – Kopieren eines Elements in ein Ganzzahl-Register

**Syntax:** `smov Rd, Vn.Ts[index]`

Kopieren eines Elements in ein Ganzzahl-Register (mit Vorzeichen).

**Wirkung:** `Rd = sext(Vn[index])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smsubl – Multiplikation 32 x 32 Bit mit Vorzeichen

**Syntax:** `smsubl Xd, Wn, Wm, Xa`

Multiplikation 32 x 32 Bit mit Vorzeichen, Subtraktion von 64 Bit.

**Wirkung:** `Xd = Xa - sext(Wn) * sext(Wm)`

Auch angezeigt als: `smnegl`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smulh – Multiplikation mit Vorzeichen

**Syntax:** `smulh Xd, Xn, Xm`

Multiplikation mit Vorzeichen, obere 64 Bit des Ergebnisses.

**Wirkung:** `Xd = (sext(Xn) * sext(Xm)) >> 64`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smull – Multiplikation mit Verbreiterung

**Syntax:** `smull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `smull Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i] (wide result)`

Auch angezeigt als: `smull2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqabs – Betrag mit Sättigung

**Syntax:** `sqabs Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = saturate(abs(Vn[i]))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqadd – Addition mit Sättigung (mit Vorzeichen)

**Syntax:** `sqadd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vn[i] + Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqdmlal – Verdoppelnde Multiplikation mit Verbreiterung und Sättigung

**Syntax:** `sqdmlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Verdoppelnde Multiplikation mit Verbreiterung und Sättigung, addiert zum Ziel.

**Wirkung:** `for every element: Vd[i] = saturate(Vd[i] + 2 * Vn[i] * Vm[i])`

Auch angezeigt als: `sqdmlal2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqdmlsl – Verdoppelnde Multiplikation mit Verbreiterung und Sättigung

**Syntax:** `sqdmlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Verdoppelnde Multiplikation mit Verbreiterung und Sättigung, subtrahiert vom Ziel.

**Wirkung:** `for every element: Vd[i] = saturate(Vd[i] - 2 * Vn[i] * Vm[i])`

Auch angezeigt als: `sqdmlsl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqdmulh – Verdoppelnde Multiplikation

**Syntax:** `sqdmulh Vd.T, Vn.T, Vm.T` &nbsp; `sqdmulh Vd.T, Vn.T, Vm.Ts[index]`

Verdoppelnde Multiplikation, obere Hälfte, mit Sättigung.

**Wirkung:** `for every element: Vd[i] = saturate((2 * Vn[i] * Vm[i]) >> esize)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqdmull – Verdoppelnde Multiplikation mit Verbreiterung und Sättigung

**Syntax:** `sqdmull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `sqdmull Vd.Ta, Vn.Tb, Vm.Ts[index]`

**Wirkung:** `for every element: Vd[i] = saturate(2 * Vn[i] * Vm[i])`

Auch angezeigt als: `sqdmull2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqneg – Negation mit Sättigung

**Syntax:** `sqneg Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = saturate(-Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrdmlah – Verdoppelnde Multiplikation

**Syntax:** `sqrdmlah Vd.T, Vn.T, Vm.T`

Verdoppelnde Multiplikation, obere Hälfte, mit Runden und Sättigung, addiert zum Ziel.

**Wirkung:** `for every element: Vd[i] = saturate(Vd[i] + round((2 * Vn[i] * Vm[i]) >> esize))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrdmlsh – Verdoppelnde Multiplikation

**Syntax:** `sqrdmlsh Vd.T, Vn.T, Vm.T`

Verdoppelnde Multiplikation, obere Hälfte, mit Runden und Sättigung, subtrahiert vom Ziel.

**Wirkung:** `for every element: Vd[i] = saturate(Vd[i] - round((2 * Vn[i] * Vm[i]) >> esize))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrdmulh – Verdoppelnde Multiplikation

**Syntax:** `sqrdmulh Vd.T, Vn.T, Vm.T` &nbsp; `sqrdmulh Vd.T, Vn.T, Vm.Ts[index]`

Verdoppelnde Multiplikation, obere Hälfte, mit Runden und Sättigung.

**Wirkung:** `for every element: Vd[i] = saturate(round((2 * Vn[i] * Vm[i]) >> esize))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrshl – Schieben je Element mit Runden und Sättigung

**Syntax:** `sqrshl Vd.T, Vn.T, Vm.T`

Schieben je Element mit Runden und Sättigung (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = saturate_signed(round(Vn[i] << Vm[i]))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrshrn – Schieben nach rechts mit Verschmälern

**Syntax:** `sqrshrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern, Runden und Sättigung (mit Vorzeichen) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_signed(round(Vn[i] >> shift))`

Auch angezeigt als: `sqrshrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrshrun – Schieben nach rechts mit Verschmälern

**Syntax:** `sqrshrun Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern, Runden und Sättigung (Quelle mit Vorzeichen, Ergebnis ohne) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] >> shift))`

Auch angezeigt als: `sqrshrun2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqshl – Schieben je Element mit Sättigung (mit Vorzeichen)

**Syntax:** `sqshl Vd.T, Vn.T, Vm.T` &nbsp; `sqshl Vd.T, Vn.T, #shift`

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vn[i] << Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqshlu – Schieben nach links mit Sättigung

**Syntax:** `sqshlu Vd.T, Vn.T, #shift`

Schieben nach links mit Sättigung (Quelle mit Vorzeichen, Ergebnis ohne).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] << shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqshrn – Schieben nach rechts mit Verschmälern und Sättigung

**Syntax:** `sqshrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern und Sättigung (mit Vorzeichen) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vn[i] >> shift)`

Auch angezeigt als: `sqshrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqshrun – Schieben nach rechts mit Verschmälern und Sättigung

**Syntax:** `sqshrun Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern und Sättigung (Quelle mit Vorzeichen, Ergebnis ohne) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] >> shift)`

Auch angezeigt als: `sqshrun2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqsub – Subtraktion mit Sättigung (mit Vorzeichen)

**Syntax:** `sqsub Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqxtn – Verschmälern mit Sättigung (mit Vorzeichen)

**Syntax:** `sqxtn Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vn[i])`

Auch angezeigt als: `sqxtn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqxtun – Verschmälern mit Sättigung

**Syntax:** `sqxtun Vd.T, Vn.T`

Verschmälern mit Sättigung (Quelle mit Vorzeichen, Ergebnis ohne).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i])`

Auch angezeigt als: `sqxtun2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srhadd – Halbierende Addition mit Aufrunden

**Syntax:** `srhadd Vd.T, Vn.T, Vm.T`

Halbierende Addition mit Aufrunden (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = (Vn[i] + Vm[i] + 1) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sri – Schieben nach rechts und Einfügen

**Syntax:** `sri Vd.T, Vn.T, #shift`

Schieben nach rechts und Einfügen (die oberen Bits des Ziels bleiben).

**Wirkung:** `for every element: Vd[i] = (Vd[i] & high_mask) | (Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srshl – Schieben je Element mit Runden (mit Vorzeichen)

**Syntax:** `srshl Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = round(Vn[i] << Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srshr – Schieben nach rechts mit Runden (mit Vorzeichen)

**Syntax:** `srshr Vd.T, Vn.T, #shift`

**Wirkung:** `for every element: Vd[i] = round(Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srsra – Schieben nach rechts mit Runden und Addition zum Ziel

**Syntax:** `srsra Vd.T, Vn.T, #shift`

Schieben nach rechts mit Runden und Addition zum Ziel (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + round(Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sshl – Schieben nach links oder rechts je Element

**Syntax:** `sshl Vd.T, Vn.T, Vm.T`

Schieben nach links oder rechts je Element (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[i] << Vm[i] (a negative count shifts right)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sshll – Verbreitern mit Linksschieben

**Syntax:** `sshll Vd.Ta, Vn.Tb, #shift`

Verbreitern mit Linksschieben (mit Vorzeichen; sxtl ist Schieben um 0).

**Wirkung:** `for every element: Vd[i] = sext(Vn[i]) << shift`

Auch angezeigt als: `sshll2`, `sxtl`, `sxtl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sshr – Schieben nach rechts mit Vorzeichen

**Syntax:** `sshr Vd.T, Vn.T, #shift`

Schieben nach rechts mit Vorzeichen (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[i] >> shift`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssra – Schieben nach rechts und Addition zum Ziel

**Syntax:** `ssra Vd.T, Vn.T, #shift`

Schieben nach rechts und Addition zum Ziel (mit Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + (Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssubl – Subtraktion mit Verbreiterung

**Syntax:** `ssubl Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion mit Verbreiterung (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] - Vm[i] (wide result)`

Auch angezeigt als: `ssubl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssubw – Subtraktion eines schmalen Operanden von einem breiten

**Syntax:** `ssubw Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion eines schmalen Operanden von einem breiten (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] - Vm[i] (Vn is wide)`

Auch angezeigt als: `ssubw2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## st1 – Speichern eines Vektor-Registers in den Speicher

**Syntax:** `st1 {Vt.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `st1 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `st1 {Vt.Ts}[index], [Xn|SP]`

Speichern eines Vektor-Registers in den Speicher (ein Register).

**Wirkung:** `[Rn] = Vt`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## st2 – Speichern von 2 Register

**Syntax:** `st2 {Vt.T, Vt2.T}, [Xn|SP]` &nbsp; `st2 {Vt.T, Vt2.T}, [Xn|SP], Xm|#imm` &nbsp; `st2 {Vt.Ts, Vt2.Ts}[index], [Xn|SP]`

Speichern von 2 Register (Elemente abwechselnd) in den Speicher.

**Wirkung:** `[Rn] = registers (2 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## st2g – Speichern des Tags für 32 Byte (Nach-Indizierung)

**Syntax:** `st2g Xt|SP, [Xn|SP], #imm9` &nbsp; `st2g Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `st2g Xt|SP, [Xn|SP, #imm9]!`

**Wirkung:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## st3 – Speichern von 3 Register

**Syntax:** `st3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP]` &nbsp; `st3 {Vt.T, Vt2.T, Vt3.T}, [Xn|SP], Xm|#imm` &nbsp; `st3 {Vt.Ts, Vt2.Ts, Vt3.Ts}[index], [Xn|SP]`

Speichern von 3 Register (Elemente abwechselnd) in den Speicher.

**Wirkung:** `[Rn] = registers (3 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## st4 – Speichern von 4 Register

**Syntax:** `st4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP]` &nbsp; `st4 {Vt.T, Vt2.T, Vt3.T, Vt4.T}, [Xn|SP], Xm|#imm` &nbsp; `st4 {Vt.Ts, Vt2.Ts, Vt3.Ts, Vt4.Ts}[index], [Xn|SP]`

Speichern von 4 Register (Elemente abwechselnd) in den Speicher.

**Wirkung:** `[Rn] = registers (4 registers (elements interleaved))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stg – Speichern des Tags einer Adresse für 16 Byte

**Syntax:** `stg Xt|SP, [Xn|SP], #imm9` &nbsp; `stg Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stg Xt|SP, [Xn|SP, #imm9]!`

Speichern des Tags einer Adresse für 16 Byte (Nach-Indizierung).

**Wirkung:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stgp – Speichern eines Registerpaares und des Tags

**Syntax:** `stgp Xt, Xt2, [Xn|SP], #imm7` &nbsp; `stgp Xt, Xt2, [Xn|SP{, #imm7}]` &nbsp; `stgp Xt, Xt2, [Xn|SP, #imm7]!`

Speichern eines Registerpaares und des Tags (Nach-Indizierung).

**Wirkung:** `[addr] = Xt, Xt2; tag of [addr] = tag of Rn`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stllr – Speichern mit Release für eine Speicher-Region mit Ordnung

**Syntax:** `stllr Wt, [Xn|SP]`

Speichern mit Release für eine Speicher-Region mit Ordnung (LORegion; b = Byte, h = Halbwort).

**Wirkung:** `[Rn] = Wt`

Auch angezeigt als: `stllrb`, `stllrh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlr – Speichern mit Freigabe (release) (Wort)

**Syntax:** `stlr Wt, [Xn|SP]` &nbsp; `stlr Xt, [Xn|SP]`

**Wirkung:** `release; [Rn] = Rt`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlrb – Speichern mit Freigabe (release) (Byte)

**Syntax:** `stlrb Wt, [Xn|SP]`

**Wirkung:** `release; [Rn] = Rt`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlrh – Speichern mit Freigabe (release) (Halbwort)

**Syntax:** `stlrh Wt, [Xn|SP]`

**Wirkung:** `release; [Rn] = Rt`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlur – Speichern mit Release

**Syntax:** `stlur Wt, [Xn|SP{, #imm9}]`

Speichern mit Release (ohne Skalierung, Adresse: Rn + imm9; b = Byte, h = Halbwort).

**Wirkung:** `[Rn + imm9] = Wt`

Auch angezeigt als: `stlurb`, `stlurh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlxp – Bedingtes Speichern eines Registerpaares

**Syntax:** `stlxp Ws, Rt, Rt2, [Xn|SP]`

Bedingtes Speichern eines Registerpaares (exklusiv) mit Freigabe.

**Wirkung:** `if the exclusive monitor is set then { release; [Rn] = Rt; [Rn + size] = Rt2; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlxr – Bedingtes Speichern

**Syntax:** `stlxr Ws, Wt, [Xn|SP]` &nbsp; `stlxr Ws, Xt, [Xn|SP]`

Bedingtes Speichern (exklusiv) mit Freigabe (release) (Wort).

**Wirkung:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlxrb – Bedingtes Speichern

**Syntax:** `stlxrb Ws, Wt, [Xn|SP]`

Bedingtes Speichern (exklusiv) mit Freigabe (release) (Byte).

**Wirkung:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stlxrh – Bedingtes Speichern

**Syntax:** `stlxrh Ws, Wt, [Xn|SP]`

Bedingtes Speichern (exklusiv) mit Freigabe (release) (Halbwort).

**Wirkung:** `if the exclusive monitor is set then { release; [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stnp – Speichern eines Registerpaares ohne Cache-Hinweis

**Syntax:** `stnp Rt, Rt2, [Xn|SP{, #imm7}]`

**Wirkung:** `[addr] = Rt; [addr + size] = Rt2`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stp – Speichern eines Registerpaares (Nach-Indizierung)

**Syntax:** `stp Rt, Rt2, [Xn|SP], #imm7` &nbsp; `stp Rt, Rt2, [Xn|SP{, #imm7}]` &nbsp; `stp Rt, Rt2, [Xn|SP, #imm7]!` &nbsp; `stp Ft, Ft2, [Xn|SP{, #imm7}]`

**Wirkung:** `[addr] = Rt; [addr + size] = Rt2; addr = Rn; Rn = Rn + imm7 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## str – Speichern eines Wortes

**Syntax:** `str Wt, [Xn|SP{, #imm12}]` &nbsp; `str Wt, [Xn|SP, #imm9]!` &nbsp; `str Wt, [Xn|SP], #imm9` &nbsp; `str Wt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; `str Xt, [Xn|SP{, #imm12}]` &nbsp; `str Xt, [Xn|SP, #imm9]!` &nbsp; `str Xt, [Xn|SP], #imm9` &nbsp; `str Xt, [Xn|SP, Rm{, extend {#amount}}]` &nbsp; …

Speichern eines Wortes (32 Bit) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `[addr] = Wt; addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strb – Speichern eines Bytes

**Syntax:** `strb Wt, [Xn|SP{, #imm12}]` &nbsp; `strb Wt, [Xn|SP, #imm9]!` &nbsp; `strb Wt, [Xn|SP], #imm9` &nbsp; `strb Wt, [Xn|SP, Rm{, extend {#amount}}]`

Speichern eines Bytes (Adresse: Rn + imm12 * Größe).

**Wirkung:** `[addr] = Wt[7:0]; addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## strh – Speichern eines Halbwortes

**Syntax:** `strh Wt, [Xn|SP{, #imm12}]` &nbsp; `strh Wt, [Xn|SP, #imm9]!` &nbsp; `strh Wt, [Xn|SP], #imm9` &nbsp; `strh Wt, [Xn|SP, Rm{, extend {#amount}}]`

Speichern eines Halbwortes (16 Bit) (Adresse: Rn + imm12 * Größe).

**Wirkung:** `[addr] = Wt[15:0]; addr = Rn + imm12 * size`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sttr – Speichern mit den Rechten des Anwendungs-Modus

**Syntax:** `sttr Wt, [Xn|SP{, #imm9}]`

Speichern mit den Rechten des Anwendungs-Modus (unprivilegiert; b = Byte, h = Halbwort).

**Wirkung:** `[Rn + imm9] = Wt`

Auch angezeigt als: `sttrb`, `sttrh`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stur – Speichern eines Wortes

**Syntax:** `stur Wt, [Xn|SP{, #imm9}]` &nbsp; `stur Xt, [Xn|SP{, #imm9}]`

Speichern eines Wortes (32 Bit) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `[addr] = Wt; addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sturb – Speichern eines Bytes

**Syntax:** `sturb Wt, [Xn|SP{, #imm9}]`

Speichern eines Bytes (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `[addr] = Wt[7:0]; addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sturh – Speichern eines Halbwortes

**Syntax:** `sturh Wt, [Xn|SP{, #imm9}]`

Speichern eines Halbwortes (16 Bit) (ohne Skalierung, Adresse: Rn + imm9).

**Wirkung:** `[addr] = Wt[15:0]; addr = Rn + imm9`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stxp – Bedingtes Speichern eines Registerpaares

**Syntax:** `stxp Ws, Rt, Rt2, [Xn|SP]`

Bedingtes Speichern eines Registerpaares (exklusiv).

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt; [Rn + size] = Rt2; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stxr – Bedingtes Speichern

**Syntax:** `stxr Ws, Wt, [Xn|SP]` &nbsp; `stxr Ws, Xt, [Xn|SP]`

Bedingtes Speichern (exklusiv): Ws = 0 bei Erfolg (Wort).

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stxrb – Bedingtes Speichern

**Syntax:** `stxrb Ws, Wt, [Xn|SP]`

Bedingtes Speichern (exklusiv): Ws = 0 bei Erfolg (Byte).

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stxrh – Bedingtes Speichern

**Syntax:** `stxrh Ws, Wt, [Xn|SP]`

Bedingtes Speichern (exklusiv): Ws = 0 bei Erfolg (Halbwort).

**Wirkung:** `if the exclusive monitor is set then { [Rn] = Rt; Ws = 0 } else Ws = 1`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stz2g – Speichern des Tags und Nullen von 32 Byte

**Syntax:** `stz2g Xt|SP, [Xn|SP], #imm9` &nbsp; `stz2g Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stz2g Xt|SP, [Xn|SP, #imm9]!`

Speichern des Tags und Nullen von 32 Byte (Nach-Indizierung).

**Wirkung:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stzg – Speichern des Tags und Nullen von 16 Byte

**Syntax:** `stzg Xt|SP, [Xn|SP], #imm9` &nbsp; `stzg Xt|SP, [Xn|SP{, #imm9}]` &nbsp; `stzg Xt|SP, [Xn|SP, #imm9]!`

Speichern des Tags und Nullen von 16 Byte (Nach-Indizierung).

**Wirkung:** `tag of [addr] = tag of Xt (imm9 * 16 added to the address)`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stzgm – Speichern mehrerer Tags und Nullen des Speichers

**Syntax:** `stzgm Xt, [Xn|SP]`

Speichern mehrerer Tags und Nullen des Speichers (Größe aus dem System).

**Wirkung:** `tags and memory of the block at Rn = Xt`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub – Subtraktion einer Konstanten

**Syntax:** `sub Rd, Rn, #imm12{, lsl #12}` &nbsp; `sub Rd, Rn, Rm{, shift #imm6}` &nbsp; `sub Rd, Rn, Rm{, extend #imm3}` &nbsp; `sub Vd.T, Vn.T, Vm.T`

Subtraktion einer Konstanten (12 Bit, optional um 12 verschoben).

**Wirkung:** `Rd = Rn - (imm12 << (sh * 12)) (Rd and Rn may be SP)`

Auch angezeigt als: `neg`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subg – Subtraktion von einer Adresse mit Änderung des Tags

**Syntax:** `subg Xd|SP, Xn|SP, #uimm6, #uimm4`

**Wirkung:** `Xd = Xn - uimm6 * 16, tag = (tag of Xn - uimm4) modulo 16`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subhn – Subtraktion mit Verschmälerung

**Syntax:** `subhn Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion mit Verschmälerung (obere Hälfte; rsubhn mit Runden) (mit Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = high half of (Vn[i] - Vm[i])`

Auch angezeigt als: `subhn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subp – Differenz zweier Adressen ohne Tags

**Syntax:** `subp Xd, Xn|SP, Xm|SP`

Differenz zweier Adressen ohne Tags (56 Bit, mit Vorzeichen).

**Wirkung:** `Xd = sext(Xn[55:0]) - sext(Xm[55:0])`

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subps – Differenz zweier Adressen ohne Tags

**Syntax:** `subps Xd, Xn|SP, Xm|SP`

Differenz zweier Adressen ohne Tags, setzt die Flags.

**Wirkung:** `Xd = sext(Xn[55:0]) - sext(Xm[55:0])`

**Flags:** N Z C V

*Gruppe: Speicher-Tagging (MTE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subs – Subtraktion einer Konstanten, setzt die Flags

**Syntax:** `subs Rd, Rn, #imm12{, lsl #12}` &nbsp; `subs Rd, Rn, Rm{, shift #imm6}` &nbsp; `subs Rd, Rn, Rm{, extend #imm3}`

**Wirkung:** `Rd = Rn - (imm12 << (sh * 12))`

**Flags:** N Z C V

Auch angezeigt als: `cmp`, `negs`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sudot – Skalarprodukt je vier Bytes mit einem Element

**Syntax:** `sudot Vd.4S, Vn.16B, Vm.4B[index]`

Skalarprodukt je vier Bytes mit einem Element (Vn mit, Vm ohne Vorzeichen), addiert zum 32-Bit-Ziel.

**Wirkung:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[index][k]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## suqadd – Addition eines Wertes ohne Vorzeichen zu einem mit Vorzeichen

**Syntax:** `suqadd Vd.T, Vn.T`

Addition eines Wertes ohne Vorzeichen zu einem mit Vorzeichen, mit Sättigung.

**Wirkung:** `for every element: Vd[i] = saturate_signed(Vd[i] + Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## svc – Systemaufruf an das Betriebssystem

**Syntax:** `svc #imm16`

Systemaufruf an das Betriebssystem (Ausnahmestufe 1).

**Wirkung:** `raise a supervisor call exception with imm16`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## swp – Atomarer Austausch eines Registers mit dem Speicher

**Syntax:** `swp Ws, Wt, [Xn|SP]`

Atomarer Austausch eines Registers mit dem Speicher (Varianten: b = Byte, h = Halbwort, a = Acquire, l = Release).

**Wirkung:** `t = [Rn]; [Rn] = Ws; Wt = t`

Auch angezeigt als: `swpa`, `swpal`, `swpl`, `swpb`, `swpab`, `swpalb`, `swplb`, `swph`, `swpah`, `swpalh`, `swplh`

*Gruppe: Atomare Speicherzugriffe (LSE). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sys – Systembefehl

**Syntax:** `sys #op1, Cn, Cm, #op2{, Xt}`

Systembefehl (Cache-, TLB- und Adress-Umwandlungs-Operationen, auch als dc, ic, at, tlbi geschrieben; sysl liest ein Ergebnis).

**Wirkung:** `execute the system operation (op1, Cn, Cm, op2) with Xt`

Auch angezeigt als: `sysl`, `tlbi`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tbl – Nachschlagen von Bytes in einer Tabelle aus 1 bis 4 Vektoren

**Syntax:** `tbl Vd.T, {Vn.16B ...}, Vm.T`

Nachschlagen von Bytes in einer Tabelle aus 1 bis 4 Vektoren (tbx lässt Bytes außerhalb unverändert, tbl setzt sie auf 0).

**Wirkung:** `for every element: Vd[i] = table[Vm[i]]`

Auch angezeigt als: `tbx`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tbnz – Sprung, wenn ein Bit des Registers 1 ist

**Syntax:** `tbnz Rt, #bit, label`

**Wirkung:** `if bit(b5:b40) of Rt == 1 then pc = pc + sext(imm14 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tbz – Sprung, wenn ein Bit des Registers 0 ist

**Syntax:** `tbz Rt, #bit, label`

**Wirkung:** `if bit(b5:b40) of Rt == 0 then pc = pc + sext(imm14 << 2)`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tcancel – Abbrechen einer Transaktion (TME)

**Syntax:** `tcancel #imm16`

**Wirkung:** `abort the transaction with the reason imm16`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## trn1 – Transponieren

**Syntax:** `trn1 Vd.T, Vn.T, Vm.T`

Transponieren: Elemente mit geraden Nummern abwechselnd aus zwei Vektoren.

**Wirkung:** `Vd = Vn[0], Vm[0], Vn[2], Vm[2] ...`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## trn2 – Transponieren

**Syntax:** `trn2 Vd.T, Vn.T, Vm.T`

Transponieren: Elemente mit ungeraden Nummern abwechselnd aus zwei Vektoren.

**Wirkung:** `Vd = Vn[1], Vm[1], Vn[3], Vm[3] ...`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uaba – Addition des absoluten Unterschieds zum Ziel

**Syntax:** `uaba Vd.T, Vn.T, Vm.T`

Addition des absoluten Unterschieds zum Ziel (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uabal – Addition des absoluten Unterschieds mit Verbreiterung

**Syntax:** `uabal Vd.Tb, Vn.Ta, Vm.Ta`

Addition des absoluten Unterschieds mit Verbreiterung (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] + abs(Vn[i] - Vm[i])`

Auch angezeigt als: `uabal2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uabd – Absoluter Unterschied (ohne Vorzeichen)

**Syntax:** `uabd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = abs(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uabdl – Absoluter Unterschied mit Verbreiterung

**Syntax:** `uabdl Vd.Tb, Vn.Ta, Vm.Ta`

Absoluter Unterschied mit Verbreiterung (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = abs(Vn[i] - Vm[i]) (wide result)`

Auch angezeigt als: `uabdl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uadalp – Paarweise Addition mit Verbreiterung

**Syntax:** `uadalp Vd.T, Vn.T`

Paarweise Addition mit Verbreiterung, addiert zum Ziel (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[2i] + Vn[2i+1]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uaddl – Addition mit Verbreiterung

**Syntax:** `uaddl Vd.Tb, Vn.Ta, Vm.Ta`

Addition mit Verbreiterung (beide Operanden werden doppelt so breit) (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] + Vm[i] (wide result)`

Auch angezeigt als: `uaddl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uaddlp – Paarweise Addition benachbarter Elemente mit Verbreiterung

**Syntax:** `uaddlp Vd.T, Vn.T`

Paarweise Addition benachbarter Elemente mit Verbreiterung (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[2i] + Vn[2i+1]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uaddlv – Summe aller Elemente mit Verbreiterung

**Syntax:** `uaddlv Vd, Vn.T`

Summe aller Elemente mit Verbreiterung (ohne Vorzeichen).

**Wirkung:** `Vd = sum of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uaddw – Addition eines breiten und eines schmalen Operanden

**Syntax:** `uaddw Vd.Tb, Vn.Ta, Vm.Ta`

Addition eines breiten und eines schmalen Operanden (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] + Vm[i] (Vn is wide)`

Auch angezeigt als: `uaddw2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ubfm – Bitfeld verschieben mit Nullen

**Syntax:** `ubfm Rd, Rn, #immr, #imms`

Bitfeld verschieben mit Nullen (Grundform von lsl, lsr, ubfx, uxtb ...).

**Wirkung:** `Rd = zero-extended field of Rn selected by immr, imms`

Auch angezeigt als: `lsl`, `lsr`, `ubfiz`, `ubfx`, `uxtb`, `uxth`

*Gruppe: Bitfelder. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ucvtf – Umwandlung einer Ganzzahl ohne Vorzeichen in Gleitkomma

**Syntax:** `ucvtf Fd, Rn` &nbsp; `ucvtf Vd.T, Vn.T`

**Wirkung:** `Fd = (float) zext(Rn)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## udf – Nicht definierter Befehl

**Syntax:** `udf #imm16`

Nicht definierter Befehl (löst immer eine Ausnahme aus).

**Wirkung:** `raise undefined-instruction exception`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## udiv – Division ohne Vorzeichen

**Syntax:** `udiv Rd, Rn, Rm`

Division ohne Vorzeichen (Division durch 0 ergibt 0).

**Wirkung:** `Rd = Rn / Rm`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## udot – Skalarprodukt von je vier Bytes

**Syntax:** `udot Vd.4S, Vn.16B, Vm.16B`

Skalarprodukt von je vier Bytes (ohne Vorzeichen), addiert zum 32-Bit-Ziel.

**Wirkung:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uhadd – Halbierende Addition (ohne Vorzeichen)

**Syntax:** `uhadd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = (Vn[i] + Vm[i]) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uhsub – Halbierende Subtraktion (ohne Vorzeichen)

**Syntax:** `uhsub Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = (Vn[i] - Vm[i]) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umaddl – Multiplikation 32 x 32 Bit ohne Vorzeichen

**Syntax:** `umaddl Xd, Wn, Wm, Xa`

Multiplikation 32 x 32 Bit ohne Vorzeichen, Addition zu 64 Bit.

**Wirkung:** `Xd = Xa + zext(Wn) * zext(Wm)`

Auch angezeigt als: `umull`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umax – Maximum der Elemente (ohne Vorzeichen)

**Syntax:** `umax Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = max_unsigned(Vn[i], Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umaxp – Maximum benachbarter Elementpaare

**Syntax:** `umaxp Vd.T, Vn.T, Vm.T`

Maximum benachbarter Elementpaare (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = max_unsigned of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umaxv – Maximum aller Elemente (ohne Vorzeichen)

**Syntax:** `umaxv Vd, Vn.T`

**Wirkung:** `Vd = max_unsigned of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umin – Minimum der Elemente (ohne Vorzeichen)

**Syntax:** `umin Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = min_unsigned(Vn[i], Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uminp – Minimum benachbarter Elementpaare

**Syntax:** `uminp Vd.T, Vn.T, Vm.T`

Minimum benachbarter Elementpaare (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = min_unsigned of each pair of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uminv – Minimum aller Elemente (ohne Vorzeichen)

**Syntax:** `uminv Vd, Vn.T`

**Wirkung:** `Vd = min_unsigned of all elements of Vn`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umlal – Multiplikation mit Verbreiterung

**Syntax:** `umlal Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umlal Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung, addiert zum Ziel (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] + Vn[i] * Vm[i]`

Auch angezeigt als: `umlal2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umlsl – Multiplikation mit Verbreiterung

**Syntax:** `umlsl Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umlsl Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung, subtrahiert vom Ziel (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vd[i] - Vn[i] * Vm[i]`

Auch angezeigt als: `umlsl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ummla – Matrix-Multiplikation 2x8 mal 8x2

**Syntax:** `ummla Vd.4S, Vn.16B, Vm.16B`

Matrix-Multiplikation 2x8 mal 8x2 (ohne Vorzeichen), addiert zum Ziel.

**Wirkung:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umov – Kopieren eines Elements in ein Ganzzahl-Register

**Syntax:** `umov Rd, Vn.Ts[index]`

Kopieren eines Elements in ein Ganzzahl-Register (ohne Vorzeichen).

**Wirkung:** `Rd = zext(Vn[index])`

Auch angezeigt als: `mov`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umsubl – Multiplikation 32 x 32 Bit ohne Vorzeichen

**Syntax:** `umsubl Xd, Wn, Wm, Xa`

Multiplikation 32 x 32 Bit ohne Vorzeichen, Subtraktion von 64 Bit.

**Wirkung:** `Xd = Xa - zext(Wn) * zext(Wm)`

Auch angezeigt als: `umnegl`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umulh – Multiplikation ohne Vorzeichen

**Syntax:** `umulh Xd, Xn, Xm`

Multiplikation ohne Vorzeichen, obere 64 Bit des Ergebnisses.

**Wirkung:** `Xd = (zext(Xn) * zext(Xm)) >> 64`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## umull – Multiplikation mit Verbreiterung

**Syntax:** `umull Vd.Tb, Vn.Ta, Vm.Ta` &nbsp; `umull Vd.Ta, Vn.Tb, Vm.Ts[index]`

Multiplikation mit Verbreiterung (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] * Vm[i] (wide result)`

Auch angezeigt als: `umull2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqadd – Addition mit Sättigung (ohne Vorzeichen)

**Syntax:** `uqadd Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] + Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqrshl – Schieben je Element mit Runden und Sättigung

**Syntax:** `uqrshl Vd.T, Vn.T, Vm.T`

Schieben je Element mit Runden und Sättigung (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] << Vm[i]))`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqrshrn – Schieben nach rechts mit Verschmälern

**Syntax:** `uqrshrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern, Runden und Sättigung (ohne Vorzeichen) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(round(Vn[i] >> shift))`

Auch angezeigt als: `uqrshrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqshl – Schieben je Element mit Sättigung

**Syntax:** `uqshl Vd.T, Vn.T, Vm.T` &nbsp; `uqshl Vd.T, Vn.T, #shift`

Schieben je Element mit Sättigung (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] << Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqshrn – Schieben nach rechts mit Verschmälern und Sättigung

**Syntax:** `uqshrn Vd.Tb, Vn.Ta, #shift`

Schieben nach rechts mit Verschmälern und Sättigung (ohne Vorzeichen) (Q = 1: Name mit 2).

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] >> shift)`

Auch angezeigt als: `uqshrn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqsub – Subtraktion mit Sättigung (ohne Vorzeichen)

**Syntax:** `uqsub Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i] - Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uqxtn – Verschmälern mit Sättigung (ohne Vorzeichen)

**Syntax:** `uqxtn Vd.T, Vn.T`

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vn[i])`

Auch angezeigt als: `uqxtn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## urhadd – Halbierende Addition mit Aufrunden

**Syntax:** `urhadd Vd.T, Vn.T, Vm.T`

Halbierende Addition mit Aufrunden (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = (Vn[i] + Vm[i] + 1) >> 1`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## urshl – Schieben je Element mit Runden (ohne Vorzeichen)

**Syntax:** `urshl Vd.T, Vn.T, Vm.T`

**Wirkung:** `for every element: Vd[i] = round(Vn[i] << Vm[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## urshr – Schieben nach rechts mit Runden (ohne Vorzeichen)

**Syntax:** `urshr Vd.T, Vn.T, #shift`

**Wirkung:** `for every element: Vd[i] = round(Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ursra – Schieben nach rechts mit Runden und Addition zum Ziel

**Syntax:** `ursra Vd.T, Vn.T, #shift`

Schieben nach rechts mit Runden und Addition zum Ziel (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + round(Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usdot – Skalarprodukt von je vier Bytes

**Syntax:** `usdot Vd.4S, Vn.16B, Vm.16B`

Skalarprodukt von je vier Bytes (Vn ohne, Vm mit Vorzeichen), addiert zum 32-Bit-Ziel.

**Wirkung:** `for every element: Vd[i] = Vd[i] + sum of Vn[4i+k] * Vm[4i+k]`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ushl – Schieben nach links oder rechts je Element

**Syntax:** `ushl Vd.T, Vn.T, Vm.T`

Schieben nach links oder rechts je Element (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[i] << Vm[i] (a negative count shifts right)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ushll – Verbreitern mit Linksschieben

**Syntax:** `ushll Vd.Ta, Vn.Tb, #shift`

Verbreitern mit Linksschieben (ohne Vorzeichen; uxtl ist Schieben um 0).

**Wirkung:** `for every element: Vd[i] = zext(Vn[i]) << shift`

Auch angezeigt als: `ushll2`, `uxtl`, `uxtl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ushr – Schieben nach rechts mit Vorzeichen

**Syntax:** `ushr Vd.T, Vn.T, #shift`

Schieben nach rechts mit Vorzeichen (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vn[i] >> shift`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usmmla – Matrix-Multiplikation 2x8 mal 8x2

**Syntax:** `usmmla Vd.4S, Vn.16B, Vm.16B`

Matrix-Multiplikation 2x8 mal 8x2 (Vn ohne, Vm mit Vorzeichen), addiert zum Ziel.

**Wirkung:** `Vd(2x2) = Vd(2x2) + Vn(2x8) * Vm(8x2)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usqadd – Addition eines Wertes mit Vorzeichen zu einem ohne

**Syntax:** `usqadd Vd.T, Vn.T`

Addition eines Wertes mit Vorzeichen zu einem ohne, mit Sättigung.

**Wirkung:** `for every element: Vd[i] = saturate_unsigned(Vd[i] + Vn[i])`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usra – Schieben nach rechts und Addition zum Ziel

**Syntax:** `usra Vd.T, Vn.T, #shift`

Schieben nach rechts und Addition zum Ziel (ohne Vorzeichen).

**Wirkung:** `for every element: Vd[i] = Vd[i] + (Vn[i] >> shift)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usubl – Subtraktion mit Verbreiterung

**Syntax:** `usubl Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion mit Verbreiterung (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] - Vm[i] (wide result)`

Auch angezeigt als: `usubl2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## usubw – Subtraktion eines schmalen Operanden von einem breiten

**Syntax:** `usubw Vd.Tb, Vn.Ta, Vm.Ta`

Subtraktion eines schmalen Operanden von einem breiten (ohne Vorzeichen; Q = 1: obere Hälfte der Quellen, Name mit 2).

**Wirkung:** `for every element: Vd[i] = Vn[i] - Vm[i] (Vn is wide)`

Auch angezeigt als: `usubw2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uzp1 – Herausziehen der Elemente mit geraden Nummern aus zwei Vektoren

**Syntax:** `uzp1 Vd.T, Vn.T, Vm.T`

**Wirkung:** `Vd = even elements of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## uzp2 – Herausziehen der Elemente mit ungeraden Nummern aus zwei Vektoren

**Syntax:** `uzp2 Vd.T, Vn.T, Vm.T`

**Wirkung:** `Vd = odd elements of (Vn:Vm)`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xar – Exklusives ODER und Rotation nach rechts (SHA-3)

**Syntax:** `xar Vd.2D, Vn.2D, Vm.2D, #imm6`

**Wirkung:** `Vd = rotate_right(Vn ^ Vm, imm6)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xtn – Verschmälern der Elemente

**Syntax:** `xtn Vd.T, Vn.T`

Verschmälern der Elemente (obere Hälfte abschneiden).

**Wirkung:** `for every element: Vd[i] = low half of Vn[i]`

Auch angezeigt als: `xtn2`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## zip1 – Mischen der unteren Hälften zweier Vektoren

**Syntax:** `zip1 Vd.T, Vn.T, Vm.T`

Mischen der unteren Hälften zweier Vektoren, abwechselnd.

**Wirkung:** `Vd = Vn[0], Vm[0], Vn[1], Vm[1] ...`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## zip2 – Mischen der oberen Hälften zweier Vektoren

**Syntax:** `zip2 Vd.T, Vn.T, Vm.T`

Mischen der oberen Hälften zweier Vektoren, abwechselnd.

**Wirkung:** `Vd = Vn[n/2], Vm[n/2], Vn[n/2+1] ...`

*Gruppe: Vektor (SIMD). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*
