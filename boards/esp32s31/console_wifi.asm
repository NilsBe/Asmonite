; The console of the ESP32-S31: the WiFi (stage W6; the same as the console of the ESP32-C3 has, with the addresses
; of the S31), for the line .include "console_wifi.asm" of console.asm.
;
; The WiFi package of Asmonite in the flash (src\asmonite\WifiPackage.pas: the format of the ESP32 and the S3): the
; library of the WiFi from 0x100000 (its code and constants run through the cache: the service maps them), the head
; at 0x1F0000 ("AWP1", the chip 32, the hash, 3 parts: the library, the parts of wlan.rom for the RAM, the service
; wlan\wlansvc_s31.asm, each its address, length and CRC-32, then the CRC-32 of the head), the parts for the RAM from
; 0x1F1000 or behind the library when they do not fit there. The packet A writes into this room (as O, W, C for a
; file, without an entry in the directory); Y reads it. The console loads the two parts for the RAM when the WiFi is
; needed first (wl_ready): the parts of wlan.rom to 0x2F046000 and 0x2F048000, the service to 0x2F03A000; the service
; maps the flash and sets up the rest itself.
;
; The network of the board: two sectors right below the room of the package, 0xFE000 and 0xFF000, as on the S3: each
; time the other one is written, with a number one higher; the valid one with the higher number counts. A record of
; 128 bytes: +0 "AWN1", +4 the number, +8 bit 0 an open network (no key), bit 1 wlan off, +12 the length of the name
; (1 .. 32), +16 the name (32 bytes), +48 the key (32 bytes: the PMK of WPA2, PBKDF2-SHA1 of the password and the
; name; not the password), +80 the name of the board (name set: up to 31 characters and a 0; zeros: the one of the
; MAC, as on the S3 and the Pico W), +124 the CRC-32 of the bytes before it. A record may keep the name of the board
; only (the length of the name of the network 0: no network; wl_known).
;
; The console runs on core 0 of the S31 only: the WiFi runs while the console is in a function of the service
; (wifi_on, wifi_connect, wifi_scan, ...) and by the tick of the service in between; its interrupts only fill its
; queues. wlan on (and wlan set, and the start of the console with a network kept and not wlan off: wl_boot) begins the connection
; (wifi_begin); from then on the service keeps it, gets the address by DHCP and answers ARP and ping (version 4,
; wlan\wlannet_c3.asm), also while a program runs; console_net.asm says at the prompt what changed.
; Once the service ran, the interrupts of the core stay on (its OS layer): fl_call keeps them off while a function of
; the ROM works on the flash (the cache is off then, and a handler in the flash would stop the chip).
;
; The commands:
;   wlan          the network of the board and the state of the WiFi
;   wlan set      the name of a network and its password (without echo; empty: an open network); then the WiFi on
;   wlan on       the WiFi on and connected to the network (kept over resets: not wlan off)
;   wlan off      the WiFi off (kept over resets)
;   wlan clear    the board knows no network
;   wlan scan     the networks in reach (channel, signal, kind, name)
;   name          the name of the board in the network (name set <name>, name clear: the one of the MAC); DHCP gives
;                 it to the router, the service answers mDNS for name.local

SVC          equ 0x2F03A000             ; the WiFi service (wlan\wlansvc_s31.asm): its entries
SVC_ON       equ SVC + 0x08
SVC_OFF      equ SVC + 0x0C
SVC_SCAN     equ SVC + 0x10
SVC_CONNECT  equ SVC + 0x1C
SVC_STATUS   equ SVC + 0x20
SVC_MAC      equ SVC + 0x2C
SVC_DISC     equ SVC + 0x30
SVC_PMK      equ SVC + 0x3C
SVC_SETNAME  equ SVC + 0x54             ; wifi_set_name (version 6)
SVC_MAGIC    equ 0x43565357             ; "WSVC"
WIFI_LO      equ 0x100000               ; the room of the WiFi package in the flash
WIFI_HI      equ 0x200000
WIFI_HEAD    equ 0x1F0000
WIFI_MAGIC   equ 0x31505741             ; "AWP1"
CRED_AT      equ 0xFE                   ; the two sectors of the network (0xFE000, 0xFF000)
CRED_MAGIC   equ 0x314E5741             ; "AWN1"
CRED         equ 0x2F074000             ; the record in use (128 bytes), +128 one read
WHEAD        equ 0x2F074200             ; the head of the WiFi package (56 bytes)
WENT         equ 0x2F074240             ; an entry for segments: +20 the sector, +24 the length
HEXKEY       equ 0x2F074260             ; the key as 64 hex digits and a 0 (for wifi_connect)
SSIDZ        equ 0x2F0742B0             ; the name of the network and a 0
PWBUF        equ 0x2F074300             ; the password typed (64 bytes and a 0; cleared at once)
SCANBUF      equ 0x2F075000             ; wlan scan: 16 networks of 48 bytes
SCAN_MAX     equ 16

; ---------- the commands ----------

; wlan [set | on | off | clear | scan]: a0 the rest of the line. s0 it
cmd_wlan:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    lbu  t0, 0(s0)
    beqz t0, wlc_show
    la   a1, c_set
    call str_eq
    bnez a0, wlc_set
    mv   a0, s0
    la   a1, c_on
    call str_eq
    bnez a0, wlc_on
    mv   a0, s0
    la   a1, c_off
    call str_eq
    bnez a0, wlc_off
    mv   a0, s0
    la   a1, c_clear
    call str_eq
    bnez a0, wlc_clear
    mv   a0, s0
    la   a1, c_scan
    call str_eq
    bnez a0, wlc_scan
    la   a0, s_wluse
    call print
    j    wlc_end
wlc_show:
    call wl_show
    j    wlc_end
wlc_set:
    call wl_set
    j    wlc_end
wlc_on:
    li   a0, 0
    call wl_switch
    j    wlc_end
wlc_off:
    li   a0, 1
    call wl_switch
    j    wlc_end
wlc_clear:
    call wl_clear
    j    wlc_end
wlc_scan:
    call wl_scan
wlc_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wlan: the network and the state of the WiFi
wl_show:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call wl_known
    bnez a0, wls_net
    la   a0, s_wlnone
    call print
    j    wls_state
wls_net:
    la   a0, s_wlnet
    call print
    call wl_print_name
    li   t0, CRED
    lw   t1, 8(t0)
    andi t1, t1, 1
    la   a0, s_wlwpa
    beqz t1, wls_kind
    la   a0, s_wlopen
wls_kind:
    call print
    li   t0, CRED
    lw   t1, 8(t0)
    andi t1, t1, 2
    beqz t1, wls_state
    la   a0, s_wlisoff
    call print
    j    wls_end
wls_state:
    call wl_state
    sw   a0, 8(sp)
    la   t0, wls_texts
    slli a0, a0, 2
    add  t0, t0, a0
    lw   a0, 0(t0)
    call print
    lw   t0, 8(sp)                      ; connected: the address (once DHCP of the service gave one)
    li   t1, 3
    bne  t0, t1, wls_end
    la   t0, net_ip
    lw   t0, 0(t0)
    beqz t0, wls_end
    la   a0, s_wladdr
    la   a1, net_ip
    call net_say_plain
wls_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wl_known(): 1 when the board keeps a network (a valid record with the name of a network; a record may keep the name
; of the board only: name set), else 0. It changes t0 only
wl_known:
    la   t0, cred_ok
    lw   a0, 0(t0)
    beqz a0, wlk_end
    li   t0, CRED
    lw   a0, 12(t0)
    snez a0, a0
wlk_end:
    ret

; wl_state(): 0 the WiFi does not run, 1 on and not connected, 3 connected, 4 off (wlan off), as packet N says it
wl_state:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, wlst_run
    li   t0, CRED
    lw   t1, 8(t0)
    andi t1, t1, 2
    li   a0, 4
    bnez t1, wlst_end
wlst_run:
    la   t0, wifi_up
    lw   t0, 0(t0)
    li   a0, 0
    beqz t0, wlst_end
    li   t0, SVC_STATUS
    jalr ra, 0(t0)
    andi a0, a0, 1
    slli a0, a0, 1
    addi a0, a0, 1                      ; 1 or 3
    li   t0, 3
    beq  a0, t0, wlst_end
    la   t0, net_keep                   ; not connected: 2 while the service keeps trying
    lw   t0, 0(t0)
    add  a0, a0, t0
wlst_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the name of the network of CRED
wl_print_name:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    li   s0, CRED + 16
    li   t0, CRED
    lw   s1, 12(t0)
wlpn_next:
    beqz s1, wlpn_end
    lbu  a0, 0(s0)
    call put_char
    addi s0, s0, 1
    addi s1, s1, -1
    j    wlpn_next
wlpn_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wlan set: the name and the password (without echo; Ctrl+C: nothing changes). The console keeps the name and the
; key (wifi_pmk of the service), not the password: PWBUF is cleared at once. s0 the length of the name, s1 the one of
; the password, s2 the flags kept (wlan off)
wl_set:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    li   s2, 0
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, wlt_ask
    li   t0, CRED
    lw   s2, 8(t0)
    andi s2, s2, 2
wlt_ask:
    la   a0, s_wlask1
    call print
    li   a0, CHUNK
    li   a1, 32
    call read_line
    bltz a0, wlt_done
    mv   s0, a0
    beqz s0, wlt_done
    la   a0, s_wlask2
    call print
    la   t0, no_echo
    li   t1, 1
    sw   t1, 0(t0)
    li   a0, PWBUF
    li   a1, 64
    call read_line
    la   t0, no_echo
    sw   zero, 0(t0)
    bltz a0, wlt_forget
    mv   s1, a0
    beqz s1, wlt_record
    li   t0, 8                          ; WPA2: 8 .. 63 characters
    bltu s1, t0, wlt_short
    li   t0, 64
    bltu s1, t0, wlt_record
wlt_short:
    la   a0, s_wlbadpw
    call print
    j    wlt_forget
wlt_record:
    li   a0, CRED                       ; the record: zeros (the name of the board at +80 stays), then the name
    li   a1, CRED + 80
    la   t0, cred_ok
    lw   t0, 0(t0)
    bnez t0, wlt_zero
    li   a1, CRED + 128
wlt_zero:
    call zero_words
    li   t0, CRED
    li   t1, CRED_MAGIC
    sw   t1, 0(t0)
    sw   s0, 12(t0)
    li   a0, CRED + 16
    li   a1, CHUNK
    mv   a2, s0
    call copy_bytes
    li   t0, CRED
    bnez s1, wlt_key
    ori  t1, s2, 1                      ; an open network
    sw   t1, 8(t0)
    j    wlt_save
wlt_key:
    sw   s2, 8(t0)
    call wl_ready                       ; the service computes the key
    beqz a0, wlt_pmk
    call print
    la   a0, s_crlf
    call print
    la   t0, cred_ok                    ; the record of the flash again
    sw   zero, 0(t0)
    call cred_load
    j    wlt_forget
wlt_pmk:
    la   a0, s_wlkey
    call print
    li   a0, PWBUF
    li   a1, CHUNK
    mv   a2, s0
    li   a3, CRED + 48
    li   t0, SVC_PMK
    jalr ra, 0(t0)
    call wl_forget
wlt_save:
    call cred_save
    beqz a0, wlt_saved
    la   a0, s_flasherr
    call print
    j    wlt_done
wlt_saved:
    la   a0, s_wlsaved
    call print
    call wl_print_name
    la   a0, s_dotcrlf
    call print
    li   t0, CRED                       ; the WiFi on the new network at once (not with wlan off)
    lw   t1, 8(t0)
    andi t1, t1, 2
    bnez t1, wlt_done
    call wl_start
    j    wlt_done
wlt_forget:
    call wl_forget
wlt_done:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the password gone from the RAM (PWBUF)
wl_forget:
    li   a0, PWBUF
    li   a1, PWBUF + 72
    j    zero_words

; wlan on (a0 = 0) / wlan off (a0 = 1): bit 1 of the record (kept over resets), then the WiFi on or off. s0 a0
wl_switch:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    call wl_known
    bnez a0, wlw_net
    beqz s0, wlw_none                   ; wlan off without a network kept: the WiFi off all the same (a program may
    call wl_halt                        ; have started it), nothing to keep
wlw_none:
    la   a0, s_wlnone
    call print
    j    wlw_end
wlw_net:
    li   t0, CRED
    lw   t1, 8(t0)
    andi t2, t1, -3
    slli t3, s0, 1
    or   t2, t2, t3
    beq  t1, t2, wlw_go                 ; as it is: nothing to write
    sw   t2, 8(t0)
    call cred_save
    beqz a0, wlw_go
    la   a0, s_flasherr
    call print
    j    wlw_end
wlw_go:
    bnez s0, wlw_off
    call wl_start
    j    wlw_end
wlw_off:
    call wl_halt
    la   a0, s_wloffnow
    call print
wlw_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wlan clear: the board knows no network; the WiFi off. A name of the board (name set, +80) stays: a record without a
; network (the length of its name 0, as on the Pico W), else both sectors erased
wl_clear:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call wl_halt
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, wlx_erase
    li   t0, CRED + 80
    lbu  t0, 0(t0)
    beqz t0, wlx_erase
    li   a0, CRED
    li   a1, CRED + 80
    call zero_words
    call cred_save
    mv   t1, a0
    la   a0, s_wlcleared
    beqz t1, wlx_say
    la   a0, s_flasherr
    j    wlx_say
wlx_erase:
    li   a0, CRED_AT
    call fl_erase
    sw   a0, 8(sp)
    li   a0, CRED_AT + 1
    call fl_erase
    lw   t0, 8(sp)
    or   t1, a0, t0
    la   t0, cred_ok
    sw   zero, 0(t0)
    la   t0, cred_num
    sw   zero, 0(t0)
    la   t0, cred_sec
    sw   zero, 0(t0)
    la   a0, s_wlcleared
    beqz t1, wlx_say
    la   a0, s_flasherr
wlx_say:
    call print
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wlan scan: the networks in reach. s0 the number, s1 a record
wl_scan:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    call wl_up
    bnez a0, wlsc_fail
    la   a0, s_wlscan
    call print
    li   a0, SCANBUF
    li   a1, SCAN_MAX
    li   t0, SVC_SCAN
    jalr ra, 0(t0)
    mv   s0, a0
    sw   a0, 0(sp)                      ; the number, for the end
    bltz s0, wlsc_err
    li   s1, SCANBUF
wlsc_next:
    beqz s0, wlsc_sum
    la   a0, s_wlch                     ; "  channel "
    call print
    lbu  a0, 6(s1)
    li   a1, 2
    call print_dec_right
    la   a0, s_wlsig                    ; "  -54 dBm  "
    call print
    li   a0, '-'
    call put_char
    lb   a0, 7(s1)
    neg  a0, a0
    li   a1, 2
    call print_dec_right
    la   a0, s_wldbm
    call print
    lbu  t0, 8(s1)
    la   a0, s_wlkopen
    beqz t0, wlsc_kind
    la   a0, s_wlkwpa
wlsc_kind:
    call print
    addi a0, s1, 12
    call print
    la   a0, s_crlf
    call print
    addi s1, s1, 48
    addi s0, s0, -1
    j    wlsc_next
wlsc_err:
    neg  s0, s0
    la   a0, s_wlerr
    call print
    mv   a0, s0
    call print_hex
    la   a0, s_crlf
    call print
    j    wlsc_end
wlsc_fail:
    call print
    la   a0, s_crlf
    call print
    j    wlsc_end
wlsc_sum:
    lw   a0, 0(sp)                      ; "7 network(s)"
    call print_dec
    la   a0, s_wlnets
    call print
wlsc_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the WiFi on and off ----------

; the WiFi on (wl_up) and connected to the network of CRED (wifi_connect: it waits); says so, or why not
wl_start:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call wl_up
    beqz a0, wlg_up
    mv   t0, a0
    la   a0, s_wlwifi
    sw   t0, 8(sp)
    call print
    lw   a0, 8(sp)
    call print
    la   a0, s_crlf
    call print
    j    wlg_end
wlg_up:
    li   a0, SSIDZ                      ; the name with its 0
    li   a1, SSIDZ + 36
    call zero_words
    li   a0, SSIDZ
    li   a1, CRED + 16
    li   t0, CRED
    lw   a2, 12(t0)
    call copy_bytes
    li   t0, CRED                       ; the key as 64 hex digits (none: an open network)
    lw   t1, 8(t0)
    andi t1, t1, 1
    li   a1, 0
    bnez t1, wlg_go
    call wl_hexkey
    li   a1, HEXKEY
wlg_go:
    li   a0, SSIDZ                      ; one attempt, in the background (then the service keeps the connection)
    li   t0, SVC_BEGIN
    jalr ra, 0(t0)
    sw   a0, 8(sp)
    li   a0, HEXKEY                     ; the key away from the RAM again (the service keeps it)
    li   a1, HEXKEY + 68
    call zero_words
    lw   t0, 8(sp)
    bnez t0, wlg_fail
    call net_start
    la   a0, s_wlconn1
    call print
    call wl_print_name
    la   a0, s_wlconn2
    call print
    j    wlg_end
wlg_fail:
    la   a0, s_wlnoconn
    call print
    lw   a0, 8(sp)
    call print_hex
    la   a0, s_wlnoconn2
    call print
wlg_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; at the start of the console (after the autostart): the WiFi in the background when the board keeps a network and
; wlan off did not switch it off
wl_boot:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call wl_known
    beqz a0, wlb_end
    li   t0, CRED
    lw   t1, 8(t0)
    andi t1, t1, 2
    bnez t1, wlb_end
    call wl_start
wlb_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the key of CRED (+48, 32 bytes) as 64 hex digits and a 0 into HEXKEY. It calls nothing.
wl_hexkey:
    li   t0, CRED + 48
    li   t1, HEXKEY
    li   t2, 32
wlh_byte:
    lbu  t3, 0(t0)
    srli t4, t3, 4
    addi t4, t4, '0'
    li   t5, '9' + 1
    bltu t4, t5, wlh_hi
    addi t4, t4, 'a' - '9' - 1
wlh_hi:
    sb   t4, 0(t1)
    andi t4, t3, 15
    addi t4, t4, '0'
    bltu t4, t5, wlh_lo
    addi t4, t4, 'a' - '9' - 1
wlh_lo:
    sb   t4, 1(t1)
    addi t0, t0, 1
    addi t1, t1, 2
    addi t2, t2, -1
    bnez t2, wlh_byte
    sb   zero, 0(t1)
    ret

; wifi_up() of the functions for programs (+64): the WiFi on as wl_up below, without a network (wifi_start of
; abelle/lib/esp32s31/wifi.abel calls it when the service is not in the RAM yet); 0, or the text of the problem
api_wifi_up:
    j    wl_up

; wl_up(): the service out of the WiFi package (wl_ready), then wifi_on (once after a reset); 0, or the text of the
; problem
wl_up:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   t0, wifi_up
    lw   t0, 0(t0)
    li   a0, 0
    bnez t0, wlu_end
    call wl_ready
    bnez a0, wlu_end
    la   a0, s_wlstart
    call print
    call flush
    li   t0, CLKRST                     ; the core from the crystal (cpu_clock of a program): the radio needs the
    lw   t1, 0(t0)                      ; PLL, back to 160 MHz (a clock from the CPLL stays)
    andi t1, t1, 3
    bnez t1, wlu_pll
    call clock_init
wlu_pll:
    li   t0, SVC_ON
    jalr ra, 0(t0)
    beqz a0, wlu_on
    sw   a0, 8(sp)
    la   a0, s_wlonerr
    call print
    lw   a0, 8(sp)
    call print_hex
    la   a0, s_crlf
    call print
    la   a0, e_wlon
    j    wlu_end
wlu_on:
    la   t0, wifi_up
    li   t1, 1
    sw   t1, 0(t0)
    li   a0, 0
wlu_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the WiFi off (wifi_disconnect, wifi_off; nothing when it does not run)
wl_halt:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call net_stop
    la   t0, wifi_up
    lw   t1, 0(t0)
    beqz t1, wlx_svc
    sw   zero, 0(t0)
    li   t0, SVC_DISC
    jalr ra, 0(t0)
    li   t0, SVC_OFF
    jalr ra, 0(t0)
    j    wlx_done
wlx_svc:                                ; the console did not start it, a program may have (wifi_on of wifi.abel): off
    la   t0, svc_loaded                 ; as well when the service is in the RAM (its wifi_off does nothing when the
    lw   t1, 0(t0)                      ; WiFi does not run)
    beqz t1, wlx_done
    li   t0, SVC_OFF
    jalr ra, 0(t0)
wlx_done:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wl_ready(): the service in the RAM, out of the WiFi package of the flash (once after a reset: the head checked, the
; CRC-32 of each part, the two parts for the RAM into their places by segments); 0, or the text of the problem
wl_ready:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    la   t0, svc_loaded
    lw   t1, 0(t0)
    li   a0, 0
    li   t2, 1
    beq  t1, t2, wlr_end
    la   a0, e_wlstale
    bnez t1, wlr_end                    ; 2: the package was written anew since
    li   a0, WIFI_HEAD
    li   a1, WHEAD
    li   a2, 56
    call fl_read
    li   s0, WHEAD
    lw   t0, 0(s0)
    li   t1, WIFI_MAGIC
    bne  t0, t1, wlr_none
    lw   t0, 4(s0)
    li   t1, 32                         ; the chip: the S31
    bne  t0, t1, wlr_none
    lw   t0, 12(s0)
    li   t1, 3
    bne  t0, t1, wlr_none
    li   a0, 0
    mv   a1, s0
    li   a2, 52
    call crc32
    lw   t0, 52(s0)
    bne  a0, t0, wlr_none
    addi a0, s0, 16                     ; each part: its CRC-32 in the flash
    call wl_part_ok
    beqz a0, wlr_bad
    addi a0, s0, 28
    call wl_part_ok
    beqz a0, wlr_bad
    addi a0, s0, 40
    call wl_part_ok
    beqz a0, wlr_bad
    addi a0, s0, 28                     ; the parts of wlan.rom for the RAM, then the service
    call wl_load
    bnez a0, wlr_end
    addi a0, s0, 40
    call wl_load
    bnez a0, wlr_end
    li   t0, SVC                        ; the service: its mark and a version with the network (wifi_get_ip)
    lw   t1, 0(t0)
    li   t2, SVC_MAGIC
    bne  t1, t2, wlr_old
    lw   t1, 4(t0)
    li   t2, 4
    bltu t1, t2, wlr_old
    la   t0, svc_loaded
    li   t1, 1
    sw   t1, 0(t0)
    call wl_name_push                   ; the name of the board (name set) for DHCP and mDNS
    li   a0, 0
    j    wlr_end
wlr_none:
    la   a0, e_wlnone
    j    wlr_end
wlr_bad:
    la   a0, e_wlbad
    j    wlr_end
wlr_old:
    la   a0, e_wlold
wlr_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wl_part_ok(part): 1 when the CRC-32 of the part (its address in the flash, its length, its CRC-32 at a0) is right
wl_part_ok:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    lw   t0, 0(a0)
    lw   a1, 4(a0)
    mv   a0, t0
    call flash_crc
    lw   t0, 8(sp)
    lw   t0, 8(t0)
    sub  a0, a0, t0
    seqz a0, a0
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wl_load(part): the image of the part (a0: its address in the flash, a multiple of 4 KB, and its length) into its
; places in the RAM (segments, as load does: checked first, then copied); 0 or the text of the problem
wl_load:
    addi sp, sp, -16
    sw   ra, 12(sp)
    lw   t0, 0(a0)
    lw   t1, 4(a0)
    li   t2, WENT
    srli t0, t0, 12
    sw   t0, 20(t2)
    sw   t1, 24(t2)
    li   a0, WENT
    li   a1, 2                          ; checked (the room of the WiFi too)
    call segments
    bnez a0, wll_end
    li   a0, WENT
    li   a1, 3                          ; copied
    call segments
wll_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the name of the board ----------

; name, name set <name>, name clear (a0 the rest of the line): the name of the board in the network (DHCP option 12,
; mDNS: name.local), kept in the record of the network (+80, as on the ESP32 and the Pico W: wlan set and wlan clear
; keep it). name shows it, name set gives it another one (1 to 31 letters, digits and '-'), name clear: the one of the
; MAC again. The service takes it at once (with an address: a REQUEST of DHCP, so that the router learns it). s0 the
; rest of the line, s1 the length of the name
cmd_name:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    lbu  t0, 0(s0)
    beqz t0, cnm_show
    la   a1, c_clear
    call str_eq
    bnez a0, cnm_clear
    lbu  t0, 0(s0)                      ; set, a space, the name
    li   t1, 's'
    bne  t0, t1, cnm_use
    lbu  t0, 1(s0)
    li   t1, 'e'
    bne  t0, t1, cnm_use
    lbu  t0, 2(s0)
    li   t1, 't'
    bne  t0, t1, cnm_use
    lbu  t0, 3(s0)
    beqz t0, cnm_bad
    li   t1, ' '
    bne  t0, t1, cnm_use
    addi s0, s0, 3
cnm_sp:
    lbu  t0, 0(s0)
    li   t1, ' '
    bne  t0, t1, cnm_chk
    addi s0, s0, 1
    j    cnm_sp
cnm_chk:
    li   s1, 0                          ; its length; letters, digits and '-' only
cnm_char:
    add  t0, s0, s1
    lbu  t0, 0(t0)
    beqz t0, cnm_len
    li   t1, '-'
    beq  t0, t1, cnm_ok
    li   t1, '0'
    bltu t0, t1, cnm_bad
    li   t1, '9' + 1
    bltu t0, t1, cnm_ok
    ori  t0, t0, 0x20                   ; small
    li   t1, 'a'
    bltu t0, t1, cnm_bad
    li   t1, 'z' + 1
    bgeu t0, t1, cnm_bad
cnm_ok:
    addi s1, s1, 1
    li   t1, 32
    bltu s1, t1, cnm_char
cnm_bad:
    la   a0, s_nmbad
    call print
    j    cnm_end
cnm_len:
    beqz s1, cnm_bad
    call cnm_rec
    li   t0, CRED + 80                  ; in small letters (as on the ESP32: Test-Board1 is test-board1)
    li   t1, 0
cnm_copy:
    add  t2, s0, t1
    lbu  t2, 0(t2)
    li   t3, 'A'
    bltu t2, t3, cnm_put
    li   t3, 'Z' + 1
    bgeu t2, t3, cnm_put
    ori  t2, t2, 0x20
cnm_put:
    add  t3, t0, t1
    sb   t2, 0(t3)
    addi t1, t1, 1
    bltu t1, s1, cnm_copy
    j    cnm_save
cnm_clear:
    call cnm_rec
cnm_save:
    call cred_save
    beqz a0, cnm_saved
    la   a0, s_flasherr
    call print
    la   t0, cred_ok                    ; the record of the flash again
    sw   zero, 0(t0)
    call cred_load
    j    cnm_end
cnm_saved:
    call wl_name_push
cnm_show:
    call cnm_say
    j    cnm_end
cnm_use:
    la   a0, s_nmuse
    call print
cnm_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the record for a new name of the board: its place cleared (+80, 32 bytes); without a record a new one without a
; network (zeros)
cnm_rec:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a0, CRED + 80
    li   a1, CRED + 112
    la   t0, cred_ok
    lw   t0, 0(t0)
    bnez t0, cnr_zero
    li   a0, CRED
    li   a1, CRED + 128
cnr_zero:
    call zero_words
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; "The name of the board: esp32s31-789a (esp32s31-789a.local)" (and where it comes from)
cnm_say:
    addi sp, sp, -48
    sw   ra, 44(sp)
    la   a0, s_nmis
    call print
    mv   a0, sp
    call wl_board_name
    mv   a0, sp
    call print
    la   a0, s_ntname1
    call print
    mv   a0, sp
    call print
    la   a0, s_ntname2
    call print
    la   a0, s_crlf
    call print
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, cns_mac
    li   t0, CRED + 80
    lbu  t0, 0(t0)
    bnez t0, cns_end
cns_mac:
    la   a0, s_nmmac
    call print
cns_end:
    lw   ra, 44(sp)
    addi sp, sp, 48
    ret

; wl_board_name(buf): the name of the board and a 0 into buf (32 bytes): the one of name set (the record, +80), else
; esp32s31- and the last two bytes of the MAC of the factory (small letters). s0 buf
wl_board_name:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, wbn_mac
    li   t0, CRED + 80
    lbu  t0, 0(t0)
    beqz t0, wbn_mac
    mv   a0, s0
    li   a1, CRED + 80
    li   a2, 31
    call copy_bytes
    sb   zero, 31(s0)
    j    wbn_end
wbn_mac:
    mv   a0, s0
    la   a1, s_wlname
    li   a2, 9
    call copy_bytes
    li   t0, EFUSE_MAC
    lw   t0, 0(t0)
    addi t1, s0, 9
    li   t2, 12
wbn_digit:
    srl  t3, t0, t2
    andi t3, t3, 15
    addi t3, t3, '0'
    li   t4, '9' + 1
    bltu t3, t4, wbn_put
    addi t3, t3, 'a' - '9' - 1
wbn_put:
    sb   t3, 0(t1)
    addi t1, t1, 1
    addi t2, t2, -4
    bgez t2, wbn_digit
    sb   zero, 0(t1)
wbn_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; wl_name_push(): the name of name set to the service (wifi_set_name, version 6), 0 for the one of the MAC; nothing
; when the service is not in the RAM or an older one
wl_name_push:
    la   t0, svc_loaded
    lw   t0, 0(t0)
    li   t1, 1
    bne  t0, t1, wnp_end
    li   t0, SVC
    lw   t1, 4(t0)
    li   t2, 6
    bltu t1, t2, wnp_end
    li   a0, 0
    la   t0, cred_ok
    lw   t0, 0(t0)
    beqz t0, wnp_call
    li   a0, CRED + 80
wnp_call:
    li   t0, SVC_SETNAME
    jr   t0
wnp_end:
    ret

; ---------- the record of the network ----------

; cred_load(): the valid record with the higher number into CRED (cred_ok 1, cred_num, cred_sec its sector), else
; cred_ok 0; cred_ok. s0 the sector, s1 the best number + 1 (0 none)
cred_load:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    la   t0, cred_ok
    sw   zero, 0(t0)
    li   s0, CRED_AT
    li   s1, 0
crl_next:
    slli a0, s0, 12
    li   a1, CRED + 128
    li   a2, 128
    call fl_read
    bnez a0, crl_skip
    li   t0, CRED + 128
    lw   t1, 0(t0)
    li   t2, CRED_MAGIC
    bne  t1, t2, crl_skip
    li   a0, 0
    li   a1, CRED + 128
    li   a2, 124
    call crc32
    li   t0, CRED + 128
    lw   t1, 124(t0)
    bne  a0, t1, crl_skip
    lw   t1, 4(t0)                      ; the number: higher than the one before?
    addi t1, t1, 1
    bgeu s1, t1, crl_skip
    mv   s1, t1
    li   a0, CRED
    li   a1, CRED + 128
    li   a2, 128
    call copy_bytes
    la   t0, cred_ok
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, cred_sec
    sw   s0, 0(t0)
    addi t1, s1, -1
    la   t0, cred_num
    sw   t1, 0(t0)
crl_skip:
    addi s0, s0, 1
    li   t0, CRED_AT + 2
    bltu s0, t0, crl_next
    la   t0, cred_ok
    lw   a0, 0(t0)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; cred_save(): CRED into the other sector (the first one when there is none), with a number one higher and its
; CRC-32; 0 done. s0 the sector
cred_save:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    li   s0, CRED_AT
    la   t0, cred_ok
    lw   t0, 0(t0)
    li   t2, 0
    beqz t0, crs_num
    la   t1, cred_sec                   ; the other one
    lw   t1, 0(t1)
    li   t2, CRED_AT
    bne  t1, t2, crs_first
    li   s0, CRED_AT + 1
crs_first:
    la   t2, cred_num
    lw   t2, 0(t2)
    addi t2, t2, 1
crs_num:
    li   t0, CRED
    li   t1, CRED_MAGIC
    sw   t1, 0(t0)
    sw   t2, 4(t0)
    li   a0, 0
    li   a1, CRED
    li   a2, 124
    call crc32
    li   t0, CRED
    sw   a0, 124(t0)
    mv   a0, s0
    call fl_erase
    bnez a0, crs_end
    slli a0, s0, 12
    li   a1, CRED
    li   a2, 128
    call fl_write
    bnez a0, crs_end
    li   t0, CRED
    lw   t1, 4(t0)
    la   t0, cred_num
    sw   t1, 0(t0)
    la   t0, cred_sec
    sw   s0, 0(t0)
    la   t0, cred_ok
    li   t1, 1
    sw   t1, 0(t0)
    li   a0, 0
crs_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the packets ----------

; A address length crc: a part of the room of the WiFi package opens for writing as a file of O, its sectors erased;
; W and C as for a file (no entry in the directory). The WiFi off first: its library may be in this room (the service
; is loaded anew only after a reset then). s0 the address, s1 the length, s2 the sectors
pk_area:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    li   t0, 12
    beq  a0, t0, pka_len
    la   a0, e_size
    call send_err
    j    pka_end
pka_len:
    li   t0, PKT
    lw   s0, 4(t0)
    lw   s1, 8(t0)
    slli t1, s0, 20                     ; a whole sector
    bnez t1, pka_where
    li   t1, WIFI_LO
    bltu s0, t1, pka_where
    li   t1, WIFI_HI
    bgeu s0, t1, pka_where
    sub  t2, t1, s0                     ; the room from the address on
    bltu t2, s1, pka_where
    call wl_halt
    la   t0, svc_loaded                 ; a service in the RAM: loaded anew after a reset only
    lw   t1, 0(t0)
    beqz t1, pka_erase
    li   t1, 2
    sw   t1, 0(t0)
pka_erase:
    li   t0, 4095
    add  s2, s1, t0
    srli s2, s2, 12
    srli s0, s0, 12                     ; the first sector
    li   s3, 0
pka_next:
    beq  s3, s2, pka_state
    add  a0, s0, s3
    call fl_erase
    bnez a0, pka_err
    addi s3, s3, 1
    j    pka_next
pka_state:
    la   t0, wf_open
    li   t1, 1
    sw   t1, 0(t0)                      ; open
    sw   s0, 4(t0)                      ; the first sector
    sw   s1, 8(t0)                      ; the length
    li   t1, PKT
    lw   t2, 12(t1)
    sw   t2, 12(t0)                     ; the CRC-32
    sw   zero, 16(t0)                   ; written so far
    li   t2, -1
    sw   t2, 20(t0)                     ; no entry: the room of the WiFi package
    sw   t2, 24(t0)                     ; the offset of the last piece
    call send_ok
    j    pka_end
pka_where:
    la   a0, e_area
    call send_err
    j    pka_end
pka_err:
    la   a0, s_flasherr
    call send_err
pka_end:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; N: the network of the board, 84 bytes as the console of a Pico W gives them: +0 the state (wl_state), +4 the
; address (none yet: K5b), +8 the MAC (once the WiFi ran), +16 the name of the board (name set, else esp32s31-xxxx),
; +48 the flags (bit 1 a network kept), +52 the name of the network
pk_net:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a0, OUT + 4
    li   a1, OUT + 4 + 84
    call zero_words
    call wl_state
    li   t0, OUT + 4
    sw   a0, 0(t0)
    la   t0, wifi_up
    lw   t0, 0(t0)
    beqz t0, pkn_cred
    li   a0, OUT + 12
    li   t0, SVC_MAC
    jalr ra, 0(t0)
    la   t0, net_ip                     ; the address (DHCP), as it lies in the RAM
    lw   t0, 0(t0)
    li   t1, OUT + 8
    sw   t0, 0(t1)
pkn_cred:
    li   a0, OUT + 20                   ; the name of the board (name set, else the one of the MAC)
    call wl_board_name
    call wl_known
    beqz a0, pkn_send
    li   t0, OUT + 4
    li   t1, 2
    sw   t1, 48(t0)
    li   a0, OUT + 56
    li   a1, CRED + 16
    li   t1, CRED
    lw   a2, 12(t1)
    call copy_bytes
pkn_send:
    li   a0, 'k'
    li   a1, OUT + 4
    li   a2, 84
    call send_packet
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
