# Instructions from the instruction reference (generated)

Made by tools/gen_help_ref.py from the tables of the assembler (tools/instr), do not edit. F1 shows a section from here when the help of the architecture has none of its own.

## aaa – ASCII adjust after an addition (BCD)

**Syntax:** `aaa`

**Operation:** `if (al & 15) > 9 or AF = 1 then { al = al + 6; ah = ah + 1; AF = CF = 1 } else { AF = CF = 0 }; al = al & 15`

**Flags:** AF CF &nbsp; undefined: OF SF ZF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## aad – ASCII adjust before a division (BCD)

**Syntax:** `aad imm8`

**Operation:** `al = ah * imm8 + al; ah = 0 (imm8 is 10 for BCD)`

**Flags:** SF ZF PF &nbsp; undefined: OF AF CF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## aam – ASCII adjust after a multiplication (BCD)

**Syntax:** `aam imm8`

**Operation:** `ah = al / imm8; al = al % imm8 (imm8 is 10 for BCD)`

**Flags:** SF ZF PF &nbsp; undefined: OF AF CF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## aas – ASCII adjust after a subtraction (BCD)

**Syntax:** `aas`

**Operation:** `if (al & 15) > 9 or AF = 1 then { al = al - 6; ah = ah - 1; AF = CF = 1 } else { AF = CF = 0 }; al = al & 15`

**Flags:** AF CF &nbsp; undefined: OF SF ZF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adc – Addition with carry (CF)

**Syntax:** `adc r/m8, r8` &nbsp; `adc r/m32, r32` &nbsp; `adc r/m16, r16` &nbsp; `adc r8, r/m8` &nbsp; `adc r32, r/m32` &nbsp; `adc r16, r/m16` &nbsp; `adc al, imm8` &nbsp; `adc eax, imm32` &nbsp; …

**Operation:** `dst = dst + src + CF`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## adcx – Addition with carry, changes only CF

**Syntax:** `adcx r32, r/m32` &nbsp; `adcx r64, r/m64`

**Operation:** `dst = dst + src + CF`

**Flags:** CF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## add – Addition of the source to the destination

**Syntax:** `add r/m8, r8` &nbsp; `add r/m32, r32` &nbsp; `add r/m16, r16` &nbsp; `add r8, r/m8` &nbsp; `add r32, r/m32` &nbsp; `add r16, r/m16` &nbsp; `add al, imm8` &nbsp; `add eax, imm32` &nbsp; …

**Operation:** `dst = dst + src`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## addpd – Addition of 2 doubles

**Syntax:** `addpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] + src[i] (double)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## addps – Addition of 4 singles

**Syntax:** `addps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] + src[i] (single)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## addsd – Addition of one double

**Syntax:** `addsd xmm, xmm/m64`

**Operation:** `dst[0] = dst[0] + src[0] (double); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## addss – Addition of one single

**Syntax:** `addss xmm, xmm/m32`

**Operation:** `dst[0] = dst[0] + src[0] (single); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## addsubpd – Alternating subtraction and addition (doubles)

**Syntax:** `addsubpd xmm, xmm/m128`

**Operation:** `even elements: dst[i] = dst[i] - src[i]; odd elements: dst[i] = dst[i] + src[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## addsubps – Alternating subtraction and addition (singles)

**Syntax:** `addsubps xmm, xmm/m128`

**Operation:** `even elements: dst[i] = dst[i] - src[i]; odd elements: dst[i] = dst[i] + src[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## adox – Addition with the overflow flag, changes only OF

**Syntax:** `adox r32, r/m32` &nbsp; `adox r64, r/m64`

**Operation:** `dst = dst + src + OF`

**Flags:** OF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## aesdec – One AES decryption round

**Syntax:** `aesdec xmm, xmm/m128`

**Operation:** `dst = inverse AES round of dst with the round key src`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## aesdeclast – The last AES decryption round

**Syntax:** `aesdeclast xmm, xmm/m128`

**Operation:** `dst = last inverse AES round of dst with the round key src`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## aesenc – One AES encryption round

**Syntax:** `aesenc xmm, xmm/m128`

**Operation:** `dst = AES round of dst with the round key src`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## aesenclast – The last AES encryption round

**Syntax:** `aesenclast xmm, xmm/m128`

**Operation:** `dst = last AES round of dst with the round key src`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## aesimc – Conversion of an AES round key for decryption

**Syntax:** `aesimc xmm, xmm/m128`

**Operation:** `dst = InvMixColumns(src)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## aeskeygenassist – Helper for AES key generation

**Syntax:** `aeskeygenassist xmm, xmm/m128, imm8`

**Operation:** `dst = helper values for the AES key schedule from src (round constant imm8)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## and – Bitwise AND

**Syntax:** `and r/m8, r8` &nbsp; `and r/m32, r32` &nbsp; `and r/m16, r16` &nbsp; `and r8, r/m8` &nbsp; `and r32, r/m32` &nbsp; `and r16, r/m16` &nbsp; `and al, imm8` &nbsp; `and eax, imm32` &nbsp; …

**Operation:** `dst = dst & src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## andnpd – Bitwise: NOT destination AND source

**Syntax:** `andnpd xmm, xmm/m128`

**Operation:** `dst = ~dst & src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## andnps – Bitwise: NOT destination AND source

**Syntax:** `andnps xmm, xmm/m128`

**Operation:** `dst = ~dst & src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## andpd – Bitwise AND

**Syntax:** `andpd xmm, xmm/m128`

**Operation:** `dst = dst & src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## andps – Bitwise AND

**Syntax:** `andps xmm, xmm/m128`

**Operation:** `dst = dst & src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## arpl – Adjustment of the requested privilege level

**Syntax:** `arpl r/m16, r16`

Adjustment of the requested privilege level (RPL) of a segment selector.

**Operation:** `if dst.RPL < src.RPL then { dst.RPL = src.RPL; ZF = 1 } else ZF = 0`

**Flags:** ZF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## blendpd – Selection of doubles from two registers by a mask

**Syntax:** `blendpd xmm, xmm/m128, imm8`

**Operation:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## blendps – Selection of singles from two registers by a mask

**Syntax:** `blendps xmm, xmm/m128, imm8`

**Operation:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## blendvpd – Selection of doubles by the sign bits of xmm0

**Syntax:** `blendvpd xmm, xmm/m128, xmm0`

**Operation:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## blendvps – Selection of singles by the sign bits of xmm0

**Syntax:** `blendvps xmm, xmm/m128, xmm0`

**Operation:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## bound – Check of an array index against bounds in memory

**Syntax:** `bound r32, m` &nbsp; `bound r16, m`

**Operation:** `raise #BR if index dst < [m] or dst > [m + size]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## bsf – Search for the lowest set bit

**Syntax:** `bsf r32, r/m32` &nbsp; `bsf r16, r/m16` &nbsp; `bsf r64, r/m64`

**Operation:** `dst = index of the lowest 1 bit of src; ZF = (src = 0), dst undefined then`

**Flags:** ZF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bsr – Search for the highest set bit

**Syntax:** `bsr r32, r/m32` &nbsp; `bsr r16, r/m16` &nbsp; `bsr r64, r/m64`

**Operation:** `dst = index of the highest 1 bit of src; ZF = (src = 0), dst undefined then`

**Flags:** ZF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bswap – Reversal of the byte order (little/big endian)

**Syntax:** `bswap r32` &nbsp; `bswap r64`

**Operation:** `dst = reverse_bytes(dst)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## bt – Copy of one bit to CF

**Syntax:** `bt r/m32, r32` &nbsp; `bt r/m16, r16` &nbsp; `bt r/m32, imm8` &nbsp; `bt r/m16, imm8` &nbsp; `bt r/m64, r64` &nbsp; `bt r/m64, imm8`

**Operation:** `CF = bit src of dst`

**Flags:** CF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## btc – Copy of one bit to CF and inversion of the bit

**Syntax:** `btc r/m32, imm8` &nbsp; `btc r/m16, imm8` &nbsp; `btc r/m32, r32` &nbsp; `btc r/m16, r16` &nbsp; `btc r/m64, imm8` &nbsp; `btc r/m64, r64`

**Operation:** `CF = bit src of dst; bit src of dst = not bit`

**Flags:** CF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## btr – Copy of one bit to CF and clearing of the bit

**Syntax:** `btr r/m32, r32` &nbsp; `btr r/m16, r16` &nbsp; `btr r/m32, imm8` &nbsp; `btr r/m16, imm8` &nbsp; `btr r/m64, r64` &nbsp; `btr r/m64, imm8`

**Operation:** `CF = bit src of dst; bit src of dst = 0`

**Flags:** CF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## bts – Copy of one bit to CF and setting of the bit

**Syntax:** `bts r/m32, r32` &nbsp; `bts r/m16, r16` &nbsp; `bts r/m32, imm8` &nbsp; `bts r/m16, imm8` &nbsp; `bts r/m64, r64` &nbsp; `bts r/m64, imm8`

**Operation:** `CF = bit src of dst; bit src of dst = 1`

**Flags:** CF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## call – Call of a function (the return address is pushed)

**Syntax:** `call rel32` &nbsp; `call rel16` &nbsp; `call r/m32` &nbsp; `call m` &nbsp; `call r/m16` &nbsp; `call r/m64`

**Operation:** `push(rip of the next instruction); rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## cbw – Sign extension of al into ax

**Syntax:** `cbw`

**Operation:** `ax = sext(al)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cdq – Sign extension of eax into edx:eax

**Syntax:** `cdq`

**Operation:** `edx:eax = sext(eax)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cdqe – Sign extension of eax into rax

**Syntax:** `cdqe`

**Operation:** `rax = sext(eax)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## clac – Clearing of the AC flag (access protection)

**Syntax:** `clac`

**Operation:** `EFLAGS.AC = 0`

**Flags:** AC

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## clc – Clearing of the carry flag

**Syntax:** `clc`

**Operation:** `CF = 0`

**Flags:** CF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## cld – Clearing of the direction flag

**Syntax:** `cld`

Clearing of the direction flag (string instructions count up).

**Operation:** `DF = 0`

**Flags:** DF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## clflush – Flush of a cache line

**Syntax:** `clflush m`

**Operation:** `write back and remove the cache line of [m] from all caches`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## clflushopt – Flush of a cache line (faster, loosely ordered)

**Syntax:** `clflushopt m`

**Operation:** `write back and remove the cache line of [m] from all caches`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## cli – Disabling of interrupts (IF=0)

**Syntax:** `cli`

**Operation:** `IF = 0`

**Flags:** IF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## clts – Clearing of the task-switched flag in cr0

**Syntax:** `clts`

**Operation:** `CR0.TS = 0 (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## clwb – Write-back of a cache line without flushing it

**Syntax:** `clwb m`

**Operation:** `write back the cache line of [m], it may stay in the cache`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmc – Inversion of the carry flag

**Syntax:** `cmc`

**Operation:** `CF = not CF`

**Flags:** CF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmova – Copy only if unsigned above (CF=0 and ZF=0)

**Syntax:** `cmova r32, r/m32` &nbsp; `cmova r16, r/m16` &nbsp; `cmova r64, r/m64`

**Operation:** `if CF = 0 and ZF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovbe – Copy only if unsigned below or equal

**Syntax:** `cmovbe r32, r/m32` &nbsp; `cmovbe r16, r/m16` &nbsp; `cmovbe r64, r/m64`

Copy only if unsigned below or equal (CF=1 or ZF=1).

**Operation:** `if CF = 1 or ZF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovc – Copy only if carry, unsigned below (CF=1)

**Syntax:** `cmovc r32, r/m32` &nbsp; `cmovc r16, r/m16` &nbsp; `cmovc r64, r/m64`

**Operation:** `if CF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovg – Copy only if signed greater (ZF=0 and SF=OF)

**Syntax:** `cmovg r32, r/m32` &nbsp; `cmovg r16, r/m16` &nbsp; `cmovg r64, r/m64`

**Operation:** `if ZF = 0 and SF = OF then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovge – Copy only if signed greater or equal (SF=OF)

**Syntax:** `cmovge r32, r/m32` &nbsp; `cmovge r16, r/m16` &nbsp; `cmovge r64, r/m64`

**Operation:** `if SF = OF then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovl – Copy only if signed less (SF≠OF)

**Syntax:** `cmovl r32, r/m32` &nbsp; `cmovl r16, r/m16` &nbsp; `cmovl r64, r/m64`

**Operation:** `if SF != OF then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovle – Copy only if signed less or equal (ZF=1 or SF≠OF)

**Syntax:** `cmovle r32, r/m32` &nbsp; `cmovle r16, r/m16` &nbsp; `cmovle r64, r/m64`

**Operation:** `if ZF = 1 or SF != OF then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovnc – Copy only if no carry

**Syntax:** `cmovnc r32, r/m32` &nbsp; `cmovnc r16, r/m16` &nbsp; `cmovnc r64, r/m64`

Copy only if no carry, unsigned above or equal (CF=0).

**Operation:** `if CF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovno – Copy only if no overflow (OF=0)

**Syntax:** `cmovno r32, r/m32` &nbsp; `cmovno r16, r/m16` &nbsp; `cmovno r64, r/m64`

**Operation:** `if OF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovnp – Copy only if parity odd (PF=0)

**Syntax:** `cmovnp r32, r/m32` &nbsp; `cmovnp r16, r/m16` &nbsp; `cmovnp r64, r/m64`

**Operation:** `if PF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovns – Copy only if not negative (SF=0)

**Syntax:** `cmovns r32, r/m32` &nbsp; `cmovns r16, r/m16` &nbsp; `cmovns r64, r/m64`

**Operation:** `if SF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovnz – Copy only if not equal, result not zero (ZF=0)

**Syntax:** `cmovnz r32, r/m32` &nbsp; `cmovnz r16, r/m16` &nbsp; `cmovnz r64, r/m64`

**Operation:** `if ZF = 0 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovo – Copy only if overflow (OF=1)

**Syntax:** `cmovo r32, r/m32` &nbsp; `cmovo r16, r/m16` &nbsp; `cmovo r64, r/m64`

**Operation:** `if OF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovp – Copy only if parity even (PF=1)

**Syntax:** `cmovp r32, r/m32` &nbsp; `cmovp r16, r/m16` &nbsp; `cmovp r64, r/m64`

**Operation:** `if PF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovs – Copy only if negative (SF=1)

**Syntax:** `cmovs r32, r/m32` &nbsp; `cmovs r16, r/m16` &nbsp; `cmovs r64, r/m64`

**Operation:** `if SF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmovz – Copy only if equal, result zero (ZF=1)

**Syntax:** `cmovz r32, r/m32` &nbsp; `cmovz r16, r/m16` &nbsp; `cmovz r64, r/m64`

**Operation:** `if ZF = 1 then dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmp – Comparison

**Syntax:** `cmp r/m8, r8` &nbsp; `cmp r/m32, r32` &nbsp; `cmp r/m16, r16` &nbsp; `cmp r8, r/m8` &nbsp; `cmp r32, r/m32` &nbsp; `cmp r16, r/m16` &nbsp; `cmp al, imm8` &nbsp; `cmp eax, imm32` &nbsp; …

Comparison (destination minus source), only the flags change.

**Operation:** `flags = dst - src (the result is thrown away)`

**Flags:** OF SF ZF AF CF PF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpeqpd – Comparison of 2 doubles for equal

**Syntax:** `cmpeqpd xmm, xmm/m128`

Comparison of 2 doubles for equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpeqps – Comparison of 4 singles for equal

**Syntax:** `cmpeqps xmm, xmm/m128`

Comparison of 4 singles for equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpeqsd – Comparison of one double for equal

**Syntax:** `cmpeqsd xmm, xmm/m64`

Comparison of one double for equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpeqss – Comparison of one single for equal

**Syntax:** `cmpeqss xmm, xmm/m32`

Comparison of one single for equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] eq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmplepd – Comparison of 2 doubles for less or equal

**Syntax:** `cmplepd xmm, xmm/m128`

Comparison of 2 doubles for less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpleps – Comparison of 4 singles for less or equal

**Syntax:** `cmpleps xmm, xmm/m128`

Comparison of 4 singles for less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmplesd – Comparison of one double for less or equal

**Syntax:** `cmplesd xmm, xmm/m64`

Comparison of one double for less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpless – Comparison of one single for less or equal

**Syntax:** `cmpless xmm, xmm/m32`

Comparison of one single for less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] le src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpltpd – Comparison of 2 doubles for less

**Syntax:** `cmpltpd xmm, xmm/m128`

Comparison of 2 doubles for less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpltps – Comparison of 4 singles for less

**Syntax:** `cmpltps xmm, xmm/m128`

Comparison of 4 singles for less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpltsd – Comparison of one double for less

**Syntax:** `cmpltsd xmm, xmm/m64`

Comparison of one double for less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpltss – Comparison of one single for less

**Syntax:** `cmpltss xmm, xmm/m32`

Comparison of one single for less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] lt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpneqpd – Comparison of 2 doubles for not equal

**Syntax:** `cmpneqpd xmm, xmm/m128`

Comparison of 2 doubles for not equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpneqps – Comparison of 4 singles for not equal

**Syntax:** `cmpneqps xmm, xmm/m128`

Comparison of 4 singles for not equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpneqsd – Comparison of one double for not equal

**Syntax:** `cmpneqsd xmm, xmm/m64`

Comparison of one double for not equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpneqss – Comparison of one single for not equal

**Syntax:** `cmpneqss xmm, xmm/m32`

Comparison of one single for not equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] neq src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnlepd – Comparison of 2 doubles for not less or equal

**Syntax:** `cmpnlepd xmm, xmm/m128`

Comparison of 2 doubles for not less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnleps – Comparison of 4 singles for not less or equal

**Syntax:** `cmpnleps xmm, xmm/m128`

Comparison of 4 singles for not less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnlesd – Comparison of one double for not less or equal

**Syntax:** `cmpnlesd xmm, xmm/m64`

Comparison of one double for not less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnless – Comparison of one single for not less or equal

**Syntax:** `cmpnless xmm, xmm/m32`

Comparison of one single for not less or equal, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nle src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnltpd – Comparison of 2 doubles for not less

**Syntax:** `cmpnltpd xmm, xmm/m128`

Comparison of 2 doubles for not less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnltps – Comparison of 4 singles for not less

**Syntax:** `cmpnltps xmm, xmm/m128`

Comparison of 4 singles for not less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnltsd – Comparison of one double for not less

**Syntax:** `cmpnltsd xmm, xmm/m64`

Comparison of one double for not less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpnltss – Comparison of one single for not less

**Syntax:** `cmpnltss xmm, xmm/m32`

Comparison of one single for not less, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] nlt src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpordpd – Comparison of 2 doubles for ordered

**Syntax:** `cmpordpd xmm, xmm/m128`

Comparison of 2 doubles for ordered (no NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpordps – Comparison of 4 singles for ordered

**Syntax:** `cmpordps xmm, xmm/m128`

Comparison of 4 singles for ordered (no NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpordsd – Comparison of one double for ordered

**Syntax:** `cmpordsd xmm, xmm/m64`

Comparison of one double for ordered (no NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpordss – Comparison of one single for ordered

**Syntax:** `cmpordss xmm, xmm/m32`

Comparison of one single for ordered (no NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] ord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmppd – Comparison of 2 doubles with a condition

**Syntax:** `cmppd xmm, xmm/m128, imm8`

Comparison of 2 doubles with a condition, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpps – Comparison of 4 singles with a condition

**Syntax:** `cmpps xmm, xmm/m128, imm8`

Comparison of 4 singles with a condition, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpsb – Comparison of [rsi] with [rdi]

**Syntax:** `cmpsb`

Comparison of [rsi] with [rdi], rsi and rdi advance.

**Operation:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpsd – Comparison of one double

**Syntax:** `cmpsd` &nbsp; `cmpsd xmm, xmm/m64, imm8`

Comparison of one double (xmm) with a condition; without operands: string compare.

**Operation:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpsq – Comparison of [rsi] with [rdi]

**Syntax:** `cmpsq`

Comparison of [rsi] with [rdi], rsi and rdi advance.

**Operation:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpss – Comparison of one single with a condition

**Syntax:** `cmpss xmm, xmm/m32, imm8`

Comparison of one single with a condition, the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] predicate src[i]) ? all 1 bits : 0; the predicate is imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpsw – Comparison of [rsi] with [rdi]

**Syntax:** `cmpsw`

Comparison of [rsi] with [rdi], rsi and rdi advance.

**Operation:** `flags = [rsi] - [rdi]; rsi, rdi = +/- size; with repe / repne: repeat while equal / not equal, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpunordpd – Comparison of 2 doubles for unordered

**Syntax:** `cmpunordpd xmm, xmm/m128`

Comparison of 2 doubles for unordered (NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpunordps – Comparison of 4 singles for unordered

**Syntax:** `cmpunordps xmm, xmm/m128`

Comparison of 4 singles for unordered (NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpunordsd – Comparison of one double for unordered

**Syntax:** `cmpunordsd xmm, xmm/m64`

Comparison of one double for unordered (NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpunordss – Comparison of one single for unordered

**Syntax:** `cmpunordss xmm, xmm/m32`

Comparison of one single for unordered (NaN), the result is a mask.

**Operation:** `for every element: dst[i] = (dst[i] unord src[i]) ? all 1 bits : 0`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpxchg – Compare and exchange if equal (atomic with lock)

**Syntax:** `cmpxchg r/m8, r8` &nbsp; `cmpxchg r/m32, r32` &nbsp; `cmpxchg r/m16, r16` &nbsp; `cmpxchg r/m64, r64`

**Operation:** `if rax == dst then { ZF = 1; dst = src } else { ZF = 0; rax = dst }`

**Flags:** OF SF ZF AF CF PF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpxchg16b – Compare and exchange of 16 bytes

**Syntax:** `cmpxchg16b m`

Compare and exchange of 16 bytes (rdx:rax, rcx:rbx).

**Operation:** `if rdx:rax == [m] then { ZF = 1; [m] = rcx:rbx } else { ZF = 0; rdx:rax = [m] }`

**Flags:** ZF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## cmpxchg8b – Compare and exchange of 8 bytes (edx:eax, ecx:ebx)

**Syntax:** `cmpxchg8b m`

**Operation:** `if edx:eax == [m] then { ZF = 1; [m] = ecx:ebx } else { ZF = 0; edx:eax = [m] }`

**Flags:** ZF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## comisd – Comparison of two doubles, sets ZF, PF, CF

**Syntax:** `comisd xmm, xmm/m64`

**Operation:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## comiss – Comparison of two singles, sets ZF, PF, CF

**Syntax:** `comiss xmm, xmm/m32`

**Operation:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## cpuid – Information about the processor

**Syntax:** `cpuid`

**Operation:** `eax, ebx, ecx, edx = information about the processor for the function in eax (and ecx)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## cqo – Sign extension of rax into rdx:rax

**Syntax:** `cqo`

**Operation:** `rdx:rax = sext(rax)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## crc32 – Calculation of a CRC-32C checksum (Castagnoli)

**Syntax:** `crc32 r32, r/m8` &nbsp; `crc32 r32, r/m32` &nbsp; `crc32 r64, r/m8` &nbsp; `crc32 r64, r/m64`

**Operation:** `dst = crc32c(dst, src)`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtdq2pd – Conversion of 2 integers (32 bit) to doubles

**Syntax:** `cvtdq2pd xmm, xmm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from int32 to double`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtdq2ps – Conversion of 4 integers (32 bit) to singles

**Syntax:** `cvtdq2ps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from int32 to single`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtpd2dq – Conversion of 2 doubles to integers (rounded)

**Syntax:** `cvtpd2dq xmm, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from double to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtpd2pi – Conversion of 2 doubles to integers (mm, rounded)

**Syntax:** `cvtpd2pi mm, xmm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from double to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtpd2ps – Conversion of 2 doubles to singles

**Syntax:** `cvtpd2ps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from double to single`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtpi2pd – Conversion of 2 integers (mm) to doubles

**Syntax:** `cvtpi2pd xmm, mm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from int32 to double`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtpi2ps – Conversion of 2 integers (mm) to singles

**Syntax:** `cvtpi2ps xmm, mm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from int32 to single`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtps2dq – Conversion of 4 singles to integers (rounded)

**Syntax:** `cvtps2dq xmm, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from single to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtps2pd – Conversion of 2 singles to doubles

**Syntax:** `cvtps2pd xmm, xmm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from single to double`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtps2pi – Conversion of 2 singles to integers (mm, rounded)

**Syntax:** `cvtps2pi mm, xmm/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from single to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtsd2si – Conversion of a double to an integer (rounded)

**Syntax:** `cvtsd2si r32, xmm/m128` &nbsp; `cvtsd2si r64, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from double to integer`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtsd2ss – Conversion of a double to a single

**Syntax:** `cvtsd2ss xmm, xmm/m128`

**Operation:** `for every element: dst[i] = convert(src[i]) from double to single`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtsi2sd – Conversion of an integer to a double

**Syntax:** `cvtsi2sd xmm, r/m32` &nbsp; `cvtsi2sd xmm, r/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from integer to double`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtsi2ss – Conversion of an integer to a single

**Syntax:** `cvtsi2ss xmm, r/m32` &nbsp; `cvtsi2ss xmm, r/m64`

**Operation:** `for every element: dst[i] = convert(src[i]) from integer to single`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtss2sd – Conversion of a single to a double

**Syntax:** `cvtss2sd xmm, xmm/m32`

**Operation:** `for every element: dst[i] = convert(src[i]) from single to double`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvtss2si – Conversion of a single to an integer (rounded)

**Syntax:** `cvtss2si r32, xmm/m32` &nbsp; `cvtss2si r64, xmm/m32`

**Operation:** `for every element: dst[i] = convert(src[i]) from single to integer`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttpd2dq – Conversion of 2 doubles to integers (truncated)

**Syntax:** `cvttpd2dq xmm, xmm/m128`

**Operation:** `for every element: dst[i] = truncate(src[i]) from double to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttpd2pi – Conversion of 2 doubles to integers

**Syntax:** `cvttpd2pi mm, xmm/m64`

Conversion of 2 doubles to integers (mm, truncated).

**Operation:** `for every element: dst[i] = truncate(src[i]) from double to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttps2dq – Conversion of 4 singles to integers (truncated)

**Syntax:** `cvttps2dq xmm, xmm/m128`

**Operation:** `for every element: dst[i] = truncate(src[i]) from single to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttps2pi – Conversion of 2 singles to integers

**Syntax:** `cvttps2pi mm, xmm/m64`

Conversion of 2 singles to integers (mm, truncated).

**Operation:** `for every element: dst[i] = truncate(src[i]) from single to int32`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttsd2si – Conversion of a double to an integer (truncated)

**Syntax:** `cvttsd2si r32, xmm/m128` &nbsp; `cvttsd2si r64, xmm/m128`

**Operation:** `for every element: dst[i] = truncate(src[i]) from double to integer`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cvttss2si – Conversion of a single to an integer (truncated)

**Syntax:** `cvttss2si r32, xmm/m32` &nbsp; `cvttss2si r64, xmm/m32`

**Operation:** `for every element: dst[i] = truncate(src[i]) from single to integer`

*Group: Conversions. Short description from the instruction reference; there is no longer explanation for it yet.*

## cwd – Sign extension of ax into dx:ax

**Syntax:** `cwd`

**Operation:** `dx:ax = sext(ax)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## cwde – Sign extension of ax into eax

**Syntax:** `cwde`

**Operation:** `eax = sext(ax)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## daa – Decimal adjust after an addition (packed BCD)

**Syntax:** `daa`

**Operation:** `if (al & 15) > 9 or AF = 1 then al = al + 6; if al > 99h or CF = 1 then al = al + 60h`

**Flags:** SF ZF AF CF PF &nbsp; undefined: OF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## das – Decimal adjust after a subtraction (packed BCD)

**Syntax:** `das`

**Operation:** `if (al & 15) > 9 or AF = 1 then al = al - 6; if al > 99h or CF = 1 then al = al - 60h`

**Flags:** SF ZF AF CF PF &nbsp; undefined: OF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## dec – Decrement by 1 (CF is unchanged)

**Syntax:** `dec r/m8` &nbsp; `dec r/m32` &nbsp; `dec r/m16` &nbsp; `dec r/m64`

**Operation:** `dst = dst - 1`

**Flags:** OF SF ZF AF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## div – Unsigned division

**Syntax:** `div ax, r/m8` &nbsp; `div eax, r/m32` &nbsp; `div ax, r/m16` &nbsp; `div r/m8` &nbsp; `div r/m32` &nbsp; `div r/m16` &nbsp; `div r/m64`

Unsigned division: edx:eax by the operand, quotient to eax, remainder to edx.

**Operation:** `rax = rdx:rax / src; rdx = rdx:rax % src (8 bit: al = ax / src; ah = ax % src); #DE if src = 0 or quotient too big (unsigned)`

**Flags:** – &nbsp; undefined: OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## divpd – Division of 2 doubles

**Syntax:** `divpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] / src[i] (double)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## divps – Division of 4 singles

**Syntax:** `divps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] / src[i] (single)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## divsd – Division of one double

**Syntax:** `divsd xmm, xmm/m64`

**Operation:** `dst[0] = dst[0] / src[0] (double); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## divss – Division of one single

**Syntax:** `divss xmm, xmm/m32`

**Operation:** `dst[0] = dst[0] / src[0] (single); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## dppd – Dot product of doubles

**Syntax:** `dppd xmm, xmm/m128, imm8`

**Operation:** `dst[i] = sum of dst[j] * src[j] for the elements chosen by imm8 (high bits), written to the elements chosen by imm8 (low bits)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## dpps – Dot product of singles

**Syntax:** `dpps xmm, xmm/m128, imm8`

**Operation:** `dst[i] = sum of dst[j] * src[j] for the elements chosen by imm8 (high bits), written to the elements chosen by imm8 (low bits)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## emms – End of MMX and freeing of the x87 registers

**Syntax:** `emms`

**Operation:** `mark all x87 registers as empty (after MMX)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## endbr32 – Marking of a valid branch target

**Syntax:** `endbr32`

Marking of a valid branch target (control-flow protection).

**Operation:** `marks a valid target of an indirect jump (no change)`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## endbr64 – Marking of a valid branch target

**Syntax:** `endbr64`

Marking of a valid branch target (control-flow protection).

**Operation:** `marks a valid target of an indirect jump (no change)`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## enter – Building of a stack frame (rare, usually push/mov)

**Syntax:** `enter imm16, imm8`

**Operation:** `push(rbp); rbp = rsp; rsp = rsp - size (nesting level 0)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## extractps – Extraction of a single from xmm into a register or memory

**Syntax:** `extractps r/m32, xmm, imm8`

**Operation:** `dst = one single of src, chosen by imm8`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## f2xm1 – 2 to the power st0 minus 1

**Syntax:** `f2xm1`

**Operation:** `st0 = 2 ^ st0 - 1`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fabs – Absolute value of st0

**Syntax:** `fabs`

**Operation:** `st0 = abs(st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fadd – Addition (st0 = st0 + operand)

**Syntax:** `fadd m32` &nbsp; `fadd st0, st(i)` &nbsp; `fadd m64` &nbsp; `fadd st(i), st0`

**Operation:** `st0 = st0 + src (or st(i) = st(i) + st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## faddp – Addition with pop

**Syntax:** `faddp st(i), st0`

**Operation:** `st(i) = st(i) + st0; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fbld – Load of a packed decimal number (BCD)

**Syntax:** `fbld m80`

**Operation:** `push: st0 = packed decimal src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fbstp – Store of st0 as a packed decimal number and pop

**Syntax:** `fbstp m80`

**Operation:** `dst = st0 as packed decimal; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fchs – Sign change of st0

**Syntax:** `fchs`

**Operation:** `st0 = -st0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovb – Copy of st(i) to st0 if CF=1

**Syntax:** `fcmovb st0, st(i)`

**Operation:** `if CF = 1 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovbe – Copy of st(i) to st0 if CF=1 or ZF=1

**Syntax:** `fcmovbe st0, st(i)`

**Operation:** `if CF = 1 or ZF = 1 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmove – Copy of st(i) to st0 if ZF=1

**Syntax:** `fcmove st0, st(i)`

**Operation:** `if ZF = 1 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovnb – Copy of st(i) to st0 if CF=0

**Syntax:** `fcmovnb st0, st(i)`

**Operation:** `if CF = 0 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovnbe – Copy of st(i) to st0 if CF=0 and ZF=0

**Syntax:** `fcmovnbe st0, st(i)`

**Operation:** `if CF = 0 and ZF = 0 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovne – Copy of st(i) to st0 if ZF=0

**Syntax:** `fcmovne st0, st(i)`

**Operation:** `if ZF = 0 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovnu – Copy of st(i) to st0 if PF=0

**Syntax:** `fcmovnu st0, st(i)`

**Operation:** `if PF = 0 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcmovu – Copy of st(i) to st0 if PF=1

**Syntax:** `fcmovu st0, st(i)`

**Operation:** `if PF = 1 then st0 = st(i)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcom – Comparison of st0 with an operand (status word)

**Syntax:** `fcom st(i)/m32` &nbsp; `fcom m64`

**Operation:** `status word C3 C2 C0 = compare(st0, src)`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcomi – Comparison setting ZF, PF, CF directly

**Syntax:** `fcomi st0, st(i)`

**Operation:** `ZF PF CF = compare(st0, st(i))`

**Flags:** ZF CF PF

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcomip – Comparison setting ZF, PF, CF with pop of st0

**Syntax:** `fcomip st0, st(i)`

**Operation:** `ZF PF CF = compare(st0, st(i)); pop`

**Flags:** ZF CF PF

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcomp – Comparison with pop of st0

**Syntax:** `fcomp st(i)/m32` &nbsp; `fcomp m64`

**Operation:** `status word C3 C2 C0 = compare(st0, src); pop`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcompp – Comparison of st0 with st1 and pop of both

**Syntax:** `fcompp`

**Operation:** `status word C3 C2 C0 = compare(st0, st1); pop twice`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fcos – Cosine of st0

**Syntax:** `fcos`

**Operation:** `st0 = cos(st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdecstp – Decrement of the x87 stack pointer

**Syntax:** `fdecstp`

**Operation:** `top of the x87 stack = top - 1`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdiv – Division

**Syntax:** `fdiv m32` &nbsp; `fdiv st0, st(i)` &nbsp; `fdiv m64` &nbsp; `fdiv st(i), st0`

**Operation:** `st0 = st0 / src (or st(i) = st(i) / st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdivp – Division with pop

**Syntax:** `fdivp st(i), st0`

**Operation:** `st(i) = st(i) / st0; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdivr – Division in reverse order

**Syntax:** `fdivr m32` &nbsp; `fdivr st0, st(i)` &nbsp; `fdivr st(i), st0` &nbsp; `fdivr m64`

**Operation:** `st0 = src / st0 (or st(i) = st0 / st(i))`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fdivrp – Reverse division with pop

**Syntax:** `fdivrp st(i), st0`

**Operation:** `st(i) = st0 / st(i); pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## ffree – Freeing of an x87 register

**Syntax:** `ffree st(i)`

**Operation:** `mark st(i) as empty`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fiadd – Addition of an integer from memory

**Syntax:** `fiadd m32` &nbsp; `fiadd m16`

**Operation:** `st0 = st0 + (float) integer src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## ficom – Comparison of st0 with an integer

**Syntax:** `ficom m32` &nbsp; `ficom m16`

**Operation:** `status word C3 C2 C0 = compare(st0, integer src)`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## ficomp – Comparison with an integer and pop of st0

**Syntax:** `ficomp m32` &nbsp; `ficomp m16`

**Operation:** `status word C3 C2 C0 = compare(st0, integer src); pop`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fidiv – Division by an integer from memory

**Syntax:** `fidiv m32` &nbsp; `fidiv m16`

**Operation:** `st0 = st0 / (float) integer src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fidivr – Division of an integer by st0 (reversed)

**Syntax:** `fidivr m32` &nbsp; `fidivr m16`

**Operation:** `st0 = (float) integer src / st0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fild – Load of an integer onto the x87 stack

**Syntax:** `fild m32` &nbsp; `fild m16` &nbsp; `fild m64`

**Operation:** `push: st0 = (float) integer src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fimul – Multiplication by an integer from memory

**Syntax:** `fimul m32` &nbsp; `fimul m16`

**Operation:** `st0 = st0 * (float) integer src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fincstp – Increment of the x87 stack pointer

**Syntax:** `fincstp`

**Operation:** `top of the x87 stack = top + 1`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fist – Store of st0 as an integer (rounded)

**Syntax:** `fist m32` &nbsp; `fist m16`

**Operation:** `dst = (integer) st0, rounded`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fistp – Store of st0 as an integer and pop

**Syntax:** `fistp m32` &nbsp; `fistp m16` &nbsp; `fistp m64`

**Operation:** `dst = (integer) st0, rounded; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fisttp – Store of st0 as an integer (truncated) and pop

**Syntax:** `fisttp m32` &nbsp; `fisttp m64` &nbsp; `fisttp m16`

**Operation:** `dst = (integer) st0, truncated; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fisub – Subtraction of an integer from memory

**Syntax:** `fisub m32` &nbsp; `fisub m16`

**Operation:** `st0 = st0 - (float) integer src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fisubr – Reverse subtraction of an integer from memory

**Syntax:** `fisubr m32` &nbsp; `fisubr m16`

**Operation:** `st0 = (float) integer src - st0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fld – Load of a value onto the x87 stack

**Syntax:** `fld st(i)/m32` &nbsp; `fld m80` &nbsp; `fld m64`

**Operation:** `push: st0 = src`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fld1 – Load of the constant 1.0

**Syntax:** `fld1`

**Operation:** `push: st0 = 1.0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldcw – Load of the x87 control word

**Syntax:** `fldcw m16`

**Operation:** `x87 control word = [m16]`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldenv – Load of the x87 environment

**Syntax:** `fldenv m`

**Operation:** `x87 environment = [m]`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldl2e – Load of log2(e)

**Syntax:** `fldl2e`

**Operation:** `push: st0 = log2(e)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldl2t – Load of log2(10)

**Syntax:** `fldl2t`

**Operation:** `push: st0 = log2(10)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldlg2 – Load of log10(2)

**Syntax:** `fldlg2`

**Operation:** `push: st0 = log10(2)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldln2 – Load of ln(2)

**Syntax:** `fldln2`

**Operation:** `push: st0 = ln(2)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldpi – Load of the constant π

**Syntax:** `fldpi`

**Operation:** `push: st0 = pi`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fldz – Load of the constant 0.0

**Syntax:** `fldz`

**Operation:** `push: st0 = 0.0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmul – Multiplication

**Syntax:** `fmul m32` &nbsp; `fmul st0, st(i)` &nbsp; `fmul m64` &nbsp; `fmul st(i), st0`

**Operation:** `st0 = st0 * src (or st(i) = st(i) * st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fmulp – Multiplication with pop

**Syntax:** `fmulp st(i), st0`

**Operation:** `st(i) = st(i) * st0; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnclex – Clearing of the x87 exceptions

**Syntax:** `fnclex`

**Operation:** `clear the x87 exception flags`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fninit – Reset of the x87 unit

**Syntax:** `fninit`

**Operation:** `reset the x87 unit`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnop – No operation (x87)

**Syntax:** `fnop`

**Operation:** `no operation`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnsave – Store of the whole x87 state

**Syntax:** `fnsave m`

**Operation:** `[m] = whole x87 state; then reset the unit`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnstcw – Store of the x87 control word

**Syntax:** `fnstcw m16`

**Operation:** `[m16] = x87 control word`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnstenv – Store of the x87 environment

**Syntax:** `fnstenv m`

**Operation:** `[m] = x87 environment`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fnstsw – Store of the x87 status word

**Syntax:** `fnstsw m16` &nbsp; `fnstsw ax`

**Operation:** `dst = x87 status word`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fpatan – Arc tangent of st1/st0

**Syntax:** `fpatan`

**Operation:** `st1 = atan(st1 / st0); pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fprem – Remainder of a division (partial)

**Syntax:** `fprem`

**Operation:** `st0 = st0 mod st1 (truncating quotient, partial)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fprem1 – IEEE remainder of a division

**Syntax:** `fprem1`

**Operation:** `st0 = IEEE remainder of st0 / st1 (partial)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fptan – Tangent of st0

**Syntax:** `fptan`

**Operation:** `st0 = tan(st0); push: st0 = 1.0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## frndint – Rounding of st0 to a whole number

**Syntax:** `frndint`

**Operation:** `st0 = round(st0) to an integer value`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## frstor – Restoring of the whole x87 state

**Syntax:** `frstor m`

**Operation:** `whole x87 state = [m]`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fscale – Multiplication of st0 by 2 to the power st1

**Syntax:** `fscale`

**Operation:** `st0 = st0 * 2 ^ trunc(st1)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsin – Sine of st0

**Syntax:** `fsin`

**Operation:** `st0 = sin(st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsincos – Sine and cosine of st0

**Syntax:** `fsincos`

**Operation:** `st0 = sin(st0); push: st0 = cos`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsqrt – Square root of st0

**Syntax:** `fsqrt`

**Operation:** `st0 = sqrt(st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fst – Store of st0 (without popping)

**Syntax:** `fst m32` &nbsp; `fst st(i)/m64`

**Operation:** `dst = st0`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fstp – Store of st0 and pop

**Syntax:** `fstp m32` &nbsp; `fstp m80` &nbsp; `fstp st(i)/m64`

**Operation:** `dst = st0; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsub – Subtraction

**Syntax:** `fsub m32` &nbsp; `fsub st0, st(i)` &nbsp; `fsub m64` &nbsp; `fsub st(i), st0`

**Operation:** `st0 = st0 - src (or st(i) = st(i) - st0)`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsubp – Subtraction with pop

**Syntax:** `fsubp st(i), st0`

**Operation:** `st(i) = st(i) - st0; pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsubr – Subtraction in reverse order

**Syntax:** `fsubr m32` &nbsp; `fsubr st0, st(i)` &nbsp; `fsubr st(i), st0` &nbsp; `fsubr m64`

**Operation:** `st0 = src - st0 (or st(i) = st0 - st(i))`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fsubrp – Reverse subtraction with pop

**Syntax:** `fsubrp st(i), st0`

**Operation:** `st(i) = st0 - st(i); pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## ftst – Comparison of st0 with 0.0

**Syntax:** `ftst`

**Operation:** `status word C3 C2 C0 = compare(st0, 0.0)`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fucom – Unordered comparison (no fault on NaN)

**Syntax:** `fucom st(i)`

**Operation:** `status word C3 C2 C0 = compare(st0, src)`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fucomi – Unordered comparison, sets ZF, PF, CF

**Syntax:** `fucomi st0, st(i)`

**Operation:** `ZF PF CF = compare(st0, st(i))`

**Flags:** ZF CF PF

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fucomip – Unordered comparison

**Syntax:** `fucomip st0, st(i)`

Unordered comparison, sets ZF, PF, CF, with pop of st0.

**Operation:** `ZF PF CF = compare(st0, st(i)); pop`

**Flags:** ZF CF PF

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fucomp – Unordered comparison with pop of st0

**Syntax:** `fucomp st(i)`

**Operation:** `status word C3 C2 C0 = compare(st0, src); pop`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fucompp – Unordered comparison of st0, st1 with pop of both

**Syntax:** `fucompp`

**Operation:** `status word C3 C2 C0 = compare(st0, st1); pop twice`

**Flags:** C0 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fwait – Wait for the x87 unit

**Syntax:** `fwait`

**Operation:** `wait until the x87 unit is done and report its errors`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## fxam – Examination of the kind of st0 (number, NaN, ...)

**Syntax:** `fxam`

**Operation:** `status word C3 C2 C1 C0 = kind of st0 (number, zero, infinity, NaN, ...)`

**Flags:** C0 C1 C2 C3

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fxch – Exchange of st0 with another register

**Syntax:** `fxch st(i)`

**Operation:** `swap(st0, st(i))`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fxrstor – Restoring of the x87, MMX and SSE state

**Syntax:** `fxrstor m`

**Operation:** `x87, MMX and SSE state = [m]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## fxrstor64 – Restoring of the x87, MMX and SSE state

**Syntax:** `fxrstor64 m`

**Operation:** `x87, MMX and SSE state = [m]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## fxsave – Saving of the x87, MMX and SSE state

**Syntax:** `fxsave m`

**Operation:** `[m] = x87, MMX and SSE state (512 bytes)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## fxsave64 – Saving of the x87, MMX and SSE state

**Syntax:** `fxsave64 m`

**Operation:** `[m] = x87, MMX and SSE state (512 bytes)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## fxtract – Splitting of st0 into exponent and mantissa

**Syntax:** `fxtract`

**Operation:** `st0 = exponent of st0; push: st0 = significand`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fyl2x – st1 times log2(st0)

**Syntax:** `fyl2x`

**Operation:** `st1 = st1 * log2(st0); pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## fyl2xp1 – st1 times log2(st0 + 1)

**Syntax:** `fyl2xp1`

**Operation:** `st1 = st1 * log2(st0 + 1); pop`

*Group: Floating point (x87). Short description from the instruction reference; there is no longer explanation for it yet.*

## getsec – Security extension instructions (Intel TXT)

**Syntax:** `getsec`

**Operation:** `run the safer-mode function selected by eax (Intel TXT)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## haddpd – Addition of adjacent doubles (horizontal)

**Syntax:** `haddpd xmm, xmm/m128`

**Operation:** `dst = (dst[0] + dst[1], dst[2] + dst[3], src[0] + src[1], src[2] + src[3])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## haddps – Addition of adjacent singles (horizontal)

**Syntax:** `haddps xmm, xmm/m128`

**Operation:** `dst = (dst[0] + dst[1], dst[2] + dst[3], src[0] + src[1], src[2] + src[3])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## hlt – Halt of the processor (until the next interrupt)

**Syntax:** `hlt`

**Operation:** `stop until the next interrupt (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## hsubpd – Subtraction of adjacent doubles (horizontal)

**Syntax:** `hsubpd xmm, xmm/m128`

**Operation:** `dst = (dst[0] - dst[1], dst[2] - dst[3], src[0] - src[1], src[2] - src[3])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## hsubps – Subtraction of adjacent singles (horizontal)

**Syntax:** `hsubps xmm, xmm/m128`

**Operation:** `dst = (dst[0] - dst[1], dst[2] - dst[3], src[0] - src[1], src[2] - src[3])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## idiv – Signed division

**Syntax:** `idiv ax, r/m8` &nbsp; `idiv eax, r/m32` &nbsp; `idiv ax, r/m16` &nbsp; `idiv r/m8` &nbsp; `idiv r/m32` &nbsp; `idiv r/m16` &nbsp; `idiv r/m64`

Signed division: edx:eax by the operand, quotient to eax, remainder to edx.

**Operation:** `rax = rdx:rax / src; rdx = rdx:rax % src (8 bit: al = ax / src; ah = ax % src); #DE if src = 0 or quotient too big (signed)`

**Flags:** – &nbsp; undefined: OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## imul – Signed multiplication (one, two or three operands)

**Syntax:** `imul r32, r/m32, imm32` &nbsp; `imul r16, r/m16, imm16` &nbsp; `imul r32, r/m32, imm8` &nbsp; `imul r16, r/m16, imm8` &nbsp; `imul r/m8` &nbsp; `imul r/m32` &nbsp; `imul r16` &nbsp; `imul r32, r/m32` &nbsp; …

**Operation:** `1 operand: rdx:rax = rax * src (signed); 2: dst = dst * src; 3: dst = src * imm`

**Flags:** OF CF &nbsp; undefined: SF ZF AF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## in – Read of a value from an I/O port

**Syntax:** `in al, imm8` &nbsp; `in eax, imm8` &nbsp; `in ax, imm8` &nbsp; `in al, dx` &nbsp; `in eax, dx` &nbsp; `in ax, dx`

**Operation:** `dst = port[src]`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## inc – Increment by 1 (CF is unchanged)

**Syntax:** `inc r/m8` &nbsp; `inc r/m32` &nbsp; `inc r/m16` &nbsp; `inc r/m64`

**Operation:** `dst = dst + 1`

**Flags:** OF SF ZF AF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## insb – Read of a port to [rdi], rdi advances

**Syntax:** `insb`

**Operation:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## insd – Read of a port to [rdi], rdi advances

**Syntax:** `insd`

**Operation:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## insertps – Insertion of a single into xmm

**Syntax:** `insertps xmm, xmm/m32, imm8`

**Operation:** `dst = dst with one single replaced by one of src (and zeroed ones), chosen by imm8`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## insw – Read of a port to [rdi], rdi advances

**Syntax:** `insw`

**Operation:** `[rdi] = port[dx]; rdi = rdi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## int – Raising of a software interrupt

**Syntax:** `int imm8`

**Operation:** `push(flags, cs, rip); jump to the handler of vector imm8`

**Flags:** IF TF

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## int1 – Raising of debug interrupt 1

**Syntax:** `int1`

**Operation:** `interrupt 1 (debug exception)`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## int3 – Breakpoint (interrupt 3, one byte)

**Syntax:** `int3`

**Operation:** `interrupt 3 (breakpoint)`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## into – Interrupt 4 if OF=1

**Syntax:** `into`

**Operation:** `if OF = 1 then interrupt 4`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## invd – Invalidation of the caches without write-back

**Syntax:** `invd`

Invalidation of the caches without write-back (privileged).

**Operation:** `empty the caches without writing back (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## invlpg – Invalidation of a TLB entry

**Syntax:** `invlpg m`

**Operation:** `remove the translation of the page of [m] from the TLB (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## iretd – Return from an interrupt (32 bit)

**Syntax:** `iretd`

**Operation:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## iretq – Return from an interrupt (64 bit)

**Syntax:** `iretq`

**Operation:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## iretw – Return from an interrupt (16 bit)

**Syntax:** `iretw`

**Operation:** `rip, cs, flags = pop(); (64 bit and on a change of level: rsp, ss = pop())`

**Flags:** all

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## ja – Jump if unsigned above (CF=0 and ZF=0)

**Syntax:** `ja rel8` &nbsp; `ja rel32` &nbsp; `ja rel16`

**Operation:** `if CF = 0 and ZF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jbe – Jump if unsigned below or equal (CF=1 or ZF=1)

**Syntax:** `jbe rel8` &nbsp; `jbe rel32` &nbsp; `jbe rel16`

**Operation:** `if CF = 1 or ZF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jc – Jump if carry, unsigned below (CF=1)

**Syntax:** `jc rel8` &nbsp; `jc rel32` &nbsp; `jc rel16`

**Operation:** `if CF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jecxz – Jump if ecx is 0

**Syntax:** `jecxz rel8`

**Operation:** `if ecx == 0 then eip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jg – Jump if signed greater (ZF=0 and SF=OF)

**Syntax:** `jg rel8` &nbsp; `jg rel32` &nbsp; `jg rel16`

**Operation:** `if ZF = 0 and SF = OF then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jge – Jump if signed greater or equal (SF=OF)

**Syntax:** `jge rel8` &nbsp; `jge rel32` &nbsp; `jge rel16`

**Operation:** `if SF = OF then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jl – Jump if signed less (SF≠OF)

**Syntax:** `jl rel8` &nbsp; `jl rel32` &nbsp; `jl rel16`

**Operation:** `if SF != OF then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jle – Jump if signed less or equal (ZF=1 or SF≠OF)

**Syntax:** `jle rel8` &nbsp; `jle rel32` &nbsp; `jle rel16`

**Operation:** `if ZF = 1 or SF != OF then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jmp – Jump to an address

**Syntax:** `jmp rel32` &nbsp; `jmp rel16` &nbsp; `jmp rel8` &nbsp; `jmp r/m32` &nbsp; `jmp m` &nbsp; `jmp r/m16` &nbsp; `jmp r/m64`

**Operation:** `rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jnc – Jump if no carry, unsigned above or equal (CF=0)

**Syntax:** `jnc rel8` &nbsp; `jnc rel32` &nbsp; `jnc rel16`

**Operation:** `if CF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jno – Jump if no overflow (OF=0)

**Syntax:** `jno rel8` &nbsp; `jno rel32` &nbsp; `jno rel16`

**Operation:** `if OF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jnp – Jump if parity odd (PF=0)

**Syntax:** `jnp rel8` &nbsp; `jnp rel32` &nbsp; `jnp rel16`

**Operation:** `if PF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jns – Jump if not negative (SF=0)

**Syntax:** `jns rel8` &nbsp; `jns rel32` &nbsp; `jns rel16`

**Operation:** `if SF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jnz – Jump if not equal, result not zero (ZF=0)

**Syntax:** `jnz rel8` &nbsp; `jnz rel32` &nbsp; `jnz rel16`

**Operation:** `if ZF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jo – Jump if overflow (OF=1)

**Syntax:** `jo rel8` &nbsp; `jo rel32` &nbsp; `jo rel16`

**Operation:** `if OF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jp – Jump if parity even (PF=1)

**Syntax:** `jp rel8` &nbsp; `jp rel32` &nbsp; `jp rel16`

**Operation:** `if PF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jrcxz – Jump if rcx is 0

**Syntax:** `jrcxz rel8`

**Operation:** `if rcx == 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## js – Jump if negative (SF=1)

**Syntax:** `js rel8` &nbsp; `js rel32` &nbsp; `js rel16`

**Operation:** `if SF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## jz – Jump if equal, result zero (ZF=1)

**Syntax:** `jz rel8` &nbsp; `jz rel32` &nbsp; `jz rel16`

**Operation:** `if ZF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## lahf – Load of the flags into ah

**Syntax:** `lahf`

**Operation:** `ah = SF:ZF:0:AF:0:PF:1:CF`

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## lar – Load of the access rights of a segment

**Syntax:** `lar r32, r32/m16` &nbsp; `lar r16, r32/m16` &nbsp; `lar r64, r32/m16`

**Operation:** `dst = access rights of the segment src; ZF = 1 if it is valid`

**Flags:** ZF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lddqu – Load of 128 bits unaligned

**Syntax:** `lddqu xmm, m128`

Load of 128 bits unaligned (fast across cache lines).

**Operation:** `dst = src (128 bits; any alignment)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## ldmxcsr – Load of the SSE control and status register

**Syntax:** `ldmxcsr m`

**Operation:** `MXCSR = [m32]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## lds – Load of a far pointer into ds:register

**Syntax:** `lds r32, m` &nbsp; `lds r16, m`

**Operation:** `dst = [m]; ds = [m + 4]`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## lea – Calculation of an address and storing of the address

**Syntax:** `lea r32, m` &nbsp; `lea r16, m` &nbsp; `lea r64, m`

Calculation of an address and storing of the address, without a memory access.

**Operation:** `dst = address of src (no memory access)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## leave – Tearing down of the stack frame

**Syntax:** `leave`

Tearing down of the stack frame (mov rsp, rbp; pop rbp).

**Operation:** `rsp = rbp; rbp = pop()`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## les – Load of a far pointer into es:register

**Syntax:** `les r32, m` &nbsp; `les r16, m`

**Operation:** `dst = [m]; es = [m + 4]`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## lfence – Barrier for loads

**Syntax:** `lfence`

**Operation:** `all earlier loads are done before later instructions`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## lgdt – Load of the global descriptor table register

**Syntax:** `lgdt m`

**Operation:** `GDTR = [m] (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lidt – Load of the interrupt descriptor table register

**Syntax:** `lidt m`

**Operation:** `IDTR = [m] (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lldt – Load of the local descriptor table register

**Syntax:** `lldt r/m16`

**Operation:** `LDTR = src (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lmsw – Load of the machine status word (low bits of cr0)

**Syntax:** `lmsw m`

**Operation:** `CR0 bits 0 to 15 = src (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lodsb – Load of [rsi] into al/ax/eax/rax, rsi advances

**Syntax:** `lodsb`

**Operation:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## lodsd – Load of [rsi] into al/ax/eax/rax, rsi advances

**Syntax:** `lodsd`

**Operation:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## lodsq – Load of [rsi] into al/ax/eax/rax, rsi advances

**Syntax:** `lodsq`

**Operation:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## lodsw – Load of [rsi] into al/ax/eax/rax, rsi advances

**Syntax:** `lodsw`

**Operation:** `acc = [rsi]; rsi = rsi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## loop – Decrement of rcx and jump while it is not 0

**Syntax:** `loop rel8`

**Operation:** `rcx = rcx - 1; if rcx != 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## loope – Like loop, but only if ZF=1

**Syntax:** `loope rel8`

**Operation:** `rcx = rcx - 1; if rcx != 0 and ZF = 1 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## loopne – Like loop, but only if ZF=0

**Syntax:** `loopne rel8`

**Operation:** `rcx = rcx - 1; if rcx != 0 and ZF = 0 then rip = target`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## lsl – Load of the limit of a segment

**Syntax:** `lsl r32, r32/m16` &nbsp; `lsl r16, r32/m16` &nbsp; `lsl r64, r32/m16`

**Operation:** `dst = limit of the segment src; ZF = 1 if it is valid`

**Flags:** ZF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ltr – Load of the task register

**Syntax:** `ltr r/m16`

**Operation:** `task register = src (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## lzcnt – Count of the leading zero bits

**Syntax:** `lzcnt r32, r/m32` &nbsp; `lzcnt r64, r/m64`

**Operation:** `dst = number of leading 0 bits of src (width if src = 0)`

**Flags:** ZF CF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## maskmovdqu – Store of only the bytes chosen by a mask (xmm)

**Syntax:** `maskmovdqu xmm, xmm`

**Operation:** `for each byte whose mask bit (the top bit) is 1: [rdi + i] = dst[i]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## maskmovq – Store of only the bytes chosen by a mask (mm)

**Syntax:** `maskmovq mm, mm`

**Operation:** `for each byte whose mask bit (the top bit) is 1: [rdi + i] = dst[i]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## maxpd – Maximum of 2 doubles

**Syntax:** `maxpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = max(dst[i], src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## maxps – Maximum of 4 singles

**Syntax:** `maxps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = max(dst[i], src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## maxsd – Maximum of one double

**Syntax:** `maxsd xmm, xmm/m64`

**Operation:** `dst[0] = max(dst[0], src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## maxss – Maximum of one single

**Syntax:** `maxss xmm, xmm/m32`

**Operation:** `dst[0] = max(dst[0], src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## mfence – Barrier for all memory accesses

**Syntax:** `mfence`

**Operation:** `all earlier loads and stores are done before later ones`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## minpd – Minimum of 2 doubles

**Syntax:** `minpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = min(dst[i], src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## minps – Minimum of 4 singles

**Syntax:** `minps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = min(dst[i], src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## minsd – Minimum of one double

**Syntax:** `minsd xmm, xmm/m64`

**Operation:** `dst[0] = min(dst[0], src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## minss – Minimum of one single

**Syntax:** `minss xmm, xmm/m32`

**Operation:** `dst[0] = min(dst[0], src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## monitor – Arming of the monitoring of an address for mwait

**Syntax:** `monitor`

**Operation:** `watch the address in rax (for mwait)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## monitorx – Arming of the monitoring of an address for mwait

**Syntax:** `monitorx`

**Operation:** `watch the address in rax (for mwait)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## mov – Copy of the source to the destination

**Syntax:** `mov r/m8, r8` &nbsp; `mov r/m32, r32` &nbsp; `mov r/m16, r16` &nbsp; `mov r8, r/m8` &nbsp; `mov r32, r/m32` &nbsp; `mov r16, r/m16` &nbsp; `mov r32/m16, Sreg` &nbsp; `mov r16, Sreg` &nbsp; …

**Operation:** `dst = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## movapd – Copy of 2 double floats

**Syntax:** `movapd xmm, xmm/m128` &nbsp; `movapd xmm/m128, xmm`

Copy of 2 double floats (128 bits), memory 16-byte aligned.

**Operation:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movaps – Copy of 4 single floats

**Syntax:** `movaps xmm, xmm/m128` &nbsp; `movaps xmm/m128, xmm`

Copy of 4 single floats (128 bits), memory 16-byte aligned.

**Operation:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movbe – Copy with byte reversal

**Syntax:** `movbe r32, m` &nbsp; `movbe r16, m` &nbsp; `movbe m, r32` &nbsp; `movbe m, r16` &nbsp; `movbe r64, m` &nbsp; `movbe m, r64`

**Operation:** `dst = reverse_bytes(src)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## movd – Copy of 32 bits between an integer register/memory and xmm/mm

**Syntax:** `movd mm, r/m32` &nbsp; `movd xmm, r/m32` &nbsp; `movd r/m32, mm` &nbsp; `movd r/m32, xmm`

**Operation:** `dst = src (32 bits; into xmm / mm the upper bits become 0)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movddup – Duplication of the low double into both halves

**Syntax:** `movddup xmm, xmm/m64`

**Operation:** `dst = (src[63:0], src[63:0])`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movdq2q – Copy of the low half of xmm to mm

**Syntax:** `movdq2q mm, xmm`

**Operation:** `dst = src[63:0] (xmm to mm)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movdqa – Copy of 128 bits of integers

**Syntax:** `movdqa xmm, xmm/m128` &nbsp; `movdqa xmm/m128, xmm`

Copy of 128 bits of integers, memory 16-byte aligned.

**Operation:** `dst = src (128 bits; memory must be 16-byte aligned)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movdqu – Copy of 128 bits of integers, any alignment

**Syntax:** `movdqu xmm, xmm/m128` &nbsp; `movdqu xmm/m128, xmm`

**Operation:** `dst = src (128 bits; any alignment)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movhlps – Copy of the high half of the source xmm to the low half

**Syntax:** `movhlps xmm, xmm`

**Operation:** `dst[63:0] = src[127:64]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movhpd – Copy of 1 double to (or from) the high half of xmm

**Syntax:** `movhpd xmm, m64` &nbsp; `movhpd m64, xmm`

**Operation:** `load: dst[127:64] = [m64]; store: [m64] = src[127:64]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movhps – Copy of 2 singles to

**Syntax:** `movhps xmm, m64` &nbsp; `movhps m64, xmm`

Copy of 2 singles to (or from) the high half of xmm.

**Operation:** `load: dst[127:64] = [m64]; store: [m64] = src[127:64]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movlhps – Copy of the low half of the source xmm to the high half

**Syntax:** `movlhps xmm, xmm`

**Operation:** `dst[127:64] = src[63:0]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movlpd – Copy of 1 double to (or from) the low half of xmm

**Syntax:** `movlpd xmm, m64` &nbsp; `movlpd m64, xmm`

**Operation:** `load: dst[63:0] = [m64]; store: [m64] = src[63:0]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movlps – Copy of 2 singles to (or from) the low half of xmm

**Syntax:** `movlps xmm, m64` &nbsp; `movlps m64, xmm`

**Operation:** `load: dst[63:0] = [m64]; store: [m64] = src[63:0]`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movmskpd – Gathering of the sign bits of 2 doubles into a register

**Syntax:** `movmskpd r32, xmm`

**Operation:** `dst = sign bits of the 2 doubles of src (2 bits)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movmskps – Gathering of the sign bits of 4 singles into a register

**Syntax:** `movmskps r32, xmm`

**Operation:** `dst = sign bits of the 4 singles of src (4 bits)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movntdq – Store of 128 bits bypassing the cache

**Syntax:** `movntdq m128, xmm`

**Operation:** `[dst] = src (past the cache)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movntdqa – Load of 128 bits from write-combining memory

**Syntax:** `movntdqa xmm, xmm/m128`

**Operation:** `dst = [src] (from write-combining memory)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movnti – Store bypassing the cache (non-temporal)

**Syntax:** `movnti m, r32` &nbsp; `movnti m, r64`

**Operation:** `[dst] = src (past the cache)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## movntpd – Store of 128 bits bypassing the cache

**Syntax:** `movntpd m128, xmm`

**Operation:** `[dst] = src (past the cache)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movntps – Store of 128 bits bypassing the cache

**Syntax:** `movntps m128, xmm`

**Operation:** `[dst] = src (past the cache)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movntq – Store of 64 bits (mm) bypassing the cache

**Syntax:** `movntq m64, mm`

**Operation:** `[dst] = src (past the cache)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movq – Copy of 64 bits

**Syntax:** `movq mm, mm/m64` &nbsp; `movq xmm, xmm/m64` &nbsp; `movq mm/m64, mm` &nbsp; `movq xmm/m64, xmm` &nbsp; `movq mm, r/m64` &nbsp; `movq xmm, r/m64` &nbsp; `movq r/m64, mm` &nbsp; `movq r/m64, xmm`

Copy of 64 bits (also between an integer register and xmm/mm).

**Operation:** `dst = src (64 bits; into xmm the upper half becomes 0)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movq2dq – Copy of mm to the low half of xmm

**Syntax:** `movq2dq xmm, mm`

**Operation:** `dst = (0, src) (mm to xmm)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsb – Copy of one element from [rsi] to [rdi]

**Syntax:** `movsb`

Copy of one element from [rsi] to [rdi], rsi and rdi advance.

**Operation:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsd – Copy of one double float

**Syntax:** `movsd` &nbsp; `movsd xmm, xmm/m64` &nbsp; `movsd xmm/m64, xmm`

Copy of one double float (with xmm; without operands: string instruction).

**Operation:** `dst[63:0] = src[63:0] (from memory: the rest of dst becomes 0); without operands it is the string instruction`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movshdup – Duplication of the odd singles

**Syntax:** `movshdup xmm, xmm/m128`

**Operation:** `dst = (src[63:32], src[63:32], src[127:96], src[127:96])`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsldup – Duplication of the even singles

**Syntax:** `movsldup xmm, xmm/m128`

**Operation:** `dst = (src[31:0], src[31:0], src[95:64], src[95:64])`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsq – Copy of one element from [rsi] to [rdi]

**Syntax:** `movsq`

Copy of one element from [rsi] to [rdi], rsi and rdi advance.

**Operation:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## movss – Copy of one single float

**Syntax:** `movss xmm, xmm/m32` &nbsp; `movss xmm/m32, xmm`

**Operation:** `dst[31:0] = src[31:0] (from memory: the rest of dst becomes 0)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsw – Copy of one element from [rsi] to [rdi]

**Syntax:** `movsw`

Copy of one element from [rsi] to [rdi], rsi and rdi advance.

**Operation:** `[rdi] = [rsi]; rsi = rsi +/- size; rdi = rdi +/- size (+ if DF = 0, - if DF = 1); with rep: repeat rcx times`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsx – Copy with sign extension to the larger size

**Syntax:** `movsx r32, r/m8` &nbsp; `movsx r16, r/m8` &nbsp; `movsx r32, r/m16` &nbsp; `movsx r16, r/m16` &nbsp; `movsx r64, r/m8` &nbsp; `movsx r64, r/m16`

**Operation:** `dst = sext(src)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## movsxd – Sign extension of a 32-bit value to 64 bits

**Syntax:** `movsxd r32, r/m32` &nbsp; `movsxd r16, r/m32` &nbsp; `movsxd r64, r/m32`

**Operation:** `dst = sext(src32)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## movupd – Copy of 2 double floats (128 bits), any alignment

**Syntax:** `movupd xmm, xmm/m128` &nbsp; `movupd xmm/m128, xmm`

**Operation:** `dst = src (128 bits; any alignment)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movups – Copy of 4 single floats (128 bits), any alignment

**Syntax:** `movups xmm, xmm/m128` &nbsp; `movups xmm/m128, xmm`

**Operation:** `dst = src (128 bits; any alignment)`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## movzx – Copy with zero extension to the larger size

**Syntax:** `movzx r32, r/m8` &nbsp; `movzx r16, r/m8` &nbsp; `movzx r32, r/m16` &nbsp; `movzx r16, r/m16` &nbsp; `movzx r64, r/m8` &nbsp; `movzx r64, r/m16`

**Operation:** `dst = zext(src)`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## mpsadbw – Sums of absolute byte differences (motion search)

**Syntax:** `mpsadbw xmm, xmm/m128, imm8`

**Operation:** `dst[i] = sums of absolute byte differences of blocks chosen by imm8`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## mul – Unsigned multiplication

**Syntax:** `mul al, r/m8` &nbsp; `mul eax, r/m32` &nbsp; `mul ax, r/m16` &nbsp; `mul r/m8` &nbsp; `mul r/m32` &nbsp; `mul r/m16` &nbsp; `mul r/m64`

Unsigned multiplication, the result is twice as wide (edx:eax).

**Operation:** `rdx:rax = rax * src (8 bit: ax = al * src; 16: dx:ax; 32: edx:eax)`

**Flags:** OF CF &nbsp; undefined: SF ZF AF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulpd – Multiplication of 2 doubles

**Syntax:** `mulpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] * src[i] (double)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulps – Multiplication of 4 singles

**Syntax:** `mulps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] * src[i] (single)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulsd – Multiplication of one double

**Syntax:** `mulsd xmm, xmm/m64`

**Operation:** `dst[0] = dst[0] * src[0] (double); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## mulss – Multiplication of one single

**Syntax:** `mulss xmm, xmm/m32`

**Operation:** `dst[0] = dst[0] * src[0] (single); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## mwait – Wait for a change of the monitored address

**Syntax:** `mwait`

**Operation:** `wait until the watched address is written or an interrupt comes`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## mwaitx – Wait for a change of the monitored address

**Syntax:** `mwaitx`

**Operation:** `wait until the watched address is written or an interrupt comes`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## neg – Negation (two's complement)

**Syntax:** `neg r/m8` &nbsp; `neg r/m32` &nbsp; `neg r/m16` &nbsp; `neg r/m64`

**Operation:** `dst = 0 - dst; CF = (dst != 0)`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## nop – No operation

**Syntax:** `nop` &nbsp; `nop r/m32` &nbsp; `nop r/m16` &nbsp; `nop r32` &nbsp; `nop eax` &nbsp; `nop ebp` &nbsp; `nop ecx` &nbsp; `nop edi` &nbsp; …

**Operation:** `no operation`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## not – Inversion of all bits (one's complement)

**Syntax:** `not r/m8` &nbsp; `not r/m32` &nbsp; `not r/m16` &nbsp; `not r/m64`

**Operation:** `dst = ~dst`

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## or – Bitwise OR

**Syntax:** `or r/m8, r8` &nbsp; `or r/m32, r32` &nbsp; `or r/m16, r16` &nbsp; `or r8, r/m8` &nbsp; `or r32, r/m32` &nbsp; `or r16, r/m16` &nbsp; `or al, imm8` &nbsp; `or eax, imm32` &nbsp; …

**Operation:** `dst = dst OR src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## orpd – Bitwise OR

**Syntax:** `orpd xmm, xmm/m128`

**Operation:** `dst = dst OR src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## orps – Bitwise OR

**Syntax:** `orps xmm, xmm/m128`

**Operation:** `dst = dst OR src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## out – Write of a value to an I/O port

**Syntax:** `out imm8, al` &nbsp; `out imm8, eax` &nbsp; `out imm8, ax` &nbsp; `out dx, al` &nbsp; `out dx, eax` &nbsp; `out dx, ax`

**Operation:** `port[dst] = src`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## outsb – Write of [rsi] to a port, rsi advances

**Syntax:** `outsb`

**Operation:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## outsd – Write of [rsi] to a port, rsi advances

**Syntax:** `outsd`

**Operation:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## outsw – Write of [rsi] to a port, rsi advances

**Syntax:** `outsw`

**Operation:** `port[dx] = [rsi]; rsi = rsi +/- size`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## pabsb – Absolute value of bytes

**Syntax:** `pabsb mm, mm/m64` &nbsp; `pabsb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = abs(src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pabsd – Absolute value of 32-bit elements

**Syntax:** `pabsd mm, mm/m64` &nbsp; `pabsd xmm, xmm/m64`

**Operation:** `for every 32 bit element: dst[i] = abs(src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pabsw – Absolute value of 16-bit elements

**Syntax:** `pabsw mm, mm/m64` &nbsp; `pabsw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = abs(src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## packssdw – Packing of 32 to 16 bit signed (saturating)

**Syntax:** `packssdw mm, mm/m64` &nbsp; `packssdw xmm, xmm/m128`

**Operation:** `dst = (sat16_s(dst[i]) ..., sat16_s(src[i]) ...) (32 to 16 bit, signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## packsswb – Packing of 16 to 8 bit signed (saturating)

**Syntax:** `packsswb mm, mm/m64` &nbsp; `packsswb xmm, xmm/m128`

**Operation:** `dst = (sat8_s(dst[i]) ..., sat8_s(src[i]) ...) (16 to 8 bit, signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## packusdw – Packing of 32 to 16 bit unsigned (saturating)

**Syntax:** `packusdw xmm, xmm/m128`

**Operation:** `dst = (sat16_u(dst[i]) ..., sat16_u(src[i]) ...) (32 to 16 bit, unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## packuswb – Packing of 16 to 8 bit unsigned (saturating)

**Syntax:** `packuswb mm, mm/m64` &nbsp; `packuswb xmm, xmm/m128`

**Operation:** `dst = (sat8_u(dst[i]) ..., sat8_u(src[i]) ...) (16 to 8 bit, unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddb – Addition of bytes

**Syntax:** `paddb mm, mm/m64` &nbsp; `paddb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = dst[i] + src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddd – Addition of 32-bit elements

**Syntax:** `paddd mm, mm/m64` &nbsp; `paddd xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = dst[i] + src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddq – Addition of 64-bit elements

**Syntax:** `paddq mm, mm/m64` &nbsp; `paddq xmm, xmm/m128`

**Operation:** `for every 64 bit element: dst[i] = dst[i] + src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddsb – Addition of bytes (signed, saturating)

**Syntax:** `paddsb mm, mm/m64` &nbsp; `paddsb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = sat_s(dst[i] + src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddsw – Addition of 16-bit elements (signed, saturating)

**Syntax:** `paddsw mm, mm/m64` &nbsp; `paddsw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = sat_s(dst[i] + src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddusb – Addition of bytes (unsigned, saturating)

**Syntax:** `paddusb mm, mm/m64` &nbsp; `paddusb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = sat_u(dst[i] + src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddusw – Addition of 16-bit elements (unsigned, saturating)

**Syntax:** `paddusw mm, mm/m64` &nbsp; `paddusw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = sat_u(dst[i] + src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## paddw – Addition of 16-bit elements

**Syntax:** `paddw mm, mm/m64` &nbsp; `paddw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = dst[i] + src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## palignr – Concatenation of two registers and shift by a number of bytes

**Syntax:** `palignr mm, mm/m64, imm8` &nbsp; `palignr xmm, xmm/m128, imm8`

**Operation:** `dst = low part of (dst:src >> (imm8 * 8 bits))`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pand – Bitwise AND

**Syntax:** `pand mm, mm/m64` &nbsp; `pand xmm, xmm/m128`

**Operation:** `dst = dst & src`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pandn – Bitwise: NOT destination AND source

**Syntax:** `pandn mm, mm/m64` &nbsp; `pandn xmm, xmm/m128`

**Operation:** `dst = ~dst & src`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pause – Hint in spin loops

**Syntax:** `pause`

Hint in spin loops (saves power, helps hyper-threading).

**Operation:** `hint: this is a wait loop (no change)`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## pavgb – Average of bytes (rounded)

**Syntax:** `pavgb mm, mm/m64` &nbsp; `pavgb xmm, xmm/m128`

**Operation:** `dst[i] = (dst[i] + src[i] + 1) >> 1 (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pavgw – Average of 16-bit elements (rounded)

**Syntax:** `pavgw mm, mm/m64` &nbsp; `pavgw xmm, xmm/m128`

**Operation:** `dst[i] = (dst[i] + src[i] + 1) >> 1 (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pblendvb – Selection of bytes by the sign bits of xmm0

**Syntax:** `pblendvb xmm, xmm/m128, xmm0`

**Operation:** `for every element: dst[i] = (sign bit of xmm0[i]) ? src[i] : dst[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pblendw – Selection of 16-bit elements by a mask

**Syntax:** `pblendw xmm, xmm/m128, imm8`

**Operation:** `for every element: dst[i] = bit i of imm8 ? src[i] : dst[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pclmulqdq – Carry-less multiplication

**Syntax:** `pclmulqdq xmm, xmm/m128, imm8`

Carry-less multiplication (Galois field, for CRC and GCM).

**Operation:** `dst = carry-less product of one quadword of dst and one of src (chosen by imm8)`

*Group: Cryptography. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpeqb – Comparison for equal (bytes), the result is a mask

**Syntax:** `pcmpeqb mm, mm/m64` &nbsp; `pcmpeqb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpeqd – Comparison for equal

**Syntax:** `pcmpeqd mm, mm/m64` &nbsp; `pcmpeqd xmm, xmm/m128`

Comparison for equal (32-bit elements), the result is a mask.

**Operation:** `for every 32 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpeqq – Comparison for equal

**Syntax:** `pcmpeqq xmm, xmm/m128`

Comparison for equal (64-bit elements), the result is a mask.

**Operation:** `for every 64 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpeqw – Comparison for equal

**Syntax:** `pcmpeqw mm, mm/m64` &nbsp; `pcmpeqw xmm, xmm/m128`

Comparison for equal (16-bit elements), the result is a mask.

**Operation:** `for every 16 bit element: dst[i] = (dst[i] == src[i]) ? all 1 bits : 0`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpestri – Comparison of strings

**Syntax:** `pcmpestri xmm, xmm/m128, imm8`

Comparison of strings (explicit lengths), the result is an index.

**Operation:** `ECX = index of the match of the strings dst, src (lengths in eax, edx; mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpestrm – Comparison of strings

**Syntax:** `pcmpestrm xmm, xmm/m128, imm8`

Comparison of strings (explicit lengths), the result is a mask.

**Operation:** `xmm0 = mask of the matches of the strings dst, src (lengths in eax, edx; mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpgtb – Comparison for greater

**Syntax:** `pcmpgtb mm, mm/m64` &nbsp; `pcmpgtb xmm, xmm/m128`

Comparison for greater, signed (bytes), the result is a mask.

**Operation:** `for every 8 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpgtd – Comparison for greater

**Syntax:** `pcmpgtd mm, mm/m64` &nbsp; `pcmpgtd xmm, xmm/m128`

Comparison for greater, signed (32-bit elements), the result is a mask.

**Operation:** `for every 32 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpgtq – Comparison for greater

**Syntax:** `pcmpgtq xmm, xmm/m128`

Comparison for greater, signed (64-bit elements), the result is a mask.

**Operation:** `for every 64 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpgtw – Comparison for greater

**Syntax:** `pcmpgtw mm, mm/m64` &nbsp; `pcmpgtw xmm, xmm/m128`

Comparison for greater, signed (16-bit elements), the result is a mask.

**Operation:** `for every 16 bit element: dst[i] = (dst[i] > src[i]) ? all 1 bits : 0 (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpistri – Comparison of strings

**Syntax:** `pcmpistri xmm, xmm/m128, imm8`

Comparison of strings (0 terminated), the result is an index.

**Operation:** `ECX = index of the match of the 0-terminated strings dst, src (mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pcmpistrm – Comparison of strings

**Syntax:** `pcmpistrm xmm, xmm/m128, imm8`

Comparison of strings (0 terminated), the result is a mask.

**Operation:** `xmm0 = mask of the matches of the 0-terminated strings dst, src (mode imm8)`

**Flags:** OF SF ZF AF CF PF

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pextrb – Extraction of an element from xmm into a register

**Syntax:** `pextrb r32/m8, xmm, imm8`

**Operation:** `dst = element number imm8 of src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pextrd – Extraction of an element from xmm into a register

**Syntax:** `pextrd r/m32, xmm, imm8`

**Operation:** `dst = element number imm8 of src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pextrq – Extraction of an element from xmm into a register

**Syntax:** `pextrq r/m64, xmm, imm8`

**Operation:** `dst = element number imm8 of src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pextrw – Extraction of an element from xmm into a register

**Syntax:** `pextrw r32, mm, imm8` &nbsp; `pextrw r32, xmm, imm8` &nbsp; `pextrw r32/m16, xmm, imm8`

**Operation:** `dst = element number imm8 of src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## phaddd – Addition of adjacent 32-bit elements (horizontal)

**Syntax:** `phaddd mm, mm/m64` &nbsp; `phaddd xmm, xmm/m128`

**Operation:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phaddsw – Addition of adjacent 16-bit elements

**Syntax:** `phaddsw mm, mm/m64` &nbsp; `phaddsw xmm, xmm/m128`

Addition of adjacent 16-bit elements (horizontal), saturating.

**Operation:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...) (saturating)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phaddw – Addition of adjacent 16-bit elements (horizontal)

**Syntax:** `phaddw mm, mm/m64` &nbsp; `phaddw xmm, xmm/m128`

**Operation:** `dst = (dst[0] + dst[1], dst[2] + dst[3], ..., src[0] + src[1], ...)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phminposuw – Search for the smallest 16-bit element and its position

**Syntax:** `phminposuw xmm, xmm/m128`

**Operation:** `dst = (smallest unsigned word of src, its index, 0 ...)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phsubd – Subtraction of adjacent 32-bit elements

**Syntax:** `phsubd mm, mm/m64` &nbsp; `phsubd xmm, xmm/m128`

Subtraction of adjacent 32-bit elements (horizontal).

**Operation:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phsubsw – Subtraction of adjacent 16-bit elements

**Syntax:** `phsubsw mm, mm/m64` &nbsp; `phsubsw xmm, xmm/m128`

Subtraction of adjacent 16-bit elements (horizontal), saturating.

**Operation:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...) (saturating)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## phsubw – Subtraction of adjacent 16-bit elements

**Syntax:** `phsubw mm, mm/m64` &nbsp; `phsubw xmm, xmm/m128`

Subtraction of adjacent 16-bit elements (horizontal).

**Operation:** `dst = (dst[0] - dst[1], dst[2] - dst[3], ..., src[0] - src[1], ...)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pinsrb – Insertion of an element from a register into xmm

**Syntax:** `pinsrb xmm, r32/m8, imm8`

**Operation:** `dst = dst with element number imm8 replaced by src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pinsrd – Insertion of an element from a register into xmm

**Syntax:** `pinsrd xmm, r/m32, imm8`

**Operation:** `dst = dst with element number imm8 replaced by src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pinsrq – Insertion of an element from a register into xmm

**Syntax:** `pinsrq xmm, r/m64, imm8`

**Operation:** `dst = dst with element number imm8 replaced by src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pinsrw – Insertion of an element from a register into xmm

**Syntax:** `pinsrw mm, r32/m16, imm8` &nbsp; `pinsrw xmm, r32/m16, imm8`

**Operation:** `dst = dst with element number imm8 replaced by src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaddubsw – Multiplication of byte pairs and addition

**Syntax:** `pmaddubsw mm, mm/m64` &nbsp; `pmaddubsw xmm, xmm/m128`

Multiplication of byte pairs and addition (saturating).

**Operation:** `dst[i] = sat16(dst_u8[2i] * src_s8[2i] + dst_u8[2i+1] * src_s8[2i+1])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaddwd – Multiplication of 16-bit pairs and addition to 32 bit

**Syntax:** `pmaddwd mm, mm/m64` &nbsp; `pmaddwd xmm, xmm/m128`

**Operation:** `dst[i] = dst_s16[2i] * src_s16[2i] + dst_s16[2i+1] * src_s16[2i+1] (32 bit)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxsb – Maximum of bytes (signed)

**Syntax:** `pmaxsb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxsd – Maximum of 32-bit elements (signed)

**Syntax:** `pmaxsd xmm, xmm/m64`

**Operation:** `for every 32 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxsw – Maximum of 16-bit elements (signed)

**Syntax:** `pmaxsw mm, mm/m64` &nbsp; `pmaxsw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = max(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxub – Maximum of bytes (unsigned)

**Syntax:** `pmaxub mm, mm/m64` &nbsp; `pmaxub xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxud – Maximum of 32-bit elements (unsigned)

**Syntax:** `pmaxud xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmaxuw – Maximum of 16-bit elements (unsigned)

**Syntax:** `pmaxuw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = max(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminsb – Minimum of bytes (signed)

**Syntax:** `pminsb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminsd – Minimum of 32-bit elements (signed)

**Syntax:** `pminsd xmm, xmm/m64`

**Operation:** `for every 32 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminsw – Minimum of 16-bit elements (signed)

**Syntax:** `pminsw mm, mm/m64` &nbsp; `pminsw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = min(dst[i], src[i]) (signed)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminub – Minimum of bytes (unsigned)

**Syntax:** `pminub mm, mm/m64` &nbsp; `pminub xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminud – Minimum of 32-bit elements (unsigned)

**Syntax:** `pminud xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pminuw – Minimum of 16-bit elements (unsigned)

**Syntax:** `pminuw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = min(dst[i], src[i]) (unsigned)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovmskb – Gathering of the sign bits of the bytes into a register

**Syntax:** `pmovmskb r32, mm` &nbsp; `pmovmskb r32, xmm`

**Operation:** `dst = the top bits of all bytes of src`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxbd – Extension of bytes to 32 bit (sign-extending)

**Syntax:** `pmovsxbd xmm, xmm/m32`

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxbq – Extension of bytes to 64 bit (sign-extending)

**Syntax:** `pmovsxbq xmm, xmm/m16`

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxbw – Extension of bytes to 16 bit (sign-extending)

**Syntax:** `pmovsxbw xmm, xmm/m64`

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxdq – Extension of 32-bit elements to 64 bit

**Syntax:** `pmovsxdq xmm, xmm/m64`

Extension of 32-bit elements to 64 bit (sign-extending).

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxwd – Extension of 16-bit elements to 32 bit

**Syntax:** `pmovsxwd xmm, xmm/m64`

Extension of 16-bit elements to 32 bit (sign-extending).

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovsxwq – Extension of 16-bit elements to 64 bit

**Syntax:** `pmovsxwq xmm, xmm/m32`

Extension of 16-bit elements to 64 bit (sign-extending).

**Operation:** `for every element: dst[i] = sext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxbd – Extension of bytes to 32 bit (zero-extending)

**Syntax:** `pmovzxbd xmm, xmm/m32`

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxbq – Extension of bytes to 64 bit (zero-extending)

**Syntax:** `pmovzxbq xmm, xmm/m16`

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxbw – Extension of bytes to 16 bit (zero-extending)

**Syntax:** `pmovzxbw xmm, xmm/m64`

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxdq – Extension of 32-bit elements to 64 bit

**Syntax:** `pmovzxdq xmm, xmm/m64`

Extension of 32-bit elements to 64 bit (zero-extending).

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxwd – Extension of 16-bit elements to 32 bit

**Syntax:** `pmovzxwd xmm, xmm/m64`

Extension of 16-bit elements to 32 bit (zero-extending).

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmovzxwq – Extension of 16-bit elements to 64 bit

**Syntax:** `pmovzxwq xmm, xmm/m32`

Extension of 16-bit elements to 64 bit (zero-extending).

**Operation:** `for every element: dst[i] = zext(src[i]) to the wider size`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmuldq – Multiplication of signed 32 bit to 64 bit

**Syntax:** `pmuldq xmm, xmm/m128`

**Operation:** `dst[i] = dst_s32[2i] * src_s32[2i] (64 bit results)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmulhrsw – Multiplication of signed 16 bit, rounded

**Syntax:** `pmulhrsw mm, mm/m64` &nbsp; `pmulhrsw xmm, xmm/m128`

**Operation:** `dst[i] = (dst[i] * src[i] >> 14 + 1) >> 1 (signed 16 bit, rounded)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmulhuw – Multiplication of unsigned 16 bit

**Syntax:** `pmulhuw mm, mm/m64` &nbsp; `pmulhuw xmm, xmm/m128`

Multiplication of unsigned 16 bit, the high half is kept.

**Operation:** `dst[i] = (dst[i] * src[i]) >> 16 (unsigned 16 bit)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmulhw – Multiplication of signed 16 bit

**Syntax:** `pmulhw mm, mm/m64` &nbsp; `pmulhw xmm, xmm/m128`

Multiplication of signed 16 bit, the high half is kept.

**Operation:** `dst[i] = (dst[i] * src[i]) >> 16 (signed 16 bit)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmulld – Multiplication of 32 bit, the low half is kept

**Syntax:** `pmulld xmm, xmm/m128`

**Operation:** `dst[i] = low 32 bits of dst[i] * src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmullw – Multiplication of 16 bit, the low half is kept

**Syntax:** `pmullw mm, mm/m64` &nbsp; `pmullw xmm, xmm/m128`

**Operation:** `dst[i] = low 16 bits of dst[i] * src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pmuludq – Multiplication of unsigned 32 bit to 64 bit

**Syntax:** `pmuludq mm, mm/m64` &nbsp; `pmuludq xmm, xmm/m128`

**Operation:** `dst[i] = dst_u32[2i] * src_u32[2i] (64 bit results)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pop – Pop of a value from the stack

**Syntax:** `pop es` &nbsp; `pop ss` &nbsp; `pop ds` &nbsp; `pop r32` &nbsp; `pop r16` &nbsp; `pop r/m32` &nbsp; `pop r/m16` &nbsp; `pop fs` &nbsp; …

**Operation:** `dst = [rsp]; rsp = rsp + 8 (16 bit: 2 bytes)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## popad – Pop of all 32-bit registers from the stack

**Syntax:** `popad`

**Operation:** `edi, esi, ebp = pop(); (esp is skipped); ebx, edx, ecx, eax = pop()`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## popaw – Pop of all 16-bit registers from the stack

**Syntax:** `popaw`

**Operation:** `di, si, bp = pop(); (sp is skipped); bx, dx, cx, ax = pop()`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## popcnt – Count of the set bits

**Syntax:** `popcnt r32, r/m32` &nbsp; `popcnt r64, r/m64`

**Operation:** `dst = number of 1 bits in src`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## popfd – Pop of the flags register (32 bit) from the stack

**Syntax:** `popfd`

**Operation:** `eflags = pop() (privileged bits stay)`

**Flags:** all

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## popfq – Pop of the flags register from the stack

**Syntax:** `popfq`

**Operation:** `flags = pop() (privileged bits stay)`

**Flags:** all

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## popfw – Pop of the flags register from the stack

**Syntax:** `popfw`

**Operation:** `flags = pop() (privileged bits stay)`

**Flags:** all

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## por – Bitwise OR

**Syntax:** `por mm, mm/m64` &nbsp; `por xmm, xmm/m128`

**Operation:** `dst = dst OR src`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetch – Prefetch of a cache line (w: for writing)

**Syntax:** `prefetch m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetchnta – Prefetch, trying not to pollute the cache

**Syntax:** `prefetchnta m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetcht0 – Prefetch into all cache levels

**Syntax:** `prefetcht0 m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetcht1 – Prefetch into cache level 2 and higher

**Syntax:** `prefetcht1 m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetcht2 – Prefetch into cache level 3

**Syntax:** `prefetcht2 m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## prefetchw – Prefetch of a cache line (w: for writing)

**Syntax:** `prefetchw m`

**Operation:** `load the cache line of [m] into the cache (a hint, no change of the program)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## psadbw – Sum of absolute byte differences

**Syntax:** `psadbw mm, mm/m64` &nbsp; `psadbw xmm, xmm/m128`

**Operation:** `dst[i] = sum of abs(dst_u8[j] - src_u8[j]) over 8 bytes`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pshufb – Shuffle of bytes by a table in the source register

**Syntax:** `pshufb mm, mm/m64` &nbsp; `pshufb xmm, xmm/m128`

**Operation:** `dst[i] = (src[i] has top bit 1) ? 0 : dst[src[i] & 15]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pshufd – Shuffle of the 32-bit elements as told

**Syntax:** `pshufd xmm, xmm/m128, imm8`

**Operation:** `dst = (src[sel0], src[sel1], src[sel2], src[sel3]); sel = bit pairs of imm8`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pshufhw – Shuffle of the upper four 16-bit elements

**Syntax:** `pshufhw xmm, xmm/m128, imm8`

**Operation:** `dst[63:0] = src[63:0]; the upper four words are chosen from src[127:64] by imm8`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pshuflw – Shuffle of the lower four 16-bit elements

**Syntax:** `pshuflw xmm, xmm/m128, imm8`

**Operation:** `dst[127:64] = src[127:64]; the lower four words are chosen from src[63:0] by imm8`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pshufw – Shuffle of four 16-bit elements (mm)

**Syntax:** `pshufw mm, mm/m64, imm8`

**Operation:** `dst = four words chosen from src by imm8 (mm)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psignb – Application of the sign of the source to bytes

**Syntax:** `psignb mm, mm/m64` &nbsp; `psignb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psignd – Application of the sign of the source to 32-bit elements

**Syntax:** `psignd mm, mm/m64` &nbsp; `psignd xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psignw – Application of the sign of the source to 16-bit elements

**Syntax:** `psignw mm, mm/m64` &nbsp; `psignw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = src[i] < 0 ? -dst[i] : (src[i] == 0 ? 0 : dst[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pslld – Shift of 32-bit elements left

**Syntax:** `pslld mm, imm8` &nbsp; `pslld xmm, imm8` &nbsp; `pslld mm, mm/m64` &nbsp; `pslld xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## pslldq – Shift of the whole register left by bytes

**Syntax:** `pslldq xmm, imm8`

**Operation:** `dst = dst << (imm8 * 8 bits) (the whole register, zeros come in)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psllq – Shift of 64-bit elements left

**Syntax:** `psllq mm, imm8` &nbsp; `psllq xmm, imm8` &nbsp; `psllq mm, mm/m64` &nbsp; `psllq xmm, xmm/m128`

**Operation:** `for every 64 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psllw – Shift of 16-bit elements left

**Syntax:** `psllw mm, imm8` &nbsp; `psllw xmm, imm8` &nbsp; `psllw mm, mm/m64` &nbsp; `psllw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = dst[i] << count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psrad – Shift of 32-bit elements right (arithmetic)

**Syntax:** `psrad mm, imm8` &nbsp; `psrad xmm, imm8` &nbsp; `psrad mm, mm/m64` &nbsp; `psrad xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = dst[i] >>s count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psraw – Shift of 16-bit elements right (arithmetic)

**Syntax:** `psraw mm, imm8` &nbsp; `psraw xmm, imm8` &nbsp; `psraw mm, mm/m64` &nbsp; `psraw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = dst[i] >>s count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psrld – Shift of 32-bit elements right (logical)

**Syntax:** `psrld mm, imm8` &nbsp; `psrld xmm, imm8` &nbsp; `psrld mm, mm/m64` &nbsp; `psrld xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psrldq – Shift of the whole register right by bytes

**Syntax:** `psrldq xmm, imm8`

**Operation:** `dst = dst >> (imm8 * 8 bits) (the whole register, zeros come in)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psrlq – Shift of 64-bit elements right (logical)

**Syntax:** `psrlq mm, imm8` &nbsp; `psrlq xmm, imm8` &nbsp; `psrlq mm, mm/m64` &nbsp; `psrlq xmm, xmm/m128`

**Operation:** `for every 64 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psrlw – Shift of 16-bit elements right (logical)

**Syntax:** `psrlw mm, imm8` &nbsp; `psrlw xmm, imm8` &nbsp; `psrlw mm, mm/m64` &nbsp; `psrlw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = dst[i] >> count (count = src or imm8)`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubb – Subtraction of bytes

**Syntax:** `psubb mm, mm/m64` &nbsp; `psubb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = dst[i] - src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubd – Subtraction of 32-bit elements

**Syntax:** `psubd mm, mm/m64` &nbsp; `psubd xmm, xmm/m128`

**Operation:** `for every 32 bit element: dst[i] = dst[i] - src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubq – Subtraction of 64-bit elements

**Syntax:** `psubq mm, mm/m64` &nbsp; `psubq xmm, xmm/m128`

**Operation:** `for every 64 bit element: dst[i] = dst[i] - src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubsb – Subtraction of bytes (signed, saturating)

**Syntax:** `psubsb mm, mm/m64` &nbsp; `psubsb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = sat_s(dst[i] - src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubsw – Subtraction of 16-bit elements

**Syntax:** `psubsw mm, mm/m64` &nbsp; `psubsw xmm, xmm/m128`

Subtraction of 16-bit elements (signed, saturating).

**Operation:** `for every 16 bit element: dst[i] = sat_s(dst[i] - src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubusb – Subtraction of bytes (unsigned, saturating)

**Syntax:** `psubusb mm, mm/m64` &nbsp; `psubusb xmm, xmm/m128`

**Operation:** `for every 8 bit element: dst[i] = sat_u(dst[i] - src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubusw – Subtraction of 16-bit elements

**Syntax:** `psubusw mm, mm/m64` &nbsp; `psubusw xmm, xmm/m128`

Subtraction of 16-bit elements (unsigned, saturating).

**Operation:** `for every 16 bit element: dst[i] = sat_u(dst[i] - src[i])`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## psubw – Subtraction of 16-bit elements

**Syntax:** `psubw mm, mm/m64` &nbsp; `psubw xmm, xmm/m128`

**Operation:** `for every 16 bit element: dst[i] = dst[i] - src[i]`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## ptest – Bit test (sets ZF and CF)

**Syntax:** `ptest xmm, xmm/m128`

**Operation:** `ZF = ((dst & src) == 0); CF = ((~dst & src) == 0); OF SF AF PF = 0`

**Flags:** OF SF ZF AF CF PF

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpckhbw – Interleave of the high bytes of two registers

**Syntax:** `punpckhbw mm, mm/m64` &nbsp; `punpckhbw xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpckhdq – Interleave of the high 32-bit elements of two registers

**Syntax:** `punpckhdq mm, mm/m64` &nbsp; `punpckhdq xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpckhqdq – Interleave of the high 64-bit elements of two registers

**Syntax:** `punpckhqdq xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpckhwd – Interleave of the high 16-bit elements of two registers

**Syntax:** `punpckhwd mm, mm/m64` &nbsp; `punpckhwd xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the high half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpcklbw – Interleave of the low bytes of two registers

**Syntax:** `punpcklbw mm, mm/m64` &nbsp; `punpcklbw xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpckldq – Interleave of the low 32-bit elements of two registers

**Syntax:** `punpckldq mm, mm/m64` &nbsp; `punpckldq xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpcklqdq – Interleave of the low 64-bit elements of two registers

**Syntax:** `punpcklqdq xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## punpcklwd – Interleave of the low 16-bit elements of two registers

**Syntax:** `punpcklwd mm, mm/m64` &nbsp; `punpcklwd xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1], ...) of the low half of the elements`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## push – Push of a value onto the stack

**Syntax:** `push es` &nbsp; `push cs` &nbsp; `push ss` &nbsp; `push ds` &nbsp; `push r32` &nbsp; `push r16` &nbsp; `push imm32` &nbsp; `push imm16` &nbsp; …

**Operation:** `rsp = rsp - 8; [rsp] = src (16 bit: 2 bytes)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pushad – Push of all 32-bit registers onto the stack

**Syntax:** `pushad`

**Operation:** `tmp = esp; push(eax, ecx, edx, ebx, tmp, ebp, esi, edi)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pushaw – Push of all 16-bit registers onto the stack

**Syntax:** `pushaw`

**Operation:** `tmp = sp; push(ax, cx, dx, bx, tmp, bp, si, di)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pushfd – Push of the flags register (32 bit) onto the stack

**Syntax:** `pushfd`

**Operation:** `push(eflags)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pushfq – Push of the flags register onto the stack

**Syntax:** `pushfq`

**Operation:** `push(flags)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pushfw – Push of the flags register onto the stack

**Syntax:** `pushfw`

**Operation:** `push(flags)`

*Group: Stack. Short description from the instruction reference; there is no longer explanation for it yet.*

## pxor – Bitwise exclusive OR (pxor x, x clears)

**Syntax:** `pxor mm, mm/m64` &nbsp; `pxor xmm, xmm/m128`

**Operation:** `dst = dst ^ src`

*Group: SSE and MMX integers. Short description from the instruction reference; there is no longer explanation for it yet.*

## rcl – Rotation to the left through the carry flag

**Syntax:** `rcl r/m8, imm8` &nbsp; `rcl r/m32, imm8` &nbsp; `rcl r/m16, imm8` &nbsp; `rcl r/m8, 1` &nbsp; `rcl r/m32, 1` &nbsp; `rcl r/m16, 1` &nbsp; `rcl r/m8, cl` &nbsp; `rcl r/m32, cl` &nbsp; …

**Operation:** `rotate_left(CF:dst, count) as one value of width + 1 bits`

**Flags:** OF CF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## rcpps – Reciprocal (approximate) of 4 singles

**Syntax:** `rcpps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = 1 / src[i] (approximate)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## rcpss – Reciprocal (approximate) of one single

**Syntax:** `rcpss xmm, xmm/m32`

**Operation:** `dst[0] = 1 / src[0] (approximate); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## rcr – Rotation to the right through the carry flag

**Syntax:** `rcr r/m8, imm8` &nbsp; `rcr r/m32, imm8` &nbsp; `rcr r/m16, imm8` &nbsp; `rcr r/m8, 1` &nbsp; `rcr r/m32, 1` &nbsp; `rcr r/m16, 1` &nbsp; `rcr r/m8, cl` &nbsp; `rcr r/m32, cl` &nbsp; …

**Operation:** `rotate_right(CF:dst, count) as one value of width + 1 bits`

**Flags:** OF CF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdfsbase – Read of the base address of fs/gs

**Syntax:** `rdfsbase r32` &nbsp; `rdfsbase r64`

**Operation:** `dst = base address of fs`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdgsbase – Read of the base address of fs/gs

**Syntax:** `rdgsbase r32` &nbsp; `rdgsbase r64`

**Operation:** `dst = base address of gs`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdmsr – Read of a model-specific register (privileged)

**Syntax:** `rdmsr`

**Operation:** `edx:eax = model-specific register number ecx (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdpid – Read of the processor id

**Syntax:** `rdpid r64`

**Operation:** `dst = id of the processor`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdpmc – Read of a performance counter

**Syntax:** `rdpmc`

**Operation:** `edx:eax = performance counter number ecx`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdrand – Read of a random number from the processor

**Syntax:** `rdrand r32` &nbsp; `rdrand r16` &nbsp; `rdrand r64`

**Operation:** `dst = random number from the processor; CF = 1 if it is valid`

**Flags:** OF SF ZF AF CF PF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdseed – Read of a seed for random number generators

**Syntax:** `rdseed r32` &nbsp; `rdseed r16` &nbsp; `rdseed r64`

**Operation:** `dst = seed value for random number generators; CF = 1 if it is valid`

**Flags:** OF SF ZF AF CF PF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdsspd – Read of the shadow stack pointer

**Syntax:** `rdsspd r32`

**Operation:** `dst = shadow stack pointer`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdsspq – Read of the shadow stack pointer

**Syntax:** `rdsspq r64`

**Operation:** `dst = shadow stack pointer`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdtsc – Read of the time stamp counter (clock cycles)

**Syntax:** `rdtsc`

**Operation:** `edx:eax = time stamp counter`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rdtscp – Read of the time stamp counter and the processor id

**Syntax:** `rdtscp`

**Operation:** `edx:eax = time stamp counter; ecx = processor id`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## ret – Return from the function (the address is popped)

**Syntax:** `ret imm16` &nbsp; `ret`

**Operation:** `rip = pop(); with imm16: rsp = rsp + imm16 afterwards`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## retf – Return from a far function

**Syntax:** `retf imm16` &nbsp; `retf`

**Operation:** `rip = pop(); cs = pop()`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## rol – Rotation to the left

**Syntax:** `rol r/m8, imm8` &nbsp; `rol r/m32, imm8` &nbsp; `rol r/m16, imm8` &nbsp; `rol r/m8, 1` &nbsp; `rol r/m32, 1` &nbsp; `rol r/m16, 1` &nbsp; `rol r/m8, cl` &nbsp; `rol r/m32, cl` &nbsp; …

**Operation:** `dst = rotate_left(dst, count); CF = lowest bit of the result`

**Flags:** OF CF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## ror – Rotation to the right

**Syntax:** `ror r/m8, imm8` &nbsp; `ror r/m32, imm8` &nbsp; `ror r/m16, imm8` &nbsp; `ror r/m8, 1` &nbsp; `ror r/m32, 1` &nbsp; `ror r/m16, 1` &nbsp; `ror r/m8, cl` &nbsp; `ror r/m32, cl` &nbsp; …

**Operation:** `dst = rotate_right(dst, count); CF = highest bit of the result`

**Flags:** OF CF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## roundpd – Rounding of 2 doubles to whole numbers

**Syntax:** `roundpd xmm, xmm/m128, imm8`

**Operation:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## roundps – Rounding of 4 singles to whole numbers

**Syntax:** `roundps xmm, xmm/m128, imm8`

**Operation:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## roundsd – Rounding of one double to a whole number

**Syntax:** `roundsd xmm, xmm/m64, imm8`

**Operation:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## roundss – Rounding of one single to a whole number

**Syntax:** `roundss xmm, xmm/m32, imm8`

**Operation:** `dst[i] = round(src[i]) with the rounding mode of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsm – Leaving of system management mode (SMM)

**Syntax:** `rsm`

**Operation:** `leave system management mode, restore the saved state`

**Flags:** all

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsqrtps – Reciprocal square root (approximate) of 4 singles

**Syntax:** `rsqrtps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = 1 / sqrt(src[i]) (approximate)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## rsqrtss – Reciprocal square root (approximate) of one single

**Syntax:** `rsqrtss xmm, xmm/m32`

**Operation:** `dst[0] = 1 / sqrt(src[0]) (approximate); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## sahf – Store of ah into the flags

**Syntax:** `sahf`

**Operation:** `SF ZF AF PF CF = bits of ah`

**Flags:** SF ZF AF CF PF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## salc – Setting of al from CF (undocumented)

**Syntax:** `salc`

**Operation:** `al = CF ? 255 : 0`

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## sar – Shift right signed (the sign bit stays)

**Syntax:** `sar r/m8, imm8` &nbsp; `sar r/m32, imm8` &nbsp; `sar r/m16, imm8` &nbsp; `sar r/m8, 1` &nbsp; `sar r/m32, 1` &nbsp; `sar r/m16, 1` &nbsp; `sar r/m8, cl` &nbsp; `sar r/m32, cl` &nbsp; …

**Operation:** `dst = dst >>s count (sign bit comes in); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## sbb – Subtraction with borrow (CF)

**Syntax:** `sbb r/m8, r8` &nbsp; `sbb r/m32, r32` &nbsp; `sbb r/m16, r16` &nbsp; `sbb r8, r/m8` &nbsp; `sbb r32, r/m32` &nbsp; `sbb r16, r/m16` &nbsp; `sbb al, imm8` &nbsp; `sbb eax, imm32` &nbsp; …

**Operation:** `dst = dst - src - CF`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## scasb – Comparison of al/ax/eax/rax with [rdi]

**Syntax:** `scasb`

Comparison of al/ax/eax/rax with [rdi], rdi advances.

**Operation:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## scasd – Comparison of al/ax/eax/rax with [rdi]

**Syntax:** `scasd`

Comparison of al/ax/eax/rax with [rdi], rdi advances.

**Operation:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## scasq – Comparison of al/ax/eax/rax with [rdi]

**Syntax:** `scasq`

Comparison of al/ax/eax/rax with [rdi], rdi advances.

**Operation:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## scasw – Comparison of al/ax/eax/rax with [rdi]

**Syntax:** `scasw`

Comparison of al/ax/eax/rax with [rdi], rdi advances.

**Operation:** `flags = acc - [rdi]; rdi = +/- size; with repe / repne: repeat, at most rcx times`

**Flags:** OF SF ZF AF CF PF

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## seta – Setting of the byte to 1 if unsigned above

**Syntax:** `seta r/m8`

Setting of the byte to 1 if unsigned above (CF=0 and ZF=0), else to 0.

**Operation:** `dst = (CF = 0 and ZF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setbe – Setting of the byte to 1 if unsigned below or equal

**Syntax:** `setbe r/m8`

Setting of the byte to 1 if unsigned below or equal (CF=1 or ZF=1), else to 0.

**Operation:** `dst = (CF = 1 or ZF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setc – Setting of the byte to 1 if carry

**Syntax:** `setc r/m8`

Setting of the byte to 1 if carry, unsigned below (CF=1), else to 0.

**Operation:** `dst = (CF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setg – Setting of the byte to 1 if signed greater

**Syntax:** `setg r/m8`

Setting of the byte to 1 if signed greater (ZF=0 and SF=OF), else to 0.

**Operation:** `dst = (ZF = 0 and SF = OF) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setge – Setting of the byte to 1 if signed greater or equal

**Syntax:** `setge r/m8`

Setting of the byte to 1 if signed greater or equal (SF=OF), else to 0.

**Operation:** `dst = (SF = OF) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setl – Setting of the byte to 1 if signed less

**Syntax:** `setl r/m8`

Setting of the byte to 1 if signed less (SF≠OF), else to 0.

**Operation:** `dst = (SF != OF) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setle – Setting of the byte to 1 if signed less or equal

**Syntax:** `setle r/m8`

Setting of the byte to 1 if signed less or equal (ZF=1 or SF≠OF), else to 0.

**Operation:** `dst = (ZF = 1 or SF != OF) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setnc – Setting of the byte to 1 if no carry

**Syntax:** `setnc r/m8`

Setting of the byte to 1 if no carry, unsigned above or equal (CF=0), else to 0.

**Operation:** `dst = (CF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setno – Setting of the byte to 1 if no overflow

**Syntax:** `setno r/m8`

Setting of the byte to 1 if no overflow (OF=0), else to 0.

**Operation:** `dst = (OF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setnp – Setting of the byte to 1 if parity odd

**Syntax:** `setnp r/m8`

Setting of the byte to 1 if parity odd (PF=0), else to 0.

**Operation:** `dst = (PF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setns – Setting of the byte to 1 if not negative

**Syntax:** `setns r/m8`

Setting of the byte to 1 if not negative (SF=0), else to 0.

**Operation:** `dst = (SF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setnz – Setting of the byte to 1 if not equal

**Syntax:** `setnz r/m8`

Setting of the byte to 1 if not equal, result not zero (ZF=0), else to 0.

**Operation:** `dst = (ZF = 0) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## seto – Setting of the byte to 1 if overflow

**Syntax:** `seto r/m8`

Setting of the byte to 1 if overflow (OF=1), else to 0.

**Operation:** `dst = (OF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setp – Setting of the byte to 1 if parity even

**Syntax:** `setp r/m8`

Setting of the byte to 1 if parity even (PF=1), else to 0.

**Operation:** `dst = (PF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## sets – Setting of the byte to 1 if negative

**Syntax:** `sets r/m8`

Setting of the byte to 1 if negative (SF=1), else to 0.

**Operation:** `dst = (SF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## setz – Setting of the byte to 1 if equal

**Syntax:** `setz r/m8`

Setting of the byte to 1 if equal, result zero (ZF=1), else to 0.

**Operation:** `dst = (ZF = 1) ? 1 : 0`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## sfence – Barrier for stores

**Syntax:** `sfence`

**Operation:** `all earlier stores are done before later stores`

*Group: Barriers and others. Short description from the instruction reference; there is no longer explanation for it yet.*

## sgdt – Store of the global descriptor table register

**Syntax:** `sgdt m`

**Operation:** `[m] = GDTR`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## shl – Shift left (times 2 per place), filled with 0

**Syntax:** `shl r/m8, imm8` &nbsp; `shl r/m32, imm8` &nbsp; `shl r/m16, imm8` &nbsp; `shl r/m8, 1` &nbsp; `shl r/m32, 1` &nbsp; `shl r/m16, 1` &nbsp; `shl r/m8, cl` &nbsp; `shl r/m32, cl` &nbsp; …

**Operation:** `dst = dst << count (count masked to 5 / 6 bits); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## shld – Shift left, filled from a second register

**Syntax:** `shld r/m32, r32, imm8` &nbsp; `shld r/m16, r16, imm8` &nbsp; `shld r/m32, r32, cl` &nbsp; `shld r/m16, r16, cl` &nbsp; `shld r/m64, r64, imm8` &nbsp; `shld r/m64, r64, cl`

**Operation:** `dst = (dst << count) OR (src >> (width - count))`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## shr – Shift right unsigned, filled with 0

**Syntax:** `shr r/m8, imm8` &nbsp; `shr r/m32, imm8` &nbsp; `shr r/m16, imm8` &nbsp; `shr r/m8, 1` &nbsp; `shr r/m32, 1` &nbsp; `shr r/m16, 1` &nbsp; `shr r/m8, cl` &nbsp; `shr r/m32, cl` &nbsp; …

**Operation:** `dst = dst >> count (zeros come in); CF = last bit shifted out`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## shrd – Shift right, filled from a second register

**Syntax:** `shrd r/m32, r32, imm8` &nbsp; `shrd r/m16, r16, imm8` &nbsp; `shrd r/m32, r32, cl` &nbsp; `shrd r/m16, r16, cl` &nbsp; `shrd r/m64, r64, imm8` &nbsp; `shrd r/m64, r64, cl`

**Operation:** `dst = (dst >> count) OR (src << (width - count))`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Shift and rotate. Short description from the instruction reference; there is no longer explanation for it yet.*

## shufpd – Shuffle of doubles from two registers as told

**Syntax:** `shufpd xmm, xmm/m128, imm8`

**Operation:** `dst = (dst[sel0], src[sel1]); sel = bits of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## shufps – Shuffle of singles from two registers as told

**Syntax:** `shufps xmm, xmm/m128, imm8`

**Operation:** `dst = (dst[sel0], dst[sel1], src[sel2], src[sel3]); sel = bit pairs of imm8`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## sidt – Store of the interrupt descriptor table register

**Syntax:** `sidt m`

**Operation:** `[m] = IDTR`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sldt – Store of the local descriptor table register

**Syntax:** `sldt r32/m16` &nbsp; `sldt r16` &nbsp; `sldt r64`

**Operation:** `dst = LDTR`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## smsw – Store of the machine status word

**Syntax:** `smsw m`

**Operation:** `dst = CR0 bits 0 to 15`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrtpd – Square root of 2 doubles

**Syntax:** `sqrtpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = sqrt(src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrtps – Square root of 4 singles

**Syntax:** `sqrtps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = sqrt(src[i])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrtsd – Square root of one double

**Syntax:** `sqrtsd xmm, xmm/m64`

**Operation:** `dst[0] = sqrt(src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## sqrtss – Square root of one single

**Syntax:** `sqrtss xmm, xmm/m32`

**Operation:** `dst[0] = sqrt(src[0]); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## stac – Setting of the AC flag (access protection)

**Syntax:** `stac`

**Operation:** `EFLAGS.AC = 1`

**Flags:** AC

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## stc – Setting of the carry flag

**Syntax:** `stc`

**Operation:** `CF = 1`

**Flags:** CF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## std – Setting of the direction flag

**Syntax:** `std`

Setting of the direction flag (string instructions count down).

**Operation:** `DF = 1`

**Flags:** DF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## sti – Enabling of interrupts (IF=1)

**Syntax:** `sti`

**Operation:** `IF = 1 (effective after the next instruction)`

**Flags:** IF

*Group: Flags. Short description from the instruction reference; there is no longer explanation for it yet.*

## stmxcsr – Store of the SSE control and status register

**Syntax:** `stmxcsr m`

**Operation:** `[m32] = MXCSR`

*Group: SSE and MMX data movement. Short description from the instruction reference; there is no longer explanation for it yet.*

## stosb – Store of al/ax/eax/rax to [rdi], rdi advances

**Syntax:** `stosb`

**Operation:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## stosd – Store of al/ax/eax/rax to [rdi], rdi advances

**Syntax:** `stosd`

**Operation:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## stosq – Store of al/ax/eax/rax to [rdi], rdi advances

**Syntax:** `stosq`

**Operation:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## stosw – Store of al/ax/eax/rax to [rdi], rdi advances

**Syntax:** `stosw`

**Operation:** `[rdi] = acc; rdi = rdi +/- size (acc is al, ax, eax or rax)`

*Group: Strings. Short description from the instruction reference; there is no longer explanation for it yet.*

## str – Store of the task register

**Syntax:** `str r32/m16` &nbsp; `str r16` &nbsp; `str r64`

**Operation:** `dst = task register`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## sub – Subtraction of the source from the destination

**Syntax:** `sub r/m8, r8` &nbsp; `sub r/m32, r32` &nbsp; `sub r/m16, r16` &nbsp; `sub r8, r/m8` &nbsp; `sub r32, r/m32` &nbsp; `sub r16, r/m16` &nbsp; `sub al, imm8` &nbsp; `sub eax, imm32` &nbsp; …

**Operation:** `dst = dst - src`

**Flags:** OF SF ZF AF CF PF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## subpd – Subtraction of 2 doubles

**Syntax:** `subpd xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] - src[i] (double)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## subps – Subtraction of 4 singles

**Syntax:** `subps xmm, xmm/m128`

**Operation:** `for every element: dst[i] = dst[i] - src[i] (single)`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## subsd – Subtraction of one double

**Syntax:** `subsd xmm, xmm/m64`

**Operation:** `dst[0] = dst[0] - src[0] (double); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## subss – Subtraction of one single

**Syntax:** `subss xmm, xmm/m32`

**Operation:** `dst[0] = dst[0] - src[0] (single); the other elements stay`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## swapgs – Swap of the gs base with the kernel value

**Syntax:** `swapgs`

**Operation:** `swap(gs base, kernel gs base) (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## syscall – Call of the operating system (64 bit, fast)

**Syntax:** `syscall`

**Operation:** `rcx = rip of the next instruction; r11 = flags; rip = LSTAR; flags = flags & ~SFMASK; ring 0`

**Flags:** RF

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## sysenter – Call of the operating system (32 bit, fast)

**Syntax:** `sysenter`

**Operation:** `enter ring 0 at the address in IA32_SYSENTER_EIP`

**Flags:** IF VM

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## sysexit – Return from a system call (32 bit, fast)

**Syntax:** `sysexit`

**Operation:** `back to ring 3: rip = rdx, rsp = rcx`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## sysretd – Return from a system call (fast)

**Syntax:** `sysretd`

**Operation:** `rip = rcx; flags = r11; back to ring 3`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## sysretq – Return from a system call (fast)

**Syntax:** `sysretq`

**Operation:** `rip = rcx; flags = r11; back to ring 3`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## test – Bitwise test (AND), only the flags change

**Syntax:** `test r/m8, r8` &nbsp; `test r/m32, r32` &nbsp; `test r/m16, r16` &nbsp; `test al, imm8` &nbsp; `test eax, imm32` &nbsp; `test ax, imm16` &nbsp; `test r/m8, imm8` &nbsp; `test r/m32, imm32` &nbsp; …

**Operation:** `flags = dst & src (the result is thrown away); CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## tzcnt – Count of the trailing zero bits

**Syntax:** `tzcnt r32, r/m32` &nbsp; `tzcnt r64, r/m64`

**Operation:** `dst = number of trailing 0 bits of src (width if src = 0)`

**Flags:** ZF CF

*Group: Arithmetic. Short description from the instruction reference; there is no longer explanation for it yet.*

## ucomisd – Like comisd, no exception for quiet NaN

**Syntax:** `ucomisd xmm, xmm/m64`

**Operation:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## ucomiss – Like comiss, no exception for quiet NaN

**Syntax:** `ucomiss xmm, xmm/m32`

**Operation:** `ZF PF CF = compare(dst, src): greater 0 0 0, less 0 0 1, equal 1 0 0, unordered 1 1 1; OF SF AF = 0`

**Flags:** OF SF ZF AF CF PF

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## ud2 – Deliberately invalid instruction

**Syntax:** `ud2`

Deliberately invalid instruction (raises an exception).

**Operation:** `raises #UD (invalid instruction)`

*Group: Jumps, calls and interrupts. Short description from the instruction reference; there is no longer explanation for it yet.*

## unpckhpd – Interleave of the high doubles of two registers

**Syntax:** `unpckhpd xmm, xmm/m128`

**Operation:** `dst = (dst[1], src[1])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## unpckhps – Interleave of the high singles of two registers

**Syntax:** `unpckhps xmm, xmm/m128`

**Operation:** `dst = (dst[2], src[2], dst[3], src[3])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## unpcklpd – Interleave of the low doubles of two registers

**Syntax:** `unpcklpd xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## unpcklps – Interleave of the low singles of two registers

**Syntax:** `unpcklps xmm, xmm/m128`

**Operation:** `dst = (dst[0], src[0], dst[1], src[1])`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## verr – Check of a segment for readability

**Syntax:** `verr r/m16`

**Operation:** `ZF = 1 if the segment src can be read`

**Flags:** ZF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## verw – Check of a segment for writability

**Syntax:** `verw r/m16`

**Operation:** `ZF = 1 if the segment src can be written`

**Flags:** ZF

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wbinvd – Write-back and invalidation of the caches

**Syntax:** `wbinvd`

Write-back and invalidation of the caches (privileged).

**Operation:** `write back and empty the caches (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wrfsbase – Write of the base address of fs/gs

**Syntax:** `wrfsbase r32` &nbsp; `wrfsbase r64`

**Operation:** `base address of fs = src`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wrgsbase – Write of the base address of fs/gs

**Syntax:** `wrgsbase r32` &nbsp; `wrgsbase r64`

**Operation:** `base address of gs = src`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## wrmsr – Write of a model-specific register (privileged)

**Syntax:** `wrmsr`

**Operation:** `model-specific register number ecx = edx:eax (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xadd – Exchange and add (atomic with lock)

**Syntax:** `xadd r/m8, r8` &nbsp; `xadd r/m32, r32` &nbsp; `xadd r/m16, r16` &nbsp; `xadd r/m64, r64`

**Operation:** `tmp = dst + src; src = dst; dst = tmp`

**Flags:** OF SF ZF AF CF PF

*Group: Compare and exchange. Short description from the instruction reference; there is no longer explanation for it yet.*

## xchg – Exchange of the two operands (with memory: atomic)

**Syntax:** `xchg r/m8, r8` &nbsp; `xchg r/m32, r32` &nbsp; `xchg r/m16, r16` &nbsp; `xchg r32, eax` &nbsp; `xchg r16, ax` &nbsp; `xchg r/m64, r64` &nbsp; `xchg r64, rax`

**Operation:** `tmp = dst; dst = src; src = tmp`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## xgetbv – Read of an extended control register (XCR)

**Syntax:** `xgetbv`

**Operation:** `edx:eax = extended control register number ecx`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xlatb – Load of al from the table at [rbx + al]

**Syntax:** `xlatb`

**Operation:** `al = [rbx + zext(al)]`

*Group: Data transfer. Short description from the instruction reference; there is no longer explanation for it yet.*

## xor – Bitwise exclusive OR (xor eax, eax sets to 0)

**Syntax:** `xor r/m8, r8` &nbsp; `xor r/m32, r32` &nbsp; `xor r/m16, r16` &nbsp; `xor r8, r/m8` &nbsp; `xor r32, r/m32` &nbsp; `xor r16, r/m16` &nbsp; `xor al, imm8` &nbsp; `xor eax, imm32` &nbsp; …

**Operation:** `dst = dst ^ src; CF = OF = 0`

**Flags:** OF SF ZF CF PF &nbsp; undefined: AF

*Group: Logic and bits. Short description from the instruction reference; there is no longer explanation for it yet.*

## xorpd – Bitwise exclusive OR (xorps x, x clears)

**Syntax:** `xorpd xmm, xmm/m128`

**Operation:** `dst = dst ^ src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## xorps – Bitwise exclusive OR (xorps x, x clears)

**Syntax:** `xorps xmm, xmm/m128`

**Operation:** `dst = dst ^ src`

*Group: SSE floating point. Short description from the instruction reference; there is no longer explanation for it yet.*

## xrstor – Restoring of the extended processor state

**Syntax:** `xrstor m`

**Operation:** `the state components selected by edx:eax = [m]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xrstor64 – Restoring of the extended processor state

**Syntax:** `xrstor64 m`

**Operation:** `the state components selected by edx:eax = [m]`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsave – Saving of the extended processor state

**Syntax:** `xsave m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsave64 – Saving of the extended processor state

**Syntax:** `xsave64 m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsavec – Saving of the extended processor state

**Syntax:** `xsavec m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsavec64 – Saving of the extended processor state

**Syntax:** `xsavec64 m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsaveopt – Saving of the extended processor state

**Syntax:** `xsaveopt m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsaveopt64 – Saving of the extended processor state

**Syntax:** `xsaveopt64 m`

Saving of the extended processor state (SSE, AVX ...).

**Operation:** `[m] = the state components selected by edx:eax`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*

## xsetbv – Write of an extended control register (XCR)

**Syntax:** `xsetbv`

**Operation:** `extended control register number ecx = edx:eax (privileged)`

*Group: System and privileged. Short description from the instruction reference; there is no longer explanation for it yet.*
