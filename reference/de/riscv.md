# RISC-V-Befehle (RV32, Hazard3)

Die Befehlsinfo von Asmonite (F1) für RISC-V (`.arch riscv32`), so wie die beiden RISC-V-Kerne (Hazard3) des Raspberry Pi Pico 2 sie haben: der Grundbefehlssatz RV32I, die Erweiterungen M (Multiplizieren und Dividieren), A (atomare Befehle), Zicsr (Steuerregister), Zifencei, C und Zcb (kurze 16-Bit-Formen) und die Bit-Manipulations-Sätze Zba, Zbb, Zbs, Zbc und Zbkb.

Jeder Abschnitt beginnt mit `## ` und den Namen, die er erklärt; lange Listen stehen in einer Zeile `<!-- names: ... -->`. Atomare Befehle mit `.aq`, `.rl` oder `.aqrl` (`amoadd.w.aq`) findet die Hilfe unter ihrem Namen ohne diese Endung.

Neu bei RISC-V? Lies zuerst `riscv` (der Prozessor in Kürze), `registers`, `pseudo` und `encoding`.

## riscv, rv32 – der Prozessor in Kürze
<!-- names: riscv, rv32, hazard3 -->

RISC-V ist ein offener Befehlssatz. Ein RV32-Kern hat:

- **32 Allzweckregister** `x0` bis `x31`, je 32 Bit breit. `x0` liest sich immer als 0 und ignoriert Schreiben. Der pc gehört nicht dazu.
- **Keine Flags.** Vergleichen und Verzweigen ist ein Befehl: `beq a0, a1, marke` springt, wenn die beiden Register gleich sind. Es gibt kein Carry- oder Zero-Flag und kein `cmp`.
- **Laden und Speichern.** Nur `lw`, `sw` und ihre Verwandten greifen auf den Speicher zu; alles andere arbeitet mit Registern.
- **Befehle mit 4 Bytes** (auf 2 ausgerichtet); mit der Erweiterung C haben viele eine kurze Form mit 2 Bytes. Little Endian.
- **Kein Push und Pop.** Der Stack ist ein gewöhnlicher Speicherbereich; `sp` zeigt darauf, und du verschiebst ihn selbst (`addi sp, sp, -16`, `sw ra, 12(sp)`).
- **Aufrufe** legen die Rücksprungadresse in ein Register: `jal ra, funktion` setzt `ra`, `ret` springt zurück. Eine Funktion, die eine andere aufruft, muss `ra` vorher sichern.

Die Namen der Register und was ein übliches Programm mit ihnen macht, steht unter `registers`. Die Befehlsformen stehen unter `encoding`, die Kurznamen, die der Assembler dazugibt, unter `pseudo`.

Siehe auch: `registers`, `encoding`, `pseudo`, `csr`

## registers – x0 bis x31 und ihre Namen
<!-- names: registers, abi, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, t0, t1, t2, t3, t4, t5, t6, s0, fp, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, a0, a1, a2, a3, a4, a5, a6, a7 -->

Jedes Register hat eine Nummer (`x5`) und einen Namen, der sagt, wofür ein Programm es üblicherweise benutzt (die „ABI“). Beides kannst du schreiben; der Debugger zeigt die Namen.

| Register | Name | Verwendung | Bleibt beim Aufruf erhalten? |
|---|---|---|---|
| `x0` | `zero` | immer 0 | – |
| `x1` | `ra` | Rücksprungadresse | nein |
| `x2` | `sp` | Stackzeiger | ja |
| `x3` | `gp` | Global Pointer | – |
| `x4` | `tp` | Thread Pointer | – |
| `x5`–`x7` | `t0`–`t2` | Zwischenwerte | nein |
| `x8` | `s0`, `fp` | gesichertes Register, Framezeiger | ja |
| `x9` | `s1` | gesichertes Register | ja |
| `x10`–`x11` | `a0`–`a1` | Argumente und Rückgabewerte | nein |
| `x12`–`x17` | `a2`–`a7` | Argumente | nein |
| `x18`–`x27` | `s2`–`s11` | gesicherte Register | ja |
| `x28`–`x31` | `t3`–`t6` | Zwischenwerte | nein |

„Bleibt beim Aufruf erhalten“ heißt: Eine Funktion, die `s0` benutzt, muss es unverändert zurückgeben; `t0` und `a0` darf sie beliebig ändern. Eine Funktion bekommt ihre ersten Argumente in `a0` bis `a7` und gibt ihr Ergebnis in `a0` (und `a1`) zurück.

In einem kleinen Programm für den Pico 2 kannst du alle Register frei benutzen; die Tabelle zählt, wenn du Code anderer aufrufst (das SDK, das Boot-ROM).

Siehe auch: `zero`, `ra`, `sp`, `pseudo`

## zero – das Register, das immer 0 ist
<!-- names: zero -->

`x0` (`zero`) liest sich als 0 und verwirft, was hineingeschrieben wird. Das ersetzt mehrere Befehle, die andere Prozessoren haben: `mv a0, zero` löscht ein Register, `beq a0, zero, marke` prüft auf 0, und `jal zero, marke` ist ein Sprung, der keine Rücksprungadresse sichert (`j`). Der Assembler benutzt es für `nop` (`addi zero, zero, 0`).

Siehe auch: `mv`, `j`, `beqz`

## ra – Rücksprungadresse
<!-- names: ra -->

`x1` (`ra`) hält die Adresse, zu der eine Funktion zurückkehrt. `jal ra, funktion` (oder `call`) legt die Adresse des nächsten Befehls dort ab; `ret` ist `jalr zero, 0(ra)`. Eine Funktion, die andere aufruft, muss `ra` zuerst auf den Stack sichern und vor dem `ret` wiederherstellen:

```asm
funktion:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call hilfe
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
```

