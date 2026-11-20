; The console of the ESP32-C3: the packets for a program on the PC (stage K4), for the line .include "console_pk.asm"
; of console.asm. The same packets as on the ESP32 and the ESP32-S3 (their console.asm; Asmonite:
; src\debugger\EspConsole.pas). A packet: STX (0x02), the command, the length of the data (16 bits), the data, the
; CRC-32 of the command, the length and the data (all little endian). The PC sends one and waits for the answer. A name
; is a field of 20 bytes (the name, zeros behind it).
;   P              -> k "Asmonite console 2"
;   V              -> k the version of the console (4 bytes: what console_version() gives a program)
;   F              -> f files, bytes in use, bytes free (3 words), the name of the program for boot
;   L              -> l for each file: name, length, CRC-32 (28 bytes)
;   O name len crc -> k  a file opens for writing: its sectors are erased
;   W offset bytes -> k  up to 1024 bytes at offset (the pieces in their order; the same piece again: k)
;   C              -> k  the file read back from the flash: its CRC-32 is the one of O, then it is in the directory
;   G name offset count -> d the bytes (count up to 1024, offset a multiple of 4)
;   D name         -> k  the file is removed
;   X name         -> k  the program starts (it ends as one of run; then the console takes packets again)
;   B name         -> k  the program for boot (a field of zeros: none)
;   M              -> k  a new, empty file system (all files are lost)
;   Q              -> k  back to the commands for a terminal (also after a second without a packet)
;   R address bytes -> k  the bytes (whole words, up to 1024) into the RAM of the programs
;   E entry        -> k  the program R put into the RAM starts at its entry (as X)
;   Y address count -> d  the bytes of the flash there (count up to 1024, address a multiple of 4)
;   K address count -> k  the CRC-32 of count bytes of the flash at address (a multiple of 4; below 16 MB): Asmonite
;                         compares the console in the flash with its own and writes it again when they differ
;   I              -> k  the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0)
;   S [divider]    -> k  the divider of UART0 on the ESP32: the USB port has no rate, so 4 bytes of the ESP32's value
;                         for 115200 baud, and with a divider just k (nothing changes)
;   H              -> k  the chip: "ESP32-C3" (the USB port of the C3 looks like the one of the S3)
; e and a text: what went wrong (a damaged packet: the PC sends it again). N (the network) and A (the room of the WiFi
; package in the flash) are in console_wifi.asm; T (the debugger through the console) the C3 does not need: the
; debugger reaches it over its USB JTAG.

PKT          equ 0x2F073000             ; a packet that came: +1 the command, +2 the length, +4 the data (1104 bytes)
OUT          equ 0x2F073800             ; a packet that goes: the same (up to 4 + 64 * 28 bytes for L)
PK_DIVIDER   equ 0x007002B6             ; packet S: the divider of 115200 baud on the ESP32

; packets while they come; a0 = 1: the STX of the first one came already
packet_mode:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    la   t0, pk_mode                    ; (net_say says nothing meanwhile: no note between the packets)
    li   t1, 1
    sw   t1, 0(t0)
pm_next:
    mv   a0, s0
    li   s0, 0
    call read_packet
    beqz a0, pm_do
    li   t0, 1
    beq  a0, t0, pm_leave               ; a second without a packet
    la   a0, e_packet
    call send_err
    j    pm_next
pm_do:
    call do_packet
    beqz a0, pm_next
pm_leave:
    la   t0, pk_mode
    sw   zero, 0(t0)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a packet into PKT (a0 = 1: its STX came already): 0 done, 1 nothing came for a second, 2 a damaged packet.
; s0 PKT, s1 a place, s2 the length, s3 the bytes to come
read_packet:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    bnez a0, rk_head
rk_wait:
    li   a0, 1000
    li   a1, 1                          ; (between the packets: the WiFi goes on)
    call wait_byte
    bltz a0, rk_idle
    li   t0, 2
    bne  a0, t0, rk_wait                ; other bytes: left out
