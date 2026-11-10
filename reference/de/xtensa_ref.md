# Befehle aus der Befehlsreferenz (erzeugt)

Erzeugt von tools/gen_help_ref.py aus den Tabellen des Assemblers (tools/instr), nicht von Hand ändern. F1 zeigt einen Abschnitt von hier, wenn die Hilfe der Architektur keinen eigenen hat.

## abs – Betrag

**Syntax:** `abs ar, at`

**Wirkung:** `ar = |at|`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## abs.s – Gleitkomma-Betrag

**Syntax:** `abs.s fr, fs`

**Wirkung:** `fr = |fs|`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add – Addition zweier Register

**Syntax:** `add ar, as, at`

**Wirkung:** `ar = as + at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add.n – Addition zweier Register (16 Bit)

**Syntax:** `add.n ar, as, at`

**Wirkung:** `ar = as + at`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add.s – Gleitkomma-Addition

**Syntax:** `add.s fr, fs, ft`

**Wirkung:** `fr = fs + ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addexp.s – Exponenten addieren

**Syntax:** `addexp.s fr, fs`

Exponenten addieren (Schritt der Division und Wurzel).

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addexpm.s – Exponenten addieren

**Syntax:** `addexpm.s fr, fs`

Exponenten addieren, aus der Mantisse (Schritt der Division und Wurzel).

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addi – Addition einer Konstanten

**Syntax:** `addi at, as, imm8`

Addition einer Konstanten (8 Bit mit Vorzeichen); mit -1 oder 1..15 wird daraus addi.n, mit 0 mov.n.

**Wirkung:** `at = as + sext(imm8)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addi.n – Addition einer Konstanten -1 oder 1..15

**Syntax:** `addi.n ar, as, imm`

Addition einer Konstanten -1 oder 1..15 (16 Bit; das Feld 0 ist -1).

**Wirkung:** `ar = as + imm`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addmi – Addition einer Konstanten mal 256 (-32768..32512)

**Syntax:** `addmi at, as, imm`

**Wirkung:** `at = as + (sext(imm8) << 8)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addx2 – Addition, das erste Register mal 2

**Syntax:** `addx2 ar, as, at`

Addition, das erste Register mal 2 (Adresse eines Halbworts).

**Wirkung:** `ar = (as << 1) + at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addx4 – Addition, das erste Register mal 4

**Syntax:** `addx4 ar, as, at`

Addition, das erste Register mal 4 (Adresse eines Worts).

**Wirkung:** `ar = (as << 2) + at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addx8 – Addition, das erste Register mal 8

**Syntax:** `addx8 ar, as, at`

**Wirkung:** `ar = (as << 3) + at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## all4 – 1, wenn alle 4 booleschen Register 1 sind

**Syntax:** `all4 bt, bs`

**Wirkung:** `bt = bs & bs+1 & bs+2 & bs+3`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## all8 – 1, wenn alle 8 booleschen Register 1 sind

**Syntax:** `all8 bt, bs`

**Wirkung:** `bt = bs & ... & bs+7`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## and – UND

**Syntax:** `and ar, as, at`

**Wirkung:** `ar = as & at`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andb – UND boolescher Register

**Syntax:** `andb br, bs, bt`

**Wirkung:** `br = bs & bt`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andbc – UND mit dem Gegenteil des zweiten

**Syntax:** `andbc br, bs, bt`

**Wirkung:** `br = bs & ~bt`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## any4 – 1, wenn eins von 4 booleschen Registern 1 ist

**Syntax:** `any4 bt, bs`

1, wenn eins von 4 booleschen Registern 1 ist (die Gruppe ab b0, b4, b8, b12).

**Wirkung:** `bt = bs | bs+1 | bs+2 | bs+3`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## any8 – 1, wenn eins von 8 booleschen Registern 1 ist

**Syntax:** `any8 bt, bs`

1, wenn eins von 8 booleschen Registern 1 ist (ab b0 oder b8).

**Wirkung:** `bt = bs | ... | bs+7`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ball – Verzweigen, wenn alle Bits der Maske gesetzt sind

**Syntax:** `ball as, at, label`

**Wirkung:** `if (~as & at) == 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bany – Verzweigen

**Syntax:** `bany as, at, label`

Verzweigen, wenn eins der Bits der Maske gesetzt ist.

**Wirkung:** `if (as & at) != 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bbc – Verzweigen

**Syntax:** `bbc as, at, label`

Verzweigen, wenn das Bit (Nummer im Register) 0 ist.

**Wirkung:** `if as[at & 31] == 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bbci – Verzweigen, wenn das Bit (Konstante 0..31) 0 ist

**Syntax:** `bbci as, bit, label`

**Wirkung:** `if as[bit] == 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bbs – Verzweigen

**Syntax:** `bbs as, at, label`

Verzweigen, wenn das Bit (Nummer im Register) 1 ist.

**Wirkung:** `if as[at & 31] == 1: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bbsi – Verzweigen, wenn das Bit (Konstante 0..31) 1 ist

**Syntax:** `bbsi as, bit, label`

**Wirkung:** `if as[bit] == 1: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## beq – Verzweigen, wenn gleich (-128..127 Byte weit)

**Syntax:** `beq as, at, label`

**Wirkung:** `if as == at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## beqi – Verzweigen

**Syntax:** `beqi as, b4const, label`

Verzweigen, wenn gleich einer Konstanten (-1, 1..8, 10, 12, 16, 32, 64, 128, 256).