Siehe auch: `jal`, `ret`, `sp`

## sp – Stackzeiger
<!-- names: sp -->

`x2` (`sp`) zeigt auf das Ende des Stacks, der nach unten wächst. Es gibt kein `push` oder `pop`: Platz schaffst du mit `addi sp, sp, -16`, gespeichert wird mit `sw reg, 12(sp)`, und am Ende gibst du den Platz zurück. Die ABI verlangt, dass `sp` ein Vielfaches von 16 ist, wenn du Code anderer aufrufst. Das Programm muss `sp` am Anfang selbst setzen; beim Pico 2 liegt das Ende des RAM bei `0x20082000`.

Siehe auch: `ra`, `sw`, `lw`

## gp, tp – Global Pointer und Thread Pointer
<!-- names: gp, tp -->

`x3` (`gp`) und `x4` (`tp`) haben nur für übersetzte Programme eine Bedeutung: Der Linker kann `gp` in den Datenbereich legen, damit Variablen mit kurzen Offsets erreichbar sind, und `tp` zeigt auf die Daten des laufenden Threads. In einem Assemblerprogramm sind sie zwei weitere Register.

## pseudo – die Kurznamen des Assemblers
<!-- names: pseudo, pseudo-instructions -->

Der Assembler kennt Namen für häufige Kombinationen; es sind keine Befehle des Prozessors, und der Disassembler zeigt sie wieder an.

| Geschrieben | Ist | Macht |
|---|---|---|
| `nop` | `addi zero, zero, 0` | nichts |
| `li rd, n` | `addi rd, zero, n` oder `lui` + `addi` | eine Zahl laden |
| `la rd, marke` | `auipc` + `addi` | eine Adresse laden (pc-relativ) |
| `mv rd, rs` | `addi rd, rs, 0` | kopieren |
| `not rd, rs` | `xori rd, rs, -1` | invertieren |
| `neg rd, rs` | `sub rd, zero, rs` | negieren |
| `seqz`, `snez` | `sltiu rd, rs, 1`, `sltu rd, zero, rs` | 1, wenn rs 0 ist / nicht 0 ist |
| `j marke` | `jal zero, marke` | springen |
| `jr rs` | `jalr zero, 0(rs)` | zu einem Register springen |
| `call marke` | `auipc ra` + `jalr ra` | eine Funktion aufrufen |
| `ret` | `jalr zero, 0(ra)` | zurückkehren |
| `beqz`, `bnez`, `blez`, `bgez`, `bltz`, `bgtz` | `beq`/`bne`/`bge`/`blt` gegen `zero` | mit 0 vergleichen und verzweigen |
| `bgt`, `ble`, `bgtu`, `bleu` | `blt`/`bge`/`bltu`/`bgeu` mit vertauschten Registern | die anderen Vergleiche |
| `csrr`, `csrw`, `csrs`, `csrc` | `csrrs`, `csrrw` ... mit `zero` | ein Steuerregister lesen, schreiben, Bits setzen, löschen |

Siehe auch: `li`, `la`, `mv`, `j`, `ret`, `call`

## encoding – die Befehlsformen
<!-- names: encoding, formats -->

Jeder Befehl hat 32 Bit (die kurzen Formen 16, siehe `compressed`). Sechs Formen legen die Register und Zahlen an dieselben Stellen, damit der Prozessor sie schnell entschlüsselt:

- **R** – drei Register: `add rd, rs1, rs2`
- **I** – zwei Register und eine 12-Bit-Zahl (-2048 bis 2047): `addi rd, rs1, imm`, `lw rd, imm(rs1)`, `jalr`
- **S** – Speichern, ein 12-Bit-Offset: `sw rs2, imm(rs1)`
- **B** – Verzweigungen, ein 13-Bit-Offset in Schritten von 2 (±4 KB): `beq rs1, rs2, ziel`
- **U** – eine 20-Bit-Zahl für die oberen Bits eines Registers: `lui rd, imm20`, `auipc`
- **J** – Sprung, ein 21-Bit-Offset in Schritten von 2 (±1 MB): `jal rd, ziel`

Deshalb braucht eine 32-Bit-Konstante zwei Befehle: `lui` lädt die oberen 20 Bit und `addi` die unteren 12 (`li` macht das für dich). Sprungziele schreibst du als Marken; den Abstand rechnet der Assembler. Eine Verzweigung zu einem Ziel, das weiter als 4 KB entfernt ist, ist ein Fehler: Drehe die Bedingung um (`bne` über einem `j`).

Siehe auch: `li`, `lui`, `beq`, `jal`

## compressed – die 16-Bit-Formen (C)
<!-- names: compressed, c.extension -->

Mit der Erweiterung C (und Zcb) führt der Kern auch Befehle mit 2 Bytes aus. Es sind die häufigsten Befehle mit weniger Auswahl: nur 8 der Register (`s0`, `s1`, `a0` bis `a5`), kleine Zahlen, das Zielregister oft gleich einer Quelle. Übersetzter Code (das Pico-SDK) benutzt sie reichlich, du triffst sie also im Disassembler bei fremdem Code, mit einem `c.` davor geschrieben: `c.addi sp, -16`, `c.lw a0, 4(a1)`, `c.jr ra`.

Der Assembler von Asmonite schreibt von jedem Befehl, den du tippst, die normale 4-Byte-Form; er kürzt nicht. Schreibe `c.`-Befehle nicht selbst, sie sind zum Lesen da. Die Bedeutung ist die des langen Befehls.

