# The instruction sets of Asmonite: what is there, what is missing

Asmonite assembles and disassembles six architectures: x86 (i386), x64, ARM32 (Thumb-2), ARM64 (AArch64), RISC-V
(RV32 and RV64) and Xtensa. The assembler and the disassembler of each use the same tables, and the instruction
reference on the website (asmonite.com, "Instruction reference") is made from them. This page says which groups of
instructions each one has and which are still missing, and what that means on the boards and computers Asmonite
runs programs on.

Status: version 0.11.0.

## x86 and x64

| There | Missing |
|---|---|
| The base instructions of i386 and x64, the system instructions (`cpuid`, `rdtsc`, `lgdt`, `invlpg` …) | **AVX, AVX2, FMA**: everything with the VEX prefix (`vaddps`, `vpaddd`, `vfmadd231ps` …) and the YMM registers |
| x87 (`fld`, `fadd`, `fsqrt` …) | **AVX-512** (EVEX prefix, ZMM and mask registers) |
| MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2 | **BMI1 and BMI2**: `andn`, `bextr`, `blsi`, `blsr`, `blsmsk`, `bzhi`, `pdep`, `pext`, `rorx`, `sarx`, `shlx`, `shrx`, `mulx` |
| AES-NI, `pclmulqdq`, `crc32`, `rdrand`, `rdseed` | **SHA**: `sha1rnds4`, `sha256rnds2` … |
| `popcnt`, `lzcnt`, `tzcnt`, `adcx`, `adox` | |

AVX, AVX2, FMA and BMI2 run on practically every PC of the last ten years; compilers use them freely. Dismonite shows
such instructions in a program as unknown bytes.

## ARM32 (Thumb-2)

| There | Missing |
|---|---|
| The 16-bit and 32-bit Thumb instructions, `sdiv`, `udiv`, `smull`, `smlal`, IT blocks | **The DSP extension**: `smlabb`, `smuad`, `qadd`, `qsub`, `sadd8`, `uadd8`, `ssat16`, `pkhbt`, `sel` … |
| VFP, floating point (`vadd`, `vmul`, `vdiv`, `vsqrt`, `vfma`, `vcvt`, `vldr`, `vldm`, `vmrs` …) | **NEON**, the SIMD of ARMv7-A (`vld1`, `vadd.i8`, `vmull` …) |
| The system instructions (`mrs`, `msr`, `cpsid`, `cpsie`, barriers); `mrs`/`msr` with the special registers of the Cortex-M (`primask`, `control`, `msp` …) in the assembler | The disassembler does not show `mrs`/`msr` with the special registers of the Cortex-M yet |

The Cortex-M33 of the **Raspberry Pi Pico 2** has the DSP extension and a single precision FPU; the Cortex-M3 of the
Blue Pill and the Cortex-M0+ of the Pico have neither. NEON is only on the bigger cores (32-bit programs on Windows on
ARM), never on a microcontroller.

## ARM64 (AArch64)

| There | Missing |
|---|---|
| The base instructions, floating point, the Neon SIMD (`ld1`, `addv`, `dup` …), `sdot`/`udot` | **SVE, SVE2, SME** (scalable vectors and matrices) |
| The atomics of LSE (`cas`, `ldadd`, `swp` …), crypto (`aese`, `sha256h` …), system (`mrs`, `msr`, `svc`, `eret`) | |

SVE is on servers and on few phones; the Windows on ARM computers Asmonite debugs on have none.

## RISC-V (RV32, RV64)

| There | Missing |
|---|---|
| RV32I and RV64I, M (multiply, divide), A (atomics), C (compressed) | **F and D**, floating point with single and double precision (`flw`, `fadd.s`, `fld`, `fmadd.d` …) and the registers `f0` to `f31` |
| Bit manipulation Zba, Zbb, Zbs, Zbc, Zbkb, the compressed Zcb | **V**, the vector extension (`vsetvli`, `vle32.v`, `vadd.vv` …) |
| Zicsr, Zifencei, `mret`, `sret`, `wfi`, `ecall`, `ebreak` | Zfh (half precision), the crypto extensions Zk, `sfence.vma` |

The C906 core of the **Allwinner D1** (MangoPi MQ-Pro) has F and D, and a vector unit of the old, not ratified version
0.7.1. The Hazard3 cores of the Pico 2 and the core of the ESP32-C3 have no floating point.

## Xtensa (ESP32-S3, ESP32)

| There | Missing |
|---|---|
| The base instructions, the register windows (`entry`, `retw`, `call8` …), the zero-overhead loops (`loop`, `loopnez`) | **MAC16**, the 16-bit multiply-accumulate unit of the original ESP32 (`mula.dd.ll`, `umul.aa.ll` …) |
| `mull`, `muluh`, `quos`, `rems` …, the boolean registers (`andb`, `orb` …), `min`, `max`, `clamps`, `sext`, `nsa` | **The `ee.*` instructions** of the ESP32-S3 (its SIMD for AI and signal processing; documented only partly by Espressif) |
| Floating point with single precision (`add.s`, `madd.s`, `lsi` …), the system instructions (`rsr`, `wsr`, `rfe`, `waiti` …) | |

## In short

| Architecture | Missing groups |
|---|---|
| x86 / x64 | AVX, AVX2, FMA, AVX-512, BMI1/BMI2, SHA |
| ARM32 | DSP extension, NEON; the special registers of the Cortex-M in the disassembler |
| ARM64 | SVE, SVE2, SME |
| RISC-V | F, D, V, Zfh, Zk |
| Xtensa | MAC16, `ee.*` |

What is in the tables can be looked up on the website, in the instruction reference of each architecture, and with
F1 on an instruction in Asmonite.
