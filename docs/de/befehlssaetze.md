# Die Befehlssätze von Asmonite: was da ist, was fehlt

Asmonite assembliert und zerlegt sechs Architekturen: x86 (i386), x64, ARM32 (Thumb-2), ARM64 (AArch64), RISC-V
(RV32 und RV64) und Xtensa. Assembler und Disassembler benutzen dafür jeweils dieselben Tabellen, und die
Befehlsreferenz auf der Website (asmonite.com, „Befehlsreferenz“) wird daraus erzeugt. Diese Seite sagt, welche
Befehlsgruppen jede Architektur hat und welche noch fehlen, und was das auf den Boards und Rechnern bedeutet, auf
denen Asmonite Programme laufen lässt.

Stand: Version 0.11.0.

## x86 und x64

| Da | Fehlt |
|---|---|
| Die Grundbefehle von i386 und x64, die Systembefehle (`cpuid`, `rdtsc`, `lgdt`, `invlpg` …) | **AVX, AVX2, FMA**: alles mit dem VEX-Präfix (`vaddps`, `vpaddd`, `vfmadd231ps` …) und die YMM-Register |
| x87 (`fld`, `fadd`, `fsqrt` …) | **AVX-512** (EVEX-Präfix, ZMM- und Maskenregister) |
| MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2 | **BMI1 und BMI2**: `andn`, `bextr`, `blsi`, `blsr`, `blsmsk`, `bzhi`, `pdep`, `pext`, `rorx`, `sarx`, `shlx`, `shrx`, `mulx` |
| AES-NI, `pclmulqdq`, `crc32`, `rdrand`, `rdseed` | **SHA**: `sha1rnds4`, `sha256rnds2` … |
| `popcnt`, `lzcnt`, `tzcnt`, `adcx`, `adox` | |

AVX, AVX2, FMA und BMI2 laufen auf praktisch jedem PC der letzten zehn Jahre; Compiler benutzen sie ganz
selbstverständlich. Dismonite zeigt solche Befehle in einem Programm als unbekannte Bytes.

## ARM32 (Thumb-2)

| Da | Fehlt |
|---|---|
| Die 16- und 32-Bit-Befehle von Thumb, `sdiv`, `udiv`, `smull`, `smlal`, IT-Blöcke | **Die DSP-Erweiterung**: `smlabb`, `smuad`, `qadd`, `qsub`, `sadd8`, `uadd8`, `ssat16`, `pkhbt`, `sel` … |
| VFP, Gleitkomma (`vadd`, `vmul`, `vdiv`, `vsqrt`, `vfma`, `vcvt`, `vldr`, `vldm`, `vmrs` …) | **NEON**, das SIMD von ARMv7-A (`vld1`, `vadd.i8`, `vmull` …) |
| Die Systembefehle (`mrs`, `msr`, `cpsid`, `cpsie`, Barrieren); `mrs`/`msr` mit den Spezialregistern des Cortex-M (`primask`, `control`, `msp` …) im Assembler | Der Disassembler zeigt `mrs`/`msr` mit den Spezialregistern des Cortex-M noch nicht |

Der Cortex-M33 des **Raspberry Pi Pico 2** hat die DSP-Erweiterung und eine FPU mit einfacher Genauigkeit; der
Cortex-M3 der Blue Pill und der Cortex-M0+ des Pico haben beides nicht. NEON gibt es nur auf den größeren Kernen
(32-Bit-Programme unter Windows on ARM), nie auf einem Mikrocontroller.

## ARM64 (AArch64)

| Da | Fehlt |
|---|---|
| Die Grundbefehle, Gleitkomma, das Neon-SIMD (`ld1`, `addv`, `dup` …), `sdot`/`udot` | **SVE, SVE2, SME** (skalierbare Vektoren und Matrizen) |
| Die Atomics von LSE (`cas`, `ldadd`, `swp` …), Krypto (`aese`, `sha256h` …), System (`mrs`, `msr`, `svc`, `eret`) | |

SVE gibt es auf Servern und wenigen Telefonen; die Windows-on-ARM-Rechner, auf denen Asmonite debuggt, haben es nicht.

## RISC-V (RV32, RV64)

| Da | Fehlt |
|---|---|
| RV32I und RV64I, M (Multiplikation, Division), A (Atomics), C (komprimiert) | **F und D**, Gleitkomma mit einfacher und doppelter Genauigkeit (`flw`, `fadd.s`, `fld`, `fmadd.d` …) und die Register `f0` bis `f31` |
| Bit-Manipulation Zba, Zbb, Zbs, Zbc, Zbkb, das komprimierte Zcb | **V**, die Vektor-Erweiterung (`vsetvli`, `vle32.v`, `vadd.vv` …) |
| Zicsr, Zifencei, `mret`, `sret`, `wfi`, `ecall`, `ebreak` | Zfh (halbe Genauigkeit), die Krypto-Erweiterungen Zk, `sfence.vma` |

Der C906-Kern des **Allwinner D1** (MangoPi MQ-Pro) hat F und D, dazu eine Vektoreinheit in der alten, nicht
ratifizierten Fassung 0.7.1. Die Hazard3-Kerne des Pico 2 und der Kern des ESP32-C3 haben kein Gleitkomma.

## Xtensa (ESP32-S3, ESP32)

| Da | Fehlt |
|---|---|
| Die Grundbefehle, die Registerfenster (`entry`, `retw`, `call8` …), die Schleifen ohne Zusatzaufwand (`loop`, `loopnez`) | **MAC16**, das 16-Bit-Multiplizieren-Addieren des ursprünglichen ESP32 (`mula.dd.ll`, `umul.aa.ll` …) |
| `mull`, `muluh`, `quos`, `rems` …, die Boolean-Register (`andb`, `orb` …), `min`, `max`, `clamps`, `sext`, `nsa` | **Die `ee.*`-Befehle** des ESP32-S3 (sein SIMD für KI und Signalverarbeitung; von Espressif nur zum Teil dokumentiert) |
| Gleitkomma mit einfacher Genauigkeit (`add.s`, `madd.s`, `lsi` …), die Systembefehle (`rsr`, `wsr`, `rfe`, `waiti` …) | |

## Kurz

| Architektur | Fehlende Gruppen |
|---|---|
| x86 / x64 | AVX, AVX2, FMA, AVX-512, BMI1/BMI2, SHA |
| ARM32 | DSP-Erweiterung, NEON; die Spezialregister des Cortex-M im Disassembler |
| ARM64 | SVE, SVE2, SME |
| RISC-V | F, D, V, Zfh, Zk |
| Xtensa | MAC16, `ee.*` |

Was in den Tabellen steht, zeigt die Befehlsreferenz jeder Architektur auf der Website, und in Asmonite F1 auf einem
Befehl.
