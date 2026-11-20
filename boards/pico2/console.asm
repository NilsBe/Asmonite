; Raspberry Pi Pico 2 (RP2350, Arm core Cortex-M33): the console of Asmonite on UART0: a prompt, the files in the
; flash, programs started from them, and the packets for Asmonite, as on the ESP32 (boards\esp32\console.asm).
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
;   info              the board (a Pico 2 W too), the chip, its cores, the boot ROM, the console
;   reset             starts the chip again: the boot ROM starts the console from the flash
;   wlan [on | off]   the WiFi chip of a Pico 2 W: on starts it with its firmware (the files 43439A0.bin and
;                     nvram_rp2040.bin, which Prepare Board puts onto a W; ../pico/console_wifi.asm), off switches it
;                     off
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
; of the file and the segments: in the RAM of the programs, 0x20000000 .. 0x2006FFFF (448 KB), the entry too. It
; copies them to their place and calls the entry (Thumb) with r0 = the text of the arguments, on a stack of its own
; from 0x20070000 down. The program ends
;   - with bx lr: "Program ended (code n).", n its r0;
;   - with exit(code) from any depth;
;   - by an exception (a fault, an interrupt the console does not know): "Program stopped: exception n at pc ...";
;   - by Ctrl+C from the terminal (Stop in the tab Serial of Asmonite): "Program stopped (Ctrl+C).". While a program
;     runs, UART0 interrupts for each byte that comes (uart_irq): the bytes go into a ring for get_char, Ctrl+C stops
;     the program (not when it keeps the interrupts off);
; and the console goes on (its stack and its vector table again; the peripherals as the program leaves them).
; The functions of the console for programs: a table of their addresses (with the Thumb bit) at 0x20078140, in the
; order of the ESP32 (jt_exit there): +0 exit(code), +4 version() (2), +8 put_char(c), +12 get_char(), +16
; poll_char() (-1 if none came), +20 print(text), +24 millis(), +28 file_size(name) (-1 none), +32 file_read(name,
; buffer, offset, count) (the bytes read, -1), +36 file_write(name, buffer, count) (0, or -1 .. -5 as on the ESP
; boards), +40 flash_read (not yet: -1), +44 args(), +48
; led(on) (the LED of the board: GPIO 25; console_wifi.asm, wifi_led). A call:
;     movw r3, #0x8148
;     movt r3, #0x2007            ; put_char
;     ldr  r3, [r3]
;     blx  r3                     ; r0 .. r3 and r12 may change, as in AAPCS
; The same functions as code to call at 0x20079E00, 16 bytes each in the same order (+0x00 exit, +0x20 put_char,
; +0x50 print ...): bl or blx to the address itself, for a program that calls a function at a fixed address (aBelle:
; examples_internal/abelle/pico2/inc/console.abel).
; With boot, after a reset the console waits a second: a key stays in the console.
;
; Where it is:
;   - in the flash from 0x10000000 (Debug > Write to Flash and Run, or the UF2 file of Project > Save as UF2 file):
;     the vector table and the IMAGE_DEF block, which tells the boot ROM that the program is for the Arm cores
;   - at its start it copies itself into the RAM at 0x20070000 and runs there: while the flash is written no code can
;     be read from it. All the code is position independent (branches and calls relative to the pc, texts behind
;     the call that prints them: print_inline), so it runs at both places; only the addresses in the vector table of
;     the RAM (VTAB) are made for the RAM (+ RUN_OFFSET)
;   - its data and its stack: 0x20078000 .. 0x20080000 (equ below). The RAM from 0x20000000 to 0x20070000 is the
;     room of the programs
;   - the clocks: clk_ref and clk_sys at 12 MHz from the crystal (XOSC; after a reset they run from the ring
;     oscillator, whose frequency is not exact enough for a baud rate), clk_peri from clk_sys for the UART; SysTick
;     counts the cycles of the core (the waits for the bytes of a packet), TIMER0 the microseconds (millis; its
;     tick generator at 1 MHz from clk_ref)
;
; A fault (a read where nothing is, an instruction that is none) goes into the handler fault: it says which
; exception it was, its pc, CFSR and BFAR, and returns to the prompt.
;
; The file system: the flash from 1 MB to 4 MB (the Pico 2 has 4 MB), sectors of 4 KB, as on the ESP32:
;   - sectors 0x100 and 0x101: the directory, twice. It is written into the other sector each time, with a number
;     one higher; at the start the console takes the valid one with the higher number. So a reset or a power cut
;     while it is written leaves the directory as it was before.
;     A directory: "AFS1", the number, the CRC-32 of the 64 entries and then of the word behind it, the program for
;     boot (its entry + 1, 0 none), then from +32 64 entries of 32 bytes: the name (up to 19 characters and a 0), the
;     first sector, the length, the CRC-32 of the file.
;   - sectors 0x102 .. 0x3FD: the files, each in sectors one after the other (the first gap big enough). A new text
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
;   T entry        -> k  the same under the debug monitor: it stands at its entry (console_mon.asm: the packets then)
;   H              -> k  the board: "Raspberry Pi Pico 2" or "Raspberry Pi Pico 2 W" (console_wifi.asm asks the WiFi
;                         chip at the start)
;   M              -> k  a new, empty file system (all files are lost)
;   Q              -> k  back to the commands for a terminal (also after a second without a packet)
;   Y address count -> d the bytes of the flash at address (from its start; count up to 1024, address a multiple of 4)
;   K address count -> k the CRC-32 of count bytes of the flash at address (a multiple of 4)
;   S              -> e  (the UART stays at 115200 baud: at 12 MHz no faster rate is exact enough)
; e and a text: what went wrong (a damaged packet: the PC sends it again).
;
; The register conventions: r0 .. r3 arguments, values and scratch; a function keeps r4 .. r11 (push / pop).
.target pico2
.arch thumb
.imagebase 0x10000000

FLASH_BASE          equ 0x10000000
RAM_BASE            equ 0x20070000          ; the console runs here (its code: up to 0x20078000)
RUN_OFFSET          equ RAM_BASE - FLASH_BASE
VTAB                equ 0x20078000          ; its vector table in the RAM (VTOR: aligned to 512 bytes)
VTAB_ENTRIES        equ 68                  ; 16 of the core, 52 interrupts
LINE                equ 0x20078200          ; the line typed
LINE_MAX            equ 120
VARS                equ 0x20078300          ; the variables (V_ below)
CRCTAB              equ 0x20078400          ; the table of the CRC-32 (1 KB)
PKT                 equ 0x20078800          ; a packet that came: +1 the command, +2 the length, +4 the data
OUT                 equ 0x20078D00          ; a packet that goes: the same
PAGEBUF             equ 0x20079200          ; a piece of a file on its way into the flash (1 KB and a page)
DIRBUF              equ 0x2007A000          ; the directory (4 KB)
;                   DIRBUF + 0x1000 .. + 0x2100: the WiFi chip (console_wifi.asm: its packets, the scan, SHA-1, the
;                   record of the network)
STACK_TOP           equ 0x20080000

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
V_NAME              equ 64                  ; a name of a command for a terminal (a field of 20 bytes)
V_ONAME             equ 96                  ; the name of the open file (20 bytes)
V_RUN               equ 116                 ; 1 while a program runs
V_CSP               equ 120                 ; the stack pointer of the console while it runs
V_RHEAD             equ 124                 ; the ring: where uart_irq puts the next byte
V_RTAIL             equ 128                 ; ... and where get_char takes the next one
V_ARGS              equ 132                 ; the text of the arguments of the program
V_QUIET             equ 136                 ; 1: started by its name alone (no "Program ended (code 0)")
V_EMPTY             equ 140                 ; an empty text (0)
JT                  equ 0x20078140          ; the functions for programs (their addresses, see jt_init)
RING                equ 0x20079800          ; the bytes that came while a program runs (256)
PROG_LO             equ 0x20000000          ; the RAM of the programs
PROG_HI             equ 0x20070000          ; ... up to here; the stack of a program from here down
V_SRC               equ 144                 ; where the last byte came from: 0 UART0, 1 USB
V_PKT_USB           equ 148                 ; 1: the packets come over USB (the answers go there only)
V_WIFI              equ 152                 ; 1: a Pico 2 W (console_wifi.asm: its WiFi chip answered)
V_FQUIET            equ 156                 ; file_write: not 0: send_packet keeps its answer here (k, e)
V_FTEXT             equ 160                 ; ... the text of e
USBV                equ 0x20079900          ; the variables of console_usb.asm (128 bytes)
USB_RXB             equ 0x20079A00          ; ... its ring of what came over USB (256)
USB_TXB             equ 0x20079B00          ; ... and of what goes (256)
USB_UID             equ 0x20079C00          ; the id of the board (8 bytes: uid_read)
USB_SERIAL          equ 0x20079C40          ; the serial number of the USB device (48 bytes)
MONV                equ 0x20079D00          ; the variables of the debug monitor (console_mon.asm, M_ below, 64 bytes)
STUBS               equ 0x20079E00          ; the functions for programs to call, 16 bytes each (jt_init)
;                   STUBS + 0x100: the variables of the WiFi chip (64 bytes, console_wifi.asm: WLV)
M_ON                equ 0                   ; 1 while a program runs under the monitor (packet T)
M_FRAME             equ 4                   ; while it stands: the frame of the exception DebugMonitor
M_EXCRET            equ 8                   ; ... its EXC_RETURN
M_REGS              equ 12                  ; ... r4 .. r11 of the program (8 words)
M_RESUME            equ 44                  ; a step of the monitor: 1 over a breakpoint and on, 2 one for the PC
M_LASTPC            equ 48                  ; the pc before that step
M_STEPS             equ 52                  ; the steps that did not move (an interrupt came first)
M_REQ               equ 56                  ; 1: a Ctrl+C asked for the stop
M_PROBE             equ 60                  ; not 0: a fault in a read or write of m or v returns there
OTP_CHIPID          equ 0x40130000          ; the OTP, rows 0 .. 3 (16 bits each, ECC): the id of the chip
USB_IRQN             equ 14                  ; the interrupt of the USB controller
USB_RESET_BIT       equ 1 << 28             ; USBCTRL in RESETS

