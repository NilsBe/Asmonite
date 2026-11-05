; ESP32-C3 (LuatOS ESP32C3-CORE): the LEDs at GPIO 12 and GPIO 13 blink in turn, and each change is
; written as a line to the USB serial port of the board. The same program as blink_ram.asm, for the flash:
; the boot ROM of the chip loads it from the flash into the RAM at 0x40380000 and starts it, without a
; debugger. So it switches the watchdogs off itself first: the boot ROM leaves the RTC watchdog and the
; super watchdog on, and they would reset the chip after a few seconds.
;
; F9 or F7 in Asmonite (.target esp32c3 flash) writes it as a flash image (the format of the boot ROM: a header
; with the magic 0xE9, DIO mode, 4 MB; one segment for 0x40380000; a checksum) to the flash at 0x0, over the
; serial port of the boot ROM (the USB serial port of the board: no terminal may have it open). Then the chip
; starts, the boot ROM loads the program and the debugger stops at _start. This replaces the firmware that
; was in the flash (on this board LuatOS: it can be downloaded again from luatos.com).
;
; The registers: see blink_ram.asm; the watchdogs: ESP32-C3 Technical Reference Manual, chapters "Timer
; Group" and "Watchdog Timers", and esptool/targets/esp32c3.py (RTC_CNTL_WDTCONFIG0_REG, the write key
; 0x50D83AA1, RTC_CNTL_SWD_CONF_REG, the key 0x8F1D312A).
.target esp32c3 flash
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
WDT_KEY              equ 0x50d83aa1       ; the write key of the watchdogs of the timer groups and the RTC
TIMG0_WDT            equ 0x6001f000       ; timer group 0: +0x48 config, +0x64 write protection
TIMG1_WDT            equ 0x60020000       ; timer group 1: the same
RTC_CNTL             equ 0x60008000       ; +0x90 RTC watchdog config, +0xa8 its write protection,
                                          ; +0xac super watchdog config, +0xb0 its write protection
SWD_KEY              equ 0x8f1d312a
SWD_AUTO_FEED        equ 0x80000000       ; the super watchdog feeds itself

_start:
    ; the watchdogs off: unlock, config 0 (each of the three); the super watchdog feeds itself
    li   t2, WDT_KEY
    li   t0, TIMG0_WDT
    sw   t2, 0x64(t0)
    sw   zero, 0x48(t0)
    li   t0, TIMG1_WDT
    sw   t2, 0x64(t0)
    sw   zero, 0x48(t0)
    li   t0, RTC_CNTL
    sw   t2, 0xa8(t0)
    sw   zero, 0x90(t0)
    li   t2, SWD_KEY
    sw   t2, 0xb0(t0)
    li   t2, SWD_AUTO_FEED
    sw   t2, 0xac(t0)

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
