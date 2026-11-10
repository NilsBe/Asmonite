; ESP32-S3: "Hello, world!" once a second over the USB port of the chip: the same cable as for the debugger, it
; shows on the COM port of the chip ("USB Serial Device", 303A:1001).
;
;   1. plug in the board at the USB port of the chip (Debug > Debug targets: "Set up the USB JTAG" once for each
;      board)
;   2. press F9: the debugger loads the program into the RAM and runs it; the tab Serial next to the output window
;      connects to the COM port of the chip and shows the text
; The USB port of the chip has two parts: the JTAG of the debugger and a serial port (CDC); the program writes to
; the second one, so the debugger and the terminal do not get in each other's way.
;
; The peripheral USB Serial/JTAG (ESP32-S3 Technical Reference Manual, chapter "USB Serial/JTAG Controller";
; ESP-IDF components/soc/esp32s3/include/soc/usb_serial_jtag_reg.h), base 0x60038000:
;   - USB_SERIAL_JTAG_EP1_REG (+0x00): a byte written there goes into the FIFO to the host (64 bytes)
;   - USB_SERIAL_JTAG_EP1_CONF_REG (+0x04): bit 1 SERIAL_IN_EP_DATA_FREE = there is room in the FIFO; writing
;     bit 0 (WR_DONE) sends what is in the FIFO
; When no terminal has the port open, the FIFO stays full: after 10 ms without room the rest of the text is dropped,
; the program goes on.
;
; The text: the RAM of the program (0x40378000) is the same memory on two buses. At its IRAM address the core
; fetches instructions and reads and writes words only (l8ui there stops with a LoadStoreError, as on the ESP32);
; on the data bus the same byte is 0x6F0000 lower (0x3FC88000 for 0x40378000), and l8ui works there. So the address
; of the text goes down by 0x6F0000 before it is read.
;
; The core runs at 40 MHz in the download mode of the boot ROM (the debugger starts it there): 40,000,000 cycles of
; CCOUNT are a second.
.target esp32s3
.arch xtensa
.imagebase 0x40378000

lit_usb:      dd 0x60038000          ; USB Serial/JTAG
lit_message:  dd message
lit_ioffset:  dd 0x6F0000            ; IRAM address - this = the same byte on the data bus
lit_second:   dd 40000000            ; one second in cycles
lit_timeout:  dd 400000              ; 10 ms

_start:
  l32r  a2, lit_usb
  l32r  a7, lit_second
  l32r  a12, lit_timeout
  l32r  a13, lit_ioffset

again:
  l32r  a3, lit_message
  sub   a3, a3, a13                  ; the text through the data bus
next_byte:
  l8ui  a5, a3, 0                    ; a byte of the text
  beqz  a5, flush
  rsr   a9, ccount
room:
  l32i  a11, a2, 4                   ; EP1_CONF
  bbsi  a11, 1, put                  ; SERIAL_IN_EP_DATA_FREE: room in the FIFO
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a12, room
  j     flush                        ; nobody reads: the rest is dropped
put:
  s32i  a5, a2, 0                    ; EP1: the byte into the FIFO
  addi  a3, a3, 1
  j     next_byte

flush:
  movi  a11, 1
  s32i  a11, a2, 4                   ; WR_DONE: the FIFO goes to the host
  memw
  rsr   a9, ccount
wait:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait
  j     again

  align 4
message:
  db    'Hello, world!', 13, 10, 0
