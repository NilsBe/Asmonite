; Raspberry Pi Pico 2 (RP2350, RISC-V core Hazard3): "Hello, world!" about once a second through UART0.
;
; UART0 sends on GPIO 0 (pin 1 of the board). The Raspberry Pi Debug Probe has a serial port of its own (its
; connector "U"): its RX at GPIO 0, its TX at GPIO 1 (pin 2), GND at GND (pin 3). Then the text shows on the COM
; port of the probe, 115200 baud, 8N1:
;   1. the Pico 2 at the debug probe (SWD, connector "D") and the UART cable as above
;   2. press F9: the debugger loads the program into the RAM and runs it; the tab Serial next to the output
;      window connects to the COM port of the probe and shows the text
; The debugger and the serial port are two parts of the same probe: they do not get in each other's way.
;
; The steps of the program:
;   1. the 12 MHz crystal (XOSC) on and clk_ref from it: after a reset clk_ref, clk_sys and clk_peri run from the
;      ring oscillator, whose frequency is not exact enough for a baud rate (as in 21_clock.asm of the ARM
;      tutorial); clk_sys follows clk_ref, so all of them run at 12 MHz then
;   2. clk_peri on (it clocks the UARTs; off after a reset), from clk_sys
;   3. IO_BANK0, PADS_BANK0 and UART0 out of reset; GPIO 0: function UART (2), its pad without isolation
;   4. UART0: the baud rate 12,000,000 / (16 * 115200) = 6.51: IBRD 6, FBRD 0.51 * 64 = 33; 8 bits, FIFO on;
;      UART and sender on
;   5. each byte when the send FIFO has room (UARTFR bit 5 TXFF is 0)
;
; The registers (RP2350 datasheet, chapters "Clocks", "Crystal Oscillator", "Resets", "GPIO", "UART"; the UART is
; an Arm PrimeCell PL011): XOSC 0x40048000, CLOCKS 0x40010000 (CLK_REF_CTRL 0x30, CLK_REF_SELECTED 0x38,
; CLK_PERI_CTRL 0x48: bit 11 ENABLE), RESETS 0x40020000 (bit 6 IO_BANK0, 9 PADS_BANK0, 26 UART0), IO_BANK0
; 0x40028000 (GPIO0_CTRL 0x04), PADS_BANK0 0x40038000 (GPIO0 0x04), UART0 0x40070000 (UARTDR 0x00, UARTFR 0x18,
; UARTIBRD 0x24, UARTFBRD 0x28, UARTLCR_H 0x2c, UARTCR 0x30).
.target pico2
.arch riscv32
.imagebase 0x20000000

SRAM_END            equ 0x20082000
ALIAS_CLR           equ 0x3000            ; +0x3000 of a register address clears bits
XOSC_BASE           equ 0x40048000
XOSC_CTRL           equ 0x00
XOSC_STATUS         equ 0x04
XOSC_STARTUP        equ 0x0c
XOSC_RANGE_1_15MHZ  equ 0xaa0
XOSC_ENABLE_1_15MHZ equ (0xfab << 12) | 0xaa0
XOSC_STARTUP_DELAY  equ 282               ; 282 * 256 cycles: about 6 ms (as the Pico SDK)
CLOCKS_BASE         equ 0x40010000
CLK_REF_CTRL        equ 0x30
CLK_REF_SELECTED    equ 0x38
CLK_PERI_CTRL       equ 0x48
CLK_PERI_ENABLE     equ 1 << 11           ; AUXSRC 0: clk_sys
RESETS_BASE         equ 0x40020000
RESET_DONE          equ 0x08
RESET_BITS          equ (1 << 6) | (1 << 9) | (1 << 26)   ; IO_BANK0, PADS_BANK0, UART0
IO_BANK0_BASE       equ 0x40028000
GPIO0_CTRL          equ 0x04
FUNCSEL_UART        equ 2
PADS_BANK0_BASE     equ 0x40038000
PAD_GPIO0           equ 0x04
PAD_ISO             equ 1 << 8            ; pad isolation: on after a reset of the RP2350
UART0_BASE          equ 0x40070000
UARTDR              equ 0x00
UARTFR              equ 0x18
UARTFR_TXFF         equ 1 << 5
UARTIBRD            equ 0x24
UARTFBRD            equ 0x28
UARTLCR_H           equ 0x2c
LCR_8BIT_FIFO       equ (3 << 5) | (1 << 4)
UARTCR              equ 0x30
CR_UART_TX          equ (1 << 0) | (1 << 8)   ; UARTEN, TXE
DELAY_COUNT         equ 4000000           ; about a second at 12 MHz

_start:
    li   sp, SRAM_END

    ; 1. the crystal, clk_ref from it
    li   t0, XOSC_BASE
    li   t1, XOSC_RANGE_1_15MHZ
    sw   t1, XOSC_CTRL(t0)                ; the frequency range first
    li   t1, XOSC_STARTUP_DELAY
    sw   t1, XOSC_STARTUP(t0)
    li   t1, XOSC_ENABLE_1_15MHZ
    sw   t1, XOSC_CTRL(t0)                ; then on
xosc_wait:
    lw   t1, XOSC_STATUS(t0)
    bgez t1, xosc_wait                    ; bit 31 STABLE
    li   t0, CLOCKS_BASE
    li   t1, 2                            ; SRC 2: XOSC
    sw   t1, CLK_REF_CTRL(t0)
ref_wait:
    lw   t1, CLK_REF_SELECTED(t0)
    li   t2, 1 << 2
    bne  t1, t2, ref_wait

    ; 2. clk_peri
    li   t1, CLK_PERI_ENABLE
    sw   t1, CLK_PERI_CTRL(t0)

    ; 3. out of reset, GPIO 0 to UART0
    li   t0, RESETS_BASE + ALIAS_CLR
    li   t1, RESET_BITS
    sw   t1, 0(t0)
    li   t0, RESETS_BASE
reset_wait:
    lw   t2, RESET_DONE(t0)
    and  t2, t2, t1
    bne  t2, t1, reset_wait
    li   t0, PADS_BANK0_BASE + ALIAS_CLR + PAD_GPIO0
    li   t1, PAD_ISO
    sw   t1, 0(t0)
    li   t0, IO_BANK0_BASE + GPIO0_CTRL
    li   t1, FUNCSEL_UART
    sw   t1, 0(t0)

    ; 4. UART0: 115200 baud, 8N1
    li   t0, UART0_BASE
    li   t1, 6
    sw   t1, UARTIBRD(t0)
    li   t1, 33
    sw   t1, UARTFBRD(t0)
    li   t1, LCR_8BIT_FIFO
    sw   t1, UARTLCR_H(t0)                ; takes the baud rate too
    li   t1, CR_UART_TX
    sw   t1, UARTCR(t0)

again:
    la   a0, message
next_byte:
    lbu  a1, 0(a0)
    beqz a1, sent
fifo_full:
    lw   t1, UARTFR(t0)
    andi t1, t1, UARTFR_TXFF
    bnez t1, fifo_full
    sw   a1, UARTDR(t0)
    addi a0, a0, 1
    j    next_byte
sent:
    li   t2, DELAY_COUNT
delay:
    addi t2, t2, -1
    bnez t2, delay
    j    again

message:
    db   'Hello, world!', 13, 10, 0
