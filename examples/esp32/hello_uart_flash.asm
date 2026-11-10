; ESP32 (the original, Xtensa LX6): "Hello, world!" through UART0 once a second, from the flash: the program of
; hello_uart_ram.asm, at every start of the board.
;
;   1. plug in the board; no terminal may have its COM port open
;   2. press F9: Asmonite writes the program into the flash at 0x1000 as an image of the boot ROM with two
;      segments: the code for the IRAM (0x40080000) and the text of .data for the DRAM (0x3FFB0000). The boot ROM
;      copies both at every start and jumps to _start. Under the debugger it runs in the IRAM next to the monitor
;   3. without the debugger: the tab Serial next to the output window, Connect, Reset: the lines of the boot ROM,
;      then "Hello, world!" once a second
; The program replaces the firmware that was in the flash.
;
; As in blink_flash.asm the watchdogs go off at the start (else the chip resets after a few seconds); the core runs
; at 40 MHz here as well.
;
; The registers: UART0 as in hello_uart_ram.asm; TIMG0 0x3FF5F000 and TIMG1 0x3FF60000: WDTCONFIG0 at 0x48,
; WDTWPROTECT at 0x64; RTC_CNTL 0x3FF48000: WDTCONFIG0 at 0x8C, WDTWPROTECT at 0xA4 (ESP32 Technical Reference
; Manual; ESP-IDF timer_group_reg.h, rtc_cntl_reg.h).
.target esp32 flash
.arch xtensa
.imagebase 0x40080000

lit_uart0:    dd 0x3FF40000
lit_message:  dd message
lit_second:   dd 40000000            ; one second in cycles (40 MHz)
lit_wdt_key:  dd 0x50D83AA1          ; the key that unlocks the watchdog registers
lit_timg0:    dd 0x3FF5F000          ; timer group 0
lit_timg1:    dd 0x3FF60000          ; timer group 1
lit_rtc_cntl: dd 0x3FF48000          ; RTC_CNTL

_start:
  ; the watchdogs off
  l32r  a2, lit_wdt_key
  movi  a3, 0
  l32r  a4, lit_timg0
  s32i  a2, a4, 0x64                 ; unlock
  s32i  a3, a4, 0x48                 ; WDTCONFIG0 = 0: off
  s32i  a3, a4, 0x64                 ; lock
  l32r  a4, lit_timg1
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_rtc_cntl
  s32i  a2, a4, 0xA4                 ; WDTWPROTECT: unlock
  s32i  a3, a4, 0x8C                 ; WDTCONFIG0 = 0
  s32i  a3, a4, 0xA4                 ; lock
  memw

  l32r  a2, lit_uart0
  l32r  a7, lit_second
  movi  a6, 120                      ; room for one more byte while fewer than 120 wait

again:
  l32r  a3, lit_message
next_byte:
  l8ui  a5, a3, 0                    ; a byte of the text (the DRAM: bytes are fine)
  beqz  a5, sent
fifo_full:
  l32i  a11, a2, 0x1C                ; UART_STATUS_REG
  extui a11, a11, 16, 8              ; TXFIFO_CNT
  bgeu  a11, a6, fifo_full
  s32i  a5, a2, 0                    ; UART_FIFO_REG
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
  db    'Hello, world!', 13, 10, 0