rk_head:
    li   s0, PKT
    li   s1, 1
rk_hbyte:
    li   a0, 500
    li   a1, 0
    call wait_byte
    bltz a0, rk_broken
    add  t0, s0, s1
    sb   a0, 0(t0)                      ; the command and the length at PKT+1
    addi s1, s1, 1
    li   t0, 4
    bltu s1, t0, rk_hbyte
    lbu  s2, 2(s0)
    lbu  t0, 3(s0)
    slli t0, t0, 8
    or   s2, s2, t0                     ; the length
    li   t0, 1100
    bltu t0, s2, rk_broken
    addi s3, s2, 4                      ; the data and the CRC
    li   s1, 0
rk_dbyte:
    beq  s1, s3, rk_check
    li   a0, 500
    li   a1, 0
    call wait_byte
    bltz a0, rk_broken
    add  t0, s0, s1
    sb   a0, 4(t0)
    addi s1, s1, 1
    j    rk_dbyte
rk_check:
    li   a0, 0
    addi a1, s0, 1
    addi a2, s2, 3
    call crc32
    add  t0, s0, s2                     ; the CRC behind the data (bytes: it need not be at a whole word)
    lbu  t1, 4(t0)
    lbu  t2, 5(t0)
    slli t2, t2, 8
    or   t1, t1, t2
    lbu  t2, 6(t0)
    slli t2, t2, 16
    or   t1, t1, t2
    lbu  t2, 7(t0)
    slli t2, t2, 24
    or   t1, t1, t2
    bne  t1, a0, rk_broken
    li   a0, 0
    j    rk_end
rk_idle:
    li   a0, 1
    j    rk_end
rk_broken:
    li   a0, 2
rk_end:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; wait_byte(ms, tick): the next byte that comes within so many milliseconds, -1 if none; tick 1: meanwhile net_tick
; when the console watches the network (the tasks of the WiFi run then also by wifi_wait, besides the tick of the
; service; net_say says nothing between the packets). s0 the start, s1 the microseconds, s2 tick
wait_byte:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s2, a1
    li   t0, 1000
    mul  s1, a0, t0
    call flush
    call micros
    mv   s0, a0
wtb_loop:
    li   t0, USB_SERIAL
    lw   t1, 4(t0)
    andi t1, t1, 4
    bnez t1, wtb_got
    beqz s2, wtb_time
    la   t1, net_keep
    lw   t1, 0(t1)
    beqz t1, wtb_time
    call net_tick
    call flush
wtb_time:
    call micros
    sub  t0, a0, s0
    bltu t0, s1, wtb_loop
    li   a0, -1
    j    wtb_end
wtb_got:
    lbu  a0, 0(t0)
wtb_end:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; send_packet(command, bytes, n): the packet with the n bytes. s0 the bytes, s1 n, s2 the CRC
send_packet:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    mv   s0, a1
    mv   s1, a2
    li   t0, OUT
    sb   a0, 1(t0)
    sb   a2, 2(t0)
    srli t1, a2, 8
    sb   t1, 3(t0)
    li   a0, 0
    addi a1, t0, 1
    li   a2, 3
    call crc32
    mv   a1, s0
    mv   a2, s1
    call crc32
    mv   s2, a0                         ; the CRC
    li   a0, 2
    call put_raw
    li   t0, OUT
    lbu  a0, 1(t0)
    call put_raw
    li   t0, OUT
    lbu  a0, 2(t0)
    call put_raw
    li   t0, OUT
    lbu  a0, 3(t0)
    call put_raw
sp_data:
    beqz s1, sp_crc
    lbu  a0, 0(s0)
    call put_raw
    addi s0, s0, 1
    addi s1, s1, -1
    j    sp_data
sp_crc:
    andi a0, s2, 255
    call put_raw
    srli a0, s2, 8
    andi a0, a0, 255
    call put_raw
    srli a0, s2, 16
    andi a0, a0, 255
    call put_raw
    srli a0, s2, 24
    call put_raw
    call flush
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; a0: a byte of a packet (put_char without its rule for the line end: an LF in a packet sends nothing by itself)
put_raw:
    li   t0, USB_SERIAL
    li   t1, USB_SPIN
prw_wait:
    lw   t2, 4(t0)
    andi t2, t2, 2
    bnez t2, prw_room
    addi t1, t1, -1
    bnez t1, prw_wait
    ret                                 ; nobody reads: dropped
prw_room:
    sw   a0, 0(t0)
    la   t2, usb_pending
    li   t1, 1
    sw   t1, 0(t2)
    ret

; k without data
send_ok:
    li   a0, 'k'
    li   a1, 0
    li   a2, 0
    j    send_packet

; e with the text a0 (without its CR LF)
send_err:
    mv   a1, a0
    li   a2, 0
se_len:
    add  t0, a1, a2
    lbu  t0, 0(t0)
    beqz t0, se_cut
    addi a2, a2, 1
    j    se_len
se_cut:
    li   t0, 2
    bltu a2, t0, se_send
    add  t0, a1, a2
    lbu  t0, -1(t0)
    li   t1, 10
    bne  t0, t1, se_send
    addi a2, a2, -2                     ; without CR LF
se_send:
    li   a0, 'e'
    j    send_packet

; the packet in PKT; 1 if it was Q. a0 the length of its data for the handler
do_packet:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, PKT
    lbu  t1, 1(t0)                      ; the command
    lbu  a0, 2(t0)
    lbu  t2, 3(t0)
    slli t2, t2, 8
    or   a0, a0, t2                     ; the length of the data
    la   t2, packets
dp_find:
    lbu  t3, 0(t2)
    beqz t3, dp_unknown
    beq  t3, t1, dp_found
    addi t2, t2, 8
    j    dp_find
dp_found:
    lw   t3, 4(t2)
    jalr ra, 0(t3)
    li   a0, 0
    j    dp_end
dp_unknown:
    li   t2, 'Q'
    bne  t1, t2, dp_bad
    call send_ok
    li   a0, 1
    j    dp_end
dp_bad:
    la   a0, e_unknown
    call send_err
    li   a0, 0
dp_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; P: the version of the console
pk_version:
    li   a0, 'k'
    la   a1, s_version
    li   a2, 18
    j    send_packet

; V: the version of the console (what console_version() gives a program; 4 bytes)
pk_conver:
    li   a0, 'k'
    la   a1, s_conver_v
    li   a2, 4
    j    send_packet

; H: the chip (Asmonite tells the S31 from the C3 and the S3 by it: they have the same USB port 303A:1001)
pk_board:
    li   a0, 'k'
    la   a1, s_board
    li   a2, 9                          ; 'ESP32-S31'
    j    send_packet

; the text of the problem of a packet with a name field of 20 bytes at PKT+4 and the length a0 (it has to be a1): the
; field ends with a 0, the name is valid, there is a file system; 0 if none
pk_name:
    beq  a0, a1, pn_len
    la   a0, e_size
    ret
pn_len:
    la   t0, fs_ok
    lw   t0, 0(t0)
    bnez t0, pn_fs
    la   a0, s_nofs
    ret
pn_fs:
    li   t0, PKT
    sb   zero, 23(t0)                   ; the field ends with a 0
    addi a0, t0, 4
    j    name_problem

; F: the files, the bytes in use, the bytes free, the program for boot
pk_free:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    la   t0, fs_ok
    lw   t0, 0(t0)
    bnez t0, pf_fs
    la   a0, s_nofs
    call send_err
    j    pf_end
pf_fs:
    call count_files
    li   t0, OUT
    sw   a0, 4(t0)
    call count_free
    mv   s0, a0
    la   t0, fs_sectors
    lw   t1, 0(t0)
    sub  t1, t1, s0
    slli t1, t1, 12
    li   t0, OUT
    sw   t1, 8(t0)
    slli t1, s0, 12
    sw   t1, 12(t0)
    addi a0, t0, 16                     ; the name of the program for boot (zeros: none)
    addi a1, t0, 36
    call zero_words
    li   t0, DIRBUF
    lw   t1, 12(t0)
    beqz t1, pf_send
    addi a0, t1, -1
    call entry_at
    mv   a1, a0
    li   a0, OUT + 16
    li   a2, 20
    call copy_bytes
pf_send:
    li   a0, 'f'
    li   a1, OUT + 4
    li   a2, 32
    call send_packet
pf_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; L: name, length, CRC-32 of each file. s0 where the next one goes, s1 the entry
pk_list:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    la   t0, fs_ok
    lw   t0, 0(t0)
    bnez t0, pl_fs
    la   a0, s_nofs
    call send_err
    j    pl_end
pl_fs:
    li   s0, OUT + 4
    li   s1, 0
pl_next:
    mv   a0, s1
    call entry_at
    lbu  t0, 0(a0)
    beqz t0, pl_skip
    mv   a1, a0
    sw   a0, 0(sp)
    mv   a0, s0
    li   a2, 20
    call copy_bytes
    lw   t0, 0(sp)
    lw   t1, 24(t0)
    sw   t1, 20(s0)
    lw   t1, 28(t0)
    sw   t1, 24(s0)
    addi s0, s0, 28
pl_skip:
    addi s1, s1, 1
    li   t0, 64
    bltu s1, t0, pl_next
    li   a0, 'l'
    li   a1, OUT + 4
    sub  a2, s0, a1
    call send_packet
pl_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; O name length crc: a file opens for writing, its sectors erased. s0 its entry, s1 the length, s2 the sectors, s3
; the first sector
pk_open:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    li   a1, 28
    call pk_name
    beqz a0, po_name
    call send_err
    j    po_end
po_name:
    li   a0, PKT + 4
    call find_entry
    mv   s0, a0                         ; its entry, or a free one
    bgez s0, po_entry
    li   s0, 0
po_free:
    mv   a0, s0
    call entry_at
    lbu  t0, 0(a0)
    beqz t0, po_entry
    addi s0, s0, 1
    li   t0, 64
    bltu s0, t0, po_free
    la   a0, s_dirfull
    call send_err
    j    po_end
po_entry:
    li   t0, PKT
    lw   s1, 24(t0)                     ; the length
    call build_used
    li   t0, 4095
    add  s2, s1, t0
    srli s2, s2, 12                     ; the sectors
    la   t0, fs_sectors
    lw   t0, 0(t0)
    bgeu t0, s2, po_size
po_full:
    la   a0, s_full
    call send_err
    j    po_end
po_size:
    mv   a0, s2
    call find_space
    mv   s3, a0                         ; the first sector
    bltz s3, po_full
    li   t0, 0
po_erase:
    beq  t0, s2, po_state
    sw   t0, 0(sp)
    add  a0, s3, t0
    call fl_erase
    bnez a0, po_err
    lw   t0, 0(sp)
    addi t0, t0, 1
    j    po_erase
po_state:
    la   t0, wf_open
    li   t1, 1
    sw   t1, 0(t0)                      ; open
    sw   s3, 4(t0)                      ; the first sector
    sw   s1, 8(t0)                      ; the length
    li   t1, PKT
    lw   t2, 28(t1)
    sw   t2, 12(t0)                     ; the CRC-32
    sw   zero, 16(t0)                   ; written so far
    sw   s0, 20(t0)                     ; the entry
    li   t2, -1
    sw   t2, 24(t0)                     ; the offset of the last piece
    la   a0, wf_name
    li   a1, PKT + 4
    li   a2, 20
    call copy_bytes
    call send_ok
    j    po_end
po_err:
    la   a0, s_flasherr
    call send_err
po_end:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; W offset bytes: a piece of the open file. s0 the bytes, s1 the offset, s2 behind the piece
pk_write:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    la   t0, wf_open
    lw   t1, 0(t0)
    bnez t1, pw_open
    la   a0, e_notopen
    call send_err
    j    pw_end
pw_open:
    addi s0, a0, -4                     ; the bytes
    blez s0, pw_size
    li   t1, 1024
    bgeu t1, s0, pw_sized
pw_size:
    la   a0, e_size
    call send_err
    j    pw_end
pw_sized:
    li   t1, PKT
    lw   s1, 4(t1)                      ; the offset
    add  s2, s1, s0                     ; behind the piece
    lw   t2, 24(t0)
    bne  s1, t2, pw_new
    lw   t2, 16(t0)
    bne  s2, t2, pw_new
    call send_ok                        ; the last piece again (its k was lost)
    j    pw_end
pw_new:
    lw   t2, 16(t0)                     ; it goes on where the last one ended
    bne  s1, t2, pw_place
    lw   t2, 8(t0)
    bltu t2, s2, pw_place               ; beyond the length
    andi t3, s0, 3
    beqz t3, pw_pad
    beq  s2, t2, pw_pad                 ; only the last piece may end within a word
pw_place:
    la   a0, e_place
    call send_err
    j    pw_end
pw_pad:
    li   t1, PKT + 8                    ; the bytes; 0xFF (erased) up to a whole word
    add  t2, t1, s0
    li   t3, 255
    sb   t3, 0(t2)
    sb   t3, 1(t2)
    sb   t3, 2(t2)
    lw   a0, 4(t0)
    slli a0, a0, 12
    add  a0, a0, s1
    li   a1, PKT + 8
    addi a2, s0, 3
    andi a2, a2, -4
    call fl_write
    bnez a0, pw_err
    la   t0, wf_open
    sw   s1, 24(t0)
    sw   s2, 16(t0)
    call send_ok
    j    pw_end
pw_err:
    la   a0, s_flasherr
    call send_err
pw_end:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; C: the open file read back, its CRC-32 checked, into the directory. s0 the CRC in the flash, s1 the entry
pk_close:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    la   t0, wf_open
    lw   t1, 0(t0)
    bnez t1, pc_open
    la   a0, e_notopen
    call send_err
    j    pc_end
pc_open:
    sw   zero, 0(t0)                    ; closed (also when it fails)
    lw   t1, 16(t0)
    lw   t2, 8(t0)
    beq  t1, t2, pc_whole
    la   a0, e_place
    call send_err
    j    pc_end
pc_whole:
    lw   a0, 4(t0)
    mv   a1, t2
    call file_crc
    mv   s0, a0                         ; the CRC of what is in the flash
    la   t0, wf_open
    lw   t1, 12(t0)
    beq  s0, t1, pc_dir
    la   a0, e_fcrc
    call send_err
    j    pc_end
pc_dir:
    lw   a0, 20(t0)
    bltz a0, pc_ok                      ; the room of the WiFi package (A, stage K5): no entry
    call entry_at
    mv   s1, a0
    la   a1, wf_name
    li   a2, 20
    call copy_bytes
    la   t0, wf_open
    lw   t1, 4(t0)
    sw   t1, 20(s1)
    lw   t1, 8(t0)
    sw   t1, 24(s1)
    sw   s0, 28(s1)
    call dir_save
    bnez a0, pc_ok
    la   a0, s_flasherr
    call send_err
    j    pc_end
pc_ok:
    call send_ok
pc_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; G name offset count: bytes of a file. s0 the entry, s1 the offset, s2 the count
pk_get:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    li   a1, 28
    call pk_name
    beqz a0, pg_name
    call send_err
    j    pg_end
pg_name:
    li   a0, PKT + 4
    call find_entry
    bgez a0, pg_found
    la   a0, e_nofile
    call send_err
    j    pg_end
pg_found:
    call entry_at
    mv   s0, a0
    li   t0, PKT
    lw   s1, 24(t0)                     ; the offset
    lw   s2, 28(t0)                     ; the count
    andi t1, s1, 3
    bnez t1, pg_bad
    li   t1, 1024
    bltu t1, s2, pg_bad
    lw   t1, 24(s0)                     ; the length of the file
    bltu t1, s1, pg_bad
    sub  t1, t1, s1                     ; the bytes from the offset on
    bgeu t1, s2, pg_read
    mv   s2, t1
pg_read:
    addi a2, s2, 3
    andi a2, a2, -4
    beqz a2, pg_send
    lw   a0, 20(s0)
    slli a0, a0, 12
    add  a0, a0, s1
    li   a1, OUT + 4
    call fl_read
    bnez a0, pg_err
pg_send:
    li   a0, 'd'
    li   a1, OUT + 4
    mv   a2, s2
    call send_packet
    j    pg_end
pg_bad:
    la   a0, e_place
    call send_err
    j    pg_end
pg_err:
    la   a0, s_flasherr
    call send_err
pg_end:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; D name: the file away
pk_delete:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a1, 20
    call pk_name
    beqz a0, pd_name
    call send_err
    j    pd_end
pd_name:
    li   a0, PKT + 4
    call find_entry
    bgez a0, pd_found
    la   a0, e_nofile
    call send_err
    j    pd_end
pd_found:
    call clear_entry
    call dir_save
    bnez a0, pd_ok
    la   a0, s_flasherr
    call send_err
    j    pd_end
pd_ok:
    call send_ok
pd_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; X name: the program starts (k first)
pk_run:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a1, 20
    call pk_name
    beqz a0, px_name
    call send_err
    j    px_end
px_name:
    li   a0, PKT + 4
    li   a1, 1
    li   a2, 0
    call run_file
    beqz a0, px_end                     ; it ran and ended
    call send_err                       ; it did not start
px_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; B name: the program for boot (a field of zeros: none)
pk_boot:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, 20
    beq  a0, t0, pb_len
    la   a0, e_size
    call send_err
    j    pb_end
pb_len:
    li   t0, PKT
    lbu  t1, 4(t0)
    bnez t1, pb_name
    la   t0, fs_ok
    lw   t0, 0(t0)
    bnez t0, pb_none
    la   a0, s_nofs
    call send_err
    j    pb_end
pb_none:
    li   t0, DIRBUF
    sw   zero, 12(t0)
    j    pb_save
pb_name:
    li   a1, 20
    call pk_name
    beqz a0, pb_find
    call send_err
    j    pb_end
pb_find:
    li   a0, PKT + 4
    call find_entry
    bgez a0, pb_found
    la   a0, e_nofile
    call send_err
    j    pb_end
pb_found:
    addi a0, a0, 1
    li   t0, DIRBUF
    sw   a0, 12(t0)
pb_save:
    call dir_save
    bnez a0, pb_ok
    la   a0, s_flasherr
    call send_err
    j    pb_end
pb_ok:
    call send_ok
pb_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; M: a new, empty file system
pk_format:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call make_fs
    bnez a0, pm_ok
    la   a0, s_flasherr
    call send_err
    j    pm_end
pm_ok:
    call send_ok
pm_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; R address bytes: the bytes (whole words, up to 1024) into the room of the programs at the address, or into the room
; above it up to the console (the parts of the WiFi; load only); s0 the bytes, s1 the address
pk_ram:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    addi s0, a0, -4                     ; the bytes
    li   t0, 4
    blt  s0, t0, pr_size
    andi t0, s0, 3
    bnez t0, pr_size
    li   t0, 1024
    bgeu t0, s0, pr_sized
pr_size:
    la   a0, e_size
    call send_err
    j    pr_end