**Wirkung:** `if as == b4const: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## beqz – Verzweigen, wenn 0 (bis 2 KB weit)

**Syntax:** `beqz as, label`

**Wirkung:** `if as == 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## beqz.n – Verzweigen

**Syntax:** `beqz.n as, label`

Verzweigen, wenn 0, nur vorwärts 0..63 Byte (16 Bit).

**Wirkung:** `if as == 0: pc = label`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bf – Verzweigen, wenn das boolesche Register 0 ist

**Syntax:** `bf bs, label`

**Wirkung:** `if not bs: pc = label`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bge – Verzweigen

**Syntax:** `bge as, at, label`

Verzweigen, wenn größer oder gleich (mit Vorzeichen).

**Wirkung:** `if as >=s at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bgei – Verzweigen

**Syntax:** `bgei as, b4const, label`

Verzweigen, wenn größer oder gleich einer Konstanten (mit Vorzeichen).

**Wirkung:** `if as >=s b4const: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bgeu – Verzweigen

**Syntax:** `bgeu as, at, label`

Verzweigen, wenn größer oder gleich (ohne Vorzeichen).

**Wirkung:** `if as >=u at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bgeui – Verzweigen

**Syntax:** `bgeui as, b4constu, label`

Verzweigen, wenn größer oder gleich einer Konstanten ohne Vorzeichen.

**Wirkung:** `if as >=u b4constu: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bgez – Verzweigen, wenn nicht negativ

**Syntax:** `bgez as, label`

**Wirkung:** `if as >=s 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blt – Verzweigen, wenn kleiner (mit Vorzeichen)

**Syntax:** `blt as, at, label`

**Wirkung:** `if as <s at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blti – Verzweigen

**Syntax:** `blti as, b4const, label`

Verzweigen, wenn kleiner als eine Konstante (mit Vorzeichen).

**Wirkung:** `if as <s b4const: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bltu – Verzweigen, wenn kleiner (ohne Vorzeichen)

**Syntax:** `bltu as, at, label`

**Wirkung:** `if as <u at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bltui – Verzweigen

**Syntax:** `bltui as, b4constu, label`

Verzweigen, wenn kleiner als eine Konstante ohne Vorzeichen (2..8, 10, 12, 16, 32, 64, 128, 256, 32768, 65536).

**Wirkung:** `if as <u b4constu: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bltz – Verzweigen, wenn negativ

**Syntax:** `bltz as, label`

**Wirkung:** `if as <s 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bnall – Verzweigen

**Syntax:** `bnall as, at, label`

Verzweigen, wenn nicht alle Bits der Maske gesetzt sind.

**Wirkung:** `if (~as & at) != 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bne – Verzweigen, wenn ungleich

**Syntax:** `bne as, at, label`

**Wirkung:** `if as != at: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bnei – Verzweigen, wenn ungleich einer Konstanten

**Syntax:** `bnei as, b4const, label`

**Wirkung:** `if as != b4const: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bnez – Verzweigen, wenn nicht 0

**Syntax:** `bnez as, label`

**Wirkung:** `if as != 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bnez.n – Verzweigen

**Syntax:** `bnez.n as, label`

Verzweigen, wenn nicht 0, nur vorwärts 0..63 Byte (16 Bit).

**Wirkung:** `if as != 0: pc = label`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bnone – Verzweigen

**Syntax:** `bnone as, at, label`

Verzweigen, wenn keins der Bits der Maske gesetzt ist.

**Wirkung:** `if (as & at) == 0: pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## break – Haltepunkt

**Syntax:** `break imm4, imm4`

Haltepunkt: hält im Debugger an (Debug-Ausnahme), die Zahlen sagen dem Handler den Grund.

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## break.n – Haltepunkt

**Syntax:** `break.n imm4`

Haltepunkt (16 Bit); Asmonite setzt ihn für Haltepunkte auf 16-Bit-Befehle.

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bt – Verzweigen, wenn das boolesche Register 1 ist

**Syntax:** `bt bs, label`

**Wirkung:** `if bs: pc = label`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## call0 – Aufruf ohne Registerfenster

**Syntax:** `call0 label`

Aufruf ohne Registerfenster: die Rücksprungadresse in a0 (das Ziel durch 4 teilbar).

**Wirkung:** `a0 = pc + 3; pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## call12 – Aufruf, der das Registerfenster um 12 dreht

**Syntax:** `call12 label`

**Wirkung:** `a12 = return address (top bits: 3); PS.CALLINC = 3; pc = label`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## call4 – Aufruf, der das Registerfenster um 4 dreht

**Syntax:** `call4 label`

Aufruf, der das Registerfenster um 4 dreht (wenn die Funktion entry ausführt): a4..a7 des Aufrufers sind ihre a0..a3.

**Wirkung:** `a4 = return address (top bits: 1); PS.CALLINC = 1; pc = label`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## call8 – Aufruf, der das Registerfenster um 8 dreht

**Syntax:** `call8 label`

Aufruf, der das Registerfenster um 8 dreht: a10..a15 des Aufrufers sind die Argumente a2..a7 der Funktion.

**Wirkung:** `a8 = return address (top bits: 2); PS.CALLINC = 2; pc = label`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## callx0 – Aufruf der Adresse im Register

**Syntax:** `callx0 as`

Aufruf der Adresse im Register, ohne Registerfenster.

**Wirkung:** `a0 = pc + 3; pc = as`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## callx12 – call12 an die Adresse im Register

**Syntax:** `callx12 as`

**Wirkung:** `a12 = return address; PS.CALLINC = 3; pc = as`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## callx4 – call4 an die Adresse im Register

**Syntax:** `callx4 as`

**Wirkung:** `a4 = return address; PS.CALLINC = 1; pc = as`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## callx8 – call8 an die Adresse im Register

**Syntax:** `callx8 as`

**Wirkung:** `a8 = return address; PS.CALLINC = 2; pc = as`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ceil.s – In eine Ganzzahl wandeln, aufgerundet

**Syntax:** `ceil.s ar, fs, imm4`

**Wirkung:** `ar = ceil(fs * 2^imm4)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clamps – Begrenzen auf den Bereich einer Zahl mit b+1 Bit

**Syntax:** `clamps ar, as, bits`

Begrenzen auf den Bereich einer Zahl mit b+1 Bit (7..22) mit Vorzeichen.

**Wirkung:** `ar = min(max(as, -2^b), 2^b - 1)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## const.s – Eine Gleitkomma-Konstante laden

**Syntax:** `const.s fr, imm4`

Eine Gleitkomma-Konstante laden (0, 1, 2, 0.5 ... nach imm4).

**Wirkung:** `fr = constant[imm4]`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## div0.s – Anfangswert für eine Division

**Syntax:** `div0.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divn.s – Letzter Schritt einer Division

**Syntax:** `divn.s fr, fs, ft`

Letzter Schritt einer Division (nach div0.s, nexp01.s ...).

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dsync – Warten, bis geschriebene Spezialregister für Speicherzugriffe gelten

**Syntax:** `dsync`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## entry – Der erste Befehl einer Funktion mit Registerfenster

**Syntax:** `entry as, framesize`

Der erste Befehl einer Funktion mit Registerfenster: dreht das Fenster um PS.CALLINC * 4 und legt den Stack an (framesize 0..32760, durch 8 teilbar; die Adresse durch 4 teilbar).

**Wirkung:** `WINDOWBASE += PS.CALLINC; as = as(old window) - framesize`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## esync – Warten, bis geschriebene Spezialregister für die Ausführung gelten

**Syntax:** `esync`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## excw – Warten, bis die Ausnahmen der vorigen Befehle ausgelöst sind

**Syntax:** `excw`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## extui – Ein Bitfeld ohne Vorzeichen holen

**Syntax:** `extui ar, at, shift, width`

Ein Bitfeld ohne Vorzeichen holen: width Bit ab Bit shift (shift + width bis 32).

**Wirkung:** `ar = (at >> shift) & ((1 << width) - 1)`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## extw – Warten, bis alle früheren Zugriffe außen angekommen sind

**Syntax:** `extw`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## float.s – Ganzzahl mit Vorzeichen in Gleitkomma wandeln

**Syntax:** `float.s fr, as, imm4`

Ganzzahl mit Vorzeichen in Gleitkomma wandeln, geteilt durch 2^imm4.

**Wirkung:** `fr = float(as) / 2^imm4`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## floor.s – In eine Ganzzahl wandeln, abgerundet

**Syntax:** `floor.s ar, fs, imm4`

**Wirkung:** `ar = floor(fs * 2^imm4)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## idtlb – Eintrag des Daten-TLB ungültig machen

**Syntax:** `idtlb as`

**Wirkung:** `invalidate DTLB[as]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## iitlb – Eintrag des Befehls-TLB ungültig machen

**Syntax:** `iitlb as`

**Wirkung:** `invalidate ITLB[as]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ill – Ungültiger Befehl: löst eine Ausnahme aus

**Syntax:** `ill`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ill.n – Ungültiger Befehl (16 Bit)

**Syntax:** `ill.n`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## isync – Befehle neu holen

**Syntax:** `isync`

Befehle neu holen (nach geändertem Code oder geänderten Spezialregistern).

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## j – Sprung (bis 128 KB weit)

**Syntax:** `j label`

**Wirkung:** `pc = label`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jx – Sprung an die Adresse im Register

**Syntax:** `jx as`

**Wirkung:** `pc = as`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l16si – Laden eines Halbworts mit Vorzeichen

**Syntax:** `l16si at, as, offset`

**Wirkung:** `at = sext(mem16[as + (imm8 << 1)])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l16ui – Laden eines Halbworts ohne Vorzeichen

**Syntax:** `l16ui at, as, offset`

Laden eines Halbworts ohne Vorzeichen (Offset 0..510, gerade).

**Wirkung:** `at = zext(mem16[as + (imm8 << 1)])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l32ai – Laden eines Worts mit Acquire-Ordnung

**Syntax:** `l32ai at, as, offset`

Laden eines Worts mit Acquire-Ordnung (spätere Zugriffe erst danach).

**Wirkung:** `at = mem32[as + (imm8 << 2)]; acquire`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l32e – Laden für die Handler der Fensterausnahmen

**Syntax:** `l32e at, as, offset`

Laden für die Handler der Fensterausnahmen (Offset -64..-4).

**Wirkung:** `at = mem32[as + ((imm4 << 2) - 64)]`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l32i – Laden eines Worts

**Syntax:** `l32i at, as, offset`

Laden eines Worts (Offset 0..1020, durch 4 teilbar); mit kleinem Offset wird daraus l32i.n.

**Wirkung:** `at = mem32[as + (imm8 << 2)]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l32i.n – Laden eines Worts, Offset 0..60 (16 Bit)

**Syntax:** `l32i.n at, as, offset`

**Wirkung:** `at = mem32[as + (imm4 << 2)]`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l32r – Laden eines Worts aus dem Literal-Pool

**Syntax:** `l32r at, label`

Laden eines Worts aus dem Literal-Pool: einer Konstanten, die bis zu 256 KB vor dem Befehl steht (die Adresse durch 4 teilbar); so kommen 32-Bit-Konstanten in ein Register.

**Wirkung:** `at = mem32[((pc + 3) & ~3) + (0xFFFF0000 | imm16) * 4]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## l8ui – Laden eines Bytes ohne Vorzeichen

**Syntax:** `l8ui at, as, imm8`

**Wirkung:** `at = zext(mem8[as + imm8])`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lddr32.p – Debug-Modus

**Syntax:** `lddr32.p as`

Debug-Modus: ein Wort nach DDR laden und die Adresse um 4 erhöhen (schnelles Lesen des Speichers durch den Debugger).

**Wirkung:** `DDR = mem32[as]; as += 4`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loop – Schleife ohne Zusatzaufwand

**Syntax:** `loop as, label`

Schleife ohne Zusatzaufwand: der Teil bis label läuft as-mal (as = 0: 2^32-mal); LBEG, LEND, LCOUNT.

**Wirkung:** `LCOUNT = as - 1; LBEG = pc + 3; LEND = label`

*Gruppe: Schleifen ohne Zusatzaufwand (loop). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loopgtz – Schleife wie loop

**Syntax:** `loopgtz as, label`

Schleife wie loop, übersprungen, wenn as nicht größer als 0 ist.

**Wirkung:** `if as <=s 0: pc = label else loop`

*Gruppe: Schleifen ohne Zusatzaufwand (loop). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loopnez – Schleife wie loop, bei as = 0 übersprungen

**Syntax:** `loopnez as, label`

**Wirkung:** `if as == 0: pc = label else loop`

*Gruppe: Schleifen ohne Zusatzaufwand (loop). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsi – Gleitkommazahl laden

**Syntax:** `lsi ft, as, offset`

**Wirkung:** `ft = mem32[as + (imm8 << 2)]`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsip – Gleitkommazahl laden, dann die Adresse erhöhen

**Syntax:** `lsip ft, as, offset`

**Wirkung:** `ft = mem32[as]; as += imm8 << 2`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsx – Gleitkommazahl laden, Adresse aus zwei Registern

**Syntax:** `lsx fr, as, at`

**Wirkung:** `fr = mem32[as + at]`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsxp – Gleitkommazahl laden, dann die Adresse erhöhen

**Syntax:** `lsxp fr, as, at`

**Wirkung:** `fr = mem32[as]; as += at`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## madd.s – Multiplizieren und addieren

**Syntax:** `madd.s fr, fs, ft`

**Wirkung:** `fr = fr + fs * ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maddn.s – Multiplizieren und addieren

**Syntax:** `maddn.s fr, fs, ft`

Multiplizieren und addieren, gerundet zur nächsten Zahl (ein Schritt der Division und Wurzel).

**Wirkung:** `fr = round(fr + fs * ft)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## max – Maximum mit Vorzeichen

**Syntax:** `max ar, as, at`

**Wirkung:** `ar = (as >s at) ? as : at`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxu – Maximum ohne Vorzeichen

**Syntax:** `maxu ar, as, at`

**Wirkung:** `ar = (as >u at) ? as : at`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## memw – Speicherschranke

**Syntax:** `memw`

Speicherschranke: frühere Zugriffe vor späteren (für Peripherieregister).

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## min – Minimum mit Vorzeichen

**Syntax:** `min ar, as, at`

**Wirkung:** `ar = (as <s at) ? as : at`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minu – Minimum ohne Vorzeichen

**Syntax:** `minu ar, as, at`

**Wirkung:** `ar = (as <u at) ? as : at`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mkdadj.s – Exponentenkorrektur für die Division bilden

**Syntax:** `mkdadj.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mksadj.s – Exponentenkorrektur für die Quadratwurzel bilden

**Syntax:** `mksadj.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mov.n – Kopieren eines Registers (16 Bit)

**Syntax:** `mov.n at, as`

**Wirkung:** `at = as`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mov.s – Gleitkommaregister kopieren

**Syntax:** `mov.s fr, fs`

**Wirkung:** `fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## moveqz – Kopieren, wenn das dritte Register 0 ist

**Syntax:** `moveqz ar, as, at`

**Wirkung:** `if at == 0: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## moveqz.s – Gleitkommaregister kopieren, wenn at 0 ist

**Syntax:** `moveqz.s fr, fs, at`

**Wirkung:** `if at == 0: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movf – Kopieren, wenn das boolesche Register 0 ist

**Syntax:** `movf ar, as, bt`

**Wirkung:** `if not bt: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movf.s – Gleitkommaregister kopieren

**Syntax:** `movf.s fr, fs, bt`

Gleitkommaregister kopieren, wenn das boolesche Register 0 ist.

**Wirkung:** `if not bt: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movgez – Kopieren, wenn das dritte Register nicht negativ ist

**Syntax:** `movgez ar, as, at`

**Wirkung:** `if at >=s 0: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movgez.s – Gleitkommaregister kopieren

**Syntax:** `movgez.s fr, fs, at`

Gleitkommaregister kopieren, wenn at nicht negativ ist.

