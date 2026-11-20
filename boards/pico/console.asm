; Raspberry Pi Pico (RP2040, Arm core Cortex-M0+): the console of Asmonite on UART0: a prompt, the files in the flash,
; programs started from them, and the packets for Asmonite, as on the Pico 2 (boards\pico2\console.asm) and the
; ESP32 (boards\esp32\console.asm).
;
; UART0 at 115200 baud, 8N1: TX on GPIO 0 (pin 1 of the board), RX on GPIO 1 (pin 2). The Raspberry Pi Debug Probe
; has a serial port of its own, its connector "U": its yellow wire (RX) at GPIO 0, its orange wire (TX) at GPIO 1, the
; black one (GND) at GND (pin 3). In Asmonite the tab Serial next to the output window shows the console on the COM
; port of the probe; Enter gives the prompt "> ", help lists the commands:
;
;   ls                the files
;   run name [args]   starts a program (name alone, and its arguments: the same, without "Running" and without
;                     "Program ended (code 0)")
;   boot name         starts the program after every reset (boot alone: which one); noboot: none
;   cat name          a file as text
;   rm name           removes a file
;   df                the room in the flash
;   format            a new, empty file system (all files are lost; it asks first)
;   info              the board (a Pico W too), the chip, its cores, the boot ROM, the console
;   reset             starts the chip again (the watchdog): the boot ROM starts the console from the flash
;   wlan [on | off]   the WiFi chip of a Pico W: on starts it with its firmware (the files 43439A0.bin and
;                     nvram_rp2040.bin, which Prepare Board puts onto a W; console_wifi.asm), off switches it off
;   wlan scan         the WiFi networks around: the signal (dBm), the channel, open or secured, the name
;   wlan set          the network of the board: its name, then its password (not shown; Enter alone: an open
;                     network). The console keeps the name and the key of WPA2 made of the password (not the
;                     password) in the two sectors behind the files, and joins it; wlan on joins it again
;   wlan clear        the board keeps no network
;   help              the commands
;
; Backspace (BS or DEL) takes back a character, Ctrl+C drops the line. A line ends with CR, LF or CR LF.
;
; A program is a file as Asmonite makes it for the console of the ESP32 (the image of a boot ROM of Espressif: 0xE9,
; the number of segments, the entry; then each segment with its address and length). The console checks the CRC-32
; of the file and the segments: in the RAM of the programs, 0x20000000 .. 0x2002FFFF (192 KB), the entry too. It
; copies them to their place and calls the entry (Thumb) with r0 = the text of the arguments, on a stack of its own
; from 0x20030000 down. The program ends
;   - with bx lr: "Program ended (code n).", n its r0;
;   - with exit(code) from any depth;
;   - by an exception (a fault, an interrupt the console does not know): "Program stopped: exception n at pc ...";
;   - by Ctrl+C from the terminal (Stop in the tab Serial of Asmonite): "Program stopped (Ctrl+C).". While a program
;     runs, UART0 interrupts for each byte that comes (uart_irq): the bytes go into a ring for get_char, Ctrl+C stops
;     the program (not when it keeps the interrupts off);
; and the console goes on (its stack and its vector table again; the peripherals as the program leaves them).
; The functions of the console for programs: a table of their addresses (with the Thumb bit) at 0x20038140, in the
; order of the ESP32 (jt_exit there): +0 exit(code), +4 version() (2), +8 put_char(c), +12 get_char(), +16
; poll_char() (-1 if none came), +20 print(text), +24 millis(), +28 file_size(name) (-1 none), +32 file_read(name,
; buffer, offset, count) (the bytes read, -1), +36 file_write(name, buffer, count) (0, or -1 .. -5 as on the ESP
; boards), +40 flash_read (not yet: -1), +44 args(), +48
; led(on) (the LED of the board: GPIO 25; console_wifi.asm, wifi_led). A call:
;     ldr  r3, lit_jt             ; lit_jt: dd 0x20038140
;     ldr  r3, [r3, #8]           ; put_char
;     blx  r3                     ; r0 .. r3 and r12 may change, as in AAPCS
; The same functions as code to call at 0x20039E00, 16 bytes each in the same order (+0x00 exit, +0x20 put_char,
; +0x50 print ...): bl or blx to the address itself, for a program that calls a function at a fixed address (aBelle:
; examples_internal/abelle/pico/inc/console.abel).
; With boot, after a reset the console waits a second: a key stays in the console.
;
; Where it is:
;   - in the flash from 0x10000000 (Debug > Write to Flash and Run, or the UF2 file of Project > Save as UF2 file):
;     boot2 (the 256 bytes of the Pico SDK that set up the flash chip; the boot ROM checks their CRC-32 and runs them),
;     then the vector table at 0x10000100, where boot2 jumps
;   - at its start it copies itself into the RAM at 0x20030000 and runs there: while the flash is written no code can
;     be read from it. All the code is position independent (branches and calls relative to the pc, the constants in
;     words behind each function, texts behind the call that prints them: print_inline), so it runs at both places;
;     only the addresses in the vector table of the RAM (VTAB) are made for the RAM (+ RUN_OFFSET)
;   - its data and its stack: 0x20038000 .. 0x20042000 (equ below). The RAM from 0x20000000 to 0x20030000 is the
;     room of the programs
;   - the clocks: clk_ref at 12 MHz from the crystal (XOSC; after a reset it runs from the ring oscillator, whose
;     frequency is not exact enough for a baud rate); clk_usb and clk_sys at 48 MHz from PLL_USB (the USB controller
;     needs them), clk_peri from clk_sys for the UART; TIMER counts the microseconds (millis, the waits for the bytes
;     of a packet; its tick from the watchdog at 1 MHz from clk_ref)
;   - the console over the USB cable of the board as well: console_usb.asm (a COM port on the PC, USB CDC-ACM, driven
;     by the interrupt of the USB controller). What it writes goes to UART0 and over USB; it takes what comes from
;     either
;
; The Cortex-M0+ knows Thumb-1 only (ARMv6-M): the constants of more than 8 bits come from words behind the code
; (ldr r0, name), most instructions take r0 .. r7 only, there is no division (udiv32 below).
;
; A fault (a read where nothing is, an instruction that is none) goes into the handler fault: it says which
; exception it was and its pc, and returns to the prompt (the Cortex-M0+ has no registers that say more).
;
; The file system: the flash from 1 MB to 2 MB (the Pico has 2 MB), sectors of 4 KB, as on the ESP32:
;   - sectors 0x100 and 0x101: the directory, twice. It is written into the other sector each time, with a number
;     one higher; at the start the console takes the valid one with the higher number. So a reset or a power cut
;     while it is written leaves the directory as it was before.
;     A directory: "AFS1", the number, the CRC-32 of the 64 entries and then of the word behind it, the program for
;     boot (its entry + 1, 0 none), then from +32 64 entries of 32 bytes: the name (up to 19 characters and a 0), the
;     first sector, the length, the CRC-32 of the file.
;   - sectors 0x102 .. 0x1FD: the files, each in sectors one after the other (the first gap big enough). A new text
;     for a file goes into a new place first; only then the directory points to it.
; The console reads the flash through the XIP window (0x10000000 + the place) and writes it with the functions of
; the boot ROM, which it finds in its table (rom_find): connect_internal_flash (IF), flash_exit_xip (EX),
; flash_range_erase (RE), flash_range_program (RP: pages of 256 bytes), flash_flush_cache (FC),
; flash_enter_cmd_xip (CX). While the flash is written the XIP window gives nothing: the console runs from the RAM.
;
; A program on the PC talks to the console in packets (Asmonite: src\debugger\EspConsole.pas, the same as for the
; ESP32): STX (0x02), the command, the length of the data (16 bits), the data, the CRC-32 (zlib) of the command, the
; length and the data, all little endian. The PC sends one and waits for the answer. A name is a field of 20 bytes
; (the name, zeros behind it). The STX at the prompt is the sign for them; a second without a packet, and the console
; takes commands from a terminal again.
;   P              -> k "Asmonite console 2"
;   V              -> k the version of the console (4 bytes: what console_version() gives a program)
;   I              -> k the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0)
;   F              -> f files, bytes in use, bytes free (3 words), the name of the program for boot
;   L              -> l for each file: name, length, CRC-32 (28 bytes)
;   O name len crc -> k  a file opens for writing: its sectors are erased
;   W offset bytes -> k  up to 1024 bytes at offset (the pieces in their order, each at a multiple of 256 bytes; the
;                         same piece again: k)
;   C              -> k  the file read back from the flash: its CRC-32 is the one of O, then it is in the directory
;   G name offset count -> d the bytes (count up to 1024, offset a multiple of 4)
;   D name         -> k  the file is removed
;   B name         -> k  the program for boot (a field of zeros: none)
;   X name         -> k  the program starts (it says when it ends, as run)
;   R address bytes -> k the bytes (whole words, up to 1024) into the RAM of the programs (F9 of Asmonite)
;   E entry        -> k  the program R put into the RAM starts at its entry (as X)
;   T entry        -> k  the same under the debug monitor (console_mon.asm: the packets then)
;   H              -> k  the board: "Raspberry Pi Pico" or "Raspberry Pi Pico W" (console_wifi.asm asks the WiFi
;                         chip at the start); "Raspberry Pi Pico (WiFi: ESP8285)" when the ESP8285 of the clones
;                         answers with our firmware (UART0 is its then: the console over USB only), "Raspberry Pi
;                         Pico (an ESP8285 at UART0?)" when GPIO 1 is held low
;   M              -> k  a new, empty file system (all files are lost)
;   Q              -> k  back to the commands for a terminal (also after a second without a packet)
;   Y address count -> d the bytes of the flash at address (from its start; count up to 1024, address a multiple of 4)
;   K address count -> k the CRC-32 of count bytes of the flash at address (a multiple of 4)
;   S              -> e  (the UART stays at 115200 baud: at 12 MHz no faster rate is exact enough)
; e and a text: what went wrong (a damaged packet: the PC sends it again).
;
; The words of VARS are at offsets up to 124 (ldr and str of the Cortex-M0+ reach no further).
;
; The register conventions: r0 .. r3 arguments, values and scratch; a function keeps r4 .. r7 (push / pop). The
; console does not use r8 .. r12.
.target pico
.arch thumb
.imagebase 0x10000000

FLASH_BASE          equ 0x10000000
RAM_BASE            equ 0x20030000          ; the console runs here (its code: up to 0x20038000)
RUN_OFFSET          equ RAM_BASE - FLASH_BASE
VTAB                equ 0x20038000          ; its vector table in the RAM (VTOR: aligned to 256 bytes)
VTAB_ENTRIES        equ 48                  ; 16 of the core, 32 interrupts (the RP2040 has 26)
LINE                equ 0x20038200          ; the line typed
LINE_MAX            equ 120
VARS                equ 0x20038300          ; the variables (V_ below)
CRCTAB              equ 0x20038400          ; the table of the CRC-32 (1 KB)
PKT                 equ 0x20038800          ; a packet that came: +1 the command, +2 the length, +4 the data
OUT                 equ 0x20038D00          ; a packet that goes: the same
PAGEBUF             equ 0x20039200          ; a piece of a file on its way into the flash (1 KB and a page)
DIRBUF              equ 0x2003A000          ; the directory (4 KB)
;                   DIRBUF + 0x1000 .. + 0x2100: the WiFi chip (console_wifi.asm: its packets, the scan, SHA-1, the
;                   record of the network)
STACK_TOP           equ 0x20042000          ; the end of the RAM

V_FSOK              equ 0                   ; 1: DIRBUF holds a valid directory
V_DIRSEC            equ 4                   ; the sector it came from (0x100 or 0x101)
V_OPEN              equ 8                   ; O: 1 while a file is open for writing
V_OFIRST            equ 12                  ; its first sector
V_OLEN              equ 16                  ; its length
V_OCRC              equ 20                  ; its CRC-32
V_OWRITTEN          equ 24                  ; the bytes written so far
V_OENTRY            equ 28                  ; its entry in DIRBUF
V_OLAST             equ 32                  ; the offset of the last piece (-1 none)
V_FN                equ 40                  ; the functions of the boot ROM: IF EX RE RP FC CX (6 words)
V_RUN               equ 64                  ; 1 while a program runs
V_CSP               equ 68                  ; the stack pointer of the console while it runs
V_RHEAD             equ 72                  ; the ring: where uart_irq puts the next byte
V_RTAIL             equ 76                  ; ... and where get_char takes the next one
V_ARGS              equ 80                  ; the text of the arguments of the program
V_QUIET             equ 84                  ; 1: started by its name alone (no "Program ended (code 0)")
V_EMPTY             equ 88                  ; an empty text (0)
V_SRC               equ 92                  ; where the last byte came from: 0 UART0, 1 USB
V_PKT_USB           equ 96                  ; 1: the packets come over USB (the answers go there only)
V_WIFI              equ 100                 ; 1: a Pico W (console_wifi.asm: its WiFi chip answered)
V_FQUIET            equ 104                 ; file_write: not 0: send_packet keeps its answer here (k, e), +4 the text
V_FTEXT             equ 108                 ; ... the text of e
V_NAME              equ 128                 ; a name of a command for a terminal (a field of 20 bytes)
V_ONAME             equ 160                 ; the name of the open file (20 bytes)
JT                  equ 0x20038140          ; the functions for programs (their addresses, see jt_init)
RING                equ 0x20039800          ; the bytes that came while a program runs (256)
PROG_LO             equ 0x20000000          ; the RAM of the programs
PROG_HI             equ 0x20030000          ; ... up to here; the stack of a program from here down
USBV                equ 0x20039900          ; the variables of console_usb.asm (128 bytes)
USB_RXB             equ 0x20039A00          ; ... its ring of what came over USB (256)
USB_TXB             equ 0x20039B00          ; ... and of what goes (256)
USB_IRQN            equ 5                   ; the interrupt of the USB controller
USB_UID             equ 0x20039C00          ; the id of the board (8 bytes: uid_read)
USB_SERIAL          equ 0x20039C40          ; the serial number of the USB device (48 bytes)
MONV                equ 0x20039D00          ; the variables of the debug monitor (console_mon.asm, M_ below, 64 bytes)
STUBS               equ 0x20039E00          ; the functions for programs to call, 16 bytes each (jt_init)
;                   STUBS + 0x100: the variables of the WiFi chip (64 bytes, console_wifi.asm: WLV)
M_ON                equ 0                   ; 1 while a program runs under the monitor (packet T)
M_FRAME             equ 4                   ; while it stands: the frame of the exception PendSV
M_EXCRET            equ 8                   ; ... its EXC_RETURN
M_REGS              equ 12                  ; ... r4 .. r11 of the program (8 words)
M_REQ               equ 56                  ; 1: a Ctrl+C asked for the stop
M_PROBE             equ 60                  ; not 0: a fault in a read or write of m or v returns there
IO_QSPI_SS_CTRL     equ 0x4001800c          ; the CS of the flash chip: OUTOVER in bits 9 .. 8 (2 low, 3 high)
SSI                 equ 0x18000000          ; the SPI of the flash: +0x28 SR (bit 1 TFNF, bit 3 RFNE), +0x60 DR0
USB_RESET_BIT       equ 1 << 24             ; USBCTRL in RESETS

FS_SECTOR           equ 0x100               ; the first directory (1 MB)
FS_FIRST            equ 0x102               ; the first sector of the files
FS_END              equ 0x1FE               ; behind the last one (2 MB less the two sectors of the WiFi network:
;                                           0x1FE and 0x1FF, console_wifi.asm)
FLASH_SIZE          equ 0x200000
ENTRIES             equ 64
MAGIC               equ 0x31534641          ; "AFS1"

