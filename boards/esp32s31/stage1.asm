; ESP32-S31 (RISC-V), stage 1 of its console: a program of its own on the chip. It switches the watchdogs off, says
; hello over the USB port of the chip (USB Serial/JTAG, the same unit as on the ESP32-C3: put_char, flush and get_char
; are the ones of boards\esp32c3\console.asm), shows what the core says about itself (misa: its extensions, mhartid:
; the core, mvendorid, marchid) and then sends back each key it gets ("echo"), Ctrl+C ends it with a reset.
;
;   in the RAM over the boot ROM:  python boards\esp32s31\s31rom.py run boards\esp32s31\stage1@2F070000 --send abc
;   from the flash (at 0x2000):    python boards\esp32s31\s31rom.py flashprog boards\esp32s31\stage1@2F070000
;                                  python boards\esp32s31\s31rom.py term --send hello
.target esp32s31
.arch riscv32
.option rvc
.imagebase 0x2F070000

STACK        equ 0x2F07A000             ; the top of the stack (below SRAM_SEG_END 0x2F07AFC0)
USB_SERIAL   equ 0x20391000             ; USB Serial/JTAG: EP1 +0 (a byte in or out), EP1_CONF +4: bit 0 WR_DONE,
                                        ; bit 1 SERIAL_IN_EP_DATA_FREE (room to send), bit 2 SERIAL_OUT_EP_DATA_AVAIL
USB_SPIN     equ 400000                 ; how long put_char waits for room in the FIFO (turns): nobody may read
RTC_WDT      equ 0x20801000             ; CONFIG0 +0 (bit 31 on), WPROTECT +0x18, SWD_CONFIG +0x1C (bit 18 AUTO_FEED),
                                        ; SWD_WPROTECT +0x20 (ESP-IDF rtc_wdt_reg.h of the S31)
TIMG0        equ 0x20580000             ; WDTCONFIG0 +0x48, WDTWPROTECT +0x64 (as on the C3)
TIMG1        equ 0x20581000
WDT_KEY      equ 0x50D83AA1
SWD_KEY      equ 0x50D83AA1             ; the super watchdog: the key of the others (the C3 has 0x8F1D312A; with it the
                                        ; S31 kept its super watchdog and reset every 3.1 s, seen 2026-11-17)

_start:
    csrci mstatus, 8                    ; no interrupts: in its download mode the boot ROM serves the USB port by its
                                        ; interrupt (as on the C3, whose console does the same)
    li   sp, STACK
    call watchdogs_off
    la   a0, s_hello
    call print
    la   a0, s_misa
    call print
    csrr a0, 0x301                      ; misa
    call print_hex
    call misa_letters
    la   a0, s_hart
    call print
    csrr a0, 0xF14                      ; mhartid
    call print_hex
    la   a0, s_vendor
    call print
    csrr a0, 0xF11                      ; mvendorid
    call print_hex
    la   a0, s_arch
    call print
    csrr a0, 0xF12                      ; marchid
    call print_hex
    la   a0, s_echo
    call print
echo:
    call get_char
    li   t0, 3
    beq  a0, t0, ctrl_c
    li   t0, 13
    bne  a0, t0, echo_one
    call put_char
    li   a0, 10
echo_one:
    call put_char
    call flush
    j    echo
ctrl_c:
    la   a0, s_bye
    call print
    li   a0, 2000000
    call spin
    ; a reset by the RTC watchdog (stage 0: a reset of the system, after 2000 of its ticks)
    li   t0, RTC_WDT
    li   t1, WDT_KEY
    sw   t1, 0x18(t0)
    li   t1, 2000
    sw   t1, 0x04(t0)
    li   t1, 0xD0000102
    sw   t1, 0(t0)
stay:
    j    stay

; the RTC watchdog, the super watchdog (fed by itself) and the watchdogs of the two timer groups off
watchdogs_off:
    li   t0, RTC_WDT
    li   t1, WDT_KEY
    sw   t1, 0x18(t0)
    sw   zero, 0(t0)
    sw   zero, 0x18(t0)
    li   t1, SWD_KEY
    sw   t1, 0x20(t0)
    lw   t2, 0x1C(t0)
    li   t1, 0x40000                    ; SWD_AUTO_FEED_EN
    or   t2, t2, t1
    sw   t2, 0x1C(t0)
    sw   zero, 0x20(t0)
    li   t1, WDT_KEY
    li   t0, TIMG0
    sw   t1, 0x64(t0)
    sw   zero, 0x48(t0)
    sw   zero, 0x64(t0)
    li   t0, TIMG1
    sw   t1, 0x64(t0)
    sw   zero, 0x48(t0)
    sw   zero, 0x64(t0)
    ret

; the letters of the extensions in misa: " (" A .. Z ")"
misa_letters:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    csrr s0, 0x301
    li   a0, 32
    call put_char
    li   a0, 40
    call put_char
    li   s1, 0
ml_next:
    srl  t0, s0, s1
    andi t0, t0, 1
    beqz t0, ml_skip
    addi a0, s1, 65
    call put_char
ml_skip:
    addi s1, s1, 1
    li   t0, 26
    blt  s1, t0, ml_next
    li   a0, 41
    call put_char
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 as 0x and eight hex digits
print_hex:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    li   a0, 48
    call put_char
    li   a0, 120
    call put_char
    li   s1, 28
ph_next:
    srl  t0, s0, s1
    andi t0, t0, 15
    addi a0, t0, 48
    li   t1, 58
    blt  a0, t1, ph_digit
    addi a0, a0, 7
ph_digit:
    call put_char
    addi s1, s1, -4
    bgez s1, ph_next
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0: a text up to its 0
print:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
pr_next:
    lbu  a0, 0(s0)
    beqz a0, pr_done
    call put_char
    addi s0, s0, 1
    j    pr_next
pr_done:
    call flush
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the USB port (as boards\esp32c3\console.asm) ----------

; a0: a byte to the USB port (not sent yet: flush, a line end, a full FIFO). When nobody reads for long, the bytes
; are dropped (usb_drop; then no wait until there is room again)
put_char:
    li   t0, USB_SERIAL
    la   t2, usb_drop
    lw   t1, 0(t2)
    bnez t1, pc_quick
    li   t1, USB_SPIN
pc_wait:
    lw   t2, 4(t0)
    andi t2, t2, 2
    bnez t2, pc_room
    addi t1, t1, -1
    bnez t1, pc_wait
    la   t2, usb_drop
    li   t1, 1
    sw   t1, 0(t2)
    ret
pc_quick:
    lw   t2, 4(t0)
    andi t2, t2, 2
    beqz t2, pc_stuck
    la   t2, usb_drop
    sw   zero, 0(t2)
pc_room:
    sw   a0, 0(t0)
    li   t1, 10
    beq  a0, t1, pc_send
    la   t2, usb_pending
    li   t1, 1
    sw   t1, 0(t2)
pc_done:
    ret
; the FIFO is full and nobody took it: a full FIFO written before the PC had the port open is not sent by itself on
; the S31 (seen 2026-11-17: no room for ever, the PC got nothing): WR_DONE sends it (the byte a0 is dropped)
pc_stuck:
    li   t1, 1
    sw   t1, 4(t0)
    ret
pc_send:
    la   t2, usb_pending                ; a line end: flush
    li   t1, 1
    sw   t1, 0(t2)

; what is in the FIFO goes out (WR_DONE). A full FIFO (64 bytes) the USB port sends by itself, but the PC takes a
; packet of 64 bytes for one that goes on: WR_DONE once the FIFO has room again ends it (see the console of the C3)
flush:
    la   t0, usb_pending
    lw   t1, 0(t0)
    beqz t1, fl_done
    li   t0, USB_SERIAL
    li   t1, USB_SPIN
fl_wait:
    lw   t2, 4(t0)
    andi t2, t2, 2
    bnez t2, fl_room
    addi t1, t1, -1
    bnez t1, fl_wait
    ret
fl_room:
    li   t1, 1
    sw   t1, 4(t0)
    la   t0, usb_pending
    sw   zero, 0(t0)
fl_done:
    ret

; a0: the next byte from the USB port (it waits; what waits to be sent goes out first)
get_char:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call flush
gc_wait:
    li   t0, USB_SERIAL
    lw   t1, 4(t0)
    andi t1, t1, 4
    beqz t1, gc_wait
    lbu  a0, 0(t0)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 turns of a loop
spin:
    addi a0, a0, -1
    bnez a0, spin
    ret

s_hello:  db 13, 10, "ESP32-S31: stage 1 of the console of Asmonite (its own program, from 0x2F070000)", 13, 10, 0
s_misa:   db "misa      ", 0
s_hart:   db 13, 10, "mhartid   ", 0
s_vendor: db 13, 10, "mvendorid ", 0
s_arch:   db 13, 10, "marchid   ", 0
s_echo:   db 13, 10, "Echo: each key comes back; Ctrl+C: a reset.", 13, 10, 0
s_bye:    db 13, 10, "Ctrl+C: reset.", 13, 10, 0
  align 4
usb_drop:    dd 0                       ; put_char: nobody read for long
usb_pending: dd 0                       ; put_char: bytes in the FIFO not sent yet