| Kurze Form | Ist |
|---|---|
| `c.li`, `c.lui`, `c.addi`, `c.addi16sp`, `c.addi4spn` | `addi` (oder `lui`) mit kleinen Zahlen oder auf `sp` |
| `c.mv`, `c.add`, `c.sub`, `c.and`, `c.or`, `c.xor` | Rechnen mit zwei Registern |
| `c.andi`, `c.slli`, `c.srli`, `c.srai` | `andi`, `slli`, `srli`, `srai` |
| `c.lw`, `c.sw`, `c.lwsp`, `c.swsp` | `lw`, `sw`, auch relativ zu `sp` |
| `c.lbu`, `c.lhu`, `c.lh`, `c.sb`, `c.sh` (Zcb) | Byte- und Halbwort-Laden und -Speichern |
| `c.zext.b`, `c.sext.b`, `c.zext.h`, `c.sext.h`, `c.not`, `c.mul` (Zcb) | Formen mit einem Register |
| `c.j`, `c.jal`, `c.jr`, `c.jalr`, `c.beqz`, `c.bnez` | Sprünge und Verzweigungen |
| `c.nop`, `c.ebreak`, `c.unimp` | `nop`, `ebreak`, ein ungültiger Befehl (alle Bits 0) |

Siehe auch: `encoding`, `addi`, `lw`, `jal`

## c.addi, c.li, c.lui, c.addi16sp, c.addi4spn – komprimiertes Addieren und Zahl laden
<!-- names: c.addi, c.li, c.lui, c.addi16sp, c.addi4spn, c.nop -->

- `c.addi rd, n` addiert eine Zahl (-32 bis 31) zu `rd`; mit `rd` = `zero` und 0 ist es `c.nop`
- `c.li rd, n` lädt eine Zahl von -32 bis 31
- `c.lui rd, n` lädt `n` in die oberen 20 Bit
- `c.addi16sp sp, n` addiert ein Vielfaches von 16 zu `sp` (Stackplatz schaffen und freigeben)
- `c.addi4spn rd, sp, n` legt `sp` + ein Vielfaches von 4 in eines der 8 kurzen Register (die Adresse einer lokalen Variablen)

Siehe auch: `compressed`, `addi`, `li`, `lui`

## c.mv, c.add, c.sub, c.and, c.or, c.xor, c.andi, c.slli, c.srli, c.srai, c.mul, c.not, c.zext.b, c.sext.b, c.zext.h, c.sext.h – komprimiertes Rechnen
<!-- names: c.mv, c.add, c.sub, c.and, c.or, c.xor, c.andi, c.slli, c.srli, c.srai, c.mul, c.not, c.zext.b, c.sext.b, c.zext.h, c.sext.h -->

Die 16-Bit-Formen von `mv`, `add`, `sub`, `and`, `or`, `xor`, `andi`, `slli`, `srli`, `srai`; `c.mul`, `c.not` (invertieren), `c.zext.b`/`c.zext.h` (obere Bits löschen) und `c.sext.b`/`c.sext.h` (das Vorzeichen kopieren) gehören zu Zcb. Bei den meisten ist das erste Register zugleich Quelle und Ergebnis: `c.sub a0, a1` ist `sub a0, a0, a1`.

Siehe auch: `compressed`, `add`, `and`, `slli`, `mul`

## c.lw, c.sw, c.lwsp, c.swsp, c.lbu, c.lhu, c.lh, c.sb, c.sh – komprimiertes Laden und Speichern
<!-- names: c.lw, c.sw, c.lwsp, c.swsp, c.lbu, c.lhu, c.lh, c.sb, c.sh -->

Die 16-Bit-Formen von `lw`, `sw`, `lb`/`lbu`, `lh`/`lhu`, `sb`, `sh`. `c.lwsp` und `c.swsp` adressieren relativ zu `sp` und sind das, womit ein Compiler Register sichert und zurückholt (`c.swsp ra, 12(sp)`). Der Offset ist klein und ein Vielfaches der Größe.

Siehe auch: `compressed`, `lw`, `sw`, `sp`

## c.j, c.jal, c.jr, c.jalr, c.beqz, c.bnez, c.ebreak, c.unimp – komprimierte Sprünge
<!-- names: c.j, c.jal, c.jr, c.jalr, c.beqz, c.bnez, c.ebreak, c.unimp -->

`c.j` und `c.jal` springen (±2 KB), `c.jr ra` ist `ret`, `c.jalr` ruft die Adresse in einem Register auf, `c.beqz`/`c.bnez` verzweigen (±256 Bytes), wenn ein Register 0 ist oder nicht. `c.ebreak` ist `ebreak`. `c.unimp` ist der Code 0x0000, der kein Befehl ist: Ein Kern, der in leeren Speicher läuft, endet hier.

Siehe auch: `compressed`, `jal`, `jalr`, `ret`, `beqz`

## lui – die oberen 20 Bit laden
<!-- names: lui -->

`lui rd, n` legt `n` (0 bis 0xFFFFF), um 12 nach links verschoben, in `rd`; die unteren 12 Bit werden 0. Mit `addi` baut es jede 32-Bit-Zahl: `lui t0, 0x40028` und `addi t0, t0, 0xcc` ergeben 0x400280cc. `li` macht das für dich.

```asm
lui t0, 0xd0000       ; t0 = 0xd0000000
```

Siehe auch: `li`, `addi`, `auipc`

## auipc – die oberen 20 Bit zum pc addieren
<!-- names: auipc -->

`auipc rd, n` legt die Adresse dieses Befehls + `n`, um 12 nach links verschoben, in `rd`. Mit `addi` oder einem Ladebefehl erreicht es jede Adresse relativ zum pc, egal wohin das Programm geladen wird (`la` und `call` benutzen es).

Siehe auch: `la`, `call`, `lui`

## li – eine Zahl laden
<!-- names: li -->

**Syntax:** `li rd, zahl`

Lädt eine beliebige 32-Bit-Zahl. Ein Pseudobefehl: ein `addi` für Zahlen von -2048 bis 2047, nur `lui`, wenn die unteren 12 Bit 0 sind, sonst `lui` + `addi`. Ist die Zahl eine Marke oder erst später bekannt, sind es immer zwei Befehle.

```asm
li   t0, 1000000      ; lui t0, 0xf4 ; addi t0, t0, 0x240
li   a0, -1
li   sp, 0x20082000
```

Siehe auch: `lui`, `addi`, `la`, `mv`

## la – eine Adresse laden
<!-- names: la -->

**Syntax:** `la rd, marke`

Lädt die Adresse einer Marke mit `auipc` + `addi`, relativ zum pc. Benutze es für Daten und Funktionen. Anders als `li rd, marke` funktioniert es auch, wenn das Programm an einer anderen Adresse liegt als beim Assemblieren.

Siehe auch: `li`, `auipc`, `call`

## mv, not, neg, seqz, snez, sltz, sgtz, nop – Kurznamen für häufige Kopier- und Rechenschritte
<!-- names: mv, not, neg, seqz, snez, sltz, sgtz, nop -->

- `mv rd, rs` kopiert ein Register (`addi rd, rs, 0`)
- `not rd, rs` invertiert alle Bits (`xori rd, rs, -1`)
- `neg rd, rs` negiert (`sub rd, zero, rs`)
- `seqz rd, rs` setzt `rd` auf 1, wenn `rs` 0 ist, sonst 0
- `snez rd, rs` setzt `rd` auf 1, wenn `rs` nicht 0 ist
- `sltz rd, rs` setzt `rd` auf 1, wenn `rs` negativ ist, `sgtz`, wenn es größer als 0 ist
- `nop` tut nichts

Siehe auch: `pseudo`, `addi`, `slt`

## add, sub – Addition und Subtraktion
<!-- names: add, sub -->

**Syntax:** `add rd, rs1, rs2` &nbsp; `sub rd, rs1, rs2`

`rd = rs1 + rs2` oder `rs1 - rs2`. Die oberen Bits des Ergebnisses gehen verloren; es gibt kein Carry. Die Summe zweier Zahlen mit Übertrag baust du mit `sltu`: `sltu t0, a0, a1` nach `add a0, a0, a1` sagt, ob es übergelaufen ist.

```asm
add a0, a1, a2     ; a0 = a1 + a2
sub t0, t0, t1
```

Siehe auch: `addi`, `sltu`, `neg`

## addi – eine Zahl addieren
<!-- names: addi -->

**Syntax:** `addi rd, rs1, n` (n von -2048 bis 2047)

`rd = rs1 + n`. Ein `subi` gibt es nicht: Nimm eine negative Zahl. `addi` mit `zero` lädt eine kleine Zahl, mit 0 kopiert es ein Register, und mit `sp` verschiebt es den Stack.

```asm
addi t2, t2, -1      ; herunterzählen
addi sp, sp, -16     ; Platz auf dem Stack schaffen
```

Siehe auch: `add`, `li`, `mv`

## and, or, xor, andi, ori, xori – Bitoperationen
<!-- names: and, or, xor, andi, ori, xori -->

**Syntax:** `and rd, rs1, rs2` &nbsp; `andi rd, rs1, n`

Bit für Bit. Die Formen mit Zahl nehmen eine Zahl von -2048 bis 2047 (vorzeichenerweitert: `andi a0, a0, -1` behält alles, `xori a0, a0, -1` ist `not`).

```asm
andi t0, t0, 0xff    ; das untere Byte behalten
ori  a0, a0, 1       ; Bit 0 setzen
```

Siehe auch: `sll`, `not`, `bset`, `andn`

## sll, srl, sra, slli, srli, srai – Schieben
<!-- names: sll, srl, sra, slli, srli, srai -->

**Syntax:** `sll rd, rs1, rs2` &nbsp; `slli rd, rs1, n` (n von 0 bis 31)

- `sll`/`slli` schieben nach links, neue Bits sind 0 (mit einer Zweierpotenz multiplizieren)
- `srl`/`srli` schieben nach rechts, neue Bits sind 0 (vorzeichenlos dividieren)
- `sra`/`srai` schieben nach rechts und behalten das Vorzeichen (vorzeichenbehaftet durch eine Zweierpotenz teilen, abgerundet)

Bei einem Register zählen nur die unteren 5 Bit (0 bis 31).

```asm
slli t0, t0, 2      ; t0 = t0 * 4
srai a0, a0, 1      ; a0 = a0 / 2, vorzeichenbehaftet
```

Siehe auch: `rol`, `ror`, `and`

## slt, sltu, slti, sltiu – vergleichen und setzen
<!-- names: slt, sltu, slti, sltiu -->

**Syntax:** `slt rd, rs1, rs2` &nbsp; `sltiu rd, rs1, n`

`rd` wird 1, wenn `rs1` kleiner als `rs2` (oder die Zahl) ist, sonst 0. `slt` und `slti` vergleichen vorzeichenbehaftet, `sltu` und `sltiu` vorzeichenlos. Das ist, was RISC-V statt der Flags hat: Du bekommst das Ergebnis eines Vergleichs in einem Register.

```asm
slt   t0, a0, a1     ; t0 = 1, wenn a0 < a1 (vorzeichenbehaftet)
sltiu t0, a0, 1      ; t0 = 1, wenn a0 == 0 (das ist seqz)
```

Siehe auch: `seqz`, `blt`, `bltu`

## mul, mulh, mulhsu, mulhu, div, divu, rem, remu – Multiplizieren und Dividieren (M)
<!-- names: mul, mulh, mulhsu, mulhu, div, divu, rem, remu -->

**Syntax:** `mul rd, rs1, rs2`

- `mul` die unteren 32 Bit des Produkts
- `mulh`, `mulhu`, `mulhsu` die oberen 32 Bit (mit Vorzeichen × mit Vorzeichen, ohne × ohne, mit × ohne) – zusammen mit `mul` das 64-Bit-Produkt
- `div`, `divu` Quotient (mit, ohne Vorzeichen); `rem`, `remu` Rest

