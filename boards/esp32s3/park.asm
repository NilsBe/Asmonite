; The park program of the ESP32-S3: Erase Flash of the Board Manager writes it into the erased flash (at 0), so the
; board starts in a controlled way instead of restarting again and again ("invalid header: 0xffffffff"). It switches
; the watchdogs off as the console does (the boot ROM leaves them on after a start from the flash; the super watchdog
; feeds itself) and writes a line to the USB port of the chip every 3 seconds; when nobody reads, the line is
; dropped. The Board Manager and the tab Serial know the board by it ("erased by Asmonite"). Prepare Board puts the
; console in its place.
;
; The registers as in boards\esp32s3\console.asm (watchdogs_off) and examples_internal\esp32s3\hello_usb_ram.asm
; (USB Serial/JTAG 0x60038000: EP1 +0, EP1_CONF +4 with bit 1 room in the FIFO, bit 0 WR_DONE). The text lies in the
; IRAM: it is read through the data bus, 0x6F0000 lower.
.target esp32s3 flash
.arch xtensa
.imagebase 0x40378000

lit_wdt_key:  dd 0x50D83AA1
lit_swd_key:  dd 0x8F1D312A          ; the key of the super watchdog
lit_bit31:    dd 0x80000000          ; SWD_AUTO_FEED_EN
lit_timg0:    dd 0x6001F000
lit_timg1:    dd 0x60020000
lit_rtc:      dd 0x60008000
lit_usb:      dd 0x60038000
lit_message:  dd message
lit_ioffset:  dd 0x6F0000
lit_pause:    dd 60000000            ; about 3 s at the 20 MHz the boot ROM leaves after a start from the flash
lit_timeout:  dd 200000              ; about 10 ms without room: nobody reads

_start:
  rsil  a2, 5                        ; no interrupts (the boot ROM left its own on)
  ; the watchdogs off
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
  s32i  a5, a4, 0xB4                 ; the super watchdog feeds itself
  s32i  a3, a4, 0xB8
  memw
  l32r  a2, lit_usb
  l32r  a7, lit_pause
  l32r  a12, lit_timeout
  l32r  a13, lit_ioffset

again:
  l32r  a3, lit_message
  sub   a3, a3, a13                  ; the text through the data bus
  movi  a8, 64                       ; the FIFO to the host after each 64 bytes (its size)
next_byte:
  l8ui  a5, a3, 0
  beqz  a5, flush
  bnez  a8, has_room
  movi  a11, 1
  s32i  a11, a2, 4                   ; WR_DONE: 64 bytes to the host
  memw
  movi  a8, 64
has_room:
  rsr   a9, ccount
room:
  l32i  a11, a2, 4                   ; EP1_CONF
  bbsi  a11, 1, put                  ; room in the FIFO
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a12, room
  j     flush                        ; nobody reads: the rest is dropped
put:
  s32i  a5, a2, 0                    ; EP1: a byte into the FIFO
  addi  a3, a3, 1
  addi  a8, a8, -1
  j     next_byte
flush:
  movi  a11, 1
  s32i  a11, a2, 4                   ; WR_DONE
  memw
  rsr   a9, ccount
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait
  j     again

  align 4
message:
  db    'Empty board: the flash was erased by Asmonite. "Prepare Board..." in the Board Manager puts the console '
  db    'on it.', 13, 10, 0
