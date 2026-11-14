; ESP32-S3 (Xtensa LX7): a console over the USB port of the chip with a small file system in the flash. It is the
; console of examples\esp32\console.asm (the original ESP32) with the parts of the chip for the ESP32-S3; the
; commands, the file system and the packets are the same. Any terminal program works (PuTTY, Tera Term, the tab
; Serial of Asmonite): the COM port of the chip's own USB port ("USB Serial Device", 303A:1001; the baud rate does not
; matter). The commands:
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
;   wlan          the WiFi network of the board (wlan set: its name and password; wlan on, wlan off; wlan clear:
;                 none; see cmd_wlan). With a network and not wlan off the WiFi starts at the start of the
;                 console, in the background (wlan_boot); once connected, the console gets an address by DHCP
;                 and the WiFi service answers ping for it (net_tick)
;   help          the commands
;   name [args]   any other word: the program name or name.bin of the files, the rest of the line its arguments (in
;                 its a2 and by args()); no "Running" before it, no "Program ended (code 0)" after it
;
; Backspace (BS or DEL) takes back a character, Ctrl+C drops the line (in put: the whole file). A line ends with CR,
; LF or CR LF, whatever the terminal sends.
;
; A program is a file as Asmonite writes it into the flash (the image of the boot ROM: 0xE9, the number of segments,
; the entry, then each segment with its address and length). The console checks the CRC-32 of the file and the
; addresses of the segments, copies them to their place and calls the entry with callx8, as the boot ROM calls a
; function: on a stack of its own (sp 0x3FCAFFE0, the top of its data, as under the debugger), the frames of the
; console in the console's stack first (spill), with the vectors of the console (VECBASE 0x403C0400). The program ends
;   - with retw (it begins with entry): "Program ended (code n)", n its a2;
;   - with exit(code) from any depth: callx8 to 0x403C0800 (the first of the functions of the console for programs,
;     each 4 bytes after the one before: exit, version, put_char, get_char, poll_char, print, millis, file_size,
;     file_read, file_write, flash_read, args; see jt_exit; for aBelle: abelle/examples/esp32s3/inc/console.abel);
;   - by an exception or a break: "Program stopped: exception c at pc p, address v" (c is exccause; 0x10n an
;     interrupt of level n, 0x106 a break; 0x200 + exccause a double exception);
;   - by Ctrl+C from the terminal (Stop in the tab Serial of Asmonite): "Program stopped (Ctrl+C)", also in an endless
;     loop with the interrupts off: while the program runs, a packet over the USB port raises the NMI (nmi_key); the
;     bytes go into the ring for get_char, Ctrl+C is not passed on;
; and the console goes on (its stack, ps, vecbase and intenable as before; the peripherals and the WiFi service on
; core 1 stay as the program leaves them). An interrupt of level 1 and alloca (exccause 4, 5) go on to the vector of
; the boot ROM, as without the console (its handlers: the WiFi on core 0). A program without entry (as the old
; examples) runs until a reset. The RAM of the ESP32-S3 is one memory on two buses: a program
; may take 0x40378000 .. 0x403BFFFF (its code, the bus of the instructions) and the same RAM as 0x3FC88000 ..
; 0x3FCCFFFF (its data, the bus of the data), as F9 loads it (.imagebase 0x40378000; aBelle: the code from
; 0x40378000 (96 KB), the data from 0x3FCA0000 (64 KB with the stack)). Above it lies the console, which loads it.
; The segments for the flash (0x42000000 .., 0x3C000000 ..) load leaves out. The watchdogs are off already, the core
; runs at 40 MHz.
; A part that load puts into the RAM may bring commands of its own: at 0x403A0000 (where the WiFi service, wlansvc,
; has its entries) the word "CMDS" and the address of its table, for each command the address of its name, of its
; function (windowed: the name after the command in a2) and of its line for help, then a 0. The console takes a command
; it does not know from there, help shows their lines too. After a reset the console forgets the part.
; With the WiFi (wlan\wlansvc.asm) a program ends below 0x403A0000 (code) and 0x3FCB0000 (data): from there up to the
; console lie the service, wlan.rom and the heap of the WiFi, and the WiFi runs on core 1 while the console or a
; program runs on core 0. The large window: a program may take that room too (0x3FCB0000 .. 0x3FCCFFFF, on the bus of
; the instructions 0x403A0000 .. 0x403BFFFF). The console stops the WiFi then before it puts the program there
; (wlan_yield: a segment of run or X, a packet R, a packet T with flag 1) and starts it again in the background when
; the program ends (wlan_back), as at its start.
; With boot, after a reset the console waits 3 seconds (the USB port goes away with the reset and comes back): press
; BOOT or a key to stay in the console.
;
; A program on the PC talks to the console in packets (see "the packets" below; Asmonite: src\debugger\EspConsole.pas):
; files of any kind and size go up and down, each piece and each file checked by its CRC-32. The byte STX (0x02) is
; the sign for it; a second without a packet, and the console takes commands from a terminal again. The packet S (the
; rate of UART0 on the ESP32) is answered, but changes nothing: the USB port has no rate.
;
;   1. plug in the board at the USB port of the chip
;   2. Board > Board Manager > Prepare Board (Asmonite also offers it at F9, and updates the console by itself later)
;   3. a terminal on the COM port of the chip; the first time: format
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
; The flash is erased, written and read by the functions of the boot ROM (ESP-IDF: esp32s3.rom.ld):
; esp_rom_spiflash_erase_sector 0x400009FC, esp_rom_spiflash_write 0x40000A14, esp_rom_spiflash_read 0x40000A20,
; spi_flash_attach 0x40000AEC. They check the size of the flash in the data of the ROM (rom_spiflash_legacy_data at
; 0x3FCEFFE4 points to it, the word at +4): the console sets it to the size of the flash (at least 4 MB) if it is less.
;
; The USB port (ESP32-S3 Technical Reference Manual, chapter "USB Serial/JTAG Controller"; ESP-IDF
; usb_serial_jtag_reg.h), base 0x60038000: EP1 (+0x00) a byte from the host when EP1_CONF (+0x04) bit 2
; (SERIAL_OUT_EP_DATA_AVAIL) is set, a byte to the host into its FIFO of 64 bytes when bit 1 (SERIAL_IN_EP_DATA_FREE)
; is set; writing bit 0 (WR_DONE) sends what is in the FIFO. The console sends when the FIFO is full and whenever it
; waits for a byte. When no program on the PC has the port open, the FIFO stays full: after 10 ms the byte is dropped.
; What comes in goes into a ring of 4 KB in the RAM, also while the console sends.
;
; The functions are windowed (entry, retw; call8 passes a10 .. a15, the result comes back in a10), as the functions
; of the ROM. The texts and the buffers are in the RAM of the data (.data, equ): the bus of the instructions takes
; words only. The console lies above the room of the programs: its code from 0x403C0000 (the same RAM as 0x3FCD0000),
; its data from 0x3FCD8000, up to 0x3FCDF000; the boot ROM keeps 0x3FCE9700 .. for itself (its stack at the start).
; FILEBUF of put is in the room of the programs (0x3FCA0000 .. 0x3FCAFFFF, below the WiFi service): it is needed only
; before one runs.
.target esp32s3 flash
.arch xtensa
.imagebase 0x403C0000

LINE     equ 0x3FCD9000              ; the line that is typed (256 bytes)
USED     equ 0x3FCDE000              ; a byte for each sector of the files: 1 = in use (up to 4 KB: a flash of 16 MB)
NAME     equ 0x3FCD9300              ; the name after the command (put reads the text into LINE)
SMALL    equ 0x3FCD9400              ; 256 bytes: what is read back to check a write, a part of a program
CHUNK    equ 0x3FCD9600              ; 256 bytes and a word: a piece of a file on its way into the flash
RING     equ 0x3FCDA000              ; what came in over the USB port and is not read yet (4 KB)
DIRBUF   equ 0x3FCDB000              ; the directory (4 KB)
PKT      equ 0x3FCDC000              ; a packet that came: +1 the command, +2 the length, +4 the data
OUT      equ 0x3FCDD000              ; a packet that goes: the same
FILEBUF  equ 0x3FCA0000              ; a file of put (64 KB)
EXT      equ 0x403A0000              ; a part with commands of its own (see ext_command)
CRED     equ 0x3FCD9800              ; the WiFi network (wlan): +0 the record in use (128 bytes), +128 one read
ROMSNAP  equ 0x3FCD9900              ; the WiFi data of the ROM as the ROM set it up (see rom_snapshot): "AWR1", 392 bytes
NETTX    equ OUT                     ; DHCP: the message that goes (342 bytes; see net_tick; the buffers of the
NETNAME  equ 0x3FCD9B00              ; the name of the board in use (32 bytes; see console_dhcp.asm)
NETRX    equ PKT                     ; packets: net_tick runs only at the prompt, between packets)

lit_usb:      dd 0x60038000          ; USB Serial/JTAG: EP1 +0, EP1_CONF +4
lit_10ms:     dd 400000              ; 10 ms at 40 MHz: how long a byte waits for room in the FIFO
lit_divider:  dd 0x007002B6          ; packet S: the divider of 115200 baud on the ESP32 (the USB has none)
lit_sysclk:   dd 0x600C0060          ; SYSTEM_SYSCLK_CONF: PRE_DIV_CNT in bits 9..0
lit_swd_key:  dd 0x8F1D312A          ; the key of the super watchdog
lit_bit31:    dd 0x80000000          ; SWD_AUTO_FEED_EN
lit_cpufreq:  dd 0x40001A40          ; ets_get_cpu_frequency(): the MHz the ROM counts with
lit_setfreq:  dd 0x40001A4C          ; ets_update_cpu_frequency(mhz)
lit_spi1:     dd 0x60002000          ; SPI1: the flash (packet I: its JEDEC id)
lit_spi_rdid: dd 0x7000009F          ; SPI_USER2: a command of 8 bits, 0x9F (read the id)
lit_spi_user: dd 0x90000000          ; SPI_USER: COMMAND and MISO
lit_spi_go:   dd 0x00040000          ; SPI_CMD: USR (bit 18)
lit_spi_wp:   dd 0x00200000          ; SPI_MEM_CTRL: WP_REG (bit 21)
lit_timg0:    dd 0x6001F000          ; timer group 0
lit_timg1:    dd 0x60020000          ; timer group 1
lit_rtc:      dd 0x60008000          ; RTC_CNTL
lit_wdt_key:  dd 0x50D83AA1          ; unlocks the registers of a watchdog
lit_chip:     dd 0x3FCEFFE4          ; rom_spiflash_legacy_data: the address of the data of the flash
lit_4m:       dd 0x400000
lit_attach:   dd 0x40000AEC          ; esp_rom_spiflash_attach(spiconfig, legacy)
lit_read:     dd 0x40000A20          ; esp_rom_spiflash_read(address, buffer, length)
lit_write:    dd 0x40000A14          ; esp_rom_spiflash_write(address, buffer, length)
lit_erase:    dd 0x400009FC          ; esp_rom_spiflash_erase_sector(sector)
lit_fs:       dd 0x200000            ; the first directory
lit_magic:    dd 0x31534641          ; "AFS1"
lit_poly:     dd 0xEDB88320          ; CRC-32
lit_filemax:  dd 0x10000             ; the longest file: 64 KB
lit_line:     dd LINE
lit_used:     dd USED
lit_name:     dd NAME
lit_small:    dd SMALL
lit_chunk:    dd CHUNK
lit_ring:     dd RING
lit_dirbuf:   dd DIRBUF
lit_filebuf:  dd FILEBUF
lit_pkt:      dd PKT
lit_out:      dd OUT
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
lit_iram_lo: dd 0x40378000          ; the room of a program: its code
lit_iram_hi: dd 0x403C0000
lit_dram_lo: dd 0x3FC88000          ; its data
lit_dram_hi: dd 0x3FCD0000
lit_wroom_lo: dd 0x403A0000         ; the room of the WiFi in it (the service, wlan.rom, the heap of the WiFi): a
lit_wroom_hi: dd 0x403C0000         ; program there stops the WiFi while it runs (wlan_yield); on the bus of the
lit_wdroom_lo: dd 0x3FCB0000        ; instructions and on the one of the data
lit_wdroom_hi: dd 0x3FCD0000
lit_kiram_lo: dd 0                 ; the room that load takes too: none on the ESP32-S3 (the room of the programs
lit_kiram_hi: dd 0                  ; goes up to the console)
lit_kdram_lo: dd 0         ; and DRAM
lit_kdram_hi: dd 0
lit_irom_lo: dd 0x42000000          ; segments for the flash (load leaves them out): code
lit_irom_hi: dd 0x44000000
lit_drom_lo: dd 0x3C000000          ; constants
lit_drom_hi: dd 0x3E000000
lit_c_load:  dd c_load
lit_s_loaded: dd s_loaded
lit_s_loaded1: dd s_loaded1
lit_s_loaded2: dd s_loaded2
lit_gpio_in: dd 0x6000403C          ; GPIO_IN_REG: bit 0 GPIO 0 (BOOT, low when pressed)
lit_iomux0:  dd 0x60009004          ; IO_MUX of GPIO 0
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
lit_c_helptxt: dd c_helptxt
lit_pstack:   dd 0x3FCAFFE0          ; the stack of a program: the top of its data (as under the debugger; 32 bytes
                                     ; below 0x3FCB0000, where the WiFi service begins)
lit_vectors:  dd vectors
lit_rf_exc:   dd rf_exc
lit_rf_dexc:  dd rf_dexc
lit_s_ended:  dd s_ended
lit_s_ended2: dd s_ended2
lit_s_stopped: dd s_stopped
lit_s_at:     dd s_at
lit_s_addr:   dd s_addr
lit_intmap:   dd 0x600C2180          ; INTERRUPT_CORE0_USB_DEVICE_INT_MAP_REG: USB Serial/JTAG (source 96) to a CPU
                                     ; interrupt of core 0
lit_nmibit:   dd 0x00004000          ; the CPU interrupt 14 (the NMI) in INTENABLE
lit_rf_key:   dd rf_key
lit_s_empty:  dd s_empty
lit_s_bin:    dd s_bin
lit_s_keystop: dd s_keystop
lit_s_dbgstop: dd s_dbgstop
lit_dbghost:  dd dbg_host
lit_rom_uvec: dd 0x40000343         ; the UserExceptionVector of the boot ROM behind its first instruction
                                     ; (wsr a0, excsave1)
lit_wifi_lo:  dd 0x100000           ; the WiFi package in the flash (packets A and Y): from 1 MB
lit_wifi_hi:  dd 0x200000           ; up to the file system
lit_appclk:   dd 0x600C0000         ; SYSTEM_CORE_1_CONTROL_0: bit 1 the clock of core 1
lit_svcmark:  dd 0x3FCB001C         ; the mark "WSVC" of the WiFi service (wlan\wlansvc.asm; 0x403A001C)
lit_svcmagic: dd 0x43565357         ; "WSVC"
lit_svchead:  dd 0x3FCB0000         ; the table of the WiFi service (0x403A0000): +32 its version, +68 its svc_pblock
lit_fromcpu:  dd 0x600C003C         ; SYSTEM_CPU_INTR_FROM_CPU_3_REG: the bell of the park of core 1 (core1_park)
lit_e_wifiruns: dd e_wifiruns
lit_e_area:   dd e_area
lit_cred:     dd 0xFE000            ; the two sectors of the WiFi network (wlan): 0xFE000 and 0xFF000
lit_credmagic: dd 0x314E5741        ; "AWN1"
lit_credbuf:  dd CRED
lit_credrd:   dd CRED + 128
lit_wifihead: dd 0x1F0000           ; the head of the WiFi package
lit_wifimagic: dd 0x31505741        ; "AWP1"
lit_svcpmk:   dd 0x403A0048         ; wifi_pmk of the WiFi service (version 7)
lit_svcstat:  dd 0x403A0028         ; wifi_status of the WiFi service
lit_c_wlan:   dd c_wlan
lit_c_set:    dd c_set
lit_c_clear:  dd c_clear
lit_s_wnuse:  dd s_wnuse
lit_s_wnnone: dd s_wnnone
lit_s_wnnet:  dd s_wnnet
lit_s_wnwpa:  dd s_wnwpa
lit_s_wnopen: dd s_wnopen
lit_s_wnoff:  dd s_wnoff
lit_s_wnnot:  dd s_wnnot
lit_s_wnconn: dd s_wnconn
lit_s_wnask1: dd s_wnask1
lit_s_wnask2: dd s_wnask2
lit_s_wnkey:  dd s_wnkey
lit_s_wnbadpw: dd s_wnbadpw
lit_s_wnsaved: dd s_wnsaved
lit_s_wnsaved2: dd s_wnsaved2
lit_s_wncleared: dd s_wncleared
lit_e_nowifi: dd e_nowifi
lit_romwifi:  dd 0x3FCEF81C          ; the WiFi data of the ROM (phy_param_rom .. privacy_en, esp32s3.rom.ld)
lit_romsnap:  dd ROMSNAP
lit_snapmagic: dd 0x31525741         ; "AWR1"
lit_e_wifiold: dd e_wifiold
lit_svckeep:  dd 0x403A004C         ; wifi_keep of the WiFi service (version 8)
lit_svchalt:  dd 0x403A0050         ; wifi_halt
lit_c_on:     dd c_on
lit_c_off:    dd c_off
lit_s_wnbg1:  dd s_wnbg1
lit_s_wnbg2:  dd s_wnbg2
lit_s_wnwifi: dd s_wnwifi
lit_s_wnisoff: dd s_wnisoff
lit_s_wnconnecting: dd s_wnconnecting
lit_s_wnoffnow: dd s_wnoffnow
CON_S3        equ 1                ; for console_dhcp.asm
lit_nettx:    dd NETTX
lit_netrx:    dd NETRX
lit_netgap:   dd 4000000             ; net_tick looks at the WiFi after so many cycles (25 ms at 160 MHz)
lit_net30s:   dd 30000
lit_netday:   dd 86400               ; the longest lease the console takes (seconds)
lit_nethead:  dd net_head
lit_netname:  dd net_name
lit_s_netup:  dd s_netup
lit_s_netgone: dd s_netgone
lit_s_netfail: dd s_netfail
lit_netnamebuf: dd NETNAME
lit_s_netin:  dd s_netin
lit_s_netlocal: dd s_netlocal
lit_c_name:   dd c_name
lit_s_nmis:   dd s_nmis
lit_s_nmmac:  dd s_nmmac
lit_s_nmuse:  dd s_nmuse
lit_s_nmbad:  dd s_nmbad
lit_c_passwd: dd c_passwd
lit_s_pwask:  dd s_pwask
lit_s_pwbad:  dd s_pwbad
lit_s_pwset:  dd s_pwset
lit_s_pwnone: dd s_pwnone
lit_s_pwdone: dd s_pwdone
lit_s_pwuse:  dd s_pwuse
lit_svccall:  dd 0x403A0000         ; the table of the WiFi service on the bus of the instructions (its entries)

_start:
  rsil  a2, 5                        ; no interrupts up to level 5 (the boot ROM left its own on)
  l32r  a2, lit_usb
  movi  a3, 0
  memw
  s32i  a3, a2, 0x10                 ; USB_SERIAL_JTAG_INT_ENA: none
  memw
  call8 watchdogs_off
  call8 rom_snapshot
  l32r  a2, lit_ext                  ; no part with commands yet (what lies there is from before the reset)
  movi  a3, 0
  s32i  a3, a2, 0
  memw
  call8 flash_init
  l32r  a10, lit_s_hello
  call8 print
  call8 wlan_boot                    ; the WiFi in the background (a network kept, not wlan off)
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
  l32r  a2, lit_vars
  movi  a3, 1
  s32i  a3, a2, 224                  ; at the prompt: net_tick may look at the WiFi
  l32r  a10, lit_line
  movi  a11, 255
  call8 read_line
  l32r  a2, lit_vars
  movi  a3, 0
  s32i  a3, a2, 224
  bltz  a10, main_loop               ; Ctrl+C
  call8 command
  j     main_loop

; ---------- the vectors while a program runs (VECBASE; the boot ROM's again when it ends) ----------
; The handlers of the windows as every Xtensa program needs them. Every other exception, interrupt or break of the
; program ends it: the cause, its pc and excvaddr into vars, then out of the exception to rf_exc, which goes back to
; the console (the registers of the program are not needed any more). The console runs at interrupt level 5, a program too.
  align 1024
vectors:
_WindowOverflow4:                     ; 0x000
  s32e  a0, a5, -16
  s32e  a1, a5, -12
  s32e  a2, a5, -8
  s32e  a3, a5, -4
  rfwo
  align 64
_WindowUnderflow4:                    ; 0x040
  l32e  a0, a5, -16
  l32e  a1, a5, -12
  l32e  a2, a5, -8
  l32e  a3, a5, -4
  rfwu
  align 64
_WindowOverflow8:                     ; 0x080
  s32e  a0, a9, -16
  l32e  a0, a1, -12
  s32e  a1, a9, -12
  s32e  a2, a9, -8
  s32e  a3, a9, -4
  s32e  a4, a0, -32
  s32e  a5, a0, -28
  s32e  a6, a0, -24
  s32e  a7, a0, -20
  rfwo
  align 64
_WindowUnderflow8:                    ; 0x0C0
  l32e  a1, a9, -12
  l32e  a0, a9, -16
  l32e  a7, a1, -12
  l32e  a2, a9, -8
  l32e  a4, a7, -32
  l32e  a3, a9, -4
  l32e  a5, a7, -28
  l32e  a6, a7, -24
  l32e  a7, a7, -20
  rfwu
  align 64
_WindowOverflow12:                    ; 0x100
  s32e  a0, a13, -16
  l32e  a0, a1, -12
  s32e  a1, a13, -12
  s32e  a2, a13, -8
  s32e  a3, a13, -4
  s32e  a4, a0, -48
  s32e  a5, a0, -44
  s32e  a6, a0, -40
  s32e  a7, a0, -36
  s32e  a8, a0, -32
  s32e  a9, a0, -28
  s32e  a10, a0, -24
  s32e  a11, a0, -20
  rfwo
  align 64
_WindowUnderflow12:                   ; 0x140
  l32e  a1, a13, -12
  l32e  a0, a13, -16
  l32e  a11, a1, -12
  l32e  a2, a13, -8
  l32e  a4, a11, -48
  l32e  a8, a11, -32
  l32e  a3, a13, -4
  l32e  a5, a11, -44
  l32e  a6, a11, -40
  l32e  a7, a11, -36
  l32e  a9, a11, -28
  l32e  a10, a11, -24
  l32e  a11, a11, -20
  rfwu
  align 64
_Level2Vector:                        ; 0x180: the cause 0x102 (an interrupt of level 2)
  l32r  a0, lit_vars
  rsr   a2, epc2
  movi  a3, 0x102
  l32r  a4, lit_rf_exc
  wsr   a4, epc2
  j     vec_high2
  align 64
_Level3Vector:                        ; 0x1C0
  l32r  a0, lit_vars
  rsr   a2, epc3
  movi  a3, 0x103
  l32r  a4, lit_rf_exc
  wsr   a4, epc3
  j     vec_high3
  align 64
_Level4Vector:                        ; 0x200
  l32r  a0, lit_vars
  rsr   a2, epc4
  movi  a3, 0x104
  l32r  a4, lit_rf_exc
  wsr   a4, epc4
  j     vec_high4
  align 64
_Level5Vector:                        ; 0x240
  l32r  a0, lit_vars
  rsr   a2, epc5
  movi  a3, 0x105
  l32r  a4, lit_rf_exc
  wsr   a4, epc5
  j     vec_high5
  align 64
_DebugExceptionVector:                ; 0x280: a break in a program that runs without the debugger (0x106)
  l32r  a0, lit_vars
  rsr   a2, epc6
  movi  a3, 0x106
  l32r  a4, lit_rf_exc
  wsr   a4, epc6
  j     vec_high6
  align 64
_NMIExceptionVector:                  ; 0x2C0: bytes came over the USB port (Ctrl+C stops the program; see nmi_key)
  wsr   a0, excsave7
  j     nmi_key
  align 64
_KernelExceptionVector:               ; 0x300
  j     vec_exc
  align 64
_UserExceptionVector:                 ; 0x340
  wsr   a0, excsave1
  rsr   a0, exccause
  beqi  a0, 4, uv_rom                ; an interrupt of level 1, or alloca (movsp): the boot ROM's handler, as for a
  beqi  a0, 5, uv_rom                ; program without the console (its interrupts, the WiFi libraries)
  j     vec_exc
uv_rom:                              ; the ROM's vector (0x40000340) behind its wsr a0, excsave1 (done above)
  l32r  a0, lit_rom_uvec
  jx    a0
  align 64
_Unused:                              ; 0x380
  j     vec_exc
  align 64
_DoubleExceptionVector:               ; 0x3C0: the cause 0x200 + exccause
  l32r  a0, lit_vars
  rsr   a3, exccause
  addmi a3, a3, 0x200
  rsr   a2, depc
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  l32r  a4, lit_rf_dexc
  wsr   a4, depc
  rfde
  align 1024

; ---------- the functions of the console for programs: at fixed places (VECBASE + 0x400 = 0x403C0800), each a jump
; of 4 bytes, called with callx8 (windowed, as the functions of the ROM) ----------
jt_exit:                              ; 0x403C0800  exit(code): the program ends, the console goes on
  j     api_exit
  align 4
jt_version:                           ; 0x403C0804  version() i32: 2 (the functions up to args; 1: up to flash_read)
  j     api_version
  align 4
jt_put_char:                          ; 0x403C0808  put_char(c): a byte to the terminal
  j     api_put_char
  align 4
jt_get_char:                          ; 0x403C080C  get_char() i32: the next byte from the terminal (waits for it)
  j     get_char
  align 4
jt_poll_char:                         ; 0x403C0810  poll_char() i32: the next byte, -1 if none came
  j     api_poll_char
  align 4
jt_print:                             ; 0x403C0814  print(text): a text up to its 0
  j     api_print
  align 4
jt_millis:                            ; 0x403C0818  millis() i32: milliseconds (see api_millis)
  j     api_millis
  align 4
jt_file_size:                         ; 0x403C081C  file_size(name) i32: the length of a file, -1 none
  j     api_file_size
  align 4
jt_file_read:                         ; 0x403C0820  file_read(name, buffer, offset, count) i32: bytes read, -1
  j     api_file_read
  align 4
jt_file_write:                        ; 0x403C0824  file_write(name, buffer, count) i32: 0 done, < 0 an error
  j     api_file_write
  align 4
jt_flash_read:                        ; 0x403C0828  flash_read(address, buffer, count) i32: 0 done, -1
  j     flash_bytes
  align 4
jt_args:                              ; 0x403C082C  args() pchar: the text of the arguments (version 2)
  j     api_args
  align 4
; not for programs: for the debugger of Asmonite over the USB JTAG (packet T, M2)
jt_debug_end:                         ; 0x403C0830  the debugger ends the program here (as q of the monitor of the ESP32)
  j     rf_dbg
  align 4
jt_dbg_host:                          ; 0x403C0834  the host of the program (T calls it)
  j     dbg_host
  align 4
jt_dh_end:                            ; 0x403C0838  a program with entry ends there (retw), the debugger stops
  j     dh_end
  align 4
jt_dh_end0:                           ; 0x403C083C  a program of call0 ends there (ret)
  j     dh_end0
  align 4

; the rest of the exceptions (the registers of the program are lost; a2 its pc, a3 the cause)
vec_high2:
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  rfi   2
vec_high3:
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  rfi   3
vec_high4:
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  rfi   4
vec_high5:
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  rfi   5
vec_high6:
  s32i  a3, a0, 112
  s32i  a2, a0, 116
  rfi   6
vec_exc:                             ; kernel and user exceptions: exccause, epc1, excvaddr
  l32r  a0, lit_vars
  rsr   a2, exccause
  s32i  a2, a0, 112
  rsr   a2, epc1
  s32i  a2, a0, 116
  rsr   a2, excvaddr
  s32i  a2, a0, 120
  l32r  a2, lit_rf_exc
  wsr   a2, epc1
  rfe

; the NMI while a program runs (key_on): what came over the USB port into the ring (the NMI alone fills it then:
; rx_poll leaves the port alone; a byte for a full ring is dropped). Ctrl+C is not for the program: it stops it, out
; of the NMI to rf_key, from wherever it is (also in a function of the console, the ROM or a handler of the windows);
; only while a function of the ROM works on the flash (vars+168) it waits for its end (fl_read, fl_write, fl_erase).
; a1 .. a5 of the program wait in vars+144 .. +160
nmi_key:
  l32r  a0, lit_vars
  s32i  a1, a0, 144
  s32i  a2, a0, 148
  s32i  a3, a0, 152
  s32i  a4, a0, 156
  s32i  a5, a0, 160
  l32r  a1, lit_usb
  l32r  a5, lit_ring
nk_next:
  memw
  l32i  a2, a1, 4
  bbci  a2, 2, nk_done               ; SERIAL_OUT_EP_DATA_AVAIL
  memw
  l32i  a2, a1, 0                    ; a byte (EP1)
  memw
  extui a2, a2, 0, 8
  movi  a3, 3
  bne   a2, a3, nk_keep
  s32i  a3, a0, 164                  ; Ctrl+C
  j     nk_next
nk_keep:
  l32i  a3, a0, 0                    ; where it goes
  add   a4, a5, a3
  s8i   a2, a4, 0
  addi  a3, a3, 1
  extui a3, a3, 0, 12
  l32i  a4, a0, 4
  beq   a3, a4, nk_next              ; the ring is full
  s32i  a3, a0, 0
  j     nk_next
nk_done:
  movi  a2, -1
  s32i  a2, a1, 0x14                 ; USB_SERIAL_JTAG_INT_CLR
  memw
  l32i  a2, a0, 164
  beqz  a2, nk_back
  l32i  a2, a0, 168
  bnez  a2, nk_back                  ; the flash is busy: the end of the function of the ROM stops it
  l32r  a2, lit_rf_key
  wsr   a2, epc7
  rfi   7
nk_back:
  l32i  a1, a0, 144
  l32i  a2, a0, 148
  l32i  a3, a0, 152
  l32i  a4, a0, 156
  l32i  a5, a0, 160
  rsr   a0, excsave7
  rfi   7

; exit(code): from any depth of the program back to the console
  align 4
api_exit:
  entry a1, 32
  movi  a3, 1
  j     rf_longjmp

; version() i32: which functions the table has (1: exit .. flash_read, 2: and args)
  align 4
api_version:
  entry a1, 32
  movi  a2, 2
  retw

; put_char(c) and print(text) for a program: the console sends what is in the FIFO to the host only when it waits for
; a byte, a program at once
  align 4
api_put_char:
  entry a1, 32
  mov   a10, a2
  call8 put_char
  call8 api_flush
  retw

  align 4
api_print:
  entry a1, 32
  mov   a10, a2
  call8 print
  call8 api_flush
  retw

; what waits in the FIFO to the host goes out: tx_flush until it is done, at most 10 ms (no program on the PC that
; reads: put_char drops the bytes then, and this does not wait either)
  align 4
api_flush:
  entry a1, 32
  l32r  a3, lit_10ms
  rsr   a4, ccount
  l32r  a6, lit_vars
af_wait:
  call8 tx_flush
  l32i  a5, a6, 84
  beqz  a5, af_done                  ; sent
  l32i  a5, a6, 88
  bnez  a5, af_done                  ; nobody reads
  rsr   a5, ccount
  sub   a5, a5, a4
  bltu  a5, a3, af_wait
af_done:
  retw

; poll_char() i32: the next byte that came in, -1 if none
  align 4
api_poll_char:
  entry a1, 32
  call8 rx_poll
  l32r  a4, lit_vars
  l32i  a5, a4, 0
  l32i  a6, a4, 4
  movi  a2, -1
  beq   a5, a6, poll_done
  call8 get_char
  mov   a2, a10
poll_done:
  retw

; millis() i32: milliseconds, counted from ccount at each call (before the first one: since the core started); a
; program has to call it at least once in 2^32 cycles (107 s at 40 MHz, 18 s at 240 MHz)
  align 4
api_millis:
  entry a1, 32
  call8 ms_cycles                    ; the cycles in a millisecond into a10
  l32r  a4, lit_vars
  rsr   a5, ccount
  l32i  a6, a4, 128                  ; ccount at the call before
  s32i  a5, a4, 128
  sub   a5, a5, a6
  l32i  a6, a4, 132                  ; the cycles left over then
  add   a5, a5, a6
  quou  a6, a5, a10
  remu  a5, a5, a10
  s32i  a5, a4, 132
  l32i  a2, a4, 136
  add   a2, a2, a6
  s32i  a2, a4, 136
  retw

; the entry of the file a2 (its address in DIRBUF), 0 if there is none or no file system
  align 4
file_entry:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a4, a4, 16
  beqz  a4, fn_none
  mov   a10, a2
  call8 find_entry
  bltz  a10, fn_none
  call8 entry_at
  mov   a2, a10
  retw
fn_none:
  movi  a2, 0
  retw

; file_size(name) i32: the length of the file, -1 if there is none
  align 4
api_file_size:
  entry a1, 32
  mov   a10, a2
  call8 file_entry
  movi  a2, -1
  beqz  a10, fz_done
  l32i  a2, a10, 24
fz_done:
  retw

; file_read(name, buffer, offset, count) i32: up to count bytes of the file from offset on into buffer; how many (0
; from its end on), -1 if there is no such file or the flash cannot be read
  align 4
api_file_read:
  entry a1, 32
  mov   a10, a2
  call8 file_entry
  beqz  a10, fr_none
  l32i  a6, a10, 24                  ; the length
  l32i  a7, a10, 20                  ; the first sector
  movi  a2, 0
  bgeu  a4, a6, fr_done              ; from its end on: nothing
  sub   a6, a6, a4                   ; the bytes from offset on
  bgeu  a6, a5, fr_count
  mov   a5, a6
fr_count:
  slli  a10, a7, 12
  add   a10, a10, a4
  mov   a11, a3
  mov   a12, a5
  call8 flash_bytes
  bnez  a10, fr_none
  mov   a2, a5
fr_done:
  retw
fr_none:
  movi  a2, -1
  retw

; file_write(name, buffer, count) i32: a file with the count bytes at buffer (a new one, or a new text for one: the
; old text stays until the directory is written); 0 done, -1 the directory is full, -2 not enough room in the flash,
; -3 the flash cannot be written, -4 not a valid name, -5 no file system
  align 4
api_file_write:
  entry a1, 32
  l32r  a5, lit_vars
  l32i  a5, a5, 16
  movi  a6, -5
  beqz  a5, fw_done
  mov   a10, a2
  call8 name_problem
  movi  a6, -4
  bnez  a10, fw_done
  movi  a6, -2
  bltz  a4, fw_done
  mov   a10, a2
  mov   a11, a3
  mov   a12, a4
  call8 store_file
  mov   a6, a10
fw_done:
  mov   a2, a6
  retw

; flash_read(address, buffer, count) i32: a4 bytes of the flash from a2 on (any address, any count) to a3, in pieces
; through SMALL; 0 done, -1 the flash cannot be read there
  align 4
flash_bytes:
  entry a1, 32
fb_part:
  beqz  a4, fb_ok
  movi  a5, -4
  and   a5, a2, a5                   ; the word where the piece starts
  sub   a6, a2, a5                   ; the bytes before it in that word
  movi  a7, 252                      ; the piece: at most 252 bytes (with a6 at most 256 to read)
  bgeu  a4, a7, fb_read
  mov   a7, a4
fb_read:
  add   a12, a6, a7
  addi  a12, a12, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  mov   a10, a5
  l32r  a11, lit_small
  call8 fl_read
  bnez  a10, fb_bad
  l32r  a8, lit_small
  add   a8, a8, a6
  movi  a9, 0
fb_copy:
  add   a10, a8, a9
  l8ui  a10, a10, 0
  add   a11, a3, a9
  s8i   a10, a11, 0
  addi  a9, a9, 1
  bltu  a9, a7, fb_copy
  add   a2, a2, a7
  add   a3, a3, a7
  sub   a4, a4, a7
  j     fb_part
fb_ok:
  movi  a2, 0
  retw
fb_bad:
  movi  a2, -1
  retw

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
  call8 help_show
  call8 ext_help
  retw
cm_7:
  mov   a10, a2
  l32r  a11, lit_c_name
  call8 streq
  beqz  a10, cm_7n
  mov   a10, a3
  call8 cmd_name
  retw
cm_7n:
  mov   a10, a2
  l32r  a11, lit_c_passwd
  call8 streq
  beqz  a10, cm_7p
  mov   a10, a3
  call8 cmd_passwd
  retw
cm_7p:
  mov   a10, a2
  l32r  a11, lit_c_wlan
  call8 streq
  beqz  a10, cm_8
  mov   a10, a3
  call8 cmd_wlan
  retw
cm_8:
  mov   a10, a2                      ; a command of the part that load put there?
  mov   a11, a3
  call8 ext_command
  bnez  a10, cm_done
  mov   a10, a2                      ; a program of this name in the files?
  mov   a11, a3
  call8 cmd_file
  bnez  a10, cm_done
  l32r  a10, lit_s_unknown
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_unknown2
  call8 print
cm_done:
  retw

; a command a2 the console does not know: the program of the file a2, else of a2 + ".bin" (as Upload This Program
; names it), with the rest of the line a3 as its arguments (args(), its a2), started as a command (run_file with 2:
; nothing before it, nothing after it when it ends with the code 0). 1 if there is such a file (it ran, or why not
; is said), 0 if not
  align 4
cmd_file:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a4, a4, 16
  beqz  a4, cf_no                    ; no file system
  mov   a10, a2
  call8 find_entry
  bgez  a10, cf_run
  mov   a10, a2
  call8 strlen
  movi  a4, 15
  bltu  a4, a10, cf_no               ; the name with .bin would be longer than 19 characters
  l32r  a5, lit_chunk                ; the name with .bin into CHUNK (free while no program runs)
  mov   a6, a2
cf_name:
  l8ui  a7, a6, 0
  s8i   a7, a5, 0
  beqz  a7, cf_ext
  addi  a5, a5, 1
  addi  a6, a6, 1
  j     cf_name
cf_ext:
  l32r  a6, lit_s_bin
cf_ext2:
  l8ui  a7, a6, 0
  s8i   a7, a5, 0
  addi  a5, a5, 1
  addi  a6, a6, 1
  bnez  a7, cf_ext2
  l32r  a10, lit_chunk
  call8 find_entry
  bltz  a10, cf_no
  l32r  a2, lit_chunk
cf_run:
  mov   a10, a2
  movi  a11, 2
  mov   a12, a3
  call8 run_file
  beqz  a10, cf_yes                  ; it ran and ended (rf_after said how, if at all)
  call8 print                        ; it did not start: why
  l32r  a10, lit_s_crlf
  call8 print
cf_yes:
  movi  a2, 1
  retw
cf_no:
  movi  a2, 0
  retw

; args() for a program: the text of its arguments (the rest of the line of a command; empty for run)
  align 4
api_args:
  entry a1, 32
  l32r  a2, lit_vars
  l32i  a2, a2, 180
  retw

; the cycles of the core in a millisecond in a2: as the ROM counts them (ets_get_cpu_frequency; watchdogs_off sets
; 40 MHz with ets_update_cpu_frequency, a program may change the clock), 40 MHz if it says 0
  align 4
ms_cycles:
  entry a1, 32
  l32r  a8, lit_cpufreq
  callx8 a8
  mov   a3, a10
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

; help: the file help.txt (Prepare Board and the update of the console write it), else the short list s_help
  align 4
help_show:
  entry a1, 32
  l32r  a3, lit_vars
  l32i  a3, a3, 16                   ; a file system?
  beqz  a3, hs_short
  l32r  a10, lit_c_helptxt
  call8 find_entry
  bltz  a10, hs_short
  l32r  a10, lit_c_helptxt
  call8 cmd_cat
  retw
hs_short:
  l32r  a10, lit_s_help
  call8 print
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
;   P              -> k "Asmonite console 2"
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
;   R address bytes -> k  the bytes (whole words, up to 1024) into the RAM of the programs (Run of Asmonite); into
;                         the room of the WiFi (the large window): the WiFi stops first, until the program ends
;   E entry        -> k  the program R put into the RAM starts at its entry (as X: then it runs, and ends as there)
;   T [0 [flags]]  -> k  the debugger of Asmonite (USB JTAG, M2): the console calls its host dbg_host as a program,
;                         which stops at once (a break); the debugger loads the program and starts it from there.
;                         flags bit 0: that program takes the room of the WiFi: the WiFi stops first, until it ends
;   A address length crc -> k  as O, for the room of the WiFi package in the flash (0x100000 .. 0x1FFFFF; address a
;                         multiple of 4 KB): its sectors are erased; then W and C as for a file, C puts nothing into the
;                         directory. The WiFi stops first (its code and data come from this room)
;   Y address count -> d  the bytes of the flash there (count up to 1024, address a multiple of 4)
;   K address count -> k  the CRC-32 of count bytes of the flash at address (a multiple of 4; below 4 MB): Asmonite
;                         compares the console in the flash with its own and writes it again when they differ
;   I              -> k  the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0)
;   N              -> k  the network: the state of the WiFi, the address, the MAC, the name of the board (48 bytes;
;                        pk_net in console_dhcp.asm)
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

; the rate of UART0 on the ESP32 (packet S); the USB port has none: nothing to do. On the ESP32: UART0 to the
; divider a2 once what is in its FIFO is out. The bytes went into the FIFO over the AHB, its count is
; read over the APB: the count may say 0 before the last bytes are in (the 'k' of S came damaged so). So first
; 250 us, then the FIFO empty and the transmitter idle (ST_UTX_OUT, bits 27..24 of UART_STATUS_REG, 0), then 250 us
; more for the last byte in the shift register.
  align 4
set_divider:
  entry a1, 32
  retw

; I: the JEDEC id of the flash, as esptool flash_id reads it: the command 0x9F over the registers of SPI1 (ESP-IDF
; spi_mem_reg.h of the ESP32-S3: SPI_MEM_USER 0x18 COMMAND and MISO, SPI_MEM_USER2 0x20 8 bits of command,
; SPI_MEM_MISO_DLEN 0x28 24 bits, SPI_MEM_CMD 0 USR until it is 0 again, the answer in SPI_MEM_W0 0x58);
; SPI_MEM_USER and SPI_MEM_USER2 as they were afterwards (the functions of the ROM set the rest each time)
  align 4
pk_ident:
  entry a1, 32
  call8 core1_park                   ; SPI1 asks the flash (core 1 parked while the WiFi runs)
  call8 flash_ident
  mov   a2, a10
  call8 core1_free
  l32r  a6, lit_vars
  s32i  a2, a6, 76
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
  l32i  a3, a2, 0x18                 ; SPI_MEM_USER before
  l32i  a4, a2, 0x20                 ; SPI_MEM_USER2 before
  l32i  a7, a2, 0x08                 ; SPI_MEM_CTRL before
  l32r  a5, lit_spi_wp
  s32i  a5, a2, 0x08                 ; SPI_MEM_CTRL: WP_REG only (not the DIO mode of the reads)
  movi  a5, 23
  s32i  a5, a2, 0x28                 ; SPI_MEM_MISO_DLEN: 24 bits
  l32r  a5, lit_spi_user
  s32i  a5, a2, 0x18
  l32r  a5, lit_spi_rdid
  s32i  a5, a2, 0x20
  movi  a5, 0
  s32i  a5, a2, 0x58                 ; SPI_MEM_W0
  memw
  l32r  a6, lit_spi_go
  s32i  a6, a2, 0                    ; SPI_CMD: go
  memw
pi_wait:
  l32i  a5, a2, 0
  and   a5, a5, a6
  bnez  a5, pi_wait
  l32i  a5, a2, 0x58                 ; the id
  s32i  a3, a2, 0x18
  s32i  a4, a2, 0x20
  s32i  a7, a2, 0x08
  memw
  slli  a5, a5, 8                    ; the low 24 bits
  srli  a2, a5, 8
  retw

; S: without data the divider now; with a divider (4 bytes) k, then the new one (packet_mode checks the next packet)
  align 4
pk_speed:
  entry a1, 32
  l32r  a4, lit_vars
  l32r  a6, lit_divider              ; the divider "now" (the USB port has no rate)
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
  bne   a3, a5, dp_n
  call8 pk_ident
  j     dp_done
dp_n:
  movi  a5, 78                       ; 'N'
  bne   a3, a5, dp_r
  call8 pk_net
  j     dp_done
dp_r:
  movi  a5, 82                       ; 'R'
  bne   a3, a5, dp_e
  call8 pk_ram
  j     dp_done
dp_e:
  movi  a5, 69                       ; 'E'
  bne   a3, a5, dp_t
  call8 pk_exec
  j     dp_done
dp_t:
  movi  a5, 84                       ; 'T'
  bne   a3, a5, dp_a
  call8 pk_debug
  j     dp_done
dp_a:
  movi  a5, 65                       ; 'A'
  bne   a3, a5, dp_y
  call8 pk_area
  j     dp_done
dp_y:
  movi  a5, 89                       ; 'Y'
  bne   a3, a5, dp_k
  call8 pk_flash
  j     dp_done
dp_k:
  movi  a5, 75                       ; 'K'
  bne   a3, a5, dp_q3
  call8 pk_crc
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
  bltz  a10, pc_ok                   ; the room of the WiFi package (A): no entry
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
  bnez  a10, pg_err
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
pg_err:
  l32r  a10, lit_s_flasherr
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
  movi  a12, 0
  call8 run_file
  beqz  a10, px_done                 ; it ran and ended (rf_after said how)
  call8 send_err                     ; it did not start
px_done:
  retw

; R address bytes: the bytes (whole words, up to 1024) into the room of the programs (code or data) at the address
  align 4
pk_ram:
  entry a1, 32
  addi  a2, a2, -4                   ; the bytes
  blti  a2, 4, pr_size
  extui a3, a2, 0, 2
  bnez  a3, pr_size
  movi  a3, 1024
  bgeu  a3, a2, pr_sized
pr_size:
  l32r  a10, lit_e_size
  call8 send_err
  retw
pr_sized:
  l32r  a3, lit_pkt
  l32i  a4, a3, 4                    ; the address
  extui a5, a4, 0, 2
  bnez  a5, pr_where
  mov   a10, a4
  mov   a11, a2
  movi  a12, 0
  call8 segment_fits
  bnei  a10, 1, pr_where
  mov   a10, a4                      ; in the room of the WiFi: the WiFi stops first (it starts again after the program)
  mov   a11, a2
  call8 wifi_room
  beqz  a10, pr_fits
  call8 wlan_yield
  beqz  a10, pr_fits
  call8 send_err
  retw
pr_fits:
  addi  a3, a3, 8
  movi  a5, 0
pr_word:                             ; a word at a time (the IRAM takes words only)
  add   a6, a3, a5
  l32i  a6, a6, 0
  add   a7, a4, a5
  s32i  a6, a7, 0
  addi  a5, a5, 4
  bltu  a5, a2, pr_word
  memw
  call8 send_ok
  retw
pr_where:
  l32r  a10, lit_e_where
  call8 send_err
  retw

; E entry: k, then the program that R put into the RAM starts at its entry (no arguments; it ends as one of X)
  align 4
pk_exec:
  entry a1, 32
  movi  a3, 4
  beq   a2, a3, pe_len
  l32r  a10, lit_e_size
  call8 send_err
  retw
pe_len:
  l32r  a3, lit_pkt
  l32i  a2, a3, 4                    ; the entry
  mov   a10, a2
  movi  a11, 4
  movi  a12, 0
  call8 segment_fits
  beqi  a10, 1, pe_fits
  l32r  a10, lit_e_where
  call8 send_err
  retw
pe_fits:
  l32r  a5, lit_vars
  s32i  a2, a5, 48                   ; the entry
  movi  a3, 1
  s32i  a3, a5, 184                  ; started by a packet
  l32r  a4, lit_s_empty
  s32i  a4, a5, 180                  ; no arguments
  movi  a4, 0                        ; no file: its segments are in their place
  j     rf_k                         ; on in run_file (the same frame: entry a1, 32)

; T [entry [flags]]: k, then dbg_host as a program (as E), with the mark of a debug session (vars+188: rf_after stops
; there). flags bit 0: the program of the debugger takes the room of the WiFi (the large window): the WiFi stops
; first, and starts again when the program ends
  align 4
pk_debug:
  entry a1, 32
  movi  a3, 8
  bne   a2, a3, pt_go
  l32r  a3, lit_pkt
  l32i  a3, a3, 8
  bbci  a3, 0, pt_go
  call8 wlan_yield
  beqz  a10, pt_go
  call8 send_err
  retw
pt_go:
  l32r  a2, lit_dbghost
  l32r  a5, lit_vars
  movi  a3, 1
  s32i  a3, a5, 188
  j     pe_fits                      ; on as E (the same frame: entry a1, 32)

; the host of a program under the debugger (T): the console calls it as a program; the debugger halts at its first
; break (the USB JTAG), loads the program and starts it from here, as callx8 (the way back to dh_end in a8 with the
; bits of call8) or as call0 (a0 at dh_end0); the end stops at dh_end, then it returns to the console
  align 4
dbg_host:
  entry a1, 32
  rsil  a2, 5                         ; the program runs at the interrupt level 5, as under the debugger before
  l32r  a2, lit_vars
  s32i  a0, a2, 192
  s32i  a1, a2, 196
  memw
  break 1, 14                         ; the first stop
dh_end:                               ; retw of a program with entry: its a2 is a10 here
  break 1, 14
  mov   a2, a10
  retw                                ; back to the console: "Program ended (code n)"
dh_end0:                              ; ret of a program of call0: its a2 is a2, a0 and a1 are its own
  l32r  a3, lit_vars
  l32i  a0, a3, 192
  l32i  a1, a3, 196
  mov   a10, a2
  j     dh_end

; A address length crc: a part of the room of the WiFi package opens for writing as a file of O, its sectors erased;
; W and C as for a file (vars+40 -1: C puts nothing into the directory)
  align 4
pk_area:
  entry a1, 32
  movi  a3, 12
  beq   a2, a3, pa_len
  l32r  a10, lit_e_size
  call8 send_err
  retw
pa_len:
  call8 svc_runs
  beqz  a10, pa_still
  call8 wlan_halt                    ; the WiFi off first (version 8: wifi_halt; it starts again at the next start
  call8 svc_runs                     ; of the console or with wlan on)
  beqz  a10, pa_still
  l32r  a10, lit_e_wifiruns          ; an older service: still running
  call8 send_err
  retw
pa_still:
  l32r  a2, lit_pkt
  l32i  a3, a2, 4                    ; the address
  l32i  a4, a2, 8                    ; the length
  extui a5, a3, 0, 12
  bnez  a5, pa_where                 ; a whole sector
  l32r  a5, lit_wifi_lo
  bltu  a3, a5, pa_where
  l32r  a5, lit_wifi_hi
  bltu  a5, a3, pa_where
  sub   a6, a5, a3                   ; the room from the address on
  bltu  a6, a4, pa_where
  movi  a6, 1
  slli  a6, a6, 12
  addi  a6, a6, -1
  add   a6, a4, a6
  srli  a6, a6, 12                   ; the sectors
  srli  a7, a3, 12                   ; the first one
  movi  a5, 0
pa_erase:
  beq   a5, a6, pa_state
  add   a10, a7, a5
  call8 fl_erase
  bnez  a10, pa_err
  addi  a5, a5, 1
  j     pa_erase
pa_state:
  l32r  a5, lit_vars
  movi  a6, 1
  s32i  a6, a5, 20                   ; open
  s32i  a7, a5, 24                   ; the first sector
  s32i  a4, a5, 28                   ; the length
  l32i  a6, a2, 12
  s32i  a6, a5, 32                   ; the CRC-32
  movi  a6, 0
  s32i  a6, a5, 36                   ; written so far
  movi  a6, -1
  s32i  a6, a5, 40                   ; no entry: the room of the WiFi package
  s32i  a6, a5, 44                   ; the offset of the last piece
  call8 send_ok
  retw
pa_where:
  l32r  a10, lit_e_area
  call8 send_err
  retw
pa_err:
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw

; K address count: the CRC-32 of count bytes of the flash at address (a multiple of 4, the bytes below 4 MB), read
; in pieces of 1024 bytes into OUT (Asmonite: is the console in the flash its own? M4)
  align 4
pk_crc:
  entry a1, 32
  movi  a3, 8
  beq   a2, a3, kc_len
  l32r  a10, lit_e_size
  call8 send_err
  retw
kc_len:
  l32r  a2, lit_pkt
  l32i  a3, a2, 4                    ; the address
  l32i  a4, a2, 8                    ; the count
  extui a5, a3, 0, 2
  bnez  a5, kc_where
  l32r  a5, lit_4m
  bltu  a5, a3, kc_where
  sub   a6, a5, a3
  bltu  a6, a4, kc_where
  movi  a7, 0                        ; the CRC so far
kc_piece:
  beqz  a4, kc_send
  movi  a5, 1024
  bgeu  a4, a5, kc_read
  mov   a5, a4
kc_read:
  mov   a10, a3
  l32r  a11, lit_out
  addi  a11, a11, 4
  addi  a12, a5, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  call8 fl_read
  bnez  a10, kc_err
  mov   a10, a7
  l32r  a11, lit_out
  addi  a11, a11, 4
  mov   a12, a5
  call8 crc32
  mov   a7, a10
  add   a3, a3, a5
  sub   a4, a4, a5
  j     kc_piece
kc_send:
  l32r  a11, lit_out
  addi  a11, a11, 4
  s32i  a7, a11, 0
  movi  a10, 107                     ; 'k'
  movi  a12, 4
  call8 send_packet
  retw
kc_where:
  l32r  a10, lit_e_area
  call8 send_err
  retw
kc_err:
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw

; Y address count: bytes of the flash in the room of the WiFi package (count up to 1024)
  align 4
pk_flash:
  entry a1, 32
  movi  a3, 8
  beq   a2, a3, py_len
  l32r  a10, lit_e_size
  call8 send_err
  retw
py_len:
  l32r  a2, lit_pkt
  l32i  a3, a2, 4                    ; the address
  l32i  a4, a2, 8                    ; the count
  extui a5, a3, 0, 2
  bnez  a5, py_where
  movi  a5, 1024
  bltu  a5, a4, py_where
  l32r  a5, lit_wifi_lo
  bltu  a3, a5, py_where
  l32r  a5, lit_wifi_hi
  bltu  a5, a3, py_where
  sub   a6, a5, a3
  bltu  a6, a4, py_where
  mov   a10, a3
  l32r  a11, lit_out
  addi  a11, a11, 4
  addi  a12, a4, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  beqz  a12, py_send
  call8 fl_read
  bnez  a10, py_err
py_send:
  movi  a10, 100                     ; 'd'
  l32r  a11, lit_out
  addi  a11, a11, 4
  mov   a12, a4
  call8 send_packet
  retw
py_where:
  l32r  a10, lit_e_area
  call8 send_err
  retw
py_err:
  l32r  a10, lit_s_flasherr
  call8 send_err
  retw

; 1 if the WiFi service runs on core 1 (core 1 has its clock, the service its mark "WSVC"), else 0
  align 4
svc_runs:
  entry a1, 32
  movi  a2, 0
  l32r  a3, lit_appclk
  l32i  a3, a3, 0
  extui a3, a3, 1, 1
  beqz  a3, sr_done
  l32r  a3, lit_svcmark
  l32i  a3, a3, 0
  l32r  a4, lit_svcmagic
  bne   a3, a4, sr_done
  movi  a2, 1
sr_done:
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
  movi  a12, 0
  call8 run_file
  beqz  a10, cr_end                  ; it ran and ended (rf_after said how)
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
  movi  a4, 0x13
  slli  a4, a4, 8
  s32i  a4, a3, 0                    ; GPIO 0: a GPIO, an input with its pull-up (0x1300)
  memw
  call8 ms_cycles
  movi  a4, 1500
  add   a4, a4, a4                   ; 3000 (movi takes up to 2047)
  mull  a3, a10, a4                  ; 3 seconds in cycles (the USB port comes back first)
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
  movi  a12, 0
  call8 run_file
  beqz  a10, as_end                  ; it ran and ended (rf_after said how)
  call8 print                        ; it did not start: why
  l32r  a10, lit_s_crlf
  call8 print
  retw
as_stay:
  l32r  a10, lit_s_stay
  call8 print
as_end:
  retw

; the program in the file a2 into its place, then its entry; a3 = 0: "Running name" before, 1: k before (packets),
; 2: a command (nothing before, and nothing after when it ends with the code 0); a4 the text of its arguments (args(),
; its a2; 0: none). Comes back only when it cannot start: the text that says why
  align 4
run_file:
  entry a1, 32
  l32r  a5, lit_vars
  s32i  a3, a5, 184                  ; how it started
  bnez  a4, rf_args
  l32r  a4, lit_s_empty
rf_args:
  s32i  a4, a5, 180                  ; its arguments
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
  beqi  a3, 2, rf_go                 ; a command: at once
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
  beqz  a4, rf_placed                ; E: R put it into its place
  mov   a10, a4
  movi  a11, 1
  call8 segments                     ; now into their place
rf_placed:
  call8 uart_drain
  ; the program gets a stack of its own (the top of its data) and the vectors of the console; the frames of the
  ; console go into its stack first, so that the program may take all the registers (spill)
  call8 spill
  l32r  a5, lit_vars
  s32i  a0, a5, 92                   ; the return of run_file and its sp: rf_after comes back here from any window
  s32i  a1, a5, 96
  rsr   a6, ps
  s32i  a6, a5, 100
  rsr   a6, vecbase
  s32i  a6, a5, 104
  rsr   a6, intenable
  s32i  a6, a5, 124
  movi  a6, 0
  s32i  a6, a5, 112
  s32i  a6, a5, 120
  s32i  a6, a5, 164                  ; no Ctrl+C yet
  s32i  a6, a5, 168                  ; the flash is not busy
  l32r  a6, lit_vectors
  wsr   a6, vecbase
  call8 key_on                       ; the USB port to the NMI: Ctrl+C stops the program
  rsr   a6, intenable
  l32r  a7, lit_nmibit
  or    a6, a6, a7
  wsr   a6, intenable
  l32i  a8, a5, 48                   ; the entry of the program
  l32r  a9, lit_pstack
  ; the base save area below its first sp: a0 and sp of a caller that is none; the handlers of the windows read
  ; that sp ([sp-12]) when they spill this frame and put its a4..a7 32 bytes below it, so it points 32 bytes above
  ; the stack (as the debug monitor does it)
  addi  a6, a9, -16
  movi  a7, 0
  s32i  a7, a6, 0
  addi  a7, a9, 32
  s32i  a7, a6, 4
  memw
  isync
  mov   a1, a9
  l32i  a10, a5, 180                 ; its a2: the text of its arguments
  callx8 a8                          ; as the boot ROM calls a program, now on the stack of the program
  mov   a2, a10                      ; it returned: its a2 is the code
  movi  a3, 0
  j     rf_after

; the program stopped by an exception (the vectors above): from the window it was in
rf_dexc:
  rsr   a2, ps                       ; after a double exception EXCM is still set
  movi  a3, -17
  and   a2, a2, a3
  wsr   a2, ps
  rsync
rf_exc:
  movi  a2, 0
  movi  a3, 3
  j     rf_longjmp
; the debugger ends the program (0x403C0830)
rf_dbg:
  movi  a2, 0
  movi  a3, 4
  j     rf_longjmp
; Ctrl+C (out of the NMI, or after a function of the ROM for the flash)
rf_key:
  movi  a2, 0
  movi  a3, 2
; a2 the code, a3 how it ended (1 exit, 2 Ctrl+C, 3 an exception, 4 the debugger): from any window of the program. Only this window stays;
; the frames of the console are in its stack (spill), the ones of the program are dropped
rf_longjmp:
  rsr   a4, windowbase
  movi  a5, 1
  ssl   a4
  sll   a5, a5
  wsr   a5, windowstart
  rsync
; back in the console: its sp, the return of run_file, ps, the vectors and interrupts as before; then what happened
rf_after:
  ; a debug session (T): an end through the console (exit, Ctrl+C, an exception) stops the debugger first, at the
  ; break rf_dbgbreak with a2 the code and a3 how; the mark is gone before it (never a second time)
  beqz  a3, ra_go
  beqi  a3, 4, ra_go
  l32r  a5, lit_vars
  l32i  a6, a5, 188
  beqz  a6, ra_go
  movi  a6, 0
  s32i  a6, a5, 188
  memw
rf_dbgbreak:
  break 1, 14
ra_go:
  l32r  a5, lit_vars
  l32i  a6, a5, 100
  wsr   a6, ps
  rsync
  l32i  a0, a5, 92
  l32i  a1, a5, 96
  l32i  a6, a5, 104
  wsr   a6, vecbase
  l32i  a6, a5, 124
  wsr   a6, intenable                ; the NMI off
  isync
  s32i  a3, a5, 108
  mov   a4, a2
  call8 key_off                      ; the USB port as before
  movi  a6, 0
  s32i  a6, a5, 164                  ; no Ctrl+C waits (fl_done)
  s32i  a6, a5, 168
  s32i  a6, a5, 188                  ; no debug session
  l32i  a6, a5, 0                    ; what the program did not read is not for the console
  s32i  a6, a5, 4
  call8 uart_drain
  movi  a6, 3
  beq   a3, a6, rf_stopped
  beqi  a3, 4, rf_dbgstop
  movi  a6, 2
  bne   a3, a6, rf_ended
  l32r  a10, lit_s_keystop           ; Program stopped (Ctrl+C).
  call8 print
  j     rf_back
rf_ended:
  l32i  a6, a5, 184
  bnei  a6, 2, rf_say
  bnez  a4, rf_say
  j     rf_back                      ; a command that ended well: nothing to say
rf_say:
  l32r  a10, lit_s_ended             ; Program ended (code n).
  call8 print
  mov   a10, a4
  call8 print_dec
  l32r  a10, lit_s_ended2
  call8 print
  j     rf_back
rf_dbgstop:                          ; Program stopped by the debugger.
  l32r  a10, lit_s_dbgstop
  call8 print
  j     rf_back
rf_stopped:                          ; Program stopped: exception n at pc 0x..., address 0x...
  l32r  a10, lit_s_stopped
  call8 print
  l32i  a10, a5, 112
  call8 print_hex
  l32r  a10, lit_s_at
  call8 print
  l32i  a10, a5, 116
  call8 print_hex
  l32r  a10, lit_s_addr
  call8 print
  l32i  a10, a5, 120
  call8 print_hex
  l32r  a10, lit_s_ended2
  addi  a10, a10, 1
  call8 print
rf_back:                             ; the WiFi again, when it stopped for this program (the large window)
  call8 wlan_back
  movi  a2, 0
  retw

; every frame of the callers into its stack: a chain of calls that takes all 64 registers (call8, then call12
; four times: 8 + 48 + the 16 of the last one), as the handlers of the windows do it when the program needs them
  align 4
spill:
  entry a1, 32
  call12 spill1
  retw
  align 4
spill1:
  entry a1, 48
  call12 spill2
  retw
  align 4
spill2:
  entry a1, 48
  call12 spill3
  retw
  align 4
spill3:
  entry a1, 48
  call12 spill4
  retw
  align 4
spill4:
  entry a1, 48
  retw

; while a program runs: a packet of the PC over the USB port raises SERIAL_OUT_RECV_PKT, the interrupt matrix leads
; it to the CPU interrupt 14, the NMI (nmi_key; rf_go switches it on in INTENABLE); the map before into vars+176,
; vars+140 = 1: rx_poll leaves the port to the NMI. What waits in the port already goes into the ring first (the
; interrupt comes only for a new packet)
  align 4
key_on:
  entry a1, 32
  call8 rx_poll
  l32r  a2, lit_usb
  l32r  a4, lit_vars
  movi  a3, 0
  memw
  s32i  a3, a2, 0x10                 ; USB_SERIAL_JTAG_INT_ENA: none
  movi  a3, -1
  s32i  a3, a2, 0x14                 ; USB_SERIAL_JTAG_INT_CLR
  l32r  a5, lit_intmap
  l32i  a6, a5, 0
  s32i  a6, a4, 176
  movi  a6, 14
  s32i  a6, a5, 0
  movi  a3, 1
  s32i  a3, a4, 140
  memw
  movi  a3, 4
  s32i  a3, a2, 0x10                 ; SERIAL_OUT_RECV_PKT
  memw
  retw

; the USB port as before key_on (the NMI is off already: INTENABLE as before the program)
  align 4
key_off:
  entry a1, 32
  l32r  a2, lit_usb
  l32r  a4, lit_vars
  movi  a3, 0
  memw
  s32i  a3, a2, 0x10
  movi  a3, -1
  s32i  a3, a2, 0x14
  l32r  a5, lit_intmap
  l32i  a6, a4, 176
  s32i  a6, a5, 0
  movi  a3, 0
  s32i  a3, a4, 140
  memw
  retw

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
  bbsi  a3, 1, sg_copy               ; load: its parts, the WiFi as it is
  l32r  a7, lit_vars                 ; a program in the room of the WiFi: the WiFi stops first
  l32i  a10, a7, 52
  l32i  a11, a7, 56
  call8 wifi_room
  beqz  a10, sg_copy
  call8 wlan_yield
  beqz  a10, sg_copy
  mov   a2, a10
  retw
sg_copy:
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

; 1 if the a3 bytes at a2 reach into the room of the WiFi (the service, wlan.rom and the heap of the WiFi, on either
; bus: the large window of a program, step 7 of the plan for the board, M3.3), else 0
  align 4
wifi_room:
  entry a1, 32
  add   a3, a3, a2                   ; behind it
  movi  a5, 1
  l32r  a6, lit_wroom_lo
  l32r  a7, lit_wroom_hi
  bgeu  a2, a7, wr_data
  bltu  a6, a3, wr_done
wr_data:
  l32r  a6, lit_wdroom_lo
  l32r  a7, lit_wdroom_hi
  bgeu  a2, a7, wr_no
  bltu  a6, a3, wr_done
wr_no:
  movi  a5, 0
wr_done:
  mov   a2, a5
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

; sends what is in the FIFO of the USB port and waits until the host has it (at most 10 ms)
  align 4
uart_drain:
  entry a1, 32
  l32r  a3, lit_vars
  l32r  a5, lit_10ms
  rsr   a6, ccount
ud_wait:
  call8 tx_flush
  l32i  a4, a3, 84
  beqz  a4, ud_done                  ; all of it went out
  rsr   a7, ccount
  sub   a7, a7, a6
  bltu  a7, a5, ud_wait
ud_done:
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

; the file a2 with the a4 bytes at a3 into the flash: into a new place first (piece by piece through CHUNK, each read
; back), only then the directory points to it; 0 done, -1 the directory is full, -2 not enough room in the flash, -3
; the flash cannot be written. The bytes may lie anywhere (the memory of a program: it is only read)
  align 4
store_file:
  entry a1, 48
  s32i  a3, a1, 0                    ; the bytes
  s32i  a4, a1, 4                    ; how many
  mov   a10, a2
  call8 find_entry
  mov   a5, a10                      ; its entry, or a free one
  bgez  a5, st_entry
  movi  a5, 0
st_free:
  mov   a10, a5
  call8 entry_at
  l8ui  a6, a10, 0
  beqz  a6, st_entry
  addi  a5, a5, 1
  movi  a6, 64
  bltu  a5, a6, st_free
  movi  a2, -1
  retw
st_entry:
  call8 build_used                   ; the old text of the file stays where it is until the directory is written
  movi  a6, 1
  slli  a6, a6, 12
  addi  a6, a6, -1
  add   a6, a4, a6
  srli  a6, a6, 12                   ; the sectors
  mov   a10, a6
  call8 find_space
  mov   a7, a10                      ; the first sector
  bgez  a7, st_room
  movi  a2, -2
  retw
st_room:
  movi  a4, 0
st_erase:
  beq   a4, a6, st_write
  add   a10, a7, a4
  call8 fl_erase
  bnez  a10, st_err
  addi  a4, a4, 1
  j     st_erase
st_write:
  l32i  a4, a1, 4                    ; the bytes still to write
  slli  a6, a7, 12                   ; where they go
st_piece:
  beqz  a4, st_dir
  movi  a10, 256                     ; a piece of at most 256 bytes into CHUNK, zeros up to a whole word
  bgeu  a4, a10, st_copy
  mov   a10, a4
st_copy:
  s32i  a10, a1, 8
  l32r  a11, lit_chunk
  srli  a12, a10, 2
  slli  a12, a12, 2
  add   a12, a11, a12
  movi  a13, 0
  s32i  a13, a12, 0
  movi  a12, 0
st_byte:
  add   a13, a3, a12
  l8ui  a13, a13, 0
  add   a14, a11, a12
  s8i   a13, a14, 0
  addi  a12, a12, 1
  bltu  a12, a10, st_byte
  addi  a12, a10, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  mov   a10, a6
  call8 fl_write
  bnez  a10, st_err
  l32i  a12, a1, 8
  addi  a12, a12, 3
  srli  a12, a12, 2
  slli  a12, a12, 2
  mov   a10, a6
  l32r  a11, lit_chunk
  call8 fl_verify
  beqz  a10, st_err
  l32i  a10, a1, 8
  add   a3, a3, a10
  add   a6, a6, a10
  sub   a4, a4, a10
  j     st_piece
st_dir:
  mov   a10, a5
  call8 entry_at
  mov   a4, a10
  s32i  a7, a4, 20                   ; the first sector
  l32i  a12, a1, 4
  s32i  a12, a4, 24                  ; the length
  movi  a10, 0
  l32i  a11, a1, 0
  call8 crc32
  s32i  a10, a4, 28
  movi  a6, 0                        ; the name, with zeros up to 20 bytes
  movi  a7, 0                        ; 1: its end is passed
st_name:
  add   a10, a2, a6
  l8ui  a10, a10, 0
  bnez  a10, st_char
  movi  a7, 1
st_char:
  beqz  a7, st_store
  movi  a10, 0
st_store:
  add   a11, a4, a6
  s8i   a10, a11, 0
  addi  a6, a6, 1
  movi  a10, 20
  bltu  a6, a10, st_name
  call8 dir_save
  beqz  a10, st_err
  movi  a2, 0
  retw
st_err:
  movi  a2, -3
  retw

; the file a2 with the a3 bytes of FILEBUF into the flash (put), and what happened; 1 if done
  align 4
save_file:
  entry a1, 32
  mov   a10, a2
  l32r  a11, lit_filebuf
  mov   a12, a3
  call8 store_file
  beqz  a10, sf_done
  l32r  a4, lit_s_flasherr
  movi  a5, -1
  bne   a10, a5, sf_room
  l32r  a4, lit_s_dirfull
sf_room:
  movi  a5, -2
  bne   a10, a5, sf_say
  l32r  a4, lit_s_full
sf_say:
  mov   a10, a4
  call8 print
  movi  a2, 0
  retw
sf_done:
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

; ---------- the WiFi network (wlan; step 8 of the plan for the board, M3.4) ----------
; Two sectors right below the WiFi package keep the network of the board, 0xFE000 and 0xFF000 (outside the file
; system and the room of packet A): each time the other one is written, with a number one higher, and the valid one
; with the higher number counts, as with the directory. A record of 128 bytes at the start of its sector: +0 "AWN1",
; +4 the number, +8 bit 0: an open network (no key), +12 the length of the name (1 .. 32), +16 the name (32 bytes),
; +48 the key (32 bytes: PBKDF2-SHA1 of the password and the name, the PMK of WPA2; not the password), +124 the
; CRC-32 of the bytes before it. Whoever reads the flash learns the key of this one network, not the password.

; wlan [set | clear]: a2 the rest of the line
  align 4
cmd_wlan:
  entry a1, 32
  l8ui  a3, a2, 0
  beqz  a3, wn_show
  mov   a10, a2
  l32r  a11, lit_c_set
  call8 streq
  bnez  a10, wn_set
  mov   a10, a2
  l32r  a11, lit_c_clear
  call8 streq
  bnez  a10, wn_clear
  mov   a10, a2
  l32r  a11, lit_c_on
  call8 streq
  bnez  a10, wn_on
  mov   a10, a2
  l32r  a11, lit_c_off
  call8 streq
  bnez  a10, wn_off
  l32r  a10, lit_s_wnuse
  call8 print
  retw
wn_on:
  movi  a10, 0
  call8 wlan_switch
  retw
wn_off:
  movi  a10, 1
  call8 wlan_switch
  retw
wn_set:
  call8 wlan_set
  retw
wn_clear:
  call8 wlan_clear
  retw
wn_show:
  call8 wlan_show
  retw

; wlan: the network (its name, open or WPA2) and the state of the WiFi
  align 4
wlan_show:
  entry a1, 32
  call8 cred_net 
  bnez  a10, ws_net
  l32r  a10, lit_s_wnnone
  call8 print
  j     ws_state
ws_net:
  l32r  a10, lit_s_wnnet
  call8 print
  l32r  a2, lit_credbuf
  addi  a10, a2, 16
  l32i  a11, a2, 12
  call8 print_n
  l32i  a3, a2, 8
  extui a3, a3, 0, 1
  l32r  a10, lit_s_wnwpa
  beqz  a3, ws_kind
  l32r  a10, lit_s_wnopen
ws_kind:
  call8 print
  l32r  a2, lit_credbuf               ; wlan off?
  l32i  a2, a2, 8
  bbci  a2, 1, ws_state
  l32r  a2, lit_s_wnisoff
  j     ws_say
ws_state:
  call8 svc_runs
  l32r  a2, lit_s_wnoff
  beqz  a10, ws_say
  l32r  a8, lit_svcstat              ; wifi_status: its words, on this core
  callx8 a8
  l32r  a2, lit_s_wnconn
  bbsi  a10, 0, ws_say               ; connected
  l32r  a2, lit_s_wnconnecting
  bbsi  a10, 24, ws_say              ; the service connects in the background
  l32r  a2, lit_s_wnnot
ws_say:
  mov   a10, a2
  call8 print
  retw

; wlan set: the name of a network and its password (without echo; Ctrl+C: nothing changes). The console keeps the
; name and the key (wifi_pmk of the WiFi service: PBKDF2-SHA1, as WPA2 makes it), not the password: LINE and the
; bytes of the ring that held it are cleared at once. An empty password: an open network
  align 4
wlan_set:
  entry a1, 32
  call8 cred_load                    ; the number and the sector for the next record; bit 1 (wlan off) kept
  l32r  a2, lit_vars
  movi  a3, 0
  beqz  a10, wt_flags
  l32r  a3, lit_credbuf
  l32i  a3, a3, 8
  movi  a4, 2
  and   a3, a3, a4
wt_flags:
  s32i  a3, a2, 216
  l32r  a10, lit_s_wnask1
  call8 print
  l32r  a10, lit_chunk
  movi  a11, 32
  call8 read_line
  bltz  a10, wt_done                 ; Ctrl+C
  mov   a2, a10                      ; the length of the name
  beqz  a2, wt_none
  l32r  a10, lit_s_wnask2
  call8 print
  l32r  a3, lit_vars
  l32i  a4, a3, 4                    ; the ring: where the password starts
  movi  a5, 1
  s32i  a5, a3, 212                  ; read_line without echo
  l32r  a10, lit_line
  movi  a11, 64
  call8 read_line
  movi  a5, 0
  s32i  a5, a3, 212
  bltz  a10, wt_forget
  mov   a5, a10                      ; the length of the password
  l32r  a6, lit_credbuf              ; the record: zeros (the name of the board at +80 stays), the length and the name
  movi  a7, 0
  movi  a8, 0
wt_zero:
  add   a9, a6, a7
  s32i  a8, a9, 0
  addi  a7, a7, 4
  movi  a9, 80
  bne   a7, a9, wt_zero
  l32r  a9, lit_vars                 ; no record before: no name either
  l32i  a9, a9, 204
  bnez  a9, wt_named
wt_zero2:
  add   a9, a6, a7
  s32i  a8, a9, 0
  addi  a7, a7, 4
  movi  a9, 128
  bne   a7, a9, wt_zero2
wt_named:
  s32i  a2, a6, 12
  l32r  a8, lit_chunk
  movi  a7, 0
wt_name:
  add   a9, a8, a7
  l8ui  a9, a9, 0
  add   a10, a6, a7
  s8i   a9, a10, 16
  addi  a7, a7, 1
  bne   a7, a2, wt_name
  bnez  a5, wt_key
  movi  a7, 1                        ; an open network
  s32i  a7, a6, 8
  j     wt_save
wt_key:
  call8 svc_ready
  bnez  a10, wt_problem
  l32r  a10, lit_s_wnkey
  call8 print
  l32r  a10, lit_line
  l32r  a11, lit_chunk
  mov   a12, a2
  addi  a13, a6, 48
  l32r  a8, lit_svcpmk
  callx8 a8
  mov   a7, a10
  mov   a10, a4
  call8 forget
  beqz  a7, wt_save
  l32r  a10, lit_s_wnbadpw
  call8 print
  retw
wt_save:
  l32r  a6, lit_vars                 ; wlan off stays off (the record before: vars+216)
  l32i  a6, a6, 216
  l32r  a7, lit_credbuf
  l32i  a8, a7, 8
  or    a8, a8, a6
  s32i  a8, a7, 8
  call8 cred_save
  bnez  a10, wt_err
  l32r  a10, lit_s_wnsaved
  call8 print
  l32r  a10, lit_chunk
  call8 print
  l32r  a10, lit_s_wnsaved2
  call8 print
  l32r  a7, lit_credbuf              ; the WiFi on the new network at once (not with wlan off)
  l32i  a8, a7, 8
  bbsi  a8, 1, wt_done
  call8 wlan_start
  retw
wt_err:
  l32r  a10, lit_s_flasherr
  call8 print
  retw
wt_none:
  l32r  a10, lit_s_notformatted
  call8 print
  retw
wt_problem:
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
wt_forget:
  mov   a10, a4
  call8 forget
wt_done:
  retw

; the password gone from the RAM: LINE (256 bytes) and the bytes of the ring from a2 up to the next byte to read
  align 4
forget:
  entry a1, 32
  l32r  a3, lit_line
  movi  a4, 0
  movi  a5, 0
fg_line:
  add   a6, a3, a4
  s32i  a5, a6, 0
  addi  a4, a4, 4
  movi  a6, 256
  bne   a4, a6, fg_line
  l32r  a3, lit_ring
  l32r  a4, lit_vars
fg_ring:
  l32i  a6, a4, 4
  beq   a2, a6, fg_done
  add   a6, a3, a2
  s8i   a5, a6, 0
  addi  a2, a2, 1
  extui a2, a2, 0, 12
  j     fg_ring
fg_done:
  memw
  retw

; at the start of the console: the WiFi in the background when the board keeps a network and wlan off did not switch
; it off (bit 1 of the record)
  align 4
wlan_boot:
  entry a1, 32
  call8 cred_net 
  beqz  a10, wb_done
  l32r  a2, lit_credbuf
  l32i  a2, a2, 8
  bbsi  a2, 1, wb_done
  call8 wlan_start
wb_done:
  retw

; the WiFi on with the network of CRED: the service out of the WiFi package if it does not run (svc_ready), then
; wifi_keep: core 1 connects in the background, again after a loss; says so, or why not
  align 4
wlan_start:
  entry a1, 32
  l32r  a2, lit_vars
  movi  a3, 0
  s32i  a3, a2, 220                  ; (not stopped for a program any more)
  call8 glitch_off
  call8 svc_ready
  bnez  a10, wst_problem
  l32r  a10, lit_credbuf
  l32r  a8, lit_svckeep
  callx8 a8
  l32r  a10, lit_s_wnbg1             ; "WiFi: connecting to NAME in the background."
  call8 print
  l32r  a2, lit_credbuf
  addi  a10, a2, 16
  l32i  a11, a2, 12
  call8 print_n
  l32r  a10, lit_s_wnbg2
  call8 print
  retw
wst_problem:
  mov   a2, a10
  l32r  a10, lit_s_wnwifi
  call8 print
  mov   a10, a2
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw

; the WiFi off (wifi_halt: stopped, core 1 stalled; nothing when the service does not run): the RAM and the power
; free
  align 4
wlan_halt:
  entry a1, 32
  call8 svc_runs
  beqz  a10, wh_done
  l32r  a3, lit_svchead
  l32i  a3, a3, 32
  movi  a4, 8
  bltu  a3, a4, wh_done
  l32r  a8, lit_svchalt
  callx8 a8
wh_done:
  retw

; a program that takes the room of the WiFi (the large window, step 7 of the plan for the board, M3.3): when the
; service runs, the WiFi off (wlan_halt) and vars+220 = 1, so that it starts again when the program ends (wlan_back);
; 0, or the text of the problem (an older service that does not stop)
  align 4
wlan_yield:
  entry a1, 32
  movi  a2, 0
  call8 svc_runs
  beqz  a10, wy_done
  call8 wlan_halt
  l32r  a3, lit_vars
  movi  a4, 1
  s32i  a4, a3, 220
  call8 svc_runs
  beqz  a10, wy_done
  l32r  a2, lit_e_wifiruns
wy_done:
  retw

; after a program: when the WiFi stopped for it (wlan_yield), the WiFi again as at the start of the console (a network
; kept, not wlan off)
  align 4
wlan_back:
  entry a1, 32
  l32r  a2, lit_vars
  l32i  a3, a2, 220
  beqz  a3, wbk_done
  movi  a3, 0
  s32i  a3, a2, 220
  call8 wlan_boot
wbk_done:
  retw

; wlan on (a2 = 0) / wlan off (a2 = 1): bit 1 of the record (kept over resets), then the WiFi on or off
  align 4
wlan_switch:
  entry a1, 32
  call8 cred_net 
  bnez  a10, wsw_net
  l32r  a10, lit_s_wnnone
  call8 print
  retw
wsw_net:
  l32r  a3, lit_credbuf
  l32i  a4, a3, 8
  movi  a5, -3
  and   a4, a4, a5
  slli  a5, a2, 1
  or    a5, a4, a5
  l32i  a4, a3, 8
  beq   a4, a5, wsw_go                ; as it is: nothing to write
  s32i  a5, a3, 8
  call8 cred_save
  beqz  a10, wsw_go
  l32r  a10, lit_s_flasherr
  call8 print
  retw
wsw_go:
  bnez  a2, wsw_off
  call8 wlan_start
  retw
wsw_off:
  call8 wlan_halt
  l32r  a10, lit_s_wnoffnow
  call8 print
  retw

; wlan clear: both sectors erased, the board knows no network
  align 4
wlan_clear:
  entry a1, 32
  call8 cred_clear_net               ; a name kept: the record without its network
  movi  a3, 0
  bnez  a10, wc_halt
  l32r  a2, lit_cred
  srli  a10, a2, 12
  call8 fl_erase
  mov   a3, a10
  srli  a10, a2, 12
  addi  a10, a10, 1
  call8 fl_erase
  or    a3, a3, a10
  l32r  a4, lit_vars
  movi  a5, 0
  s32i  a5, a4, 204
  s32i  a2, a4, 208
wc_halt:
  call8 wlan_halt                    ; no network: the WiFi off
  l32r  a10, lit_s_wncleared
  beqz  a3, wc_say
  l32r  a10, lit_s_flasherr
wc_say:
  call8 print
  retw

; the record of the network into CRED: 1, or 0 when neither sector holds a valid one. vars+204 its number (0: none),
; vars+208 the sector for the next record (the other one)
  align 4
cred_load:
  entry a1, 32
  l32r  a2, lit_vars
  movi  a3, 0
  s32i  a3, a2, 204
  l32r  a4, lit_cred
  s32i  a4, a2, 208
  movi  a5, 0                        ; the sector: 0, 1
cd_next:
  l32r  a4, lit_cred
  slli  a6, a5, 12
  add   a4, a4, a6
  mov   a10, a4
  l32r  a11, lit_credrd
  movi  a12, 128
  call8 fl_read
  bnez  a10, cd_skip
  l32r  a3, lit_credrd
  l32i  a6, a3, 0
  l32r  a7, lit_credmagic
  bne   a6, a7, cd_skip
  movi  a10, 0
  mov   a11, a3
  movi  a12, 124
  call8 crc32
  l32i  a6, a3, 124
  bne   a10, a6, cd_skip
  l32i  a6, a3, 4
  l32i  a7, a2, 204
  bgeu  a7, a6, cd_skip              ; not newer
  s32i  a6, a2, 204
  movi  a7, 1
  slli  a7, a7, 12
  xor   a7, a4, a7                   ; the other sector
  s32i  a7, a2, 208
  l32r  a7, lit_credbuf
  movi  a8, 0
cd_copy:
  add   a9, a3, a8
  l32i  a9, a9, 0
  add   a10, a7, a8
  s32i  a9, a10, 0
  addi  a8, a8, 4
  movi  a9, 128
  bne   a8, a9, cd_copy
cd_skip:
  addi  a5, a5, 1
  movi  a6, 2
  bne   a5, a6, cd_next
  l32i  a3, a2, 204
  movi  a2, 0
  beqz  a3, cd_done
  movi  a2, 1
cd_done:
  retw

; the record in CRED (+8 .. +123 filled) into the sector of vars+208, with "AWN1", the next number and its CRC-32; 0,
; or 1 when the flash failed
  align 4
cred_save:
  entry a1, 32
  l32r  a2, lit_vars
  l32r  a3, lit_credbuf
  l32r  a4, lit_credmagic
  s32i  a4, a3, 0
  l32i  a4, a2, 204
  addi  a4, a4, 1
  s32i  a4, a3, 4
  movi  a10, 0
  mov   a11, a3
  movi  a12, 124
  call8 crc32
  s32i  a10, a3, 124
  l32i  a5, a2, 208
  srli  a10, a5, 12
  call8 fl_erase
  bnez  a10, cs_bad
  mov   a10, a5
  mov   a11, a3
  movi  a12, 128
  call8 fl_write
  bnez  a10, cs_bad
  mov   a10, a5
  mov   a11, a3
  movi  a12, 128
  call8 fl_verify
  beqz  a10, cs_bad
  l32i  a4, a3, 4
  s32i  a4, a2, 204
  movi  a6, 1
  slli  a6, a6, 12
  xor   a5, a5, a6
  s32i  a5, a2, 208
  movi  a2, 0
  retw
cs_bad:
  movi  a2, 1
  retw

; the WiFi service in the RAM for wifi_pmk on this core: when it does not run on core 1, its parts for the RAM out of
; the WiFi package (as inc/wifi.abel loads them: the head at 0x1F0000 checked, each part by its CRC-32, then its
; segments as load puts them); 0, or the text of the problem. The frame: +0 the head (56 bytes), +56 an entry of
; the directory for segments (the sector of the part at +20, its length at +24)
  align 4
svc_ready:
  entry a1, 128
  call8 svc_runs
  bnez  a10, sv_version
  l32r  a10, lit_wifihead
  mov   a11, a1
  movi  a12, 56
  call8 fl_read
  bnez  a10, sv_none
  l32i  a3, a1, 0
  l32r  a4, lit_wifimagic
  bne   a3, a4, sv_none
  l32i  a3, a1, 4
  movi  a4, 9                       ; the chip
  bne   a3, a4, sv_none
  l32i  a3, a1, 12
  movi  a4, 3
  bne   a3, a4, sv_none
  movi  a10, 0
  mov   a11, a1
  movi  a12, 52
  call8 crc32
  l32i  a3, a1, 52
  bne   a10, a3, sv_none
  addi  a2, a1, 28                   ; the parts 1 and 2: their address, length and CRC-32
  movi  a5, 2
sv_part:
  l32i  a10, a2, 0
  srli  a10, a10, 12
  l32i  a11, a2, 4
  call8 file_crc
  l32i  a3, a2, 8
  bne   a10, a3, sv_none
  l32i  a3, a2, 0
  srli  a3, a3, 12
  s32i  a3, a1, 76
  l32i  a3, a2, 4
  s32i  a3, a1, 80
  addi  a10, a1, 56
  movi  a11, 3
  call8 segments
  bnez  a10, sv_none
  addi  a2, a2, 12
  addi  a5, a5, -1
  bnez  a5, sv_part
sv_version:
  l32r  a3, lit_svchead
  l32i  a3, a3, 32
  movi  a4, 8
  l32r  a2, lit_e_wifiold
  bltu  a3, a4, sv_done
  movi  a2, 0
sv_done:
  retw
sv_none:
  l32r  a2, lit_e_nowifi
  retw

; the a3 bytes of the text at a2 to the terminal
  align 4
print_n:
  entry a1, 32
pq_next:
  beqz  a3, pq_done
  l8ui  a10, a2, 0
  call8 put_char
  addi  a2, a2, 1
  addi  a3, a3, -1
  j     pq_next
pq_done:
  retw

; The WiFi data of the ROM of the S3 (0x3FCEF81C .. 0x3FCEF9A3: phy_param_rom .. privacy_en, the variables of the
; parts of the WiFi in the ROM: pp_task_hdl, s_pp_task_create_sem, s_wifi_queue, g_wifi_global_lock ...) as the ROM
; set them up, into ROMSNAP at each start, before any WiFi runs: the WiFi service puts them back before it starts the
; WiFi anew after wifi_halt (wlan\wlansvc.asm, svc_core1); else they point to the task and the locks of the WiFi before
; (pp_create_task waited for ever, tested 2026-11-11)
  align 4
rom_snapshot:
  entry a1, 32
  l32r  a2, lit_romwifi
  l32r  a3, lit_romsnap
  l32r  a4, lit_snapmagic
  s32i  a4, a3, 0
  movi  a5, 0
rs_word:
  add   a6, a2, a5
  l32i  a6, a6, 0
  add   a7, a3, a5
  s32i  a6, a7, 4
  addi  a5, a5, 4
  movi  a6, 392
  bne   a5, a6, rs_word
  memw
  retw

; ---------- the flash (the functions of the ROM; 0 = done) ----------

; the flash attached to the SPI pins of the eFuses (as at the start from the flash); its size from its JEDEC id (4 to
; 16 MB, else 4 MB as before): the ROM knows it (rom_spiflash_legacy_data, at least that size), and the file system reaches to
; its end (the sectors of the files in vars+80)
  align 4
flash_init:
  entry a1, 32
  l32r  a2, lit_chip
  l32i  a2, a2, 0                    ; the data of the flash of the ROM
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
  l32i  a2, a2, 0
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

; While a function of the ROM works on the flash, vars+168 = 1: Ctrl+C (nmi_key) waits for its end, then the program
; stops here (a command of the flash cut off in the middle could leave the flash in a state the ROM does not expect).
; And while the WiFi service runs on core 1, core 1 is parked (core1_park): its cache must not fetch from the flash
; while SPI1 works on it. When core 1 does not park, the function is not done: 1 (a failure of the flash)

; a4 bytes (whole words) from the flash at a2 to a3
  align 4
fl_read:
  entry a1, 32
  l32r  a5, lit_vars
  movi  a6, 1
  s32i  a6, a5, 168
  call8 core1_park
  bnez  a10, fl_nopark
  mov   a10, a2
  mov   a11, a3
  mov   a12, a4
  l32r  a8, lit_read
  callx8 a8
  mov   a2, a10
  j     fl_done

; a4 bytes (whole words) from a3 into the flash at a2 (erased before)
  align 4
fl_write:
  entry a1, 32
  l32r  a5, lit_vars
  movi  a6, 1
  s32i  a6, a5, 168
  call8 core1_park
  bnez  a10, fl_nopark
  mov   a10, a2
  mov   a11, a3
  mov   a12, a4
  l32r  a8, lit_write
  callx8 a8
  mov   a2, a10
  j     fl_done

; erases sector a2 (4 KB)
  align 4
fl_erase:
  entry a1, 32
  l32r  a5, lit_vars
  movi  a6, 1
  s32i  a6, a5, 168
  call8 core1_park
  bnez  a10, fl_nopark
  mov   a10, a2
  l32r  a8, lit_erase
  callx8 a8
  mov   a2, a10
  j     fl_done
fl_nopark:
  movi  a2, 1
fl_done:                             ; a5 vars: the flash is free; a Ctrl+C that came meanwhile stops the program now
  call8 core1_free
  movi  a6, 0
  s32i  a6, a5, 168
  memw
  l32i  a6, a5, 164
  bnez  a6, fl_key
  retw
fl_key:
  j     rf_key

; core 1 parked before the console uses the flash (step 6 of the plan for the board, M3.2): when the WiFi service runs
; on core 1 (version 6 or later), a request in its svc_pblock (+0, counted up) and its bell FROM_CPU_INTR3; then wait
; until core 1 says it is parked for it (+4: svc_park of wlan\wlansvc.asm), at most 200 ms. vars+200 the block (0:
; nothing parked). 0, or 1 when core 1 did not park (the request is over then: +8, so a late park ends at once)
  align 4
core1_park:
  entry a1, 32
  movi  a2, 0
  l32r  a3, lit_vars
  s32i  a2, a3, 200
  call8 svc_runs
  beqz  a10, cp_done
  l32r  a4, lit_svchead
  l32i  a5, a4, 32                   ; the version of the service
  movi  a6, 6
  bltu  a5, a6, cp_done
  l32i  a5, a4, 68                   ; svc_pblock
  memw
  l32i  a6, a5, 0
  addi  a6, a6, 1
  s32i  a6, a5, 0                    ; the request
  memw
  l32r  a7, lit_fromcpu
  movi  a8, 1
  s32i  a8, a7, 0                    ; the bell
  memw
  call8 ms_cycles
  movi  a9, 200
  mull  a9, a9, a10                  ; the cycles of 200 ms
  rsr   a8, ccount
cp_wait:
  memw
  l32i  a7, a5, 4
  beq   a7, a6, cp_parked
  rsr   a7, ccount
  sub   a7, a7, a8
  bltu  a7, a9, cp_wait
  l32r  a7, lit_fromcpu
  movi  a8, 0
  s32i  a8, a7, 0                    ; the bell off
  s32i  a6, a5, 8                    ; the request is over
  memw
  movi  a2, 1
  retw
cp_parked:
  s32i  a5, a3, 200
cp_done:
  retw

; core 1 goes on (after core1_park)
  align 4
core1_free:
  entry a1, 32
  l32r  a3, lit_vars
  l32i  a5, a3, 200
  beqz  a5, cf_done
  l32i  a6, a5, 0
  s32i  a6, a5, 8                    ; the request is over
  memw
  movi  a6, 0
  s32i  a6, a3, 200
cf_done:
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

; ---------- the USB port ----------

; what came from the host into the ring; what waits in the FIFO to the host goes out (a byte is awaited now). A full
; ring leaves the bytes in the USB port: the port makes the PC wait (the PC sends faster than the console echoes:
; with UART0 the rate of the line kept both equal)
  align 4
rx_poll:
  entry a1, 32
  call8 tx_flush
  l32r  a2, lit_usb
  l32r  a4, lit_vars
  l32r  a7, lit_ring
  l32i  a5, a4, 140
  bnez  a5, rp_done                  ; a program runs: the NMI takes the bytes (nmi_key)
rp_next:
  l32i  a6, a4, 0                    ; where the next byte goes
  addi  a9, a6, 1
  extui a9, a9, 0, 12
  l32i  a8, a4, 4
  beq   a9, a8, rp_done              ; the ring is full: the byte stays in the USB port
  memw                               ; each access to the USB port in its order (as ESP-IDF: -mserialize-volatile)
  l32i  a5, a2, 4
  bbci  a5, 2, rp_done               ; SERIAL_OUT_EP_DATA_AVAIL
  memw
  l32i  a5, a2, 0                    ; a byte (EP1)
  memw
  add   a8, a7, a6
  s8i   a5, a8, 0
  s32i  a9, a4, 0
  j     rp_next
rp_done:
  retw

; what is in the FIFO to the host goes out (WR_DONE), if anything was written since the last time. A full FIFO (64
; bytes) the USB port sends by itself, but the PC takes a packet of 64 bytes for one that goes on: WR_DONE once the
; FIFO has room again ends it (a packet of 0 bytes; ESP-IDF usb_serial_jtag_ll.h, txfifo_flush). While the PC has
; not taken the packet before (no room), a WR_DONE is lost: it is done later (the mark stays)
  align 4
tx_flush:
  entry a1, 32
  l32r  a4, lit_vars
  l32i  a5, a4, 84
  beqz  a5, tf_done
  l32r  a3, lit_usb
  memw
  l32i  a6, a3, 4
  bbci  a6, 1, tf_done               ; SERIAL_IN_EP_DATA_FREE: not yet (the mark stays)
  movi  a5, 0
  s32i  a5, a4, 84
  movi  a5, 1
  memw
  s32i  a5, a3, 4                    ; EP1_CONF: WR_DONE
  memw
tf_done:
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
  l32i  a7, a4, 224
  beqz  a7, gc_wait
  call8 net_tick                     ; at the prompt: the address of the board (DHCP)
  j     gc_wait
gc_got:
  l32r  a7, lit_ring
  add   a7, a7, a6
  l8ui  a2, a7, 0                    ; the ring is in the RAM of the data: bytes work there
  addi  a6, a6, 1
  extui a6, a6, 0, 12
  s32i  a6, a4, 4
  retw

; one byte a2 to the host: into the FIFO (it waits up to 10 ms for room; no program on the PC that reads: dropped, and
; the next bytes at once while there is no room: the console goes on at its speed, the PC gets what it reads);
; a full FIFO goes out by itself, the rest when the console waits for a byte (tx_flush)
  align 4
put_char:
  entry a1, 32
  l32r  a3, lit_usb
  l32r  a5, lit_10ms
  l32r  a8, lit_vars
  rsr   a6, ccount
pc_wait:
  memw
  l32i  a4, a3, 4
  bbsi  a4, 1, pc_room               ; SERIAL_IN_EP_DATA_FREE
  l32i  a7, a8, 88
  bnez  a7, pc_drop                  ; the bytes before found no room either: no wait
  call8 rx_poll                      ; sends what waits, takes what came
  rsr   a7, ccount
  sub   a7, a7, a6
  bltu  a7, a5, pc_wait
  movi  a7, 1
  s32i  a7, a8, 88                   ; nobody reads: dropped, and the next ones at once until there is room
pc_drop:
  retw
pc_room:
  movi  a7, 0
  s32i  a7, a8, 88
  memw
  s32i  a2, a3, 0                    ; EP1: the byte into the FIFO
  memw
  l32r  a4, lit_vars
  movi  a5, 1
  s32i  a5, a4, 84                   ; something to send (tx_flush; a full FIFO goes out by itself)
  retw

; a line into a2 (at most a3 characters and a 0), with echo; its length, -1 for Ctrl+C. The line has its 0 behind it
; all the time: net_say shows it again after a message
  align 4
read_line:
  entry a1, 32
  movi  a4, 0                        ; the length
rl_zero:
  add   a8, a2, a4
  movi  a6, 0
  s8i   a6, a8, 0
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
  l32r  a8, lit_vars                 ; a program started by a packet (F9) ran: the prompt again after its end
  l32i  a9, a8, 184
  bnei  a9, 1, rl_pkdone
  movi  a9, 0
  s32i  a9, a8, 184
  l32r  a10, lit_s_prompt
  call8 print
rl_pkdone:
  movi  a4, 0
  j     rl_zero
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
  movi  a6, 0
  s8i   a6, a8, 1
  addi  a4, a4, 1
  l32i  a8, a7, 212                  ; wlan set: the password without echo
  bnez  a8, rl_next
  mov   a10, a5
  call8 put_char
  j     rl_next
rl_back:
  beqz  a4, rl_next
  addi  a4, a4, -1
  add   a8, a2, a4
  movi  a6, 0
  s8i   a6, a8, 0
  l32i  a8, a7, 212
  bnez  a8, rl_next
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

; the text at a2 (up to its 0) to the USB port
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

; a2 as 8 hex digits
  align 4
print_hex:
  entry a1, 32
  l32r  a3, lit_digits
  movi  a4, 8
ph_next:
  extui a5, a2, 28, 4
  slli  a2, a2, 4
  movi  a6, 10
  bltu  a5, a6, ph_digit
  addi  a5, a5, 7
ph_digit:
  addi  a5, a5, 48
  s8i   a5, a3, 0
  addi  a3, a3, 1
  addi  a4, a4, -1
  bnez  a4, ph_next
  movi  a5, 0
  s8i   a5, a3, 0
  l32r  a10, lit_digits
  call8 print
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

; the watchdogs off: unlocked, WDTCONFIG0 = 0, locked again; the super watchdog feeds itself (see
; examples\esp32s3\rgb_ws2812_flash.asm). The core at 40 MHz (from the flash the boot ROM leaves 20 MHz), and the
; ROM told so (its ets_delay_us and ms_cycles count with it)
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
  s32i  a2, a4, 0xB0
  s32i  a3, a4, 0x98
  s32i  a3, a4, 0xB0
  l32r  a2, lit_swd_key
  s32i  a2, a4, 0xB8
  l32i  a5, a4, 0xB4
  l32r  a6, lit_bit31
  or    a5, a5, a6
  s32i  a5, a4, 0xB4                 ; SWD_AUTO_FEED_EN
  s32i  a3, a4, 0xB8
  memw
  l32r  a4, lit_sysclk
  l32i  a5, a4, 0
  movi  a6, -1024                    ; all bits but those of PRE_DIV_CNT
  and   a5, a5, a6
  s32i  a5, a4, 0                    ; 40 MHz
  memw
  movi  a10, 40
  l32r  a8, lit_setfreq
  callx8 a8
  retw


; ---------- the clock glitch detector (added at the end of the code: the code before keeps its addresses) ----------

; the reset of the clock glitch detector off before the WiFi starts (RTC_CNTL_FIB_SEL bit 0 FIB_GLITCH_RST 0: the
; software decides; RTC_CNTL_ANA_CONF bit 20 GLITCH_RST_EN 0; as ESP-IDF's bootloader_ana_clock_glitch_reset_config
; (false)). On two boards with an ESP32-S3 v0.2 the start of the radio set off that reset (RTC_CNTL_RESET_STATE 0x13,
; GLITCH_RTC_RST), on one already 0.3 s after the start of the console: the USB port never came, a loop. The WiFi
; service does the same before the radio (base_radio_on); here also for a WiFi package of before
  align 4
glitch_off:
  entry a1, 32
  l32r  a2, lit_rtc
  l32i  a3, a2, 0x148                ; RTC_CNTL_FIB_SEL: FIB_GLITCH_RST (bit 0) 0
  movi  a4, 1
  or    a3, a3, a4
  xor   a3, a3, a4
  s32i  a3, a2, 0x148
  memw
  l32i  a3, a2, 0x34                 ; RTC_CNTL_ANA_CONF: GLITCH_RST_EN (bit 20) 0
  movi  a4, 1
  slli  a4, a4, 20
  or    a3, a3, a4
  xor   a3, a3, a4
  s32i  a3, a2, 0x34
  memw
  retw

.include "../esp32/console_dhcp.asm"                ; DHCP: the address of the board (net_tick)

.data 0x3FCD8000
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
          dd 0                       ; +40 its entry (-1: the room of the WiFi package, packet A)
          dd 0                       ; +44 the offset of the last piece
          dd 0                       ; +48 the entry of the program that is loaded
          dd 0                       ; +52 the address of a segment
          dd 0                       ; +56 its length
          dd 0                       ; +60 load: the segments for the flash it left out
          dd 0                       ; +64 packet S: the divider at the start (0: not changed; the USB has none)
          dd 0                       ; +68 packet S: the divider before, while the next packet has to show the new one
          dd 0                       ; +72 packet S: the divider now (its answer)
          dd 0                       ; +76 packet I: the JEDEC id of the flash (its answer)
          dd 510                     ; +80 the sectors of the files: from 0x202 to the end of the flash (flash_init)
          dd 0                       ; +84 1: bytes wait in the FIFO of the USB port (tx_flush sends them)
          dd 0                       ; +88 1: a byte found no room in 10 ms (put_char drops the next ones at once)
          dd 0                       ; +92 a program runs: the return of run_file (its a0 with the bits of call8)
          dd 0                       ; +96 its sp
          dd 0                       ; +100 its ps
          dd 0                       ; +104 vecbase before the program (the boot ROM's)
          dd 0                       ; +108 how the last program ended: 0 returned, 1 exit, 3 an exception
          dd 0                       ; +112 the exception: exccause (0x100 + n: interrupt level n, 0x106 a break;
                                     ;      0x200 + exccause: a double exception)
          dd 0                       ; +116 its pc
          dd 0                       ; +120 excvaddr (a load or store)
          dd 0                       ; +124 intenable before the program
          dd 0                       ; +128 millis: ccount at the call before
          dd 0                       ; +132 millis: the cycles left over then (less than a millisecond)
          dd 0                       ; +136 millis: the milliseconds
          dd 0                       ; +140 1: a program runs, the NMI takes the bytes of the USB port (key_on)
          dd 0, 0, 0, 0, 0           ; +144 .. +160 a1 .. a5 of the program in the NMI (nmi_key)
          dd 0                       ; +164 Ctrl+C came
          dd 0                       ; +168 1: a function of the ROM works on the flash (Ctrl+C waits)
          dd 0                       ; +172 (the ESP32: UART_CONF1_REG before key_on)
          dd 0                       ; +176 INTERRUPT_CORE0_USB_DEVICE_INT_MAP_REG before key_on
          dd 0                       ; +180 the text of the arguments of the program (args())
          dd 0                       ; +184 how it started: 0 run, 1 packet X, 2 a command (run_file)
          dd 0                       ; +188 1: a debug session (T): rf_after stops at rf_dbgbreak
          dd 0, 0                    ; +192, +196 a0 and a1 of dbg_host
          dd 0                       ; +200 core 1 is parked (core1_park): svc_pblock of the WiFi service, 0 not
          dd 0                       ; +204 the number of the record of the WiFi network (wlan; 0: none)
          dd 0xFE000                 ; +208 the sector for the next record
          dd 0                       ; +212 1: read_line without echo (the password of wlan set)
          dd 0                       ; +216 wlan set: bit 1 (wlan off) of the record before
          dd 0                       ; +220 1: the WiFi was stopped for a program in its room (wlan_yield)
          dd 0                       ; +224 1: at the prompt (net_tick)
          dd 0                       ; +228 DHCP: the state (0 none, 1 DISCOVER sent, 2 REQUEST sent, 3 an address,
                                     ;      4 no answer: again after 30 s)
          dd 0                       ; +232 the time of the last message (wifi_millis)
          dd 0                       ; +236 its tries
          dd 0                       ; +240 the xid
          dd 0                       ; +244 the address offered (4 bytes)
          dd 0                       ; +248 the server (option 54)
          dd 0                       ; +252 the time to ask again (half the lease)
          dd 0                       ; +256 the address said last (0: none)
          dd 0                       ; +260 ccount at the last look of net_tick
wname:    dd 0, 0, 0, 0, 0           ; its name (20 bytes)
digits:   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
s_hello:  db 13, 10, 'Asmonite console 2 for the ESP32-S3 (help shows the commands)', 13, 10, 0
s_nofs:   db 'There is no file system in the flash yet: format makes one.', 13, 10, 0
s_prompt: db '> ', 0
s_crlf:   db 13, 10, 0
s_bs:     db 8, 32, 8, 0
s_cancel: db '^C', 13, 10, 0
s_help:   db '  ls cat put rm df format run load boot noboot wlan help, or a program: name [args]', 13, 10
          db '  (help.txt is missing: Prepare Board in the Board Manager writes it)', 13, 10, 0
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
s_version: db 'Asmonite console 2', 0
e_packet: db 'The packet was damaged.', 0
e_unknown: db 'Unknown packet.', 0
e_size:   db 'The packet has the wrong length.', 0
e_nofile: db 'There is no such file.', 0
e_notopen: db 'No file is open for writing.', 0
e_place:  db 'The bytes are not at their place in the file.', 0
e_fcrc:   db 'The file in the flash does not match its CRC-32.', 0
e_noprog: db 'This is not a program (an image as Asmonite writes it into the flash).', 0
e_where:  db 'The program does not fit: its code must be in 0x40378000..0x403BFFFF, its data in 0x3FC88000..0x3FCCFFFF.', 0
e_damaged: db 'The file is damaged: its CRC-32 does not match.', 0
e_wifiruns: db 'The WiFi service runs on core 1: reset the board first.', 0
e_area:   db 'Not in the room of the WiFi package (0x100000..0x1FFFFF).', 0
s_running: db 'Running ', 0
s_ended:  db 13, 10, 'Program ended (code ', 0
s_ended2: db ').', 13, 10, 0
s_stopped: db 13, 10, 'Program stopped: exception 0x', 0
s_keystop: db 13, 10, 'Program stopped (Ctrl+C).', 13, 10, 0
s_dbgstop: db 13, 10, 'Program stopped by the debugger.', 13, 10, 0
s_empty:  db 0
s_bin:    db '.bin', 0
s_at:     db ' at pc 0x', 0
s_addr:   db ', address 0x', 0
s_auto:   db 'Autostart of ', 0
s_auto2:  db ' in 3 seconds (press BOOT or a key to stay in the console)', 13, 10, 0
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
c_helptxt: db 'help.txt', 0
c_wlan:   db 'wlan', 0
c_set:    db 'set', 0
c_clear:  db 'clear', 0
s_wnuse:  db 'wlan shows the WiFi network, wlan set sets one, wlan on / wlan off, wlan clear forgets it.', 13, 10, 0
s_wnnone: db 'No WiFi network is set (wlan set sets one).', 13, 10, 0
s_wnnet:  db 'WiFi network: ', 0
s_wnwpa:  db ' (WPA2)', 13, 10, 0
s_wnopen: db ' (open)', 13, 10, 0
s_wnoff:  db 'The WiFi does not run (wlan on starts it).', 13, 10, 0
s_wnnot:  db 'The WiFi is on, not connected.', 13, 10, 0
s_wnconn: db 'The WiFi is on and connected.', 13, 10, 0
s_wnask1: db 'Name of the network: ', 0
s_wnask2: db 'Password (not shown; empty for an open network): ', 0
s_wnkey:  db 'Computing the key ...', 13, 10, 0
s_wnbadpw: db 'The password must have 8 to 63 characters. Nothing was changed.', 13, 10, 0
s_wnsaved: db 'Saved: the network ', 0
s_wnsaved2: db '. The board keeps its name and key, not the password.', 13, 10, 0
s_wncleared: db 'The board knows no WiFi network now.', 13, 10, 0
e_nowifi: db 'The WiFi package is not on the board: F9 of a WiFi program or Prepare Board in Asmonite writes it.', 0
e_wifiold: db 'The WiFi package on the board is too old: Board Manager > Install WiFi Again in Asmonite writes the new one.', 0
c_on:     db 'on', 0
c_off:    db 'off', 0
s_wnbg1:  db 'WiFi: connecting to ', 0
s_wnbg2:  db ' in the background.', 13, 10, 0
s_wnwifi: db 'WiFi: ', 0
s_wnisoff: db 'The WiFi is off (wlan on switches it on).', 13, 10, 0
s_wnconnecting: db 'The WiFi is on, connecting ...', 13, 10, 0
s_wnoffnow: db 'The WiFi is off, also after a reset (wlan on switches it on).', 13, 10, 0
.include "../esp32/console_dhcp_data.asm"