FS_SECTOR           equ 0x100               ; the first directory (1 MB)
FS_FIRST            equ 0x102               ; the first sector of the files
FS_END              equ 0x3FE               ; behind the last one (4 MB less the two sectors of the WiFi network:
;                                           0x3FE and 0x3FF, ../pico/console_wifi.asm)
ENTRIES             equ 64
MAGIC               equ 0x31534641          ; "AFS1"

; the registers (RP2350 datasheet)
SYSINFO             equ 0x40000000          ; +0 CHIP_ID, +4 PACKAGE_SEL
XOSC                equ 0x40048000
XOSC_CTRL           equ 0x00
XOSC_STATUS         equ 0x04
XOSC_STARTUP        equ 0x0c
XOSC_RANGE_1_15MHZ  equ 0xaa0
XOSC_STARTUP_DELAY  equ 282                 ; * 256 cycles of 12 MHz: about 6 ms
XOSC_ENABLE         equ (0xfab << 12) | 0xaa0
CLOCKS              equ 0x40010000
CLK_REF_CTRL        equ 0x30
CLK_REF_SELECTED    equ 0x38
CLK_REF_DIV         equ 0x34
CLK_SYS_CTRL        equ 0x3c                ; SRC bit 0 (0 clk_ref), AUXSRC bits 7 .. 5
CLK_SYS_DIV         equ 0x40                ; the whole part in bits 31 .. 16
CLK_SYS_SELECTED    equ 0x44
CLK_PERI_CTRL       equ 0x48
CLK_PERI_DIV        equ 0x4c
CLK_PERI_ENABLE     equ 1 << 11
CLK_USB_CTRL        equ 0x60
CLK_USB_DIV         equ 0x64                ; the whole part in bits 31 .. 16
PLL_USB             equ 0x40058000          ; +0 CS, +4 PWR, +8 FBDIV, +0xc PRIM
RESET_PLL_USB       equ 1 << 15
RESETS              equ 0x40020000
RESET_DONE          equ 0x08
RESET_BITS          equ (1 << 6) | (1 << 9) | (1 << 23) | (1 << 26)    ; IO_BANK0, PADS_BANK0, TIMER0, UART0
TICKS               equ 0x40108000          ; the tick generators: TIMER0 at +0x18 (CTRL), +0x1c (CYCLES)
TIMER0              equ 0x400b0000          ; +0x24 TIMERAWH, +0x28 TIMERAWL: the microseconds
ALIAS_CLR           equ 0x3000              ; + of a register address: clears the bits written
IO_BANK0            equ 0x40028000
GPIO0_CTRL          equ 0x04
GPIO1_CTRL          equ 0x0c
FUNCSEL_UART        equ 2
PADS_BANK0          equ 0x40038000
SIO_IN              equ 0x04                ; the SIO (0xd0000000): GPIO_IN
SIO_OUT_SET         equ 0x18
SIO_OUT_CLR         equ 0x20
SIO_OE_SET          equ 0x38
SIO_OE_CLR          equ 0x40
PAD_GPIO0           equ 0x04
PAD_GPIO1           equ 0x08
PAD_ISO             equ 1 << 8              ; the isolation of the pad: on after a reset of the RP2350
PAD_RX              equ 0x5a                ; GPIO 1: input on (IE), 4 mA, pull-up, Schmitt trigger, no isolation
UART0               equ 0x40070000          ; an Arm PL011
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
NVIC_ISER1          equ 0xe000e104          ; the interrupts 32 .. 63 on (UART0 is 33)
NVIC_ICER1          equ 0xe000e184          ; ... off
UART0_VECTOR        equ 16 + 33             ; its entry in the vector table
CR_ON               equ (1 << 0) | (1 << 8) | (1 << 9)      ; UARTEN, TXE, RXE
SYST_CSR            equ 0xe000e010          ; SysTick: on, the clock of the core
SYST_RVR            equ 0xe000e014
SYST_CVR            equ 0xe000e018          ; counts down, 24 bits
US_MS               equ 1000                ; TIMER0 counts microseconds
SCB_CPUID           equ 0xe000ed00
SCB_VTOR            equ 0xe000ed08
SCB_AIRCR           equ 0xe000ed0c
AIRCR_RESET         equ 0x05fa0004          ; VECTKEY, SYSRESETREQ
SCB_CFSR            equ 0xe000ed28
SCB_BFAR            equ 0xe000ed38

; ---------- in the flash: what the boot ROM finds, the copy into the RAM ----------

vectors:
    dd STACK_TOP                ; the stack pointer at the start
    dd _start + 1               ; reset (+1: Thumb code)
    dd hang + 1                 ; NMI
    dd hang + 1                 ; HardFault (until the table in the RAM takes over)

; IMAGE_DEF: a program for the Arm cores of the RP2350
image_def:
    dd 0xffffded3               ; start marker
    db 0x42, 1                  ; item IMAGE_TYPE, 1 word
    dw 0x1021                   ; executable | Secure | Arm | RP2350
    db 0xff
    dw 1                        ; the items so far, in words
    db 0
    dd 0                        ; no further block
    dd 0xab123579               ; end marker

_start:
    movw r0, #(FLASH_BASE & 0xffff)
    movt r0, #(FLASH_BASE >> 16)
    movw r1, #(RAM_BASE & 0xffff)
    movt r1, #(RAM_BASE >> 16)
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
lit_size:   dd image_end - vectors
lit_main:   dd main + RUN_OFFSET + 1

; ---------- in the RAM from here on ----------

