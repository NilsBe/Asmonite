; ESP32 (the original, Xtensa LX6): a console over UART0 with a small file system in the flash. Any terminal
; program works (PuTTY, Tera Term, the tab Serial of Asmonite): the COM port of the board, 115200 baud, 8N1, no flow
; control. The commands:
;
;   ls            the files
;   cat name      shows a file
;   put name      a new file (or a new text for one): type or paste the text, then a line with only a dot
;   rm name       removes a file
;   df            the room in the flash
;   format        a new, empty file system (all files are lost)
;   run name      starts a program
;   load name     puts the parts of a program for the RAM into their place, without starting it
;   boot name     starts the program after every reset (boot alone: which one)
;   noboot        no program after a reset
;   help          the commands
;
; Backspace (BS or DEL) takes back a character, Ctrl+C drops the line (in put: the whole file). A line ends with CR,
; LF or CR LF, whatever the terminal sends.
;
; A program is a file as Asmonite writes it into the flash (the image of the boot ROM: 0xE9, the number of segments,
; the entry, then each segment with its address and length). The console checks the CRC-32 of the file and the
; addresses of the segments, copies them to their place and calls the entry, as the boot ROM does at a start from
; the flash: the program runs until the next reset. Its code may take the IRAM 0x40080000 .. 0x40097FFF (96 KB), its
; data the DRAM 0x3FFB0000 .. 0x3FFCFFFF (128 KB): above them the console lies, which loads it. A program written for
; F9 (.imagebase 0x40080000, .data from 0x3FFB0000) fits. The watchdogs are off already.
; load takes also the room between the programs and the console, IRAM 0x40098000 .. 0x4009BFFF and DRAM
; 0x3FFD8000 .. 0x3FFDFFFF (for a part that stays while programs come and go), and leaves out the segments for the
; flash (0x400C2000 .. 0x40BFFFFF, 0x3F400000 .. 0x3F7FFFFF), which the console does not map yet.
; A part that load puts into the RAM may bring commands of its own: at 0x40094000 (the top 16 KB of the room of the
; programs) the word "CMDS" and the address of its table, for each command the address of its name, of its function
; (windowed: the name after the command in a2) and of its line for help, then a 0. The console takes a command it
; does not know from there, help shows their lines too. After a reset the console forgets the part.
; With boot, after a reset the console waits a second: press BOOT or a key to stay in the console (not BOOT during the
; reset itself: then the boot ROM waits for a download).
;
; A program on the PC talks to the console in packets (see "the packets" below; Asmonite: src\debugger\EspConsole.pas):
; files of any kind and size go up and down, each piece and each file checked by its CRC-32. The byte STX (0x02) is
; the sign for it; a second without a packet, and the console takes commands from a terminal again.
;
;   1. plug in the board (its USB port goes to a USB serial chip: CP2102, CH340 ...)
;   2. Debug > Write to Flash and Run: the program goes into the flash, the board runs it at every start
;   3. a terminal on the COM port of the board; the first time: format
;
; Some terminal programs switch the lines DTR and RTS when they open the port: on most boards these reach EN and
; GPIO 0, the board starts again (the console says hello again) or, rarely, stays in the download mode of its boot
; ROM. Then switch DTR and RTS off in the terminal.
;
; The console does not run under the debugger: the debug monitor stops the program at every byte that comes in over
; UART0 (that is its pause).
;
; The file system takes the flash from 2 MB on to its end (0x200000 .. 0x3FFFFF on a flash of 4 MB, up to 0x7FFFFF on
; one of 8 MB: flash_init reads its size from its JEDEC id; 4 to 16 MB, else 4 MB), sectors of 4 KB:
;   - sectors 0x200 and 0x201: the directory, twice. It is written into the other sector each time, with a number
;     one higher; at the start the console takes the valid one with the higher number. So a reset or a power cut
;     while it is written leaves the directory as it was before.
;     A directory: "AFS1", the number, the CRC-32 of the 64 entries and then of the word behind it, the program for
;     boot (its entry + 1, 0 none), then 64 entries of 32 bytes: the name (up to 19 characters and a 0), the first
;     sector, the length, the CRC-32 of the file.
;   - sectors 0x202 .. the last one: the files, each in sectors one after the other (the first gap big enough). A
;     new text for a file goes into a new place first; only then the directory points to it.
; The flash is erased, written and read by the functions of the ROM (ESP-IDF: esp32.rom.spiflash.ld):
; esp_rom_spiflash_erase_sector 0x40062CCC, esp_rom_spiflash_write 0x40062D50, esp_rom_spiflash_read 0x40062ED8,
; esp_rom_spiflash_attach 0x40062A6C. They check the size of the flash in g_rom_flashchip (0x3FFAE270, the word at
; +4): the console sets it to the size of the flash (at least 4 MB) if it is less.
;
; What comes in over UART0 goes into a ring of 4 KB in the RAM, also while the console sends (its FIFO in the chip
; holds only 128 bytes): so a pasted text is not lost while the console echoes it. As ESP-IDF does it, the FIFO is
; read at 0x3FF40000 (APB) and written at 0x60000000 (its address on the AHB bus): read on the AHB, a byte came
; twice now and then while core 1 ran the WiFi (wlansvc). While nothing comes, the console looks at UART0 only every
; 400 cycles or so: a core that keeps the APB busy may make the DPORT reads of the other one go wrong (an errata of
; the ESP32).
;
; The functions are windowed (entry, retw; call8 passes a10 .. a15, the result comes back in a10), as the functions
; of the ROM. The texts are in the DRAM (.data): the IRAM of the program takes words only. The buffers lie in the
; DRAM above .data (equ). The console lies above the room of the programs: its code from 0x4009C000, its data from
; 0x3FFD0000 (FILEBUF of put is below, in the room of the programs: it is needed only before one runs).
;
; A program that the boot ROM starts from the flash has to switch the watchdogs off itself (see blink_flash.asm).
.target esp32
.arch xtensa
.imagebase 0x4009C000

LINE     equ 0x3FFD1000              ; the line that is typed (256 bytes)
USED     equ 0x3FFD6000              ; a byte for each sector of the files: 1 = in use (up to 4 KB: a flash of 16 MB)
NAME     equ 0x3FFD1300              ; the name after the command (put reads the text into LINE)
SMALL    equ 0x3FFD1400              ; 256 bytes: what is read back to check a write, a part of a program
RING     equ 0x3FFD2000              ; what came in over UART0 and is not read yet (4 KB)
DIRBUF   equ 0x3FFD3000              ; the directory (4 KB)
PKT      equ 0x3FFD4000              ; a packet that came: +1 the command, +2 the length, +4 the data
OUT      equ 0x3FFD5000              ; a packet that goes: the same
FILEBUF  equ 0x3FFC0000              ; a file of put (64 KB)
EXT      equ 0x40094000              ; a part with commands of its own (see ext_command)

lit_uart0:    dd 0x3FF40000          ; UART0
lit_uart_ahb: dd 0x60000000          ; its FIFO on the AHB bus
lit_spi1:     dd 0x3FF42000          ; SPI1: the flash (packet I: its JEDEC id)
lit_spi_rdid: dd 0x7000009F          ; SPI_USER2: a command of 8 bits, 0x9F (read the id)
lit_spi_user: dd 0x90000000          ; SPI_USER: COMMAND and MISO
lit_spi_go:   dd 0x00040000          ; SPI_CMD: USR (bit 18)
lit_timg0:    dd 0x3FF5F000          ; timer group 0
lit_timg1:    dd 0x3FF60000          ; timer group 1
lit_rtc:      dd 0x3FF48000          ; RTC_CNTL
lit_wdt_key:  dd 0x50D83AA1          ; unlocks the registers of a watchdog
lit_chip:     dd 0x3FFAE270          ; g_rom_flashchip
lit_4m:       dd 0x400000
lit_attach:   dd 0x40062A6C          ; esp_rom_spiflash_attach(spiconfig, legacy)
lit_read:     dd 0x40062ED8          ; esp_rom_spiflash_read(address, buffer, length)
lit_write:    dd 0x40062D50          ; esp_rom_spiflash_write(address, buffer, length)
lit_erase:    dd 0x40062CCC          ; esp_rom_spiflash_erase_sector(sector)
lit_fs:       dd 0x200000            ; the first directory
lit_magic:    dd 0x31534641          ; "AFS1"
lit_poly:     dd 0xEDB88320          ; CRC-32
lit_filemax:  dd 0x10000             ; the longest file: 64 KB
lit_line:     dd LINE
lit_used:     dd USED
lit_name:     dd NAME
lit_small:    dd SMALL
lit_ring:     dd RING
lit_dirbuf:   dd DIRBUF
lit_filebuf:  dd FILEBUF
lit_pkt:      dd PKT
lit_out:      dd OUT
lit_ticks:    dd 0x3FFE01E0          ; g_ticks_per_us_pro of the ROM: the cycles of the core in a microsecond
lit_ext:      dd EXT
lit_ext_magic: dd 0x53444D43         ; "CMDS"
lit_wname:    dd wname
lit_s_version: dd s_version
lit_e_packet: dd e_packet
lit_e_unknown: dd e_unknown
lit_e_size:   dd e_size
lit_e_nofile: dd e_nofile
lit_e_notopen: dd e_notopen
lit_e_place:  dd e_place
lit_e_fcrc:   dd e_fcrc
lit_iram_lo: dd 0x40080000          ; the room of a program: its code
lit_iram_hi: dd 0x40098000
lit_dram_lo: dd 0x3FFB0000          ; its data
lit_dram_hi: dd 0x3FFD0000
lit_kiram_lo: dd 0x40098000         ; the room that load takes too: IRAM
lit_kiram_hi: dd 0x4009C000
lit_kdram_lo: dd 0x3FFD8000         ; and DRAM
lit_kdram_hi: dd 0x3FFE0000
lit_irom_lo: dd 0x400C2000          ; segments for the flash (load leaves them out): code
lit_irom_hi: dd 0x40C00000
lit_drom_lo: dd 0x3F400000          ; constants
lit_drom_hi: dd 0x3F800000
lit_c_load:  dd c_load
lit_s_loaded: dd s_loaded
lit_s_loaded1: dd s_loaded1
lit_s_loaded2: dd s_loaded2
lit_gpio_in: dd 0x3FF4403C          ; GPIO_IN_REG: bit 0 GPIO 0 (BOOT, low when pressed)
lit_iomux0:  dd 0x3FF49044          ; IO_MUX of GPIO 0
lit_e_noprog: dd e_noprog
lit_e_where:  dd e_where
lit_e_damaged: dd e_damaged
lit_s_running: dd s_running
lit_s_auto:   dd s_auto
lit_s_auto2:  dd s_auto2
lit_s_stay:   dd s_stay
lit_s_boot:   dd s_boot
lit_s_noboot: dd s_noboot
lit_c_run:    dd c_run
lit_c_boot:   dd c_boot
lit_c_noboot: dd c_noboot
lit_vars:     dd vars
lit_digits:   dd digits
lit_s_hello:  dd s_hello
lit_s_nofs:   dd s_nofs
lit_s_prompt: dd s_prompt
lit_s_crlf:   dd s_crlf
lit_s_bs:     dd s_bs
lit_s_cancel: dd s_cancel
lit_s_help:   dd s_help
lit_s_unknown: dd s_unknown
lit_s_unknown2: dd s_unknown2
lit_s_noname: dd s_noname
lit_s_long:   dd s_long
lit_s_space:  dd s_space
lit_s_nofile: dd s_nofile
lit_s_puthint: dd s_puthint
lit_s_toolong: dd s_toolong
lit_s_saved:  dd s_saved
lit_s_bytes:  dd s_bytes
lit_s_dirfull: dd s_dirfull
lit_s_full:   dd s_full
lit_s_flasherr: dd s_flasherr
lit_s_damaged: dd s_damaged
lit_s_removed: dd s_removed
lit_s_files:  dd s_files
lit_s_inuse:  dd s_inuse
lit_s_free:   dd s_free
lit_s_nofiles: dd s_nofiles
lit_s_sure:   dd s_sure
lit_s_yes:    dd s_yes
lit_s_formatted: dd s_formatted
lit_s_notformatted: dd s_notformatted
lit_c_ls:     dd c_ls
lit_c_cat:    dd c_cat
lit_c_put:    dd c_put
lit_c_rm:     dd c_rm
lit_c_df:     dd c_df
lit_c_format: dd c_format
lit_c_help:   dd c_help

