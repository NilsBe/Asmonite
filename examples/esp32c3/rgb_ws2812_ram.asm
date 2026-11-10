; ESP32-C3 boards with an RGB LED WS2812 at GPIO 8 (for example the boards with two USB-C ports and an
; RGB LED): the LED is red, green and blue in turn, and each change is written as a line to the USB
; serial port of the chip ("LED red", "LED green", "LED blue").
;
; This program runs in the RAM of the chip, loaded by the debugger over the USB JTAG of the chip:
;   1. plug in the board at the USB port of the chip (Debug > Debug targets: ESP32-C3)
;   2. press F9 (Run) or F7 (Step into): the chip is reset and halted before its firmware starts,
;      the program is loaded to 0x40380000 and stops at _start
;   3. the tab Serial next to the output window connects to the COM port of that USB port by itself and shows
;      the lines
; Nothing is written to the flash: after RESET the firmware of the board runs again.
;
; The WS2812 has no on and off: it takes 24 bits of colour on one wire (green, red, blue, 8 bits each,
; the highest bit first), and each bit is a pulse of 1.25 microseconds: high for about 0.4 microseconds
; for a 0, for about 0.8 microseconds for a 1, then low. After 24 bits the line stays low for more than
; 280 microseconds, and the LED shows the new colour.
; The pulses are timed with the cycle counter of the core (the CSRs 0x7E0..0x7E2 of the ESP32-C3:
; mpcer, mpcmr, mpccr), not with loops of instructions: a store to the GPIO takes about 5 cycles, and
; the counter does not care.
;
; The clock: after the reset the core runs from the crystal (40 MHz) divided by 2, that is 20 MHz. The
; program sets the divider to 1 (SYSTEM_SYSCLK_CONF, PRE_DIV_CNT = 0): 40 MHz, 25 ns for each cycle.
;
; The registers (ESP-IDF, components/soc/esp32c3/register/soc: reg_base.h, gpio_reg.h, io_mux_reg.h,
; system_reg.h, usb_serial_jtag_reg.h; ESP32-C3 Technical Reference Manual): see blink_ram.asm.
.target esp32c3
.arch riscv32
.imagebase 0x40380000

SYSTEM_SYSCLK_CONF   equ 0x600c0058
GPIO_BASE            equ 0x60004000
GPIO_OUT_W1TS        equ 0x08
GPIO_OUT_W1TC        equ 0x0c
GPIO_ENABLE_W1TS     equ 0x24
GPIO_FUNC8_OUT_SEL   equ 0x574
SIG_GPIO_OUT         equ 0x80
IO_MUX_BASE          equ 0x60009000
IO_MUX_GPIO8         equ 0x24
PAD_GPIO             equ 0x1800           ; MCU_SEL = 1 (GPIO, bits 14..12), FUN_DRV = 2 (bits 11..10)
LED_PIN              equ 1 << 8
USB_JTAG_BASE        equ 0x60043000
USB_EP1              equ 0x00
USB_EP1_CONF         equ 0x04
USB_WR_DONE          equ 1
USB_DATA_FREE        equ 2
USB_TRIES            equ 100000           ; tries before a line is dropped (the port is not open)
DELAY_COUNT          equ 5000000          ; half a second at 40 MHz (4 cycles for each round)

; the pulses in cycles of 25 ns; waiting for the counter adds up to about 6 cycles to each of them
T0_HIGH              equ 12               ; a 0: 0.30 .. 0.45 microseconds high
T1_HIGH              equ 28               ; a 1: 0.70 .. 0.85 microseconds high
T_BIT                equ 50               ; 1.25 microseconds for each bit
T_LATCH              equ 12000            ; 300 microseconds low: the LED takes the colour