Die Division durch 0 löst keine Ausnahme aus: Der Quotient ist lauter Einsen (-1), der Rest ist der Dividend. `div` der kleinsten negativen Zahl durch -1 ergibt diese Zahl, Rest 0.

```asm
mul  a0, a0, a1
divu t0, a0, t1
remu t1, a0, t1
```

Siehe auch: `slli`, `sll`

## lw, lh, lhu, lb, lbu – aus dem Speicher laden
<!-- names: lw, lh, lhu, lb, lbu -->

**Syntax:** `lw rd, offset(rs1)` (Offset von -2048 bis 2047)

Lädt von der Adresse `rs1 + offset`: `lw` ein Wort (4 Bytes), `lh`/`lhu` ein Halbwort (2), `lb`/`lbu` ein Byte. Die Formen ohne `u` kopieren das Vorzeichen in die oberen Bits, die mit `u` füllen mit 0. Die Adresse eines Wortes muss ein Vielfaches von 4 sein, die eines Halbworts ein Vielfaches von 2; sonst löst der Kern eine Ausnahme aus.

```asm
lw  t2, 8(t0)        ; t2 = das Wort bei t0 + 8
lbu a0, 0(a1)        ; ein Byte, vorzeichenlos
```

Um von einer Marke zu laden, lege ihre Adresse zuerst in ein Register (`la`).

Siehe auch: `sw`, `la`, `lui`

## sw, sh, sb – in den Speicher schreiben
<!-- names: sw, sh, sb -->

**Syntax:** `sw rs2, offset(rs1)`

Schreibt das Register `rs2` (zuerst der Wert, dann die Adresse `rs1 + offset`): `sw` 4 Bytes, `sh` die unteren 2 Bytes, `sb` das untere Byte. Die Peripherieregister des Pico 2 beschreibst du mit `sw`.

```asm
sw t1, 0(t0)         ; t1 an die Adresse in t0 schreiben
sw ra, 12(sp)        ; die Rücksprungadresse sichern
```

Siehe auch: `lw`, `sp`

## beq, bne, blt, bge, bltu, bgeu – bedingte Verzweigungen
<!-- names: beq, bne, blt, bge, bltu, bgeu -->

**Syntax:** `beq rs1, rs2, marke`

Vergleichen zwei Register und springen zur Marke, wenn die Bedingung gilt, sonst geht es weiter: gleich, ungleich, kleiner (mit Vorzeichen), größer oder gleich (mit Vorzeichen), kleiner und größer oder gleich als vorzeichenlose Zahlen. Das Ziel darf bis zu 4 KB davor oder dahinter liegen. Für die anderen Vergleiche vertauschst du die Register: `bgt a, b, l` ist `blt b, a, l`.

```asm
warten:
    lw   t2, 8(t0)
    bne  t2, t1, warten  ; bis beide Bits gesetzt sind
```

Siehe auch: `beqz`, `bnez`, `j`, `slt`

## beqz, bnez, blez, bgez, bltz, bgtz, bgt, ble, bgtu, bleu – Verzweigungen gegen 0 und die anderen Vergleiche
<!-- names: beqz, bnez, blez, bgez, bltz, bgtz, bgt, ble, bgtu, bleu -->

Kurznamen des Assemblers: `beqz rs, marke` ist `beq rs, zero, marke`, `bnez` ist `bne`, `bltz` `blt`, `bgez` `bge`, `blez` `bge zero, rs`, `bgtz` `blt zero, rs`. `bgt`, `ble`, `bgtu`, `bleu` vertauschen die beiden Register von `blt`, `bge`, `bltu`, `bgeu`.

```asm
pause:
    addi t2, t2, -1
    bnez t2, pause
```

Siehe auch: `beq`, `pseudo`

## jal, j – springen und verknüpfen
<!-- names: jal, j -->

**Syntax:** `jal rd, marke` &nbsp; `jal marke` &nbsp; `j marke`

Springt zur Marke (±1 MB) und legt die Adresse des nächsten Befehls in `rd`. `jal marke` benutzt `ra`: Das ist ein Aufruf. `j marke` (`jal zero, marke`) springt, ohne etwas zu sichern.

```asm
    jal  ra, funktion    ; aufrufen
    j    schleife        ; springen
```

Siehe auch: `jalr`, `call`, `ret`

## jalr, jr, ret, call, tail – zu einem Register springen, aufrufen, zurückkehren
<!-- names: jalr, jr, ret, call, tail -->

**Syntax:** `jalr rd, offset(rs1)` &nbsp; `jr rs` &nbsp; `ret` &nbsp; `call marke` &nbsp; `tail marke`

`jalr` springt zu `rs1 + offset` und legt die Rücksprungadresse in `rd`. `jr rs` springt zu einem Register; `ret` ist `jr ra`. `call marke` erreicht jede Adresse (`auipc` + `jalr`); `tail marke` ist dasselbe wie ein Sprung (`ra` bleibt erhalten) und dient für den letzten Aufruf einer Funktion.

```asm
    la   t0, behandler
    jalr t0              ; die Adresse in t0 aufrufen
    ret
```

Siehe auch: `jal`, `ra`, `la`

## ecall, ebreak, mret, sret, wfi – Systembefehle
<!-- names: ecall, ebreak, mret, sret, wfi -->

- `ebreak` hält den Kern im Debugger an (wenn der Debugger verbunden ist), sonst löst er eine Ausnahme aus. Setze ihn dorthin, wo du einen Halt ohne Breakpoint willst.
- `ecall` ruft die Umgebung: eine Ausnahme für die Systemsoftware; ein kleines Programm benutzt ihn nicht.
- `mret` kehrt aus einem Ausnahmebehandler zurück (siehe `csr`): Der pc wird `mepc`. `sret` tut dasselbe für den Supervisor-Modus, den der Hazard3 nicht hat.
- `wfi` wartet auf eine Unterbrechung; der Kern schläft, bis eine kommt.

Siehe auch: `csr`, `fence`

## fence, fence.i – Speicherreihenfolge
<!-- names: fence, fence.i -->

`fence` stellt sicher, dass die Speicherzugriffe davor erledigt sind (für andere Kerne und Geräte sichtbar), bevor die danach beginnen. `fence.i` lässt den Kern die Befehle neu lesen, nachdem Code in den Speicher geschrieben wurde. Einfache Programme für einen Kern brauchen beides nicht.

## csr – Steuer- und Statusregister
<!-- names: csr, mstatus, misa, mie, mtvec, mscratch, mepc, mcause, mtval, mip, mcycle, minstret, mhartid, mvendorid, marchid, mimpid, cycle, time, instret, dcsr, dpc, tselect, tdata1, tdata2 -->

Neben den 32 Registern hat ein Kern Steuer- und Statusregister (CSR), die du mit `csrr`, `csrw` und den Befehlen unten erreichst. Die gängigen:

- `mstatus` – globaler Zustand; Bit 3 (`MIE`) schaltet Unterbrechungen ein oder aus
- `mie`, `mip` – welche Unterbrechungen erlaubt sind / anstehen
- `mtvec` – wohin der pc bei einer Ausnahme oder Unterbrechung geht
- `mepc` – der pc, als es passierte (`mret` geht dorthin zurück); `mcause` – warum; `mtval` – die falsche Adresse oder der falsche Befehl
- `mscratch` – ein freies Register für den Behandler
- `mhartid` – die Nummer des Kerns (0 oder 1 beim Pico 2)
- `mcycle`, `minstret` – Zähler der Takte und der fertigen Befehle
- `dcsr`, `dpc`, `tselect`, `tdata1`, `tdata2` – die Register des Debuggers (Breakpoints sind Trigger)

```asm
csrr  a0, mhartid       ; welcher Kern bin ich?
csrw  mtvec, t0         ; wohin die Ausnahmen gehen
csrsi mstatus, 8        ; Unterbrechungen erlauben
```

Siehe auch: `csrrw`, `mret`

## csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci, csrr, csrw, csrs, csrc, csrwi, csrsi, csrci – ein Steuerregister ansprechen
<!-- names: csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci, csrr, csrw, csrs, csrc, csrwi, csrsi, csrci -->

**Syntax:** `csrrw rd, csr, rs1` &nbsp; `csrr rd, csr` &nbsp; `csrw csr, rs1`

Ein Befehl liest den alten Wert des Registers nach `rd` und schreibt einen neuen:

- `csrrw` schreibt `rs1`
- `csrrs` setzt die Bits, die in `rs1` 1 sind (mit `rs1` = `zero` wird nur gelesen)
- `csrrc` löscht die Bits, die in `rs1` 1 sind
- die Formen mit `i` nehmen eine Zahl von 0 bis 31 statt `rs1`

`csrr rd, csr` liest, `csrw csr, rs` schreibt, `csrs`/`csrc` setzen/löschen Bits, `csrwi`/`csrsi`/`csrci` dasselbe mit einer Zahl (sie benutzen `zero` als `rd`). Das Register gibst du mit Namen (`mstatus`) oder Nummer (`0x300`) an.

Siehe auch: `csr`, `mret`

## lr.w, sc.w – laden mit Reservierung, bedingt speichern (A)
<!-- names: lr.w, sc.w -->

**Syntax:** `lr.w rd, (rs1)` &nbsp; `sc.w rd, rs2, (rs1)`

`lr.w` liest das Wort an der Adresse und markiert es. `sc.w` schreibt dort `rs2` nur, wenn niemand das Wort seither geändert hat; `rd` ist 0, wenn es geklappt hat, sonst nicht 0 (noch einmal versuchen). Zusammen ergeben sie ein atomares Aktualisieren (eine Sperre, ein Zähler). Mit `.aq` und `.rl` legst du die Speicherreihenfolge fest (`lr.w.aq`).

```asm
nochmal:
    lr.w t0, (a0)
    addi t0, t0, 1
    sc.w t1, t0, (a0)
    bnez t1, nochmal
```

Siehe auch: `amoadd.w`, `fence`

## amoswap.w, amoadd.w, amoxor.w, amoand.w, amoor.w, amomin.w, amomax.w, amominu.w, amomaxu.w – atomare Speicheroperationen (A)
<!-- names: amoswap.w, amoadd.w, amoxor.w, amoand.w, amoor.w, amomin.w, amomax.w, amominu.w, amomaxu.w -->

**Syntax:** `amoadd.w rd, rs2, (rs1)`

Liest das Wort an der Adresse `rs1` nach `rd` und schreibt das Ergebnis der Operation (tauschen, addieren, xor, und, oder, Minimum, Maximum; `u`: vorzeichenlos) mit `rs2` zurück, in einem Schritt, den kein anderer Kern unterbrechen kann. `.aq` und `.rl` ordnen die Speicherzugriffe.

```asm
li        t0, 1
amoadd.w  zero, t0, (a0)    ; 1 zum Wort bei a0 addieren
```

Siehe auch: `lr.w`, `fence`

## sh1add, sh2add, sh3add – addieren mit Verschiebung (Zba)
<!-- names: sh1add, sh2add, sh3add -->

**Syntax:** `sh2add rd, rs1, rs2`

`rd = (rs1 << n) + rs2` mit n = 1, 2 oder 3: die Adresse eines Elements eines Feldes aus Halbworten, Worten oder Doppelworten in einem Befehl (`sh2add t0, index, basis`).