; the registers (RP2040 datasheet)
SYSINFO             equ 0x40000000          ; +0 CHIP_ID
XOSC                equ 0x40024000
XOSC_CTRL           equ 0x00
XOSC_STATUS         equ 0x04
XOSC_STARTUP        equ 0x0c
XOSC_RANGE_1_15MHZ  equ 0xaa0
XOSC_STARTUP_DELAY  equ 282                 ; * 256 cycles of 12 MHz: about 6 ms
XOSC_ENABLE         equ (0xfab << 12) | 0xaa0
CLOCKS              equ 0x40008000
CLK_REF_CTRL        equ 0x30                ; SRC bits 1 .. 0 (2 XOSC)
CLK_REF_DIV         equ 0x34                ; the divisor in bits 9 .. 8
CLK_REF_SELECTED    equ 0x38
CLK_SYS_CTRL        equ 0x3c                ; SRC bit 0 (0 clk_ref), AUXSRC bits 7 .. 5
CLK_SYS_DIV         equ 0x40                ; the whole part in bits 31 .. 8
CLK_SYS_SELECTED    equ 0x44
CLK_PERI_CTRL       equ 0x48
CLK_PERI_ENABLE     equ 1 << 11
RESETS              equ 0x4000c000
RESET_DONE          equ 0x08
RESET_BITS          equ (1 << 5) | (1 << 8) | (1 << 21) | (1 << 22)    ; IO_BANK0, PADS_BANK0, TIMER, UART0
WATCHDOG            equ 0x40058000          ; +0 CTRL (bit 31 TRIGGER), +0x1c SCRATCH4, +0x2c TICK
WATCHDOG_TICK       equ (1 << 9) | 12       ; on, 12 cycles of clk_ref: a microsecond
PSM_WDSEL           equ 0x40010008          ; what the watchdog resets
PSM_WDSEL_ALL       equ 0x1fffc             ; all but the oscillators (as the Pico SDK)
TIMER               equ 0x40054000          ; +0x24 TIMERAWH, +0x28 TIMERAWL: the microseconds
TIMER0              equ TIMER               ; (the name of the Pico 2)
CLK_USB_CTRL        equ 0x54
CLK_USB_DIV         equ 0x58                ; the whole part in bits 31 .. 8
PLL_USB             equ 0x4002c000          ; +0 CS, +4 PWR, +8 FBDIV, +0xc PRIM
RESET_PLL_USB       equ 1 << 13
ALIAS_CLR           equ 0x3000              ; + of a register address: clears the bits written
IO_BANK0            equ 0x40014000
GPIO0_CTRL          equ 0x04
GPIO1_CTRL          equ 0x0c
FUNCSEL_UART        equ 2
PADS_BANK0          equ 0x4001c000
SIO_IN              equ 0x04                ; the SIO (0xd0000000): GPIO_IN
SIO_OUT_SET         equ 0x14
SIO_OUT_CLR         equ 0x18
SIO_OE_SET          equ 0x24
SIO_OE_CLR          equ 0x28
PAD_GPIO1           equ 0x08
PAD_RX              equ 0x5a                ; GPIO 1: input on (IE), 4 mA, pull-up, Schmitt trigger
UART0               equ 0x40034000          ; an Arm PL011
UARTDR              equ 0x00
UARTDR_ERRORS       equ 0xf00               ; OE, BE, PE, FE of a byte that came
UARTFR              equ 0x18
UARTFR_BUSY         equ 1 << 3
UARTFR_RXFE         equ 1 << 4
UARTFR_TXFF         equ 1 << 5
UARTIBRD            equ 0x24
UARTFBRD            equ 0x28
UARTLCR_H           equ 0x2c
LCR_8BIT_FIFO       equ (3 << 5) | (1 << 4)
UARTCR              equ 0x30
UARTIMSC            equ 0x38                ; the interrupts: RXIM (bit 4), RTIM (bit 6)
UARTICR             equ 0x44
NVIC_ISER           equ 0xe000e100          ; the interrupts on (UART0 is 20)
NVIC_ICER           equ 0xe000e180          ; ... off
UART0_IRQ_BIT       equ 1 << 20
UART0_VECTOR        equ 16 + 20             ; its entry in the vector table
CR_ON               equ (1 << 0) | (1 << 8) | (1 << 9)      ; UARTEN, TXE, RXE
US_MS               equ 1000                ; TIMER counts microseconds
SCB_CPUID           equ 0xe000ed00
SCB_VTOR            equ 0xe000ed08

; ---------- in the flash: what the boot ROM finds, the copy into the RAM ----------

    .boot2

vectors:
    dd STACK_TOP                ; the stack pointer at the start
    dd _start + 1               ; reset (+1: Thumb code)
    dd hang + 1                 ; NMI
    dd hang + 1                 ; HardFault (until the table in the RAM takes over)

_start:
    ldr  r0, lit_flash
    ldr  r1, lit_ram
    ldr  r2, lit_size
copy:
    ldr  r3, [r0]
    str  r3, [r1]
    adds r0, r0, #4
    adds r1, r1, #4
    subs r2, r2, #4
    bgt  copy
    ldr  r0, lit_main
    bx   r0
hang:
    b    hang

    align 4
lit_flash:  dd FLASH_BASE
lit_ram:    dd RAM_BASE
lit_size:   dd image_end - vectors + 256        ; boot2 and all behind it
lit_main:   dd main + RUN_OFFSET + 1

; ---------- in the RAM from here on ----------

