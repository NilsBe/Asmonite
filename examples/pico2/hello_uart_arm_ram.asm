; Raspberry Pi Pico 2 (RP2350, Arm core Cortex-M33): "Hello, world!" about once a second through UART0, in the RAM.
;
; The same program as hello_uart_ram.asm, for the Arm cores of the RP2350 (the chip must run its Arm cores: start
; blink_arm_flash.asm once first if it runs its RISC-V cores). UART0 sends on GPIO 0 (pin 1 of the board): the
; Raspberry Pi Debug Probe has a serial port of its own (its connector "U"): its RX at GPIO 0, its TX at GPIO 1
; (pin 2), GND at GND (pin 3). Press F9: the tab Serial next to the output window connects to the COM port of the
; probe and shows the text (115200 baud, 8N1).
;
; The steps and the registers are those of hello_uart_ram.asm: the crystal on and clk_ref, clk_sys and clk_peri
; from it (12 MHz), IO_BANK0, PADS_BANK0 and UART0 out of reset, GPIO 0 to UART0, 115200 baud (IBRD 6, FBRD 33),
; then each byte when the send FIFO has room. The constants of 32 bits come from the literals at the end (lit_...),
; the offsets of the registers fit into the instructions.
.target pico2
.arch thumb
.imagebase 0x20000000

ALIAS_CLR           equ 0x3000
XOSC_CTRL           equ 0x00
XOSC_STATUS         equ 0x04
XOSC_STARTUP        equ 0x0c
XOSC_RANGE_1_15MHZ  equ 0xaa0
XOSC_STARTUP_DELAY  equ 282
CLK_REF_CTRL        equ 0x30
CLK_REF_SELECTED    equ 0x38
CLK_PERI_CTRL       equ 0x48
CLK_PERI_ENABLE     equ 1 << 11
RESET_DONE          equ 0x08
GPIO0_CTRL          equ 0x04
FUNCSEL_UART        equ 2
PAD_GPIO0           equ 0x04
PAD_ISO             equ 1 << 8
UARTDR              equ 0x00
UARTFR              equ 0x18
UARTFR_TXFF         equ 1 << 5
UARTIBRD            equ 0x24
UARTFBRD            equ 0x28
UARTLCR_H           equ 0x2c
LCR_8BIT_FIFO       equ (3 << 5) | (1 << 4)
UARTCR              equ 0x30
CR_UART_TX          equ (1 << 0) | (1 << 8)

_start:
    ldr  r0, lit_sram_end
    mov  sp, r0

    ; 1. the crystal, clk_ref from it
    ldr  r1, lit_xosc
    movw r0, #XOSC_RANGE_1_15MHZ
    str  r0, [r1, #XOSC_CTRL]           ; the frequency range first
    movw r0, #XOSC_STARTUP_DELAY
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
    movw r0, #CLK_PERI_ENABLE
    str  r0, [r1, #CLK_PERI_CTRL]

    ; 3. out of reset, GPIO 0 to UART0
    ldr  r1, lit_resets_clr
    ldr  r0, lit_reset_bits
    str  r0, [r1]
    ldr  r1, lit_resets
reset_wait:
    ldr  r2, [r1, #RESET_DONE]
    and  r2, r2, r0
    cmp  r2, r0
    bne  reset_wait
    ldr  r1, lit_pads_clr
    movw r0, #PAD_ISO
    str  r0, [r1, #PAD_GPIO0]
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
    movw r0, #CR_UART_TX
    str  r0, [r4, #UARTCR]

again:
    adr  r5, message
next_byte:
    ldrb r0, [r5]
    cmp  r0, #0
    beq  sent
fifo_full:
    ldr  r1, [r4, #UARTFR]
    tst  r1, #UARTFR_TXFF
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
lit_sram_end:    dd 0x20082000
lit_xosc:        dd 0x40048000
lit_xosc_enable: dd (0xfab << 12) | 0xaa0
lit_clocks:      dd 0x40010000
lit_resets:      dd 0x40020000
lit_resets_clr:  dd 0x40020000 + ALIAS_CLR
lit_reset_bits:  dd (1 << 6) | (1 << 9) | (1 << 26)   ; IO_BANK0, PADS_BANK0, UART0
lit_pads_clr:    dd 0x40038000 + ALIAS_CLR
lit_io_bank0:    dd 0x40028000
lit_uart0:       dd 0x40070000
lit_delay:       dd 3000000             ; about a second at 12 MHz
message:
    db   'Hello, world!', 13, 10, 0
