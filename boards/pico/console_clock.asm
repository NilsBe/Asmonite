; The clock of the core, for the consoles of the Pico and the Pico 2 (boards/pico/console.asm and
; boards/pico2/console.asm include it, each with its CLOCKS, PLL_SYS and CLK_SYS_DIV_SHIFT; not a program of its own).
; The console runs clk_sys at 48 MHz from PLL_USB after a reset. A program may change it (abelle/lib/pico/cpuclock.abel,
; lib/pico2/cpuclock.abel: cpu_clock PLL_SYS, 48 .. 133 MHz on the Pico, 48 .. 150 MHz on the Pico 2; cpu_clock_khz
; clk_ref, the crystal, through CLK_SYS_DIV, 1 .. 12000 kHz), and the console keeps the clock a program leaves (the
; user, 2026-11-24: a program that changes the clock means it to stay; setclock). Nothing of the console follows
; clk_sys: clk_peri (UART0) comes from PLL_USB itself (uart_init), the USB controller from clk_usb, TIMER (millis) from
; clk_ref through the tick of the watchdog; the library sets the reload of SysTick (wl_tick of a W, 10 ms) at each
; change.
; Only from PLL_USB or PLL_SYS (48 MHz and more) the console stays reachable: with clk_sys from clk_ref (the crystal,
; 12 MHz and less: cpu_clock_khz) Windows could not open the port anew (seen 2026-11-24 at 12, 6 MHz, 1 kHz: "The
; semaphore timeout period has expired"; a port that is open goes on), and below about 1 MHz TIMER loses its ticks.
; clock_back takes 48 MHz again then: clk_sys to clk_ref (SRC 0, glitchless; it is there already), its divider 1,
; AUXSRC 1 (PLL_USB; not glitchless: only while SRC is clk_ref), SRC 1, PLL_SYS powered down, on a W the reload of
; SysTick for 48 MHz.
; put_clock: the clock now for info, from the registers.

; after a program: from clk_ref (the crystal, 12 MHz and less) to 48 MHz from PLL_USB; PLL_USB and PLL_SYS stay
clock_back:
    ldr  r3, cb_clocks
    ldr  r0, [r3, #CLK_SYS_CTRL]
    lsrs r1, r0, #1
    bcs  cb_end                     ; from an aux source (PLL_USB, PLL_SYS): 48 MHz or more
    mrs  r2, primask
    cpsid i
cb_ref:
    ldr  r0, [r3, #CLK_SYS_SELECTED]
    cmp  r0, #1
    bne  cb_ref
    movs r0, #1
    lsls r0, r0, #CLK_SYS_DIV_SHIFT
    str  r0, [r3, #CLK_SYS_DIV]     ; divider 1: 12 MHz
    movs r0, #1 << 5
    str  r0, [r3, #CLK_SYS_CTRL]    ; AUXSRC 1: PLL_USB
    movs r0, #(1 << 5) | 1
    str  r0, [r3, #CLK_SYS_CTRL]    ; SRC 1
cb_aux:
    ldr  r0, [r3, #CLK_SYS_SELECTED]
    cmp  r0, #2
    bne  cb_aux
    ldr  r3, cb_pll_sys
    movs r0, #0x2d
    str  r0, [r3, #4]               ; PLL_SYS powered down (PWR as after its reset)
    ldr  r3, cb_syst
    ldr  r0, [r3]
    lsrs r0, r0, #1
    bcc  cb_on                      ; SysTick off (not a W)
    ldr  r0, cb_reload
    str  r0, [r3, #4]
    movs r0, #0
    str  r0, [r3, #8]
cb_on:
    msr  primask, r2
cb_end:
    bx   lr

; info: the clock of the core now, "48 MHz (PLL_USB from the crystal)", "133 MHz (PLL_SYS from the crystal)",
; "2400 kHz (the crystal)": clk_ref 12 MHz, PLL_USB 48 MHz or PLL_SYS 12 MHz * FBDIV / (POSTDIV1 * POSTDIV2), through
; CLK_SYS_DIV; in MHz when it is whole, else in kHz
put_clock:
    push {r4, r5, r6, lr}
    ldr  r3, cb_clocks
    ldr  r4, [r3, #CLK_SYS_CTRL]
    ldr  r5, [r3, #CLK_SYS_DIV]
    lsrs r5, r5, #CLK_SYS_DIV_SHIFT
    bne  pk_src
    movs r5, #1
pk_src:
    movs r6, #0                     ; 0 the crystal (clk_ref)
    ldr  r0, cb_12000
    lsrs r1, r4, #1
    bcc  pk_khz                     ; SRC 0
    lsrs r1, r4, #5
    movs r2, #7
    ands r1, r2                     ; AUXSRC
    movs r6, #1                     ; 1 PLL_USB
    ldr  r0, cb_48000
    cmp  r1, #1
    beq  pk_khz
    movs r6, #2                     ; 2 PLL_SYS
    ldr  r3, cb_pll_sys
    ldr  r1, [r3, #8]               ; FBDIV
    ldr  r0, cb_12000
    muls r0, r1
    ldr  r1, [r3, #0x0c]            ; PRIM: POSTDIV1 bits 18..16, POSTDIV2 bits 14..12
    lsrs r2, r1, #16
    movs r3, #7
    ands r2, r3
    lsrs r1, r1, #12
    ands r1, r3
    muls r1, r2
    bl   udiv32
pk_khz:
    mov  r1, r5
    bl   udiv32                     ; the kHz
    mov  r4, r0
    ldr  r1, cb_1000
    bl   udiv32
    cmp  r1, #0
    bne  pk_k
    bl   put_dec
    bl   print_inline
    db   ' MHz (', 0
    align 2
    b    pk_name
pk_k:
    mov  r0, r4
    bl   put_dec
    bl   print_inline
    db   ' kHz (', 0
    align 2
pk_name:
    cmp  r6, #1
    beq  pk_usb
    bhi  pk_sys
    bl   print_inline
    db   'the crystal)', 0
    align 2
    pop  {r4, r5, r6, pc}
pk_usb:
    bl   print_inline
    db   'PLL_USB from the crystal)', 0
    align 2
    pop  {r4, r5, r6, pc}
pk_sys:
    bl   print_inline
    db   'PLL_SYS from the crystal)', 0
    align 2
    pop  {r4, r5, r6, pc}

    align 4
cb_clocks:      dd CLOCKS
cb_pll_sys:     dd PLL_SYS          ; +4 PWR, +8 FBDIV, +0xc PRIM
cb_syst:        dd 0xe000e010       ; SysTick: +0 CSR (bit 0 on), +4 RVR, +8 CVR
cb_reload:      dd 480000 - 1       ; 10 ms at 48 MHz
cb_12000:       dd 12000
cb_48000:       dd 48000
cb_1000:        dd 1000
