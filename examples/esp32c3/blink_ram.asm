; ESP32-C3 (LuatOS ESP32C3-CORE): the LEDs at GPIO 12 and GPIO 13 blink in turn, and each change is
; written as a line to the USB serial port of the board (COM8 here: the "USB Serial Device" of the board).
;
; This program runs in the RAM of the chip, loaded by the debugger over the USB JTAG of the chip:
;   1. plug in the board (Debug > Debug targets: ESP32-C3)
;   2. press F9 (Run) or F7 (Step into): the chip is reset and halted before its firmware starts,
;      the program is loaded to 0x40380000 and stops at _start
;   3. the tab Serial next to the output window connects to that port by itself and shows the lines (or a
;      terminal program on COM8; the speed does not matter on this port)
; Nothing is written to the flash: after RESET the firmware of the board runs again.
;
; The registers (ESP-IDF, components/soc/esp32c3/register/soc: reg_base.h, gpio_reg.h, io_mux_reg.h,
; usb_serial_jtag_reg.h; ESP32-C3 Technical Reference Manual, chapters "IO MUX and GPIO Matrix" and
; "USB Serial/JTAG Controller"):
;   - IO_MUX_GPIOn: MCU_SEL (bits 14..12) = 1 selects the function GPIO of the pad. GPIO 12 and 13 are
;     SPIHD and SPIWP of the flash by default; the board runs the flash in DIO mode, so they are free.
;   - GPIO_FUNCn_OUT_SEL_CFG: 0x80 (SIG_GPIO_OUT_IDX) puts the bit of GPIO_OUT on the pad.
;   - GPIO_ENABLE_W1TS, GPIO_OUT_W1TS, GPIO_OUT_W1TC: output on, a bit to 1, a bit to 0.
;   - USB_SERIAL_JTAG_EP1: a byte into the send FIFO of the serial port; EP1_CONF bit 0 WR_DONE sends
;     what is in the FIFO, bit 1 SERIAL_IN_EP_DATA_FREE says that the FIFO takes data.
.target esp32c3
.arch riscv32
.imagebase 0x40380000

GPIO_BASE            equ 0x60004000
GPIO_OUT_W1TS        equ 0x08
GPIO_OUT_W1TC        equ 0x0c
GPIO_ENABLE_W1TS     equ 0x24
GPIO_FUNC12_OUT_SEL  equ 0x584
GPIO_FUNC13_OUT_SEL  equ 0x588
SIG_GPIO_OUT         equ 0x80
IO_MUX_BASE          equ 0x60009000
IO_MUX_GPIO12        equ 0x34
IO_MUX_GPIO13        equ 0x38
PAD_GPIO             equ 0x1800           ; MCU_SEL = 1 (GPIO, bits 14..12), FUN_DRV = 2 (bits 11..10)
LED12                equ 1 << 12
LED13                equ 1 << 13
USB_JTAG_BASE        equ 0x60043000
USB_EP1              equ 0x00
USB_EP1_CONF         equ 0x04
USB_WR_DONE          equ 1
USB_DATA_FREE        equ 2
USB_TRIES            equ 100000           ; tries before a line is dropped (the port is not open)
DELAY_COUNT          equ 4000000          ; about half a second at the clock after the reset

_start:
    ; the pads of GPIO 12 and 13: function GPIO
    li   t0, IO_MUX_BASE
    li   t1, PAD_GPIO
    sw   t1, IO_MUX_GPIO12(t0)
    sw   t1, IO_MUX_GPIO13(t0)

    ; their output signals: the bits of GPIO_OUT; then output on
    li   t0, GPIO_BASE
    li   t1, SIG_GPIO_OUT
    sw   t1, GPIO_FUNC12_OUT_SEL(t0)
    sw   t1, GPIO_FUNC13_OUT_SEL(t0)
    li   t1, LED12 | LED13
    sw   t1, GPIO_ENABLE_W1TS(t0)

blink_loop:
    li   t1, LED12
    sw   t1, GPIO_OUT_W1TS(t0)            ; LED 12 on
    li   t1, LED13
    sw   t1, GPIO_OUT_W1TC(t0)            ; LED 13 off
    la   a0, text_12
    call usb_print
    call pause

    li   t1, LED13
    sw   t1, GPIO_OUT_W1TS(t0)            ; LED 13 on
    li   t1, LED12
    sw   t1, GPIO_OUT_W1TC(t0)            ; LED 12 off
    la   a0, text_13
    call usb_print
    call pause
    j    blink_loop

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

; ---- wait a while; changes t3 -------------------------------------------------------------------------
pause:
    li   t3, DELAY_COUNT
pause_loop:
    addi t3, t3, -1
    bnez t3, pause_loop
    ret

text_12:
    db   'LED 12 on', 13, 10, 0
text_13:
    db   'LED 13 on', 13, 10, 0