_start:
  call8 watchdogs_off
  l32r  a2, lit_ext                  ; no part with commands yet (what lies there is from before the reset)
  movi  a3, 0
  s32i  a3, a2, 0
  memw
  call8 flash_init
  l32r  a10, lit_s_hello
  call8 print
  call8 dir_load
  beqz  a10, no_fs
  call8 autostart
  j     main_loop
no_fs:
  l32r  a10, lit_s_nofs
  call8 print
main_loop:
  l32r  a10, lit_s_prompt
  call8 print
  l32r  a10, lit_line
  movi  a11, 255
  call8 read_line
  bltz  a10, main_loop               ; Ctrl+C
  call8 command
  j     main_loop

; ---------- the commands ----------

; the line in LINE: the command, then its name
  align 4
command:
  entry a1, 32
  l32r  a2, lit_line
  movi  a5, 32
cm_lead:
  l8ui  a4, a2, 0                    ; spaces before the command
  bne   a4, a5, cm_word
  addi  a2, a2, 1
  j     cm_lead
cm_word:
  beqz  a4, cm_done                  ; an empty line
  mov   a3, a2
cm_end:
  l8ui  a4, a3, 0                    ; the end of the command
  beqz  a4, cm_args
  beq   a4, a5, cm_cut
  addi  a3, a3, 1
  j     cm_end
cm_cut:
  movi  a4, 0
  s8i   a4, a3, 0                    ; the command ends with a 0
  addi  a3, a3, 1
cm_skip:
  l8ui  a4, a3, 0                    ; spaces before the name
  bne   a4, a5, cm_args
  addi  a3, a3, 1
  j     cm_skip
cm_args:
  mov   a10, a3
  call8 trim                         ; spaces behind the name
  l32r  a6, lit_name
  mov   a7, a6
cm_copy:
  l8ui  a4, a3, 0                    ; the name into NAME
  s8i   a4, a7, 0
  addi  a3, a3, 1
  addi  a7, a7, 1
  bnez  a4, cm_copy
  mov   a3, a6
  mov   a10, a2
  l32r  a11, lit_c_ls
  call8 streq
  beqz  a10, cm_1
  call8 cmd_ls
  retw
cm_1:
  mov   a10, a2
  l32r  a11, lit_c_cat
  call8 streq
  beqz  a10, cm_2
  mov   a10, a3
  call8 cmd_cat
  retw
cm_2:
  mov   a10, a2
  l32r  a11, lit_c_put
  call8 streq
  beqz  a10, cm_3
  mov   a10, a3
  call8 cmd_put
  retw
cm_3:
  mov   a10, a2
  l32r  a11, lit_c_rm
  call8 streq
  beqz  a10, cm_4
  mov   a10, a3
  call8 cmd_rm
  retw
cm_4:
  mov   a10, a2
  l32r  a11, lit_c_df
  call8 streq
  beqz  a10, cm_5
  call8 cmd_df
  retw
cm_5:
  mov   a10, a2
  l32r  a11, lit_c_format
  call8 streq
  beqz  a10, cm_6
  call8 cmd_format
  retw
cm_6:
  mov   a10, a2
  l32r  a11, lit_c_run
  call8 streq
  beqz  a10, cm_6a
  mov   a10, a3
  call8 cmd_run
  retw
cm_6a:
  mov   a10, a2
  l32r  a11, lit_c_load
  call8 streq
  beqz  a10, cm_6b
  mov   a10, a3
  call8 cmd_load
  retw
cm_6b:
  mov   a10, a2
  l32r  a11, lit_c_boot
  call8 streq
  beqz  a10, cm_6c
  mov   a10, a3
  call8 cmd_boot
  retw
cm_6c:
  mov   a10, a2
  l32r  a11, lit_c_noboot
  call8 streq
  beqz  a10, cm_6d
  call8 cmd_noboot
  retw
cm_6d:
  mov   a10, a2
  l32r  a11, lit_c_help
  call8 streq
  beqz  a10, cm_7
  l32r  a10, lit_s_help
  call8 print
  call8 ext_help
  retw
cm_7:
  mov   a10, a2                      ; a command of the part that load put there?
  mov   a11, a3
  call8 ext_command
  bnez  a10, cm_done
  l32r  a10, lit_s_unknown
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_unknown2
  call8 print
cm_done:
  retw

; the cycles of the core in a millisecond in a2: as the ROM counts them (g_ticks_per_us_pro, which
; ets_update_cpu_frequency sets: a program may change the clock), 40 MHz if it says 0
  align 4
ms_cycles:
  entry a1, 32
  l32r  a3, lit_ticks
  l32i  a3, a3, 0
  bnez  a3, mc_ticks
  movi  a3, 40
mc_ticks:
  movi  a2, 1000
  mull  a2, a2, a3
  retw

; the commands of a part that load put into the RAM: at EXT the word "CMDS", then the address of its table: for each
; command its name, its function, its line for help (each the address of the text), then a 0
; the command a2 with the name a3: 1 if it is one of the part (it ran), else 0
  align 4
ext_command:
  entry a1, 32
  call8 ext_table
  beqz  a10, ec_none
  mov   a4, a10
ec_next:
  l32i  a11, a4, 0
  beqz  a11, ec_none
  mov   a10, a2
  call8 streq
  bnez  a10, ec_run
  addi  a4, a4, 12
  j     ec_next
ec_run:
  mov   a10, a3                      ; function(name): windowed, as the commands here
  l32i  a8, a4, 4
  callx8 a8
  movi  a2, 1
  retw
ec_none:
  movi  a2, 0
  retw

; the lines for help of the commands of the part
  align 4
ext_help:
  entry a1, 32
  call8 ext_table
  beqz  a10, eh_done
  mov   a4, a10
eh_next:
  l32i  a5, a4, 0
  beqz  a5, eh_done
  l32i  a10, a4, 8
  call8 print
  addi  a4, a4, 12
  j     eh_next
eh_done:
  retw

; the table of the commands of the part in a2, 0 if there is none
  align 4
ext_table:
  entry a1, 32
  l32r  a3, lit_ext
  l32i  a4, a3, 0
  l32r  a5, lit_ext_magic
  movi  a2, 0
  bne   a4, a5, et_done
  l32i  a2, a3, 4
et_done:
  retw

; ls: the files and their lengths
  align 4
cmd_ls:
  entry a1, 32
  call8 need_fs
  beqz  a10, ls_done
  movi  a2, 0                        ; the entry
  movi  a3, 0                        ; the files
  movi  a4, 0                        ; their bytes
ls_next:
  mov   a10, a2
  call8 entry_at
  mov   a5, a10
  l8ui  a6, a5, 0
  beqz  a6, ls_skip
  addi  a3, a3, 1
  l32i  a6, a5, 24
  add   a4, a4, a6
  movi  a10, 32
  call8 put_char
  movi  a10, 32
  call8 put_char
  mov   a10, a5
  movi  a11, 20
  call8 print_pad
  l32i  a10, a5, 24
  movi  a11, 8
  call8 print_dec_right
  l32r  a10, lit_s_crlf
  call8 print
ls_skip:
  addi  a2, a2, 1
  movi  a6, 64
  bltu  a2, a6, ls_next
  bnez  a3, ls_sum
  l32r  a10, lit_s_nofiles
  call8 print
  retw
ls_sum:
  mov   a10, a3
  call8 print_dec
  l32r  a10, lit_s_files
  call8 print
  mov   a10, a4
  call8 print_dec
  l32r  a10, lit_s_bytes
  call8 print
ls_done:
  retw

; cat name: the text of the file; CR LF for every LF
  align 4
cmd_cat:
  entry a1, 32
  call8 need_fs
  beqz  a10, cat_done
  mov   a10, a2
  call8 check_name
  beqz  a10, cat_done
  mov   a10, a2
  call8 find_entry
  bgez  a10, cat_found
  l32r  a10, lit_s_nofile
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw
cat_found:
  call8 entry_at
  mov   a3, a10                      ; the entry
  l32i  a4, a3, 24                   ; the length
  l32r  a5, lit_filemax
  bgeu  a5, a4, cat_read
  l32r  a10, lit_s_damaged           ; longer than a file can be
  call8 print
  retw
cat_read:
  l32i  a10, a3, 20
  slli  a10, a10, 12                 ; the sector: its address
  l32r  a11, lit_filebuf
  addi  a12, a4, 3
  srli  a12, a12, 2
  slli  a12, a12, 2                  ; whole words
  call8 fl_read
  movi  a10, 0
  l32r  a11, lit_filebuf
  mov   a12, a4
  call8 crc32
  l32i  a5, a3, 28
  beq   a10, a5, cat_ok
  l32r  a10, lit_s_damaged
  call8 print
cat_ok:
  l32r  a5, lit_filebuf
  movi  a6, 0                        ; the byte before
  movi  a7, 0                        ; the place
cat_next:
  beq   a7, a4, cat_end
  add   a3, a5, a7
  l8ui  a3, a3, 0
  movi  a10, 10
  bne   a3, a10, cat_put
  movi  a10, 13
  beq   a6, a10, cat_put
  call8 put_char                     ; CR before an LF
cat_put:
  mov   a10, a3
  call8 put_char
  mov   a6, a3
  addi  a7, a7, 1
  j     cat_next
cat_end:
  movi  a10, 10
  beq   a6, a10, cat_done
  beqz  a4, cat_done
  l32r  a10, lit_s_crlf              ; the last line had no end
  call8 print
cat_done:
  retw

; put name: the lines up to a line with only a dot into FILEBUF, each with an LF, then into the flash
  align 4
cmd_put:
  entry a1, 32
  call8 need_fs
  beqz  a10, put_done
  mov   a10, a2
  call8 check_name
  beqz  a10, put_done
  l32r  a10, lit_s_puthint
  call8 print
  movi  a3, 0                        ; the length
  movi  a4, 0                        ; 1: too long
put_line:
  l32r  a10, lit_line
  movi  a11, 255
  call8 read_line
  bltz  a10, put_done                ; Ctrl+C: nothing is written
  mov   a5, a10
  l32r  a6, lit_line
  movi  a7, 1
  bne   a5, a7, put_add
  l8ui  a7, a6, 0
  movi  a8, 46                       ; '.'
  beq   a7, a8, put_end
put_add:
  bnez  a4, put_line                 ; too long: up to the dot, then nothing
  add   a7, a3, a5
  addi  a7, a7, 1
  l32r  a8, lit_filemax
  bgeu  a8, a7, put_copy
  movi  a4, 1
  j     put_line
put_copy:
  l32r  a7, lit_filebuf
  add   a7, a7, a3
  add   a3, a3, a5
  addi  a3, a3, 1
put_byte:
  beqz  a5, put_lf
  l8ui  a8, a6, 0
  s8i   a8, a7, 0
  addi  a6, a6, 1
  addi  a7, a7, 1
  addi  a5, a5, -1
  j     put_byte
put_lf:
  movi  a8, 10
  s8i   a8, a7, 0
  j     put_line
put_end:
  beqz  a4, put_save
  l32r  a10, lit_s_toolong
  call8 print
  retw
put_save:
  mov   a10, a2
  mov   a11, a3
  call8 save_file
put_done:
  retw

; rm name
  align 4
cmd_rm:
  entry a1, 32
  call8 need_fs
  beqz  a10, rm_done
  mov   a10, a2
  call8 check_name
  beqz  a10, rm_done
  mov   a10, a2
  call8 find_entry
  bgez  a10, rm_found
  l32r  a10, lit_s_nofile
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw
rm_found:
  call8 clear_entry
  call8 dir_save
  bnez  a10, rm_ok
  l32r  a10, lit_s_flasherr
  call8 print
  retw
rm_ok:
  l32r  a10, lit_s_removed
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
rm_done:
  retw

; df: the files, the bytes in their sectors, the bytes free
  align 4
cmd_df:
  entry a1, 32
  call8 need_fs
  beqz  a10, df_done
  call8 count_free
  mov   a3, a10                      ; the free sectors
  call8 count_files
  call8 print_dec
  l32r  a10, lit_s_files
  call8 print
  l32r  a10, lit_vars
  l32i  a10, a10, 80   ; the sectors of the files (flash_init)
  sub   a10, a10, a3
  slli  a10, a10, 12
  call8 print_dec
  l32r  a10, lit_s_inuse
  call8 print
  slli  a10, a3, 12
  call8 print_dec
  l32r  a10, lit_s_free
  call8 print
df_done:
  retw

; format: an empty directory (after "yes")
  align 4
cmd_format:
  entry a1, 32
  l32r  a10, lit_s_sure
  call8 print
  l32r  a10, lit_line
  movi  a11, 255
  call8 read_line
  l32r  a10, lit_line
  l32r  a11, lit_s_yes
  call8 streq
  bnez  a10, fm_go
  l32r  a10, lit_s_notformatted
  call8 print
  retw
fm_go:
  call8 make_fs
  beqz  a10, fm_err
  l32r  a10, lit_s_formatted
  call8 print
  retw
fm_err:
  l32r  a10, lit_s_flasherr
  call8 print
  retw

; an empty directory into the first sector, the second one erased; 1 if done
  align 4
make_fs:
  entry a1, 32
  l32r  a2, lit_dirbuf
  movi  a3, 0
  movi  a4, 0
mf_clear:
  add   a5, a2, a4
  s32i  a3, a5, 0
  addi  a4, a4, 4
  movi  a5, 1
  slli  a5, a5, 12
  bltu  a4, a5, mf_clear
  movi  a10, 0x201
  call8 fl_erase                     ; the second directory away first (its number may be higher)
  bnez  a10, mf_err
  l32r  a5, lit_vars
  movi  a6, 1
  s32i  a6, a5, 12                   ; dir_save writes the other one: the first
  call8 dir_save
  mov   a2, a10
  retw
mf_err:
  movi  a2, 0
  retw

; M: a new, empty file system
  align 4
pk_format:
  entry a1, 32
  call8 make_fs
  bnez  a10, pm_ok
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw
pm_ok:
  call8 send_ok
  retw

; ---------- the packets (for a program on the PC) ----------
; A packet: STX (0x02), the command, the length of the data (16 bits), the data, the CRC-32 of the command, the
; length and the data (all little endian). The PC sends one and waits for the answer. A name is a field of 20 bytes
; (the name, zeros behind it).
;   P              -> k "Asmonite console 1"
;   F              -> f files, bytes in use, bytes free (3 words), the name of the program for boot
;   L              -> l for each file: name, length, CRC-32 (28 bytes)
;   O name len crc -> k  a file opens for writing: its sectors are erased (a while: 50 ms each)
;   W offset bytes -> k  up to 1024 bytes at offset (the pieces in their order; the same piece again: k)
;   C              -> k  the file read back from the flash: its CRC-32 is the one of O, then it is in the directory
;   G name offset count -> d the bytes (count up to 1024, offset a multiple of 4)
;   D name         -> k  the file is removed
;   X name         -> k  the program starts (no answer after k: it runs until a reset)
;   B name         -> k  the program for boot (a field of zeros: none)
;   M              -> k  a new, empty file system (all files are lost)
;   Q              -> k  back to the commands for a terminal (also after a second without a packet)
;   I              -> k  the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0)
;   S              -> k  the divider of UART0 now (UART_CLKDIV_REG, 4 bytes)
;   S divider      -> k  at the rate now, then UART0 at the new divider: the next packet has to come right at the new
;                         rate within its second, else the divider before again. Back to the commands for a terminal
;                         the divider of the start comes back.
; e and a text: what went wrong (a damaged packet: the PC sends it again).

; packets while they come; a2 = 1: the STX of the first one came already
  align 4
packet_mode:
  entry a1, 32
pm_next:
  mov   a10, a2
  call8 read_packet
  ; after S: this packet came right at the new rate (it stays), or not (the divider before again, and what came at
  ; the wrong rate is dropped)
  l32r  a4, lit_vars
  l32i  a5, a4, 68
  beqz  a5, pm_check
  movi  a6, 0
  s32i  a6, a4, 68
  beqz  a10, pm_check
  mov   a7, a10
  mov   a10, a5
  call8 set_divider
  call8 rx_poll
  l32r  a4, lit_vars
  l32i  a5, a4, 0
  s32i  a5, a4, 4                    ; the ring empty
  mov   a10, a7
pm_check:
  movi  a2, 0
  beqz  a10, pm_do
  movi  a3, 1
  beq   a10, a3, pm_leave            ; a second without a packet
  l32r  a10, lit_e_packet
  call8 send_err
  j     pm_next
pm_do:
  call8 do_packet
  beqz  a10, pm_next
pm_leave:
  ; the terminal: the rate of the start again
  l32r  a4, lit_vars
  l32i  a5, a4, 64
  beqz  a5, pm_ret
  movi  a6, 0
  s32i  a6, a4, 64
  mov   a10, a5
  call8 set_divider
pm_ret:
  retw

; UART0 to the divider a2 once what is in its FIFO is out. The bytes went into the FIFO over the AHB, its count is
; read over the APB: the count may say 0 before the last bytes are in (the 'k' of S came damaged so). So first
; 250 us, then the FIFO empty and the transmitter idle (ST_UTX_OUT, bits 27..24 of UART_STATUS_REG, 0), then 250 us
; more for the last byte in the shift register.
  align 4
set_divider:
  entry a1, 32
  l32r  a3, lit_uart0
  memw
  call8 ms_cycles
  srli  a5, a10, 2                   ; the cycles of 250 us
  rsr   a6, ccount
sd_wait1:
  rsr   a7, ccount
  sub   a7, a7, a6
  bltu  a7, a5, sd_wait1
sd_tx:
  l32i  a4, a3, 0x1C
  extui a7, a4, 16, 8                ; TXFIFO_CNT
  bnez  a7, sd_tx
  extui a7, a4, 24, 4                ; ST_UTX_OUT
  bnez  a7, sd_tx
  rsr   a6, ccount
sd_wait2:
  rsr   a7, ccount
  sub   a7, a7, a6
  bltu  a7, a5, sd_wait2
  s32i  a2, a3, 0x14                 ; UART_CLKDIV_REG
  memw
  retw

; I: the JEDEC id of the flash, as esptool flash_id reads it: the command 0x9F over the registers of SPI1 (SPI_USER
; COMMAND and MISO, SPI_USER2 8 bits of command, SPI_MISO_DLEN 24 bits, SPI_CMD USR until it is 0 again, the answer
; in SPI_W0); SPI_USER and SPI_USER2 as they were afterwards (the functions of the ROM set the rest each time)
  align 4
pk_ident:
  entry a1, 32
  call8 flash_ident
  l32r  a6, lit_vars
  s32i  a10, a6, 76
  movi  a10, 107                     ; 'k'
  addi  a11, a6, 76
  movi  a12, 4
  call8 send_packet
  retw

; the JEDEC id of the flash into a2 (see pk_ident)
  align 4
flash_ident:
  entry a1, 32
  l32r  a2, lit_spi1
  l32i  a3, a2, 0x1C                 ; SPI_USER before
  l32i  a4, a2, 0x24                 ; SPI_USER2 before
  movi  a5, 23
  s32i  a5, a2, 0x2C                 ; SPI_MISO_DLEN: 24 bits
  l32r  a5, lit_spi_user
  s32i  a5, a2, 0x1C
  l32r  a5, lit_spi_rdid
  s32i  a5, a2, 0x24
  movi  a5, 0
  s32i  a5, a2, 0x80                 ; SPI_W0
  memw
  l32r  a6, lit_spi_go
  s32i  a6, a2, 0                    ; SPI_CMD: go
  memw
pi_wait:
  l32i  a5, a2, 0
  and   a5, a5, a6
  bnez  a5, pi_wait
  l32i  a5, a2, 0x80                 ; the id
  s32i  a3, a2, 0x1C
  s32i  a4, a2, 0x24
  memw
  slli  a5, a5, 8                    ; the low 24 bits
  srli  a2, a5, 8
  retw

; S: without data the divider now; with a divider (4 bytes) k, then the new one (packet_mode checks the next packet)
  align 4
pk_speed:
  entry a1, 32
  l32r  a4, lit_vars
  l32r  a5, lit_uart0
  l32i  a6, a5, 0x14                 ; the divider now
  bnez  a2, ps_set
  s32i  a6, a4, 72
  movi  a10, 107                     ; 'k'
  addi  a11, a4, 72
  movi  a12, 4
  call8 send_packet
  retw
ps_set:
  movi  a3, 4
  beq   a2, a3, ps_four
  l32r  a10, lit_e_packet
  call8 send_err
  retw
ps_four:
  l32i  a7, a4, 64
  bnez  a7, ps_start
  s32i  a6, a4, 64                   ; the divider of the start (once)
ps_start:
  s32i  a6, a4, 68                   ; the one to go back to if the next packet does not come right
  call8 send_ok
  l32r  a3, lit_pkt
  l32i  a10, a3, 4
  call8 set_divider
  retw

; a packet into PKT (a2 = 1: its STX came already): 0 done, 1 nothing came for a second, 2 a damaged packet
  align 4
read_packet:
  entry a1, 32
  bnez  a2, rk_head
rk_wait:
  movi  a10, 1000
  call8 wait_byte
  bltz  a10, rk_idle
  movi  a3, 2
  bne   a10, a3, rk_wait             ; other bytes: left out
rk_head:
  l32r  a3, lit_pkt
  movi  a4, 1
rk_hbyte:
  movi  a10, 500
  call8 wait_byte
  bltz  a10, rk_broken
  add   a5, a3, a4
  s8i   a10, a5, 0                   ; the command and the length at PKT+1
  addi  a4, a4, 1
  movi  a5, 4
  bltu  a4, a5, rk_hbyte
  l8ui  a5, a3, 2
  l8ui  a6, a3, 3
  slli  a6, a6, 8
  or    a5, a5, a6                   ; the length
  movi  a6, 1100
  bltu  a6, a5, rk_broken
  addi  a6, a5, 4                    ; the data and the CRC
  movi  a4, 0
rk_dbyte:
  beq   a4, a6, rk_check
  movi  a10, 500
  call8 wait_byte
  bltz  a10, rk_broken
  addi  a7, a3, 4
  add   a7, a7, a4
  s8i   a10, a7, 0
  addi  a4, a4, 1
  j     rk_dbyte
rk_check:
  movi  a10, 0
  addi  a11, a3, 1
  addi  a12, a5, 3
  call8 crc32
  addi  a7, a3, 4
  add   a7, a7, a5                   ; the CRC behind the data (bytes: it need not be at a whole word)
  l8ui  a4, a7, 0
  l8ui  a6, a7, 1
  slli  a6, a6, 8
  or    a4, a4, a6
  l8ui  a6, a7, 2
  slli  a6, a6, 16
  or    a4, a4, a6
  l8ui  a6, a7, 3
  slli  a6, a6, 24
  or    a4, a4, a6
  bne   a4, a10, rk_broken
  movi  a2, 0
  retw
rk_idle:
  movi  a2, 1
  retw
rk_broken:
  movi  a2, 2
  retw

; the next byte that comes within a2 milliseconds, -1 if none
  align 4
wait_byte:
  entry a1, 32
  call8 ms_cycles
  mull  a2, a2, a10                  ; cycles
  rsr   a4, ccount
wb_loop:
  call8 rx_poll
  l32r  a5, lit_vars
  l32i  a6, a5, 0
  l32i  a7, a5, 4
  bne   a6, a7, wb_got
  rsr   a6, ccount
  sub   a6, a6, a4
  bltu  a6, a2, wb_loop
  movi  a2, -1
  retw
wb_got:
  call8 get_char
  mov   a2, a10
  retw

; the packet a2 (its command) with the a4 bytes at a3
  align 4
send_packet:
  entry a1, 32
  l32r  a5, lit_out
  s8i   a2, a5, 1
  s8i   a4, a5, 2
  srli  a6, a4, 8
  s8i   a6, a5, 3
  movi  a10, 0
  addi  a11, a5, 1
  movi  a12, 3
  call8 crc32
  mov   a11, a3
  mov   a12, a4
  call8 crc32
  mov   a6, a10                      ; the CRC
  movi  a10, 2
  call8 put_char
  l8ui  a10, a5, 1
  call8 put_char
  l8ui  a10, a5, 2
  call8 put_char
  l8ui  a10, a5, 3
  call8 put_char
  movi  a7, 0
sp_data:
  beq   a7, a4, sp_crc
  add   a10, a3, a7
  l8ui  a10, a10, 0
  call8 put_char
  addi  a7, a7, 1
  j     sp_data
sp_crc:
  extui a10, a6, 0, 8
  call8 put_char
  extui a10, a6, 8, 8
  call8 put_char
  extui a10, a6, 16, 8
  call8 put_char
  extui a10, a6, 24, 8
  call8 put_char
  retw

; k without data
  align 4
send_ok:
  entry a1, 32
  movi  a10, 107                     ; 'k'
  movi  a11, 0
  movi  a12, 0
  call8 send_packet
  retw

; e with the text a2 (without its CR LF)
  align 4
send_err:
  entry a1, 32
  mov   a10, a2
  call8 strlen
  mov   a3, a10
  blti  a3, 2, sx_send
  add   a4, a2, a3
  addi  a4, a4, -1
  l8ui  a5, a4, 0
  movi  a6, 10
  bne   a5, a6, sx_send
  addi  a3, a3, -2                   ; without CR LF
sx_send:
  movi  a10, 101                     ; 'e'
  mov   a11, a2
  mov   a12, a3
  call8 send_packet
  retw

; the packet in PKT; 1 if it was Q
  align 4
do_packet:
  entry a1, 32
  l32r  a2, lit_pkt
  l8ui  a3, a2, 1                    ; the command
  l8ui  a4, a2, 2
  l8ui  a5, a2, 3
  slli  a5, a5, 8
  or    a4, a4, a5                   ; the length of the data
  mov   a10, a4
  movi  a5, 80                       ; 'P'
  bne   a3, a5, dp_f
  movi  a10, 107
  l32r  a11, lit_s_version
  movi  a12, 18
  call8 send_packet
  j     dp_done
dp_f:
  movi  a5, 70                       ; 'F'
  bne   a3, a5, dp_l
  call8 pk_free
  j     dp_done
dp_l:
  movi  a5, 76                       ; 'L'
  bne   a3, a5, dp_o
  call8 pk_list
  j     dp_done
dp_o:
  movi  a5, 79                       ; 'O'
  bne   a3, a5, dp_w
  call8 pk_open
  j     dp_done
dp_w:
  movi  a5, 87                       ; 'W'
  bne   a3, a5, dp_c
  call8 pk_write
  j     dp_done
dp_c:
  movi  a5, 67                       ; 'C'
  bne   a3, a5, dp_g
  call8 pk_close
  j     dp_done
dp_g:
  movi  a5, 71                       ; 'G'
  bne   a3, a5, dp_d
  call8 pk_get
  j     dp_done
dp_d:
  movi  a5, 68                       ; 'D'
  bne   a3, a5, dp_q
  call8 pk_delete
  j     dp_done
dp_q:
  movi  a5, 88                       ; 'X'
  bne   a3, a5, dp_b
  call8 pk_run
  j     dp_done
dp_b:
  movi  a5, 66                       ; 'B'
  bne   a3, a5, dp_m
  call8 pk_boot
  j     dp_done
dp_m:
  movi  a5, 77                       ; 'M'
  bne   a3, a5, dp_q2
  call8 pk_format
  j     dp_done
dp_q2:
  movi  a5, 83                       ; 'S'
  bne   a3, a5, dp_i
  call8 pk_speed
  j     dp_done
dp_i:
  movi  a5, 73                       ; 'I'
  bne   a3, a5, dp_q3
  call8 pk_ident
  j     dp_done
dp_q3:
  movi  a5, 81                       ; 'Q'
  bne   a3, a5, dp_unknown
  call8 send_ok
  movi  a2, 1
  retw
dp_unknown:
  l32r  a10, lit_e_unknown
  call8 send_err
dp_done:
  movi  a2, 0
  retw

; the text of the problem of a packet with a name field of 20 bytes at PKT+4 and the length a2 (it has to be a3): the
; field ends with a 0, the name is valid, there is a file system; 0 if none
  align 4
pk_name:
  entry a1, 32
  beq   a2, a3, pn_len
  l32r  a2, lit_e_size
  retw
pn_len:
  l32r  a4, lit_vars
  l32i  a4, a4, 16
  bnez  a4, pn_fs
  l32r  a2, lit_s_nofs
  retw
pn_fs:
  l32r  a4, lit_pkt
  movi  a5, 0
  s8i   a5, a4, 23                   ; the field ends with a 0
  addi  a10, a4, 4
  call8 name_problem
  mov   a2, a10
  retw

; F: the files, the bytes in use, the bytes free
  align 4
pk_free:
  entry a1, 32
  l32r  a3, lit_vars
  l32i  a3, a3, 16
  bnez  a3, pf_fs
  l32r  a10, lit_s_nofs
  call8 send_err
  retw
pf_fs:
  l32r  a3, lit_out
  call8 count_files
  s32i  a10, a3, 4
  call8 count_free
  l32r  a4, lit_vars
  l32i  a4, a4, 80     ; the sectors of the files (flash_init)
  sub   a4, a4, a10
  slli  a4, a4, 12
  s32i  a4, a3, 8
  slli  a4, a10, 12
  s32i  a4, a3, 12
  movi  a4, 0                        ; the name of the program for boot (zeros: none)
  movi  a5, 0
pf_zero:
  add   a6, a3, a5
  s32i  a4, a6, 16
  addi  a5, a5, 4
  movi  a6, 20
  bltu  a5, a6, pf_zero
  l32r  a4, lit_dirbuf
  l32i  a4, a4, 12
  beqz  a4, pf_send
  addi  a10, a4, -1
  call8 entry_at
  movi  a5, 0
pf_name:
  add   a6, a10, a5
  l32i  a6, a6, 0
  add   a7, a3, a5
  s32i  a6, a7, 16
  addi  a5, a5, 4
  movi  a6, 20
  bltu  a5, a6, pf_name
pf_send:
  movi  a10, 102                     ; 'f'
  addi  a11, a3, 4
  movi  a12, 32
  call8 send_packet
  retw

; L: name, length, CRC-32 of each file
  align 4
pk_list:
  entry a1, 32
  l32r  a3, lit_vars
  l32i  a3, a3, 16
  bnez  a3, pl_fs
  l32r  a10, lit_s_nofs
  call8 send_err
  retw
pl_fs:
  l32r  a3, lit_out
  addi  a3, a3, 4                    ; where the next one goes
  mov   a5, a3
  movi  a2, 0                        ; the entry
pl_next:
  mov   a10, a2
  call8 entry_at
  l8ui  a4, a10, 0
  beqz  a4, pl_skip
  movi  a6, 0
pl_word:
  add   a7, a10, a6
  l32i  a7, a7, 0
  add   a4, a3, a6
  s32i  a7, a4, 0
  addi  a6, a6, 4
  movi  a7, 20
  bltu  a6, a7, pl_word
  l32i  a7, a10, 24
  s32i  a7, a3, 20
  l32i  a7, a10, 28
  s32i  a7, a3, 24
  addi  a3, a3, 28
pl_skip:
  addi  a2, a2, 1
  movi  a4, 64
  bltu  a2, a4, pl_next
  movi  a10, 108                     ; 'l'
  mov   a11, a5
  sub   a12, a3, a5
  call8 send_packet
  retw

; O name length crc: a file opens for writing, its sectors erased
  align 4
pk_open:
  entry a1, 32
  mov   a10, a2
  movi  a11, 28
  call8 pk_name
  beqz  a10, po_name
  call8 send_err
  retw
po_name:
  l32r  a2, lit_pkt
  addi  a10, a2, 4
  call8 find_entry
  mov   a5, a10                      ; its entry, or a free one
  bgez  a5, po_entry
  movi  a5, 0
po_free:
  mov   a10, a5
  call8 entry_at
  l8ui  a6, a10, 0
  beqz  a6, po_entry
  addi  a5, a5, 1
  movi  a6, 64
  bltu  a5, a6, po_free
  l32r  a10, lit_s_dirfull
  call8 send_err
  retw
po_entry:
  l32i  a3, a2, 24                   ; the length
  call8 build_used
  movi  a6, 1
  slli  a6, a6, 12
  addi  a6, a6, -1
  add   a6, a3, a6
  srli  a6, a6, 12                   ; the sectors
  l32r  a7, lit_vars
  l32i  a7, a7, 80     ; the sectors of the files (flash_init)
  bgeu  a7, a6, po_size
  l32r  a10, lit_s_full
  call8 send_err
  retw
po_size:
  mov   a10, a6
  call8 find_space
  mov   a7, a10                      ; the first sector
  bgez  a7, po_room
  l32r  a10, lit_s_full
  call8 send_err
  retw
po_room:
  movi  a4, 0
po_erase:
  beq   a4, a6, po_state
  add   a10, a7, a4
  call8 fl_erase
  bnez  a10, po_err
  addi  a4, a4, 1
  j     po_erase
po_state:
  l32r  a4, lit_vars
  movi  a6, 1
  s32i  a6, a4, 20                   ; open
  s32i  a7, a4, 24                   ; the first sector
  s32i  a3, a4, 28                   ; the length
  l32i  a6, a2, 28
  s32i  a6, a4, 32                   ; the CRC-32
  movi  a6, 0
  s32i  a6, a4, 36                   ; written so far
  s32i  a5, a4, 40                   ; the entry
  movi  a6, -1
  s32i  a6, a4, 44                   ; the offset of the last piece
  l32r  a5, lit_wname
  movi  a6, 0
po_copy:
  addi  a7, a2, 4
  add   a7, a7, a6
  l32i  a7, a7, 0
  add   a3, a5, a6
  s32i  a7, a3, 0
  addi  a6, a6, 4
  movi  a7, 20
  bltu  a6, a7, po_copy
  call8 send_ok
  retw
po_err:
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw

; W offset bytes: a piece of the open file
  align 4
pk_write:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a5, a4, 20
  bnez  a5, pw_open
  l32r  a10, lit_e_notopen
  call8 send_err
  retw
pw_open:
  addi  a2, a2, -4                   ; the bytes
  blti  a2, 1, pw_size
  movi  a5, 1024
  bgeu  a5, a2, pw_sized
pw_size:
  l32r  a10, lit_e_size
  call8 send_err
  retw
pw_sized:
  l32r  a3, lit_pkt
  l32i  a5, a3, 4                    ; the offset
  l32i  a6, a4, 36                   ; written so far
  add   a7, a5, a2                   ; behind the piece
  l32i  a8, a4, 44
  bne   a5, a8, pw_new
  bne   a7, a6, pw_new
  call8 send_ok                      ; the last piece again (its k was lost)
  retw
pw_new:
  bne   a5, a6, pw_place
  l32i  a8, a4, 28
  bltu  a8, a7, pw_place             ; beyond the length
  extui a8, a2, 0, 2
  beqz  a8, pw_pad
  l32i  a8, a4, 28
  beq   a7, a8, pw_pad               ; only the last piece may end within a word
pw_place:
  l32r  a10, lit_e_place
  call8 send_err
  retw
pw_pad:
  addi  a3, a3, 8                    ; the bytes
  add   a8, a3, a2
  movi  a9, 255
  s8i   a9, a8, 0                    ; 0xFF (erased) up to a whole word
  s8i   a9, a8, 1
  s8i   a9, a8, 2
  l32i  a10, a4, 24
  slli  a10, a10, 12
  add   a10, a10, a5
  mov   a11, a3
  addi  a12, a2, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  call8 fl_write
  bnez  a10, pw_err
  s32i  a5, a4, 44
  s32i  a7, a4, 36
  call8 send_ok
  retw
pw_err:
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw

; C: the open file read back, its CRC-32 checked, into the directory
  align 4
pk_close:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a5, a4, 20
  bnez  a5, pc_open
  l32r  a10, lit_e_notopen
  call8 send_err
  retw
pc_open:
  movi  a5, 0
  s32i  a5, a4, 20                   ; closed (also when it fails)
  l32i  a5, a4, 36
  l32i  a6, a4, 28
  beq   a5, a6, pc_whole
  l32r  a10, lit_e_place
  call8 send_err
  retw
pc_whole:
  l32i  a10, a4, 24
  mov   a11, a6
  call8 file_crc
  mov   a2, a10                      ; the CRC of what is in the flash
  l32i  a5, a4, 32
  beq   a2, a5, pc_dir
  l32r  a10, lit_e_fcrc
  call8 send_err
  retw
pc_dir:
  l32i  a10, a4, 40
  call8 entry_at
  l32r  a3, lit_wname
  movi  a5, 0
pc_name:
  add   a7, a3, a5
  l32i  a7, a7, 0
  add   a6, a10, a5
  s32i  a7, a6, 0
  addi  a5, a5, 4
  movi  a7, 20
  bltu  a5, a7, pc_name
  l32i  a5, a4, 24
  s32i  a5, a10, 20
  l32i  a5, a4, 28
  s32i  a5, a10, 24
  s32i  a2, a10, 28
  call8 dir_save
  bnez  a10, pc_ok
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw
pc_ok:
  call8 send_ok
  retw

; G name offset count: bytes of a file
  align 4
pk_get:
  entry a1, 32
  mov   a10, a2
  movi  a11, 28
  call8 pk_name
  beqz  a10, pg_name
  call8 send_err
  retw
pg_name:
  l32r  a2, lit_pkt
  addi  a10, a2, 4
  call8 find_entry
  bgez  a10, pg_found
  l32r  a10, lit_e_nofile
  call8 send_err
  retw
pg_found:
  call8 entry_at
  mov   a3, a10                      ; the entry
  l32i  a4, a2, 24                   ; the offset
  l32i  a5, a2, 28                   ; the count
  extui a6, a4, 0, 2
  bnez  a6, pg_bad
  movi  a6, 1024
  bltu  a6, a5, pg_bad
  l32i  a6, a3, 24                   ; the length of the file
  bltu  a6, a4, pg_bad
  sub   a6, a6, a4                   ; the bytes from the offset on
  bgeu  a6, a5, pg_read
  mov   a5, a6
pg_read:
  l32i  a10, a3, 20
  slli  a10, a10, 12
  add   a10, a10, a4
  l32r  a11, lit_out
  addi  a11, a11, 4
  addi  a12, a5, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  beqz  a12, pg_send
  call8 fl_read
pg_send:
  movi  a10, 100                     ; 'd'
  l32r  a11, lit_out
  addi  a11, a11, 4
  mov   a12, a5
  call8 send_packet
  retw
pg_bad:
  l32r  a10, lit_e_place
  call8 send_err
  retw

; D name: the file away
  align 4
pk_delete:
  entry a1, 32
  mov   a10, a2
  movi  a11, 20
  call8 pk_name
  beqz  a10, pd_name
  call8 send_err
  retw
pd_name:
  l32r  a2, lit_pkt
  addi  a10, a2, 4
  call8 find_entry
  bgez  a10, pd_found
  l32r  a10, lit_e_nofile
  call8 send_err
  retw
pd_found:
  call8 clear_entry
  call8 dir_save
  bnez  a10, pd_ok
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw
pd_ok:
  call8 send_ok
  retw

; X name: the program starts (k first)
  align 4
pk_run:
  entry a1, 32
  mov   a10, a2
  movi  a11, 20
  call8 pk_name
  beqz  a10, px_name
  call8 send_err
  retw
px_name:
  l32r  a10, lit_pkt
  addi  a10, a10, 4
  movi  a11, 1
  call8 run_file
  call8 send_err                     ; it did not start
  retw

; B name: the program for boot (a name field of zeros: none)
  align 4
pk_boot:
  entry a1, 32
  movi  a3, 20
  beq   a2, a3, pb_len
  l32r  a10, lit_e_size
  call8 send_err
  retw
pb_len:
  l32r  a3, lit_pkt
  l8ui  a4, a3, 4
  bnez  a4, pb_name
  l32r  a4, lit_vars
  l32i  a4, a4, 16
  beqz  a4, pb_nofs
  l32r  a4, lit_dirbuf
  movi  a5, 0
  s32i  a5, a4, 12
  j     pb_save
pb_name:
  mov   a10, a2
  movi  a11, 20
  call8 pk_name
  beqz  a10, pb_find
  call8 send_err
  retw
pb_find:
  addi  a10, a3, 4
  call8 find_entry
  bgez  a10, pb_found
  l32r  a10, lit_e_nofile
  call8 send_err
  retw
pb_found:
  addi  a10, a10, 1
  l32r  a4, lit_dirbuf
  s32i  a10, a4, 12
pb_save:
  call8 dir_save
  bnez  a10, pb_ok
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw
pb_ok:
  call8 send_ok
  retw
pb_nofs:
  l32r  a10, lit_s_nofs
  call8 send_err
  retw

; ---------- programs ----------

; run name: the program starts
  align 4
cmd_run:
  entry a1, 32
  call8 need_fs
  beqz  a10, cr_end
  mov   a10, a2
  call8 check_name
  beqz  a10, cr_end
  mov   a10, a2
  movi  a11, 0
  call8 run_file
  call8 print                        ; it did not start: why
  l32r  a10, lit_s_crlf
  call8 print
cr_end:
  retw

; load name: the segments of the program for the RAM into their place (also the room between the programs and the
; console), without starting it; the segments for the flash are left out
  align 4
cmd_load:
  entry a1, 32
  call8 need_fs
  beqz  a10, cl_end
  mov   a10, a2
  call8 check_name
  beqz  a10, cl_end
  mov   a10, a2
  call8 find_entry
  bgez  a10, cl_found
  l32r  a10, lit_e_nofile
  j     cl_say
cl_found:
  call8 entry_at
  mov   a4, a10                      ; the entry
  l32i  a10, a4, 20
  l32i  a11, a4, 24
  call8 file_crc
  l32i  a5, a4, 28
  beq   a10, a5, cl_whole
  l32r  a10, lit_e_damaged
  j     cl_say
cl_whole:
  mov   a10, a4
  movi  a11, 2
  call8 segments                     ; first only checked
  bnez  a10, cl_say
  mov   a10, a4
  movi  a11, 3
  call8 segments                     ; now into their place
  l32r  a10, lit_s_loaded
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_loaded1
  call8 print
  l32r  a10, lit_vars
  l32i  a10, a10, 60
  call8 print_dec
  l32r  a10, lit_s_loaded2
cl_say:
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
cl_end:
  retw

; boot name: the program after every reset; boot alone: which one
  align 4
cmd_boot:
  entry a1, 32
  call8 need_fs
  beqz  a10, cb_end
  l8ui  a3, a2, 0
  bnez  a3, cb_set
  call8 show_boot
  retw
cb_set:
  mov   a10, a2
  call8 check_name
  beqz  a10, cb_end
  mov   a10, a2
  call8 find_entry
  bgez  a10, cb_found
  l32r  a10, lit_s_nofile
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw
cb_found:
  addi  a10, a10, 1
  l32r  a3, lit_dirbuf
  s32i  a10, a3, 12
  call8 dir_save
  bnez  a10, cb_show
  l32r  a10, lit_s_flasherr
  call8 print
  retw
cb_show:
  call8 show_boot
cb_end:
  retw

; noboot: no program after a reset
  align 4
cmd_noboot:
  entry a1, 32
  call8 need_fs
  beqz  a10, nb_end
  l32r  a3, lit_dirbuf
  movi  a4, 0
  s32i  a4, a3, 12
  call8 dir_save
  bnez  a10, nb_show
  l32r  a10, lit_s_flasherr
  call8 print
  retw
nb_show:
  call8 show_boot
nb_end:
  retw

; "Autostart: name" or "No autostart."
  align 4
show_boot:
  entry a1, 32
  l32r  a2, lit_dirbuf
  l32i  a2, a2, 12
  bnez  a2, sb_one
  l32r  a10, lit_s_noboot
  call8 print
  retw
sb_one:
  l32r  a10, lit_s_boot
  call8 print
  addi  a10, a2, -1
  call8 entry_at
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw

; after the start: the program for boot, unless BOOT is pressed or a key comes within a second
  align 4
autostart:
  entry a1, 32
  l32r  a2, lit_dirbuf
  l32i  a2, a2, 12
  beqz  a2, as_end
  addi  a10, a2, -1
  call8 entry_at
  mov   a2, a10                      ; the entry: its name
  l8ui  a3, a2, 0
  beqz  a3, as_end
  l32r  a10, lit_s_auto
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_auto2
  call8 print
  l32r  a3, lit_iomux0
  movi  a4, 0x2B
  slli  a4, a4, 8
  s32i  a4, a3, 0                    ; GPIO 0: an input with its pull-up (0x2B00)
  memw
  call8 ms_cycles
  movi  a4, 1000
  mull  a3, a10, a4                  ; a second in cycles
  rsr   a4, ccount
as_wait:
  call8 rx_poll
  l32r  a5, lit_vars
  l32i  a6, a5, 0
  l32i  a7, a5, 4
  bne   a6, a7, as_stay              ; a key (it is read as a command then)
  l32r  a5, lit_gpio_in
  l32i  a5, a5, 0
  extui a5, a5, 0, 1
  beqz  a5, as_stay                  ; BOOT pressed
  rsr   a5, ccount
  sub   a5, a5, a4
  bltu  a5, a3, as_wait
  mov   a10, a2
  movi  a11, 0
  call8 run_file
  call8 print                        ; it did not start: why
  l32r  a10, lit_s_crlf
  call8 print
  retw
as_stay:
  l32r  a10, lit_s_stay
  call8 print
as_end:
  retw

; the program in the file a2 into its place, then its entry; a3 = 1: k before (packets), else a line. Comes back
; only when it cannot start: the text that says why
  align 4
run_file:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a4, a4, 16
  bnez  a4, rf_fs
  l32r  a2, lit_s_nofs
  retw
rf_fs:
  mov   a10, a2
  call8 find_entry
  bgez  a10, rf_found
  l32r  a2, lit_e_nofile
  retw
rf_found:
  call8 entry_at
  mov   a4, a10                      ; the entry
  l32i  a10, a4, 20
  l32i  a11, a4, 24
  call8 file_crc
  l32i  a5, a4, 28
  beq   a10, a5, rf_whole
  l32r  a2, lit_e_damaged
  retw
rf_whole:
  mov   a10, a4
  movi  a11, 0
  call8 segments                     ; first only checked
  beqz  a10, rf_load
  mov   a2, a10
  retw
rf_load:
  bnez  a3, rf_k
  l32r  a10, lit_s_running
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  j     rf_go
rf_k:
  call8 send_ok
rf_go:
  mov   a10, a4
  movi  a11, 1
  call8 segments                     ; now into their place
  call8 uart_drain
  l32r  a5, lit_vars
  l32i  a8, a5, 48                   ; the entry of the program
  isync
  callx8 a8                          ; as the boot ROM does; it does not come back
  j     rf_go

; the segments of the program in the file of entry a2: a3 bit 0 = 0 checked, 1 copied into their place; bit 1 = 1 for
; load (the room between the programs and the console too, the segments for the flash left out and counted in
; vars+60); 0 or the text of the problem. The entry of the program into vars+48
  align 4
segments:
  entry a1, 32
  l32r  a7, lit_vars
  movi  a8, 0
  s32i  a8, a7, 60                   ; no segment for the flash yet
  l32i  a4, a2, 24                   ; the length of the file
  l32i  a2, a2, 20
  slli  a2, a2, 12                   ; its address in the flash
  movi  a5, 24
  bltu  a4, a5, sg_noprog
  mov   a10, a2
  l32r  a11, lit_small
  movi  a12, 24
  call8 fl_read
  l32r  a5, lit_small
  l8ui  a6, a5, 0
  movi  a7, 0xE9
  bne   a6, a7, sg_noprog
  l32i  a6, a5, 4
  l32r  a7, lit_vars
  s32i  a6, a7, 48                   ; the entry
  l8ui  a5, a5, 1                    ; the segments
  beqz  a5, sg_noprog
  movi  a6, 16
  bltu  a6, a5, sg_noprog
  movi  a6, 24                       ; the place in the file
  j     sg_next
sg_noprog:                           ; (here in the middle: the branches reach it from both sides)
  l32r  a2, lit_e_noprog
  retw
sg_where:
  l32r  a2, lit_e_where
  retw
sg_next:
  beqz  a5, sg_done
  addi  a7, a6, 8
  bltu  a4, a7, sg_noprog
  add   a10, a2, a6
  l32r  a11, lit_small
  movi  a12, 8
  call8 fl_read
  mov   a6, a7
  l32r  a7, lit_small
  l32i  a10, a7, 0                   ; its address
  l32i  a11, a7, 4                   ; its length
  l32r  a7, lit_vars
  s32i  a10, a7, 52
  s32i  a11, a7, 56
  extui a7, a11, 0, 2
  bnez  a7, sg_noprog
  add   a7, a6, a11
  bltu  a4, a7, sg_noprog
  extui a12, a3, 1, 1                ; load?
  call8 segment_fits
  beqz  a10, sg_where
  movi  a7, 2
  bne   a10, a7, sg_ram
  l32r  a7, lit_vars                 ; a segment for the flash: left out, counted
  l32i  a8, a7, 60
  addi  a8, a8, 1
  s32i  a8, a7, 60
  j     sg_skip
sg_ram:
  extui a7, a3, 0, 1
  beqz  a7, sg_skip
  add   a10, a2, a6
  l32r  a7, lit_vars
  l32i  a11, a7, 52
  l32i  a12, a7, 56
  call8 copy_in
sg_skip:
  l32r  a7, lit_vars
  l32i  a7, a7, 56
  add   a6, a6, a7
  addi  a5, a5, -1
  j     sg_next
sg_done:
  movi  a2, 0
  retw

; 1 if a3 bytes at a2 lie in the room of a program (the IRAM or the DRAM below the console); with a4 = 1 (load) also
; in the room between the programs and the console, and 2 for a segment for the flash; else 0
  align 4
segment_fits:
  entry a1, 32
  add   a3, a3, a2                   ; behind it
  bltu  a3, a2, sf_no                ; over the end of the addresses
  l32r  a6, lit_iram_lo              ; each room: from a6, up to a7
  l32r  a7, lit_iram_hi
  bltu  a2, a6, sf_1
  bgeu  a7, a3, sf_yes
sf_1:
  l32r  a6, lit_dram_lo
  l32r  a7, lit_dram_hi
  bltu  a2, a6, sf_2
  bgeu  a7, a3, sf_yes
sf_2:
  beqz  a4, sf_no
  l32r  a6, lit_kiram_lo
  l32r  a7, lit_kiram_hi
  bltu  a2, a6, sf_3
  bgeu  a7, a3, sf_yes
sf_3:
  l32r  a6, lit_kdram_lo
  l32r  a7, lit_kdram_hi
  bltu  a2, a6, sf_4
  bgeu  a7, a3, sf_yes
sf_4:
  l32r  a6, lit_irom_lo
  l32r  a7, lit_irom_hi
  bltu  a2, a6, sf_5
  bgeu  a7, a3, sf_flash
sf_5:
  l32r  a6, lit_drom_lo
  l32r  a7, lit_drom_hi
  bltu  a2, a6, sf_no
  bgeu  a7, a3, sf_flash
sf_no:
  movi  a2, 0
  retw
sf_yes:
  movi  a2, 1
  retw
sf_flash:
  movi  a2, 2
  retw

; a4 bytes (whole words) from the flash at a2 to a3, a word at a time (the IRAM takes words only)
  align 4
copy_in:
  entry a1, 32
ci_part:
  beqz  a4, ci_done
  movi  a5, 256
  bgeu  a4, a5, ci_read
  mov   a5, a4
ci_read:
  mov   a10, a2
  l32r  a11, lit_small
  mov   a12, a5
  call8 fl_read
  l32r  a6, lit_small
  movi  a7, 0
ci_word:
  add   a8, a6, a7
  l32i  a8, a8, 0
  add   a9, a3, a7
  s32i  a8, a9, 0
  addi  a7, a7, 4
  bltu  a7, a5, ci_word
  add   a2, a2, a5
  add   a3, a3, a5
  sub   a4, a4, a5
  j     ci_part
ci_done:
  memw
  retw

; the CRC-32 of a3 bytes of the file from sector a2
  align 4
file_crc:
  entry a1, 32
  slli  a2, a2, 12                   ; the address
  movi  a4, 0                        ; the CRC
  movi  a5, 0                        ; the place
fc_part:
  beq   a5, a3, fc_done
  sub   a6, a3, a5
  movi  a7, 256
  bgeu  a7, a6, fc_read
  mov   a6, a7                       ; the bytes of this part
fc_read:
  add   a10, a2, a5
  l32r  a11, lit_small
  addi  a12, a6, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  call8 fl_read
  mov   a10, a4
  l32r  a11, lit_small
  mov   a12, a6
  call8 crc32
  mov   a4, a10
  add   a5, a5, a6
  j     fc_part
fc_done:
  mov   a2, a4
  retw

; waits until UART0 has sent all its bytes
  align 4
uart_drain:
  entry a1, 32
  l32r  a3, lit_uart0
ud_wait:
  l32i  a4, a3, 0x1C
  extui a4, a4, 16, 8                ; TXFIFO_CNT
  bnez  a4, ud_wait
  movi  a10, 2
  call8 wait_byte                    ; and the last byte leaves the shift register (it takes what comes)
  retw

; ---------- the file system ----------

; entry a2 cleared; if it was the program for boot: none
  align 4
clear_entry:
  entry a1, 32
  l32r  a3, lit_dirbuf
  l32i  a4, a3, 12
  addi  a5, a2, 1
  bne   a4, a5, ce_clear
  movi  a4, 0
  s32i  a4, a3, 12
ce_clear:
  mov   a10, a2
  call8 entry_at
  movi  a3, 0
  movi  a4, 0
ce_word:
  add   a5, a10, a4
  s32i  a3, a5, 0
  addi  a4, a4, 4
  movi  a5, 32
  bltu  a4, a5, ce_word
  retw

; the sectors that no file takes
  align 4
count_free:
  entry a1, 32
  call8 build_used
  movi  a2, 0                        ; the free ones
  movi  a3, 0                        ; the sector
  l32r  a4, lit_used
cf_next:
  add   a5, a4, a3
  l8ui  a5, a5, 0
  bnez  a5, cf_used
  addi  a2, a2, 1
cf_used:
  addi  a3, a3, 1
  l32r  a5, lit_vars
  l32i  a5, a5, 80     ; the sectors of the files (flash_init)
  bltu  a3, a5, cf_next
  retw

; the files in the directory
  align 4
count_files:
  entry a1, 32
  movi  a2, 0
  movi  a3, 0                        ; the entry
cfi_next:
  mov   a10, a3
  call8 entry_at
  l8ui  a5, a10, 0
  beqz  a5, cfi_none
  addi  a2, a2, 1
cfi_none:
  addi  a3, a3, 1
  movi  a5, 64
  bltu  a3, a5, cfi_next
  retw

; 1 if there is a file system, else a message and 0
  align 4
need_fs:
  entry a1, 32
  l32r  a3, lit_vars
  l32i  a2, a3, 16
  bnez  a2, nf_done
  l32r  a10, lit_s_nofs
  call8 print
  movi  a2, 0
nf_done:
  retw

; 1 if the name a2 can be a file name, else a message and 0
  align 4
check_name:
  entry a1, 32
  mov   a10, a2
  call8 name_problem
  beqz  a10, cn_ok
  call8 print
  movi  a2, 0
  retw
cn_ok:
  movi  a2, 1
  retw

; 0 if the name a2 can be a file name (1 to 19 characters, no spaces or control characters), else the text that
; says why not
  align 4
name_problem:
  entry a1, 32
  l8ui  a3, a2, 0
  bnez  a3, np_some
  l32r  a2, lit_s_noname
  retw
np_some:
  movi  a4, 0                        ; the length
np_next:
  add   a6, a2, a4
  l8ui  a6, a6, 0
  beqz  a6, np_end
  movi  a5, 33
  bltu  a6, a5, np_space
  movi  a5, 127
  beq   a6, a5, np_space
  addi  a4, a4, 1
  j     np_next
np_space:
  l32r  a2, lit_s_space
  retw
np_end:
  movi  a5, 20
  bltu  a4, a5, np_ok
  l32r  a2, lit_s_long
  retw
np_ok:
  movi  a2, 0
  retw

; the address of entry a2 of the directory
  align 4
entry_at:
  entry a1, 32
  l32r  a3, lit_dirbuf
  addi  a3, a3, 32
  slli  a2, a2, 5
  add   a2, a2, a3
  retw

; the entry of the file a2, -1 if there is none
  align 4
find_entry:
  entry a1, 32
  movi  a3, 0
fe_next:
  mov   a10, a3
  call8 entry_at
  mov   a4, a10
  l8ui  a5, a4, 0
  beqz  a5, fe_skip
  mov   a11, a2
  call8 streq
  bnez  a10, fe_found
fe_skip:
  addi  a3, a3, 1
  movi  a5, 64
  bltu  a3, a5, fe_next
  movi  a2, -1
  retw
fe_found:
  mov   a2, a3
  retw

; USED: 1 for every sector that a file takes
  align 4
build_used:
  entry a1, 32
  l32r  a2, lit_used
  movi  a3, 0
  movi  a4, 0
bu_clear:
  add   a5, a2, a4
  s32i  a3, a5, 0
  addi  a4, a4, 4
  movi  a5, 1
  slli  a5, a5, 12                   ; all of USED (4 KB: up to 16 MB of flash)
  bltu  a4, a5, bu_clear
  movi  a3, 0                        ; the entry
bu_next:
  mov   a10, a3
  call8 entry_at
  l8ui  a4, a10, 0
  beqz  a4, bu_skip
  l32i  a4, a10, 20                  ; the first sector
  l32i  a5, a10, 24                  ; the length
  movi  a6, 1
  slli  a6, a6, 12
  addi  a6, a6, -1
  add   a5, a5, a6
  srli  a5, a5, 12                   ; the sectors
  movi  a6, 0x202
  sub   a4, a4, a6                   ; from the first sector of the files
  bltz  a4, bu_skip                  ; (a damaged entry: left out)
  add   a6, a4, a5
  l32r  a7, lit_vars
  l32i  a7, a7, 80     ; the sectors of the files (flash_init)
  bltu  a7, a6, bu_skip
  movi  a6, 1
bu_mark:
  beqz  a5, bu_skip
  add   a7, a2, a4
  s8i   a6, a7, 0
  addi  a4, a4, 1
  addi  a5, a5, -1
  j     bu_mark
bu_skip:
  addi  a3, a3, 1
  movi  a4, 64
  bltu  a3, a4, bu_next
  retw

; the first sector of a2 free sectors one after the other (after build_used), -1 if there is no such gap
  align 4
find_space:
  entry a1, 32
  movi  a3, 0                        ; the sector
  movi  a4, 0                        ; free ones in a row
  l32r  a5, lit_used
  bnez  a2, fs_next
  movi  a2, 0x202                    ; an empty file takes no sector
  retw
fs_next:
  l32r  a6, lit_vars
  l32i  a6, a6, 80     ; the sectors of the files (flash_init)
  bgeu  a3, a6, fs_none
  add   a6, a5, a3
  l8ui  a6, a6, 0
  addi  a3, a3, 1
  movi  a4, 0
  bnez  a6, fs_next
  ; a free sector: count the row from it
  addi  a4, a3, -1                   ; where the row starts
fs_row:
  sub   a6, a3, a4
  beq   a6, a2, fs_found
  l32r  a6, lit_vars
  l32i  a6, a6, 80     ; the sectors of the files (flash_init)
  bgeu  a3, a6, fs_none
  add   a6, a5, a3
  l8ui  a6, a6, 0
  addi  a3, a3, 1
  beqz  a6, fs_row
  j     fs_next
fs_found:
  movi  a6, 0x202
  add   a2, a4, a6
  retw
fs_none:
  movi  a2, -1
  retw

; the file a2 with the a3 bytes of FILEBUF into the flash; 1 if done
  align 4
save_file:
  entry a1, 32
  mov   a10, a2
  call8 find_entry
  mov   a5, a10                      ; its entry, or a free one
  bgez  a5, sf_entry
  movi  a5, 0
sf_free:
  mov   a10, a5
  call8 entry_at
  l8ui  a6, a10, 0
  beqz  a6, sf_entry
  addi  a5, a5, 1
  movi  a6, 64
  bltu  a5, a6, sf_free
  l32r  a10, lit_s_dirfull
  call8 print
  movi  a2, 0
  retw
sf_entry:
  call8 build_used                   ; the old text of the file stays where it is until the directory is written
  movi  a6, 1
  slli  a6, a6, 12
  addi  a6, a6, -1
  add   a6, a3, a6
  srli  a6, a6, 12                   ; the sectors
  mov   a10, a6
  call8 find_space
  mov   a7, a10                      ; the first sector
  bgez  a7, sf_room
  l32r  a10, lit_s_full
  call8 print
  movi  a2, 0
  retw
sf_room:
  l32r  a4, lit_filebuf              ; zeros up to a whole word
  add   a4, a4, a3
  movi  a10, 0
  s8i   a10, a4, 0
  s8i   a10, a4, 1
  s8i   a10, a4, 2
  movi  a4, 0
sf_erase:
  beq   a4, a6, sf_write
  add   a10, a7, a4
  call8 fl_erase
  bnez  a10, sf_err
  addi  a4, a4, 1
  j     sf_erase
sf_write:
  beqz  a3, sf_dir
  slli  a10, a7, 12
  l32r  a11, lit_filebuf
  addi  a12, a3, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  call8 fl_write
  bnez  a10, sf_err
  slli  a10, a7, 12
  l32r  a11, lit_filebuf
  addi  a12, a3, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  call8 fl_verify
  beqz  a10, sf_err
sf_dir:
  mov   a10, a5
  call8 entry_at
  mov   a4, a10
  s32i  a7, a4, 20                   ; the first sector
  s32i  a3, a4, 24                   ; the length
  movi  a10, 0
  l32r  a11, lit_filebuf
  mov   a12, a3
  call8 crc32
  s32i  a10, a4, 28
  movi  a6, 0                        ; the name, with zeros up to 20 bytes
  movi  a7, 0                        ; 1: its end is passed
sf_name:
  add   a10, a2, a6
  l8ui  a10, a10, 0
  bnez  a10, sf_char
  movi  a7, 1
sf_char:
  beqz  a7, sf_store
  movi  a10, 0
sf_store:
  add   a11, a4, a6
  s8i   a10, a11, 0
  addi  a6, a6, 1
  movi  a10, 20
  bltu  a6, a10, sf_name
  call8 dir_save
  beqz  a10, sf_err
  l32r  a10, lit_s_saved
  call8 print
  mov   a10, a2
  call8 print
  movi  a10, 58                      ; ':'
  call8 put_char
  movi  a10, 32
  call8 put_char
  mov   a10, a3
  call8 print_dec
  l32r  a10, lit_s_bytes
  call8 print
  movi  a2, 1
  retw
sf_err:
  l32r  a10, lit_s_flasherr
  call8 print
sf_fail:
  movi  a2, 0
  retw

; reads both directories and keeps the valid one with the higher number in DIRBUF; 1 if there is one
  align 4
dir_load:
  entry a1, 32
  movi  a10, 1
  call8 dir_read
  mov   a3, a10                      ; the second one valid?
  movi  a4, 0
  beqz  a3, dl_first
  l32r  a5, lit_dirbuf
  l32i  a4, a5, 4                    ; its number
dl_first:
  movi  a10, 0
  call8 dir_read
  beqz  a10, dl_second
  l32r  a5, lit_dirbuf
  l32i  a6, a5, 4
  beqz  a3, dl_use_first
  bgeu  a6, a4, dl_use_first
  movi  a10, 1
  call8 dir_read                     ; the second one is newer: read it again
  movi  a6, 1
  j     dl_set
dl_use_first:
  movi  a6, 0
  j     dl_set
dl_second:
  beqz  a3, dl_none
  movi  a10, 1
  call8 dir_read
  movi  a6, 1
dl_set:
  l32r  a5, lit_vars
  s32i  a6, a5, 12                   ; the directory in use
  movi  a7, 1
  s32i  a7, a5, 16                   ; a file system
  movi  a2, 1
  retw
dl_none:
  l32r  a5, lit_vars
  movi  a7, 0
  s32i  a7, a5, 16
  movi  a2, 0
  retw

; directory a2 (0 or 1) into DIRBUF; 1 if it is valid
  align 4
dir_read:
  entry a1, 32
  slli  a10, a2, 12
  l32r  a3, lit_fs
  add   a10, a10, a3
  l32r  a11, lit_dirbuf
  movi  a12, 1
  slli  a12, a12, 12
  call8 fl_read
  bnez  a10, dr_bad
  l32r  a2, lit_dirbuf
  l32i  a3, a2, 0
  l32r  a4, lit_magic
  bne   a3, a4, dr_bad
  movi  a10, 0
  addi  a11, a2, 32
  movi  a12, 1024
  add   a12, a12, a12                ; 64 entries of 32 bytes
  call8 crc32
  addi  a11, a2, 12                  ; then the program for boot
  movi  a12, 4
  call8 crc32
  l32i  a3, a2, 8
  bne   a10, a3, dr_bad
  movi  a2, 1
  retw
dr_bad:
  movi  a2, 0
  retw

; DIRBUF with the next number into the other directory; 1 if done
  align 4
dir_save:
  entry a1, 32
  l32r  a2, lit_dirbuf
  l32r  a3, lit_magic
  s32i  a3, a2, 0
  l32i  a3, a2, 4
  addi  a3, a3, 1
  s32i  a3, a2, 4
  movi  a10, 0
  addi  a11, a2, 32
  movi  a12, 1024
  add   a12, a12, a12
  call8 crc32
  addi  a11, a2, 12
  movi  a12, 4
  call8 crc32
  s32i  a10, a2, 8
  l32r  a4, lit_vars
  l32i  a5, a4, 12
  movi  a6, 1
  xor   a5, a5, a6                   ; the other one
  movi  a10, 0x200
  add   a10, a10, a5
  call8 fl_erase
  bnez  a10, ds_err
  slli  a3, a5, 12
  l32r  a6, lit_fs
  add   a3, a3, a6                   ; its address
  mov   a10, a3
  mov   a11, a2
  movi  a12, 1
  slli  a12, a12, 12
  call8 fl_write
  bnez  a10, ds_err
  mov   a10, a3
  mov   a11, a2
  movi  a12, 1
  slli  a12, a12, 12
  call8 fl_verify
  beqz  a10, ds_err
  s32i  a5, a4, 12                   ; now the one in use
  movi  a6, 1
  s32i  a6, a4, 16
  movi  a2, 1
  retw
ds_err:
  movi  a2, 0
  retw

; the CRC-32 (as zlib) of a4 bytes at a3, going on from the CRC a2 of the bytes before them (0 at the start)
  align 4
crc32:
  entry a1, 32
  movi  a6, -1
  xor   a2, a2, a6
  l32r  a5, lit_poly
  beqz  a4, cr_done
cr_byte:
  l8ui  a6, a3, 0
  xor   a2, a2, a6
  movi  a7, 8
cr_bit:
  extui a6, a2, 0, 1
  srli  a2, a2, 1
  beqz  a6, cr_next
  xor   a2, a2, a5
cr_next:
  addi  a7, a7, -1
  bnez  a7, cr_bit
  addi  a3, a3, 1
  addi  a4, a4, -1
  bnez  a4, cr_byte
cr_done:
  movi  a6, -1
  xor   a2, a2, a6
  retw

; ---------- the flash (the functions of the ROM; 0 = done) ----------

; the flash attached to the SPI pins of the eFuses (as at the start from the flash); its size from its JEDEC id (4 to
; 16 MB, else 4 MB as before): the ROM knows it (g_rom_flashchip, at least that size), and the file system reaches to
; its end (the sectors of the files in vars+80)
  align 4
flash_init:
  entry a1, 32
  l32r  a2, lit_chip
  l32r  a3, lit_4m
  l32i  a4, a2, 4
  bgeu  a4, a3, fi_attach
  s32i  a3, a2, 4
fi_attach:
  movi  a10, 0
  movi  a11, 0
  l32r  a8, lit_attach
  callx8 a8
  call8 flash_ident
  extui a5, a10, 16, 8               ; the size as a power of two (0x16: 4 MB, 0x17: 8 MB, 0x18: 16 MB)
  movi  a6, 0x16
  bltu  a5, a6, fi_size
  movi  a6, 0x18
  bltu  a6, a5, fi_size
  movi  a3, 1
  ssl   a5
  sll   a3, a3                       ; 1 << the power
fi_size:
  l32r  a2, lit_chip
  l32i  a4, a2, 4
  bgeu  a4, a3, fi_count
  s32i  a3, a2, 4
fi_count:
  srli  a3, a3, 12                   ; the sectors of the flash
  movi  a6, 0x202
  sub   a3, a3, a6                   ; from the first sector of the files on
  l32r  a6, lit_vars
  s32i  a3, a6, 80
  retw

; a4 bytes (whole words) from the flash at a2 to a3
  align 4
fl_read:
  entry a1, 32
  mov   a10, a2
  mov   a11, a3
  mov   a12, a4
  l32r  a8, lit_read
  callx8 a8
  mov   a2, a10
  retw

; a4 bytes (whole words) from a3 into the flash at a2 (erased before)
  align 4
fl_write:
  entry a1, 32
  mov   a10, a2
  mov   a11, a3
  mov   a12, a4
  l32r  a8, lit_write
  callx8 a8
  mov   a2, a10
  retw

; erases sector a2 (4 KB)
  align 4
fl_erase:
  entry a1, 32
  mov   a10, a2
  l32r  a8, lit_erase
  callx8 a8
  mov   a2, a10
  retw

; 1 if the flash at a2 holds the a4 bytes (whole words) at a3
  align 4
fl_verify:
  entry a1, 32
fv_part:
  beqz  a4, fv_ok
  movi  a5, 256
  bgeu  a4, a5, fv_read
  mov   a5, a4
fv_read:
  mov   a10, a2
  l32r  a11, lit_small
  mov   a12, a5
  call8 fl_read
  bnez  a10, fv_bad
  l32r  a6, lit_small
  movi  a7, 0
fv_word:
  add   a8, a6, a7
  l32i  a8, a8, 0
  add   a9, a3, a7
  l32i  a9, a9, 0
  bne   a8, a9, fv_bad
  addi  a7, a7, 4
  bltu  a7, a5, fv_word
  add   a2, a2, a5
  add   a3, a3, a5
  sub   a4, a4, a5
  j     fv_part
fv_ok:
  movi  a2, 1
  retw
fv_bad:
  movi  a2, 0
  retw

; ---------- UART0 ----------

; what the FIFO of UART0 holds into the ring (a byte is dropped when the ring is full)
  align 4
rx_poll:
  entry a1, 32
  l32r  a2, lit_uart0
  l32r  a4, lit_vars
  l32r  a7, lit_ring
rp_next:
  l32i  a5, a2, 0x1C
  extui a5, a5, 0, 8                 ; RXFIFO_CNT
  beqz  a5, rp_done
  l32i  a5, a2, 0                    ; a byte (UART_FIFO_REG on the APB)
  l32i  a6, a4, 0                    ; where it goes
  add   a8, a7, a6
  s8i   a5, a8, 0
  addi  a6, a6, 1
  extui a6, a6, 0, 12
  l32i  a8, a4, 4
  beq   a6, a8, rp_next              ; the ring is full
  s32i  a6, a4, 0
  j     rp_next
rp_done:
  retw

; the next byte that came in (waits for it)
  align 4
get_char:
  entry a1, 32