_start:
    ; the clock of the core: the crystal without the divider, 40 MHz
    li   t0, SYSTEM_SYSCLK_CONF
    lw   t1, 0(t0)
    li   t2, -1024                        ; all bits but PRE_DIV_CNT (bits 9..0)
    and  t1, t1, t2
    sw   t1, 0(t0)

    ; the cycle counter: count the cycles (mpcer = 1), on (mpcmr = 1)
    li   t1, 1
    csrw 0x7e0, t1
    csrw 0x7e1, t1

    ; the pad of GPIO 8: function GPIO; its output signal: the bit of GPIO_OUT; low, then output on
    li   t0, IO_MUX_BASE
    li   t1, PAD_GPIO
    sw   t1, IO_MUX_GPIO8(t0)
    li   t0, GPIO_BASE
    li   t1, SIG_GPIO_OUT
    sw   t1, GPIO_FUNC8_OUT_SEL(t0)
    li   t1, LED_PIN
    sw   t1, GPIO_OUT_W1TC(t0)
    sw   t1, GPIO_ENABLE_W1TS(t0)

colour_loop:
    li   a0, 0x002000                     ; red: green 0x00, red 0x20, blue 0x00 (not too bright)
    call ws2812_send
    la   a0, text_red
    call usb_print
    call pause

    li   a0, 0x200000                     ; green
    call ws2812_send
    la   a0, text_green
    call usb_print
    call pause

    li   a0, 0x000020                     ; blue
    call ws2812_send
    la   a0, text_blue
    call usb_print
    call pause
    j    colour_loop

; ---- the colour in a0 (0x00GGRRBB) to the WS2812 at GPIO 8; changes a0, a1, t0, t1, t3 .. t6 ------
ws2812_send:
    li   t0, GPIO_BASE
    li   t1, LED_PIN
    slli a0, a0, 8                        ; bit 23 (the first one) to bit 31: the sign
    li   a1, 24
ws_bit:
    csrr t5, 0x7e2                        ; the start of the bit
    sw   t1, GPIO_OUT_W1TS(t0)            ; high
    li   t6, T0_HIGH
    bgez a0, ws_high                      ; bit 31 = 0: a short pulse
    li   t6, T1_HIGH
ws_high:
    add  t6, t5, t6
ws_wait_high:
    csrr t4, 0x7e2
    sub  t3, t4, t6
    bltz t3, ws_wait_high
    sw   t1, GPIO_OUT_W1TC(t0)            ; low
    addi t6, t5, T_BIT
ws_wait_low:
    csrr t4, 0x7e2
    sub  t3, t4, t6
    bltz t3, ws_wait_low
    slli a0, a0, 1                        ; the next bit
    addi a1, a1, -1
    bnez a1, ws_bit
    ; stay low: the LED takes the colour
    csrr t5, 0x7e2
    li   t6, T_LATCH
    add  t6, t5, t6
ws_wait_latch:
    csrr t4, 0x7e2
    sub  t3, t4, t6
    bltz t3, ws_wait_latch
    ret

; ---- the text at a0 (with 0 at its end) to the USB serial port; changes a0, t2, t3, t4 --------------
usb_print:
    li   t2, USB_JTAG_BASE
    li   t4, USB_TRIES
usb_wait:
    lw   t3, USB_EP1_CONF(t2)
    andi t3, t3, USB_DATA_FREE
    bnez t3, usb_char
    addi t4, t4, -1
    bnez t4, usb_wait
    ret                                   ; nobody reads the port: the line is dropped
usb_char:
    lbu  t3, 0(a0)
    beqz t3, usb_send
    sw   t3, USB_EP1(t2)                  ; one byte into the FIFO (64 bytes: a line fits)
    addi a0, a0, 1
    j    usb_char
usb_send:
    li   t3, USB_WR_DONE
    sw   t3, USB_EP1_CONF(t2)             ; send what is in the FIFO
    ret

; ---- wait half a second; changes t3 -------------------------------------------------------------------
pause:
    li   t3, DELAY_COUNT
pause_loop:
    addi t3, t3, -1
    bnez t3, pause_loop
    ret

text_red:
    db   'LED red', 13, 10, 0
text_green:
    db   'LED green', 13, 10, 0
text_blue:
    db   'LED blue', 13, 10, 0
