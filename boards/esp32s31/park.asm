; The park program of the ESP32-S31: Erase Flash of the Board Manager writes it into the erased flash (at 0x2000), so
; the board starts in a controlled way instead of restarting again and again. It switches the watchdogs off as the
; console does (watchdogs_off of boards\esp32s31\console.asm: the super watchdog has the key of the others on the S31)
; and writes a line to the USB port of the chip every 3 seconds; when nobody reads, the line is dropped. The Board
; Manager and the tab Serial know the board by it ("erased by Asmonite"). Prepare Board puts the console in its place.
.target esp32s31
.arch riscv32
.imagebase 0x2F000000

USB_SERIAL   equ 0x20391000             ; USB Serial/JTAG: EP1 +0, EP1_CONF +4 (bit 0 WR_DONE, bit 1 room in the FIFO)
USB_TRIES    equ 100000                 ; tries before a line is dropped (nobody reads)
PAUSE_COUNT  equ 24000000               ; some seconds at the clock the boot ROM leaves
RTC_WDT      equ 0x20801000             ; CONFIG0 +0, WPROTECT +0x18, SWD_CONFIG +0x1C (bit 18 AUTO_FEED), SWD_WPROTECT
                                        ; +0x20
TIMG0        equ 0x20580000             ; WDTCONFIG0 +0x48, WDTWPROTECT +0x64
TIMG1        equ 0x20581000
WDT_KEY      equ 0x50D83AA1             ; also the key of the super watchdog on the S31

_start:
    li   t0, RTC_WDT
    li   t1, WDT_KEY
    sw   t1, 0x18(t0)
    sw   zero, 0(t0)
    sw   zero, 0x18(t0)
    sw   t1, 0x20(t0)
    lw   t2, 0x1C(t0)
    li   t3, 0x40000                    ; SWD_AUTO_FEED_EN
    or   t2, t2, t3
    sw   t2, 0x1C(t0)
    sw   zero, 0x20(t0)
    li   t0, TIMG0
    sw   t1, 0x64(t0)
    sw   zero, 0x48(t0)
    sw   zero, 0x64(t0)
    li   t0, TIMG1
    sw   t1, 0x64(t0)
    sw   zero, 0x48(t0)
    sw   zero, 0x64(t0)
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
    li   t2, USB_SERIAL
    li   t5, 64
usb_char:
    li   t4, USB_TRIES
usb_wait:
    lw   t3, 4(t2)
    andi t3, t3, 2
    bnez t3, usb_put
    addi t4, t4, -1
    bnez t4, usb_wait
    ret                                 ; nobody reads the port: the rest is dropped
usb_put:
    lbu  t3, 0(a0)
    beqz t3, usb_send
    sw   t3, 0(t2)
    addi a0, a0, 1
    addi t5, t5, -1
    bnez t5, usb_char
    li   t3, 1
    sw   t3, 4(t2)                      ; 64 bytes: the FIFO to the host
    li   t5, 64
    j    usb_char
usb_send:
    li   t3, 1
    sw   t3, 4(t2)                      ; WR_DONE: the rest to the host
    ret

message:
    db   'Empty board: the flash was erased by Asmonite. "Prepare Board..." in the Board Manager puts the console '
    db   'on it.', 13, 10, 0
