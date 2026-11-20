; ESP32-S31 (RISC-V): the console of Asmonite over the USB port of the chip, the console of the ESP32-C3
; (boards\esp32c3\console.asm) brought over (stage 2 of the S31: the commands, the files, the programs and the packets;
; stage W6: the WiFi; Ctrl+C for a program over the CLIC of the S31). Any terminal program works
; (PuTTY, Tera Term, the tab Serial of Asmonite) on the COM port of the chip's own USB port ("USB Serial Device",
; 303A:1001; the baud rate does not matter). The commands:
;
;   ls            the files
;   cat name      shows a file
;   rm name       removes a file
;   df            the room in the flash
;   format        a new, empty file system (all files are lost)
;   run name      starts a program
;   boot name     starts the program after every reset (boot alone: which one)
;   noboot        no program after a reset
;   name [args]   any other word: the program name or name.bin of the files, the rest of the line its arguments (in
;                 its a0 and by args()); no "Running" before it, no "Program ended (code 0)" after it
;   help          the commands (the file help.txt when there is one)
;   info          the chip, the clock of the core, the flash, the MAC, the version of the console
;   reset         a reset of the chip (the program of the flash starts)
;   wlan          the WiFi network of the board (wlan set: its name and password; wlan on, wlan off; wlan clear: none;
;                 wlan scan: the networks in reach); console_wifi.asm
;
; Backspace (BS or DEL) takes back a character, Ctrl+C drops the line. A line ends with CR, LF or CR LF, whatever the
; terminal sends.
;
; The console runs in the RAM; it lies in the flash at 0x2000 (where the boot ROM of the S31 looks for its image):
; python boards\esp32s31\s31rom.py flashprog boards\esp32s31\console@2F060000. At its start: the watchdogs off (the
; super watchdog has the key of the others on the S31), timer 0 in microseconds, the trap vector of the console
; (console_run.asm), the flash attached and its size from its JEDEC id, the directory of the file system
; (console_fs.asm: the format of the ESP32), then the program for boot (autostart: 3 seconds, a key stays in the
; console). The core keeps the clock the boot ROM gave it.
;
; The RAM of the S31 is one memory for the instructions and the data (0x2F000000 .. 0x2F07AFBF; above it the boot ROM
; and the bootloader of ESP-IDF keep theirs). The plan (2026-11-17): programs 0x2F000000 .. 0x2F039FFF, the WiFi
; 0x2F03A000 .. 0x2F05FFFF (its service 0x2F03A000, the RAM parts of wlan.rom 0x2F046000 and 0x2F048000, its heap and
; buffers 0x2F050000; see abelle\linker\ablink.abel), this console from 0x2F060000 (its code and data up to 0x2F06FFFF), its buffers
; 0x2F070000 .. 0x2F077FFF, its stack below 0x2F07A000. FILEBUF of cat is in the room of the programs
; (0x2F010000, 64 KB): it is needed only before one runs.
.target esp32s31
.arch riscv32
.option rvc                             ; the short forms (2 bytes) where they fit; data words stand after align 4,
                                        ; the trap vector and con_api need jumps of 4 bytes: .option norvc there
.imagebase 0x2F060000

CON_STACK    equ 0x2F07A000             ; the top of the stack of the console (8 KB below it are its own)
CON_END      equ 0x2F070000             ; the code and the data of the console end below it
DIRBUF       equ 0x2F070000             ; the directory (4 KB)
USED         equ 0x2F071000             ; a byte for each sector of the files: 1 = in use (4 KB: a flash of 16 MB)
SMALL        equ 0x2F072000             ; 256 bytes: what is read back to check a write
CHUNK        equ 0x2F072100             ; 256 bytes and a word: a piece of a file on its way into the flash
FILEBUF      equ 0x2F010000             ; a file for cat (64 KB, in the room of the programs)
USB_SERIAL   equ 0x20391000             ; USB Serial/JTAG (as on the C3): EP1 +0 (a byte in or out), EP1_CONF +4: bit 0
                                        ; WR_DONE, bit 1 SERIAL_IN_EP_DATA_FREE (room to send), bit 2
                                        ; SERIAL_OUT_EP_DATA_AVAIL
USB_SPIN     equ 1600000                ; how long put_char waits for room in the FIFO (turns): nobody may read (400000
                                        ; at 40 MHz; the core runs at 160 MHz now: clock_init)
LINE_MAX     equ 120
RTC_WDT      equ 0x20801000             ; CONFIG0 +0 (bit 31 on), CONFIG1 +4, WPROTECT +0x18, SWD_CONFIG +0x1C (bit 18
                                        ; AUTO_FEED), SWD_WPROTECT +0x20 (ESP-IDF rtc_wdt_reg.h of the S31)
TIMG0        equ 0x20580000             ; T0CONFIG +0, T0LO +4, T0HI +8, T0UPDATE +0xC, WDTCONFIG0 +0x48, WDTWPROTECT
                                        ; +0x64, REGCLK +0xFC (as on the C3)
TIMG1        equ 0x20581000
WDT_KEY      equ 0x50D83AA1
SWD_KEY      equ 0x50D83AA1             ; the super watchdog: the key of the others (the C3 has 0x8F1D312A; with it the
                                        ; S31 kept its super watchdog and reset every 3.1 s, seen 2026-11-17)