main:
    ldr  r0, main_stack_top
    mov  sp, r0
    bl   vtab_init
    bl   uart_init
    bl   crc_init
    bl   vars_init
    bl   mon_init
    bl   rom_init
    bl   uid_read                   ; (with the functions of the boot ROM for the flash)
    bl   usb_init                   ; (console_usb.asm) the PC sees the COM port of the console
    bl   dir_load
    bl   jt_init
    bl   wifi_detect                ; (console_wifi.asm) a Pico W?
    bl   print_inline
    db   13, 10, 'Asmonite console 2 for the RP2040 (', 0
    align 2
    bl   put_board
    bl   print_inline
    db   '; help shows the commands)', 13, 10, 0
    align 2
    ldr  r0, main_vars
    ldr  r1, [r0, #V_FN + 20]
    cmp  r1, #0
    bne  main_rom
    bl   print_inline
    db   'The boot ROM has not all the functions for the flash: the files cannot be written.', 13, 10, 0
    align 2
main_rom:
    ldr  r0, main_vars
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  main_nofs
    bl   autostart
    b    prompt
main_nofs:
    bl   print_inline
    db   'No file system in the flash yet: format makes one.', 13, 10, 0
    align 2
prompt:
    bl   print_inline
    db   '> ', 0
    align 2
    bl   read_line
    bl   command
    b    prompt

    align 4
main_stack_top: dd STACK_TOP
main_vars:      dd VARS

; after a fault (fault: the exception returns here)
recover:
    ldr  r0, recover_stack_top
    mov  sp, r0
    b    prompt

    align 4
recover_stack_top: dd STACK_TOP

; the vector table in the RAM: every exception and interrupt to fault, UART0 to uart_irq; VTOR to it
vtab_init:
    ldr  r0, vtab_init_vtab
    ldr  r1, lit_fault
    movs r2, #0
vt_fill:
    str  r1, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #VTAB_ENTRIES * 4
    blt  vt_fill
    ldr  r1, vtab_init_stack_top
    str  r1, [r0]
    ldr  r1, lit_main_ram
    str  r1, [r0, #4]
    ldr  r1, lit_uart_irq
    movs r2, #UART0_VECTOR * 4
    str  r1, [r0, r2]
    ldr  r1, lit_usb_irq
    str  r1, [r0, #(16 + USB_IRQN) * 4]
    ldr  r1, vtab_init_scb_vtor
    str  r0, [r1]
    dsb
    isb
    bx   lr

    align 4
vtab_init_vtab:      dd VTAB
vtab_init_stack_top: dd STACK_TOP
vtab_init_scb_vtor:  dd SCB_VTOR

; an exception: which one and its pc (the Cortex-M0+ has no registers that say more); then back to the prompt (its
; frame gets the pc of recover, or of prog_abort when a program ran)
fault:
    mov  r1, sp                 ; the frame
    push {r7, lr}               ; r7 of the code the exception came from, and EXC_RETURN
    mov  r7, lr                 ; EXC_RETURN (the calls below change lr)
    bl   mon_fault              ; a BKPT under the debug monitor, or a read of it where nothing is: back
    cmp  r0, #0
    beq  fa_go
    pop  {r7, pc}               ; back with its r7 (the pc gets EXC_RETURN: the return of the exception)
fa_go:
    add  sp, #8                 ; (from here r7 is EXC_RETURN: the console goes on at recover or prog_abort)
    mrs  r4, ipsr
    mov  r5, sp                 ; the frame: r0 r1 r2 r3 r12 lr pc xpsr
    ldr  r6, fault_vars
    ldr  r6, [r6, #V_RUN]       ; a program runs: it stops
    cmp  r6, #0
    beq  fa_console
    bl   print_inline
    db   13, 10, 'Program stopped: exception ', 0
    align 2
    b    fa_number
fa_console:
    bl   print_inline
    db   13, 10, 'exception ', 0
    align 2
fa_number:
    mov  r0, r4
    bl   put_dec
    bl   print_inline
    db   ' at pc 0x', 0
    align 2
    ldr  r0, [r5, #24]
    bl   put_hex8
    bl   put_nl
    ldr  r0, lit_recover
    cmp  r6, #0
    beq  fa_back
    ldr  r0, lit_abort
fa_back:
    str  r0, [r5, #24]
    movs r0, #1
    lsls r0, r0, #24            ; xPSR: only the Thumb bit
    str  r0, [r5, #28]
    bx   r7

    align 4
fault_vars:     dd VARS
lit_fault:      dd fault + RUN_OFFSET + 1
lit_main_ram:   dd main + RUN_OFFSET + 1
lit_recover:    dd recover + RUN_OFFSET
lit_uart_irq:   dd uart_irq + RUN_OFFSET + 1
lit_usb_irq:    dd usb_irq + RUN_OFFSET + 1
lit_abort:      dd prog_abort + RUN_OFFSET

; the variables: no file open
vars_init:
    ldr  r0, vars_init_vars
    movs r1, #0
    movs r2, #252
vi_clear:
    str  r1, [r0, r2]
    subs r2, r2, #4
    bpl  vi_clear
    bx   lr

    align 4
vars_init_vars: dd VARS

; the id of the board into USB_UID (the serial number of the USB device): the RP2040 has no id of its own, so the
; unique id of the flash chip, as the Pico SDK (pico_get_unique_board_id): its command 0x4B, 4 bytes, then the 8 bytes
; of the id. The flash out of XIP (flash_open: the boot ROM sets up the SSI for single bytes), its CS low by hand
; (IO_QSPI: OUTOVER), 13 bytes through the SSI (at most 14 on their way), CS high, the flash back (flash_close).
; Without the functions of the boot ROM the id stays 0
uid_read:
    push {r4, r5, r6, r7, lr}
    ldr  r0, uid_read_vars
    ldr  r0, [r0, #V_FN + 20]
    cmp  r0, #0
    beq  ur_end
    bl   flash_open
    ldr  r4, uid_read_ss_ctrl
    ldr  r0, [r4]
    ldr  r1, uid_read_outover
    bics r0, r1
    movs r1, #2
    lsls r1, r1, #8
    orrs r0, r1
    str  r0, [r4]                   ; CS low
    ldr  r5, uid_read_ssi
    movs r6, #0                     ; the bytes sent
    movs r7, #0                     ; the bytes that came
ur_loop:
    ldr  r0, [r5, #0x28]            ; SR
    cmp  r6, #13
    bhs  ur_get
    subs r1, r6, r7
    cmp  r1, #14
    bhs  ur_get
    lsls r1, r0, #30                ; TFNF (bit 1)
    bpl  ur_get
    movs r1, #0
    cmp  r6, #0
    bne  ur_put
    movs r1, #0x4b                  ; READ UNIQUE ID, then 4 dummy bytes and 8 for the id
ur_put:
    str  r1, [r5, #0x60]
    adds r6, #1
ur_get:
    lsls r1, r0, #28                ; RFNE (bit 3)
    bpl  ur_next
    ldr  r1, [r5, #0x60]
    cmp  r7, #5
    blo  ur_skip
    ldr  r2, uid_read_uid
    subs r3, r7, #5
    strb r1, [r2, r3]
ur_skip:
    adds r7, #1
ur_next:
    cmp  r7, #13
    blo  ur_loop
    ldr  r0, [r4]
    ldr  r1, uid_read_outover
    orrs r0, r1
    str  r0, [r4]                   ; CS high
    bl   flash_close
ur_end:
    pop  {r4, r5, r6, r7, pc}

    align 4
uid_read_vars:      dd VARS
uid_read_ss_ctrl:   dd IO_QSPI_SS_CTRL
uid_read_outover:   dd 3 << 8
uid_read_ssi:       dd SSI
uid_read_uid:       dd USB_UID

; ---------- UART0 and SysTick ----------

; the crystal, clk_ref (and with it clk_sys) from it, clk_peri; GPIO 0 and 1 to UART0; 115200 baud 8N1; the tick of
; the watchdog for TIMER
uart_init:
    ldr  r1, uart_init_xosc
    ldr  r0, uart_init_xosc_range
    str  r0, [r1, #XOSC_CTRL]
    ldr  r0, uart_init_xosc_startup
    str  r0, [r1, #XOSC_STARTUP]
    ldr  r0, uart_init_xosc_enable
    str  r0, [r1, #XOSC_CTRL]
ui_xosc:
    ldr  r0, [r1, #XOSC_STATUS]
    cmp  r0, #0
    bge  ui_xosc                ; bit 31 STABLE
    ; clk_sys from clk_ref, and clk_peri from clk_sys: not only after a reset. After the USB boot (an empty flash)
    ; the reset at the end of a write of the flash may leave the clocks as they were, clk_sys at 48 MHz from a PLL
    ; (seen on the Pico 2). Each switch as the datasheet wants it: only SRC of the glitchless clocks, clk_peri off
    ; for a while before it comes on with its source
    ldr  r1, uart_init_clocks
    movs r3, #1
    ldr  r0, [r1, #CLK_SYS_CTRL]
    bics r0, r3                 ; SRC 0: clk_ref
    str  r0, [r1, #CLK_SYS_CTRL]
ui_sys:
    ldr  r0, [r1, #CLK_SYS_SELECTED]
    tst  r0, r3
    beq  ui_sys
    movs r0, #1
    lsls r0, r0, #8
    str  r0, [r1, #CLK_SYS_DIV]     ; 1
    str  r0, [r1, #CLK_REF_DIV]     ; 1
    ldr  r0, [r1, #CLK_REF_CTRL]
    movs r3, #3
    bics r0, r3
    movs r3, #2
    orrs r0, r3                 ; SRC 2: XOSC
    str  r0, [r1, #CLK_REF_CTRL]
ui_ref:
    ldr  r0, [r1, #CLK_REF_SELECTED]
    cmp  r0, #1 << 2
    bne  ui_ref
    ; clk_usb and clk_sys at 48 MHz from PLL_USB (the USB controller needs 48 MHz): clk_usb off, PLL_USB 12 MHz / 1
    ; * 40 = 480 MHz, / 5 / 2 = 48 MHz (the steps of pll_init in the SDK), clk_usb on; clk_sys AUXSRC 1 (PLL_USB)
    ; while SRC is still clk_ref, then SRC 1. clk_peri follows clk_sys below: the UART at 48 MHz too
    movs r0, #0
    str  r0, [r1, #CLK_USB_CTRL]
    movs r0, #100               ; (the RP2040 has no ENABLED bit: a few cycles of the clock are enough)
ui_usb_off:
    subs r0, r0, #1
    bne  ui_usb_off
    ldr  r0, uart_init_reset_pll
    ldr  r2, uart_init_resets_set
    str  r0, [r2]               ; PLL_USB into reset ...
    ldr  r2, uart_init_resets_clr
    str  r0, [r2]               ; ... and out again
    ldr  r2, uart_init_resets
ui_pll_reset:
    ldr  r3, [r2, #RESET_DONE]
    tst  r3, r0
    beq  ui_pll_reset
    ldr  r2, uart_init_pll_usb
    movs r0, #1
    str  r0, [r2]               ; CS: REFDIV 1
    movs r0, #40
    str  r0, [r2, #8]           ; FBDIV
    movs r0, #0x0c              ; PWR: PD and VCOPD off (DSMPD and POSTDIVPD stay: 0x2d at reset)
    str  r0, [r2, #4]
ui_pll_lock:
    ldr  r0, [r2]
    cmp  r0, #0
    bge  ui_pll_lock            ; bit 31 LOCK
    ldr  r0, uart_init_prim
    str  r0, [r2, #0x0c]
    movs r0, #0x04              ; POSTDIVPD off too
    str  r0, [r2, #4]
    movs r0, #1
    lsls r0, r0, #8
    str  r0, [r1, #CLK_USB_DIV] ; 1
    ldr  r0, uart_init_clk_peri_enable  ; ENABLE (bit 11), AUXSRC 0: PLL_USB
    str  r0, [r1, #CLK_USB_CTRL]
    movs r0, #1 << 5
    str  r0, [r1, #CLK_SYS_CTRL]    ; AUXSRC 1 (PLL_USB), SRC still 0
    movs r0, #(1 << 5) | 1
    str  r0, [r1, #CLK_SYS_CTRL]    ; SRC 1: the aux source
ui_sys_aux:
    ldr  r0, [r1, #CLK_SYS_SELECTED]
    cmp  r0, #2
    bne  ui_sys_aux
    movs r0, #0
    str  r0, [r1, #CLK_PERI_CTRL]   ; off
    movs r0, #100               ; the RP2040 has no ENABLED bit: a few cycles of the old clock are enough
ui_peri:
    subs r0, r0, #1
    bne  ui_peri
    ldr  r0, uart_init_clk_peri_enable  ; AUXSRC 0: clk_sys
    str  r0, [r1, #CLK_PERI_CTRL]
    ldr  r1, uart_init_resets_clr
    ldr  r0, uart_init_reset_bits
    str  r0, [r1]
    ldr  r1, uart_init_resets
ui_reset:
    ldr  r2, [r1, #RESET_DONE]
    ands r2, r0
    cmp  r2, r0
    bne  ui_reset
    ldr  r1, uart_init_pads_bank0
    movs r0, #PAD_RX
    str  r0, [r1, #PAD_GPIO1]
    ldr  r1, uart_init_io_bank0
    movs r0, #FUNCSEL_UART
    str  r0, [r1, #GPIO0_CTRL]
    str  r0, [r1, #GPIO1_CTRL]
    ldr  r1, uart_init_uart0
    movs r0, #26                ; 48,000,000 / (16 * 115200) = 26.04: 26 and 3/64
    str  r0, [r1, #UARTIBRD]
    movs r0, #3
    str  r0, [r1, #UARTFBRD]
    movs r0, #LCR_8BIT_FIFO
    str  r0, [r1, #UARTLCR_H]
    ldr  r0, uart_init_cr_on
    str  r0, [r1, #UARTCR]
    ldr  r1, uart_init_watchdog
    ldr  r0, uart_init_tick
    str  r0, [r1, #0x2c]        ; TICK: 1 MHz for TIMER
    bx   lr

    align 4
uart_init_xosc:             dd XOSC
uart_init_xosc_range:       dd XOSC_RANGE_1_15MHZ
uart_init_xosc_startup:     dd XOSC_STARTUP_DELAY
uart_init_xosc_enable:      dd XOSC_ENABLE
uart_init_clocks:           dd CLOCKS
uart_init_clk_peri_enable:  dd CLK_PERI_ENABLE
uart_init_resets_clr:       dd RESETS + ALIAS_CLR
uart_init_resets_set:       dd RESETS + 0x2000
uart_init_reset_pll:        dd RESET_PLL_USB
uart_init_pll_usb:          dd PLL_USB
uart_init_prim:             dd (5 << 16) | (2 << 12)    ; POSTDIV1 5, POSTDIV2 2
uart_init_reset_bits:       dd RESET_BITS
uart_init_resets:           dd RESETS
uart_init_pads_bank0:       dd PADS_BANK0
uart_init_io_bank0:         dd IO_BANK0
uart_init_uart0:            dd UART0
uart_init_cr_on:            dd CR_ON
uart_init_watchdog:         dd WATCHDOG
uart_init_tick:             dd WATCHDOG_TICK

; the microseconds of TIMER0 in r0 (its low word: it wraps after 71 minutes)
tick_now:
    ldr  r1, tick_now_timer0
    ldr  r0, [r1, #0x28]        ; TIMERAWL
    bx   lr

    align 4
tick_now_timer0: dd TIMER0

; the byte r0 out (waits while the send FIFO is full) to UART0 and over USB (console_usb.asm: when a terminal has the
; port open); keeps r0. While packets come over USB (V_PKT_USB) only there: the UART is much slower. Not to UART0 when
; it belongs to the ESP8285 of the clones (console_wifi.asm: esp_detect)
put_char:
    push {r0, lr}
    ldr  r1, put_char_vars
    ldr  r1, [r1, #V_PKT_USB]
    cmp  r1, #0
    bne  pc_usb
    ldr  r1, put_char_esp
    ldr  r1, [r1]
    cmp  r1, #0
    bne  pc_usb
    ldr  r1, put_char_uart0
pc_wait:
    ldr  r2, [r1, #UARTFR]
    lsls r2, r2, #26            ; TXFF (bit 5) into N
    bmi  pc_wait
    str  r0, [r1, #UARTDR]
pc_usb:
    bl   usb_putc
    pop  {r0, pc}

    align 4
put_char_vars:  dd VARS
put_char_uart0: dd UART0
put_char_esp:   dd WLV + WL_ESP

; a byte that came in r0, from UART0 or over USB, -1 when none waits; V_SRC says where it came from. A byte of the
; UART with an error (bits 8 .. 11 of UARTDR: framing, parity, break, overrun) is left out: at a reset of the chip a 0
; with a break came. UART0 is left out when it belongs to the ESP8285 (its frames are not typed text)
poll_byte:
    push {lr}
    ldr  r1, poll_byte_esp
    ldr  r1, [r1]
    cmp  r1, #0
    bne  pb_usb
    ldr  r1, poll_byte_uart0
pb_uart:
    ldr  r2, [r1, #UARTFR]
    lsls r2, r2, #27            ; RXFE (bit 4) into N
    bmi  pb_usb
    ldr  r0, [r1, #UARTDR]
    lsls r2, r0, #20
    lsrs r2, r2, #28            ; the errors (bits 11 .. 8)
    bne  pb_uart
    uxtb r0, r0
    movs r1, #0
    b    pb_src
pb_usb:
    bl   usb_getc
    cmp  r0, #0
    blt  pb_end
    movs r1, #1
pb_src:
    ldr  r2, poll_byte_vars
    str  r1, [r2, #V_SRC]
pb_end:
    pop  {pc}

    align 4
poll_byte_uart0: dd UART0
poll_byte_vars:  dd VARS
poll_byte_esp:   dd WLV + WL_ESP

; the next byte in into r0 (waits for one), from UART0 or over USB
get_char:
    push {lr}
gc_wait:
    bl   poll_byte
    cmp  r0, #0
    blt  gc_wait
    pop  {pc}

; the next byte that comes within r0 milliseconds (at most 1000) in r0, -1 when none came
wait_byte:
    push {r4, r5, lr}
    ldr  r1, wait_byte_us_ms
    mov  r4, r0
    muls r4, r1             ; the microseconds to wait
    bl   tick_now
    mov  r5, r0                 ; the start
wb_loop:
    bl   poll_byte
    cmp  r0, #0
    bge  wb_got
    bl   tick_now
    subs r0, r0, r5             ; the microseconds since the start
    cmp  r0, r4
    blo  wb_loop
    movs r0, #0
    subs r0, r0, #1
wb_got:
    pop  {r4, r5, pc}

    align 4
wait_byte_us_ms: dd US_MS

; ---------- output ----------

; the text behind the call (up to its 0, then align 2), back behind it
print_inline:
    push {r4, lr}
    mov  r4, lr
    subs r4, r4, #1             ; lr has the Thumb bit
pi_next:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  pi_end
    bl   put_char
    adds r4, r4, #1
    b    pi_next
pi_end:
    adds r4, r4, #2
    movs r0, #1
    orrs r4, r0                 ; behind the 0, at the next halfword, with the Thumb bit
    str  r4, [sp, #4]           ; the way back
    pop  {r4, pc}

; the text at r0 up to its 0
put_text:
    push {r4, lr}
    mov  r4, r0
pt_next:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  pt_end
    bl   put_char
    adds r4, r4, #1
    b    pt_next
pt_end:
    pop  {r4, pc}

put_nl:
    push {lr}
    movs r0, #13
    bl   put_char
    movs r0, #10
    bl   put_char
    pop  {pc}

put_space:
    movs r0, #' '
    b    put_char

; r0 in hexadecimal, r1 digits
put_hex:
    push {r4, r5, lr}
    mov  r4, r0
    mov  r5, r1
ph_next:
    subs r5, r5, #1
    bmi  ph_end
    lsls r1, r5, #2
    mov  r0, r4
    lsrs r0, r1
    movs r1, #15
    ands r0, r1
    cmp  r0, #10
    blt  ph_digit
    adds r0, #39            ; 'a' - 10 - '0'
ph_digit:
    adds r0, #'0'
    bl   put_char
    b    ph_next
ph_end:
    pop  {r4, r5, pc}

put_hex8:
    movs r1, #8
    b    put_hex

; r0 (unsigned) in decimal
put_dec:
    push {r4, r5, r6, lr}
    sub  sp, #12
    mov  r4, r0
    movs r6, #0
pd_div:
    mov  r0, r4
    movs r1, #10
    bl   udiv32
    adds r1, #'0'
    mov  r2, sp
    strb r1, [r2, r6]
    adds r6, r6, #1
    mov  r4, r0
    cmp  r4, #0
    bne  pd_div
pd_out:
    subs r6, r6, #1
    mov  r2, sp
    ldrb r0, [r2, r6]
    bl   put_char
    cmp  r6, #0
    bne  pd_out
    add  sp, #12
    pop  {r4, r5, r6, pc}

; r0 in decimal, right-aligned in r1 places
put_dec_w:
    push {r4, r5, r6, lr}
    mov  r4, r0
    mov  r5, r1
    movs r6, #1                 ; its digits
pw_count:
    cmp  r0, #10
    blo  pw_pad
    movs r1, #10
    bl   udiv32
    adds r6, r6, #1
    b    pw_count
pw_pad:
    cmp  r6, r5
    bge  pw_out
    bl   put_space
    adds r6, r6, #1
    b    pw_pad
pw_out:
    mov  r0, r4
    bl   put_dec
    pop  {r4, r5, r6, pc}

; r0 / r1 (unsigned, r1 not 0 and below 2^31): r0 the quotient, r1 the remainder (the Cortex-M0+ has no division)
udiv32:
    push {r4, lr}
    movs r2, #0                 ; the quotient
    movs r3, #0                 ; the remainder
    movs r4, #32
ud_bit:
    lsls r0, r0, #1             ; the next bit of the dividend into the carry ...
    adcs r3, r3                 ; ... and into the remainder
    lsls r2, r2, #1
    cmp  r3, r1
    blo  ud_next
    subs r3, r3, r1
    adds r2, r2, #1
ud_next:
    subs r4, r4, #1
    bne  ud_bit
    mov  r0, r2
    mov  r1, r3
    pop  {r4, pc}

; ---------- input ----------

; a line into LINE (echo, Backspace, Ctrl+C throws it away, CR or LF ends it, the LF of CR LF is skipped); r0 = LINE.
; An STX: packets from a program on the PC (packet_mode), then the line again from its start, without an echo
read_line:
    push {r4, r5, r6, lr}
    ldr  r5, read_line_line
    movs r4, #0                 ; its length
    movs r6, #0                 ; the byte before
rl_next:
    bl   poll_byte
    cmp  r0, #0
    bge  rl_got
    mov  r0, r4                     ; (what was typed: LINE, r4 bytes)
    bl   wifi_idle                  ; (console_wifi.asm) while no byte comes: the WiFi at the start, the lease
    b    rl_next
rl_got:
    bl   wifi_key                   ; (console_wifi.asm) the time of the last byte (r0 stays)
    cmp  r0, #2
    bne  rl_not_stx
    ldr  r1, read_line_vars
    ldr  r2, [r1, #V_SRC]
    str  r2, [r1, #V_PKT_USB]       ; the STX came over USB: the answers go there only
    bl   packet_mode
    ldr  r1, read_line_vars
    movs r2, #0
    str  r2, [r1, #V_PKT_USB]
    movs r4, #0
    movs r6, #0
    cmp  r0, #0
    beq  rl_next
    bl   print_inline
    db   '> ', 0
    align 2
    b    rl_next
rl_not_stx:
    cmp  r0, #10
    bne  rl_not_lf
    mov  r1, r6                 ; the byte before
    mov  r6, r0
    cmp  r1, #13
    beq  rl_next                ; the LF of CR LF
    b    rl_done
rl_not_lf:
    mov  r6, r0
    cmp  r0, #13
    beq  rl_done
    cmp  r0, #3
    beq  rl_ctrl_c
    cmp  r0, #8
    beq  rl_back
    cmp  r0, #127
    beq  rl_back
    cmp  r0, #' '
    blt  rl_next
    cmp  r0, #127
    bge  rl_next
    cmp  r4, #LINE_MAX
    bge  rl_next
    strb r0, [r5, r4]
    adds r4, r4, #1
    bl   put_char
    b    rl_next
rl_back:
    cmp  r4, #0
    beq  rl_next
    subs r4, r4, #1
    bl   print_inline
    db   8, ' ', 8, 0
    align 2
    b    rl_next
rl_ctrl_c:
    bl   print_inline
    db   '^C', 0
    align 2
    movs r4, #0
rl_done:
    movs r0, #0
    strb r0, [r5, r4]
    bl   put_nl
    mov  r0, r5
    pop  {r4, r5, r6, pc}

    align 4
read_line_line: dd LINE
read_line_vars: dd VARS

; r0 behind the spaces of the text at r0
skip_spaces:
    ldrb r1, [r0]
    cmp  r1, #' '
    bne  ss_end
    adds r0, r0, #1
    b    skip_spaces
ss_end:
    bx   lr

; the word behind the call (up to its 0, then align 2) at the start of the text r0, followed by a space or the end?
; r0 = behind it in the text, else 0; back behind the word
match_inline:
    push {r4, r5, lr}
    mov  r1, lr
    subs r1, r1, #1
    mov  r2, r0
mi_next:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  mi_word_end
    ldrb r4, [r2]
    cmp  r4, r3
    bne  mi_differs
    adds r1, r1, #1
    adds r2, r2, #1
    b    mi_next
mi_differs:
    movs r2, #0
mi_skip:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  mi_done
    adds r1, r1, #1
    b    mi_skip
mi_word_end:
    ldrb r4, [r2]
    cmp  r4, #0
    beq  mi_done
    cmp  r4, #' '
    beq  mi_done
    movs r2, #0                 ; a longer word ("helpx")
mi_done:
    adds r1, r1, #2
    movs r3, #1
    orrs r1, r3
    str  r1, [sp, #8]
    mov  r0, r2
    pop  {r4, r5, pc}

; a number at r0 (after spaces): hexadecimal with 0x, else decimal, up to a space or the end. r0 its value, r1 behind
; it, r2 = 1 when it was one (at least one digit, nothing else), else 0
parse_number:
    push {r4, lr}
    bl   skip_spaces
    mov  r1, r0
    movs r0, #0
    movs r2, #0                 ; digits
    ldrb r3, [r1]
    cmp  r3, #'0'
    bne  pn_dec
    ldrb r3, [r1, #1]
    movs r4, #0x20
    orrs r3, r4
    cmp  r3, #'x'
    bne  pn_dec
    adds r1, r1, #2
pn_hex:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  pn_end
    cmp  r3, #' '
    beq  pn_end
    mov  r4, r3
    subs r4, #'0'
    cmp  r4, #10
    blo  pn_hex_digit
    movs r4, #0x20
    orrs r3, r4
    mov  r4, r3
    subs r4, #'a'
    cmp  r4, #6
    bhs  pn_bad
    adds r4, #10
pn_hex_digit:
    lsls r0, r0, #4
    orrs r0, r4
    adds r2, r2, #1
    adds r1, r1, #1
    b    pn_hex
pn_dec:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  pn_end
    cmp  r3, #' '
    beq  pn_end
    mov  r4, r3
    subs r4, #'0'
    cmp  r4, #10
    bhs  pn_bad
    movs r3, #10
    muls r0, r3
    adds r0, r0, r4
    adds r2, r2, #1
    adds r1, r1, #1
    b    pn_dec
pn_bad:
    movs r2, #0
    pop  {r4, pc}
pn_end:
    cmp  r2, #0
    beq  pn_bad
    movs r2, #1
    pop  {r4, pc}

; the name at r0 (after spaces, up to a space or the end, at most 19 characters) into the field V_NAME (zeros behind
; it); r0 = its length (0: none, -1: too long)
name_field:
    push {r4, lr}
    bl   skip_spaces
    ldr  r1, name_field_vars_v_name
    movs r2, #0
    movs r3, #0
nf_clear:
    str  r3, [r1, r2]
    adds r2, r2, #4
    cmp  r2, #20
    blt  nf_clear
    movs r2, #0
nf_next:
    ldrb r3, [r0, r2]
    cmp  r3, #0
    beq  nf_end
    cmp  r3, #' '
    beq  nf_end
    cmp  r2, #19
    bge  nf_long
    strb r3, [r1, r2]
    adds r2, r2, #1
    b    nf_next
nf_long:
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, pc}
nf_end:
    adds r1, r0, r2             ; behind the name
    mov  r0, r2
    pop  {r4, pc}

    align 4
name_field_vars_v_name: dd VARS + V_NAME

; ---------- the CRC-32 (zlib) ----------

crc_init:
    push {r4, r5, lr}
    ldr  r0, crc_init_crctab
    ldr  r3, crc_init_poly
    movs r1, #0                 ; the byte
ct_byte:
    mov  r2, r1
    movs r4, #8
ct_bit:
    lsrs r2, r2, #1
    bcc  ct_nopoly
    eors r2, r3
ct_nopoly:
    subs r4, r4, #1
    bne  ct_bit
    lsls r5, r1, #2
    str  r2, [r0, r5]
    adds r1, r1, #1
    cmp  r1, #255
    bls  ct_byte
    pop  {r4, r5, pc}

    align 4
crc_init_crctab:    dd CRCTAB
crc_init_poly:      dd 0xedb88320       ; the polynomial, reflected

; the CRC r0 (0 at the start, or the one of the bytes before) of r2 bytes at r1 more: r0
crc32:
    push {r4, r5, lr}
    ldr  r4, crc32_crctab
    mvns r0, r0
cr_next:
    cmp  r2, #0
    beq  cr_end
    ldrb r3, [r1]
    eors r3, r0
    uxtb r3, r3
    lsls r3, r3, #2
    ldr  r5, [r4, r3]
    lsrs r0, r0, #8
    eors r0, r5
    adds r1, r1, #1
    subs r2, r2, #1
    b    cr_next
cr_end:
    mvns r0, r0
    pop  {r4, r5, pc}

    align 4
crc32_crctab:   dd CRCTAB

; ---------- the flash: the functions of the boot ROM ----------

; the function of the boot ROM with the code r0 (two letters, the first in the low byte): its address (with the
; Thumb bit) in r0, 0 when there is none. The table (its address in the halfword at 0x14): pairs of halfwords, the
; code and the address of the function; a code 0 ends it
rom_find:
    movs r1, #0x14
    ldrh r1, [r1]               ; the table
rf_next:
    ldrh r2, [r1]               ; the code
    cmp  r2, #0
    beq  rf_none
    cmp  r2, r0
    beq  rf_found
    adds r1, r1, #4
    b    rf_next
rf_found:
    ldrh r0, [r1, #2]
    movs r1, #1
    orrs r0, r1
    bx   lr
rf_none:
    movs r0, #0
    bx   lr

; the six functions for the flash into V_FN (0 for one that is not there)
rom_init:
    push {r4, r5, lr}
    ldr  r4, rom_init_vars_v_fn
    ldr  r0, rom_init_i_f_8
    bl   rom_find
    str  r0, [r4]
    ldr  r0, rom_init_ke_x_8
    bl   rom_find
    str  r0, [r4, #4]
    ldr  r0, rom_init_r_e_8
    bl   rom_find
    str  r0, [r4, #8]
    ldr  r0, rom_init_r_p_8
    bl   rom_find
    str  r0, [r4, #12]
    ldr  r0, rom_init_kf_c_8
    bl   rom_find
    str  r0, [r4, #16]
    ldr  r0, rom_init_kc_x_8
    bl   rom_find
    str  r0, [r4, #20]
    ; one missing: none of them (main says so)
    movs r5, #0
ri_check:
    ldr  r0, [r4, r5]
    cmp  r0, #0
    beq  ri_none
    adds r5, r5, #4
    cmp  r5, #24
    blt  ri_check
    pop  {r4, r5, pc}
ri_none:
    movs r0, #0
    str  r0, [r4, #20]
    pop  {r4, r5, pc}

    align 4
rom_init_vars_v_fn: dd VARS + V_FN
rom_init_i_f_8:     dd ('I' | ('F' << 8))
rom_init_ke_x_8:    dd ('E' | ('X' << 8))
rom_init_r_e_8:     dd ('R' | ('E' << 8))
rom_init_r_p_8:     dd ('R' | ('P' << 8))
rom_init_kf_c_8:    dd ('F' | ('C' << 8))
rom_init_kc_x_8:    dd ('C' | ('X' << 8))

; calls the function r3 of V_FN (its offset) with r0 .. r2 and a fourth argument from the stack ...: see below
; the flash ready to be written: connect_internal_flash, flash_exit_xip (the XIP window gives nothing from now on)
flash_open:
    push {r4, lr}
    ldr  r4, flash_open_vars_v_fn
    ldr  r3, [r4]
    blx  r3
    ldr  r3, [r4, #4]
    blx  r3
    pop  {r4, pc}

    align 4
flash_open_vars_v_fn: dd VARS + V_FN

; the flash readable through the XIP window again: flash_flush_cache, flash_enter_cmd_xip
flash_close:
    push {r4, lr}
    ldr  r4, flash_close_vars_v_fn
    ldr  r3, [r4, #16]
    blx  r3
    ldr  r3, [r4, #20]
    blx  r3
    pop  {r4, pc}

    align 4
flash_close_vars_v_fn: dd VARS + V_FN

; r1 bytes of the flash from its place r0 erased (both multiples of 4 KB): flash_range_erase(r0, r1, 4096, 0x20)
flash_erase:
    push {r4, lr}
    ldr  r4, flash_erase_vars_v_fn
    ldr  r2, flash_erase_k4096
    movs r3, #0x20
    ldr  r4, [r4, #8]
    blx  r4
    pop  {r4, pc}

    align 4
flash_erase_vars_v_fn: dd VARS + V_FN
flash_erase_k4096:     dd 4096

; r2 bytes (a multiple of 256) from r1 into the flash at its place r0 (a multiple of 256): flash_range_program
flash_program:
    push {r4, lr}
    ldr  r4, flash_program_vars_v_fn
    ldr  r4, [r4, #12]
    blx  r4
    pop  {r4, pc}

    align 4
flash_program_vars_v_fn: dd VARS + V_FN

; ---------- the directory ----------

; the directory at r0 (in the flash, through XIP) valid? r0 1 or 0
dir_valid:
    push {r4, lr}
    mov  r4, r0
    ldr  r1, [r4]
    ldr  r2, dir_valid_magic
    cmp  r1, r2
    bne  dv_no
    movs r0, #0
    movs r1, #32
    adds r1, r1, r4
    ldr  r2, dir_valid_entries_32
    bl   crc32
    movs r1, #12
    adds r1, r1, r4
    movs r2, #4
    bl   crc32
    ldr  r1, [r4, #8]
    cmp  r0, r1
    bne  dv_no
    movs r0, #1
    pop  {r4, pc}
dv_no:
    movs r0, #0
    pop  {r4, pc}

    align 4
dir_valid_magic:      dd MAGIC
dir_valid_entries_32: dd ENTRIES * 32

; the valid directory with the higher number into DIRBUF (V_FSOK, V_DIRSEC)
dir_load:
    push {r4, r5, r6, lr}
    ldr  r4, dir_load_flash_base_fs_sector_4096
    mov  r0, r4
    bl   dir_valid
    mov  r5, r0
    movs r0, #1
    lsls r0, r0, #12
    adds r0, r0, r4
    bl   dir_valid
    mov  r6, r0
    cmp  r5, #0
    beq  dl_one
    cmp  r6, #0
    beq  dl_zero
    ldr  r0, [r4, #4]
    movs r1, #1
    lsls r1, r1, #12
    adds r1, r1, r4
    ldr  r1, [r1, #4]
    cmp  r1, r0
    bhi  dl_first               ; the second one is newer
    b    dl_zero
dl_one:
    cmp  r6, #0
    beq  dl_none
dl_first:
    movs r0, #1
    lsls r0, r0, #12
    adds r4, r4, r0
    ldr  r5, dir_load_fs_sector_1
    b    dl_copy
dl_zero:
    ldr  r5, dir_load_fs_sector
dl_copy:
    ldr  r0, dir_load_dirbuf
    movs r1, #0
dl_word:
    ldr  r2, [r4, r1]
    str  r2, [r0, r1]
    adds r1, r1, #4
    lsrs r2, r1, #12            ; 4096 reached?
    beq  dl_word
    ldr  r0, dir_load_vars
    str  r5, [r0, #V_DIRSEC]
    movs r1, #1
    str  r1, [r0, #V_FSOK]
    pop  {r4, r5, r6, pc}
dl_none:
    ldr  r0, dir_load_vars
    movs r1, #0
    str  r1, [r0, #V_FSOK]
    pop  {r4, r5, r6, pc}

    align 4
dir_load_flash_base_fs_sector_4096: dd FLASH_BASE + FS_SECTOR * 4096
dir_load_fs_sector_1:               dd FS_SECTOR + 1
dir_load_fs_sector:                 dd FS_SECTOR
dir_load_dirbuf:                    dd DIRBUF
dir_load_vars:                      dd VARS

; DIRBUF with a number one higher and its CRC into the other sector of the directory; r0 0, or -1 when the boot ROM
; has not the functions for the flash
dir_save:
    push {r4, r5, lr}
    ldr  r4, dir_save_dirbuf
    ldr  r5, dir_save_vars
    ldr  r0, [r5, #V_FN + 20]
    cmp  r0, #0
    beq  ds_err
    ldr  r0, [r4, #4]
    adds r0, r0, #1
    str  r0, [r4, #4]
    bl   dir_crc
    ldr  r0, [r5, #V_DIRSEC]
    movs r1, #1
    eors r0, r1                 ; 0x100 <-> 0x101
    str  r0, [r5, #V_DIRSEC]
    bl   flash_open
    ldr  r0, [r5, #V_DIRSEC]
    lsls r0, r0, #12
    ldr  r1, dir_save_k4096
    bl   flash_erase
    ldr  r0, [r5, #V_DIRSEC]
    lsls r0, r0, #12
    mov  r1, r4
    ldr  r2, dir_save_k4096
    bl   flash_program
    bl   flash_close
    movs r0, #0
    pop  {r4, r5, pc}
ds_err:
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, pc}

    align 4
dir_save_dirbuf: dd DIRBUF
dir_save_vars:   dd VARS
dir_save_k4096:  dd 4096

; the CRC of DIRBUF into its word at +8
dir_crc:
    push {r4, lr}
    ldr  r4, dir_crc_dirbuf
    movs r0, #0
    movs r1, #32
    adds r1, r1, r4
    ldr  r2, dir_crc_entries_32
    bl   crc32
    movs r1, #12
    adds r1, r1, r4
    movs r2, #4
    bl   crc32
    str  r0, [r4, #8]
    pop  {r4, pc}

    align 4
dir_crc_dirbuf:     dd DIRBUF
dir_crc_entries_32: dd ENTRIES * 32

; a new, empty file system: the second directory erased (its number may be higher), the first one written with the
; number 1; r0 0, or -1 (no functions for the flash)
make_fs:
    push {r4, r5, lr}
    ldr  r5, make_fs_vars
    ldr  r0, [r5, #V_FN + 20]
    cmp  r0, #0
    beq  mf_err
    ldr  r4, make_fs_dirbuf
    movs r0, #0
    movs r1, #0
mf_clear:
    str  r0, [r4, r1]
    adds r1, r1, #4
    lsrs r2, r1, #12
    beq  mf_clear
    ldr  r0, make_fs_magic
    str  r0, [r4]
    movs r0, #1
    str  r0, [r4, #4]
    bl   dir_crc
    bl   flash_open
    ldr  r0, make_fs_fs_sector_4096
    ldr  r1, make_fs_k8192
    bl   flash_erase
    ldr  r0, make_fs_fs_sector_4096
    mov  r1, r4
    ldr  r2, make_fs_k4096
    bl   flash_program
    bl   flash_close
    ldr  r0, make_fs_fs_sector
    str  r0, [r5, #V_DIRSEC]
    movs r0, #1
    str  r0, [r5, #V_FSOK]
    movs r0, #0
    str  r0, [r5, #V_OPEN]
    pop  {r4, r5, pc}
mf_err:
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, pc}

    align 4
make_fs_vars:           dd VARS
make_fs_dirbuf:         dd DIRBUF
make_fs_magic:          dd MAGIC
make_fs_fs_sector_4096: dd FS_SECTOR * 4096
make_fs_k8192:          dd 8192
make_fs_k4096:          dd 4096
make_fs_fs_sector:      dd FS_SECTOR

; the entry of the name field r0 (20 bytes, zeros behind the name) in DIRBUF: r0, or 0 when there is none
find_entry:
    push {r4, r5, r6, lr}
    mov  r4, r0
    ldr  r5, find_entry_dirbuf_32
    movs r6, #0
fe_next:
    ldrb r0, [r5]
    cmp  r0, #0
    beq  fe_skip
    movs r1, #0
fe_byte:
    ldrb r2, [r5, r1]
    ldrb r3, [r4, r1]
    cmp  r2, r3
    bne  fe_skip
    cmp  r2, #0
    beq  fe_found
    adds r1, r1, #1
    cmp  r1, #20
    blt  fe_byte
fe_found:
    mov  r0, r5
    pop  {r4, r5, r6, pc}
fe_skip:
    adds r5, #32
    adds r6, r6, #1
    cmp  r6, #ENTRIES
    blt  fe_next
    movs r0, #0
    pop  {r4, r5, r6, pc}

    align 4
find_entry_dirbuf_32: dd DIRBUF + 32

; a free entry in DIRBUF: r0, or 0 when all are taken
free_entry:
    ldr  r0, free_entry_dirbuf_32
    movs r1, #0
fr_next:
    ldrb r2, [r0]
    cmp  r2, #0
    beq  fr_found
    adds r0, #32
    adds r1, r1, #1
    cmp  r1, #ENTRIES
    blt  fr_next
    movs r0, #0
fr_found:
    bx   lr

    align 4
free_entry_dirbuf_32: dd DIRBUF + 32

; the first gap of r0 sectors among the files (from FS_FIRST): its first sector in r0, 0 when there is none
find_gap:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0                 ; the sectors
    ldr  r5, find_gap_fs_first          ; the candidate
fg_again:
    adds r0, r5, r4
    movs r1, #FS_END >> 1
    lsls r1, r1, #1
    cmp  r0, r1
    bhi  fg_none
    ldr  r6, find_gap_dirbuf_32
    movs r7, #0
fg_entry:
    ldrb r0, [r6]
    cmp  r0, #0
    beq  fg_skip
    ldr  r1, [r6, #24]          ; the length
    cmp  r1, #0
    beq  fg_skip
    ldr  r0, [r6, #20]          ; its first sector
    subs r1, r1, #1
    lsrs r1, r1, #12
    adds r1, r1, #1             ; its sectors (it is not empty)
    adds r1, r1, r0             ; behind it
    cmp  r5, r1
    bhs  fg_skip                ; the candidate behind it
    adds r2, r5, r4
    cmp  r0, r2
    bhs  fg_skip                ; it behind the candidate
    mov  r5, r1                 ; they overlap: behind it
    b    fg_again
fg_skip:
    adds r6, #32
    adds r7, r7, #1
    cmp  r7, #ENTRIES
    blt  fg_entry
    mov  r0, r5
    pop  {r4, r5, r6, r7, pc}
fg_none:
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

    align 4
find_gap_fs_first:  dd FS_FIRST
find_gap_dirbuf_32: dd DIRBUF + 32

; the bytes in use by the files (whole sectors) in r0, the files in r1
dir_used:
    ldr  r2, dir_used_dirbuf_32
    movs r0, #0
    movs r1, #0
    push {r4, r5}
    movs r4, #0
du_next:
    ldrb r3, [r2]
    cmp  r3, #0
    beq  du_skip
    adds r1, r1, #1
    ldr  r3, [r2, #24]
    cmp  r3, #0
    beq  du_skip                ; an empty file: no sectors
    subs r3, r3, #1
    lsrs r3, r3, #12
    adds r3, r3, #1
    lsls r3, r3, #12            ; whole sectors
    adds r0, r0, r3
du_skip:
    adds r2, #32
    adds r4, r4, #1
    cmp  r4, #ENTRIES
    blt  du_next
    pop  {r4, r5}
    bx   lr

    align 4
dir_used_dirbuf_32: dd DIRBUF + 32

; ---------- the commands for a terminal ----------

; the line at r0: its command
command:
    push {r4, lr}
    bl   skip_spaces
    mov  r4, r0
    ldrb r1, [r4]
    cmp  r1, #0
    bne  cm_word
    pop  {r4, pc}               ; an empty line
cm_word:
    mov  r0, r4
    bl   wifi_command           ; (console_wifi.asm) wlan
    cmp  r0, #0
    beq  cm_words
    pop  {r4, pc}
cm_words:
    mov  r0, r4
    bl   match_inline
    db   'ls', 0
    align 2
    cmp  r0, #0
    bne  cm_ls
    mov  r0, r4
    bl   match_inline
    db   'run', 0
    align 2
    cmp  r0, #0
    bne  cm_run
    mov  r0, r4
    bl   match_inline
    db   'boot', 0
    align 2
    cmp  r0, #0
    bne  cm_boot
    mov  r0, r4
    bl   match_inline
    db   'noboot', 0
    align 2
    cmp  r0, #0
    bne  cm_noboot
    mov  r0, r4
    bl   match_inline
    db   'cat', 0
    align 2
    cmp  r0, #0
    bne  cm_cat
    mov  r0, r4
    bl   match_inline
    db   'rm', 0
    align 2
    cmp  r0, #0
    bne  cm_rm
    mov  r0, r4
    bl   match_inline
    db   'df', 0
    align 2
    cmp  r0, #0
    bne  cm_df
    mov  r0, r4
    bl   match_inline
    db   'format', 0
    align 2
    cmp  r0, #0
    bne  cm_format
    mov  r0, r4
    bl   match_inline
    db   'help', 0
    align 2
    cmp  r0, #0
    bne  cm_help
    mov  r0, r4
    bl   match_inline
    db   'info', 0
    align 2
    cmp  r0, #0
    bne  cm_info
    mov  r0, r4
    bl   match_inline
    db   'reset', 0
    align 2
    cmp  r0, #0
    bne  cm_reset
    ; any other word: a program of that name
    mov  r0, r4
    movs r1, #1
    bl   cmd_run
    cmp  r0, #0
    bne  cm_end
    mov  r0, r4
    bl   put_text
    bl   print_inline
    db   ': no such command (help: the commands)', 13, 10, 0
    align 2
cm_end:
    pop  {r4, pc}
cm_run:
    movs r1, #0
    bl   cmd_run
    pop  {r4, pc}
cm_boot:
    bl   cmd_boot
    pop  {r4, pc}
cm_noboot:
    bl   cmd_noboot
    pop  {r4, pc}
cm_ls:
    bl   cmd_ls
    pop  {r4, pc}
cm_cat:
    bl   cmd_cat
    pop  {r4, pc}
cm_rm:
    bl   cmd_rm
    pop  {r4, pc}
cm_df:
    bl   cmd_df
    pop  {r4, pc}
cm_format:
    bl   cmd_format
    pop  {r4, pc}
cm_help:
    bl   cmd_help
    pop  {r4, pc}
cm_info:
    bl   cmd_info
    pop  {r4, pc}
cm_reset:
    bl   cmd_reset
    pop  {r4, pc}

; help: the file help.txt (Prepare Board writes it, boards\pico\help.txt), else the short list
cmd_help:
    push {lr}
    ldr  r0, cmd_help_vars
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    beq  hp_short
    adr  r0, hp_name
    bl   find_entry
    cmp  r0, #0
    beq  hp_short
    bl   cat_entry
    pop  {pc}
hp_short:
    bl   print_inline
    db   '  ls cat rm df format run boot noboot info reset wlan name passwd help, or a program: name [args]', 13, 10
    db   '  (help.txt is missing: "Prepare Board..." in the Board Manager writes it)', 13, 10, 0
    align 2
    pop  {pc}
    align 4
cmd_help_vars: dd VARS
hp_name:       db 'help.txt', 0
    align 2

; r0 1 when there is a file system, else 0 and a line that says so
need_fs:
    push {lr}
    ldr  r0, need_fs_vars
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    bne  nfs_ok
    bl   print_inline
    db   'no file system (format makes one)', 13, 10, 0
    align 2
    movs r0, #0
nfs_ok:
    pop  {pc}

    align 4
need_fs_vars: dd VARS

; ls: the name, the length, the program for boot; the files and their bytes
cmd_ls:
    push {r4, r5, r6, r7, lr}
    bl   need_fs
    cmp  r0, #0
    beq  ls_done
    ldr  r4, cmd_ls_dirbuf_32
    movs r5, #0                 ; the entry
    movs r7, #0                 ; files shown
ls_next:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  ls_skip
    adds r7, r7, #1
    bl   put_space
    bl   put_space
    mov  r0, r4
    bl   put_text
    mov  r0, r4
    movs r6, #0
ls_len:
    ldrb r1, [r0, r6]
    cmp  r1, #0
    beq  ls_pad
    adds r6, r6, #1
    b    ls_len
ls_pad:
    cmp  r6, #20
    bge  ls_size
    bl   put_space
    adds r6, r6, #1
    b    ls_pad
ls_size:
    ldr  r0, [r4, #24]
    movs r1, #8
    bl   put_dec_w
    ldr  r0, cmd_ls_dirbuf
    ldr  r0, [r0, #12]
    subs r0, r0, #1
    cmp  r0, r5
    bne  ls_nl
    bl   print_inline
    db   '  starts after a reset', 0
    align 2
ls_nl:
    bl   put_nl
ls_skip:
    adds r4, #32
    adds r5, r5, #1
    cmp  r5, #ENTRIES
    blt  ls_next
    cmp  r7, #0
    bne  ls_done
    bl   print_inline
    db   'no files', 13, 10, 0
    align 2
ls_done:
    pop  {r4, r5, r6, r7, pc}

    align 4
cmd_ls_dirbuf_32: dd DIRBUF + 32
cmd_ls_dirbuf:    dd DIRBUF

; df: the files, the bytes in use, the bytes free
cmd_df:
    push {r4, r5, lr}
    bl   need_fs
    cmp  r0, #0
    beq  df_done
    bl   dir_used
    mov  r4, r0
    mov  r0, r1
    bl   put_dec
    bl   print_inline
    db   ' file(s), ', 0
    align 2
    mov  r0, r4
    bl   put_dec
    bl   print_inline
    db   ' bytes in use, ', 0
    align 2
    ldr  r0, cmd_df_fs_end_fs_first_4096
    subs r0, r0, r4
    bl   put_dec
    bl   print_inline
    db   ' bytes free', 13, 10, 0
    align 2
df_done:
    pop  {r4, r5, pc}

    align 4
cmd_df_fs_end_fs_first_4096: dd (FS_END - FS_FIRST) * 4096

; the name after the command at r0 into V_NAME and its entry: r0, or 0 (and a line why)
named_entry:
    push {lr}
    bl   name_field
    cmp  r0, #0
    bgt  ne_find
    bl   print_inline
    db   'which file?', 13, 10, 0
    align 2
    movs r0, #0
    pop  {pc}
ne_find:
    bl   need_fs
    cmp  r0, #0
    beq  ne_none
    ldr  r0, named_entry_vars_v_name
    bl   find_entry
    cmp  r0, #0
    bne  ne_done
    bl   print_inline
    db   'no such file', 13, 10, 0
    align 2
ne_none:
    movs r0, #0
ne_done:
    pop  {pc}

    align 4
named_entry_vars_v_name: dd VARS + V_NAME

; cat name: the file as text (LF as CR LF, other control characters as a dot)
cmd_cat:
    push {r4, r5, r6, lr}
    bl   named_entry
    cmp  r0, #0
    beq  cat_done
    b    cat_go
; the file of the entry r0 as text (help: help.txt)
cat_entry:
    push {r4, r5, r6, lr}
cat_go:
    ldr  r5, [r0, #24]          ; the length
    ldr  r4, [r0, #20]
    lsls r4, r4, #12
    movs r0, #1
    lsls r0, r0, #28
    adds r4, r4, r0    ; its bytes through XIP
    movs r6, #0
cat_next:
    cmp  r6, r5
    bge  cat_end
    ldrb r0, [r4, r6]
    cmp  r0, #10
    bne  cat_cr
    bl   put_nl
    b    cat_step
cat_cr:
    cmp  r0, #13
    beq  cat_step
    cmp  r0, #9
    beq  cat_put
    cmp  r0, #' '
    blt  cat_dot
    cmp  r0, #127
    blt  cat_put
cat_dot:
    movs r0, #'.'
cat_put:
    bl   put_char
cat_step:
    adds r6, r6, #1
    b    cat_next
cat_end:
    cmp  r5, #0
    beq  cat_done
    subs r0, r5, #1
    ldrb r0, [r4, r0]
    cmp  r0, #10
    beq  cat_done
    bl   put_nl
cat_done:
    pop  {r4, r5, r6, pc}

; rm name
cmd_rm:
    push {r4, lr}
    bl   named_entry
    cmp  r0, #0
    beq  rm_done
    bl   remove_entry
    cmp  r0, #0
    bne  rm_err
    bl   print_inline
    db   'removed', 13, 10, 0
    align 2
    b    rm_done
rm_err:
    bl   flash_error
rm_done:
    pop  {r4, pc}

flash_error:
    push {lr}
    bl   print_inline
    db   'the flash cannot be written (the boot ROM has not the functions)', 13, 10, 0
    align 2
    pop  {pc}

; the entry r0 away (and the program for boot when it was this one), the directory written: r0 0 or -1
remove_entry:
    push {r4, lr}
    ldr  r1, remove_entry_dirbuf_32
    subs r2, r0, r1
    lsrs r2, r2, #5
    adds r2, r2, #1             ; its number for boot
    ldr  r1, remove_entry_dirbuf
    ldr  r3, [r1, #12]
    cmp  r3, r2
    bne  re_clear
    movs r3, #0
    str  r3, [r1, #12]
re_clear:
    movs r1, #0
    movs r2, #0
re_word:
    str  r2, [r0, r1]
    adds r1, r1, #4
    cmp  r1, #32
    blt  re_word
    bl   dir_save
    pop  {r4, pc}

    align 4
remove_entry_dirbuf_32: dd DIRBUF + 32
remove_entry_dirbuf:    dd DIRBUF

; format: asks first
cmd_format:
    push {lr}
    bl   print_inline
    db   'a new, empty file system: all files are lost. Type yes: ', 0
    align 2
    bl   read_line
    bl   match_inline
    db   'yes', 0
    align 2
    cmp  r0, #0
    bne  fmt_go
    bl   print_inline
    db   'not formatted', 13, 10, 0
    align 2
    pop  {pc}
fmt_go:
    bl   make_fs
    cmp  r0, #0
    bne  fmt_err
    bl   print_inline
    db   'formatted', 13, 10, 0
    align 2
    pop  {pc}
fmt_err:
    bl   flash_error
    pop  {pc}

cmd_info:
    push {r4, r5, lr}
    ldr  r5, cmd_info_sysinfo
    ldr  r4, [r5]               ; CHIP_ID
    bl   print_inline
    db   'board     ', 0
    align 2
    bl   put_board
    bl   print_inline
    db   13, 10, 'chip      ', 0
    align 2
    lsls r0, r4, #4
    lsrs r0, r0, #16            ; PART (bits 27 .. 12): 2 for the RP2040
    cmp  r0, #2
    bne  ci_other
    bl   print_inline
    db   'RP2040, revision B', 0
    align 2
    lsrs r0, r4, #28            ; REVISION: 1 B0, 2 B1, 3 B2
    subs r0, r0, #1
    bl   put_dec
    bl   print_inline
    db   ' (CHIP_ID 0x', 0
    align 2
    b    ci_id
ci_other:
    bl   print_inline
    db   'not an RP2040 (CHIP_ID 0x', 0
    align 2
ci_id:
    mov  r0, r4
    bl   put_hex8
    bl   print_inline
    db   ')', 13, 10, 'cores     2 x Arm Cortex-M0+ (CPUID 0x', 0
    align 2
    ldr  r0, cmd_info_scb_cpuid
    ldr  r0, [r0]
    bl   put_hex8
    bl   print_inline
    db   '), 48 MHz (PLL_USB from the crystal)', 13, 10, 0
    align 2
    movs r0, #0x10
    ldr  r4, [r0]               ; the boot ROM: 'M', 'u', 1, its version
    lsls r0, r4, #8
    lsrs r0, r0, #8
    ldr  r1, cmd_info_rom_magic
    cmp  r0, r1
    bne  ci_console
    bl   print_inline
    db   'boot ROM  version ', 0
    align 2
    lsrs r0, r4, #24
    bl   put_dec
    bl   put_nl
ci_console:
    bl   print_inline
    db   'console   2, in the RAM at 0x', 0
    align 2
    ldr  r0, cmd_info_ram_base
    bl   put_hex8
    bl   print_inline
    db   ', ', 0
    align 2
    ldr  r0, cmd_info_size
    bl   put_dec
    bl   print_inline
    db   ' bytes', 13, 10, 'files     the flash from 0x10100000 to 0x101FE000 (behind: the WiFi network)', 13, 10, 0
    align 2
    pop  {r4, r5, pc}

    align 4
cmd_info_sysinfo:   dd SYSINFO
cmd_info_scb_cpuid: dd SCB_CPUID
cmd_info_rom_magic: dd 0x01754d
cmd_info_ram_base:  dd RAM_BASE
cmd_info_size:      dd image_end - vectors + 256

; reset: the last byte out of the UART, then the watchdog resets the chip (all but the oscillators, as the Pico SDK)
cmd_reset:
    bl   print_inline
    db   'reset', 13, 10, 0
    align 2
    bl   usb_flush                  ; the line to the host over USB too, and a moment for the PC to take it before the
    movs r0, #20                    ; device goes away (else Windows drops it)
    bl   wait_byte
    ldr  r1, cmd_reset_uart0
    movs r3, #UARTFR_BUSY
cr_wait:
    ldr  r2, [r1, #UARTFR]
    tst  r2, r3
    bne  cr_wait
    ldr  r1, cmd_reset_psm_wdsel
    ldr  r0, cmd_reset_wdsel_all
    str  r0, [r1]
    ldr  r1, cmd_reset_watchdog
    movs r0, #0
    str  r0, [r1, #0x1c]        ; SCRATCH4: no special start in the boot ROM
    movs r0, #1
    lsls r0, r0, #31            ; CTRL: TRIGGER
    str  r0, [r1]
cr_hang:
    b    cr_hang

    align 4
cmd_reset_uart0:        dd UART0
cmd_reset_psm_wdsel:    dd PSM_WDSEL
cmd_reset_wdsel_all:    dd PSM_WDSEL_ALL
cmd_reset_watchdog:     dd WATCHDOG

; ---------- the packets (for a program on the PC) ----------

; packets while they come (the STX of the first one came already)
packet_mode:
    push {r4, lr}
    movs r4, #1                 ; the STX is there
pm_next:
    mov  r0, r4
    bl   read_packet
    movs r4, #0
    cmp  r0, #1
    beq  pm_leave               ; a second without a packet
    cmp  r0, #0
    beq  pm_do
    bl   send_err_inline
    db   'The packet was damaged.', 0             ; (the text of the ESP32: TEspConsole sends it again)
    align 2
    b    pm_next
pm_do:
    bl   do_packet
    cmp  r0, #0
    beq  pm_next
    subs r0, r0, #1             ; Q: 0, a program ran: 1
    pop  {r4, pc}
pm_leave:
    movs r0, #0
    pop  {r4, pc}

; a packet into PKT: r0 1 when its STX came already. r0 0 a packet, 1 a second without an STX, 2 a damaged one
read_packet:
    push {r4, r5, r6, lr}
    ldr  r4, read_packet_pkt
    cmp  r0, #0
    bne  rp_head
rp_wait:
    ldr  r0, read_packet_k1000
    bl   wait_byte
    cmp  r0, #0
    blt  rp_idle
    cmp  r0, #2
    bne  rp_wait                ; other bytes: left out
rp_head:
    movs r5, #1
rp_hbyte:
    ldr  r0, read_packet_k500
    bl   wait_byte
    cmp  r0, #0
    blt  rp_broken
    strb r0, [r4, r5]           ; the command and the length at PKT+1
    adds r5, r5, #1
    cmp  r5, #4
    blt  rp_hbyte
    ldrh r6, [r4, #2]           ; the length
    ldr  r0, read_packet_k1100
    cmp  r6, r0
    bhi  rp_broken
    adds r6, r6, #4             ; the data and the CRC
    movs r5, #0
rp_dbyte:
    cmp  r5, r6
    beq  rp_check
    ldr  r0, read_packet_k500
    bl   wait_byte
    cmp  r0, #0
    blt  rp_broken
    adds r1, r4, #4
    strb r0, [r1, r5]
    adds r5, r5, #1
    b    rp_dbyte
rp_check:
    subs r6, r6, #4
    movs r0, #0
    adds r1, r4, #1
    adds r2, r6, #3
    bl   crc32
    adds r1, r4, #4
    adds r1, r1, r6             ; the CRC behind the data (it need not be at a whole word)
    ldrb r2, [r1]
    ldrb r3, [r1, #1]
    lsls r3, r3, #8
    orrs r2, r3
    ldrb r3, [r1, #2]
    lsls r3, r3, #16
    orrs r2, r3
    ldrb r3, [r1, #3]
    lsls r3, r3, #24
    orrs r2, r3
    cmp  r0, r2
    bne  rp_broken
    movs r0, #0
    pop  {r4, r5, r6, pc}
rp_idle:
    movs r0, #1
    pop  {r4, r5, r6, pc}
rp_broken:
    movs r0, #2
    pop  {r4, r5, r6, pc}

    align 4
read_packet_pkt:   dd PKT
read_packet_k1000: dd 1000
read_packet_k500:  dd 500
read_packet_k1100: dd 1100

; the packet r0 (its command) with the r2 bytes at r1
send_packet:
    push {r4, r5, r6, r7, lr}
    ; for file_write of a program (api_file_write): the answer kept, nothing sent
    ldr  r4, send_packet_vars
    ldr  r3, [r4, #V_FQUIET]
    cmp  r3, #0
    beq  sp_send
    str  r0, [r4, #V_FQUIET]
    str  r1, [r4, #V_FTEXT]
    pop  {r4, r5, r6, r7, pc}
sp_send:
    mov  r5, r1
    mov  r6, r2
    ldr  r4, send_packet_out
    strb r0, [r4, #1]
    strh r2, [r4, #2]
    movs r0, #0
    adds r1, r4, #1
    movs r2, #3
    bl   crc32
    mov  r1, r5
    mov  r2, r6
    bl   crc32
    mov  r7, r0                 ; the CRC
    movs r0, #2
    bl   put_char
    ldrb r0, [r4, #1]
    bl   put_char
    ldrb r0, [r4, #2]
    bl   put_char
    ldrb r0, [r4, #3]
    bl   put_char
sp_data:
    cmp  r6, #0
    beq  sp_crc
    ldrb r0, [r5]
    bl   put_char
    adds r5, r5, #1
    subs r6, r6, #1
    b    sp_data
sp_crc:
    uxtb r0, r7
    bl   put_char
    lsrs r0, r7, #8
    uxtb r0, r0
    bl   put_char
    lsrs r0, r7, #16
    uxtb r0, r0
    bl   put_char
    lsrs r0, r7, #24
    bl   put_char
    pop  {r4, r5, r6, r7, pc}

    align 4
send_packet_out: dd OUT
send_packet_vars: dd VARS

; k without data
send_ok:
    movs r0, #'k'
    movs r1, #0
    movs r2, #0
    b    send_packet

; e with the text behind the call (up to its 0, then align 2), back behind it
send_err_inline:
    push {r4, r5, lr}
    mov  r4, lr
    subs r4, r4, #1
    movs r5, #0
se_len:
    ldrb r0, [r4, r5]
    cmp  r0, #0
    beq  se_send
    adds r5, r5, #1
    b    se_len
se_send:
    movs r0, #'e'
    mov  r1, r4
    mov  r2, r5
    bl   send_packet
    adds r4, r4, r5
    adds r4, r4, #2
    movs r0, #1
    orrs r4, r0
    str  r4, [sp, #8]
    pop  {r4, r5, pc}

; the packet in PKT; r0 1 when it was Q (back to the terminal), else 0
do_packet:
    push {r4, lr}
    ldr  r4, do_packet_pkt
    ldrb r0, [r4, #1]
    cmp  r0, #'P'
    beq  dp_p
    cmp  r0, #'F'
    beq  dp_f
    cmp  r0, #'L'
    beq  dp_l
    cmp  r0, #'O'
    beq  dp_o
    cmp  r0, #'W'
    beq  dp_w
    cmp  r0, #'C'
    beq  dp_c
    cmp  r0, #'G'
    beq  dp_g
    cmp  r0, #'D'
    beq  dp_d
    cmp  r0, #'B'
    beq  dp_b
    cmp  r0, #'M'
    beq  dp_m
    cmp  r0, #'Y'
    beq  dp_y
    cmp  r0, #'K'
    beq  dp_k
    cmp  r0, #'S'
    beq  dp_s
    cmp  r0, #'Q'
    beq  dp_q
    cmp  r0, #'R'
    beq  dp_r
    cmp  r0, #'E'
    beq  dp_e
    cmp  r0, #'X'
    beq  dp_x
    cmp  r0, #'T'
    beq  dp_t
    cmp  r0, #'H'
    beq  dp_h
    cmp  r0, #'N'
    beq  dp_n
    cmp  r0, #'V'
    beq  dp_v
    cmp  r0, #'I'
    beq  dp_i
    bl   send_err_inline
    db   'Unknown packet.', 0                     ; (the text of the ESP32: TEspConsole knows an older console by it)
    align 2
    b    dp_done
dp_p:
    bl   pk_ping
    b    dp_done
dp_f:
    bl   pk_free
    b    dp_done
dp_l:
    bl   pk_list
    b    dp_done
dp_o:
    bl   pk_open
    b    dp_done
dp_w:
    bl   pk_write
    b    dp_done
dp_c:
    bl   pk_close
    b    dp_done
dp_g:
    bl   pk_get
    b    dp_done
dp_d:
    bl   pk_delete
    b    dp_done
dp_b:
    bl   pk_boot
    b    dp_done
dp_m:
    bl   pk_format
    b    dp_done
dp_y:
    bl   pk_flash
    b    dp_done
dp_k:
    bl   pk_crc
    b    dp_done
dp_s:
    bl   send_err_inline
    db   'the UART of the Pico stays at 115200 baud', 0
    align 2
    b    dp_done
dp_q:
    bl   send_ok
    movs r0, #1
    pop  {r4, pc}
dp_r:
    bl   pk_ram
    b    dp_done
dp_e:
    bl   pk_exec
    pop  {r4, pc}
dp_x:
    bl   pk_run
    pop  {r4, pc}
dp_t:
    bl   pk_debug               ; (console_mon.asm)
    pop  {r4, pc}
dp_h:
    bl   pk_board               ; (console_wifi.asm)
    b    dp_done
dp_n:
    bl   pk_net                 ; (console_wifi.asm)
    b    dp_done
dp_v:
    bl   pk_conver
    b    dp_done
dp_i:
    bl   pk_ident
    b    dp_done
dp_done:
    movs r0, #0
    pop  {r4, pc}

    align 4
do_packet_pkt: dd PKT

; I: the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0), as on the ESP32: the
; flash out of XIP (flash_open; interrupts off meanwhile, the console runs from the RAM), CS low by the override of
; GPIO_QSPI_SS_CTRL (IO_QSPI, OUTOVER 2), the command 0x9F and three bytes through the SSI (DR0, each byte waits for
; RFNE in SR), CS back to the SSI (OUTOVER 0), XIP again (flash_close); as flash_do_cmd of the Pico SDK
pk_ident:
    push {r4, r5, r6, r7, lr}
    cpsid i
    bl   flash_open
    ldr  r4, pki_ss_clr
    ldr  r5, pki_ss_set
    movs r0, #3
    lsls r0, r0, #8
    str  r0, [r4]                   ; OUTOVER 0
    movs r0, #2
    lsls r0, r0, #8
    str  r0, [r5]                   ; OUTOVER 2: CS low
    ldr  r6, pki_ssi
    movs r7, #0                     ; the id
    movs r1, #0x9F
    movs r2, #0                     ; the byte
pki_byte:
    str  r1, [r6, #0x60]            ; DR0
pki_wait:
    ldr  r0, [r6, #0x28]            ; SR: bit 3 RFNE
    lsls r0, r0, #28
    bpl  pki_wait
    ldr  r0, [r6, #0x60]
    cmp  r2, #0
    beq  pki_next                   ; (the byte during the command)
    uxtb r0, r0
    subs r3, r2, #1
    lsls r3, r3, #3
    lsls r0, r3
    orrs r7, r0
pki_next:
    movs r1, #0
    adds r2, #1
    cmp  r2, #4
    bne  pki_byte
    movs r0, #3
    lsls r0, r0, #8
    str  r0, [r4]                   ; OUTOVER 0: CS back to the SSI (high)
    bl   flash_close
    cpsie i
    push {r7}
    mov  r1, sp
    movs r0, #'k'
    movs r2, #4
    bl   send_packet
    add  sp, #4
    pop  {r4, r5, r6, r7, pc}

    align 4
pki_ss_clr: dd 0x4001B00C           ; IO_QSPI GPIO_QSPI_SS_CTRL (0x4001800C), its alias for clearing bits
pki_ss_set: dd 0x4001A00C           ; ... for setting bits
pki_ssi:    dd 0x18000000           ; XIP_SSI

; V: the version of the console (what console_version() gives a program, api_version; 4 bytes)
CON_VERSION     equ 5
pk_conver:
    push {lr}
    movs r0, #'k'
    adr  r1, s_conver_v
    movs r2, #4
    bl   send_packet
    pop  {pc}
    align 4
s_conver_v:
    dd   CON_VERSION

; P: the version
pk_ping:
    push {lr}
    movs r0, #'k'
    adr  r1, s_version
    movs r2, #18
    bl   send_packet
    pop  {pc}
    align 4
s_version:
    db   'Asmonite console 2', 0, 0

; r0 1 when there is a file system, else 0 and the error sent
pk_need_fs:
    push {lr}
    ldr  r0, pk_need_fs_vars
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    bne  pnf_ok
    bl   send_err_inline
    db   'no file system (format)', 0
    align 2
    movs r0, #0
pnf_ok:
    pop  {pc}

    align 4
pk_need_fs_vars: dd VARS

; the length of the data of the packet in r0
pk_len:
    ldr  r0, pk_len_pkt
    ldrh r0, [r0, #2]
    bx   lr

    align 4
pk_len_pkt: dd PKT

; F: the files, the bytes in use, the bytes free, the name of the program for boot
pk_free:
    push {r4, r5, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pf_done
    ldr  r4, pk_free_out
    adds r4, r4, #4             ; the data of the answer (OUT + 1 .. 3 is its head)
    bl   dir_used
    str  r1, [r4]
    str  r0, [r4, #4]
    ldr  r1, pk_free_fs_end_fs_first_4096
    subs r1, r1, r0
    str  r1, [r4, #8]
    movs r0, #0
    movs r1, #12
pf_zero:
    str  r0, [r4, r1]
    adds r1, r1, #4
    cmp  r1, #32
    blt  pf_zero
    ldr  r0, pk_free_dirbuf
    ldr  r1, [r0, #12]          ; the program for boot: its entry + 1
    cmp  r1, #0
    beq  pf_send
    cmp  r1, #ENTRIES
    bhi  pf_send
    lsls r1, r1, #5
    adds r0, r0, r1     ; DIRBUF + 32 * (entry + 1): the entry
    movs r1, #0
pf_name:
    ldrb r2, [r0, r1]
    movs r3, #12
    adds r3, r3, r4
    strb r2, [r3, r1]
    adds r1, r1, #1
    cmp  r1, #19
    blt  pf_name
pf_send:
    movs r0, #'f'
    mov  r1, r4
    movs r2, #32
    bl   send_packet
pf_done:
    pop  {r4, r5, pc}

    align 4
pk_free_out:                  dd OUT
pk_free_fs_end_fs_first_4096: dd (FS_END - FS_FIRST) * 4096
pk_free_dirbuf:               dd DIRBUF

; L: name, length, CRC-32 of each file (into PAGEBUF: up to 64 * 28 bytes)
pk_list:
    push {r4, r5, r6, r7, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pl_done
    ldr  r4, pk_list_dirbuf_32
    ldr  r5, pk_list_pagebuf
    movs r6, #0                 ; the bytes of the answer
    movs r7, #0                 ; the entry
pl_next:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  pl_skip
    movs r1, #0
pl_word:
    ldr  r0, [r4, r1]
    adds r2, r5, r6
    str  r0, [r2, r1]
    adds r1, r1, #4
    cmp  r1, #20
    blt  pl_word
    adds r2, r5, r6
    ldr  r0, [r4, #24]
    str  r0, [r2, #20]
    ldr  r0, [r4, #28]
    str  r0, [r2, #24]
    adds r6, #28
pl_skip:
    adds r4, #32
    adds r7, r7, #1
    cmp  r7, #ENTRIES
    blt  pl_next
    movs r0, #'l'
    mov  r1, r5
    mov  r2, r6
    bl   send_packet
pl_done:
    pop  {r4, r5, r6, r7, pc}

    align 4
pk_list_dirbuf_32: dd DIRBUF + 32
pk_list_pagebuf:   dd PAGEBUF

; O name length crc: a file opens for writing, its sectors are erased
pk_open:
    push {r4, r5, r6, r7, lr}
    bl   pk_need_fs
    cmp  r0, #0
    bne  far1
    b    po_done
far1:
    bl   pk_len
    cmp  r0, #28
    bne  po_size_err
    ldr  r4, pk_open_pkt_4
    ldr  r7, pk_open_vars
    ldr  r0, [r7, #V_FN + 20]
    cmp  r0, #0
    beq  po_noflash
    ldrb r0, [r4]
    cmp  r0, #0
    beq  po_noname
    movs r0, #0
    strb r0, [r4, #19]          ; the field ends with a 0
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    bne  po_entry
    bl   free_entry
    cmp  r0, #0
    beq  po_full
po_entry:
    mov  r5, r0                 ; its entry (the old file stays until C)
    ldr  r6, [r4, #20]          ; the length
    movs r0, #0
    cmp  r6, #0
    beq  po_state
    subs r0, r6, #1
    lsrs r0, r0, #12
    adds r0, r0, #1             ; the sectors
    cmp  r0, #0
    beq  po_state               ; an empty file: no sectors
    push {r0}
    bl   find_gap
    pop  {r1}
    cmp  r0, #0
    beq  po_room
    str  r0, [r7, #V_OFIRST]
    push {r0, r1}
    bl   flash_open
    pop  {r0, r1}
    lsls r0, r0, #12
    lsls r1, r1, #12
    bl   flash_erase
    bl   flash_close
    b    po_state2
po_state:
    str  r0, [r7, #V_OFIRST]
po_state2:
    movs r0, #1
    str  r0, [r7, #V_OPEN]
    str  r6, [r7, #V_OLEN]
    ldr  r0, [r4, #24]
    str  r0, [r7, #V_OCRC]
    movs r0, #0
    str  r0, [r7, #V_OWRITTEN]
    str  r5, [r7, #V_OENTRY]
    subs r0, r0, #1
    str  r0, [r7, #V_OLAST]
    ; the name of the open file (C puts it into the entry)
    ldr  r1, pk_open_vars_v_oname
    movs r2, #0
po_copy:
    ldr  r0, [r4, r2]
    str  r0, [r1, r2]
    adds r2, r2, #4
    cmp  r2, #20
    blt  po_copy
    bl   send_ok
    b    po_done
po_size_err:
    bl   send_err_inline
    db   'O: name, length, CRC-32', 0
    align 2
    b    po_done
po_noflash:
    bl   send_err_inline
    db   'the boot ROM has not the functions for the flash', 0
    align 2
    b    po_done
po_noname:
    bl   send_err_inline
    db   'no name', 0
    align 2
    b    po_done
po_full:
    bl   send_err_inline
    db   'the directory is full (64 files)', 0
    align 2
    b    po_done
po_room:
    bl   send_err_inline
    db   'no room in the flash for the file', 0
    align 2
po_done:
    pop  {r4, r5, r6, r7, pc}

    align 4
pk_open_pkt_4:        dd PKT + 4
pk_open_vars:         dd VARS
pk_open_vars_v_oname: dd VARS + V_ONAME

; W offset bytes: a piece of the open file (its offset a multiple of 256: the pages of the flash)
pk_write:
    push {r4, r5, r6, r7, lr}
    ldr  r7, pk_write_vars
    ldr  r0, [r7, #V_OPEN]
    cmp  r0, #0
    beq  pw_notopen
    bl   pk_len
    subs r5, r0, #4             ; the bytes
    blt  pw_bad
    ldr  r0, pk_write_k1024
    cmp  r5, r0
    bgt  pw_bad
    ldr  r4, pk_write_pkt_4
    ldr  r6, [r4]               ; the offset
    ldr  r0, [r7, #V_OLAST]
    cmp  r0, r6
    bne  pw_new
    ldr  r0, [r7, #V_OWRITTEN]
    adds r1, r6, r5
    cmp  r0, r1
    bne  pw_new
    bl   send_ok                ; the last piece again (its k was lost)
    b    pw_done
pw_new:
    ldr  r0, [r7, #V_OWRITTEN]
    cmp  r0, r6
    bne  pw_order
    lsls r0, r6, #24            ; a multiple of 256?
    bne  pw_order
    adds r1, r6, r5
    ldr  r0, [r7, #V_OLEN]
    cmp  r1, r0
    bhi  pw_beyond
    cmp  r5, #0
    beq  pw_ok
    ; the piece into PAGEBUF, 0xFF behind it up to a whole page
    ldr  r0, pk_write_pagebuf
    movs r1, #0
pw_copy:
    cmp  r1, r5
    bge  pw_fill
    adds r2, r4, #4
    ldrb r3, [r2, r1]
    strb r3, [r0, r1]
    adds r1, r1, #1
    b    pw_copy
pw_fill:
    lsls r3, r1, #24
    beq  pw_flash
    movs r3, #0xff
    strb r3, [r0, r1]
    adds r1, r1, #1
    b    pw_fill
pw_flash:
    push {r1}
    bl   flash_open
    pop  {r2}
    ldr  r0, [r7, #V_OFIRST]
    lsls r0, r0, #12
    adds r0, r0, r6
    ldr  r1, pk_write_pagebuf
    bl   flash_program
    bl   flash_close
pw_ok:
    adds r0, r6, r5
    str  r0, [r7, #V_OWRITTEN]
    str  r6, [r7, #V_OLAST]
    bl   send_ok
    b    pw_done
pw_notopen:
    bl   send_err_inline
    db   'no file is open (O first)', 0
    align 2
    b    pw_done
pw_bad:
    bl   send_err_inline
    db   'W: offset and up to 1024 bytes', 0
    align 2
    b    pw_done
pw_order:
    bl   send_err_inline
    db   'W: the pieces in their order, each at a multiple of 256 bytes', 0
    align 2
    b    pw_done
pw_beyond:
    bl   send_err_inline
    db   'W: beyond the length of the file', 0
    align 2
pw_done:
    pop  {r4, r5, r6, r7, pc}

    align 4
pk_write_vars:    dd VARS
pk_write_k1024:   dd 1024
pk_write_pkt_4:   dd PKT + 4
pk_write_pagebuf: dd PAGEBUF

; C: the open file read back, its CRC-32 checked, then into the directory
pk_close:
    push {r4, r5, r6, r7, lr}
    ldr  r7, pk_close_vars
    ldr  r0, [r7, #V_OPEN]
    cmp  r0, #0
    beq  pc_notopen
    movs r0, #0
    str  r0, [r7, #V_OPEN]      ; closed (also when it fails)
    ldr  r0, [r7, #V_OWRITTEN]
    ldr  r1, [r7, #V_OLEN]
    cmp  r0, r1
    bne  pc_short
    ldr  r1, [r7, #V_OFIRST]
    lsls r1, r1, #12
    movs r0, #1
    lsls r0, r0, #28
    adds r1, r1, r0
    ldr  r2, [r7, #V_OLEN]
    movs r0, #0
    bl   crc32                  ; what is in the flash
    ldr  r1, [r7, #V_OCRC]
    cmp  r0, r1
    bne  pc_crc
    ; the entry: the name, the first sector, the length, the CRC
    ldr  r4, [r7, #V_OENTRY]
    ldr  r1, pk_close_vars_v_oname
    movs r2, #0
pc_name:
    ldr  r3, [r1, r2]
    str  r3, [r4, r2]
    adds r2, r2, #4
    cmp  r2, #20
    blt  pc_name
    ldr  r0, [r7, #V_OFIRST]
    str  r0, [r4, #20]
    ldr  r0, [r7, #V_OLEN]
    str  r0, [r4, #24]
    ldr  r0, [r7, #V_OCRC]
    str  r0, [r4, #28]
    bl   dir_save
    bl   send_ok
    b    pc_done
pc_notopen:
    bl   send_err_inline
    db   'no file is open (O first)', 0
    align 2
    b    pc_done
pc_short:
    bl   send_err_inline
    db   'C: the file is not complete', 0
    align 2
    b    pc_done
pc_crc:
    ; the directory as it was (the old file stays)
    bl   send_err_inline
    db   'C: the CRC-32 of the file in the flash is another one', 0
    align 2
pc_done:
    pop  {r4, r5, r6, r7, pc}

    align 4
pk_close_vars:         dd VARS
pk_close_vars_v_oname: dd VARS + V_ONAME

; G name offset count: bytes of a file
pk_get:
    push {r4, r5, r6, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pg_done
    bl   pk_len
    cmp  r0, #28
    bne  pg_bad
    ldr  r4, pk_get_pkt_4
    movs r0, #0
    strb r0, [r4, #19]
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  pg_nofile
    ldr  r5, [r4, #20]          ; the offset
    ldr  r6, [r4, #24]          ; the count
    lsls r1, r5, #30            ; a multiple of 4?
    bne  pg_bad
    ldr  r1, pk_get_k1024
    cmp  r6, r1
    bhi  pg_bad
    ldr  r1, [r0, #24]          ; the length
    cmp  r5, r1
    bhi  pg_bad
    subs r1, r1, r5             ; the bytes from the offset on
    cmp  r6, r1
    bls  pg_send
    mov  r6, r1
pg_send:
    ldr  r1, [r0, #20]
    lsls r1, r1, #12
    movs r0, #1
    lsls r0, r0, #28
    adds r1, r1, r0
    adds r1, r1, r5
    movs r0, #'d'
    mov  r2, r6
    bl   send_packet
    b    pg_done
pg_nofile:
    bl   send_err_inline
    db   'no such file', 0
    align 2
    b    pg_done
pg_bad:
    bl   send_err_inline
    db   'G: name, offset (a multiple of 4, not beyond the file), up to 1024 bytes', 0
    align 2
pg_done:
    pop  {r4, r5, r6, pc}

    align 4
pk_get_pkt_4: dd PKT + 4
pk_get_k1024: dd 1024

; D name: the file away
pk_delete:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pd_done
    ldr  r4, pk_delete_pkt_4
    movs r0, #0
    strb r0, [r4, #19]
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  pd_nofile
    bl   remove_entry
    cmp  r0, #0
    bne  pd_noflash
    bl   send_ok
    b    pd_done
pd_nofile:
    bl   send_err_inline
    db   'no such file', 0
    align 2
    b    pd_done
pd_noflash:
    bl   send_err_inline
    db   'the boot ROM has not the functions for the flash', 0
    align 2
pd_done:
    pop  {r4, pc}

    align 4
pk_delete_pkt_4: dd PKT + 4

; B name: the program for boot (zeros: none)
pk_boot:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pb_done
    ldr  r4, pk_boot_pkt_4
    movs r1, #0                 ; none
    ldrb r0, [r4]
    cmp  r0, #0
    beq  pb_set
    movs r0, #0
    strb r0, [r4, #19]
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  pb_nofile
    ldr  r1, pk_boot_dirbuf_32
    subs r1, r0, r1
    lsrs r1, r1, #5
    adds r1, r1, #1
pb_set:
    ldr  r0, pk_boot_dirbuf
    str  r1, [r0, #12]
    bl   dir_save
    cmp  r0, #0
    bne  pb_noflash
    bl   send_ok
    b    pb_done
pb_nofile:
    bl   send_err_inline
    db   'no such file', 0
    align 2
    b    pb_done
pb_noflash:
    bl   send_err_inline
    db   'the boot ROM has not the functions for the flash', 0
    align 2
pb_done:
    pop  {r4, pc}

    align 4
pk_boot_pkt_4:     dd PKT + 4
pk_boot_dirbuf_32: dd DIRBUF + 32
pk_boot_dirbuf:    dd DIRBUF

; M: a new, empty file system
pk_format:
    push {lr}
    bl   make_fs
    cmp  r0, #0
    bne  pm_err
    bl   send_ok
    pop  {pc}
pm_err:
    bl   send_err_inline
    db   'the boot ROM has not the functions for the flash', 0
    align 2
    pop  {pc}

; the address r0 and the count r1 of Y and K valid (address a multiple of 4, both in the flash of 2 MB)? r0 1 or 0
flash_range_ok:
    lsls r2, r0, #30
    bne  fro_no                 ; not a multiple of 4
    ldr  r2, flash_range_ok_size
    cmp  r0, r2
    bhi  fro_no
    subs r2, r2, r0
    cmp  r1, r2
    bhi  fro_no
    movs r0, #1
    bx   lr
fro_no:
    movs r0, #0
    bx   lr

    align 4
flash_range_ok_size:    dd FLASH_SIZE

; Y address count: the bytes of the flash there (up to 1024)
pk_flash:
    push {r4, r5, lr}
    bl   pk_len
    cmp  r0, #8
    bne  py_bad
    ldr  r0, pk_flash_pkt_4
    ldr  r4, [r0]
    ldr  r5, [r0, #4]
    ldr  r0, pk_flash_k1024
    cmp  r5, r0
    bhi  py_bad
    mov  r0, r4
    mov  r1, r5
    bl   flash_range_ok
    cmp  r0, #0
    beq  py_bad
    movs r0, #'d'
    movs r1, #1
    lsls r1, r1, #28
    adds r1, r1, r4
    mov  r2, r5
    bl   send_packet
    pop  {r4, r5, pc}
py_bad:
    bl   send_err_inline
    db   'Y: an address in the flash (a multiple of 4), up to 1024 bytes', 0
    align 2
    pop  {r4, r5, pc}

    align 4
pk_flash_pkt_4: dd PKT + 4
pk_flash_k1024: dd 1024

; K address count: the CRC-32 of count bytes of the flash at address
pk_crc:
    push {r4, r5, lr}
    bl   pk_len
    cmp  r0, #8
    bne  pk_crc_bad
    ldr  r0, pk_crc_pkt_4
    ldr  r4, [r0]
    ldr  r5, [r0, #4]
    mov  r0, r4
    mov  r1, r5
    bl   flash_range_ok
    cmp  r0, #0
    beq  pk_crc_bad
    movs r0, #0
    movs r1, #1
    lsls r1, r1, #28
    adds r1, r1, r4
    mov  r2, r5
    bl   crc32
    ldr  r1, pk_crc_pagebuf
    str  r0, [r1]
    movs r0, #'k'
    movs r2, #4
    bl   send_packet
    pop  {r4, r5, pc}
pk_crc_bad:
    bl   send_err_inline
    db   'K: an address in the flash (a multiple of 4) and a count', 0
    align 2
    pop  {r4, r5, pc}

    align 4
pk_crc_pkt_4:   dd PKT + 4
pk_crc_pagebuf: dd PAGEBUF


; ---------- programs ----------

; the table of the functions for programs at JT (their addresses in the RAM, with the Thumb bit), and at STUBS the
; same functions to call: 16 bytes of code each (jt_stub and the address), for a program that calls a function at a
; fixed address (aBelle: def print(s: pchar) at STUBS + 0x50). r3 stays (the fourth argument), ip changes (as the Arm
; ABI allows it in a call)
jt_init:
    push {r4, lr}
    ldr  r0, jt_init_jt
    adr  r1, jt_lits
    movs r2, #0
ji_next:
    ldr  r3, [r1, r2]
    str  r3, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #56
    blt  ji_next
    ldr  r0, jt_init_stubs
    adr  r4, jt_stub
    movs r2, #0
ji_stub:
    ldr  r3, [r4, #0]
    str  r3, [r0, #0]
    ldr  r3, [r4, #4]
    str  r3, [r0, #4]
    ldr  r3, [r4, #8]
    str  r3, [r0, #8]
    ldr  r3, [r1, r2]
    str  r3, [r0, #12]
    adds r0, #16
    adds r2, r2, #4
    cmp  r2, #56
    blt  ji_stub
    pop  {r4, pc}

    align 4
jt_init_jt:    dd JT
jt_init_stubs: dd STUBS

    align 4
jt_stub:
    dd 0x4B02B408                           ; push {r3}; ldr r3, [pc, #8] (the address behind)
    dd 0xBC08469C                           ; mov ip, r3; pop {r3}
    dd 0x46C04760                           ; bx ip; nop
jt_lits:
    dd api_exit + RUN_OFFSET + 1            ; +0
    dd api_version + RUN_OFFSET + 1         ; +4
    dd put_char + RUN_OFFSET + 1            ; +8
    dd api_get_char + RUN_OFFSET + 1        ; +12
    dd api_poll_char + RUN_OFFSET + 1       ; +16
    dd put_text + RUN_OFFSET + 1            ; +20 print
    dd api_millis + RUN_OFFSET + 1          ; +24
    dd api_file_size + RUN_OFFSET + 1       ; +28
    dd api_file_read + RUN_OFFSET + 1       ; +32
    dd api_file_write + RUN_OFFSET + 1      ; +36 file_write
    dd api_none + RUN_OFFSET + 1            ; +40 flash_read (not yet: the flash is readable at 0x10000000)
    dd api_args + RUN_OFFSET + 1            ; +44
    dd wifi_led + RUN_OFFSET + 1            ; +48 led(on)
    dd api_wifi + RUN_OFFSET + 1            ; +52 wl_call(op, a, b, c): the WiFi (console_wifi.asm)

; runs the program at its entry r0 (in the RAM of the programs) with the arguments r1 (a text): r0 its code (-1 when
; it was stopped). Its stack from PROG_HI down; UART0 interrupts while it runs (Ctrl+C, the ring). The console keeps
; r4 .. r7 and uses no other: what a program leaves in r8 .. r11 does not matter
run_entry:
    push {r4, r5, r6, r7, lr}
    ldr  r4, run_entry_vars
    str  r1, [r4, #V_ARGS]
    mov  r2, sp
    str  r2, [r4, #V_CSP]
    movs r2, #0
    str  r2, [r4, #V_RHEAD]
    str  r2, [r4, #V_RTAIL]
    movs r2, #1
    str  r2, [r4, #V_RUN]
    movs r5, #1
    orrs r5, r0                 ; Thumb
    bl   irq_on
    ldr  r0, run_entry_prog_hi
    mov  sp, r0
    ldr  r0, [r4, #V_ARGS]
    blx  r5
; the end of a program: r0 its code (bx lr, or exit from any depth)
prog_finish:
    mov  r6, r0
    bl   irq_off
    ldr  r4, run_entry_vars2
    ldr  r1, [r4, #V_CSP]
    mov  sp, r1
    movs r1, #0
    str  r1, [r4, #V_RUN]
    ldr  r1, [r4, #V_QUIET]
    cmp  r1, #0
    beq  pf_say
    cmp  r6, #0
    beq  pf_back                ; started by its name: no "Program ended (code 0)"
pf_say:
    bl   print_inline
    db   13, 10, 'Program ended (code ', 0
    align 2
    mov  r0, r6
    bl   put_int
    bl   print_inline
    db   ').', 13, 10, 0
    align 2
pf_back:
    mov  r0, r6
    bl   mon_end                ; under the debug monitor: x and the code
    mov  r0, r6
    pop  {r4, r5, r6, r7, pc}
; a program stopped (fault, Ctrl+C: they have said so): the console as before the program
prog_abort:
    bl   irq_off
    bl   wl_abort               ; CS of the WiFi chip high (Ctrl+C in the middle of a transfer)
    ldr  r4, run_entry_vars2
    ldr  r1, [r4, #V_CSP]
    mov  sp, r1
    movs r1, #0
    str  r1, [r4, #V_RUN]
    movs r0, #0
    subs r0, r0, #1
    bl   mon_end                ; under the debug monitor: x and -1
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, r6, r7, pc}

    align 4
run_entry_vars:     dd VARS
run_entry_prog_hi:  dd PROG_HI
run_entry_vars2:    dd VARS

; r0 as a signed decimal number
put_int:
    push {r4, lr}
    mov  r4, r0
    cmp  r4, #0
    bge  pint_pos
    movs r0, #'-'
    bl   put_char
    rsbs r4, r4, #0
pint_pos:
    mov  r0, r4
    bl   put_dec
    pop  {r4, pc}

; UART0 interrupts for the bytes that come (the FIFO half full, or a pause after a byte); none when UART0 belongs to
; the ESP8285 (Ctrl+C comes over USB then)
irq_on:
    ldr  r1, irq_on_esp
    ldr  r1, [r1]
    cmp  r1, #0
    bne  irq_on_go
    ldr  r1, irq_on_uart0
    ldr  r0, irq_on_all
    str  r0, [r1, #UARTICR]
    movs r0, #(1 << 4) | (1 << 6)
    str  r0, [r1, #UARTIMSC]
    ldr  r1, irq_on_nvic_iser
    ldr  r0, irq_on_bit
    str  r0, [r1]
irq_on_go:
    cpsie i
    bx   lr

    align 4
irq_on_esp:         dd WLV + WL_ESP
irq_on_uart0:       dd UART0
irq_on_all:         dd 0x7ff
irq_on_nvic_iser:   dd NVIC_ISER
irq_on_bit:         dd UART0_IRQ_BIT

irq_off:
    ldr  r1, irq_off_esp            ; UART0 of the ESP8285: its interrupt stays (console_esp.asm: esp_irq)
    ldr  r1, [r1]
    cmp  r1, #0
    bne  irq_off_end
    ldr  r1, irq_off_uart0
    movs r0, #0
    str  r0, [r1, #UARTIMSC]
    ldr  r1, irq_off_nvic_icer
    ldr  r0, irq_off_bit
    str  r0, [r1]
    dsb
    isb
irq_off_end:
    bx   lr

    align 4
irq_off_esp:        dd WLV + WL_ESP
irq_off_uart0:      dd UART0
irq_off_nvic_icer:  dd NVIC_ICER
irq_off_bit:        dd UART0_IRQ_BIT

; the interrupt of UART0 while a program runs: the bytes into the ring (a full ring drops them); Ctrl+C stops the
; program (its frame returns to prog_abort)
uart_irq:
    push {r4, r5, r6, lr}
    ldr  r4, uart_irq_uart0
    ldr  r5, uart_irq_vars
ui_next:
    ldr  r0, [r4, #UARTFR]
    lsls r0, r0, #27            ; RXFE
    bmi  ui_done
    ldr  r0, [r4, #UARTDR]
    lsls r1, r0, #20
    lsrs r1, r1, #28            ; the errors
    bne  ui_next                ; left out (see get_char)
    uxtb r0, r0
    cmp  r0, #3
    beq  ui_stop
    ldr  r1, [r5, #V_RHEAD]
    ldr  r2, [r5, #V_RTAIL]
    adds r3, r1, #1
    uxtb r3, r3
    cmp  r3, r2
    beq  ui_next                ; full
    ldr  r2, uart_irq_ring
    strb r0, [r2, r1]
    str  r3, [r5, #V_RHEAD]
    b    ui_next
ui_stop:
    ldr  r0, [r5, #V_RUN]
    cmp  r0, #0
    beq  ui_next
    bl   mon_ctrl_c             ; under the debug monitor: the program stands instead
    cmp  r0, #0
    bne  ui_next
    bl   print_inline
    db   13, 10, 'Program stopped (Ctrl+C).', 13, 10, 0
    align 2
    add  r6, sp, #16            ; the frame of the exception, above what this handler pushed
    ldr  r0, lit_abort2
    str  r0, [r6, #24]
    movs r0, #1
    lsls r0, r0, #24
    str  r0, [r6, #28]
ui_done:
    ldr  r0, uart_irq_k0x7ff
    str  r0, [r4, #UARTICR]
    pop  {r4, r5, r6, pc}

    align 4
uart_irq_uart0:  dd UART0
uart_irq_vars:   dd VARS
uart_irq_ring:   dd RING
uart_irq_k0x7ff: dd 0x7ff

    align 4
lit_abort2:     dd prog_abort + RUN_OFFSET

; ---------- the functions for programs ----------

; exit(code): the program ends, from any depth
api_exit:
    b    prog_finish

; version(): 5 (4: without the pings of wl_call, 3: without its scan, 2: without wl_call, 1: without led)
api_version:
    movs r0, #CON_VERSION
    bx   lr

; flash_read: not yet
api_none:
    movs r0, #0
    subs r0, r0, #1
    bx   lr

; get_char(): the next byte from the terminal (waits for it in the ring)
api_get_char:
    push {lr}
ag_wait:
    bl   api_poll_char
    cmp  r0, #0
    blt  ag_wait
    pop  {pc}

; poll_char(): the next byte from the ring of UART0, else from the one of USB; -1 if none came
api_poll_char:
    ldr  r1, api_poll_char_vars
    ldr  r2, [r1, #V_RTAIL]
    ldr  r3, [r1, #V_RHEAD]
    cmp  r2, r3
    beq  ap_none
    ldr  r0, api_poll_char_ring
    ldrb r0, [r0, r2]
    adds r2, r2, #1
    uxtb r2, r2
    str  r2, [r1, #V_RTAIL]
    bx   lr
ap_none:
    push {lr}
    bl   usb_getc
    pop  {pc}

    align 4
api_poll_char_vars: dd VARS
api_poll_char_ring: dd RING

; a Ctrl+C over USB (usb_irq, r0 the frame of its exception) while a program runs: it stops (as in uart_irq)
con_ctrl_c:
    push {r4, lr}
    mov  r4, r0
    bl   mon_ctrl_c             ; under the debug monitor: the program stands instead
    cmp  r0, #0
    bne  cc_done
    bl   print_inline
    db   13, 10, 'Program stopped (Ctrl+C).', 13, 10, 0
    align 2
    ldr  r0, lit_abort3
    str  r0, [r4, #24]
    movs r0, #1
    lsls r0, r0, #24            ; xPSR: only the Thumb bit
    str  r0, [r4, #28]
cc_done:
    pop  {r4, pc}

    align 4
lit_abort3:     dd prog_abort + RUN_OFFSET

; millis(): the milliseconds of TIMER (since the chip started; after 49 days 0 again): (H * 2^32 + L) / 1000 =
; H * 4294967 + L / 1000 + (H * 296 + L mod 1000) / 1000
api_millis:
    push {r4, r5, r6, lr}
    ldr  r3, api_millis_timer
am_read:
    ldr  r4, [r3, #0x24]        ; TIMERAWH
    ldr  r5, [r3, #0x28]        ; TIMERAWL
    ldr  r0, [r3, #0x24]
    cmp  r0, r4
    bne  am_read                ; L wrapped meanwhile
    mov  r0, r5
    ldr  r1, api_millis_k1000
    bl   udiv32                 ; r0 L / 1000, r1 L mod 1000
    mov  r6, r0
    ldr  r0, api_millis_k296
    muls r0, r4
    adds r0, r0, r1
    ldr  r1, api_millis_k1000
    bl   udiv32
    adds r6, r6, r0
    ldr  r0, api_millis_k4294967
    muls r0, r4
    adds r0, r0, r6
    pop  {r4, r5, r6, pc}

    align 4
api_millis_timer:       dd TIMER
api_millis_k1000:       dd 1000
api_millis_k296:        dd 296
api_millis_k4294967:    dd 4294967

; args(): the text of the arguments
api_args:
    ldr  r0, api_args_vars
    ldr  r0, [r0, #V_ARGS]
    bx   lr

    align 4
api_args_vars: dd VARS

; the entry of the file with the name r0 (a text): r0, 0 when there is none (or no file system)
entry_of_text:
    push {lr}
    bl   name_field
    cmp  r0, #0
    ble  et_none
    ldr  r0, entry_of_text_vars
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  et_none
    adds r0, #V_NAME
    bl   find_entry
    pop  {pc}
et_none:
    movs r0, #0
    pop  {pc}

    align 4
entry_of_text_vars: dd VARS

; file_size(name): its length, -1 when there is none
api_file_size:
    push {lr}
    bl   entry_of_text
    cmp  r0, #0
    beq  afs_none
    ldr  r0, [r0, #24]
    pop  {pc}
afs_none:
    movs r0, #0
    subs r0, r0, #1
    pop  {pc}

; file_read(name, buffer, offset, count): the bytes read (count, or what is left from offset on), -1 when there is no
; such file or offset is beyond it
api_file_read:
    push {r4, r5, r6, r7, lr}
    mov  r5, r1
    mov  r6, r2
    mov  r7, r3
    bl   entry_of_text
    cmp  r0, #0
    beq  afr_none
    ldr  r1, [r0, #24]          ; the length
    cmp  r6, r1
    bhi  afr_none
    subs r1, r1, r6
    cmp  r7, r1
    bls  afr_count
    mov  r7, r1
afr_count:
    ldr  r4, [r0, #20]
    lsls r4, r4, #12
    movs r0, #1
    lsls r0, r0, #28
    adds r4, r4, r0
    adds r4, r4, r6
    movs r1, #0
afr_copy:
    cmp  r1, r7
    bge  afr_done
    ldrb r2, [r4, r1]
    strb r2, [r5, r1]
    adds r1, r1, #1
    b    afr_copy
afr_done:
    mov  r0, r7
    pop  {r4, r5, r6, r7, pc}
afr_none:
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, r6, r7, pc}

; file_write(name, buffer, count): the file (a new one, or a new text for one) as Upload File writes it: the parts of
; the packets O, W (1 KB each) and C, their answers kept in V_FQUIET instead of sent. 0 done, -1 the directory is
; full (64 files), -2 no room in the flash, -3 the flash cannot be written, -4 not a valid name (1 to 19
; characters, no spaces), -5 no file system (format in the console)
api_file_write:
    push {r4, r5, r6, r7, lr}
    mov  r5, r1                 ; the bytes
    mov  r6, r2                 ; how many
    ldr  r7, afw_vars
    ldr  r4, afw_pkt
    adds r4, r4, #4             ; the data of the packet
    movs r3, #5
    ldr  r1, [r7, #V_FSOK]
    cmp  r1, #0
    beq  afw_err
    ; the name into the packet O: 20 bytes, zeros behind it
    movs r3, #4
    movs r1, #0
afw_name:
    ldrb r2, [r0, r1]
    cmp  r2, #0
    beq  afw_zeros
    cmp  r2, #' '
    bls  afw_err
    strb r2, [r4, r1]
    adds r1, r1, #1
    cmp  r1, #20
    blt  afw_name
    b    afw_err                ; 20 characters or more
afw_zeros:
    cmp  r1, #0
    beq  afw_err
    movs r2, #0
afw_z:
    strb r2, [r4, r1]
    adds r1, r1, #1
    cmp  r1, #20
    blt  afw_z
    str  r6, [r4, #20]          ; the length
    movs r0, #0
    mov  r1, r5
    mov  r2, r6
    bl   crc32
    str  r0, [r4, #24]          ; its CRC-32
    movs r0, #28
    bl   afw_len
    bl   pk_open
    ldr  r0, [r7, #V_FQUIET]
    cmp  r0, #'k'
    beq  afw_opened
    ; e: "no room ..." -2, else the directory is full -1
    movs r3, #2
    ldr  r0, [r7, #V_FTEXT]
    ldrb r0, [r0]
    cmp  r0, #'n'
    beq  afw_err
    movs r3, #1
    b    afw_err
afw_opened:
    push {r5}                   ; the start of the bytes
afw_piece:
    cmp  r6, #0
    beq  afw_close
    ldr  r0, [sp]
    subs r0, r5, r0
    str  r0, [r4]               ; the offset of the piece
    ldr  r2, afw_k1024
    cmp  r6, r2
    bhs  afw_n
    mov  r2, r6
afw_n:
    adds r3, r4, #4
    movs r1, #0
afw_copy:
    ldrb r0, [r5, r1]
    strb r0, [r3, r1]
    adds r1, r1, #1
    cmp  r1, r2
    blt  afw_copy
    adds r5, r5, r2
    subs r6, r6, r2
    adds r0, r2, #4
    bl   afw_len
    bl   pk_write
    ldr  r0, [r7, #V_FQUIET]
    cmp  r0, #'k'
    beq  afw_piece
    add  sp, #4
    b    afw_err3
afw_close:
    add  sp, #4
    movs r0, #0
    bl   afw_len
    bl   pk_close
    ldr  r0, [r7, #V_FQUIET]
    cmp  r0, #'k'
    bne  afw_err3
    movs r0, #0
    b    afw_end
afw_err3:
    movs r3, #3
afw_err:
    movs r0, #0
    subs r0, r0, r3
afw_end:
    movs r1, #0
    str  r1, [r7, #V_FQUIET]    ; the answers go out again
    pop  {r4, r5, r6, r7, pc}

; r0 the length of the data of the packet in PKT; its answer kept, not sent
afw_len:
    ldr  r1, afw_pkt
    strh r0, [r1, #2]
    ldr  r1, afw_vars
    movs r0, #1
    str  r0, [r1, #V_FQUIET]
    bx   lr

    align 4
afw_vars:  dd VARS
afw_pkt:   dd PKT
afw_k1024: dd 1024

; the program of the entry r0 into the RAM of the programs: r0 its entry, r1 0; or r1 what is wrong (1 the file is
; damaged, 2 it is no program, 3 a segment outside the RAM of the programs, 4 the entry outside it)
load_file:
    push {r4, r5, r6, r7, lr}
    sub  sp, #8             ; [sp]: the entry
    ldr  r5, [r0, #24]          ; the length
    ldr  r6, [r0, #28]          ; the CRC-32
    ldr  r4, [r0, #20]
    lsls r4, r4, #12
    ldr  r1, load_file_flash_base
    adds r4, r4, r1             ; its bytes
    movs r0, #0
    mov  r1, r4
    mov  r2, r5
    bl   crc32
    cmp  r0, r6
    bne  lf_damaged
    cmp  r5, #24
    blt  lf_noprog
    ldrb r0, [r4]
    cmp  r0, #0xe9
    bne  lf_noprog
    ldrb r6, [r4, #1]           ; the segments
    cmp  r6, #0
    beq  lf_noprog
    cmp  r6, #16
    bhi  lf_noprog
    ldr  r0, [r4, #4]
    str  r0, [sp]               ; the entry
    movs r7, #24                ; the first segment
lf_seg:
    cmp  r6, #0
    beq  lf_entry
    mov  r0, r7
    adds r0, #8
    cmp  r0, r5
    bhi  lf_noprog
    ldr  r0, [r4, r7]           ; its address
    adds r1, r4, r7
    ldr  r2, [r1, #4]           ; its length
    cmp  r2, r5
    bhi  lf_noprog
    mov  r3, r7
    adds r3, #8
    adds r3, r3, r2
    cmp  r3, r5
    bhi  lf_noprog              ; beyond the end of the file
    lsls r3, r0, #30
    bne  lf_where
    ldr  r3, load_file_prog_lo
    cmp  r0, r3
    blo  lf_where
    adds r1, r0, r2
    ldr  r3, load_file_prog_hi
    cmp  r1, r3
    bhi  lf_where
    adds r1, r4, r7
    adds r1, #8             ; its bytes
    adds r7, #8
    adds r7, r7, r2             ; the next segment
    cmp  r2, #0
    beq  lf_next
lf_copy:
    ldrb r3, [r1]
    strb r3, [r0]
    adds r0, r0, #1
    adds r1, r1, #1
    subs r2, r2, #1
    bne  lf_copy
lf_next:
    subs r6, r6, #1
    b    lf_seg
lf_entry:
    ldr  r7, [sp]
    ldr  r0, load_file_prog_lo
    cmp  r7, r0
    blo  lf_badentry
    ldr  r0, load_file_prog_hi
    cmp  r7, r0
    bhs  lf_badentry
    dsb
    isb
    mov  r0, r7
    movs r1, #0
    add  sp, #8
    pop  {r4, r5, r6, r7, pc}
lf_damaged:
    movs r1, #1
    b    lf_err
lf_noprog:
    movs r1, #2
    b    lf_err
lf_where:
    movs r1, #3
    b    lf_err
lf_badentry:
    movs r1, #4
lf_err:
    movs r0, #0
    add  sp, #8
    pop  {r4, r5, r6, r7, pc}

    align 4
load_file_flash_base:   dd FLASH_BASE
load_file_prog_lo:      dd PROG_LO
load_file_prog_hi:      dd PROG_HI

; what load_file said (r1) as a line
load_error:
    push {lr}
    cmp  r1, #1
    bne  le_2
    bl   print_inline
    db   'the file is damaged (its CRC-32 is not the one of the directory)', 13, 10, 0
    align 2
    pop  {pc}
le_2:
    cmp  r1, #2
    bne  le_3
    bl   print_inline
    db   'this is not a program (an image as Asmonite makes it: 0xE9, segments, the entry)', 13, 10, 0
    align 2
    pop  {pc}
le_3:
    cmp  r1, #3
    bne  le_4
    bl   print_inline
    db   'a part of the program lies outside the RAM of the programs (0x20000000 .. 0x2002FFFF)', 13, 10, 0
    align 2
    pop  {pc}
le_4:
    bl   print_inline
    db   'the entry of the program lies outside the RAM of the programs', 13, 10, 0
    align 2
    pop  {pc}

; run name [args] (r1 0), or name [args] alone (r1 1: quiet; r0 0 when there is no such file, for "no such
; command"); r0 1 otherwise
cmd_run:
    push {r4, r5, r6, lr}
    mov  r6, r1
    bl   name_field
    cmp  r0, #0
    bgt  crn_name
    cmp  r6, #0
    bne  crn_notfound
    bl   print_inline
    db   'which program?', 13, 10, 0
    align 2
    b    crn_done
crn_name:
    mov  r0, r1
    bl   skip_spaces
    mov  r5, r0                 ; the arguments
    ldr  r0, cmd_run_vars
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  crn_nofile
    adds r0, #V_NAME
    bl   find_entry
    cmp  r0, #0
    beq  crn_nofile
    bl   load_file
    cmp  r1, #0
    beq  crn_go
    bl   load_error
    b    crn_done
crn_go:
    mov  r4, r0
    ldr  r0, cmd_run_vars
    str  r6, [r0, #V_QUIET]
    cmp  r6, #0
    bne  crn_start
    bl   print_inline
    db   'Running ', 0
    align 2
    ldr  r0, cmd_run_vars_v_name
    bl   put_text
    bl   put_nl
crn_start:
    mov  r0, r4
    mov  r1, r5
    bl   run_entry
    b    crn_done
crn_nofile:
    cmp  r6, #0
    bne  crn_notfound
    bl   print_inline
    db   'no such file', 13, 10, 0
    align 2
crn_done:
    movs r0, #1
    pop  {r4, r5, r6, pc}
crn_notfound:
    movs r0, #0
    pop  {r4, r5, r6, pc}

    align 4
cmd_run_vars:        dd VARS
cmd_run_vars_v_name: dd VARS + V_NAME

; boot name: the program after every reset; boot alone: which one
cmd_boot:
    push {r4, lr}
    mov  r4, r0
    bl   need_fs
    cmp  r0, #0
    beq  cb_done
    mov  r0, r4
    bl   skip_spaces
    ldrb r1, [r0]
    cmp  r1, #0
    bne  cb_set
    ldr  r0, cmd_boot_dirbuf
    ldr  r1, [r0, #12]
    cmp  r1, #0
    beq  cb_none
    lsls r1, r1, #5
    adds r0, r0, r1
    bl   put_text
    bl   print_inline
    db   ' starts after a reset', 13, 10, 0
    align 2
    b    cb_done
cb_none:
    bl   print_inline
    db   'no program starts after a reset (boot name sets one)', 13, 10, 0
    align 2
    b    cb_done
cb_set:
    bl   named_entry
    cmp  r0, #0
    beq  cb_done
    ldr  r1, cmd_boot_dirbuf_32
    subs r1, r0, r1
    lsrs r1, r1, #5
    adds r1, r1, #1
    ldr  r0, cmd_boot_dirbuf
    str  r1, [r0, #12]
    bl   dir_save
    cmp  r0, #0
    bne  cb_err
    ldr  r0, cmd_boot_vars_v_name
    bl   put_text
    bl   print_inline
    db   ' starts after every reset now (noboot: none)', 13, 10, 0
    align 2
    b    cb_done
cb_err:
    bl   flash_error
cb_done:
    pop  {r4, pc}

    align 4
cmd_boot_dirbuf:      dd DIRBUF
cmd_boot_dirbuf_32:   dd DIRBUF + 32
cmd_boot_vars_v_name: dd VARS + V_NAME

; noboot: no program after a reset
cmd_noboot:
    push {lr}
    bl   need_fs
    cmp  r0, #0
    beq  cnb_done
    ldr  r0, cmd_noboot_dirbuf
    movs r1, #0
    str  r1, [r0, #12]
    bl   dir_save
    cmp  r0, #0
    bne  cnb_err
    bl   print_inline
    db   'no program starts after a reset now', 13, 10, 0
    align 2
    b    cnb_done
cnb_err:
    bl   flash_error
cnb_done:
    pop  {pc}

    align 4
cmd_noboot_dirbuf: dd DIRBUF

; after the start: the program for boot, after a second without a key
autostart:
    push {r4, lr}
    ldr  r0, autostart_dirbuf
    ldr  r1, [r0, #12]
    cmp  r1, #0
    beq  as_done
    cmp  r1, #ENTRIES
    bhi  as_done
    lsls r4, r1, #5
    adds r4, r4, r0             ; its entry
    ldrb r0, [r4]
    cmp  r0, #0
    beq  as_done
    bl   print_inline
    db   'Autostart of ', 0
    align 2
    mov  r0, r4
    bl   put_text
    bl   print_inline
    db   ' in a second (a key to stay in the console)', 13, 10, 0
    align 2
    ldr  r0, autostart_k1000
    bl   wait_byte
    cmp  r0, #0
    blt  as_go
    bl   print_inline
    db   'No autostart this time.', 13, 10, 0
    align 2
    b    as_done
as_go:
    mov  r0, r4
    bl   load_file
    cmp  r1, #0
    beq  as_run
    bl   load_error
    b    as_done
as_run:
    ldr  r1, autostart_vars
    movs r2, #0
    str  r2, [r1, #V_QUIET]
    adds r1, #V_EMPTY
    bl   run_entry
as_done:
    pop  {r4, pc}

    align 4
autostart_dirbuf: dd DIRBUF
autostart_k1000:  dd 1000
autostart_vars:   dd VARS

; R address bytes: whole words (up to 1024) into the RAM of the programs
pk_ram:
    push {r4, r5, lr}
    bl   pk_len
    subs r5, r0, #4             ; the bytes
    blt  pr_bad
    ldr  r1, pk_ram_k1024
    cmp  r5, r1
    bhi  pr_bad
    lsls r1, r5, #30
    bne  pr_bad
    ldr  r0, pk_ram_pkt_4
    ldr  r4, [r0]               ; the address
    lsls r1, r4, #30
    bne  pr_where
    ldr  r1, pk_ram_prog_lo
    cmp  r4, r1
    blo  pr_where
    adds r1, r4, r5
    ldr  r2, pk_ram_prog_hi
    cmp  r1, r2
    bhi  pr_where
    adds r0, r0, #4
    movs r1, #0
pr_copy:
    cmp  r1, r5
    bge  pr_ok
    ldr  r2, [r0, r1]
    str  r2, [r4, r1]
    adds r1, r1, #4
    b    pr_copy
pr_ok:
    bl   send_ok
    pop  {r4, r5, pc}
pr_bad:
    bl   send_err_inline
    db   'R: an address and whole words, up to 1024 bytes', 0
    align 2
    pop  {r4, r5, pc}
pr_where:
    bl   send_err_inline
    db   'R: the RAM of the programs is 0x20000000 .. 0x2002FFFF', 0
    align 2
    pop  {r4, r5, pc}

    align 4
pk_ram_k1024:   dd 1024
pk_ram_pkt_4:   dd PKT + 4
pk_ram_prog_lo: dd PROG_LO
pk_ram_prog_hi: dd PROG_HI

; E entry: the program that R put into the RAM starts (k first); r0 2 (a program ran), or 0 (an error was sent)
pk_exec:
    push {r4, lr}
    bl   pk_len
    cmp  r0, #4
    bne  pe_bad
    ldr  r0, pk_exec_pkt_4
    ldr  r4, [r0]
    ldr  r1, pk_exec_prog_lo
    cmp  r4, r1
    blo  pe_bad
    ldr  r1, pk_exec_prog_hi
    cmp  r4, r1
    bhs  pe_bad
    bl   send_ok
    dsb
    isb
    ldr  r1, pk_exec_vars
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    adds r1, #V_EMPTY
    mov  r0, r4
    bl   run_entry
    movs r0, #2
    pop  {r4, pc}
pe_bad:
    bl   send_err_inline
    db   'E: the entry, in the RAM of the programs', 0
    align 2
    movs r0, #0
    pop  {r4, pc}

    align 4
pk_exec_pkt_4:   dd PKT + 4
pk_exec_prog_lo: dd PROG_LO
pk_exec_prog_hi: dd PROG_HI
pk_exec_vars:    dd VARS

; X name: the program starts (k first); r0 2 (a program ran), or 0 (an error was sent)
pk_run:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  px_none
    ldr  r4, pk_run_pkt_4
    movs r0, #0
    strb r0, [r4, #19]
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  px_nofile
    bl   load_file
    cmp  r1, #0
    bne  px_bad
    mov  r4, r0
    bl   send_ok
    ldr  r1, pk_run_vars
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    adds r1, #V_EMPTY
    mov  r0, r4
    bl   run_entry
    movs r0, #2
    pop  {r4, pc}
px_nofile:
    bl   send_err_inline
    db   'no such file', 0
    align 2
    b    px_none
px_bad:
    bl   send_err_inline
    db   'this is not a program for the RAM of the Pico (or the file is damaged)', 0
    align 2
px_none:
    movs r0, #0
    pop  {r4, pc}

    align 4
pk_run_pkt_4: dd PKT + 4
pk_run_vars:  dd VARS

; ---------- the console over the USB cable of the board ----------

.include "console_usb.asm"

; ---------- the debug monitor: programs under the debugger over the console ----------

.include "console_mon.asm"

; ---------- the board: one with WiFi (W)? ----------

.include "console_wifi.asm"

; ---------- the ESP8285 of the clones "Pico W-2023" (their WiFi chip) ----------

.include "console_esp.asm"

    align 4
image_end:
