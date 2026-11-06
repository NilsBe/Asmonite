; ESP32 (the original, Xtensa LX6): "Hello, world!" through UART0 once a second.
; UART0 is the serial port of the board: its TX (GPIO 1) goes to the USB serial chip, so a terminal on the COM
; port of the board shows the text (115200 baud, 8N1; the boot ROM has set UART0 up). Press F9: the program goes
; into the RAM under the debug monitor of Asmonite, which has the port then: the text shows in the output window
; ("UART0: Hello, world!"). The program does not end: put a breakpoint into its loop to stop it (a running program
; cannot be paused yet), or press EN on the board.
;
; The program and its text are in the IRAM (0x40080000): the core reads it only in words of 32 bits (l8ui there is
; a LoadStoreError), so the text is read word by word and taken apart with extui, the lowest byte first.
;
; UART0 (ESP32 Technical Reference Manual, chapter "UART Controller"; ESP-IDF
; components/soc/esp32/include/soc/uart_reg.h): UART_FIFO_REG at 0x3FF40000 takes a byte to send,
; UART_STATUS_REG at 0x3FF4001C has in bits 23..16 (TXFIFO_CNT) how many bytes wait in the FIFO of 128.
.target esp32
.arch xtensa
.imagebase 0x40080000

lit_uart0:    dd 0x3FF40000
lit_message:  dd message
lit_second:   dd 40000000            ; one second in cycles (40 MHz)

_start:
  l32r  a2, lit_uart0
  l32r  a7, lit_second
  movi  a6, 120                      ; room for one more byte while fewer than 120 wait

again:
  l32r  a3, lit_message
next_word:
  l32i  a4, a3, 0                    ; four bytes of the text
  movi  a8, 4
next_byte:
  extui a5, a4, 0, 8                 ; the lowest one
  beqz  a5, sent
fifo_full:
  l32i  a11, a2, 0x1C                ; UART_STATUS_REG
  extui a11, a11, 16, 8              ; TXFIFO_CNT
  bgeu  a11, a6, fifo_full
  s32i  a5, a2, 0                    ; UART_FIFO_REG
  srli  a4, a4, 8
  addi  a8, a8, -1
  bnez  a8, next_byte
  addi  a3, a3, 4
  j     next_word

sent:
  rsr   a9, ccount
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait
  j     again

align 4
message:
  db    'Hello, world!', 13, 10, 0
