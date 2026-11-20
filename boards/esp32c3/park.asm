; The park program of the ESP32-C3: Erase Flash of the Board Manager writes it into the erased flash (at 0), so the
; board starts in a controlled way instead of restarting again and again ("invalid header: 0xffffffff"). It switches
; the watchdogs off (the boot ROM leaves the RTC watchdog and the super watchdog on after a start from the flash) and
; writes a line to the USB port of the chip every 3 seconds; when nobody reads, the line is dropped. The Board Manager
; and the tab Serial know the board by it ("erased by Asmonite"). Prepare Board puts the console in its place.
;
; The registers as in examples_internal\esp32c3\blink_flash.asm.
.target esp32c3 flash
.arch riscv32
.imagebase 0x40380000

USB_JTAG_BASE        equ 0x60043000       ; EP1 +0, EP1_CONF +4: bit 0 WR_DONE, bit 1 room in the FIFO
USB_TRIES            equ 100000           ; tries before a line is dropped (nobody reads)
PAUSE_COUNT          equ 24000000         ; about 3 s at the clock after the reset
WDT_KEY              equ 0x50d83aa1
TIMG0_WDT            equ 0x6001f000       ; +0x48 config, +0x64 write protection
TIMG1_WDT            equ 0x60020000
RTC_CNTL             equ 0x60008000       ; +0x90 RTC watchdog config, +0xa8 its write protection, +0xac super
                                          ; watchdog config, +0xb0 its write protection
SWD_KEY              equ 0x8f1d312a
SWD_AUTO_FEED        equ 0x80000000

_start:
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
park_loop:
    la   a0, message
    call usb_print
    li   t3, PAUSE_COUNT
pause_loop:
    addi t3, t3, -1
    bnez t3, pause_loop
    j    park_loop

; the text at a0 (with a 0 at its end) to the USB port, the FIFO to the host after each 64 bytes (its size) and at the
; end; changes a0, t2, t3, t4, t5
usb_print:
    li   t2, USB_JTAG_BASE
    li   t5, 64
usb_char:
    li   t4, USB_TRIES
usb_wait:
    lw   t3, 4(t2)
    andi t3, t3, 2
    bnez t3, usb_put
    addi t4, t4, -1
    bnez t4, usb_wait
    ret                                   ; nobody reads the port: the rest is dropped
usb_put:
    lbu  t3, 0(a0)
    beqz t3, usb_send
    sw   t3, 0(t2)
    addi a0, a0, 1
    addi t5, t5, -1
    bnez t5, usb_char
    li   t3, 1
    sw   t3, 4(t2)                        ; 64 bytes: the FIFO to the host
    li   t5, 64
    j    usb_char
usb_send:
    li   t3, 1
    sw   t3, 4(t2)                        ; WR_DONE: the rest to the host
    ret

message:
    db   'Empty board: the flash was erased by Asmonite. "Prepare Board..." in the Board Manager puts the console '
    db   'on it.', 13, 10, 0
