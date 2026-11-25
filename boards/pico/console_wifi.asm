; The console of Asmonite: the WiFi chip of a Pico W or a Pico 2 W. The part of boards\pico\console.asm and
; boards\pico2\console.asm that asks it (is the board a W?) and starts it with its firmware (wlan on). Thumb-1, for
; both chips.
;
; The chip itself does not tell (the Pico W has the same RP2040 as the Pico, the Pico 2 W the same RP2350 as the
; Pico 2). On the W boards the WiFi chip (Infineon CYW43439) hangs at four GPIOs, the same on both:
;   GPIO 23  WL_ON   its power (high: on)
;   GPIO 24  WL_D    the data of its SPI (one wire, both ways)
;   GPIO 25  WL_CS   the chip select of the SPI (low: selected)
;   GPIO 29  WL_CLK  the clock of the SPI
; wifi_detect switches the WiFi chip off and on again and reads its register for tests (0x14, function 0) over this
; SPI, by hand: a W answers 0xFEEDBEAD within some milliseconds (the Pico 2 W within 50). Then the chip goes off
; again. While its power comes on, the data line has to be low: the chip takes it as the sign to talk gSPI (high, as a
; pull-up leaves it, means SDIO, and the chip answers nonsense). On a Pico or Pico 2
; without WiFi these pins are the power save pin of the voltage regulator (GPIO 23), the sense of VBUS (GPIO 24), the
; LED (GPIO 25: it lights while the console asks, at most a quarter of a second) and the measure of VSYS (GPIO 29):
; nothing that a short ask harms. Afterwards GPIO 23 is an output, low (the WiFi chip off; the regulator as after a
; reset), 24, 25 and 29 are inputs.
;
; The protocol (the gSPI of the CYW43439): CS low, a command word of 32 bits (bit 31 write, bit 30 the address counts
; up, bits 29 .. 28 the function, bits 27 .. 11 the address, bits 10 .. 0 the bytes), the highest bit first, each bit
; taken by the WiFi chip at the rising edge of the clock; then the line turns, and the chip sends the 32 bits of the
; answer. After the power comes on the chip talks in halfwords: the two halves of the command and of the answer are
; swapped (so 0x4000A004 goes as 0xA0044000, and 0xFEEDBEAD comes as 0xBEADFEED). The bits are read at both edges of
; the clock (before the rising edge and after it): one of them is the answer, whatever edge the chip sends at.
;
; wlan on (wlan_start) starts the WiFi chip with its firmware, from three files of the console (Board Manager: Prepare
; Board puts them there on a W, from vendor\infineon of Asmonite):
;   43439A0.bin       the firmware of its Arm core (Infineon, 7.95.61; about 226 KB)
;   nvram_rp2040.bin  the NVRAM of the board (its crystal, its antenna ...: 742 bytes)
;   43439A0_clm.bin   the CLM data: the channels and the power per country (984 bytes)
; The console reads them straight from the flash (XIP: a file lies in sectors one after the other). The steps, as the
; driver of the chip does them (cyw43-driver of the Pico SDK, embassy): the chip on (as wifi_detect); the test register
; in halfwords until it is 0xFEEDBEAD; then 32-bit words (register 0 of function 0: 0xA1, written in halfwords); the
; test register again, now 0xFEEDBEAD at once. The ALP clock of its backplane (the bus inside the chip: register
; 0x1000E of function 1 = 8, it answers 0x48). The Arm core of the WiFi chip held off (its wrapper at 0x18103000),
; its RAM (SOCSRAM, wrapper 0x18104000) reset, then its bank 3 not remapped (0x18004010 = 3, 0x18004044 = 0). The
; firmware into its RAM from 0, over the window of function 1 (registers 0x1000A .. 0x1000C: bits 31 .. 15 of the
; address; the offset in the window in the command, pieces of up to 64 bytes); the NVRAM at the end of the 512 KB of
; its RAM, before the last word: its length in words n as (~n << 16) | n. Then its core out of reset: the firmware
; runs and switches the HT clock on (bit 7 of 0x1000E, after some 20 ms). A word of function 1 reads with one word of
; padding before it; a single word of the backplane has 0x8000 in the offset (4 bytes), a byte not.
; Then the bus as the drivers set it (its interrupts, the mask of the SDIO core 0x18002024 = 0xF0, the watermark of
; function 2 = 0x20), function 2 ready (bit 5 of the status register), the pulls of the pads off, the HT clock asked
; (0x1000E = 0x10). From here the console talks to the firmware in packets over function 2 (wl_ioctl, wl_poll): the
; CLM data (the iovar clmload, then clmload_status 0), bus:txglom 0, apsta 1. The LED of a W is GPIO 0 of the WiFi
; chip: the iovar gpioout (wifi_led). wlan off: the chip off (GPIO 23 low). wlan scan: the iovar escan, its events
; (wl_scan). wlan set, wlan clear: the network the board keeps (its name and its key, as on the ESP32; wl_join joins
; it). The frames of the network for programs: wl_call (api_wifi below), on which examples_internal/abelle/pico/inc/wifi.abel
; builds the functions of the ESP32 (inc/net.abel: DHCP, ARP, ping, DNS, UDP; inc/tcp.abel).
;
; The console gives: IO_BANK0, PADS_BANK0, the offsets of the registers of the SIO (SIO_IN, SIO_OUT_SET, SIO_OUT_CLR,
; SIO_OE_SET, SIO_OE_CLR: they differ between the RP2040 and the RP2350), VARS + V_WIFI (a word: 1 a W board, else
; 0), V_FSOK, STUBS (the variables of the WiFi behind its 256 bytes: WLV), tick_now (the microseconds in r0; changes
; r1), put_text (r0 the text), put_dec, put_nl, print_inline, skip_spaces, match_inline, find_entry, send_packet (r0
; the command, r1 the bytes, r2 their number).
;
; For the console:
;   wifi_detect     asks the WiFi chip once (at the start of the console), V_WIFI
;   wifi_name       r0 the name of the board ("Raspberry Pi Pico 2 W" ...), r1 its length: SYSINFO (CHIP_ID) tells
;                   the chip, V_WIFI the W
;   pk_board        the packet H: k and the name of the board
;   wifi_led        led(on) of the functions for programs: the LED of the board (GPIO 25; on a W GPIO 0 of the
;                   WiFi chip: its first call starts the chip when wlan on has not)
;   cmd_wlan        the command wlan [on | off | scan | set | clear] (r0 the rest of the line)
;   api_wifi        wl_call(op, a, b, c) of the functions for programs (+52): the WiFi for a program
;   wl_abort        a program stopped: CS of the WiFi chip high

WL_SIO          equ 0xd0000000
WL_SYSINFO      equ 0x40000000          ; +0 CHIP_ID: bits 27 .. 12 the part, 2 the RP2040, 4 the RP2350
WL_TRIES        equ 50                  ; asks, 5 ms apart: at most a quarter of a second
WL_PAD          equ 0x52                ; the pads: input on (IE), 4 mA, Schmitt trigger, no pulls, no isolation
WL_FUNC_SIO     equ 5

WLV             equ STUBS + 0x100       ; the variables of the WiFi (256 bytes):
WL_WIN          equ 0                   ;   the window of function 1 set last (bits 31 .. 15), -1 none
WL_STATE        equ 4                   ;   1: the firmware runs (wlan on)
WL_TXD          equ 8                   ;   the wait of half a clock (loops) while the console sends
WL_RXD          equ 12                  ;   ... while it reads
WL_FWLEN        equ 16                  ;   the bytes of the firmware
WL_TIME         equ 20                  ;   the microseconds its download took
WL_HT           equ 24                  ;   the milliseconds until the HT clock came
WL_NV           equ 28                  ;   the NVRAM (its bytes through XIP)
WL_NVLEN        equ 32                  ;   ... their number
WL_CLM          equ 36                  ;   the CLM data (through XIP)
WL_CLMLEN       equ 40                  ;   ... their bytes
WL_SEQ          equ 44                  ;   the number of the next packet to the chip (8 bits)
WL_SEQMAX       equ 48                  ;   ... the chip takes up to this one (its credit; not this one)
WL_ID           equ 52                  ;   the number of the last ioctl (16 bits)
WL_RESP         equ 56                  ;   the answer of the last ioctl (in WL_RX)
WL_RLEN         equ 60                  ;   ... its bytes
WL_NSEEN        equ 64                  ;   the BSSIDs in WL_SEEN (a scan)
WL_NETNUM       equ 68                  ;   the number of the record of the network (0: none)
WL_NETSEC       equ 72                  ;   the sector for the next record
WL_SECLEN       equ 76                  ;   the bytes of the password in WL_SECRET
WL_ECMD         equ 80                  ;   a join failed: the ioctl the firmware did not take (0: none)
WL_ESTAT        equ 84                  ;   ... its status
WL_ETEXT        equ 88                  ;   the text of the last error of wl_call (0: none)
WL_IP           equ 92                  ;   the IPv4 address of the board (wl_call 6; 0: none)
WL_BUSY         equ 96                  ;   1: the console or a program talks to the chip (wl_tick waits)
WL_RPUT         equ 100                 ;   the ring of the frames (WL_RING): the frames put in (wl_tick ...)
WL_RGET         equ 104                 ;   ... and the ones taken out (wifi_recv)
WL_MAC          equ 108                 ;   the MAC of the chip (6 bytes; read at each join)
WL_NARP         equ 116                 ;   the ARP requests the console answered (wl_answer)
WL_NPING        equ 120                 ;   ... the pings
WL_ESP          equ 200                 ;   1: the WiFi is an ESP8285 at UART0 with our firmware (esp_detect); the
;                                           words behind it up to 236: console_esp.asm (E_ there)
WL_SOUT         equ 236                 ;   a scan for a program (wl_call 11): its buffer (0: wlan scan shows lines)
WL_SMAX         equ 240                 ;   ... the records that fit into it
WL_SCNT         equ 244                 ;   ... the records put there (-1: the scan did not start)
WL_AUX          equ 176                 ;   +0 1: the WiFi at the start was tried (wl_auto), +4 millis of the last byte
WL_PB           equ 184                 ;   wl_pbkdf2_any: +0 the salt, +4 its length, +8 the key, +12 its length
WL_DIAG         equ 124                 ;   the events of the last join (wl_diag_event), 4 words: AUTH, ASSOC or
;                                           REASSOC, SET_SSID, PSK_SUP (bit 31 it came, the reason, the status)
WL_TX           equ DIRBUF + 0x1000     ; a packet to the chip (SDPCM 12, CDC 16, then up to 1040 bytes)
WL_DATA         equ WL_TX + 28          ; ... its data
WL_RX           equ DIRBUF + 0x1480     ; a packet from the chip (up to 2048 bytes)
WL_TXD_INIT     equ 1                   ; loops of 3 cycles at 48 MHz: the firmware in 0.6 s (20: 5.2 s)
WL_RXD_INIT     equ 4                   ; (1 works too; the reads are few)

wifi_detect:
    push {r4, r5, r6, r7, lr}
    ldr  r1, wl_lit_wlv
    movs r0, #0
    str  r0, [r1, #WL_STATE]
    str  r0, [r1, #WL_ETEXT]
    str  r0, [r1, #WL_IP]
    str  r0, [r1, #WL_BUSY]
    str  r0, [r1, #WL_RPUT]
    str  r0, [r1, #WL_RGET]
    str  r0, [r1, #WL_NARP]
    str  r0, [r1, #WL_NPING]
    ldr  r2, wl_lit_aux
    str  r0, [r2]                   ; the WiFi at the start not tried yet (wl_auto)
    str  r0, [r2, #4]
    ldr  r2, wl_lit_esp
    str  r0, [r2]                   ; no ESP8285 (yet)
    str  r0, [r2, #36]              ; WL_SOUT (WL_ESP + 36) 0: wlan scan shows lines (the RAM holds anything after
                                    ; power on: a scan wrote its records there once and the console stopped)
    movs r0, #WL_TXD_INIT
    str  r0, [r1, #WL_TXD]
    movs r0, #WL_RXD_INIT
    str  r0, [r1, #WL_RXD]
    bl   wl_power
    movs r7, #WL_TRIES
    movs r5, #0                     ; not a W (yet)
wd_try:
    ldr  r0, wl_lit_5ms
    bl   wl_wait
    bl   wl_read_test
    ldr  r2, wl_lit_beadfeed
    ldr  r3, wl_lit_feedbead
    cmp  r0, r2
    beq  wd_yes
    cmp  r0, r3
    beq  wd_yes
    cmp  r1, r2
    beq  wd_yes
    cmp  r1, r3
    beq  wd_yes
    subs r7, r7, #1
    bne  wd_try
    b    wd_end
wd_yes:
    movs r5, #1
wd_end:
    bl   wl_off
    ldr  r1, wl_lit_wifi
    str  r5, [r1]
    cmp  r5, #0
    beq  wd_esp
    bl   wl_tick_init               ; a W: SysTick for the frames (ARP, ping) while the board is in a network
wd_done:
    pop  {r4, r5, r6, r7, pc}
wd_esp:
    ldr  r1, wl_lit_sysinfo         ; no W chip: on an RP2040 the ESP8285 of the clones "Pico W-2023"?
    ldr  r0, [r1]
    lsls r0, r0, #4
    lsrs r0, r0, #16                ; the part: 2 the RP2040
    cmp  r0, #2
    bne  wd_done
    bl   esp_detect
    b    wd_done

; the pins of the WiFi chip to the SIO; the chip off for 20 ms, then on (the data line low while its power comes:
; gSPI), CS high, the clock low
wl_power:
    push {r6, lr}
    ldr  r6, wl_lit_sio
    ldr  r0, wl_lit_cs
    str  r0, [r6, #SIO_OUT_SET]     ; CS high (not selected)
    ldr  r0, wl_lit_on_clk_d
    str  r0, [r6, #SIO_OUT_CLR]     ; the power off, the clock low
    ldr  r0, wl_lit_all
    str  r0, [r6, #SIO_OE_SET]      ; the data low too: while the power comes, it makes the chip talk gSPI (not SDIO)
    ldr  r1, wl_lit_pads
    movs r0, #WL_PAD
    str  r0, [r1, #0x60]            ; GPIO 23 (the pads: 4 + 4 * n)
    str  r0, [r1, #0x64]            ; 24
    str  r0, [r1, #0x68]            ; 25
    str  r0, [r1, #0x78]            ; 29
    ldr  r1, wl_lit_io
    movs r0, #WL_FUNC_SIO
    str  r0, [r1, #0x3c]            ; GPIO 23_CTRL (IO_BANK0 + 4 + 8 * n, from + 0x80)
    str  r0, [r1, #0x44]            ; 24
    str  r0, [r1, #0x4c]            ; 25
    str  r0, [r1, #0x6c]            ; 29
    ldr  r0, wl_lit_20ms
    bl   wl_wait                    ; off for 20 ms (a program before may have left it on)
    ldr  r0, wl_lit_on
    str  r0, [r6, #SIO_OUT_SET]     ; the power on
    pop  {r6, pc}

; the WiFi chip off; data, CS and clock inputs (on a Pico the LED goes off)
wl_off:
    push {lr}
    bl   esp_mode                   ; the ESP8285: it leaves its network (it stays on)
    cmp  r0, #0
    beq  wof_cyw
    bl   esp_leave
wof_cyw:
    pop  {r0}
    mov  lr, r0
    ldr  r2, wl_lit_sio
    ldr  r0, wl_lit_on
    str  r0, [r2, #SIO_OUT_CLR]
    ldr  r0, wl_lit_d_cs_clk
    str  r0, [r2, #SIO_OE_CLR]
    ldr  r1, wl_lit_wlv
    movs r0, #0
    str  r0, [r1, #WL_STATE]
    str  r0, [r1, #WL_IP]           ; no address without the network
    bx   lr

; r0 the microseconds to wait (TIMER: tick_now)
wl_wait:
    push {r4, r5, lr}
    mov  r5, r0
    bl   tick_now
    mov  r4, r0
ww_loop:
    bl   tick_now
    subs r0, r0, r4
    cmp  r0, r5
    blo  ww_loop
    pop  {r4, r5, pc}

; about 0.2 microseconds at 48 MHz (half a clock of the SPI: some 2 MHz, the CYW43439 takes up to 50)
wl_half:
    movs r2, #4
wh_loop:
    subs r2, r2, #1
    bne  wh_loop
    bx   lr

; the register for tests: r0 the answer read before each rising edge of the clock, r1 the one read after it
wl_read_test:
    push {r4, r5, r6, r7, lr}
    ldr  r6, wl_lit_sio
    ldr  r5, wl_lit_clk
    ldr  r7, wl_lit_d
    ldr  r0, wl_lit_cs
    str  r0, [r6, #SIO_OUT_CLR]     ; CS low
    str  r7, [r6, #SIO_OE_SET]      ; the data: an output
    ldr  r4, wl_lit_cmd
    movs r3, #32
wr_out:
    lsls r4, r4, #1                 ; the next bit (the highest first) into C
    bcc  wr_zero
    str  r7, [r6, #SIO_OUT_SET]
    b    wr_clock
wr_zero:
    str  r7, [r6, #SIO_OUT_CLR]
wr_clock:
    bl   wl_half
    str  r5, [r6, #SIO_OUT_SET]     ; the rising edge: the WiFi chip takes the bit
    bl   wl_half
    str  r5, [r6, #SIO_OUT_CLR]
    subs r3, r3, #1
    bne  wr_out
    str  r7, [r6, #SIO_OE_CLR]      ; the data: an input, the chip answers
    movs r3, #32
    movs r0, #0                     ; read before the rising edge
    movs r1, #0                     ; ... and after it
    push {r0, r1}
wr_in:
    bl   wl_half
    ldr  r0, [r6, #SIO_IN]
    lsrs r0, r0, #24                ; GPIO 24
    movs r2, #1
    ands r0, r2
    ldr  r2, [sp]
    lsls r2, r2, #1
    orrs r2, r0
    str  r2, [sp]
    str  r5, [r6, #SIO_OUT_SET]     ; the rising edge
    bl   wl_half
    ldr  r0, [r6, #SIO_IN]
    lsrs r0, r0, #24
    movs r2, #1
    ands r0, r2
    ldr  r2, [sp, #4]
    lsls r2, r2, #1
    orrs r2, r0
    str  r2, [sp, #4]
    str  r5, [r6, #SIO_OUT_CLR]
    subs r3, r3, #1
    bne  wr_in
    ldr  r0, wl_lit_cs
    str  r0, [r6, #SIO_OUT_SET]     ; CS high
    pop  {r0, r1}
    pop  {r4, r5, r6, r7, pc}

; r0 the name of the board, r1 its length
wifi_name:
    ldr  r1, wl_lit_esp             ; the ESP8285 of the clones with our firmware answered (esp_detect; V_WIFI 1 too)
    ldr  r1, [r1]
    adr  r0, wl_name_esp
    cmp  r1, #0
    bne  wn_count
    ldr  r1, wl_lit_sysinfo
    ldr  r0, [r1]                   ; CHIP_ID
    lsls r0, r0, #4
    lsrs r0, r0, #16                ; the part (bits 27 .. 12)
    movs r2, #0                     ; the RP2040: the first two names
    cmp  r0, #4
    bne  wn_wifi
    movs r2, #2                     ; the RP2350: the other two
wn_wifi:
    ldr  r1, wl_lit_wifi
    ldr  r1, [r1]
    movs r3, #1
    ands r1, r3                     ; (bit 1: wifi_led has said its word)
    adds r2, r2, r1                 ; + 1 a W
    bne  wn_table
    ; an RP2040 without a WiFi chip: GPIO 1 (UART0 RX, its pull-up on) low means something drives it there: on the
    ; clones "Pico W-2023" the TX of an ESP8285, whose stock firmware keeps it low (a plain Pico, or one with a Debug
    ; Probe, reads high there)
    ldr  r1, wl_lit_sio
    ldr  r1, [r1, #4]               ; GPIO_IN
    movs r3, #2
    tst  r1, r3
    bne  wn_table
    adr  r0, wl_name_uart0
    b    wn_count
wn_table:
    lsls r2, r2, #5                 ; 32 bytes each
    adr  r0, wl_names
    adds r0, r0, r2
wn_count:
    movs r1, #0
wn_len:
    ldrb r2, [r0, r1]
    cmp  r2, #0
    beq  wn_end
    adds r1, r1, #1
    b    wn_len
wn_end:
    bx   lr

; H: the board
pk_board:
    push {lr}
    bl   wifi_name
    mov  r2, r1
    mov  r1, r0
    movs r0, #'k'
    bl   send_packet
    pop  {pc}

; the name of the board in the console (info, the hello)
put_board:
    push {lr}
    bl   wifi_name
    bl   put_text
    pop  {pc}

; led(on) for programs: the LED of the board on (r0 not 0) or off. The Pico and the Pico 2: GPIO 25 (its pad, the
; SIO, an output). The Pico W and the Pico 2 W have their LED at the WiFi chip (its GPIO 0), which drives it only with
; its firmware: the iovar gpioout. When the chip is off, the first call starts it (wlan_start, about a second); when
; that fails (or the firmware does not take gpioout), it says why once (V_WIFI bit 1). WL_BUSY meanwhile (wl_tick)
wifi_led:
    push {lr}
    bl   wl_busy_on
    bl   wled_inner
    bl   wl_busy_off
    pop  {pc}
wled_inner:
    push {r4, lr}
    mov  r4, r0
    ldr  r1, wl_lit_wifi
    ldr  r0, [r1]
    cmp  r0, #0
    beq  wled_pin
    bl   esp_mode                   ; the clones with the ESP8285: GPIO 25 as on a Pico
    cmp  r0, #0
    beq  wled_w0
wled_pin:
    ldr  r1, wl_lit_pads
    movs r0, #WL_PAD
    str  r0, [r1, #0x68]            ; GPIO 25
    ldr  r1, wl_lit_io
    movs r0, #WL_FUNC_SIO
    str  r0, [r1, #0x4c]
    ldr  r2, wl_lit_sio
    ldr  r0, wl_lit_cs              ; 1 << 25
    str  r0, [r2, #SIO_OE_SET]
    cmp  r4, #0
    beq  wled_off
    str  r0, [r2, #SIO_OUT_SET]
    pop  {r4, pc}
wled_off:
    str  r0, [r2, #SIO_OUT_CLR]
    pop  {r4, pc}
wled_w0:
    ldr  r1, wl_lit_wifi
    ldr  r0, [r1]
wled_w:
    ldr  r2, wl_lit_wlv
    ldr  r3, [r2, #WL_STATE]
    cmp  r3, #0
    bne  wled_set                   ; the firmware runs
    movs r2, #2
    tst  r0, r2
    bne  wled_done                  ; it failed before: not again
    bl   wlan_start
    cmp  r0, #0
    beq  wled_set
wled_fail:
    push {r0}
    ldr  r1, wl_lit_wifi
    ldr  r0, [r1]
    movs r2, #2
    orrs r0, r2
    str  r0, [r1]
    adr  r0, wl_led_text
    bl   put_text
    pop  {r0}
    bl   put_text
    bl   put_nl
wled_done:
    pop  {r4, pc}
wled_set:
    mov  r0, r4
    bl   wl_gpio_led
    cmp  r0, #0
    beq  wled_done
    ldr  r1, wl_lit_wifi            ; the firmware did not take it: said once
    ldr  r0, [r1]
    movs r2, #2
    tst  r0, r2
    bne  wled_done
    adr  r0, wl_e_gpio
    b    wled_fail

    align 4
wl_lit_sio:         dd WL_SIO
wl_lit_sysinfo:     dd WL_SYSINFO
wl_lit_wifi:        dd VARS + V_WIFI
wl_lit_wlv:         dd WLV
wl_lit_aux:         dd WLV + WL_AUX
wl_lit_esp:         dd WLV + WL_ESP
wl_lit_pads:        dd PADS_BANK0
wl_lit_io:          dd IO_BANK0 + 0x80
wl_lit_on:          dd 1 << 23
wl_lit_d:           dd 1 << 24
wl_lit_cs:          dd 1 << 25
wl_lit_clk:         dd 1 << 29
wl_lit_on_clk_d:    dd (1 << 23) | (1 << 29) | (1 << 24)
wl_lit_all:         dd (1 << 23) | (1 << 24) | (1 << 25) | (1 << 29)
wl_lit_d_cs_clk:    dd (1 << 24) | (1 << 25) | (1 << 29)
wl_lit_20ms:        dd 20000
wl_lit_5ms:         dd 5000
wl_lit_cmd:         dd 0xa0044000           ; read, counting up, function 0, address 0x14, 4 bytes; halves swapped
wl_lit_beadfeed:    dd 0xbeadfeed           ; 0xFEEDBEAD in halfwords
wl_lit_feedbead:    dd 0xfeedbead
    align 4
wl_led_text:
    db   'led(): the LED of this board hangs at its WiFi chip: ', 0
    align 4
wl_e_gpio:
    db   'its firmware did not take the command gpioout.', 0
    align 32
wl_names:
    db   'Raspberry Pi Pico', 0
    align 32
    db   'Raspberry Pi Pico W', 0
    align 32
    db   'Raspberry Pi Pico 2', 0
    align 32
    db   'Raspberry Pi Pico 2 W', 0
    align 32
wl_name_uart0:
    db   'Raspberry Pi Pico (an ESP8285 at UART0?)', 0
    align 4
wl_name_esp:
    db   'Raspberry Pi Pico (WiFi: ESP8285)', 0
    align 4

; ---------- gSPI: the words to the WiFi chip and from it (in 32-bit mode) ----------

; r0: its 32 bits to the WiFi chip, the highest first (the data line an output; CS as it is). Changes r0 .. r3
wl_tx32:
    push {r4, r5, r6, r7, lr}
    ldr  r6, wl2_sio
    ldr  r5, wl2_clk
    ldr  r7, wl2_d
    ldr  r4, wl2_wlv
    ldr  r4, [r4, #WL_TXD]
    str  r7, [r6, #SIO_OE_SET]
    movs r3, #32
wt_bit:
    lsls r0, r0, #1                 ; the next bit into C
    bcc  wt_zero
    str  r7, [r6, #SIO_OUT_SET]
    b    wt_half
wt_zero:
    str  r7, [r6, #SIO_OUT_CLR]
wt_half:
    mov  r2, r4
wt_d1:
    subs r2, r2, #1
    bne  wt_d1
    str  r5, [r6, #SIO_OUT_SET]     ; the rising edge: the chip takes the bit
    mov  r2, r4
wt_d2:
    subs r2, r2, #1
    bne  wt_d2
    str  r5, [r6, #SIO_OUT_CLR]
    subs r3, r3, #1
    bne  wt_bit
    pop  {r4, r5, r6, r7, pc}

; 32 bits from the WiFi chip into r0, each read before the rising edge (the data line an input). Changes r1 .. r3
wl_rx32:
    push {r4, r5, r6, lr}
    ldr  r6, wl2_sio
    ldr  r5, wl2_clk
    ldr  r4, wl2_wlv
    ldr  r4, [r4, #WL_RXD]
    movs r3, #32
    movs r0, #0
wx_bit:
    mov  r2, r4
wx_d1:
    subs r2, r2, #1
    bne  wx_d1
    ldr  r1, [r6, #SIO_IN]
    lsrs r1, r1, #25                ; GPIO 24 into C
    adcs r0, r0                     ; r0 * 2 + the bit
    str  r5, [r6, #SIO_OUT_SET]
    mov  r2, r4
wx_d2:
    subs r2, r2, #1
    bne  wx_d2
    str  r5, [r6, #SIO_OUT_CLR]
    subs r3, r3, #1
    bne  wx_bit
    pop  {r4, r5, r6, pc}

; a write: the command r0 and the word r1
wl_write:
    push {r4, r5, lr}
    mov  r4, r1
    ldr  r5, wl2_sio
    ldr  r1, wl2_cs
    str  r1, [r5, #SIO_OUT_CLR]     ; CS low
    bl   wl_tx32
    mov  r0, r4
    bl   wl_tx32
    ldr  r1, wl2_cs
    str  r1, [r5, #SIO_OUT_SET]     ; CS high
    pop  {r4, r5, pc}

; a read: the command r0, r1 words of padding, then the word in r0
wl_read:
    push {r4, r5, lr}
    mov  r4, r1
    ldr  r5, wl2_sio
    ldr  r1, wl2_cs
    str  r1, [r5, #SIO_OUT_CLR]
    bl   wl_tx32
    ldr  r1, wl2_d
    str  r1, [r5, #SIO_OE_CLR]      ; the data line an input: the chip answers
wrd_pad:
    cmp  r4, #0
    beq  wrd_data
    bl   wl_rx32
    subs r4, r4, #1
    b    wrd_pad
wrd_data:
    bl   wl_rx32
    ldr  r1, wl2_cs
    str  r1, [r5, #SIO_OUT_SET]
    pop  {r4, r5, pc}

; the clock register of the backplane (0x1000E of function 1): its byte in r0
wl_csr_read:
    push {lr}
    ldr  r0, wl2_csr_rd
    movs r1, #1
    bl   wl_read
    movs r1, #0xff
    ands r0, r1
    pop  {pc}

; ... the byte r0 into it
wl_csr_write:
    push {lr}
    mov  r1, r0
    ldr  r0, wl2_csr_wr
    bl   wl_write
    pop  {pc}

; the window of function 1 for the backplane address r0 (bits 31 .. 15; only when it changes). Keeps r0
wl_window:
    push {r4, r5, lr}
    mov  r4, r0
    lsrs r5, r0, #15
    lsls r5, r5, #15
    ldr  r1, wl2_wlv
    ldr  r0, [r1, #WL_WIN]
    cmp  r0, r5
    beq  wwi_done
    str  r5, [r1, #WL_WIN]
    lsrs r1, r5, #8
    movs r0, #0xff
    ands r1, r0
    ldr  r0, wl2_win_a
    bl   wl_write                   ; 0x1000A: bits 15 .. 8 (only bit 15)
    lsrs r1, r5, #16
    movs r0, #0xff
    ands r1, r0
    ldr  r0, wl2_win_b
    bl   wl_write                   ; 0x1000B: bits 23 .. 16
    lsrs r1, r5, #24
    ldr  r0, wl2_win_c
    bl   wl_write                   ; 0x1000C: bits 31 .. 24
wwi_done:
    mov  r0, r4
    pop  {r4, r5, pc}

; the command of function 1 for the backplane address r0 (its offset in the window), r1 bytes, r2 the flag of 4
; bytes (0x8000 or 0), r3 0x50000000 (read) or 0xD0000000 (write): into r0
wl_bp_cmd:
    lsls r0, r0, #17
    lsrs r0, r0, #17
    orrs r0, r2
    lsls r0, r0, #11
    orrs r0, r1
    orrs r0, r3
    bx   lr

; a word r1 to the backplane address r0
wl_bp_write32:
    push {r4, lr}
    mov  r4, r1
    bl   wl_window
    movs r1, #4
    movs r2, #1
    lsls r2, r2, #15
    ldr  r3, wl2_f1_wr
    bl   wl_bp_cmd
    mov  r1, r4
    bl   wl_write
    pop  {r4, pc}

; a byte r1 to the backplane address r0
wl_bp_write8:
    push {r4, lr}
    mov  r4, r1
    bl   wl_window
    movs r1, #1
    movs r2, #0
    ldr  r3, wl2_f1_wr
    bl   wl_bp_cmd
    mov  r1, r4
    bl   wl_write
    pop  {r4, pc}

; the word at the backplane address r0: r0
wl_bp_read32:
    push {lr}
    bl   wl_window
    movs r1, #4
    movs r2, #1
    lsls r2, r2, #15
    ldr  r3, wl2_f1_rd
    bl   wl_bp_cmd
    movs r1, #1
    bl   wl_read
    pop  {pc}

; the byte at the backplane address r0: r0
wl_bp_read8:
    push {lr}
    bl   wl_window
    movs r1, #1
    movs r2, #0
    ldr  r3, wl2_f1_rd
    bl   wl_bp_cmd
    movs r1, #1
    bl   wl_read
    movs r1, #0xff
    ands r0, r1
    pop  {pc}

    align 4
wl2_sio:            dd WL_SIO
wl2_wlv:            dd WLV
wl2_d:              dd 1 << 24
wl2_cs:             dd 1 << 25
wl2_clk:            dd 1 << 29
wl2_csr_rd:         dd 0x58007001           ; read, function 1, 0x1000E, 1 byte
wl2_csr_wr:         dd 0xd8007001           ; write ...
wl2_win_a:          dd 0xd8005001           ; write, function 1, 0x1000A, 1 byte
wl2_win_b:          dd 0xd8005801           ; ... 0x1000B
wl2_win_c:          dd 0xd8006001           ; ... 0x1000C
wl2_f1_rd:          dd 0x50000000           ; read, counting up, function 1
wl2_f1_wr:          dd 0xd0000000           ; write ...

; ---------- the backplane: the cores of the WiFi chip, a block into its RAM ----------

; r2 bytes (a multiple of 4) from r1 to the backplane address r0, in pieces of up to 64 bytes inside a window
wl_bp_block:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0                     ; the address
    mov  r5, r1                     ; the source
    mov  r7, r2                     ; the bytes left
wb_next:
    cmp  r7, #0
    beq  wb_done
    lsls r0, r4, #17
    lsrs r0, r0, #17
    movs r6, #1
    lsls r6, r6, #15
    subs r6, r6, r0                 ; left in the window
    cmp  r6, #64
    bls  wb_most
    movs r6, #64
wb_most:
    cmp  r6, r7
    bls  wb_piece
    mov  r6, r7
wb_piece:
    mov  r0, r4
    bl   wl_window
    mov  r1, r6
    movs r2, #0
    ldr  r3, wl3_f1_wr
    bl   wl_bp_cmd
    adds r4, r4, r6
    subs r7, r7, r6
    ldr  r1, wl3_sio
    ldr  r2, wl3_cs
    str  r2, [r1, #SIO_OUT_CLR]     ; CS low
    bl   wl_tx32
wb_word:
    ldr  r0, [r5]
    adds r5, r5, #4
    bl   wl_tx32
    subs r6, r6, #4
    bne  wb_word
    ldr  r1, wl3_sio
    ldr  r2, wl3_cs
    str  r2, [r1, #SIO_OUT_SET]     ; CS high
    b    wb_next
wb_done:
    pop  {r4, r5, r6, r7, pc}

; the core of wrapper r0 off (held in reset), as core_disable of the drivers
wl_core_off:
    push {r4, lr}
    mov  r4, r0
    ldr  r0, wl3_resetctrl
    adds r0, r0, r4
    bl   wl_bp_read8
    ldr  r0, wl3_resetctrl
    adds r0, r0, r4
    bl   wl_bp_read8
    movs r1, #1
    tst  r0, r1
    bne  wco_done                   ; in reset already
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    movs r1, #0
    bl   wl_bp_write8
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    bl   wl_bp_read8
    ldr  r0, wl3_1ms
    bl   wl_wait
    ldr  r0, wl3_resetctrl
    adds r0, r0, r4
    movs r1, #1
    bl   wl_bp_write8
    ldr  r0, wl3_resetctrl
    adds r0, r0, r4
    bl   wl_bp_read8
wco_done:
    pop  {r4, pc}

; the core of wrapper r0 off and on again: its clock on, out of reset
wl_core_reset:
    push {r4, lr}
    mov  r4, r0
    bl   wl_core_off
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    movs r1, #3                     ; FGC | CLOCK_EN
    bl   wl_bp_write8
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    bl   wl_bp_read8
    ldr  r0, wl3_resetctrl
    adds r0, r0, r4
    movs r1, #0
    bl   wl_bp_write8
    ldr  r0, wl3_1ms
    bl   wl_wait
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    movs r1, #1                     ; CLOCK_EN
    bl   wl_bp_write8
    ldr  r0, wl3_ioctrl
    adds r0, r0, r4
    bl   wl_bp_read8
    ldr  r0, wl3_1ms
    bl   wl_wait
    pop  {r4, pc}

; the file named r0 (a text) in the directory: r0 its bytes (through XIP), r1 its length; r0 = 0 when it is not there
wl_file:
    push {r4, lr}
    mov  r4, r0
    ldr  r1, wl3_vars
    ldr  r0, [r1, #V_FSOK]
    cmp  r0, #0
    beq  wf_done
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  wf_done
    ldr  r1, [r0, #24]              ; the length
    ldr  r0, [r0, #20]              ; the first sector
    lsls r0, r0, #12
    ldr  r2, wl3_flash
    adds r0, r0, r2
wf_done:
    pop  {r4, pc}

    align 4
wl3_sio:            dd WL_SIO
wl3_cs:             dd 1 << 25
wl3_f1_wr:          dd 0xd0000000
wl3_ioctrl:         dd 0x408
wl3_resetctrl:      dd 0x800
wl3_1ms:            dd 1000
wl3_vars:           dd VARS
wl3_flash:          dd 0x10000000

; ---------- wlan on: the WiFi chip with its firmware ----------

; r0 0 when the firmware runs, else the text of what went wrong (the chip off then)
wlan_start:
    push {r4, r5, r6, r7, lr}
    bl   esp_mode                   ; the ESP8285: its firmware runs, it answers a ping (esp_start)
    cmp  r0, #0
    beq  ws_cyw
    bl   esp_start
    pop  {r4, r5, r6, r7, pc}
ws_cyw:
    adr  r0, wl_fw_name
    bl   wl_file
    cmp  r0, #0
    beq  ws_nofile
    mov  r6, r0                     ; the firmware
    mov  r7, r1                     ; its length
    adr  r0, wl_nv_name
    bl   wl_file
    cmp  r0, #0
    beq  ws_nofile
    ldr  r4, wl4_wlv
    str  r0, [r4, #WL_NV]
    str  r1, [r4, #WL_NVLEN]
    str  r7, [r4, #WL_FWLEN]
    adr  r0, wl_clm_name
    bl   wl_file
    cmp  r0, #0
    beq  ws_nofile
    ldr  r4, wl4_wlv
    str  r0, [r4, #WL_CLM]
    str  r1, [r4, #WL_CLMLEN]
    movs r0, #0
    mvns r0, r0
    str  r0, [r4, #WL_WIN]          ; no window yet
    bl   wl_power
    ldr  r0, wl4_50ms
    bl   wl_wait
    ; the test register in halfwords until it is 0xFEEDBEAD (up to 50 times, 5 ms apart)
    movs r5, #50
ws_ask:
    ldr  r0, wl4_test16
    movs r1, #0
    bl   wl_read
    ldr  r1, wl4_beadfeed
    cmp  r0, r1
    beq  ws_words
    ldr  r0, wl4_5ms
    bl   wl_wait
    subs r5, r5, #1
    bne  ws_ask
    adr  r0, wl_e_answer
    b    ws_fail
ws_nofile:
    adr  r0, wl_e_files
    b    ws_fail
ws_words:
    ; 32-bit words: register 0 = 0xA1, written in halfwords
    ldr  r0, wl4_mode_cmd
    ldr  r1, wl4_mode
    bl   wl_write
    ldr  r0, wl4_test32
    movs r1, #0
    bl   wl_read
    ldr  r1, wl4_feedbead
    cmp  r0, r1
    beq  ws_alp
    adr  r0, wl_e_words
    b    ws_fail
ws_alp:
    bl   wl_irq_init
    ; the ALP clock of the backplane
    movs r0, #8
    bl   wl_csr_write
    ldr  r0, wl4_10ms
    bl   wl_wait
    bl   wl_csr_read
    movs r1, #0x40
    tst  r0, r1
    bne  ws_cores
    adr  r0, wl_e_alp
    b    ws_fail
ws_cores:
    movs r0, #0
    bl   wl_csr_write
    ldr  r0, wl4_wlan_wrap
    bl   wl_core_off
    ldr  r0, wl4_sram_wrap
    bl   wl_core_reset
    ldr  r0, wl4_sram_10
    movs r1, #3
    bl   wl_bp_write32
    ldr  r0, wl4_sram_44
    movs r1, #0
    bl   wl_bp_write32
    ; the firmware to 0 of its RAM
    bl   tick_now
    mov  r5, r0
    movs r0, #0
    mov  r1, r6
    adds r2, r7, #3
    lsrs r2, r2, #2
    lsls r2, r2, #2
    bl   wl_bp_block
    bl   tick_now
    subs r0, r0, r5
    ldr  r4, wl4_wlv
    str  r0, [r4, #WL_TIME]
    ; its first and its last word read back
    movs r0, #0
    bl   wl_bp_read32
    ldr  r1, [r6]
    cmp  r0, r1
    bne  ws_efw
    adds r5, r7, #3
    lsrs r5, r5, #2
    lsls r5, r5, #2
    subs r5, r5, #4
    mov  r0, r5
    bl   wl_bp_read32
    ldr  r1, [r6, r5]
    cmp  r0, r1
    beq  ws_nvram
ws_efw:
    adr  r0, wl_e_fw
    b    ws_fail
ws_nvram:
    ; the NVRAM at the end of its RAM, before the last word: its length in words n as (~n << 16) | n
    ldr  r4, wl4_wlv
    ldr  r1, [r4, #WL_NV]
    ldr  r2, [r4, #WL_NVLEN]
    adds r2, r2, #3
    lsrs r2, r2, #2
    lsls r2, r2, #2
    mov  r5, r2
    ldr  r0, wl4_ram_last
    subs r0, r0, r2
    bl   wl_bp_block
    lsrs r1, r5, #2
    mvns r0, r1
    lsls r0, r0, #16
    orrs r1, r0
    ldr  r0, wl4_ram_last
    bl   wl_bp_write32
    ; its core out of reset: the firmware runs, and it switches on the HT clock (up to a second)
    ldr  r0, wl4_wlan_wrap
    bl   wl_core_reset
    movs r5, #0
ws_ht:
    ldr  r0, wl4_10ms
    bl   wl_wait
    adds r5, r5, #10
    bl   wl_csr_read
    movs r1, #0x80
    tst  r0, r1
    bne  ws_runs
    ldr  r1, wl4_1000
    cmp  r5, r1
    blo  ws_ht
    adr  r0, wl_e_ht
    b    ws_fail
ws_runs:
    ldr  r4, wl4_wlv
    str  r5, [r4, #WL_HT]
    bl   wl_bus_up                  ; function 2, the CLM data, the first iovars
    cmp  r0, #0
    bne  ws_fail
    ldr  r4, wl4_wlv
    movs r0, #1
    str  r0, [r4, #WL_STATE]
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}
ws_fail:
    mov  r4, r0
    bl   wl_off
    mov  r0, r4
    pop  {r4, r5, r6, r7, pc}

    align 4
wl4_wlv:            dd WLV
wl4_50ms:           dd 50000
wl4_10ms:           dd 10000
wl4_5ms:            dd 5000
wl4_1000:           dd 1000
wl4_test16:         dd 0xa0044000           ; read the test register (0x14), in halfwords
wl4_beadfeed:       dd 0xbeadfeed
wl4_test32:         dd 0x4000a004           ; ... in words
wl4_feedbead:       dd 0xfeedbead
wl4_mode_cmd:       dd 0x0004c000           ; write register 0 of function 0, 4 bytes (0xC0000004), in halfwords
wl4_mode:           dd 0x00a10000           ; 0xA1: words of 32 bits, the interrupt high active, wake up
wl4_wlan_wrap:      dd 0x18103000           ; the wrapper of the Arm core of the WiFi chip
wl4_sram_wrap:      dd 0x18104000           ; ... of its RAM (SOCSRAM)
wl4_sram_10:        dd 0x18004010           ; SOCSRAM: bank index
wl4_sram_44:        dd 0x18004044           ; ... bank PDA
wl4_ram_last:       dd 0x80000 - 4          ; the last word of its RAM (512 KB)
    align 4
wl_fw_name:
    db   '43439A0.bin', 0
    align 4
wl_nv_name:
    db   'nvram_rp2040.bin', 0
    align 4
wl_clm_name:
    db   '43439A0_clm.bin', 0
    align 4
wl_e_files:
    db   'The files 43439A0.bin, 43439A0_clm.bin and nvram_rp2040.bin are not on the board (Board Manager: Prepare '
    db   'Board puts them there).', 0
    align 4
wl_e_answer:
    db   'The WiFi chip does not answer.', 0
    align 4
wl_e_words:
    db   'The WiFi chip did not take the words of 32 bits.', 0
    align 4
wl_e_alp:
    db   'The backplane of the WiFi chip has no clock (ALP).', 0
    align 4
wl_e_fw:
    db   'The firmware did not arrive in the RAM of the WiFi chip.', 0
    align 4
wl_e_ht:
    db   'The firmware of the WiFi chip did not start (no HT clock).', 0
    align 4

; ---------- function 2: the packets to the firmware and from it (SDPCM, ioctl) ----------
;
; A packet over function 2 (its length in the command, whole words): the SDPCM header (12 bytes: the length and its
; complement, the number of the packet, the channel (0 control, 1 events, 2 data), the length of the header, the credit
; of the chip: the number up to which it takes packets), then on channel 0 the CDC header (16 bytes: the command, the
; length of its data, the flags (0 get, 2 set; the interface << 12), its number, its status) and the data. The answer
; has the same number. An iovar is the command 262 (get) or 263 (set) with its name, a 0 and the value as its data.
; The status register of function 0 (0x8) tells when a packet waits: bit 8, its length in bits 19 .. 9.

; the bus interrupts: the error bits cleared (0x04 of function 0), a selection on (0x06), as the drivers do
wl_irq_init:
    push {lr}
    ldr  r0, wl6_irq_cmd
    movs r1, #0x99                  ; data unavailable, command error, data error, F1 overflow
    bl   wl_write
    ldr  r0, wl6_irqen_cmd
    movs r1, #0xbe                  ; ... and F2/F3 FIFO underflow and overflow, F2 packet available
    bl   wl_write
    pop  {pc}

; after the HT clock: function 2 ready, the pulls off, the HT clock asked, the CLM data, txglom 0, apsta 1. r0 0, else
; the text of what went wrong
wl_bus_up:
    push {r4, lr}
    ldr  r0, wl6_sdio_mask
    movs r1, #0xf0                  ; I_HMB_SW_MASK
    bl   wl_bp_write32
    ldr  r0, wl6_irqen_cmd
    movs r1, #0x20                  ; F2 packet available
    bl   wl_write
    ldr  r0, wl6_wmark_cmd
    movs r1, #0x20                  ; the watermark of function 2 (SPI)
    bl   wl_write
    bl   tick_now
    mov  r4, r0
wbu_f2:
    ldr  r0, wl6_status_cmd
    movs r1, #0
    bl   wl_read
    movs r1, #0x20                  ; F2 RX ready
    tst  r0, r1
    bne  wbu_ready
    bl   tick_now
    subs r0, r0, r4
    ldr  r1, wl6_1s
    cmp  r0, r1
    blo  wbu_f2
    adr  r0, wl_e_f2
    pop  {r4, pc}
wbu_ready:
    ldr  r0, wl6_pull_wr
    movs r1, #0
    bl   wl_write                   ; the pulls of the pads off
    ldr  r0, wl6_pull_rd
    movs r1, #1
    bl   wl_read
    movs r0, #0x10
    bl   wl_csr_write               ; HT asked
    bl   tick_now
    mov  r4, r0
wbu_ht:
    bl   wl_csr_read
    movs r1, #0x80
    tst  r0, r1
    bne  wbu_packets
    bl   tick_now
    subs r0, r0, r4
    ldr  r1, wl6_1s
    cmp  r0, r1
    blo  wbu_ht
    adr  r0, wl_e_ht2
    pop  {r4, pc}
wbu_packets:
    ldr  r4, wl6_wlv
    movs r0, #0
    str  r0, [r4, #WL_SEQ]
    str  r0, [r4, #WL_ID]
    movs r0, #1
    str  r0, [r4, #WL_SEQMAX]       ; the chip takes one packet before it says more
    bl   wl_clm_load
    cmp  r0, #0
    bne  wbu_end
    adr  r0, wl_n_txglom
    movs r1, #0
    bl   wl_set_u32
    cmp  r0, #0
    bne  wbu_ioctl
    adr  r0, wl_n_apsta
    movs r1, #1
    bl   wl_set_u32
    cmp  r0, #0
    bne  wbu_ioctl
    bl   wl_events_up               ; the events wanted, the interface up
    cmp  r0, #0
    bne  wbu_ioctl
wbu_end:
    pop  {r4, pc}
wbu_ioctl:
    adr  r0, wl_e_ioctl
    pop  {r4, pc}

; the CLM data (the channels and the power per country) into the firmware: the iovar clmload with a header (flags
; 0x1006: begin, end, the version of the handler; type 2; the length; no CRC) and the bytes (one piece: up to 1024),
; then clmload_status 0. r0 0, else the text of what went wrong
wl_clm_load:
    push {r4, r5, r6, lr}
    ldr  r4, wl6_data
    ldr  r5, wl6_wlv
    ldr  r6, [r5, #WL_CLMLEN]
    ldr  r0, wl6_1024
    cmp  r6, r0
    bhi  wcl_err
    adr  r0, wl_n_clmload
    mov  r1, r4
    bl   wl_copy_name               ; 8 bytes: the header at +8 is a whole word
    ldr  r0, wl6_clm_flags
    str  r0, [r4, #8]
    str  r6, [r4, #12]
    movs r0, #0
    str  r0, [r4, #16]
    mov  r0, r4
    adds r0, r0, #20
    ldr  r1, [r5, #WL_CLM]
    mov  r2, r6
    bl   wl_memcpy
    ldr  r0, wl6_setvar
    movs r1, #2
    mov  r2, r6
    adds r2, r2, #20
    bl   wl_ioctl
    cmp  r0, #0
    bne  wcl_err
    adr  r0, wl_n_clmstatus
    bl   wl_get_u32
    cmp  r0, #0
    bne  wcl_err
    cmp  r1, #0
    bne  wcl_err
    movs r0, #0
    pop  {r4, r5, r6, pc}
wcl_err:
    adr  r0, wl_e_clm
    pop  {r4, r5, r6, pc}

    align 4
wl6_wlv:            dd WLV
wl6_data:           dd WL_DATA
wl6_1s:             dd 1000000
wl6_1024:           dd 1024
wl6_setvar:         dd 263
wl6_clm_flags:      dd 0x00021006           ; flags 0x1006, type 2 (CLM)
wl6_irq_cmd:        dd 0xc0002001           ; write function 0, 0x04, 1 byte
wl6_irqen_cmd:      dd 0xc0003002           ; ... 0x06, 2 bytes
wl6_status_cmd:     dd 0x40004004           ; read function 0, 0x08, 4 bytes
wl6_wmark_cmd:      dd 0xd8004001           ; write function 1, 0x10008, 1 byte
wl6_pull_wr:        dd 0xd8007801           ; ... 0x1000F
wl6_pull_rd:        dd 0x58007801           ; read function 1, 0x1000F
wl6_sdio_mask:      dd 0x18002024           ; the SDIO core: SDIO_INT_HOST_MASK
    align 4
wl_n_clmload:
    db   'clmload', 0
    align 4
wl_n_clmstatus:
    db   'clmload_status', 0
    align 4
wl_n_txglom:
    db   'bus:txglom', 0
    align 4
wl_n_apsta:
    db   'apsta', 0
    align 4
wl_e_f2:
    db   'The function 2 of the WiFi chip did not get ready.', 0
    align 4
wl_e_ht2:
    db   'The WiFi chip did not keep its HT clock.', 0
    align 4
wl_e_ioctl:
    db   'The firmware of the WiFi chip did not answer a command.', 0
    align 4
wl_e_clm:
    db   'The firmware of the WiFi chip did not take its CLM data (43439A0_clm.bin).', 0
    align 4

; the text r0 with its 0 to r1: r0 its bytes with the 0
wl_copy_name:
    movs r2, #0
wcn_next:
    ldrb r3, [r0, r2]
    strb r3, [r1, r2]
    adds r2, r2, #1
    cmp  r3, #0
    bne  wcn_next
    mov  r0, r2
    bx   lr

; r2 bytes from r1 to r0
wl_memcpy:
    cmp  r2, #0
    beq  wmc_done
wmc_next:
    ldrb r3, [r1]
    strb r3, [r0]
    adds r0, r0, #1
    adds r1, r1, #1
    subs r2, r2, #1
    bne  wmc_next
wmc_done:
    bx   lr

; the word r1 at r0, byte by byte (little endian; r0 need not be aligned)
wl_put32:
    strb r1, [r0]
    lsrs r1, r1, #8
    strb r1, [r0, #1]
    lsrs r1, r1, #8
    strb r1, [r0, #2]
    lsrs r1, r1, #8
    strb r1, [r0, #3]
    bx   lr

; the word at r0, byte by byte: r0
wl_get32:
    ldrb r1, [r0, #3]
    ldrb r2, [r0, #2]
    lsls r1, r1, #8
    orrs r1, r2
    ldrb r2, [r0, #1]
    lsls r1, r1, #8
    orrs r1, r2
    ldrb r2, [r0]
    lsls r1, r1, #8
    orrs r1, r2
    mov  r0, r1
    bx   lr

; the iovar named r0 = the word r1: r0 0, else the status (-1: no answer)
wl_set_u32:
    push {r4, r5, lr}
    mov  r5, r1
    ldr  r1, wl7_data
    bl   wl_copy_name
    mov  r4, r0
    ldr  r0, wl7_data
    adds r0, r0, r4
    mov  r1, r5
    bl   wl_put32
    ldr  r0, wl7_setvar
    movs r1, #2
    adds r2, r4, #4
    bl   wl_ioctl
    pop  {r4, r5, pc}

; the iovar named r0 = the words r1 and r2: r0 0, else the status
wl_set_u32x2:
    push {r4, r5, r6, lr}
    mov  r5, r1
    mov  r6, r2
    ldr  r1, wl7_data
    bl   wl_copy_name
    mov  r4, r0
    ldr  r0, wl7_data
    adds r0, r0, r4
    mov  r1, r5
    bl   wl_put32
    ldr  r0, wl7_data
    adds r0, r0, r4
    adds r0, r0, #4
    mov  r1, r6
    bl   wl_put32
    ldr  r0, wl7_setvar
    movs r1, #2
    mov  r2, r4
    adds r2, r2, #8
    bl   wl_ioctl
    pop  {r4, r5, r6, pc}

; the iovar named r0: r0 0 and r1 its word, else r0 the status
wl_get_u32:
    push {r4, lr}
    ldr  r1, wl7_data
    bl   wl_copy_name
    mov  r2, r0
    cmp  r2, #4
    bhs  wgu_len
    movs r2, #4
wgu_len:
    ldr  r0, wl7_getvar
    movs r1, #0
    bl   wl_ioctl
    cmp  r0, #0
    bne  wgu_done
    ldr  r4, wl7_wlv
    ldr  r0, [r4, #WL_RESP]
    bl   wl_get32
    mov  r1, r0
    movs r0, #0
wgu_done:
    pop  {r4, pc}

; the LED of a W (GPIO 0 of the WiFi chip) on (r0 not 0) or off: gpioout (mask 1, value)
wl_gpio_led:
    push {lr}
    movs r2, #0
    cmp  r0, #0
    beq  wgl_set
    movs r2, #1
wgl_set:
    adr  r0, wl_n_gpioout
    movs r1, #1
    bl   wl_set_u32x2
    pop  {pc}

    align 4
wl7_wlv:            dd WLV
wl7_data:           dd WL_DATA
wl7_setvar:         dd 263
wl7_getvar:         dd 262
wl_n_gpioout:
    db   'gpioout', 0
    align 4

; an ioctl: the command r0, the kind r1 (0 get, 2 set), r2 bytes of data at WL_DATA. Waits (up to a second each) for
; the credit of the chip and for the answer. r0 0 (the answer: WL_RESP, WL_RLEN), else its status (-1: none came)
wl_ioctl:
    push {r4, r5, r6, r7, lr}
    mov  r5, r0
    mov  r6, r1
    mov  r7, r2
    bl   tick_now
    mov  r4, r0
wi_credit:
    ldr  r3, wl8_wlv
    ldr  r0, [r3, #WL_SEQMAX]
    ldr  r1, [r3, #WL_SEQ]
    subs r0, r0, r1
    movs r2, #0xff
    ands r0, r2
    cmp  r0, #0
    beq  wi_wait
    cmp  r0, #0x80
    blo  wi_send                    ; 1 .. 127 ahead: the chip takes it
wi_wait:
    bl   wl_poll
    bl   tick_now
    subs r0, r0, r4
    ldr  r1, wl8_1s
    cmp  r0, r1
    blo  wi_credit
    b    wi_none
wi_send:
    ldr  r4, wl8_tx
    mov  r0, r7
    adds r0, r0, #28                ; the length of the packet
    strh r0, [r4]
    mvns r1, r0
    strh r1, [r4, #2]
    ldr  r3, wl8_wlv
    ldr  r1, [r3, #WL_SEQ]
    strb r1, [r4, #4]
    adds r1, r1, #1
    movs r2, #0xff
    ands r1, r2
    str  r1, [r3, #WL_SEQ]
    movs r1, #0
    strb r1, [r4, #5]               ; channel 0: control
    strb r1, [r4, #6]
    movs r1, #12
    strb r1, [r4, #7]               ; the length of the header
    movs r1, #0
    str  r1, [r4, #8]
    str  r5, [r4, #12]              ; CDC: the command
    str  r7, [r4, #16]              ; ... the length of the data
    strh r6, [r4, #20]              ; ... the flags
    ldr  r1, [r3, #WL_ID]
    adds r1, r1, #1
    lsls r1, r1, #16
    lsrs r1, r1, #16
    str  r1, [r3, #WL_ID]
    strh r1, [r4, #22]              ; ... its number
    movs r1, #0
    str  r1, [r4, #24]              ; ... the status
    adds r0, r0, #3
    lsrs r7, r0, #2                 ; the words
    lsls r0, r7, #2
    ldr  r1, wl8_f2_wr
    orrs r0, r1
    ldr  r1, wl8_sio
    ldr  r2, wl8_cs
    str  r2, [r1, #SIO_OUT_CLR]     ; CS low
    bl   wl_tx32
wi_word:
    ldr  r0, [r4]
    adds r4, r4, #4
    bl   wl_tx32
    subs r7, r7, #1
    bne  wi_word
    ldr  r1, wl8_sio
    ldr  r2, wl8_cs
    str  r2, [r1, #SIO_OUT_SET]     ; CS high
    bl   tick_now
    mov  r4, r0
wi_answer:
    bl   wl_poll
    cmp  r0, #0
    beq  wi_later
    ldr  r0, wl8_rx
    ldrb r1, [r0, #5]
    movs r2, #0x0f
    ands r1, r2
    cmp  r1, #0
    bne  wi_later                   ; an event or data: not the answer
    ldrb r1, [r0, #7]
    adds r5, r0, r1                 ; its CDC header
    ldrb r1, [r5, #10]
    ldrb r2, [r5, #11]
    lsls r2, r2, #8
    orrs r1, r2
    ldr  r3, wl8_wlv
    ldr  r2, [r3, #WL_ID]
    cmp  r1, r2
    bne  wi_later
    adds r0, r5, #4
    bl   wl_get32
    ldr  r3, wl8_wlv
    str  r0, [r3, #WL_RLEN]
    mov  r0, r5
    adds r0, r0, #16
    str  r0, [r3, #WL_RESP]
    adds r0, r5, #6
    adds r0, r0, #6
    bl   wl_get32                   ; its status
    pop  {r4, r5, r6, r7, pc}
wi_later:
    bl   tick_now
    subs r0, r0, r4
    ldr  r1, wl8_1s
    cmp  r0, r1
    blo  wi_answer
wi_none:
    movs r0, #0
    mvns r0, r0
    pop  {r4, r5, r6, r7, pc}

; a packet of the chip into WL_RX, when one waits (the status register): r0 1, else 0. Takes its credit (channels 0
; .. 2), as the drivers: a credit more than 0x40 ahead counts as 2 ahead
wl_poll:
    push {r4, r5, r6, lr}
    ldr  r0, wl8_status
    movs r1, #0
    bl   wl_read
    movs r1, #1
    lsls r1, r1, #8
    tst  r0, r1
    beq  wp_none
    lsls r0, r0, #12
    lsrs r5, r0, #21                ; its length (bits 19 .. 9)
    beq  wp_none
    ldr  r1, wl8_f2_rd
    mov  r0, r5
    orrs r0, r1
    ldr  r1, wl8_sio
    ldr  r2, wl8_cs
    str  r2, [r1, #SIO_OUT_CLR]
    bl   wl_tx32
    ldr  r1, wl8_sio
    ldr  r2, wl8_d
    str  r2, [r1, #SIO_OE_CLR]      ; the data line an input
    adds r5, r5, #3
    lsrs r5, r5, #2
    ldr  r4, wl8_rx
wp_word:
    bl   wl_rx32
    str  r0, [r4]
    adds r4, r4, #4
    subs r5, r5, #1
    bne  wp_word
    ldr  r1, wl8_sio
    ldr  r2, wl8_cs
    str  r2, [r1, #SIO_OUT_SET]
    ldr  r4, wl8_rx
    ldrb r0, [r4, #5]
    movs r1, #0x0f
    ands r0, r1
    cmp  r0, #3
    bhs  wp_got
    ldrb r0, [r4, #9]               ; the credit
    ldr  r3, wl8_wlv
    ldr  r1, [r3, #WL_SEQ]
    subs r2, r0, r1
    movs r6, #0xff
    ands r2, r6
    cmp  r2, #0x40
    bls  wp_take
    adds r0, r1, #2
    ands r0, r6
wp_take:
    str  r0, [r3, #WL_SEQMAX]
wp_got:
    movs r0, #1
    pop  {r4, r5, r6, pc}
wp_none:
    movs r0, #0
    pop  {r4, r5, r6, pc}

    align 4
wl8_wlv:            dd WLV
wl8_tx:             dd WL_TX
wl8_rx:             dd WL_RX
wl8_1s:             dd 1000000
wl8_sio:            dd WL_SIO
wl8_cs:             dd 1 << 25
wl8_d:              dd 1 << 24
wl8_f2_wr:          dd 0xe0000000           ; write, counting up, function 2
wl8_f2_rd:          dd 0x60000000           ; read ...
wl8_status:         dd 0x40004004           ; read function 0, 0x08 (the status), 4 bytes

; ---------- the events of the firmware, the scan ----------
;
; An event comes on channel 1: behind the SDPCM header the BDC header (4 bytes; its byte 3: the words of more header
; behind it), then an Ethernet frame of the type 0x886C: 14 bytes, the event header (10), the message (48: its type at
; +14 of it, its status at +18, both big endian) and its data. ESCAN_RESULT (69): status 8 a result (the data: 12
; bytes of head, then the BSS info: the BSSID at +8, the capability at +16 (bit 4: secured), the length of the name
; at +18, the name at +19, the chanspec at +72 (the channel in its low byte), the RSSI at +78), status 0 the end.

WL_SEEN         equ DIRBUF + 0x1C80     ; the BSSIDs shown by a scan (32 of 6 bytes)
WL_SEEN_MAX     equ 32

; as the drivers before UP: the country XX (the world: country, rev -1), 100 ms, SET_ANTDIV 0 (the antenna of the
; board), ampdu_ba_wsize 8, ampdu_mpdu 4, 100 ms (without them a join right after the start failed now and then).
; Then the events the console takes (bsscfg:event_msgs: the interface 0, then a bit per event: SET_SSID 0, JOIN 1,
; AUTH 3, DEAUTH 5 and 6, ASSOC 7, REASSOC 9, DISASSOC 11 and 12, LINK 16, PSK_SUP 46, ESCAN_RESULT 69), then the
; ioctl UP (2). r0 0,
; else the status
wl_events_up:
    push {r4, lr}
    adr  r0, wl_n_country
    ldr  r1, wl9_data
    bl   wl_copy_name
    mov  r4, r0
    ldr  r0, wl9_data
    adds r0, r0, r4                 ; abbrev "XX", rev -1, code "XX"
    movs r1, #12
    bl   wl_memset0
    ldr  r1, wl9_data
    adds r1, r1, r4
    movs r0, #'X'
    strb r0, [r1]
    strb r0, [r1, #1]
    strb r0, [r1, #8]
    strb r0, [r1, #9]
    movs r0, #0xff
    strb r0, [r1, #4]
    strb r0, [r1, #5]
    strb r0, [r1, #6]
    strb r0, [r1, #7]
    ldr  r0, wl9_setvar
    movs r1, #2
    mov  r2, r4
    adds r2, r2, #12
    bl   wl_ioctl
    cmp  r0, #0
    bne  weu_done
    ldr  r0, wl9_100ms
    bl   wl_wait
    movs r0, #64                    ; SET_ANTDIV
    movs r1, #0
    bl   wl_ioctl_u32
    adr  r0, wl_n_bawsize
    movs r1, #8
    bl   wl_set_u32
    adr  r0, wl_n_mpdu
    movs r1, #4
    bl   wl_set_u32
    adr  r0, wl_n_mcast             ; mcast_list: one address, the MAC of mDNS (without it the chip drops the
    ldr  r1, wl9_data               ; questions to 224.0.0.251: name.local only from the cache of the PC; the
    bl   wl_copy_name               ; drivers set it as cyw43_wifi_update_multicast_filter does)
    mov  r4, r0
    ldr  r0, wl9_data
    adds r0, r0, r4
    adr  r1, wl_mcast_val
    movs r2, #10
    bl   wl_memcpy
    ldr  r0, wl9_setvar
    movs r1, #2
    mov  r2, r4
    adds r2, r2, #10
    bl   wl_ioctl
    ldr  r0, wl9_100ms
    bl   wl_wait
    adr  r0, wl_n_events
    ldr  r1, wl9_data
    bl   wl_copy_name
    mov  r4, r0
    ldr  r0, wl9_data
    adds r0, r0, r4
    movs r1, #28
    bl   wl_memset0
    ldr  r1, wl9_data
    adds r1, r1, r4                 ; the mask behind the interface (4 bytes)
    movs r0, #0xeb
    strb r0, [r1, #4]               ; 0, 1, 3, 5, 6, 7 (ASSOC)
    movs r0, #0x1a
    strb r0, [r1, #5]               ; 9 (REASSOC), 11, 12
    movs r0, #0x01
    strb r0, [r1, #6]               ; 16
    movs r0, #0x40
    strb r0, [r1, #9]               ; 46
    movs r0, #0x20
    strb r0, [r1, #12]              ; 69
    ldr  r0, wl9_setvar
    movs r1, #2
    mov  r2, r4
    adds r2, r2, #28
    bl   wl_ioctl
    cmp  r0, #0
    bne  weu_done
    movs r0, #2                     ; UP
    movs r1, #2
    movs r2, #0
    bl   wl_ioctl
    cmp  r0, #0
    bne  weu_done
    ; as the drivers: 100 ms, SET_GMODE auto, SET_BAND any, 100 ms (a join at once after UP fails)
    ldr  r0, wl9_100ms
    bl   wl_wait
    movs r0, #110
    movs r1, #1
    bl   wl_ioctl_u32
    movs r0, #142
    movs r1, #0
    bl   wl_ioctl_u32
    ldr  r0, wl9_100ms
    bl   wl_wait
    movs r0, #0
weu_done:
    pop  {r4, pc}

; r1 bytes of zeros at r0
wl_memset0:
    movs r2, #0
    cmp  r1, #0
    beq  wms_done
wms_next:
    strb r2, [r0]
    adds r0, r0, #1
    subs r1, r1, #1
    bne  wms_next
wms_done:
    bx   lr

; wlan scan: the networks around (escan, active, all channels), each BSSID once: the RSSI, the channel, open or
; secured, the name. Up to 15 seconds
wl_scan:
    push {r4, r5, r6, r7, lr}
    adr  r0, wl_n_escan
    ldr  r1, wl9_data
    bl   wl_copy_name
    mov  r4, r0
    ldr  r5, wl9_data
    adds r5, r5, r4                 ; the parameters (74 bytes)
    mov  r0, r5
    movs r1, #74
    bl   wl_memset0
    movs r0, #1
    strb r0, [r5]                   ; version 1
    strb r0, [r5, #4]               ; action 1 (start)
    strb r0, [r5, #6]               ; sync_id 1
    movs r0, #0xff
    movs r1, #44
wsc_bssid:
    strb r0, [r5, r1]               ; the BSSID ff:ff:ff:ff:ff:ff: any
    adds r1, r1, #1
    cmp  r1, #50
    blo  wsc_bssid
    movs r0, #2
    movs r1, #50
    strb r0, [r5, r1]               ; bss_type: any
    movs r0, #0xff
    movs r1, #52
wsc_times:
    strb r0, [r5, r1]               ; nprobes, active, passive, home time: -1 (the defaults)
    adds r1, r1, #1
    cmp  r1, #68
    blo  wsc_times
    ldr  r0, wl9_seen_n
    movs r1, #0
    str  r1, [r0]
    ldr  r0, wl9_setvar
    movs r1, #2
    mov  r2, r4
    adds r2, r2, #74
    bl   wl_ioctl
    cmp  r0, #0
    beq  wsc_started
    bl   wl_scan_failed             ; for a program: WL_SCNT -1, r0 1
    cmp  r0, #0
    bne  wsc_quiet
    bl   print_inline
    db   'The firmware did not start the scan.', 13, 10, 0
    align 2
wsc_quiet:
    pop  {r4, r5, r6, r7, pc}
wsc_started:
    bl   tick_now
    mov  r7, r0
wsc_next:
    bl   tick_now
    subs r0, r0, r7
    ldr  r1, wl9_15s
    cmp  r0, r1
    bhs  wsc_end
    bl   wl_poll
    cmp  r0, #0
    beq  wsc_next
    bl   wl_event                   ; r0 the event, r1 its status, r2 its data (0 not an event)
    cmp  r2, #0
    beq  wsc_next
    cmp  r0, #69
    bne  wsc_next
    cmp  r1, #8
    bne  wsc_end                    ; 0: the end of the scan (or an error)
    adds r2, r2, #12                ; the BSS info
    mov  r6, r2
    bl   wl_seen_bss                ; r0 1: shown before
    cmp  r0, #0
    bne  wsc_next
    movs r0, #0
    mvns r0, r0                     ; the security: from its IEs
    bl   wl_put_bss
    b    wsc_next
wsc_end:
    bl   wl_scan_count              ; the number of networks (not for a program)
    pop  {r4, r5, r6, r7, pc}

; the end of a scan: "n network(s)" for wlan scan; nothing for a program (wl_call 11)
wl_scan_count:
    push {lr}
    ldr  r0, wl9_sout
    ldr  r0, [r0]
    cmp  r0, #0
    bne  wscc_end
    ldr  r0, wl9_seen_n
    ldr  r0, [r0]
    bl   put_dec
    bl   print_inline
    db   ' network(s)', 13, 10, 0
    align 2
wscc_end:
    pop  {pc}

; the scan did not start: for a program (WL_SOUT) WL_SCNT -1 and r0 1; for wlan scan r0 0 (it says so)
wl_scan_failed:
    ldr  r1, wl9_sout
    ldr  r0, [r1]
    cmp  r0, #0
    beq  wsf_end
    movs r0, #0
    mvns r0, r0
    str  r0, [r1, #8]               ; WL_SCNT
    movs r0, #1
wsf_end:
    bx   lr

; a network of a scan (r6 its BSS info, as the CYW43439 gives it; the ESP8285 one made the same way; r0 its
; security as wifi_scan of the ESP32 counts it, or -1: from the IEs of the BSS info). wlan scan shows it as a line
; (WL_SOUT 0); wl_call 11 (a program) puts it into its buffer instead while there is room: a record of 48 bytes as
; on the ESP32 (+0 the BSSID, +6 the channel, +7 the RSSI, +8 the security, +12 the name and a 0)
wl_put_bss:
    push {r4, r5, r7, lr}
    ldr  r7, wl9_sout
    ldr  r4, [r7]                   ; WL_SOUT
    cmp  r4, #0
    bne  wpb_rec
    bl   wl_show_bss
    pop  {r4, r5, r7, pc}
wpb_rec:
    mov  r5, r0
    ldr  r1, [r7, #8]               ; WL_SCNT
    ldr  r2, [r7, #4]               ; WL_SMAX
    cmp  r1, r2
    bge  wpb_end
    adds r2, r1, #1
    str  r2, [r7, #8]
    movs r2, #48
    muls r1, r2
    adds r4, r4, r1                 ; the record
    mov  r0, r4
    movs r1, #48
    bl   wl_memset0
    mov  r0, r4
    mov  r1, r6
    adds r1, r1, #8
    movs r2, #6
    bl   wl_memcpy                  ; the BSSID
    mov  r0, r6
    adds r0, r0, #72
    ldrb r0, [r0]
    strb r0, [r4, #6]               ; the channel (the low byte of the chanspec)
    mov  r0, r6
    adds r0, r0, #78
    ldrb r0, [r0]
    strb r0, [r4, #7]               ; the RSSI (the low byte of its 16 bits: -64 is 0xC0)
    cmp  r5, #0
    bge  wpb_sec
    bl   wl_bss_auth
    mov  r5, r0
wpb_sec:
    strb r5, [r4, #8]
    ldrb r2, [r6, #18]              ; the length of the name
    cmp  r2, #32
    bls  wpb_len
    movs r2, #32
wpb_len:
    mov  r0, r4
    adds r0, r0, #12
    mov  r1, r6
    adds r1, r1, #19
    bl   wl_memcpy                  ; the name (its 0: the record was zeros)
wpb_end:
    pop  {r4, r5, r7, pc}

; the security of the BSS info at r6 from its IEs (ie_offset at +116, ie_length at +120, the length of the BSS info
; at +4; the bytes one by one: it need not be aligned), as wifi_scan of the ESP32 counts it: 0 open, 1 WEP, 2 WPA,
; 3 WPA2, 4 WPA/WPA2, 5 WPA2 Enterprise, 6 WPA3, 7 WPA2/WPA3. The RSN IE (48) gives WPA2 and its AKM suites (00-0F-AC:
; 1 and 5 802.1X, 8 SAE, others PSK), the IE 221 with 00-50-F2 type 1 WPA; neither: the bit privacy of the capability
; (+16) WEP, else open. r7 its flags: 1 WPA, 2 PSK, 4 SAE, 8 802.1X, 16 RSN
wl_bss_auth:
    push {r4, r5, r6, r7, lr}
    movs r7, #0
    mov  r0, r6
    adds r0, r0, #116
    ldrb r4, [r0]
    ldrb r1, [r0, #1]
    lsls r1, r1, #8
    orrs r4, r1                     ; ie_offset
    ldrb r5, [r0, #4]
    ldrb r1, [r0, #5]
    lsls r1, r1, #8
    orrs r5, r1                     ; ie_length (below 64 KB)
    ldrb r2, [r6, #4]
    ldrb r1, [r6, #5]
    lsls r1, r1, #8
    orrs r2, r1                     ; the length of the BSS info
    cmp  r4, #0
    beq  wba_flags                  ; no IEs (the one of the ESP8285 does not come here)
    adds r0, r4, r5
    cmp  r0, r2
    bhi  wba_flags                  ; IEs outside of it: none
    adds r4, r6, r4                 ; the first IE
    adds r5, r4, r5                 ; their end
wba_ie:
    adds r0, r4, #2
    cmp  r0, r5
    bhi  wba_flags
    ldrb r0, [r4]                   ; its tag
    ldrb r1, [r4, #1]               ; its length
    adds r2, r4, #2                 ; its data
    adds r3, r2, r1                 ; its end
    cmp  r3, r5
    bhi  wba_flags
    cmp  r0, #48
    beq  wba_rsn
    cmp  r0, #221
    bne  wba_skip
    cmp  r1, #4                     ; vendor: 00 50 F2 01 is WPA
    blo  wba_skip
    ldrb r0, [r2]
    cmp  r0, #0x00
    bne  wba_skip
    ldrb r0, [r2, #1]
    cmp  r0, #0x50
    bne  wba_skip
    ldrb r0, [r2, #2]
    cmp  r0, #0xF2
    bne  wba_skip
    ldrb r0, [r2, #3]
    cmp  r0, #1
    bne  wba_skip
    movs r0, #1
    orrs r7, r0
    b    wba_skip
wba_rsn:
    movs r0, #16
    orrs r7, r0
    adds r2, r2, #6                 ; behind the version (2) and the group cipher (4): the pairwise ones
    adds r0, r2, #2
    cmp  r0, r3
    bhi  wba_skip
    ldrb r0, [r2]
    ldrb r1, [r2, #1]
    lsls r1, r1, #8
    orrs r0, r1
    lsls r0, r0, #2
    adds r2, r2, #2
    adds r2, r2, r0                 ; the AKM suites
    adds r0, r2, #2
    cmp  r0, r3
    bhi  wba_skip
    ldrb r0, [r2]
    ldrb r1, [r2, #1]
    lsls r1, r1, #8
    orrs r0, r1                     ; their number
    adds r2, r2, #2
wba_akm:
    cmp  r0, #0
    beq  wba_skip
    adds r1, r2, #4
    cmp  r1, r3
    bhi  wba_skip
    ldrb r1, [r2, #3]               ; its type
    cmp  r1, #8
    beq  wba_sae
    cmp  r1, #1
    beq  wba_1x
    cmp  r1, #5
    beq  wba_1x
    movs r1, #2
    b    wba_akm_or
wba_sae:
    movs r1, #4
    b    wba_akm_or
wba_1x:
    movs r1, #8
wba_akm_or:
    orrs r7, r1
    adds r2, r2, #4
    subs r0, r0, #1
    b    wba_akm
wba_skip:
    mov  r4, r3
    b    wba_ie
wba_flags:
    movs r1, #4
    tst  r7, r1
    beq  wba_no_sae
    movs r0, #6                     ; WPA3
    movs r1, #2
    tst  r7, r1
    beq  wba_end
    movs r0, #7                     ; WPA2/WPA3
    b    wba_end
wba_no_sae:
    movs r0, #5                     ; WPA2 Enterprise
    movs r1, #8
    tst  r7, r1
    bne  wba_end
    movs r1, #16
    tst  r7, r1
    beq  wba_no_rsn
    movs r0, #3                     ; WPA2
    movs r1, #1
    tst  r7, r1
    beq  wba_end
    movs r0, #4                     ; WPA/WPA2
    b    wba_end
wba_no_rsn:
    movs r0, #2                     ; WPA
    movs r1, #1
    tst  r7, r1
    bne  wba_end
    movs r0, #1                     ; WEP
    ldrb r1, [r6, #16]
    movs r2, #0x10
    tst  r1, r2
    bne  wba_end
    movs r0, #0                     ; open
wba_end:
    pop  {r4, r5, r6, r7, pc}

    align 4
wl9_data:           dd WL_DATA
wl9_setvar:         dd 263
wl9_15s:            dd 15000000
wl9_100ms:          dd 100000
wl9_seen_n:         dd WLV + WL_NSEEN
wl9_sout:           dd WLV + WL_SOUT
wl_n_events:
    db   'bsscfg:event_msgs', 0
    align 4
wl_n_country:
    db   'country', 0
    align 4
wl_n_bawsize:
    db   'ampdu_ba_wsize', 0
    align 4
wl_n_mpdu:
    db   'ampdu_mpdu', 0
    align 4
wl_n_mcast:
    db   'mcast_list', 0
    align 4
wl_mcast_val:                           ; the count (1), then 01:00:5E:00:00:FB
    db   1, 0, 0, 0, 0x01, 0x00, 0x5E, 0x00, 0x00, 0xFB
    align 4
wl_n_escan:
    db   'escan', 0
    align 4

; the packet in WL_RX an event? r2 its data (0: not an event), r0 its type, r1 its status
wl_event:
    ldr  r3, wl10_rx
    ldrb r0, [r3, #5]
    movs r1, #0x0f
    ands r0, r1
    cmp  r0, #1
    bne  wev_not
    ldrb r0, [r3, #7]
    adds r3, r3, r0                 ; the BDC header
    ldrb r0, [r3, #3]
    lsls r0, r0, #2
    adds r0, r0, #4
    adds r3, r3, r0                 ; the Ethernet frame
    ldrb r0, [r3, #12]
    cmp  r0, #0x88
    bne  wev_not
    ldrb r0, [r3, #13]
    cmp  r0, #0x6c
    bne  wev_not
    adds r3, r3, #24                ; the message
    ldrb r0, [r3, #6]               ; its type (big endian, at +4): its two low bytes
    ldrb r1, [r3, #7]
    lsls r0, r0, #8
    orrs r0, r1
    ldrb r1, [r3, #11]              ; its status: its low byte
    mov  r2, r3
    adds r2, r2, #48                ; its data
    bx   lr
wev_not:
    movs r2, #0
    bx   lr

; the BSS info at r6: its BSSID in WL_SEEN already? r0 1; else it goes in (up to WL_SEEN_MAX) and r0 0
wl_seen_bss:
    push {r4, r5, lr}
    ldr  r4, wl10_seen
    ldr  r5, wl10_seen_n
    ldr  r5, [r5]
wse_next:
    cmp  r5, #0
    beq  wse_new
    movs r1, #0
wse_byte:
    adds r2, r6, r1
    ldrb r2, [r2, #8]
    ldrb r3, [r4, r1]
    cmp  r2, r3
    bne  wse_other
    adds r1, r1, #1
    cmp  r1, #6
    blo  wse_byte
    movs r0, #1
    pop  {r4, r5, pc}
wse_other:
    adds r4, r4, #6
    subs r5, r5, #1
    b    wse_next
wse_new:
    ldr  r5, wl10_seen_n
    ldr  r0, [r5]
    cmp  r0, #WL_SEEN_MAX
    bhs  wse_full
    adds r0, r0, #1
    str  r0, [r5]
    movs r1, #0
wse_copy:
    adds r2, r6, r1
    ldrb r2, [r2, #8]
    strb r2, [r4, r1]
    adds r1, r1, #1
    cmp  r1, #6
    blo  wse_copy
wse_full:
    movs r0, #0
    pop  {r4, r5, pc}

; a line for the BSS info at r6: the RSSI, the channel, open or secured, the name
wl_show_bss:
    push {r4, r5, lr}
    bl   put_space
    bl   put_space
    mov  r0, r6
    adds r0, r0, #78
    ldrb r1, [r0, #1]
    ldrb r0, [r0]
    lsls r1, r1, #8
    orrs r0, r1                     ; the RSSI (16 bits, signed)
    lsls r0, r0, #16
    asrs r0, r0, #16
    rsbs r4, r0, #0                 ; (it is below 0: -30 .. -95 dBm)
    cmp  r4, #100
    bhs  wsb_minus
    bl   put_space
wsb_minus:
    movs r0, #'-'
    bl   put_char
    mov  r0, r4
    bl   put_dec
    bl   print_inline
    db   ' dBm  channel ', 0
    align 2
    mov  r0, r6
    adds r0, r0, #72
    ldrb r0, [r0]
    movs r1, #3
    bl   put_dec_w
    ldrb r0, [r6, #16]
    movs r1, #0x10
    tst  r0, r1
    bne  wsb_secured
    bl   print_inline
    db   '  open     ', 0
    align 2
    b    wsb_name
wsb_secured:
    bl   print_inline
    db   '  secured  ', 0
    align 2
wsb_name:
    ldrb r5, [r6, #18]              ; the length of the name
    cmp  r5, #32
    bls  wsb_len
    movs r5, #32
wsb_len:
    cmp  r5, #0
    bne  wsb_chars
    bl   print_inline
    db   '(hidden)', 0
    align 2
    b    wsb_end
wsb_chars:
    movs r4, #0
wsb_char:
    adds r0, r6, r4
    ldrb r0, [r0, #19]
    cmp  r0, #' '
    blo  wsb_dot
    cmp  r0, #127
    blo  wsb_put
wsb_dot:
    movs r0, #'.'
wsb_put:
    bl   put_char
    adds r4, r4, #1
    cmp  r4, r5
    blo  wsb_char
wsb_end:
    bl   put_nl
    pop  {r4, r5, pc}

    align 4
wl10_rx:            dd WL_RX
wl10_seen:          dd WL_SEEN
wl10_seen_n:        dd WLV + WL_NSEEN

; ---------- the network of the board (wlan set, wlan clear) ----------
;
; As on the ESP32 (boards\esp32\console.asm): two sectors at the end of the flash keep the network of the board,
; FS_END and FS_END + 1 (behind the file system): each time the other one is written, with a number one higher, and
; the valid one with the higher number counts. A record of 128 bytes at the start of its sector: +0 "AWN1", +4 the
; number, +8 bit 0: an open network (no key), +12 the length of the name (1 .. 32), +16 the name (32 bytes), +48 the
; key (32 bytes: PBKDF2-SHA1 of the password and the name, 4096 rounds, the PMK of WPA2; not the password), +124 the
; CRC-32 of the bytes before it. Whoever reads the flash learns the key of this one network, not the password. The
; console gives the key itself to the firmware (SET_WSEC_PMK: its 32 bytes, without the flag of a passphrase).

WL_NET          equ DIRBUF + 0x2000     ; the record (128 bytes) in a page of 256 for the flash
WL_W            equ DIRBUF + 0x1D40     ; SHA-1: the 80 words of a block
WL_BLK          equ DIRBUF + 0x1E80     ; ... a block (64 bytes)
WL_HS           equ DIRBUF + 0x1EC0     ; ... the state of a hash (5 words)
WL_HI           equ DIRBUF + 0x1ED4     ; HMAC: the state after the block of the key ^ 0x36
WL_HO           equ DIRBUF + 0x1EE8     ; ... ^ 0x5C
WL_HU           equ DIRBUF + 0x1EFC     ; PBKDF2: U (20 bytes)
WL_HX           equ DIRBUF + 0x1F10     ; ... the xor of the Us (20 bytes)
WL_HM           equ DIRBUF + 0x1F24     ; ... the inner hash of an HMAC (20 bytes)
WL_MSG          equ DIRBUF + 0x1F40     ; ... the name and the number of the block (36 bytes)
WL_SECRET       equ DIRBUF + 0x1F80     ; the password typed (up to 64 bytes)
WL_NET_MAGIC    equ 0x314e5741          ; "AWN1"

; r0 the address of a record (through XIP): its number when it is valid ("AWN1", its CRC), else 0
wl_rec_valid:
    push {r4, lr}
    mov  r4, r0
    ldr  r1, [r4]
    ldr  r2, wlN_magic
    cmp  r1, r2
    bne  wrv_no
    movs r0, #0
    mov  r1, r4
    movs r2, #124
    bl   crc32
    ldr  r1, [r4, #124]
    cmp  r0, r1
    bne  wrv_no
    ldr  r0, [r4, #4]
    pop  {r4, pc}
wrv_no:
    movs r0, #0
    pop  {r4, pc}

; the record of the network into WL_NET: r0 1, or 0 (WL_NET zeros) when neither sector holds a valid one.
; WL_NETNUM its number (0: none), WL_NETSEC the sector for the next record (the other one)
wl_net_load:
    push {r4, r5, r6, r7, lr}
    movs r6, #0                     ; the highest number
    movs r7, #0                     ; its record
    ldr  r4, wlN_rec0
    mov  r0, r4
    bl   wl_rec_valid
    cmp  r0, #0
    beq  wnl_second
    mov  r6, r0
    mov  r7, r4
wnl_second:
    ldr  r5, wlN_4096
    adds r5, r5, r4
    mov  r0, r5
    bl   wl_rec_valid
    cmp  r0, r6
    bls  wnl_take
    mov  r6, r0
    mov  r7, r5
wnl_take:
    ldr  r5, wlN_wlv
    str  r6, [r5, #WL_NETNUM]
    ldr  r0, wlN_fs_end
    cmp  r6, #0
    beq  wnl_next
    cmp  r7, r4
    bne  wnl_next
    adds r0, r0, #1                 ; the record in the first sector: the next one into the second
wnl_next:
    str  r0, [r5, #WL_NETSEC]
    cmp  r6, #0
    beq  wnl_none
    ldr  r0, wlN_net
    mov  r1, r7
    movs r2, #128
    bl   wl_memcpy
    movs r0, #1
    pop  {r4, r5, r6, r7, pc}
wnl_none:
    ldr  r0, wlN_net
    movs r1, #128
    bl   wl_memset0
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; a file in the two sectors of the network (a file system of an older console reached there)? r0 0, else the text
wl_net_room:
    push {r4, r5, r6, lr}
    ldr  r0, wlN_vars
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    beq  wnr_free
    ldr  r4, wlN_entries
    movs r5, #0
wnr_entry:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  wnr_skip
    ldr  r1, [r4, #24]              ; the length
    cmp  r1, #0
    beq  wnr_skip
    ldr  r0, [r4, #20]              ; the first sector
    ldr  r2, wlN_4095
    adds r1, r1, r2
    lsrs r1, r1, #12
    adds r1, r1, r0                 ; behind its last one
    ldr  r6, wlN_fs_end
    cmp  r1, r6
    bls  wnr_skip                   ; it ends before
    adds r6, r6, #2
    cmp  r0, r6
    bhs  wnr_skip                   ; it starts behind (no flash there)
    adr  r0, wl_e_room
    pop  {r4, r5, r6, pc}
wnr_skip:
    adds r4, r4, #32
    adds r5, r5, #1
    cmp  r5, #ENTRIES
    blo  wnr_entry
wnr_free:
    movs r0, #0
    pop  {r4, r5, r6, pc}

; WL_NET (+8 .. +123 filled) into the sector WL_NETSEC, with "AWN1", the next number and its CRC-32; r0 0, else the
; text of what went wrong
wl_net_save:
    push {r4, r5, lr}
    bl   wl_net_room
    cmp  r0, #0
    bne  wns_end
    ldr  r0, wlN_vars
    ldr  r0, [r0, #V_FN + 20]
    cmp  r0, #0
    beq  wns_rom
    ldr  r4, wlN_net
    ldr  r5, wlN_wlv
    ldr  r0, wlN_magic
    str  r0, [r4]
    ldr  r0, [r5, #WL_NETNUM]
    adds r0, r0, #1
    str  r0, [r4, #4]
    str  r0, [r5, #WL_NETNUM]
    movs r0, #0
    mov  r1, r4
    movs r2, #124
    bl   crc32
    str  r0, [r4, #124]
    mov  r0, r4
    adds r0, r0, #128
    movs r1, #128
    bl   wl_memset0                 ; the rest of the page
    bl   flash_open
    ldr  r0, [r5, #WL_NETSEC]
    lsls r0, r0, #12
    ldr  r1, wlN_4096
    bl   flash_erase
    ldr  r0, [r5, #WL_NETSEC]
    lsls r0, r0, #12
    mov  r1, r4
    movs r2, #1
    lsls r2, r2, #8
    bl   flash_program
    bl   flash_close
    ldr  r0, [r5, #WL_NETSEC]
    movs r1, #1
    eors r0, r1                     ; the next one into the other sector (FS_END is even)
    str  r0, [r5, #WL_NETSEC]
    movs r0, #0
wns_end:
    pop  {r4, r5, pc}
wns_rom:
    adr  r0, wl_e_rom
    pop  {r4, r5, pc}

; wlan clear: the board keeps no network. When the record has a name of the board or a password (wl_rec_rest), a record
; with them and without a network (the length of its name 0, as on the ESP32); else both sectors erased
wl_net_clear:
    push {r4, lr}
    bl   wl_rec_rest
    cmp  r0, #0
    beq  wnc_erase
    ldr  r0, wlN_net
    movs r1, #80
    bl   wl_memset0
    bl   wl_net_save
    pop  {r4, pc}
wnc_erase:
    ldr  r0, wlN_vars
    ldr  r0, [r0, #V_FN + 20]
    cmp  r0, #0
    beq  wnc_rom
    bl   flash_open
    ldr  r0, wlN_fs_end
    lsls r0, r0, #12
    ldr  r1, wlN_4096
    lsls r1, r1, #1
    bl   flash_erase
    bl   flash_close
    ldr  r4, wlN_wlv
    movs r0, #0
    str  r0, [r4, #WL_NETNUM]
    ldr  r0, wlN_fs_end
    str  r0, [r4, #WL_NETSEC]
    ldr  r0, wlN_net
    movs r1, #128
    bl   wl_memset0
    movs r0, #0
    pop  {r4, pc}
wnc_rom:
    adr  r0, wl_e_rom
    pop  {r4, pc}

; WL_NET keeps a name of the board (+80) or a password for telnet (+112 .. +123)? r0 1, else 0
wl_rec_rest:
    ldr  r1, wlN_net
    adds r1, r1, #80
    ldrb r0, [r1]
    cmp  r0, #0
    bne  wrr_yes
    adds r1, r1, #32
    movs r2, #0
wrr_next:
    ldrb r0, [r1, r2]
    cmp  r0, #0
    bne  wrr_yes
    adds r2, r2, #1
    cmp  r2, #12
    blo  wrr_next
    movs r0, #0
    bx   lr
wrr_yes:
    movs r0, #1
    bx   lr

    align 4
wlN_magic:          dd WL_NET_MAGIC
wlN_rec0:           dd 0x10000000 + FS_END * 4096
wlN_fs_end:         dd FS_END
wlN_4096:           dd 4096
wlN_4095:           dd 4095
wlN_wlv:            dd WLV
wlN_net:            dd WL_NET
wlN_vars:           dd VARS
wlN_entries:        dd DIRBUF + 32
    align 4
wl_e_room:
    db   'A file lies in the last 8 KB of the flash, where the console keeps the network (ls; rm it, upload it '
    db   'again).', 0
    align 4
wl_e_rom:
    db   'The boot ROM has not all the functions for the flash.', 0
    align 4

; ---------- SHA-1, HMAC, PBKDF2 (the key of WPA2) ----------

; r0 the state (5 words): the start of SHA-1
wl_sha1_init:
    ldr  r1, wlS_h0
    str  r1, [r0]
    ldr  r1, wlS_h1
    str  r1, [r0, #4]
    ldr  r1, wlS_h2
    str  r1, [r0, #8]
    ldr  r1, wlS_h3
    str  r1, [r0, #12]
    ldr  r1, wlS_h4
    str  r1, [r0, #16]
    bx   lr

; the block r1 (64 bytes) into the state r0
wl_sha1_block:
    push {r4, r5, r6, r7, lr}
    mov  r2, r8
    mov  r3, r9
    push {r2, r3}
    mov  r8, r0
    ldr  r2, wlS_w
    movs r3, #0
wsb_load:
    ldrb r4, [r1]                   ; the 16 words of the block, big endian
    lsls r4, r4, #24
    ldrb r5, [r1, #1]
    lsls r5, r5, #16
    orrs r4, r5
    ldrb r5, [r1, #2]
    lsls r5, r5, #8
    orrs r4, r5
    ldrb r5, [r1, #3]
    orrs r4, r5
    str  r4, [r2, r3]
    adds r1, r1, #4
    adds r3, r3, #4
    cmp  r3, #64
    blo  wsb_load
wsb_expand:
    mov  r0, r3                     ; w[t] = rol 1 (w[t-3] ^ w[t-8] ^ w[t-14] ^ w[t-16])
    subs r0, r0, #12
    ldr  r4, [r2, r0]
    mov  r0, r3
    subs r0, r0, #32
    ldr  r5, [r2, r0]
    eors r4, r5
    mov  r0, r3
    subs r0, r0, #56
    ldr  r5, [r2, r0]
    eors r4, r5
    mov  r0, r3
    subs r0, r0, #64
    ldr  r5, [r2, r0]
    eors r4, r5
    movs r0, #31
    rors r4, r0
    str  r4, [r2, r3]
    adds r3, r3, #4
    ldr  r0, wlS_320
    cmp  r3, r0
    blo  wsb_expand
    mov  r0, r8
    ldr  r3, [r0]                   ; a
    ldr  r4, [r0, #4]               ; b
    ldr  r5, [r0, #8]               ; c
    ldr  r6, [r0, #12]              ; d
    ldr  r7, [r0, #16]              ; e
    movs r0, #0
    mov  r9, r0                     ; 4 t
wsb_round:
    ldr  r2, wlS_w
    mov  r0, r9
    ldr  r1, [r2, r0]               ; w[t]
    cmp  r0, #80
    blo  wsb_f1
    cmp  r0, #160
    blo  wsb_f2
    cmp  r0, #240
    blo  wsb_f3
    mov  r0, r4                     ; 60 .. 79: b ^ c ^ d
    eors r0, r5
    eors r0, r6
    ldr  r2, wlS_k4
    b    wsb_t
wsb_f1:
    mov  r0, r5                     ; 0 .. 19: d ^ (b & (c ^ d))
    eors r0, r6
    ands r0, r4
    eors r0, r6
    ldr  r2, wlS_k1
    b    wsb_t
wsb_f2:
    mov  r0, r4                     ; 20 .. 39: b ^ c ^ d
    eors r0, r5
    eors r0, r6
    ldr  r2, wlS_k2
    b    wsb_t
wsb_f3:
    mov  r0, r4                     ; 40 .. 59: (b & c) | (d & (b | c))
    orrs r0, r5
    ands r0, r6
    mov  r2, r4
    ands r2, r5
    orrs r0, r2
    ldr  r2, wlS_k3
wsb_t:
    adds r0, r0, r2                 ; f + k + w + e + rol 5 (a)
    adds r0, r0, r1
    adds r0, r0, r7
    movs r1, #27
    mov  r2, r3
    rors r2, r1
    adds r0, r0, r2
    mov  r7, r6                     ; e = d
    mov  r6, r5                     ; d = c
    movs r1, #2
    mov  r5, r4
    rors r5, r1                     ; c = rol 30 (b)
    mov  r4, r3                     ; b = a
    mov  r3, r0                     ; a = the new one
    mov  r0, r9
    adds r0, r0, #4
    mov  r9, r0
    ldr  r1, wlS_320
    cmp  r0, r1
    blo  wsb_round
    mov  r0, r8
    ldr  r1, [r0]
    adds r1, r1, r3
    str  r1, [r0]
    ldr  r1, [r0, #4]
    adds r1, r1, r4
    str  r1, [r0, #4]
    ldr  r1, [r0, #8]
    adds r1, r1, r5
    str  r1, [r0, #8]
    ldr  r1, [r0, #12]
    adds r1, r1, r6
    str  r1, [r0, #12]
    ldr  r1, [r0, #16]
    adds r1, r1, r7
    str  r1, [r0, #16]
    pop  {r2, r3}
    mov  r8, r2
    mov  r9, r3
    pop  {r4, r5, r6, r7, pc}

    align 4
wlS_h0:             dd 0x67452301
wlS_h1:             dd 0xefcdab89
wlS_h2:             dd 0x98badcfe
wlS_h3:             dd 0x10325476
wlS_h4:             dd 0xc3d2e1f0
wlS_k1:             dd 0x5a827999
wlS_k2:             dd 0x6ed9eba1
wlS_k3:             dd 0x8f1bbcdc
wlS_k4:             dd 0xca62c1d6
wlS_w:              dd WL_W
wlS_320:            dd 320

; the end of an HMAC half: the hash of the state r3 (after a block of 64 bytes) and r2 bytes at r1 (up to 55), its 20
; bytes to r0 (r0 may be r1)
wl_hmac_half:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0
    mov  r5, r1
    mov  r6, r2
    ldr  r0, wlH_hs
    mov  r1, r3
    movs r2, #20
    bl   wl_memcpy
    ldr  r0, wlH_blk
    movs r1, #64
    bl   wl_memset0
    ldr  r0, wlH_blk
    mov  r1, r5
    mov  r2, r6
    bl   wl_memcpy
    ldr  r0, wlH_blk
    movs r1, #0x80
    strb r1, [r0, r6]
    mov  r1, r6
    adds r1, r1, #64
    lsls r1, r1, #3                 ; the bits of the message, with the block before
    adds r0, r0, #60
    strb r1, [r0, #3]
    lsrs r1, r1, #8
    strb r1, [r0, #2]
    ldr  r0, wlH_hs
    ldr  r1, wlH_blk
    bl   wl_sha1_block
    ldr  r1, wlH_hs
    movs r2, #0
whh_word:
    ldr  r0, [r1, r2]
    adds r5, r4, r2
    lsrs r3, r0, #24
    strb r3, [r5]
    lsrs r3, r0, #16
    strb r3, [r5, #1]
    lsrs r3, r0, #8
    strb r3, [r5, #2]
    strb r0, [r5, #3]
    adds r2, r2, #4
    cmp  r2, #20
    blo  whh_word
    pop  {r4, r5, r6, r7, pc}

; HMAC-SHA1 of r2 bytes at r1 with the key of WL_HI and WL_HO: its 20 bytes to r0
wl_hmac:
    push {r4, lr}
    mov  r4, r0
    ldr  r0, wlH_hm
    ldr  r3, wlH_hi
    bl   wl_hmac_half
    mov  r0, r4
    ldr  r1, wlH_hm
    movs r2, #20
    ldr  r3, wlH_ho
    bl   wl_hmac_half
    pop  {r4, pc}

; the key of the HMAC: the password (WL_SECRET, WL_SECLEN bytes) ^ 0x36 into WL_HI, ^ 0x5C into WL_HO
wl_hmac_key:
    push {r4, r5, r6, lr}
    movs r6, #0x36
    ldr  r4, wlH_hi
whk_pad:
    ldr  r0, wlH_blk
    movs r1, #64
    bl   wl_memset0
    ldr  r0, wlH_blk
    ldr  r1, wlH_secret
    ldr  r2, wlH_wlv
    ldr  r2, [r2, #WL_SECLEN]
    bl   wl_memcpy
    ldr  r0, wlH_blk
    movs r1, #0
whk_xor:
    ldrb r2, [r0, r1]
    eors r2, r6
    strb r2, [r0, r1]
    adds r1, r1, #1
    cmp  r1, #64
    blo  whk_xor
    mov  r0, r4
    bl   wl_sha1_init
    mov  r0, r4
    ldr  r1, wlH_blk
    bl   wl_sha1_block
    cmp  r6, #0x5c
    beq  whk_done
    movs r6, #0x5c
    ldr  r4, wlH_ho
    b    whk_pad
whk_done:
    pop  {r4, r5, r6, pc}

    align 4
wlH_hs:             dd WL_HS
wlH_blk:            dd WL_BLK
wlH_hm:             dd WL_HM
wlH_hi:             dd WL_HI
wlH_ho:             dd WL_HO
wlH_secret:         dd WL_SECRET
wlH_wlv:            dd WLV

; the key of WPA2 into WL_NET + 48 (32 bytes): PBKDF2-HMAC-SHA1 of the password (WL_SECRET) and the name (WL_NET +
; 12, + 16), 4096 rounds; then the states that hold the password are cleared. Some seconds
wl_pbkdf2:
    push {lr}
    ldr  r2, wlP_net
    mov  r0, r2
    adds r0, r0, #16
    ldr  r1, [r2, #12]
    adds r2, r2, #48
    movs r3, #32
    bl   wl_pbkdf2_any
    pop  {pc}

; PBKDF2-HMAC-SHA1 of the password (WL_SECRET, WL_SECLEN) with the salt r0 (r1 bytes, up to 32), 4096 rounds: r3
; bytes (up to 40) of the key to r2 (for WPA2 the name of the network and 32 bytes; for passwd the MAC and 12); then
; the states that hold the password are cleared
wl_pbkdf2_any:
    push {r4, r5, r6, r7, lr}
    ldr  r4, wlP_pb
    str  r0, [r4]
    str  r1, [r4, #4]
    str  r2, [r4, #8]
    str  r3, [r4, #12]
    bl   wl_hmac_key
    movs r7, #1                     ; the number of the block
wpb_block:
    ldr  r4, wlP_pb
    ldr  r6, [r4, #4]               ; the length of the salt
    ldr  r1, [r4]
    ldr  r0, wlP_msg
    mov  r2, r6
    bl   wl_memcpy
    ldr  r0, wlP_msg
    adds r0, r0, r6
    movs r1, #0
    strb r1, [r0]
    strb r1, [r0, #1]
    strb r1, [r0, #2]
    strb r7, [r0, #3]               ; the number, big endian
    ldr  r0, wlP_hu
    ldr  r1, wlP_msg
    adds r2, r6, #4
    bl   wl_hmac                    ; U1
    ldr  r0, wlP_hx
    ldr  r1, wlP_hu
    movs r2, #20
    bl   wl_memcpy
    ldr  r5, wlP_4095
wpb_round:
    ldr  r0, wlP_hu
    mov  r1, r0
    movs r2, #20
    bl   wl_hmac                    ; U(n+1) = HMAC(U(n))
    ldr  r0, wlP_hx
    ldr  r1, wlP_hu
    movs r2, #0
wpb_xor:
    ldrb r3, [r0, r2]
    ldrb r6, [r1, r2]
    eors r3, r6
    strb r3, [r0, r2]
    adds r2, r2, #1
    cmp  r2, #20
    blo  wpb_xor
    subs r5, r5, #1
    bne  wpb_round
    ldr  r4, wlP_pb                 ; block n: the bytes 20 (n - 1) .. of the key
    ldr  r0, [r4, #8]
    ldr  r2, [r4, #12]
    cmp  r7, #1
    beq  wpb_first
    adds r0, r0, #20
    subs r2, r2, #20                ; the rest (up to 20)
    b    wpb_put
wpb_first:
    cmp  r2, #20
    bls  wpb_put
    movs r2, #20
wpb_put:
    ldr  r1, wlP_hx
    bl   wl_memcpy
    ldr  r4, wlP_pb
    ldr  r0, [r4, #12]
    cmp  r0, #20
    bls  wpb_done                   ; one block is enough
    adds r7, r7, #1
    cmp  r7, #2
    bls  wpb_block
wpb_done:
    ldr  r0, wlP_w                  ; SHA-1 and HMAC: nothing of the password stays
    movs r1, #1
    lsls r1, r1, #9
    bl   wl_memset0
    pop  {r4, r5, r6, r7, pc}

; the password gone from the RAM: WL_SECRET, the rings of what came over USB and over the UART
wl_forget:
    push {lr}
    ldr  r0, wlP_secret
    movs r1, #64
    bl   wl_memset0
    ldr  r0, wlP_usbrx
    movs r1, #255
    adds r1, r1, #1
    bl   wl_memset0
    ldr  r0, wlP_ring
    movs r1, #255
    adds r1, r1, #1
    bl   wl_memset0
    ldr  r1, wlP_wlv
    movs r0, #0
    str  r0, [r1, #WL_SECLEN]
    pop  {pc}

; a password from the terminal into WL_SECRET, without an echo (Backspace, Ctrl+C; CR or LF ends it): r0 its length
; (64: too long), -1 for Ctrl+C
wl_read_secret:
    push {r4, r5, lr}
    ldr  r4, wlP_secret
    movs r5, #0
wrs_next:
    bl   get_char
    cmp  r0, #13
    beq  wrs_end
    cmp  r0, #10
    beq  wrs_end
    cmp  r0, #3
    beq  wrs_cancel
    cmp  r0, #8
    beq  wrs_back
    cmp  r0, #127
    beq  wrs_back
    cmp  r0, #' '
    blo  wrs_next
    cmp  r5, #64
    bhs  wrs_next
    strb r0, [r4, r5]
    adds r5, r5, #1
    b    wrs_next
wrs_back:
    cmp  r5, #0
    beq  wrs_next
    subs r5, r5, #1
    b    wrs_next
wrs_end:
    cmp  r0, #13
    bne  wrs_done
    ldr  r0, wlP_20ms               ; the LF of CR LF
    bl   wl_wait
    bl   poll_byte
wrs_done:
    bl   put_nl
    mov  r0, r5
    pop  {r4, r5, pc}
wrs_cancel:
    bl   put_nl
    movs r0, #0
    mvns r0, r0
    pop  {r4, r5, pc}

    align 4
wlP_net:            dd WL_NET
wlP_pb:             dd WLV + WL_PB
wlP_msg:            dd WL_MSG
wlP_hu:             dd WL_HU
wlP_hx:             dd WL_HX
wlP_w:              dd WL_W
wlP_secret:         dd WL_SECRET
wlP_usbrx:          dd USB_RXB
wlP_ring:           dd RING
wlP_wlv:            dd WLV
wlP_4095:           dd 4095
wlP_20ms:           dd 20000

; ---------- joining the network ----------

; an ioctl set with a word: the command r0, the word r1. r0 0, else the status
wl_ioctl_u32:
    push {r4, lr}
    mov  r4, r0
    ldr  r0, wlJ_data
    bl   wl_put32
    mov  r0, r4
    movs r1, #2
    movs r2, #4
    bl   wl_ioctl
    pop  {r4, pc}

; the network of WL_NET, as the drivers join it (WPA2 with AES, or open): r0 0 when the board is in it (WL_STATE 2),
; else the text of what went wrong. Up to 15 seconds
wl_join:
    push {r4, r5, r6, lr}
    bl   esp_mode                   ; the ESP8285: J (esp_join)
    cmp  r0, #0
    beq  wj_cyw
    bl   esp_join
    pop  {r4, r5, r6, pc}
wj_cyw:
    ldr  r4, wlJ_net
    bl   wl_diag_clear
    adr  r0, wl_n_ampdu
    movs r1, #8
    bl   wl_set_u32
    ldr  r0, [r4, #8]
    movs r1, #1
    tst  r0, r1
    beq  wj_wpa
    movs r0, #134                   ; SET_WSEC: none
    movs r1, #0
    bl   wl_ioctl_u32
    adr  r0, wl_n_supwpa
    movs r1, #0
    movs r2, #0
    bl   wl_set_u32x2
    movs r0, #20                    ; SET_INFRA: 1
    movs r1, #1
    bl   wl_ioctl_u32
    movs r0, #22                    ; SET_AUTH: open
    movs r1, #0
    bl   wl_ioctl_u32
    movs r0, #165                   ; SET_WPA_AUTH: disabled
    movs r1, #0
    bl   wl_ioctl_u32
    b    wj_ssid
wj_wpa:
    movs r0, #134                   ; SET_WSEC: AES
    movs r1, #4
    bl   wl_ioctl_u32
    adr  r0, wl_n_supwpa
    movs r1, #0
    movs r2, #1
    bl   wl_set_u32x2
    adr  r0, wl_n_eapver
    movs r1, #0
    movs r2, #0
    mvns r2, r2
    bl   wl_set_u32x2
    adr  r0, wl_n_wpatmo
    movs r1, #0
    ldr  r2, wlJ_2500
    bl   wl_set_u32x2
    ldr  r0, wlJ_100ms
    bl   wl_wait
    ; SET_WSEC_PMK: its length 32, no flags (not a passphrase: the key itself), the 32 bytes, zeros up to 64
    ldr  r5, wlJ_data
    mov  r0, r5
    movs r1, #68
    bl   wl_memset0
    movs r0, #32
    strb r0, [r5]
    mov  r0, r5
    adds r0, r0, #4
    mov  r1, r4
    adds r1, r1, #48
    movs r2, #32
    bl   wl_memcpy
    ldr  r0, wlJ_pmk
    movs r1, #2
    movs r2, #68
    bl   wl_ioctl
    mov  r5, r0
    ldr  r0, wlJ_data
    movs r1, #68
    bl   wl_memset0                 ; the key gone from the packet
    ldr  r6, wlJ_pmk
    cmp  r5, #0
    bne  wj_ioctl_err
    movs r0, #20                    ; SET_INFRA: 1
    movs r1, #1
    bl   wl_ioctl_u32
    movs r0, #22                    ; SET_AUTH: open
    movs r1, #0
    bl   wl_ioctl_u32
    adr  r0, wl_n_mfp
    movs r1, #1                     ; capable
    bl   wl_set_u32
    movs r0, #165                   ; SET_WPA_AUTH: WPA2-PSK
    movs r1, #0x80
    bl   wl_ioctl_u32
wj_ssid:
    ; SET_SSID: the length of the name (4 bytes), the name (32)
    ldr  r0, wlJ_data
    ldr  r1, [r4, #12]
    bl   wl_put32
    ldr  r0, wlJ_data
    adds r0, r0, #4
    mov  r1, r4
    adds r1, r1, #16
    movs r2, #32
    bl   wl_memcpy
    movs r0, #26
    movs r1, #2
    movs r2, #36
    bl   wl_ioctl
    mov  r5, r0
    movs r6, #26
    cmp  r5, #0
    bne  wj_ioctl_err
    bl   tick_now
    mov  r6, r0
wj_wait:
    bl   tick_now
    subs r0, r0, r6
    ldr  r1, wlJ_15s
    cmp  r0, r1
    bhs  wj_timeout
    bl   wl_poll
    cmp  r0, #0
    beq  wj_wait
    bl   wl_event                   ; r0 the event, r1 its status
    cmp  r2, #0
    beq  wj_wait
    bl   wl_diag_event              ; kept for the words of a failure
    cmp  r0, #0
    bne  wj_not_ssid
    cmp  r1, #0                     ; SET_SSID
    bne  wj_ssid_fail
    ldr  r2, [r4, #8]
    movs r3, #1
    tst  r2, r3
    beq  wj_wait                    ; WPA2: the key exchange still comes (PSK_SUP)
    b    wj_ok
wj_ssid_fail:
    ldr  r2, wlJ_wlv                ; the status of the event SET_SSID, said as the one of its ioctl (26)
    movs r0, #26
    str  r0, [r2, #WL_ECMD]
    str  r1, [r2, #WL_ESTAT]
    cmp  r1, #3                     ; no networks
    beq  wj_notfound
    adr  r0, wl_e_join
    b    wj_end
wj_not_ssid:
    cmp  r0, #46                    ; PSK_SUP
    bne  wj_not_psk
    cmp  r1, #6                     ; unsolicited: the keys are made
    beq  wj_ok
    cmp  r1, #4                     ; abort: comes before a success sometimes
    beq  wj_wait
    b    wj_badkey
wj_not_psk:
    cmp  r0, #3                     ; AUTH
    bne  wj_wait
    cmp  r1, #1                     ; fail
    bne  wj_wait
wj_badkey:
    adr  r0, wl_e_key
    b    wj_end
wj_notfound:
    adr  r0, wl_e_notfound
    b    wj_end
wj_timeout:
    adr  r0, wl_e_jointime
    b    wj_end
wj_ioctl_err:
    ldr  r1, wlJ_wlv                ; which one, and its status (wlan on says them)
    str  r6, [r1, #WL_ECMD]
    str  r5, [r1, #WL_ESTAT]
    adr  r0, wl_e_jioctl
    b    wj_end
wj_ok:
    ldr  r0, wlJ_mac                ; the MAC for the answers of wl_tick
    bl   wl_read_mac
    ldr  r1, wlJ_wlv
    ldr  r0, [r1, #WL_RPUT]
    str  r0, [r1, #WL_RGET]         ; the ring empty
    movs r0, #2
    str  r0, [r1, #WL_STATE]
    movs r0, #0
wj_end:
    pop  {r4, r5, r6, pc}

    align 4
wlJ_net:            dd WL_NET
wlJ_data:           dd WL_DATA
wlJ_wlv:            dd WLV
wlJ_2500:           dd 2500
wlJ_100ms:          dd 100000
wlJ_15s:            dd 15000000
wlJ_mac:            dd WLV + WL_MAC
wlJ_pmk:            dd 268                  ; SET_WSEC_PMK
wl_n_ampdu:
    db   'ampdu_ba_wsize', 0
    align 4
wl_n_supwpa:
    db   'bsscfg:sup_wpa', 0
    align 4
wl_n_eapver:
    db   'bsscfg:sup_wpa2_eapver', 0
    align 4
wl_n_wpatmo:
    db   'bsscfg:sup_wpa_tmo', 0
    align 4
wl_n_mfp:
    db   'mfp', 0
    align 4
wl_e_join:
    db   'The WiFi chip did not join the network.', 0
    align 4
wl_e_key:
    db   'The network did not take the key: is the password right?', 0
    align 4
wl_e_notfound:
    db   'The WiFi chip does not find the network (wlan scan shows the ones around).', 0
    align 4
wl_e_jointime:
    db   'The network did not answer within 15 seconds.', 0
    align 4
wl_e_jioctl:
    db   'The firmware of the WiFi chip did not take a command of the join.', 0
    align 4

; ---------- the command wlan ----------

; the line r0 (behind its spaces) of the terminal: the command wlan or name? r0 1 (done), else 0. WL_BUSY meanwhile
; (wl_tick waits)
wifi_command:
    push {r4, lr}
    mov  r4, r0
    bl   wifi_present               ; a board without a WiFi chip has no such commands (they are no commands there)
    cmp  r0, #0
    beq  wc_none
    mov  r0, r4
    bl   match_inline
    db   'wlan', 0
    align 2
    cmp  r0, #0
    beq  wc_name
    bl   wl_busy_on
    bl   cmd_wlan
    bl   wl_busy_off
    movs r0, #1
    pop  {r4, pc}
wc_name:
    mov  r0, r4
    bl   match_inline
    db   'name', 0
    align 2
    cmp  r0, #0
    beq  wc_passwd
    bl   wl_busy_on
    bl   cmd_name
    bl   wl_busy_off
    movs r0, #1
    pop  {r4, pc}
wc_passwd:
    mov  r0, r4
    bl   match_inline
    db   'passwd', 0
    align 2
    cmp  r0, #0
    beq  wc_none
    bl   wl_busy_on
    bl   cmd_passwd
    bl   wl_busy_off
    movs r0, #1
wc_none:
    pop  {r4, pc}


; wlan [on | off | scan | set | clear]: r0 the rest of the line
cmd_wlan:
    push {r4, lr}
    bl   skip_spaces
    mov  r4, r0
    bl   wl_net_load
    mov  r0, r4
    bl   match_inline
    db   'on', 0
    align 2
    cmp  r0, #0
    beq  cw_1
    bl   wn_connect
    pop  {r4, pc}
cw_1:
    mov  r0, r4
    bl   match_inline
    db   'off', 0
    align 2
    cmp  r0, #0
    beq  cw_2
    bl   esp_mode
    cmp  r0, #0
    beq  cw_off
    bl   esp_off
    pop  {r4, pc}
cw_off:
    bl   wl_off
    bl   print_inline
    db   'The WiFi chip is off.', 13, 10, 0
    align 2
    pop  {r4, pc}
cw_2:
    mov  r0, r4
    bl   match_inline
    db   'scan', 0
    align 2
    cmp  r0, #0
    beq  cw_3
    bl   wn_scan
    pop  {r4, pc}
cw_3:
    mov  r0, r4
    bl   match_inline
    db   'set', 0
    align 2
    cmp  r0, #0
    beq  cw_4
    bl   wn_set
    pop  {r4, pc}
cw_4:
    mov  r0, r4
    bl   match_inline
    db   'clear', 0
    align 2
    cmp  r0, #0
    beq  cw_5
    bl   wn_clear
    pop  {r4, pc}
cw_5:
    ldrb r0, [r4]
    cmp  r0, #0
    bne  cw_usage
    bl   wn_show
    pop  {r4, pc}
cw_usage:
    bl   print_inline
    db   'wlan, wlan on, wlan off, wlan scan, wlan set or wlan clear', 13, 10, 0
    align 2
    pop  {r4, pc}

; r0 1 when the board has a WiFi chip (V_WIFI bit 0: a W, or the ESP8285 of the clones "Pico W-2023"), else 0:
; wifi_command, the short help and info of the console
wifi_present:
    ldr  r0, wl50_wifi
    ldr  r0, [r0]
    movs r1, #1
    ands r0, r1
    bx   lr

    align 4
wl50_wifi:          dd VARS + V_WIFI

; the name of the network (WL_NET) to the terminal
wl_put_net:
    push {r4, r5, lr}
    ldr  r4, wl51_net
    ldr  r5, [r4, #12]
    adds r4, r4, #16
wpn_next:
    cmp  r5, #0
    beq  wpn_end
    ldrb r0, [r4]
    bl   put_char
    adds r4, r4, #1
    subs r5, r5, #1
    b    wpn_next
wpn_end:
    pop  {r4, r5, pc}

    align 4
wl51_net:           dd WL_NET

; wlan: the network kept and the state of the WiFi chip
wn_show:
    push {lr}
    ldr  r1, wl52_net
    ldr  r0, [r1, #12]              ; the length of the name of the network (0: a record with the name of the board only)
    cmp  r0, #0
    bne  wsh_net
    bl   print_inline
    db   'No network kept (wlan set: its name and its password).', 13, 10, 0
    align 2
    b    wsh_state
wsh_net:
    bl   print_inline
    db   'Network: ', 0
    align 2
    bl   wl_put_net
    ldr  r1, wl52_net
    ldr  r0, [r1, #8]
    movs r1, #1
    tst  r0, r1
    bne  wsh_open
    bl   print_inline
    db   ' (WPA2)', 13, 10, 0
    align 2
    b    wsh_state
wsh_open:
    bl   print_inline
    db   ' (open)', 13, 10, 0
    align 2
wsh_state:
    ldr  r1, wl52_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #1
    beq  wsh_on
    cmp  r0, #2
    beq  wsh_in
    bl   print_inline
    db   'The WiFi chip is off (wlan on: the chip and the network).', 13, 10, 0
    align 2
    pop  {pc}
wsh_on:
    bl   print_inline
    db   'The WiFi chip is on, in no network.', 13, 10, 0
    align 2
    pop  {pc}
wsh_in:
    bl   print_inline
    db   'The WiFi chip is in the network.', 13, 10, 0
    align 2
    ldr  r1, wl52_wlv
    ldr  r0, [r1, #WL_IP]
    cmp  r0, #0
    bne  wsh_ip
    bl   print_inline
    db   'No address (no DHCP server answered).', 13, 10, 0
    align 2
    pop  {pc}
wsh_ip:
    push {r4, r5}
    bl   wl_put_addr
    bl   print_inline
    db   'The console answered ', 0
    align 2
    ldr  r4, wl52_wlv
    ldr  r0, [r4, #WL_NARP]
    bl   put_dec
    bl   print_inline
    db   ' ARP requests and ', 0
    align 2
    ldr  r0, [r4, #WL_NPING]
    bl   put_dec
    bl   print_inline
    db   ' pings.', 13, 10, 0
    align 2
    pop  {r4, r5}
    pop  {pc}

    align 4
wl52_net:           dd WL_NET
wl52_wlv:           dd WLV

; wlan scan
wn_scan:
    push {lr}
    bl   wn_chip
    cmp  r0, #0
    bne  wsc2_end
    bl   print_inline
    db   'Scanning ...', 13, 10, 0
    align 2
    bl   esp_mode
    cmp  r0, #0
    beq  wsc2_cyw
    bl   esp_scan
    pop  {pc}
wsc2_cyw:
    bl   wl_scan
wsc2_end:
    pop  {pc}

; the chip on when it is off (with what wlan on says): r0 0, else 1 (it said why). The ESP8285: esp_chip
wn_chip:
    push {r4, r5, lr}
    bl   esp_mode
    cmp  r0, #0
    beq  wch_cyw
    bl   esp_chip
    pop  {r4, r5, pc}
wch_cyw:
    ldr  r1, wl54_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #0
    beq  wch_start
    movs r0, #0
    pop  {r4, r5, pc}
wch_start:
    bl   print_inline
    db   'The firmware goes into the WiFi chip ...', 13, 10, 0
    align 2
    bl   wlan_start
    cmp  r0, #0
    beq  wch_ok
    bl   put_text
    bl   put_nl
    movs r0, #1
    pop  {r4, r5, pc}
wch_ok:
    bl   print_inline
    db   'The firmware (', 0
    align 2
    ldr  r4, wl54_wlv
    ldr  r0, [r4, #WL_FWLEN]
    bl   put_dec
    bl   print_inline
    db   ' bytes) went in in ', 0
    align 2
    ; the microseconds as seconds with a tenth
    ldr  r0, [r4, #WL_TIME]
    ldr  r2, wl54_100ms
    movs r5, #0
wch_tenths:
    cmp  r0, r2
    blo  wch_secs
    subs r0, r0, r2
    adds r5, r5, #1
    b    wch_tenths
wch_secs:
    movs r0, #0
wch_tens:
    cmp  r5, #10
    blo  wch_put
    subs r5, r5, #10
    adds r0, r0, #1
    b    wch_tens
wch_put:
    bl   put_dec
    movs r0, #'.'
    bl   put_char
    mov  r0, r5
    bl   put_dec
    bl   print_inline
    db   ' s; it runs (its HT clock after ', 0
    align 2
    ldr  r0, [r4, #WL_HT]
    bl   put_dec
    bl   print_inline
    db   ' ms).', 13, 10, 0
    align 2
    movs r0, #0
    pop  {r4, r5, pc}

    align 4
wl54_100ms:         dd 100000
wl54_wlv:           dd WLV

; wlan on (and after wlan set): the chip, then the network kept
wn_connect:
    push {r4, lr}
    bl   wn_chip
    cmp  r0, #0
    beq  wfar1
    b    wco_end
wfar1:
    ldr  r1, wl55_net
    ldr  r0, [r1, #12]              ; a network kept (the length of its name)
    cmp  r0, #0
    bne  wco_join
    bl   print_inline
    db   'No network kept (wlan set: its name and its password).', 13, 10, 0
    align 2
    pop  {r4, pc}
wco_join:
    bl   print_inline
    db   'Joining ', 0
    align 2
    bl   wl_put_net
    bl   print_inline
    db   ' ...', 13, 10, 0
    align 2
    bl   wl_join_tries
    cmp  r0, #0
    bne  wco_fail
wco_in:
    bl   print_inline
    db   'The board is in the network ', 0
    align 2
    bl   wl_put_net
    bl   print_inline
    db   '.', 13, 10, 'An address by DHCP ...', 13, 10, 0
    align 2
    bl   wl_dhcp
    cmp  r0, #0
    beq  wco_addr
    bl   print_inline
    db   'No DHCP server answered: the board has no address (ARP and ping get no answer).', 13, 10, 0
    align 2
    pop  {r4, pc}
wco_addr:
    bl   wl_put_addr
    pop  {r4, pc}
wco_fail:
    bl   put_text
    ldr  r1, wl55_wlv
    ldr  r0, [r1, #WL_ECMD]
    cmp  r0, #0
    bne  wco_cmd
    bl   wl_diag_any                ; no command failed: the events, when some came
    cmp  r0, #0
    beq  wco_nl
    bl   print_inline
    db   ' (events', 0
    align 2
    bl   wl_put_diag
    movs r0, #')'
    bl   put_char
    b    wco_nl
wco_cmd:
    bl   print_inline
    db   ' (command ', 0
    align 2
    ldr  r1, wl55_wlv
    ldr  r0, [r1, #WL_ECMD]
    bl   put_dec
    bl   print_inline
    db   ', status ', 0
    align 2
    ldr  r1, wl55_wlv
    ldr  r0, [r1, #WL_ESTAT]
    cmp  r0, #0
    bge  wco_stat
    push {r0}
    movs r0, #'-'
    bl   put_char
    pop  {r0}
    rsbs r0, r0, #0
wco_stat:
    bl   put_dec
    bl   wl_put_diag
    movs r0, #')'
    bl   put_char
    ldr  r1, wl55_wlv
    movs r0, #0
    str  r0, [r1, #WL_ECMD]
wco_nl:
    bl   put_nl
wco_end:
    pop  {r4, pc}

    align 4
wl55_wlv:           dd WLV
wl55_net:           dd WL_NET

; the network of WL_NET joined (wl_join), up to five tries: right after the start the firmware fails a join now and
; then (SET_SSID: once more, a second later). r0 0, else the text of what went wrong (WL_ECMD, WL_ESTAT)
wl_join_tries:
    push {r4, lr}
    movs r4, #5
wjt_try:
    ldr  r1, wl58_wlv
    movs r0, #0
    str  r0, [r1, #WL_ECMD]
    bl   wl_join
    cmp  r0, #0
    beq  wjt_end
    subs r4, r4, #1
    beq  wjt_end
    ldr  r1, wl58_wlv
    ldr  r1, [r1, #WL_ECMD]
    cmp  r1, #26
    bne  wjt_end
    ldr  r0, wl58_1s
    bl   wl_wait
    b    wjt_try
wjt_end:
    pop  {r4, pc}

    align 4
wl58_wlv:           dd WLV
wl58_1s:            dd 1000000

; some events of a join kept (WL_DIAG)? r0 not 0
wl_diag_any:
    ldr  r1, wlD_diag
    ldr  r0, [r1]
    ldr  r2, [r1, #4]
    orrs r0, r2
    ldr  r2, [r1, #8]
    orrs r0, r2
    ldr  r2, [r1, #12]
    orrs r0, r2
    bx   lr

; the events of a join kept (WL_DIAG) cleared: at the start of each try
wl_diag_clear:
    ldr  r0, wlD_diag
    movs r1, #0
    str  r1, [r0]
    str  r1, [r0, #4]
    str  r1, [r0, #8]
    str  r1, [r0, #12]
    bx   lr

; the event r0 (its status r1, its data r2: the message 48 bytes before them, its reason at +12 big endian) of a
; join kept for the words of a failure: AUTH, ASSOC or REASSOC, SET_SSID, PSK_SUP (bit 31, the reason in bits 23 .. 8,
; the status in bits 7 .. 0). r0 .. r2 stay
wl_diag_event:
    push {r0, r1, r2, r4, lr}
    movs r4, #0
    cmp  r0, #3                     ; AUTH
    beq  wde_keep
    movs r4, #4
    cmp  r0, #7                     ; ASSOC
    beq  wde_keep
    cmp  r0, #9                     ; REASSOC
    beq  wde_keep
    movs r4, #8
    cmp  r0, #0                     ; SET_SSID
    beq  wde_keep
    movs r4, #12
    cmp  r0, #46                    ; PSK_SUP
    bne  wde_end
wde_keep:
    subs r2, r2, #48
    ldrb r3, [r2, #14]
    ldrb r0, [r2, #15]
    lsls r3, r3, #8
    orrs r3, r0                     ; the reason (its low 16 bits)
    lsls r3, r3, #8
    movs r0, #0xff
    ands r1, r0
    orrs r3, r1
    movs r0, #1
    lsls r0, r0, #31
    orrs r3, r0
    ldr  r0, wlD_diag
    str  r3, [r0, r4]
wde_end:
    pop  {r0, r1, r2, r4, pc}

; the events kept (wl_diag_event), each that came: "; AUTH status 0 reason 0, ASSOC status 1 reason 17 ..." (the
; status of the firmware: 0 success, 1 fail, 2 timeout ...; the reason: for AUTH and ASSOC the status code of the
; access point in IEEE 802.11)
wl_put_diag:
    push {r4, r5, lr}
    movs r5, #0
wpd_next:
    ldr  r0, wlD_diag
    ldr  r4, [r0, r5]
    cmp  r4, #0
    beq  wpd_skip
    cmp  r5, #0
    bne  wpd_1
    bl   print_inline
    db   '; AUTH', 0
    align 2
    b    wpd_vals
wpd_1:
    cmp  r5, #4
    bne  wpd_2
    bl   print_inline
    db   '; ASSOC', 0
    align 2
    b    wpd_vals
wpd_2:
    cmp  r5, #8
    bne  wpd_3
    bl   print_inline
    db   '; SET_SSID', 0
    align 2
    b    wpd_vals
wpd_3:
    bl   print_inline
    db   '; PSK_SUP', 0
    align 2
wpd_vals:
    bl   print_inline
    db   ' status ', 0
    align 2
    movs r0, #0xff
    ands r0, r4
    bl   put_dec
    bl   print_inline
    db   ' reason ', 0
    align 2
    lsls r0, r4, #8
    lsrs r0, r0, #16                ; bits 23 .. 8
    bl   put_dec
wpd_skip:
    adds r5, r5, #4
    cmp  r5, #16
    blo  wpd_next
    pop  {r4, r5, pc}

    align 4
wlD_diag:           dd WLV + WL_DIAG

; wlan set: the name of a network and its password (without an echo; Ctrl+C: nothing changes). The console keeps the
; name and the key (PBKDF2-SHA1, as WPA2 makes it), not the password: WL_SECRET and the rings are cleared at once. An
; empty password: an open network. Then the chip joins it
wn_set:
    push {r4, r5, lr}
    bl   print_inline
    db   'The name of the network: ', 0
    align 2
    bl   read_line
    mov  r4, r0
    movs r5, #0
wst_len:
    ldrb r0, [r4, r5]
    cmp  r0, #0
    beq  wst_name
    adds r5, r5, #1
    b    wst_len
wst_name:
    cmp  r5, #0
    bne  wst_some
    b    wst_same
wst_some:
    cmp  r5, #32
    bls  wst_ok
    bl   print_inline
    db   'A name of a network has at most 32 characters: nothing changed.', 13, 10, 0
    align 2
    pop  {r4, r5, pc}
wst_ok:
    ldr  r0, wl56_net
    movs r1, #80                    ; the network; the name of the board (+80) and the password (+112) stay
    bl   wl_memset0
    ldr  r0, wl56_net
    str  r5, [r0, #12]
    adds r0, r0, #16
    mov  r1, r4
    mov  r2, r5
    bl   wl_memcpy
    bl   print_inline
    db   'Its password (8 to 63 characters, not shown; Enter alone: an open network): ', 0
    align 2
    bl   wl_read_secret
    cmp  r0, #0
    bge  wst_typed
    b    wst_cancel
wst_typed:
    ldr  r1, wl56_wlv
    str  r0, [r1, #WL_SECLEN]
    cmp  r0, #0
    bne  wst_key
    ldr  r0, wl56_net
    movs r1, #1
    str  r1, [r0, #8]               ; open
    b    wst_save
wst_key:
    cmp  r0, #8
    blo  wst_badpw
    cmp  r0, #63
    bhi  wst_badpw
    bl   print_inline
    db   'The key of WPA2 is made of it (some seconds) ...', 13, 10, 0
    align 2
    bl   wl_pbkdf2
    bl   wl_forget
wst_save:
    bl   wl_net_save
    cmp  r0, #0
    bne  wst_err
    bl   print_inline
    db   'The board keeps the network ', 0
    align 2
    bl   wl_put_net
    bl   print_inline
    db   ' (the key, not the password).', 13, 10, 0
    align 2
    bl   wn_connect
    pop  {r4, r5, pc}
wst_err:
    bl   put_text
    bl   put_nl
    bl   wl_net_load                ; the record as it was
    pop  {r4, r5, pc}
wst_badpw:
    bl   wl_forget
    bl   print_inline
    db   'A password of WPA2 has 8 to 63 characters: nothing changed.', 13, 10, 0
    align 2
    bl   wl_net_load
    pop  {r4, r5, pc}
wst_cancel:
    bl   wl_forget
wst_same:
    bl   print_inline
    db   'Nothing changed.', 13, 10, 0
    align 2
    bl   wl_net_load
    pop  {r4, r5, pc}

    align 4
wl56_net:           dd WL_NET
wl56_wlv:           dd WLV

; wlan clear: the board keeps no network; out of the one it is in
wn_clear:
    push {lr}
    bl   wl_net_clear
    cmp  r0, #0
    beq  wcl2_done
    bl   put_text
    bl   put_nl
    pop  {pc}
wcl2_done:
    ldr  r1, wl57_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #2
    bne  wcl2_say
    movs r0, #52                    ; DISASSOC
    movs r1, #2
    movs r2, #0
    bl   wl_ioctl
    ldr  r1, wl57_wlv
    movs r0, #1
    str  r0, [r1, #WL_STATE]
wcl2_say:
    bl   print_inline
    db   'The board keeps no network now.', 13, 10, 0
    align 2
    pop  {pc}

    align 4
wl57_wlv:           dd WLV

; ---------- the WiFi for programs ----------
;
; wl_call(op, a, b, c) of the functions for programs (+52, STUBS + 0xD0; examples_internal/abelle/pico/inc/wifi.abel builds the
; functions of the ESP32 on it: wifi_connect_saved, wifi_send, wifi_recv ...): r0 the operation, r1 .. r3 its
; arguments, r0 the result.
;   0 status              bit 0: the board is in the network, bit 1: the chip runs, bit 24: the console keeps them
;                         (the chip and the network stay after a program); 0 on a board without WiFi
;   1 connect             the chip on when it is off, the network kept joined when the board is in none (as wlan on,
;                         without its words): 0, else a WLE_ below (its text: 8)
;   2 off                 the chip off (as wlan off): 0
;   3 send(frame, n)      an Ethernet frame (destination, source, type, data; no FCS; up to 1514 bytes): 0, else WLE_
;   4 recv(buf, max, ms)  the next frame that came (up to max bytes of it into buf), waiting for it up to ms
;                         milliseconds: its length, 0 when none came. An event DEAUTH or DISASSOC on the way: the board
;                         is in no network (bit 0 of the status)
;   5 mac(buf)            the MAC of the chip into the 6 bytes at buf (the chip on when it is off): 0, else WLE_
;   6 set_ip(p)           the IPv4 address of the board (the 4 bytes at p; zeros: none), kept for the console: 0
;   7 get_ip(p)           ... into the 4 bytes at p: 1, 0 when there is none
;   8 error text          the text of the last WLE_ (0: none)
;   9 login set           a password for telnet set (passwd set)? 1, else 0
;   10 login check(p)     the text p the password for telnet? 1, else 0 (about 2 s: its key as passwd makes it)
;   11 scan(buf, max)     the networks around (as wlan scan, the chip on when it is off; some seconds), each BSSID
;                         once, up to max of them into buf as records of 48 bytes, as wifi_scan of the ESP32 gives
;                         them (wl_put_bss): their number, else minus a WLE_ (console_version 4)
;   12 pings              how many pings (echo requests to the board) the console answered since the start
;                         (console_version 5)
; A frame goes on channel 2 of the bus: the SDPCM header (12 bytes; its header length 14: the drivers put 2 bytes of
; padding behind it, else the firmware adds two zeros to the frame), the BDC header (4 bytes: 0x20, its version 2), the
; frame. A frame that comes: the BDC header at the header length, the frame behind it and 4 * its byte 3 more bytes.
WLE_LINK        equ 0x7F6               ; the network did not take the board (the text says why)
WLE_FILES       equ 0x7F9               ; the chip did not start (its files? the text says why)
WLE_NONET       equ 0x7FA               ; the board keeps no network (wlan set)
WLE_NOWIFI      equ 0x7FB               ; the board has no WiFi chip
WLE_OFF         equ 0x7FC               ; send: the board is in no network
WLE_LEN         equ 0x7FD               ; send: the frame is longer than 1514 bytes
WLE_CHIP        equ 0x7FE               ; the firmware did not answer
WL_FTX          equ DIRBUF + 0x2100     ; a frame to the chip: 18 bytes of headers, up to 1514 of the frame

api_wifi:
    push {lr}
    bl   wl_busy_on                 ; wl_tick waits meanwhile (wl_abort clears it after Ctrl+C)
    bl   wl_api
    bl   wl_busy_off
    pop  {pc}
wl_api:
    push {r4, r5, r6, r7, lr}
    mov  r4, r1
    mov  r5, r2
    mov  r6, r3
    ldr  r7, wlA_wlv
    ldr  r3, wlA_wifi
    ldr  r3, [r3]
    movs r2, #1
    tst  r3, r2
    bne  wa_w
    cmp  r0, #0
    beq  wa_zero                    ; the status of a board without WiFi: 0
    cmp  r0, #8
    beq  wa_notext
    ldr  r0, wlA_e_nowifi
    b    wa_end
wa_notext:
    adr  r0, wl_e_nowifi
    b    wa_end
wa_w:
    cmp  r0, #0
    beq  wa_status
    cmp  r0, #1
    beq  wa_connect
    cmp  r0, #2
    beq  wa_off
    cmp  r0, #6
    beq  wa_set_ip
    cmp  r0, #7
    beq  wa_get_ip
    cmp  r0, #8
    beq  wa_text
    cmp  r0, #9
    beq  wa_login_set
    cmp  r0, #10
    beq  wa_login_check
    cmp  r0, #12
    beq  wa_pings
    cmp  r0, #3                     ; (3 .. 5 last: their code lies farthest)
    beq  wa_send
    cmp  r0, #4
    beq  wa_recv
    cmp  r0, #5
    beq  wa_mac
    cmp  r0, #11
    bne  wa_unknown
    b    wa_scan                    ; (far: behind wa_mac)
wa_unknown:
    movs r0, #0
    mvns r0, r0
    b    wa_end
wa_login_set:
    bl   wl_net_load
    bl   wl_login_set
    b    wa_end
wa_login_check:
    mov  r0, r4
    bl   wl_login_check
    b    wa_end
wa_zero:
    movs r0, #0
wa_end:
    pop  {r4, r5, r6, r7, pc}
wa_status:
    ldr  r1, [r7, #WL_STATE]
    movs r0, #1
    lsls r0, r0, #24
    cmp  r1, #0
    beq  wa_end
    adds r0, r0, #2
    cmp  r1, #2
    bne  wa_end
    adds r0, r0, #1
    b    wa_end
wa_off:
    bl   wl_off
    b    wa_zero
wa_text:
    ldr  r0, [r7, #WL_ETEXT]
    b    wa_end
wa_pings:
    ldr  r0, [r7, #WL_NPING]
    b    wa_end
wa_set_ip:
    mov  r0, r7
    adds r0, r0, #WL_IP
    mov  r1, r4
    movs r2, #4
    bl   wl_memcpy
    b    wa_zero
wa_get_ip:
    mov  r0, r4
    mov  r1, r7
    adds r1, r1, #WL_IP
    movs r2, #4
    bl   wl_memcpy
    ldr  r0, [r7, #WL_IP]
    cmp  r0, #0
    beq  wa_end
    movs r0, #1
    b    wa_end
wa_connect:
    bl   wl_net_load
    ldr  r0, [r7, #WL_STATE]
    cmp  r0, #2
    beq  wa_zero                    ; in the network already
    cmp  r0, #0
    bne  wac_join
    bl   wlan_start
    cmp  r0, #0
    bne  wa_e_files
wac_join:
    ldr  r0, wlA_net
    ldr  r0, [r0, #12]              ; a network kept (the length of its name)
    cmp  r0, #0
    beq  wa_e_nonet
    bl   wl_join_tries
    cmp  r0, #0
    bne  wac_fail
    bl   wl_dhcp                    ; the address for the console (ARP, ping); dhcp_run of a program asks again
    b    wa_zero
wac_fail:
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_link
    b    wa_end
wa_e_files:
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_files
    b    wa_end
wa_e_nonet:
    adr  r0, wl_e_nonet
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_nonet
    b    wa_end
wa_send:
    ldr  r0, [r7, #WL_STATE]
    cmp  r0, #2
    bne  wa_e_off
    ldr  r0, wlA_1514
    cmp  r5, r0
    bhi  wa_e_len
    mov  r0, r4
    mov  r1, r5
    bl   wl_send_frame
    cmp  r0, #0
    beq  wa_end
    adr  r0, wl_e_credit
wa_e_chip:
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_chip
    b    wa_end
wa_e_off:
    adr  r0, wl_e_off
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_off
    b    wa_end
wa_e_len:
    adr  r0, wl_e_len
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_len
    b    wa_end
wa_recv:
    ldr  r0, [r7, #WL_STATE]
    cmp  r0, #0
    beq  wa_zero
    mov  r0, r4
    mov  r1, r5
    mov  r2, r6
    bl   wl_recv_frame
    b    wa_end
wa_mac:
    ldr  r0, [r7, #WL_STATE]
    cmp  r0, #0
    bne  wam_on
    bl   wlan_start
    cmp  r0, #0
    bne  wa_e_files
wam_on:
    mov  r0, r4
    bl   wl_read_mac
    cmp  r0, #0
    bne  wam_err
    b    wa_zero
wam_err:
    adr  r0, wl_e_noanswer
    b    wa_e_chip
wa_scan:
    ldr  r0, [r7, #WL_STATE]
    cmp  r0, #0
    bne  was_on
    bl   wlan_start
    cmp  r0, #0
    beq  was_on
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_files
    rsbs r0, r0, #0
    b    wa_end
was_on:
    ldr  r3, wlA_sout
    str  r4, [r3]                   ; WL_SOUT: the buffer
    str  r5, [r3, #4]               ; WL_SMAX
    movs r0, #0
    str  r0, [r3, #8]               ; WL_SCNT
    bl   esp_mode
    cmp  r0, #0
    beq  was_cyw
    bl   esp_scan
    b    was_done
was_cyw:
    bl   wl_scan
was_done:
    ldr  r3, wlA_sout
    ldr  r0, [r3, #8]               ; the records, -1: the scan did not start
    movs r1, #0
    str  r1, [r3]                   ; wlan scan shows lines again
    cmp  r0, #0
    blt  was_err
    b    wa_end
was_err:
    adr  r0, wl_e_noscan
    str  r0, [r7, #WL_ETEXT]
    ldr  r0, wlA_e_chip
    rsbs r0, r0, #0
    b    wa_end

; the MAC of the chip (the iovar cur_etheraddr) into the 6 bytes at r0: r0 0, else the status
wl_read_mac:
    push {r4, lr}
    mov  r4, r0
    bl   esp_mode                   ; the ESP8285: its state S (esp_mac)
    cmp  r0, #0
    beq  wrm_cyw
    mov  r0, r4
    bl   esp_mac
    pop  {r4, pc}
wrm_cyw:
    adr  r0, wl_n_ether
    ldr  r1, wlA_data
    bl   wl_copy_name
    mov  r2, r0                     ; 14 bytes: more than the 6 of the answer
    ldr  r0, wlA_getvar
    movs r1, #0
    bl   wl_ioctl
    cmp  r0, #0
    bne  wrm_end
    ldr  r3, wlA_wlv
    ldr  r1, [r3, #WL_RESP]
    mov  r0, r4
    movs r2, #6
    bl   wl_memcpy
    movs r0, #0
wrm_end:
    pop  {r4, pc}

    align 4
wlA_wlv:            dd WLV
wlA_wifi:           dd VARS + V_WIFI
wlA_net:            dd WL_NET
wlA_data:           dd WL_DATA
wlA_getvar:         dd 262
wlA_1514:           dd 1514
wlA_e_link:         dd WLE_LINK
wlA_e_files:        dd WLE_FILES
wlA_e_nonet:        dd WLE_NONET
wlA_e_nowifi:       dd WLE_NOWIFI
wlA_e_off:          dd WLE_OFF
wlA_e_len:          dd WLE_LEN
wlA_e_chip:         dd WLE_CHIP
wlA_sout:           dd WLV + WL_SOUT
wl_n_ether:
    db   'cur_etheraddr', 0
    align 4
wl_e_nowifi:
    db   'This board has no WiFi chip (a Pico W and a Pico 2 W have one).', 0
    align 4
wl_e_nonet:
    db   'The board keeps no network (wlan set in the console: its name and its password).', 0
    align 4
wl_e_credit:
    db   'The WiFi chip took no frame within a second.', 0
    align 4
wl_e_off:
    db   'The board is in no network (wifi_connect_saved first).', 0
    align 4
wl_e_len:
    db   'A frame has at most 1514 bytes.', 0
    align 4
wl_e_noanswer:
    db   'The firmware of the WiFi chip did not answer.', 0
    align 4
wl_e_noscan:
    db   'The WiFi chip did not start the scan.', 0
    align 4

; the Ethernet frame r0 (r1 bytes, up to 1514) to the chip, when it has the credit (waits for it up to a second; the
; packets that come meanwhile go through wl_service_one): r0 0, else -1
wl_send_frame:
    push {r4, r5, r6, lr}
    mov  r5, r0
    mov  r6, r1
    bl   tick_now
    mov  r4, r0
wsf_credit:
    bl   wl_credit
    cmp  r0, #0
    bne  wsf_go
    bl   wl_service_one
    bl   tick_now
    subs r0, r0, r4
    ldr  r1, wlB_1s
    cmp  r0, r1
    blo  wsf_credit
    movs r0, #0
    mvns r0, r0
    pop  {r4, r5, r6, pc}
wsf_go:
    mov  r0, r5
    mov  r1, r6
    bl   wl_send_now
    movs r0, #0
    pop  {r4, r5, r6, pc}

; the chip takes a packet now (its credit: 1 .. 127 ahead)? r0 1, else 0
wl_credit:
    ldr  r3, wlB_wlv
    ldr  r0, [r3, #WL_SEQMAX]
    ldr  r1, [r3, #WL_SEQ]
    subs r0, r0, r1
    movs r2, #0xff
    ands r0, r2
    beq  wcr_no
    cmp  r0, #0x80
    bhs  wcr_no
    movs r0, #1
    bx   lr
wcr_no:
    movs r0, #0
    bx   lr

; the Ethernet frame r0 (r1 bytes) to the chip now (it has the credit: wl_credit), through WL_FTX
wl_send_now:
    push {r4, r5, r6, r7, lr}
    mov  r5, r0
    mov  r6, r1
    bl   esp_mode                   ; the ESP8285: the frame F over UART0 (it always has the credit: WL_SEQMAX)
    cmp  r0, #0
    beq  wsn_cyw
    movs r0, #'F'
    mov  r1, r5
    mov  r2, r6
    bl   esp_send
    pop  {r4, r5, r6, r7, pc}
wsn_cyw:
    ldr  r4, wlB_ftx
    mov  r0, r4
    adds r0, r0, #18
    mov  r1, r5
    mov  r2, r6
    bl   wl_memcpy
    adds r6, r6, #18                ; the length of the packet
    strh r6, [r4]
    mvns r0, r6
    strh r0, [r4, #2]
    ldr  r3, wlB_wlv
    ldr  r1, [r3, #WL_SEQ]
    strb r1, [r4, #4]
    adds r1, r1, #1
    movs r2, #0xff
    ands r1, r2
    str  r1, [r3, #WL_SEQ]
    movs r1, #2
    strb r1, [r4, #5]               ; channel 2: data
    movs r1, #0
    strb r1, [r4, #6]
    movs r1, #14
    strb r1, [r4, #7]               ; the length of the header: 12 and the 2 bytes of padding
    movs r1, #0
    str  r1, [r4, #8]
    strh r1, [r4, #12]
    movs r1, #0x20
    strb r1, [r4, #14]              ; BDC: version 2
    movs r1, #0
    strb r1, [r4, #15]              ; ... the priority
    strb r1, [r4, #16]              ; ... flags
    strb r1, [r4, #17]              ; ... the frame right behind it
    adds r6, r6, #3
    lsrs r7, r6, #2                 ; the words
    lsls r0, r7, #2
    ldr  r1, wlB_f2_wr
    orrs r0, r1
    ldr  r1, wlB_sio
    ldr  r2, wlB_cs
    str  r2, [r1, #SIO_OUT_CLR]     ; CS low
    bl   wl_tx32
wsn_word:
    ldr  r0, [r4]
    adds r4, r4, #4
    bl   wl_tx32
    subs r7, r7, #1
    bne  wsn_word
    ldr  r1, wlB_sio
    ldr  r2, wlB_cs
    str  r2, [r1, #SIO_OUT_SET]     ; CS high
    pop  {r4, r5, r6, r7, pc}

; the next frame into r0 (up to r1 bytes of it), waiting for it up to r2 milliseconds: r0 its length, 0 when none
; came. From the ring (wl_tick put it there) or from the chip (wl_service_one: ARP and ping for the board answered)
wl_recv_frame:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0
    mov  r5, r1
    ldr  r1, wlB_1000
    muls r2, r1
    mov  r6, r2                     ; the microseconds
    bl   tick_now
    mov  r7, r0
wrf_loop:
    mov  r0, r4
    mov  r1, r5
    bl   wl_ring_get
    cmp  r0, #0
    bne  wrf_end
    bl   wl_service_one
    mov  r0, r4
    mov  r1, r5
    bl   wl_ring_get
    cmp  r0, #0
    bne  wrf_end
    bl   tick_now
    subs r0, r0, r7
    cmp  r0, r6
    blo  wrf_loop
    movs r0, #0
wrf_end:
    pop  {r4, r5, r6, r7, pc}

; a program stopped (Ctrl+C, a fault), perhaps in the middle of a talk to the WiFi chip: WL_BUSY 0 (wl_tick goes on),
; no buffer of a scan (wlan scan shows lines again), CS high, the clock low. The pins on a W only (on a Pico GPIO 25 is
; the LED)
wl_abort:
    ldr  r1, wlB_wlv
    movs r0, #0
    str  r0, [r1, #WL_BUSY]
    ldr  r1, wlB_sout
    str  r0, [r1]
    ldr  r1, wlB_wifi
    ldr  r0, [r1]
    movs r2, #1
    tst  r0, r2
    beq  wab_end
    ldr  r1, wlB_esp                ; (not with the ESP8285: GPIO 25 is the LED there)
    ldr  r1, [r1]
    cmp  r1, #0
    bne  wab_end
    ldr  r1, wlB_sio
    ldr  r2, wlB_cs
    str  r2, [r1, #SIO_OUT_SET]
    ldr  r2, wlB_clk
    str  r2, [r1, #SIO_OUT_CLR]
wab_end:
    bx   lr

; WL_BUSY 1, then 0: the console or a program talks to the chip, wl_tick waits (r0 .. r3 stay)
wl_busy_on:
    push {r0, r1}
    ldr  r0, wlB_wlv
    movs r1, #1
    str  r1, [r0, #WL_BUSY]
    pop  {r0, r1}
    bx   lr
wl_busy_off:
    push {r0, r1}
    ldr  r0, wlB_wlv
    movs r1, #0
    str  r1, [r0, #WL_BUSY]
    pop  {r0, r1}
    bx   lr

    align 4
wlB_wlv:            dd WLV
wlB_wifi:           dd VARS + V_WIFI
wlB_esp:            dd WLV + WL_ESP
wlB_sout:           dd WLV + WL_SOUT
wlB_ftx:            dd WL_FTX
wlB_1s:             dd 1000000
wlB_1000:           dd 1000
wlB_sio:            dd WL_SIO
wlB_cs:             dd 1 << 25
wlB_clk:            dd 1 << 29
wlB_f2_wr:          dd 0xe0000000           ; write, counting up, function 2

; ---------- the frames while the console waits or a program runs: SysTick ----------
;
; On a W SysTick comes every 10 ms (wl_tick_init at the start of the console; the clock of the core, 48 MHz). While
; the board is in a network and neither the console nor a program talks to the chip (WL_BUSY 0), wl_tick takes up to
; four packets of the chip (wl_service_one): an ARP request for the address of the board (WL_IP: the program said it
; by wifi_set_ip, dhcp_run of inc/net.abel) and an echo request (a ping) to it are answered at once, the other frames
; go into the ring (WL_RING: 4 frames; more are lost) until wifi_recv takes them; an event DEAUTH or DISASSOC takes the
; board out of the network. So the board answers ARP and ping at the prompt of the console, while a program runs (also
; one that does not look at the network) and while it stands at a breakpoint (the debug monitor has the lowest
; priority). An answer that finds no credit of the chip is left out (an interrupt does not wait). A frame takes some
; milliseconds over the SPI by hand; a network with many broadcasts costs a program that much of its time.
WL_RING         equ DIRBUF + 0x2800     ; 4 frames of up to 1532 bytes, each behind its length (a word): 6 KB
WL_RSLOT        equ 0x600
SYST            equ 0xe000e010          ; SysTick: +0 CSR, +4 RVR, +8 CVR

wl_tick_init:
    ldr  r0, wlC_vec
    ldr  r1, wlC_tick
    str  r1, [r0]                   ; its entry in the vector table (15)
    ldr  r0, wlC_syst
    ldr  r1, wlC_reload
    str  r1, [r0, #4]
    movs r1, #0
    str  r1, [r0, #8]
    movs r1, #7                     ; on, its interrupt, the clock of the core
    str  r1, [r0]
    bx   lr

; SysTick (an exception: r0 .. r3, r12, lr saved by the core)
wl_tick:
    push {r4, lr}
    ldr  r3, wlC_wlv
    ldr  r0, [r3, #WL_BUSY]
    cmp  r0, #0
    bne  wtk_end
    ldr  r0, [r3, #WL_STATE]
    cmp  r0, #2
    bne  wtk_end
    movs r0, #1
    str  r0, [r3, #WL_BUSY]
    movs r4, #4
wtk_next:
    bl   wl_service_one
    cmp  r0, #0
    beq  wtk_free
    subs r4, r4, #1
    bne  wtk_next
wtk_free:
    ldr  r3, wlC_wlv
    movs r0, #0
    str  r0, [r3, #WL_BUSY]
wtk_end:
    pop  {r4, pc}

; one packet of the chip, when one waits (WL_BUSY is set): an event (DEAUTH, DISASSOC: the board in no network), a
; frame (ARP and ping for the board answered, wl_answer; else into the ring). r0 1, 0 when none waited
wl_service_one:
    push {r4, r5, lr}
    bl   esp_mode                   ; the ESP8285: a frame from its ring (esp_service)
    cmp  r0, #0
    beq  wso_cyw
    bl   esp_service
    pop  {r4, r5, pc}
wso_cyw:
    bl   wl_poll
    cmp  r0, #0
    beq  wso_none
    ldr  r3, wlC_rx
    ldrb r0, [r3, #5]
    movs r1, #0x0f
    ands r0, r1
    cmp  r0, #2
    beq  wso_data
    cmp  r0, #1
    bne  wso_done
    bl   wl_event                   ; r0 the event
    cmp  r2, #0
    beq  wso_done
    cmp  r0, #5
    beq  wso_out
    cmp  r0, #6
    beq  wso_out
    cmp  r0, #11
    beq  wso_out
    cmp  r0, #12
    bne  wso_done
wso_out:
    ldr  r3, wlC_wlv
    ldr  r0, [r3, #WL_STATE]
    cmp  r0, #2
    bne  wso_done
    movs r0, #1
    str  r0, [r3, #WL_STATE]
    b    wso_done
wso_data:
    ldrh r0, [r3]                   ; the length of the packet
    adds r0, r3, r0                 ; its end
    ldrb r1, [r3, #7]
    adds r2, r3, r1                 ; the BDC header
    ldrb r1, [r2, #3]
    lsls r1, r1, #2
    adds r1, r1, #4
    adds r4, r2, r1                 ; the frame
    subs r5, r0, r4                 ; its length
    ble  wso_done
    mov  r0, r4
    mov  r1, r5
    bl   wl_answer
    cmp  r0, #0
    bne  wso_done
    mov  r0, r4
    mov  r1, r5
    bl   wl_ring_put
wso_done:
    movs r0, #1
    pop  {r4, r5, pc}
wso_none:
    movs r0, #0
    pop  {r4, r5, pc}

; the frame r0 (r1 bytes) an ARP request for the address of the board, or an echo request to it? Then the answer
; goes (in its place: the same frame turned round, when the chip has the credit) and r0 1; else r0 0
wl_answer:
    push {r4, r5, r6, lr}
    mov  r4, r0
    mov  r5, r1
    ldr  r6, wlC_wlv
    ldr  r0, [r6, #WL_IP]
    cmp  r0, #0
    bne  wan_ip
    b    wan_no                     ; no address yet
wan_ip:
    cmp  r5, #42
    bhs  wfar2
    b    wan_no
wfar2:
    ldrb r0, [r4, #12]
    ldrb r1, [r4, #13]
    cmp  r0, #8
    bne  wan_udp_no
    cmp  r1, #6
    beq  wan_arp
    cmp  r1, #0
    bne  wan_udp_no
    ; IPv4: UDP (a question of mDNS for the name of the board: wl_mdns), or protocol 1 (ICMP) to us, type 8 (echo
    ; request)
    ldrb r0, [r4, #23]
    cmp  r0, #17
    bne  wan_icmp
    mov  r0, r4
    mov  r1, r5
    bl   wl_mdns
    mov  r5, r0                     ; the length of the answer (0: none)
    cmp  r0, #0
    beq  wan_udp_no
    b    wan_send
wan_udp_no:
    b    wan_no
wan_icmp:
    cmp  r0, #1
    bne  wan_udp_no
    mov  r0, r4
    adds r0, r0, #30                ; the destination
    bl   wl_is_ours
    cmp  r0, #0
    beq  wan_no
    ldrb r0, [r4, #14]
    movs r1, #15
    ands r0, r1
    lsls r0, r0, #2                 ; the length of the IPv4 header
    mov  r1, r4
    adds r1, r1, #14
    adds r1, r1, r0                 ; ICMP
    ldrb r0, [r1]
    cmp  r0, #8
    bne  wan_no
    ldrb r0, [r4, #16]              ; the length of the IPv4 packet
    ldrb r2, [r4, #17]
    lsls r0, r0, #8
    orrs r0, r2
    adds r0, r0, #14
    cmp  r0, r5
    bhi  wan_no                     ; not all of it came
    mov  r5, r0
    movs r0, #0
    strb r0, [r1]                   ; type 0: echo reply
    ldrb r0, [r1, #2]               ; its checksum: 0x0800 less in the sum, 0x0800 more in the checksum
    ldrb r2, [r1, #3]
    lsls r0, r0, #8
    orrs r0, r2
    movs r2, #8
    lsls r2, r2, #8
    adds r0, r0, r2
    lsrs r2, r0, #16
    adds r0, r0, r2                 ; the carry around
    strb r0, [r1, #3]
    lsrs r0, r0, #8
    strb r0, [r1, #2]
    mov  r0, r4
    adds r0, r0, #30
    mov  r1, r4
    adds r1, r1, #26
    movs r2, #4
    bl   wl_memcpy                  ; to the one who asked
    mov  r0, r4
    adds r0, r0, #26
    mov  r1, r6
    adds r1, r1, #WL_IP
    movs r2, #4
    bl   wl_memcpy                  ; from us (the checksum of IPv4 stays: the same words)
    ldr  r0, [r6, #WL_NPING]
    adds r0, r0, #1
    str  r0, [r6, #WL_NPING]
    b    wan_eth
wan_arp:
    ldrb r0, [r4, #20]              ; op 1: a request
    cmp  r0, #0
    bne  wan_no
    ldrb r0, [r4, #21]
    cmp  r0, #1
    bne  wan_no
    mov  r0, r4
    adds r0, r0, #38                ; the address asked for
    bl   wl_is_ours
    cmp  r0, #0
    beq  wan_no
    movs r0, #2
    strb r0, [r4, #21]              ; op 2: the answer
    mov  r0, r4
    adds r0, r0, #32
    mov  r1, r4
    adds r1, r1, #22
    movs r2, #10
    bl   wl_memcpy                  ; the target: the one who asked (MAC, address)
    mov  r0, r4
    adds r0, r0, #22
    mov  r1, r6
    adds r1, r1, #WL_MAC
    movs r2, #6
    bl   wl_memcpy                  ; the sender: us
    mov  r0, r4
    adds r0, r0, #28
    mov  r1, r6
    adds r1, r1, #WL_IP
    movs r2, #4
    bl   wl_memcpy
    ldr  r0, [r6, #WL_NARP]
    adds r0, r0, #1
    str  r0, [r6, #WL_NARP]
    movs r5, #42
wan_eth:
    mov  r0, r4
    mov  r1, r4
    adds r1, r1, #6
    movs r2, #6
    bl   wl_memcpy                  ; Ethernet: to the one who asked
    mov  r0, r4
    adds r0, r0, #6
    mov  r1, r6
    adds r1, r1, #WL_MAC
    movs r2, #6
    bl   wl_memcpy                  ; ... from us
wan_send:
    bl   wl_credit
    cmp  r0, #0
    beq  wan_yes                    ; no credit: left out
    mov  r0, r4
    mov  r1, r5
    bl   wl_send_now
wan_yes:
    movs r0, #1
    pop  {r4, r5, r6, pc}
wan_no:
    movs r0, #0
    pop  {r4, r5, r6, pc}

; the 4 bytes at r0 the address of the board (WL_IP)? r0 1, else 0
wl_is_ours:
    push {r4, lr}
    ldr  r3, wlC_ip
    movs r1, #0
wio_next:
    ldrb r2, [r0, r1]
    ldrb r4, [r3, r1]
    cmp  r2, r4
    bne  wio_no
    adds r1, r1, #1
    cmp  r1, #4
    blo  wio_next
    movs r0, #1
    pop  {r4, pc}
wio_no:
    movs r0, #0
    pop  {r4, pc}

; the frame r0 (r1 bytes) into the ring (up to 1532 bytes of it); when it is full, it is lost
wl_ring_put:
    push {r4, lr}
    ldr  r3, wlC_wlv
    ldr  r2, [r3, #WL_RPUT]
    ldr  r4, [r3, #WL_RGET]
    subs r4, r2, r4
    cmp  r4, #4
    bhs  wrp_end
    movs r4, #3
    ands r4, r2
    ldr  r2, wlC_rslot
    muls r4, r2
    ldr  r2, wlC_ring
    adds r4, r4, r2                 ; its place
    str  r1, [r4]
    ldr  r2, wlC_1532
    cmp  r1, r2
    bls  wrp_copy
    mov  r1, r2
wrp_copy:
    mov  r2, r1
    mov  r1, r0
    adds r0, r4, #4
    bl   wl_memcpy
    ldr  r3, wlC_wlv
    ldr  r2, [r3, #WL_RPUT]
    adds r2, r2, #1
    str  r2, [r3, #WL_RPUT]
wrp_end:
    pop  {r4, pc}

; the oldest frame of the ring into r0 (up to r1 bytes of it): r0 its length, 0 when the ring is empty
wl_ring_get:
    push {r4, r5, lr}
    ldr  r3, wlC_wlv
    ldr  r2, [r3, #WL_RGET]
    ldr  r4, [r3, #WL_RPUT]
    cmp  r2, r4
    beq  wrg_none
    movs r4, #3
    ands r4, r2
    ldr  r2, wlC_rslot
    muls r4, r2
    ldr  r2, wlC_ring
    adds r4, r4, r2
    ldr  r5, [r4]                   ; its length
    mov  r2, r5
    cmp  r2, r1
    bls  wrg_1
    mov  r2, r1
wrg_1:
    ldr  r3, wlC_1532
    cmp  r2, r3
    bls  wrg_2
    mov  r2, r3
wrg_2:
    adds r1, r4, #4
    bl   wl_memcpy
    ldr  r3, wlC_wlv
    ldr  r2, [r3, #WL_RGET]
    adds r2, r2, #1
    str  r2, [r3, #WL_RGET]
    mov  r0, r5
    pop  {r4, r5, pc}
wrg_none:
    movs r0, #0
    pop  {r4, r5, pc}

    align 4
wlC_wlv:            dd WLV
wlC_ip:             dd WLV + WL_IP
wlC_rx:             dd WL_RX
wlC_ring:           dd WL_RING
wlC_rslot:          dd WL_RSLOT
wlC_1532:           dd 1532
wlC_vec:            dd VTAB + 15 * 4
wlC_tick:           dd wl_tick + RUN_OFFSET + 1
wlC_syst:           dd SYST
wlC_reload:         dd 480000 - 1           ; 10 ms at 48 MHz

; ---------- mDNS: name.local (as net_mdns of boards\esp32\console_dhcp.asm, RFC 6762) ----------
;
; The frame r0 (r1 bytes): a question of mDNS (IPv4 without options, UDP to port 5353) whose first question is the
; name of the board (wl_dhcp_name) .local, type A or ANY, class IN (the bit "unicast answer" left out)? Then the
; answer in its place: to all (224.0.0.251:5353, 01:00:5E:00:00:FB; its class with the bit "flush the cache", 120 s)
; when the question came from port 5353, else to the one who asked (its id and its question again, 10 s); r0 the
; length of the frame. Else r0 0. Later questions of a message are not looked at. The name in the question stays
; where it is: it is the name of the record (to all) or the question again (a pointer to it in the record)
wl_mdns:
    push {r4, r5, r6, r7, lr}
    sub  sp, sp, #32                ; the name of the board
    mov  r4, r0
    mov  r5, r1
    b    wmd_go
wmd_no:
    movs r0, #0
wmd_end:
    add  sp, sp, #32
    pop  {r4, r5, r6, r7, pc}
wmd_go:
    ldrb r0, [r4, #14]
    cmp  r0, #0x45
    bne  wmd_no
    mov  r3, r4
    adds r3, r3, #34                ; UDP
    ldrb r0, [r3, #2]               ; to port 5353 (0x14E9)
    cmp  r0, #0x14
    bne  wmd_no
    ldrb r0, [r3, #3]
    cmp  r0, #0xe9
    bne  wmd_no
    ldrb r0, [r3, #10]              ; DNS: a question, not an answer
    lsrs r0, r0, #7
    bne  wmd_no
    ldrb r0, [r3, #12]              ; questions: at least one
    ldrb r1, [r3, #13]
    orrs r0, r1
    beq  wmd_no
    mov  r0, sp
    bl   wl_dhcp_name               ; r0 its length
    mov  r6, r0
    adds r0, r0, #66                ; 54 + the name + 8 + 4: the frame has its first question
    cmp  r5, r0
    blo  wmd_no
    mov  r7, r4
    adds r7, r7, #54
    ldrb r0, [r7]                   ; the first label: the name (upper and lower case alike)
    cmp  r0, r6
    bne  wmd_no
    adds r7, r7, #1
    movs r5, #0x20
    movs r2, #0
wmd_cmp:
    mov  r0, sp
    ldrb r0, [r0, r2]
    ldrb r1, [r7, r2]
    orrs r0, r5
    orrs r1, r5
    cmp  r0, r1
    bne  wmd_no
    adds r2, r2, #1
    cmp  r2, r6
    blo  wmd_cmp
    adds r7, r7, r6                 ; behind it: 5 "local" 0
    ldrb r0, [r7]
    cmp  r0, #5
    bne  wmd_no
    adr  r1, wmd_local
    movs r2, #0
wmd_loc:
    ldrb r0, [r1, r2]
    adds r2, r2, #1
    ldrb r3, [r7, r2]
    orrs r3, r5
    cmp  r0, r3
    bne  wmd_no
    cmp  r2, #5
    blo  wmd_loc
    ldrb r0, [r7, #6]               ; the end of the name
    cmp  r0, #0
    bne  wmd_no
    ldrb r0, [r7, #7]               ; type A (1) or ANY (255)
    cmp  r0, #0
    bne  wmd_no
    ldrb r0, [r7, #8]
    cmp  r0, #1
    beq  wmd_cls
    cmp  r0, #255
    bne  wmd_no
wmd_cls:
    ldrb r0, [r7, #9]               ; class IN
    movs r1, #0x7f
    ands r0, r1
    bne  wmd_no
    ldrb r0, [r7, #10]
    cmp  r0, #1
    bne  wmd_no
    ; the head of DNS: an answer, authoritative, one record, nothing else
    mov  r3, r4
    adds r3, r3, #34
    movs r0, #0x84
    strb r0, [r3, #10]
    movs r0, #0
    strb r0, [r3, #11]
    strb r0, [r3, #14]
    strb r0, [r3, #16]
    strb r0, [r3, #17]
    strb r0, [r3, #18]
    strb r0, [r3, #19]
    movs r0, #1
    strb r0, [r3, #15]
    ldrb r0, [r3, #0]               ; from port 5353: to all
    cmp  r0, #0x14
    bne  wmd_uni
    ldrb r0, [r3, #1]
    cmp  r0, #0xe9
    bne  wmd_uni
    movs r0, #0                     ; the id 0, no question: the record with the name where it is
    strb r0, [r3, #8]
    strb r0, [r3, #9]
    strb r0, [r3, #12]
    strb r0, [r3, #13]
    adds r7, r7, #7
    movs r1, #0x80                  ; flush the cache, 120 s
    movs r2, #120
    movs r6, #1
    b    wmd_rec
wmd_uni:
    movs r0, #0                     ; its id, its question again (class IN), the record behind it: the name at 12
    strb r0, [r3, #12]
    strb r0, [r7, #9]
    movs r0, #1
    strb r0, [r3, #13]
    strb r0, [r7, #10]
    adds r7, r7, #11
    movs r0, #0xc0
    strb r0, [r7]
    movs r0, #12
    strb r0, [r7, #1]
    adds r7, r7, #2
    movs r1, #0
    movs r2, #10
    movs r6, #0
wmd_rec:
    movs r0, #0                     ; type A, the class (r1: its high byte), the time to live (r2), 4 bytes: the address
    strb r0, [r7]
    strb r0, [r7, #4]
    strb r0, [r7, #5]
    strb r0, [r7, #6]
    strb r0, [r7, #8]
    movs r0, #1
    strb r0, [r7, #1]
    strb r0, [r7, #3]
    strb r1, [r7, #2]
    strb r2, [r7, #7]
    movs r0, #4
    strb r0, [r7, #9]
    mov  r0, r7
    adds r0, r0, #10
    ldr  r1, wmdC_ip
    movs r2, #4
    bl   wl_memcpy
    adds r7, r7, #14
    subs r7, r7, r4                 ; the length of the frame
    mov  r3, r4                     ; UDP: from 5353 to the port that asked, its length, no checksum
    adds r3, r3, #34
    ldrb r0, [r3, #0]
    strb r0, [r3, #2]
    ldrb r0, [r3, #1]
    strb r0, [r3, #3]
    movs r0, #0x14
    strb r0, [r3, #0]
    movs r0, #0xe9
    strb r0, [r3, #1]
    mov  r0, r7
    subs r0, r0, #34
    strb r0, [r3, #5]
    lsrs r0, r0, #8
    strb r0, [r3, #4]
    movs r0, #0
    strb r0, [r3, #6]
    strb r0, [r3, #7]
    mov  r0, r7                     ; IPv4: its length, no fragments, the time to live 255 (mDNS: this network)
    subs r0, r0, #14
    strb r0, [r4, #17]
    lsrs r0, r0, #8
    strb r0, [r4, #16]
    movs r0, #0
    strb r0, [r4, #20]
    strb r0, [r4, #21]
    strb r0, [r4, #24]
    strb r0, [r4, #25]
    movs r0, #255
    strb r0, [r4, #22]
    mov  r0, r4
    adds r0, r0, #30
    mov  r1, r4
    adds r1, r1, #26
    movs r2, #4
    bl   wl_memcpy                  ; to the one who asked
    mov  r0, r4
    adds r0, r0, #26
    ldr  r1, wmdC_ip
    movs r2, #4
    bl   wl_memcpy                  ; from us
    mov  r0, r4                     ; Ethernet: to the one who asked, from us
    mov  r1, r4
    adds r1, r1, #6
    movs r2, #6
    bl   wl_memcpy
    mov  r0, r4
    adds r0, r0, #6
    ldr  r1, wmdC_mac
    movs r2, #6
    bl   wl_memcpy
    cmp  r6, #0
    beq  wmd_sum
    mov  r3, r4                     ; to all: 224.0.0.251, 01:00:5E:00:00:FB
    adds r3, r3, #30
    movs r0, #224
    strb r0, [r3]
    movs r0, #251
    strb r0, [r3, #3]
    movs r0, #0xfb
    strb r0, [r4, #5]
    movs r0, #0x5e
    strb r0, [r4, #2]
    movs r0, #1
    strb r0, [r4, #0]
    movs r0, #0
    strb r0, [r3, #1]
    strb r0, [r3, #2]
    strb r0, [r4, #1]
    strb r0, [r4, #3]
    strb r0, [r4, #4]
wmd_sum:
    mov  r0, r4
    adds r0, r0, #14
    movs r1, #20
    bl   wl_csum
    strb r0, [r4, #25]
    lsrs r0, r0, #8
    strb r0, [r4, #24]
    mov  r0, r7
    b    wmd_end
    align 4
wmdC_ip:            dd WLV + WL_IP
wmdC_mac:           dd WLV + WL_MAC
wmd_local:          db 'local', 0
    align 2

; ---------- the address of the board: DHCP ----------
;
; After a join (wlan on, wl_call connect) the console asks for an address by DHCP: DISCOVER to all, the OFFER of a
; server, REQUEST, its ACK (each again after 2 s, four times). The address goes to WL_IP (from then on wl_tick answers
; ARP and ping for it), the mask, the router, the DNS server, the server and the lease to WLV + WL_DHC. Its name for
; the router (option 12): the one of name set (the record, +80), else "picow-" or "pico2w-" and the last two bytes of
; the MAC in hex ("picow-789a"). The frames of DHCP: Ethernet 14, IPv4 20, UDP 8, BOOTP 236 and 64 bytes of options.
WL_DHC         equ 140                 ; WLV + 140: the words below (9)
D_MASK          equ 0                   ;   the mask (4 bytes, as in the frame)
D_GW            equ 4                   ;   the router
D_DNS           equ 8                   ;   the DNS server
D_SERVER        equ 12                  ;   the DHCP server
D_LEASE         equ 16                  ;   the lease in seconds
D_TIME          equ 20                  ;   the milliseconds (millis) of the ACK
D_XID           equ 24                  ;   the number of the transaction
D_OFFER         equ 28                  ;   the address offered (yiaddr)
D_TYPE          equ 32                  ;   the type of the message that came last (option 53)
WL_DTX          equ DIRBUF + 0x4000     ; a DHCP message to send (342 bytes)
WL_DRX          equ DIRBUF + 0x4200     ; a frame that came (up to 1536 bytes)

; DHCP: r0 0 when the board has its address (WL_IP, WL_DHC), else 1
wl_dhcp:
    push {r4, r5, r6, r7, lr}
    ldr  r7, wlE_wlv
    movs r0, #0
    str  r0, [r7, #WL_IP]
    bl   tick_now
    ldr  r1, wlE_mul
    muls r0, r1
    ldr  r1, wlE_d
    str  r0, [r1, #D_XID]           ; a new transaction
    movs r4, #4
wdh_disc:
    movs r0, #1                     ; DISCOVER
    bl   wl_dhcp_send
    movs r0, #2                     ; OFFER
    bl   wl_dhcp_wait
    cmp  r0, #0
    bne  wdh_offer
    subs r4, r4, #1
    bne  wdh_disc
    b    wdh_fail
wdh_offer:
    movs r4, #4
wdh_req:
    movs r0, #3                     ; REQUEST
    bl   wl_dhcp_send
    movs r0, #5                     ; ACK
    bl   wl_dhcp_wait
    cmp  r0, #0
    bne  wdh_ack
    subs r4, r4, #1
    bne  wdh_req
wdh_fail:
    movs r0, #1
    pop  {r4, r5, r6, r7, pc}
wdh_ack:
    ldr  r1, wlE_d
    ldr  r0, [r1, #D_OFFER]         ; the address of the ACK
    str  r0, [r7, #WL_IP]
    bl   api_millis
    ldr  r1, wlE_d
    str  r0, [r1, #D_TIME]
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; a DHCP message of type r0 (1 DISCOVER, 3 REQUEST: with the address offered and the server) to all
wl_dhcp_send:
    push {r4, r5, r6, lr}
    mov  r6, r0
    ldr  r4, wlE_dtx
    mov  r0, r4
    ldr  r1, wlE_342
    bl   wl_memset0
    movs r0, #0xff                  ; Ethernet: to all, from us, IPv4
    strb r0, [r4]
    strb r0, [r4, #1]
    strb r0, [r4, #2]
    strb r0, [r4, #3]
    strb r0, [r4, #4]
    strb r0, [r4, #5]
    mov  r0, r4
    adds r0, r0, #6
    ldr  r1, wlE_mac
    movs r2, #6
    bl   wl_memcpy
    movs r0, #8
    strb r0, [r4, #12]
    movs r0, #0x45                  ; IPv4: 20 bytes of header, 328 in all, ttl 64, UDP, from 0.0.0.0 to all
    strb r0, [r4, #14]
    movs r0, #1
    strb r0, [r4, #16]
    movs r0, #0x48
    strb r0, [r4, #17]
    movs r0, #64
    strb r0, [r4, #22]
    movs r0, #17
    strb r0, [r4, #23]
    mov  r0, r4
    adds r0, r0, #30
    movs r1, #0xff
    strb r1, [r0]
    strb r1, [r0, #1]
    strb r1, [r0, #2]
    strb r1, [r0, #3]
    mov  r0, r4
    adds r0, r0, #14
    movs r1, #20
    bl   wl_csum
    strb r0, [r4, #25]
    lsrs r0, r0, #8
    strb r0, [r4, #24]
    mov  r5, r4
    adds r5, r5, #34                ; UDP: 68 to 67, 308 bytes, no checksum
    movs r0, #68
    strb r0, [r5, #1]
    movs r0, #67
    strb r0, [r5, #3]
    movs r0, #1
    strb r0, [r5, #4]
    movs r0, #0x34
    strb r0, [r5, #5]
    adds r5, r5, #8                 ; BOOTP: a request, Ethernet, 6 bytes of MAC
    movs r0, #1
    strb r0, [r5]
    strb r0, [r5, #1]
    movs r0, #6
    strb r0, [r5, #2]
    adds r0, r5, #4
    ldr  r1, wlE_d
    ldr  r1, [r1, #D_XID]
    bl   wl_put32
    movs r0, #0x80
    strb r0, [r5, #10]              ; the answer to all (we have no address yet)
    mov  r0, r5
    adds r0, r0, #28
    ldr  r1, wlE_mac
    movs r2, #6
    bl   wl_memcpy
    adds r5, r5, #236               ; the options: the magic cookie, 53 (the type)
    movs r0, #0x63
    strb r0, [r5]
    strb r0, [r5, #3]
    movs r0, #0x82
    strb r0, [r5, #1]
    movs r0, #0x53
    strb r0, [r5, #2]
    movs r0, #53
    strb r0, [r5, #4]
    movs r0, #1
    strb r0, [r5, #5]
    strb r6, [r5, #6]
    adds r5, r5, #7
    cmp  r6, #3
    bne  wds_name
    movs r0, #50                    ; REQUEST: 50 the address, 54 the server
    strb r0, [r5]
    movs r0, #4
    strb r0, [r5, #1]
    strb r0, [r5, #7]
    movs r0, #54
    strb r0, [r5, #6]
    adds r0, r5, #2
    ldr  r1, wlE_offer
    movs r2, #4
    bl   wl_memcpy
    mov  r0, r5
    adds r0, r0, #8
    ldr  r1, wlE_server
    movs r2, #4
    bl   wl_memcpy
    adds r5, r5, #12
wds_name:
    adds r0, r5, #2                 ; 12: the name of the board
    bl   wl_dhcp_name
    movs r1, #12
    strb r1, [r5]
    strb r0, [r5, #1]
    adds r5, r5, #2
    adds r5, r5, r0
    movs r0, #55                    ; 55: the mask, the router, DNS
    strb r0, [r5]
    movs r0, #3
    strb r0, [r5, #1]
    strb r0, [r5, #3]
    movs r0, #1
    strb r0, [r5, #2]
    movs r0, #6
    strb r0, [r5, #4]
    movs r0, #255
    strb r0, [r5, #5]
    mov  r0, r4
    ldr  r1, wlE_342
    bl   wl_send_frame
    pop  {r4, r5, r6, pc}

; a DHCP message of type r0 for our transaction, waiting for it up to 2 s: r0 1 (its fields in WL_DHC), else 0
wl_dhcp_wait:
    push {r4, r5, r6, lr}
    mov  r6, r0
    bl   api_millis
    mov  r5, r0
wdw_next:
    ldr  r0, wlE_drx
    ldr  r1, wlE_1536
    movs r2, #100
    bl   wl_recv_frame
    cmp  r0, #0
    beq  wdw_time
    mov  r1, r0
    ldr  r0, wlE_drx
    mov  r2, r6
    bl   wl_dhcp_parse
    cmp  r0, #0
    bne  wdw_end
wdw_time:
    bl   api_millis
    subs r0, r0, r5
    ldr  r1, wlE_2000
    cmp  r0, r1
    blo  wdw_next
    movs r0, #0
wdw_end:
    pop  {r4, r5, r6, pc}

    align 4
wlE_wlv:            dd WLV
wlE_d:              dd WLV + WL_DHC
wlE_offer:          dd WLV + WL_DHC + D_OFFER
wlE_server:         dd WLV + WL_DHC + D_SERVER
wlE_mac:            dd WLV + WL_MAC
wlE_mul:            dd 1103515245
wlE_dtx:            dd WL_DTX
wlE_drx:            dd WL_DRX
wlE_342:            dd 342
wlE_1536:           dd 1536
wlE_2000:           dd 2000

; the frame r0 (r1 bytes) a DHCP message of type r2 for our transaction (UDP to port 68, BOOTREPLY, our xid)? Then its
; address (yiaddr) to D_OFFER, its options 1, 3, 6, 54, 51 to WL_DHC and r0 1; else r0 0
wl_dhcp_parse:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0
    adds r5, r0, r1                 ; its end
    mov  r6, r2
    ldr  r0, wlF_min
    cmp  r1, r0
    blo  wdp_no
    ldrb r0, [r4, #12]
    cmp  r0, #8
    bne  wdp_no
    ldrb r0, [r4, #13]
    cmp  r0, #0
    bne  wdp_no
    ldrb r0, [r4, #14]
    cmp  r0, #0x45
    bne  wdp_no
    ldrb r0, [r4, #23]
    cmp  r0, #17
    bne  wdp_no
    mov  r7, r4
    adds r7, r7, #34                ; UDP
    ldrb r0, [r7, #2]
    cmp  r0, #0
    bne  wdp_no
    ldrb r0, [r7, #3]
    cmp  r0, #68
    bne  wdp_no
    adds r7, r7, #8                 ; BOOTP
    ldrb r0, [r7]
    cmp  r0, #2
    bne  wdp_no
    adds r0, r7, #4
    bl   wl_get32
    ldr  r1, wlF_d
    ldr  r1, [r1, #D_XID]
    cmp  r0, r1
    bne  wdp_no
    mov  r0, r7
    adds r0, r0, #236
    bl   wl_get32
    ldr  r1, wlF_magic
    cmp  r0, r1
    bne  wdp_no
    ldr  r1, wlF_d
    movs r0, #0
    str  r0, [r1, #D_TYPE]
    mov  r4, r7
    adds r4, r4, #240               ; the options
wdp_opt:
    cmp  r4, r5
    bhs  wdp_done
    ldrb r0, [r4]
    cmp  r0, #255
    beq  wdp_done
    cmp  r0, #0
    bne  wdp_some
    adds r4, r4, #1                 ; padding
    b    wdp_opt
wdp_some:
    ldrb r1, [r4, #1]               ; its length
    adds r2, r4, #2                 ; its data
    adds r4, r2, r1                 ; the next one
    cmp  r4, r5
    bhi  wdp_done
    cmp  r0, #53
    bne  wdp_1
    ldrb r0, [r2]
    ldr  r1, wlF_d
    str  r0, [r1, #D_TYPE]
    b    wdp_opt
wdp_1:
    cmp  r1, #4
    blo  wdp_opt                    ; the others have 4 bytes at least
    ldr  r3, wlF_d
    cmp  r0, #1
    beq  wdp_copy                   ; the mask (D_MASK 0)
    adds r3, r3, #D_GW
    cmp  r0, #3
    beq  wdp_copy
    adds r3, r3, #D_DNS - D_GW
    cmp  r0, #6
    beq  wdp_copy
    adds r3, r3, #D_SERVER - D_DNS
    cmp  r0, #54
    beq  wdp_copy
    cmp  r0, #51
    bne  wdp_opt
    ldrb r0, [r2]                   ; the lease, big endian
    ldrb r1, [r2, #1]
    lsls r0, r0, #8
    orrs r0, r1
    ldrb r1, [r2, #2]
    lsls r0, r0, #8
    orrs r0, r1
    ldrb r1, [r2, #3]
    lsls r0, r0, #8
    orrs r0, r1
    ldr  r1, wlF_d
    str  r0, [r1, #D_LEASE]
    b    wdp_opt
wdp_copy:
    mov  r0, r3
    mov  r1, r2
    movs r2, #4
    bl   wl_memcpy
    b    wdp_opt
wdp_done:
    ldr  r1, wlF_d
    ldr  r0, [r1, #D_TYPE]
    cmp  r0, r6
    bne  wdp_no
    ldr  r0, wlF_offer
    mov  r1, r7
    adds r1, r1, #16                ; yiaddr
    movs r2, #4
    bl   wl_memcpy
    movs r0, #1
    pop  {r4, r5, r6, r7, pc}
wdp_no:
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; the checksum of IPv4 of r1 bytes (even) at r0: r0 (16 bits)
wl_csum:
    push {r4, lr}
    movs r2, #0
wcs_next:
    cmp  r1, #0
    beq  wcs_fold
    ldrb r3, [r0]
    lsls r3, r3, #8
    ldrb r4, [r0, #1]
    orrs r3, r4
    adds r2, r2, r3
    adds r0, r0, #2
    subs r1, r1, #2
    b    wcs_next
wcs_fold:
    lsrs r3, r2, #16
    beq  wcs_done
    uxth r2, r2
    adds r2, r2, r3
    b    wcs_fold
wcs_done:
    mvns r0, r2
    uxth r0, r0
    pop  {r4, pc}

; the name of the board for DHCP into r0 (no 0 behind it): the one of name set (the record), else "picow-789a" /
; "pico2w-789a" (the last two bytes of the MAC). r0 its length
wl_dhcp_name:
    push {r4, r5, lr}
    mov  r4, r0
    ldr  r1, wlF_netname
    ldrb r0, [r1]
    cmp  r0, #0
    beq  wdn_mac
    movs r5, #0
wdn_copy:
    ldrb r0, [r1, r5]
    cmp  r0, #0
    beq  wdn_end
    strb r0, [r4, r5]
    adds r5, r5, #1
    cmp  r5, #31
    blo  wdn_copy
wdn_end:
    mov  r0, r5
    pop  {r4, r5, pc}
wdn_mac:
    ldr  r1, wlF_sysinfo
    ldr  r0, [r1]                   ; CHIP_ID: the RP2350 (part 4) or the RP2040
    lsls r0, r0, #4
    lsrs r0, r0, #16
    cmp  r0, #4
    beq  wdn_2
    adr  r0, wl_n_picow
    b    wdn_prefix
wdn_2:
    adr  r0, wl_n_pico2w
wdn_prefix:
    mov  r1, r4
    bl   wl_copy_name
    subs r5, r0, #1                 ; without its 0
    ldr  r1, wlF_mac
    ldrb r0, [r1, #4]
    bl   wdn_hex
    ldr  r1, wlF_mac
    ldrb r0, [r1, #5]
    bl   wdn_hex
    mov  r0, r5
    pop  {r4, r5, pc}
; the byte r0 as two small hex digits at r4 + r5 (r5 + 2)
wdn_hex:
    push {lr}
    lsrs r1, r0, #4
    movs r2, #15
    ands r0, r2
    push {r0}
    mov  r0, r1
    bl   wdn_digit
    pop  {r0}
    bl   wdn_digit
    pop  {pc}
wdn_digit:
    cmp  r0, #10
    blo  wdd_num
    adds r0, r0, #87                ; 'a' - 10
    b    wdd_put
wdd_num:
    adds r0, r0, #48
wdd_put:
    strb r0, [r4, r5]
    adds r5, r5, #1
    bx   lr

; the 4 bytes at r0 as an IPv4 address to the terminal ("192.168.1.20")
wl_put_ip:
    push {r4, r5, lr}
    mov  r4, r0
    movs r5, #0
wpi_next:
    ldrb r0, [r4, r5]
    bl   put_dec
    adds r5, r5, #1
    cmp  r5, #4
    beq  wpi_end
    movs r0, #'.'
    bl   put_char
    b    wpi_next
wpi_end:
    pop  {r4, r5, pc}

    align 4
wlF_d:              dd WLV + WL_DHC
wlF_offer:          dd WLV + WL_DHC + D_OFFER
wlF_mac:            dd WLV + WL_MAC
wlF_netname:        dd WL_NET + 80
wlF_sysinfo:        dd WL_SYSINFO
wlF_min:            dd 14 + 20 + 8 + 240
wlF_magic:          dd 0x63538263           ; 63 82 53 63 (little endian: wl_get32)
wl_n_picow:
    db   'picow-', 0
    align 4
wl_n_pico2w:
    db   'pico2w-', 0
    align 4

; "Address 192.168.1.20 (mask 255.255.255.0, router 192.168.1.1, DNS 192.168.1.1, lease 21600 s)." and a line end
wl_put_addr:
    push {r4, lr}
    bl   print_inline
    db   'Address ', 0
    align 2
    ldr  r0, wlG_ip
    bl   wl_put_ip
    bl   print_inline
    db   ' (mask ', 0
    align 2
    ldr  r4, wlG_d
    mov  r0, r4
    bl   wl_put_ip
    bl   print_inline
    db   ', router ', 0
    align 2
    mov  r0, r4
    adds r0, r0, #D_GW
    bl   wl_put_ip
    bl   print_inline
    db   ', DNS ', 0
    align 2
    mov  r0, r4
    adds r0, r0, #D_DNS
    bl   wl_put_ip
    bl   print_inline
    db   ', lease ', 0
    align 2
    ldr  r0, [r4, #D_LEASE]
    bl   put_dec
    bl   print_inline
    db   ' s).', 13, 10, 0
    align 2
    pop  {r4, pc}

    align 4
wlG_ip:             dd WLV + WL_IP
wlG_d:              dd WLV + WL_DHC

; read_line of the console while no byte comes (r0 the bytes typed in LINE): the WiFi at the start (wl_auto); at
; half the lease the address again by DHCP (as clients do). When no server answers, the address stays and the console
; asks again a minute later
wifi_idle:
    push {r4, r5, lr}
    bl   wl_auto
    ldr  r4, wlI_wlv
    ldr  r0, [r4, #WL_BUSY]
    cmp  r0, #0
    bne  wid_end                    ; (wlan set reads a line: the console talks to the chip)
    ldr  r0, [r4, #WL_STATE]
    cmp  r0, #2
    bne  wid_end
    ldr  r0, [r4, #WL_IP]
    cmp  r0, #0
    beq  wid_end
    ldr  r5, wlI_d
    ldr  r0, [r5, #D_LEASE]
    cmp  r0, #0
    beq  wid_end
    ldr  r1, wlI_max
    cmp  r0, r1
    bhi  wid_end                    ; (an endless lease)
    bl   api_millis
    ldr  r1, [r5, #D_TIME]
    subs r0, r0, r1                 ; the milliseconds since the ACK
    ldr  r1, [r5, #D_LEASE]
    ldr  r2, wlI_500
    muls r1, r2                     ; half the lease
    cmp  r0, r1
    blo  wid_end
    bl   wl_busy_on
    ldr  r0, [r4, #WL_IP]
    push {r0}
    bl   wl_dhcp
    pop  {r1}
    cmp  r0, #0
    beq  wid_free                   ; a new lease (D_TIME now)
    str  r1, [r4, #WL_IP]           ; the address stays; again in a minute
    ldr  r0, [r5, #D_TIME]
    ldr  r1, wlI_60s
    adds r0, r0, r1
    str  r0, [r5, #D_TIME]
wid_free:
    bl   wl_busy_off
wid_end:
    pop  {r4, r5, pc}

    align 4
wlI_wlv:            dd WLV
wlI_d:              dd WLV + WL_DHC
wlI_max:            dd 0x100000             ; 12 days: longer is an endless lease
wlI_500:            dd 500
wlI_60s:            dd 60000

; ---------- the name of the board ----------

; name, name set <name>, name clear (r0 the rest of the line): the name of the board in the network (DHCP option 12),
; kept in the record of the network (+80, as on the ESP32: wlan set and wlan clear keep it). name shows it, name set
; gives it another one (1 to 31 letters, digits and '-'), name clear: the one of the MAC again. A new name while the
; board is in a network: the console asks for its address again, so the router learns it
cmd_name:
    push {r4, r5, lr}
    bl   skip_spaces
    mov  r4, r0
    bl   wl_net_load
    ldrb r0, [r4]
    cmp  r0, #0
    bne  wfar3
    b    cnm_show
wfar3:
    mov  r0, r4
    bl   match_inline
    db   'clear', 0
    align 2
    cmp  r0, #0
    bne  cnm_clear
    mov  r0, r4
    bl   match_inline
    db   'set', 0
    align 2
    cmp  r0, #0
    bne  cnm_set
    bl   print_inline
    db   'name, name set <name>, name clear', 13, 10, 0
    align 2
    pop  {r4, r5, pc}
cnm_set:
    bl   skip_spaces
    mov  r4, r0
    movs r5, #0                     ; its length; letters, digits and '-' only
cnm_char:
    ldrb r0, [r4, r5]
    cmp  r0, #0
    beq  cnm_len
    cmp  r0, #'-'
    beq  cnm_ok
    cmp  r0, #'0'
    blo  cnm_bad
    cmp  r0, #'9'
    bls  cnm_ok
    movs r1, #0x20
    orrs r0, r1                     ; small
    cmp  r0, #'a'
    blo  cnm_bad
    cmp  r0, #'z'
    bhi  cnm_bad
cnm_ok:
    adds r5, r5, #1
    cmp  r5, #31
    bls  cnm_char
cnm_bad:
    bl   print_inline
    db   'A name has 1 to 31 letters, digits or -, for example: name set keller', 13, 10, 0
    align 2
    pop  {r4, r5, pc}
cnm_len:
    cmp  r5, #0
    beq  cnm_bad
    ldr  r0, wlK_name
    movs r1, #32
    bl   wl_memset0
    ldr  r0, wlK_name
    mov  r1, r4
    mov  r2, r5
    bl   wl_memcpy
    b    cnm_save
cnm_clear:
    ldr  r0, wlK_name
    movs r1, #32
    bl   wl_memset0
cnm_save:
    bl   wl_net_save
    cmp  r0, #0
    beq  cnm_saved
    bl   put_text
    bl   put_nl
    bl   wl_net_load                ; the record as it was
    pop  {r4, r5, pc}
cnm_saved:
    bl   cnm_say
    ldr  r1, wlK_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #2
    bne  cnm_end
    bl   print_inline
    db   'An address by DHCP (the router learns the name) ...', 13, 10, 0
    align 2
    bl   wl_dhcp
    cmp  r0, #0
    bne  cnm_end
    bl   wl_put_addr
cnm_end:
    pop  {r4, r5, pc}
cnm_show:
    bl   cnm_say
    pop  {r4, r5, pc}

; "The name of the board: picow-789a" (and where it comes from)
cnm_say:
    push {r4, lr}
    bl   print_inline
    db   'The name of the board: ', 0
    align 2
    ldr  r0, wlK_name
    ldrb r0, [r0]
    cmp  r0, #0
    bne  cns_set
    ldr  r1, wlK_mac                ; from the MAC: known after the first join
    ldr  r0, [r1]
    ldrh r1, [r1, #4]
    orrs r0, r1
    cmp  r0, #0
    bne  cns_set
    ldr  r1, wlK_sysinfo
    ldr  r0, [r1]
    lsls r0, r0, #4
    lsrs r0, r0, #16
    cmp  r0, #4
    beq  cns_2
    adr  r0, wl_n_picow2
    b    cns_q
cns_2:
    adr  r0, wl_n_pico2w2
cns_q:
    bl   put_text
    bl   print_inline
    db   '???? (the MAC comes with wlan on)', 13, 10, 0
    align 2
    pop  {r4, pc}
cns_set:
    ldr  r0, wlK_buf
    bl   wl_dhcp_name
    mov  r4, r0
    ldr  r0, wlK_buf
    movs r1, #0
    strb r1, [r0, r4]
    bl   put_text
    bl   put_nl
    ldr  r0, wlK_name
    ldrb r0, [r0]
    cmp  r0, #0
    bne  cns_end
    bl   print_inline
    db   'It comes from the MAC; name set <name> gives the board another one.', 13, 10, 0
    align 2
cns_end:
    pop  {r4, pc}

    align 4
wlK_wlv:            dd WLV
wlK_name:           dd WL_NET + 80
wlK_mac:            dd WLV + WL_MAC
wlK_sysinfo:        dd WL_SYSINFO
wlK_buf:            dd WL_DRX
wl_n_picow2:
    db   'picow-', 0
    align 4
wl_n_pico2w2:
    db   'pico2w-', 0
    align 4

; ---------- the WiFi at the start of the console ----------

; read_line: a byte came (r0, stays): its time (wl_auto waits for 3 quiet seconds)
wifi_key:
    push {r0, lr}
    bl   api_millis
    ldr  r1, wlL_aux
    str  r0, [r1, #4]
    pop  {r0, pc}

; once after the start, when the console has waited 3 seconds without a byte at its prompt (r0 the bytes typed, in
; LINE): a W with a network kept joins it as wlan on does, without its words (the console answers nothing meanwhile,
; 2 to 5 s; the bytes that come wait), then "WiFi: connected, address a.b.c.d (name)." or "WiFi: no connection: ..."
; on a line of its own, and the prompt with what was typed again. Not when the chip runs already (wlan on by hand)
wl_auto:
    push {r4, r5, lr}
    mov  r5, r0
    ldr  r1, wlL_wifi
    ldr  r0, [r1]
    movs r2, #1
    tst  r0, r2
    bne  wfar4
    b    wau_end
wfar4:
    ldr  r4, wlL_aux
    ldr  r0, [r4]
    cmp  r0, #0
    beq  wfar5
    b    wau_end                    ; tried once
wfar5:
    ldr  r1, wlL_wlv
    ldr  r0, [r1, #WL_BUSY]
    cmp  r0, #0
    beq  wfar6
    b    wau_end
wfar6:
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #0
    bne  wau_tried                  ; on already
    bl   api_millis
    ldr  r1, [r4, #4]
    subs r0, r0, r1
    ldr  r1, wlL_3s
    cmp  r0, r1
    bhs  wfar7
    b    wau_end
wfar7:
wau_tried:
    movs r0, #1
    str  r0, [r4]
    ldr  r1, wlL_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #0
    bne  wau_end
    bl   wl_net_load
    ldr  r0, wlL_net
    ldr  r0, [r0, #12]
    cmp  r0, #0
    beq  wau_end                    ; no network kept
    bl   wl_busy_on
    bl   wlan_start
    cmp  r0, #0
    bne  wau_fail
    bl   wl_join_tries
    cmp  r0, #0
    bne  wau_fail
    bl   wl_dhcp
    cmp  r0, #0
    bne  wau_noaddr
    bl   print_inline
    db   13, 10, 'WiFi: connected, address ', 0
    align 2
    ldr  r0, wlL_ip
    bl   wl_put_ip
    bl   print_inline
    db   ' (', 0
    align 2
    ldr  r0, wlL_buf
    bl   wl_dhcp_name
    ldr  r1, wlL_buf
    movs r2, #0
    strb r2, [r1, r0]
    mov  r0, r1
    bl   put_text
    bl   print_inline
    db   ').', 13, 10, 0
    align 2
    b    wau_prompt
wau_noaddr:
    bl   print_inline
    db   13, 10, 'WiFi: connected, no address (no DHCP server answered).', 13, 10, 0
    align 2
    b    wau_prompt
wau_fail:
    push {r0}
    bl   print_inline
    db   13, 10, 'WiFi: no connection: ', 0
    align 2
    pop  {r0}
    bl   put_text
    bl   put_nl
wau_prompt:
    bl   wl_busy_off
    bl   print_inline
    db   '> ', 0
    align 2
    ldr  r4, wlL_line
wau_line:
    cmp  r5, #0
    beq  wau_end
    ldrb r0, [r4]
    bl   put_char
    adds r4, r4, #1
    subs r5, r5, #1
    b    wau_line
wau_end:
    pop  {r4, r5, pc}

    align 4
wlL_wifi:           dd VARS + V_WIFI
wlL_wlv:            dd WLV
wlL_aux:            dd WLV + WL_AUX
wlL_net:            dd WL_NET
wlL_ip:             dd WLV + WL_IP
wlL_buf:            dd WL_DRX
wlL_line:           dd LINE
wlL_3s:             dd 3000

; ---------- the password for telnet ----------

; passwd, passwd set, passwd clear (r0 the rest of the line), as on the ESP32: the password a program asks a telnet
; client for (telnetd: wifi_login_check). The console keeps 12 bytes of its key in the record of the network (+112):
; PBKDF2-HMAC-SHA1 with the MAC of the board as its salt (about 2 s: a brake for one who tries many), not the password
cmd_passwd:
    push {r4, lr}
    bl   skip_spaces
    mov  r4, r0
    bl   wl_net_load
    ldrb r0, [r4]
    cmp  r0, #0
    bne  wfar8
    b    cpw_show
wfar8:
    mov  r0, r4
    bl   match_inline
    db   'clear', 0
    align 2
    cmp  r0, #0
    beq  wfar9
    b    cpw_clear
wfar9:
    mov  r0, r4
    bl   match_inline
    db   'set', 0
    align 2
    cmp  r0, #0
    bne  cpw_set
    bl   print_inline
    db   'passwd, passwd set, passwd clear', 13, 10, 0
    align 2
    pop  {r4, pc}
cpw_set:
    bl   wl_mac_known               ; the salt: the MAC (the chip on once when it has not run yet)
    cmp  r0, #0
    beq  wfar10
    b    cpw_end
wfar10:
    bl   print_inline
    db   'Password for telnet (not shown, 8 to 63 characters): ', 0
    align 2
    bl   wl_read_secret
    cmp  r0, #0
    blt  cpw_cancel
    ldr  r1, wlM_wlv
    str  r0, [r1, #WL_SECLEN]
    cmp  r0, #8
    blo  cpw_bad
    cmp  r0, #63
    bhi  cpw_bad
    ldr  r0, wlM_mac
    movs r1, #6
    ldr  r2, wlM_pw
    movs r3, #12
    bl   wl_pbkdf2_any
    bl   wl_forget
    bl   wl_net_save
    cmp  r0, #0
    beq  wfar11
    b    cpw_err
wfar11:
    bl   print_inline
    db   'The password for telnet is set.', 13, 10, 0
    align 2
    pop  {r4, pc}
cpw_bad:
    bl   wl_forget
    bl   print_inline
    db   'A password for telnet has 8 to 63 characters: nothing changed.', 13, 10, 0
    align 2
    bl   wl_net_load
    pop  {r4, pc}
cpw_cancel:
    bl   wl_forget
    bl   print_inline
    db   'Nothing changed.', 13, 10, 0
    align 2
    pop  {r4, pc}
cpw_clear:
    ldr  r0, wlM_pw
    movs r1, #12
    bl   wl_memset0
    bl   wl_net_save
    cmp  r0, #0
    bne  cpw_err
cpw_show:
    bl   wl_login_set
    cmp  r0, #0
    beq  cpw_none
    bl   print_inline
    db   'telnet asks for a password (passwd clear: none).', 13, 10, 0
    align 2
    pop  {r4, pc}
cpw_none:
    bl   print_inline
    db   'No password: telnet lets everyone in (passwd set gives one).', 13, 10, 0
    align 2
cpw_end:
    pop  {r4, pc}
cpw_err:
    bl   put_text
    bl   put_nl
    bl   wl_net_load
    pop  {r4, pc}

; the MAC of the chip known (WL_MAC)? Else the chip on (with the words of wlan on) and its MAC read. r0 0, else 1 (it
; said why)
wl_mac_known:
    push {lr}
    ldr  r1, wlM_mac
    ldr  r0, [r1]
    ldrh r1, [r1, #4]
    orrs r0, r1
    cmp  r0, #0
    bne  wmk_ok
    bl   wn_chip
    cmp  r0, #0
    bne  wmk_end
    ldr  r0, wlM_mac
    bl   wl_read_mac
    cmp  r0, #0
    beq  wmk_end
    bl   print_inline
    db   'The firmware of the WiFi chip did not tell its MAC.', 13, 10, 0
    align 2
    movs r0, #1
    pop  {pc}
wmk_ok:
    movs r0, #0
wmk_end:
    pop  {pc}

; a password for telnet set (WL_NET + 112: not 12 zeros)? r0 1, else 0 (WL_NET loaded)
wl_login_set:
    ldr  r1, wlM_pw
    movs r2, #0
wls_next:
    ldrb r0, [r1, r2]
    cmp  r0, #0
    bne  wls_yes
    adds r2, r2, #1
    cmp  r2, #12
    blo  wls_next
    movs r0, #0
    bx   lr
wls_yes:
    movs r0, #1
    bx   lr

; the text r0 (a 0 at its end) the password for telnet? Its key as passwd set makes it (about 2 s), against the 12
; bytes of the record: r0 1, else 0 (also when none is set, or the MAC is not known)
wl_login_check:
    push {r4, r5, lr}
    mov  r4, r0
    bl   wl_net_load
    bl   wl_login_set
    cmp  r0, #0
    beq  wlc_end
    ldr  r1, wlM_mac
    ldr  r0, [r1]
    ldrh r1, [r1, #4]
    orrs r0, r1
    beq  wlc_end                    ; (r0 0)
    movs r5, #0                     ; its length, into WL_SECRET (at most 63)
wlc_len:
    ldrb r0, [r4, r5]
    cmp  r0, #0
    beq  wlc_key
    ldr  r1, wlM_secret
    strb r0, [r1, r5]
    adds r5, r5, #1
    cmp  r5, #63
    blo  wlc_len
wlc_key:
    ldr  r1, wlM_wlv
    str  r5, [r1, #WL_SECLEN]
    ldr  r0, wlM_mac
    movs r1, #6
    ldr  r2, wlM_out
    movs r3, #12
    bl   wl_pbkdf2_any
    ldr  r0, wlM_secret
    movs r1, #64
    bl   wl_memset0
    movs r5, #0
    ldr  r4, wlM_out
    ldr  r3, wlM_pw
    movs r2, #0
wlc_cmp:
    ldrb r0, [r4, r2]
    ldrb r1, [r3, r2]
    eors r0, r1
    orrs r5, r0
    adds r2, r2, #1
    cmp  r2, #12
    blo  wlc_cmp
    mov  r0, r4
    movs r1, #12
    bl   wl_memset0                 ; the key made gone too
    movs r0, #0
    cmp  r5, #0
    bne  wlc_end
    movs r0, #1
wlc_end:
    pop  {r4, r5, pc}

    align 4
wlM_wlv:            dd WLV
wlM_mac:            dd WLV + WL_MAC
wlM_pw:             dd WL_NET + 112
wlM_secret:         dd WL_SECRET
wlM_out:            dd WL_DTX

; ---------- the packet N: the network for the Board Manager ----------

; N -> k and 84 bytes, the first 48 as on the ESP32 (TEspConsole.Network): the state (0 off, 1 on in no network, 3 in
; the network), the address (4 bytes), the MAC (6), 2 zeros, the name of the board (32 with its 0; "?" while the MAC
; is not known); then a word of flags (bit 0: a password for telnet, bit 1: a network kept) and the name of the
; network kept (32 bytes, zeros behind it)
pk_net:
    push {r4, r5, lr}
    bl   wl_net_load
    ldr  r4, wlO_buf
    mov  r0, r4
    movs r1, #84
    bl   wl_memset0
    ldr  r5, wlO_wlv
    ldr  r0, [r5, #WL_STATE]
    cmp  r0, #2
    bne  pkn_state
    movs r0, #3
pkn_state:
    str  r0, [r4]
    ldr  r0, [r5, #WL_IP]
    str  r0, [r4, #4]
    mov  r0, r4
    adds r0, r0, #8
    ldr  r1, wlO_mac
    movs r2, #6
    bl   wl_memcpy
    ldr  r0, wlO_name               ; a name of name set, or the MAC known: the name in use
    ldrb r0, [r0]
    cmp  r0, #0
    bne  pkn_name
    ldr  r1, wlO_mac
    ldr  r0, [r1]
    ldrh r1, [r1, #4]
    orrs r0, r1
    cmp  r0, #0
    bne  pkn_name
    movs r0, #'?'
    strb r0, [r4, #16]
    b    pkn_flags
pkn_name:
    mov  r0, r4
    adds r0, r0, #16
    bl   wl_dhcp_name
pkn_flags:
    bl   wl_login_set
    ldr  r1, wlO_net
    ldr  r1, [r1, #12]              ; the length of the name of the network
    cmp  r1, #0
    beq  pkn_put
    movs r1, #2
    orrs r0, r1
    str  r0, [r4, #48]
    mov  r0, r4
    adds r0, r0, #52
    ldr  r1, wlO_net
    ldr  r2, [r1, #12]
    adds r1, r1, #16
    cmp  r2, #32
    bls  pkn_copy
    movs r2, #32
pkn_copy:
    bl   wl_memcpy
    b    pkn_send
pkn_put:
    str  r0, [r4, #48]
pkn_send:
    movs r0, #'k'
    mov  r1, r4
    movs r2, #84
    bl   send_packet
    pop  {r4, r5, pc}

    align 4
wlO_buf:            dd WL_DTX
wlO_wlv:            dd WLV
wlO_mac:            dd WLV + WL_MAC
wlO_name:           dd WL_NET + 80
wlO_net:            dd WL_NET