main:
    movw r0, #(STACK_TOP & 0xffff)
    movt r0, #(STACK_TOP >> 16)
    mov  sp, r0
    movs r0, #0
    msr  msplim, r0             ; no limit of the stack (the boot ROM may have set one)
    bl   vtab_init
    bl   uart_init
    bl   uid_read
    bl   usb_init                   ; (console_usb.asm) the PC sees the COM port of the console
    bl   crc_init
    bl   vars_init
    bl   mon_init
    bl   rom_init
    bl   dir_load
    bl   jt_init
    bl   wifi_detect                ; (console_wifi.asm) a Pico 2 W?
    bl   print_inline
    db   13, 10, 'Asmonite console 2 for the RP2350 (', 0
    align 2
    bl   put_board
    bl   print_inline
    db   '; help shows the commands)', 13, 10, 0
    align 2
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r1, [r0, #V_FN + 20]
    cmp  r1, #0
    bne  main_rom
    bl   print_inline
    db   'The boot ROM has not all the functions for the flash: the files cannot be written.', 13, 10, 0
    align 2
main_rom:
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  main_nofs
    bl   autostart
    b    prompt
main_nofs:
    bl   print_inline
    db   'No file system in the flash yet: format makes one.', 13, 10, 0
    align 2
    b    prompt
prompt:
    bl   print_inline
    db   '> ', 0
    align 2
    bl   read_line
    bl   command
    b    prompt

; after a fault (fault: the exception returns here)
recover:
    movw r0, #(STACK_TOP & 0xffff)
    movt r0, #(STACK_TOP >> 16)
    mov  sp, r0
    b    prompt

; the vector table in the RAM: every exception and interrupt to fault (they are not used yet), VTOR to it
vtab_init:
    movw r0, #(VTAB & 0xffff)
    movt r0, #(VTAB >> 16)
    ldr  r1, lit_fault
    movs r2, #0
vt_fill:
    str  r1, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #VTAB_ENTRIES * 4
    blt  vt_fill
    movw r1, #(STACK_TOP & 0xffff)
    movt r1, #(STACK_TOP >> 16)
    str  r1, [r0]
    ldr  r1, lit_main_ram
    str  r1, [r0, #4]
    ldr  r1, lit_uart_irq
    str  r1, [r0, #UART0_VECTOR * 4]
    ldr  r1, lit_usb_irq
    str  r1, [r0, #(16 + USB_IRQN) * 4]
    ldr  r1, lit_mon
    str  r1, [r0, #12 * 4]          ; DebugMonitor (console_mon.asm)
    movw r1, #(SCB_VTOR & 0xffff)
    movt r1, #(SCB_VTOR >> 16)
    str  r0, [r1]
    dsb
    isb
    bx   lr

    align 4
lit_fault:      dd fault + RUN_OFFSET + 1
lit_main_ram:   dd main + RUN_OFFSET + 1
lit_recover:    dd recover + RUN_OFFSET
lit_uart_irq:   dd uart_irq + RUN_OFFSET + 1
lit_usb_irq:    dd usb_irq + RUN_OFFSET + 1
lit_abort:      dd prog_abort + RUN_OFFSET
lit_mon:        dd mon_handler + RUN_OFFSET + 1

; an exception: which one, its pc, CFSR and BFAR; then back to the prompt (its frame gets the pc of recover)
fault:
    mov  r1, sp                 ; the frame
    push {r7, lr}               ; r7 of the code the exception came from, and EXC_RETURN
    mov  r7, lr                 ; EXC_RETURN (the calls below change lr)
    bl   mon_fault              ; a read or write of the debug monitor where nothing is: back into it
    cmp  r0, #0
    beq  fa_go
    pop  {r7, pc}               ; back with its r7 (the pc gets EXC_RETURN: the return of the exception)
fa_go:
    add  sp, sp, #8             ; (from here r7 is EXC_RETURN: the console goes on at recover or prog_abort)
    mrs  r4, ipsr
    mov  r5, sp                 ; the frame: r0 r1 r2 r3 r12 lr pc xpsr
    movw r6, #(SCB_BFAR & 0xffff)
    movt r6, #(SCB_BFAR >> 16)
    ldr  r8, [r6]               ; BFAR before CFSR is cleared (that clears its BFARVALID)
    movw r9, #(VARS & 0xffff)
    movt r9, #(VARS >> 16)
    ldr  r9, [r9, #V_RUN]       ; a program runs: it stops
    cmp  r9, #0
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
    bl   print_inline
    db   ', CFSR 0x', 0
    align 2
    movw r6, #(SCB_CFSR & 0xffff)
    movt r6, #(SCB_CFSR >> 16)
    ldr  r0, [r6]
    str  r0, [r6]               ; its bits cleared (write 1)
    bl   put_hex8
    bl   print_inline
    db   ', BFAR 0x', 0
    align 2
    mov  r0, r8
    bl   put_hex8
    bl   put_nl
    ldr  r0, lit_recover
    cmp  r9, #0
    beq  fa_back
    ldr  r0, lit_abort
fa_back:
    str  r0, [r5, #24]
    movs r0, #1
    lsls r0, r0, #24            ; xPSR: only the Thumb bit
    str  r0, [r5, #28]
    bx   r7

; the variables: no file open
vars_init:
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    movs r1, #0
    movs r2, #0
vi_clear:
    str  r1, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #256
    blt  vi_clear
    bx   lr

; the id of the chip (OTP rows 0 .. 3, CHIPID0 .. 3) into USB_UID: the serial number of the USB device
uid_read:
    movw r0, #(OTP_CHIPID & 0xffff)
    movt r0, #(OTP_CHIPID >> 16)
    ldr  r1, [r0]
    ldr  r2, [r0, #4]
    movw r0, #(USB_UID & 0xffff)
    movt r0, #(USB_UID >> 16)
    str  r1, [r0]
    str  r2, [r0, #4]
    bx   lr

; ---------- UART0 and SysTick ----------

; the crystal, clk_ref (and with it clk_sys) from it, clk_peri; GPIO 0 and 1 to UART0; 115200 baud 8N1
uart_init:
    movw r1, #(XOSC & 0xffff)
    movt r1, #(XOSC >> 16)
    movw r0, #XOSC_RANGE_1_15MHZ
    str  r0, [r1, #XOSC_CTRL]
    movw r0, #XOSC_STARTUP_DELAY
    str  r0, [r1, #XOSC_STARTUP]
    movw r0, #(XOSC_ENABLE & 0xffff)
    movt r0, #(XOSC_ENABLE >> 16)
    str  r0, [r1, #XOSC_CTRL]
ui_xosc:
    ldr  r0, [r1, #XOSC_STATUS]
    cmp  r0, #0
    bge  ui_xosc                ; bit 31 STABLE
    ; clk_sys from clk_ref, and clk_peri from clk_sys: not only after a reset. After the USB boot (an empty flash:
    ; Erase Flash, then Prepare Board) the reset at the end of a write of the flash leaves the clocks as they were,
    ; clk_sys at 48 MHz from a PLL: the UART ran at four times the rate (found by the user). Each switch as the
    ; datasheet wants it: only SRC of the glitchless clocks (AUXSRC changed while it is the source may glitch: that
    ; stopped the chip), clk_peri off and waited for before its source changes
    movw r1, #(CLOCKS & 0xffff)
    movt r1, #(CLOCKS >> 16)
    ldr  r0, [r1, #CLK_SYS_CTRL]
    bic  r0, r0, #1             ; SRC 0: clk_ref
    str  r0, [r1, #CLK_SYS_CTRL]
ui_sys:
    ldr  r0, [r1, #CLK_SYS_SELECTED]
    tst  r0, #1
    beq  ui_sys
    movs r0, #1
    lsls r0, r0, #16
    str  r0, [r1, #CLK_SYS_DIV]     ; 1
    str  r0, [r1, #CLK_REF_DIV]     ; 1
    ldr  r0, [r1, #CLK_REF_CTRL]
    bic  r0, r0, #3
    orr  r0, r0, #2             ; SRC 2: XOSC
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
ui_usb_off:
    ldr  r0, [r1, #CLK_USB_CTRL]
    tst  r0, #1 << 28               ; ENABLED
    bne  ui_usb_off
    movw r2, #((RESETS + 0x2000) & 0xffff)
    movt r2, #((RESETS + 0x2000) >> 16)
    movw r0, #(RESET_PLL_USB & 0xffff)
    str  r0, [r2]                   ; PLL_USB into reset ...
    movw r2, #((RESETS + ALIAS_CLR) & 0xffff)
    movt r2, #((RESETS + ALIAS_CLR) >> 16)
    str  r0, [r2]                   ; ... and out again
    movw r2, #(RESETS & 0xffff)
    movt r2, #(RESETS >> 16)
ui_pll_reset:
    ldr  r3, [r2, #RESET_DONE]
    tst  r3, r0
    beq  ui_pll_reset
    movw r2, #(PLL_USB & 0xffff)
    movt r2, #(PLL_USB >> 16)
    movs r0, #1
    str  r0, [r2]                   ; CS: REFDIV 1
    movs r0, #40
    str  r0, [r2, #8]               ; FBDIV
    movs r0, #0x0c                  ; PWR: PD and VCOPD off (DSMPD and POSTDIVPD stay: 0x2d at reset)
    str  r0, [r2, #4]
ui_pll_lock:
    ldr  r0, [r2]
    cmp  r0, #0
    bge  ui_pll_lock                ; bit 31 LOCK
    movw r0, #(2 << 12)
    movt r0, #5                     ; PRIM: POSTDIV1 5, POSTDIV2 2
    str  r0, [r2, #0x0c]
    movs r0, #0x04                  ; POSTDIVPD off too
    str  r0, [r2, #4]
    movs r0, #1
    lsls r0, r0, #16
    str  r0, [r1, #CLK_USB_DIV]     ; 1
    movw r0, #(1 << 11)             ; ENABLE, AUXSRC 0: PLL_USB
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
ui_peri:
    ldr  r0, [r1, #CLK_PERI_CTRL]
    tst  r0, #1 << 28           ; ENABLED
    bne  ui_peri
    movs r0, #1
    lsls r0, r0, #16
    str  r0, [r1, #CLK_PERI_DIV]    ; 1
    movw r0, #CLK_PERI_ENABLE   ; AUXSRC 0: clk_sys
    str  r0, [r1, #CLK_PERI_CTRL]
    movw r1, #((RESETS + ALIAS_CLR) & 0xffff)
    movt r1, #((RESETS + ALIAS_CLR) >> 16)
    movw r0, #(RESET_BITS & 0xffff)
    movt r0, #(RESET_BITS >> 16)
    str  r0, [r1]
    movw r1, #(RESETS & 0xffff)
    movt r1, #(RESETS >> 16)
ui_reset:
    ldr  r2, [r1, #RESET_DONE]
    and  r2, r2, r0
    cmp  r2, r0
    bne  ui_reset
    movw r1, #((PADS_BANK0 + ALIAS_CLR) & 0xffff)
    movt r1, #((PADS_BANK0 + ALIAS_CLR) >> 16)
    movw r0, #PAD_ISO
    str  r0, [r1, #PAD_GPIO0]
    movw r1, #(PADS_BANK0 & 0xffff)
    movt r1, #(PADS_BANK0 >> 16)
    movs r0, #PAD_RX
    str  r0, [r1, #PAD_GPIO1]
    movw r1, #(IO_BANK0 & 0xffff)
    movt r1, #(IO_BANK0 >> 16)
    movs r0, #FUNCSEL_UART
    str  r0, [r1, #GPIO0_CTRL]
    str  r0, [r1, #GPIO1_CTRL]
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
    movs r0, #26                ; 48,000,000 / (16 * 115200) = 26.04: 26 and 3/64
    str  r0, [r1, #UARTIBRD]
    movs r0, #3
    str  r0, [r1, #UARTFBRD]
    movs r0, #LCR_8BIT_FIFO
    str  r0, [r1, #UARTLCR_H]
    movw r0, #CR_ON
    str  r0, [r1, #UARTCR]
    movw r1, #(TICKS & 0xffff)
    movt r1, #(TICKS >> 16)
    movs r0, #12                ; 12 cycles of clk_ref: a microsecond
    str  r0, [r1, #0x1c]
    movs r0, #1
    str  r0, [r1, #0x18]
    bx   lr

; the microseconds of TIMER0 in r0 (its low word: it wraps after 71 minutes)
tick_now:
    movw r1, #(TIMER0 & 0xffff)
    movt r1, #(TIMER0 >> 16)
    ldr  r0, [r1, #0x28]        ; TIMERAWL
    bx   lr

; the byte r0 out (waits while the send FIFO is full) to UART0 and over USB (console_usb.asm: when a terminal has the
; port open); keeps r0. While packets come over USB (V_PKT_USB) only there: the UART is much slower
put_char:
    push {r0, lr}
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    ldr  r1, [r1, #V_PKT_USB]
    cmp  r1, #0
    bne  pc_usb
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
pc_wait:
    ldr  r2, [r1, #UARTFR]
    tst  r2, #UARTFR_TXFF
    bne  pc_wait
    str  r0, [r1, #UARTDR]
pc_usb:
    bl   usb_putc
    pop  {r0, pc}

; a byte that came in r0, from UART0 or over USB, -1 when none waits; V_SRC says where it came from. A byte of the
; UART with an error (bits 8 .. 11 of UARTDR: framing, parity, break, overrun) is left out: at a reset of the chip a 0
; with a break came
poll_byte:
    push {lr}
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
pb_uart:
    ldr  r2, [r1, #UARTFR]
    tst  r2, #UARTFR_RXFE
    bne  pb_usb
    ldr  r0, [r1, #UARTDR]
    tst  r0, #UARTDR_ERRORS
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
    movw r2, #(VARS & 0xffff)
    movt r2, #(VARS >> 16)
    str  r1, [r2, #V_SRC]
pb_end:
    pop  {pc}

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
    movw r1, #US_MS
    mul  r4, r0, r1             ; the microseconds to wait
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
    bic  r4, r4, #1             ; behind the 0, at the next halfword
    adds r4, r4, #1
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
    lsr  r0, r4, r1
    and  r0, r0, #15
    cmp  r0, #10
    blt  ph_digit
    adds r0, r0, #'a' - 10 - '0'
ph_digit:
    adds r0, r0, #'0'
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
    sub  sp, sp, #12
    mov  r4, r0
    movs r6, #0
    movs r5, #10
pd_div:
    udiv r1, r4, r5
    mul  r2, r1, r5
    subs r2, r4, r2
    adds r2, r2, #'0'
    strb r2, [sp, r6]
    adds r6, r6, #1
    mov  r4, r1
    cmp  r4, #0
    bne  pd_div
pd_out:
    subs r6, r6, #1
    ldrb r0, [sp, r6]
    bl   put_char
    cmp  r6, #0
    bne  pd_out
    add  sp, sp, #12
    pop  {r4, r5, r6, pc}

; r0 in decimal, right-aligned in r1 places
put_dec_w:
    push {r4, r5, lr}
    mov  r4, r0
    mov  r5, r1
    movs r2, #1                 ; its digits
    movs r3, #10
pw_count:
    cmp  r0, #10
    blo  pw_pad
    udiv r0, r0, r3
    adds r2, r2, #1
    b    pw_count
pw_pad:
    cmp  r2, r5
    bge  pw_out
    push {r2}
    bl   put_space
    pop  {r2}
    adds r2, r2, #1
    b    pw_pad
pw_out:
    mov  r0, r4
    bl   put_dec
    pop  {r4, r5, pc}

; ---------- input ----------

; a line into LINE (echo, Backspace, Ctrl+C throws it away, CR or LF ends it, the LF of CR LF is skipped); r0 = LINE.
; An STX: packets from a program on the PC (packet_mode), then the line again from its start, without an echo
read_line:
    push {r4, r5, r6, lr}
    movw r5, #(LINE & 0xffff)
    movt r5, #(LINE >> 16)
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
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    ldr  r2, [r1, #V_SRC]
    str  r2, [r1, #V_PKT_USB]       ; the STX came over USB: the answers go there only
    bl   packet_mode
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
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
    cmp  r6, #13
    mov  r6, r0
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
    bic  r1, r1, #1
    adds r1, r1, #1
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
    orr  r3, r3, #0x20
    cmp  r3, #'x'
    bne  pn_dec
    adds r1, r1, #2
pn_hex:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  pn_end
    cmp  r3, #' '
    beq  pn_end
    sub  r4, r3, #'0'
    cmp  r4, #10
    blo  pn_hex_digit
    orr  r3, r3, #0x20
    sub  r4, r3, #'a'
    cmp  r4, #6
    bhs  pn_bad
    adds r4, r4, #10
pn_hex_digit:
    lsls r0, r0, #4
    orr  r0, r0, r4
    adds r2, r2, #1
    adds r1, r1, #1
    b    pn_hex
pn_dec:
    ldrb r3, [r1]
    cmp  r3, #0
    beq  pn_end
    cmp  r3, #' '
    beq  pn_end
    sub  r4, r3, #'0'
    cmp  r4, #10
    bhs  pn_bad
    movs r3, #10
    mul  r0, r0, r3
    add  r0, r0, r4
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
    movw r1, #((VARS + V_NAME) & 0xffff)
    movt r1, #((VARS + V_NAME) >> 16)
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
    add  r1, r0, r2             ; behind the name
    mov  r0, r2
    pop  {r4, pc}

; ---------- the CRC-32 (zlib) ----------

crc_init:
    push {r4, lr}
    movw r0, #(CRCTAB & 0xffff)
    movt r0, #(CRCTAB >> 16)
    movw r3, #0x8320
    movt r3, #0xedb8            ; the polynomial, reflected
    movs r1, #0                 ; the byte
ct_byte:
    mov  r2, r1
    movs r4, #8
ct_bit:
    lsrs r2, r2, #1
    bcc  ct_nopoly
    eor  r2, r2, r3
ct_nopoly:
    subs r4, r4, #1
    bne  ct_bit
    str  r2, [r0, r1, lsl #2]
    adds r1, r1, #1
    cmp  r1, #256
    blt  ct_byte
    pop  {r4, pc}

; the CRC r0 (0 at the start, or the one of the bytes before) of r2 bytes at r1 more: r0
crc32:
    push {r4, r5, lr}
    movw r4, #(CRCTAB & 0xffff)
    movt r4, #(CRCTAB >> 16)
    mvn  r0, r0
cr_next:
    cmp  r2, #0
    beq  cr_end
    ldrb r3, [r1]
    eor  r3, r3, r0
    uxtb r3, r3
    ldr  r5, [r4, r3, lsl #2]
    eor  r0, r5, r0, lsr #8
    adds r1, r1, #1
    subs r2, r2, #1
    b    cr_next
cr_end:
    mvn  r0, r0
    pop  {r4, r5, pc}

; ---------- the flash: the functions of the boot ROM ----------

; the function of the boot ROM with the code r0 (two letters, the first in the low byte) for the Secure Arm code:
; its address (with the Thumb bit) in r0, 0 when there is none. The table (its address in the halfword at 0x14):
; a code, its flags, then data for each flag set: RISC-V (bit 0; bit 1 too: 4 bytes, else 2), Arm Secure (bit 2: the
; halfword of its address), Arm Non-secure (bit 4), data (bit 6); a code 0 ends it
rom_find:
    push {r4, r5, lr}
    movs r1, #0x14
    ldrh r1, [r1]               ; the table
rf_next:
    ldrh r2, [r1]               ; the code
    cmp  r2, #0
    beq  rf_none
    ldrh r3, [r1, #2]           ; the flags
    adds r1, r1, #4
    and  r4, r3, #3
    cmp  r4, #3
    bne  rf_rv2
    adds r1, r1, #4
    b    rf_arm
rf_rv2:
    tst  r3, #1
    beq  rf_arm
    adds r1, r1, #2
rf_arm:
    cmp  r2, r0
    bne  rf_skip
    tst  r3, #4
    beq  rf_none
    ldrh r0, [r1]
    orr  r0, r0, #1
    pop  {r4, r5, pc}
rf_skip:
    tst  r3, #4
    beq  rf_skip2
    adds r1, r1, #2
rf_skip2:
    tst  r3, #0x10
    beq  rf_skip3
    adds r1, r1, #2
rf_skip3:
    tst  r3, #0x40
    beq  rf_next
    adds r1, r1, #2
    b    rf_next
rf_none:
    movs r0, #0
    pop  {r4, r5, pc}

; the six functions for the flash into V_FN (0 for one that is not there)
rom_init:
    push {r4, r5, lr}
    movw r4, #((VARS + V_FN) & 0xffff)
    movt r4, #((VARS + V_FN) >> 16)
    movw r0, #('I' | ('F' << 8))
    bl   rom_find
    str  r0, [r4]
    movw r0, #('E' | ('X' << 8))
    bl   rom_find
    str  r0, [r4, #4]
    movw r0, #('R' | ('E' << 8))
    bl   rom_find
    str  r0, [r4, #8]
    movw r0, #('R' | ('P' << 8))
    bl   rom_find
    str  r0, [r4, #12]
    movw r0, #('F' | ('C' << 8))
    bl   rom_find
    str  r0, [r4, #16]
    movw r0, #('C' | ('X' << 8))
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

; calls the function r3 of V_FN (its offset) with r0 .. r2 and a fourth argument from the stack ...: see below
; the flash ready to be written: connect_internal_flash, flash_exit_xip (the XIP window gives nothing from now on)
flash_open:
    push {r4, lr}
    movw r4, #((VARS + V_FN) & 0xffff)
    movt r4, #((VARS + V_FN) >> 16)
    ldr  r3, [r4]
    blx  r3
    ldr  r3, [r4, #4]
    blx  r3
    pop  {r4, pc}

; the flash readable through the XIP window again: flash_flush_cache, flash_enter_cmd_xip
flash_close:
    push {r4, lr}
    movw r4, #((VARS + V_FN) & 0xffff)
    movt r4, #((VARS + V_FN) >> 16)
    ldr  r3, [r4, #16]
    blx  r3
    ldr  r3, [r4, #20]
    blx  r3
    pop  {r4, pc}

; r1 bytes of the flash from its place r0 erased (both multiples of 4 KB): flash_range_erase(r0, r1, 4096, 0x20)
flash_erase:
    push {r4, lr}
    movw r4, #((VARS + V_FN) & 0xffff)
    movt r4, #((VARS + V_FN) >> 16)
    movw r2, #4096
    movs r3, #0x20
    ldr  r4, [r4, #8]
    blx  r4
    pop  {r4, pc}

; r2 bytes (a multiple of 256) from r1 into the flash at its place r0 (a multiple of 256): flash_range_program
flash_program:
    push {r4, lr}
    movw r4, #((VARS + V_FN) & 0xffff)
    movt r4, #((VARS + V_FN) >> 16)
    ldr  r4, [r4, #12]
    blx  r4
    pop  {r4, pc}

; ---------- the directory ----------

; the directory at r0 (in the flash, through XIP) valid? r0 1 or 0
dir_valid:
    push {r4, lr}
    mov  r4, r0
    ldr  r1, [r4]
    movw r2, #(MAGIC & 0xffff)
    movt r2, #(MAGIC >> 16)
    cmp  r1, r2
    bne  dv_no
    movs r0, #0
    add  r1, r4, #32
    movw r2, #ENTRIES * 32
    bl   crc32
    add  r1, r4, #12
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

; the valid directory with the higher number into DIRBUF (V_FSOK, V_DIRSEC)
dir_load:
    push {r4, r5, r6, lr}
    movw r4, #((FLASH_BASE + FS_SECTOR * 4096) & 0xffff)
    movt r4, #((FLASH_BASE + FS_SECTOR * 4096) >> 16)
    mov  r0, r4
    bl   dir_valid
    mov  r5, r0
    add  r0, r4, #4096
    bl   dir_valid
    mov  r6, r0
    cmp  r5, #0
    beq  dl_one
    cmp  r6, #0
    beq  dl_zero
    ldr  r0, [r4, #4]
    add  r1, r4, #4096
    ldr  r1, [r1, #4]
    cmp  r1, r0
    bhi  dl_first               ; the second one is newer
    b    dl_zero
dl_one:
    cmp  r6, #0
    beq  dl_none
dl_first:
    add  r4, r4, #4096
    movw r5, #(FS_SECTOR + 1)
    b    dl_copy
dl_zero:
    movw r5, #FS_SECTOR
dl_copy:
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
    movs r1, #0
dl_word:
    ldr  r2, [r4, r1]
    str  r2, [r0, r1]
    adds r1, r1, #4
    cmp  r1, #4096
    blt  dl_word
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    str  r5, [r0, #V_DIRSEC]
    movs r1, #1
    str  r1, [r0, #V_FSOK]
    pop  {r4, r5, r6, pc}
dl_none:
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    movs r1, #0
    str  r1, [r0, #V_FSOK]
    pop  {r4, r5, r6, pc}

; DIRBUF with a number one higher and its CRC into the other sector of the directory; r0 0, or -1 when the boot ROM
; has not the functions for the flash
dir_save:
    push {r4, r5, lr}
    movw r4, #(DIRBUF & 0xffff)
    movt r4, #(DIRBUF >> 16)
    movw r5, #(VARS & 0xffff)
    movt r5, #(VARS >> 16)
    ldr  r0, [r5, #V_FN + 20]
    cmp  r0, #0
    beq  ds_err
    ldr  r0, [r4, #4]
    adds r0, r0, #1
    str  r0, [r4, #4]
    bl   dir_crc
    ldr  r0, [r5, #V_DIRSEC]
    eor  r0, r0, #1             ; 0x100 <-> 0x101
    str  r0, [r5, #V_DIRSEC]
    bl   flash_open
    ldr  r0, [r5, #V_DIRSEC]
    lsls r0, r0, #12
    movw r1, #4096
    bl   flash_erase
    ldr  r0, [r5, #V_DIRSEC]
    lsls r0, r0, #12
    mov  r1, r4
    movw r2, #4096
    bl   flash_program
    bl   flash_close
    movs r0, #0
    pop  {r4, r5, pc}
ds_err:
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, pc}

; the CRC of DIRBUF into its word at +8
dir_crc:
    push {r4, lr}
    movw r4, #(DIRBUF & 0xffff)
    movt r4, #(DIRBUF >> 16)
    movs r0, #0
    add  r1, r4, #32
    movw r2, #ENTRIES * 32
    bl   crc32
    add  r1, r4, #12
    movs r2, #4
    bl   crc32
    str  r0, [r4, #8]
    pop  {r4, pc}

; a new, empty file system: the second directory erased (its number may be higher), the first one written with the
; number 1; r0 0, or -1 (no functions for the flash)
make_fs:
    push {r4, r5, lr}
    movw r5, #(VARS & 0xffff)
    movt r5, #(VARS >> 16)
    ldr  r0, [r5, #V_FN + 20]
    cmp  r0, #0
    beq  mf_err
    movw r4, #(DIRBUF & 0xffff)
    movt r4, #(DIRBUF >> 16)
    movs r0, #0
    movs r1, #0
mf_clear:
    str  r0, [r4, r1]
    adds r1, r1, #4
    cmp  r1, #4096
    blt  mf_clear
    movw r0, #(MAGIC & 0xffff)
    movt r0, #(MAGIC >> 16)
    str  r0, [r4]
    movs r0, #1
    str  r0, [r4, #4]
    bl   dir_crc
    bl   flash_open
    movw r0, #(FS_SECTOR * 4096 & 0xffff)
    movt r0, #(FS_SECTOR * 4096 >> 16)
    movw r1, #8192
    bl   flash_erase
    movw r0, #(FS_SECTOR * 4096 & 0xffff)
    movt r0, #(FS_SECTOR * 4096 >> 16)
    mov  r1, r4
    movw r2, #4096
    bl   flash_program
    bl   flash_close
    movw r0, #FS_SECTOR
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

; the entry of the name field r0 (20 bytes, zeros behind the name) in DIRBUF: r0, or 0 when there is none
find_entry:
    push {r4, r5, r6, lr}
    mov  r4, r0
    movw r5, #((DIRBUF + 32) & 0xffff)
    movt r5, #((DIRBUF + 32) >> 16)
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
    adds r5, r5, #32
    adds r6, r6, #1
    cmp  r6, #ENTRIES
    blt  fe_next
    movs r0, #0
    pop  {r4, r5, r6, pc}

; a free entry in DIRBUF: r0, or 0 when all are taken
free_entry:
    movw r0, #((DIRBUF + 32) & 0xffff)
    movt r0, #((DIRBUF + 32) >> 16)
    movs r1, #0
fr_next:
    ldrb r2, [r0]
    cmp  r2, #0
    beq  fr_found
    adds r0, r0, #32
    adds r1, r1, #1
    cmp  r1, #ENTRIES
    blt  fr_next
    movs r0, #0
fr_found:
    bx   lr

; the first gap of r0 sectors among the files (from FS_FIRST): its first sector in r0, 0 when there is none
find_gap:
    push {r4, r5, r6, r7, lr}
    mov  r4, r0                 ; the sectors
    movw r5, #FS_FIRST          ; the candidate
fg_again:
    add  r0, r5, r4
    movw r1, #FS_END
    cmp  r0, r1
    bhi  fg_none
    movw r6, #((DIRBUF + 32) & 0xffff)
    movt r6, #((DIRBUF + 32) >> 16)
    movs r7, #0
fg_entry:
    ldrb r0, [r6]
    cmp  r0, #0
    beq  fg_skip
    ldr  r1, [r6, #24]          ; the length
    cmp  r1, #0
    beq  fg_skip
    ldr  r0, [r6, #20]          ; its first sector
    addw r1, r1, #4095
    lsrs r1, r1, #12
    add  r1, r1, r0             ; behind it
    cmp  r5, r1
    bhs  fg_skip                ; the candidate behind it
    add  r2, r5, r4
    cmp  r0, r2
    bhs  fg_skip                ; it behind the candidate
    mov  r5, r1                 ; they overlap: behind it
    b    fg_again
fg_skip:
    adds r6, r6, #32
    adds r7, r7, #1
    cmp  r7, #ENTRIES
    blt  fg_entry
    mov  r0, r5
    pop  {r4, r5, r6, r7, pc}
fg_none:
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; the bytes in use by the files (whole sectors) in r0, the files in r1
dir_used:
    movw r2, #((DIRBUF + 32) & 0xffff)
    movt r2, #((DIRBUF + 32) >> 16)
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
    addw r3, r3, #4095
    bic  r3, r3, #0xff
    bic  r3, r3, #0xf00
    add  r0, r0, r3
du_skip:
    adds r2, r2, #32
    adds r4, r4, #1
    cmp  r4, #ENTRIES
    blt  du_next
    pop  {r4, r5}
    bx   lr

; ---------- the commands for a terminal ----------

; the line at r0: its command
command:
    push {r4, lr}
    bl   skip_spaces
    mov  r4, r0
    ldrb r1, [r4]
    cmp  r1, #0
    beq  cm_end                 ; an empty line
    mov  r0, r4
    bl   wifi_command               ; (console_wifi.asm) wlan
    cmp  r0, #0
    bne  cm_end
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

; help: the file help.txt (Prepare Board writes it, boards\pico2\help.txt), else the short list
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
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    bne  nfs_ok
    bl   print_inline
    db   'no file system (format makes one)', 13, 10, 0
    align 2
    movs r0, #0
nfs_ok:
    pop  {pc}

; ls: the name, the length, the program for boot; the files and their bytes
cmd_ls:
    push {r4, r5, r6, r7, lr}
    bl   need_fs
    cmp  r0, #0
    beq  ls_done
    movw r4, #((DIRBUF + 32) & 0xffff)
    movt r4, #((DIRBUF + 32) >> 16)
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
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
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
    adds r4, r4, #32
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
    movw r0, #((FS_END - FS_FIRST) * 4096 & 0xffff)
    movt r0, #((FS_END - FS_FIRST) * 4096 >> 16)
    subs r0, r0, r4
    bl   put_dec
    bl   print_inline
    db   ' bytes free', 13, 10, 0
    align 2
df_done:
    pop  {r4, r5, pc}

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
    movw r0, #((VARS + V_NAME) & 0xffff)
    movt r0, #((VARS + V_NAME) >> 16)
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
    add  r4, r4, #FLASH_BASE    ; its bytes through XIP
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
    movw r1, #((DIRBUF + 32) & 0xffff)
    movt r1, #((DIRBUF + 32) >> 16)
    subs r2, r0, r1
    lsrs r2, r2, #5
    adds r2, r2, #1             ; its number for boot
    movw r1, #(DIRBUF & 0xffff)
    movt r1, #(DIRBUF >> 16)
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
    movw r5, #(SYSINFO & 0xffff)
    movt r5, #(SYSINFO >> 16)
    ldr  r4, [r5]               ; CHIP_ID
    bl   print_inline
    db   'board     ', 0
    align 2
    bl   put_board
    bl   print_inline
    db   13, 10, 'chip      ', 0
    align 2
    lsrs r0, r4, #12
    uxth r0, r0
    cmp  r0, #4
    bne  ci_other
    ldr  r0, [r5, #4]           ; PACKAGE_SEL: 0 the RP2350A (the Pico 2), 1 the RP2350B
    tst  r0, #1
    bne  ci_b
    bl   print_inline
    db   'RP2350A (QFN-60)', 0
    align 2
    b    ci_rev
ci_b:
    bl   print_inline
    db   'RP2350B (QFN-80)', 0
    align 2
ci_rev:
    bl   print_inline
    db   ', revision ', 0
    align 2
    lsrs r0, r4, #28
    bl   put_dec
    bl   print_inline
    db   ' (CHIP_ID 0x', 0
    align 2
    b    ci_id
ci_other:
    bl   print_inline
    db   'not an RP2350 (CHIP_ID 0x', 0
    align 2
ci_id:
    mov  r0, r4
    bl   put_hex8
    bl   print_inline
    db   ')', 13, 10, 'cores     Arm Cortex-M33 (CPUID 0x', 0
    align 2
    movw r0, #(SCB_CPUID & 0xffff)
    movt r0, #(SCB_CPUID >> 16)
    ldr  r0, [r0]
    bl   put_hex8
    bl   print_inline
    db   '), 48 MHz (PLL_USB from the crystal)', 13, 10, 0
    align 2
    movs r0, #0x10
    ldr  r4, [r0]               ; the boot ROM: 'M', 'u', 2, its version
    bic  r0, r4, #0xff000000
    movw r1, #0x754d
    movt r1, #0x0002
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
    movw r0, #(RAM_BASE & 0xffff)
    movt r0, #(RAM_BASE >> 16)
    bl   put_hex8
    bl   print_inline
    db   ', ', 0
    align 2
    ldr  r0, lit_size2
    bl   put_dec
    bl   print_inline
    db   ' bytes', 13, 10, 'files     the flash from 0x10100000 to 0x103FE000 (behind: the WiFi network)', 13, 10, 0
    align 2
    pop  {r4, r5, pc}

    align 4
lit_size2:  dd image_end - vectors

; reset: the last byte out of the UART, then SYSRESETREQ
cmd_reset:
    bl   print_inline
    db   'reset', 13, 10, 0
    align 2
    bl   usb_flush                  ; the line to the host over USB too, and a moment for the PC to take it before the
    movs r0, #20                    ; device goes away (else Windows drops it)
    bl   wait_byte
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
cr_wait:
    ldr  r2, [r1, #UARTFR]
    tst  r2, #UARTFR_BUSY
    bne  cr_wait
    movw r1, #(SCB_AIRCR & 0xffff)
    movt r1, #(SCB_AIRCR >> 16)
    movw r0, #(AIRCR_RESET & 0xffff)
    movt r0, #(AIRCR_RESET >> 16)
    dsb
    str  r0, [r1]
cr_hang:
    b    cr_hang

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
    movw r4, #(PKT & 0xffff)
    movt r4, #(PKT >> 16)
    cmp  r0, #0
    bne  rp_head
rp_wait:
    movw r0, #1000
    bl   wait_byte
    cmp  r0, #0
    blt  rp_idle
    cmp  r0, #2
    bne  rp_wait                ; other bytes: left out
rp_head:
    movs r5, #1
rp_hbyte:
    movw r0, #500
    bl   wait_byte
    cmp  r0, #0
    blt  rp_broken
    strb r0, [r4, r5]           ; the command and the length at PKT+1
    adds r5, r5, #1
    cmp  r5, #4
    blt  rp_hbyte
    ldrh r6, [r4, #2]           ; the length
    movw r0, #1100
    cmp  r6, r0
    bhi  rp_broken
    adds r6, r6, #4             ; the data and the CRC
    movs r5, #0
rp_dbyte:
    cmp  r5, r6
    beq  rp_check
    movw r0, #500
    bl   wait_byte
    cmp  r0, #0
    blt  rp_broken
    add  r1, r4, #4
    strb r0, [r1, r5]
    adds r5, r5, #1
    b    rp_dbyte
rp_check:
    subs r6, r6, #4
    movs r0, #0
    add  r1, r4, #1
    add  r2, r6, #3
    bl   crc32
    add  r1, r4, #4
    add  r1, r1, r6             ; the CRC behind the data (it need not be at a whole word)
    ldrb r2, [r1]
    ldrb r3, [r1, #1]
    orr  r2, r2, r3, lsl #8
    ldrb r3, [r1, #2]
    orr  r2, r2, r3, lsl #16
    ldrb r3, [r1, #3]
    orr  r2, r2, r3, lsl #24
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

; the packet r0 (its command) with the r2 bytes at r1
send_packet:
    push {r4, r5, r6, r7, lr}
    ; for file_write of a program (api_file_write): the answer kept, nothing sent
    movw r4, #(VARS & 0xffff)
    movt r4, #(VARS >> 16)
    ldr  r3, [r4, #V_FQUIET]
    cbz  r3, sp_send
    str  r0, [r4, #V_FQUIET]
    str  r1, [r4, #V_FTEXT]
    pop  {r4, r5, r6, r7, pc}
sp_send:
    mov  r5, r1
    mov  r6, r2
    movw r4, #(OUT & 0xffff)
    movt r4, #(OUT >> 16)
    strb r0, [r4, #1]
    strh r2, [r4, #2]
    movs r0, #0
    add  r1, r4, #1
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
    add  r4, r4, r5
    adds r4, r4, #2
    bic  r4, r4, #1
    adds r4, r4, #1
    str  r4, [sp, #8]
    pop  {r4, r5, pc}

; the packet in PKT; r0 1 when it was Q (back to the terminal), else 0
do_packet:
    push {r4, lr}
    movw r4, #(PKT & 0xffff)
    movt r4, #(PKT >> 16)
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
    db   'the UART of the Pico 2 stays at 115200 baud', 0
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

; I: the JEDEC id of the flash (4 bytes: the maker, the type, the size as a power of two, 0), as on the ESP32: the
; flash out of XIP (flash_open; interrupts off meanwhile, the console runs from the RAM), the direct mode of the QMI
; (DIRECT_CSR: EN, a slow clock, ASSERT_CS0N), the command 0x9F and three bytes through DIRECT_TX and DIRECT_RX (each
; byte waits until RXEMPTY is 0), the direct mode off, XIP again (flash_close); as flash_do_cmd of the Pico SDK
pk_ident:
    push {r4, r5, r6, r7, lr}
    cpsid i
    bl   flash_open
    ldr  r4, pki_qmi
    ldr  r5, pki_csr                ; CLKDIV 30, EN
    str  r5, [r4]
    adds r0, r5, #4                 ; ASSERT_CS0N: CS low
    str  r0, [r4]
    movs r7, #0                     ; the id
    movs r1, #0x9F
    movs r2, #0                     ; the byte
pki_byte:
    str  r1, [r4, #4]               ; DIRECT_TX: 8 bits, single, pushed to RX
pki_wait:
    ldr  r0, [r4]                   ; DIRECT_CSR: bit 16 RXEMPTY
    lsls r0, r0, #15
    bmi  pki_wait
    ldr  r0, [r4, #8]               ; DIRECT_RX
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
    str  r5, [r4]                   ; CS high
    subs r0, r5, #1
    str  r0, [r4]                   ; the direct mode off
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
pki_qmi: dd 0x400D0000              ; QMI: +0 DIRECT_CSR, +4 DIRECT_TX, +8 DIRECT_RX
pki_csr: dd (30 << 22) | 1          ; CLKDIV 30, EN

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
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r0, [r0, #V_FSOK]
    cmp  r0, #0
    bne  pnf_ok
    bl   send_err_inline
    db   'no file system (format)', 0
    align 2
    movs r0, #0
pnf_ok:
    pop  {pc}

; the length of the data of the packet in r0
pk_len:
    movw r0, #(PKT & 0xffff)
    movt r0, #(PKT >> 16)
    ldrh r0, [r0, #2]
    bx   lr

; F: the files, the bytes in use, the bytes free, the name of the program for boot
pk_free:
    push {r4, r5, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pf_done
    movw r4, #(OUT & 0xffff)
    movt r4, #(OUT >> 16)
    adds r4, r4, #4             ; the data of the answer (OUT + 1 .. 3 is its head)
    bl   dir_used
    str  r1, [r4]
    str  r0, [r4, #4]
    movw r1, #((FS_END - FS_FIRST) * 4096 & 0xffff)
    movt r1, #((FS_END - FS_FIRST) * 4096 >> 16)
    subs r1, r1, r0
    str  r1, [r4, #8]
    movs r0, #0
    movs r1, #12
pf_zero:
    str  r0, [r4, r1]
    adds r1, r1, #4
    cmp  r1, #32
    blt  pf_zero
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
    ldr  r1, [r0, #12]          ; the program for boot: its entry + 1
    cmp  r1, #0
    beq  pf_send
    cmp  r1, #ENTRIES
    bhi  pf_send
    add  r0, r0, r1, lsl #5     ; DIRBUF + 32 * (entry + 1): the entry
    movs r1, #0
pf_name:
    ldrb r2, [r0, r1]
    add  r3, r4, #12
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

; L: name, length, CRC-32 of each file (into PAGEBUF: up to 64 * 28 bytes)
pk_list:
    push {r4, r5, r6, r7, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pl_done
    movw r4, #((DIRBUF + 32) & 0xffff)
    movt r4, #((DIRBUF + 32) >> 16)
    movw r5, #(PAGEBUF & 0xffff)
    movt r5, #(PAGEBUF >> 16)
    movs r6, #0                 ; the bytes of the answer
    movs r7, #0                 ; the entry
pl_next:
    ldrb r0, [r4]
    cmp  r0, #0
    beq  pl_skip
    movs r1, #0
pl_word:
    ldr  r0, [r4, r1]
    add  r2, r5, r6
    str  r0, [r2, r1]
    adds r1, r1, #4
    cmp  r1, #20
    blt  pl_word
    add  r2, r5, r6
    ldr  r0, [r4, #24]
    str  r0, [r2, #20]
    ldr  r0, [r4, #28]
    str  r0, [r2, #24]
    adds r6, r6, #28
pl_skip:
    adds r4, r4, #32
    adds r7, r7, #1
    cmp  r7, #ENTRIES
    blt  pl_next
    movs r0, #'l'
    mov  r1, r5
    mov  r2, r6
    bl   send_packet
pl_done:
    pop  {r4, r5, r6, r7, pc}

; O name length crc: a file opens for writing, its sectors are erased
pk_open:
    push {r4, r5, r6, r7, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  po_done
    bl   pk_len
    cmp  r0, #28
    bne  po_size_err
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
    movw r7, #(VARS & 0xffff)
    movt r7, #(VARS >> 16)
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
    addw r0, r6, #4095
    lsrs r0, r0, #12            ; the sectors
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
    movw r1, #((VARS + V_ONAME) & 0xffff)
    movt r1, #((VARS + V_ONAME) >> 16)
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

; W offset bytes: a piece of the open file (its offset a multiple of 256: the pages of the flash)
pk_write:
    push {r4, r5, r6, r7, lr}
    movw r7, #(VARS & 0xffff)
    movt r7, #(VARS >> 16)
    ldr  r0, [r7, #V_OPEN]
    cmp  r0, #0
    beq  pw_notopen
    bl   pk_len
    subs r5, r0, #4             ; the bytes
    blt  pw_bad
    movw r0, #1024
    cmp  r5, r0
    bgt  pw_bad
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
    ldr  r6, [r4]               ; the offset
    ldr  r0, [r7, #V_OLAST]
    cmp  r0, r6
    bne  pw_new
    ldr  r0, [r7, #V_OWRITTEN]
    add  r1, r6, r5
    cmp  r0, r1
    bne  pw_new
    bl   send_ok                ; the last piece again (its k was lost)
    b    pw_done
pw_new:
    ldr  r0, [r7, #V_OWRITTEN]
    cmp  r0, r6
    bne  pw_order
    tst  r6, #255
    bne  pw_order
    add  r1, r6, r5
    ldr  r0, [r7, #V_OLEN]
    cmp  r1, r0
    bhi  pw_beyond
    cmp  r5, #0
    beq  pw_ok
    ; the piece into PAGEBUF, 0xFF behind it up to a whole page
    movw r0, #(PAGEBUF & 0xffff)
    movt r0, #(PAGEBUF >> 16)
    movs r1, #0
pw_copy:
    cmp  r1, r5
    bge  pw_fill
    add  r2, r4, #4
    ldrb r3, [r2, r1]
    strb r3, [r0, r1]
    adds r1, r1, #1
    b    pw_copy
pw_fill:
    tst  r1, #255
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
    add  r0, r0, r6
    movw r1, #(PAGEBUF & 0xffff)
    movt r1, #(PAGEBUF >> 16)
    bl   flash_program
    bl   flash_close
pw_ok:
    add  r0, r6, r5
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

; C: the open file read back, its CRC-32 checked, then into the directory
pk_close:
    push {r4, r5, r6, r7, lr}
    movw r7, #(VARS & 0xffff)
    movt r7, #(VARS >> 16)
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
    add  r1, r1, #FLASH_BASE
    ldr  r2, [r7, #V_OLEN]
    movs r0, #0
    bl   crc32                  ; what is in the flash
    ldr  r1, [r7, #V_OCRC]
    cmp  r0, r1
    bne  pc_crc
    ; the entry: the name, the first sector, the length, the CRC
    ldr  r4, [r7, #V_OENTRY]
    movw r1, #((VARS + V_ONAME) & 0xffff)
    movt r1, #((VARS + V_ONAME) >> 16)
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

; G name offset count: bytes of a file
pk_get:
    push {r4, r5, r6, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pg_done
    bl   pk_len
    cmp  r0, #28
    bne  pg_bad
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
    movs r0, #0
    strb r0, [r4, #19]
    mov  r0, r4
    bl   find_entry
    cmp  r0, #0
    beq  pg_nofile
    ldr  r5, [r4, #20]          ; the offset
    ldr  r6, [r4, #24]          ; the count
    tst  r5, #3
    bne  pg_bad
    movw r1, #1024
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
    add  r1, r1, #FLASH_BASE
    add  r1, r1, r5
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

; D name: the file away
pk_delete:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pd_done
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
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

; B name: the program for boot (zeros: none)
pk_boot:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  pb_done
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
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
    movw r1, #((DIRBUF + 32) & 0xffff)
    movt r1, #((DIRBUF + 32) >> 16)
    subs r1, r0, r1
    lsrs r1, r1, #5
    adds r1, r1, #1
pb_set:
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
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

; the address r0 and the count r1 of Y and K valid (address a multiple of 4, both in the flash of 4 MB)? r0 1 or 0
flash_range_ok:
    tst  r0, #3
    bne  fro_no
    movw r2, #0
    movt r2, #0x40              ; 4 MB
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

; Y address count: the bytes of the flash there (up to 1024)
pk_flash:
    push {r4, r5, lr}
    bl   pk_len
    cmp  r0, #8
    bne  py_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]
    ldr  r5, [r0, #4]
    movw r0, #1024
    cmp  r5, r0
    bhi  py_bad
    mov  r0, r4
    mov  r1, r5
    bl   flash_range_ok
    cmp  r0, #0
    beq  py_bad
    movs r0, #'d'
    add  r1, r4, #FLASH_BASE
    mov  r2, r5
    bl   send_packet
    pop  {r4, r5, pc}
py_bad:
    bl   send_err_inline
    db   'Y: an address in the flash (a multiple of 4), up to 1024 bytes', 0
    align 2
    pop  {r4, r5, pc}

; K address count: the CRC-32 of count bytes of the flash at address
pk_crc:
    push {r4, r5, lr}
    bl   pk_len
    cmp  r0, #8
    bne  pk_crc_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]
    ldr  r5, [r0, #4]
    mov  r0, r4
    mov  r1, r5
    bl   flash_range_ok
    cmp  r0, #0
    beq  pk_crc_bad
    movs r0, #0
    add  r1, r4, #FLASH_BASE
    mov  r2, r5
    bl   crc32
    movw r1, #(PAGEBUF & 0xffff)
    movt r1, #(PAGEBUF >> 16)
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


; ---------- programs ----------

; the table of the functions for programs at JT (their addresses in the RAM, with the Thumb bit), and at STUBS the
; same functions to call: 16 bytes of code each (jt_stub and the address), for a program that calls a function at a
; fixed address (aBelle: def print(s: pchar) at STUBS + 0x50). r3 stays (the fourth argument), ip changes (as the Arm
; ABI allows it in a call)
jt_init:
    push {r4, lr}
    movw r0, #(JT & 0xffff)
    movt r0, #(JT >> 16)
    adr  r1, jt_lits
    movs r2, #0
ji_next:
    ldr  r3, [r1, r2]
    str  r3, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #56
    blt  ji_next
    movw r0, #(STUBS & 0xffff)
    movt r0, #(STUBS >> 16)
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
    adds r0, r0, #16
    adds r2, r2, #4
    cmp  r2, #56
    blt  ji_stub
    pop  {r4, pc}

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
; it was stopped). Its stack from PROG_HI down; UART0 interrupts while it runs (Ctrl+C, the ring)
run_entry:
    push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
    movw r4, #(VARS & 0xffff)
    movt r4, #(VARS >> 16)
    str  r1, [r4, #V_ARGS]
    mov  r2, sp
    str  r2, [r4, #V_CSP]
    movs r2, #0
    str  r2, [r4, #V_RHEAD]
    str  r2, [r4, #V_RTAIL]
    movs r2, #1
    str  r2, [r4, #V_RUN]
    orr  r5, r0, #1
    bl   irq_on
    movw r0, #(PROG_HI & 0xffff)
    movt r0, #(PROG_HI >> 16)
    mov  sp, r0
    ldr  r0, [r4, #V_ARGS]
    blx  r5
; the end of a program: r0 its code (bx lr, or exit from any depth)
prog_finish:
    mov  r6, r0
    bl   irq_off
    movw r4, #(VARS & 0xffff)
    movt r4, #(VARS >> 16)
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
    pop  {r4, r5, r6, r7, r8, r9, r10, r11, pc}
; a program stopped (fault, Ctrl+C: they have said so): the console as before the program
prog_abort:
    bl   irq_off
    bl   wl_abort               ; CS of the WiFi chip high (Ctrl+C in the middle of a transfer)
    movw r4, #(VARS & 0xffff)
    movt r4, #(VARS >> 16)
    ldr  r1, [r4, #V_CSP]
    mov  sp, r1
    movs r1, #0
    str  r1, [r4, #V_RUN]
    movs r0, #0
    subs r0, r0, #1
    bl   mon_end                ; under the debug monitor: x and -1
    movs r0, #0
    subs r0, r0, #1
    pop  {r4, r5, r6, r7, r8, r9, r10, r11, pc}

; r0 as a signed decimal number
put_int:
    cmp  r0, #0
    bge  put_dec
    push {r4, lr}
    mov  r4, r0
    movs r0, #'-'
    bl   put_char
    rsbs r0, r4, #0
    bl   put_dec
    pop  {r4, pc}

; UART0 interrupts for the bytes that come (the FIFO half full, or a pause after a byte)
irq_on:
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
    movw r0, #0x7ff
    str  r0, [r1, #UARTICR]
    movs r0, #(1 << 4) | (1 << 6)
    str  r0, [r1, #UARTIMSC]
    movw r1, #(NVIC_ISER1 & 0xffff)
    movt r1, #(NVIC_ISER1 >> 16)
    movs r0, #2
    str  r0, [r1]
    cpsie i
    bx   lr

irq_off:
    movw r1, #(UART0 & 0xffff)
    movt r1, #(UART0 >> 16)
    movs r0, #0
    str  r0, [r1, #UARTIMSC]
    movw r1, #(NVIC_ICER1 & 0xffff)
    movt r1, #(NVIC_ICER1 >> 16)
    movs r0, #2
    str  r0, [r1]
    dsb
    isb
    bx   lr

; the interrupt of UART0 while a program runs: the bytes into the ring (a full ring drops them); Ctrl+C stops the
; program (its frame returns to prog_abort)
uart_irq:
    push {r4, r5, r6, lr}
    movw r4, #(UART0 & 0xffff)
    movt r4, #(UART0 >> 16)
    movw r5, #(VARS & 0xffff)
    movt r5, #(VARS >> 16)
ui_next:
    ldr  r0, [r4, #UARTFR]
    tst  r0, #UARTFR_RXFE
    bne  ui_done
    ldr  r0, [r4, #UARTDR]
    tst  r0, #UARTDR_ERRORS
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
    movw r2, #(RING & 0xffff)
    movt r2, #(RING >> 16)
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
    movw r0, #0x7ff
    str  r0, [r4, #UARTICR]
    pop  {r4, r5, r6, pc}

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
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    ldr  r2, [r1, #V_RTAIL]
    ldr  r3, [r1, #V_RHEAD]
    cmp  r2, r3
    beq  ap_none
    movw r0, #(RING & 0xffff)
    movt r0, #(RING >> 16)
    ldrb r0, [r0, r2]
    adds r2, r2, #1
    uxtb r2, r2
    str  r2, [r1, #V_RTAIL]
    bx   lr
ap_none:
    push {lr}
    bl   usb_getc
    pop  {pc}

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

; millis(): the milliseconds of TIMER0 (since the chip started; after 49 days 0 again): (H * 2^32 + L) / 1000 =
; H * 4294967 + L / 1000 + (H * 296 + L mod 1000) / 1000
api_millis:
    push {r4, r5, lr}
    movw r3, #(TIMER0 & 0xffff)
    movt r3, #(TIMER0 >> 16)
am_read:
    ldr  r4, [r3, #0x24]        ; TIMERAWH
    ldr  r5, [r3, #0x28]        ; TIMERAWL
    ldr  r0, [r3, #0x24]
    cmp  r0, r4
    bne  am_read                ; L wrapped meanwhile
    movw r2, #1000
    udiv r0, r5, r2             ; L / 1000
    mul  r1, r0, r2
    subs r1, r5, r1             ; L mod 1000
    movw r3, #296
    mul  r3, r4, r3
    add  r1, r1, r3
    udiv r1, r1, r2
    add  r0, r0, r1
    movw r3, #(4294967 & 0xffff)
    movt r3, #(4294967 >> 16)
    mul  r3, r4, r3
    add  r0, r0, r3
    pop  {r4, r5, pc}

; args(): the text of the arguments
api_args:
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r0, [r0, #V_ARGS]
    bx   lr

; the entry of the file with the name r0 (a text): r0, 0 when there is none (or no file system)
entry_of_text:
    push {lr}
    bl   name_field
    cmp  r0, #0
    ble  et_none
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  et_none
    add  r0, r0, #V_NAME
    bl   find_entry
    pop  {pc}
et_none:
    movs r0, #0
    pop  {pc}

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
    add  r4, r4, #FLASH_BASE
    add  r4, r4, r6
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
    push {r4, r5, r6, r7, r8, lr}
    mov  r5, r1                 ; the bytes
    mov  r6, r2                 ; how many
    movw r7, #(VARS & 0xffff)
    movt r7, #(VARS >> 16)
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16) ; the data of the packet
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
    mov  r8, r5                 ; the start of the bytes
afw_piece:
    cbz  r6, afw_close
    sub  r0, r5, r8
    str  r0, [r4]               ; the offset of the piece
    mov  r2, #1024
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
    b    afw_err3
afw_close:
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
    pop  {r4, r5, r6, r7, r8, pc}

; r0 the length of the data of the packet in PKT; its answer kept, not sent
afw_len:
    movw r1, #(PKT & 0xffff)
    movt r1, #(PKT >> 16)
    strh r0, [r1, #2]
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    movs r0, #1
    str  r0, [r1, #V_FQUIET]
    bx   lr

; the program of the entry r0 into the RAM of the programs: r0 its entry, r1 0; or r1 what is wrong (1 the file is
; damaged, 2 it is no program, 3 a segment outside the RAM of the programs, 4 the entry outside it)
load_file:
    push {r4, r5, r6, r7, r8, r9, r10, lr}
    ldr  r5, [r0, #24]          ; the length
    ldr  r6, [r0, #28]          ; the CRC-32
    ldr  r4, [r0, #20]
    lsls r4, r4, #12
    add  r4, r4, #FLASH_BASE    ; its bytes
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
    ldr  r7, [r4, #4]           ; the entry
    movs r8, #24                ; the first segment
lf_seg:
    cmp  r6, #0
    beq  lf_entry
    add  r0, r8, #8
    cmp  r0, r5
    bhi  lf_noprog
    ldr  r9, [r4, r8]           ; its address
    add  r0, r4, r8
    ldr  r10, [r0, #4]          ; its length
    cmp  r10, r5
    bhi  lf_noprog
    add  r0, r8, #8
    add  r0, r0, r10
    cmp  r0, r5
    bhi  lf_noprog              ; beyond the end of the file
    tst  r9, #3
    bne  lf_where
    movw r0, #(PROG_LO & 0xffff)
    movt r0, #(PROG_LO >> 16)
    cmp  r9, r0
    blo  lf_where
    add  r0, r9, r10
    movw r1, #(PROG_HI & 0xffff)
    movt r1, #(PROG_HI >> 16)
    cmp  r0, r1
    bhi  lf_where
    add  r1, r4, r8
    adds r1, r1, #8             ; its bytes
    movs r2, #0
lf_copy:
    cmp  r2, r10
    bge  lf_next
    ldrb r3, [r1, r2]
    strb r3, [r9, r2]
    adds r2, r2, #1
    b    lf_copy
lf_next:
    add  r8, r8, #8
    add  r8, r8, r10
    subs r6, r6, #1
    b    lf_seg
lf_entry:
    movw r0, #(PROG_LO & 0xffff)
    movt r0, #(PROG_LO >> 16)
    cmp  r7, r0
    blo  lf_badentry
    movw r0, #(PROG_HI & 0xffff)
    movt r0, #(PROG_HI >> 16)
    cmp  r7, r0
    bhs  lf_badentry
    dsb
    isb
    mov  r0, r7
    movs r1, #0
    pop  {r4, r5, r6, r7, r8, r9, r10, pc}
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
    pop  {r4, r5, r6, r7, r8, r9, r10, pc}

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
    db   'a part of the program lies outside the RAM of the programs (0x20000000 .. 0x2006FFFF)', 13, 10, 0
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
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    ldr  r1, [r0, #V_FSOK]
    cmp  r1, #0
    beq  crn_nofile
    add  r0, r0, #V_NAME
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
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    str  r6, [r0, #V_QUIET]
    cmp  r6, #0
    bne  crn_start
    bl   print_inline
    db   'Running ', 0
    align 2
    movw r0, #((VARS + V_NAME) & 0xffff)
    movt r0, #((VARS + V_NAME) >> 16)
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
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
    ldr  r1, [r0, #12]
    cmp  r1, #0
    beq  cb_none
    add  r0, r0, r1, lsl #5
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
    movw r1, #((DIRBUF + 32) & 0xffff)
    movt r1, #((DIRBUF + 32) >> 16)
    subs r1, r0, r1
    lsrs r1, r1, #5
    adds r1, r1, #1
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
    str  r1, [r0, #12]
    bl   dir_save
    cmp  r0, #0
    bne  cb_err
    movw r0, #((VARS + V_NAME) & 0xffff)
    movt r0, #((VARS + V_NAME) >> 16)
    bl   put_text
    bl   print_inline
    db   ' starts after every reset now (noboot: none)', 13, 10, 0
    align 2
    b    cb_done
cb_err:
    bl   flash_error
cb_done:
    pop  {r4, pc}

; noboot: no program after a reset
cmd_noboot:
    push {lr}
    bl   need_fs
    cmp  r0, #0
    beq  cnb_done
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
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

; after the start: the program for boot, after a second without a key
autostart:
    push {r4, lr}
    movw r0, #(DIRBUF & 0xffff)
    movt r0, #(DIRBUF >> 16)
    ldr  r1, [r0, #12]
    cmp  r1, #0
    beq  as_done
    cmp  r1, #ENTRIES
    bhi  as_done
    add  r4, r0, r1, lsl #5     ; its entry
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
    movw r0, #1000
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
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    movs r2, #0
    str  r2, [r1, #V_QUIET]
    add  r1, r1, #V_EMPTY
    bl   run_entry
as_done:
    pop  {r4, pc}

; R address bytes: whole words (up to 1024) into the RAM of the programs
pk_ram:
    push {r4, r5, lr}
    bl   pk_len
    subs r5, r0, #4             ; the bytes
    blt  pr_bad
    movw r1, #1024
    cmp  r5, r1
    bhi  pr_bad
    tst  r5, #3
    bne  pr_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]               ; the address
    tst  r4, #3
    bne  pr_where
    movw r1, #(PROG_LO & 0xffff)
    movt r1, #(PROG_LO >> 16)
    cmp  r4, r1
    blo  pr_where
    add  r1, r4, r5
    movw r2, #(PROG_HI & 0xffff)
    movt r2, #(PROG_HI >> 16)
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
    db   'R: the RAM of the programs is 0x20000000 .. 0x2006FFFF', 0
    align 2
    pop  {r4, r5, pc}

; E entry: the program that R put into the RAM starts (k first); r0 2 (a program ran), or 0 (an error was sent)
pk_exec:
    push {r4, lr}
    bl   pk_len
    cmp  r0, #4
    bne  pe_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]
    movw r1, #(PROG_LO & 0xffff)
    movt r1, #(PROG_LO >> 16)
    cmp  r4, r1
    blo  pe_bad
    movw r1, #(PROG_HI & 0xffff)
    movt r1, #(PROG_HI >> 16)
    cmp  r4, r1
    bhs  pe_bad
    bl   send_ok
    dsb
    isb
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    add  r1, r1, #V_EMPTY
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

; X name: the program starts (k first); r0 2 (a program ran), or 0 (an error was sent)
pk_run:
    push {r4, lr}
    bl   pk_need_fs
    cmp  r0, #0
    beq  px_none
    movw r4, #((PKT + 4) & 0xffff)
    movt r4, #((PKT + 4) >> 16)
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
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    add  r1, r1, #V_EMPTY
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
    db   'this is not a program for the RAM of the Pico 2 (or the file is damaged)', 0
    align 2
px_none:
    movs r0, #0
    pop  {r4, pc}

; ---------- the console over the USB cable of the board ----------

.include "../pico/console_usb.asm"

; ---------- the debug monitor: programs under the debugger over the console ----------

.include "console_mon.asm"

; ---------- the board: one with WiFi (W)? ----------

.include "../pico/console_wifi.asm"

; ---------- no ESP8285 on a Pico 2 (the names console_wifi.asm calls) ----------

.include "console_esp_none.asm"

    align 4
image_end:
