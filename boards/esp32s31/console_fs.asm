; The console of the ESP32-S31: the file system and the flash (that of the ESP32-C3, boards\esp32c3\console_fs.asm,
; with the addresses of the S31), for the line .include "console_fs.asm" of console.asm. The same format as on the ESP32 and the ESP32-S3 (their console.asm), so Asmonite reads it the same way:
; the file system takes the flash from 2 MB on to its end (flash_init reads its size from its JEDEC id; 4 to 16 MB,
; else 4 MB), sectors of 4 KB:
;   - sectors 0x200 and 0x201: the directory, twice. It is written into the other sector each time, with a number
;     one higher; at the start the console takes the valid one with the higher number. So a reset or a power cut
;     while it is written leaves the directory as it was before.
;     A directory: "AFS1", the number, the CRC-32 of the 64 entries and then of the word behind it, the program for
;     boot (its entry + 1, 0 none), then 64 entries of 32 bytes: the name (up to 19 characters and a 0), the first
;     sector, the length, the CRC-32 of the file.
;   - sectors 0x202 .. the last one: the files, each in sectors one after the other (the first gap big enough). A
;     new text for a file goes into a new place first; only then the directory points to it.
; The flash is erased, written and read by the functions of the boot ROM (ESP-IDF esp32s31.rom.ld):
; esp_rom_spiflash_erase_sector 0x2F800160, esp_rom_spiflash_write 0x2F800168, esp_rom_spiflash_read 0x2F80016C,
; spi_flash_attach 0x2F800200. They check the size of the flash in the data of the ROM (rom_spiflash_legacy_data at
; 0x2F07FFE0 points to it, the word at +4): the console sets it to the size of the flash (at least 4 MB).

ROM_FL_ERASE  equ 0x2F800160            ; esp_rom_spiflash_erase_sector(sector)
ROM_FL_WRITE  equ 0x2F800168            ; esp_rom_spiflash_write(address, buffer, length)
ROM_FL_READ   equ 0x2F80016C            ; esp_rom_spiflash_read(address, buffer, length)
ROM_FL_ATTACH equ 0x2F800200            ; spi_flash_attach(spiconfig, legacy) (esp_rom_spiflash_attach of ESP-IDF)
ROM_FL_DATA   equ 0x2F07FFE0            ; rom_spiflash_legacy_data: the address of the data of the flash (+4 its size)
SPI1          equ 0x20501000            ; the SPI of the flash (esptool SPI_REG_BASE of the S31; the offsets of the C3):
                                        ; CMD +0, CTRL +8, USER +0x18, USER2 +0x20,
                                        ; MISO_DLEN +0x28, W0 +0x58
FS_START      equ 0x200000              ; the first directory
FS_MAGIC      equ 0x31534641            ; "AFS1"
CRC_POLY      equ 0xEDB88320
FILE_MAX      equ 0x10000               ; the longest file: 64 KB

; ---------- the commands ----------

; ls: the files with their lengths, how many and their bytes. s0 the entry, s1 the files, s2 their bytes
cmd_ls:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    call need_fs
    beqz a0, ls_done
    li   s0, 0
    li   s1, 0
    li   s2, 0
ls_next:
    mv   a0, s0
    call entry_at
    lbu  t0, 0(a0)
    beqz t0, ls_skip
    addi s1, s1, 1
    lw   t0, 24(a0)
    add  s2, s2, t0
    li   a0, ' '
    call put_char
    li   a0, ' '
    call put_char
    mv   a0, s0
    call entry_at
    li   a1, 20
    call print_pad
    mv   a0, s0
    call entry_at
    lw   a0, 24(a0)
    li   a1, 8
    call print_dec_right
    la   a0, s_crlf
    call print
ls_skip:
    addi s0, s0, 1
    li   t0, 64
    bltu s0, t0, ls_next
    bnez s1, ls_sum
    la   a0, s_nofiles
    call print
    j    ls_done
ls_sum:
    mv   a0, s1
    call print_dec
    la   a0, s_files
    call print
    mv   a0, s2
    call print_dec
    la   a0, s_bytes
    call print
ls_done:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; cat name: the text of the file; CR LF for every LF. s0 the name, s1 the entry, s2 the length
cmd_cat:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s0, a0
    call need_fs
    beqz a0, cat_done
    mv   a0, s0
    call check_name
    beqz a0, cat_done
    mv   a0, s0
    call find_entry
    bgez a0, cat_found
    mv   a0, s0
    call say_nofile
    j    cat_done
cat_found:
    call entry_at
    mv   s1, a0
    lw   s2, 24(s1)                     ; the length
    li   t0, FILE_MAX
    bgeu t0, s2, cat_read
    la   a0, s_damaged                  ; longer than a file can be
    call print
    j    cat_done
cat_read:
    lw   a0, 20(s1)
    slli a0, a0, 12                     ; the sector: its address
    li   a1, FILEBUF
    addi a2, s2, 3
    andi a2, a2, -4                     ; whole words
    call fl_read
    li   a0, 0
    li   a1, FILEBUF
    mv   a2, s2
    call crc32
    lw   t0, 28(s1)
    beq  a0, t0, cat_ok
    la   a0, s_damaged
    call print
cat_ok:
    li   a0, FILEBUF
    mv   a1, s2
    call print_text
cat_done:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the a1 bytes of text at a0: CR LF for every LF, a line end at the end if the last line had none. s0 the place,
; s1 the end, s2 the byte before
print_text:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s0, a0
    add  s1, a0, a1
    li   s2, 0
pt_next:
    beq  s0, s1, pt_end
    lbu  t0, 0(s0)
    li   t1, 10
    bne  t0, t1, pt_put
    li   t1, 13
    beq  s2, t1, pt_put
    li   a0, 13                         ; CR before an LF
    call put_char
pt_put:
    lbu  a0, 0(s0)
    mv   s2, a0
    call put_char
    addi s0, s0, 1
    j    pt_next
pt_end:
    li   t0, 10
    beq  s2, t0, pt_done
    beqz s2, pt_done                    ; (empty: nothing)
    la   a0, s_crlf                     ; the last line had no end
    call print
pt_done:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; help: the file help.txt (Prepare Board and the update of the console write it), else the short list s_help
cmd_help:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   t0, fs_ok                      ; a file system?
    lw   t0, 0(t0)
    beqz t0, hs_short
    la   a0, c_helptxt
    call find_entry
    bltz a0, hs_short
    la   a0, c_helptxt
    call cmd_cat
    j    hs_end
hs_short:
    la   a0, s_help
    call print
hs_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; rm name. s0 the name
cmd_rm:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    call need_fs
    beqz a0, rm_done
    mv   a0, s0
    call check_name
    beqz a0, rm_done
    mv   a0, s0
    call find_entry
    bgez a0, rm_found
    mv   a0, s0
    call say_nofile
    j    rm_done
rm_found:
    call clear_entry
    call dir_save
    bnez a0, rm_ok
    la   a0, s_flasherr
    call print
    j    rm_done
rm_ok:
    la   a0, s_removed
    call print
    mv   a0, s0
    call print
    la   a0, s_crlf
    call print
rm_done:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; "There is no file <name>" and a line end
say_nofile:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    la   a0, s_nofile
    call print
    lw   a0, 8(sp)
    call print
    la   a0, s_crlf
    call print
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; df: the files, the bytes in their sectors, the bytes free. s0 the free sectors
cmd_df:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    call need_fs
    beqz a0, df_done
    call count_free
    mv   s0, a0
    call count_files
    call print_dec
    la   a0, s_files
    call print
    la   t0, fs_sectors                 ; the sectors of the files (flash_init)
    lw   a0, 0(t0)
    sub  a0, a0, s0
    slli a0, a0, 12
    call print_dec
    la   a0, s_inuse
    call print
    slli a0, s0, 12
    call print_dec
    la   a0, s_free
    call print
df_done:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; format: an empty directory (after "yes")
cmd_format:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   a0, s_sure
    call print
    la   a0, line
    li   a1, LINE_MAX
    call read_line
    la   a0, line
    la   a1, s_yes
    call str_eq
    bnez a0, fm_go
    la   a0, s_notformatted
    call print
    j    fm_end
fm_go:
    call make_fs
    beqz a0, fm_err
    la   a0, s_formatted
    call print
    j    fm_end
fm_err:
    la   a0, s_flasherr
    call print
fm_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; an empty directory into the first sector, the second one erased; 1 if done
make_fs:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a0, DIRBUF
    li   a1, DIRBUF + 4096
    call zero_words
    li   a0, 0x201
    call fl_erase                       ; the second directory away first (its number may be higher)
    bnez a0, mf_err
    la   t0, fs_dir
    li   t1, 1
    sw   t1, 0(t0)                      ; dir_save writes the other one: the first
    call dir_save
    j    mf_end
mf_err:
    li   a0, 0
mf_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the file system ----------

; entry a0 cleared; if it was the program for boot: none
clear_entry:
    li   t0, DIRBUF
    lw   t1, 12(t0)
    addi t2, a0, 1
    bne  t1, t2, ce_clear
    sw   zero, 12(t0)
ce_clear:
    slli t1, a0, 5
    add  t1, t1, t0
    addi t1, t1, 32
    li   t2, 8
ce_word:
    sw   zero, 0(t1)
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, ce_word
    ret

; the sectors that no file takes
count_free:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call build_used
    li   a0, 0
    li   t0, 0
    li   t1, USED
    la   t3, fs_sectors
    lw   t3, 0(t3)
cf_next:
    bgeu t0, t3, cf_done
    add  t2, t1, t0
    lbu  t2, 0(t2)
    bnez t2, cf_used
    addi a0, a0, 1
cf_used:
    addi t0, t0, 1
    j    cf_next
cf_done:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the files in the directory
count_files:
    li   a0, 0
    li   t0, DIRBUF + 32
    li   t1, 64
cfi_next:
    lbu  t2, 0(t0)
    beqz t2, cfi_none
    addi a0, a0, 1
cfi_none:
    addi t0, t0, 32
    addi t1, t1, -1
    bnez t1, cfi_next
    ret

; 1 if there is a file system, else a message and 0
need_fs:
    la   t0, fs_ok
    lw   a0, 0(t0)
    bnez a0, nf_done
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   a0, s_nofs
    call print
    lw   ra, 12(sp)
    addi sp, sp, 16
    li   a0, 0
nf_done:
    ret

; 1 if the name a0 can be a file name, else a message and 0
check_name:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call name_problem
    beqz a0, cn_ok
    call print
    li   a0, 0
    j    cn_end
cn_ok:
    li   a0, 1
cn_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; 0 if the name a0 can be a file name (1 to 19 characters, no spaces or control characters; it ends at its 0 or at a
; space: what follows a space is told as a space in the name), else the text that says why not
name_problem:
    lbu  t0, 0(a0)
    bnez t0, np_some
    la   a0, s_noname
    ret
np_some:
    li   t1, 0                          ; the length
np_next:
    add  t2, a0, t1
    lbu  t2, 0(t2)
    beqz t2, np_end
    li   t3, 33
    bltu t2, t3, np_space
    li   t3, 127
    beq  t2, t3, np_space
    addi t1, t1, 1
    j    np_next
np_space:
    la   a0, s_space
    ret
np_end:
    li   t3, 20
    bltu t1, t3, np_ok
    la   a0, s_long
    ret
np_ok:
    li   a0, 0
    ret

; the address of entry a0 of the directory
entry_at:
    slli a0, a0, 5
    li   t0, DIRBUF + 32
    add  a0, a0, t0
    ret

; the entry of the file a0, -1 if there is none. s0 the name, s1 the entry
find_entry:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    li   s1, 0
fe_next:
    mv   a0, s1
    call entry_at
    lbu  t0, 0(a0)
    beqz t0, fe_skip
    mv   a1, s0
    call str_eq
    bnez a0, fe_found
fe_skip:
    addi s1, s1, 1
    li   t0, 64
    bltu s1, t0, fe_next
    li   a0, -1
    j    fe_end
fe_found:
    mv   a0, s1
fe_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; USED: 1 for every sector that a file takes. It calls nothing.
build_used:
    li   t0, USED                       ; all of USED (4 KB: up to 16 MB of flash)
    li   t1, USED + 4096
bu_clear:
    sw   zero, 0(t0)
    addi t0, t0, 4
    bltu t0, t1, bu_clear
    li   t0, DIRBUF + 32                ; the entry
    li   t6, 64
    la   t5, fs_sectors
    lw   t5, 0(t5)
bu_next:
    lbu  t1, 0(t0)
    beqz t1, bu_skip
    lw   t1, 20(t0)                     ; the first sector
    lw   t2, 24(t0)                     ; the length
    li   t3, 4095
    add  t2, t2, t3
    srli t2, t2, 12                     ; the sectors
    addi t1, t1, -0x202                 ; from the first sector of the files
    bltz t1, bu_skip                    ; (a damaged entry: left out)
    add  t3, t1, t2
    bltu t5, t3, bu_skip
    li   t3, USED
    add  t1, t1, t3
    li   t4, 1
bu_mark:
    beqz t2, bu_skip
    sb   t4, 0(t1)
    addi t1, t1, 1
    addi t2, t2, -1
    j    bu_mark
bu_skip:
    addi t0, t0, 32
    addi t6, t6, -1
    bnez t6, bu_next
    ret

; the first sector of a0 free sectors one after the other (after build_used), -1 if there is no such gap. It calls
; nothing.
find_space:
    bnez a0, fsp_go
    li   a0, 0x202                      ; an empty file takes no sector
    ret
fsp_go:
    li   t0, 0                          ; the sector
    li   t1, USED
    la   t2, fs_sectors
    lw   t2, 0(t2)
fsp_next:
    bgeu t0, t2, fsp_none
    add  t3, t1, t0
    lbu  t3, 0(t3)
    addi t0, t0, 1
    bnez t3, fsp_next
    addi t4, t0, -1                     ; a free sector: where the row starts
fsp_row:
    sub  t3, t0, t4
    beq  t3, a0, fsp_found
    bgeu t0, t2, fsp_none
    add  t3, t1, t0
    lbu  t3, 0(t3)
    addi t0, t0, 1
    beqz t3, fsp_row
    j    fsp_next
fsp_found:
    addi a0, t4, 0x202
    ret
fsp_none:
    li   a0, -1
    ret

; store_file(name, bytes, n): the file into the flash: into a new place first (piece by piece through CHUNK, each read
; back), only then the directory points to it; 0 done, -1 the directory is full, -2 not enough room in the flash, -3
; the flash cannot be written. The bytes may lie anywhere (they are only read). s0 the name, s1 the bytes, s2 their
; number, s3 the entry, s4 the first sector, s5 the sectors / the bytes left, s6 where they go, s7 a piece
store_file:
    addi sp, sp, -48
    sw   ra, 44(sp)
    sw   s0, 40(sp)
    sw   s1, 36(sp)
    sw   s2, 32(sp)
    sw   s3, 28(sp)
    sw   s4, 24(sp)
    sw   s5, 20(sp)
    sw   s6, 16(sp)
    sw   s7, 12(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
    sw   a1, 0(sp)                      ; the bytes from the start (for the CRC)
    call find_entry
    mv   s3, a0                         ; its entry, or a free one
    bgez s3, st_entry
    li   s3, 0
st_free:
    mv   a0, s3
    call entry_at
    lbu  t0, 0(a0)
    beqz t0, st_entry
    addi s3, s3, 1
    li   t0, 64
    bltu s3, t0, st_free
    li   a0, -1
    j    st_end
st_entry:
    call build_used                     ; the old text of the file stays where it is until the directory is written
    li   t0, 4095
    add  s5, s2, t0
    srli s5, s5, 12                     ; the sectors
    mv   a0, s5
    call find_space
    mv   s4, a0                         ; the first sector
    bgez s4, st_room
    li   a0, -2
    j    st_end
st_room:
    li   s7, 0
st_erase:
    beq  s7, s5, st_write
    add  a0, s4, s7
    call fl_erase
    bnez a0, st_err
    addi s7, s7, 1
    j    st_erase
st_write:
    mv   s5, s2                         ; the bytes still to write
    slli s6, s4, 12                     ; where they go
st_piece:
    beqz s5, st_dir
    li   s7, 256                        ; a piece of at most 256 bytes into CHUNK, zeros up to a whole word
    bgeu s5, s7, st_copy
    mv   s7, s5
st_copy:
    li   t0, CHUNK
    andi t1, s7, -4
    add  t1, t1, t0
    sw   zero, 0(t1)
    li   a0, CHUNK
    mv   a1, s1
    mv   a2, s7
    call copy_bytes
    mv   a0, s6
    li   a1, CHUNK
    addi a2, s7, 3
    andi a2, a2, -4
    call fl_write
    bnez a0, st_err
    mv   a0, s6
    li   a1, CHUNK
    addi a2, s7, 3
    andi a2, a2, -4
    call fl_verify
    beqz a0, st_err
    add  s1, s1, s7
    add  s6, s6, s7
    sub  s5, s5, s7
    j    st_piece
st_dir:
    mv   a0, s3
    call entry_at
    mv   s6, a0
    sw   s4, 20(s6)                     ; the first sector
    sw   s2, 24(s6)                     ; the length
    li   a0, 0
    lw   a1, 0(sp)
    mv   a2, s2
    call crc32
    sw   a0, 28(s6)
    li   t0, 0                          ; the name, with zeros up to 20 bytes
    li   t1, 0                          ; 1: its end is passed
st_name:
    add  t2, s0, t0
    lbu  t2, 0(t2)
    bnez t2, st_char
    li   t1, 1
st_char:
    beqz t1, st_store
    li   t2, 0
st_store:
    add  t3, s6, t0
    sb   t2, 0(t3)
    addi t0, t0, 1
    li   t3, 20
    bltu t0, t3, st_name
    call dir_save
    beqz a0, st_err
    li   a0, 0
    j    st_end
st_err:
    li   a0, -3
st_end:
    lw   s7, 12(sp)
    lw   s6, 16(sp)
    lw   s5, 20(sp)
    lw   s4, 24(sp)
    lw   s3, 28(sp)
    lw   s2, 32(sp)
    lw   s1, 36(sp)
    lw   s0, 40(sp)
    lw   ra, 44(sp)
    addi sp, sp, 48
    ret

; reads both directories and keeps the valid one with the higher number in DIRBUF; 1 if there is one. s0 the second
; is valid, s1 its number
dir_load:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    li   a0, 1
    call dir_read
    mv   s0, a0
    li   s1, 0
    beqz s0, dl_first
    li   t0, DIRBUF
    lw   s1, 4(t0)                      ; its number
dl_first:
    li   a0, 0
    call dir_read
    beqz a0, dl_second
    li   t0, DIRBUF
    lw   t1, 4(t0)
    beqz s0, dl_use_first
    bgeu t1, s1, dl_use_first
    li   a0, 1
    call dir_read                       ; the second one is newer: read it again
    li   t1, 1
    j    dl_set
dl_use_first:
    li   t1, 0
    j    dl_set
dl_second:
    beqz s0, dl_none
    li   a0, 1
    call dir_read
    li   t1, 1
dl_set:
    la   t0, fs_dir
    sw   t1, 0(t0)                      ; the directory in use
    la   t0, fs_ok
    li   t1, 1
    sw   t1, 0(t0)                      ; a file system
    li   a0, 1
    j    dl_end
dl_none:
    la   t0, fs_ok
    sw   zero, 0(t0)
    li   a0, 0
dl_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; directory a0 (0 or 1) into DIRBUF; 1 if it is valid
dir_read:
    addi sp, sp, -16
    sw   ra, 12(sp)
    slli a0, a0, 12
    li   t0, FS_START
    add  a0, a0, t0
    li   a1, DIRBUF
    li   a2, 4096
    call fl_read
    bnez a0, dr_bad
    li   t0, DIRBUF
    lw   t1, 0(t0)
    li   t2, FS_MAGIC
    bne  t1, t2, dr_bad
    call dir_crc
    li   t0, DIRBUF
    lw   t1, 8(t0)
    bne  a0, t1, dr_bad
    li   a0, 1
    j    dr_end
dr_bad:
    li   a0, 0
dr_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the CRC-32 of the directory in DIRBUF: of its 64 entries, then of the word for boot (+12)
dir_crc:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a0, 0
    li   a1, DIRBUF + 32
    li   a2, 2048
    call crc32
    li   a1, DIRBUF + 12
    li   a2, 4
    call crc32
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; DIRBUF with the next number into the other directory; 1 if done. s0 the other one, s1 its address
dir_save:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    li   t0, DIRBUF
    li   t1, FS_MAGIC
    sw   t1, 0(t0)
    lw   t1, 4(t0)
    addi t1, t1, 1
    sw   t1, 4(t0)
    call dir_crc
    li   t0, DIRBUF
    sw   a0, 8(t0)
    la   t0, fs_dir
    lw   s0, 0(t0)
    xori s0, s0, 1                      ; the other one
    addi a0, s0, 0x200
    call fl_erase
    bnez a0, ds_err
    slli s1, s0, 12
    li   t0, FS_START
    add  s1, s1, t0                     ; its address
    mv   a0, s1
    li   a1, DIRBUF
    li   a2, 4096
    call fl_write
    bnez a0, ds_err
    mv   a0, s1
    li   a1, DIRBUF
    li   a2, 4096
    call fl_verify
    beqz a0, ds_err
    la   t0, fs_dir
    sw   s0, 0(t0)                      ; now the one in use
    la   t0, fs_ok
    li   t1, 1
    sw   t1, 0(t0)
    li   a0, 1
    j    ds_end
ds_err:
    li   a0, 0
ds_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; crc32(crc, bytes, n): the CRC-32 (as zlib) of the n bytes, going on from the CRC of the bytes before them (0 at the
; start). It calls nothing.
crc32:
    not  a0, a0
    li   t0, CRC_POLY
    beqz a2, crc_done
crc_byte:
    lbu  t1, 0(a1)
    xor  a0, a0, t1
    li   t2, 8
crc_bit:
    andi t1, a0, 1
    srli a0, a0, 1
    beqz t1, crc_next
    xor  a0, a0, t0
crc_next:
    addi t2, t2, -1
    bnez t2, crc_bit
    addi a1, a1, 1
    addi a2, a2, -1
    bnez a2, crc_byte
crc_done:
    not  a0, a0
    ret

; ---------- the flash (the functions of the ROM; 0 = done) ----------

; the flash attached to the SPI pins of the eFuses (as at the start from the flash); its size from its JEDEC id (4 to
; 16 MB, else 4 MB): the ROM knows it (rom_spiflash_legacy_data, at least that size), and the file system reaches to
; its end (fs_sectors: the sectors of the files); flash_id keeps the id
flash_init:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, ROM_FL_DATA                ; the ROM's size of the flash at least 4 MB first
    lw   t0, 0(t0)
    lw   t1, 4(t0)
    li   t2, 0x400000
    bgeu t1, t2, fi_attach
    sw   t2, 4(t0)
fi_attach:
    li   a0, 0
    li   a1, 0
    li   t0, ROM_FL_ATTACH
    jalr ra, 0(t0)
    call flash_ident
    la   t0, flash_id
    sw   a0, 0(t0)
    srli t1, a0, 16                     ; the size as a power of two (0x16: 4 MB, 0x17: 8 MB, 0x18: 16 MB)
    andi t1, t1, 255
    li   t2, 0x400000
    li   t3, 0x16
    bltu t1, t3, fi_size
    li   t3, 0x18
    bltu t3, t1, fi_size
    li   t2, 1
    sll  t2, t2, t1
fi_size:
    la   t0, flash_size
    sw   t2, 0(t0)
    li   t0, ROM_FL_DATA
    lw   t0, 0(t0)
    lw   t1, 4(t0)
    bgeu t1, t2, fi_count
    sw   t2, 4(t0)
fi_count:
    srli t2, t2, 12                     ; the sectors of the flash
    addi t2, t2, -0x202                 ; from the first sector of the files on
    la   t0, fs_sectors
    sw   t2, 0(t0)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the JEDEC id of the flash (its command 0x9F over SPI1, by hand, as on the C3; Read Chip reads it so too); the low
; 24 bits: the maker, the type, the size as a power of two. It calls nothing.
flash_ident:
    li   t0, SPI1
    lw   t1, 0x18(t0)                   ; SPI_MEM_USER before
    lw   t2, 0x20(t0)                   ; SPI_MEM_USER2 before
    lw   t3, 0x08(t0)                   ; SPI_MEM_CTRL before
    li   t4, 0x00200000                 ; SPI_MEM_CTRL: WP_REG only (not the DIO mode of the reads)
    sw   t4, 0x08(t0)
    li   t4, 23                         ; SPI_MEM_MISO_DLEN: 24 bits
    sw   t4, 0x28(t0)
    li   t4, 0x90000000                 ; SPI_MEM_USER: COMMAND and MISO
    sw   t4, 0x18(t0)
    li   t4, 0x7000009F                 ; SPI_MEM_USER2: a command of 8 bits, 0x9F (read the id)
    sw   t4, 0x20(t0)
    sw   zero, 0x58(t0)                 ; SPI_MEM_W0
    li   t5, 0x00040000                 ; SPI_MEM_CMD: USR (bit 18), go
    sw   t5, 0(t0)
fid_wait:
    lw   t4, 0(t0)
    and  t4, t4, t5
    bnez t4, fid_wait
    lw   a0, 0x58(t0)                   ; the id
    sw   t1, 0x18(t0)
    sw   t2, 0x20(t0)
    sw   t3, 0x08(t0)
    slli a0, a0, 8                      ; the low 24 bits
    srli a0, a0, 8
    ret

; While a function of the ROM works on the flash, flash_busy = 1: a Ctrl+C for a program (key_isr) waits for its end,
; then the program stops here (a command of the flash cut off in the middle could leave the flash in a state the ROM
; does not expect).

; fl_read(address, buffer, n): n bytes (whole words) from the flash; 0 done
fl_read:
    li   t0, ROM_FL_READ
    j    fl_call

; fl_write(address, buffer, n): n bytes (whole words) into the flash (erased before); 0 done
fl_write:
    li   t0, ROM_FL_WRITE
    j    fl_call

; fl_erase(sector): the sector (4 KB) erased; 0 done
fl_erase:
    li   t0, ROM_FL_ERASE

; the function t0 of the ROM with a0 .. a2, flash_busy meanwhile, the interrupts of the core off (the cache is off
; while the ROM works on the flash: a handler of the WiFi in the flash would stop the chip; the interrupt of Ctrl+C
; comes right after); a Ctrl+C that came meanwhile stops the program now
fl_call:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   t1, flash_busy
    li   t2, 1
    sw   t2, 0(t1)
    csrrci t2, mstatus, 8
    sw   t2, 8(sp)
    jalr ra, 0(t0)
    lw   t2, 8(sp)
    andi t2, t2, 8
    csrs mstatus, t2
    la   t1, flash_busy
    sw   zero, 0(t1)
    la   t1, key_stop
    lw   t2, 0(t1)
    bnez t2, fl_stop
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
fl_stop:
    sw   zero, 0(t1)
    j    re_key

; fl_verify(address, bytes, n): 1 if the flash holds the n bytes (whole words) there, else 0. s0 the address, s1 the
; bytes, s2 the bytes left, s3 a piece
fl_verify:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
fv_part:
    beqz s2, fv_ok
    li   s3, 256
    bgeu s2, s3, fv_read
    mv   s3, s2
fv_read:
    mv   a0, s0
    li   a1, SMALL
    mv   a2, s3
    call fl_read
    bnez a0, fv_bad
    li   t0, SMALL
    li   t1, 0
fv_word:
    add  t2, t0, t1
    lw   t2, 0(t2)
    add  t3, s1, t1
    lw   t3, 0(t3)
    bne  t2, t3, fv_bad
    addi t1, t1, 4
    bltu t1, s3, fv_word
    add  s0, s0, s3
    add  s1, s1, s3
    sub  s2, s2, s3
    j    fv_part
fv_ok:
    li   a0, 1
    j    fv_end
fv_bad:
    li   a0, 0
fv_end:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret
