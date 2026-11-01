# Der Asmonite-Assembler im Vergleich zu NASM

Der Quelltext sieht aus wie NASM (Intel-Syntax, `;` als Kommentar, `mov eax,[ebx+ecx*4+8]`),
und der Disassembler gibt NASM-Schreibweise aus. Der Assembler ist aber **nicht NASM-kompatibel**.
Diese Seite listet, wo er abweicht. Jede Angabe ist mit `asmoc` ausprobiert (Stand 2026-10-06);
die Bytes stehen dabei, wo sie helfen.

Grundidee: Asmonite baut Programme **Byte für Byte aus dem Quelltext** nach (jedes Byte der
EXE steht im Quelltext, auch der PE-Header). Deshalb gibt es viele Dinge nicht, die ein
Programmierer-Assembler wie NASM bietet (Makros, Linker-Direktiven), und einige,
die NASM nicht kennt (Wahl der Kodierung, `section <Adresse>`, `.format pe`).

## 1. Aufbau und Direktiven

| NASM | Asmonite |
|---|---|
| `bits 16` / `bits 32` | `.arch x86_real` / `.arch i386` (Standard: 32 Bit). `bits 32` ist ein Fehler (`unexpected "32"`), ebenso `use32` (`unsupported instruction`). |
| `org 0x100` setzt die Ladeadresse, erzeugt keine Bytes | `org 0x100` füllt die Ausgabe mit `00` bis zur **Dateiposition** 0x100 (nach einem `nop` ist die Datei 257 Bytes lang). Liegt die Position schon dahinter, ist das ein **Fehler** (`org 0x1: the output is already at 0x3`), seit 2026-10-07; vorher wurde sie still zurückgesetzt und spätere Bytes überschrieben. `align 0x200` füllt bis zum nächsten Vielfachen. |
| `section .text`, `.data`, `.bss` | `section <Zahl>`: beginnt an der aktuellen Dateiposition eine Section mit dieser virtuellen Adresse (RVA), z. B. `section 0x1000`. Der Name wird nicht ausgewertet. Siehe `src/tests/cases/section_three.asm`. |
| – | `segment <Zahl>` (DOS-Programme): beginnt ein Segment mit diesem Segmentwert; `segment 0` markiert außerdem den Anfang des Lademoduls (was davor steht, der MZ-Header, zählt für die Segmentadressen nicht mit). |
| `align 4` füllt Code mit `nop` | `align 4` füllt immer mit `00`. |
| `global`, `extern` | gibt es nicht (`unknown instruction: "global"`). Importe: `.import` (nur mit `.format pe`). |
| `resb 4`, `resw`, `resd`, `resq` | mit `.format pe` nur am Ende einer Section (`.code`/`.data`): der Bereich steht nicht in der Datei (VirtualSize > RawSize). Danach nur Labels und weitere `resX`. Ohne `.format pe` Nullbytes. |
| `x equ 5` | wie NASM: `name equ ausdruck`, auch hinter der Verwendung; die Zeile schreibt keine Bytes. Siehe [Ausdrücke](#2-zahlen-und-ausdrücke). |
| `times 4 db 0`, `incbin` | gibt es nicht (Fehler `unknown instruction` oder `unexpected …`). |
| Makros, `%define`, `%include` | gibt es nicht, es gibt keinen Präprozessor. |
| `$`, `$$` | wie NASM: `$` ist die Adresse der Zeile, `$$` der Anfang des Abschnitts (hinter `org`, `section`, `segment`, `.code`, `.data` oder der Anfang der Datei): `len equ $-msg`, `dd $-start`. |
| `db 'AB', 0, 10` | wie NASM. Nur **einfache** Anführungszeichen: `db "AB"` ist ein Fehler. |
| `dw`, `dd` | wie NASM. `dq` gibt es nicht. |
| `dw __utf16__('AB')` | `du 'AB', 0`: jedes Zeichen als 16-Bit-Wort (UTF-16, Little Endian), eine Zahl ebenso (`du 'Gr', 0x00E4, 'n', 0`). Nur in Asmonite. |
| `dd label` | ergibt die **virtuelle Adresse** (ImageBase + RVA, Standard-ImageBase 0x400000, änderbar mit `.imagebase 0x10000000`), nicht den Abstand vom Anfang. Ebenso ein Label als Adresse im Befehl (`mov eax,[label]`, `push dword label`). |
| – | `rva label` schreibt die RVA (32 Bit), `rel32 label` den 32-Bit-Abstand von seinem Ende bis zum Label. Nur in Asmonite. |
| – | `codeend` trägt in einen von Hand geschriebenen PE-Header (Offset 0x180) die Größe des Codes ein: Ausgabelänge − 0x200. Nur in Asmonite. |
| – | `.format binary` / `pe [console\|gui]`, `.import dll name`, `.code`, `.data`, `.entry label`: erzeugen PE-Header und Importtabelle selbst, siehe [src/assembler/README.md](../../src/assembler/README.md). Nur in Asmonite. |

## 2. Zahlen und Ausdrücke

| NASM | Asmonite |
|---|---|
| `0x1F`, Dezimal, `-1` | wie NASM. `017` ist wie bei NASM dezimal 17. |
| `1Fh`, `0b101`, `101b` | gehen (der Assembler schreibt sie als `0x1F` und Dezimal, bevor der Kern sie sieht). |
| `0o17`, `1_000` | gibt es nicht (`invalid number`). |
| `'A'` | wie NASM (ein Zeichen); `db 'AB'` schreibt zwei Bytes. |
| `db 256` | Fehler (`value out of range for db`); NASM warnt und schneidet ab. |
| `1+2`, `'A'+1`, `end-start`, `msg_len equ $-msg` | **wie NASM**: `* / % + - << >> & ^ \| ~` und Klammern, überall wo eine Zahl steht (Operanden, `db`, `dw`, `dd`, `dq`, `resb`, `align`, `org`); die Differenz zweier Labels ist eine Zahl; `label+4` und `label-4` sind Adressen (`mov eax, table+4`, `dd table+4`; nicht bei Sprung und Aufruf). `/` teilt mit Vorzeichen (NASM: `/` ohne, `//` mit Vorzeichen); `%` ist der Rest; ein `%%` gibt es nicht. Eine Differenz von Labels lässt den Assembler mehrmals laufen (bis die Adressen gleich bleiben). |

## 3. Namen, Groß-/Kleinschreibung, Kommentare

| NASM | Asmonite |
|---|---|
| Labels unterscheiden Groß-/Kleinschreibung | **Labels nicht**: `L1` und `l1` sind dasselbe Label. |
| `label:` mit Doppelpunkt | Doppelpunkt ist **optional**: `l1` allein in einer Zeile oder `l1 nop` ist ein Label. Ausnahme: Ein x86-Befehl, den der Assembler nicht kennt (`cpuid`, `pause`, `str`, …), ist allein in einer Zeile ein Fehler (`unsupported instruction`); als Label braucht er den Doppelpunkt (`str:`) oder eine Anweisung dahinter (`str db 'x'`). Ein beliebiger anderer Name allein (auch ein Tippfehler wie `nopp`) ist ein Label. |
| `.local` ist ein lokales Label (gilt bis zum nächsten globalen) | `.l` ist ein gewöhnliches Label **ohne Bereich**: zwei `.l` in einer Datei sind ein Fehler (`redefinition of Label`). |
| Befehle: Groß-/Kleinschreibung egal | egal, **aber**: Beginnt ein Befehl mit einem **Großbuchstaben**, wählt der Assembler die **zweite Kodierung**, wenn es zwei gibt: `mov eax,ebx` = `8B C3`, `MOV eax,ebx` = `89 D8`. Damit lässt sich ein Programm byte-genau nachbauen. Register in Großbuchstaben ändern nichts (`mov EAX,EBX` = `8B C3`). |
| Kommentare `;` | nur `;`. `#` und `//` sind Fehler. |
| Label und Befehl in einer Zeile (`l: db 1`) | geht. Zwei Befehle in einer Zeile gehen nicht (`nop nop` ist ein Fehler), wie bei NASM. |

## 4. Sprünge und Aufrufe

| NASM | Asmonite |
|---|---|
| `jmp label`, `jmp short label`, `jmp near label` | wie NASM. Ohne Angabe wählt der Assembler die kürzeste Form. |
| `jmp 0x401000` springt an die **Adresse** | eine Zahl ist die **Verschiebung**: `jmp 5` = `EB 05`, `call 0x10` = `E8 10 00 00 00`, `jz 0x10` = `74 10`. |
| – | `jmp short -2`, `jz near +300`, `call near -5`: Größe und Verschiebung **mit Vorzeichen**, vom Ende des Befehls aus. So schreibt Dismonite seinen Export (`jmp +5` = nur die Verschiebung, kürzeste Form). `jmp short +200` ist ein Fehler. |
| `jmp far 0x1234:0x5678` | wie NASM; `jmp 0x1234:0x5678` geht auch (`EA 78 56 34 12` in `.arch x86_real`). |
| `loop label`, `jecxz label`, `jcxz label` | mit Label nur **mit `short`**: `loop short l` geht, `loop l` ist ein Fehler (`cmd not found`). `loop short -2` geht. |
| `ret`, `retn`, `retf`, `ret 4` | wie NASM. |
| `jmp [eax]`, `call [eax]`, `jmp eax` | wie NASM (`FF 20`, `FF 10`, `FF E0`). |

## 5. Operanden und Adressierung

| NASM | Asmonite |
|---|---|
| `mov byte [ebx], 1` | wie NASM; zusätzlich `byte ptr [ebx]` (MASM-Schreibweise). Größen: `byte`, `word`, `dword`; `mov word [ebx],0` = `66 C7 03 00 00`. Bestimmt ein Register die Größe schon, gilt das Register (`les bx,dword [x]` in 16 Bit ohne `66`). |
| `[ebx+ecx*4+8]`, `[es:ebx]`, `es mov eax,[ebx]` | wie NASM. |
| `mov eax, label` / `mov eax, [label]` | wie NASM: Adresse als Zahl / Speicher am Label. `mov eax, offset label` (MASM) gibt es nicht. |
| `mov eax,[label+4]`, `[tab+ebx*4+8]`, `[ebp-4]`, `[0x401000+4]` | wie NASM: Labels, Zahlen und Register lassen sich in einer Adresse mischen, Zahlen werden addiert, ein Minus setzt die Adresse fort. Ein Label in der Adresse ist die 32-Bit-Verschiebung (16 Bit bei 16-Bit-Adressierung). Ausdrücke wie `[tab+2*4]` oder `[a-b]` gehen nicht. |
| `[eax+0x80]` ist `[eax+128]` (32-Bit-Verschiebung `8B 80 80 00 00 00`) | **Achtung, siehe Abschnitt 7:** Eine Zahl von 0 bis 255 wird als 8-Bit-Verschiebung geschrieben, `[eax+0x80]` und `[eax+128]` ergeben `8B 40 80` und das ist `[eax-128]`. Ab 256 ist die Verschiebung 32 Bit, kleine negative Zahlen (-128 bis -1) sind 8 Bit. Mit `dword` in der Klammer wird sie 32 Bit: `[dword eax+0x80]` = `8B 80 80 00 00 00`. |
| `push word 5` ergibt `66 6A 05` (32 Bit) | wie NASM. `push byte 5` = `6A 05`. |
| `mul ebx`, `div ebx`, `idiv ebx` | der Akkumulator steht mit: `mul eax,ebx` (`F7 E3`), `div al,bl` (`F6 F3`). `mul ebx` ist ein Fehler (`cmd not found`). |
| `imul ebx`, `imul eax,ebx`, `imul eax,[ebx],10`, `imul eax,10` | wie NASM (seit 2026-10-06): ein Operand `F7 EB`, zwei `0F AF C3`, drei `6B 03 0A`, `imul eax,10` = `imul eax,eax,10`. Früher war `imul eax,ebx` die Einoperand-Form `F7 EB`; die ältere Schreibweise `imul al,bl` (= `imul bl`) geht noch. |
| `.arch`-Größe | Ohne `.arch` gilt 32 Bit: `mov ax,5` = `66 B8 05 00`. In `.arch x86_real` ist es `B8 05 00` und `mov eax,5` hat `66`. |
| `movsd`, `stosd`, `pushad` … | Namen mit Größe wie bei NASM, siehe [src/assembler/README.md](../../src/assembler/README.md). |

## 6. Befehlssatz

Der Assembler kennt **177 Mnemonics** (393 Kodierungen). Alles, was ein 386-Programm normalerweise
braucht, ist dabei; **nicht** vorhanden sind unter anderem:

- die gesamte **x87-FPU** (`fld`, `fstp`, `fadd`, …), **MMX/SSE** (`movaps`, …)
- `cmovcc`, `bswap`, `cmpxchg`, `xadd`, `shld`, `cpuid`, `rdtsc`, `pause`
- `lgdt`, `lidt`, `lmsw`, `lar`, `lsl`, `bound` und andere Systembefehle
- `int3` (stattdessen `int 3`)

Die aktuelle Liste der noch nicht übersetzbaren Befehle, die der Disassembler ausgibt, steht in
`src/tests/instr_known.txt` (179 Familien).

Unterstützt sind: `aaa aad aam aas adc add and bsf bsr bt btc btr bts call cbw cdq clc cld cli clts
cmc cmp cmpsb cmpsd cmpsw cwd cwde daa das dec div enter hlt idiv imul in inc insb insd insw int into
iret iretd ja jae jb jbe jc jcxz je jecxz jg jge jl jle jmp jna jnae jnb jnbe jnc jne jng jnge jnl jnle
jno jnp jns jnz jo jp jpe jpo js jz lahf lds lea leave les lock lodsb lodsd lodsw loop loope loopne
loopnz loopz mov movsb movsd movsw movsx movzx mul neg nop not or out outsb outsd outsw pop popa popad
popf popfd push pusha pushad pushf pushfd rcl rcr rep repne ret retf retn rol ror sahf sal sar sbb scasb
scasd scasw seta setae setb setbe setc sete setg setge setl setle setna setnae setnb setnbe setnc setne
setng setnge setnl setnle setno setnp setns setnz seto setp setpe setpo sets setz shl shr shrd stc std
sti stosb stosd stosw sub test wait xchg xlatb xor`
(dazu die Präfixe `rep`, `repe`, `repz`, `repne`, `repnz`, `lock` und Segment-Präfixe).

## 7. Bekannte Probleme (Fehler, keine Absicht)

Diese Punkte sind Fehler, die behoben werden sollen. Bis dahin vermeiden:

1. **Verschiebungen von 128 bis 255 sind negativ.** `mov eax,[eax+0x80]` und `mov eax,[eax+128]` werden
   zu `8B 40 80`, das ist `[eax-128]`, **ohne Meldung**. Der Grund: Ältere Quelltexte (z. B. `tpc.asm` mit 944 Stellen)
   enthalten 8-Bit-Verschiebungen als vorzeichenlose Zahl (`[0xEC+ebp]`) und müssen dieselben Bytes ergeben. Der
   Disassembler schreibt sie jetzt mit Vorzeichen (`[ebp-0x14]`). Abhilfe: `[dword eax+0x80]`. Sobald diese
   Quelltexte neu erzeugt sind, kann der Assembler 128 bis 255 wie NASM als 32-Bit-Wert nehmen.
2. **Konstanten von 128 bis 255 sind negativ**, wo der Befehl eine 8-Bit-Konstante mit Vorzeichen erweitert
   (`83 /x ib`, `6A`, `6B`): `add ebx,0xF0` wird zu `83 C3 F0`, das ist `add ebx,-16`; `push 0x80` ist
   `push -128`; `or word [ebx],0x80` verknüpft mit `0xFF80`, **ohne Meldung**. NASM nimmt dafür die lange
   Form (`81 C3 F0 00 00 00`). Der Grund ist derselbe wie bei Punkt 1: Der Disassembler schreibt `83 C0 F0` als
   `add eax,0xF0`. Abhilfe: `dword` vor die Zahl (`add ebx,dword 0xF0`). Umgekehrt wird `add ebx,-16` lang
   (`81 C3 F0 FF FF FF`) statt kurz.
3. **`section .text`** wird angenommen, der Name aber nicht ausgewertet; die Section bekommt keine Adresse.
4. **Absolute 32-Bit-Adresse in 16-Bit-Code** (`mov al,[0x12345678]` in `.arch x86_real`): Die Adresse wird
   auf 16 Bit gekürzt, das Präfix `67` fehlt.

Weitere Einschränkungen des Assemblers stehen in [src/assembler/README.md](../../src/assembler/README.md),
die Tests dazu in [src/tests/README.md](../../src/tests/README.md).