pr_sized:
    li   t0, PKT
    lw   s1, 4(t0)                      ; the address
    andi t0, s1, 3
    bnez t0, pr_where
    mv   a0, s1
    mv   a1, s0
    li   a2, 1                          ; (a segment for the flash: 2, refused below)
    call segment_fits
    li   t0, 1
    bne  a0, t0, pr_where
    mv   a0, s1                         ; a word at a time
    li   a1, PKT + 8
    mv   a2, s0
    call copy_words
    call send_ok
    j    pr_end
pr_where:
    la   a0, e_where
    call send_err
pr_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; E entry: k, then the program that R put into the RAM starts at its entry (no arguments; it ends as one of X)
pk_exec:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, 4
    beq  a0, t0, pe_len
    la   a0, e_size
    call send_err
    j    pe_end
pe_len:
    li   t0, PKT
    lw   a0, 4(t0)                      ; the entry
    sw   a0, 8(sp)
    li   a1, 4
    li   a2, 0
    call segment_fits
    li   t0, 1
    beq  a0, t0, pe_fits
    la   a0, e_where
    call send_err
    j    pe_end
pe_fits:
    lw   t0, 8(sp)
    la   t1, prog_entry
    sw   t0, 0(t1)
    call send_ok
    la   a0, s_empty                    ; no arguments, started by a packet
    li   a1, 1
    call run_entry
pe_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; Y address count: the bytes of the flash (count up to 1024, address a multiple of 4). s0 the count
pk_flash:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    li   t0, 8
    beq  a0, t0, py_len
    la   a0, e_size
    call send_err
    j    py_end
py_len:
    li   t0, PKT
    lw   a0, 4(t0)
    lw   s0, 8(t0)
    andi t1, a0, 3
    bnez t1, py_where
    li   t1, 1024
    bltu t1, s0, py_where
    la   t1, flash_size
    lw   t1, 0(t1)
    add  t2, a0, s0
    bltu t1, t2, py_where
    li   a1, OUT + 4
    addi a2, s0, 3
    andi a2, a2, -4
    beqz a2, py_send
    call fl_read
    bnez a0, py_err
py_send:
    li   a0, 'd'
    li   a1, OUT + 4
    mv   a2, s0
    call send_packet
    j    py_end
py_where:
    la   a0, e_place
    call send_err
    j    py_end
py_err:
    la   a0, s_flasherr
    call send_err
py_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; K address count: the CRC-32 of the bytes of the flash there (address a multiple of 4, within the flash)
pk_crc:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, 8
    beq  a0, t0, kc_len
    la   a0, e_size
    call send_err
    j    kc_end
kc_len:
    li   t0, PKT
    lw   a0, 4(t0)
    lw   a1, 8(t0)
    andi t1, a0, 3
    bnez t1, kc_where
    la   t1, flash_size
    lw   t1, 0(t1)
    add  t2, a0, a1
    bltu t1, t2, kc_where
    bltu t2, a0, kc_where
    call flash_crc
kc_send:
    li   t0, OUT + 4
    sw   a0, 0(t0)
    li   a0, 'k'
    li   a1, OUT + 4
    li   a2, 4
    call send_packet
    j    kc_end
kc_where:
    la   a0, e_place
    call send_err
kc_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; I: the JEDEC id of the flash
pk_ident:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call flash_ident
    li   t0, OUT + 4
    sw   a0, 0(t0)
    li   a0, 'k'
    li   a1, OUT + 4
    li   a2, 4
    call send_packet
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; S [divider]: the USB port has no rate; without data the value of the ESP32 for 115200 baud, with one just k
pk_speed:
    beqz a0, ps_now
    li   t0, 4
    beq  a0, t0, send_ok
    la   a0, e_packet
    j    send_err
ps_now:
    li   t0, OUT + 4
    li   t1, PK_DIVIDER
    sw   t1, 0(t0)
    li   a0, 'k'
    li   a1, OUT + 4
    li   a2, 4
    j    send_packet
