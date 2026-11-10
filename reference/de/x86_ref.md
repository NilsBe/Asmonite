# Befehle aus der Befehlsreferenz (erzeugt)

Erzeugt von tools/gen_help_ref.py aus den Tabellen des Assemblers (tools/instr), nicht von Hand ändern. F1 zeigt einen Abschnitt von hier, wenn die Hilfe der Architektur keinen eigenen hat.

## aaa – ASCII-Korrektur nach einer Addition (BCD)

**Syntax:** `aaa`

**Wirkung:** `if (al & 15) > 9 or AF = 1 then { al = al + 6; ah = ah + 1; AF = CF = 1 } else { AF = CF = 0 }; al = al & 15`

**Flags:** AF CF &nbsp; undefiniert: OF SF ZF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aad – ASCII-Korrektur vor einer Division (BCD)

**Syntax:** `aad imm8`

**Wirkung:** `al = ah * imm8 + al; ah = 0 (imm8 is 10 for BCD)`

**Flags:** SF ZF PF &nbsp; undefiniert: OF AF CF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aam – ASCII-Korrektur nach einer Multiplikation (BCD)

**Syntax:** `aam imm8`

**Wirkung:** `ah = al / imm8; al = al % imm8 (imm8 is 10 for BCD)`

**Flags:** SF ZF PF &nbsp; undefiniert: OF AF CF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aas – ASCII-Korrektur nach einer Subtraktion (BCD)

**Syntax:** `aas`

**Wirkung:** `if (al & 15) > 9 or AF = 1 then { al = al - 6; ah = ah - 1; AF = CF = 1 } else { AF = CF = 0 }; al = al & 15`

**Flags:** AF CF &nbsp; undefiniert: OF SF ZF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adc – Addition mit Übertrag (CF)

**Syntax:** `adc r/m8, r8` &nbsp; `adc r/m32, r32` &nbsp; `adc r/m16, r16` &nbsp; `adc r8, r/m8` &nbsp; `adc r32, r/m32` &nbsp; `adc r16, r/m16` &nbsp; `adc al, imm8` &nbsp; `adc eax, imm32` &nbsp; …

**Wirkung:** `dst = dst + src + CF`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adcx – Addition mit Übertrag, ändert nur CF

**Syntax:** `adcx r32, r/m32` &nbsp; `adcx r64, r/m64`

**Wirkung:** `dst = dst + src + CF`

**Flags:** CF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## add – Addition der Quelle zum Ziel

**Syntax:** `add r/m8, r8` &nbsp; `add r/m32, r32` &nbsp; `add r/m16, r16` &nbsp; `add r8, r/m8` &nbsp; `add r32, r/m32` &nbsp; `add r16, r/m16` &nbsp; `add al, imm8` &nbsp; `add eax, imm32` &nbsp; …

**Wirkung:** `dst = dst + src`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addpd – Addition von 2 Doubles

**Syntax:** `addpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] + src[i] (double)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addps – Addition von 4 Singles

**Syntax:** `addps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] + src[i] (single)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addsd – Addition von einem Double

**Syntax:** `addsd xmm, xmm/m64`

**Wirkung:** `dst[0] = dst[0] + src[0] (double); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addss – Addition von einem Single

**Syntax:** `addss xmm, xmm/m32`

**Wirkung:** `dst[0] = dst[0] + src[0] (single); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addsubpd – Abwechselnde Subtraktion und Addition (Doubles)

**Syntax:** `addsubpd xmm, xmm/m128`

**Wirkung:** `even elements: dst[i] = dst[i] - src[i]; odd elements: dst[i] = dst[i] + src[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## addsubps – Abwechselnde Subtraktion und Addition (Singles)

**Syntax:** `addsubps xmm, xmm/m128`

**Wirkung:** `even elements: dst[i] = dst[i] - src[i]; odd elements: dst[i] = dst[i] + src[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## adox – Addition mit Überlauf-Flag, ändert nur OF

**Syntax:** `adox r32, r/m32` &nbsp; `adox r64, r/m64`

**Wirkung:** `dst = dst + src + OF`

**Flags:** OF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aesdec – Eine Entschlüsselungsrunde von AES

**Syntax:** `aesdec xmm, xmm/m128`

**Wirkung:** `dst = inverse AES round of dst with the round key src`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aesdeclast – Die letzte Entschlüsselungsrunde von AES

**Syntax:** `aesdeclast xmm, xmm/m128`

**Wirkung:** `dst = last inverse AES round of dst with the round key src`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aesenc – Eine Verschlüsselungsrunde von AES

**Syntax:** `aesenc xmm, xmm/m128`

**Wirkung:** `dst = AES round of dst with the round key src`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aesenclast – Die letzte Verschlüsselungsrunde von AES

**Syntax:** `aesenclast xmm, xmm/m128`

**Wirkung:** `dst = last AES round of dst with the round key src`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aesimc – Umwandlung eines AES-Rundenschlüssels für die Entschlüsselung

**Syntax:** `aesimc xmm, xmm/m128`

**Wirkung:** `dst = InvMixColumns(src)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## aeskeygenassist – Hilfsbefehl für die AES-Schlüsselerzeugung

**Syntax:** `aeskeygenassist xmm, xmm/m128, imm8`

**Wirkung:** `dst = helper values for the AES key schedule from src (round constant imm8)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## and – Bitweise UND-Verknüpfung

**Syntax:** `and r/m8, r8` &nbsp; `and r/m32, r32` &nbsp; `and r/m16, r16` &nbsp; `and r8, r/m8` &nbsp; `and r32, r/m32` &nbsp; `and r16, r/m16` &nbsp; `and al, imm8` &nbsp; `and eax, imm32` &nbsp; …

**Wirkung:** `dst = dst & src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andnpd – Bitweise Verknüpfung: NICHT Ziel UND Quelle

**Syntax:** `andnpd xmm, xmm/m128`

**Wirkung:** `dst = ~dst & src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andnps – Bitweise Verknüpfung: NICHT Ziel UND Quelle

**Syntax:** `andnps xmm, xmm/m128`

**Wirkung:** `dst = ~dst & src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andpd – Bitweise UND-Verknüpfung

**Syntax:** `andpd xmm, xmm/m128`

**Wirkung:** `dst = dst & src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## andps – Bitweise UND-Verknüpfung

**Syntax:** `andps xmm, xmm/m128`

**Wirkung:** `dst = dst & src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## arpl – Anpassen des Anforderungs-Privilegs

**Syntax:** `arpl r/m16, r16`

Anpassen des Anforderungs-Privilegs (RPL) eines Segmentselektors.

**Wirkung:** `if dst.RPL < src.RPL then { dst.RPL = src.RPL; ZF = 1 } else ZF = 0`

**Flags:** ZF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blendpd – Auswahl von Doubles aus zwei Registern nach einer Maske

**Syntax:** `blendpd xmm, xmm/m128, imm8`

**Wirkung:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blendps – Auswahl von Singles aus zwei Registern nach einer Maske

**Syntax:** `blendps xmm, xmm/m128, imm8`

**Wirkung:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blendvpd – Auswahl von Doubles nach den Vorzeichenbits von xmm0

**Syntax:** `blendvpd xmm, xmm/m128, xmm0`

**Wirkung:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## blendvps – Auswahl von Singles nach den Vorzeichenbits von xmm0

**Syntax:** `blendvps xmm, xmm/m128, xmm0`

**Wirkung:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bound – Prüfung eines Array-Index gegen Grenzen im Speicher

**Syntax:** `bound r32, m` &nbsp; `bound r16, m`

**Wirkung:** `raise #BR if index dst < [m] or dst > [m + size]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bsf – Suche des niedrigsten gesetzten Bits

**Syntax:** `bsf r32, r/m32` &nbsp; `bsf r16, r/m16` &nbsp; `bsf r64, r/m64`

**Wirkung:** `dst = index of the lowest 1 bit of src; ZF = (src = 0), dst undefined then`

**Flags:** ZF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bsr – Suche des höchsten gesetzten Bits

**Syntax:** `bsr r32, r/m32` &nbsp; `bsr r16, r/m16` &nbsp; `bsr r64, r/m64`

**Wirkung:** `dst = index of the highest 1 bit of src; ZF = (src = 0), dst undefined then`

**Flags:** ZF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bswap – Umkehren der Reihenfolge der Bytes

**Syntax:** `bswap r32` &nbsp; `bswap r64`

Umkehren der Reihenfolge der Bytes (Little/Big Endian).

**Wirkung:** `dst = reverse_bytes(dst)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bt – Kopie eines Bits nach CF

**Syntax:** `bt r/m32, r32` &nbsp; `bt r/m16, r16` &nbsp; `bt r/m32, imm8` &nbsp; `bt r/m16, imm8` &nbsp; `bt r/m64, r64` &nbsp; `bt r/m64, imm8`

**Wirkung:** `CF = bit src of dst`

**Flags:** CF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## btc – Kopie eines Bits nach CF und Umkehren des Bits

**Syntax:** `btc r/m32, imm8` &nbsp; `btc r/m16, imm8` &nbsp; `btc r/m32, r32` &nbsp; `btc r/m16, r16` &nbsp; `btc r/m64, imm8` &nbsp; `btc r/m64, r64`

**Wirkung:** `CF = bit src of dst; bit src of dst = not bit`

**Flags:** CF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## btr – Kopie eines Bits nach CF und Löschen des Bits

**Syntax:** `btr r/m32, r32` &nbsp; `btr r/m16, r16` &nbsp; `btr r/m32, imm8` &nbsp; `btr r/m16, imm8` &nbsp; `btr r/m64, r64` &nbsp; `btr r/m64, imm8`

**Wirkung:** `CF = bit src of dst; bit src of dst = 0`

**Flags:** CF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## bts – Kopie eines Bits nach CF und Setzen des Bits

**Syntax:** `bts r/m32, r32` &nbsp; `bts r/m16, r16` &nbsp; `bts r/m32, imm8` &nbsp; `bts r/m16, imm8` &nbsp; `bts r/m64, r64` &nbsp; `bts r/m64, imm8`

**Wirkung:** `CF = bit src of dst; bit src of dst = 1`

**Flags:** CF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## call – Aufruf einer Funktion

**Syntax:** `call rel32` &nbsp; `call rel16` &nbsp; `call r/m32` &nbsp; `call m` &nbsp; `call r/m16` &nbsp; `call r/m64`

Aufruf einer Funktion (die Rücksprungadresse kommt auf den Stack).

**Wirkung:** `push(rip of the next instruction); rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cbw – Vorzeichenerweiterung von al nach ax

**Syntax:** `cbw`

**Wirkung:** `ax = sext(al)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cdq – Vorzeichenerweiterung von eax nach edx:eax

**Syntax:** `cdq`

**Wirkung:** `edx:eax = sext(eax)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cdqe – Vorzeichenerweiterung von eax nach rax

**Syntax:** `cdqe`

**Wirkung:** `rax = sext(eax)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clac – Löschen des AC-Flags (Zugriffsschutz)

**Syntax:** `clac`

**Wirkung:** `EFLAGS.AC = 0`

**Flags:** AC

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clc – Löschen des Carry-Flags

**Syntax:** `clc`

**Wirkung:** `CF = 0`

**Flags:** CF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cld – Löschen des Richtungs-Flags

**Syntax:** `cld`

Löschen des Richtungs-Flags (String-Befehle zählen aufwärts).

**Wirkung:** `DF = 0`

**Flags:** DF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clflush – Leeren einer Cache-Zeile

**Syntax:** `clflush m`

**Wirkung:** `write back and remove the cache line of [m] from all caches`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clflushopt – Leeren einer Cache-Zeile

**Syntax:** `clflushopt m`

Leeren einer Cache-Zeile (schneller, lose geordnet).

**Wirkung:** `write back and remove the cache line of [m] from all caches`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cli – Sperren der Interrupts (IF=0)

**Syntax:** `cli`

**Wirkung:** `IF = 0`

**Flags:** IF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clts – Löschen des Task-Switched-Flags in cr0

**Syntax:** `clts`

**Wirkung:** `CR0.TS = 0 (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## clwb – Zurückschreiben einer Cache-Zeile

**Syntax:** `clwb m`

Zurückschreiben einer Cache-Zeile, ohne sie zu leeren.

**Wirkung:** `write back the cache line of [m], it may stay in the cache`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmc – Umkehren des Carry-Flags

**Syntax:** `cmc`

**Wirkung:** `CF = not CF`

**Flags:** CF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmova – Kopieren nur

**Syntax:** `cmova r32, r/m32` &nbsp; `cmova r16, r/m16` &nbsp; `cmova r64, r/m64`

Kopieren nur, wenn ohne Vorzeichen größer (CF=0 und ZF=0).

**Wirkung:** `if CF = 0 and ZF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovbe – Kopieren nur

**Syntax:** `cmovbe r32, r/m32` &nbsp; `cmovbe r16, r/m16` &nbsp; `cmovbe r64, r/m64`

Kopieren nur, wenn ohne Vorzeichen kleiner oder gleich (CF=1 oder ZF=1).

**Wirkung:** `if CF = 1 or ZF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovc – Kopieren nur

**Syntax:** `cmovc r32, r/m32` &nbsp; `cmovc r16, r/m16` &nbsp; `cmovc r64, r/m64`

Kopieren nur, wenn Übertrag, ohne Vorzeichen kleiner (CF=1).

**Wirkung:** `if CF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovg – Kopieren nur

**Syntax:** `cmovg r32, r/m32` &nbsp; `cmovg r16, r/m16` &nbsp; `cmovg r64, r/m64`

Kopieren nur, wenn mit Vorzeichen größer (ZF=0 und SF=OF).

**Wirkung:** `if ZF = 0 and SF = OF then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovge – Kopieren nur

**Syntax:** `cmovge r32, r/m32` &nbsp; `cmovge r16, r/m16` &nbsp; `cmovge r64, r/m64`

Kopieren nur, wenn mit Vorzeichen größer oder gleich (SF=OF).

**Wirkung:** `if SF = OF then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovl – Kopieren nur, wenn mit Vorzeichen kleiner (SF≠OF)

**Syntax:** `cmovl r32, r/m32` &nbsp; `cmovl r16, r/m16` &nbsp; `cmovl r64, r/m64`

**Wirkung:** `if SF != OF then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovle – Kopieren nur

**Syntax:** `cmovle r32, r/m32` &nbsp; `cmovle r16, r/m16` &nbsp; `cmovle r64, r/m64`

Kopieren nur, wenn mit Vorzeichen kleiner oder gleich (ZF=1 oder SF≠OF).

**Wirkung:** `if ZF = 1 or SF != OF then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovnc – Kopieren nur

**Syntax:** `cmovnc r32, r/m32` &nbsp; `cmovnc r16, r/m16` &nbsp; `cmovnc r64, r/m64`

Kopieren nur, wenn kein Übertrag, ohne Vorzeichen größer oder gleich (CF=0).

**Wirkung:** `if CF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovno – Kopieren nur, wenn kein Überlauf (OF=0)

**Syntax:** `cmovno r32, r/m32` &nbsp; `cmovno r16, r/m16` &nbsp; `cmovno r64, r/m64`

**Wirkung:** `if OF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovnp – Kopieren nur, wenn Parität ungerade (PF=0)

**Syntax:** `cmovnp r32, r/m32` &nbsp; `cmovnp r16, r/m16` &nbsp; `cmovnp r64, r/m64`

**Wirkung:** `if PF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovns – Kopieren nur, wenn nicht negativ (SF=0)

**Syntax:** `cmovns r32, r/m32` &nbsp; `cmovns r16, r/m16` &nbsp; `cmovns r64, r/m64`

**Wirkung:** `if SF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovnz – Kopieren nur

**Syntax:** `cmovnz r32, r/m32` &nbsp; `cmovnz r16, r/m16` &nbsp; `cmovnz r64, r/m64`

Kopieren nur, wenn ungleich, Ergebnis nicht null (ZF=0).

**Wirkung:** `if ZF = 0 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovo – Kopieren nur, wenn Überlauf (OF=1)

**Syntax:** `cmovo r32, r/m32` &nbsp; `cmovo r16, r/m16` &nbsp; `cmovo r64, r/m64`

**Wirkung:** `if OF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovp – Kopieren nur, wenn Parität gerade (PF=1)

**Syntax:** `cmovp r32, r/m32` &nbsp; `cmovp r16, r/m16` &nbsp; `cmovp r64, r/m64`

**Wirkung:** `if PF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovs – Kopieren nur, wenn negativ (SF=1)

**Syntax:** `cmovs r32, r/m32` &nbsp; `cmovs r16, r/m16` &nbsp; `cmovs r64, r/m64`

**Wirkung:** `if SF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmovz – Kopieren nur, wenn gleich, Ergebnis null (ZF=1)

**Syntax:** `cmovz r32, r/m32` &nbsp; `cmovz r16, r/m16` &nbsp; `cmovz r64, r/m64`

**Wirkung:** `if ZF = 1 then dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmp – Vergleich (Ziel minus Quelle)

**Syntax:** `cmp r/m8, r8` &nbsp; `cmp r/m32, r32` &nbsp; `cmp r/m16, r16` &nbsp; `cmp r8, r/m8` &nbsp; `cmp r32, r/m32` &nbsp; `cmp r16, r/m16` &nbsp; `cmp al, imm8` &nbsp; `cmp eax, imm32` &nbsp; …

Vergleich (Ziel minus Quelle), nur die Flags ändern sich.

**Wirkung:** `flags = dst - src (the result is thrown away)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpeqpd – Vergleich von 2 Doubles auf gleich

**Syntax:** `cmpeqpd xmm, xmm/m128`

Vergleich von 2 Doubles auf gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpeqps – Vergleich von 4 Singles auf gleich

**Syntax:** `cmpeqps xmm, xmm/m128`

Vergleich von 4 Singles auf gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpeqsd – Vergleich von einem Double auf gleich

**Syntax:** `cmpeqsd xmm, xmm/m64`

Vergleich von einem Double auf gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpeqss – Vergleich von einem Single auf gleich

**Syntax:** `cmpeqss xmm, xmm/m32`

Vergleich von einem Single auf gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmplepd – Vergleich von 2 Doubles auf kleiner oder gleich

**Syntax:** `cmplepd xmm, xmm/m128`

Vergleich von 2 Doubles auf kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpleps – Vergleich von 4 Singles auf kleiner oder gleich

**Syntax:** `cmpleps xmm, xmm/m128`

Vergleich von 4 Singles auf kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmplesd – Vergleich von einem Double auf kleiner oder gleich

**Syntax:** `cmplesd xmm, xmm/m64`

Vergleich von einem Double auf kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpless – Vergleich von einem Single auf kleiner oder gleich

**Syntax:** `cmpless xmm, xmm/m32`

Vergleich von einem Single auf kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpltpd – Vergleich von 2 Doubles auf kleiner

**Syntax:** `cmpltpd xmm, xmm/m128`

Vergleich von 2 Doubles auf kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpltps – Vergleich von 4 Singles auf kleiner

**Syntax:** `cmpltps xmm, xmm/m128`

Vergleich von 4 Singles auf kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpltsd – Vergleich von einem Double auf kleiner

**Syntax:** `cmpltsd xmm, xmm/m64`

Vergleich von einem Double auf kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpltss – Vergleich von einem Single auf kleiner

**Syntax:** `cmpltss xmm, xmm/m32`

Vergleich von einem Single auf kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpneqpd – Vergleich von 2 Doubles auf ungleich

**Syntax:** `cmpneqpd xmm, xmm/m128`

Vergleich von 2 Doubles auf ungleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpneqps – Vergleich von 4 Singles auf ungleich

**Syntax:** `cmpneqps xmm, xmm/m128`

Vergleich von 4 Singles auf ungleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpneqsd – Vergleich von einem Double auf ungleich

**Syntax:** `cmpneqsd xmm, xmm/m64`

Vergleich von einem Double auf ungleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpneqss – Vergleich von einem Single auf ungleich

**Syntax:** `cmpneqss xmm, xmm/m32`

Vergleich von einem Single auf ungleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnlepd – Vergleich von 2 Doubles auf nicht kleiner oder gleich

**Syntax:** `cmpnlepd xmm, xmm/m128`

Vergleich von 2 Doubles auf nicht kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnleps – Vergleich von 4 Singles auf nicht kleiner oder gleich

**Syntax:** `cmpnleps xmm, xmm/m128`

Vergleich von 4 Singles auf nicht kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnlesd – Vergleich von einem Double auf nicht kleiner oder gleich

**Syntax:** `cmpnlesd xmm, xmm/m64`

Vergleich von einem Double auf nicht kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnless – Vergleich von einem Single auf nicht kleiner oder gleich

**Syntax:** `cmpnless xmm, xmm/m32`

Vergleich von einem Single auf nicht kleiner oder gleich, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnltpd – Vergleich von 2 Doubles auf nicht kleiner

**Syntax:** `cmpnltpd xmm, xmm/m128`

Vergleich von 2 Doubles auf nicht kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnltps – Vergleich von 4 Singles auf nicht kleiner

**Syntax:** `cmpnltps xmm, xmm/m128`

Vergleich von 4 Singles auf nicht kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnltsd – Vergleich von einem Double auf nicht kleiner

**Syntax:** `cmpnltsd xmm, xmm/m64`

Vergleich von einem Double auf nicht kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpnltss – Vergleich von einem Single auf nicht kleiner

**Syntax:** `cmpnltss xmm, xmm/m32`

Vergleich von einem Single auf nicht kleiner, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpordpd – Vergleich von 2 Doubles auf geordnet

**Syntax:** `cmpordpd xmm, xmm/m128`

Vergleich von 2 Doubles auf geordnet (kein NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpordps – Vergleich von 4 Singles auf geordnet

**Syntax:** `cmpordps xmm, xmm/m128`

Vergleich von 4 Singles auf geordnet (kein NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpordsd – Vergleich von einem Double auf geordnet

**Syntax:** `cmpordsd xmm, xmm/m64`

Vergleich von einem Double auf geordnet (kein NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpordss – Vergleich von einem Single auf geordnet

**Syntax:** `cmpordss xmm, xmm/m32`

Vergleich von einem Single auf geordnet (kein NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmppd – Vergleich von 2 Doubles mit einer Bedingung

**Syntax:** `cmppd xmm, xmm/m128, imm8`

Vergleich von 2 Doubles mit einer Bedingung, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpps – Vergleich von 4 Singles mit einer Bedingung

**Syntax:** `cmpps xmm, xmm/m128, imm8`

Vergleich von 4 Singles mit einer Bedingung, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpsb – Vergleich von [rsi] mit [rdi]

**Syntax:** `cmpsb`

Vergleich von [rsi] mit [rdi], rsi und rdi laufen weiter.

**Wirkung:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpsd – Vergleich eines Doubles

**Syntax:** `cmpsd` &nbsp; `cmpsd xmm, xmm/m64, imm8`

Vergleich eines Doubles (xmm) mit einer Bedingung; ohne Operanden: String-Vergleich.

**Wirkung:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpsq – Vergleich von [rsi] mit [rdi]

**Syntax:** `cmpsq`

Vergleich von [rsi] mit [rdi], rsi und rdi laufen weiter.

**Wirkung:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpss – Vergleich eines Singles mit einer Bedingung

**Syntax:** `cmpss xmm, xmm/m32, imm8`

Vergleich eines Singles mit einer Bedingung, Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpsw – Vergleich von [rsi] mit [rdi]

**Syntax:** `cmpsw`

Vergleich von [rsi] mit [rdi], rsi und rdi laufen weiter.

**Wirkung:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpunordpd – Vergleich von 2 Doubles auf ungeordnet

**Syntax:** `cmpunordpd xmm, xmm/m128`

Vergleich von 2 Doubles auf ungeordnet (NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpunordps – Vergleich von 4 Singles auf ungeordnet

**Syntax:** `cmpunordps xmm, xmm/m128`

Vergleich von 4 Singles auf ungeordnet (NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpunordsd – Vergleich von einem Double auf ungeordnet

**Syntax:** `cmpunordsd xmm, xmm/m64`

Vergleich von einem Double auf ungeordnet (NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpunordss – Vergleich von einem Single auf ungeordnet

**Syntax:** `cmpunordss xmm, xmm/m32`

Vergleich von einem Single auf ungeordnet (NaN), Ergebnis ist eine Maske.

**Wirkung:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpxchg – Vergleichen und Tauschen bei Gleichheit

**Syntax:** `cmpxchg r/m8, r8` &nbsp; `cmpxchg r/m32, r32` &nbsp; `cmpxchg r/m16, r16` &nbsp; `cmpxchg r/m64, r64`

Vergleichen und Tauschen bei Gleichheit (atomar mit lock).

**Wirkung:** `if rax == dst then { ZF = 1; dst = src } else { ZF = 0; rax = dst }`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpxchg16b – Vergleichen und Tauschen von 16 Bytes

**Syntax:** `cmpxchg16b m`

Vergleichen und Tauschen von 16 Bytes (rdx:rax, rcx:rbx).

**Wirkung:** `if rdx:rax == [m] then { ZF = 1; [m] = rcx:rbx } else { ZF = 0; rdx:rax = [m] }`

**Flags:** ZF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cmpxchg8b – Vergleichen und Tauschen von 8 Bytes

**Syntax:** `cmpxchg8b m`

Vergleichen und Tauschen von 8 Bytes (edx:eax, ecx:ebx).

**Wirkung:** `if edx:eax == [m] then { ZF = 1; [m] = ecx:ebx } else { ZF = 0; edx:eax = [m] }`

**Flags:** ZF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## comisd – Vergleich zweier Doubles, setzt ZF, PF, CF

**Syntax:** `comisd xmm, xmm/m64`

**Wirkung:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## comiss – Vergleich zweier Singles, setzt ZF, PF, CF

**Syntax:** `comiss xmm, xmm/m32`

**Wirkung:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cpuid – Auskunft über den Prozessor

**Syntax:** `cpuid`

**Wirkung:** `eax, ebx, ecx, edx = information about the processor for the function in eax (and ecx)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cqo – Vorzeichenerweiterung von rax nach rdx:rax

**Syntax:** `cqo`

**Wirkung:** `rdx:rax = sext(rax)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## crc32 – Berechnung einer CRC-32C-Prüfsumme (Castagnoli)

**Syntax:** `crc32 r32, r/m8` &nbsp; `crc32 r32, r/m32` &nbsp; `crc32 r64, r/m8` &nbsp; `crc32 r64, r/m64`

**Wirkung:** `dst = crc32c(dst, src)`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtdq2pd – Umwandlung von 2 Ganzzahlen (32 Bit) in Doubles

**Syntax:** `cvtdq2pd xmm, xmm/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from int32 to double`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtdq2ps – Umwandlung von 4 Ganzzahlen (32 Bit) in Singles

**Syntax:** `cvtdq2ps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from int32 to single`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtpd2dq – Umwandlung von 2 Doubles in Ganzzahlen (gerundet)

**Syntax:** `cvtpd2dq xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from double to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtpd2pi – Umwandlung von 2 Doubles in Ganzzahlen

**Syntax:** `cvtpd2pi mm, xmm/m64`

Umwandlung von 2 Doubles in Ganzzahlen (mm, gerundet).

**Wirkung:** `for every element: dst[i] = convert(src[i]) from double to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtpd2ps – Umwandlung von 2 Doubles in Singles

**Syntax:** `cvtpd2ps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from double to single`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtpi2pd – Umwandlung von 2 Ganzzahlen (mm) in Doubles

**Syntax:** `cvtpi2pd xmm, mm/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from int32 to double`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtpi2ps – Umwandlung von 2 Ganzzahlen (mm) in Singles

**Syntax:** `cvtpi2ps xmm, mm/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from int32 to single`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtps2dq – Umwandlung von 4 Singles in Ganzzahlen (gerundet)

**Syntax:** `cvtps2dq xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from single to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtps2pd – Umwandlung von 2 Singles in Doubles

**Syntax:** `cvtps2pd xmm, xmm/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from single to double`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtps2pi – Umwandlung von 2 Singles in Ganzzahlen

**Syntax:** `cvtps2pi mm, xmm/m64`

Umwandlung von 2 Singles in Ganzzahlen (mm, gerundet).

**Wirkung:** `for every element: dst[i] = convert(src[i]) from single to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtsd2si – Umwandlung eines Doubles in eine Ganzzahl

**Syntax:** `cvtsd2si r32, xmm/m128` &nbsp; `cvtsd2si r64, xmm/m128`

Umwandlung eines Doubles in eine Ganzzahl (gerundet).

**Wirkung:** `for every element: dst[i] = convert(src[i]) from double to integer`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtsd2ss – Umwandlung eines Doubles in einen Single

**Syntax:** `cvtsd2ss xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from double to single`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtsi2sd – Umwandlung einer Ganzzahl in einen Double

**Syntax:** `cvtsi2sd xmm, r/m32` &nbsp; `cvtsi2sd xmm, r/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from integer to double`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtsi2ss – Umwandlung einer Ganzzahl in einen Single

**Syntax:** `cvtsi2ss xmm, r/m32` &nbsp; `cvtsi2ss xmm, r/m64`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from integer to single`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtss2sd – Umwandlung eines Singles in einen Double

**Syntax:** `cvtss2sd xmm, xmm/m32`

**Wirkung:** `for every element: dst[i] = convert(src[i]) from single to double`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvtss2si – Umwandlung eines Singles in eine Ganzzahl

**Syntax:** `cvtss2si r32, xmm/m32` &nbsp; `cvtss2si r64, xmm/m32`

Umwandlung eines Singles in eine Ganzzahl (gerundet).

**Wirkung:** `for every element: dst[i] = convert(src[i]) from single to integer`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttpd2dq – Umwandlung von 2 Doubles in Ganzzahlen

**Syntax:** `cvttpd2dq xmm, xmm/m128`

Umwandlung von 2 Doubles in Ganzzahlen (abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from double to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttpd2pi – Umwandlung von 2 Doubles in Ganzzahlen

**Syntax:** `cvttpd2pi mm, xmm/m64`

Umwandlung von 2 Doubles in Ganzzahlen (mm, abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from double to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttps2dq – Umwandlung von 4 Singles in Ganzzahlen

**Syntax:** `cvttps2dq xmm, xmm/m128`

Umwandlung von 4 Singles in Ganzzahlen (abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from single to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttps2pi – Umwandlung von 2 Singles in Ganzzahlen

**Syntax:** `cvttps2pi mm, xmm/m64`

Umwandlung von 2 Singles in Ganzzahlen (mm, abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from single to int32`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttsd2si – Umwandlung eines Doubles in eine Ganzzahl

**Syntax:** `cvttsd2si r32, xmm/m128` &nbsp; `cvttsd2si r64, xmm/m128`

Umwandlung eines Doubles in eine Ganzzahl (abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from double to integer`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cvttss2si – Umwandlung eines Singles in eine Ganzzahl

**Syntax:** `cvttss2si r32, xmm/m32` &nbsp; `cvttss2si r64, xmm/m32`

Umwandlung eines Singles in eine Ganzzahl (abgeschnitten).

**Wirkung:** `for every element: dst[i] = truncate(src[i]) from single to integer`

*Gruppe: Umwandlungen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cwd – Vorzeichenerweiterung von ax nach dx:ax

**Syntax:** `cwd`

**Wirkung:** `dx:ax = sext(ax)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## cwde – Vorzeichenerweiterung von ax nach eax

**Syntax:** `cwde`

**Wirkung:** `eax = sext(ax)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## daa – Dezimalkorrektur nach einer Addition

**Syntax:** `daa`

Dezimalkorrektur nach einer Addition (gepackte BCD-Zahlen).

**Wirkung:** `if (al & 15) > 9 or AF = 1 then al = al + 6; if al > 99h or CF = 1 then al = al + 60h`

**Flags:** SF ZF AF CF PF &nbsp; undefiniert: OF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## das – Dezimalkorrektur nach einer Subtraktion

**Syntax:** `das`

Dezimalkorrektur nach einer Subtraktion (gepackte BCD-Zahlen).

**Wirkung:** `if (al & 15) > 9 or AF = 1 then al = al - 6; if al > 99h or CF = 1 then al = al - 60h`

**Flags:** SF ZF AF CF PF &nbsp; undefiniert: OF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dec – Verringerung um 1 (CF bleibt)

**Syntax:** `dec r/m8` &nbsp; `dec r/m32` &nbsp; `dec r/m16` &nbsp; `dec r/m64`

**Wirkung:** `dst = dst - 1`

**Flags:** OF SF ZF AF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## div – Division ohne Vorzeichen

**Syntax:** `div ax, r/m8` &nbsp; `div eax, r/m32` &nbsp; `div ax, r/m16` &nbsp; `div r/m8` &nbsp; `div r/m32` &nbsp; `div r/m16` &nbsp; `div r/m64`

Division ohne Vorzeichen: edx:eax durch den Operanden, Quotient nach eax, Rest nach edx.

**Wirkung:** `rax = rdx:rax / src; rdx = rdx:rax % src (8 bit: al = ax / src; ah = ax % src); #DE if src = 0 or quotient too big (unsigned)`

**Flags:** – &nbsp; undefiniert: OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divpd – Division von 2 Doubles

**Syntax:** `divpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] / src[i] (double)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divps – Division von 4 Singles

**Syntax:** `divps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] / src[i] (single)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divsd – Division von einem Double

**Syntax:** `divsd xmm, xmm/m64`

**Wirkung:** `dst[0] = dst[0] / src[0] (double); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## divss – Division von einem Single

**Syntax:** `divss xmm, xmm/m32`

**Wirkung:** `dst[0] = dst[0] / src[0] (single); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dppd – Skalarprodukt von Doubles

**Syntax:** `dppd xmm, xmm/m128, imm8`

**Wirkung:** `dst[i] = sum of dst[j] * src[j] for the elements chosen by imm8 (high bits), written to the elements chosen by imm8 (low bits)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## dpps – Skalarprodukt von Singles

**Syntax:** `dpps xmm, xmm/m128, imm8`

**Wirkung:** `dst[i] = sum of dst[j] * src[j] for the elements chosen by imm8 (high bits), written to the elements chosen by imm8 (low bits)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## emms – Beenden von MMX und Freigabe der x87-Register

**Syntax:** `emms`

**Wirkung:** `mark all x87 registers as empty (after MMX)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## endbr32 – Markierung eines gültigen Sprungziels

**Syntax:** `endbr32`

Markierung eines gültigen Sprungziels (Kontrollfluss-Schutz).

**Wirkung:** `marks a valid target of an indirect jump (no change)`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## endbr64 – Markierung eines gültigen Sprungziels

**Syntax:** `endbr64`

Markierung eines gültigen Sprungziels (Kontrollfluss-Schutz).

**Wirkung:** `marks a valid target of an indirect jump (no change)`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## enter – Aufbau eines Stackrahmens (selten, meist push/mov)

**Syntax:** `enter imm16, imm8`

**Wirkung:** `push(rbp); rbp = rsp; rsp = rsp - size (nesting level 0)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## extractps – Herausholen eines Singles aus xmm in ein Register oder Speicher

**Syntax:** `extractps r/m32, xmm, imm8`

**Wirkung:** `dst = one single of src, chosen by imm8`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## f2xm1 – 2 hoch st0 minus 1

**Syntax:** `f2xm1`

**Wirkung:** `st0 = 2 ^ st0 - 1`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fabs – Betrag von st0

**Syntax:** `fabs`

**Wirkung:** `st0 = abs(st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fadd – Addition (st0 = st0 + Operand)

**Syntax:** `fadd m32` &nbsp; `fadd st0, st(i)` &nbsp; `fadd m64` &nbsp; `fadd st(i), st0`

**Wirkung:** `st0 = st0 + src (or st(i) = st(i) + st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## faddp – Addition mit Entfernen vom Stack

**Syntax:** `faddp st(i), st0`

**Wirkung:** `st(i) = st(i) + st0; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fbld – Laden einer gepackten Dezimalzahl (BCD)

**Syntax:** `fbld m80`

**Wirkung:** `push: st0 = packed decimal src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fbstp – Speichern von st0 als gepackte Dezimalzahl und Entfernen

**Syntax:** `fbstp m80`

**Wirkung:** `dst = st0 as packed decimal; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fchs – Vorzeichenwechsel von st0

**Syntax:** `fchs`

**Wirkung:** `st0 = -st0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovb – Kopieren von st(i) nach st0, wenn CF=1

**Syntax:** `fcmovb st0, st(i)`

**Wirkung:** `if CF = 1 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovbe – Kopieren von st(i) nach st0, wenn CF=1 oder ZF=1

**Syntax:** `fcmovbe st0, st(i)`

**Wirkung:** `if CF = 1 or ZF = 1 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmove – Kopieren von st(i) nach st0, wenn ZF=1

**Syntax:** `fcmove st0, st(i)`

**Wirkung:** `if ZF = 1 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovnb – Kopieren von st(i) nach st0, wenn CF=0

**Syntax:** `fcmovnb st0, st(i)`

**Wirkung:** `if CF = 0 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovnbe – Kopieren von st(i) nach st0, wenn CF=0 und ZF=0

**Syntax:** `fcmovnbe st0, st(i)`

**Wirkung:** `if CF = 0 and ZF = 0 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovne – Kopieren von st(i) nach st0, wenn ZF=0

**Syntax:** `fcmovne st0, st(i)`

**Wirkung:** `if ZF = 0 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovnu – Kopieren von st(i) nach st0, wenn PF=0

**Syntax:** `fcmovnu st0, st(i)`

**Wirkung:** `if PF = 0 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcmovu – Kopieren von st(i) nach st0, wenn PF=1

**Syntax:** `fcmovu st0, st(i)`

**Wirkung:** `if PF = 1 then st0 = st(i)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcom – Vergleich von st0 mit einem Operanden (Statuswort)

**Syntax:** `fcom st(i)/m32` &nbsp; `fcom m64`

**Wirkung:** `status word C3 C2 C0 = compare(st0, src)`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcomi – Vergleich mit direkter Wirkung auf ZF, PF, CF

**Syntax:** `fcomi st0, st(i)`

**Wirkung:** `ZF PF CF = compare(st0, st(i))`

**Flags:** ZF CF PF

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcomip – Vergleich mit ZF, PF, CF und Entfernen von st0

**Syntax:** `fcomip st0, st(i)`

**Wirkung:** `ZF PF CF = compare(st0, st(i)); pop`

**Flags:** ZF CF PF

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcomp – Vergleich mit Entfernen von st0 vom Stack

**Syntax:** `fcomp st(i)/m32` &nbsp; `fcomp m64`

**Wirkung:** `status word C3 C2 C0 = compare(st0, src); pop`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcompp – Vergleich von st0 mit st1 und Entfernen beider

**Syntax:** `fcompp`

**Wirkung:** `status word C3 C2 C0 = compare(st0, st1); pop twice`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fcos – Kosinus von st0

**Syntax:** `fcos`

**Wirkung:** `st0 = cos(st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdecstp – Verringerung des x87-Stackzeigers

**Syntax:** `fdecstp`

**Wirkung:** `top of the x87 stack = top - 1`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdiv – Division

**Syntax:** `fdiv m32` &nbsp; `fdiv st0, st(i)` &nbsp; `fdiv m64` &nbsp; `fdiv st(i), st0`

**Wirkung:** `st0 = st0 / src (or st(i) = st(i) / st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdivp – Division mit Entfernen vom Stack

**Syntax:** `fdivp st(i), st0`

**Wirkung:** `st(i) = st(i) / st0; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdivr – Division in umgekehrter Reihenfolge

**Syntax:** `fdivr m32` &nbsp; `fdivr st0, st(i)` &nbsp; `fdivr st(i), st0` &nbsp; `fdivr m64`

**Wirkung:** `st0 = src / st0 (or st(i) = st0 / st(i))`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fdivrp – Umgekehrte Division mit Entfernen vom Stack

**Syntax:** `fdivrp st(i), st0`

**Wirkung:** `st(i) = st0 / st(i); pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ffree – Freigabe eines x87-Registers

**Syntax:** `ffree st(i)`

**Wirkung:** `mark st(i) as empty`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fiadd – Addition einer Ganzzahl aus dem Speicher

**Syntax:** `fiadd m32` &nbsp; `fiadd m16`

**Wirkung:** `st0 = st0 + (float) integer src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ficom – Vergleich von st0 mit einer Ganzzahl

**Syntax:** `ficom m32` &nbsp; `ficom m16`

**Wirkung:** `status word C3 C2 C0 = compare(st0, integer src)`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ficomp – Vergleich mit einer Ganzzahl und Entfernen von st0

**Syntax:** `ficomp m32` &nbsp; `ficomp m16`

**Wirkung:** `status word C3 C2 C0 = compare(st0, integer src); pop`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fidiv – Division durch eine Ganzzahl aus dem Speicher

**Syntax:** `fidiv m32` &nbsp; `fidiv m16`

**Wirkung:** `st0 = st0 / (float) integer src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fidivr – Division einer Ganzzahl durch st0 (umgekehrt)

**Syntax:** `fidivr m32` &nbsp; `fidivr m16`

**Wirkung:** `st0 = (float) integer src / st0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fild – Laden einer Ganzzahl auf den x87-Stack

**Syntax:** `fild m32` &nbsp; `fild m16` &nbsp; `fild m64`

**Wirkung:** `push: st0 = (float) integer src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fimul – Multiplikation mit einer Ganzzahl aus dem Speicher

**Syntax:** `fimul m32` &nbsp; `fimul m16`

**Wirkung:** `st0 = st0 * (float) integer src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fincstp – Erhöhung des x87-Stackzeigers

**Syntax:** `fincstp`

**Wirkung:** `top of the x87 stack = top + 1`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fist – Speichern von st0 als Ganzzahl (gerundet)

**Syntax:** `fist m32` &nbsp; `fist m16`

**Wirkung:** `dst = (integer) st0, rounded`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fistp – Speichern von st0 als Ganzzahl und Entfernen

**Syntax:** `fistp m32` &nbsp; `fistp m16` &nbsp; `fistp m64`

**Wirkung:** `dst = (integer) st0, rounded; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fisttp – Speichern von st0 als Ganzzahl

**Syntax:** `fisttp m32` &nbsp; `fisttp m64` &nbsp; `fisttp m16`

Speichern von st0 als Ganzzahl (abgeschnitten) und Entfernen.

**Wirkung:** `dst = (integer) st0, truncated; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fisub – Subtraktion einer Ganzzahl aus dem Speicher

**Syntax:** `fisub m32` &nbsp; `fisub m16`

**Wirkung:** `st0 = st0 - (float) integer src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fisubr – Umgekehrte Subtraktion einer Ganzzahl aus dem Speicher

**Syntax:** `fisubr m32` &nbsp; `fisubr m16`

**Wirkung:** `st0 = (float) integer src - st0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fld – Laden eines Wertes auf den x87-Stack

**Syntax:** `fld st(i)/m32` &nbsp; `fld m80` &nbsp; `fld m64`

**Wirkung:** `push: st0 = src`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fld1 – Laden der Konstante 1.0

**Syntax:** `fld1`

**Wirkung:** `push: st0 = 1.0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldcw – Laden des x87-Steuerworts

**Syntax:** `fldcw m16`

**Wirkung:** `x87 control word = [m16]`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldenv – Laden der x87-Umgebung

**Syntax:** `fldenv m`

**Wirkung:** `x87 environment = [m]`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldl2e – Laden von log2(e)

**Syntax:** `fldl2e`

**Wirkung:** `push: st0 = log2(e)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldl2t – Laden von log2(10)

**Syntax:** `fldl2t`

**Wirkung:** `push: st0 = log2(10)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldlg2 – Laden von log10(2)

**Syntax:** `fldlg2`

**Wirkung:** `push: st0 = log10(2)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldln2 – Laden von ln(2)

**Syntax:** `fldln2`

**Wirkung:** `push: st0 = ln(2)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldpi – Laden der Konstante π

**Syntax:** `fldpi`

**Wirkung:** `push: st0 = pi`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fldz – Laden der Konstante 0.0

**Syntax:** `fldz`

**Wirkung:** `push: st0 = 0.0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmul – Multiplikation

**Syntax:** `fmul m32` &nbsp; `fmul st0, st(i)` &nbsp; `fmul m64` &nbsp; `fmul st(i), st0`

**Wirkung:** `st0 = st0 * src (or st(i) = st(i) * st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fmulp – Multiplikation mit Entfernen vom Stack

**Syntax:** `fmulp st(i), st0`

**Wirkung:** `st(i) = st(i) * st0; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnclex – Löschen der x87-Ausnahmen

**Syntax:** `fnclex`

**Wirkung:** `clear the x87 exception flags`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fninit – Zurücksetzen der x87-Einheit

**Syntax:** `fninit`

**Wirkung:** `reset the x87 unit`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnop – Keine Operation (x87)

**Syntax:** `fnop`

**Wirkung:** `no operation`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnsave – Speichern des ganzen x87-Zustands

**Syntax:** `fnsave m`

**Wirkung:** `[m] = whole x87 state; then reset the unit`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnstcw – Speichern des x87-Steuerworts

**Syntax:** `fnstcw m16`

**Wirkung:** `[m16] = x87 control word`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnstenv – Speichern der x87-Umgebung

**Syntax:** `fnstenv m`

**Wirkung:** `[m] = x87 environment`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fnstsw – Speichern des x87-Statusworts

**Syntax:** `fnstsw m16` &nbsp; `fnstsw ax`

**Wirkung:** `dst = x87 status word`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fpatan – Arkustangens von st1/st0

**Syntax:** `fpatan`

**Wirkung:** `st1 = atan(st1 / st0); pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fprem – Rest einer Division (teilweise)

**Syntax:** `fprem`

**Wirkung:** `st0 = st0 mod st1 (truncating quotient, partial)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fprem1 – IEEE-Rest einer Division

**Syntax:** `fprem1`

**Wirkung:** `st0 = IEEE remainder of st0 / st1 (partial)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fptan – Tangens von st0

**Syntax:** `fptan`

**Wirkung:** `st0 = tan(st0); push: st0 = 1.0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frndint – Runden von st0 auf eine ganze Zahl

**Syntax:** `frndint`

**Wirkung:** `st0 = round(st0) to an integer value`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## frstor – Wiederherstellen des ganzen x87-Zustands

**Syntax:** `frstor m`

**Wirkung:** `whole x87 state = [m]`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fscale – Multiplikation von st0 mit 2 hoch st1

**Syntax:** `fscale`

**Wirkung:** `st0 = st0 * 2 ^ trunc(st1)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsin – Sinus von st0

**Syntax:** `fsin`

**Wirkung:** `st0 = sin(st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsincos – Sinus und Kosinus von st0

**Syntax:** `fsincos`

**Wirkung:** `st0 = sin(st0); push: st0 = cos`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsqrt – Quadratwurzel von st0

**Syntax:** `fsqrt`

**Wirkung:** `st0 = sqrt(st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fst – Speichern von st0 (ohne Entfernen)

**Syntax:** `fst m32` &nbsp; `fst st(i)/m64`

**Wirkung:** `dst = st0`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fstp – Speichern von st0 und Entfernen vom Stack

**Syntax:** `fstp m32` &nbsp; `fstp m80` &nbsp; `fstp st(i)/m64`

**Wirkung:** `dst = st0; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsub – Subtraktion

**Syntax:** `fsub m32` &nbsp; `fsub st0, st(i)` &nbsp; `fsub m64` &nbsp; `fsub st(i), st0`

**Wirkung:** `st0 = st0 - src (or st(i) = st(i) - st0)`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsubp – Subtraktion mit Entfernen vom Stack

**Syntax:** `fsubp st(i), st0`

**Wirkung:** `st(i) = st(i) - st0; pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsubr – Subtraktion in umgekehrter Reihenfolge

**Syntax:** `fsubr m32` &nbsp; `fsubr st0, st(i)` &nbsp; `fsubr st(i), st0` &nbsp; `fsubr m64`

**Wirkung:** `st0 = src - st0 (or st(i) = st0 - st(i))`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fsubrp – Umgekehrte Subtraktion mit Entfernen vom Stack

**Syntax:** `fsubrp st(i), st0`

**Wirkung:** `st(i) = st0 - st(i); pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ftst – Vergleich von st0 mit 0.0

**Syntax:** `ftst`

**Wirkung:** `status word C3 C2 C0 = compare(st0, 0.0)`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fucom – Ungeordneter Vergleich (kein Fehler bei NaN)

**Syntax:** `fucom st(i)`

**Wirkung:** `status word C3 C2 C0 = compare(st0, src)`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fucomi – Ungeordneter Vergleich, setzt ZF, PF, CF

**Syntax:** `fucomi st0, st(i)`

**Wirkung:** `ZF PF CF = compare(st0, st(i))`

**Flags:** ZF CF PF

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fucomip – Ungeordneter Vergleich

**Syntax:** `fucomip st0, st(i)`

Ungeordneter Vergleich, setzt ZF, PF, CF, mit Entfernen von st0.

**Wirkung:** `ZF PF CF = compare(st0, st(i)); pop`

**Flags:** ZF CF PF

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fucomp – Ungeordneter Vergleich mit Entfernen von st0

**Syntax:** `fucomp st(i)`

**Wirkung:** `status word C3 C2 C0 = compare(st0, src); pop`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fucompp – Ungeordneter Vergleich von st0

**Syntax:** `fucompp`

Ungeordneter Vergleich von st0, st1 mit Entfernen beider.

**Wirkung:** `status word C3 C2 C0 = compare(st0, st1); pop twice`

**Flags:** C0 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fwait – Warten auf die x87-Einheit

**Syntax:** `fwait`

**Wirkung:** `wait until the x87 unit is done and report its errors`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxam – Feststellen der Art von st0 (Zahl, NaN, ...)

**Syntax:** `fxam`

**Wirkung:** `status word C3 C2 C1 C0 = kind of st0 (number, zero, infinity, NaN, ...)`

**Flags:** C0 C1 C2 C3

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxch – Vertauschen von st0 mit einem anderen Register

**Syntax:** `fxch st(i)`

**Wirkung:** `swap(st0, st(i))`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxrstor – Wiederherstellen des x87-, MMX- und SSE-Zustands

**Syntax:** `fxrstor m`

**Wirkung:** `x87, MMX and SSE state = [m]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxrstor64 – Wiederherstellen des x87-, MMX- und SSE-Zustands

**Syntax:** `fxrstor64 m`

**Wirkung:** `x87, MMX and SSE state = [m]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxsave – Sichern des x87-, MMX- und SSE-Zustands

**Syntax:** `fxsave m`

**Wirkung:** `[m] = x87, MMX and SSE state (512 bytes)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxsave64 – Sichern des x87-, MMX- und SSE-Zustands

**Syntax:** `fxsave64 m`

**Wirkung:** `[m] = x87, MMX and SSE state (512 bytes)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fxtract – Zerlegung von st0 in Exponent und Mantisse

**Syntax:** `fxtract`

**Wirkung:** `st0 = exponent of st0; push: st0 = significand`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fyl2x – st1 mal log2(st0)

**Syntax:** `fyl2x`

**Wirkung:** `st1 = st1 * log2(st0); pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## fyl2xp1 – st1 mal log2(st0 + 1)

**Syntax:** `fyl2xp1`

**Wirkung:** `st1 = st1 * log2(st0 + 1); pop`

*Gruppe: Gleitkomma (x87). Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## getsec – Befehle der Sicherheitserweiterung (Intel TXT)

**Syntax:** `getsec`

**Wirkung:** `run the safer-mode function selected by eax (Intel TXT)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## haddpd – Addition benachbarter Doubles (horizontal)

**Syntax:** `haddpd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] + dst[1], dst[2] + dst[3], src[0] + src[1], src[2] + src[3])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## haddps – Addition benachbarter Singles (horizontal)

**Syntax:** `haddps xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] + dst[1], dst[2] + dst[3], src[0] + src[1], src[2] + src[3])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hlt – Anhalten des Prozessors

**Syntax:** `hlt`

Anhalten des Prozessors (bis zum nächsten Interrupt).

**Wirkung:** `stop until the next interrupt (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hsubpd – Subtraktion benachbarter Doubles (horizontal)

**Syntax:** `hsubpd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] - dst[1], dst[2] - dst[3], src[0] - src[1], src[2] - src[3])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## hsubps – Subtraktion benachbarter Singles (horizontal)

**Syntax:** `hsubps xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] - dst[1], dst[2] - dst[3], src[0] - src[1], src[2] - src[3])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## idiv – Division mit Vorzeichen

**Syntax:** `idiv ax, r/m8` &nbsp; `idiv eax, r/m32` &nbsp; `idiv ax, r/m16` &nbsp; `idiv r/m8` &nbsp; `idiv r/m32` &nbsp; `idiv r/m16` &nbsp; `idiv r/m64`

Division mit Vorzeichen: edx:eax durch den Operanden, Quotient nach eax, Rest nach edx.

**Wirkung:** `rax = rdx:rax / src; rdx = rdx:rax % src (8 bit: al = ax / src; ah = ax % src); #DE if src = 0 or quotient too big (signed)`

**Flags:** – &nbsp; undefiniert: OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## imul – Multiplikation mit Vorzeichen

**Syntax:** `imul r32, r/m32, imm32` &nbsp; `imul r16, r/m16, imm16` &nbsp; `imul r32, r/m32, imm8` &nbsp; `imul r16, r/m16, imm8` &nbsp; `imul r/m8` &nbsp; `imul r/m32` &nbsp; `imul r16` &nbsp; `imul r32, r/m32` &nbsp; …

Multiplikation mit Vorzeichen (ein, zwei oder drei Operanden).

**Wirkung:** `1 operand: rdx:rax = rax * src (signed); 2: dst = dst * src; 3: dst = src * imm`

**Flags:** OF CF &nbsp; undefiniert: SF ZF AF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## in – Lesen eines Wertes von einem Ein-/Ausgabeport

**Syntax:** `in al, imm8` &nbsp; `in eax, imm8` &nbsp; `in ax, imm8` &nbsp; `in al, dx` &nbsp; `in eax, dx` &nbsp; `in ax, dx`

**Wirkung:** `dst = port[src]`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## inc – Erhöhung um 1 (CF bleibt)

**Syntax:** `inc r/m8` &nbsp; `inc r/m32` &nbsp; `inc r/m16` &nbsp; `inc r/m64`

**Wirkung:** `dst = dst + 1`

**Flags:** OF SF ZF AF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## insb – Lesen eines Ports nach [rdi], rdi läuft weiter

**Syntax:** `insb`

**Wirkung:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## insd – Lesen eines Ports nach [rdi], rdi läuft weiter

**Syntax:** `insd`

**Wirkung:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## insertps – Einfügen eines Singles in xmm

**Syntax:** `insertps xmm, xmm/m32, imm8`

**Wirkung:** `dst = dst with one single replaced by one of src (and zeroed ones), chosen by imm8`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## insw – Lesen eines Ports nach [rdi], rdi läuft weiter

**Syntax:** `insw`

**Wirkung:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## int – Auslösen eines Software-Interrupts

**Syntax:** `int imm8`

**Wirkung:** `push(flags, cs, rip); jump to the handler of vector imm8`

**Flags:** IF TF

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## int1 – Auslösen des Debug-Interrupts 1

**Syntax:** `int1`

**Wirkung:** `interrupt 1 (debug exception)`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## int3 – Haltepunkt (Interrupt 3, ein Byte)

**Syntax:** `int3`

**Wirkung:** `interrupt 3 (breakpoint)`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## into – Interrupt 4, wenn OF=1

**Syntax:** `into`

**Wirkung:** `if OF = 1 then interrupt 4`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## invd – Leeren der Caches ohne Zurückschreiben

**Syntax:** `invd`

Leeren der Caches ohne Zurückschreiben (privilegiert).

**Wirkung:** `empty the caches without writing back (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## invlpg – Entwerten eines Eintrags des Adressübersetzungspuffers

**Syntax:** `invlpg m`

Entwerten eines Eintrags des Adressübersetzungspuffers (TLB).

**Wirkung:** `remove the translation of the page of [m] from the TLB (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## iretd – Rückkehr aus einem Interrupt (32 Bit)

**Syntax:** `iretd`

**Wirkung:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## iretq – Rückkehr aus einem Interrupt (64 Bit)

**Syntax:** `iretq`

**Wirkung:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## iretw – Rückkehr aus einem Interrupt (16 Bit)

**Syntax:** `iretw`

**Wirkung:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ja – Sprung, wenn ohne Vorzeichen größer

**Syntax:** `ja rel8` &nbsp; `ja rel32` &nbsp; `ja rel16`

Sprung, wenn ohne Vorzeichen größer (CF=0 und ZF=0).

**Wirkung:** `if CF = 0 and ZF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jbe – Sprung, wenn ohne Vorzeichen kleiner oder gleich

**Syntax:** `jbe rel8` &nbsp; `jbe rel32` &nbsp; `jbe rel16`

Sprung, wenn ohne Vorzeichen kleiner oder gleich (CF=1 oder ZF=1).

**Wirkung:** `if CF = 1 or ZF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jc – Sprung, wenn Übertrag

**Syntax:** `jc rel8` &nbsp; `jc rel32` &nbsp; `jc rel16`

Sprung, wenn Übertrag, ohne Vorzeichen kleiner (CF=1).

**Wirkung:** `if CF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jecxz – Sprung, wenn ecx gleich 0 ist

**Syntax:** `jecxz rel8`

**Wirkung:** `if ecx == 0 then eip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jg – Sprung, wenn mit Vorzeichen größer

**Syntax:** `jg rel8` &nbsp; `jg rel32` &nbsp; `jg rel16`

Sprung, wenn mit Vorzeichen größer (ZF=0 und SF=OF).

**Wirkung:** `if ZF = 0 and SF = OF then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jge – Sprung, wenn mit Vorzeichen größer oder gleich

**Syntax:** `jge rel8` &nbsp; `jge rel32` &nbsp; `jge rel16`

Sprung, wenn mit Vorzeichen größer oder gleich (SF=OF).

**Wirkung:** `if SF = OF then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jl – Sprung, wenn mit Vorzeichen kleiner (SF≠OF)

**Syntax:** `jl rel8` &nbsp; `jl rel32` &nbsp; `jl rel16`

**Wirkung:** `if SF != OF then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jle – Sprung, wenn mit Vorzeichen kleiner oder gleich

**Syntax:** `jle rel8` &nbsp; `jle rel32` &nbsp; `jle rel16`

Sprung, wenn mit Vorzeichen kleiner oder gleich (ZF=1 oder SF≠OF).

**Wirkung:** `if ZF = 1 or SF != OF then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jmp – Sprung zu einer Adresse

**Syntax:** `jmp rel32` &nbsp; `jmp rel16` &nbsp; `jmp rel8` &nbsp; `jmp r/m32` &nbsp; `jmp m` &nbsp; `jmp r/m16` &nbsp; `jmp r/m64`

**Wirkung:** `rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jnc – Sprung, wenn kein Übertrag

**Syntax:** `jnc rel8` &nbsp; `jnc rel32` &nbsp; `jnc rel16`

Sprung, wenn kein Übertrag, ohne Vorzeichen größer oder gleich (CF=0).

**Wirkung:** `if CF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jno – Sprung, wenn kein Überlauf (OF=0)

**Syntax:** `jno rel8` &nbsp; `jno rel32` &nbsp; `jno rel16`

**Wirkung:** `if OF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jnp – Sprung, wenn Parität ungerade (PF=0)

**Syntax:** `jnp rel8` &nbsp; `jnp rel32` &nbsp; `jnp rel16`

**Wirkung:** `if PF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jns – Sprung, wenn nicht negativ (SF=0)

**Syntax:** `jns rel8` &nbsp; `jns rel32` &nbsp; `jns rel16`

**Wirkung:** `if SF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jnz – Sprung, wenn ungleich, Ergebnis nicht null (ZF=0)

**Syntax:** `jnz rel8` &nbsp; `jnz rel32` &nbsp; `jnz rel16`

**Wirkung:** `if ZF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jo – Sprung, wenn Überlauf (OF=1)

**Syntax:** `jo rel8` &nbsp; `jo rel32` &nbsp; `jo rel16`

**Wirkung:** `if OF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jp – Sprung, wenn Parität gerade (PF=1)

**Syntax:** `jp rel8` &nbsp; `jp rel32` &nbsp; `jp rel16`

**Wirkung:** `if PF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jrcxz – Sprung, wenn rcx gleich 0 ist

**Syntax:** `jrcxz rel8`

**Wirkung:** `if rcx == 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## js – Sprung, wenn negativ (SF=1)

**Syntax:** `js rel8` &nbsp; `js rel32` &nbsp; `js rel16`

**Wirkung:** `if SF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## jz – Sprung, wenn gleich, Ergebnis null (ZF=1)

**Syntax:** `jz rel8` &nbsp; `jz rel32` &nbsp; `jz rel16`

**Wirkung:** `if ZF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lahf – Laden der Flags nach ah

**Syntax:** `lahf`

**Wirkung:** `ah = SF:ZF:0:AF:0:PF:1:CF`

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lar – Laden der Zugriffsrechte eines Segments

**Syntax:** `lar r32, r32/m16` &nbsp; `lar r16, r32/m16` &nbsp; `lar r64, r32/m16`

**Wirkung:** `dst = access rights of the segment src; ZF = 1 if it is valid`

**Flags:** ZF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lddqu – Laden von 128 Bit ohne Ausrichtung

**Syntax:** `lddqu xmm, m128`

Laden von 128 Bit ohne Ausrichtung (schnell über Cache-Zeilen).

**Wirkung:** `dst = src (128 bits; any alignment)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ldmxcsr – Laden des SSE-Steuer- und Statusregisters

**Syntax:** `ldmxcsr m`

**Wirkung:** `MXCSR = [m32]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lds – Laden eines Far-Zeigers nach ds:Register

**Syntax:** `lds r32, m` &nbsp; `lds r16, m`

**Wirkung:** `dst = [m]; ds = [m + 4]`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lea – Berechnung einer Adresse und Speichern der Adresse

**Syntax:** `lea r32, m` &nbsp; `lea r16, m` &nbsp; `lea r64, m`

Berechnung einer Adresse und Speichern der Adresse, ohne Zugriff auf den Speicher.

**Wirkung:** `dst = address of src (no memory access)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## leave – Abbau des Stackrahmens (mov rsp, rbp; pop rbp)

**Syntax:** `leave`

**Wirkung:** `rsp = rbp; rbp = pop()`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## les – Laden eines Far-Zeigers nach es:Register

**Syntax:** `les r32, m` &nbsp; `les r16, m`

**Wirkung:** `dst = [m]; es = [m + 4]`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lfence – Schranke für Ladezugriffe

**Syntax:** `lfence`

**Wirkung:** `all earlier loads are done before later instructions`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lgdt – Laden des Registers der globalen Deskriptortabelle

**Syntax:** `lgdt m`

**Wirkung:** `GDTR = [m] (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lidt – Laden des Registers der Interrupt-Deskriptortabelle

**Syntax:** `lidt m`

**Wirkung:** `IDTR = [m] (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lldt – Laden des Registers der lokalen Deskriptortabelle

**Syntax:** `lldt r/m16`

**Wirkung:** `LDTR = src (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lmsw – Laden des Maschinen-Statuswortes

**Syntax:** `lmsw m`

Laden des Maschinen-Statuswortes (untere Bits von cr0).

**Wirkung:** `CR0 bits 0 to 15 = src (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lodsb – Laden von [rsi] nach al/ax/eax/rax

**Syntax:** `lodsb`

Laden von [rsi] nach al/ax/eax/rax, rsi läuft weiter.

**Wirkung:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lodsd – Laden von [rsi] nach al/ax/eax/rax

**Syntax:** `lodsd`

Laden von [rsi] nach al/ax/eax/rax, rsi läuft weiter.

**Wirkung:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lodsq – Laden von [rsi] nach al/ax/eax/rax

**Syntax:** `lodsq`

Laden von [rsi] nach al/ax/eax/rax, rsi läuft weiter.

**Wirkung:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lodsw – Laden von [rsi] nach al/ax/eax/rax

**Syntax:** `lodsw`

Laden von [rsi] nach al/ax/eax/rax, rsi läuft weiter.

**Wirkung:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loop – Verringern von rcx und Sprung

**Syntax:** `loop rel8`

Verringern von rcx und Sprung, solange es nicht 0 ist.

**Wirkung:** `rcx = rcx - 1; if rcx != 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loope – Wie loop, aber nur bei ZF=1

**Syntax:** `loope rel8`

**Wirkung:** `rcx = rcx - 1; if rcx != 0 and ZF = 1 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## loopne – Wie loop, aber nur bei ZF=0

**Syntax:** `loopne rel8`

**Wirkung:** `rcx = rcx - 1; if rcx != 0 and ZF = 0 then rip = target`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lsl – Laden der Grenze eines Segments

**Syntax:** `lsl r32, r32/m16` &nbsp; `lsl r16, r32/m16` &nbsp; `lsl r64, r32/m16`

**Wirkung:** `dst = limit of the segment src; ZF = 1 if it is valid`

**Flags:** ZF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ltr – Laden des Task-Registers

**Syntax:** `ltr r/m16`

**Wirkung:** `task register = src (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## lzcnt – Zählen der führenden Nullbits

**Syntax:** `lzcnt r32, r/m32` &nbsp; `lzcnt r64, r/m64`

**Wirkung:** `dst = number of leading 0 bits of src (width if src = 0)`

**Flags:** ZF CF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maskmovdqu – Schreiben nur der durch eine Maske gewählten Bytes

**Syntax:** `maskmovdqu xmm, xmm`

Schreiben nur der durch eine Maske gewählten Bytes (xmm).

**Wirkung:** `for each byte whose mask bit (the top bit) is 1: [rdi + i] = dst[i]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maskmovq – Schreiben nur der durch eine Maske gewählten Bytes

**Syntax:** `maskmovq mm, mm`

Schreiben nur der durch eine Maske gewählten Bytes (mm).

**Wirkung:** `for each byte whose mask bit (the top bit) is 1: [rdi + i] = dst[i]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxpd – Maximum von 2 Doubles

**Syntax:** `maxpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = max(dst[i], src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxps – Maximum von 4 Singles

**Syntax:** `maxps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = max(dst[i], src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxsd – Maximum von einem Double

**Syntax:** `maxsd xmm, xmm/m64`

**Wirkung:** `dst[0] = max(dst[0], src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## maxss – Maximum von einem Single

**Syntax:** `maxss xmm, xmm/m32`

**Wirkung:** `dst[0] = max(dst[0], src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mfence – Schranke für alle Speicherzugriffe

**Syntax:** `mfence`

**Wirkung:** `all earlier loads and stores are done before later ones`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minpd – Minimum von 2 Doubles

**Syntax:** `minpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = min(dst[i], src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minps – Minimum von 4 Singles

**Syntax:** `minps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = min(dst[i], src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minsd – Minimum von einem Double

**Syntax:** `minsd xmm, xmm/m64`

**Wirkung:** `dst[0] = min(dst[0], src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## minss – Minimum von einem Single

**Syntax:** `minss xmm, xmm/m32`

**Wirkung:** `dst[0] = min(dst[0], src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## monitor – Einrichten der Überwachung einer Adresse für mwait

**Syntax:** `monitor`

**Wirkung:** `watch the address in rax (for mwait)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## monitorx – Einrichten der Überwachung einer Adresse für mwait

**Syntax:** `monitorx`

**Wirkung:** `watch the address in rax (for mwait)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mov – Kopieren der Quelle in das Ziel

**Syntax:** `mov r/m8, r8` &nbsp; `mov r/m32, r32` &nbsp; `mov r/m16, r16` &nbsp; `mov r8, r/m8` &nbsp; `mov r32, r/m32` &nbsp; `mov r16, r/m16` &nbsp; `mov r32/m16, Sreg` &nbsp; `mov r16, Sreg` &nbsp; …

**Wirkung:** `dst = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movapd – Kopieren von 2 Double-Floats

**Syntax:** `movapd xmm, xmm/m128` &nbsp; `movapd xmm/m128, xmm`

Kopieren von 2 Double-Floats (128 Bit), Speicher 16-Byte-ausgerichtet.

**Wirkung:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movaps – Kopieren von 4 Single-Floats

**Syntax:** `movaps xmm, xmm/m128` &nbsp; `movaps xmm/m128, xmm`

Kopieren von 4 Single-Floats (128 Bit), Speicher 16-Byte-ausgerichtet.

**Wirkung:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movbe – Kopieren mit Umkehren der Bytes

**Syntax:** `movbe r32, m` &nbsp; `movbe r16, m` &nbsp; `movbe m, r32` &nbsp; `movbe m, r16` &nbsp; `movbe r64, m` &nbsp; `movbe m, r64`

**Wirkung:** `dst = reverse_bytes(src)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movd – Kopieren von 32 Bit zwischen Ganzzahl-Register/Speicher und xmm/mm

**Syntax:** `movd mm, r/m32` &nbsp; `movd xmm, r/m32` &nbsp; `movd r/m32, mm` &nbsp; `movd r/m32, xmm`

**Wirkung:** `dst = src (32 bits; into xmm / mm the upper bits become 0)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movddup – Verdoppeln des unteren Doubles in beide Hälften

**Syntax:** `movddup xmm, xmm/m64`

**Wirkung:** `dst = (src[63:0], src[63:0])`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movdq2q – Kopieren der unteren Hälfte von xmm nach mm

**Syntax:** `movdq2q mm, xmm`

**Wirkung:** `dst = src[63:0] (xmm to mm)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movdqa – Kopieren von 128 Bit Ganzzahlen

**Syntax:** `movdqa xmm, xmm/m128` &nbsp; `movdqa xmm/m128, xmm`

Kopieren von 128 Bit Ganzzahlen, Speicher 16-Byte-ausgerichtet.

**Wirkung:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movdqu – Kopieren von 128 Bit Ganzzahlen

**Syntax:** `movdqu xmm, xmm/m128` &nbsp; `movdqu xmm/m128, xmm`

Kopieren von 128 Bit Ganzzahlen, beliebig ausgerichtet.

**Wirkung:** `dst = src (128 bits; any alignment)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movhlps – Kopieren der oberen Hälfte des Quell-xmm nach unten

**Syntax:** `movhlps xmm, xmm`

**Wirkung:** `dst[63:0] = src[127:64]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movhpd – Kopieren von 1 Double in die obere Hälfte von xmm

**Syntax:** `movhpd xmm, m64` &nbsp; `movhpd m64, xmm`

Kopieren von 1 Double in die obere Hälfte von xmm (oder aus ihr).

**Wirkung:** `load: dst[127:64] = [m64]; store: [m64] = src[127:64]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movhps – Kopieren von 2 Singles in die obere Hälfte von xmm

**Syntax:** `movhps xmm, m64` &nbsp; `movhps m64, xmm`

Kopieren von 2 Singles in die obere Hälfte von xmm (oder aus ihr).

**Wirkung:** `load: dst[127:64] = [m64]; store: [m64] = src[127:64]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movlhps – Kopieren der unteren Hälfte des Quell-xmm nach oben

**Syntax:** `movlhps xmm, xmm`

**Wirkung:** `dst[127:64] = src[63:0]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movlpd – Kopieren von 1 Double in die untere Hälfte von xmm

**Syntax:** `movlpd xmm, m64` &nbsp; `movlpd m64, xmm`

Kopieren von 1 Double in die untere Hälfte von xmm (oder aus ihr).

**Wirkung:** `load: dst[63:0] = [m64]; store: [m64] = src[63:0]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movlps – Kopieren von 2 Singles in die untere Hälfte von xmm

**Syntax:** `movlps xmm, m64` &nbsp; `movlps m64, xmm`

Kopieren von 2 Singles in die untere Hälfte von xmm (oder aus ihr).

**Wirkung:** `load: dst[63:0] = [m64]; store: [m64] = src[63:0]`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movmskpd – Sammeln der Vorzeichenbits von 2 Doubles in ein Register

**Syntax:** `movmskpd r32, xmm`

**Wirkung:** `dst = sign bits of the 2 doubles of src (2 bits)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movmskps – Sammeln der Vorzeichenbits von 4 Singles in ein Register

**Syntax:** `movmskps r32, xmm`

**Wirkung:** `dst = sign bits of the 4 singles of src (4 bits)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movntdq – Schreiben von 128 Bit am Cache vorbei

**Syntax:** `movntdq m128, xmm`

**Wirkung:** `[dst] = src (past the cache)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movntdqa – Lesen von 128 Bit aus Speicher mit Write-Combining

**Syntax:** `movntdqa xmm, xmm/m128`

**Wirkung:** `dst = [src] (from write-combining memory)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movnti – Schreiben am Cache vorbei (nicht-temporal)

**Syntax:** `movnti m, r32` &nbsp; `movnti m, r64`

**Wirkung:** `[dst] = src (past the cache)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movntpd – Schreiben von 128 Bit am Cache vorbei

**Syntax:** `movntpd m128, xmm`

**Wirkung:** `[dst] = src (past the cache)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movntps – Schreiben von 128 Bit am Cache vorbei

**Syntax:** `movntps m128, xmm`

**Wirkung:** `[dst] = src (past the cache)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movntq – Schreiben von 64 Bit (mm) am Cache vorbei

**Syntax:** `movntq m64, mm`

**Wirkung:** `[dst] = src (past the cache)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movq – Kopieren von 64 Bit

**Syntax:** `movq mm, mm/m64` &nbsp; `movq xmm, xmm/m64` &nbsp; `movq mm/m64, mm` &nbsp; `movq xmm/m64, xmm` &nbsp; `movq mm, r/m64` &nbsp; `movq xmm, r/m64` &nbsp; `movq r/m64, mm` &nbsp; `movq r/m64, xmm`

Kopieren von 64 Bit (auch zwischen Ganzzahl-Register und xmm/mm).

**Wirkung:** `dst = src (64 bits; into xmm the upper half becomes 0)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movq2dq – Kopieren von mm in die untere Hälfte von xmm

**Syntax:** `movq2dq xmm, mm`

**Wirkung:** `dst = (0, src) (mm to xmm)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsb – Kopieren eines Elements von [rsi] nach [rdi]

**Syntax:** `movsb`

Kopieren eines Elements von [rsi] nach [rdi], rsi und rdi laufen weiter.

**Wirkung:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsd – Kopieren eines Double-Floats

**Syntax:** `movsd` &nbsp; `movsd xmm, xmm/m64` &nbsp; `movsd xmm/m64, xmm`

Kopieren eines Double-Floats (bei xmm; ohne Operanden: String-Befehl).

**Wirkung:** `dst[63:0] = src[63:0] (from memory: the rest of dst becomes 0); without operands it is the string instruction`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movshdup – Verdoppeln der ungeraden Singles

**Syntax:** `movshdup xmm, xmm/m128`

**Wirkung:** `dst = (src[63:32], src[63:32], src[127:96], src[127:96])`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsldup – Verdoppeln der geraden Singles

**Syntax:** `movsldup xmm, xmm/m128`

**Wirkung:** `dst = (src[31:0], src[31:0], src[95:64], src[95:64])`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsq – Kopieren eines Elements von [rsi] nach [rdi]

**Syntax:** `movsq`

Kopieren eines Elements von [rsi] nach [rdi], rsi und rdi laufen weiter.

**Wirkung:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movss – Kopieren eines Single-Floats

**Syntax:** `movss xmm, xmm/m32` &nbsp; `movss xmm/m32, xmm`

**Wirkung:** `dst[31:0] = src[31:0] (from memory: the rest of dst becomes 0)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsw – Kopieren eines Elements von [rsi] nach [rdi]

**Syntax:** `movsw`

Kopieren eines Elements von [rsi] nach [rdi], rsi und rdi laufen weiter.

**Wirkung:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsx – Kopieren mit Erweitern des Vorzeichens auf die größere Breite

**Syntax:** `movsx r32, r/m8` &nbsp; `movsx r16, r/m8` &nbsp; `movsx r32, r/m16` &nbsp; `movsx r16, r/m16` &nbsp; `movsx r64, r/m8` &nbsp; `movsx r64, r/m16`

**Wirkung:** `dst = sext(src)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movsxd – Erweitern eines 32-Bit-Wertes mit Vorzeichen auf 64 Bit

**Syntax:** `movsxd r32, r/m32` &nbsp; `movsxd r16, r/m32` &nbsp; `movsxd r64, r/m32`

**Wirkung:** `dst = sext(src32)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movupd – Kopieren von 2 Double-Floats

**Syntax:** `movupd xmm, xmm/m128` &nbsp; `movupd xmm/m128, xmm`

Kopieren von 2 Double-Floats (128 Bit), beliebig ausgerichtet.

**Wirkung:** `dst = src (128 bits; any alignment)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movups – Kopieren von 4 Single-Floats

**Syntax:** `movups xmm, xmm/m128` &nbsp; `movups xmm/m128, xmm`

Kopieren von 4 Single-Floats (128 Bit), beliebig ausgerichtet.

**Wirkung:** `dst = src (128 bits; any alignment)`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## movzx – Kopieren mit Auffüllen der oberen Hälfte durch Nullen

**Syntax:** `movzx r32, r/m8` &nbsp; `movzx r16, r/m8` &nbsp; `movzx r32, r/m16` &nbsp; `movzx r16, r/m16` &nbsp; `movzx r64, r/m8` &nbsp; `movzx r64, r/m16`

Kopieren mit Auffüllen der oberen Hälfte durch Nullen (ohne Vorzeichen).

**Wirkung:** `dst = zext(src)`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mpsadbw – Summen absoluter Differenzen von Bytes

**Syntax:** `mpsadbw xmm, xmm/m128, imm8`

Summen absoluter Differenzen von Bytes (Bewegungssuche).

**Wirkung:** `dst[i] = sums of absolute byte differences of blocks chosen by imm8`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mul – Multiplikation ohne Vorzeichen

**Syntax:** `mul al, r/m8` &nbsp; `mul eax, r/m32` &nbsp; `mul ax, r/m16` &nbsp; `mul r/m8` &nbsp; `mul r/m32` &nbsp; `mul r/m16` &nbsp; `mul r/m64`

Multiplikation ohne Vorzeichen, das Ergebnis ist doppelt so breit (edx:eax).

**Wirkung:** `rdx:rax = rax * src (8 bit: ax = al * src; 16: dx:ax; 32: edx:eax)`

**Flags:** OF CF &nbsp; undefiniert: SF ZF AF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulpd – Multiplikation von 2 Doubles

**Syntax:** `mulpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] * src[i] (double)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulps – Multiplikation von 4 Singles

**Syntax:** `mulps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] * src[i] (single)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulsd – Multiplikation von einem Double

**Syntax:** `mulsd xmm, xmm/m64`

**Wirkung:** `dst[0] = dst[0] * src[0] (double); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mulss – Multiplikation von einem Single

**Syntax:** `mulss xmm, xmm/m32`

**Wirkung:** `dst[0] = dst[0] * src[0] (single); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mwait – Warten auf eine Änderung der überwachten Adresse

**Syntax:** `mwait`

**Wirkung:** `wait until the watched address is written or an interrupt comes`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## mwaitx – Warten auf eine Änderung der überwachten Adresse

**Syntax:** `mwaitx`

**Wirkung:** `wait until the watched address is written or an interrupt comes`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## neg – Negation (Zweierkomplement)

**Syntax:** `neg r/m8` &nbsp; `neg r/m32` &nbsp; `neg r/m16` &nbsp; `neg r/m64`

**Wirkung:** `dst = 0 - dst; CF = (dst != 0)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## nop – Keine Operation

**Syntax:** `nop` &nbsp; `nop r/m32` &nbsp; `nop r/m16` &nbsp; `nop r32` &nbsp; `nop eax` &nbsp; `nop ebp` &nbsp; `nop ecx` &nbsp; `nop edi` &nbsp; …

**Wirkung:** `no operation`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## not – Umkehrung aller Bits (Einerkomplement)

**Syntax:** `not r/m8` &nbsp; `not r/m32` &nbsp; `not r/m16` &nbsp; `not r/m64`

**Wirkung:** `dst = ~dst`

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## or – Bitweise ODER-Verknüpfung

**Syntax:** `or r/m8, r8` &nbsp; `or r/m32, r32` &nbsp; `or r/m16, r16` &nbsp; `or r8, r/m8` &nbsp; `or r32, r/m32` &nbsp; `or r16, r/m16` &nbsp; `or al, imm8` &nbsp; `or eax, imm32` &nbsp; …

**Wirkung:** `dst = dst OR src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orpd – Bitweise ODER-Verknüpfung

**Syntax:** `orpd xmm, xmm/m128`

**Wirkung:** `dst = dst OR src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## orps – Bitweise ODER-Verknüpfung

**Syntax:** `orps xmm, xmm/m128`

**Wirkung:** `dst = dst OR src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## out – Schreiben eines Wertes auf einen Ein-/Ausgabeport

**Syntax:** `out imm8, al` &nbsp; `out imm8, eax` &nbsp; `out imm8, ax` &nbsp; `out dx, al` &nbsp; `out dx, eax` &nbsp; `out dx, ax`

**Wirkung:** `port[dst] = src`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## outsb – Schreiben von [rsi] auf einen Port

**Syntax:** `outsb`

Schreiben von [rsi] auf einen Port, rsi läuft weiter.

**Wirkung:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## outsd – Schreiben von [rsi] auf einen Port

**Syntax:** `outsd`

Schreiben von [rsi] auf einen Port, rsi läuft weiter.

**Wirkung:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## outsw – Schreiben von [rsi] auf einen Port

**Syntax:** `outsw`

Schreiben von [rsi] auf einen Port, rsi läuft weiter.

**Wirkung:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pabsb – Betrag von Bytes

**Syntax:** `pabsb mm, mm/m64` &nbsp; `pabsb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = abs(src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pabsd – Betrag von 32-Bit-Elementen

**Syntax:** `pabsd mm, mm/m64` &nbsp; `pabsd xmm, xmm/m64`

**Wirkung:** `for every 32 bit element: dst[i] = abs(src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pabsw – Betrag von 16-Bit-Elementen

**Syntax:** `pabsw mm, mm/m64` &nbsp; `pabsw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = abs(src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packssdw – Packen von 32 in 16 Bit mit Vorzeichen (gesättigt)

**Syntax:** `packssdw mm, mm/m64` &nbsp; `packssdw xmm, xmm/m128`

**Wirkung:** `dst = (sat16_s(dst[i]) ..., sat16_s(src[i]) ...) (32 to 16 bit, signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packsswb – Packen von 16 in 8 Bit mit Vorzeichen (gesättigt)

**Syntax:** `packsswb mm, mm/m64` &nbsp; `packsswb xmm, xmm/m128`

**Wirkung:** `dst = (sat8_s(dst[i]) ..., sat8_s(src[i]) ...) (16 to 8 bit, signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packusdw – Packen von 32 in 16 Bit ohne Vorzeichen

**Syntax:** `packusdw xmm, xmm/m128`

Packen von 32 in 16 Bit ohne Vorzeichen (gesättigt).

**Wirkung:** `dst = (sat16_u(dst[i]) ..., sat16_u(src[i]) ...) (32 to 16 bit, unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## packuswb – Packen von 16 in 8 Bit ohne Vorzeichen (gesättigt)

**Syntax:** `packuswb mm, mm/m64` &nbsp; `packuswb xmm, xmm/m128`

**Wirkung:** `dst = (sat8_u(dst[i]) ..., sat8_u(src[i]) ...) (16 to 8 bit, unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddb – Addition von Bytes

**Syntax:** `paddb mm, mm/m64` &nbsp; `paddb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = dst[i] + src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddd – Addition von 32-Bit-Elementen

**Syntax:** `paddd mm, mm/m64` &nbsp; `paddd xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = dst[i] + src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddq – Addition von 64-Bit-Elementen

**Syntax:** `paddq mm, mm/m64` &nbsp; `paddq xmm, xmm/m128`

**Wirkung:** `for every 64 bit element: dst[i] = dst[i] + src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddsb – Addition von Bytes (mit Vorzeichen, gesättigt)

**Syntax:** `paddsb mm, mm/m64` &nbsp; `paddsb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = sat_s(dst[i] + src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddsw – Addition von 16-Bit-Elementen

**Syntax:** `paddsw mm, mm/m64` &nbsp; `paddsw xmm, xmm/m128`

Addition von 16-Bit-Elementen (mit Vorzeichen, gesättigt).

**Wirkung:** `for every 16 bit element: dst[i] = sat_s(dst[i] + src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddusb – Addition von Bytes (ohne Vorzeichen, gesättigt)

**Syntax:** `paddusb mm, mm/m64` &nbsp; `paddusb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = sat_u(dst[i] + src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddusw – Addition von 16-Bit-Elementen

**Syntax:** `paddusw mm, mm/m64` &nbsp; `paddusw xmm, xmm/m128`

Addition von 16-Bit-Elementen (ohne Vorzeichen, gesättigt).

**Wirkung:** `for every 16 bit element: dst[i] = sat_u(dst[i] + src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## paddw – Addition von 16-Bit-Elementen

**Syntax:** `paddw mm, mm/m64` &nbsp; `paddw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = dst[i] + src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## palignr – Verbinden zweier Register und Schieben um eine Byte-Zahl

**Syntax:** `palignr mm, mm/m64, imm8` &nbsp; `palignr xmm, xmm/m128, imm8`

**Wirkung:** `dst = low part of (dst:src >> (imm8 * 8 bits))`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pand – Bitweise UND-Verknüpfung

**Syntax:** `pand mm, mm/m64` &nbsp; `pand xmm, xmm/m128`

**Wirkung:** `dst = dst & src`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pandn – Bitweise Verknüpfung: NICHT Ziel UND Quelle

**Syntax:** `pandn mm, mm/m64` &nbsp; `pandn xmm, xmm/m128`

**Wirkung:** `dst = ~dst & src`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pause – Hinweis in Warteschleifen

**Syntax:** `pause`

Hinweis in Warteschleifen (spart Strom, hilft bei Hyper-Threading).

**Wirkung:** `hint: this is a wait loop (no change)`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pavgb – Mittelwert von Bytes (gerundet)

**Syntax:** `pavgb mm, mm/m64` &nbsp; `pavgb xmm, xmm/m128`

**Wirkung:** `dst[i] = (dst[i] + src[i] + 1) >> 1 (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pavgw – Mittelwert von 16-Bit-Elementen (gerundet)

**Syntax:** `pavgw mm, mm/m64` &nbsp; `pavgw xmm, xmm/m128`

**Wirkung:** `dst[i] = (dst[i] + src[i] + 1) >> 1 (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pblendvb – Auswahl von Bytes nach den Vorzeichenbits von xmm0

**Syntax:** `pblendvb xmm, xmm/m128, xmm0`

**Wirkung:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pblendw – Auswahl von 16-Bit-Elementen nach einer Maske

**Syntax:** `pblendw xmm, xmm/m128, imm8`

**Wirkung:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pclmulqdq – Multiplikation ohne Übertrag

**Syntax:** `pclmulqdq xmm, xmm/m128, imm8`

Multiplikation ohne Übertrag (Galois-Feld, für CRC und GCM).

**Wirkung:** `dst = carry-less product of one quadword of dst and one of src (chosen by imm8)`

*Gruppe: Kryptografie. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpeqb – Vergleich auf gleich

**Syntax:** `pcmpeqb mm, mm/m64` &nbsp; `pcmpeqb xmm, xmm/m128`

Vergleich auf gleich (Bytes), Ergebnis ist eine Maske.

**Wirkung:** `for every 8 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpeqd – Vergleich auf gleich

**Syntax:** `pcmpeqd mm, mm/m64` &nbsp; `pcmpeqd xmm, xmm/m128`

Vergleich auf gleich (32-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 32 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpeqq – Vergleich auf gleich

**Syntax:** `pcmpeqq xmm, xmm/m128`

Vergleich auf gleich (64-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 64 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpeqw – Vergleich auf gleich

**Syntax:** `pcmpeqw mm, mm/m64` &nbsp; `pcmpeqw xmm, xmm/m128`

Vergleich auf gleich (16-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 16 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpestri – Vergleich von Zeichenketten

**Syntax:** `pcmpestri xmm, xmm/m128, imm8`

Vergleich von Zeichenketten (explizite Längen), Ergebnis ist ein Index.

**Wirkung:** `ECX = index of the match of the strings dst, src (lengths in eax, edx; mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpestrm – Vergleich von Zeichenketten

**Syntax:** `pcmpestrm xmm, xmm/m128, imm8`

Vergleich von Zeichenketten (explizite Längen), Ergebnis ist eine Maske.

**Wirkung:** `xmm0 = mask of the matches of the strings dst, src (lengths in eax, edx; mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpgtb – Vergleich auf größer

**Syntax:** `pcmpgtb mm, mm/m64` &nbsp; `pcmpgtb xmm, xmm/m128`

Vergleich auf größer, mit Vorzeichen (Bytes), Ergebnis ist eine Maske.

**Wirkung:** `for every 8 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpgtd – Vergleich auf größer

**Syntax:** `pcmpgtd mm, mm/m64` &nbsp; `pcmpgtd xmm, xmm/m128`

Vergleich auf größer, mit Vorzeichen (32-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 32 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpgtq – Vergleich auf größer

**Syntax:** `pcmpgtq xmm, xmm/m128`

Vergleich auf größer, mit Vorzeichen (64-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 64 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpgtw – Vergleich auf größer

**Syntax:** `pcmpgtw mm, mm/m64` &nbsp; `pcmpgtw xmm, xmm/m128`

Vergleich auf größer, mit Vorzeichen (16-Bit-Elementen), Ergebnis ist eine Maske.

**Wirkung:** `for every 16 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpistri – Vergleich von Zeichenketten

**Syntax:** `pcmpistri xmm, xmm/m128, imm8`

Vergleich von Zeichenketten (mit Ende 0), Ergebnis ist ein Index.

**Wirkung:** `ECX = index of the match of the 0-terminated strings dst, src (mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pcmpistrm – Vergleich von Zeichenketten

**Syntax:** `pcmpistrm xmm, xmm/m128, imm8`

Vergleich von Zeichenketten (mit Ende 0), Ergebnis ist eine Maske.

**Wirkung:** `xmm0 = mask of the matches of the 0-terminated strings dst, src (mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pextrb – Herausholen eines Elements aus xmm in ein Register

**Syntax:** `pextrb r32/m8, xmm, imm8`

**Wirkung:** `dst = element number imm8 of src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pextrd – Herausholen eines Elements aus xmm in ein Register

**Syntax:** `pextrd r/m32, xmm, imm8`

**Wirkung:** `dst = element number imm8 of src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pextrq – Herausholen eines Elements aus xmm in ein Register

**Syntax:** `pextrq r/m64, xmm, imm8`

**Wirkung:** `dst = element number imm8 of src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pextrw – Herausholen eines Elements aus xmm in ein Register

**Syntax:** `pextrw r32, mm, imm8` &nbsp; `pextrw r32, xmm, imm8` &nbsp; `pextrw r32/m16, xmm, imm8`

**Wirkung:** `dst = element number imm8 of src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phaddd – Addition benachbarter 32-Bit-Elemente (horizontal)

**Syntax:** `phaddd mm, mm/m64` &nbsp; `phaddd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phaddsw – Addition benachbarter 16-Bit-Elemente

**Syntax:** `phaddsw mm, mm/m64` &nbsp; `phaddsw xmm, xmm/m128`

Addition benachbarter 16-Bit-Elemente (horizontal), gesättigt.

**Wirkung:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...) (saturating)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phaddw – Addition benachbarter 16-Bit-Elemente (horizontal)

**Syntax:** `phaddw mm, mm/m64` &nbsp; `phaddw xmm, xmm/m128`

**Wirkung:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phminposuw – Suche des kleinsten 16-Bit-Elements samt Position

**Syntax:** `phminposuw xmm, xmm/m128`

**Wirkung:** `dst = (smallest unsigned word of src, its index, 0 ...)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phsubd – Subtraktion benachbarter 32-Bit-Elemente

**Syntax:** `phsubd mm, mm/m64` &nbsp; `phsubd xmm, xmm/m128`

Subtraktion benachbarter 32-Bit-Elemente (horizontal).

**Wirkung:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phsubsw – Subtraktion benachbarter 16-Bit-Elemente

**Syntax:** `phsubsw mm, mm/m64` &nbsp; `phsubsw xmm, xmm/m128`

Subtraktion benachbarter 16-Bit-Elemente (horizontal), gesättigt.

**Wirkung:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...) (saturating)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## phsubw – Subtraktion benachbarter 16-Bit-Elemente

**Syntax:** `phsubw mm, mm/m64` &nbsp; `phsubw xmm, xmm/m128`

Subtraktion benachbarter 16-Bit-Elemente (horizontal).

**Wirkung:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pinsrb – Einfügen eines Elements aus einem Register in xmm

**Syntax:** `pinsrb xmm, r32/m8, imm8`

**Wirkung:** `dst = dst with element number imm8 replaced by src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pinsrd – Einfügen eines Elements aus einem Register in xmm

**Syntax:** `pinsrd xmm, r/m32, imm8`

**Wirkung:** `dst = dst with element number imm8 replaced by src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pinsrq – Einfügen eines Elements aus einem Register in xmm

**Syntax:** `pinsrq xmm, r/m64, imm8`

**Wirkung:** `dst = dst with element number imm8 replaced by src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pinsrw – Einfügen eines Elements aus einem Register in xmm

**Syntax:** `pinsrw mm, r32/m16, imm8` &nbsp; `pinsrw xmm, r32/m16, imm8`

**Wirkung:** `dst = dst with element number imm8 replaced by src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaddubsw – Multiplikation von Bytepaaren und Addition

**Syntax:** `pmaddubsw mm, mm/m64` &nbsp; `pmaddubsw xmm, xmm/m128`

Multiplikation von Bytepaaren und Addition (mit Sättigung).

**Wirkung:** `dst[i] = sat16(dst_u8[2i] * src_s8[2i] + dst_u8[2i+1] * src_s8[2i+1])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaddwd – Multiplikation von 16-Bit-Paaren und Addition zu 32 Bit

**Syntax:** `pmaddwd mm, mm/m64` &nbsp; `pmaddwd xmm, xmm/m128`

**Wirkung:** `dst[i] = dst_s16[2i] * src_s16[2i] + dst_s16[2i+1] * src_s16[2i+1] (32 bit)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxsb – Maximum von Bytes (mit Vorzeichen)

**Syntax:** `pmaxsb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxsd – Maximum von 32-Bit-Elementen (mit Vorzeichen)

**Syntax:** `pmaxsd xmm, xmm/m64`

**Wirkung:** `for every 32 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxsw – Maximum von 16-Bit-Elementen (mit Vorzeichen)

**Syntax:** `pmaxsw mm, mm/m64` &nbsp; `pmaxsw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxub – Maximum von Bytes (ohne Vorzeichen)

**Syntax:** `pmaxub mm, mm/m64` &nbsp; `pmaxub xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxud – Maximum von 32-Bit-Elementen (ohne Vorzeichen)

**Syntax:** `pmaxud xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmaxuw – Maximum von 16-Bit-Elementen (ohne Vorzeichen)

**Syntax:** `pmaxuw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminsb – Minimum von Bytes (mit Vorzeichen)

**Syntax:** `pminsb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminsd – Minimum von 32-Bit-Elementen (mit Vorzeichen)

**Syntax:** `pminsd xmm, xmm/m64`

**Wirkung:** `for every 32 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminsw – Minimum von 16-Bit-Elementen (mit Vorzeichen)

**Syntax:** `pminsw mm, mm/m64` &nbsp; `pminsw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminub – Minimum von Bytes (ohne Vorzeichen)

**Syntax:** `pminub mm, mm/m64` &nbsp; `pminub xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminud – Minimum von 32-Bit-Elementen (ohne Vorzeichen)

**Syntax:** `pminud xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pminuw – Minimum von 16-Bit-Elementen (ohne Vorzeichen)

**Syntax:** `pminuw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovmskb – Sammeln der Vorzeichenbits der Bytes in ein Register

**Syntax:** `pmovmskb r32, mm` &nbsp; `pmovmskb r32, xmm`

**Wirkung:** `dst = the top bits of all bytes of src`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxbd – Erweiterung von Bytes zu 32 Bit (mit Vorzeichen)

**Syntax:** `pmovsxbd xmm, xmm/m32`

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxbq – Erweiterung von Bytes zu 64 Bit (mit Vorzeichen)

**Syntax:** `pmovsxbq xmm, xmm/m16`

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxbw – Erweiterung von Bytes zu 16 Bit (mit Vorzeichen)

**Syntax:** `pmovsxbw xmm, xmm/m64`

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxdq – Erweiterung von 32-Bit-Elementen zu 64 Bit

**Syntax:** `pmovsxdq xmm, xmm/m64`

Erweiterung von 32-Bit-Elementen zu 64 Bit (mit Vorzeichen).

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxwd – Erweiterung von 16-Bit-Elementen zu 32 Bit

**Syntax:** `pmovsxwd xmm, xmm/m64`

Erweiterung von 16-Bit-Elementen zu 32 Bit (mit Vorzeichen).

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovsxwq – Erweiterung von 16-Bit-Elementen zu 64 Bit

**Syntax:** `pmovsxwq xmm, xmm/m32`

Erweiterung von 16-Bit-Elementen zu 64 Bit (mit Vorzeichen).

**Wirkung:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxbd – Erweiterung von Bytes zu 32 Bit (mit Nullen)

**Syntax:** `pmovzxbd xmm, xmm/m32`

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxbq – Erweiterung von Bytes zu 64 Bit (mit Nullen)

**Syntax:** `pmovzxbq xmm, xmm/m16`

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxbw – Erweiterung von Bytes zu 16 Bit (mit Nullen)

**Syntax:** `pmovzxbw xmm, xmm/m64`

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxdq – Erweiterung von 32-Bit-Elementen zu 64 Bit

**Syntax:** `pmovzxdq xmm, xmm/m64`

Erweiterung von 32-Bit-Elementen zu 64 Bit (mit Nullen).

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxwd – Erweiterung von 16-Bit-Elementen zu 32 Bit

**Syntax:** `pmovzxwd xmm, xmm/m64`

Erweiterung von 16-Bit-Elementen zu 32 Bit (mit Nullen).

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmovzxwq – Erweiterung von 16-Bit-Elementen zu 64 Bit

**Syntax:** `pmovzxwq xmm, xmm/m32`

Erweiterung von 16-Bit-Elementen zu 64 Bit (mit Nullen).

**Wirkung:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmuldq – Multiplikation von 32 Bit mit Vorzeichen zu 64 Bit

**Syntax:** `pmuldq xmm, xmm/m128`

**Wirkung:** `dst[i] = dst_s32[2i] * src_s32[2i] (64 bit results)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmulhrsw – Multiplikation von 16 Bit mit Vorzeichen, gerundet

**Syntax:** `pmulhrsw mm, mm/m64` &nbsp; `pmulhrsw xmm, xmm/m128`

**Wirkung:** `dst[i] = (dst[i] * src[i] >> 14 + 1) >> 1 (signed 16 bit, rounded)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmulhuw – Multiplikation von 16 Bit ohne Vorzeichen

**Syntax:** `pmulhuw mm, mm/m64` &nbsp; `pmulhuw xmm, xmm/m128`

Multiplikation von 16 Bit ohne Vorzeichen, obere Hälfte bleibt.

**Wirkung:** `dst[i] = (dst[i] * src[i]) >> 16 (unsigned 16 bit)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmulhw – Multiplikation von 16 Bit mit Vorzeichen

**Syntax:** `pmulhw mm, mm/m64` &nbsp; `pmulhw xmm, xmm/m128`

Multiplikation von 16 Bit mit Vorzeichen, obere Hälfte bleibt.

**Wirkung:** `dst[i] = (dst[i] * src[i]) >> 16 (signed 16 bit)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmulld – Multiplikation von 32 Bit, untere Hälfte bleibt

**Syntax:** `pmulld xmm, xmm/m128`

**Wirkung:** `dst[i] = low 32 bits of dst[i] * src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmullw – Multiplikation von 16 Bit, untere Hälfte bleibt

**Syntax:** `pmullw mm, mm/m64` &nbsp; `pmullw xmm, xmm/m128`

**Wirkung:** `dst[i] = low 16 bits of dst[i] * src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pmuludq – Multiplikation von 32 Bit ohne Vorzeichen zu 64 Bit

**Syntax:** `pmuludq mm, mm/m64` &nbsp; `pmuludq xmm, xmm/m128`

**Wirkung:** `dst[i] = dst_u32[2i] * src_u32[2i] (64 bit results)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pop – Holen eines Wertes vom Stack

**Syntax:** `pop es` &nbsp; `pop ss` &nbsp; `pop ds` &nbsp; `pop r32` &nbsp; `pop r16` &nbsp; `pop r/m32` &nbsp; `pop r/m16` &nbsp; `pop fs` &nbsp; …

**Wirkung:** `dst = [rsp]; rsp = rsp + 8 (16 bit: 2 bytes)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popad – Holen aller 32-Bit-Register vom Stack

**Syntax:** `popad`

**Wirkung:** `edi, esi, ebp = pop(); (esp is skipped); ebx, edx, ecx, eax = pop()`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popaw – Holen aller 16-Bit-Register vom Stack

**Syntax:** `popaw`

**Wirkung:** `di, si, bp = pop(); (sp is skipped); bx, dx, cx, ax = pop()`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popcnt – Zählen der gesetzten Bits

**Syntax:** `popcnt r32, r/m32` &nbsp; `popcnt r64, r/m64`

**Wirkung:** `dst = number of 1 bits in src`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popfd – Holen des Flag-Registers (32 Bit) vom Stack

**Syntax:** `popfd`

**Wirkung:** `eflags = pop() (privileged bits stay)`

**Flags:** all

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popfq – Holen des Flag-Registers vom Stack

**Syntax:** `popfq`

**Wirkung:** `flags = pop() (privileged bits stay)`

**Flags:** all

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## popfw – Holen des Flag-Registers vom Stack

**Syntax:** `popfw`

**Wirkung:** `flags = pop() (privileged bits stay)`

**Flags:** all

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## por – Bitweise ODER-Verknüpfung

**Syntax:** `por mm, mm/m64` &nbsp; `por xmm, xmm/m128`

**Wirkung:** `dst = dst OR src`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetch – Vorab-Laden einer Cache-Zeile (w: zum Schreiben)

**Syntax:** `prefetch m`

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetchnta – Vorab-Laden

**Syntax:** `prefetchnta m`

Vorab-Laden, möglichst ohne den Cache zu verdrängen.

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetcht0 – Vorab-Laden in alle Cache-Ebenen

**Syntax:** `prefetcht0 m`

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetcht1 – Vorab-Laden in die Cache-Ebene 2 und höher

**Syntax:** `prefetcht1 m`

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetcht2 – Vorab-Laden in die Cache-Ebene 3

**Syntax:** `prefetcht2 m`

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## prefetchw – Vorab-Laden einer Cache-Zeile (w: zum Schreiben)

**Syntax:** `prefetchw m`

**Wirkung:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psadbw – Summe der absoluten Byte-Differenzen

**Syntax:** `psadbw mm, mm/m64` &nbsp; `psadbw xmm, xmm/m128`

**Wirkung:** `dst[i] = sum of abs(dst_u8[j] - src_u8[j]) over 8 bytes`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pshufb – Mischen von Bytes nach einer Tabelle im Quellregister

**Syntax:** `pshufb mm, mm/m64` &nbsp; `pshufb xmm, xmm/m128`

**Wirkung:** `dst[i] = (src[i] has top bit 1) ? 0 : dst[src[i] & 15]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pshufd – Mischen der 32-Bit-Elemente nach einer Vorgabe

**Syntax:** `pshufd xmm, xmm/m128, imm8`

**Wirkung:** `dst = (src[sel0], src[sel1], src[sel2], src[sel3]); sel = bit pairs of imm8`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pshufhw – Mischen der oberen vier 16-Bit-Elemente

**Syntax:** `pshufhw xmm, xmm/m128, imm8`

**Wirkung:** `dst[63:0] = src[63:0]; the upper four words are chosen from src[127:64] by imm8`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pshuflw – Mischen der unteren vier 16-Bit-Elemente

**Syntax:** `pshuflw xmm, xmm/m128, imm8`

**Wirkung:** `dst[127:64] = src[127:64]; the lower four words are chosen from src[63:0] by imm8`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pshufw – Mischen von vier 16-Bit-Elementen (mm)

**Syntax:** `pshufw mm, mm/m64, imm8`

**Wirkung:** `dst = four words chosen from src by imm8 (mm)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psignb – Übernahme des Vorzeichens der Quelle für Bytes

**Syntax:** `psignb mm, mm/m64` &nbsp; `psignb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psignd – Übernahme des Vorzeichens der Quelle für 32-Bit-Elementen

**Syntax:** `psignd mm, mm/m64` &nbsp; `psignd xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psignw – Übernahme des Vorzeichens der Quelle für 16-Bit-Elementen

**Syntax:** `psignw mm, mm/m64` &nbsp; `psignw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pslld – Schieben von 32-Bit-Elementen nach links

**Syntax:** `pslld mm, imm8` &nbsp; `pslld xmm, imm8` &nbsp; `pslld mm, mm/m64` &nbsp; `pslld xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pslldq – Schieben des ganzen Registers um Bytes nach links

**Syntax:** `pslldq xmm, imm8`

**Wirkung:** `dst = dst << (imm8 * 8 bits) (the whole register, zeros come in)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psllq – Schieben von 64-Bit-Elementen nach links

**Syntax:** `psllq mm, imm8` &nbsp; `psllq xmm, imm8` &nbsp; `psllq mm, mm/m64` &nbsp; `psllq xmm, xmm/m128`

**Wirkung:** `for every 64 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psllw – Schieben von 16-Bit-Elementen nach links

**Syntax:** `psllw mm, imm8` &nbsp; `psllw xmm, imm8` &nbsp; `psllw mm, mm/m64` &nbsp; `psllw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psrad – Schieben von 32-Bit-Elementen nach rechts

**Syntax:** `psrad mm, imm8` &nbsp; `psrad xmm, imm8` &nbsp; `psrad mm, mm/m64` &nbsp; `psrad xmm, xmm/m128`

Schieben von 32-Bit-Elementen nach rechts (arithmetisch).

**Wirkung:** `for every 32 bit element: dst[i] = dst[i] >>s count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psraw – Schieben von 16-Bit-Elementen nach rechts

**Syntax:** `psraw mm, imm8` &nbsp; `psraw xmm, imm8` &nbsp; `psraw mm, mm/m64` &nbsp; `psraw xmm, xmm/m128`

Schieben von 16-Bit-Elementen nach rechts (arithmetisch).

**Wirkung:** `for every 16 bit element: dst[i] = dst[i] >>s count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psrld – Schieben von 32-Bit-Elementen nach rechts

**Syntax:** `psrld mm, imm8` &nbsp; `psrld xmm, imm8` &nbsp; `psrld mm, mm/m64` &nbsp; `psrld xmm, xmm/m128`

Schieben von 32-Bit-Elementen nach rechts (logisch).

**Wirkung:** `for every 32 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psrldq – Schieben des ganzen Registers um Bytes nach rechts

**Syntax:** `psrldq xmm, imm8`

**Wirkung:** `dst = dst >> (imm8 * 8 bits) (the whole register, zeros come in)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psrlq – Schieben von 64-Bit-Elementen nach rechts

**Syntax:** `psrlq mm, imm8` &nbsp; `psrlq xmm, imm8` &nbsp; `psrlq mm, mm/m64` &nbsp; `psrlq xmm, xmm/m128`

Schieben von 64-Bit-Elementen nach rechts (logisch).

**Wirkung:** `for every 64 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psrlw – Schieben von 16-Bit-Elementen nach rechts

**Syntax:** `psrlw mm, imm8` &nbsp; `psrlw xmm, imm8` &nbsp; `psrlw mm, mm/m64` &nbsp; `psrlw xmm, xmm/m128`

Schieben von 16-Bit-Elementen nach rechts (logisch).

**Wirkung:** `for every 16 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubb – Subtraktion von Bytes

**Syntax:** `psubb mm, mm/m64` &nbsp; `psubb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = dst[i] - src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubd – Subtraktion von 32-Bit-Elementen

**Syntax:** `psubd mm, mm/m64` &nbsp; `psubd xmm, xmm/m128`

**Wirkung:** `for every 32 bit element: dst[i] = dst[i] - src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubq – Subtraktion von 64-Bit-Elementen

**Syntax:** `psubq mm, mm/m64` &nbsp; `psubq xmm, xmm/m128`

**Wirkung:** `for every 64 bit element: dst[i] = dst[i] - src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubsb – Subtraktion von Bytes (mit Vorzeichen, gesättigt)

**Syntax:** `psubsb mm, mm/m64` &nbsp; `psubsb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = sat_s(dst[i] - src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubsw – Subtraktion von 16-Bit-Elementen

**Syntax:** `psubsw mm, mm/m64` &nbsp; `psubsw xmm, xmm/m128`

Subtraktion von 16-Bit-Elementen (mit Vorzeichen, gesättigt).

**Wirkung:** `for every 16 bit element: dst[i] = sat_s(dst[i] - src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubusb – Subtraktion von Bytes (ohne Vorzeichen, gesättigt)

**Syntax:** `psubusb mm, mm/m64` &nbsp; `psubusb xmm, xmm/m128`

**Wirkung:** `for every 8 bit element: dst[i] = sat_u(dst[i] - src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubusw – Subtraktion von 16-Bit-Elementen

**Syntax:** `psubusw mm, mm/m64` &nbsp; `psubusw xmm, xmm/m128`

Subtraktion von 16-Bit-Elementen (ohne Vorzeichen, gesättigt).

**Wirkung:** `for every 16 bit element: dst[i] = sat_u(dst[i] - src[i])`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## psubw – Subtraktion von 16-Bit-Elementen

**Syntax:** `psubw mm, mm/m64` &nbsp; `psubw xmm, xmm/m128`

**Wirkung:** `for every 16 bit element: dst[i] = dst[i] - src[i]`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ptest – Bit-Test (setzt ZF und CF)

**Syntax:** `ptest xmm, xmm/m128`

**Wirkung:** `ZF = ((dst & src) == 0); CF = ((~dst & src) == 0); OF SF AF PF = 0`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpckhbw – Verschränken der oberen Bytes zweier Register

**Syntax:** `punpckhbw mm, mm/m64` &nbsp; `punpckhbw xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpckhdq – Verschränken der oberen 32-Bit-Elemente zweier Register

**Syntax:** `punpckhdq mm, mm/m64` &nbsp; `punpckhdq xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpckhqdq – Verschränken der oberen 64-Bit-Elemente zweier Register

**Syntax:** `punpckhqdq xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpckhwd – Verschränken der oberen 16-Bit-Elemente zweier Register

**Syntax:** `punpckhwd mm, mm/m64` &nbsp; `punpckhwd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpcklbw – Verschränken der unteren Bytes zweier Register

**Syntax:** `punpcklbw mm, mm/m64` &nbsp; `punpcklbw xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpckldq – Verschränken der unteren 32-Bit-Elemente zweier Register

**Syntax:** `punpckldq mm, mm/m64` &nbsp; `punpckldq xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpcklqdq – Verschränken der unteren 64-Bit-Elemente zweier Register

**Syntax:** `punpcklqdq xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## punpcklwd – Verschränken der unteren 16-Bit-Elemente zweier Register

**Syntax:** `punpcklwd mm, mm/m64` &nbsp; `punpcklwd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## push – Ablegen eines Wertes auf dem Stack

**Syntax:** `push es` &nbsp; `push cs` &nbsp; `push ss` &nbsp; `push ds` &nbsp; `push r32` &nbsp; `push r16` &nbsp; `push imm32` &nbsp; `push imm16` &nbsp; …

**Wirkung:** `rsp = rsp - 8; [rsp] = src (16 bit: 2 bytes)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pushad – Ablegen aller 32-Bit-Register auf dem Stack

**Syntax:** `pushad`

**Wirkung:** `tmp = esp; push(eax, ecx, edx, ebx, tmp, ebp, esi, edi)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pushaw – Ablegen aller 16-Bit-Register auf dem Stack

**Syntax:** `pushaw`

**Wirkung:** `tmp = sp; push(ax, cx, dx, bx, tmp, bp, si, di)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pushfd – Ablegen des Flag-Registers (32 Bit) auf dem Stack

**Syntax:** `pushfd`

**Wirkung:** `push(eflags)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pushfq – Ablegen des Flag-Registers auf dem Stack

**Syntax:** `pushfq`

**Wirkung:** `push(flags)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pushfw – Ablegen des Flag-Registers auf dem Stack

**Syntax:** `pushfw`

**Wirkung:** `push(flags)`

*Gruppe: Stack. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## pxor – Bitweise exklusive ODER-Verknüpfung

**Syntax:** `pxor mm, mm/m64` &nbsp; `pxor xmm, xmm/m128`

Bitweise exklusive ODER-Verknüpfung (pxor x, x löscht).

**Wirkung:** `dst = dst ^ src`

*Gruppe: SSE und MMX Ganzzahlen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rcl – Rotation nach links durch das Carry-Flag

**Syntax:** `rcl r/m8, imm8` &nbsp; `rcl r/m32, imm8` &nbsp; `rcl r/m16, imm8` &nbsp; `rcl r/m8, 1` &nbsp; `rcl r/m32, 1` &nbsp; `rcl r/m16, 1` &nbsp; `rcl r/m8, cl` &nbsp; `rcl r/m32, cl` &nbsp; …

**Wirkung:** `rotate_left(CF:dst, count) as one value of width + 1 bits`

**Flags:** OF CF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rcpps – Kehrwert (angenähert) von 4 Singles

**Syntax:** `rcpps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = 1 / src[i] (approximate)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rcpss – Kehrwert (angenähert) von einem Single

**Syntax:** `rcpss xmm, xmm/m32`

**Wirkung:** `dst[0] = 1 / src[0] (approximate); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rcr – Rotation nach rechts durch das Carry-Flag

**Syntax:** `rcr r/m8, imm8` &nbsp; `rcr r/m32, imm8` &nbsp; `rcr r/m16, imm8` &nbsp; `rcr r/m8, 1` &nbsp; `rcr r/m32, 1` &nbsp; `rcr r/m16, 1` &nbsp; `rcr r/m8, cl` &nbsp; `rcr r/m32, cl` &nbsp; …

**Wirkung:** `rotate_right(CF:dst, count) as one value of width + 1 bits`

**Flags:** OF CF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdfsbase – Lesen der Basisadresse von fs/gs

**Syntax:** `rdfsbase r32` &nbsp; `rdfsbase r64`

**Wirkung:** `dst = base address of fs`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdgsbase – Lesen der Basisadresse von fs/gs

**Syntax:** `rdgsbase r32` &nbsp; `rdgsbase r64`

**Wirkung:** `dst = base address of gs`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdmsr – Lesen eines modellspezifischen Registers

**Syntax:** `rdmsr`

Lesen eines modellspezifischen Registers (privilegiert).

**Wirkung:** `edx:eax = model-specific register number ecx (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdpid – Lesen der Prozessor-Kennung

**Syntax:** `rdpid r64`

**Wirkung:** `dst = id of the processor`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdpmc – Lesen eines Leistungszählers

**Syntax:** `rdpmc`

**Wirkung:** `edx:eax = performance counter number ecx`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdrand – Lesen einer Zufallszahl des Prozessors

**Syntax:** `rdrand r32` &nbsp; `rdrand r16` &nbsp; `rdrand r64`

**Wirkung:** `dst = random number from the processor; CF = 1 if it is valid`

**Flags:** OF SF ZF AF CF PF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdseed – Lesen eines Startwertes für Zufallsgeneratoren

**Syntax:** `rdseed r32` &nbsp; `rdseed r16` &nbsp; `rdseed r64`

**Wirkung:** `dst = seed value for random number generators; CF = 1 if it is valid`

**Flags:** OF SF ZF AF CF PF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdsspd – Lesen des Schatten-Stackzeigers

**Syntax:** `rdsspd r32`

**Wirkung:** `dst = shadow stack pointer`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdsspq – Lesen des Schatten-Stackzeigers

**Syntax:** `rdsspq r64`

**Wirkung:** `dst = shadow stack pointer`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdtsc – Lesen des Zeitstempelzählers (Taktzyklen)

**Syntax:** `rdtsc`

**Wirkung:** `edx:eax = time stamp counter`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rdtscp – Lesen des Zeitstempelzählers und der Prozessor-Kennung

**Syntax:** `rdtscp`

**Wirkung:** `edx:eax = time stamp counter; ecx = processor id`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ret – Rückkehr aus der Funktion

**Syntax:** `ret imm16` &nbsp; `ret`

Rückkehr aus der Funktion (die Adresse kommt vom Stack).

**Wirkung:** `rip = pop(); with imm16: rsp = rsp + imm16 afterwards`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## retf – Rückkehr aus einer Far-Funktion

**Syntax:** `retf imm16` &nbsp; `retf`

**Wirkung:** `rip = pop(); cs = pop()`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rol – Rotation nach links

**Syntax:** `rol r/m8, imm8` &nbsp; `rol r/m32, imm8` &nbsp; `rol r/m16, imm8` &nbsp; `rol r/m8, 1` &nbsp; `rol r/m32, 1` &nbsp; `rol r/m16, 1` &nbsp; `rol r/m8, cl` &nbsp; `rol r/m32, cl` &nbsp; …

**Wirkung:** `dst = rotate_left(dst, count); CF = lowest bit of the result`

**Flags:** OF CF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ror – Rotation nach rechts

**Syntax:** `ror r/m8, imm8` &nbsp; `ror r/m32, imm8` &nbsp; `ror r/m16, imm8` &nbsp; `ror r/m8, 1` &nbsp; `ror r/m32, 1` &nbsp; `ror r/m16, 1` &nbsp; `ror r/m8, cl` &nbsp; `ror r/m32, cl` &nbsp; …

**Wirkung:** `dst = rotate_right(dst, count); CF = highest bit of the result`

**Flags:** OF CF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## roundpd – Runden von 2 Doubles auf ganze Zahlen

**Syntax:** `roundpd xmm, xmm/m128, imm8`

**Wirkung:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## roundps – Runden von 4 Singles auf ganze Zahlen

**Syntax:** `roundps xmm, xmm/m128, imm8`

**Wirkung:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## roundsd – Runden eines Doubles auf eine ganze Zahl

**Syntax:** `roundsd xmm, xmm/m64, imm8`

**Wirkung:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## roundss – Runden eines Singles auf eine ganze Zahl

**Syntax:** `roundss xmm, xmm/m32, imm8`

**Wirkung:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsm – Verlassen des Systemverwaltungsmodus (SMM)

**Syntax:** `rsm`

**Wirkung:** `leave system management mode, restore the saved state`

**Flags:** all

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsqrtps – Kehrwert der Wurzel (angenähert) von 4 Singles

**Syntax:** `rsqrtps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = 1 / sqrt(src[i]) (approximate)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## rsqrtss – Kehrwert der Wurzel (angenähert) von einem Single

**Syntax:** `rsqrtss xmm, xmm/m32`

**Wirkung:** `dst[0] = 1 / sqrt(src[0]) (approximate); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sahf – Speichern von ah in die Flags

**Syntax:** `sahf`

**Wirkung:** `SF ZF AF PF CF = bits of ah`

**Flags:** SF ZF AF CF PF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## salc – Setzen von al aus CF (undokumentiert)

**Syntax:** `salc`

**Wirkung:** `al = CF ? 255 : 0`

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sar – Schieben nach rechts mit Vorzeichen

**Syntax:** `sar r/m8, imm8` &nbsp; `sar r/m32, imm8` &nbsp; `sar r/m16, imm8` &nbsp; `sar r/m8, 1` &nbsp; `sar r/m32, 1` &nbsp; `sar r/m16, 1` &nbsp; `sar r/m8, cl` &nbsp; `sar r/m32, cl` &nbsp; …

Schieben nach rechts mit Vorzeichen (Vorzeichenbit bleibt).

**Wirkung:** `dst = dst >>s count (sign bit comes in); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sbb – Subtraktion mit Borgen (CF)

**Syntax:** `sbb r/m8, r8` &nbsp; `sbb r/m32, r32` &nbsp; `sbb r/m16, r16` &nbsp; `sbb r8, r/m8` &nbsp; `sbb r32, r/m32` &nbsp; `sbb r16, r/m16` &nbsp; `sbb al, imm8` &nbsp; `sbb eax, imm32` &nbsp; …

**Wirkung:** `dst = dst - src - CF`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## scasb – Vergleich von al/ax/eax/rax mit [rdi]

**Syntax:** `scasb`

Vergleich von al/ax/eax/rax mit [rdi], rdi läuft weiter.

**Wirkung:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## scasd – Vergleich von al/ax/eax/rax mit [rdi]

**Syntax:** `scasd`

Vergleich von al/ax/eax/rax mit [rdi], rdi läuft weiter.

**Wirkung:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## scasq – Vergleich von al/ax/eax/rax mit [rdi]

**Syntax:** `scasq`

Vergleich von al/ax/eax/rax mit [rdi], rdi läuft weiter.

**Wirkung:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## scasw – Vergleich von al/ax/eax/rax mit [rdi]

**Syntax:** `scasw`

Vergleich von al/ax/eax/rax mit [rdi], rdi läuft weiter.

**Wirkung:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## seta – Setzen des Bytes auf 1

**Syntax:** `seta r/m8`

Setzen des Bytes auf 1, wenn ohne Vorzeichen größer (CF=0 und ZF=0), sonst auf 0.

**Wirkung:** `dst = (CF = 0 and ZF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setbe – Setzen des Bytes auf 1

**Syntax:** `setbe r/m8`

Setzen des Bytes auf 1, wenn ohne Vorzeichen kleiner oder gleich (CF=1 oder ZF=1), sonst auf 0.

**Wirkung:** `dst = (CF = 1 or ZF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setc – Setzen des Bytes auf 1

**Syntax:** `setc r/m8`

Setzen des Bytes auf 1, wenn Übertrag, ohne Vorzeichen kleiner (CF=1), sonst auf 0.

**Wirkung:** `dst = (CF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setg – Setzen des Bytes auf 1

**Syntax:** `setg r/m8`

Setzen des Bytes auf 1, wenn mit Vorzeichen größer (ZF=0 und SF=OF), sonst auf 0.

**Wirkung:** `dst = (ZF = 0 and SF = OF) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setge – Setzen des Bytes auf 1

**Syntax:** `setge r/m8`

Setzen des Bytes auf 1, wenn mit Vorzeichen größer oder gleich (SF=OF), sonst auf 0.

**Wirkung:** `dst = (SF = OF) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setl – Setzen des Bytes auf 1

**Syntax:** `setl r/m8`

Setzen des Bytes auf 1, wenn mit Vorzeichen kleiner (SF≠OF), sonst auf 0.

**Wirkung:** `dst = (SF != OF) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setle – Setzen des Bytes auf 1

**Syntax:** `setle r/m8`

Setzen des Bytes auf 1, wenn mit Vorzeichen kleiner oder gleich (ZF=1 oder SF≠OF), sonst auf 0.

**Wirkung:** `dst = (ZF = 1 or SF != OF) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setnc – Setzen des Bytes auf 1

**Syntax:** `setnc r/m8`

Setzen des Bytes auf 1, wenn kein Übertrag, ohne Vorzeichen größer oder gleich (CF=0), sonst auf 0.

**Wirkung:** `dst = (CF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setno – Setzen des Bytes auf 1

**Syntax:** `setno r/m8`

Setzen des Bytes auf 1, wenn kein Überlauf (OF=0), sonst auf 0.

**Wirkung:** `dst = (OF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setnp – Setzen des Bytes auf 1

**Syntax:** `setnp r/m8`

Setzen des Bytes auf 1, wenn Parität ungerade (PF=0), sonst auf 0.

**Wirkung:** `dst = (PF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setns – Setzen des Bytes auf 1

**Syntax:** `setns r/m8`

Setzen des Bytes auf 1, wenn nicht negativ (SF=0), sonst auf 0.

**Wirkung:** `dst = (SF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setnz – Setzen des Bytes auf 1

**Syntax:** `setnz r/m8`

Setzen des Bytes auf 1, wenn ungleich, Ergebnis nicht null (ZF=0), sonst auf 0.

**Wirkung:** `dst = (ZF = 0) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## seto – Setzen des Bytes auf 1

**Syntax:** `seto r/m8`

Setzen des Bytes auf 1, wenn Überlauf (OF=1), sonst auf 0.

**Wirkung:** `dst = (OF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setp – Setzen des Bytes auf 1

**Syntax:** `setp r/m8`

Setzen des Bytes auf 1, wenn Parität gerade (PF=1), sonst auf 0.

**Wirkung:** `dst = (PF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sets – Setzen des Bytes auf 1

**Syntax:** `sets r/m8`

Setzen des Bytes auf 1, wenn negativ (SF=1), sonst auf 0.

**Wirkung:** `dst = (SF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## setz – Setzen des Bytes auf 1

**Syntax:** `setz r/m8`

Setzen des Bytes auf 1, wenn gleich, Ergebnis null (ZF=1), sonst auf 0.

**Wirkung:** `dst = (ZF = 1) ? 1 : 0`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sfence – Schranke für Schreibzugriffe

**Syntax:** `sfence`

**Wirkung:** `all earlier stores are done before later stores`

*Gruppe: Schranken und Sonstiges. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sgdt – Speichern des Registers der globalen Deskriptortabelle

**Syntax:** `sgdt m`

**Wirkung:** `[m] = GDTR`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shl – Schieben nach links

**Syntax:** `shl r/m8, imm8` &nbsp; `shl r/m32, imm8` &nbsp; `shl r/m16, imm8` &nbsp; `shl r/m8, 1` &nbsp; `shl r/m32, 1` &nbsp; `shl r/m16, 1` &nbsp; `shl r/m8, cl` &nbsp; `shl r/m32, cl` &nbsp; …

Schieben nach links (Faktor 2 je Stelle), Auffüllen mit 0.

**Wirkung:** `dst = dst << count (count masked to 5 / 6 bits); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shld – Schieben nach links mit Auffüllen aus einem zweiten Register

**Syntax:** `shld r/m32, r32, imm8` &nbsp; `shld r/m16, r16, imm8` &nbsp; `shld r/m32, r32, cl` &nbsp; `shld r/m16, r16, cl` &nbsp; `shld r/m64, r64, imm8` &nbsp; `shld r/m64, r64, cl`

**Wirkung:** `dst = (dst << count) OR (src >> (width - count))`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shr – Schieben nach rechts ohne Vorzeichen

**Syntax:** `shr r/m8, imm8` &nbsp; `shr r/m32, imm8` &nbsp; `shr r/m16, imm8` &nbsp; `shr r/m8, 1` &nbsp; `shr r/m32, 1` &nbsp; `shr r/m16, 1` &nbsp; `shr r/m8, cl` &nbsp; `shr r/m32, cl` &nbsp; …

Schieben nach rechts ohne Vorzeichen, Auffüllen mit 0.

**Wirkung:** `dst = dst >> count (zeros come in); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shrd – Schieben nach rechts mit Auffüllen aus einem zweiten Register

**Syntax:** `shrd r/m32, r32, imm8` &nbsp; `shrd r/m16, r16, imm8` &nbsp; `shrd r/m32, r32, cl` &nbsp; `shrd r/m16, r16, cl` &nbsp; `shrd r/m64, r64, imm8` &nbsp; `shrd r/m64, r64, cl`

**Wirkung:** `dst = (dst >> count) OR (src << (width - count))`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Schieben und Rotieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shufpd – Mischen von Doubles aus zwei Registern nach einer Vorgabe

**Syntax:** `shufpd xmm, xmm/m128, imm8`

**Wirkung:** `dst = (dst[sel0], src[sel1]); sel = bits of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## shufps – Mischen von Singles aus zwei Registern nach einer Vorgabe

**Syntax:** `shufps xmm, xmm/m128, imm8`

**Wirkung:** `dst = (dst[sel0], dst[sel1], src[sel2], src[sel3]); sel = bit pairs of imm8`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sidt – Speichern des Registers der Interrupt-Deskriptortabelle

**Syntax:** `sidt m`

**Wirkung:** `[m] = IDTR`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sldt – Speichern des Registers der lokalen Deskriptortabelle

**Syntax:** `sldt r32/m16` &nbsp; `sldt r16` &nbsp; `sldt r64`

**Wirkung:** `dst = LDTR`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## smsw – Speichern des Maschinen-Statuswortes

**Syntax:** `smsw m`

**Wirkung:** `dst = CR0 bits 0 to 15`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrtpd – Quadratwurzel von 2 Doubles

**Syntax:** `sqrtpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = sqrt(src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrtps – Quadratwurzel von 4 Singles

**Syntax:** `sqrtps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = sqrt(src[i])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrtsd – Quadratwurzel von einem Double

**Syntax:** `sqrtsd xmm, xmm/m64`

**Wirkung:** `dst[0] = sqrt(src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sqrtss – Quadratwurzel von einem Single

**Syntax:** `sqrtss xmm, xmm/m32`

**Wirkung:** `dst[0] = sqrt(src[0]); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stac – Setzen des AC-Flags (Zugriffsschutz)

**Syntax:** `stac`

**Wirkung:** `EFLAGS.AC = 1`

**Flags:** AC

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stc – Setzen des Carry-Flags

**Syntax:** `stc`

**Wirkung:** `CF = 1`

**Flags:** CF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## std – Setzen des Richtungs-Flags

**Syntax:** `std`

Setzen des Richtungs-Flags (String-Befehle zählen abwärts).

**Wirkung:** `DF = 1`

**Flags:** DF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sti – Erlauben der Interrupts (IF=1)

**Syntax:** `sti`

**Wirkung:** `IF = 1 (effective after the next instruction)`

**Flags:** IF

*Gruppe: Flags. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stmxcsr – Speichern des SSE-Steuer- und Statusregisters

**Syntax:** `stmxcsr m`

**Wirkung:** `[m32] = MXCSR`

*Gruppe: SSE und MMX Datenbewegung. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stosb – Speichern von al/ax/eax/rax nach [rdi]

**Syntax:** `stosb`

Speichern von al/ax/eax/rax nach [rdi], rdi läuft weiter.

**Wirkung:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stosd – Speichern von al/ax/eax/rax nach [rdi]

**Syntax:** `stosd`

Speichern von al/ax/eax/rax nach [rdi], rdi läuft weiter.

**Wirkung:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stosq – Speichern von al/ax/eax/rax nach [rdi]

**Syntax:** `stosq`

Speichern von al/ax/eax/rax nach [rdi], rdi läuft weiter.

**Wirkung:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## stosw – Speichern von al/ax/eax/rax nach [rdi]

**Syntax:** `stosw`

Speichern von al/ax/eax/rax nach [rdi], rdi läuft weiter.

**Wirkung:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Gruppe: Zeichenketten. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## str – Speichern des Task-Registers

**Syntax:** `str r32/m16` &nbsp; `str r16` &nbsp; `str r64`

**Wirkung:** `dst = task register`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sub – Subtraktion der Quelle vom Ziel

**Syntax:** `sub r/m8, r8` &nbsp; `sub r/m32, r32` &nbsp; `sub r/m16, r16` &nbsp; `sub r8, r/m8` &nbsp; `sub r32, r/m32` &nbsp; `sub r16, r/m16` &nbsp; `sub al, imm8` &nbsp; `sub eax, imm32` &nbsp; …

**Wirkung:** `dst = dst - src`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subpd – Subtraktion von 2 Doubles

**Syntax:** `subpd xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] - src[i] (double)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subps – Subtraktion von 4 Singles

**Syntax:** `subps xmm, xmm/m128`

**Wirkung:** `for every element: dst[i] = dst[i] - src[i] (single)`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subsd – Subtraktion von einem Double

**Syntax:** `subsd xmm, xmm/m64`

**Wirkung:** `dst[0] = dst[0] - src[0] (double); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## subss – Subtraktion von einem Single

**Syntax:** `subss xmm, xmm/m32`

**Wirkung:** `dst[0] = dst[0] - src[0] (single); the other elements stay`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## swapgs – Tausch der gs-Basis mit dem Kernel-Wert

**Syntax:** `swapgs`

**Wirkung:** `swap(gs base, kernel gs base) (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## syscall – Aufruf des Betriebssystems (64 Bit, schnell)

**Syntax:** `syscall`

**Wirkung:** `rcx = rip of the next instruction; r11 = flags; rip = LSTAR; flags = flags & ~SFMASK; ring 0`

**Flags:** RF

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sysenter – Aufruf des Betriebssystems (32 Bit, schnell)

**Syntax:** `sysenter`

**Wirkung:** `enter ring 0 at the address in IA32_SYSENTER_EIP`

**Flags:** IF VM

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sysexit – Rückkehr aus einem Systemaufruf (32 Bit, schnell)

**Syntax:** `sysexit`

**Wirkung:** `back to ring 3: rip = rdx, rsp = rcx`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sysretd – Rückkehr aus einem Systemaufruf (schnell)

**Syntax:** `sysretd`

**Wirkung:** `rip = rcx; flags = r11; back to ring 3`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## sysretq – Rückkehr aus einem Systemaufruf (schnell)

**Syntax:** `sysretq`

**Wirkung:** `rip = rcx; flags = r11; back to ring 3`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## test – Bitweiser Test (UND), nur die Flags ändern sich

**Syntax:** `test r/m8, r8` &nbsp; `test r/m32, r32` &nbsp; `test r/m16, r16` &nbsp; `test al, imm8` &nbsp; `test eax, imm32` &nbsp; `test ax, imm16` &nbsp; `test r/m8, imm8` &nbsp; `test r/m32, imm32` &nbsp; …

**Wirkung:** `flags = dst & src (the result is thrown away); CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## tzcnt – Zählen der Nullbits am unteren Ende

**Syntax:** `tzcnt r32, r/m32` &nbsp; `tzcnt r64, r/m64`

**Wirkung:** `dst = number of trailing 0 bits of src (width if src = 0)`

**Flags:** ZF CF

*Gruppe: Arithmetik. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ucomisd – Wie comisd, ohne Ausnahme bei stillen NaN

**Syntax:** `ucomisd xmm, xmm/m64`

**Wirkung:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ucomiss – Wie comiss, ohne Ausnahme bei stillen NaN

**Syntax:** `ucomiss xmm, xmm/m32`

**Wirkung:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## ud2 – Absichtlich ungültiger Befehl

**Syntax:** `ud2`

Absichtlich ungültiger Befehl (löst eine Ausnahme aus).

**Wirkung:** `raises #UD (invalid instruction)`

*Gruppe: Sprünge, Aufrufe und Interrupts. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## unpckhpd – Verschränken der oberen Doubles zweier Register

**Syntax:** `unpckhpd xmm, xmm/m128`

**Wirkung:** `dst = (dst[1], src[1])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## unpckhps – Verschränken der oberen Singles zweier Register

**Syntax:** `unpckhps xmm, xmm/m128`

**Wirkung:** `dst = (dst[2], src[2], dst[3], src[3])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## unpcklpd – Verschränken der unteren Doubles zweier Register

**Syntax:** `unpcklpd xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## unpcklps – Verschränken der unteren Singles zweier Register

**Syntax:** `unpcklps xmm, xmm/m128`

**Wirkung:** `dst = (dst[0], src[0], dst[1], src[1])`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## verr – Prüfung eines Segments auf Lesbarkeit

**Syntax:** `verr r/m16`

**Wirkung:** `ZF = 1 if the segment src can be read`

**Flags:** ZF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## verw – Prüfung eines Segments auf Schreibbarkeit

**Syntax:** `verw r/m16`

**Wirkung:** `ZF = 1 if the segment src can be written`

**Flags:** ZF

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wbinvd – Zurückschreiben und Leeren der Caches

**Syntax:** `wbinvd`

Zurückschreiben und Leeren der Caches (privilegiert).

**Wirkung:** `write back and empty the caches (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wrfsbase – Schreiben der Basisadresse von fs/gs

**Syntax:** `wrfsbase r32` &nbsp; `wrfsbase r64`

**Wirkung:** `base address of fs = src`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wrgsbase – Schreiben der Basisadresse von fs/gs

**Syntax:** `wrgsbase r32` &nbsp; `wrgsbase r64`

**Wirkung:** `base address of gs = src`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## wrmsr – Schreiben eines modellspezifischen Registers

**Syntax:** `wrmsr`

Schreiben eines modellspezifischen Registers (privilegiert).

**Wirkung:** `model-specific register number ecx = edx:eax (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xadd – Tauschen und Addieren (atomar mit lock)

**Syntax:** `xadd r/m8, r8` &nbsp; `xadd r/m32, r32` &nbsp; `xadd r/m16, r16` &nbsp; `xadd r/m64, r64`

**Wirkung:** `tmp = dst + src; src = dst; dst = tmp`

**Flags:** OF SF ZF AF CF PF

*Gruppe: Vergleichen und Tauschen. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xchg – Vertauschen der beiden Operanden

**Syntax:** `xchg r/m8, r8` &nbsp; `xchg r/m32, r32` &nbsp; `xchg r/m16, r16` &nbsp; `xchg r32, eax` &nbsp; `xchg r16, ax` &nbsp; `xchg r/m64, r64` &nbsp; `xchg r64, rax`

Vertauschen der beiden Operanden (mit Speicher: atomar).

**Wirkung:** `tmp = dst; dst = src; src = tmp`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xgetbv – Lesen eines erweiterten Steuerregisters (XCR)

**Syntax:** `xgetbv`

**Wirkung:** `edx:eax = extended control register number ecx`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xlatb – Laden von al aus der Tabelle bei [rbx + al]

**Syntax:** `xlatb`

**Wirkung:** `al = [rbx + zext(al)]`

*Gruppe: Daten kopieren. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xor – Bitweise exklusive ODER-Verknüpfung

**Syntax:** `xor r/m8, r8` &nbsp; `xor r/m32, r32` &nbsp; `xor r/m16, r16` &nbsp; `xor r8, r/m8` &nbsp; `xor r32, r/m32` &nbsp; `xor r16, r/m16` &nbsp; `xor al, imm8` &nbsp; `xor eax, imm32` &nbsp; …

Bitweise exklusive ODER-Verknüpfung (xor eax, eax setzt auf 0).

**Wirkung:** `dst = dst ^ src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefiniert: AF

*Gruppe: Logik und Bits. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xorpd – Bitweise exklusive ODER-Verknüpfung

**Syntax:** `xorpd xmm, xmm/m128`

Bitweise exklusive ODER-Verknüpfung (xorps x, x löscht).

**Wirkung:** `dst = dst ^ src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xorps – Bitweise exklusive ODER-Verknüpfung

**Syntax:** `xorps xmm, xmm/m128`

Bitweise exklusive ODER-Verknüpfung (xorps x, x löscht).

**Wirkung:** `dst = dst ^ src`

*Gruppe: SSE Gleitkomma. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xrstor – Wiederherstellen des erweiterten Prozessorzustands

**Syntax:** `xrstor m`

**Wirkung:** `the state components selected by edx:eax = [m]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xrstor64 – Wiederherstellen des erweiterten Prozessorzustands

**Syntax:** `xrstor64 m`

**Wirkung:** `the state components selected by edx:eax = [m]`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsave – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsave m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsave64 – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsave64 m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsavec – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsavec m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsavec64 – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsavec64 m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsaveopt – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsaveopt m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsaveopt64 – Sichern des erweiterten Prozessorzustands

**Syntax:** `xsaveopt64 m`

Sichern des erweiterten Prozessorzustands (SSE, AVX ...).

**Wirkung:** `[m] = the state components selected by edx:eax`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*

## xsetbv – Schreiben eines erweiterten Steuerregisters (XCR)

**Syntax:** `xsetbv`

**Wirkung:** `extended control register number ecx = edx:eax (privileged)`

*Gruppe: System und Privilegien. Kurzbeschreibung aus der Befehlsreferenz; eine ausführliche Erklärung gibt es dafür noch nicht.*