Siehe auch: `slli`, `add`

## andn, orn, xnor – Bitoperationen mit einem invertierten Operanden (Zbb)
<!-- names: andn, orn, xnor -->

**Syntax:** `andn rd, rs1, rs2`

`andn` ist `rs1 & ~rs2` (löscht Bits), `orn` ist `rs1 | ~rs2`, `xnor` ist `~(rs1 ^ rs2)`.

Siehe auch: `and`, `bclr`

## clz, ctz, cpop – Bits zählen (Zbb)
<!-- names: clz, ctz, cpop -->

**Syntax:** `clz rd, rs`

`clz` zählt die Nullbits von oben (32 bei 0), `ctz` von unten, `cpop` zählt die Bits, die 1 sind. `ctz` findet das niedrigste gesetzte Bit, `31 - clz` das höchste.

Siehe auch: `rev8`, `bext`

## min, minu, max, maxu – kleiner und größer (Zbb)
<!-- names: min, minu, max, maxu -->

**Syntax:** `max rd, rs1, rs2`

Das kleinere oder größere von zwei Registern, mit Vorzeichen (`min`, `max`) oder ohne (`minu`, `maxu`) – ohne Verzweigung.

Siehe auch: `slt`

## sext.b, sext.h, zext.h – ein Byte oder Halbwort erweitern (Zbb)
<!-- names: sext.b, sext.h, zext.h -->

**Syntax:** `sext.b rd, rs`

`sext.b`/`sext.h` kopieren Bit 7 / 15 in die oberen Bits (ein Byte oder Halbwort mit Vorzeichen wird ein Wort mit Vorzeichen); `zext.h` löscht die oberen 16 Bit. Für ein Byte ohne Vorzeichen nimm `andi rd, rs, 0xff`.

Siehe auch: `andi`, `lb`

## rol, ror, rori – rotieren (Zbb)
<!-- names: rol, ror, rori -->

**Syntax:** `ror rd, rs1, rs2` &nbsp; `rori rd, rs1, n`

Schieben, aber die Bits, die auf der einen Seite herausfallen, kommen auf der anderen wieder hinein (nach links oder rechts rotieren).

Siehe auch: `slli`, `srli`

## rev8, orc.b, brev8, zip, unzip – Bits und Bytes umordnen (Zbb, Zbkb)
<!-- names: rev8, orc.b, brev8, zip, unzip -->

**Syntax:** `rev8 rd, rs`

- `rev8` kehrt die Reihenfolge der 4 Bytes um (Little Endian zu Big Endian)
- `orc.b` setzt jedes Byte auf 0xFF, wenn es nicht 0 war, sonst auf 0 (eine schnelle Suche nach einem Nullbyte)
- `brev8` kehrt die Bits innerhalb jedes Bytes um
- `zip` und `unzip` mischen / trennen die Bits der beiden Hälften

Siehe auch: `ror`

## bset, bclr, binv, bext, bseti, bclri, binvi, bexti – einzelne Bits (Zbs)
<!-- names: bset, bclr, binv, bext, bseti, bclri, binvi, bexti -->

**Syntax:** `bseti rd, rs1, n` &nbsp; `bset rd, rs1, rs2`

Setzen (`bset`), löschen (`bclr`), invertieren (`binv`) oder lesen (`bext`: das Bit als 0 oder 1) das Bit Nummer `n` (0 bis 31) eines Registers. Ohne sie: `ori`/`andi` mit einer Maske.

```asm
bseti t1, zero, 25      ; t1 = 1 << 25 (der Pin der LED)
```

Siehe auch: `ori`, `andi`, `slli`

## pack, packh – Hälften zusammensetzen (Zbkb)
<!-- names: pack, packh -->

**Syntax:** `pack rd, rs1, rs2`

`pack` fügt die untere Hälfte von `rs1` (unten) und von `rs2` (oben) zu einem Wort zusammen; `packh` fügt die unteren Bytes zu einem Halbwort zusammen.

Siehe auch: `zext.h`

## clmul, clmulh, clmulr – Multiplikation ohne Übertrag (Zbc)
<!-- names: clmul, clmulh, clmulr -->

**Syntax:** `clmul rd, rs1, rs2`

Eine Multiplikation, bei der die Teilprodukte mit xor verknüpft und nicht addiert werden: für Prüfsummen (CRC) und fehlerkorrigierende Codes. `clmul` liefert die untere Hälfte, `clmulh` die obere, `clmulr` die umgekehrte Form.

Siehe auch: `xor`, `mul`

## riscv64, rv64 – der 64-Bit-RISC-V
<!-- names: riscv64, rv64, xlen -->

Mit `.arch riscv64` sind die Register `x0` bis `x31` 64 Bit breit (der T-Head C906 des Milk-V Duo und des MangoPi MQ-Pro, QEMU `virt`). Die Befehle von RV32 bleiben und arbeiten auf allen 64 Bit (`add`, `slli` bis 63, `lw` erweitert das Vorzeichen des Wortes auf 64 Bit); neu sind das Laden und Speichern von 64 Bit (`ld`, `sd`, `lwu`), die W-Befehle, die mit den unteren 32 Bit rechnen und das Vorzeichen des Ergebnisses auf 64 Bit erweitern (`addw`, `addiw`, `sllw` …), die atomaren `.d`-Formen und einige Formen der Bit-Manipulation. Auch die 16-Bit-Formen ändern sich: `c.jal` fällt weg, an seine Stelle treten `c.addiw`, `c.ld`, `c.sd`.

`li` nimmt jede 64-Bit-Zahl (bis zu 8 Befehle). `lui` erweitert das Vorzeichen seiner 32 Bit auf 64: `lui a0, 0x80000` ist `0xFFFFFFFF80000000`; `li` berücksichtigt das, und `li` mit einer Marke gibt 4 Befehle, die die oberen 32 Bit auf 0 lassen, damit Adressen ab `0x80000000` (das RAM von QEMU `virt` und der Boards) positiv bleiben.

Siehe auch: `ld`, `addw`, `li`

## ld, lwu, sd – 64 Bit laden und speichern (RV64)
<!-- names: ld, lwu, sd -->

**Syntax:** `ld rd, offset(rs1)`, `sd rs2, offset(rs1)` (Offset von -2048 bis 2047)

`ld` lädt ein Doppelwort (8 Bytes), `sd` speichert eins. `lwu` lädt ein Wort und füllt die oberen 32 Bit mit 0 (`lw` kopiert das Vorzeichen hinein). Der Stack von RV64-Code hat 8 Bytes pro Register (`sd ra, 8(sp)`).

```asm
addi sp, sp, -16
sd   ra, 8(sp)       ; die Rücksprungadresse sichern (64 Bit)
ld   ra, 8(sp)
addi sp, sp, 16
```

Siehe auch: `lw`, `sw`, `sp`

## addw, subw, addiw, sllw, srlw, sraw, slliw, srliw, sraiw, sext.w, negw – Rechnen mit 32 Bit (RV64)
<!-- names: addw, subw, addiw, sllw, srlw, sraw, slliw, srliw, sraiw, sext.w, negw -->

**Syntax:** `addw rd, rs1, rs2`, `addiw rd, rs1, imm`, `slliw rd, rs1, shamt` (0 bis 31)

Rechnen mit den unteren 32 Bit wie bei RV32 und erweitern das Vorzeichen des 32-Bit-Ergebnisses in die obere Hälfte: das Rechnen mit `int` in C. `sext.w rd, rs` ist `addiw rd, rs, 0` (das Vorzeichen eines Wortes erweitern), `negw rd, rs` ist `subw rd, zero, rs`.

```asm
addw  a0, a0, a1     ; eine 32-Bit-Summe, als 64-Bit-Zahl
sext.w a2, a3        ; das untere Wort von a3 mit seinem Vorzeichen
```

Siehe auch: `add`, `slli`, `riscv64`

## mulw, divw, divuw, remw, remuw – Multiplizieren und Dividieren mit 32 Bit (RV64)
<!-- names: mulw, divw, divuw, remw, remuw -->

**Syntax:** `mulw rd, rs1, rs2`

Wie `mul`, `div`, `divu`, `rem`, `remu` mit den unteren 32 Bit; das Vorzeichen des 32-Bit-Ergebnisses wird auf 64 Bit erweitert.

Siehe auch: `mul`, `addw`

## lr.d, sc.d, amoswap.d, amoadd.d, amoxor.d, amoand.d, amoor.d, amomin.d, amomax.d, amominu.d, amomaxu.d – atomare Doppelwörter (RV64)
<!-- names: lr.d, sc.d, amoswap.d, amoadd.d, amoxor.d, amoand.d, amoor.d, amomin.d, amomax.d, amominu.d, amomaxu.d -->

**Syntax:** `amoadd.d rd, rs2, (rs1)`, `lr.d rd, (rs1)`, `sc.d rd, rs2, (rs1)`

Die atomaren Befehle von `lr.w`, `sc.w` und `amoadd.w` auf 8 Bytes; die Adresse ist ein Vielfaches von 8.

Siehe auch: `lr.w`, `amoadd.w`

## add.uw, sh1add.uw, sh2add.uw, sh3add.uw, slli.uw, zext.w – Adressen aus 32-Bit-Indizes (Zba, RV64)
<!-- names: add.uw, sh1add.uw, sh2add.uw, sh3add.uw, slli.uw, zext.w -->

**Syntax:** `sh2add.uw rd, rs1, rs2`, `slli.uw rd, rs1, shamt`

Nehmen die unteren 32 Bit von `rs1` ohne Vorzeichen (als `unsigned int`), verschieben sie und addieren `rs2`: die Adresse eines Feldelements aus einem 32-Bit-Index. `zext.w rd, rs` ist `add.uw rd, rs, zero`: das untere Wort mit den oberen 32 Bit auf 0.

Siehe auch: `sh1add`, `lwu`

## clzw, ctzw, cpopw, rolw, rorw, roriw, packw – die W-Formen von Zbb und Zbkb (RV64)
<!-- names: clzw, ctzw, cpopw, rolw, rorw, roriw, packw -->

**Syntax:** `clzw rd, rs`, `rolw rd, rs1, rs2`, `roriw rd, rs1, shamt` (0 bis 31)

`clz`, `ctz`, `cpop`, `rol`, `ror`, `rori` und `pack` auf den unteren 32 Bit; das Vorzeichen des 32-Bit-Ergebnisses wird erweitert. Auf RV64 zählen und rotieren `clz` und die anderen ohne `w` alle 64 Bit.

Siehe auch: `clz`, `rol`, `pack`

## c.ld, c.sd, c.ldsp, c.sdsp, c.addiw, c.addw, c.subw, c.zext.w – die 16-Bit-Formen von RV64
<!-- names: c.ld, c.sd, c.ldsp, c.sdsp, c.addiw, c.addw, c.subw, c.zext.w -->

Die kurzen Formen von `ld`, `sd` (Register `s0`, `s1`, `a0` bis `a5`, Offsets 0 bis 248 in Schritten von 8), `ld`/`sd` relativ zu `sp` (0 bis 504), `addiw` (-32 bis 31), `addw`, `subw` und `zext.w`. Sie stehen an den Stellen von `c.jal` und der Gleitkomma-Lade- und Speicherbefehle von RV32. `c.slli`, `c.srli`, `c.srai` verschieben auf RV64 bis 63.

Siehe auch: `compressed`, `ld`, `addw`
