; Raspberry Pi Pico (RP2040, Cortex-M0+): "Hello, world!" about once a second through UART0, in the RAM.
;
; UART0 sends on GPIO 0 (pin 1 of the board). The Raspberry Pi Debug Probe has a serial port of its own (its
; connector "U"): its RX at GPIO 0, its TX at GPIO 1 (pin 2), GND at GND (pin 3). Press F9: the debugger loads the
; program over the probe (SWD), and the tab Serial next to the output window connects to the COM port of the probe
; and shows the text (115200 baud, 8N1).
;
; The steps are those of examples\pico2\hello_uart_ram.asm, with the addresses of the RP2040:
;   1. the 12 MHz crystal (XOSC 0x40024000) on and clk_ref from it (CLOCKS 0x40008000: CLK_REF_CTRL 0x30, SRC 2,
;      CLK_REF_SELECTED 0x38); clk_sys follows clk_ref, so it runs at 12 MHz then (after a reset it runs from the
;      ring oscillator, whose frequency is not exact enough for a baud rate)
;   2. clk_peri on (CLK_PERI_CTRL 0x48, bit 11 ENABLE), from clk_sys: it clocks the UARTs
;   3. IO_BANK0, PADS_BANK0 and UART0 out of reset (RESETS 0x4000c000: bits 5, 8, 22); GPIO 0: function UART
;      (IO_BANK0 0x40014000, GPIO0_CTRL 0x04 = 2); the RP2040 has no pad isolation
;   4. UART0 (0x40034000, an Arm PL011): 12,000,000 / (16 * 115200) = 6.51: IBRD 6, FBRD 33; 8 bits, FIFO on;
;      UART and sender on
;   5. each byte when the send FIFO has room (UARTFR bit 5 TXFF is 0)
; The Cortex-M0+ knows Thumb-1 only: the constants of more than 8 bits come from the words behind the code
; (ldr r0, lit_...), tst takes a register.
.target pico
.arch thumb
.imagebase 0x20000000

XOSC_CTRL           equ 0x00
XOSC_STATUS         equ 0x04
XOSC_STARTUP        equ 0x0c
CLK_REF_CTRL        equ 0x30
CLK_REF_SELECTED    equ 0x38
CLK_PERI_CTRL       equ 0x48
RESET_DONE          equ 0x08
GPIO0_CTRL          equ 0x04
FUNCSEL_UART        equ 2
UARTDR              equ 0x00
UARTFR              equ 0x18
UARTFR_TXFF         equ 1 << 5
UARTIBRD            equ 0x24
UARTFBRD            equ 0x28
UARTLCR_H           equ 0x2c
LCR_8BIT_FIFO       equ (3 << 5) | (1 << 4)
UARTCR              equ 0x30

_start:
    ldr  r0, lit_sram_end
    mov  sp, r0

    ; 1. the crystal, clk_ref from it
    ldr  r1, lit_xosc
    ldr  r0, lit_xosc_range
    str  r0, [r1, #XOSC_CTRL]           ; the frequency range first
    ldr  r0, lit_xosc_startup
    str  r0, [r1, #XOSC_STARTUP]
    ldr  r0, lit_xosc_enable
    str  r0, [r1, #XOSC_CTRL]           ; then on
xosc_wait:
    ldr  r0, [r1, #XOSC_STATUS]
    cmp  r0, #0
    bge  xosc_wait                      ; bit 31 STABLE
    ldr  r1, lit_clocks
    movs r0, #2                         ; SRC 2: XOSC
    str  r0, [r1, #CLK_REF_CTRL]
ref_wait:
    ldr  r0, [r1, #CLK_REF_SELECTED]
    cmp  r0, #1 << 2
    bne  ref_wait

    ; 2. clk_peri
    ldr  r0, lit_peri_enable
    str  r0, [r1, #CLK_PERI_CTRL]

    ; 3. out of reset, GPIO 0 to UART0
    ldr  r1, lit_resets_clr
    ldr  r0, lit_reset_bits
    str  r0, [r1]
    ldr  r1, lit_resets
reset_wait:
    ldr  r2, [r1, #RESET_DONE]
    ands r2, r0
    cmp  r2, r0
    bne  reset_wait
    ldr  r1, lit_io_bank0
    movs r0, #FUNCSEL_UART
    str  r0, [r1, #GPIO0_CTRL]

    ; 4. UART0: 115200 baud, 8N1
    ldr  r4, lit_uart0
    movs r0, #6
    str  r0, [r4, #UARTIBRD]
    movs r0, #33
    str  r0, [r4, #UARTFBRD]
    movs r0, #LCR_8BIT_FIFO
    str  r0, [r4, #UARTLCR_H]           ; takes the baud rate too
    ldr  r0, lit_cr_uart_tx
    str  r0, [r4, #UARTCR]
    movs r3, #UARTFR_TXFF

again:
    adr  r5, message
next_byte:
    ldrb r0, [r5]
    cmp  r0, #0
    beq  sent
fifo_full:
    ldr  r1, [r4, #UARTFR]
    tst  r1, r3
    bne  fifo_full
    str  r0, [r4, #UARTDR]
    adds r5, r5, #1
    b    next_byte
sent:
    ldr  r2, lit_delay
delay:
    subs r2, r2, #1
    bne  delay
    b    again

    align 4
lit_sram_end:      dd 0x20042000
lit_xosc:          dd 0x40024000
lit_xosc_range:    dd 0xaa0                ; 1 .. 15 MHz
lit_xosc_startup:  dd 282                  ; 282 * 256 cycles: about 6 ms
lit_xosc_enable:   dd (0xfab << 12) | 0xaa0
lit_clocks:        dd 0x40008000
lit_peri_enable:   dd 1 << 11              ; ENABLE, AUXSRC 0: clk_sys
lit_resets:        dd 0x4000c000
lit_resets_clr:    dd 0x4000c000 + 0x3000  ; +0x3000: clears bits
lit_reset_bits:    dd (1 << 5) | (1 << 8) | (1 << 22)   ; IO_BANK0, PADS_BANK0, UART0
lit_io_bank0:      dd 0x40014000
lit_uart0:         dd 0x40034000
lit_cr_uart_tx:    dd (1 << 0) | (1 << 8)  ; UARTEN, TXE
lit_delay:         dd 3000000              ; about a second at 12 MHz
message:
    db   'Hello, world!', 13, 10, 0
