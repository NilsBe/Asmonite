; The park program of the ESP32: Erase Flash of the Board Manager writes it into the erased flash (at 0x1000), so the
; board starts in a controlled way instead of restarting again and again ("flash read err, 1000"). It switches the
; watchdogs off (the boot ROM leaves them on after a start from the flash) and writes a line through UART0 every 3
; seconds; the Board Manager and the tab Serial know the board by it ("erased by Asmonite"). Prepare Board puts the
; console in its place.
;
; The registers as in examples_internal\esp32\hello_uart_flash.asm: UART0 0x3FF40000 (its FIFO on the AHB at
; 0x60000000), TIMG0 0x3FF5F000 and TIMG1 0x3FF60000 (WDTCONFIG0 +0x48, WDTWPROTECT +0x64), RTC_CNTL 0x3FF48000
; (WDTCONFIG0 +0x8C, WDTWPROTECT +0xA4).
.target esp32 flash
.arch xtensa
.imagebase 0x40080000

lit_uart0:    dd 0x3FF40000
lit_uart_ahb: dd 0x60000000
lit_message:  dd message
lit_pause:    dd 120000000           ; about 3 s at the 40 MHz of the core
lit_wdt_key:  dd 0x50D83AA1
lit_timg0:    dd 0x3FF5F000
lit_timg1:    dd 0x3FF60000
lit_rtc_cntl: dd 0x3FF48000

_start:
  ; the watchdogs off: unlock, WDTCONFIG0 = 0, lock
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
  l32r  a4, lit_rtc_cntl
  s32i  a2, a4, 0xA4
  s32i  a3, a4, 0x8C
  s32i  a3, a4, 0xA4
  memw
  l32r  a2, lit_uart0
  l32r  a4, lit_uart_ahb
  l32r  a7, lit_pause
  movi  a6, 120                      ; room for one more byte while fewer than 120 wait

again:
  l32r  a3, lit_message
next_byte:
  l8ui  a5, a3, 0                    ; a byte of the text (in the DRAM)
  beqz  a5, sent
fifo_full:
  l32i  a11, a2, 0x1C                ; UART_STATUS_REG: TXFIFO_CNT
  extui a11, a11, 16, 8
  bgeu  a11, a6, fifo_full
  s32i  a5, a4, 0                    ; UART_FIFO_REG (AHB)
  memw
  addi  a3, a3, 1
  j     next_byte
sent:
  rsr   a9, ccount
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait
  j     again

.data
message:
  db    'Empty board: the flash was erased by Asmonite. "Prepare Board..." in the Board Manager puts the console '
  db    'on it.', 13, 10, 0