EFUSE_MAC    equ 0x20715050             ; block 1 of the eFuses, words 0 and 1: the MAC of the factory
ROM_CPU_FREQ equ 0x2F800040             ; ets_get_cpu_frequency(): the MHz the ROM counts with (esp32s31.rom.ld)
ROM_SET_FREQ equ 0x2F800044             ; ets_update_cpu_frequency(mhz): the same, set (its ets_delay_us counts with it)
; the clock (clock_init; ESP-IDF esp32s31: rtc_clk.c, clk_tree_ll.h and the register headers)
PMU_CK_POWER equ 0x207040F4             ; PMU_IMM_HP_CK_POWER_1: TIE_HIGH_XPD_CPLL bit 27, _I2C bit 23, GLOBAL_CPLL_ICG 19
PMU_ACT_CK   equ 0x2070401C             ; PMU_HP_ACTIVE_HP_CK_POWER: XPD_CPLL bit 27, XPD_CPLL_I2C bit 23
ALIVE_CLK    equ 0x20589000             ; HP_ALIVE_SYS_HP_CLK_CTRL: HP_CPLL_300M_CLK_EN bit 29
CPLL_DIV     equ 0x2070104C             ; LP_AONCLKRST_CPLL_DIV: fb_div bits 11..4, ref_div bits 3..0
CLKRST       equ 0x20587000             ; HP_SYS_CLKRST: SOC_CLK_SEL +0 (1 the CPLL), the dividers (n - 1) of CPU +4,
                                        ; MEM +8, SYS +0xC, APB +0x10, ROOT_CLK_CTRL0 +0x14 (bit 0 SOC_CLK_UPDATE),
                                        ; ANA_PLL_CTRL0 +0x174 (CPU_PLL_CAL_END bit 2, CPU_PLL_CAL_STOP bit 3)
CPU_MHZ      equ 160

_start:
    j    con_start

; the trap vector (console_run.asm): mtvec in the vectored mode, 256 bytes aligned; each exception to exc_entry, each
; interrupt n to entry n (each 4 bytes: .option norvc up to the end of con_api)
.option norvc
  align 256
trap_vector:                            ; 0x2F060100
    j    exc_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry
    j    irq_entry

; the functions of the console for programs at CON_API (0x2F060200): each a jump of 4 bytes, in the order of the
; ESP32 (console_run.asm)
  align 256
con_api:
    j    api_exit                       ; +0   exit(code)
    j    api_version                    ; +4   version() i32
    j    api_put_char                   ; +8   put_char(c)
    j    api_get_char                   ; +12  get_char() i32
    j    api_poll_char                  ; +16  poll_char() i32
    j    api_print                      ; +20  print(text)
    j    api_millis                     ; +24  millis() i32
    j    api_file_size                  ; +28  file_size(name) i32
    j    api_file_read                  ; +32  file_read(name, buffer, offset, count) i32
    j    api_file_write                 ; +36  file_write(name, buffer, count) i32
    j    flash_bytes                    ; +40  flash_read(address, buffer, count) i32
    j    api_args                       ; +44  args() pchar
    j    api_dbg_run                    ; +48  dbg_run(entry): for the debugger only (version 3, console_run.asm)
dbg_end:
    ebreak                              ; +52  the end of a program of dbg_run: the debugger stops here
    j    main_loop                      ; +56  then the prompt
    j    api_rgb                        ; +60  rgb(pin, colour): an RGB LED WS2812 (version 4, console_run.asm)
    j    api_wifi_up                    ; +64  wifi_up() pchar: the WiFi on (version 5, console_wifi.asm)
.option rvc

con_start:
    csrci mstatus, 8                    ; no interrupts: in its download mode the boot ROM serves the USB port by its
                                        ; interrupt (it took bytes and changed registers of the console in between)
    li   sp, CON_STACK
    li   t0, SVC_BUSY                   ; the WiFi service does not run yet (its words are set up with it); no
    sw   zero, 0(t0)                    ; key_hook for it (SVC_HOOK: it calls one when it leaves an entry)
    sw   zero, 20(t0)
    call watchdogs_off
    call clock_init
    call timer_init
    call trap_init
    call flash_init
    call cred_load                      ; the network of the board (console_wifi.asm)
    la   a0, s_hello
    call print
    call dir_load
    bnez a0, con_boot
    la   a0, s_nofs
    call print
con_boot:
    call autostart
    call wl_boot                        ; the WiFi in the background (a network kept, not wlan off)

main_loop:
    la   a0, s_prompt
    call print
    la   t0, at_prompt
    li   t1, 1
    sw   t1, 0(t0)
    la   a0, line
    li   a1, LINE_MAX
    call read_line
    la   t0, at_prompt
    sw   zero, 0(t0)
    bltz a0, main_loop                  ; Ctrl+C
    la   a0, line
    call skip_spaces
    mv   s0, a0                         ; s0: the command
    lbu  t0, 0(s0)
    beqz t0, main_loop                  ; an empty line
    mv   a0, s0
    call word_end
    mv   s1, a0                         ; s1: behind the command
    la   s2, commands                   ; the table: the name, the function
ml_find:
    lw   a1, 0(s2)
    beqz a1, ml_unknown
    mv   a0, s0
    mv   a2, s1
    call word_is
    bnez a0, ml_found
    addi s2, s2, 8
    j    ml_find
ml_found:
    mv   a0, s1                         ; the function gets the rest of the line
    call skip_spaces
    lw   t0, 4(s2)
    jalr ra, 0(t0)
    j    main_loop
ml_unknown:
    lbu  t0, 0(s1)                      ; a program of this name in the files? (the rest of the line its arguments)
    sb   zero, 0(s1)
    mv   a1, s1
    beqz t0, ml_file
    addi a0, s1, 1
    call skip_spaces
    mv   a1, a0
ml_file:
    mv   a0, s0
    call cmd_file
    bnez a0, main_loop
    la   a0, s_unknown
    call print
    mv   a0, s0
    call print
    la   a0, s_unknown2
    call print
    j    main_loop

; ---------- the commands (a0: the rest of the line, without the spaces in front) ----------

cmd_info:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 4(sp)
    la   a0, s_chip
    call print
    li   t0, ROM_CPU_FREQ
    jalr ra, 0(t0)
    call print_dec
    la   a0, s_mhz
    call print
    la   a0, s_flash                    ; the flash: its size, its JEDEC id
    call print
    la   t0, flash_size
    lw   a0, 0(t0)
    srli a0, a0, 20
    call print_dec
    la   a0, s_flashid
    call print
    la   t0, flash_id
    lw   a0, 0(t0)
    call print_byte
    li   a0, ' '
    call put_char
    la   t0, flash_id
    lw   a0, 0(t0)
    srli a0, a0, 8
    call print_byte
    li   a0, ' '
    call put_char
    la   t0, flash_id
    lw   a0, 0(t0)
    srli a0, a0, 16
    call print_byte
    la   a0, s_flashend
    call print
    la   a0, s_mac
    call print
    li   t0, EFUSE_MAC                  ; the bytes as in the eFuse (word 1 bits 15..0, then word 0 from its top)
    lw   t1, 4(t0)
    lw   t2, 0(t0)
    sw   t2, 8(sp)
    srli a0, t1, 8
    call print_byte
    li   t0, EFUSE_MAC
    lw   a0, 4(t0)
    call mac_colon
    li   s0, 24
in_mac:
    lw   t2, 8(sp)
    srl  a0, t2, s0
    call mac_colon
    addi s0, s0, -8
    bgez s0, in_mac
    la   a0, s_crlf
    call print
    la   a0, s_conver
    call print
    la   a0, s_version
    call print
    la   a0, s_crlf
    call print
    lw   s0, 4(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ":" and the byte a0 (for info)
mac_colon:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    li   a0, ':'
    call put_char
    lw   a0, 8(sp)
    call print_byte
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

cmd_reset:
    la   a0, s_reset
    call print
    call flush
    li   a0, 20000                      ; the line goes out first
    call spin
    li   t0, RTC_WDT                    ; the RTC watchdog: stage 0 a reset of the system after 2000 of its ticks (as
    li   t1, WDT_KEY                    ; esptool resets a chip at its USB port)
    sw   t1, 0x18(t0)
    li   t1, 2000
    sw   t1, 0x04(t0)
    li   t1, 0xD0000102
    sw   t1, 0(t0)
cr_wait:
    j    cr_wait

; ---------- the start ----------

; the watchdogs off (the RTC one, the ones of the timer groups: after a start from the flash the boot ROM leaves
; them on; they would reset the chip in some seconds), the super watchdog feeds itself
; The core from the crystal (40 MHz; MEM 20, SYS 13.3, APB 6.7 after the reset) to the CPLL: 320 MHz (40 * 8 / 1,
; set by its dividers only, no analog registers on the S31), the core at 320 / 2 = 160 MHz, MEM 160, SYS 80, APB 40
; (rtc_clk_cpu_freq_to_cpll_mhz of ESP-IDF; 320 MHz would need MEM / 2 and maybe more voltage). Found 2026-11-17: the
; calibration is done at once, the USB port and the timer (from the crystal) go on. The ROM is told (its delays).
clock_init:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, CLKRST                     ; already on the CPLL (the console started again by run of a program, a debugger):
    lw   t1, 0(t0)                      ; nothing more
    andi t1, t1, 3
    li   t2, 1
    beq  t1, t2, ci_rom
    li   t0, PMU_CK_POWER               ; the CPLL powered (clk_ll_cpll_enable)
    lw   t1, 0(t0)
    li   t2, (1 << 27) | (1 << 23)
    or   t1, t1, t2
    sw   t1, 0(t0)
    lw   t1, 0(t0)
    li   t2, 1 << 19
    or   t1, t1, t2
    sw   t1, 0(t0)
    li   t0, ALIVE_CLK
    lw   t1, 0(t0)
    li   t2, 1 << 29
    or   t1, t1, t2
    sw   t1, 0(t0)
    li   t0, PMU_ACT_CK
    lw   t1, 0(t0)
    li   t2, (1 << 27) | (1 << 23)
    or   t1, t1, t2
    sw   t1, 0(t0)
    li   t0, CPLL_DIV                   ; 320 MHz
    lw   t1, 0(t0)
    li   t2, -4096
    and  t1, t1, t2
    ori  t1, t1, (8 << 4) | 1
    sw   t1, 0(t0)
    li   t0, CLKRST + 0x174             ; the calibration: CAL_STOP off, CAL_END, 10 us, CAL_STOP on
    lw   t1, 0(t0)
    andi t1, t1, -9
    sw   t1, 0(t0)
    li   t3, 1000000
ci_cal:
    lw   t1, 0(t0)
    andi t1, t1, 4
    bnez t1, ci_caldone
    addi t3, t3, -1
    bnez t3, ci_cal
    j    ci_out                         ; it does not end: the core stays at 40 MHz
ci_caldone:
    li   t3, 400
ci_us:
    addi t3, t3, -1
    bnez t3, ci_us
    lw   t1, 0(t0)
    ori  t1, t1, 8
    sw   t1, 0(t0)
    li   t0, CLKRST                     ; the dividers: CPU / 2, MEM / 1, SYS / 2, APB / 2
    li   t3, -16384                     ; all but the divider and its fraction (bits 13..0)
    lw   t1, 4(t0)
    and  t1, t1, t3
    ori  t1, t1, 1
    sw   t1, 4(t0)
    lw   t1, 8(t0)
    andi t1, t1, -2
    sw   t1, 8(t0)
    lw   t1, 0xC(t0)
    and  t1, t1, t3
    ori  t1, t1, 1
    sw   t1, 0xC(t0)
    lw   t1, 0x10(t0)
    and  t1, t1, t3
    ori  t1, t1, 1
    sw   t1, 0x10(t0)
    lw   t1, 0(t0)                      ; the CPLL
    andi t1, t1, -4
    ori  t1, t1, 1
    sw   t1, 0(t0)
    lw   t1, 0x14(t0)                   ; take them
    ori  t1, t1, 1
    sw   t1, 0x14(t0)
ci_upd:
    lw   t1, 0x14(t0)
    andi t1, t1, 1
    bnez t1, ci_upd
ci_rom:
    li   a0, CPU_MHZ
    li   t0, ROM_SET_FREQ
    jalr t0
ci_out:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; timer 0 of timer group 0: microseconds from the crystal (40 MHz / 40), whatever the clock of the core
timer_init:
    li   t0, TIMG0
    lw   t1, 0xFC(t0)                   ; REGCLK: CLK_EN
    li   t2, 0x80000000
    or   t1, t1, t2
    sw   t1, 0xFC(t0)
    li   t1, 0x40050200                 ; T0CONFIG: counts up, divider 40, the crystal (USE_XTAL)
    sw   t1, 0(t0)
    li   t1, 0xC0050200                 ; and on
    sw   t1, 0(t0)
    ret

; a0: the microseconds of timer 0 (T0UPDATE, the latch done when its bit 31 has cleared itself, then T0LO); changes
; t0, t1 only
micros:
    li   t0, TIMG0
    li   t1, 0x80000000
    sw   t1, 0x0C(t0)
mc_wait:
    lw   t1, 0x0C(t0)
    bltz t1, mc_wait
    lw   a0, 0x04(t0)
    ret

watchdogs_off:
    li   t0, RTC_WDT
    li   t1, WDT_KEY
    sw   t1, 0x18(t0)
    sw   zero, 0(t0)
    sw   zero, 0x18(t0)
    li   t1, SWD_KEY
    sw   t1, 0x20(t0)
    lw   t2, 0x1C(t0)
    li   t1, 0x40000                    ; SWD_AUTO_FEED_EN (bit 18 on the S31)
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

; ---------- the USB port ----------

; a0: a byte to the USB port (not sent yet: flush, a line end, a full FIFO). When nobody reads for long, the bytes
; are dropped (vars +0 counts the drops; then no wait until there is room again)
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
    la   t2, usb_drop                   ; nobody reads: dropped, and the next ones at once until there is room
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
; the S31 (seen 2026-11-17, boards\esp32s31\stage1.asm: no room for ever, the PC got nothing): WR_DONE sends it (the
; byte a0 is dropped)
pc_stuck:
    li   t1, 1
    sw   t1, 4(t0)
    ret
pc_send:
    la   t2, usb_pending                ; a line end: flush
    li   t1, 1
    sw   t1, 0(t2)

; what is in the FIFO goes out (WR_DONE). A full FIFO (64 bytes) the USB port sends by itself, but the PC takes a
; packet of 64 bytes for one that goes on: WR_DONE once the FIFO has room again ends it (a packet of 0 bytes; ESP-IDF
; usb_serial_jtag_ll.h, txfifo_flush). A WR_DONE while the PC has not taken the packet before (no room) is lost: so
; it waits for the room (USB_SPIN at most: the mark stays then, the next flush does it)
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

; a0: the next byte from the USB port (it waits; what waits to be sent goes out first). Meanwhile net_tick when the
; console watches the network (console_net.asm: the notes of a new address or of a loss)
get_char:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call flush
gc_wait:
    li   t0, USB_SERIAL
    lw   t1, 4(t0)
    andi t1, t1, 4
    bnez t1, gc_got
    la   t1, net_keep
    lw   t1, 0(t1)
    beqz t1, gc_wait
    call net_tick
    call flush
    j    gc_wait
gc_got:
    lbu  a0, 0(t0)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 turns of a loop
spin:
    addi a0, a0, -1
    bnez a0, spin
    ret

; ---------- the line ----------

; a line into a0 (at most a1 characters and a 0), with echo; its length, -1 for Ctrl+C. s0 the buffer, s1 the most,
; s2 the length
read_line:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s0, a0
    mv   s1, a1
    li   s2, 0
rl_zero:
    add  t0, s0, s2
    sb   zero, 0(t0)
rl_next:
    call get_char
    la   t0, last_cr                    ; the byte before was a CR
    lw   t1, 0(t0)
    sw   zero, 0(t0)
    li   t2, 10
    bne  a0, t2, rl_cr
    bnez t1, rl_next                    ; the LF of CR LF: the line has ended already
    j    rl_end
rl_cr:
    li   t2, 13
    bne  a0, t2, rl_cc
    li   t1, 1
    sw   t1, 0(t0)
    j    rl_end
rl_cc:
    li   t2, 2
    bne  a0, t2, rl_cc3
    li   a0, 1
    call packet_mode                    ; STX: a program on the PC; then the line starts anew
    la   t0, pk_ran                     ; a program started by a packet ran: the prompt again after its end
    lw   t1, 0(t0)
    beqz t1, rl_pkdone
    sw   zero, 0(t0)
    la   a0, s_prompt
    call print
rl_pkdone:
    li   s2, 0
    j    rl_zero
rl_cc3:
    li   t2, 3
    bne  a0, t2, rl_bs
    la   a0, s_cancel
    call print
    li   a0, -1
    j    rl_ret
rl_bs:
    li   t2, 8
    beq  a0, t2, rl_back
    li   t2, 127
    beq  a0, t2, rl_back
    li   t2, 9
    bne  a0, t2, rl_ctrl
    li   a0, 32                         ; a tab: a space
rl_ctrl:
    li   t2, 32
    bltu a0, t2, rl_next                ; other control characters: left out
    bgeu s2, s1, rl_next                ; the line is full
    add  t0, s0, s2
    sb   a0, 0(t0)
    sb   zero, 1(t0)
    addi s2, s2, 1
    la   t0, no_echo
    lw   t0, 0(t0)
    bnez t0, rl_next
    call put_char
    j    rl_next
rl_back:
    beqz s2, rl_next
    addi s2, s2, -1
    add  t0, s0, s2
    sb   zero, 0(t0)
    la   t0, no_echo
    lw   t0, 0(t0)
    bnez t0, rl_next
    la   a0, s_bs
    call print
    j    rl_next
rl_end:
    la   a0, s_crlf
    call print
    mv   a0, s2
rl_ret:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 behind the spaces at a0
skip_spaces:
    lbu  t0, 0(a0)
    li   t1, ' '
    bne  t0, t1, ss_done
    addi a0, a0, 1
    j    skip_spaces
ss_done:
    ret

; a0 at the end of the word at a0 (a space or the 0)
word_end:
    lbu  t0, 0(a0)
    beqz t0, we_done
    li   t1, ' '
    beq  t0, t1, we_done
    addi a0, a0, 1
    j    word_end
we_done:
    ret

; 1 when the word a0 .. a2 (exclusive) is the text a1, else 0
word_is:
    lbu  t0, 0(a1)
    beq  a0, a2, wi_end
    beqz t0, wi_no
    lbu  t1, 0(a0)
    bne  t0, t1, wi_no
    addi a0, a0, 1
    addi a1, a1, 1
    j    word_is
wi_end:
    seqz a0, t0
    ret
wi_no:
    li   a0, 0
    ret

; a number at a0: hex with 0x, else decimal. a0 its value, a1 0 (or -1: there is none), a2 behind it
parse_number:
    mv   a2, a0
    li   a0, 0
    li   a1, -1
    lbu  t0, 0(a2)
    li   t1, '0'
    bne  t0, t1, pn_dec
    lbu  t0, 1(a2)
    ori  t0, t0, 32
    li   t1, 'x'
    bne  t0, t1, pn_dec
    addi a2, a2, 2
pn_hex:
    lbu  t0, 0(a2)
    addi t1, t0, -48                    ; 0 .. 9
    li   t2, 10
    bltu t1, t2, pn_hdig
    ori  t0, t0, 32
    addi t1, t0, -87                    ; a .. f
    li   t2, 10
    bltu t1, t2, pn_done
    li   t2, 16
    bgeu t1, t2, pn_done
pn_hdig:
    slli a0, a0, 4
    or   a0, a0, t1
    li   a1, 0
    addi a2, a2, 1
    j    pn_hex
pn_dec:
    lbu  t0, 0(a2)
    addi t1, t0, -48
    li   t2, 10
    bgeu t1, t2, pn_done
    li   t2, 10
    mul  a0, a0, t2
    add  a0, a0, t1
    li   a1, 0
    addi a2, a2, 1
    j    pn_dec
pn_done:
    lbu  t0, 0(a2)                      ; a number ends at a space or the end of the line
    beqz t0, pn_ret
    li   t1, ' '
    beq  t0, t1, pn_ret
    li   a1, -1
pn_ret:
    ret

; copy_bytes(to, from, n). It calls nothing (changes t0 and the arguments).
copy_bytes:
    beqz a2, cb_done
    lbu  t0, 0(a1)
    sb   t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j    copy_bytes
cb_done:
    ret

; str_eq(a, b): 1 when the texts at a and b are the same (up to their 0), else 0. It calls nothing.
str_eq:
    lbu  t0, 0(a0)
    lbu  t1, 0(a1)
    bne  t0, t1, se_no
    beqz t0, se_yes
    addi a0, a0, 1
    addi a1, a1, 1
    j    str_eq
se_yes:
    li   a0, 1
    ret
se_no:
    li   a0, 0
    ret

; zero_words(from, to): the words from .. to (exclusive) to 0. It calls nothing.
zero_words:
    bgeu a0, a1, zw_done
    sw   zero, 0(a0)
    addi a0, a0, 4
    j    zero_words
zw_done:
    ret

; ---------- texts and numbers ----------

; print_pad(text, w): the text, then spaces up to w places
print_pad:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    mv   s1, a1
ppd_next:
    lbu  a0, 0(s0)
    beqz a0, ppd_fill
    call put_char
    addi s0, s0, 1
    addi s1, s1, -1
    j    ppd_next
ppd_fill:
    blez s1, ppd_done
    li   a0, ' '
    call put_char
    addi s1, s1, -1
    j    ppd_fill
ppd_done:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; print_dec_right(v, w): v as a decimal number, right-aligned in w places
print_dec_right:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    mv   s1, a1
    mv   t0, a0                         ; its digits
    li   t1, 0
pdr_count:
    li   t2, 10
    divu t0, t0, t2
    addi t1, t1, 1
    bnez t0, pdr_count
    sub  s1, s1, t1
pdr_fill:
    blez s1, pdr_num
    li   a0, ' '
    call put_char
    addi s1, s1, -1
    j    pdr_fill
pdr_num:
    mv   a0, s0
    call print_dec
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the text at a0 (up to its 0)
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
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 as "0x" and 8 hex digits
print_hex:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    li   a0, '0'
    call put_char
    li   a0, 'x'
    call put_char
    lw   a0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ; (on into print_hex8)

; a0 as 8 hex digits
print_hex8:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    li   s1, 28
ph_digit:
    srl  a0, s0, s1
    call hex_digit
    addi s1, s1, -4
    bgez s1, ph_digit
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 as two hex digits
print_byte:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    srli a0, a0, 4
    call hex_digit
    lw   a0, 8(sp)
    call hex_digit
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a0 & 15 as a hex digit
hex_digit:
    andi a0, a0, 15
    li   t0, 10
    blt  a0, t0, hd_num
    addi a0, a0, 'A' - '0' - 10
hd_num:
    addi a0, a0, '0'
    j    put_char

; a0 as a decimal number (without a sign)
print_dec:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    li   s0, 0                          ; the digits on the stack, the last first
pd_div:
    li   t0, 10
    remu t1, a0, t0
    divu a0, a0, t0
    addi t1, t1, '0'
    add  t2, sp, s0
    sb   t1, 0(t2)
    addi s0, s0, 1
    bnez a0, pd_div
pd_out:
    addi s0, s0, -1
    add  t2, sp, s0
    lbu  a0, 0(t2)
    call put_char
    bnez s0, pd_out
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

.include "console_fs.asm"
.include "console_pk.asm"
.include "console_run.asm"
.include "console_wifi.asm"
.include "console_net.asm"

; ---------- data ----------
  align 4
commands:                               ; a command: its name, its function; 0 at the end
  dd c_ls, cmd_ls
  dd c_cat, cmd_cat
  dd c_rm, cmd_rm
  dd c_df, cmd_df
  dd c_format, cmd_format
  dd c_run, cmd_run
  dd c_boot, cmd_boot
  dd c_noboot, cmd_noboot
  dd c_help, cmd_help
  dd c_info, cmd_info
  dd c_reset, cmd_reset
  dd c_wlan, cmd_wlan
  dd c_name, cmd_name
  dd 0, 0
packets:                                ; a packet: its command (a word), its function; 0 at the end (Q: do_packet)
  dd 0x50, pk_version   ; P
  dd 0x56, pk_conver    ; V
  dd 0x46, pk_free   ; F
  dd 0x4C, pk_list   ; L
  dd 0x4F, pk_open   ; O
  dd 0x57, pk_write   ; W
  dd 0x43, pk_close   ; C
  dd 0x47, pk_get   ; G
  dd 0x44, pk_delete   ; D
  dd 0x58, pk_run   ; X
  dd 0x42, pk_boot   ; B
  dd 0x4D, pk_format   ; M
  dd 0x52, pk_ram   ; R
  dd 0x45, pk_exec   ; E
  dd 0x59, pk_flash   ; Y
  dd 0x4B, pk_crc   ; K
  dd 0x49, pk_ident   ; I
  dd 0x53, pk_speed   ; S
  dd 0x48, pk_board   ; H
  dd 0x41, pk_area    ; A
  dd 0x4E, pk_net     ; N
  dd 0, 0
rooms:                                  ; segment_fits: from, up to (exclusive), the kind (1 a program, 3 load only,
                                        ; 2 a segment for the flash, load leaves it out)
  dd 0x2F000000, 0x2F03A000, 1          ; the programs: their code and data (one RAM)
  dd 0x2F03A000, 0x2F060000, 3          ; above them up to the console: the WiFi (service, wlan.rom, its heap)
  dd 0x40000000, 0x54000000, 2          ; the flash through the cache (esptool IROM_MAP, DROM_MAP of the S31)
  dd 0, 0, 0
prog_running: dd 0                      ; a program runs (exc_entry: its exception ends it)
prog_cause:  dd 0, 0, 0                 ; the exception: mcause, mepc, mtval
prog_entry:  dd 0                       ; the entry of the program (segments, packet E)
prog_args:   dd 0                       ; the text of its arguments
prog_how:    dd 0                       ; how it started (run_file)
prog_sp:     dd 0                       ; the sp of the console while it runs
prog_mie:    dd 0                       ; mstatus.MIE of the console before it (re_back sets it again)
prog_code:   dd 0, 0                    ; its code, how it ended
pk_ran:      dd 0                       ; a program started by a packet ran (read_line: the prompt again)
seg_flash:   dd 0                       ; segments, bit 1 of its mode: the segments for the flash left out
key_head:    dd 0, 0                    ; KEYRING: head, tail
key_stop:    dd 0                       ; a Ctrl+C waits for the end of a function of the flash
flash_busy:  dd 0                       ; a function of the ROM works on the flash
wf_open:     dd 0, 0, 0, 0, 0, 0, 0     ; packet O .. C: open, the first sector, the length, the CRC-32, written so far,
                                        ; the entry, the offset of the last piece
wf_name:     dd 0, 0, 0, 0, 0           ; its name
fs_ok:       dd 0                       ; there is a file system (dir_load, dir_save)
fs_dir:      dd 0                       ; the directory in use (0 or 1)
fs_sectors:  dd 0                       ; the sectors of the files (flash_init)
flash_size:  dd 0                       ; the bytes of the flash (flash_init)
flash_id:    dd 0                       ; its JEDEC id (flash_init)
namebuf:     dd 0, 0, 0, 0, 0, 0        ; put: the name of the file (the line is read anew)
usb_drop:    dd 0                       ; put_char: nobody read for long
usb_pending: dd 0                       ; put_char: bytes in the FIFO not sent yet
last_cr:     dd 0                       ; read_line: the byte before was a CR
no_echo:     dd 0                       ; read_line: without echo (the password of wlan set)
svc_loaded:  dd 0                       ; the WiFi service: 1 in the RAM (wl_ready), 2 the package written anew since
wifi_up:     dd 0                       ; wifi_on of the service ran (wl_up), not off again
cred_ok:     dd 0                       ; CRED holds a valid record of the network (cred_load)
cred_num:    dd 0                       ; its number
cred_sec:    dd 0                       ; its sector
at_prompt:   dd 0                       ; main_loop reads a command (net_say: the prompt and the line again)
pk_mode:     dd 0                       ; packet_mode runs (net_say says nothing)
net_keep:    dd 0                       ; the console watches the connection (console_net.asm: net_tick in get_char)
net_ip:      dd 0                       ; the address of the board (wifi_get_ip; as it lies in the RAM), 0 none
line:        db 0
  align 4
             dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
s_hello:   db 13, 10, 'Asmonite console 2 for the ESP32-S31, stage 2 (help shows the commands)', 13, 10, 0
  align 4
s_conver_v: dd CON_VERSION              ; the answer to V
s_version: db 'Asmonite console 2', 0
s_board:   db 'ESP32-S31', 0            ; the answer to H: the USB port of the S31 looks like the one of the C3, S3
s_prompt:  db '> ', 0
s_crlf:    db 13, 10, 0
s_bs:      db 8, 32, 8, 0
s_cancel:  db '^C', 13, 10, 0
s_help:    db '  ls cat rm df format run boot noboot wlan name help info reset, or a program: name [args]', 13, 10
           db '  (help.txt is missing: Prepare Board in the Board Manager writes it)', 13, 10, 0
s_nofs:    db 'There is no file system in the flash yet: format makes one.', 13, 10, 0
s_noname:  db 'Which file? (a name after the command)', 13, 10, 0
s_long:    db 'The name is too long: 19 characters at most.', 13, 10, 0
s_space:   db 'A name has no spaces.', 13, 10, 0
s_nofile:  db 'There is no file ', 0
s_bytes:   db ' bytes', 13, 10, 0
s_dirfull: db 'The directory is full: 64 files at most.', 13, 10, 0
s_full:    db 'There is not enough room in the flash.', 13, 10, 0
s_flasherr: db 'The flash cannot be written there (it reads back otherwise).', 13, 10, 0
s_damaged: db '(The file is damaged: its checksum does not match.)', 13, 10, 0
s_removed: db 'Removed ', 0
s_files:   db ' file(s), ', 0
s_inuse:   db ' bytes in use, ', 0
s_free:    db ' bytes free', 13, 10, 0
s_nofiles: db 'No files.', 13, 10, 0
s_sure:    db 'All files will be lost. Type yes to go on: ', 0
s_yes:     db 'yes', 0
s_formatted: db 'Done: an empty file system.', 13, 10, 0
s_notformatted: db 'Nothing was changed.', 13, 10, 0
s_flash:   db 'Flash: ', 0
s_flashid: db ' MB (JEDEC id ', 0
s_flashend: db ')', 13, 10, 0
c_ls:      db 'ls', 0
c_cat:     db 'cat', 0
c_rm:      db 'rm', 0
c_df:      db 'df', 0
c_format:  db 'format', 0
c_helptxt: db 'help.txt', 0
s_unknown: db 'Unknown command: ', 0
s_unknown2: db ' (help shows the commands)', 13, 10, 0
s_chip:    db 'Chip: ESP32-S31 (RISC-V), core at ', 0
s_mhz:     db ' MHz', 13, 10, 0
s_mac:     db 'MAC: ', 0
s_conver:  db 'Console: ', 0
s_reset:   db 'Reset.', 13, 10, 0
c_help:    db 'help', 0
c_info:    db 'info', 0
c_reset:   db 'reset', 0
c_run:     db 'run', 0
c_boot:    db 'boot', 0
c_noboot:  db 'noboot', 0
s_empty:   db 0
s_bin:     db '.bin', 0
s_running: db 'Running ', 0
s_ended:   db 'Program ended (code ', 0
s_ended2:  db ').', 13, 10, 0
s_stopped: db 'Program stopped: exception ', 0
s_keystop: db 'Program stopped (Ctrl+C).', 13, 10, 0
s_confault: db 'The console stopped: exception ', 0
s_at:      db ' at pc ', 0
s_addr:    db ', address ', 0
s_dotcrlf: db '.', 13, 10, 0
s_auto:    db 'Autostart of ', 0
s_auto2:   db ' in 3 seconds (press a key to stay in the console)', 13, 10, 0
s_stay:    db 'No autostart this time.', 13, 10, 0
s_boot:    db 'Autostart: ', 0
s_noboot:  db 'No autostart.', 13, 10, 0
e_packet:  db 'The packet was damaged.', 0
e_unknown: db 'Unknown packet.', 0
e_size:    db 'The packet has the wrong length.', 0
e_nofile:  db 'There is no such file.', 0
e_notopen: db 'No file is open for writing.', 0
e_place:   db 'The bytes are not at their place in the file.', 0
e_fcrc:    db 'The file in the flash does not match its CRC-32.', 0
e_noprog:  db 'This is not a program (an image as Asmonite writes it into the flash).', 0
e_where:   db 'The program does not fit: its code and data must be in 0x2F000000..0x2F039FFF.', 0
e_damaged: db 'The file is damaged: its CRC-32 does not match.', 0
e_area:    db 'The address is not in the room of the WiFi package (0x100000 .. 0x1FFFFF, whole sectors).', 0
; the WiFi (console_wifi.asm)
c_wlan:    db 'wlan', 0
s_wlname:  db 'esp32s31-'
c_set:     db 'set', 0
c_on:      db 'on', 0
c_off:     db 'off', 0
c_clear:   db 'clear', 0
c_scan:    db 'scan', 0
s_wluse:   db 'wlan, wlan set, wlan on, wlan off, wlan clear, wlan scan', 13, 10, 0
s_wlnone:  db 'The board knows no network (wlan set gives it one).', 13, 10, 0
s_wlnet:   db 'Network: ', 0
s_wlwpa:   db ' (WPA2)', 13, 10, 0
s_wlopen:  db ' (open)', 13, 10, 0
s_wlisoff: db 'The WiFi is off (wlan off; wlan on switches it on).', 13, 10, 0
s_wlst0:   db 'The WiFi does not run (wlan on).', 13, 10, 0
s_wlst1:   db 'The WiFi runs, not connected.', 13, 10, 0
s_wlst2:   db 'The WiFi connects in the background.', 13, 10, 0
s_wladdr:  db 'Address: ', 0
s_ntconn:  db 'WiFi: connected, address ', 0
s_ntlost:  db 'WiFi: no connection', 0
s_ntname1: db ' (', 0
s_ntname2: db '.local)', 0
s_wlst3:   db 'The WiFi is connected.', 13, 10, 0
s_wlask1:  db 'Name of the network: ', 0
s_wlask2:  db 'Password (empty: an open network): ', 0
s_wlbadpw: db 'A password of WPA2 has 8 to 63 characters. Nothing was changed.', 13, 10, 0
s_wlkey:   db 'The key of the network (half a second) ...', 13, 10, 0
s_wlsaved: db 'The board keeps the network ', 0
s_wloffnow: db 'WiFi off (also after a reset: wlan on switches it on again).', 13, 10, 0
s_wlcleared: db 'The board knows no network now.', 13, 10, 0
s_wlscan:  db 'The networks in reach:', 13, 10, 0
s_wlch:    db '  channel ', 0
s_wlsig:   db '  ', 0
s_wldbm:   db ' dBm  ', 0
s_wlkopen: db 'open  ', 0
s_wlkwpa:  db 'key   ', 0
s_wlerr:   db 'WiFi: the error ', 0
s_wlnets:  db ' network(s)', 13, 10, 0
s_wlwifi:  db 'WiFi: ', 0
s_wlconn1: db 'WiFi: connecting to ', 0
s_wlconn2: db ' in the background.', 13, 10, 0
s_wlnoconn: db 'WiFi: no connection (', 0
s_wlnoconn2: db ').', 13, 10, 0
s_wlstart: db 'WiFi: the radio on ...', 13, 10, 0
s_wlonerr: db 'WiFi: wifi_on failed: ', 0
e_wlon:    db 'The WiFi did not start.', 0
e_wlstale: db 'The WiFi package was written anew: reset the board first (reset).', 0
e_wlnone:  db 'There is no WiFi package in the flash (Board Manager > Prepare Board or Install WiFi Again).', 0
e_wlbad:   db 'The WiFi package in the flash is damaged (Board Manager > Install WiFi Again).', 0
e_wlold:   db 'The WiFi service in the flash is an older one (Board Manager > Install WiFi Again).', 0
c_name:    db 'name', 0
s_nmuse:   db 'name, name set <name>, name clear', 13, 10, 0
s_nmbad:   db 'A name has 1 to 31 letters, digits or -, for example: name set keller', 13, 10, 0
s_nmis:    db 'The name of the board: ', 0
s_nmmac:   db 'It comes from the MAC; name set <name> gives the board another one.', 13, 10, 0
  align 4
wls_texts: dd s_wlst0, s_wlst1, s_wlst2, s_wlst3, s_wlisoff
