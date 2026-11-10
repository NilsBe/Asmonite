# Xtensa-Befehle (ESP32 LX6, ESP32-S3 LX7)

Die Befehlsinfo von Asmonite (F1) für Xtensa (`.arch xtensa`): die Kerne des ESP32 (LX6) und des ESP32-S3 (LX7). Die
Abschnitte hier erklären die Ideen des Prozessors und seine wichtigen Befehle; jeder andere Befehl hat einen kurzen
Abschnitt aus der Befehlsreferenz (help/de/xtensa_ref.md).

Neu bei Xtensa? Lies zuerst `xtensa` (der Prozessor in Kürze), `registers`, `window` und `l32r`.

## xtensa, lx6, lx7 – der Prozessor in Kürze

Xtensa ist ein 32-Bit-RISC-Prozessor von Cadence, den jeder Chiphersteller für seine Zwecke zusammenstellt; der ESP32
hat einen LX6, der ESP32-S3 einen LX7 (mit `salt` und `saltu`, die dem LX6 fehlen). Das Besondere:

- **Befehle mit 24 Bit**, und Kurzformen mit 16 Bit und `.n` (`add.n`, `l32i.n`, `mov.n`, `ret.n` …): die Option
  Code Density. Der Assembler wählt keine Kurzform von selbst: Schreib `.n`, wo du sie willst.
- **Registerfenster:** 16 Register `a0` bis `a15` sind ein Fenster auf 64 echte; ein Aufruf dreht das Fenster, so
  bekommt eine Funktion frische Register, ohne welche zu sichern (siehe `window`).
- **Literale:** Eine Konstante mit mehr als 12 Bit kommt mit `l32r` aus einem Wort vor dem Code (siehe `l32r`).
- **Schleifen ohne Aufwand** mit `loop` (siehe `loop`).
- **Schieben um ein Register** geht über das Spezialregister `SAR` (siehe `sar`).
- Der Speicher ist Little-Endian; ein Wort muss an einer durch 4 teilbaren Adresse stehen.

```asm
.target esp32
.arch xtensa
.imagebase 0x40080000
lit_value: dd 100000           ; ein Literal: vor dem Code
_start:
  l32r  a2, lit_value          ; a2 = 100000
  movi  a3, 5                  ; kleine Zahlen direkt (-2048 .. 2047)
  add   a2, a2, a3
  ret
```

Verwandt: `registers`, `window`, `l32r`, `call0`

## registers, a0, a1, sp – die Adressregister

`a0` bis `a15`, je 32 Bit, sind die Register des aktuellen Fensters. Nach der Konvention:

| Register | Zweck |
|---|---|
| `a0` | die Rücksprungadresse (geschrieben von `call0`, `call8` …) |
| `a1` (`sp`) | der Stackzeiger, durch 16 teilbar |
| `a2` bis `a7` | die Argumente und das Ergebnis (`a2`) einer Funktion |
| `a8` bis `a15` | frei; mit `call8` gehen die Argumente der aufgerufenen Funktion in `a10` .. `a15` |

Spezialregister (`SAR`, `PS`, `CCOUNT`, `LBEG` …) liest `rsr`, `wsr` schreibt sie (siehe `rsr`). Es gibt kein
Register, das immer 0 ist, und kein Flag-Register: Der Vergleich ist Teil des Sprungs (`beq`, `blt` …).

Verwandt: `window`, `rsr`, `sar`

## window, call4, call8, call12, callx4, callx8, callx12, entry, retw, retw.n – Aufrufe mit Registerfenster

Die 16 Register `a0` .. `a15` sind ein Fenster auf 64 echte Register (`WINDOWBASE` sagt, wo es beginnt). `call8
func` legt die Rücksprungadresse in `a8` ab und merkt sich den Schritt (8) in `PS.CALLINC`; `entry a1, 32` am Anfang
von `func` dreht das Fenster um 8 Register und legt den Stackrahmen an: Das `a8` des Aufrufers ist jetzt das `a0` von
`func`, seine `a10` .. `a15` sind die `a2` .. `a7` von `func` (die Argumente), und das neue `a1` ist das alte weniger
32. `retw` dreht das Fenster zurück und kehrt zurück: Der Aufrufer hat seine Register `a0` .. `a7` wie vorher, das
Ergebnis steht in seinem `a10` (dem `a2` von `func`).

```asm
_start:
  movi  a10, 3            ; das Argument
  call8 seven             ; a8 = Rücksprungadresse
  ; hier a10 = 10
  align 4
seven:
  entry a1, 32            ; das Fenster dreht sich: a2 = 3 (das a10 des Aufrufers)
  addi  a2, a2, 7         ; das Ergebnis in a2
  retw                    ; zurück: der Aufrufer sieht es in a10
```

- Eine Funktion, die mit `call4`/`call8`/`call12` aufgerufen wird, beginnt mit `entry` und endet mit `retw` (oder
  `retw.n`); das Ziel eines Aufrufs muss durch 4 teilbar sein (`align 4`).
- Sind die 64 Register aufgebraucht (Aufrufe tiefer als etwa 7 Ebenen mit `call8`), legt der Prozessor das älteste
  Fenster auf den Stack und holt es später zurück: Das tun die Handler für Überlauf und Unterlauf der Fenster (beim
  ESP32 im Debug-Monitor von Asmonite).
- `callx8 a8`: dasselbe mit dem Ziel in einem Register.

Verwandt: `call0`, `entry`, `registers`

## call0, callx0, ret, ret.n – Aufrufe ohne Fenster

`call0 label` legt die Rücksprungadresse in `a0` und springt; `ret` springt zu `a0` zurück. Das Fenster dreht sich
nicht: Die aufgerufene Funktion teilt die Register mit dem Aufrufer (die „call0-ABI“). Eine Funktion, die eine andere
aufruft, muss ihr `a0` vorher sichern. `_start` eines Programms auf dem ESP32 ruft der Debugger so auf: `ret` am Ende
beendet die Sitzung.

```asm
  call0 wait              ; a0 = Rücksprungadresse
  ...
  align 4
wait:
  rsr   a9, ccount
  ret                     ; zurück zu a0
```

Verwandt: `window`

## l32r – ein Wort aus einem Literal

`l32r at, label` lädt das Wort bei `label`, das **vor** dem Befehl stehen muss (bis 256 KB zurück) und durch 4 teilbar
sein muss. So bekommt ein Programm Konstanten mit mehr als 12 Bit und Adressen: Die Literale stehen in einer Reihe
vor dem Code (`lit_x: dd 0x3FF44000`). Die Adresse zählt vom Befehl aus (pc-relativ), das Literal wandert also mit
dem Programm.

```asm
lit_gpio: dd 0x3FF44000
lit_text: dd text
_start:
  l32r a2, lit_gpio       ; a2 = 0x3FF44000
  l32r a3, lit_text       ; a3 = die Adresse von text
```

`movi` nimmt -2048 .. 2047 direkt, `movi.n` -32 .. 95.

Verwandt: `movi`, `l32i`

## movi, movi.n, mov, mov.n – eine Zahl oder ein Register in ein Register

`movi at, n` lädt eine Zahl von -2048 .. 2047, `movi.n` eine von -32 .. 95 (2 Bytes). `mov ar, as` kopiert ein
Register (`mov.n`: 2 Bytes). Größere Zahlen kommen mit `l32r` aus einem Literal.

Verwandt: `l32r`

## l8ui, l16ui, l16si, l32i, l32i.n, s8i, s16i, s32i, s32i.n – Laden und Speichern

`l32i at, as, offset` lädt das Wort bei `as + offset` (Offset 0 .. 1020, durch 4 teilbar); `s32i` speichert eins.
`l8ui` lädt ein Byte (mit Nullen erweitert), `l16ui`/`l16si` ein Halbwort (mit Nullen oder dem Vorzeichen erweitert),
`s8i`/`s16i` speichern sie. Die Formen mit `.n` nehmen einen Offset 0 .. 60 und 2 Bytes.

Der Speicher macht einen Unterschied: Das **IRAM** des ESP32 und des ESP32-S3 nimmt nur Wörter; ein Zugriff auf ein
Byte oder Halbwort dort hält mit einem LoadStoreError an. Beim ESP32 kommen Daten hinter `.data` (ins DRAM); beim
ESP32-S3 liest man sie über den Datenbus, 0x6F0000 unter ihrer IRAM-Adresse. Der ESP32-C3 ist RISC-V. Register der
Peripherie sind Wörter: `l32i`, `s32i`, und `memw` nach Schreibzugriffen, die in ihrer Reihenfolge ankommen müssen.

```asm
  l32i  a4, a3, 0          ; ein Wort
  l8ui  a5, a3, 1          ; ein Byte (nicht im IRAM)
  s32i  a5, a2, 0x08       ; ein Wort in ein Register der Peripherie
  memw
```

Verwandt: `memw`, `l32r`

## add, add.n, addi, addi.n, addmi, sub, neg, abs – Rechnen

`add ar, as, at` (`ar = as + at`), `sub ar, as, at`, `addi at, as, n` (n = -128 .. 127), `addmi at, as, n` (n ein
Vielfaches von 256 bis ±32768), `neg`, `abs`. Die Formen mit `.n` haben 2 Bytes (`addi.n`: n = -1, 1 .. 15). Es gibt
keine Flags: Ein Überlauf ist nicht zu sehen; verglichen wird mit einem Sprung.

Verwandt: `branches`, `mull`

## branches, beq, bne, blt, bge, bltu, bgeu, beqz, bnez, bltz, bgez, beqi, bnei, blti, bgei, bltui, bgeui, beqz.n, bnez.n, bbs, bbc, bbsi, bbci, bany, ball, bnone, bnall, j, jx – Sprünge

Ein bedingter Sprung vergleicht und springt in einem Befehl (es gibt keine Flags): `beq as, at, label` springt, wenn
`as = at`, `blt`, wenn `as < at` (mit Vorzeichen), `bltu` (ohne); `beqz`, `bnez`, `bltz`, `bgez` vergleichen mit 0;
`beqi`, `blti` … mit einer kleinen Zahl. `bbsi as, 5, label` springt, wenn Bit 5 von `as` gesetzt ist, `bbci`, wenn
es gelöscht ist; `bany`, `ball`, `bnone`, `bnall` prüfen die Bits einer Maske. Das Ziel eines bedingten Sprungs ist
nah (etwa ±128 Bytes; `beqz`/`bnez` ±2 KB); `j label` springt weit (±128 KB), `jx as` zur Adresse in einem Register.

```asm
count:
  addi  a2, a2, 1
  bne   a2, a3, count      ; bis a2 = a3
  bbsi  a11, 1, ready      ; Bit 1 gesetzt?
```

Verwandt: `loop`

## loop, loopnez, loopgtz – Schleifen ohne Aufwand

`loop as, label` führt die Befehle bis `label` (ohne ihn) `as`-mal aus, ohne einen eigenen Befehl je Runde: Der
Prozessor zählt in `LCOUNT` und springt von `LEND` selbst nach `LBEG` zurück. `loopnez` überspringt die Schleife, wenn
`as` 0 ist (`loop` liefe dann 2^32-mal), `loopgtz`, wenn `as` 0 oder kleiner ist. Die Register `LBEG`, `LEND`,
`LCOUNT` stehen im Fenster der Register.

```asm
  movi    a3, 10
  loopnez a3, done
  addi    a2, a2, 1        ; 10-mal
done:
```

Verwandt: `branches`

## sar, ssl, ssr, ssai, ssa8l, sll, srl, sra, src, slli, srli, srai – Schieben

Schieben um eine Zahl geht direkt: `slli ar, as, 4`, `srli ar, at, 4` (logisch), `srai ar, at, 4` (arithmetisch).
Schieben um ein Register geht über das Spezialregister `SAR`: `ssl as` stellt es für ein Schieben nach links um `as`
ein, dann schiebt `sll ar, as`; `ssr as` für rechts, dann `srl ar, at` oder `sra ar, at`. `src ar, as, at` schiebt
die 64 Bit aus `as` und `at` um `SAR` nach rechts (ein Funnel-Shift); `ssai n` setzt `SAR` auf eine Zahl.

```asm
  ssl  a4                  ; SAR für ein Schieben nach links um a4
  sll  a5, a5              ; a5 = a5 << a4
```

Verwandt: `extui`

## extui – Bits aus einem Register

`extui ar, at, shift, bits` nimmt `bits` Bits (1 .. 16) von `at` ab Bit `shift`, als vorzeichenlose Zahl: `extui a5,
a4, 8, 8` ist das zweite Byte von `a4`. Mit `slli` und `or` setzt man damit Bytes und Felder von Registern zusammen
und nimmt sie auseinander.

Verwandt: `sar`

## mull, muluh, mulsh, mul16u, mul16s, quos, quou, rems, remu – Multiplizieren und Dividieren

`mull ar, as, at` sind die unteren 32 Bit des Produkts, `muluh`/`mulsh` die oberen 32 (ohne / mit Vorzeichen),
`mul16u`/`mul16s` multiplizieren die unteren Halbwörter. `quos`/`quou` dividieren (mit / ohne Vorzeichen),
`rems`/`remu` geben den Rest; eine Division durch 0 ist eine Ausnahme. Die MAC16-Einheit des ESP32 (`mula.dd.ll` …)
kennt der Assembler nicht.

Verwandt: `add`

## rsr, wsr, xsr, ccount, ps, vecbase – Spezialregister

`rsr ar, ccount` (oder `rsr.ccount ar`) liest ein Spezialregister, `wsr` schreibt eins, `xsr` tauscht. Einige davon:

| Register | Was |
|---|---|
| `CCOUNT` | der Taktzähler: zählt jeden Takt (40 MHz nach dem Boot-ROM des ESP32) |
| `SAR` | die Schiebeweite (siehe `sar`) |
| `PS` | der Zustand: Interrupt-Stufe, `EXCM`, `CALLINC`, `WOE` (Fenster an) |
| `LBEG`, `LEND`, `LCOUNT` | die Schleife (siehe `loop`) |
| `WINDOWBASE`, `WINDOWSTART` | die Registerfenster |
| `VECBASE` | die Adresse der Vektoren der Ausnahmen (der Debug-Monitor von Asmonite setzt seine eigene) |
| `EPC1`, `EXCCAUSE`, `EXCVADDR` | wo und warum eine Ausnahme kam |

Nach einem `wsr`, das ändert, wie der Prozessor läuft (`PS`, `VECBASE`, …), macht ein `rsync` oder `isync` es gültig.

```asm
  rsr   a9, ccount         ; die Zeit
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait      ; a7 Takte
```

Verwandt: `memw`

## memw, isync, rsync, esync, dsync, extw – Barrieren

`memw` wartet, bis die Lade- und Speicherzugriffe davor fertig sind: nach Schreibzugriffen auf Register der
Peripherie, vor dem nächsten, der von ihnen abhängt. `isync` macht geänderte Befehle und Spezialregister für das
Holen der Befehle gültig, `rsync` für die Register, `esync` und `dsync` für Ausnahmen und Daten.

Verwandt: `l32i`, `rsr`

## break, break.n, ill, ill.n, nop, nop.n, waiti, rfe, rfi, rfwo, rfwu – System

`break 1, 15` (und `break.n 1`) hält im Debugger an: Der Debug-Monitor von Asmonite schreibt sie als Breakpoints.
`ill` ist ein ungültiger Befehl (eine Ausnahme). `waiti n` wartet auf einen Interrupt über Stufe `n`. `rfe`, `rfi n`,
`rfwo`, `rfwu` kehren aus einer Ausnahme, einem Interrupt der Stufe `n`, einem Überlauf oder Unterlauf der Fenster
zurück. `nop` tut nichts.

Verwandt: `window`, `rsr`

## salt, saltu – setzen, wenn kleiner (nur LX7)

`salt ar, as, at` setzt `ar` auf 1, wenn `as < at` (mit Vorzeichen), sonst auf 0; `saltu` ohne Vorzeichen. Nur der
LX7 des ESP32-S3 hat sie; mit `.target esp32` (LX6) weist der Assembler sie ab.

Verwandt: `branches`

## !missing

Zu `{name}` gibt es noch keine Erklärung.
