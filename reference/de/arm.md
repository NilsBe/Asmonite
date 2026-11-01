# ARM- und Thumb-Befehle (ARMv7, UAL)

Die Befehlsinfo von Dismonite (F1) für ARM (A32, 4 Bytes je Befehl) und Thumb (T32, 2 oder 4 Bytes). Beide werden in derselben Sprache (UAL) geschrieben; ein Befehl wie `add` gibt es in beiden.

Jeder Abschnitt beginnt mit `## ` und den Namen, die er erklärt; lange Listen stehen in einer Zeile `<!-- names: ... -->`. Dismonite findet `addeq`, `adds.w` oder `vmoveq.f64` unter `add` bzw. `vmov` und zeigt die Bedingung (`eq`) dazu.

## cond – Bedingungen
<!-- names: eq, ne, cs, hs, cc, lo, mi, pl, vs, vc, hi, ls, ge, lt, gt, le, al -->

Fast jeder ARM-Befehl kann eine Bedingung tragen: Er wird nur ausgeführt, wenn die Flags passen, sonst übersprungen. Die Bedingung steht hinter dem Namen: `addeq`, `bne`, `ldrlt`. In Thumb gilt sie für die Befehle eines `it`-Blocks (und für `b`).

- `eq` gleich (Z = 1), `ne` ungleich (Z = 0)
- ohne Vorzeichen: `hs`/`cs` >=, `lo`/`cc` <, `hi` >, `ls` <=
- mit Vorzeichen: `ge` >=, `lt` <, `gt` >, `le` <=
- `mi` negativ (N = 1), `pl` nicht negativ
- `vs` Überlauf (V = 1), `vc` kein Überlauf
- `al` immer (wird nicht geschrieben)

Die Flags setzt `cmp`, `tst` oder ein Befehl mit `s` (`adds`, `subs`, ...).

```asm
cmp r0, #10
movge r0, #10    ; höchstens 10
addlt r1, r1, #1
```

Verwandt: `cmp`, `it`, `b`

## mov, movs – Wert kopieren

Kopiert einen Wert in ein Register: aus einem anderen Register (auch verschoben, siehe `lsl`) oder eine Zahl. `movs` setzt dazu die Flags N und Z (und C beim Schieben).

**Syntax:** `mov rd, rm` oder `mov rd, #zahl`

Nicht jede Zahl passt in den Befehl (ARM: 8 Bit, um eine gerade Zahl gedreht); größere lädt man mit `movw`/`movt` oder `ldr rd, [pc, #...]` aus einem Literal-Pool.

**Flags:** `movs`: N, Z, (C)

```asm
mov r0, #0       ; r0 = 0
mov r1, r2       ; r1 = r2
mov pc, lr       ; zurück (alt)
```

Verwandt: `mvn`, `movw`, `movt`, `ldr`

## mvn, mvns – Wert umgekehrt kopieren

Kopiert die Quelle mit umgekehrten Bits (`not`): `rd = ~quelle`. So lassen sich Zahlen wie 0xFFFFFF00 laden.

**Syntax:** `mvn rd, #zahl` oder `mvn rd, rm`

**Flags:** `mvns`: N, Z, (C)

```asm
mvn r0, #0       ; r0 = 0xFFFFFFFF
```

Verwandt: `mov`, `bic`

## movw, movt – 16 Bit laden

- `movw rd, #zahl`: lädt eine 16-Bit-Zahl, die oberen 16 Bit werden 0
- `movt rd, #zahl`: setzt nur die oberen 16 Bit, die unteren bleiben

Zusammen laden sie jede 32-Bit-Zahl oder Adresse.

**Flags:** keine

```asm
movw r0, #0x5678
movt r0, #0x1234 ; r0 = 0x12345678
```

Verwandt: `mov`, `ldr`, `adr`

## adr – Adresse relativ zu pc

Berechnet eine Adresse relativ zum Befehl selbst (eigentlich `add rd, pc, #zahl` bzw. `sub`). Dismonite zeigt im Kommentar, wohin sie zeigt (`=GetStdHandle`, ein Label).

**Syntax:** `adr rd, ziel`

`pc` ist beim Lesen die Adresse des Befehls + 8 (ARM) bzw. + 4 (Thumb, auf 4 abgerundet).

**Flags:** keine

Verwandt: `ldr`, `add`

## add, adds, addw – addieren

Addiert: `rd = rn + operand`. Der Operand ist ein Register (auch verschoben: `r2, lsl #2`) oder eine Zahl. `adds` setzt die Flags; `addw` (Thumb) nimmt eine 12-Bit-Zahl 0..4095.

**Syntax:** `add rd, rn, operand` (mit nur zwei Operanden: `rd = rd + operand`)

**Flags:** `adds`: N, Z, C, V

```asm
add r0, r0, #1   ; r0 + 1
add r0, r1, r2, lsl #2 ; r1+r2*4
add sp, sp, #16  ; Stack freigeben
```

Verwandt: `adc`, `sub`, `adr`

## adc, adcs – addieren mit Übertrag

Addiert mit dem Carry-Flag: `rd = rn + operand + C`. Für Zahlen über 32 Bit: erst `adds` für die unteren Wörter, dann `adc`.

**Flags:** `adcs`: N, Z, C, V

```asm
adds r0, r0, r2  ; untere 32 Bit
adc r1, r1, r3   ; obere + C
```

Verwandt: `add`, `sbc`

## sub, subs, subw – subtrahieren

Subtrahiert: `rd = rn - operand`. `subs` setzt die Flags (C = 1 heißt: kein Borgen); `subw` (Thumb) mit 12-Bit-Zahl.

**Syntax:** `sub rd, rn, operand`

**Flags:** `subs`: N, Z, C, V

```asm
sub sp, sp, #8   ; lokaler Platz
subs r2, r2, #1  ; Zähler - 1
bne schleife
```

Verwandt: `rsb`, `sbc`, `cmp`, `add`

## sbc, sbcs – subtrahieren mit Borgen

`rd = rn - operand - (1 - C)`. Für Zahlen über 32 Bit nach `subs`.

**Flags:** `sbcs`: N, Z, C, V

Verwandt: `sub`, `adc`, `rsc`

## rsb, rsbs – umgekehrt subtrahieren

Subtrahiert andersherum: `rd = operand - rn`. Mit 0 als Operand dreht es das Vorzeichen um (wie `neg`).

**Syntax:** `rsb rd, rn, operand`

**Flags:** `rsbs`: N, Z, C, V

```asm
rsb r0, r0, #0   ; r0 = -r0
```

Verwandt: `sub`, `rsc`

## rsc, rscs – umgekehrt subtrahieren mit Borgen

`rd = operand - rn - (1 - C)` (nur ARM, nicht Thumb).

**Flags:** `rscs`: N, Z, C, V

Verwandt: `rsb`, `sbc`

## cmp – vergleichen

Rechnet `rn - operand` und setzt nur die Flags. Danach folgt ein bedingter Befehl (`bne`, `movge`, ...) oder ein `it`-Block.

**Syntax:** `cmp rn, operand`

**Flags:** N, Z, C, V

```asm
cmp r0, #0
beq null         ; wenn r0 = 0
```

Verwandt: `cmn`, `tst`, Bedingungen (`cond`)

## cmn – negativ vergleichen

Rechnet `rn + operand` und setzt nur die Flags; vergleicht also mit dem negativen Operanden (`cmn r0, #1` prüft auf -1).

**Flags:** N, Z, C, V

Verwandt: `cmp`

## tst – Bits prüfen

Rechnet `rn and operand` und setzt nur die Flags N und Z.

**Syntax:** `tst rn, operand`

```asm
tst r0, #1
bne ungerade     ; Bit 0 gesetzt
```

Verwandt: `teq`, `and`, `cmp`

## teq – auf Gleichheit prüfen

Rechnet `rn xor operand` und setzt nur die Flags N und Z: Z = 1, wenn beide gleich sind (ohne C und V zu ändern).

Verwandt: `tst`, `eor`, `cmp`

## and, ands – Und

Bitweises Und: `rd = rn and operand`. Ein Bit bleibt nur, wenn es in beiden gesetzt ist; damit löscht man Bits.

**Flags:** `ands`: N, Z, (C)

```asm
and r0, r0, #0xFF ; unterstes Byte
```

Verwandt: `orr`, `eor`, `bic`, `tst`

## orr, orrs – Oder

Bitweises Oder: `rd = rn or operand`. Damit setzt man Bits.

**Flags:** `orrs`: N, Z, (C)

```asm
orr r0, r0, #0x80 ; Bit 7 setzen
```

Verwandt: `and`, `eor`, `orn`

## orn, orns – Oder mit umgekehrtem Operanden

`rd = rn or not operand` (nur Thumb).

**Flags:** `orns`: N, Z, (C)

Verwandt: `orr`, `mvn`

## eor, eors – exklusives Oder

Bitweises exklusives Oder: `rd = rn xor operand`. Ein Bit wird 1, wenn genau eines der beiden 1 ist; damit kippt man Bits.

**Flags:** `eors`: N, Z, (C)

```asm
eor r0, r0, r0   ; r0 = 0
eor r1, r1, #1   ; Bit 0 kippen
```

Verwandt: `and`, `orr`, `teq`

## bic, bics – Bits löschen

`rd = rn and not operand`: die Bits, die im Operanden gesetzt sind, werden gelöscht.

**Flags:** `bics`: N, Z, (C)

```asm
bic r0, r0, #3   ; auf 4 abrunden
```

Verwandt: `and`, `orr`

## lsl, lsls – nach links schieben

Schiebt die Bits nach links, rechts kommen Nullen: jede Stelle verdoppelt. Als eigener Befehl oder als Zusatz eines Operanden (`add r0, r1, r2, lsl #2`).

**Syntax:** `lsl rd, rm, #zahl` oder `lsl rd, rm, rs`

**Flags:** `lsls`: N, Z, C (das letzte hinausgeschobene Bit)

```asm
lsl r0, r1, #2   ; r1 * 4
```

Verwandt: `lsr`, `asr`, `ror`

## lsr, lsrs – nach rechts schieben (ohne Vorzeichen)

Schiebt nach rechts, links kommen Nullen: teilt ohne Vorzeichen durch 2 je Stelle.

**Flags:** `lsrs`: N, Z, C

```asm
lsr r0, r0, #4   ; r0 / 16
```

Verwandt: `asr`, `lsl`, `ubfx`

## asr, asrs – nach rechts schieben (mit Vorzeichen)

Schiebt nach rechts, links wird das Vorzeichenbit wiederholt: teilt mit Vorzeichen durch 2 je Stelle (abgerundet).

**Flags:** `asrs`: N, Z, C

```asm
asr r1, r0, #31  ; 0 oder -1
```

Verwandt: `lsr`, `sbfx`

## ror, rors – rotieren

Dreht die Bits nach rechts: was rechts hinausgeht, kommt links wieder herein.

**Flags:** `rors`: N, Z, C

Verwandt: `rrx`, `lsr`

## rrx, rrxs – um 1 rotieren durch Carry

Schiebt um eine Stelle nach rechts; links kommt das Carry-Flag herein, das hinausgeschobene Bit wird (bei `rrxs`) das neue C.

**Flags:** `rrxs`: N, Z, C

Verwandt: `ror`, `adc`

## clz – führende Nullen zählen

Zählt die Nullbits von oben bis zum ersten gesetzten Bit (0 bis 32).

**Syntax:** `clz rd, rm`

**Flags:** keine

```asm
clz r1, r0       ; 32 bei r0 = 0
```

Verwandt: `rbit`

## rbit – Bitreihenfolge umkehren

Kehrt die 32 Bits um: Bit 0 wird Bit 31 usw. Zusammen mit `clz` zählt man so Nullen von unten.

**Flags:** keine

Verwandt: `clz`, `rev`

## rev, rev16, revsh – Bytereihenfolge umkehren

- `rev`: die 4 Bytes umkehren (Little Endian <-> Big Endian)
- `rev16`: in jeder Hälfte die 2 Bytes tauschen
- `revsh`: die unteren 2 Bytes tauschen und mit Vorzeichen erweitern

**Flags:** keine

```asm
rev r0, r0       ; 0x11223344 ->
                 ; 0x44332211
```

Verwandt: `rbit`

## bfc – Bitfeld löschen

Setzt `breite` Bits ab Bit `lsb` auf 0.

**Syntax:** `bfc rd, #lsb, #breite`

**Flags:** keine

Verwandt: `bfi`, `bic`

## bfi – Bitfeld einfügen

Kopiert die unteren `breite` Bits von `rn` nach `rd` ab Bit `lsb`; die übrigen Bits von `rd` bleiben.

**Syntax:** `bfi rd, rn, #lsb, #breite`

**Flags:** keine

```asm
bfi r0, r1, #8, #4 ; Bits 8..11
```

Verwandt: `bfc`, `ubfx`

## sbfx, ubfx – Bitfeld herausholen

Holt `breite` Bits ab Bit `lsb` aus `rn` nach `rd` (an Bit 0): `ubfx` mit Nullen erweitert, `sbfx` mit Vorzeichen.

**Syntax:** `ubfx rd, rn, #lsb, #breite`

**Flags:** keine

```asm
ubfx r0, r1, #4, #4 ; Bits 4..7
```

Verwandt: `bfi`, `lsr`, `and`

## sxtb, sxth, uxtb, uxth, sxtb16, uxtb16 – erweitern

Erweitert ein Byte (`b`) oder Halbwort (`h`) auf 32 Bit: `sxt` mit Vorzeichen, `uxt` mit Nullen. Die Quelle kann vorher um 8, 16 oder 24 Bit gedreht werden (`, ror #8`). `sxtb16`/`uxtb16` erweitern zwei Bytes zu zwei Halbwörtern.

**Syntax:** `uxtb rd, rm`

**Flags:** keine

```asm
uxtb r0, r0      ; r0 and 0xFF
sxth r1, r2      ; -32768..32767
```

Verwandt: `sxtab`, `and`, `ldrb`

## sxtab, sxtah, uxtab, uxtah, sxtab16, uxtab16 – erweitern und addieren

Wie `sxtb` usw., das Ergebnis wird zu `rn` addiert: `rd = rn + erweitert(rm)`.

**Syntax:** `uxtab rd, rn, rm`

**Flags:** keine

Verwandt: `sxtb`, `add`

## pkhbt, pkhtb – Halbwörter zusammensetzen

Setzt ein Wort aus zwei Halbwörtern zusammen: `pkhbt` unten aus `rn`, oben aus `rm` (nach `lsl`); `pkhtb` oben aus `rn`, unten aus `rm` (nach `asr`).

**Flags:** keine

Verwandt: `bfi`

## ssat, usat, ssat16, usat16 – sättigen

Begrenzt einen Wert auf einen Bereich, statt überzulaufen: `ssat rd, #n, rm` auf -2^(n-1) .. 2^(n-1)-1, `usat` auf 0 .. 2^n-1. Die Varianten mit 16 tun das für beide Halbwörter.

**Flags:** Q = 1, wenn begrenzt wurde

```asm
usat r0, #8, r0  ; auf 0..255
```

Verwandt: `qadd`

## sel – Bytes nach GE-Flags wählen

Wählt jedes Byte aus `rn` oder `rm`, je nach den GE-Flags, die ein paralleler Befehl (`uadd8`, `usub8`, ...) gesetzt hat.

**Flags:** keine

Verwandt: `uadd8`

## usad8, usada8 – Summe der Differenzen

Bildet die Beträge der Differenzen der vier Bytes von `rn` und `rm` und addiert sie (`usada8`: noch `ra` dazu). Für Bild- und Videovergleiche.

**Flags:** keine

Verwandt: `uadd8`, `sel`

## mul, muls – multiplizieren

`rd = rn * rm`, die unteren 32 Bit des Produkts (mit und ohne Vorzeichen gleich).

**Syntax:** `mul rd, rn, rm`

**Flags:** `muls`: N, Z

```asm
mul r0, r1, r2   ; r0 = r1 * r2
```

Verwandt: `mla`, `umull`, `smull`

## mla, mlas – multiplizieren und addieren

`rd = rn * rm + ra`.

**Syntax:** `mla rd, rn, rm, ra`

**Flags:** `mlas`: N, Z

Verwandt: `mul`, `mls`

## mls – multiplizieren und subtrahieren

`rd = ra - rn * rm`. Zusammen mit `udiv`/`sdiv` ergibt das den Rest einer Division.

**Syntax:** `mls rd, rn, rm, ra`

**Flags:** keine

```asm
udiv r2, r0, r1  ; r2 = r0 / r1
mls r3, r2, r1, r0 ; r3 = Rest
```

Verwandt: `mla`, `udiv`

## umull, umulls, smull, smulls – multiplizieren, 64 Bit

Das ganze 64-Bit-Produkt in zwei Registern: `rdhi:rdlo = rn * rm`; `umull` ohne, `smull` mit Vorzeichen.

**Syntax:** `umull rdlo, rdhi, rn, rm`

**Flags:** mit `s`: N, Z

Verwandt: `umlal`, `mul`

## umlal, umlals, smlal, smlals – multiplizieren und addieren, 64 Bit

`rdhi:rdlo = rdhi:rdlo + rn * rm`; `umlal` ohne, `smlal` mit Vorzeichen.

**Flags:** mit `s`: N, Z

Verwandt: `umull`, `umaal`

## umaal – multiplizieren, zwei Summanden

`rdhi:rdlo = rn * rm + rdlo + rdhi` (ohne Vorzeichen), für Langzahl-Arithmetik.

**Flags:** keine

Verwandt: `umlal`

## sdiv, udiv – dividieren

`rd = rn / rm`, zu 0 hin gerundet; `udiv` ohne, `sdiv` mit Vorzeichen. Teilen durch 0 ergibt 0 (oder eine Ausnahme, wenn das System es so einstellt). Ältere ARM-Prozessoren kennen keine Division; dann ruft der Compiler eine Funktion (Windows: `__rt_udiv`).

**Syntax:** `udiv rd, rn, rm`

**Flags:** keine

Verwandt: `mls`, `mul`

## smlabb, smlabt, smlatb, smlatt – 16 x 16 + 32

Multipliziert je ein Halbwort mit Vorzeichen (b = unten, t = oben; erst von `rn`, dann von `rm`) und addiert `ra`.

**Flags:** Q bei Überlauf der Addition

Verwandt: `smulbb`, `smlawb`

## smulbb, smulbt, smultb, smultt – 16 x 16

Multipliziert je ein Halbwort mit Vorzeichen (b = unten, t = oben): `rd = rn.x * rm.y`.

**Flags:** keine

Verwandt: `smlabb`, `smulwb`

## smlawb, smlawt, smulwb, smulwt – 32 x 16

Multipliziert `rn` (32 Bit) mit einem Halbwort von `rm` und nimmt die oberen 32 Bit des 48-Bit-Produkts; `smlaw` addiert `ra` dazu.

**Flags:** `smlaw`: Q bei Überlauf

Verwandt: `smulbb`

## smlalbb, smlalbt, smlaltb, smlaltt – 16 x 16 + 64

Multipliziert je ein Halbwort mit Vorzeichen und addiert zum 64-Bit-Wert in `rdhi:rdlo`.

**Flags:** keine

Verwandt: `smlal`, `smlabb`

## smlad, smladx, smlsd, smlsdx, smuad, smuadx, smusd, smusdx – zwei Produkte

Multipliziert beide Halbwortpaare und addiert (`smuad`, `smlad`) bzw. subtrahiert (`smusd`, `smlsd`) die Produkte; `smla...`/`smls...` addieren `ra` dazu. Mit `x` werden die Halbwörter von `rm` vorher getauscht.

**Flags:** Q bei Überlauf

Verwandt: `smlald`, `smulbb`

## smlald, smlaldx, smlsld, smlsldx – zwei Produkte, 64 Bit

Wie `smlad`/`smlsd`, aber das Ergebnis wird zu `rdhi:rdlo` addiert.

**Flags:** keine

Verwandt: `smlad`, `smlal`

## smmul, smmulr, smmla, smmlar, smmls, smmlsr – obere 32 Bit

Multipliziert mit Vorzeichen und nimmt die oberen 32 Bit des Produkts; `smmla`/`smmls` addieren bzw. subtrahieren es mit `ra`. Mit `r` wird gerundet statt abgeschnitten.

**Flags:** keine

Verwandt: `smull`

## qadd, qsub, qdadd, qdsub – mit Sättigung rechnen

Addieren bzw. subtrahieren mit Vorzeichen; statt überzulaufen bleibt das Ergebnis beim größten bzw. kleinsten Wert stehen. `qdadd`/`qdsub` verdoppeln `rn` vorher (auch gesättigt).

**Flags:** Q = 1, wenn gesättigt wurde

Verwandt: `ssat`, `qadd8`

## sadd16, uadd8 – parallel rechnen (und Verwandte)
<!-- names: sadd16, sadd8, sasx, ssax, ssub16, ssub8, uadd16, uadd8, uasx, usax, usub16, usub8, qadd16, qadd8, qasx, qsax, qsub16, qsub8, uqadd16, uqadd8, uqasx, uqsax, uqsub16, uqsub8, shadd16, shadd8, shasx, shsax, shsub16, shsub8, uhadd16, uhadd8, uhasx, uhsax, uhsub16, uhsub8 -->

Rechnen mit zwei Halbwörtern (`16`) oder vier Bytes (`8`) in einem Register zugleich (SIMD). Der Name setzt sich zusammen:

- Anfang: `s` mit Vorzeichen, `u` ohne; `q`/`uq` mit Sättigung; `sh`/`uh` mit Halbierung des Ergebnisses
- `add`, `sub`; `asx` = oben addieren, unten subtrahieren (nach Tausch); `sax` umgekehrt
- Ende: `16` oder `8`

Die Formen ohne `q`/`h` setzen die GE-Flags für `sel`.

```asm
uadd8 r0, r1, r2 ; 4 Bytes
```

Verwandt: `sel`, `qadd`, `usad8`

## ldr – Wort laden

Lädt 4 Bytes aus dem Speicher in ein Register. ARM rechnet nur mit Registern; Speicher wird nur mit `ldr`/`str` (und ihren Verwandten) gelesen und geschrieben.

**Syntax:** `ldr rt, [rn, #offset]`

- `[rn]`, `[rn, #4]`, `[rn, -r2]`, `[rn, r2, lsl #2]`: die Adresse
- `[rn, #4]!`: vorher addieren und `rn` ändern (pre-indexed)
- `[rn], #4`: an `rn` lesen, danach `rn` um 4 erhöhen (post-indexed)
- `[pc, #offset]`: ein Wert aus dem Literal-Pool hinter dem Code (Dismonite zeigt ihn im Kommentar)

Mit `pc` als Ziel ist `ldr` ein Sprung.

**Flags:** keine

```asm
ldr r0, [r1]     ; r0 = Wort an r1
ldr r2, [r1, #4]!
ldr r3, [pc, #0x10] ; Konstante
```

Verwandt: `str`, `ldrb`, `ldrh`, `ldm`, `adr`

## str – Wort speichern

Schreibt ein Register (4 Bytes) in den Speicher. Adressformen wie bei `ldr`.

**Syntax:** `str rt, [rn, #offset]`

**Flags:** keine

```asm
str r0, [sp, #4] ; lokale Variable
str r1, [r2], #4 ; und r2 + 4
```

Verwandt: `ldr`, `strb`, `strh`, `stm`, `push`

## ldrb, strb – Byte laden und speichern

`ldrb` lädt ein Byte und füllt die oberen 24 Bit mit 0; `strb` schreibt die unteren 8 Bit eines Registers.

**Flags:** keine

```asm
ldrb r0, [r1], #1 ; Zeichen
cmp r0, #0
bne weiter
```

Verwandt: `ldr`, `ldrsb`, `uxtb`

## ldrh, strh – Halbwort laden und speichern

`ldrh` lädt 2 Bytes und füllt die oberen 16 Bit mit 0; `strh` schreibt die unteren 16 Bit.

**Flags:** keine

Verwandt: `ldr`, `ldrsh`, `uxth`

## ldrsb, ldrsh – mit Vorzeichen laden

Laden ein Byte (`ldrsb`) oder Halbwort (`ldrsh`) und erweitern es mit dem Vorzeichen auf 32 Bit.

**Flags:** keine

Verwandt: `ldrb`, `ldrh`, `sxtb`

## ldrt, ldrbt, ldrht, ldrsbt, ldrsht, strt, strbt, strht – Zugriff wie im Benutzermodus

Wie `ldr`, `ldrb`, ... `str`, aber mit den Rechten des Benutzermodus, auch wenn der Kern sie ausführt. Nur im Betriebssystem sinnvoll.

**Flags:** keine

Verwandt: `ldr`, `str`

## ldrd, strd – zwei Wörter laden und speichern

Laden bzw. speichern zwei Register auf einmal (8 Bytes) an aufeinanderfolgenden Adressen.

**Syntax:** `ldrd rt, rt2, [rn, #offset]`

**Flags:** keine

```asm
ldrd r0, r1, [sp, #8] ; 64 Bit
```

Verwandt: `ldr`, `ldm`

## ldm, ldmia, ldmib, ldmda, ldmdb – mehrere Register laden

Lädt die Register der Liste nacheinander ab der Adresse in `rn`. Das niedrigste Register kommt von der niedrigsten Adresse.

- `ia` (oder ohne): ab `rn` aufwärts; `ib`: ab `rn + 4`
- `db`: unterhalb von `rn`; `da`: bis `rn`
- `rn!`: `rn` danach auf das Ende setzen

Mit `pc` in der Liste ist es ein Rücksprung.

**Flags:** keine

```asm
ldm r0!, {r1, r2, r3}
```

Verwandt: `stm`, `pop`, `ldr`

## stm, stmia, stmib, stmda, stmdb – mehrere Register speichern

Speichert die Register der Liste; Adressierung wie bei `ldm`. `stmdb sp!, {...}` ist `push`.

**Flags:** keine

```asm
stmia r0!, {r4, r5} ; 8 Bytes
```

Verwandt: `ldm`, `push`, `str`

## push – Register auf den Stack

Legt die Register der Liste auf den Stack (`stmdb sp!, {...}`): `sp` wird um 4 je Register kleiner. Am Anfang einer Funktion sichert es die Register, die sie ändert, und `lr` (die Rücksprungadresse).

**Syntax:** `push {r4, r5, lr}`

**Flags:** keine

```asm
push {r4, lr}    ; Funktionsanfang
; ...
pop {r4, pc}     ; zurück
```

Verwandt: `pop`, `stm`, `bl`

## pop – Register vom Stack

Holt die Register der Liste vom Stack (`ldmia sp!, {...}`). Mit `pc` in der Liste kehrt die Funktion zurück: der gesicherte Wert von `lr` wird der neue `pc`.

**Syntax:** `pop {r4, pc}`

**Flags:** keine

Verwandt: `push`, `ldm`, `bx`

## ldrex, ldrexb, ldrexh, ldrexd, strex, strexb, strexh, strexd – exklusiver Zugriff

Für atomare Operationen zwischen Threads und Prozessoren: `ldrex` lädt und merkt sich die Adresse; `strex` speichert nur, wenn seitdem niemand anders dort geschrieben hat, und schreibt 0 (geklappt) oder 1 (nochmal) in das Statusregister.

**Syntax:** `strex rd, rt, [rn]` (rd: Status)

**Flags:** keine

```asm
nochmal:
    ldrex r1, [r0]
    add r1, r1, #1
    strex r2, r1, [r0]
    cmp r2, #0
    bne nochmal  ; atomar + 1
```

Verwandt: `clrex`, `dmb`

## clrex – exklusive Markierung löschen

Löscht die Markierung von `ldrex`; ein folgendes `strex` schlägt fehl.

**Flags:** keine

Verwandt: `ldrex`

## swp, swpb – tauschen (alt)

Lädt ein Wort (`swpb`: Byte) aus dem Speicher und schreibt zugleich ein Register dorthin, atomar. Veraltet, ersetzt durch `ldrex`/`strex`.

**Flags:** keine

Verwandt: `ldrex`

## pld, pldw, pli – vorab laden

Hinweis an den Prozessor, die Daten (`pld`, `pldw` zum Schreiben) oder Befehle (`pli`) an der Adresse schon in den Cache zu laden. Ändert nichts am Programm.

**Flags:** keine

Verwandt: `ldr`

## b – springen

Springt zum Ziel. Mit Bedingung (`beq`, `bne`, `blt`, ...) nur, wenn die Flags passen; sonst geht es mit dem nächsten Befehl weiter.

**Syntax:** `b ziel`, `bne ziel`

Reichweite: ARM ±32 MB; Thumb 16 Bit ±2 KB (bedingt ±256 Bytes), 32 Bit (`b.w`) ±16 MB.

**Flags:** keine geändert

```asm
    cmp r0, #0
    beq fertig
    b schleife
```

Verwandt: `bl`, `bx`, `cbz`, Bedingungen (`cond`)

## bl – Unterprogramm aufrufen

Speichert die Rücksprungadresse (den nächsten Befehl) in `lr` und springt. Die Funktion kehrt mit `bx lr` oder `pop {..., pc}` zurück. Anders als bei x86 kommt die Adresse nicht auf den Stack; eine Funktion, die selbst aufruft, sichert `lr` mit `push`.

**Syntax:** `bl ziel`

**Flags:** keine

```asm
bl printf        ; lr = Rückkehr
```

Verwandt: `blx`, `bx`, `push`

## blx – aufrufen, mit Wechsel ARM/Thumb

Wie `bl`, aber das Ziel kann im anderen Befehlssatz sein:

- `blx ziel`: wechselt immer (ARM nach Thumb und umgekehrt)
- `blx rm`: springt zur Adresse in `rm`; Bit 0 = 1 heißt Thumb

`blx r4` ist der übliche Aufruf über einen Funktionszeiger, z. B. eine Windows-Funktion aus der Importtabelle.

**Flags:** keine

```asm
ldr r4, [pc, #0x10] ; Adresse
blx r4           ; aufrufen
```

Verwandt: `bl`, `bx`

## bx – springen zur Adresse im Register

Springt zur Adresse in `rm`; Bit 0 wählt Thumb (1) oder ARM (0). `bx lr` ist der normale Rücksprung aus einer Funktion.

**Syntax:** `bx rm`

**Flags:** keine

```asm
bx lr            ; zurück
```

Verwandt: `blx`, `pop`, `bl`

## bxj – nach Jazelle wechseln

Wie `bx`; auf Prozessoren mit Jazelle (Java-Bytecode) würde es dorthin wechseln. Heute wie `bx`.

Verwandt: `bx`

## cbz, cbnz – vergleichen und springen (Thumb)

Springt, wenn das Register 0 ist (`cbz`) bzw. nicht 0 ist (`cbnz`), nur vorwärts bis 126 Bytes. Ändert die Flags nicht.

**Syntax:** `cbz rn, ziel`

```asm
cbz r0, fehler   ; wenn r0 = 0
```

Verwandt: `cmp`, `b`

## tbb, tbh – Sprungtabelle (Thumb)

Springt über eine Tabelle direkt hinter dem Befehl: `tbb [rn, rm]` liest das Byte an `rn + rm`, `tbh [rn, rm, lsl #1]` das Halbwort; der Sprung geht um das Doppelte dieses Werts vorwärts. So übersetzt der Compiler `switch`.

```asm
cmp r0, #3
bhi sonst
tbb [pc, r0]     ; Tabelle folgt
```

Verwandt: `b`, `ldr`

## it – bedingter Block (Thumb)
<!-- names: it, itt, ite, ittt, itte, itet, itee, itttt, ittte, ittet, ittee, itett, itete, iteet, iteee -->

Macht die nächsten 1 bis 4 Befehle bedingt. Die Buchstaben nach `it` sagen für den zweiten bis vierten Befehl: `t` (then) mit der Bedingung, `e` (else) mit der umgekehrten. Dismonite schreibt die Bedingung an jeden Befehl des Blocks.

**Syntax:** `ite eq` (zwei Befehle: der erste bei eq, der zweite bei ne)

**Flags:** keine geändert

```asm
cmp r0, #0
ite eq
moveq r1, #1     ; wenn r0 = 0
movne r1, #2     ; sonst
```

Verwandt: Bedingungen (`cond`), `cmp`

## svc – Systemaufruf

Ruft das Betriebssystem (Supervisor Call; früher `swi`). Linux: Nummer der Funktion in `r7`, Parameter in `r0`...; Ergebnis in `r0`.

**Syntax:** `svc #zahl`

```asm
mov r7, #4       ; write
svc #0
```

Verwandt: `bkpt`, `bl`

## bkpt – Haltepunkt

Hält das Programm im Debugger an (Breakpoint). Die Zahl wertet nur der Debugger aus.

**Syntax:** `bkpt #zahl`

Verwandt: `udf`, `svc`

## udf, trap – undefinierter Befehl

Löst absichtlich eine Ausnahme aus (undefined). Windows nutzt das für Fehler: `udf #0xfe` meldet einen Fehler wie `int3`, `udf #0xf9` ist `__brkdiv0` (Teilen durch 0).

Verwandt: `bkpt`

## smc, hvc, eret – Monitor und Hypervisor

- `smc`: ruft den Secure Monitor (TrustZone)
- `hvc`: ruft den Hypervisor
- `eret`: Rückkehr aus dem Hypervisor-Modus

Nur für Systemsoftware.

Verwandt: `svc`

## mrs – Statusregister lesen

Liest das Statusregister (`apsr`: die Flags N, Z, C, V, Q, GE; im System auch `cpsr`/`spsr`) in ein Register.

**Syntax:** `mrs rd, apsr`

Verwandt: `msr`

## msr – Statusregister schreiben

Schreibt Flags (`apsr_nzcvq`, `apsr_g`) oder im System Teile von `cpsr`/`spsr` aus einem Register oder einer Zahl.

**Syntax:** `msr apsr_nzcvq, rn`

Verwandt: `mrs`, `cps`

## cps, cpsie, cpsid – Interrupts und Modus

`cpsie` erlaubt, `cpsid` sperrt Interrupts: `i` (IRQ), `f` (FIQ), `a` (asynchrone Fehler). `cps #modus` wechselt den Prozessormodus. Nur im Betriebssystem.

```asm
cpsid i          ; IRQ aus
```

Verwandt: `msr`, `mrs`

## setend – Byte-Reihenfolge

`setend be` stellt die Speicherzugriffe auf Big Endian um, `setend le` zurück auf Little Endian.

Verwandt: `rev`

## nop, yield, wfe, wfi, sev, hint, dbg – Hinweise

- `nop`: tut nichts (Füller)
- `yield`: Hinweis, dass ein anderer Thread laufen darf (in Warteschleifen)
- `wfi`: schlafen bis zum nächsten Interrupt
- `wfe`: schlafen bis zu einem Ereignis; `sev` sendet ein Ereignis an alle Prozessoren
- `hint #n`, `dbg #n`: weitere Hinweise (ohne Wirkung auf das Programm)

Verwandt: `dmb`

## dmb, dsb, isb – Speicherbarrieren

Sorgen für die Reihenfolge von Speicherzugriffen, wichtig zwischen Prozessoren und für Geräte:

- `dmb`: Zugriffe vor der Barriere werden vor denen danach sichtbar
- `dsb`: wartet, bis alle Zugriffe davor fertig sind
- `isb`: lädt die folgenden Befehle neu (nach Änderungen an Code oder Systemregistern)

Die Option sagt, für wen: `sy` (alle), `ish` (innerhalb der Prozessoren), `st` (nur Schreiben), ...

```asm
dmb ish
```

Verwandt: `ldrex`, `strex`

## rfeia, rfeib, rfeda, rfedb, srsia, srsib, srsda, srsdb – Rückkehr aus Ausnahme

`srs` speichert `lr` und `spsr` eines Modus auf dessen Stack, `rfe` lädt `pc` und `cpsr` von dort zurück. Für Ausnahme-Routinen im Betriebssystem.

Verwandt: `cps`

## tt, ttt, tta, ttat – Sicherheit prüfen (ARMv8-M)

Fragen bei Mikrocontrollern mit TrustZone ab, ob eine Adresse sicher ist und welche Rechte gelten. In Windows-Programmen nicht verwendet (Dismonite findet sie höchstens in Daten).

Verwandt: `bxns`

## bxns, blxns – in den unsicheren Bereich (ARMv8-M)

Springen bzw. rufen aus dem sicheren Teil (TrustZone) in den unsicheren. Nur bei Mikrocontrollern.

Verwandt: `bx`, `blx`

## mcr, mrc, mcr2, mrc2 – Koprozessor-Register

`mrc` liest ein Register eines Koprozessors in ein ARM-Register, `mcr` schreibt es. Koprozessor 15 ist die Systemsteuerung (Cache, MMU, ...).

Windows liest damit den Thread-Block (TEB), Linux den Thread-Zeiger:

```asm
mrc p15, #0, r0, c13, c0, #2
```

Verwandt: `mcrr`, `vmrs`

## mcrr, mrrc, mcrr2, mrrc2 – Koprozessor, zwei Register

Wie `mcr`/`mrc`, mit zwei ARM-Registern (64 Bit), z. B. für Zähler.

Verwandt: `mcr`

## ldc, ldcl, ldc2, ldc2l, stc, stcl, stc2, stc2l – Koprozessor und Speicher

Laden bzw. speichern Register eines Koprozessors direkt aus dem bzw. in den Speicher. Für allgemeine Koprozessoren; in Windows-Programmen kommen sie nicht vor (Dismonite sieht sie nur in Daten).

Verwandt: `vldr`, `mcr`

## cdp, cdp2 – Koprozessor-Operation

Lässt einen Koprozessor rechnen. Für allgemeine Koprozessoren; heute kaum benutzt.

Verwandt: `mcr`

## vldr, vstr – Gleitkommaregister laden und speichern

Laden bzw. speichern ein Register der Gleitkommaeinheit (VFP): `s0`..`s31` (32 Bit, float) oder `d0`..`d31` (64 Bit, double; `d0` besteht aus `s0` und `s1`).

**Syntax:** `vldr d0, [rn, #offset]`

**Flags:** keine

```asm
vldr d0, [r0]    ; double laden
vstr s2, [sp, #4] ; float
```

Verwandt: `vldmia`, `vmov`, `ldr`

## vpush, vpop – Gleitkommaregister auf den Stack

Wie `push`/`pop` für Gleitkommaregister: `vpush {d8, d9}` sichert sie, `vpop` holt sie zurück. Funktionen sichern so `d8`..`d15`, die sie ändern.

**Flags:** keine

Verwandt: `push`, `vstmdb`

## vldmia, vldmdb, vstmia, vstmdb – mehrere Gleitkommaregister

Laden bzw. speichern eine Liste von Gleitkommaregistern ab `rn` (`ia` aufwärts, `db` unterhalb von `rn`); `rn!` ändert `rn`.

**Flags:** keine

Verwandt: `ldm`, `vpush`

## fldmiax, fldmdbx, fstmiax, fstmdbx – mehrere Register (alte Form)

Die alte Schreibweise von `vldm`/`vstm` für Doppelregister (mit ungerader Wortzahl, VFPv1). Wirkung wie `vldmia` usw.

Verwandt: `vldmia`

## vmov – Gleitkommawerte kopieren

Kopiert zwischen Gleitkommaregistern, zwischen ARM- und Gleitkommaregistern oder lädt eine Konstante:

- `vmov.f64 d0, d1`: Register kopieren
- `vmov s0, r0` / `vmov r0, s0`: 32 Bit hin und her (ohne Umwandlung)
- `vmov d0, r0, r1`: zwei ARM-Register in ein Doppelregister
- `vmov.f64 d0, #1.0`: einfache Konstanten (`#1.000000e+00`)
- `vmov.32 d0[1], r0`: eine Hälfte eines Doppelregisters

**Flags:** keine

Verwandt: `vldr`, `vcvt`, `mov`

## vmrs, vmsr – Status der Gleitkommaeinheit

`vmrs` liest ein Systemregister der Gleitkommaeinheit (meist `fpscr`), `vmsr` schreibt es. `vmrs apsr_nzcv, fpscr` kopiert das Ergebnis von `vcmp` in die normalen Flags, damit ein bedingter Sprung folgen kann.

```asm
vcmpe.f64 d0, #0
vmrs apsr_nzcv, fpscr
blt negativ
```

Verwandt: `vcmp`, `mrs`

## vadd, vsub, vmul, vdiv – Gleitkomma rechnen

Rechnen mit Gleitkommazahlen: `.f32` (float, s-Register) oder `.f64` (double, d-Register).

**Syntax:** `vadd.f64 d0, d1, d2` (d0 = d1 + d2)

**Flags:** keine (Ausnahmen in `fpscr`)

```asm
vmul.f64 d0, d0, d1
vdiv.f32 s0, s0, s1
```

Verwandt: `vmla`, `vcvt`, `vmov`

## vmla, vmls, vnmla, vnmls, vnmul – multiplizieren und addieren

- `vmla`: `d = d + n * m`; `vmls`: `d = d - n * m`
- `vnmla`: `d = -d - n * m`; `vnmls`: `d = -d + n * m`
- `vnmul`: `d = -(n * m)`

Das Produkt wird vor dem Addieren gerundet (anders als `vfma`).

Verwandt: `vfma`, `vmul`

## vfma, vfms, vfnma, vfnms – fused multiply-add

Wie `vmla`/`vmls`/`vnmla`/`vnmls`, aber ohne Zwischenrundung: genauer (VFPv4).

Verwandt: `vmla`

## vabs, vneg, vsqrt – Betrag, Vorzeichen, Wurzel

- `vabs`: Betrag
- `vneg`: Vorzeichen umkehren
- `vsqrt`: Quadratwurzel

**Syntax:** `vsqrt.f64 d0, d1`

Verwandt: `vmul`

## vcmp, vcmpe – Gleitkomma vergleichen

Vergleicht zwei Werte (oder mit `#0`) und setzt die Flags in `fpscr`; erst `vmrs apsr_nzcv, fpscr` bringt sie zu den normalen Flags. `vcmpe` meldet auch bei stillen NaN einen Fehler.

Verwandt: `vmrs`, `cmp`

## vcvt, vcvtr – umwandeln

Wandelt zwischen Zahlenarten um:

- `vcvt.f64.f32 d0, s0`: float nach double, `vcvt.f32.f64` zurück
- `vcvt.f64.s32 d0, s0`: ganze Zahl (mit Vorzeichen; `u32` ohne) nach double
- `vcvt.s32.f64 s0, d0`: double nach ganzer Zahl, zu 0 hin abgeschnitten; `vcvtr` rundet nach `fpscr`

Die ganze Zahl steht dabei in einem s-Register; mit `vmov r0, s0` kommt sie in ein ARM-Register.

Verwandt: `vmov`

## db, dw, dd, dq – Daten

Bytes in der Datei: `db` je ein Byte, `dw` 2 Bytes, `dd` 4 Bytes (ein ARM-Wort), `dq` 8 Bytes. Bei `db` auch Text in Anführungszeichen.

Dismonite schreibt ARM-Code aus ELF-Dateien im Export noch als `db` mit dem Befehl als Kommentar, bis Asmonite einen A32-Assembler hat; Thumb-Code aus PE-Dateien steht als Befehle da (`.arch thumb`). In den Strukturen der Datei (PE- oder ELF-Header) steht im Kommentar der Name des Felds.

```asm
db 0x10,0xB5     ; push {r4, lr}
dd 0x00401000
```

Verwandt: `org`, `align`, `rva`

## resb, resw, resd, resq – Platz reservieren

Reserviert Speicher ohne Dateibytes (uninitialisierte Daten, `.bss`): `resb` je ein Byte, `resw` Wörter, `resd` Doppelwörter, `resq` Qwords; die Zahl sagt, wie viele. Der Windows-Lader füllt den Platz beim Start mit Nullen, in der Datei steht nichts davon. Im Assembler (`.format pe`) darf `resb` am Ende einer Section stehen.

**Syntax:** `resb anzahl`

```asm
buffer: resb 4096   ; 4096 Bytes
count:  resd 1      ; ein Doppelwort
```

In Dismonite sind das die Zeilen im Speicher hinter der Datei (Labels `V...`); mit B, W, D, Q legst du fest, wie groß eine Variable ist.

Verwandt: `db`, `align`

## rva – relative Adresse

Die Adresse eines Labels minus die Basisadresse des Programms, 4 Bytes (in PE-Dateien). Bei Thumb-Code hat ein Einsprungpunkt Bit 0 gesetzt (`start + 1`).

Verwandt: `dd`

## org – Position festlegen

Die folgenden Bytes beginnen an diesem Datei-Offset; davor wird mit Nullen aufgefüllt.

Verwandt: `align`

## align – auf Grenze auffüllen

Füllt mit Nullen auf, bis die Position durch die Zahl teilbar ist (z. B. `FileAlignment` einer Section).

Verwandt: `org`

## !label

**Label** (Sprungmarke): ein Name für eine Adresse. Sprünge, Aufrufe und Daten beziehen sich darauf.

Dismonite vergibt automatische Namen wie `C00401020` (ein `call` zeigt darauf), `J00401020` (ein Sprung) oder `L00401020` (nur Daten); mit **N** gibt man einem Label einen eigenen Namen, Strg+Klick auf einen Namen (oder die Taste **F** in der Zeile) springt hin.

## !comment

**Kommentarzeile**: ein eigener Kommentar vor der Zeile darunter (Eingabe-Taste). Er wird in der `.dmon`-Datei gespeichert.

## !info

**Infozeile**: ein Hinweis von Dismonite zur Datei oder zum Bereich darunter, z. B. welcher Prozessor oder welche Struktur.

## !missing

Zu `{name}` gibt es noch keine Erklärung.
