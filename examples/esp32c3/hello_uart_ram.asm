; ESP32-C3: print "Hello, world!" once through UART0, then wait here.
; UART0 is normally initialized by the ESP ROM at 115200 baud. Its TX is the pin
; GPIO 21, not the USB port of the board: a USB-serial adapter at GPIO 21 shows
; the text. For output on the USB serial port (the COM port of the board) see
; blink_ram.asm.
; This is a RAM-debugging example; it does not write flash.
.target esp32c3
.arch riscv32
.imagebase 0x40380000

UART0_FIFO equ 0x60000000

_start:
    li   t0, UART0_FIFO
    la   t1, message

send_char:
    lbu  t2, 0(t1)
    beqz t2, finished
    sw   t2, 0(t0)
    addi t1, t1, 1
    j    send_char

finished:
    j    finished

message:
    db   'Hello, world!', 13, 10, 0