**Wirkung:** `if at >=s 0: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movi – Laden einer Konstanten

**Syntax:** `movi at, imm12`

Laden einer Konstanten (12 Bit mit Vorzeichen, -2048..2047); größere kommen mit l32r.

**Wirkung:** `at = sext(imm12)`

*Gruppe: Konstanten und Adressen laden. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movi.n – Laden einer Konstanten -32..95 (16 Bit)

**Syntax:** `movi.n as, imm7`

**Wirkung:** `as = imm7`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movltz – Kopieren, wenn das dritte Register negativ ist

**Syntax:** `movltz ar, as, at`

**Wirkung:** `if at <s 0: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movltz.s – Gleitkommaregister kopieren, wenn at negativ ist

**Syntax:** `movltz.s fr, fs, at`

**Wirkung:** `if at <s 0: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movnez – Kopieren, wenn das dritte Register nicht 0 ist

**Syntax:** `movnez ar, as, at`

**Wirkung:** `if at != 0: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movnez.s – Gleitkommaregister kopieren, wenn at nicht 0 ist

**Syntax:** `movnez.s fr, fs, at`

**Wirkung:** `if at != 0: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsp – Den Stackpointer setzen

**Syntax:** `movsp at, as`

Den Stackpointer setzen, so dass Registerfenster der Aufrufer zuerst gespeichert werden.

**Wirkung:** `at = as (after spilling the windows when needed)`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movt – Kopieren, wenn das boolesche Register 1 ist

**Syntax:** `movt ar, as, bt`

**Wirkung:** `if bt: ar = as`

*Gruppe: Bedingte Auswahl. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movt.s – Gleitkommaregister kopieren

**Syntax:** `movt.s fr, fs, bt`

Gleitkommaregister kopieren, wenn das boolesche Register 1 ist.

**Wirkung:** `if bt: fr = fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## msub.s – Multiplizieren und subtrahieren

**Syntax:** `msub.s fr, fs, ft`

**Wirkung:** `fr = fr - fs * ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul.s – Gleitkomma-Multiplikation

**Syntax:** `mul.s fr, fs, ft`

**Wirkung:** `fr = fs * ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul16s – Multiplikation der unteren 16 Bit mit Vorzeichen

**Syntax:** `mul16s ar, as, at`

**Wirkung:** `ar = sext(as[15:0]) * sext(at[15:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul16u – Multiplikation der unteren 16 Bit ohne Vorzeichen

**Syntax:** `mul16u ar, as, at`

**Wirkung:** `ar = zext(as[15:0]) * zext(at[15:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mull – Multiplikation, die unteren 32 Bit

**Syntax:** `mull ar, as, at`

**Wirkung:** `ar = (as * at)[31:0]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulsh – Multiplikation mit Vorzeichen, die oberen 32 Bit

**Syntax:** `mulsh ar, as, at`

**Wirkung:** `ar = (as *s at)[63:32]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## muluh – Multiplikation ohne Vorzeichen, die oberen 32 Bit

**Syntax:** `muluh ar, as, at`

**Wirkung:** `ar = (as *u at)[63:32]`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## neg – Negation

**Syntax:** `neg ar, at`

**Wirkung:** `ar = -at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## neg.s – Gleitkomma-Negation

**Syntax:** `neg.s fr, fs`

**Wirkung:** `fr = -fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nexp01.s – Mantisse auf 1..2 bringen und Exponent negieren

**Syntax:** `nexp01.s fr, fs`

Mantisse auf 1..2 bringen und Exponent negieren (Schritt der Division und Wurzel).

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nop – Keine Wirkung; wird als nop.n geschrieben

**Syntax:** `nop`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nop.n – Keine Wirkung (16 Bit)

**Syntax:** `nop.n`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nsa – Anzahl der Vorzeichenbits minus 1

**Syntax:** `nsa at, as`

Anzahl der Vorzeichenbits minus 1 (Normalisieren mit Vorzeichen).

**Wirkung:** `at = count of the leading bits equal to as[31], less 1`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nsau – Anzahl der führenden Nullbits (32 bei 0)

**Syntax:** `nsau at, as`

**Wirkung:** `at = clz(as)`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## oeq.s – Vergleich: 1, wenn gleich (ohne NaN)

**Syntax:** `oeq.s br, fs, ft`

**Wirkung:** `br = fs == ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ole.s – Vergleich: 1, wenn kleiner oder gleich (ohne NaN)

**Syntax:** `ole.s br, fs, ft`

**Wirkung:** `br = fs <= ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## olt.s – Vergleich: 1, wenn kleiner (ohne NaN)

**Syntax:** `olt.s br, fs, ft`

**Wirkung:** `br = fs < ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## or – ODER; mit zwei gleichen Quellen das Kopieren eines Registers

**Syntax:** `or ar, as, at`

ODER; mit zwei gleichen Quellen das Kopieren eines Registers (mov, als mov.n).

**Wirkung:** `ar = as | at`

Auch angezeigt als: `mov`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orb – ODER boolescher Register

**Syntax:** `orb br, bs, bt`

**Wirkung:** `br = bs | bt`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orbc – ODER mit dem Gegenteil des zweiten

**Syntax:** `orbc br, bs, bt`

**Wirkung:** `br = bs | ~bt`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pdtlb – Daten-TLB für eine Adresse befragen

**Syntax:** `pdtlb at, as`

**Wirkung:** `at = probe DTLB(as)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pitlb – Befehls-TLB für eine Adresse befragen

**Syntax:** `pitlb at, as`

**Wirkung:** `at = probe ITLB(as)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## quos – Division mit Vorzeichen

**Syntax:** `quos ar, as, at`

**Wirkung:** `ar = as /s at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## quou – Division ohne Vorzeichen (bei 0: Ausnahme)

**Syntax:** `quou ar, as, at`

**Wirkung:** `ar = as /u at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdtlb0 – Eintrag des Daten-TLB lesen (virtuelle Adresse)

**Syntax:** `rdtlb0 at, as`

**Wirkung:** `at = DTLB[as].vaddr`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdtlb1 – Eintrag des Daten-TLB lesen (Übersetzung)

**Syntax:** `rdtlb1 at, as`

**Wirkung:** `at = DTLB[as].paddr`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## recip0.s – Anfangswert für einen Kehrwert

**Syntax:** `recip0.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rems – Rest der Division mit Vorzeichen

**Syntax:** `rems ar, as, at`

**Wirkung:** `ar = as %s at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## remu – Rest der Division ohne Vorzeichen

**Syntax:** `remu ar, as, at`

**Wirkung:** `ar = as %u at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rer – Externes Register lesen

**Syntax:** `rer at, as`

**Wirkung:** `at = ER[as]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ret – Rücksprung nach call0

**Syntax:** `ret`

Rücksprung nach call0 (an a0); wird als ret.n geschrieben.

**Wirkung:** `pc = a0`

*Gruppe: Sprünge und Aufrufe. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ret.n – Rücksprung nach call0 (16 Bit)

**Syntax:** `ret.n`

**Wirkung:** `pc = a0`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## retw – Rücksprung aus einer Funktion mit Registerfenster

**Syntax:** `retw`

Rücksprung aus einer Funktion mit Registerfenster: dreht das Fenster zurück; wird als retw.n geschrieben.

**Wirkung:** `pc = a0 (top bits from pc); WINDOWBASE -= a0[31:30]`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## retw.n – Rücksprung mit Registerfenster (16 Bit)

**Syntax:** `retw.n`

**Wirkung:** `pc = a0; WINDOWBASE -= a0[31:30]`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfdd – Rückkehr aus einer Debug-Ausnahme im Debug-Modus

**Syntax:** `rfdd`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfde – Rückkehr aus einer doppelten Ausnahme

**Syntax:** `rfde`

**Wirkung:** `pc = DEPC`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfdo – Rückkehr aus dem Debug-Modus

**Syntax:** `rfdo imm4`

Rückkehr aus dem Debug-Modus (OCD: der Debugger lässt den Kern weiterlaufen).

**Wirkung:** `pc = EPC6; PS = EPS6`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfe – Rückkehr aus einer Ausnahme der Ebene 1

**Syntax:** `rfe`

**Wirkung:** `pc = EPC1; PS.EXCM = 0`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfi – Rückkehr aus einem Interrupt der Ebene imm4

**Syntax:** `rfi imm4`

**Wirkung:** `pc = EPC[imm4]; PS = EPS[imm4]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfr – Gleitkommaregister in ein Adressregister kopieren

**Syntax:** `rfr ar, fs`

Gleitkommaregister in ein Adressregister kopieren (die Bits).

**Wirkung:** `ar = bits(fs)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfwo – Rückkehr aus dem Handler eines Fensterüberlaufs

**Syntax:** `rfwo`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rfwu – Rückkehr aus dem Handler eines Fensterunterlaufs

**Syntax:** `rfwu`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ritlb0 – Eintrag des Befehls-TLB lesen (virtuelle Adresse)

**Syntax:** `ritlb0 at, as`

**Wirkung:** `at = ITLB[as].vaddr`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ritlb1 – Eintrag des Befehls-TLB lesen (Übersetzung)

**Syntax:** `ritlb1 at, as`

**Wirkung:** `at = ITLB[as].paddr`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rotw – Das Registerfenster drehen

**Syntax:** `rotw imm4`

Das Registerfenster drehen (in den Handlern der Fensterausnahmen).

**Wirkung:** `WINDOWBASE += imm4`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## round.s – In eine Ganzzahl wandeln, gerundet (mal 2^imm4)

**Syntax:** `round.s ar, fs, imm4`

**Wirkung:** `ar = round(fs * 2^imm4)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsil – PS lesen und die Interrupt-Ebene setzen

**Syntax:** `rsil at, imm4`

PS lesen und die Interrupt-Ebene setzen (Interrupts bis imm4 aus).

**Wirkung:** `at = PS; PS.INTLEVEL = imm4`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsqrt0.s – Anfangswert für den Kehrwert einer Quadratwurzel

**Syntax:** `rsqrt0.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsr – Spezialregister lesen

**Syntax:** `rsr sr, at`

Spezialregister lesen; auch rsr.name at geschrieben (rsr.ps a3).

**Wirkung:** `at = SR[sr]`

*Gruppe: Spezial- und Benutzerregister. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsync – Warten, bis geschriebene Spezialregister für das Lesen von Registern gelten

**Syntax:** `rsync`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rur – Benutzerregister lesen

**Syntax:** `rur ar, ur`

Benutzerregister lesen (threadptr, fcr, fsr ...); auch rur.name ar.

**Wirkung:** `ar = UR[ur]`

*Gruppe: Spezial- und Benutzerregister. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s16i – Speichern eines Halbworts

**Syntax:** `s16i at, as, offset`

**Wirkung:** `mem16[as + (imm8 << 1)] = at[15:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32c1i – Bedingtes Speichern

**Syntax:** `s32c1i at, as, offset`

Bedingtes Speichern (Compare and Swap): speichert at, wenn das Wort gleich SCOMPARE1 ist; at bekommt den alten Wert.

**Wirkung:** `old = mem32[a]; if old == SCOMPARE1: mem32[a] = at; at = old`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32e – Speichern für die Handler der Fensterausnahmen

**Syntax:** `s32e at, as, offset`

Speichern für die Handler der Fensterausnahmen (Offset -64..-4).

**Wirkung:** `mem32[as + ((imm4 << 2) - 64)] = at`

*Gruppe: Registerfenster (call4/8/12, entry, retw). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32i – Speichern eines Worts

**Syntax:** `s32i at, as, offset`

Speichern eines Worts; mit kleinem Offset wird daraus s32i.n.

**Wirkung:** `mem32[as + (imm8 << 2)] = at`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32i.n – Speichern eines Worts, Offset 0..60 (16 Bit)

**Syntax:** `s32i.n at, as, offset`

**Wirkung:** `mem32[as + (imm4 << 2)] = at`

*Gruppe: 16-Bit-Befehle (Code Density). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32nb – Speichern eines Worts am Schreibpuffer vorbei

**Syntax:** `s32nb at, as, offset`

Speichern eines Worts am Schreibpuffer vorbei (Offset 0..60).

**Wirkung:** `mem32[as + (imm4 << 2)] = at`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s32ri – Speichern eines Worts mit Release-Ordnung

**Syntax:** `s32ri at, as, offset`

Speichern eines Worts mit Release-Ordnung (frühere Zugriffe zuerst).

**Wirkung:** `release; mem32[as + (imm8 << 2)] = at`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## s8i – Speichern eines Bytes

**Syntax:** `s8i at, as, imm8`

**Wirkung:** `mem8[as + imm8] = at[7:0]`

*Gruppe: Laden und Speichern. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## salt – Vergleich mit Vorzeichen

**Syntax:** `salt ar, as, at`

Vergleich mit Vorzeichen: 1, wenn kleiner (nur ESP32-S3, nicht ESP32).

**Wirkung:** `ar = (as <s at) ? 1 : 0`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## saltu – Vergleich ohne Vorzeichen

**Syntax:** `saltu ar, as, at`

Vergleich ohne Vorzeichen: 1, wenn kleiner (nur ESP32-S3, nicht ESP32).

**Wirkung:** `ar = (as <u at) ? 1 : 0`

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sddr32.p – Debug-Modus

**Syntax:** `sddr32.p as`

Debug-Modus: DDR speichern und die Adresse um 4 erhöhen.

**Wirkung:** `mem32[as] = DDR; as += 4`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sext – Vorzeichen erweitern ab Bit b (7..22)

**Syntax:** `sext ar, as, bits`

**Wirkung:** `ar = sext(as[b:0])`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## simcall – Aufruf eines Simulators

**Syntax:** `simcall`

Aufruf eines Simulators (auf dem Chip ohne Wirkung).

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sll – Schieben nach links um 32 minus SAR

**Syntax:** `sll ar, as`

Schieben nach links um 32 minus SAR (SAR mit ssl gesetzt).

**Wirkung:** `ar = as << (32 - SAR)`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## slli – Schieben nach links um eine Konstante

**Syntax:** `slli ar, as, sa`

Schieben nach links um eine Konstante (1..31; die Felder halten 32 minus sa).

**Wirkung:** `ar = as << sa`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrt0.s – Anfangswert für eine Quadratwurzel

**Syntax:** `sqrt0.s fr, fs`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sra – Schieben nach rechts mit Vorzeichen um SAR

**Syntax:** `sra ar, at`

**Wirkung:** `ar = at >>s SAR`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srai – Schieben nach rechts mit Vorzeichen um eine Konstante

**Syntax:** `srai ar, at, sa`

Schieben nach rechts mit Vorzeichen um eine Konstante (0..31).

**Wirkung:** `ar = at >>s sa`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## src – Schieben nach rechts über zwei Register

**Syntax:** `src ar, as, at`

Schieben nach rechts über zwei Register (64 Bit) um SAR; mit zweimal demselben Register ein Rotieren.

**Wirkung:** `ar = ((as : at) >> SAR)[31:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srl – Schieben nach rechts ohne Vorzeichen um SAR

**Syntax:** `srl ar, at`

**Wirkung:** `ar = at >>u SAR`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## srli – Schieben nach rechts ohne Vorzeichen um eine Konstante

**Syntax:** `srli ar, at, imm4`

Schieben nach rechts ohne Vorzeichen um eine Konstante (0..15; mehr mit extui).

**Wirkung:** `ar = at >>u imm4`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssa8b – SAR für das Schieben um ganze Bytes

**Syntax:** `ssa8b as`

SAR für das Schieben um ganze Bytes (big endian) setzen.

**Wirkung:** `SAR = 32 - as[1:0] * 8`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssa8l – SAR für das Schieben um ganze Bytes

**Syntax:** `ssa8l as`

SAR für das Schieben um ganze Bytes (little endian) setzen.

**Wirkung:** `SAR = as[1:0] * 8`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssai – SAR auf eine Konstante setzen

**Syntax:** `ssai sa`

**Wirkung:** `SAR = sa`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssi – Gleitkommazahl speichern

**Syntax:** `ssi ft, as, offset`

**Wirkung:** `mem32[as + (imm8 << 2)] = ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssip – Gleitkommazahl speichern, dann die Adresse erhöhen

**Syntax:** `ssip ft, as, offset`

**Wirkung:** `mem32[as] = ft; as += imm8 << 2`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssl – SAR für das Schieben nach links setzen

**Syntax:** `ssl as`

**Wirkung:** `SAR = 32 - as[4:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssr – SAR für das Schieben nach rechts setzen

**Syntax:** `ssr as`

SAR für das Schieben nach rechts setzen (aus den unteren 5 Bit).

**Wirkung:** `SAR = as[4:0]`

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssx – Gleitkommazahl speichern

**Syntax:** `ssx fr, as, at`

Gleitkommazahl speichern, Adresse aus zwei Registern.

**Wirkung:** `mem32[as + at] = fr`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ssxp – Gleitkommazahl speichern, dann die Adresse erhöhen

**Syntax:** `ssxp fr, as, at`

**Wirkung:** `mem32[as] = fr; as += at`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub – Subtraktion zweier Register

**Syntax:** `sub ar, as, at`

**Wirkung:** `ar = as - at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub.s – Gleitkomma-Subtraktion

**Syntax:** `sub.s fr, fs, ft`

**Wirkung:** `fr = fs - ft`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subx2 – Subtraktion, das erste Register mal 2

**Syntax:** `subx2 ar, as, at`

**Wirkung:** `ar = (as << 1) - at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subx4 – Subtraktion, das erste Register mal 4

**Syntax:** `subx4 ar, as, at`

**Wirkung:** `ar = (as << 2) - at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subx8 – Subtraktion, das erste Register mal 8

**Syntax:** `subx8 ar, as, at`

**Wirkung:** `ar = (as << 3) - at`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## syscall – Systemaufruf: löst die Ausnahme SYSCALL aus

**Syntax:** `syscall`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## trunc.s – In eine Ganzzahl wandeln, abgeschnitten

**Syntax:** `trunc.s ar, fs, imm4`

**Wirkung:** `ar = trunc(fs * 2^imm4)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ueq.s – Vergleich: 1, wenn gleich oder NaN

**Syntax:** `ueq.s br, fs, ft`

**Wirkung:** `br = fs == ft or unordered`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ufloat.s – Ganzzahl ohne Vorzeichen in Gleitkomma wandeln

**Syntax:** `ufloat.s fr, as, imm4`

Ganzzahl ohne Vorzeichen in Gleitkomma wandeln, geteilt durch 2^imm4.

**Wirkung:** `fr = ufloat(as) / 2^imm4`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ule.s – Vergleich: 1, wenn kleiner oder gleich oder NaN

**Syntax:** `ule.s br, fs, ft`

**Wirkung:** `br = fs <= ft or unordered`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ult.s – Vergleich: 1, wenn kleiner oder NaN

**Syntax:** `ult.s br, fs, ft`

**Wirkung:** `br = fs < ft or unordered`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## un.s – Vergleich: 1, wenn eine der Zahlen NaN ist

**Syntax:** `un.s br, fs, ft`

**Wirkung:** `br = isnan(fs) or isnan(ft)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## utrunc.s – In eine Ganzzahl ohne Vorzeichen wandeln

**Syntax:** `utrunc.s ar, fs, imm4`

In eine Ganzzahl ohne Vorzeichen wandeln, abgeschnitten.

**Wirkung:** `ar = utrunc(fs * 2^imm4)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## waiti – Interrupt-Ebene setzen und auf einen Interrupt warten

**Syntax:** `waiti imm4`

Interrupt-Ebene setzen und auf einen Interrupt warten (Strom sparen).

**Wirkung:** `PS.INTLEVEL = imm4; wait`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wdtlb – Eintrag des Daten-TLB schreiben

**Syntax:** `wdtlb at, as`

**Wirkung:** `DTLB[as] = at`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wer – Externes Register schreiben

**Syntax:** `wer at, as`

**Wirkung:** `ER[as] = at`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wfr – Adressregister in ein Gleitkommaregister kopieren

**Syntax:** `wfr fr, as`

Adressregister in ein Gleitkommaregister kopieren (die Bits).

**Wirkung:** `fr = bits(as)`

*Gruppe: Gleitkomma (skalar). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## witlb – Eintrag des Befehls-TLB schreiben

**Syntax:** `witlb at, as`

**Wirkung:** `ITLB[as] = at`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wsr – Spezialregister schreiben; auch wsr.name at

**Syntax:** `wsr sr, at`

**Wirkung:** `SR[sr] = at`

*Gruppe: Spezial- und Benutzerregister. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wur – Benutzerregister schreiben; auch wur.name at

**Syntax:** `wur ur, at`

**Wirkung:** `UR[ur] = at`

*Gruppe: Spezial- und Benutzerregister. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xor – Exklusives ODER

**Syntax:** `xor ar, as, at`

**Wirkung:** `ar = as ^ at`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xorb – Exklusives ODER boolescher Register

**Syntax:** `xorb br, bs, bt`

**Wirkung:** `br = bs ^ bt`

*Gruppe: Boolesche Register. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsr – Spezialregister und Register tauschen

**Syntax:** `xsr sr, at`

Spezialregister und Register tauschen; auch xsr.name at.

**Wirkung:** `t = SR[sr]; SR[sr] = at; at = t`

*Gruppe: Spezial- und Benutzerregister. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*