gc_wait:
  call8 rx_poll
  l32r  a4, lit_vars
  l32i  a5, a4, 0
  l32i  a6, a4, 4
  bne   a5, a6, gc_got
  movi  a5, 200                      ; nothing: a while without the bus (see the head of the file)
gc_idle:
  addi  a5, a5, -1
  bnez  a5, gc_idle
  j     gc_wait
gc_got:
  l32r  a7, lit_ring
  add   a7, a7, a6
  l8ui  a2, a7, 0
  addi  a6, a6, 1
  extui a6, a6, 0, 12
  s32i  a6, a4, 4
  retw

; one byte a2 to UART0; while its FIFO is (nearly) full, what comes in goes into the ring
  align 4
put_char:
  entry a1, 32
  l32r  a3, lit_uart0
  movi  a5, 120
pc_wait:
  l32i  a4, a3, 0x1C
  extui a4, a4, 16, 8                ; TXFIFO_CNT
  bltu  a4, a5, pc_room
  call8 rx_poll
  j     pc_wait
pc_room:
  l32r  a3, lit_uart_ahb
  s32i  a2, a3, 0                    ; UART_FIFO_REG on the AHB
  memw
  retw

; a line into a2 (at most a3 characters and a 0), with echo; its length, -1 for Ctrl+C
  align 4
read_line:
  entry a1, 32
  movi  a4, 0                        ; the length
rl_next:
  call8 get_char
  mov   a5, a10
  l32r  a7, lit_vars
  l32i  a6, a7, 8                    ; the byte before was a CR
  movi  a8, 0
  s32i  a8, a7, 8
  movi  a8, 10
  bne   a5, a8, rl_cr
  bnez  a6, rl_next                  ; the LF of CR LF: the line has ended already
  j     rl_end
rl_cr:
  movi  a8, 13
  bne   a5, a8, rl_cc
  movi  a8, 1
  s32i  a8, a7, 8
  j     rl_end
rl_cc:
  movi  a8, 2
  bne   a5, a8, rl_cc3
  movi  a10, 1
  call8 packet_mode                  ; STX: a program on the PC; then the line starts anew
  movi  a4, 0
  j     rl_next
rl_cc3:
  movi  a8, 3
  bne   a5, a8, rl_bs
  l32r  a10, lit_s_cancel
  call8 print
  movi  a2, -1
  retw
rl_bs:
  movi  a8, 8
  beq   a5, a8, rl_back
  movi  a8, 127
  beq   a5, a8, rl_back
  movi  a8, 9
  bne   a5, a8, rl_ctrl
  movi  a5, 32                       ; a tab: a space
rl_ctrl:
  movi  a8, 32
  bltu  a5, a8, rl_next              ; other control characters: left out
  bgeu  a4, a3, rl_next              ; the line is full
  add   a8, a2, a4
  s8i   a5, a8, 0
  addi  a4, a4, 1
  mov   a10, a5
  call8 put_char
  j     rl_next
rl_back:
  beqz  a4, rl_next
  addi  a4, a4, -1
  l32r  a10, lit_s_bs
  call8 print
  j     rl_next
rl_end:
  add   a8, a2, a4
  movi  a6, 0
  s8i   a6, a8, 0
  l32r  a10, lit_s_crlf
  call8 print
  mov   a2, a4
  retw

; ---------- texts ----------

; the text at a2 (up to its 0) to UART0
  align 4
print:
  entry a1, 32
pr_next:
  l8ui  a10, a2, 0
  beqz  a10, pr_done
  call8 put_char
  addi  a2, a2, 1
  j     pr_next
pr_done:
  retw

; the text a2, then spaces up to a3 characters
  align 4
print_pad:
  entry a1, 32
  mov   a10, a2
  call8 strlen
  sub   a3, a3, a10
  mov   a10, a2
  call8 print
pp_space:
  blti  a3, 1, pp_done
  movi  a10, 32
  call8 put_char
  addi  a3, a3, -1
  j     pp_space
pp_done:
  retw

; a2 in decimal (unsigned)
  align 4
print_dec:
  entry a1, 32
  mov   a10, a2
  call8 dec_text
  call8 print
  retw

; a2 in decimal, with spaces before it up to a3 characters
  align 4
print_dec_right:
  entry a1, 32
  mov   a10, a2
  call8 dec_text
  mov   a2, a10
  call8 strlen
  sub   a3, a3, a10
pd_space:
  blti  a3, 1, pd_text
  movi  a10, 32
  call8 put_char
  addi  a3, a3, -1
  j     pd_space
pd_text:
  mov   a10, a2
  call8 print
  retw

; a2 in decimal (unsigned) as a text in digits: its address
  align 4
dec_text:
  entry a1, 32
  l32r  a3, lit_digits
  addi  a3, a3, 11
  movi  a4, 0
  s8i   a4, a3, 0
  movi  a5, 10
dt_next:
  addi  a3, a3, -1
  remu  a6, a2, a5
  addi  a6, a6, 48                   ; '0'
  s8i   a6, a3, 0
  quou  a2, a2, a5
  bnez  a2, dt_next
  mov   a2, a3
  retw

; the length of the text a2
  align 4
strlen:
  entry a1, 32
  mov   a3, a2
sl_next:
  l8ui  a4, a3, 0
  beqz  a4, sl_done
  addi  a3, a3, 1
  j     sl_next
sl_done:
  sub   a2, a3, a2
  retw

; 1 if the texts a2 and a3 are the same, else 0
  align 4
streq:
  entry a1, 32
se_next:
  l8ui  a4, a2, 0
  l8ui  a5, a3, 0
  bne   a4, a5, se_no
  beqz  a4, se_yes
  addi  a2, a2, 1
  addi  a3, a3, 1
  j     se_next
se_yes:
  movi  a2, 1
  retw
se_no:
  movi  a2, 0
  retw

; the spaces at the end of the text a2 away
  align 4
trim:
  entry a1, 32
  mov   a10, a2
  call8 strlen
  add   a3, a2, a10                  ; behind the text
  movi  a5, 32
tr_back:
  beq   a3, a2, tr_done
  addi  a3, a3, -1
  l8ui  a4, a3, 0
  bne   a4, a5, tr_done
  movi  a4, 0
  s8i   a4, a3, 0
  j     tr_back
tr_done:
  retw

; the watchdogs off: unlocked, WDTCONFIG0 = 0, locked again (see blink_flash.asm)
  align 4
watchdogs_off:
  entry a1, 32
  l32r  a2, lit_wdt_key
  movi  a3, 0
  l32r  a4, lit_timg0
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_timg1
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_rtc
  s32i  a2, a4, 0xA4
  s32i  a3, a4, 0x8C
  s32i  a3, a4, 0xA4
  memw
  retw

.data 0x3FFD0000
vars:    dd 0                       ; +0 the ring: where the next byte goes
          dd 0                       ; +4 the ring: the next byte to read
          dd 0                       ; +8 the byte before was a CR
          dd 0                       ; +12 the directory in use (0, 1)
          dd 0                       ; +16 1: there is a file system
          dd 0                       ; +20 1: a file is open for writing (packets O, W, C)
          dd 0                       ; +24 its first sector
          dd 0                       ; +28 its length
          dd 0                       ; +32 its CRC-32
          dd 0                       ; +36 the bytes written so far
          dd 0                       ; +40 its entry
          dd 0                       ; +44 the offset of the last piece
          dd 0                       ; +48 the entry of the program that is loaded
          dd 0                       ; +52 the address of a segment
          dd 0                       ; +56 its length
          dd 0                       ; +60 load: the segments for the flash it left out
          dd 0                       ; +64 packet S: the divider of UART0 at the start (0: not changed)
          dd 0                       ; +68 packet S: the divider before, while the next packet has to show the new one
          dd 0                       ; +72 packet S: the divider now (its answer)
          dd 0                       ; +76 packet I: the JEDEC id of the flash (its answer)
          dd 510                     ; +80 the sectors of the files: from 0x202 to the end of the flash (flash_init)
wname:    dd 0, 0, 0, 0, 0           ; its name (20 bytes)
digits:   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
s_hello:  db 13, 10, 'Asmonite console for the ESP32 (help shows the commands)', 13, 10, 0
s_nofs:   db 'There is no file system in the flash yet: format makes one.', 13, 10, 0
s_prompt: db '> ', 0
s_crlf:   db 13, 10, 0
s_bs:     db 8, 32, 8, 0
s_cancel: db '^C', 13, 10, 0
s_help:   db '  ls            the files', 13, 10
          db '  cat name      shows a file', 13, 10
          db '  put name      a new file: type or paste the text, then a line with only a dot', 13, 10
          db '  rm name       removes a file', 13, 10
          db '  df            the room in the flash', 13, 10
          db '  format        a new, empty file system (all files are lost)', 13, 10
          db '  run name      starts a program (a file as Asmonite writes it into the flash)', 13, 10
          db '  load name     puts its parts for the RAM into their place, without starting it', 13, 10
          db '  boot name     starts it after every reset (boot alone: which one)', 13, 10
          db '  noboot        no program after a reset', 13, 10
          db '  help          this list', 13, 10, 0
s_unknown: db 'Unknown command: ', 0
s_unknown2: db ' (help shows the commands)', 13, 10, 0
s_noname: db 'Which file? (a name after the command)', 13, 10, 0
s_long:   db 'The name is too long: 19 characters at most.', 13, 10, 0
s_space:  db 'A name has no spaces.', 13, 10, 0
s_nofile: db 'There is no file ', 0
s_puthint: db 'The text, then a line with only a dot (Ctrl+C: cancel):', 13, 10, 0
s_toolong: db 'The text is too long: 64 KB at most. Nothing was written.', 13, 10, 0
s_saved:  db 'Saved ', 0
s_bytes:  db ' bytes', 13, 10, 0
s_dirfull: db 'The directory is full: 64 files at most.', 13, 10, 0
s_full:   db 'There is not enough room in the flash.', 13, 10, 0
s_flasherr: db 'The flash cannot be written there (it reads back otherwise).', 13, 10, 0
s_damaged: db '(The file is damaged: its checksum does not match.)', 13, 10, 0
s_removed: db 'Removed ', 0
s_files:  db ' file(s), ', 0
s_inuse:  db ' bytes in use, ', 0
s_free:   db ' bytes free', 13, 10, 0
s_nofiles: db 'No files.', 13, 10, 0
s_sure:   db 'All files will be lost. Type yes to go on: ', 0
s_yes:    db 'yes', 0
s_formatted: db 'Done: an empty file system.', 13, 10, 0
s_notformatted: db 'Nothing was changed.', 13, 10, 0
s_version: db 'Asmonite console 1', 0
e_packet: db 'The packet was damaged.', 0
e_unknown: db 'Unknown packet.', 0
e_size:   db 'The packet has the wrong length.', 0
e_nofile: db 'There is no such file.', 0
e_notopen: db 'No file is open for writing.', 0
e_place:  db 'The bytes are not at their place in the file.', 0
e_fcrc:   db 'The file in the flash does not match its CRC-32.', 0
e_noprog: db 'This is not a program (an image as Asmonite writes it into the flash).', 0
e_where:  db 'The program does not fit: its code must be in 0x40080000..0x40097FFF, its data in 0x3FFB0000..0x3FFCFFFF.', 0
e_damaged: db 'The file is damaged: its CRC-32 does not match.', 0
s_running: db 'Running ', 0
s_auto:   db 'Autostart of ', 0
s_auto2:  db ' in a second (press BOOT or a key to stay in the console)', 13, 10, 0
s_stay:   db 'No autostart this time.', 13, 10, 0
s_boot:   db 'Autostart: ', 0
s_noboot: db 'No autostart.', 13, 10, 0
c_run:    db 'run', 0
c_load:   db 'load', 0
s_loaded: db 'Loaded ', 0
s_loaded1: db ': ', 0
s_loaded2: db ' segment(s) for the flash left out.', 0
c_boot:   db 'boot', 0
c_noboot: db 'noboot', 0
c_ls:     db 'ls', 0
c_cat:    db 'cat', 0
c_put:    db 'put', 0
c_rm:     db 'rm', 0
c_df:     db 'df', 0
c_format: db 'format', 0
c_help:   db 'help', 0
